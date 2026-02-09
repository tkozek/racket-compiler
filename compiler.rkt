#lang racket

(require
 cpsc411/compiler-lib)

(provide
 check-paren-x64
 interp-paren-x64
 generate-x64
 wrap-x64-run-time
 wrap-x64-boilerplate)

(define-syntax-rule (TODO . stx)
  (error "Unfinished skeleton"))

(define (paren-x64-s? s)
  (match s
    [`(set! ,reg ,int64)
     (cond
	[(not (register? reg))
	(error 'paren-x64-s? "Expected register for set!, got ~a" reg)]
	[(not (int64? int64))
	(error 'paren-x64-s? "Expected int64 for set!, got ~a" int64)]
	[else #t])]
    [`(set! ,reg1 ,reg2)
     (cond 
       [(not (and (register? reg1) (register? reg2)))
	    (error 'paren-x64-s? "Expected two registers for set!, got ~a and ~a" reg1 reg2)]
       [else #t])]
    [`(set! ,reg1 (,binop ,reg1 ,int32))
     (cond
       [(not (register? reg1))
	    (error 'paren-x64-s? "Expected a register for reg1, got ~a" reg1)]
	[(not (paren-x64-binop? binop))
      	(error 'paren-x64-s? "Expected one of + or *, got ~a" binop)]
	[(not (int32? int32))
      	(error 'paren-x64-s? "Expected an int32, got ~a" int32)]
	[else #t])]
    [`(set! ,reg1 (,binop ,reg1 ,reg))
     (cond 
       [(not (register? reg1))
	    (error 'paren-x64-s? "Expected a register, got ~a" reg1)]

       [(not (paren-x64-binop? binop))
	    (error 'paren-x64-s? "Expected one of + or *, got ~a" binop)]

       [(not (register? reg))
	    (error 'paren-x64-s? "Expected a register, got ~a" reg)]
      [else #t])]
	[_ (error 'paren-x64-s? "Unrecognized statement ~a" s)]))


(define (register? r)
  (and
   (member r '(rsp rbp rax rbx rcx rdx rsi rdi r8 r9 r10 r11 r12 r13 r14 r15))
	#t)) 

(define (paren-x64-binop? op)
  (and 
     (member op '(* +)) 
     #t))



;; Optional; if you choose not to complete, implement a stub that returns the input
(define (check-paren-x64-init p)
  (p))

;; Optional; if you choose not to complete, implement a stub that returns the input
(define (check-paren-x64-syntax p)
  (define process-p p)
  (match p
    [`(begin ,s ...)
     (paren-x64-s? s)])
  (process-p p))

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

(define (generate-x64 p)
  ; Paren-x64-v1 -> x64-instruction-sequence
  (define (program->x64 p)
    (match p
      [`(begin ,s ...)
       (string-join (map statement->x64 s) "\n")]))

  (define (statement->x64 s)
    (match s
        [`(set! ,reg1 (,op ,reg1 ,reg))
            #:when (register? reg) ;; do i only need to check this part to disambiguate?
            (format "~a ~a, ~a\n" (binop->ins op) reg1 reg)]
        [`(set! ,reg1 (,op ,reg1 ,val))
            (format "~a ~a, ~a\n" (binop->ins op) reg1 reg)]
        [`(set! ,reg1 ,reg2)
            #:when (register? reg2)
            (format "mov ~a, ~a\n" reg1 reg2)]
        [`(set! ,reg ,val)
            (format "mov ~a, ~a\n" reg1 val)]
            ))

  (define (binop->ins op)
    (match op
        ['+ "add"]
        ['* "imul"]
        [_ (error (format "Invalid binop"))]))

  (program->x64 p))

(define (wrap-x64-run-time str)
  (TODO ...))

(define (wrap-x64-boilerplate str)
  (TODO ...))

(module+ test
  (require
   rackunit
   rackunit/text-ui
   cpsc411/langs/v1
   cpsc411/test-suite/public/v1)

  (run-tests
   (v1-public-test-suite
    (list
     check-paren-x64
     generate-x64
     wrap-x64-run-time
     wrap-x64-boilerplate)
    (list
     interp-paren-x64-v1
     interp-paren-x64-v1
     #f
     #f)
    check-paren-x64
    interp-paren-x64)))
