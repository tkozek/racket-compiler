#lang racket
(require cpsc411/compiler-lib
         "common.rkt")

(provide optimize-direct-calls)

;; (Just-exprs-lang-v9 p)-> (Just-exprs-lang-v9 p)
;; Inline all direct calls to first-class procedures.
(define (optimize-direct-calls p)
  ;   triv	 	::=	 	aloc
  ;  	 	|	 	fixnum
  ;  	 	|	 	#t
  ;  	 	|	 	#f
  ;  	 	|	 	empty
  ;  	 	|	 	(void)
  ;  	 	|	 	(error uint8)
  ;  	 	|	 	ascii-char-literal
  ;  	 	|	 	(lambda (aloc ...) value)
  ; src-triv (trg-triv -> X) -> X
  (define (optimize-triv triv [k identity])
    (match triv
      [`(lambda ,aloc* ,val) (k `(lambda ,aloc* ,(optimize-value val)))]
      [_ (k triv)]))
  ;   effect	 	::=	 	(primop value ...)
  ;  	 	|	 	(begin effect ... effect)
  (define (optimize-effect fx)
    (match fx
      [`(begin
          ,fx* ...)
       (make-begin (map optimize-effect fx*))]
      [`(,primop ,val* ...) `(,primop ,@(map optimize-value val*))]))
  (define (optimize-entry e)
    (match e
      [`(,name (lambda ,param* ,value)) `(,name (lambda ,param* ,(optimize-value value)))]))
  ;   value	 	::=	 	triv
  ;  	 	|	 	(primop value ...)
  ;  	 	|	 	(unsafe-procedure-call value value ...)
  ;  	 	|	 	(letrec ([aloc (lambda (aloc ...) value)] ...) value)
  ;  	 	|	 	(let ([aloc value] ...) value)
  ;  	 	|	 	(if value value value)
  ;  	 	|	 	(begin effect ... value)
  ; src-value (trg-value -> trg-value) -> trg->value
  (define (optimize-value value [k identity])
    (let loop ([value value]
               [k k])
      (match value
        [`(begin
            ,fx* ...
            ,val)
         ; effects would causes value to change regardless of whether we inline
         (make-begin (map optimize-effect fx*) (loop val k))]
        [`(if ,val0 ,val1 ,val2)
         `(if ,(loop val0 identity)
              ,(loop val1 k)
              ,(loop val2 k))]
        [`(let ([,aloc* ,val*] ...) ,val)
         ; uniquified value, just pass k along
         (let* ([val*/updated (map optimize-value val*)]
                [val/updated (loop val k)]
                [entry*/updated (map list aloc* val*/updated)])
           `(let ,entry*/updated ,val/updated))]
        [`(letrec (,entry* ...)
            ,value)
         ; uniquified value, just pass k along
         `(letrec ,(map optimize-entry entry*)
            ,(loop value k))]
        [`(unsafe-procedure-call ,val0 ,opand* ...)
         (define opand*/updated (map optimize-value opand*))
         (loop val0
               (λ (triv)
                 (match triv
                   [`(lambda ,aloc* ,value) `(let ,(map list aloc* opand*/updated) ,(loop value k))]
                   [_ (k `(unsafe-procedure-call ,triv ,@opand*/updated))])))]
        [`(,primop ,val* ...) (k `(,primop ,@(map optimize-value val*)))]
        [_ (optimize-triv value k)])))

  (match p
    [`(module ,value) `(module ,(optimize-value value))]))

(module+ test
  (require rackunit
           cpsc411/langs/v9)
  (define (fail-if-invalid p)
    ; (pretty-write p)
    (when (not (just-exprs-lang-v9? p))
      (error
       (~a (pretty-format p) "\n is not a semantically valid " "just-exprs-lang-v9" " program")))
    p)
  (define-syntax-rule (check-by-interp p)
    (check-equal? (interp-just-exprs-lang-v9 p)
                  (interp-just-exprs-lang-v9 (fail-if-invalid (optimize-direct-calls p)))))
  (let ([x (fresh 'x)]
        [y (fresh 'y)]
        [z (fresh 'z)]
        [+/sym 'unsafe-fx+])
    (check-by-interp `(module (unsafe-procedure-call (lambda (,x) ,x) 1)))
    (check-by-interp `(module (let ([,x (unsafe-make-vector 1)])
                                (begin
                                  (unsafe-vector-set! ,x 0 1)
                                  (unsafe-procedure-call (lambda (,z) ,z)
                                                         (begin
                                                           (unsafe-vector-set! ,x 0 2)
                                                           67))))))
    (check-by-interp `(module (let ([,x (unsafe-make-vector 1)])
                                (begin
                                  (unsafe-vector-set! ,x 0 1)
                                  (unsafe-procedure-call (lambda (,z) (unsafe-vector-ref ,x 0))
                                                         (begin
                                                           (unsafe-vector-set! ,x 0 2)
                                                           67))))))
    (check-by-interp
     `(module (unsafe-procedure-call (lambda (,x) (unsafe-procedure-call (lambda (,y) ,y) ,x)) 1)))
    (check-by-interp `(module (unsafe-procedure-call (if (eq? 1 0)
                                                         (lambda (,x) ,x)
                                                         (letrec ([,y (lambda (,x) (,+/sym ,x 1))])
                                                           ,y))
                                                     1)))
    (check-by-interp `(module (unsafe-procedure-call
                               (lambda (,z)
                                 (unsafe-procedure-call (if (eq? 1 ,z)
                                                            (lambda (,x) ,x)
                                                            (letrec ([,y (lambda (,x) (,+/sym ,x 1))])
                                                              ,y))
                                                        ,z))
                               1)))))
