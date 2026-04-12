#lang racket
(require cpsc411/compiler-lib
         racket/random
         cpsc411/langs/v9)
(provide generate/p
         pass-map
         pass-lang-map
         allowed-passes
         interpretors/sym
         langs)
; p	 	::=	 	(module (define x (lambda (x ...) value)) ... value)
;   value	 	::=	 	triv
;  	 	|	 	(let ([x value] ...) value)
;  	 	|	 	(if value value value)
;  	 	|	 	(call value value ...)
;   triv	 	::=	 	x
;  	 	|	 	fixnum
;  	 	|	 	#t
;  	 	|	 	#f
;  	 	|	 	empty
;  	 	|	 	(void)
;  	 	|	 	(error uint8)
;  	 	|	 	ascii-char-literal
;   x	 	::=	 	name?
;  	 	|	 	prim-f
;   prim-f	 	::=	 	*
;  	 	|	 	+
;  	 	|	 	-
;  	 	|	 	<
;  	 	|	 	<=
;  	 	|	 	>
;  	 	|	 	>=
;  	 	|	 	eq?
;  	 	|	 	fixnum?
;  	 	|	 	boolean?
;  	 	|	 	empty?
;  	 	|	 	void?
;  	 	|	 	ascii-char?
;  	 	|	 	error?
;  	 	|	 	not
;  	 	|	 	pair?
;  	 	|	 	vector?
;  	 	|	 	cons
;  	 	|	 	car
;  	 	|	 	cdr
;  	 	|	 	make-vector
;  	 	|	 	vector-length
;  	 	|	 	vector-set!
;  	 	|	 	vector-ref
;   uint8	 	::=	 	uint8?
;   ascii-char-literal	 	::=	 	ascii-char-literal?
;   fixnum	 	::=	 	int61?

(define numop `(+ - *))
(define numop? (compose not false? (curryr memq numop)))
(define numcomp `(> >= < <=))
(define numcomp? (compose not false? (curryr memq numcomp)))
(define type-check '(fixnum? boolean? empty? void? ascii-char? error? pair?
                             vector?
                             procedure?))
(define type-check? (compose not false? (curryr memq type-check)))
(define type-check-map
  (list
   (cons 'fixnum? 'fixnum/value?)
   (cons 'boolean? 'boolean/value?)
   (cons 'empty? 'empty/value?)
   (cons 'void? 'void/value?)
   (cons 'ascii-char? 'ascii-char/value?)
   (cons 'error? 'error/value?)
   (cons 'pair? 'pair/value?)
   (cons 'vector? 'vector/value?)))

(define fixnum/triv? int61?)
(define (fixnum/value? x)
  (match x
    [(? fixnum/triv?) #t]
    [`(call ,(? numop?) ,(? fixnum?) ,(? fixnum?)) #t]
    [`(vector-length ,(? vector/value?)) #t]
    [_ #f]))
(define boolean/triv? boolean?)
(define (boolean/value? x)
  (match x
    [(? boolean/triv?) #t]
    [`(not ,_) #t]
    [`(call ,(? numcomp?) ,(? fixnum?) ,(? fixnum?)) #t]
    [`(call eq? ,_ ,_) #t]
    [`(call ,(? type-check?) ,_) #t]
    [_ #f]))
(define empty/triv? (curry eq? 'empty))
(define empty/value? empty/triv?)
(define void/triv? (curry equal? '(void)))
(define void/value? void/triv?)
(define ascii-char/triv? ascii-char-literal?)
(define ascii-char/value? ascii-char/triv?)
(define (error/triv? x) (match x
                          [`(error ,(? uint8?)) #t]
                          [_ #f]))
(define error/value? error/triv?)
(define (pair/triv? x)
  (match x
    [`(cons ,_ ,_) #t]
    [_ #f]))
(define prim-f (append numop
                       numcomp
                       type-check
                       '(eq?)
                       '(cons car cdr make-vector vector-length vector-set! vector-ref)))
(define pair/value? pair/triv?)
(define vector/triv? (curry eq? '(make-vector)))
(define vector/value? vector/triv?)
(define (any? x) #t)
;; env is (listof (cons expr-value (cons input-type output-type)))
(define DEFAULT-ENV
  `(,@(map (λ(key) (cons `(call ,key) (cons '(fixnum? fixnum?) 'fixnum?))) numop)
    ,@(map (λ(key) (cons `(call ,key) (cons '(fixnum? fixnum?) 'boolean?))) numcomp)
    ,@(map (λ(key) (cons `(call ,key) (cons '(any?) 'boolean?))) type-check)
    ((call eq?) ,(cons '(any? any?) 'boolean?))
    ((call car) ,(cons '(pair?) 'fixnum?))
    ((call cdr) ,(cons '(pair?) 'fixnum?))
    ((call vector-length) ,(cons '(vector?) 'fixnum?))
    ((call procedure-arity) ,(cons '(procedure?) 'fixnum?))
    ((call not) ,(cons '(any?) 'boolean))))

(define (select-var/returns env expected-type)
  (filter (λ(entry) (eq? (cddr entry) expected-type)) env))

(define (entry-fun/expr? entry)
  (pair? (car entry)))
;; int int -> expr-p
;; recur-depth represent the maximum amount of recursion happening
;; iter-depth represent the maximum amount of concurrently defined variables
;;    and labels per branch
(define (generate/p recur-depth iter-depth)
  (generate-value recur-depth
                  iter-depth
                  DEFAULT-ENV
                  (λ (def* val)
                    `(module ,@(set->list def*) ,val))
                  (random-ref type-check))
  )
(define (random/zero k)
  (if (<= k)
      k
      (random k)))
; hard set this so it is easier to deal with
(define VECTOR-DEF-SIZE 8)
(define (generate-triv env expected-type)
  (match expected-type
    ['fixnum? (random 0 255)]
    ['boolean? (random-ref '(#t #f))]
    ['empty? 'empty]
    ['void? '(void)]
    ['ascii-char? (integer->char (random 65 123))]
    ['error? `(error ,(random 0 255))]
    ['pair? `(call cons ,(random 0 255) ,(random 256 512))]
    ['vector? `(call make-vector ,VECTOR-DEF-SIZE)]
    ['procedure? `(lambda () (random 512 1024))]
    ['any? (generate-triv env (random-ref type-check))])
  )
;; int int env (def env value -> X) typecheck? ->  X
(define (generate-type/concrete recur-depth iter-depth env k expected-type)
  (define return (curry k (mutable-seteq) env))
  (match expected-type
    ['void? (let* [(env-vectors (select-var/returns env 'vector?))
                   (available-vectors (filter (not/c entry-fun/expr?) env-vectors))
                   (vector-set-type (random-ref type-check))]
              (if (empty? available-vectors)
                  (return (generate-triv env 'void?))
                  (generate-value (sub1 recur-depth)
                                  iter-depth
                                  env
                                  (λ (def* val)
                                    (define vec (car (random-ref available-vectors)))
                                    (define pos (sub1 (random/zero VECTOR-DEF-SIZE)))
                                    (define env/updated
                                      (dict-set env `(call vector-ref ,vec ,pos)
                                                (cons '() vector-set-type)))
                                    (k def* env/updated `(call vector-set! ,vec ,pos ,val)))
                                  vector-set-type)))]
    ['any? (generate-type/concrete recur-depth iter-depth env k (random-ref type-check))]
    [_ (return (generate-triv env expected-type))])
  )
;; int int env (def lambda (listof typedef?) -> X) typedef? -> X
(define (generate-lambda recur-depth iter-depth env k expected-type)
  (define n-param (random/zero iter-depth))
  (define param-name* (map (compose string->symbol
                                    (curry string-append "oprand")
                                    number->string)
                           (range n-param)))
  (define param-type* (map (λ (x) (random-ref type-check)) (range n-param)))
  (define env/updated (foldr (λ (name type env) (dict-set env name (cons '() type)))
                             env
                             param-name*
                             param-type*))
  (generate-value recur-depth (- iter-depth n-param) env/updated
                  (λ (def* val)
                    (k def* `(lambda ,param-name* ,val) param-type*))
                  expected-type)
  )
;; int int env (def* label (listof typedef?) env -> X) typedef? -> X
(define (generate-def recur-depth iter-depth env k expected-type)
  (define expected-type/str (symbol->string expected-type))
  (define funname (gensym (~a 'fun/ (substring expected-type/str 0
                                               (sub1 (string-length expected-type/str))))))
  (generate-lambda recur-depth iter-depth '()
                   (λ (def* lambda param-type*)
                     (define def `(define ,funname ,lambda))
                     (set-add! def* def)
                     (k def* funname param-type* env))
                   expected-type))

(define (generate-let recur-depth iter-depth env k expected-type)
  (define n-var (random/zero iter-depth))
  (define var-type* (map (λ (x) (random-ref type-check)) (range n-var)))
  (define var-name* (map (compose string->symbol
                                  (curryr string-replace "?" "")
                                  (λ(x) (~a (list-ref var-type* x) x)))
                         (range n-var)))
  (define recur-depth/new (sub1 recur-depth))
  (define iter-depth/new (- iter-depth n-var))
  (define def* (mutable-seteq))
  (define env/updated env)
  (define (gen-val/typed! name type)
    (match type
      ['pair? (let ([car-type (random-ref type-check)]
                    [cdr-type (random-ref type-check)])
                (generate-value (sub1 recur-depth/new)
                                iter-depth/new
                                env
                                (λ (def*2 car-val)
                                  (generate-value
                                   (sub1 recur-depth/new)
                                   iter-depth/new
                                   env
                                   (λ (def*3 cdr-val)
                                     (set-union! def* def*2 def*3)
                                     (set! env/updated
                                           (dict-set env/updated `(call car ,name) (cons '() car-type)))
                                     (set! env/updated
                                           (dict-set env/updated `(call cdr ,name) (cons '() cdr-type)))
                                     `(cons ,car-val ,cdr-val))
                                   cdr-type))
                                car-type))]
      ['vector? (generate-value recur-depth/new
                                iter-depth/new
                                env
                                (λ (def*2 val)
                                  (set-union! def* def*2)
                                  (set! env/updated (dict-set env/updated  `(call vector-length ,name) (cons '() 'fixnum?)))
                                  (for ([i (range VECTOR-DEF-SIZE)])
                                    (set! env/updated (dict-set env/updated  `(call vector-ref ,name ,i) (cons '() 'fixnum?))))
                                  val)
                                'vector?)]
      ['procedure?
       (let ([ret-type (random-ref type-check)])
         (generate-lambda recur-depth/new
                          iter-depth/new
                          env
                          (λ(def*2 val param-type*)
                            (set-union! def* def*2)
                            (set! env/updated
                                  (dict-set env/updated `(call ,name) (cons param-type* ret-type)))
                            val)
                          ret-type))]
      [_ (generate-value recur-depth/new iter-depth/new env
                         (λ (def*2 val)
                           (set-union! def* def*2)
                           val)
                         type)]))
  (define val* (map gen-val/typed!
                    var-name*
                    var-type*))
  (generate-value recur-depth/new
                  iter-depth/new
                  env/updated
                  (λ(def*2 val)
                    (set-union! def* def*2)
                    (k def* `(let ,(map list var-name* val*) ,val)))
                  expected-type))

;; int int env ((listof expr-define) Value -> X) typecheck? -> X
(define (generate-if recur-depth iter-depth env k expected-type)
  (define recur-depth/new (sub1 recur-depth))
  (define gen-val (curry generate-value recur-depth/new iter-depth env))
  (gen-val (λ (def* val)
             (gen-val (λ(def*2 val1)
                        (gen-val (λ (def*3 val2)
                                   (define def*/final (mutable-seteq))
                                   (set-union! def*/final def* def*2 def*3)
                                   (k def*/final `(if ,val
                                                      ,val1
                                                      ,val2)))
                                 expected-type))
                      expected-type))
           'boolean?))
;; int int env ((listof expr-define) Value -> X) typecheck? -> X
(define (generate-value recur-depth iter-depth env k expected-type)
  ; (pretty-display (list recur-depth iter-depth))
  (define options (list 'newfun 'let 'if 'oldvar))
  (when (<= iter-depth 0) (set! options (list 'oldvar)))
  (when (<= recur-depth 0) (set! options (list 'triv 'oldvar)))
  (define def* (mutable-seteq))
  ;; (listof type-check?) -> (listof expr-value)
  (define (generate-param* param-type* [env env])
    (map (λ(type) (generate-value (sub1 recur-depth) iter-depth env
                                  (λ (def*2 val)
                                    (set-union! def* def*2)
                                    val)
                                  type))
         param-type*))
  (define (gen-value option [recur-depth recur-depth])
    (match option
      ['triv (generate-type/concrete (sub1 recur-depth) iter-depth env
                                     (λ(def*2 env/updated val)
                                       (set-union! def* def*2)
                                       (k def*2 val)) expected-type)]
      ['newfun (generate-def (sub1 recur-depth) (sub1 iter-depth) env
                             (λ(def*2 label param-type* env)
                               (set-union! def* def*2)
                               (define env/updated (dict-set env `(call ,label)
                                                             (cons param-type*
                                                                   expected-type)))
                               (define param* (generate-param* param-type* env/updated))
                               (k def* `(call ,label ,@param*)))
                             expected-type)]
      ['let (generate-let (sub1 recur-depth) iter-depth env k expected-type)]
      ['if (generate-if (sub1 recur-depth) iter-depth env k expected-type)]
      ['oldvar
       ;; represent both function call and referencing old variable...
       ;;    excellent naming, i know.
       (define available-vars (select-var/returns env expected-type))
       (when (<= recur-depth 0) (set! available-vars (filter (not/c entry-fun/expr?) available-vars)))
       (if (empty? available-vars)
           (if (> recur-depth 0)
               (gen-value 'newfun (sub1 recur-depth))
               (gen-value 'triv))
           (let* [(chosen-var (random-ref available-vars))
                  (param-type* (cadr chosen-var))
                  (param* (generate-param* param-type*))]
             (if (entry-fun/expr? chosen-var)
                 (k def* `(,@(car chosen-var) ,@param*))
                 (k def* (car chosen-var)))))]
      ))
  (gen-value (random-ref options))
  )

(define pass-map
  (list
   #;(cons 'check-exprs-lang #f)
   (cons 'uniquify 'interp-exprs-lang-v9)
   (cons 'implement-safe-primops 'interp-exprs-unique-lang-v9)
   (cons 'implement-safe-call 'interp-exprs-unsafe-data-lang-v9)
   (cons 'define->letrec 'interp-exprs-unsafe-lang-v9)
   (cons 'optimize-direct-calls 'interp-just-exprs-lang-v9)
   (cons 'dox-lambdas 'interp-just-exprs-lang-v9)
   (cons 'uncover-free 'interp-lam-opticon-lang-v9)
   (cons 'convert-closures 'interp-lam-free-lang-v9)
   (cons 'optimize-known-calls 'interp-closure-lang-v9)
   (cons 'hoist-lambdas 'interp-closure-lang-v9)
   (cons 'implement-closures 'interp-hoisted-lang-v9)
   (cons 'specify-representation 'interp-proc-exposed-lang-v9)
   (cons 'remove-complex-opera* 'interp-exprs-bits-lang-v8)
   (cons 'sequentialize-let 'interp-values-bits-lang-v8)
   (cons 'normalize-bind 'interp-imp-mf-lang-v8)
   (cons 'impose-calling-conventions 'interp-proc-imp-cmf-lang-v8)
   (cons 'select-instructions 'interp-imp-cmf-lang-v8)
   (cons 'expose-allocation-pointer 'interp-asm-alloc-lang-v8)
   (cons 'uncover-locals 'interp-asm-pred-lang-v8)
   (cons 'undead-analysis 'interp-asm-pred-lang-v8/locals)
   (cons 'conflict-analysis 'interp-asm-pred-lang-v8/undead)
   (cons 'assign-call-undead-variables 'interp-asm-pred-lang-v8/conflicts)
   (cons 'allocate-frames 'interp-asm-pred-lang-v8/pre-framed)
   (cons 'assign-registers 'interp-asm-pred-lang-v8/framed)
   (cons 'assign-frame-variables 'interp-asm-pred-lang-v8/spilled)
   (cons 'replace-locations 'interp-asm-pred-lang-v8/assignments)
   (cons 'optimize-predicates 'interp-nested-asm-lang-fvars-v8)
   (cons 'implement-fvars 'interp-nested-asm-lang-fvars-v8)
   (cons 'expose-basic-blocks 'interp-nested-asm-lang-v8)
   (cons 'resolve-predicates 'interp-block-pred-lang-v8)
   (cons 'flatten-program 'interp-block-asm-lang-v8)
   (cons 'patch-instructions 'interp-para-asm-lang-v8)
   (cons 'implement-mops 'interp-paren-x64-mops-v8)
   (cons 'generate-x64 'interp-paren-x64-v8)
   (cons #f '(compose nasm-run/print-number wrap-x64-run-time wrap-x64-boilerplate))))
(define pass-lang-map
  (list
   #;(cons 'check-exprs-lang #f)
   (cons 'uniquify 'exprs-lang-v9)
   (cons 'implement-safe-primops 'exprs-unique-lang-v9)
   (cons 'implement-safe-call 'exprs-unsafe-data-lang-v9)
   (cons 'define->letrec 'exprs-unsafe-lang-v9)
   (cons 'optimize-direct-calls 'just-exprs-lang-v9)
   (cons 'dox-lambdas 'just-exprs-lang-v9)
   (cons 'uncover-free 'lam-opticon-lang-v9)
   (cons 'convert-closures 'lam-free-lang-v9)
   (cons 'optimize-known-calls 'closure-lang-v9)
   (cons 'hoist-lambdas 'closure-lang-v9)
   (cons 'implement-closures 'hoisted-lang-v9)
   (cons 'specify-representation 'proc-exposed-lang-v9)
   (cons 'remove-complex-opera* 'exprs-bits-lang-v8)
   (cons 'sequentialize-let 'values-bits-lang-v8)
   (cons 'normalize-bind 'imp-mf-lang-v8)
   (cons 'impose-calling-conventions 'proc-imp-cmf-lang-v8)
   (cons 'select-instructions 'imp-cmf-lang-v8)
   (cons 'expose-allocation-pointer 'asm-alloc-lang-v8)
   (cons 'uncover-locals 'asm-pred-lang-v8)
   (cons 'undead-analysis 'asm-pred-lang-v8/locals)
   (cons 'conflict-analysis 'asm-pred-lang-v8/undead)
   (cons 'assign-call-undead-variables 'asm-pred-lang-v8/conflicts)
   (cons 'allocate-frames 'asm-pred-lang-v8/pre-framed)
   (cons 'assign-registers 'asm-pred-lang-v8/framed)
   (cons 'assign-frame-variables 'asm-pred-lang-v8/spilled)
   (cons 'replace-locations 'asm-pred-lang-v8/assignments)
   (cons 'optimize-predicates 'nested-asm-lang-fvars-v8)
   (cons 'implement-fvars 'nested-asm-lang-fvars-v8)
   (cons 'expose-basic-blocks 'nested-asm-lang-v8)
   (cons 'resolve-predicates 'block-pred-lang-v8)
   (cons 'flatten-program 'block-asm-lang-v8)
   (cons 'patch-instructions 'para-asm-lang-v8)
   (cons 'implement-mops 'paren-x64-mops-v8)
   (cons 'generate-x64 'paren-x64-v8)
   (cons #f #f)))
(define allowed-passes (filter-map car pass-map))
(define interpretors/sym (map cdr pass-map))
(define langs (map cdr pass-lang-map))

(module+ test
  (define (interp/catch-error x)
    (call-with-exception-handler (λ (y) (displayln (cons y (pretty-format x)))
                                   (raise y))
                                 (thunk (interp-exprs-lang-v9 x))))


  (for-each interp/catch-error (map (λ(x) (generate/p 3 3)) (range 999)))
  )