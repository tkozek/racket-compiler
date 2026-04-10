#lang racket

(require cpsc411/compiler-lib
         cpsc411/2c-run-time)

(require rackunit)

(provide check-paren-x64
        check-paren-x64-syntax
        check-paren-x64-init
         generate-x64
         relop?)

(define-syntax-rule (TODO . stx)
  (error "Unfinished skeleton"))

; Paren-x64 v2:
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

(define registers `(rax rbx rcx rdx rsi rdi r8 r9 r10 r11 r12 r13 r14 r15 rsp rbp))
(define assoc/binops->fun (list (list '+ x64-add) (list '* x64-mul)))
(define binops (map car assoc/binops->fun))

(define (relop? rl)
  (memq rl '(< <= = >= > !=)))

;; symbol -> boolean
;; returns true if bo is a binop, false otherwise
(define (binop? bo)
  (memq bo binops))

;; symbol -> boolean
;; reutrns true if addr is an address, false otherwise
(define (addr? addr)
  (match addr
    [`(,(? frame-base-pointer-register?) - ,(? dispoffset?)) #t]
    [_ #f]))

;; symbol -> boolean
;; returns true if provided symbol is a loc(reg or addr), false otherwise
(define loc? (or/c register? addr?))

;; imperative, do nothing on success
(define check-success (void))

;; Optional; if you choose not to complete, implement a stub that returns the input
;; paren-x64-v2 -> paren-x64-v2
;; Takes valid Paren-x64 v1 syntax, and returns a valid Paren-x64 v1 program
;;     or raises an error with a descriptive error message.
(define (check-paren-x64-init p)
  ;; env is hashtable that maps location to its value
  (define env (make-hash))
  (define (env-set! reg val)
    (hash-set! env reg val))

  ;; location -> int64 or void
  (define (env-get reg)
    (hash-ref env reg (void)))

  ; set is 0, represent that the register is set
  (define set 0)
  ;; any -> boolean
  ;; returns true if val is set, false otherwise
  (define (set? val)
    (equal? val 0))

  ;; loc -> void
  ;; raises error if location is not set
  (define (check-loc-defined loc)
    (if (set? (env-get loc))
        check-success
        (error "location ~a not set" loc)))
  ;; int64 or loc or bin-op -> void
  ;; raises error if op2 is not an int64, a set register, or valid binop expression
  (define (check-paren-x64-init-op2 op2)
    (match op2
      [(? int64? _) check-success]
      [r
       #:when (loc? r)
       (check-loc-defined r)]
      [`(,bin-op ,reg1 ,i32)
       #:when (and (binop? bin-op) (register? reg1) (int32? i32))
       (check-loc-defined reg1)]
      [`(,bin-op ,reg1 ,loc)
       #:when (and (binop? bin-op) (register? reg1) (loc? loc))
       (check-loc-defined reg1)
       (check-loc-defined loc)]))

  ;; paren-x64-v2-s -> void
  ;; raises error if s is not valid paren-x64-v2 set!-expression
  (define (check-paren-x64-init-s s)
    (match s
      [`(set! ,reg ,op2)
       #:when (loc? reg)
       (check-paren-x64-init-op2 op2)
       ; define register on successful validation
       (env-set! reg set)]))

  ;; paren-x64-v2-p -> void
  ;; raises error if p is not valid paren-x64-v2 begin-expression
  (define (check-paren-x64-init-p p)
    (match p
      [`(begin
          ,s ...)
       (for-each check-paren-x64-init-s s)]))

  (check-paren-x64-init-p p)
  p)

;; Optional; if you choose not to complete, implement a stub that returns the input
;; any -> paren-x64-v4
;; Takes an arbitrary value and either returns it, if it is valid Paren-x64 v1 syntax,
;;     or raises an error with a descriptive error message.
(define (check-paren-x64-syntax p)
  ;; any addr -> void
  ;; raises error if op2 is not valid second op for set! given that op1 is an addr
  (define (check-paren-x64-syntax-op2/addr op2 addr)
    (match op2
      [(? int32?) check-success]
      [(? int64?) (error "address assignment only allow int32, given int64: ~a" op2)]
      [(? register?) check-success]
      [`(,(? binop?) ,_ ,_) (error "binop not allowed for memory address")]
      [_ (error (format "invalid operation: ~a for address: ~a" op2 addr))]))
  ;; any register -> void
  ;; raises error if op2 is not valid syntax for second parameter of a set!-expression
  (define (check-paren-x64-syntax-op2/reg op2 reg)
    (match op2
      [(? int64?) check-success]
      [(? loc?) check-success]
      [`(,bin-op ,reg1 ,i32)
       #:when (and (binop? bin-op) (register? reg1) (equal? reg reg1) (int32? i32))
       check-success]
      [`(,bin-op ,reg1 ,loc)
       #:when (and (binop? bin-op) (equal? reg reg1) (register? reg1) (loc? loc))
       check-success]
      [`(,bin-op ,op1 ,_)
       #:when (binop? bin-op)
       (error (format "unknown oprand ~a, expected ~a" op1 reg))]
      [x
       (error (format "unexpected symbol ~a, expected a int64, register or a bin-op expression" x))]))
  ;; any loc -> void
  ;; raises error if op2 is not valid syntax for the second paramter of a set!
  ;;    given location
  (define (check-paren-x64-syntax-op2 op2 loc)
    (match loc
      [(? addr?) (check-paren-x64-syntax-op2/addr op2 loc)]
      [(? register?) (check-paren-x64-syntax-op2/reg op2 loc)]))
  ;; any -> void
  ;; raises error if s is not a valid syntax for a set!-expression
  ;; uses match to progressively check for violations for "descriptive" error message
  (define (check-paren-x64-syntax-s s)
    (match s
      [`(set! ,loc ,op2)
       #:when (loc? loc)
       (check-paren-x64-syntax-op2 op2 loc)]
      [`(set! ,op1 ,_)
       (error (format "unknown oprand ~a, expected a location(symbol in '~a)" op1 registers))]
      [`(with-label ,(? label?) ,s) (check-paren-x64-syntax-s s)]
      [`(jump ,(? (or/c register? label?))) (void)]
      [`(compare ,(? register?) ,(? (or/c register? int64?))) (void)]
      [`(jump-if ,(? relop?) ,(? label?)) (void)]
      [x (error (format "unexpected symbol ~a, expected a paren-x64-s expression" x))]))
  ;; any -> void
  ;; raises an error if p is not valid syntax for begin-expression.
  (define (check-paren-x64-syntax-p p)
    (match p
      [`(begin
          ,s ...)
       (for-each check-paren-x64-syntax-s s)]
      [x (error "no begin expression: ~a" x)]))

  (check-paren-x64-syntax-p p)
  p)

(define (check-paren-x64 p)
  (check-paren-x64-init (check-paren-x64-syntax p)))

;; paren-x64-v4 -> x64-instruction-sequence
;; Compiles a Paren-x64 v4 program into a x64 instruction sequence represented as a string.
(define (generate-x64 p)

  ;; paren-x64-v4-p -> x64-instruction-sequence
  ;; Compiles a Paren-x64 v4 begin-expression into a x64 instruction sequence represented as a string.
  (define (program->x64 p)
    (match p
      [`(begin
          ,s* ...)
       (string-join (map statement->x64 s*) "")]))

  ;; paren-x64-v4-loc -> x64-instruction-sequence
  (define (loc->ins loc)
    (match loc
      [(? register?) (~a loc)]
      [(? addr?)
       (match-let ([`(,reg - ,off) loc])
         (format "QWORD [~a - ~a]" reg off))]))
  ;; (or paren-x64-v2-loc int64) -> x64-instruction-sequence
  (define (val->ins val)
    (match val
      [(? int64?) val]
      [(? label?) (~a val)]
      [_ (loc->ins val)]))

  ;; paren-x64-v4-trg -> x64-instruction-sequence
  (define (trg->ins trg)
    (match trg
      [(? register?) (~a trg)]
      [(? label?) (~a trg)]))

  (define (opand->ins opand)
    (match opand
      [(? int64?) opand]
      [_ (~a opand)]))

  ;; paren-x64-v4-s -> x64-instruction-sequence
  ;; Compiles a Paren-x64 v4 set!-expression into a x64 instruction sequence represented as a string.
  (define (statement->x64 s)
    (match s
      [`(set! ,reg1 (,binop ,reg1 ,val))
       (format "~a ~a, ~a\n" (binop->ins binop) reg1 (val->ins val))]
      [`(set! ,loc ,label)
       #:when (label? label)
       (format "lea ~a, [rel ~a]\n" (loc->ins loc) label)]
      [`(set! ,loc ,val) (format "mov ~a, ~a\n" (loc->ins loc) (val->ins val))]
      [`(with-label ,l ,s) (format "~a:\n~a" l (statement->x64 s))]
      [`(jump ,trg) (format "jmp ~a\n" (trg->ins trg))]
      [`(compare ,reg ,opand) (format "cmp ~a, ~a\n" reg (opand->ins opand))]
      [`(jump-if ,relop ,l) (format "~a ~a\n" (relop->ins relop) l)]))

  (define (relop->ins relop)
    (match relop
      [`< "jl"]
      [`<= "jle"]
      [`= "je"]
      [`>= "jge"]
      [`> "jg"]
      [`!= "jne"]))

  ;; binop-> x64-instruction
  ;; returns the corresponding x64 operator for the given binop
  (define (binop->ins b)
    (match b
      ['+ "add"]
      ['* "imul"]))
  (program->x64 p #;(check-paren-x64 p)))

;; string -> string
;; Installs the Paren-x64 v1 run-time system. The input is the same as the output for generate-x64:
;;     a string representing an x64 instruction sequence. The run-time system is composed with the
;;     input as a second instruction sequence.
; (define (wrap-x64-run-time str)
;   (define runtime-sys
;     #<<EOS
;   mov rdi, rax
; EOS
;     )
;   (~a str runtime-sys #:separator "\n"))

;; x64-instruction-sequence -> string
;; Takes an x64 instruction sequence and wraps it with the necessary boilerplate to
;;     return a complete x64 program in Intel syntax.
; (define (wrap-x64-boilerplate str)
;   (define start
;     #<<EOS
; global start

; section .text
; start:
; mov rbx, .data

; EOS
;     )

;   (define exit
;     #<<EOS
; exit:
;   mov rax, 60
;   ;mov rax, 0x200001
;   syscall

; section .data
; dummy:   db 0
; EOS
;     )
;   (~a start str exit #:separator "\n"))
