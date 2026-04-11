#lang racket

(require cpsc411/compiler-lib
         cpsc411/2c-run-time
         cpsc411/langs/v2)

(provide generate-x64
         interp-paren-x64
         check-paren-x64)
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
      [`(,fbp - ,dispoffset)
       #:when (eq? (current-frame-base-pointer-register) fbp)
       dispoffset]))

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

;; stub
(define (check-paren-x64 p)
  p)
;; stub
(define (interp-paren-x64 p)
  0)
(current-pass-list (list check-paren-x64 generate-x64 wrap-x64-run-time wrap-x64-boilerplate))

(module+ test
  (require rackunit
           cpsc411/2c-run-time
           cpsc411/langs/v2
           cpsc411/langs/v3)

  ;; START OF MILESTONE-1 generate-x64 TESTS
  (check-equal? (generate-x64 `(begin
                                 (set! rax 0)))
                "mov rax, 0\n")
  (check-equal? (generate-x64 `(begin
                                 (set! rax 0)
                                 (set! rax (+ rax 42))))
                "mov rax, 0\nadd rax, 42\n")
  (check-equal? (generate-x64 `(begin
                                 (set! rax ,(max-int 64))
                                 (set! rdi ,(min-int 64))
                                 (set! rdi rax)))
                "mov rax, 9223372036854775807\nmov rdi, -9223372036854775808\nmov rdi, rax\n")

  (check-equal? (generate-x64 `(begin
                                 (set! rax ,(max-int 64))
                                 (set! rdi ,(min-int 64))
                                 (set! rdi (+ rdi rax))))
                "mov rax, 9223372036854775807\nmov rdi, -9223372036854775808\nadd rdi, rax\n")
  (check-equal? (generate-x64 `(begin
                                 (set! rax 3)
                                 (set! rdi 2)
                                 (set! rdi (* rdi rax))))
                "mov rax, 3\nmov rdi, 2\nimul rdi, rax\n")

  (check-equal? (generate-x64 `(begin
                                 (set! rax -1)
                                 (set! rbx -1)
                                 (set! rbx (+ rbx ,(max-int 32)))))
                "mov rax, -1\nmov rbx, -1\nadd rbx, 2147483647\n")
  (check-equal? (generate-x64 `(begin
                                 (set! rcx -1)
                                 (set! rax rcx)
                                 (set! rcx (+ rcx ,(min-int 32)))))
                "mov rcx, -1\nmov rax, rcx\nadd rcx, -2147483648\n")
  (check-equal?
   (generate-x64 `(begin
                    (set! rdx 2)
                    (set! rsi 3)
                    (set! r11 4)
                    (set! rsi (* rsi rdx))
                    (set! r11 (+ r11 -1))
                    (set! r12 (+ r12 r11))
                    (set! rax r12)))
   "mov rdx, 2\nmov rsi, 3\nmov r11, 4\nimul rsi, rdx\nadd r11, -1\nadd r12, r11\nmov rax, r12\n")

  ;; END OF MILESTONE-1 generate-x64 TESTS
  (check-equal? (generate-x64 '(begin
                                 (set! (rbp - 0) 0)
                                 (set! (rbp - 8) 42)
                                 (set! rax (rbp - 0))
                                 (set! rax (+ rax (rbp - 8)))))
                (~a "mov QWORD [rbp - 0], 0"
                    "mov QWORD [rbp - 8], 42"
                    "mov rax, QWORD [rbp - 0]"
                    "add rax, QWORD [rbp - 8]\n"
                    #:separator "\n"))
  (check-equal? (generate-x64 '(begin
                                 (set! (rbp - 0) -1)
                                 (set! (rbp - 8) 42)
                                 (set! rax (rbp - 0))
                                 (set! rax (* rax (rbp - 8)))))
                (~a "mov QWORD [rbp - 0], -1"
                    "mov QWORD [rbp - 8], 42"
                    "mov rax, QWORD [rbp - 0]"
                    "imul rax, QWORD [rbp - 8]\n"
                    #:separator "\n"))

  (check-equal? (generate-x64 `(begin
                                 (set! (rbp - 8) ,(max-int 32))
                                 (set! (rbp - 0) ,(min-int 32))
                                 (set! rax (rbp - 0))
                                 (set! rax (+ rax (rbp - 8)))))
                (~a "mov QWORD [rbp - 8], 2147483647"
                    "mov QWORD [rbp - 0], -2147483648"
                    "mov rax, QWORD [rbp - 0]"
                    "add rax, QWORD [rbp - 8]\n"
                    #:separator "\n")))
