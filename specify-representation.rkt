#lang racket
(require cpsc411/compiler-lib
         cpsc411/langs/v8
         "common.rkt")

(provide specify-representation)
;; NB: only unsafe-vector-set! can appear in effect context

;; (Exprs-unsafe-data-lang v8 p) -> (Exprs-bits-lang-v8 p)
;; Compiles immediate data and primitive operations into their implementations as
;; ptrs and primitive bitwise operations on ptrs.
(define (specify-representation p)

  (define (specify-triv triv)
    (match triv
      ['empty (current-empty-ptr)]
      ['(void) (current-void-ptr)]
      ['#t (current-true-ptr)]
      ['#f (current-false-ptr)]
      [(? ascii-char-literal?)
       (bitwise-ior (arithmetic-shift (char->integer triv) (current-ascii-char-shift))
                    (current-ascii-char-tag))]
      [(? int61?) (bitwise-ior (arithmetic-shift triv (current-fixnum-shift)) (current-fixnum-tag))]
      [`(error ,(? uint8? error-code))
       (bitwise-ior (arithmetic-shift error-code (current-error-shift)) (current-error-tag))]
      ;; label or aloc
      [_ triv]))

  ;; for add and sub: add then tag both
  ;; for *: tag one, then multiply
  ;; for relop, do nothing?

  (define (specify-binop binop value1 value2)

    (define (unsafe-binop->relop relop)
      (match relop
        [`eq? '=]
        [`unsafe-fx< '<]
        [`unsafe-fx<= '<=]
        [`unsafe-fx> '>]
        [`unsafe-fx>= '>=]))

    (match binop
      [`unsafe-fx*
       `(* ,(specify-value value1)
           (arithmetic-shift-right ,(specify-value value2) ,(current-fixnum-shift)))]
      [`unsafe-fx+ `(+ ,(specify-value value1) ,(specify-value value2))]
      [`unsafe-fx- `(- ,(specify-value value1) ,(specify-value value2))]
      ;; added for M8
      [`cons
       (define base (gensym))
       `(let ([,base (+ (alloc 16) 1)])
          (begin
            ;; TODO: remove magic numbers
            (mset! ,base -1 ,(specify-value value1))
            (mset! ,base 7 ,(specify-value value2))
            ,base))]
      [`unsafe-vector-ref
       `(mref ,(specify-value value1)
              ,(- (+ (specify-value value2) (current-vector-base-displacement))
                  (current-vector-tag)))]
      [_
       `(if (,(unsafe-binop->relop binop) ,(specify-value value1) ,(specify-value value2))
            ,(current-true-ptr)
            ,(current-false-ptr))]))

  ;`(this that) -> (list 'this 'that)
  ; `(,(identity '>)) -> '(>) = (list '>)
  (define (specify-unop unop value)
    (define (evaluate-unop mask tag)
      `(if (= (bitwise-and ,(specify-value value) ,mask) ,tag)
           ,(current-true-ptr)
           ,(current-false-ptr)))

    (match unop
      [`fixnum? (evaluate-unop (current-fixnum-mask) (current-fixnum-tag))]
      [`boolean? (evaluate-unop (current-boolean-mask) (current-boolean-tag))]
      [`empty? (evaluate-unop (current-empty-mask) (current-empty-tag))]
      [`void? (evaluate-unop (current-void-mask) (current-void-tag))]
      [`ascii-char? (evaluate-unop (current-ascii-char-mask) (current-ascii-char-tag))]
      [`error? (evaluate-unop (current-error-mask) (current-error-tag))]
      [`not
       `(if (= ,(specify-value value) ,(current-false-ptr))
            ,(current-true-ptr)
            ,(current-false-ptr))]
      ;; added for M8
      [`pair? (evaluate-unop (current-pair-mask) (current-pair-tag))]
      [`vector? (evaluate-unop (current-vector-mask) (current-vector-tag))]
      ;; (car|cdr)-offset both incorporate detagging
      [`unsafe-car `(mref ,(specify-value value) ,(car-offset))]
      [`unsafe-cdr `(mref ,(specify-value value) ,(cdr-offset))]
      [`unsafe-make-vector
       (define base (gensym))
       (define total-size
         (+ (current-vector-base-displacement) (arithmetic-shift value (current-vector-shift))))
       `(let ([,base (+ (alloc ,total-size) ,(current-vector-tag))])
          (begin
            (mset! ,base
                   ,(* -1 (current-vector-tag))
                   ,(- total-size (current-vector-base-displacement)))
            ,base))]
      [`unsafe-vector-length
       `(mref ,(specify-value value)
              ,(+ (* -1 (current-vector-tag)) (current-vector-length-displacement)))]))

  (define (specify-primop primop values)
    (match primop
      [(? binop/unsafe?) (specify-binop primop (first values) (second values))]
      [(? unop?) (specify-unop primop (first values))]))

  (define (specify-effect effect)
    (match effect
      [`(,primop ,values ...)
       ;; TODO: Add imperative-primop? to common.rkt
       ;; for now this will simply check if primop == unsafe-vector-set!
       #:when (imperative-primop? primop)
       `(,(specify-primop primop) ,@(specify-value values))]
      [`(begin
          ,effects ...)
       `(begin
          ,@(map specify-effect effects))]))

  (define (specify-value value)
    (match value
      [`(if ,v1 ,v2 ,v3)
       `(if (!= ,(specify-value v1) ,(current-false-ptr))
            ,(specify-value v2)
            ,(specify-value v3))]
      [`(let ([,alocs ,values] ...) ,body-value)
       ;; don't want to unquote splice the map result, or we lose outer brackets ([]
       ;;                                                                        []
       ;;                                                                        [])
       `(let ,(map (lambda (aloc value) `[,aloc ,(specify-value value)]) alocs values)
          ,(specify-value body-value))]
      [`(call ,values ...) `(call ,@(map specify-value values))]
      [`(,primop ,values ...)
       #:when (primop? primop)
       (specify-primop primop values)]
      [`(begin
          ,effects ...
          ,val)
       `(begin
          ,@(map specify-effect effects)
          ,(specify-value val))]
      [_ (specify-triv value)]))

  (define (specify-definition def)
    (match def
      [`(define ,label (lambda (,alocs ...) ,value))
       `(define ,label (lambda (,@alocs) ,(specify-value value)))]))

  (define (specify-p p)
    (match p
      [`(module ,defs ...
          ,value)
       `(module ,@(map specify-definition defs) ,(specify-value value)
          )]))

  (specify-p p))

(module+ test
  (require rackunit
           cpsc411/langs/v8
           cpsc411/test-suite/public/v8
           cpsc411/compiler-lib)
  (define-syntax-rule (check-by-interp p)
    (check-equal? p p))
  (v8-public-test-suite '(specify-representation) '(interp-exprs-unsafe-data-lang-v8))

  (check-match (specify-representation '(module (cons 5 6)))
               `(module (let ([,tmp (+ (alloc 16) 1)])
                          (begin
                            (mset! ,tmp -1 40)
                            (mset! ,tmp 7 48)
                            ,tmp))))
  (check-match (specify-representation '(module (unsafe-car (cons 5 6))))
               `(module (mref (let ([,tmp (+ (alloc 16) 1)])
                                (begin
                                  (mset! ,tmp -1 40)
                                  (mset! ,tmp 7 48)
                                  ,tmp))
                              -1)))
  (check-match (specify-representation '(module (unsafe-vector-ref (unsafe-make-vector 3) 6)))
               `(module (mref (let ([,tmp (+ (alloc 32) 3)])
                                (begin
                                  (mset! ,tmp -3 24)
                                  ,tmp))
                              53)))
  (check-match (specify-representation '(module (unsafe-vector-length (unsafe-make-vector 4))))
               `(module (mref (let ([,tmp (+ (alloc 40) 3)])
                                (begin
                                  (mset! ,tmp -3 32)
                                  ,tmp))
                              ;   ,(- (current-vector-length-displacement) (current-vector-tag))
                              -3))))
