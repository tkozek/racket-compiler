#lang racket

(require cpsc411/compiler-lib
         "common.rkt")

(provide optimize-predicates
         nested-asm-lang-progs)
; Not supported past M6

;; (nested-asm-lang-fvars-v6 p) -> (nested-asm-lang-fvars-v6 p)
;; Optimizes Nested-asm-lang-v4 programs by analyzing and simplifying predicates
(define (optimize-predicates p)

  ;   ;; (nested-asm-lang-fvars-v6?) -> boolean
  ;   ;; wrapper for int64?, may change implementation if optimize-predicates implementation changes
  ;   ;; to statically evaluate a wider array of expressions.
  ;   (define (concrete? val)
  ;     (int64? val))

  ;   ;; ((nested-asm-lang-fvars-v6 opand) (list (loc . (triv | 'unknown)))) ->
  ;   ;;                                                              (nested-asm-lang-fvars-v6 triv) | 'unknown
  ;   ;; Tries to make opand concrete using env, returns 'unknown if this is not possible
  ;   (define (abstract-opand opand env)
  ;     (if (int64? opand)
  ;         opand
  ;         (hash-ref env opand 'unknown)))

  ;   ;; ((nested-asm-lang-fvars-v6 binop opand opand) (list (loc . (triv | 'unknown))))
  ;   ;;      -> 'unknown | int64
  ;   (define (abstract-binop op v1 v2 env)
  ;     (define v1 (abstract-opand v1 env))
  ;     (define v2 (abstract-opand v2 env))
  ;     (match* (v1 v2)
  ;       [((? int64?) (? int64?)) (op v1 v2)]
  ;       [(_ _) 'unknown]))

  ;   ;; ('relop) -> (nested-asm-lang-fvars-v6 relop)
  ;   ;; Returns the function which op symbolizes.
  ;   (define (patch-relop op)
  ;     (match op
  ;       ['> >]
  ;       ['< <]
  ;       ['= =]
  ;       ['>= >=]
  ;       ['<= <=]
  ;       ['!= (λ (x y) (not (= x y)))]))

  ;   ;; (nested-asm-lang-fvars-v6 relop loc opand (list (loc . (triv | 'unknown)))
  ;   ;;                                          -> '(true) | '(false) | 'unknown
  ;   ;; Attempts to resolve (relop v1 v2), using static information stored in env. Returns 'unknown
  ;   ;; if there is not enough static information available.
  ;   (define (abstract-relop relop loc opand env)
  ;     (define v1 (abstract-opand loc env))
  ;     (define v2 (abstract-opand opand env))
  ;     (match* (v1 v2)
  ;       [((? concrete?) (? concrete?))
  ;        (if ((patch-relop relop) v1 v2)
  ;            '(true)
  ;            '(false))]
  ;       [(_ _) `(,relop ,loc ,opand)]))

  ;   ;; ((nested-asm-lang-fvars-v6 effect) ((and/c hash? (not/c immutable?)))) -> ('unknown | triv)
  ;   (define (update-env effect env)
  ;     (match effect
  ;       [`(set! ,loc ,triv)
  ;        (if (int64? triv)
  ;            (hash-set! env loc triv)
  ;            (hash-set! env loc (hash-ref env triv 'unknown)))]
  ;       [`(set! ,loc1 (,op ,loc1 ,opand))
  ;        (define cur-val (hash-ref env loc1 'unknown))
  ;        (if (int64? cur-val)
  ;            (hash-set! env loc1 (abstract-binop op cur-val opand env))
  ;            (hash-set! env loc1 'unknown))]))

  ;   (define (optimize-pred pred env)
  ;     (match pred
  ;       [`(if (not ,pred) ,pred2 ,pred3) (optimize-pred `(if ,pred ,pred3 ,pred2) env)]
  ;       [`(if ,pred-cond ,then-pred ,else-pred)
  ;        (define optimized-cond (optimize-pred pred-cond env))
  ;        (define env-then (hash-copy env))
  ;        (define env-else (hash-copy env))
  ;        (cond
  ;          [(equal? optimized-cond '(true)) (optimize-pred then-pred env-then)]
  ;          [(equal? optimized-cond '(false)) (optimize-pred else-pred env-else)]
  ;          [else
  ;           `(if ,optimized-cond
  ;                ,(optimize-pred then-pred env-then)
  ;                ,(optimize-pred else-pred env-else))])]
  ;       [`(begin
  ;           ,effects ...
  ;           ,pred)
  ;        `(begin
  ;           ,@(for/list ([e effects])
  ;               (optimize-effect e env))
  ;           ,(optimize-pred pred env))]
  ;       [`(,relop ,loc ,opand) (abstract-relop relop loc opand env)]
  ;       [_ pred]))

  ;   (define (optimize-effect effect env)
  ;     (match effect
  ;       [`(set! ,loc ,rest)
  ;        (begin
  ;          (update-env effect env)
  ;          effect)]
  ;       [`(begin
  ;           ,effects ...)
  ;        `(begin
  ;           ,@(for/list ([effect effects])
  ;               (optimize-effect effect env)))]
  ;       [`(if (not ,cond-pred) ,then-pred ,else-pred)
  ;        (optimize-effect `(if ,cond-pred ,else-pred ,then-pred) env)]
  ;       [`(if ,cond-pred ,then-pred ,else-pred)
  ;        (define optimized-cond (optimize-pred cond-pred env))
  ;        (define env-then (hash-copy env))
  ;        (define env-else (hash-copy env))
  ;        (cond
  ;          [(equal? optimized-cond '(true)) (optimize-effect then-pred env-then)]
  ;          [(equal? optimized-cond '(false)) (optimize-effect else-pred env-else)]
  ;          [else
  ;           `(if ,optimized-cond
  ;                ,(optimize-effect then-pred env-then)
  ;                ,(optimize-effect else-pred env-else))])]
  ;       ;; not really extending m8
  ;       [_ effect]))

  ;   (define (optimize-tail tail env)
  ;     (match tail
  ;       [`(begin
  ;           ,effects ...
  ;           ,tail)
  ;        `(begin
  ;           ,@(for/list ([effect effects])
  ;               (optimize-effect effect env))
  ;           ,(optimize-tail tail env))]
  ;       [`(if (not ,pred) ,t1 ,t2) (optimize-tail `(if ,pred ,t2 ,t1) env)]
  ;       [`(if ,pred ,t1 ,t2)
  ;        (define optimized-cond (optimize-pred pred env))
  ;        (define env-then (hash-copy env))
  ;        (define env-else (hash-copy env))
  ;        (cond
  ;          [(equal? optimized-cond '(true)) (optimize-tail t1 env-then)]
  ;          [(equal? optimized-cond '(false)) (optimize-tail t2 env-else)]
  ;          [else
  ;           `(if ,optimized-cond
  ;                ,(optimize-tail t1 env-then)
  ;                ,(optimize-tail t2 env-else))])]
  ;       [_ tail]))

  ;   ;; (nested-asm-lang-fvars-v6) -> (nested-asm-lang-fvars-v6)
  ;   ;; Optimizes an individual nested-asm-lang-fvars-v6 procedure definition
  ;   (define (optimize-def def)
  ;     (match def
  ;       [`(define ,label ,tail) `(define ,label ,(optimize-tail tail (make-hash)))]))

  ;   ;; (nested-asm-lang-fvars-v6 p) -> (nested-asm-lang-fvars-v6 p)
  ;   (define (optimize-p p)
  ;     (match p
  ;       [`(module ,defs ...
  ;           ,tail)
  ;        `(module ,@(map optimize-def defs) ,(optimize-tail tail (make-hash))
  ;           )]))

  ;   (optimize-p p)
  p)

(define nested-asm-lang-progs
  '((module (true)) (module (false))
                    (module (not (true)))
                    (module (not (false)))
                    (module (if (true)))))

(module+ test
  (require rackunit
           cpsc411/langs/v6)

  (define-syntax-rule (check-by-interp p)
    (check-equal? (interp-nested-asm-lang-fvars-v6 p)
                  (interp-nested-asm-lang-fvars-v6 (optimize-predicates p)))))
