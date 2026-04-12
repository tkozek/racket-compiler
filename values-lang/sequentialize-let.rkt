#lang racket

(require cpsc411/compiler-lib
         cpsc411/langs/v3
         "../util.rkt")

(provide sequentialize-let)

;; (values-unique-lang-v3) -> (imp-mf-lang-v3)
;; Picks a particular ordering for let expressions using 'set!'
(define (sequentialize-let p)

  (define (sequentialize-value value)
    (match value
      [`(let ([,as ,vs] ...) ,body-value)
       `(begin
          ,@(map (lambda (a v) `(set! ,a ,(sequentialize-value v))) as vs)
          ,(sequentialize-value body-value))]
      [_ value]))

  (define (sequentialize-tail tail)
    (match tail
      [`(let ([,as ,vs] ...) ,body-tail)
       `(begin
          ,@(map (lambda (a v) `(set! ,a ,(sequentialize-value v))) as vs)
          ,(sequentialize-tail body-tail))]
      [_ (sequentialize-value tail)]))

  (define (sequentialize-p p)
    (match p
      [`(module ,tail) `(module ,(sequentialize-tail tail))]))

  (sequentialize-p p))
