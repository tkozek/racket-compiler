#lang racket

(require cpsc411/compiler-lib)

(provide flatten-program)

;; block-asm-lang-v6
;  p	 	::=	 	(module b ... b)

;   b	 	::=	 	(define label tail)

;   tail	 	::=	 	(jump trg)
;  	 	|	 	(begin effect ... tail)
;  	 	|	 	(if (relop loc opand) (jump trg) (jump trg))

;   effect	 	::=	 	(set! loc triv)
;  	 	|	 	(set! loc_1 (binop loc_1 opand))

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

;   int64	 	::=	 	int64?

;   addr	 	::=	 	(fbp - dispoffset)

;   fbp	 	::=	 	frame-base-pointer-register?

;   dispoffset	 	::=	 	dispoffset?

;   label	 	::=	 	label?
;; --------------------------
;; para-asm-lang-v6
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

(define (addr? addr)
  (match addr
    [`(,(? frame-base-pointer-register?) - ,(? dispoffset?)) #t]
    [_ #f]))
(define reg? register?)
(define loc? (or/c reg? addr?))
(define opand? (or/c int64? loc?))
(define triv? (or/c opand? label?))
(define trg? (or/c label? loc?))
(define binop? (or/c '+ '* '-))
;; block-asm-lang-v6 -> para-asm-lang-v6
;; Compile Block-asm-lang v6 to Para-asm-lang v6 by flattening basic blocks into labeled instructions.
(define (flatten-program bal4)
  (define flatten-effect identity)

  (define (flatten-tail tail)
    (match tail
      [`(halt ,(? opand?)) (list tail)]
      [`(jump ,(? trg?)) (list tail)]
      [`(begin
          ,fx* ...
          ,tail)
       (append (map flatten-effect fx*) (flatten-tail tail))]
      [`(if (,relop ,loc ,opand)
            (jump ,trg)
            (jump ,trg2))
       `((compare ,loc ,opand) (jump-if ,relop ,trg) (jump ,trg2))]))
  (define (flatten-b b)
    (match b
      [`(define ,(? label? label)
          ,tail)
       (let ([s* (flatten-tail tail)]) `((with-label ,label ,(first s*)) ,@(rest s*)))]))
  (define (flatten-p p)
    (match p
      [`(module ,b* ...
          ,b)
       `(begin
          ,@(foldr append '() (map flatten-b b*))
          ,@(flatten-b b))]))
  (flatten-p bal4))
