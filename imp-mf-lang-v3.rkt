#lang racket

(require cpsc411/compiler-lib
         "util.rkt")

(provide normalize-bind)

;; (Imp-mf-lang-v3 effect) -> (Imp-cmf-lang-v3 effect)
(define (normalize-effect effect)
  (match effect
    [`(set! ,aloc
            (begin
              ,effects ...
              ,value))
     `(begin
        ,@(map normalize-effect effects)
        (set! ,aloc ,(normalize-value value)))]
    [`(set! ,aloc ,value) `(set! ,aloc ,(normalize-value value))]
    [`(begin
        ,effects ...
        ,effect2)
     `(begin
        ,@(map normalize-effect effects)
        ,(normalize-effect effect2))]))

;; (Imp-mf-lang-v3 value) -> (Imp-cmf-lang-v3 value)
(define (normalize-value value)
  (match value
    [(? triv?) value]
    [`(,op ,triv1 ,triv2)
     (if (and (binop? op) (triv? triv1) (triv? triv2))
         value
         (error (format "Expected a value, got: ~a" value)))]
    [`(begin
        ,effects ...
        ,body)
     `(begin
        ,@(map normalize-effect effects)
        ,(normalize-value body))]))

;; (Imp-mf-lang-v3 tail) -> (Imp-cmf-lang-v3 tail)
(define (normalize-tail tail)
  (match tail
    [(? triv?) (normalize-value tail)]
    [`(,op ,triv1 ,triv2) (normalize-value tail)]
    [`(begin
        ,effects ...
        ,body)
     `(begin
        ,@(map normalize-effect effects)
        ,(normalize-tail body))]))

;; (imp-mf-lang-v3 p) -> (imp-cmf-lang-v3 p)
;; Pushes 'set!' under 'begin' so that RHS of each 'set!' is a simple value producing operation
(define (normalize-bind p)
  (match p
    [`(module ,tail) `(module ,(normalize-tail tail))]))

(module+ test
  (require rackunit
           cpsc411/langs/v3)
  (define-syntax-rule (check-by-interp p)
    (check-equal? (interp-values-lang-v3 p) (interp-values-unique-lang-v3 (uniquify p))))

  (check-equal? (normalize-bind '(module 0)) '(module 0))
  (check-equal? (normalize-bind '(module 9223372036854775807)) '(module 9223372036854775807))
  (check-equal? (normalize-bind '(module -9223372036854775808)) '(module -9223372036854775808))
  (check-equal? (normalize-bind '(module (+ 1 2))) '(module (+ 1 2)))
  (check-equal? (normalize-bind '(module (* -2 1))) '(module (* -2 1)))
  (check-equal? (normalize-bind '(module (* 1 9223372036854775807)))
                '(module (* 1 9223372036854775807)))
  (check-equal? (normalize-bind '(module (+ 10 -9223372036854775808)))
                '(module (+ 10 -9223372036854775808)))
  (check-equal? (normalize-bind '(module (begin
                                           (set! x.1 1)
                                           x.1)))
                '(module (begin
                           (set! x.1 1)
                           x.1)))
  (check-equal? (normalize-bind '(module (begin
                                           (set! x.1 2)
                                           (set! x.1 5)
                                           (+ 42 x.1))))
                '(module (begin
                           (set! x.1 2)
                           (set! x.1 5)
                           (+ 42 x.1))))
  (check-equal? (normalize-bind '(module (begin
                                           (set! x.1 (+ 2 4))
                                           (set! x.1 (* 3 3))
                                           (+ 42 x.1))))
                '(module (begin
                           (set! x.1 (+ 2 4))
                           (set! x.1 (* 3 3))
                           (+ 42 x.1))))
  (check-equal? (normalize-bind '(module (begin
                                           (set! x.1 (+ 2 4))
                                           (set! x.2 (* 3 3))
                                           (+ x.2 x.1))))
                '(module (begin
                           (set! x.1 (+ 2 4))
                           (set! x.2 (* 3 3))
                           (+ x.2 x.1))))
  (check-equal? (normalize-bind '(module (begin
                                           (set! x.1 1)
                                           (set! x.2 0)
                                           (* x.2 x.1))))
                '(module (begin
                           (set! x.1 1)
                           (set! x.2 0)
                           (* x.2 x.1))))
  (check-equal? (normalize-bind '(module (begin
                                           (set! x.1 2)
                                           (set! x.1 5)
                                           (+ x.1 x.1))))
                '(module (begin
                           (set! x.1 2)
                           (set! x.1 5)
                           (+ x.1 x.1))))
  (check-equal? (normalize-bind '(module (begin
                                           (set! x.1
                                                 (begin
                                                   ()
                                                   5))
                                           0)))
                '(module (begin
                           (begin
                             (set! x.1 5))
                           0)))
  (check-equal? (normalize-bind '(module (begin
                                           (set! x.1
                                                 (begin
                                                   ()
                                                   5))
                                           x.1)))
                '(module (begin
                           (begin
                             (set! x.1 5))
                           x.1)))
  (check-equal? (normalize-bind '(module (begin
                                           (set! x.1
                                                 (begin
                                                   (set! x.2 5)
                                                   (set! x.1 3)
                                                   1))
                                           2)))
                '(module (begin
                           (begin
                             (set! x.2 5)
                             (set! x.1 3)
                             (set! x.1 1)
                             2))))
  (check-equal? (normalize-bind '(module (begin
                                           (set! x.1
                                                 (begin
                                                   (set! x.2 5)
                                                   (set! x.1 3)
                                                   1))
                                           (+ x.1 x.2))))
                '(module (begin
                           (begin
                             (set! x.2 5)
                             (set! x.1 3)
                             (set! x.1 1)
                             (+ x.1 x.2)))))
  (check-equal? (normalize-bind '(module (begin
                                           (set! x.1
                                                 (begin
                                                   (set! x.2 5)
                                                   (set! x.1 3)
                                                   (+ x.2 x.1)))
                                           (+ x.1 x.2))))
                '(module (begin
                           (begin
                             (set! x.2 5)
                             (set! x.1 3)
                             (set! x.1 (+ x.2 x.1))
                             (+ x.1 x.2)))))
  (check-equal? (normalize-bind '(module (begin
                                           (set! x.1
                                                 (begin
                                                   (set! x.2 5)
                                                   (set! x.1 3)
                                                   (* x.2 x.1)))
                                           (+ x.1 x.2))))
                '(module (begin
                           (begin
                             (set! x.2 5)
                             (set! x.1 3)
                             (set! x.1 (* x.2 x.1))
                             (+ x.1 x.2)))))
  (check-equal? (normalize-bind '(module (begin
                                           (set! x.1
                                                 (begin
                                                   (set! x.2 5)
                                                   (set! x.1 3)
                                                   (* x.2 x.1)))
                                           (* 5 x.2))))
                '(module (begin
                           (begin
                             (set! x.2 5)
                             (set! x.1 3)
                             (set! x.1 (* x.2 x.1))
                             (* 5 x.2)))))
  (check-equal? (normalize-bind '(module (begin
                                           (set! x.1
                                                 (begin
                                                   (set! x.2 5)
                                                   (set! x.1 3)
                                                   (+ x.2 x.1)))
                                           (* 5 x.2))))
                '(module (begin
                           (begin
                             (set! x.2 5)
                             (set! x.1 3)
                             (set! x.1 (+ x.2 x.1))
                             (* 5 x.2)))))
  (check-equal? (normalize-bind '(module (begin
                                           (set! x.1 2)
                                           (set! x.2 3)
                                           (begin
                                             (set! x.1 3)
                                             (set! x.2 1)
                                             1))))
                '(module (begin
                           (set! x.1 2)
                           (set! x.2 3)
                           (begin
                             (set! x.1 3)
                             (set! x.2 1)
                             1))))
  (check-equal? (normalize-bind '(module (begin
                                           (set! x.1 2)
                                           (set! x.2 3)
                                           (begin
                                             (set! x.1 3)
                                             (set! x.2 1)
                                             (+ x.1 x.2)))))
                '(module (begin
                           (set! x.1 2)
                           (set! x.2 3)
                           (begin
                             (set! x.1 3)
                             (set! x.2 1)
                             (+ x.1 x.2)))))
  (check-equal? (normalize-bind '(module (begin
                                           (set! x.1 2)
                                           (set! x.2 3)
                                           (begin
                                             (set! x.1 3)
                                             (set! x.2
                                                   (begin
                                                     4))
                                             (+ x.1 x.2)))))
                '(module (begin
                           (set! x.1 2)
                           (set! x.2 3)
                           (begin
                             (set! x.1 3)
                             (begin
                               (set! x.2 4))
                             (+ x.1 x.2)))))

  (check-equal? (normalize-bind '(module (begin
                                           (set! x.1 2)
                                           (set! x.2 3)
                                           (begin
                                             (set! x.1 3)
                                             (set! x.2
                                                   (begin
                                                     (set! x.1 4)
                                                     (set! x.1 0)
                                                     (+ x.1 x.1))))
                                           (+ x.1 x.2))))
                '(module (begin
                           (set! x.1 2)
                           (set! x.2 3)
                           (begin
                             (set! x.1 3)
                             (begin
                               (set! x.1 4)
                               (set! x.1 0)
                               (set! x.2 (+ x.1 x.1)))
                             (+ x.1 x.2))))))
