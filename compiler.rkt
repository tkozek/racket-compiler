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
         
;; Optional
(define (check-values-lang values)
  values)

(require "asm-lang/assign-fvars.rkt"
         "asm-lang/replace-locations.rkt"
         "asm-lang/uncover-locals.rkt"
         "asm-lang/assign-homes.rkt"
         "asm-lang/flatten-begins.rkt"
         "asm-lang/patch-instructions.rkt"
         "imp-lang/normalize-bind.rkt"
         "imp-lang/select-instructions.rkt"
         "paren-x64/implement-fvars.rkt"
         "paren-x64/generate-x64.rkt"
         "values-lang/uniquify.rkt"
         "values-lang/sequentialize-let.rkt"
         "util.rkt")


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
  (require (submod "asm-lang/assign-fvars.rkt" test)
           (submod "asm-lang/replace-locations.rkt" test)
           (submod "asm-lang/uncover-locals.rkt" test)
           (submod "asm-lang/assign-homes.rkt" test)
           (submod "paren-x64/generate-x64.rkt" test))

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
