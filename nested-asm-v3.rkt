#lang racket

(require cpsc411/compiler-lib
        compiler.rkt)

(provide flatten-begins)

;; (nested-asm-lang-v2) -> (para-asm-lang-v2)
;; Flatten all nested begin expressions
(define (flatten-begins p)
    p)
