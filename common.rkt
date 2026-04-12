#lang racket
(require cpsc411/compiler-lib)

(provide (all-defined-out))

(define (addr? addr)
  (match addr
    [`(,(? frame-base-pointer-register?) - ,(? dispoffset?)) #t]
    [_ #f]))
(define reg? register?)
(define loc? (or/c reg? addr?))
(define opand? (or/c int64? loc?))
(define triv? (or/c opand? label?))
(define trg? (or/c label? loc?))

;;;;;

(define paren-x64-mops-trg? (or/c label? register?))
(define paren-x64-mops-triv? (or/c trg? int64?))
(define paren-x64-mops-opand? (or/c int64? register?))
(define (paren-x64-v8-addr? addr)
  (match addr
    [`(,(? frame-base-pointer-register?) - ,(? dispoffset?)) #t]
    [`(,(? register?) + ,(? int32?)) #t]
    [`(,(? register?) + ,(? register?)) #t]
    [_ #f]))
(define (paren-x64-v8-loc? loc)
  (or/c register? paren-x64-v8-addr?))

;;;

(define binop '(+ - * eq? < <= > >=))
(define binop? (compose not false? (curryr memq binop)))

(define binop/unsafe
  '(unsafe-fx+ unsafe-fx-
               unsafe-fx*
               eq?
               unsafe-fx<
               unsafe-fx<=
               unsafe-fx>
               unsafe-fx>=
               cons
               unsafe-vector-ref
               unsafe-procedure-ref))
(define binop/unsafe? (compose not false? (curryr memq binop/unsafe)))

(define binop/ptr '(+ - * bitwise-and bitwise-ior bitwise-xor arithmetic-shift-right))

(define binop/ptr? (compose not false? (curryr memq binop/ptr)))

(define structop '(cons car cdr make-vector vector-length vector-set! vector-ref))
(define structop? (compose not false? (curry memq structop)))

(define procedureop '(procedure-arity))
(define procedureop? (compose not false? (curry memq procedureop)))

(define procedureop/unsafe
  '(make-procedure unsafe-procedure-arity
                   unsafe-procedure-label
                   unsafe-procedure-ref
                   unsafe-procedure-set!))
(define procedureop/unsafe? (compose not false? (curry memq procedureop/unsafe)))

(define unop
  '(fixnum? boolean?
            empty?
            void?
            ascii-char?
            error?
            not
            unsafe-car
            unsafe-cdr
            unsafe-vector-length
            unsafe-make-vector
            pair?
            vector?
            procedure?
            unsafe-procedure-arity
            unsafe-procedure-label))
(define unop? (compose not false? (curryr memq unop)))

(define prim-f `(,@binop ,@unop ,@structop ,@procedureop 'unsafe-vector-set!))
(define prim-f? (compose not false? (curryr memq prim-f)))

(define (binop->fun op)
  (match op
    ['+ x64-add]
    ['* x64-mul]
    ['- x64-sub]
    ['bitwise-and bitwise-and]
    ['bitwise-xor bitwise-xor]
    ['bitwise-ior bitwise-ior]
    ['arithmetic-shift-right (λ (x) (arithmetic-shift (- x)))]))

;; alias for int61?
(define (fixnum? n)
  (int61? n))
(define (fixnum/tagged? fn)
  (and (int64? fn) (eq? (bitwise-and (current-fixnum-mask) fn) (current-fixnum-tag))))

(define (boolean/tagged? fn)
  (and (int64? fn) (eq? (bitwise-and (current-boolean-mask) fn) (current-boolean-tag))))

(define (empty/tagged? fn)
  (and (int64? fn) (eq? (bitwise-and (current-empty-mask) fn) (current-empty-tag))))

(define (void/tagged? fn)
  (and (int64? fn) (eq? (bitwise-and (current-void-mask) fn) (current-void-tag))))

(define (ascii-char/tagged? fn)
  (and (int64? fn) (eq? (bitwise-and (current-ascii-char-mask) fn) (current-ascii-char-tag))))

(define (error/tagged? fn)
  (and (int64? fn) (eq? (bitwise-and (current-error-mask) fn) (current-error-tag))))

(define (pair/tagged? fn)
  (and (int64? fn) (eq? (bitwise-and (current-pair-mask) fn) (current-pair-tag))))

(define primop
  `(fixnum? boolean?
            empty?
            void?
            ascii-char?
            error?
            not
            unsafe-car
            unsafe-cdr
            unsafe-vector-length
            unsafe-make-vector
            pair?
            vector?
            procedure?
            unsafe-procedure-arity
            unsafe-procedure-label
            unsafe-fx+
            unsafe-fx-
            unsafe-fx*
            eq?
            unsafe-fx<
            unsafe-fx<=
            unsafe-fx>
            unsafe-fx>=
            cons
            unsafe-vector-ref
            unsafe-procedure-ref
            unsafe-vector-set!
            unsafe-procedure-set!
            make-procedure))
(define primop? (compose not false? (curryr memq primop)))

(define imperative-primop '(unsafe-vector-set! unsafe-procedure-set!))

(define imperative-primop? (compose not false? (curryr memq imperative-primop)))

(module+ test
  (require rackunit)
  (check-true (binop? '+))
  (check-true (binop? '-))
  (check-true (binop? '*))
  (check-true (binop? 'eq?))
  (check-true (binop? '>))
  (check-true (binop? '>=))
  (check-true (binop? '<=))
  (check-true (binop? '<))

  (check-true (unop? 'fixnum?))
  (check-true (unop? 'boolean?))
  (check-true (unop? 'empty?))
  (check-true (unop? 'void?))
  (check-true (unop? 'ascii-char?))
  (check-true (unop? 'error?))
  (check-true (unop? 'not))

  (let ([binop? prim-f?]
        [unop? prim-f?])
    (check-true (binop? '+))
    (check-true (binop? '-))
    (check-true (binop? '*))
    (check-true (binop? 'eq?))
    (check-true (binop? '>))
    (check-true (binop? '>=))
    (check-true (binop? '<=))
    (check-true (binop? '<))

    (check-true (unop? 'fixnum?))
    (check-true (unop? 'boolean?))
    (check-true (unop? 'empty?))
    (check-true (unop? 'void?))
    (check-true (unop? 'ascii-char?))
    (check-true (unop? 'error?))
    (check-true (unop? 'not)))
  (check-true (primop? 'unsafe-fx+))
  (check-true (primop? 'unsafe-fx-))
  (check-true (primop? 'unsafe-fx*))
  (check-true (primop? 'unsafe-fx<))
  (check-true (primop? 'unsafe-fx<=))
  (check-true (primop? 'unsafe-fx>))
  (check-true (primop? 'unsafe-fx>=))
  (check-true (primop? 'unsafe-car))
  (check-true (primop? 'unsafe-cdr))
  (check-true (primop? 'cons))
  (check-true (primop? 'unsafe-vector-ref))
  (check-true (primop? 'unsafe-procedure-ref))
  (check-true (primop? 'unsafe-vector-set!))
  (check-true (primop? 'make-procedure))
  (check-true (primop? 'unsafe-procedure-set!))
  (check-true (primop? 'unsafe-procedure-label))
  (check-true (primop? 'unsafe-procedure-ref))
  (check-true (primop? 'procedure?))
  (check-true (primop? 'unsafe-make-vector))
  (check-true (primop? 'unsafe-vector-length))
  (check-true (primop? 'unsafe-procedure-arity)))
