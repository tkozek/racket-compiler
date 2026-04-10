#lang racket
(require rackunit
         cpsc411/langs/v6
         cpsc411/compiler-lib
         "../.rkt")

(define (check-input p)
  (if (block-asm-lang-v6? p)
      p
      (error
       (~a (pretty-format p) "\n is not a semantically valid " "block-asm-lang-v6" " program"))))

(define (check-output p)
  (if (para-asm-lang-v6? p)
      p
      (error (~a (pretty-format p) "\n is not a semantically valid " "para-asm-lang-v6" " program"))))



(define-syntax-rule (check-by-interp p)
  (check-equal? (interp-para-asm-lang-v6 (check-output (flatten-program p)))
                (interp-block-asm-lang-v6 (check-input p))))
