#lang racket

(require cpsc411/compiler-lib
         "common.rkt")

(provide expand-macros)
;; let src represent racketish-surface
;; let trg represent exprs-lang-v9

;; make an if expr using the given parameter
;; (src-value src-value src-value) -> src-value
(define (make-if pred truecase falsecase)
  `(if ,pred ,truecase ,falsecase))

;; make an if expr representing 'AND' logic using the given predicates
;;     skips over #t to save on number of if generated
;;     shortcircuits and produce #f immediately on encoutering a #f in the chain
;; (src-value ...) -> src-value
(define (make-and . pred)
  (cond
    [(empty? pred) #t]
    [(empty? (rest pred)) (first pred)]
    [(eq? #t (first pred)) (apply make-and (rest pred))]
    [(false? (first pred)) #f]
    ; although we can use open-recursion to expand on this, it saves some recursion to expand it out here
    [else (make-if (first pred) (apply make-and (rest pred)) #f)]))

;; make an if expr representing 'OR' logic using the given predicates
;;     skips over #f to save on number of if generated
;;     shortcircuits and produce #t immediately on encoutering a #t in the chain
;; (src-value ...) -> src-value
(define (make-or . pred)
  (cond
    [(empty? pred) #f]
    [(empty? (rest pred)) (first pred)]
    [(eq? #t (first pred)) #t]
    [(false? (first pred)) (apply make-or (rest pred))]
    ; although we can use open-recursion to expand on this, it saves some recursion to expand it out here
    [else
     (define sym (fresh 'pred/or))
     `(let ([,sym ,(first pred)]) ,(make-if sym sym (apply make-or (rest pred))))]))

;; (src-value ...) -> src-value
(define (make-begin/macro . es)
  (cond
    [(empty? es) '(void)]
    [(empty? (rest es)) (first es)]
    ; although we can use open-recursion to expand on this, it saves some recursion to expand it out here
    [else
     (define sym (fresh 'begin-tmp))
     `(let ([,sym ,(first es)]) ,(make-if `(error? ,sym) sym (apply make-begin/macro (rest es))))]))

;; zero is allowed for make-vector in racket
;; (src-value ...) -> src-value
(define (make-vector/macro . item*)
  (let ([size (length item*)])
    `(let ([vec (make-vector ,size)])
       ,(apply make-begin/macro
               (append (map (λ (i item) `(vector-set! vec ,i ,item)) (range size) item*) '(vec))))))

;; src-sexpr -> src-quote
(define (make-quote/macro sexpr)
  (match sexpr
    [`'(,sexpr ,sexpr* ...) `(cons ,(make-quote/macro `',sexpr) ,(make-quote/macro `',sexpr*))]
    [`'() 'empty]
    [`',v v]))

(define MACRO-ID-MAP
  `([and . ,make-and] [or . ,make-or]
                      (begin
                        . ,make-begin/macro)
                      [vector . ,make-vector/macro]))

(define (macro-id? mid)
  ((compose not false?) (memq mid (map car MACRO-ID-MAP))))
;; src-macro-id -> ((src-value ...) -> src-value)
(define (macro-id->fun mid)
  (dict-ref MACRO-ID-MAP mid (thunk (error (format "Invalid macro-id ~v" mid)))))

;; (Racketish-Surface p) -> (Exprs-lang-v9 p)
;; Expands all racketish-surface macros
(define (expand-macros p)
  ; triv	 	::=	 	x
  ;     |	 	fixnum
  ;     |	 	prim-f-
  ;     |	 	#t
  ;     |	 	#f
  ;     |	 	empty
  ;     |	 	(void)
  ;     |	 	(error uint8)
  ;     |	 	ascii-char-literal
  ;     |	 	(lambda (x ...) value)
  ;     |	 	vec-literal-
  ; value	 	::=	 	triv
  ;  	|	 	(quote s-expr)-
  ;  	|	 	(value value ...)-
  ;  	|	 	(macro-id value ...)-
  ;  	|	 	(let ([x value] ...) value)
  ;  	|	 	(if value value value)
  ;  	|	 	(call value value ...)
  ;; src-value -> trg-value
  ;; this inlines both the src-triv and src-val
  (define (expand-value val)
    (let loop ([val val])
      (match val
        [`(call ,val* ...) `(call ,@(map loop val*))]
        [`(if ,val0 ,val1 ,val2) (make-if (loop val0) (loop val1) (loop val2))]
        [`(let ([,x* ,val*] ...) ,val0)
         (let* ([val*/updated (map loop val*)]
                [letpair*/updated (map list x* val*/updated)])
           `(let ,letpair*/updated ,(loop val0)))]
        [`(,(? macro-id? mid) ,val* ...) (loop (apply (macro-id->fun mid) val*))]
        [(vector item* ...) (loop `(vector ,@item*))]
        [(? (or/c name? prim-f? fixnum? #t #f 'empty ascii-char-literal?)) val]
        [`(lambda ,param* ,val) `(lambda ,param* ,(expand-value val))]
        ['(void) val]
        [`(error ,(? uint8?)) val]
        [`',_ (loop (make-quote/macro val))]
        [`(,value ,value* ...) `(call ,(loop value) ,@(map loop value*))])))
  ; p	 	::=	 	(module (define x (lambda (x ...) value)) ... value)
  (define (expand-def def)
    (match def
      [`(define ,x (lambda ,param* ,val)) `(define ,x (lambda ,param* ,(expand-value val)))]))
  (match p
    [`(module ,def* ...
        ,val)
     `(module ,@(map expand-def def*) ,(expand-value val)
        )]))

(module+ test
  (require rackunit)
  (define-syntax-rule (check-and a b)
    (check-equal? (apply make-and a) b))

  (check-and '() #t)
  (check-and '(a) 'a)
  (check-and '(#t) #t)
  (check-and '(#f) #f)
  (check-and '(#f a b c) #f)
  (check-and '(a b) (make-if 'a 'b #f))
  (check-and '(a b c) (make-if 'a (make-if 'b 'c #f) #f))

  (define-syntax check-or
    (syntax-rules ()
      [(_ a b) (check-match (apply make-or a) b)]
      [(_ a b pred) (check-match (apply make-or a) b pred)]))

  (check-or '() #f)
  (check-or '(a) 'a)
  (check-or '(#t) #t)
  (check-or '(#f) #f)
  (check-or '(#t a b c) #t)
  (check-or '(a b) `(let ([,sym a]) (if ,sym ,sym b)) (symbol? sym))
  (check-or '(a b c)
            `(let ([,sym1 a])
               (if ,sym1
                   ,sym1
                   (let ([,sym2 b]) (if ,sym2 ,sym2 c))))
            (andmap symbol? (list sym1 sym2)))
  (define-syntax check-begin/macro
    (syntax-rules ()
      [[_ a b] (check-match (apply make-begin/macro a) b)]
      [[_ a b pred] (check-match (apply make-begin/macro a) b pred)]))

  (check-begin/macro '() '(void))
  (check-begin/macro '(a) 'a)
  (check-begin/macro '(a b) `(let ([,sym a]) (if (error? ,sym) ,sym b)) (symbol? sym))

  (define-syntax check-vector/macro
    (syntax-rules ()
      [[_ a b] (check-match (apply make-vector/macro a) b)]
      [[_ a b pred] (check-match (apply make-vector/macro a) b pred)]))

  (check-vector/macro '() `(let ([vec (make-vector 0)]) vec))
  (check-vector/macro '(a)
                      `(let ([,vec (make-vector 1)])
                         (let ([,v (vector-set! ,vec 0 a)]) (if (error? ,v) ,v ,vec)))
                      (andmap symbol? (list v vec)))
  (define-syntax-rule (check-quote/macro a b)
    (check-equal? (make-quote/macro a) b))
  (check-quote/macro ''() 'empty)
  (check-quote/macro ''#f #f)
  (check-quote/macro ''(1 2 3) '(cons 1 (cons 2 (cons 3 empty))))
  (check-quote/macro ''((1 2 3)) '(cons (cons 1 (cons 2 (cons 3 empty))) empty)))
