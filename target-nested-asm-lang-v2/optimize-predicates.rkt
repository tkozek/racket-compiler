#lang racket

(require cpsc411/compiler-lib
         cpsc411/langs/v4
         "assign-homes.rkt"
         "../generate-x64.rkt")

(provide optimize-predicates
         nested-asm-lang-progs)

;; nested-asm-lang-v5
;   p	 	::=	 	(module (define label tail) ... tail)
;   pred	 	::=	 	(relop loc opand)
;  	 	|	 	(true)
;  	 	|	 	(false)
;  	 	|	 	(not pred)
;  	 	|	 	(begin effect ... pred)
;  	 	|	 	(if pred pred pred)
;   tail	 	::=	 	(halt opand)
;  	 	|	 	(jump trg)
;  	 	|	 	(begin effect ... tail)
;  	 	|	 	(if pred tail tail)
;   effect	 	::=	 	(set! loc triv)
;  	 	|	 	(set! loc_1 (binop loc_1 opand))
;  	 	|	 	(begin effect ... effect)
;  	 	|	 	(if pred effect effect)
;   triv	 	::=	 	opand
;  	 	|	 	label
;   opand	 	::=	 	int64
;  	 	|	 	loc
;   loc	 	::=	 	reg
;  	 	|	 	fvar
;   trg	 	::=	 	label
;  	 	|	 	loc
;   reg	 	::=	 	rsp
;  	 	|	 	rbp
;  	 	|	 	rax
;  	 	|	 	rbx
;  	 	|	 	rcx
;  	 	|	 	rdx
;  	 	|	 	rsi
;  	 	|	 	rdi
;  	 	|	 	r8
;  	 	|	 	r9
;  	 	|	 	r12
;  	 	|	 	r13
;  	 	|	 	r14
;  	 	|	 	r15

;   binop	 	::=	 	*
;  	 	|	 	+

;   relop	 	::=	 	<
;  	 	|	 	<=
;  	 	|	 	=
;  	 	|	 	>=
;  	 	|	 	>
;  	 	|	 	!=
;   fvar	 	::=	 	fvar?
;   label	 	::=	 	label?
;   int64	 	::=	 	int64?

;; returns x64 function corresponding to this binop
(define (op->x64-function op)
  (match op

    ['+ x64-add]
    ['* x64-mul]))

;; (nested-asm-lang-v5 p) -> (nested-asm-lang-v5 p)
;; Optimizes Nested-asm-lang-v4 programs by analyzing and simplifying predicates
(define (optimize-predicates p)

  ;; (nested-asm-lang-v5?) -> boolean
  ;; wrapper for int64?, may change implementation if optimize-predicates implementation changes
  ;; to statically evaluate a wider array of expressions.
  (define (concrete? val)
    (int64? val))

  ;; ((nested-asm-lang-v5 opand) (list (loc . (triv | 'unknown)))) ->
  ;;                                                              (nested-asm-lang-v5 triv) | 'unknown
  ;; Tries to make opand concrete using env, returns 'unknown if this is not possible
  (define (abstract-opand opand env)
    (if (int64? opand)
        opand
        (hash-ref env opand 'unknown)))

  ;; ((nested-asm-lang-v5 binop opand opand) (list (loc . (triv | 'unknown))))
  ;;      -> 'unknown | int64
  (define (abstract-binop op v1 v2 env)
    (let ([v1 (abstract-opand v1 env)]
          [v2 (abstract-opand v2 env)])
      (match* (v1 v2)
        [((? int64?) (? int64?)) ((op->x64-function op) v1 v2)]
        [(_ _) 'unknown])))

  ;; ('relop) -> (nested-asm-lang-v5 relop)
  ;; Returns the function which op symbolizes.
  (define (patch-relop op)
    (match op
      ['> >]
      ['< <]
      ['= =]
      ['>= >=]
      ['<= <=]
      ['!= (λ (x y) (not (= x y)))]
      [_ (error "ffddf")]))

  ;; (nested-asm-lang-v5 relop loc opand (list (loc . (triv | 'unknown)))
  ;;                                          -> '(true) | '(false) | 'unknown
  ;; Attempts to resolve (relop v1 v2), using static information stored in env. Returns 'unknown
  ;; if there is not enough static information available.
  (define (abstract-relop relop loc opand env)
    (define v1 (abstract-opand loc env))
    (define v2 (abstract-opand opand env))
    (match* (v1 v2)
      [((? concrete?) (? concrete?))
       (if ((patch-relop relop) v1 v2)
           '(true)
           '(false))]
      [(_ _) `(,relop ,loc ,opand)]))

  ;; ((nested-asm-lang-v5 effect) ((and/c hash? (not/c immutable?)))) -> ('unknown | triv)
  (define (update-env effect env)
    (match effect
      [`(set! ,loc ,triv)
       (if (int64? triv)
           (hash-set! env loc triv)
           (hash-set! env loc (hash-ref env triv 'unknown)))]
      [`(set! ,loc1 (,op ,loc1 ,opand))
       (define cur-val (hash-ref env loc1 'unknown))
       (hash-set! env
                  loc1
                  (if (int64? cur-val)
                      (abstract-binop op cur-val opand env)
                      'unknown))]))

  (define (optimize-pred pred env)
    (match pred
      [`(if (not ,pred) ,pred2 ,pred3) (optimize-pred `(if ,pred ,pred3 ,pred2) env)]
      [`(if ,conditional ,then ,otherwise)
       (define optimized-cond (optimize-pred conditional env))
       (define env-then (hash-copy env))
       (define env-else (hash-copy env))
       (cond
         [(equal? optimized-cond '(true)) (optimize-pred then env-then)]
         [(equal? optimized-cond '(false)) (optimize-pred otherwise env-else)]
         [else
          `(if ,optimized-cond
               ,(optimize-pred then env-then)
               ,(optimize-pred otherwise env-else))])]
      [`(begin
          ,effects ...
          ,pred)
       `(begin
          ,@(for/list ([e effects])
              (optimize-effect e env))
          ,(optimize-pred pred env))]
      [`(,relop ,loc ,opand)
       #:when (relop? relop)
       (abstract-relop relop loc opand env)]
      [_ pred]))

  (define (optimize-effect effect env)
    (match effect
      [`(set! ,loc ,rest)
       (begin
         (update-env effect env)
         effect)]
      [`(begin
          ,effects ...)
       `(begin
          ,@(for/list ([effect effects])
              (optimize-effect effect env)))]
      [`(if (not ,conditional) ,then ,otherwise)
       (optimize-effect `(if ,conditional ,otherwise ,then) env)]
      [`(if ,conditional ,then ,otherwise)
       (define optimized-cond (optimize-pred conditional env))
       (define env-then (hash-copy env))
       (define env-else (hash-copy env))
       (cond
         [(equal? optimized-cond '(true)) (optimize-effect then env-then)]
         [(equal? optimized-cond '(false)) (optimize-effect otherwise env-else)]
         [else
          `(if ,optimized-cond
               ,(optimize-effect then env-then)
               ,(optimize-effect otherwise env-else))])]))

  (define (optimize-tail tail env)
    (match tail
      [`(begin
          ,effects ...
          ,tail)
       `(begin
          ,@(for/list ([effect effects])
              (optimize-effect effect env))
          ,(optimize-tail tail env))]
      [`(if (not ,pred) ,t1 ,t2) (optimize-tail `(if ,pred ,t2 ,t1) env)]
      [`(if ,pred ,t1 ,t2)
       (define optimized-cond (optimize-pred pred env))
       (define env-then (hash-copy env))
       (define env-else (hash-copy env))
       (cond
         [(equal? optimized-cond '(true)) (optimize-tail t1 env-then)]
         [(equal? optimized-cond '(false)) (optimize-tail t2 env-else)]
         [else
          `(if ,optimized-cond
               ,(optimize-tail t1 env-then)
               ,(optimize-tail t2 env-else))])]
      [_ tail]))

  ;; (nested-asm-lang-v5) -> (nested-asm-lang-v5)
  ;; Optimizes an individual nested-asm-lang-v5 procedure definition
  (define (optimize-def def)
    (match def
      [`(define ,label ,tail) `(define ,label ,(optimize-tail tail (make-hash)))]))

  ;; (nested-asm-lang-v5 p) -> (nested-asm-lang-v5 p)
  (define (optimize-p p)
    (match p
      [`(module ,defs ...
          ,tail)
       `(module ,@(map optimize-def defs) ,(optimize-tail tail (make-hash))
          )]))

  (optimize-p p))

(define nested-asm-lang-progs
  '((module (true)) (module (false))
                    (module (not (true)))
                    (module (not (false)))
                    (module (if (true)))))
