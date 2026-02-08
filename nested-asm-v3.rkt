#lang racket

(require cpsc411/compiler-lib
        )

(provide flatten-begins)

;; (nested-asm-lang-v2) -> (para-asm-lang-v2)
;; Flatten all nested begin expressions
(define (flatten-begins p)

    (define (flatten-effect effect)
        (match effect
            [`(set! ,loc1 (,binop ,loc1 ,triv))
                effect]
            [`(set! ,loc ,triv)
                effect]
            [`(begin ,first ,rest ...)
                (append (flatten-effect first)
                        (map flatten-effect rest))]
            [_ (error (format "Expected an effect, got: ~a" effect))]))


    (define (flatten-tail tail)
        (match tail
            [`(halt ,triv)
                tail]
            [`(begin ,effects ... ,tail)
                (append (map flatten-effect effects)
                        (flatten-tail tail))]
            [_ (error (format "Expected tail, got: ~a" tail))]))
    
    (define (flatten-p p)
        (match p
            [`(begin ,effects ... tail)
                `(begin ,@(flatten-tail p))]
            [`(halt ,triv)
                `(begin ,p)]
            [_ (error (format "Expected Nested-asm-lang-v2, got: ~a" p))]))
            
    (flatten-p p))
    
