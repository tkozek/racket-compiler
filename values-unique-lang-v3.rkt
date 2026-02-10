#lang racket

(require cpsc411/compiler-lib
        "util.rkt"
        )


(provide sequentialize-let)

(define (sequentialize-value value)
    (match value
    [(? triv?)
            value]
    [`(,op ,triv1 ,triv2)
        (if (and (binop? op) (triv? triv1) (triv? triv2))
            `(,op ,triv1 ,triv2)
            (error (format "Expected a value, got: ~a" value)))]
    [`(let ([,as ,vs] ...) ,body)
        `(begin ,@(map (lambda (a v) `(set! ,a ,(sequentialize-value v))) as vs)
                    ,(sequentialize-value body))]))


(define (sequentialize-tail tail)
    (match tail
    [(? triv?) (sequentialize-value tail)]
    [`(,op ,triv1 ,triv2)
        (sequentialize-value tail)]
    [`(let ([,as ,vs] ...) ,body)
        `(begin ,@(map (lambda (a v) `(set! ,a ,(sequentialize-value v))) as vs) 
                ,(sequentialize-tail body))]))


;; (values-unique-lang-v3) -> (imp-mf-lang-v3)
;; Picks a particular ordering for let expressions using 'set!'
(define (sequentialize-let p)
    (match p
    [`(module ,tail)
        `(module ,(sequentialize-tail tail))]) )