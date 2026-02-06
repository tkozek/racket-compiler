#lang racket

(require cpsc411/compiler-lib
        compiler.rkt)

(provide uniquify)



(define (uniquify-triv triv env)
    (match triv
        [(? int64?) triv]
        [(? name?)
            (dict-ref env triv  (lambda () (raise (make-exn:fail))))] ;; We found a name, it is supposed to be trivial, which means it should exist in our environment, so raise error if it isn't in our environment 
            ;; (it not being in our environment would mean we have an unbound name)
        [_ (error "Expected triv but got ~a" triv)]))

(define (uniquify-value value env)
    (match value
    [(? triv?)
        (uniquify-triv value env)]
    [`(,op ,triv1 ,triv2)
        `(,op ,(uniquify-triv triv1 env) ,(uniquify-triv triv2 env))]
    [`(let ([,xs ,vs] ...) ,body)
        (define alocs (map (lambda (_) (fresh)) xs))
        (define env*
            (let loop ([xs xs] [as alocs] [e env])
            (if (empty? xs)
                e
                (loop (cdr xs) (cdr as) (cons (cons (car xs) (car as)) e)))))
        (define vs* (map (lambda (v) (uniquify-value v env)) vs))
        `(let (,@(map list alocs vs*)) ,(uniquify-value body env*))]
    [_ (error 'uniquify-value "Expected a value, got: ~a" value)]))

(define (uniquify-tail tail env)
    (match tail
    [(? value?) ; could be int64, then just return that, could be binop triv triv, then we'd have to check if the trivs have name?'s in them, passing environment along
        (uniquify-value tail env)]
    [`(let ([,xs ,vs] ...) ,body)
        (define alocs (map (lambda (_) (fresh)) xs))
        (define env* 
            (let loop ([xs xs]
                [as alocs]
                [e env])
            (if (empty? xs)
                e
                (loop (cdr xs) (cdr as) (cons (cons (car xs) (car as)) e)))))
        (define vs* (map (lambda (v) (uniquify-value v env)) vs))
        `(let (,@(map list alocs vs*)) ,(uniquify-tail body env*))]
    [_ (error 'uniquify-tail "Expected a tail, got: ~a" tail)]
    ))
    
;; (values-lang-v3) -> (values-unique-lang-v3)
;; Resolves all lexical identifiers to abstract locations
(define (uniquify p)
    (check-values-lang p)
    (match p
    [`(module ,tail)
    `(module ,(uniquify-tail tail '()))]
    [_ (error 'uniquify "Expected  (module tail), got: ~a" p)]))