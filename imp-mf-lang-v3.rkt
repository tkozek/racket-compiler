#lang racket

(require cpsc411/compiler-lib
         "util.rkt")

(provide normalize-bind)

;; (Imp-mf-lang-v3 effect) -> (Imp-cmf-lang-v3 effect)
(define (normalize-effect effect)
  (match effect
    [`(set! ,aloc
            (begin
              ,effects ...
              ,value))
     `(begin
        ,@(map normalize-effect effects)
        (set! ,aloc ,(normalize-value value)))]
    [`(set! ,aloc ,value) `(set! ,aloc ,(normalize-value value))]
    [`(begin
        ,effects ...
        ,effect2)
     `(begin
        ,@(map normalize-effect effects)
        ,(normalize-effect effect2))]))

;; (Imp-mf-lang-v3 value) -> (Imp-cmf-lang-v3 value)
(define (normalize-value value)
  (match value
    [(? triv?) value]
    [`(,op ,triv1 ,triv2)
     (if (and (binop? op) (triv? triv1) (triv? triv2))
         value
         (error (format "Expected a value, got: ~a" value)))]
    [`(begin
        ,effects ...
        ,body)
     `(begin
        ,@(map normalize-effect effects)
        ,(normalize-value body))]))

;; (Imp-mf-lang-v3 tail) -> (Imp-cmf-lang-v3 tail)
(define (normalize-tail tail)
  (match tail
    [(? triv?) (normalize-value tail)]
    [`(,op ,triv1 ,triv2) (normalize-value tail)]
    [`(begin
        ,effects ...
        ,body)
     `(begin
        ,@(map normalize-effect effects)
        ,(normalize-tail body))]))

;; (imp-mf-lang-v3 p) -> (imp-cmf-lang-v3 p)
;; Pushes 'set!' under 'begin' so that RHS of each 'set!' is a simple value producing operation
(define (normalize-bind p)
  (match p
    [`(module ,tail) `(module ,(normalize-tail tail))]))
