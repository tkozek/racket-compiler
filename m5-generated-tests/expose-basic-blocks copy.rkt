#lang racket
(require rackunit
         cpsc411/langs/v5
         cpsc411/compiler-lib
         "../expose-basic-blocks.rkt")

(define (check-input p)
  (if (nested-asm-lang-v5? p)
      p
      (error
       (~a (pretty-format p) "\n is not a semantically valid " "nested-asm-lang-v5" " program"))))

(define (check-output p)
  (if (block-pred-lang-v5? p)
      p
      (error
       (~a (pretty-format p) "\n is not a semantically valid " "block-pred-lang-v5" " program"))))


