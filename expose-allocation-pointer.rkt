#lang racket
(require cpsc411/compiler-lib
         cpsc411/langs/v8
         "common.rkt")

(provide expose-allocation-pointer)

;; only thing of interest is the effect: (set! loc (alloc index))
;; which will become:
;; (begin
;;   (set! ,loc ,(current-heap-base-pointer-register))
;;   (set! ,(current-heap-base-pointer-register) (+ ,(current-heap-base-pointer-register) ,index))
;;;  )

;; Implements the allocation primitive in terms of pointer arithmetic on the
;;  current-heap-base-pointer-register
(define (expose-allocation-pointer p)

  (define (expose-pred pred)
    (match pred
      [`(not ,pred1) `(not ,(expose-pred pred1))]
      [`(begin
          ,effects ...
          ,pred1)
       `(begin
          ,@(map expose-effect effects)
          ,(expose-pred pred1))]
      [`(if ,pred1 ,then-pred ,else-pred)
       `(if ,(expose-pred pred1)
            ,(expose-pred then-pred)
            ,(expose-pred else-pred))]
      [_ pred]))

  (define (expose-effect effect)
    (match effect
      [`(begin
          ,effects ...)
       `(begin
          ,@(map expose-effect effects))]
      [`(if ,pred ,then-effect ,else-effect)
       `(if ,(expose-pred pred)
            ,(expose-effect then-effect)
            ,(expose-effect else-effect))]
      [`(return-point ,label ,tail) `(return-point ,label ,(expose-tail tail))]
      [`(set! ,loc (alloc ,index))
       (let ([hbp (current-heap-base-pointer-register)])
         `(begin
            (set! ,loc ,hbp)
            (set! ,hbp (+ ,hbp ,index))))]
      [_ effect]))

  (define (expose-tail tail)
    (match tail
      [`(begin
          ,effects ...
          ,tail)
       `(begin
          ,@(map expose-effect effects)
          ,(expose-tail tail))]
      [`(if ,pred ,then-tail ,else-tail)
       `(if ,(expose-pred pred)
            ,(expose-tail then-tail)
            ,(expose-tail else-tail))]
      [_ tail]))

  (define (expose-definition def)
    (match def
      [`(define ,label
          ,info
          ,tail)
       `(define ,label
          ,info
          ,(expose-tail tail))]))

  (define (expose-p p)
    (match p
      [`(module ,info ,defs
          ...
          ,tail)
       `(module ,info ,@(map expose-definition defs)
          ,(expose-tail tail))]))

  (expose-p p))

(module+ test
  (require rackunit
           rackunit/text-ui
           cpsc411/langs/v8
           cpsc411/test-suite/public/v8
           cpsc411/compiler-lib)
  (define-syntax-rule (check-by-interp p)
    (check-equal? p p))
  #;(check-match (expose-allocation-pointer '(module (cons 5 6)))
                 `(module (let ([,tmp (+ (alloc 16) 1)])
                            (begin
                              (mset! ,tmp -1 40)
                              (mset! ,tmp 7 48)
                              ,tmp)))))
