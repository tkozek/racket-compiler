#lang racket
(require cpsc411/compiler-lib
         cpsc411/2c-run-time)
(require cpsc411/test-suite/public/v2)

(provide check-values-lang
         uniquify
         sequentialize-let
         normalize-bind
         select-instructions
         uncover-locals
         assign-fvars
         replace-locations
         assign-homes
         flatten-begins
         patch-instructions
         implement-fvars
         check-paren-x64
         generate-x64
         interp-values-lang
         interp-paren-x64)

(require "values-lang-v3.rkt"
         "values-unique-lang-v3.rkt"
         "imp-mf-lang-v3.rkt"
         "imp-cmf-lang-v3.rkt"
         "asm-lang-v2.rkt"
         "nested-asm-v3.rkt"
         "para-asm-v2.rkt"
         "paren-x64-fvars-v2.rkt"
         "paren-x64-v2.rkt"
         "util.rkt")

;; Optional
(define (check-paren-x64 p)
  p)

;; Optional
(define (interp-values-lang p)
  0)

(current-pass-list (list check-values-lang
                         uniquify
                         sequentialize-let
                         normalize-bind
                         select-instructions
                         assign-homes
                         flatten-begins
                         patch-instructions
                         implement-fvars
                         generate-x64
                         wrap-x64-run-time
                         wrap-x64-boilerplate))

(module+ test
  (require rackunit
           rackunit/text-ui
           cpsc411/test-suite/public/v3
           ;; NB: Workaround typo in shipped version of cpsc411-lib
           (except-in cpsc411/langs/v3 values-lang-v3)
           cpsc411/langs/v2)
  (require (submod "values-lang-v3.rkt" test)
           (submod "values-unique-lang-v3.rkt" test)
           (submod "imp-mf-lang-v3.rkt" test)
           (submod "imp-cmf-lang-v3.rkt" test)
           (submod "asm-lang-v2.rkt" test)
           (submod "nested-asm-v3.rkt" test)
           (submod "para-asm-v2.rkt" test)
           (submod "paren-x64-fvars-v2.rkt" test)
           (submod "paren-x64-v2.rkt" test))

  (run-tests (v3-public-test-sutie (current-pass-list)
                                   (list interp-values-lang-v3
                                         interp-values-lang-v3
                                         interp-values-unique-lang-v3
                                         interp-imp-mf-lang-v3
                                         interp-imp-cmf-lang-v3
                                         interp-asm-lang-v2
                                         interp-nested-asm-lang-v2
                                         interp-para-asm-lang-v2
                                         interp-paren-x64-fvars-v2
                                         interp-paren-x64-v2
                                         #f
                                         #f))))
