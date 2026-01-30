#lang racket (require cpsc411/compiler-lib cpsc411/2c-run-time)
(provide
 check-values-lang
 uniquify
 sequentialize-let
 normalize-bind
 select-instructions
 uncover-locals
 assign-fvars
 replace-locations
 assign-homes
 flatten-begins
 patch-instructions
 implement-fvars
 check-paren-x64
 generate-x64
 interp-values-lang
 interp-paren-x64)


;; You might want to reuse check-paren-x64 and generate-x64 from milestone-1
(define (triv? t)
  (or (int64? t) (name? t)))

(define (binop? op)
  (and (member op '(+ *)) #t))

(define (value? val)
  (match val
    [(? triv?)
    #t]
    [`(,op ,t1 ,t2)
     (and (binop? op) (triv? t1) (triv? t2))]
    [`(let ([,xs ,vs] ...) ,body)
    (and (andmap (name? xs)) (andmap (value? vs)) (value? body))]
    [_ #f]))
 
(define (tail? tail)
    (match tail
        [(? value?) #t]
        [`(let ([,xs ,vs] ...) ,body)
        (and 
        (andmap (name? xs)) 
        (andmap (value? vs)) 
        (tail? body))]
        [_ #f]))

;; Validator for Values-lang-v3
(define (check-values-lang p)
    (match p
    [`(module ,tail)
    (if (tail? tail)
        p
        (error "wasn't values-lang-v3"))]
    [_ (error "wasn't values-lang-v3")])
  )

(define (uniquify-triv triv env)
    (match triv
        [(? int64?) triv]
        [(? name?)
            (dict-ref env triv  (lambda () (raise (make-exn:fail))))] ;; We found a name, it is supposed to be trivial, which means it should exist in our environment, so raise error if it isn't in our environment 
            ;; (it not being in our environment would mean we have an unbound name)
        [_ (error "Expected triv but got ~a" triv)]))

(define (uniquify-value value env)
    (match value
    [(? triv?)
        (uniquify-triv value env)]
    [`(,op ,triv1 ,triv2)
        `(,op ,(uniquify-triv triv1 env) ,(uniquify-triv triv2 env))]
    [`(let ([,xs ,vs] ...) ,body)
        (define alocs (map (lambda (_) (fresh)) xs))
        (define env*
            (let loop ([xs xs] [as alocs] [e env])
            (if (empty? xs)
                e
                (loop (cdr xs) (cdr as) (cons (cons (car xs) (car as)) e)))))
        (define vs* (map (lambda (v) (uniquify-value v env)) vs))
        `(let (,@(map list alocs vs*)) ,(uniquify-value body env*))]
    [_ (error 'uniquify-value "Expected a value, got: ~a" value)]))

(define (uniquify-tail tail env)
    (match tail
    [(? value?) ; could be int64, then just return that, could be binop triv triv, then we'd have to check if the trivs have name?'s in them, passing environment along
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
        `(let (,@(map list alocs vs*)) ,(uniquify-tail body env*))]
    [_ (error 'uniquify-tail "Expected a tail, got: ~a" tail)]
    ))
    
;; (values-lang-v3) -> (values-unique-lang-v3)
;; Resolves all lexical identifiers to abstract locations
(define (uniquify p)
    (check-values-lang p)
    (match p
    [`(module ,tail)
    `(module ,(uniquify-tail tail '()))]
    [_ (error 'uniquify "Expected  (module tail), got: ~a" p)]))

(define (sequentialize-value value)
    (match value
    [(? triv?)
            value]
    [`(,op ,triv1 ,triv2)
        (if (and (binop? op) (triv? triv1) (triv? triv2))
            `(,op ,triv1 ,triv2)
            (error "Expected a value, got: ~a" value))]
    [`(let ([,as ,vs] ...) ,body)
        `(begin ,@(map (lambda (a v) `(set! ,a ,(sequentialize-value v))) as vs)
                    ,(sequentialize-value body))]

    [_ (error "Expected a value, got: ~a" value)]
    ))


(define (sequentialize-tail tail)
    (match tail
    [(? triv?) (sequentialize-value tail)]
    [`(,op ,triv1 ,triv2)
        (sequentialize-value tail)]
    [`(let ([,as ,vs] ...) ,body)
        `(begin ,@(map (lambda (a v) `(set! ,a ,(sequentialize-value v))) as vs) 
                ,(sequentialize-tail body))]
    [_ (error "Expected a tail, got: ~a" tail)]))


;; (values-unique-lang-v3) -> (imp-mf-lang-v3)
;; Picks a particular ordering for let expressions using 'set!'
(define (sequentialize-let p)
    (match p
    [`(module ,tail)
        `(module ,(sequentialize-tail tail))])
    [_ (error "Expected values-unique-lang-v3, got: ~a" p)])  

;; (Imp-mf-lang-v3 effect) -> (Imp-cmf-lang-v3 effect)
(define (normalize-effect effect)
    (match effect
    [`(set! ,aloc (begin ,effects ... ,value))
        `(begin ,@(map normalize-effect effects)
                (set! ,aloc ,(normalize-value value)))]
    [`(set! ,aloc ,value)
        `(set! ,aloc ,(normalize-value value))]
    [`(begin ,effects ... ,effect2)
        `(begin ,@(map normalize-effect effects)
                    ,(normalize-effect effect2))]
    [_ (error "Expected an effect, got: ~a" effect)]
    
    ))

;; (Imp-mf-lang-v3 value) -> (Imp-cmf-lang-v3 value)
(define (normalize-value value)
    (match value
    [(? triv?)
        value]
    [`(,op ,triv1 ,triv2)
        (if (and (binop? op) (triv? triv1) (triv? triv2))
            value
            (error "Expected a value, got: ~a" value))]
    [`(begin ,effects ... ,body)
        `(begin ,@(map normalize-effect effects)
                    ,(normalize-value body))]
    [_ (error "Expected a value, got: ~a" value)]
        
        ))

;; (Imp-mf-lang-v3 tail) -> (Imp-cmf-lang-v3 tail)
(define (normalize-tail tail)
    (match tail
    [(? triv?)
        (normalize-value tail)]
    [`(,op ,triv1 ,triv2)
        (normalize-value tail)]
    [`(begin ,effects ... ,body)
        `(begin ,@(map normalize-effect effects)
                ,(normalize-tail body))]
    [_ (error "Expected a tail, got: ~a" tail)]))


;; (imp-mf-lang-v3 p) -> (imp-cmf-lang-v3 p)
;; Pushes 'set!' under 'begin' so that RHS of each 'set!' is a simple value producing operation
(define (normalize-bind p)
    (match p
    [`(module ,tail)
        `(module ,(normalize-tail tail))]
    [_ (error "Expected (module tail), got: ~a" p)]))


;; (imp-cmf-lang-v3) -> (asm-lang-v2)
;; Selects appropriate sequences of abstract assembly instructions to implement ops of src lang
(define (select-instructions p)

  ; (Imp-cmf-lang-v3 value) -> (List-of (Asm-lang-v2 effect)) and (Asm-lang-v2 aloc)
  ; Assigns the value v to a fresh temporary, returning two values: the list of
  ; statements the implement the assignment in Loc-lang, and the aloc that the
  ; value is stored in.
  (define (assign-tmp v)
    (TODO "Consider implementing assign-tmp."))

  (define (select-tail e)
    (TODO "Implement select-tail"))

  (define (select-value e)
    (TODO "Implement select-value"))

  (define (select-effect e)
    (TODO "Implement select-value"))

  (match p
    [`(module ,tail)
     `(module () ,(select-tail tail))]))

(define (interp-paren-x64 p)
  ; Environment (List-of (paren-x64-v2 Statements)) -> Integer
  (define (eval-instruction-sequence env sls)
    (if (empty? sls)
        (dict-ref env 'rax)
        (TODO "Implement the fold over a sequence of Paren-x64-v2 /s/.")))

  ; Environment Statement -> Environment
  (define (eval-statement env s)
    (TODO "Implement the transition function evaluating a Paren-x64-v2 /s/."))

  ; (Paren-x64-v2 binop) -> procedure?
  (define (eval-binop b)
    (TODO "Implement the interpreter for Paren-x64-v2 /binop/."))

  ; Environment (Paren-x64-v2 triv) -> Integer
  (define (eval-triv regfile t)
    (TODO "Implement the interpreter for Paren-x64-v2 /triv/."))

  (TODO "Implement the interpreter for Paren-x64-v2 /p/."))

(define (generate-x64 p)
  (define (program->x64 p)
    (match p
      [`(begin ,s ...)
       (TODO "generate-x64")]))

  (define (statement->x64 s)
    (TODO "generate-x64"))

  (define (loc->x64 loc)
    (TODO "generate-x64"))

  (define (binop->ins b)
    (TODO "generate-x64"))

  (program->x64 p))



;; (asm-lang-v2/assignments) -> (nested-asm-lang-v2)
;; Replaces each aloc with its assigned physical location from the assignment info field
(define (replace-locations p)
    p)

;; (asm-lang-v2/locals) -> (asm-lang-v2/assignments)
;; Assigns each aloc from the locals info field to a fresh frame variable
(define (assign-fvars p)
    p)

;; (asm-lang-v2) -> (asm-lang-v2/locals)
;; Analyzes which alocs are used in p and decorates program with set of variables in info field
(define (uncover-locals p)
    p)

;; (asm-lang-v2) -> (nested-asm-lang-v2)
;; Replaces each aloc its with assigned physical location from assignment info field
(define (assign-homes p)
    (replace-locations (assign-fvars (uncover-locals p))))

;; (nested-asm-lang-v2) -> (para-asm-lang-v2)
;; Flatten all nested begin expressions
(define (flatten-begins p)
    p)


;; (para-asm-lang-v2) -> (paren-x64-fvars-v2)
;; Patches instructions in p that have no x64 analogue
(define (patch-instructions p)
    p)

;; (paren-x64-fvars-v2) -> (paren-x64-v2)
;; Reifies fvars into displacement mode operands
(define (implement-fvars p)
    p)



(define (check-paren-x64 p)
    p)


(define (interp-values-lang p)
    0)

(current-pass-list
 (list
  check-values-lang
  uniquify
  sequentialize-let
  normalize-bind
  select-instructions
  assign-homes
  flatten-begins
  patch-instructions
  implement-fvars
  generate-x64
  wrap-x64-run-time
  wrap-x64-boilerplate))

(module+ test
  (require
   rackunit
   rackunit/text-ui
   cpsc411/test-suite/public/v3
   ;; NB: Workaround typo in shipped version of cpsc411-lib
   (except-in cpsc411/langs/v3 values-lang-v3)
   cpsc411/langs/v2)

  (run-tests
   (v3-public-test-sutie
    (current-pass-list)
    (list
     interp-values-lang-v3
     interp-values-lang-v3
     interp-values-unique-lang-v3
     interp-imp-mf-lang-v3
     interp-imp-cmf-lang-v3
     interp-asm-lang-v2
     interp-nested-asm-lang-v2
     interp-para-asm-lang-v2
     interp-paren-x64-fvars-v2
     interp-paren-x64-v2
     #f #f))))

(module+ test
;; First five tests taken from book
    (check-eq? (uniquify '(module (+ 2 2)))     
                        '(module (+ 2 2)))
    (check-eq? (uniquify '(module (* 2 2)))     
                        '(module (* 2 2)))
    (check-eq? (uniquify '(module (let ([x 5]) x))) 
                '(module (let ([x.1 5]) x.1)))
    (check-eq? (uniquify '(module (let ([x (+ 2 2)]) x))) 
                        '(module (let ([x.2 (+ 2 2)]) x.2)))
    (check-eq? (uniquify '(module (let ([x 2]) (let ([y 2]) (+ x y)))))
                    '(module (let ((x.3 2)) (let ((y.4 2)) (+ x.3 y.4)))))
    (check-eq? (uniquify '(module (let ([x 2]) (let ([x 2]) (+ x x))))) 
                    '(module (let ((x.5 2)) (let ((x.6 2)) (+ x.6 x.6)))))  
    (check-eq? (uniquify '(module (let '() 0))) '(module (let '() 0)))
    (check-eq? (uniquify '(module (let '() (+ 2 2)))) '(module (let '() (+ 2 2))))
    (check-eq? (uniquify '(module (let '() (let '() 42)))) 
                            '(module (let '() (let '() 42))))
    (check-eq? (uniquify '(module (let '() (let ([x 0]) (+ (max-int 64) x))))) 
                        '(module (let '() (let ([x.7 0]) (+ (max-int 64) x.7))))) 
    (check-eq? (uniquify '(module (let '() (let '() (let '() -1)))))
                        '(module (let '() (let '() (let '() -1)))))
    (check-eq? (uniquify '(module 0)) '(module 0))
    (check-eq? (uniquify '(module 9223372036854775807)) '(module 9223372036854775807))
    (check-eq? (uniquify '(module 9223372036854775806)) '(module 9223372036854775806))
    (check-eq? (uniquify '(module -9223372036854775808)) '(module -9223372036854775808))
    (check-eq? (uniquify '(module -9223372036854775807)) '(module -9223372036854775807))
    (check-exn exn:fail?
        (lambda () (uniquify '(module 9223372036854775808))))
    (check-exn exn:fail?
        (lambda () (uniquify '(module -9223372036854775809))))
    (check-exn exn:fail? 
        (lambda () (uniquify '(module x))))
    (check-exn exn:fail? 
        (lambda () (uniquify '(module (+ x y)))))
    (check-exn exn:fail? 
        (lambda () (uniquify '(module (* x y)))))
    (check-exn exn:fail? 
        (lambda () (uniquify '(module ))))
    (check-exn exn:fail? 
        (lambda () (uniquify '(module (add1 2 2)))))
    ;; Nested binop
    (check-exn exn:fail? 
        (lambda () (uniquify '(module (+ 1 (+ 1 1))))))
    ;; Binop with one triv OOB for int64
    (check-exn exn:fail? 
        (lambda () (uniquify '(module (* 2 9223372036854775808)))))
    ;; Binop with both triv OOB for int64
    (check-exn exn:fail? 
        (lambda () (uniquify '(module (* 9223372036854775808 9223372036854775808)))))
    (check-exn exn:fail? 
        (lambda () (uniquify '(module (* -9223372036854775809 -9223372036854775808)))))
    (check-exn exn:fail? 
        (lambda () (uniquify '(module (* -9223372036854775809 9223372036854775808)))))
    )
    
(module+ test
    (check-eq? (sequentialize-let '(module 0)) '(module 0))
    (check-eq? (sequentialize-let '(module 9223372036854775807)) '(module 9223372036854775807))
    (check-eq? (sequentialize-let '(module -9223372036854775808)) '(module -9223372036854775808))
    (check-eq? (sequentialize-let '(module (let '() 0))) '(module (begin 0)))
    (check-eq? (sequentialize-let '(module (let '() 9223372036854775807))) 
                                    '(module (begin 9223372036854775807)))
    (check-eq? (sequentialize-let '(module (let '() -9223372036854775808))) 
                                    '(module (begin -9223372036854775808)))
    (check-eq? (sequentialize-let '(module (let ([x.1 0]) 1)))
                '(module (begin (set! x.1 0) 1)))
    (check-eq? (sequentialize-let '(module (let ([x.2 1]) x.2)))
                '(module (begin (set! x.2 1) x.2)))    
    (check-eq? (sequentialize-let '(module (+ 0 1)))
                '(module (+ 0 1)))     
    (check-eq? (sequentialize-let '(module (* -1 2)))
                '(module (* -1 2)))  
    (check-eq? (sequentialize-let '(module x.2))
                '(module x.2))  
    (check-eq? (sequentialize-let '(module (let ([x.1 1] [x.2 -1] [x.3 4]) (* x.3 x.2))))
                '(module (begin (set! x.1 1) (set! x.2 -1) (set! x.3 4) (* x.3 x.2))))
    (check-eq? (sequentialize-let '(module (let ([x.1 (let ([x.2 5]) x.2)]) x.1)))
                '(module (begin (set! x.1 (begin (set! x.2 5) x.2)) x.1)))
    (check-eq? (sequentialize-let '(module (let ([x.1 
                                            (let ([x.2 
                                            (let ([x.3 3]) (* x.3 x.3))]) x.2)]) (* 2 x.1))))
                '(module (begin (set! x.1 
                            (begin (set! x.2 
                                (begin (set! x.3 3) (* x.3 x.3))) x.2)) (* 2 x.1))))
    (check-eq? (sequentialize-let '(module 
                                    (let ([x.1 (+ 1 2)]) 
                                    (let ([x.2 (+ x.1 3)]) 0))))
            '(module (begin (set! x.1 (+ 1 2)) (begin (set! x.2 (+ x.1 3)) 0))))
    (check-eq? (sequentialize-let '(module (let ([x.1 (+ 1 2)]) (let ([x.2 (+ x.1 3)]) (* 2 x.1)))))
            '(module (begin (set! x.1 (+ 1 2)) (begin (set! x.2 (+ x.1 3)) (* 2 x.1)))))
    (check-eq? (sequentialize-let '(module (let ([x.1 (+ 1 2)]) (let ([x.2 (+ x.1 3)]) (+ x.2 x.1)))))
            '(module (begin (set! x.1 (+ 1 2)) (begin (set! x.2 (+ x.1 3)) (+ x.2 x.1)))))
    (check-eq? (sequentialize-let '(module (let ([x.1 (+ 1 2)]) (let ([x.2 (+ x.1 3)]) (* x.2 x.1)))))
            '(module (begin (set! x.1 (+ 1 2)) (begin (set! x.2 (+ x.1 3)) (* x.2 x.1)))))
)

(module+ test
    (check-eq? (normalize-bind '(module 0)) '(module 0))
    (check-eq? (normalize-bind '(module 9223372036854775807)) '(module 9223372036854775807))
    (check-eq? (normalize-bind '(module -9223372036854775808)) '(module -9223372036854775808))
    (check-eq? (normalize-bind '(module (+ 1 2))) '(module (+ 1 2)))
    (check-eq? (normalize-bind '(module (* -2 1))) '(module (* -2 1)))
    (check-eq? (normalize-bind '(module (* 1 9223372036854775807))) 
                                '(module (* 1 9223372036854775807)))
    (check-eq? (normalize-bind '(module (+ 10 -9223372036854775808))) 
                                '(module (+ 10 -9223372036854775808)))
    (check-eq? (normalize-bind '(module (begin (set! x.1 1) x.1))) 
                                '(module (begin (set! x.1 1) x.1)))
    (check-eq? (normalize-bind '(module (begin (set! x.1 2) (set! x.1 5) (+ 42 x.1)))) 
                                '(module (begin (set! x.1 2) (set! x.1 5) (+ 42 x.1))))
    (check-eq? (normalize-bind '(module (begin (set! x.1 (+ 2 4)) (set! x.1 (* 3 3)) (+ 42 x.1)))) 
                                '(module (begin (set! x.1 (+ 2 4)) (set! x.1 (* 3 3)) (+ 42 x.1))))
    (check-eq? (normalize-bind '(module (begin (set! x.1 (+ 2 4)) (set! x.2 (* 3 3)) (+ x.2 x.1)))) 
                                '(module (begin (set! x.1 (+ 2 4)) (set! x.2 (* 3 3)) (+ x.2 x.1))))
    (check-eq? (normalize-bind '(module (begin (set! x.1 1) (set! x.2 0) (* x.2 x.1)))) 
                                '(module (begin (set! x.1 1) (set! x.2 0) (* x.2 x.1))))
    (check-eq? (normalize-bind '(module (begin (set! x.1 2) (set! x.1 5) (+ x.1 x.1)))) 
                                '(module (begin (set! x.1 2) (set! x.1 5) (+ x.1 x.1))))
    (check-eq? (normalize-bind '(module (begin (set! x.1 (begin () 5)) 0)))
                                '(module (begin (begin (set! x.1 5)) 0)))
    (check-eq? (normalize-bind '(module (begin (set! x.1 (begin () 5)) x.1)))
                                '(module (begin (begin (set! x.1 5)) x.1)))
    (check-eq? (normalize-bind '(module (begin (set! x.1 
                                            (begin (set! x.2 5) (set! x.1 3) 1)) 2))) 
                                '(module (begin (begin 
                                                    (set! x.2 5) (set! x.1 3) (set! x.1 1) 2))))
    (check-eq? (normalize-bind '(module (begin (set! x.1 
                                            (begin (set! x.2 5) 
                                                (set! x.1 3) 1)) (+ x.1 x.2))))
                                '(module (begin 
                                            (begin (set! x.2 5) (set! x.1 3) 
                                                    (set! x.1 1) (+ x.1 x.2)))))
    (check-eq? (normalize-bind '(module (begin (set! x.1 
                                            (begin (set! x.2 5) 
                                                (set! x.1 3) (+ x.2 x.1))) (+ x.1 x.2))))
                                '(module (begin 
                                            (begin (set! x.2 5) (set! x.1 3) 
                                                    (set! x.1 (+ x.2 x.1)) (+ x.1 x.2)))))
    (check-eq? (normalize-bind '(module (begin (set! x.1 
                                            (begin (set! x.2 5) 
                                                (set! x.1 3) (* x.2 x.1))) (+ x.1 x.2))))
                                '(module (begin 
                                            (begin (set! x.2 5) (set! x.1 3) 
                                                    (set! x.1 (* x.2 x.1)) (+ x.1 x.2)))))
    (check-eq? (normalize-bind '(module (begin (set! x.1 
                                            (begin (set! x.2 5) 
                                                (set! x.1 3) (* x.2 x.1))) (* 5 x.2))))
                                '(module (begin 
                                            (begin (set! x.2 5) (set! x.1 3) 
                                                    (set! x.1 (* x.2 x.1)) (* 5 x.2)))))
    (check-eq? (normalize-bind '(module (begin (set! x.1 
                                            (begin (set! x.2 5) 
                                                (set! x.1 3) (+ x.2 x.1))) (* 5 x.2))))
                                '(module (begin 
                                            (begin (set! x.2 5) (set! x.1 3) 
                                                    (set! x.1 (+ x.2 x.1)) (* 5 x.2)))))
    (check-eq? (normalize-bind '(module (begin (set! x.1 2) (set! x.2 3) 
                                        (begin (set! x.1 3) (set! x.2 1) 1))))
                            '(module (begin (set! x.1 2) (set! x.2 3) 
                                        (begin (set! x.1 3) (set! x.2 1) 1))))
    (check-eq? (normalize-bind '(module (begin (set! x.1 2) (set! x.2 3) 
                                        (begin (set! x.1 3) (set! x.2 1) (+ x.1 x.2)))))
                            '(module (begin (set! x.1 2) (set! x.2 3) 
                                        (begin (set! x.1 3) (set! x.2 1) (+ x.1 x.2)))))
    (check-eq? (normalize-bind '(module (begin (set! x.1 2) (set! x.2 3) 
                                        (begin (set! x.1 3) (set! x.2 (begin 4)) (+ x.1 x.2)))))
                                '(module (begin (set! x.1 2) (set! x.2 3) 
                                        (begin (set! x.1 3) (begin (set! x.2 4)) (+ x.1 x.2)))))

    (check-eq? (normalize-bind '(module (begin (set! x.1 2) (set! x.2 3) 
                                        (begin (set! x.1 3) (set! x.2 
                                        (begin (set! x.1 4) (set! x.1 0) (+ x.1 x.1)))) (+ x.1 x.2))))
                                '(module (begin (set! x.1 2) (set! x.2 3) 
                                        (begin (set! x.1 3) 
                                        (begin (set! x.1 4) (set! x.1 0) (set! x.2 (+ x.1 x.1))) 
                                                (+ x.1 x.2)))))                            
)

(module+ test
    (check-eq? (select-instructions '(module (+ 2 2))) 
            '(module () (begin (set! tmp.1 2) (set! tmp.1 (+ tmp.1 2)) (halt tmp.1))))

    (check-eq? (select-instructions '(module (begin (set! x.1 5) x.1)))
                '(module () (begin (set! x.1 5) (halt x.1))))

    (check-eq? (select-instructions '(module (begin (set! x.1 (+ 2 2)) x.1)))
        '(module () (begin (set! x.1 2) (set! x.1 (+ x.1 2)) (halt x.1))))

    (check-eq? (select-instructions '(module (begin (set! x.1 2) (set! x.2 2) (+ x.1 x.2)))) 
        '(module () (begin (set! x.1 2) (set! x.2 2) (set! tmp.2 x.1) 
                (set! tmp.2 (+ tmp.2 x.2)) (halt tmp.2))))
)

(module+ test
    (check-eq? (uncover-locals '(module () (begin (set! x.1 0) (halt x.1))))
                '(module ((locals (x.1))) (begin (set! x.1 0) (halt x.1))))
    (check-eq? (uncover-locals '(module () (begin (set! x.1 0) (set! y.1 x.1)
                                            (set! y.1 (+ y.1 x.1)) (halt y.1))))
                '(module ((locals (x.1 y.1))) (begin (set! x.1 0) (set! y.1 x.1) 
                                                (set! y.1 (+ y.1 x.1)) (halt y.1))))
)

(module+ test
    (check-eq?  (assign-fvars '(module ((locals (x.1))) (begin (set! x.1 0) (halt x.1))))
            '(module ((locals (x.1)) (assignment ((x.1 fv0)))) (begin (set! x.1 0) (halt x.1))))
    (check-eq? (assign-fvars '(module ((locals (x.1 y.1 w.1))) (begin (set! x.1 0) (set! y.1 x.1)
                    (set! w.1 1) (set! w.1 (+ w.1 y.1)) (halt w.1)))) 
        '(module ((locals (x.1 y.1 w.1)) (assignment ((x.1 fv0) (y.1 fv1) (w.1 fv2))))
           (begin (set! x.1 0) (set! y.1 x.1) (set! w.1 1) (set! w.1 (+ w.1 y.1)) (halt w.1))))
)

(module+ test
    (check-eq? (replace-locations '(module ((locals (x.1)) (assignment ((x.1 rax))))
                    (begin (set! x.1 0) (halt x.1))))
                    '(begin (set! rax 0) (halt rax)))
    (check-eq? (replace-locations '(module ((locals (x.1 y.1 w.1)) 
                    (assignment ((x.1 rax) (y.1 rbx) (w.1 r9)))) 
            (begin (set! x.1 0) (set! y.1 x.1) (set! w.1 1) (set! w.1 (+ w.1 y.1)) (halt w.1))))
            '(begin (set! rax 0) (set! rbx rax) (set! r9 1) (set! r9 (+ r9 rbx)) (halt r9)))
)

(module+ test
    (check-eq? (flatten-begins '(halt 0)) '(begin (halt 0)))

)

(module+ test
    (check-eq? (patch-instructions '(begin (set! rbx 42) (halt rbx)))
                '(begin (set! rbx 42) (set! rax rbx)))
    (check-eq? (patch-instructions '(begin (set! fv0 0) (set! fv1 42) (set! fv0 fv1) (halt fv0)))
                '(begin (set! fv0 0) (set! fv1 42) (set! r10 fv1) (set! fv0 r10) (set! rax fv0)))
    (check-eq? (patch-instructions '(begin (set! rbx 0) (set! rcx 0) (set! r9 42) (set! rbx rcx)
                        (set! rbx (+ rbx r9)) (halt rbx))) 
                        '(begin (set! rbx 0) (set! rcx 0) (set! r9 42) (set! rbx rcx)
                         (set! rbx (+ rbx r9)) (set! rax rbx)))
)

(module+ test
    (check-eq? (implement-fvars '(begin)) '(begin))
)
