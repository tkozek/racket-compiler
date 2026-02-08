#lang racket

(require cpsc411/compiler-lib
        cpsc411/2c-run-time)

(provide triv?
        binop?
        value?
        tail?)
(define (triv? t)
  (or (int64? t) (name? t)))

(define (binop? op)
  (and (member op '(+ *)) #t))

(define (value? val)
  (match val
    [(? triv?)
    #t]
    [`(,op ,t1 ,t2)
     (and (binop? op) (triv? t1) (triv? t2))]
    [`(let ([,xs ,vs] ...) ,body)
    (and (andmap (name? xs)) (andmap (value? vs)) (value? body))]
    [_ #f]))
 
(define (tail? tail)
    (match tail
        [(? value?) #t]
        [`(let ([,xs ,vs] ...) ,body)
        (and 
        (andmap (name? xs)) 
        (andmap (value? vs)) 
        (tail? body))]
        [_ #f]))
