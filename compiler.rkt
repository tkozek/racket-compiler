#lang racket

(require cpsc411/compiler-lib)

(provide check-paren-x64
         interp-paren-x64
         generate-x64
         wrap-x64-run-time
         wrap-x64-boilerplate)

;; Paren-x64-v1 grammar:
;   p	 	::=	 	(begin s ...)

;   s	 	::=	 	(set! reg int64)
;  	 	|	 	(set! reg reg)
;  	 	|	 	(set! reg_1 (binop reg_1 int32))
;  	 	|	 	(set! reg_1 (binop reg_1 reg))

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

;   binop	 	::=	 	*
;  	 	|	 	+

;   int64	 	::=	 	int64?

;   int32	 	::=	 	int32?

(define-syntax-rule (TODO . stx)
  (error "Unfinished skeleton"))

(define (register? r)
  (and (member r '(rsp rbp rax rbx rcx rdx rsi rdi r8 r9 r10 r11 r12 r13 r14 r15)) #t))

(define (paren-x64-binop? op)
  (and (member op '(* +)) #t))

;; Optional; if you choose not to complete, implement a stub that returns the input
(define (check-paren-x64-init p)
  p)

;; Optional; if you choose not to complete, implement a stub that returns the input
(define (check-paren-x64-syntax p)
  p)

(define (check-paren-x64 p)
  (check-paren-x64-init (check-paren-x64-syntax p)))

;; Optional; if you choose not to complete, implement a stub that returns a valid exit code
(define (interp-paren-x64 p)
  (define (eval-instruction-sequence regfile s)
    (if (empty? s)
        ; If no more instructions, return exit code modulo 256 (since operating
        ; systems return exit code modulo 256).
        (modulo (dict-ref regfile 'rax) 256)
        0))
  0)

;; (paren-x64-v1 p) -> x64-instruction-sequence
;; Compiles a Paren-x64 v1 program into x64 instruction sequence, represented as a string
(define (generate-x64 p)
  ; (paren-x64-v1 p) -> x64-instruction-sequence
  (define (program->x64 p)
    (match p
      [`(begin
          ,s ...)
       (string-join (map statement->x64 s) "")]))

  ; (paren-x64-v1 s) -> x64-instruction-sequence
  (define (statement->x64 s)
    (match s
      [`(set! ,reg1 (,op ,reg1 ,val))
       (format "~a ~a, ~a\n" (binop->ins op) reg1 val)] ;; val can be int32 or reg
      [`(set! ,reg ,val) (format "mov ~a, ~a\n" reg val)])) ;; val can be int32 or reg

  (define (binop->ins op)
    (match op
      ['+ "add"]
      ['* "imul"]))

  (program->x64 p))

;; Rum-time system for paren-x64-v1
(define run-time-exit (string-append "mov rdi, rax\n" "mov rax, 60\n"))

;; x64-instruction-sequence -> x64-instruction-sequence
;; Installs the paren-x64-v1 run-time system by appending it to input sequence
(define (wrap-x64-run-time str)
  (string-append str run-time-exit))

(define (wrap-x64-boilerplate str)
  (TODO ...))

(module+ test
  (require rackunit
           rackunit/text-ui
           cpsc411/langs/v1
           cpsc411/test-suite/public/v1)

  (run-tests (v1-public-test-suite
              (list check-paren-x64 generate-x64 wrap-x64-run-time wrap-x64-boilerplate)
              (list interp-paren-x64-v1 interp-paren-x64-v1 #f #f)
              check-paren-x64
              interp-paren-x64)))
(module+ test
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
   "mov rdx, 2\nmov rsi, 3\nmov r11, 4\nimul rsi, rdx\nadd r11, -1\nadd r12, r11\nmov rax, r12\n"))

(module+ test

  (check-equal? (wrap-x64-run-time (generate-x64 `(begin
                                                    (set! rax 0))))
                (string-append (generate-x64 `(begin
                                                (set! rax 0)))
                               run-time-exit))

  (check-equal? (wrap-x64-run-time (generate-x64 `(begin
                                                    (set! rax 0)
                                                    (set! rax (+ rax 42)))))
                (string-append (generate-x64 `(begin
                                                (set! rax 0)
                                                (set! rax (+ rax 42))))
                               run-time-exit))

  (check-equal? (wrap-x64-run-time (generate-x64 `(begin
                                                    (set! rax ,(max-int 64))
                                                    (set! rdi ,(min-int 64))
                                                    (set! rdi rax))))
                (string-append (generate-x64 `(begin
                                                (set! rax ,(max-int 64))
                                                (set! rdi ,(min-int 64))
                                                (set! rdi rax)))
                               run-time-exit))

  (check-equal? (wrap-x64-run-time (generate-x64 `(begin
                                                    (set! rax ,(max-int 64))
                                                    (set! rdi ,(min-int 64))
                                                    (set! rdi (+ rdi rax)))))
                (string-append (generate-x64 `(begin
                                                (set! rax ,(max-int 64))
                                                (set! rdi ,(min-int 64))
                                                (set! rdi (+ rdi rax))))
                               run-time-exit))

  (check-equal? (wrap-x64-run-time (generate-x64 `(begin
                                                    (set! rax 3)
                                                    (set! rdi 2)
                                                    (set! rdi (* rdi rax)))))
                (string-append (generate-x64 `(begin
                                                (set! rax 3)
                                                (set! rdi 2)
                                                (set! rdi (* rdi rax))))
                               run-time-exit))

  (check-equal? (wrap-x64-run-time (generate-x64 `(begin
                                                    (set! rax -1)
                                                    (set! rbx -1)
                                                    (set! rbx (+ rbx ,(max-int 32))))))
                (string-append (generate-x64 `(begin
                                                (set! rax -1)
                                                (set! rbx -1)
                                                (set! rbx (+ rbx ,(max-int 32)))))
                               run-time-exit))

  (check-equal? (wrap-x64-run-time (generate-x64 `(begin
                                                    (set! rcx -1)
                                                    (set! rax rcx)
                                                    (set! rcx (+ rcx ,(min-int 32))))))
                (string-append (generate-x64 `(begin
                                                (set! rcx -1)
                                                (set! rax rcx)
                                                (set! rcx (+ rcx ,(min-int 32)))))
                               run-time-exit))

  (check-equal? (wrap-x64-run-time (generate-x64 `(begin
                                                    (set! rdx 2)
                                                    (set! rsi 3)
                                                    (set! r11 4)
                                                    (set! rsi (* rsi rdx))
                                                    (set! r11 (+ r11 -1))
                                                    (set! r12 (+ r12 r11))
                                                    (set! rax r12))))
                (string-append (generate-x64 `(begin
                                                (set! rdx 2)
                                                (set! rsi 3)
                                                (set! r11 4)
                                                (set! rsi (* rsi rdx))
                                                (set! r11 (+ r11 -1))
                                                (set! r12 (+ r12 r11))
                                                (set! rax r12)))
                               run-time-exit)))
