#lang racket

(require cpsc411/compiler-lib
         "common.rkt")

(provide uniquify)

;; (Exprs-lang-v9 p)-> (Exprs-unique-lang-v9 p)
;; Compiles Exprs-lang-v9 to Exprs-unique-lang-v9 by
;; resolving lexical identifiers into unique abstract locations.
(define (uniquify p)
  ;; env is an immutable association list that maps x to aloc or prim-f
  (define DEFAULT-ENV (map cons prim-f prim-f))
  ;; triv env -> unique-triv
  ; triv	 	::= +aloc
  ; |	 	+prim-f
  ; |	 	-x
  ; |	 	fixnum
  ; |	 	#t
  ; |	 	#f
  ; |	 	empty
  ; |	 	(void)
  ; |	 	(error uint8)
  ; |	 	ascii-char-literal
  (define (uniquify-triv triv env)
    (match triv
      [(? (or/c int61? #t #f 'empty ascii-char-literal?)) triv]
      ['(void) triv]
      [`(error ,(? uint8?)) triv]
      [`(lambda (,x* ...) ,value)
       (define aloc* (map fresh x*))
       (define env/updated
         (for/foldr ([env/updated env]) ([x x*] [aloc aloc*]) (dict-set! env/updated x aloc)))
       `(lambda ,aloc* ,(uniquify-value value env/updated))]
      [(? (or/c name? prim-f?)) (dict-ref env triv)]))
  ;; value env -> unique-value
  ; value	 	::=	 	triv
  ;  	|	 	(let ([+aloc -x value] ...) value)
  ;  	|	 	(if value value value)
  ;  	|	 	(call value value ...)
  (define (uniquify-value value env)
    (match value
      [`(call ,val1 ,val* ...)
       `(call ,(uniquify-value val1 env) ,@(map (curryr uniquify-value env) val*))]
      [`(if ,val0 ,val1 ,val2)
       `(if ,(uniquify-value val0 env)
            ,(uniquify-value val1 env)
            ,(uniquify-value val2 env))]
      [`(let ([,x* ,val*] ...) ,val)
       (let-values ([(env/updated aloc* unique-val*) (for/fold ([env/updated env]
                                                                [aloc* '()]
                                                                [unique-val* '()])
                                                               ([x (reverse x*)]
                                                                [val (reverse val*)])
                                                       (define aloc (fresh x))
                                                       (values (dict-set env/updated x aloc)
                                                               (cons aloc aloc*)
                                                               ;use original env, this is not let*
                                                               (cons (uniquify-value val env)
                                                                     unique-val*)))])
         `(let ,(map list aloc* unique-val*) ,(uniquify-value val env/updated)))]
      [_ (uniquify-triv value env)]))
  ;  p	 	::=	 	(module (define x (lambda (x ...) value)) ... value)
  ;; (define x (lambda (x ...) value)) env -> env
  ;; returns an updated env with the definition's x as a new aloc
  ;; this step is necessary for mutual recursion
  (define (mark-def def env)
    (match def
      [`(define ,x (lambda (,_ ...) ,_)) (dict-set env x (fresh x))]))

  ;; (define x (lambda (x ...) value)) env -> (define label (lambda (aloc ...) unique-value))
  (define (uniquify-def def env)
    (match def
      [`(define ,x (lambda (,param* ...) ,value))
       (define param/aloc* (map fresh param*))
       `(define ,(dict-ref env x)
          (lambda ,param/aloc* ,(uniquify-value value (append (map cons param* param/aloc*) env))))]))
  (match p
    [`(module ,def* ...
        ,value)
     (define env (foldr mark-def DEFAULT-ENV def*))
     `(module ,@(map (curryr uniquify-def env) def*) ,(uniquify-value value env)
        )]))

(module+ test
  (require rackunit
           cpsc411/langs/v8)
  (define-syntax-rule (check-by-interp p)
    (check-equal? (interp-exprs-lang-v8 p) (interp-exprs-unique-lang-v8 (uniquify p))))

  (check-by-interp `(module (define fact
                              (lambda (n)
                                (if (call <= n 1)
                                    1
                                    (call * n (call fact (call - n 1))))))
                            (call fact 5)
                      ))

  (check-by-interp `(module (define fact
                              (lambda (n acc)
                                (if (call <= n 1)
                                    acc
                                    (call fact (call - n 1) (call * acc n)))))
                            (call fact 5 1)
                      ))

  (check-by-interp `(module (define fib
                              (lambda (n)
                                (if (call <= n 1)
                                    n
                                    (call + (call fib (call - n 1)) (call fib (call - n 2))))))
                            (call fib 5)
                      ))
  (check-by-interp
   '(module (define fact
              (lambda (p)
                (if (call <= (call car p) 1)
                    (call cdr p)
                    (call fact
                          (call cons (call - (call car p) 1) (call * (call cdr p) (call car p)))))))
            (call fact (call cons 5 1))
      ))
  ; "implicit" factorial with accumulator... what have I done
  (check-by-interp `(module (define fact
                              (lambda (v)
                                (let ([n (call vector-ref v 0)]
                                      [acc (call vector-ref v 1)])
                                  (if (call <= n 1)
                                      acc
                                      (let ([_0 (call vector-set! v 1 (call * acc n))]
                                            [_1 (call vector-set! v 0 (call - n 1))])
                                        (call fact v))))))
                            (let ([v (call make-vector 2)])
                              (let ([_0 (call vector-set! v 0 5)]
                                    [_1 (call vector-set! v 1 1)])
                                (call fact v)))
                      ))
  (check-by-interp '(module (define foo (lambda () (let ([+ bar]) (call + 1 2))))
                            (define bar (lambda (a b) (call * a b)))
                      (call foo)))
  (check-match (uniquify '(module (define + (lambda (a) (call + a 1))) (call + 1)
                            ))
               `(module (define ,+ (lambda (,a) (call ,+ ,a 1))) (call ,+ 1)
                  )
               (and (label? +) (aloc? a)))
  (check-match
   (uniquify
    '(module (define fact
               (lambda (p)
                 (if (call <= (call car p) 1)
                     (call cdr p)
                     (call fact
                           (call cons (call - (call car p) 1) (call * (call cdr p) (call car p)))))))
             (call fact (call cons 5 1))
       ))
   `(module (define ,fact
              (lambda (,p)
                (if (call <= (call car ,p) 1)
                    (call cdr ,p)
                    (call
                     ,fact
                     (call cons (call - (call car ,p) 1) (call * (call cdr ,p) (call car ,p)))))))
            (call ,fact (call cons 5 1))
      )
   (and (aloc? p) (label? fact)))
  (check-match (uniquify '(module (define fact
                                    (lambda (v)
                                      (let ([n (call vector-ref v 0)]
                                            [acc (call vector-ref v 1)])
                                        (if (call <= n 1)
                                            acc
                                            (let ([_0 (call vector-set! v 1 (call * acc n))]
                                                  [_1 (call vector-set! v 0 (call - n 1))])
                                              (call fact v))))))
                                  (let ([v (call make-vector 2)])
                                    (let ([_0 (call vector-set! v 0 5)]
                                          [_1 (call vector-set! v 1 1)])
                                      (call fact v)))
                            ))
               `(module (define ,fact
                          (lambda (,v)
                            (let ([,n (call vector-ref ,v 0)]
                                  [,acc (call vector-ref ,v 1)])
                              (if (call <= ,n 1)
                                  ,acc
                                  (let ([,_0 (call vector-set! ,v 1 (call * ,acc ,n))]
                                        [,_1 (call vector-set! ,v 0 (call - ,n 1))])
                                    (call ,fact ,v))))))
                        (let ([,v0 (call make-vector 2)])
                          (let ([,_00 (call vector-set! ,v0 0 5)]
                                [,_10 (call vector-set! ,v0 1 1)])
                            (call ,fact ,v0)))
                  )
               (and (andmap aloc? (list v n acc _0 _1 v0 _00 _10)) (label? fact))))
