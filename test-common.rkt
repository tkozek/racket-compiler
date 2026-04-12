#lang racket
(require "ourcommon.rkt"
         cpsc411/compiler-lib)

(provide ptr->v/p3yaz)
(define (ptr->v/p3yaz ptr)
  (match ptr
    [(? fixnum/tagged?) (arithmetic-shift ptr (- (current-fixnum-shift)))]
    [(? boolean/tagged?) (eq? ptr (current-true-ptr))]
    [(? empty/tagged?) empty]
    [(? void/tagged?) (void)]
    [(? ascii-char/tagged?) (integer->char (arithmetic-shift ptr (- (current-ascii-char-shift))))]
    [(? error/tagged?) `(error (arithmetic-shift ptr (- (current-error-shift))))]
    [(? pair/tagged?) (error "Pair tags are unsupported yet")]
    [_ (error (format "unsupported ptr value ~b" ptr))]))
