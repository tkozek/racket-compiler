#lang racket

(require cpsc411/compiler-lib
         cpsc411/langs/v3
         "../util.rkt")

(provide normalize-bind)

;; (imp-mf-lang-v3 p) -> (imp-cmf-lang-v3 p)
;; Pushes 'set!' under 'begin' so that RHS of each 'set!' is a simple value producing operation
(define (normalize-bind p)

  ;; (imp-mf-lang-v3 effect) -> (imp-cmf-lang-v3 effect)
  (define (normalize-effect effect)
    (match effect
      [`(set! ,aloc ,value) (normalize-value value aloc)]
      [`(begin
          ,effects ...)
       `(begin
          ,@(map normalize-effect effects))]))

  ;; (imp-mf-lang-v3 value) -> (imp-cmf-lang-v3 value)
  (define (normalize-value value aloc)
    (match value
      [`(begin
          ,effects ...
          ,body)
       `(begin
          ,@(map normalize-effect effects)
          ,(normalize-value body aloc))]
      [_ `(set! ,aloc ,value)]))

  ;; (imp-mf-lang-v3 tail) -> (imp-cmf-lang-v3 tail)
  (define (normalize-tail tail)
    (match tail
      [`(begin
          ,effects ...
          ,body)
       `(begin
          ,@(map normalize-effect effects)
          ,(normalize-tail body))]
      [_ tail]))

  (define (normalize-p p)
    (match p
      [`(module ,tail) `(module ,(normalize-tail tail))]))

  (normalize-p p))
