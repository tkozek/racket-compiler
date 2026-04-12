#lang racket
(require cpsc411/compiler-lib)

(provide uncover-locals
         replace-locations
         undead-analysis
         conflict-analysis
         assign-registers
         optimize-predicates
         assign-call-undead-variables
         allocate-frames)

(require "replace-locations.rkt"
         "uncover-locals.rkt"
         "undead-analysis.rkt"
         "conflict-analysis.rkt"
         "assign-registers.rkt"
         "optimize-predicates.rkt"
         "assign-call-undead-variables.rkt"
         "allocate-frames.rkt")
#;
;; X -> X
;; debug function, displays X and returns X
(define (peek datum)
  (displayln datum)
  datum)

(module+ test
  (require rackunit)
  (require (submod "replace-locations.rkt" test)
           (submod "uncover-locals.rkt" test)
           ;  (submod "undead-analysis.rkt" test)
           (submod "conflict-analysis.rkt" test)
           (submod "assign-registers.rkt" test)
           (submod "assign-call-undead-variables.rkt" test)
           (submod "allocate-frames.rkt" test)))
