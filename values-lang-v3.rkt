#lang racket

(require cpsc411/compiler-lib
         "util.rkt"
         cpsc411/2c-run-time)

(provide uniquify
         check-values-lang)

;; Validator for Values-lang-v3
(define (check-values-lang p)
  (match p
    [`(module ,tail)
     (if (tail? tail)
         p
         (error "wasn't values-lang-v3"))]))

(define (uniquify-triv triv env)
  (match triv
    [(? int64?) triv]
    [(? name?)
     (dict-ref env triv (lambda () (raise (make-exn:fail))))] ;; We found a name, it is supposed to be trivial, which means it should exist in our environment, so raise error if it isn't in our environment
    ;; (it not being in our environment would mean we have an unbound name)
    ))

(define (uniquify-value value env)
  (match value
    [(? triv?) (uniquify-triv value env)]
    [`(,op ,triv1 ,triv2) `(,op ,(uniquify-triv triv1 env) ,(uniquify-triv triv2 env))]
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
     `(let (,@(map list alocs vs*)) ,(uniquify-value body env*))]))

(define (uniquify-tail tail env)
  (match tail
    [(?
      value?) ; could be int64, then just return that, could be binop triv triv, then we'd have to check if the trivs have name?'s in them, passing environment along
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
     `(let (,@(map list alocs vs*)) ,(uniquify-tail body env*))]))

;; (values-lang-v3) -> (values-unique-lang-v3)
;; Resolves all lexical identifiers to abstract locations
(define (uniquify p)
  ; (check-values-lang p)
  (match p
    [`(module ,tail) `(module ,(uniquify-tail tail '()))]))

(module+ test
  (require rackunit
           cpsc411/langs/v3)
  (define-syntax-rule (check-by-interp p)
    (check-equal? (interp-values-lang-v3 p) (interp-values-unique-lang-v3 (uniquify p))))

  ;; First five tests taken from book
  (check-equal? (uniquify '(module (+ 2 2))) '(module (+ 2 2)))
  (check-equal? (uniquify '(module (* 2 2))) '(module (* 2 2)))
  (check-match (uniquify '(module (let ([x 5]) x))) `(module (let ([,x 5]) ,x)))
  (check-match (uniquify '(module (let ([x (+ 2 2)]) x))) `(module (let ([,x (+ 2 2)]) ,x)))
  (check-match (uniquify '(module (let ([x 2]) (let ([y 2]) (+ x y)))))
               `(module (let ([,x 2]) (let ([,y 2]) (+ ,x ,y)))))
  (check-match (uniquify '(module (let ([x 2]) (let ([x 2]) (+ x x)))))
               `(module (let ([,x 2]) (let ([,y 2]) (+ ,y ,y)))))
  (check-equal? (uniquify '(module (let '() 0))) '(module (let '() 0)))
  (check-equal? (uniquify '(module (let '() (+ 2 2)))) '(module (let '() (+ 2 2))))
  (check-equal? (uniquify '(module (let '() (let '() 42)))) '(module (let '() (let '() 42))))
  (check-equal? (uniquify '(module (let '() (let ([x 0]) (+ (max-int 64) x)))))
                '(module (let '() (let ([x.7 0]) (+ (max-int 64) x.7)))))
  (check-equal? (uniquify '(module (let '() (let '() (let '() -1)))))
                '(module (let '() (let '() (let '() -1)))))
  (check-equal? (uniquify '(module 0)) '(module 0))
  (check-equal? (uniquify '(module 9223372036854775807)) '(module 9223372036854775807))
  (check-equal? (uniquify '(module 9223372036854775806)) '(module 9223372036854775806))
  (check-equal? (uniquify '(module -9223372036854775808)) '(module -9223372036854775808))
  (check-equal? (uniquify '(module -9223372036854775807)) '(module -9223372036854775807))
  (check-exn exn:fail? (lambda () (uniquify '(module 9223372036854775808))))
  (check-exn exn:fail? (lambda () (uniquify '(module -9223372036854775809))))
  (check-exn exn:fail? (lambda () (uniquify '(module x))))
  (check-exn exn:fail? (lambda () (uniquify '(module (+ x y)))))
  (check-exn exn:fail? (lambda () (uniquify '(module (* x y)))))
  (check-exn exn:fail? (lambda () (uniquify '(module))))
  (check-exn exn:fail? (lambda () (uniquify '(module (add1 2 2)))))
  ;; Nested binop
  (check-exn exn:fail? (lambda () (uniquify '(module (+ 1 (+ 1 1))))))
  ;; Binop with one triv OOB for int64
  (check-exn exn:fail? (lambda () (uniquify '(module (* 2 9223372036854775808)))))
  ;; Binop with both triv OOB for int64
  (check-exn exn:fail? (lambda () (uniquify '(module (* 9223372036854775808 9223372036854775808)))))
  (check-exn exn:fail? (lambda () (uniquify '(module (* -9223372036854775809 -9223372036854775808)))))
  (check-exn exn:fail? (lambda () (uniquify '(module (* -9223372036854775809 9223372036854775808)))))
  ;;
  )
