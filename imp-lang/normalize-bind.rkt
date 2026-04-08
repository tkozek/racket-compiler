#lang racket

(require cpsc411/compiler-lib
         cpsc411/langs/v3
         "../util.rkt")

(provide normalize-bind)

;; (imp-mf-lang-v3 p) -> (imp-cmf-lang-v3 p)
;; Pushes 'set!' under 'begin' so that RHS of each 'set!' is a simple value producing operation
(define (normalize-bind p)

  ;; (Imp-mf-lang-v3 effect) -> (Imp-cmf-lang-v3 effect)
  (define (normalize-effect effect)
    (match effect
      [`(set! ,aloc ,value)
       (let ([normalized-val (normalize-value value)])
         (match normalized-val
           [`(begin
               ,effects ...
               ,body)
            `(begin
               ,@effects
               (set! ,aloc ,body))]
           [_ `(set! ,aloc ,normalized-val)]))]
      [`(begin
          ,effects ...)
       `(begin
          ,@(map normalize-effect effects))]))

  ;; (imp-mf-lang-v3 value) -> (imp-cmf-lang-v3 value)
  (define (normalize-value value)
    (match value
      [`(begin
          ,effects ...
          ,body)
       `(begin
          ,@(map normalize-effect effects)
          ,(normalize-value body))]
      [_ value]))

  ;; (Imp-mf-lang-v3 tail) -> (Imp-cmf-lang-v3 tail)
  (define (normalize-tail tail)
    (match tail
      [`(begin
          ,effects ...
          ,body)
       `(begin
          ,@(map normalize-effect effects)
          ,(normalize-tail body))]
      [_ (normalize-value tail)]))

  (define (normalize-p p)
    (match p
      [`(module ,tail) `(module ,(normalize-tail tail))]))

  (normalize-p p))

(module+ test
  (require rackunit
           cpsc411/langs/v3)
  (define-syntax-rule (check-by-interp p)
    (check-equal? (interp-imp-mf-lang-v3 p) (interp-imp-cmf-lang-v3 (normalize-bind p)))))
