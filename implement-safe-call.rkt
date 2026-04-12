#lang racket

(provide implement-safe-call)
(require cpsc411/compiler-lib
         "common.rkt")

; `(call ,e ,es ...)
; =>
; `(if (procedure? ,e)
;      (if (eq? (unsafe-procedure-arity ,e) ,(length es))
;          (unsafe-procedure-call ,e ,es ...)
;          ,bad-arity-error)
;      ,bad-proc-error)
(define BAD-ARITY-ERROR '(error 69))
(define BAD-PROC-ERROR '(error 67))
(define (make-if pred tcase fcase)
  `(if ,pred ,tcase ,fcase))

;; (Exprs-unsafe-data-lang-v9 p) -> (Exprs-unsafe-lang-v9 p)
;; Implement call as an unsafe procedure call with dynamic checks.
(define (implement-safe-call p)

  ;   triv	 	::=	 	aloc
  ;  	 	|	 	fixnum
  ;  	 	|	 	#t
  ;  	 	|	 	#f
  ;  	 	|	 	empty
  ;  	 	|	 	(void)
  ;  	 	|	 	(error uint8)
  ;  	 	|	 	ascii-char-literal
  ;  	 	|	 	(lambda (aloc ...) value)
  (define (implement-triv triv)
    (match triv
      [(? (or/c aloc? fixnum? #t #f 'empty ascii-char-literal?)) triv]
      ['(void) triv]
      [`(error ,(? uint8?)) triv]
      [`(lambda ,aloc* ,val) `(lambda ,aloc* ,(implement-value val))]))
  ;   effect	 	::=	 	(primop value ...)
  ;  	 	|	 	(begin effect ... effect)
  (define (implement-effect fx)
    (match fx
      [`(,(? primop? pop) ,val* ...) `(,pop ,@(map implement-value val*))]
      [`(begin
          ,fx* ...)
       (make-begin-effect (map implement-effect fx*))]))
  ;   value	 	::=	 	triv
  ;  	 	|	 	(primop value ...)
  ;  	 	|	 	(call value value ...)
  ;  	 	|	 	(let ([aloc value] ...) value)
  ;  	 	|	 	(if value value value)
  ;  	 	|	 	(begin effect ... value)
  (define (implement-value value)
    (match value
      [`(begin
          ,fx* ...
          ,value)
       (make-begin (map implement-effect fx*) (implement-value value))]
      [`(if ,val0 ,val1 ,val2)
       (make-if (implement-value val0) (implement-value val1) (implement-value val2))]
      [`(let ([,aloc* ,value*] ...) ,val)
       `(let ,(map list aloc* (map implement-value value*)) ,(implement-value val))]
      [`(call ,val ,value* ...)
       ;  use let binding to avoid incurring extra work
       (let ([val/updated (implement-value val)]
             [value*/updated (map implement-value value*)]
             [fun/aloc (fresh 'lambda)])
         `(let ([,fun/aloc ,val/updated])
            ,(make-if `(procedure? ,fun/aloc)
                      (make-if `(eq? (unsafe-procedure-arity ,fun/aloc) ,(length value*))
                               `(unsafe-procedure-call ,fun/aloc ,@value*/updated)
                               BAD-ARITY-ERROR)
                      BAD-PROC-ERROR)))]
      [`(,(? primop? pop) ,val* ...) `(,pop ,@(map implement-value val*))]
      [_ (implement-triv value)]))
  ;  p	 	::=	 	(module (define aloc (lambda (aloc ...) value)) ... value)
  (define (implement-def def)
    (match def
      [`(define ,aloc* ,value) `(define ,aloc* ,(implement-value value))]))
  (match p
    [`(module ,def* ...
        ,value)
     `(module ,@(map implement-def def*) ,(implement-value value)
        )]))
