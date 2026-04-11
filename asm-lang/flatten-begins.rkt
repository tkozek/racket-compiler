#lang racket

(require cpsc411/compiler-lib
         cpsc411/langs/v2)

(provide flatten-begins)

;; (nested-asm-lang-v2) -> (para-asm-lang-v2)
;; Flatten all nested begin expressions
(define (flatten-begins p)

  (define (flatten-effect effect)
    (match effect
      [`(begin
          ,effects ...
          ,last)
       (append (append-map flatten-effect effects) (flatten-effect last))]
      [_ (list effect)]))

  (define (flatten-tail tail)
    (match tail
      [`(begin
          ,effects ...
          ,tail)
       (append (append-map flatten-effect effects) (flatten-tail tail))]
      [_ (list tail)]))

  (define (flatten-p p)
    `(begin
       ,@(flatten-tail p)))

  (flatten-p p))
