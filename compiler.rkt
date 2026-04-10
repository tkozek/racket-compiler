#lang racket

(require cpsc411/compiler-lib
         cpsc411/2c-run-time)

(provide check-values-lang
         uniquify
         sequentialize-let
         normalize-bind
         impose-calling-conventions
         select-instructions
         assign-homes-opt
         uncover-locals
         undead-analysis
         conflict-analysis
         assign-registers
         replace-locations
         optimize-predicates
         expose-basic-blocks
         resolve-predicates
         flatten-program
         patch-instructions
         implement-fvars
         generate-x64)

;; Template support macro; feel free to delete
(define-syntax-rule (.... stx ...)
  (error "Unfinished template"))

(require "uniquify.rkt")
(require "sequentialize-let.rkt")
(require "normalize-bind.rkt")
(require "select-instructions.rkt")
(require "target-nested-asm-lang-v2/all-exports.rkt")

(require "patch-instructions.rkt")
(require "implement-fvars.rkt")
(require "resolve-predicates.rkt")
(require "generate-x64.rkt")
(require "expose-basic-blocks.rkt")
(require "flatten-program.rkt")
(require "impose-calling-conventions.rkt")

;; Stubs; remove or replace with your definitions.
(define-values (check-values-lang) (values values))

(module+ test
  (require rackunit
           rackunit/text-ui
           cpsc411/langs/v5
           cpsc411/test-suite/utils
           cpsc411/test-suite/public/v5
           errortrace)

  (require (submod "uniquify.rkt" test))
  (require (submod "sequentialize-let.rkt" test))
  (require (submod "normalize-bind.rkt" test))
  (require (submod "select-instructions.rkt" test))
  (require (submod "flatten-program.rkt" test))
  (require (submod "patch-instructions.rkt" test))
  (require (submod "resolve-predicates.rkt" test))
  (require (submod "implement-fvars.rkt" test))
  (require (submod "generate-x64.rkt" test))
  (require (submod "expose-basic-blocks.rkt" test))
  (require (submod "target-nested-asm-lang-v2/all-exports.rkt" test))
  (require (submod "impose-calling-conventions.rkt" test))

  ;; You can modify this pass list, e.g., by adding check-assignment, or other
  ;; debugging and validation passes.
  ;; Doing this may provide additional debugging info when running the rest
  ;; suite.
  (define pass-map
    (list (cons check-values-lang interp-values-lang-v5)
          (cons uniquify interp-values-lang-v5)
          (cons sequentialize-let interp-values-unique-lang-v5)
          (cons normalize-bind interp-imp-mf-lang-v5)
          (cons impose-calling-conventions interp-proc-imp-cmf-lang-v5)
          (cons select-instructions interp-imp-cmf-lang-v5)
          (cons uncover-locals interp-asm-pred-lang-v5)
          (cons undead-analysis interp-asm-pred-lang-v5/locals)
          (cons conflict-analysis interp-asm-pred-lang-v5/undead)
          (cons assign-registers interp-asm-pred-lang-v5/conflicts)
          (cons replace-locations interp-asm-pred-lang-v5/assignments)
          (cons optimize-predicates interp-nested-asm-lang-v5)
          (cons expose-basic-blocks interp-nested-asm-lang-v5)
          (cons resolve-predicates interp-block-pred-lang-v5)
          (cons flatten-program interp-block-asm-lang-v5)
          (cons patch-instructions interp-para-asm-lang-v5)
          (cons implement-fvars interp-paren-x64-fvars-v5)
          (cons generate-x64 interp-paren-x64-v5)
          (cons wrap-x64-run-time #f)
          (cons wrap-x64-boilerplate #f)))

  (current-pass-list (map car pass-map))

  (run-tests (v5-public-test-suite (current-pass-list) (map cdr pass-map) check-values-lang)))
