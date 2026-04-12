#lang racket

(require cpsc411/compiler-lib
         "common.rkt")

(provide implement-safe-primops)

(define ERROR-BAD-TYPE-CHECK '(error 2))
(define ERROR-VECTOR-SET-OOB '(error 10))
(define ERROR-NEGATIVE-FIXNUM '(error 12))
(define ERROR-VECTOR-REF-OOB '(error 11))

; represents dependcies of a label and its underlying function labels

(define fill0-lab (fresh 'fill0))
(define fill0-def
  (let ([vec (fresh 'vec)]
        [off (fresh 'off)]
        [len (fresh 'len)])
    ; only will be called by us so no need to type check
    `(define ,fill0-lab
       (lambda (,vec ,off ,len)
         (if (unsafe-fx< ,off ,len)
             (let ([,(fresh 'ignored) (unsafe-vector-set! ,vec ,off 0)])
               (call ,fill0-lab ,vec (unsafe-fx+ ,off 1) ,len))
             (void))))))
(define make-init-vector-label (fresh 'make-init-vector))
(define make-init-vector-def
  (let ([n (fresh 'n)]
        [vec (fresh 'vec)])
    `(define ,make-init-vector-label
       (lambda (,n)
         (if (unsafe-fx>= ,n 0)
             (let ([,vec (unsafe-make-vector ,n)])
               (let ([,(fresh 'ignored) (call ,fill0-lab ,vec 0 ,n)]) ,vec))
             ,ERROR-NEGATIVE-FIXNUM)))))

(define unsafe-vector-set!-label (fresh 'vector-set!u))
(define unsafe-vector-set!-def
  (let ([vec (fresh 'vec)]
        [off (fresh 'off)]
        [val (fresh 'val)])
    `(define ,unsafe-vector-set!-label
       (lambda (,vec ,off ,val)
         (if (if (unsafe-fx>= ,off 0)
                 (unsafe-fx< ,off (unsafe-vector-length ,vec))
                 #f)
             (unsafe-vector-set! ,vec ,off ,val)
             ,ERROR-VECTOR-SET-OOB)))))

(define unsafe-vector-ref-label (fresh 'vector-refu))
(define unsafe-vector-ref-def
  (let ([vec (fresh 'vec)]
        [off (fresh 'off)])
    `(define ,unsafe-vector-ref-label
       (lambda (,vec ,off)
         (if (if (unsafe-fx>= ,off 0)
                 (unsafe-fx< ,off (unsafe-vector-length ,vec))
                 #f)
             (unsafe-vector-ref ,vec ,off)
             ,ERROR-VECTOR-REF-OOB)))))

;; prim-f (or primop label 'passthrough) (listof (type or 'any?)) (listof unsafe-def)
;; interp. table of prim-f to primop/label (listof type-requirement) (listof definition-dependencies)
(define prim-f-specs
  `((* unsafe-fx* (fixnum? fixnum?) ())
    (+ unsafe-fx+ (fixnum? fixnum?) ())
    (- unsafe-fx- (fixnum? fixnum?) ())
    (< unsafe-fx< (fixnum? fixnum?) ())
    (<= unsafe-fx<= (fixnum? fixnum?) ())
    (> unsafe-fx> (fixnum? fixnum?) ())
    (>= unsafe-fx>= (fixnum? fixnum?) ())
    (make-vector ,make-init-vector-label (fixnum?) (,fill0-def ,make-init-vector-def))
    (vector-length unsafe-vector-length (vector?) ())
    (vector-set! ,unsafe-vector-set!-label (vector? fixnum? any?) (,unsafe-vector-set!-def))
    (vector-ref ,unsafe-vector-ref-label (vector? fixnum?) (,unsafe-vector-ref-def))
    (car unsafe-car (pair?) ())
    (cdr unsafe-cdr (pair?) ())
    (procedure-arity unsafe-procedure-arity (procedure?) ())
    ,@(map (lambda (x) `(,x 'passthrough '(any?) ()))
           '(fixnum? boolean? empty? void? ascii-char? error? pair? vector? procedure? not))
    ,@(map (lambda (x) `(,x 'passthrough '(any? any?) ())) '(cons eq?))))

;; make an if expr using the given parameter
(define (make-if pred truecase falsecase)
  `(if ,pred ,truecase ,falsecase))

;; make an if expr representing and logic using the given predicates
;;     skips over #t to save on number of if generated
;;     shortcircuits and produce #f immediately on encoutering and #f in the chain
(define (make-and . pred)
  (cond
    [(empty? pred) #t]
    [(empty? (rest pred)) (first pred)]
    [(eq? #t (first pred)) (apply make-and (rest pred))]
    [(false? (first pred)) #f]
    [else (make-if (first pred) (apply make-and (rest pred)) #f)]))

;; (list prim-f (or primop label 'passthrough)) -> (listof ((list primop '()) or (list (call aloc) (listof def))))
(define (gen-defs entry)
  (match entry
    [`(,prim-f 'passthrough ,_ ,_) (list prim-f '())]
    [`(,prim-f ,inner ,type* ,def*)
     (let* ([i* (range (length type*))]
            [lab (fresh prim-f)]
            [param* (map (λ (i type) (fresh (~a type i))) i* type*)]
            [pred* (map (λ (type? param)
                          (if (eq? type? 'any?)
                              #t
                              `(,type? ,param)))
                        type*
                        param*)])
       (list lab
             (cons `(define ,lab
                      (lambda ,param*
                        ,(make-if (apply make-and pred*)
                                  (if (aloc? inner)
                                      `(call ,inner ,@param*)
                                      `(,inner ,@param*))
                                  ERROR-BAD-TYPE-CHECK)))
                   def*)))]))

;; association list mapping prim-f to (list (primop or aloc) (listof unsafe-def))
;; interp. it is a dict that maps the prim-f to its corresponding primop or label
;;            alongside the label's needed definitions, if it exists
(define DEF-ENV (filter cdr (map cons (map car prim-f-specs) (map gen-defs prim-f-specs))))
(define (implement-safe-primops p)

  ; usage is a a set of all prim-f referenced in this program p
  (define usage (mutable-seteq))
  ; usage is a a set of all aloc referenced by primops corresponding to the prim-fs in usage set
  ;  triv -> (unsafe-triv or aloc or primop)
  ;; EFFECT: adds referenced prim-f to usage
  (define (implement-triv! triv)
    (match triv
      [(? (or/c label? aloc? int61? boolean? 'empty ascii-char-literal?)) triv]
      [`(error ,(? uint8?)) triv]
      ['(void) triv]
      [`(lambda ,aloc* ,value) `(lambda ,aloc* ,(implement-value! value))]
      [prim-f
       (set-add! usage prim-f)
       (car (dict-ref DEF-ENV prim-f))]))

  (define (implement-value! value [k identity])
    (match value
      [`(if ,val0 ,val1 ,val2)
       `(if ,(implement-value! val0)
            ,(implement-value! val1 k)
            ,(implement-value! val2 k))]
      [`(let ([,aloc* ,val*] ...) ,val)
       `(let ,(map list aloc* (map implement-value! val*)) ,(implement-value! val k))]
      [`(call ,val0 ,opand* ...)
       (implement-value! val0
                         (λ (triv)
                           (k (if (primop? triv)
                                  `(,triv ,@(map implement-value! opand*))
                                  `(call ,triv ,@(map implement-value! opand*))))))]
      [_ (k (implement-triv! value))]))
  ;   p	 	::=	 	(module (define label (lambda (aloc ...) value)) ... value)
  ;; EFFECT: adds referenced prim-fs to usage
  (define (implement-def! def)
    (match def
      [`(define ,label (lambda (,aloc* ...) ,value))
       `(define ,label (lambda ,aloc* ,(implement-value! value)))]))
  (match p
    [`(module ,def* ...
        ,value)
     (define def/unsafe* (map implement-def! def*))
     (define value/unsafe (implement-value! value))
     (define primop-def*
       (for/fold ([def* '()]) ([primop (set->list usage)])
         (append (cadr (dict-ref DEF-ENV primop)) def*)))
     `(module ,@primop-def* ,@def/unsafe*
        ,value/unsafe)]))

(module+ test
  (require rackunit
           cpsc411/langs/v9)
  (define (peek x)
    ; (pretty-display x)
    x)

  (define-syntax-rule (check-by-interp p)
    (check-equal? (peek (interp-exprs-unique-lang-v9 p))
                  (interp-exprs-unsafe-data-lang-v9 (peek (implement-safe-primops p)))))
  (check-by-interp `(module 1))
  (check-by-interp `(module #t))
  (check-by-interp `(module #f))
  (check-by-interp `(module #\a))

  (check-by-interp `(module (define fact.0
                              (lambda (x.0)
                                (if (call <= x.0 1)
                                    1
                                    (call * x.0 (call fact.0 (call - x.0 1))))))
                            (call fact.0 5)
                      ))
  (check-by-interp `(module (let ([sub1.0 (lambda (x.0) (call - x.0 1))]) (call sub1.0 5))))
  (check-by-interp `(module (define fact.0
                              (lambda (x.0 a.0)
                                (if (call <= x.0 1)
                                    a.0
                                    (call fact.0 (call - x.0 1) (call * x.0 a.0)))))
                            (call fact.0 5 1)
                      ))

  (check-by-interp
   `(module (define fib.0
              (lambda (x.0)
                (if (call <= x.0 1)
                    x.0
                    (call + (call fib.0 (call - x.0 1)) (call fib.0 (call - x.0 2))))))
            (call fib.0 5)
      )))
