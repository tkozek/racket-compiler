#lang racket

(require cpsc411/compiler-lib
         "common.rkt")

(provide dox-lambdas)

;; (Just-exprs-lang-v9 p) -> (Lam-opticon-lang-v9 p)
;; Explicitly binds all procedures to abstract locations.
(define (dox-lambdas p)

  (define (dox-value value)
    (match value
      [`(,primop ,values ...)
       #:when (primop? primop)
       `(,primop ,@(map dox-value values))]
      [`(unsafe-procedure-call ,values ...) `(unsafe-procedure-call ,@(map dox-value values))]
      [`(letrec ([,alocs ,lambdas] ...)
          ,value-body)
       (let ([doxxed-bindings (for/list ([aloc alocs]
                                         [lambda lambdas])
                                (match lambda
                                  [`(lambda ,params ,value)
                                   `(,aloc (lambda ,params ,(dox-value value)))]))])
         `(letrec ,doxxed-bindings
            ,(dox-value value-body)))]
      [`(let ([,alocs ,values] ...) ,value-body)
       (let ([doxxed-bindings (for/list ([aloc alocs]
                                         [value values])
                                `(,aloc ,(dox-value value)))])
         `(let ,doxxed-bindings ,(dox-value value-body)))]
      [`(if ,values ...) `(if ,@(map dox-value values))]
      [`(begin
          ,effects ...
          ,value)
       `(begin
          ,@(map dox-effect effects)
          ,(dox-value value))]
      [triv (dox-triv triv)]))

  (define (dox-effect effect)
    (match effect
      [`(,primop ,values ...)
       #:when (primop? primop)
       `(,primop ,@(map dox-value values))]
      [`(begin
          ,effects ...)
       `(begin
          ,@(map dox-effect effects))]))

  (define (dox-triv triv)
    (match triv
      [`(lambda ,alocs ,value-body)
       (let ([new-aloc (fresh)])
         `(letrec ([,new-aloc (lambda ,alocs ,(dox-value value-body))])
            ,new-aloc))]
      [_ triv]))

  (match p
    [`(module ,value) `(module ,(dox-value value))]))

(module+ test
  (require rackunit)

  (check-match (dox-lambdas `(module (lambda (x.1) x.1)))
               `(module (letrec ([,lam.4 (lambda (x.1) x.1)])
                          ,lam.4)))

  (check-match (dox-lambdas `(module (let ([x.1 5]
                                           [y.2 (lambda (z.3) z.3)])
                                       y.2)))
               `(module (let ([x.1 5]
                              [y.2 (letrec ([,lam.4 (lambda (z.3) z.3)])
                                     ,lam.4)])
                          y.2)))

  (check-match (dox-lambdas `(module (let ([x.1 (lambda (a.2) a.2)]
                                           [y.3 (lambda (b.4) (unsafe-fx+ b.4 1))])
                                       x.1)))
               `(module (let ([x.1 (letrec ([,lam.4 (lambda (a.2) a.2)])
                                     ,lam.4)]
                              [y.3 (letrec ([,lam.5 (lambda (b.4) (unsafe-fx+ b.4 1))])
                                     ,lam.5)])
                          x.1)))

  (check-match (dox-lambdas `(module (letrec ([f.1 (lambda (x.2) x.2)]
                                              [g.3 (lambda (y.4) (unsafe-fx+ y.4 1))])
                                       f.1)))
               `(module (letrec ([f.1 (lambda (x.2) x.2)]
                                 [g.3 (lambda (y.4) (unsafe-fx+ y.4 1))])
                          f.1))))
