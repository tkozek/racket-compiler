#lang racket

(require cpsc411/compiler-lib
         cpsc411/ptr-run-time)

(provide uniquify
         implement-safe-primops
         specify-representation
         remove-complex-opera*
         sequentialize-let
         normalize-bind
         impose-calling-conventions
         select-instructions
         expose-allocation-pointer
         uncover-locals
         undead-analysis
         conflict-analysis
         assign-call-undead-variables
         allocate-frames
         assign-registers
         assign-frame-variables
         replace-locations
         implement-fvars
         optimize-predicates
         expose-basic-blocks
         resolve-predicates
         flatten-program
         patch-instructions
         implement-mops
         generate-x64)

;; TODO: Fill in.
;; You'll want to merge milestone-7 code in

;; Stubs; remove or replace with your definitions.

; (define implement-mops values)
; (define expose-allocation-pointer values)

(require "uniquify.rkt")
(require "implement-safe-primops.rkt")
(require "sequentialize-let.rkt")
(require "normalize-bind.rkt")
(require "select-instructions.rkt")
(require "target-nested-asm-lang-v2/all-exports.rkt")
(require "flatten-begins.rkt")
(require "patch-instructions.rkt")
(require "expose-basic-blocks.rkt")
(require "assign-frame-variables.rkt")
(require "implement-fvars.rkt")
(require "resolve-predicates.rkt")
(require "generate-x64.rkt")
(require "expose-allocation-pointer.rkt")
(require "implement-mops.rkt")

(require "specify-representation.rkt")
(require "remove-complex-opera.rkt")
(require "flatten-program.rkt")
(require "impose-calling-conventions.rkt")

(module+ test
  (require rackunit
           rackunit/text-ui
           cpsc411/langs/v8
           cpsc411/test-suite/public/v8
           file/glob)
  (require (submod "uniquify.rkt" test))

  (require (submod "implement-safe-primops.rkt" test))
  (require (submod "sequentialize-let.rkt" test))
  (require (submod "normalize-bind.rkt" test))
  (require (submod "impose-calling-conventions.rkt" test))
  (require (submod "select-instructions.rkt" test))
  ; (require (submod "target-nested-asm-lang-v2/all-exports.rkt" test))
  (require (submod "implement-fvars.rkt" test))
  (require (submod "expose-basic-blocks.rkt" test))
  (require (submod "resolve-predicates.rkt" test))
  ;   (require (submod "specify-representation.rkt" test))
  (require (submod "flatten-program.rkt" test))
  ;   (require (submod "patch-instructions.rkt" test))
  ; (for-each (λ(p) (dynamic-require p #f)) (glob "m7-generated-tests/**.rkt"))
  ;   (for-each (λ(p) (dynamic-require p #f)) (glob "m8-generated-tests/**.rkt"))
  ;; You can modify this pass list, e.g., by adding other
  ;; optimization, debugging, or validation passes.
  ;; Doing this may provide additional debugging info when running the rest
  ;; suite.
  (define pass-map
    #;(cons check-exprs-lang #f)
    (list (cons uniquify interp-exprs-lang-v8)
          (cons implement-safe-primops interp-exprs-unique-lang-v8)
          (cons specify-representation interp-exprs-unsafe-data-lang-v8)
          (cons remove-complex-opera* interp-exprs-bits-lang-v8)
          (cons sequentialize-let interp-values-bits-lang-v8)
          (cons normalize-bind interp-imp-mf-lang-v8)
          (cons impose-calling-conventions interp-proc-imp-cmf-lang-v8)
          (cons select-instructions interp-imp-cmf-lang-v8)
          (cons expose-allocation-pointer interp-asm-alloc-lang-v8)
          (cons uncover-locals interp-asm-pred-lang-v8)
          (cons undead-analysis interp-asm-pred-lang-v8/locals)
          (cons conflict-analysis interp-asm-pred-lang-v8/undead)
          (cons assign-call-undead-variables interp-asm-pred-lang-v8/conflicts)
          (cons allocate-frames interp-asm-pred-lang-v8/pre-framed)
          (cons assign-registers interp-asm-pred-lang-v8/framed)
          (cons assign-frame-variables interp-asm-pred-lang-v8/spilled)
          (cons replace-locations interp-asm-pred-lang-v8/assignments)
          (cons optimize-predicates interp-nested-asm-lang-fvars-v8)
          (cons implement-fvars interp-nested-asm-lang-fvars-v8)
          (cons expose-basic-blocks interp-nested-asm-lang-v8)
          (cons resolve-predicates interp-block-pred-lang-v8)
          (cons flatten-program interp-block-asm-lang-v8)
          (cons patch-instructions interp-para-asm-lang-v8)
          (cons implement-mops interp-paren-x64-mops-v8)
          (cons generate-x64 interp-paren-x64-v8)
          (cons wrap-x64-boilerplate #f)
          (cons wrap-x64-run-time #f)))

  (current-pass-list (map car pass-map))

  (run-tests (v8-public-test-suite (current-pass-list) (map cdr pass-map))))
