#lang racket

(require cpsc411/compiler-lib
         "common.rkt")

(provide normalize-bind)

;; (Imp-mf-lang v8 p) -> (Proc-imp-cmf-lang v8 p)
;; Compiles Imp-mf-lang v8 to Imp-cmf-lang v8, pushing set!
;; under begin and if so that the right-hand-side of each set!
;;is a simple value-producing operation.
(define (normalize-bind mf)
  (define opand? (or/c int64? aloc?) )
  (define triv? (or/c opand? label?))
  ;; let nvalue represent a value in Proc-imp-cmf-lang-v8
  ;; let ntail represent a tail in Proc-imp-cmf-lang-v8

  ;; join-begin so that the effects take place after the given tail's effect
  ;; this is necessary due to the use of continuations
  ;; (listof effect) tail -> tail
  (define (join-begin fx* tail)
    (match tail
      [`(begin
          ,fx2* ...
          ,tail)
       (make-begin (append fx2* fx*) tail)]
      [_ (make-begin fx* tail)]))
  (define (normalize-def def)
    (match def
      [`(define ,label (lambda ,alocs ,tail))
       `(define ,label (lambda ,alocs ,(normalize-tail tail)))]))

  ;; value (nvalue -> ntail) -> ntail
  (define (normalize-value value [k identity])
    (let loop ([value value]
               [k k])
      (match value
        [`(if ,pred ,value1 ,value2)
         `(if ,(normalize-pred pred)
              ,(loop value1 k)
              ,(loop value2 k))]
        [`(begin ,fx* ... ,val0)
         (make-begin (map normalize-effect fx*) (loop val0 k))]
        [triv (k triv)])))
  (define (normalize-pred pred)
    (match pred
      [`(not ,pred) `(not ,(normalize-pred pred))]
      [`(begin
          ,fxs ...
          ,pred)
       (make-begin
        (map normalize-effect fxs)
        (normalize-pred pred))]
      [`(if ,pred1 ,pred2 ,pred3)
       `(if ,(normalize-pred pred1)
            ,(normalize-pred pred2)
            ,(normalize-pred pred3))]
      [_ pred]))
  (define (normalize-effect effect)
    (match effect
      [`(set! ,aloc ,value) (normalize-value value (λ (nvalue) `(set! ,aloc ,nvalue)))]
      [`(begin
          ,effects ...
          ,effect2)
       (make-begin (map normalize-effect effects)
                   (normalize-effect effect2))]
      [`(mset! ,aloc ,opand ,value)
       (normalize-value value (λ (nvalue)
                                (if (not (triv? nvalue))
                                    (let ([ntriv (fresh 'mset-tmp)])
                                      (make-begin-effect
                                       `((set! ,ntriv ,nvalue)
                                         (mset! ,aloc ,opand ,ntriv))))
                                    `(mset! ,aloc ,opand ,nvalue))))]
      [`(if ,pred ,effect1 ,effect2)
       `(if ,(normalize-pred pred)
            ,(normalize-effect effect1)
            ,(normalize-effect effect2))]))

  (define (normalize-tail tail)
    (match tail
      [`(if ,pred ,tail1 ,tail2)
       `(if ,(normalize-pred pred)
            ,(normalize-tail tail1)
            ,(normalize-tail tail2))]
      [`(begin
          ,effects ...
          ,tail)
       (make-begin
        (map normalize-effect effects)
        (normalize-tail tail))]
      ;; nothing special happens
      [`(call ,_ ,_ ...) tail]
      [value (normalize-value value)]))
  (define (normalize-p p)
    (match p
      [`(module ,definitions ...
          ,tail)
       `(module ,@(map normalize-def definitions) ,(normalize-tail tail))]))

  (normalize-p mf))

(module+ test
  (require rackunit)
  )
