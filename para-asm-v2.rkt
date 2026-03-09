#lang racket

(require cpsc411/compiler-lib)

(provide patch-instructions)
;; para-asm-lang-v2
;  p	 	::=	 	(begin effect ... (halt triv))

;   effect	 	::=	 	(set! loc triv) | (set! loc_1 (binop loc_1 triv))
;   triv	 	::=	 	int64 |	loc

;   loc	 	::=	 	reg  | fvar

;   reg	 	::=	 	rsp
;  	 	|	 	rbp
;  	 	|	 	rax
;  	 	|	 	rbx
;  	 	|	 	rcx
;  	 	|	 	rdx
;  	 	|	 	rsi
;  	 	|	 	rdi
;  	 	|	 	r8
;  	 	|	 	r9
;  	 	|	 	r12
;  	 	|	 	r13
;  	 	|	 	r14
;  	 	|	 	r15
;   binop	 	::=	 	* | +
;   int64	 	::=	 	int64?
;   fvar	 	::=	 	fvar?

;; (para-asm-lang-v2) -> (paren-x64-fvars-v2)
;; Patches instructions in p that have no x64 analogue
(define (patch-instructions p)
  (define aux-reg (current-patch-instructions-registers))
  (define first-reg (first (aux-reg)))

  (define (patch-effect-reg effect)
    (match effect
      [`(set! ,reg1 (,binop ,reg1 ,triv))
       #:when (integer? triv)
       (not (int32? triv))
       `((set! ,first-reg ,triv) (set! ,reg1 (,binop ,reg1 ,first-reg)))]
      [`(set! ,fvar1 ,triv)
       #:when (and (fvar? fvar1) (or (fvar? triv) (and (integer? triv) (not (int32? triv)))))
       `((set! ,first-reg ,triv) (set! ,fvar1 ,first-reg))]
      [_ effect]))

  (define (patch-effect-fvar effect)
    (match effect
      [`(set! ,fvar1 (,binop ,fvar1 ,triv))
       #:when (fvar? fvar1)
       `((set! ,first-reg ,triv) (set! ,first-reg (,binop ,first-reg ,fvar1))
                                 (set! ,fvar1 ,first-reg))]
      [`(set! ,fvar1 ,triv)
       #:when (or (fvar? triv) (and (integer? triv) (not (int32? triv))))
       `((set! ,first-reg ,triv) (set! ,fvar1 ,first-reg))]
      [_ effect]))

  (define (patch-effect effect)
    (match effect
      [`(set! ,loc ,rest)
       #:when (register? loc)
       (patch-effect-reg loc)]
      [`(set! ,loc ,rest) (patch-effect-fvar loc)]))

  (define (patch-p p)
    (match p
      [`(begin
          ,effects ...
          (halt ,triv))
       `(begin
          ,@(map patch-effect effects)
          (set! ,(current-return-value-register) ,triv))]))

  (patch-p p))

(module+ test
  (require rackunit
           cpsc411/langs/v3)
  (define-syntax-rule (check-by-interp p)
    (check-equal? (interp-values-lang-v3 p) (interp-values-unique-lang-v3 (uniquify p))))
  (check-equal? (patch-instructions '(begin
                                       (set! rbx 42)
                                       (halt rbx)))
                '(begin
                   (set! rbx 42)
                   (set! rax rbx)))
  (check-equal? (patch-instructions '(begin
                                       (set! fv0 0)
                                       (set! fv1 42)
                                       (set! fv0 fv1)
                                       (halt fv0)))
                '(begin
                   (set! fv0 0)
                   (set! fv1 42)
                   (set! r10 fv1)
                   (set! fv0 r10)
                   (set! rax fv0)))
  (check-equal? (patch-instructions '(begin
                                       (set! rbx 0)
                                       (set! rcx 0)
                                       (set! r9 42)
                                       (set! rbx rcx)
                                       (set! rbx (+ rbx r9))
                                       (halt rbx)))
                '(begin
                   (set! rbx 0)
                   (set! rcx 0)
                   (set! r9 42)
                   (set! rbx rcx)
                   (set! rbx (+ rbx r9))
                   (set! rax rbx))))
