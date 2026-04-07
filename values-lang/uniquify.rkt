#lang racket

(require cpsc411/compiler-lib
         "../util.rkt"
         cpsc411/2c-run-time)

(provide uniquify
         check-values-lang)

;; stub of validator for Values-lang-v3
(define (check-values-lang p)
  p)

;; (values-lang-v3) -> (values-unique-lang-v3)
;; Resolves all lexical identifiers to abstract locations
(define (uniquify p)

  (define (uniquify-triv triv env)
    (match triv
      [(? int64?) triv]
      [_ (dict-ref env triv (fresh triv))]))

  ;; maps names to abstract locations, updates environment with these new bindings and returns them
  ;; along with the updated environment
  ;; ('(name) '(value) '(name : aloc)) -> ((values '((aloc value)) '(name : aloc)))
  (define (uniquify-pairs xs vals env)
    (define alocs (map (lambda (x) (dict-ref env x (fresh x))) xs))
    ;; n lists input to foldl, requires n + 1 args in lambda, last arg is an accumulator
    ;; (the environment in this case). accumulator must be passed before the n lists
    (define new-env (foldl (lambda (x aloc e) (dict-set e x aloc)) env xs alocs))
    (values (map list alocs (map (lambda (val) (uniquify-value val env)) vals)) new-env))

  (define (uniquify-value value env)
    (match value
      [`(let ([,xs ,vals] ...) ,body-value)
       (define-values (bindings new-env) (uniquify-pairs xs vals env))
       `(let ,bindings ,(uniquify-value body-value new-env))]
      [`(,binop ,triv1 ,triv2)
       #:when (binop? binop)
       `(,binop ,(uniquify-triv triv1 env) ,(uniquify-triv triv2 env))]
      [_ (uniquify-triv value env)]))

  (define (uniquify-tail tail env)
    (match tail
      [`(let ([,xs ,vals] ...) ,body-tail)
       (define-values (bindings new-env) (uniquify-pairs xs vals env))
       `(let ,bindings ,(uniquify-tail body-tail new-env))]
      [_ (uniquify-value tail env)]))

  (define (uniquify-p p)
    (match p
      [`(module ,tail) `(module ,(uniquify-tail tail (hash)))]))
  (uniquify-p p))

(module+ test
  (require rackunit
           cpsc411/langs/v3)
  (define-syntax-rule (check-by-interp p)
    (check-equal? (interp-values-lang-v3 p) (interp-values-unique-lang-v3 (uniquify p))))
  ;;

  ;   ;; First five tests taken from book
  ;   (check-equal? (uniquify '(module (+ 2 2))) '(module (+ 2 2)))
  ;   (check-equal? (uniquify '(module (* 2 2))) '(module (* 2 2)))
  ;   (check-match (uniquify '(module (let ([x 5]) x))) `(module (let ([,x 5]) ,x)))
  ;   (check-match (uniquify '(module (let ([x (+ 2 2)]) x))) `(module (let ([,x (+ 2 2)]) ,x)))
  ;   (check-match (uniquify '(module (let ([x 2]) (let ([y 2]) (+ x y)))))
  ;                `(module (let ([,x 2]) (let ([,y 2]) (+ ,x ,y)))))
  ;   (check-match (uniquify '(module (let ([x 2]) (let ([x 2]) (+ x x)))))
  ;                `(module (let ([,x 2]) (let ([,y 2]) (+ ,y ,y)))))
  ;   (check-equal? (uniquify '(module (let '() 0))) '(module (let '() 0)))
  ;   (check-equal? (uniquify '(module (let '() (+ 2 2)))) '(module (let '() (+ 2 2))))
  ;   (check-equal? (uniquify '(module (let '() (let '() 42)))) '(module (let '() (let '() 42))))
  ;   (check-equal? (uniquify '(module (let '() (let ([x 0]) (+ (max-int 64) x)))))
  ;                 '(module (let '() (let ([x.7 0]) (+ (max-int 64) x.7)))))
  ;   (check-equal? (uniquify '(module (let '() (let '() (let '() -1)))))
  ;                 '(module (let '() (let '() (let '() -1)))))
  ;   (check-equal? (uniquify '(module 0)) '(module 0))
  ;   (check-equal? (uniquify '(module 9223372036854775807)) '(module 9223372036854775807))
  ;   (check-equal? (uniquify '(module 9223372036854775806)) '(module 9223372036854775806))
  ;   (check-equal? (uniquify '(module -9223372036854775808)) '(module -9223372036854775808))
  ;   (check-equal? (uniquify '(module -9223372036854775807)) '(module -9223372036854775807))
  ;   (check-exn exn:fail? (lambda () (uniquify '(module 9223372036854775808))))
  ;   (check-exn exn:fail? (lambda () (uniquify '(module -9223372036854775809))))
  ;   (check-exn exn:fail? (lambda () (uniquify '(module x))))
  ;   (check-exn exn:fail? (lambda () (uniquify '(module (+ x y)))))
  ;   (check-exn exn:fail? (lambda () (uniquify '(module (* x y)))))
  ;   (check-exn exn:fail? (lambda () (uniquify '(module))))
  ;   (check-exn exn:fail? (lambda () (uniquify '(module (add1 2 2)))))
  ;   ;; Nested binop
  ;   (check-exn exn:fail? (lambda () (uniquify '(module (+ 1 (+ 1 1))))))
  ;   ;; Binop with one triv OOB for int64
  ;   (check-exn exn:fail? (lambda () (uniquify '(module (* 2 9223372036854775808)))))
  ;   ;; Binop with both triv OOB for int64
  ;   (check-exn exn:fail? (lambda () (uniquify '(module (* 9223372036854775808 9223372036854775808)))))
  ;   (check-exn exn:fail? (lambda () (uniquify '(module (* -9223372036854775809 -9223372036854775808)))))
  ;   (check-exn exn:fail? (lambda () (uniquify '(module (* -9223372036854775809 9223372036854775808)))))
  ;;
  )
