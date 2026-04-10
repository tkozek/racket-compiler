#lang racket

(require cpsc411/compiler-lib
         cpsc411/langs/v5)

(provide uniquify
         interp-values-lang)

(define (binop? op)
  (or (equal? op '+) (equal? op '*)))

(define (binop->fun op)
  (match op
    ['+ x64-add]
    ['* x64-mul]))
(define triv? (or/c name? int64?))

; values-lang-v5
;   p	 	::=	 	(module (define x (lambda (x ...) tail)) ... tail)

;   pred	 	::=	 	(relop triv triv)
;  	 	|	 	(true)
;  	 	|	 	(false)
;  	 	|	 	(not pred)
;  	 	|	 	(let ([x value] ...) pred)
;  	 	|	 	(if pred pred pred)

;   tail	 	::=	 	value
;  	 	|	 	(let ([x value] ...) tail)
;  	 	|	 	(if pred tail tail)
;  	 	|	 	(call x triv ...)

;   value	 	::=	 	triv
;  	 	|	 	(binop triv triv)
;  	 	|	 	(let ([x value] ...) value)
;  	 	|	 	(if pred value value)

;   triv	 	::=	 	int64
;  	 	|	 	x

;   x	 	::=	 	name?

;   binop	 	::=	 	*
;  	 	|	 	+

;   relop	 	::=	 	<
;  	 	|	 	<=
;  	 	|	 	=
;  	 	|	 	>=
;  	 	|	 	>
;  	 	|	 	!=

;   int64	 	::=	 	int64?

(define (interp-values-lang vl3)
  (define (interp-triv triv env)
    (match triv
      [(? name?) (dict-ref env triv (λ () (error "not defined: ~a" triv)))]
      [(? int64?) triv]))
  (define (interp-tail tail env)
    (match tail
      [`(let ([,x* ,value*] ...) ,tail)
       (define val+ (map (λ (val) (interp-tail val env)) value*))
       (define env+ (foldl (λ (x val env) (dict-set env x val)) env x* val+))
       (interp-tail tail env+)]
      [`(,(? binop? binop) ,(? triv? triv) ,(? triv? triv2))
       ((binop->fun binop) (interp-triv triv env) (interp-triv triv2 env))]
      [(? triv?) (interp-triv tail env)]))
  (let _ ([p vl3]
          [env '()])
    (match p
      [`(module ,tail) (interp-tail tail env)])))

;---------------------
; values-unique-lang-v5
;  p	 	::=	 	(module (define label (lambda (aloc ...) tail)) ... tail)
;   pred	 	::=	 	(relop opand opand)
;  	 	|	 	(true)
;  	 	|	 	(false)
;  	 	|	 	(not pred)
;  	 	|	 	(let ([aloc value] ...) pred)
;  	 	|	 	(if pred pred pred)
;   tail	 	::=	 	value
;  	 	|	 	(let ([aloc value] ...) tail)
;  	 	|	 	(if pred tail tail)
;  	 	|	 	(call triv opand ...)
;   value	 	::=	 	triv
;  	 	|	 	(binop opand opand)
;  	 	|	 	(let ([aloc value] ...) value)
;  	 	|	 	(if pred value value)
;   opand	 	::=	 	int64
;  	 	|	 	aloc
;   triv	 	::=	 	opand
;  	 	|	 	label
;   binop	 	::=	 	* | +
;   relop	 	::=	 	< | <= | = >= | > | !=
;   aloc	 	::=	 	aloc?
;   label	 	::=	 	label?
;   int64	 	::=	 	int64?

; values-lang-v5 -> values-unique-lang-v5
(define (uniquify vlv5)
  (define proc-env (make-hash))

  ; let env be a dict which maps (procedure-name : label)
  ;; name -> label
  (define (proc-name->label proc-name)
    (dict-ref! proc-env proc-name (fresh-label proc-name)))

  ; let env be a dict which maps name to aloc
  ; name env -> aloc
  (define (name->aloc x arg-env)
    (hash-ref arg-env x (λ () (error (format "undefined: ~a" x)))))

  ;; Takes triv in argument position and assigns aloc if triv is a name, otherwise returns
  ;; triv if triv is int64.
  ;; (values-lang-v5 triv?) -> (values-lang-v5 triv | int64)
  (define (triv->arg arg arg-env)
    (if (int64? arg)
        arg
        (name->aloc arg arg-env)))

  ; values-lang-v5-triv env -> values-unique-lang-v5-triv
  (define (uniquify-triv triv env)
    (match triv
      [(? int64?) triv]
      [(? name?) (hash-ref env triv (λ () (error (format "undefined: ~a" triv))))]))

  ; (listof values-lang-v5-name) (listof value-lang-v5-value) env ->
  ;     (list (listof (list values-unique-lang-v5-name values-unique-lang-v5-value)) env)
  (define (uniquify-pairs xs vals arg-env)
    (when (not (equal? (set-count (list->set xs)) (length xs)))
      (error (format "duplicate declaration in the same let: ~a" xs)))
    (define alocs (map fresh xs))
    (define bindings (map (λ (aloc val) (list aloc (uniquify-value val arg-env))) alocs vals))
    (define new-env
      (for/fold ([env arg-env])
                ([x xs]
                 [aloc alocs])
        (hash-set env x aloc)))
    (values bindings new-env))

  (define (uniquify-pred pred env)
    (match pred
      [`(,relop ,triv1 ,triv2)
       #:when (memq relop '(< <= = >= > !=))
       `(,relop ,(uniquify-triv triv1 env) ,(uniquify-triv triv2 env))]
      [`(not ,pred) `(not ,(uniquify-pred pred env))]
      [`(let ([,xs ,vals] ...) ,pred)
       ;    #:when ((listof name?) xs) ;; isn't it guaranteed to be (listof name) ?
       (let-values ([(bindings new-env) (uniquify-pairs xs vals env)])
         `(let ,bindings ,(uniquify-pred pred new-env)))]
      [`(if ,pred1 ,pred2 ,pred3)
       `(if ,(uniquify-pred pred1 env)
            ,(uniquify-pred pred2 env)
            ,(uniquify-pred pred3 env))]
      [_ pred]))

  ; values-lang-v5-value env -> values-unique-lang-v5-value
  (define (uniquify-value value env)
    (match value
      [`(let ([,xs ,vals] ...) ,value)
       (let-values ([(bindings new-env) (uniquify-pairs xs vals env)])
         `(let ,bindings ,(uniquify-value value new-env)))]
      [`(if ,pred1 ,pred2 ,pred3)
       `(if ,(uniquify-pred pred1 env)
            ,(uniquify-value pred2 env)
            ,(uniquify-value pred3 env))]
      ;; reordered to disambiguate with (if) instead

      [`(,binop ,triv1 ,triv2)
       #:when (and (binop? binop) (triv? triv1) (triv? triv2))
       `(,binop ,(uniquify-triv triv1 env) ,(uniquify-triv triv2 env))]
      [(? triv?) (uniquify-triv value env)])) ;;

  (define (uniquify-tail tail arg-env)
    (match tail
      [`(let ([,xs ,vals] ...) ,tail)
       ;#:when ((listof name?) xs) ;; is this necessary?
       (let-values ([(bindings new-env) (uniquify-pairs xs vals arg-env)])
         `(let ,bindings ,(uniquify-tail tail new-env)))]
      [`(if ,pred ,t1 ,t2)
       `(if ,(uniquify-pred pred arg-env)
            ,(uniquify-tail t1 arg-env)
            ,(uniquify-tail t2 arg-env))]
      ;; call to function x, with trivs as args
      [`(call ,x ,trivs ...)
       `(call ,(proc-name->label x) ,@(map (λ (arg) (triv->arg arg arg-env)) trivs))]
      [_ (uniquify-value tail arg-env)]))

  (define (uniquify-definitions def)
    (match def
      [`(define ,proc-name (lambda (,args ...) ,tail))
       (define alocs (map fresh args))
       (define arg-env
         (for/fold ([env (hash)])
                   ([arg args]
                    [aloc alocs])
           (hash-set env arg aloc)))
       `(define ,(proc-name->label proc-name)
          (lambda ,alocs ,(uniquify-tail tail arg-env)))]))

  ; (values-lang-v5-p env) -> (values-unique-lang-v5 p)
  (define (uniquify-p p)
    (match p
      [`(module ,defs ...
          ,tail)
       `(module ,@(map (λ (def) (uniquify-definitions def)) defs) ,(uniquify-tail tail (hash))
          )]))

  (uniquify-p vlv5))
