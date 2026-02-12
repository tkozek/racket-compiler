#lang racket

(require cpsc411/compiler-lib)

(provide generate-x64
         interp-paren-x64)
; p	 	::=	 	(begin s ...)

;   s	 	::=	 	(set! addr int32)
;  	 	|	 	(set! addr reg)
;  	 	|	 	(set! reg loc)
;  	 	|	 	(set! reg triv)
;  	 	|	 	(set! reg_1 (binop reg_1 int32))
;  	 	|	 	(set! reg_1 (binop reg_1 loc))

;   triv	 	::=	 	reg
;  	 	|	 	int64

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

;   int64	 	::=	 	int64?

;   int32	 	::=	 	int32?

;   dispoffset	 	::=	 	dispoffset?

;; (paren-x64-v2 p) -> x64-instruction-sequence
;; Compiles a Paren-x64 v2 program into x64 instruction sequence, represented as a string
(define (generate-x64 p)

  ;; (paren-x64-v2 addr) -> (paren-x64-v2 dispoffset)
  ;; returns displacement offset for a given address.
  (define (addr->dispoffset addr)
    (match addr
      [`[,(current-frame-base-pointer-register) - dispoffset] dispoffset]))

  ;; (paren-x64-v2 dispoffset) -> (x64 displacement mode operand)
  ;; Takes an offset and produces: QWORD [fbp - offset]
  (define (dispoffset->dmo offset)
    (format "QWORD [~a - ~a]" (current-frame-base-pointer-register) offset))

  ;; (paren-x64-v2 addr) -> (x64 displacement mode operand)
  ;; Takes address of the form: (fbp - offset), and produces: QWORD [fbp - offset]
  (define (addr->dmo addr)
    (dispoffset->dmo (addr->dispoffset addr)))

  (define (binop->ins op)
    (match op
      ['+ "add"]
      ['* "imul"]))

  ;   (define (loc->x64 loc)
  ;     (TODO "generate-x64"))

  ; (paren-x64-v2 s) -> x64-instruction-sequence
  (define (statement->x64 s)
    (match s
      [`(set! ,reg1 (,op ,reg1 ,val))
       #:when (or (int32? val) (register? val))
       (format "~a ~a, ~a\n" (binop->ins op) reg1 val)]
      [`(set! ,reg1 (,op ,reg1 ,addr)) (format "~a ~a, ~a\n" (binop->ins op) reg1 (addr->dmo addr))]
      [`(set! ,reg ,val)
       #:when (and (register? reg) (or (register? val) (int64? val)))
       (format "mov ~a, ~a\n" reg val)]
      [`(set! ,reg ,addr)
       #:when (register? reg)
       (format "mov ~a, ~a\n" reg (addr->dmo addr))]
      [`(set! ,addr ,val) (format "mov ~a, ~a\n" (addr->dmo addr) val)]))

  ; (paren-x64-v2 p) -> x64-instruction-sequence
  (define (program->x64 p)
    (match p
      [`(begin
          ,s ...)
       (string-join (map statement->x64 s) "")]))

  (program->x64 p))

(define (interp-paren-x64 p)
  ; Environment (List-of (paren-x64-v2 Statements)) -> Integer
  (define (eval-instruction-sequence env sls)
    (if (empty? sls)
        (dict-ref env 'rax)
        (TODO "Implement the fold over a sequence of Paren-x64-v2 /s/.")))

  ; Environment Statement -> Environment
  (define (eval-statement env s)
    (TODO "Implement the transition function evaluating a Paren-x64-v2 /s/."))

  ; (Paren-x64-v2 binop) -> procedure?
  (define (eval-binop b)
    (TODO "Implement the interpreter for Paren-x64-v2 /binop/."))

  ; Environment (Paren-x64-v2 triv) -> Integer
  (define (eval-triv regfile t)
    (TODO "Implement the interpreter for Paren-x64-v2 /triv/."))

  (TODO "Implement the interpreter for Paren-x64-v2 /p/."))
