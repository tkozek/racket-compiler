#lang racket

(require cpsc411/compiler-lib
        compiler.rkt)

(provide patch-instructions)


;; (para-asm-lang-v2) -> (paren-x64-fvars-v2)
;; Patches instructions in p that have no x64 analogue
(define (patch-instructions p)
    p)
