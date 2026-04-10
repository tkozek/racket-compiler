#lang racket

(require cpsc411/compiler-lib
         cpsc411/2c-run-time)

(provide uniquify
         sequentialize-let
         normalize-bind
         impose-calling-conventions
         select-instructions
         uncover-locals
         undead-analysis
         conflict-analysis
         assign-call-undead-variables
         allocate-frames
         assign-registers
         replace-locations
         assign-frame-variables
         implement-fvars
         optimize-predicates
         expose-basic-blocks
         resolve-predicates
         flatten-program
         patch-instructions
         generate-x64)

(require "uniquify.rkt")
(require "sequentialize-let.rkt")
(require "normalize-bind.rkt")
(require "select-instructions.rkt")
(require "target-nested-asm-lang-v2/all-exports.rkt")

(require "patch-instructions.rkt")
(require "expose-basic-blocks.rkt")
(require "assign-frame-variables.rkt")
(require "implement-fvars.rkt")
(require "resolve-predicates.rkt")
(require "generate-x64.rkt")
(require "expose-basic-blocks.rkt")
(require "flatten-program.rkt")
(require "impose-calling-conventions.rkt")


(module+ test
  (require rackunit
           rackunit/text-ui
           cpsc411/langs/v6
           cpsc411/test-suite/public/v6
           file/glob)
  (require (submod "uniquify.rkt" test))
  (require (submod "sequentialize-let.rkt" test))
  (require (submod "normalize-bind.rkt" test))
  (require (submod "impose-calling-conventions.rkt" test))
  (require (submod "select-instructions.rkt" test))
  (require (submod "target-nested-asm-lang-v2/all-exports.rkt" test))
  (require (submod "implement-fvars.rkt" test))
  (require (submod "expose-basic-blocks.rkt" test))
  (require (submod "resolve-predicates.rkt" test))
  (require (submod "flatten-program.rkt" test))
  (require (submod "patch-instructions.rkt" test))
  (require (submod "generate-x64.rkt" test))
  (for-each (λ(p) (dynamic-require p #f)) (glob "generated_tests/**.rkt"))

  ;; You can modify this pass list, e.g., by adding other
  ;; optimization, debugging, or validation passes.
  ;; Doing this may provide additional debugging info when running the rest
  ;; suite.
  (define pass-map
    (list (cons uniquify interp-values-lang-v6)
          (cons sequentialize-let interp-values-unique-lang-v6)
          (cons normalize-bind interp-imp-mf-lang-v6)
          (cons impose-calling-conventions interp-proc-imp-cmf-lang-v6)
          (cons select-instructions interp-imp-cmf-lang-v6)
          (cons uncover-locals interp-asm-pred-lang-v6)
          (cons undead-analysis interp-asm-pred-lang-v6/locals)
          (cons conflict-analysis interp-asm-pred-lang-v6/undead)
          (cons assign-call-undead-variables interp-asm-pred-lang-v6/conflicts)
          (cons allocate-frames interp-asm-pred-lang-v6/pre-framed)
          (cons assign-registers interp-asm-pred-lang-v6/framed)
          (cons assign-frame-variables interp-asm-pred-lang-v6/spilled)
          (cons replace-locations interp-asm-pred-lang-v6/assignments)
          (cons optimize-predicates interp-nested-asm-lang-fvars-v6)
          (cons implement-fvars interp-nested-asm-lang-fvars-v6)
          (cons expose-basic-blocks interp-nested-asm-lang-v6)
          (cons resolve-predicates interp-block-pred-lang-v6)
          (cons flatten-program interp-block-asm-lang-v6)
          (cons patch-instructions interp-para-asm-lang-v6)
          (cons generate-x64 interp-paren-x64-v6)
          (cons wrap-x64-boilerplate #f)
          (cons wrap-x64-run-time #f)))

  (current-pass-list (map car pass-map))

  (run-tests (v6-public-test-suite (current-pass-list) (map cdr pass-map))))
