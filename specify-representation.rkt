#lang racket
(require cpsc411/compiler-lib
         cpsc411/langs/v8
         cpsc411/langs/v9
         "common.rkt")

(provide specify-representation)
;; NB: only unsafe-vector-set! can appear in effect context

;; (Proc-exposed-lang-v9 p) -> (Exprs-bits-lang-v8 p)
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

  (define (specify-primop primop values)

    (define (evaluate-unop mask tag)
      `(if (= (bitwise-and 5 10) ,tag)
           ,(current-true-ptr)
           ,(current-false-ptr)))

    (define (unsafe-binop->relop relop)
      (match relop
        [`eq? '=]
        [`unsafe-fx< '<]
        [`unsafe-fx<= '<=]
        [`unsafe-fx> '>]
        [`unsafe-fx>= '>=]))

    (match primop
      [`fixnum? (evaluate-unop (current-fixnum-mask) (current-fixnum-tag))]
      [`boolean? (evaluate-unop (current-boolean-mask) (current-boolean-tag))]
      [`empty? (evaluate-unop (current-empty-mask) (current-empty-tag))]
      [`void? (evaluate-unop (current-void-mask) (current-void-tag))]
      [`ascii-char? (evaluate-unop (current-ascii-char-mask) (current-ascii-char-tag))]
      [`error? (evaluate-unop (current-error-mask) (current-error-tag))]
      [`not
       `(if (= ,(specify-value (first values)) ,(current-false-ptr))
            ,(current-true-ptr)
            ,(current-false-ptr))]
      [`pair? (evaluate-unop (current-pair-mask) (current-pair-tag))]
      [`vector? (evaluate-unop (current-vector-mask) (current-vector-tag))]
      ;; added for m9
      [`procedure? (evaluate-unop (current-procedure-mask) (current-procedure-tag))]
      ;; (car|cdr)-offset both incorporate detagging
      [`unsafe-car `(mref ,(specify-value (first values)) ,(car-offset))]
      [`unsafe-cdr `(mref ,(specify-value (first values)) ,(cdr-offset))]
      [`unsafe-make-vector
       (define base (fresh-label))
       (define total-size
         (+ (current-vector-base-displacement)
            (arithmetic-shift (specify-value (first values)) (current-vector-shift))))
       `(let ([,base (+ (alloc ,total-size) ,(current-vector-tag))])
          (begin
            (mset! ,base
                   ,(* -1 (current-vector-tag))
                   ,(- total-size (current-vector-base-displacement)))
            ,base))]
      [`unsafe-vector-length
       `(mref ,(specify-value (first values))
              ,(- (current-vector-length-displacement) (current-vector-tag)))]
      [`unsafe-procedure-arity
       `(mref ,(specify-value (first values))
              ,(- (current-procedure-arity-displacement) (current-procedure-tag)))]
      [`unsafe-procedure-label
       `(mref ,(specify-value (first values))
              ,(- (current-procedure-label-displacement) (current-procedure-tag)))]
      ;;
      [`unsafe-fx*
       `(* ,(specify-value (first values))
           (arithmetic-shift-right ,(specify-value (second values)) ,(current-fixnum-shift)))]
      [`unsafe-fx+ `(+ ,(specify-value (first values)) ,(specify-value (second values)))]
      [`unsafe-fx- `(- ,(specify-value (first values)) ,(specify-value (second values)))]
      ;; added for M8
      [`cons
       (define base (fresh-label))
       `(let ([,base (+ (alloc ,(current-pair-size)) ,(current-pair-tag))])
          (begin
            (mset! ,base
                   ,(- (current-car-displacement) (current-pair-tag))
                   ,(specify-value (first values)))
            (mset! ,base
                   ,(- (current-cdr-displacement) (current-pair-tag))
                   ,(specify-value (second values)))
            ,base))]
      [`unsafe-vector-ref
       `(mref ,(specify-value (first values))
              (- (+ ,(specify-value (second values)) ,(current-vector-base-displacement))
                 ,(current-vector-tag)))]

      [`unsafe-procedure-ref
       `(mref ,(specify-value (first values))
              (- (+ ,(specify-value (second values)) ,(current-procedure-environment-displacement))
                 ,(current-procedure-tag)))]

      [`unsafe-vector-set!
       `(mset! ,(specify-value (first values))
               (+ ,(- (current-vector-base-displacement) (current-vector-tag))
                  ,(specify-value (second values)))
               ,(specify-value (third values)))]
      [`make-procedure
       (define base (fresh-label))
       `(let ([,base (+ (alloc (+ ,(current-procedure-environment-displacement)
                                  ,(specify-value (third values))))
                        ,(current-procedure-tag))])
          (begin
            (mset! ,base
                   ,(- (current-procedure-label-displacement) (current-procedure-tag))
                   ,(specify-value (first values)))
            (mset! ,base
                   ,(- (current-procedure-arity-displacement) (current-procedure-tag))
                   ,(specify-value (second values)))
            ,base))]
      [`unsafe-procedure-set!
       `(mset! ,(specify-value (first values))
               (+ ,(specify-value (second values))
                  ,(- (current-procedure-environment-displacement) (current-procedure-tag)))
               ,(specify-value (third values)))]

      [_

       `(if (,(unsafe-binop->relop primop) ,(specify-value (first values))
                                           ,(specify-value (second values)))
            ,(current-true-ptr)
            ,(current-false-ptr))]))

  (define (specify-effect effect)
    (match effect
      [`(begin
          ,effects ...)
       `(begin
          ,@(map specify-effect effects))]
      [`(,primop ,values ...)
       ;; update this
       #:when (primop? primop)
       (specify-primop primop values)]))

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
      [`(begin
          ,effects ...
          ,val)
       `(begin
          ,@(map specify-effect effects)
          ,(specify-value val))]

      [`(,primop ,values ...)
       #:when (primop? primop)
       (specify-primop primop values)]

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
