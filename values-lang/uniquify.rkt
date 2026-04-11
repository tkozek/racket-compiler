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
      [_ (dict-ref env triv (λ () (fresh triv)))]))

  ;; maps names to abstract locations, updates environment with these new bindings and returns them
  ;; along with the updated environment
  ;; ('(name) '(value) '(name : aloc)) -> ((values '((aloc value)) '(name : aloc)))
  (define (uniquify-pairs xs vals env)
    (define alocs (map (lambda (x) (fresh x)) xs))
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
