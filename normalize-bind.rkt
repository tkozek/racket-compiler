#lang racket

(require cpsc411/compiler-lib
         "common.rkt")

(provide normalize-bind)

;; (Imp-mf-lang v8 p) -> (Proc-imp-cmf-lang v8 p)
;; Compiles Imp-mf-lang v4 to Imp-cmf-lang v4, pushing set!
;; under begin and if so that the right-hand-side of each set!
;;is a simple value-producing operation.
(define (normalize-bind mf)
  (define (join-begin fx* tail)
    (match tail
      [`(begin
          ,fx2* ...
          ,tail)
       (make-begin (append fx2* fx*) tail)]
      [_ (make-begin fx* tail)]))
  (define (normalize-definitions definition)
    (match definition
      [`(define ,label (lambda ,alocs ,tail))
       `(define ,label (lambda ,alocs ,(normalize-tail tail)))]))

  (define (normalize-triv triv)
    triv)
  ;; value (nvalue -> nvalue) -> nvalue
  (define (normalize-value value [k identity])
    (match value
      [`(begin
          ,effects ...
          ,value2)
       (normalize-value value2 (λ (nvalue) (join-begin (map normalize-effect effects) (k nvalue))))]
      [`(if ,pred ,value1 ,value2)
       (normalize-value value1
                        (λ (nvalue1)
                          (normalize-value value2
                                           (λ (nvalue2)
                                             `(if ,(normalize-pred pred)
                                                  ,(k nvalue1)
                                                  ,(k nvalue2))))))]
      [`(mref ,aloc ,opand) (k `(mref ,aloc ,opand))]
      [`(alloc ,opand) (k `(alloc ,opand))]
      [`(,binop ,triv1 ,triv2)
       #:when (binop/ptr? binop)
       (k `(,binop ,(normalize-triv triv1) ,(normalize-triv triv2)))]
      [triv (k (normalize-triv triv))]))
  (define (normalize-pred pred)
    (match pred
      [`(not ,pred) `(not ,(normalize-pred pred))]
      [`(begin
          ,fxs ...
          ,pred)
       `(begin
          ,@(map normalize-effect fxs)
          ,(normalize-pred pred))]
      [`(if ,pred1 ,pred2 ,pred3)
       `(if ,(normalize-pred pred1)
            ,(normalize-pred pred2)
            ,(normalize-pred pred3))]
      [_ pred]))
  (define (normalize-effect effect)
    (match effect
      ; need to convert value to triv or (binop triv triv) with begin isolated out
      [`(set! ,aloc ,value) (normalize-value value (λ (nvalue) `(set! ,aloc ,nvalue)))]
      [`(begin
          ,effects ...
          ,effect2)
       `(begin
          ,@(map normalize-effect effects)
          ,(normalize-effect effect2))]
      [`(mset! ,aloc ,opand ,value)
       (normalize-value value (λ (nvalue) `(mset! ,aloc ,opand ,nvalue)))]
      [`(if ,pred ,effect1 ,effect2)
       `(if ,(normalize-pred pred)
            ,(normalize-effect effect1)
            ,(normalize-effect effect2))]))

  (define (normalize-tail tail)
    (match tail
      [`(begin
          ,effects ...
          ,tail)
       `(begin
          ,@(map normalize-effect effects)
          ,(normalize-tail tail))]
      [`(if ,pred ,tail1 ,tail2)
       `(if ,(normalize-pred pred)
            ,(normalize-tail tail1)
            ,(normalize-tail tail2))]
      ;; nothing special happens
      [`(call ,_ ,_ ...) tail]
      [`(,binop ,triv1 ,triv2)
       #:when (binop/ptr? binop)
       `(,binop ,(normalize-triv triv1) ,(normalize-triv triv2))]
      [triv (normalize-triv triv)]))
  (define (normalize-p p)
    (match p
      [`(module ,definitions ...
          ,tail)
       `(module ,@(map normalize-definitions definitions) ,(normalize-tail tail)
          )]))

  (normalize-p mf))

(module+ test
  (require rackunit)
  (check-match (normalize-bind '(module (begin
                                          (mset! x.1
                                                 y.1
                                                 (begin
                                                   (set! a.1 1)
                                                   (set! b.1 2)
                                                   42))
                                          0)))
               `(module (begin
                          (begin
                            (set! a.1 1)
                            (set! b.1 2)
                            (mset! x.1 y.1 42))
                          0)))

  (check-match (normalize-bind '(module (begin
                                          (mset! x.1 y.1 (if (true) 1 2))
                                          0)))
               `(module (begin
                          (if (true)
                              (mset! x.1 y.1 1)
                              (mset! x.1 y.1 2))
                          0)))

  ;; interpretation is correct, but were duplicating code.
  #;(check-match (normalize-bind '(module (begin
                                            (mset! x.1
                                                   y.1
                                                   (begin
                                                     (set! a.1 1)
                                                     (if (false) 10 20)))
                                            0)))
                 ;; interrogator response, pulling the set! out
                 `(module (begin
                            (begin
                              (set! a.1 1)
                              (if (false)
                                  (mset! x.1 y.1 10)
                                  (mset! x.1 y.1 20)))
                            0)))

  (check-match (normalize-bind '(module (begin
                                          (set! x.1
                                                (begin
                                                  (set! a.1 1)
                                                  (alloc y.1)))
                                          0)))
               `(module (begin
                          (begin
                            (set! a.1 1)
                            (set! x.1 (alloc y.1)))
                          0)))

  (check-match (normalize-bind '(module (begin
                                          (set! x.1
                                                (begin
                                                  (set! a.1 1)
                                                  (mref y.1 z.1)))
                                          0)))
               `(module (begin
                          (begin
                            (set! a.1 1)
                            (set! x.1 (mref y.1 z.1)))
                          0))))
