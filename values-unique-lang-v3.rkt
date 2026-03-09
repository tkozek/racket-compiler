#lang racket

(require cpsc411/compiler-lib
         "util.rkt")

(provide sequentialize-let)

(define (sequentialize-value value)
  (match value
    [(? triv?) value]
    [`(,op ,triv1 ,triv2)
     (if (and (binop? op) (triv? triv1) (triv? triv2))
         `(,op ,triv1 ,triv2)
         (error (format "Expected a value, got: ~a" value)))]
    [`(let ([,as ,vs] ...) ,body)
     `(begin
        ,@(map (lambda (a v) `(set! ,a ,(sequentialize-value v))) as vs)
        ,(sequentialize-value body))]))

(define (sequentialize-tail tail)
  (match tail
    [(? triv?) (sequentialize-value tail)]
    [`(,op ,triv1 ,triv2) (sequentialize-value tail)]
    [`(let ([,as ,vs] ...) ,body)
     `(begin
        ,@(map (lambda (a v) `(set! ,a ,(sequentialize-value v))) as vs)
        ,(sequentialize-tail body))]))

;; (values-unique-lang-v3) -> (imp-mf-lang-v3)
;; Picks a particular ordering for let expressions using 'set!'
(define (sequentialize-let p)
  (match p
    [`(module ,tail) `(module ,(sequentialize-tail tail))]))

(module+ test
  (require rackunit
           cpsc411/langs/v3)
  (define-syntax-rule (check-by-interp p)
    (check-equal? (interp-values-lang-v3 p) (interp-values-unique-lang-v3 (uniquify p))))
  (check-equal? (sequentialize-let '(module 0)) '(module 0))
  (check-equal? (sequentialize-let '(module 9223372036854775807)) '(module 9223372036854775807))
  (check-equal? (sequentialize-let '(module -9223372036854775808)) '(module -9223372036854775808))
  (check-equal? (sequentialize-let '(module (let () 0)))
                '(module (begin
                           0)))
  (check-eq? (sequentialize-let '(module (let () 9223372036854775807)))
             '(module (begin
                        9223372036854775807)))
  (check-equal? (sequentialize-let `(module (let () -9223372036854775808)))
                `(module (begin
                           -9223372036854775808)))
  (check-eq? (sequentialize-let '(module (let ([x.1 0]) 1)))
             '(module (begin
                        (set! x.1 0)
                        1)))
  (check-eq? (sequentialize-let '(module (let ([x.2 1]) x.2)))
             '(module (begin
                        (set! x.2 1)
                        x.2)))
  (check-eq? (sequentialize-let '(module (+ 0 1))) '(module (+ 0 1)))
  (check-eq? (sequentialize-let '(module (* -1 2))) '(module (* -1 2)))
  (check-eq? (sequentialize-let '(module x.2)) '(module x.2))
  (check-eq? (sequentialize-let '(module (let ([x.1 1]
                                               [x.2 -1]
                                               [x.3 4])
                                           (* x.3 x.2))))
             '(module (begin
                        (set! x.1 1)
                        (set! x.2 -1)
                        (set! x.3 4)
                        (* x.3 x.2))))
  (check-eq? (sequentialize-let '(module (let ([x.1 (let ([x.2 5]) x.2)]) x.1)))
             '(module (begin
                        (set! x.1
                              (begin
                                (set! x.2 5)
                                x.2))
                        x.1)))
  (check-eq? (sequentialize-let '(module (let ([x.1 (let ([x.2 (let ([x.3 3]) (* x.3 x.3))]) x.2)])
                                           (* 2 x.1))))
             '(module (begin
                        (set! x.1
                              (begin
                                (set! x.2
                                      (begin
                                        (set! x.3 3)
                                        (* x.3 x.3)))
                                x.2))
                        (* 2 x.1))))
  (check-eq? (sequentialize-let '(module (let ([x.1 (+ 1 2)]) (let ([x.2 (+ x.1 3)]) 0))))
             '(module (begin
                        (set! x.1 (+ 1 2))
                        (begin
                          (set! x.2 (+ x.1 3))
                          0))))
  (check-eq? (sequentialize-let '(module (let ([x.1 (+ 1 2)]) (let ([x.2 (+ x.1 3)]) (* 2 x.1)))))
             '(module (begin
                        (set! x.1 (+ 1 2))
                        (begin
                          (set! x.2 (+ x.1 3))
                          (* 2 x.1)))))
  (check-eq? (sequentialize-let '(module (let ([x.1 (+ 1 2)]) (let ([x.2 (+ x.1 3)]) (+ x.2 x.1)))))
             '(module (begin
                        (set! x.1 (+ 1 2))
                        (begin
                          (set! x.2 (+ x.1 3))
                          (+ x.2 x.1)))))
  (check-eq? (sequentialize-let '(module (let ([x.1 (+ 1 2)]) (let ([x.2 (+ x.1 3)]) (* x.2 x.1)))))
             '(module (begin
                        (set! x.1 (+ 1 2))
                        (begin
                          (set! x.2 (+ x.1 3))
                          (* x.2 x.1))))))
