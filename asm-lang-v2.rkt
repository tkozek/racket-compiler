#lang racket

(require cpsc411/compiler-lib
        compiler.rkt)


(provide uncover-locals
         assign-fvars
         replace-locations
         assign-homes)

(define (uncover-tails tail)
    (match tail
        [`()]))
;; (asm-lang-v2) -> (asm-lang-v2/locals)
;; Analyzes which alocs are used in p and decorates program with set of variables in info field
(define (uncover-locals p)
    (match p
    [`(module () ,tail)
        `(module (locals ,(uncover-tail '())) ,tail)]
    [_ (error "Expected asm-lang-v2 p, got: ~a" p)]))


;; (asm-lang-v2/assignments) -> (nested-asm-lang-v2)
;; Replaces each aloc with its assigned physical location from the assignment info field
(define (replace-locations p)
    p)

;; (asm-lang-v2/locals) -> (asm-lang-v2/assignments)
;; Assigns each aloc from the locals info field to a fresh frame variable
(define (assign-fvars p)
    p)

;; (asm-lang-v2) -> (nested-asm-lang-v2)
;; Replaces each aloc its with assigned physical location from assignment info field
(define (assign-homes p)
    (replace-locations (assign-fvars (uncover-locals p))))