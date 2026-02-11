#lang racket

(require cpsc411/compiler-lib)

(provide implement-fvars)

;  p	 	::=	 	(begin s ...)
;   s	 	::=	 	(set! fvar int32)
;  	 	|	 	(set! fvar reg)
;  	 	|	 	(set! reg loc)
;  	 	|	 	(set! reg triv)
;  	 	|	 	(set! reg_1 (binop reg_1 int32))
;  	 	|	 	(set! reg_1 (binop reg_1 loc))
;   triv	 	::=	 	reg  | 	int64

;   loc	 	::=	 	reg | fvar
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
;   binop	 	::=	 	* |	+
;   int64	 	::=	 	int64?
;   int32	 	::=	 	int32?
;   fvar	 	::=	 	fvar?

;; (paren-x64-fvars-v2) -> (paren-x64-v2)
;; Reifies fvars into displacement mode operands
(define (implement-fvars p)
  ;; (paren-x64-fvars-v2 fvar) -> (paren-x64-v2 addr)
  ;; converts an fvar into an address
  (define (implement-fvar fvar)
    `(,(current-frame-base-pointer-register) - ,(* 8 (fvar->index fvar))))

  (define (implement-s s)
    (match s
      [`(set! ,(? fvar? fvar) ,rest) `(set! ,(implement-fvar fvar) ,rest)]
      [`(set! ,reg1 (,binop ,reg1 ,(? fvar? fvar)))
       `(set! ,reg1 (,binop ,reg1 ,(implement-fvar fvar)))]
      [`(set! ,reg (? fvar? fvar)) `(set! ,reg ,(implement-fvar fvar))]
      [_ s]))

  (define (implement-p)
    (match p
      [`(begin
          ,s ...)
       `(begin
          ,@(map implement-s s))]))
  (implement-p p))
