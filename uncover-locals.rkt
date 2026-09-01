#lang racket

(require cpsc411/compiler-lib
         "common.rkt")
(provide uncover-locals)

;; (Asm-pred-lang-v8 p) -> (Asm-pred-lang-v8/locals p)
;; Compiles Asm-pred-lang v8 to Asm-pred-lang v8/locals,
;; analysing which abstract locations are used in each block,
;; and updating each block and the module with the set of variables
;; in an info?'s fields.
(define (uncover-locals p)

  (define (uncover-definitions def)
    (match def
      [`(define ,label
          ,info
          ,tail)
       `(define ,label
          ,(info-set info 'locals (set->list (uncover-tail tail)))
          ,tail)]))

  (define (uncover-triv triv)
    (match triv
      [(? (or/c register? fvar? label? int64?)) (set)]
      [(? aloc?) (set triv)]))

  (define (uncover-loc loc)
    (match loc
      [(? aloc?) (set loc)]
      [_ (set)]))

  (define (uncover-pred pred)
    (match pred
      [`(,relop ,loc ,triv)
       #:when (memq relop '(< <= = >= > !=))
       (set-union (uncover-loc loc) (uncover-triv triv))]
      [`(true) (set)]
      [`(false) (set)]
      [`(not ,p) (uncover-pred p)]
      [`(begin
          ,fxs ...
          ,p)
       (set-union (uncover-effects fxs) (uncover-pred p))]
      [`(if ,p1 ,p2 ,p3) (set-union (uncover-pred p1) (uncover-pred p2) (uncover-pred p3))]))

  (define (uncover-effect effect)
    (match effect
      [`(set! ,loc (,binop ,loc ,triv))
       #:when (binop/ptr? binop)
       (set-union (uncover-loc loc) (uncover-triv triv))]
      [`(set! ,loc1 (mref ,loc2 ,triv))
       (set-union (uncover-loc loc1) (uncover-loc loc2) (uncover-loc triv))]
      [`(mset! ,loc ,index ,triv)
       (set-union (uncover-loc loc) (uncover-loc index) (uncover-triv triv))]
      [`(set! ,loc ,triv) (set-union (uncover-loc loc) (uncover-triv triv))]
      [`(begin
          ,fxs ...
          ,fx)
       (set-union (uncover-effects fxs) (uncover-effect fx))]
      [`(if ,pred ,e1 ,e2) (set-union (uncover-pred pred) (uncover-effect e1) (uncover-effect e2))]
      [`(return-point ,_ ,tail) (uncover-tail tail)]))

  (define (uncover-effects fxs)
    (for/fold ([locals (set)]) ([fx fxs])
      (set-union locals (uncover-effect fx))))

  (define (uncover-tail tail)
    (match tail
      [`(begin
          ,fxs ...
          ,t)
       (set-union (uncover-effects fxs) (uncover-tail t))]
      [`(halt ,triv) (uncover-triv triv)]
      [`(if ,pred ,t1 ,t2) (set-union (uncover-pred pred) (uncover-tail t1) (uncover-tail t2))]
      [`(jump ,trg ,loc ...) (foldr (lambda (cur acc) (set-union (uncover-loc cur) acc)) (set) loc)]))

  (define (uncover-p p)
    (match p
      [`(module ,info ,definitions
          ...
          ,tail)
       `(module ,(info-set info 'locals (set->list (uncover-tail tail)))
                ,@(map uncover-definitions definitions)
          ,tail)]))
  (uncover-p p))

(module+ test
  (require rackunit)
  (check-match (uncover-locals `(module ((new-frames ()))
                                        (begin
                                          (set! x.1 (mref x.2 x.3))
                                          (mset! x.6 x.7 x.8)
                                          (mset! x.6 x.7 x.8)
                                          (jump L.test.1 r15))
                                  ))
               `(module ((new-frames ()) (locals (x.1 x.2 x.3 x.6 x.7 x.8)))
                        (begin
                          (set! x.1 (mref x.2 x.3))
                          (mset! x.6 x.7 x.8)
                          (mset! x.6 x.7 x.8)
                          (jump L.test.1 r15))
                  )))
