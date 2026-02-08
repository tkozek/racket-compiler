#lang racket

(require cpsc411/compiler-lib
        )

(provide implement-fvars)


;; (paren-x64-fvars-v2) -> (paren-x64-v2)
;; Reifies fvars into displacement mode operands
(define (implement-fvars p)
    p)