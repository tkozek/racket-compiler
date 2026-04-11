#lang racket

(require cpsc411/compiler-lib
         cpsc411/langs/v2)

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
  (define first-reg (first aux-reg))

  ;; (para-asm-lang-v2 effect) -> (paren-x64-fvars-v2 effect)
  ;; patches an effect which sets the value at a register
  (define (patch-effect-reg effect)
    (match effect
      [`(set! ,reg1 (,binop ,reg1 ,triv))
       #:when (and (integer? triv) (not (int32? triv)))
       `((set! ,first-reg ,triv) (set! ,reg1 (,binop ,reg1 ,first-reg)))]
      [`(set! ,fvar1 ,triv)
       #:when (and (fvar? fvar1) (or (fvar? triv) (and (integer? triv) (not (int32? triv)))))
       `((set! ,first-reg ,triv) (set! ,fvar1 ,first-reg))]
      [_ (list effect)]))

  ;; (para-asm-lang-v2 effect) -> (paren-x64-fvars-v2 effect)
  ;; patches an effect which sets the value at an fvar
  (define (patch-effect-fvar effect)
    (match effect
      [`(set! ,fvar1 (,binop ,fvar1 ,triv))
       #:when (fvar? fvar1)
       `((set! ,first-reg ,triv) (set! ,first-reg (,binop ,first-reg ,fvar1))
                                 (set! ,fvar1 ,first-reg))]
      [`(set! ,fvar1 ,triv)
       #:when (or (fvar? triv) (and (integer? triv) (not (int32? triv))))
       `((set! ,first-reg ,triv) (set! ,fvar1 ,first-reg))]
      [_ (list effect)]))

  (define (patch-effect effect)
    (match effect
      [`(set! ,loc ,rest)
       #:when (register? loc)
       (patch-effect-reg effect)]
      [_ (patch-effect-fvar effect)]))

  (define (patch-p p)
    (match p
      [`(begin
          ,effects ...
          (halt ,triv))
       `(begin
          ,@(append-map patch-effect effects)
          (set! ,(current-return-value-register) ,triv))]))

  (patch-p p))
