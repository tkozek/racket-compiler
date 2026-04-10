#lang racket
(require cpsc411/compiler-lib
         cpsc411/langs/v4)
(provide patch-instructions)
;para-asm-lang-v2
; p	 	::=	 	(begin effect ... (halt triv))
; effect	 	::=	 	(set! loc triv)
;  	|	 	(set! loc_1 (binop loc_1 triv))
; triv	 	::=	 	int64
;  	|	 	loc
; loc	 	::=	 	reg
;  	|	 	fvar
; reg	 	::=	 	rsp
;  	|	 	rbp
;  	|	 	rax
;  	|	 	rbx
;  	|	 	rcx
;  	|	 	rdx
;  	|	 	rsi
;  	|	 	rdi
;  	|	 	r8
;  	|	 	r9
;  	|	 	r12
;  	|	 	r13
;  	|	 	r14
;  	|	 	r15
; binop	 	::=	 	*
;  	|	 	+
; int64	 	::=	 	int64?
; fvar	 	::=	 	fvar?
; -----------------------
; paren-x64-fvars-v2
; p	 	::=	 	(begin s ...)

; s	 	::=	 	(set! fvar int32)
;  	|	 	(set! fvar reg)
;  	|	 	(set! reg loc)
;  	|	 	(set! reg triv)
;  	|	 	(set! reg_1 (binop reg_1 int32))
;  	|	 	(set! reg_1 (binop reg_1 loc))

; triv	 	::=	 	reg
;  	|	 	int64

; loc	 	::=	 	reg
;  	|	 	fvar

; reg	 	::=	 	rsp
;  	|	 	rbp
;  	|	 	rax
;  	|	 	rbx
;  	|	 	rcx
;  	|	 	rdx
;  	|	 	rsi
;  	|	 	rdi
;  	|	 	r8
;  	|	 	r9
;  	|	 	r10
;  	|	 	r11
;  	|	 	r12
;  	|	 	r13
;  	|	 	r14
;  	|	 	r15

; binop	 	::=	 	*
;  	|	 	+

;; para-asm-lang-v4 -> paren-x64-fvars-v4
;; Compiles Para-asm-lang v4 to Paren-x64-fvars v4 by patching each instruction that has no x64
;; analogue into a sequence of instructions using auxilliary
;; register from current-patch-instruction-registers
(define (patch-instructions p)
  (define aux-reg current-patch-instructions-registers)
  (define first-reg (first (aux-reg)))
  (define second-reg (second (aux-reg)))

  ;; (para-asm-lang-v4 s)-> (paren-x64-fvars-v4 s)
  ;; patches set! instructions where the id is a register
  (define (patch-set-reg s)
    (match s
      [`(set! ,reg1 (,binop ,reg1 ,triv))
       #:when (and (integer? triv) (not (int32? triv)))
       `((set! ,first-reg ,triv) (set! ,reg1 (,binop ,reg1 ,first-reg)))]
      [_ `(,s)]))

  ;; (para-asm-lang-v4 s)-> (paren-x64-fvars-v4 s)
  ;; patches set! instructions where the id is a register
  (define (patch-set-fvar s)
    (match s
      [`(set! ,fvar1 (,binop ,fvar1 ,triv))
       `((set! ,first-reg ,triv) (set! ,first-reg (,binop ,first-reg ,fvar1))
                                 (set! ,fvar1 ,first-reg))]
      [`(set! ,fvar1 ,triv)
       #:when (or (fvar? triv) (and (integer? triv) (not (int32? triv))))
       `((set! ,first-reg ,triv) (set! ,fvar1 ,first-reg))]
      [_ `(,s)]))

  (define (patch-s s)
    (match s
      [`(set! ,loc ,rest)
       #:when (register? loc)
       (patch-set-reg s)]
      [`(set! ,loc ,rest) (patch-set-fvar s)]
      [`(with-label ,label ,s)
       (define patched (patch-s s))
       `((with-label ,label ,(first patched)) ,@(rest patched))]
      [`(halt ,opand) `((set! ,(current-return-value-register) ,opand) (jump done))]
      [`(compare ,loc ,opand)
       `((set! ,first-reg ,loc) (set! ,second-reg ,opand) (compare ,first-reg ,second-reg))]
      [`(jump-if ,relop ,trg)
       #:when (or (fvar? trg) (register? trg))
       `((set! ,first-reg ,trg) (jump-if ,relop ,first-reg))]
      [`(jump ,relop ,trg)
       #:when (fvar? trg)
       `((set! ,first-reg ,trg) (jump ,relop ,first-reg))]
      [_ `(,s)]))

  (define (patch-p p)
    (match p
      [`(begin
          ,ss ...)
       `(begin
          ,@(apply append (map patch-s ss)))]))

  (patch-p p))
