#lang racket

(require cpsc411/compiler-lib
         cpsc411/langs/v2)

(provide flatten-begins)

;; (nested-asm-lang-v2) -> (para-asm-lang-v2)
;; Flatten all nested begin expressions
(define (flatten-begins p)

  (define (flatten-effect effect)
    (match effect
      [`(set! ,loc1 (,binop ,loc1 ,triv)) effect]
      [`(set! ,loc ,triv) effect]
      [`(begin
          ,first
          ,rest ...)
       (append (flatten-effect first) (map flatten-effect rest))]))

  (define (flatten-tail tail)
    (match tail
      [`(halt ,triv) tail]
      [`(begin
          ,effects ...
          ,tail)
       (append (map flatten-effect effects) (flatten-tail tail))]))

  (define (flatten-p p)
    (match p
      [`(begin
          ,effects ...
          tail)
       `(begin
          ,@(flatten-tail p))]
      [`(halt ,triv)
       `(begin
          ,p)]))

  (flatten-p p))

(module+ test
  (require rackunit
           cpsc411/langs/v2
           cpsc411/langs/v3)
  (define-syntax-rule (check-by-interp p)
    (check-equal? (interp-nested-asm-lang-v2 p) (interp-para-asm-lang-v2 (flatten-begins p)))))
