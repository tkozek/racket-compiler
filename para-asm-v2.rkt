#lang racket

(require cpsc411/compiler-lib
        compiler.rkt)

(provide patch-instructions)


;; (para-asm-lang-v2) -> (paren-x64-fvars-v2)
;; Patches instructions in p that have no x64 analogue
(define (patch-instructions p)
    (define aux-reg (current-patch-instructions-registers))
    



        (define (patch-p p)
            ()
        )

    (patch-p p))
