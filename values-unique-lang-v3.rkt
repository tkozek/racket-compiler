#lang racket

(require cpsc411/compiler-lib
        compiler.rkt)


(provide sequentialize-let)

(define (sequentialize-value value)
    (match value
    [(? triv?)
            value]
    [`(,op ,triv1 ,triv2)
        (if (and (binop? op) (triv? triv1) (triv? triv2))
            `(,op ,triv1 ,triv2)
            (error "Expected a value, got: ~a" value))]
    [`(let ([,as ,vs] ...) ,body)
        `(begin ,@(map (lambda (a v) `(set! ,a ,(sequentialize-value v))) as vs)
                    ,(sequentialize-value body))]

    [_ (error "Expected a value, got: ~a" value)]
    ))


(define (sequentialize-tail tail)
    (match tail
    [(? triv?) (sequentialize-value tail)]
    [`(,op ,triv1 ,triv2)
        (sequentialize-value tail)]
    [`(let ([,as ,vs] ...) ,body)
        `(begin ,@(map (lambda (a v) `(set! ,a ,(sequentialize-value v))) as vs) 
                ,(sequentialize-tail body))]
    [_ (error "Expected a tail, got: ~a" tail)]))


;; (values-unique-lang-v3) -> (imp-mf-lang-v3)
;; Picks a particular ordering for let expressions using 'set!'
(define (sequentialize-let p)
    (match p
    [`(module ,tail)
        `(module ,(sequentialize-tail tail))])
    [_ (error "Expected values-unique-lang-v3, got: ~a" p)]) 