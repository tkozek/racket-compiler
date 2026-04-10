#lang racket
(require cpsc411/compiler-lib
         cpsc411/langs/v4)
(provide patch-instructions)
;para-asm-lang-v6
;   p	 	::=	 	(begin s ...)

;   s	 	::=	 	(set! loc triv)
;  	 	|	 	(set! loc_1 (binop loc_1 opand))
;  	 	|	 	(jump trg)
;  	 	|	 	(with-label label s)
;  	 	|	 	(compare loc opand)
;  	 	|	 	(jump-if relop trg)

;   triv	 	::=	 	opand
;  	 	|	 	label

;   opand	 	::=	 	int64
;  	 	|	 	loc

;   trg	 	::=	 	label
;  	 	|	 	loc

;   loc	 	::=	 	reg
;  	 	|	 	addr

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

;   binop	 	::=	 	*
;  	 	|	 	+
;  	 	|	 	-

;   relop	 	::=	 	<
;  	 	|	 	<=
;  	 	|	 	=
;  	 	|	 	>=
;  	 	|	 	>
;  	 	|	 	!=

;   addr	 	::=	 	(fbp - dispoffset)

;   fbp	 	::=	 	frame-base-pointer-register?

;   int64	 	::=	 	int64?

;   dispoffset	 	::=	 	dispoffset?

;   label	 	::=	 	label?
; -----------------------
; paren-x64-v6
;   p	 	::=	 	(begin s ...)

;   s	 	::=	 	(set! addr int32)
;  	 	|	 	(set! addr trg)
;  	 	|	 	(set! reg loc)
;  	 	|	 	(set! reg triv)
;  	 	|	 	(set! reg_1 (binop reg_1 int32))
;  	 	|	 	(set! reg_1 (binop reg_1 loc))
;  	 	|	 	(with-label label s)
;  	 	|	 	(jump trg)
;  	 	|	 	(compare reg opand)
;  	 	|	 	(jump-if relop label)

;   trg	 	::=	 	reg
;  	 	|	 	label

;   triv	 	::=	 	trg
;  	 	|	 	int64

;   opand	 	::=	 	int64
;  	 	|	 	reg

;   loc	 	::=	 	reg
;  	 	|	 	addr

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
;  	 	|	 	r10
;  	 	|	 	r11
;  	 	|	 	r12
;  	 	|	 	r13
;  	 	|	 	r14
;  	 	|	 	r15

;   addr	 	::=	 	(fbp - dispoffset)

;   fbp	 	::=	 	frame-base-pointer-register?

;   binop	 	::=	 	*
;  	 	|	 	+
;  	 	|	 	-

;   relop	 	::=	 	<
;  	 	|	 	<=
;  	 	|	 	=
;  	 	|	 	>=
;  	 	|	 	>
;  	 	|	 	!=

;   int64	 	::=	 	int64?

;   int32	 	::=	 	int32?

;   dispoffset	 	::=	 	dispoffset?

;   label	 	::=	 	label?

;; (any/c) -> boolean
;; returns #t if addr is a para-asm-lang-v6 addr, otherwise returns #f
(define (addr? addr)
  (match addr
    [`(,fbp - ,dispoffset)
     #:when (and (frame-base-pointer-register? fbp) (dispoffset? dispoffset))
     #t]
    [_ #f]))

;; para-asm-lang-v6 -> paren-x64-v6
;; Compiles Para-asm-lang-v6 to Paren-x64-v6 by patching each instruction that has no x64
;; analogue into a sequence of instructions using auxiliary
;; registers from current-patch-instruction-registers
(define (patch-instructions p)
  (define aux-reg current-patch-instructions-registers)
  (define first-reg (first (aux-reg)))
  (define second-reg (second (aux-reg)))

  ;; (para-asm-lang-v6 s)-> (paren-x64-v6 s)
  ;; patches set! instructions where the id is a register
  (define (patch-set-reg s)
    (match s
      [`(set! ,reg1 (,binop ,reg1 ,triv))
       #:when (and (integer? triv) (not (int32? triv)))
       `((set! ,first-reg ,triv) (set! ,reg1 (,binop ,reg1 ,first-reg)))]
      [_ `(,s)]))

  ;; (para-asm-lang-v6 s)-> (paren-x64-v6 s)
  ;; patches set! instructions where the id is a register
  (define (patch-set-addr s)
    (match s
      [`(set! ,addr1 (,binop ,addr1 ,triv))
       `((set! ,first-reg ,triv) (set! ,first-reg (,binop ,first-reg ,addr1))
                                 (set! ,addr1 ,first-reg))]
      [`(set! ,addr1 ,triv)
       #:when (or (addr? triv) (and (integer? triv) (not (int32? triv))))
       `((set! ,first-reg ,triv) (set! ,addr1 ,first-reg))]
      [_ `(,s)]))

  (define (patch-s s)
    (match s
      [`(set! ,loc ,rest)
       #:when (register? loc)
       (patch-set-reg s)]
      [`(set! ,loc ,rest) (patch-set-addr s)]
      [`(with-label ,label ,s)
       (define patched (patch-s s))
       `((with-label ,label ,(first patched)) ,@(rest patched))]
      [`(compare ,loc ,opand)
       `((set! ,first-reg ,loc) (set! ,second-reg ,opand) (compare ,first-reg ,second-reg))]
      [`(jump-if ,relop ,trg)
       #:when (or (addr? trg) (register? trg))
       `((set! ,first-reg ,trg) (jump-if ,relop ,first-reg))]
      [`(jump ,trg)
       #:when (addr? trg)
       `((set! ,first-reg ,trg) (jump ,first-reg))]
      [_ `(,s)]))

  (define (patch-p p)
    (match p
      [`(begin
          ,ss ...)
       `(begin
          ,@(apply append (map patch-s ss)))]))

  (patch-p p))
