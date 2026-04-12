#lang racket

(require cpsc411/compiler-lib
         cpsc411/ptr-run-time
         "common.rkt")

(provide generate-x64)

;; (Paren-x64-v8 p)-> x64-instruction-sequence
;; Compiles a Paren-x64 v8 program into a x64 instruction sequence represented as a string.
(define (generate-x64 p)

  ;; paren-x64-v8-p -> x64-instruction-sequence
  ;; Compiles a Paren-x64-v8 begin-expression into a x64 instruction sequence represented as a string.
  (define (program->x64 p)
    (match p
      [`(begin
          ,s* ...)
       (string-join (map statement->x64 s*) "")]))

  ;; paren-x64-v8-loc -> x64-instruction-sequence
  (define (loc->ins loc)
    (match loc
      [(? register?) (~a loc)]
      [`(,(? frame-base-pointer-register? fbp) - ,(? dispoffset? offset))
       (format "QWORD [~a - ~a]" fbp offset)]
      [`(,(? register? reg) + ,offset) (format "QWORD [~a + ~a]" reg offset)]))

  ;; (or paren-x64-v8-loc int64) -> x64-instruction-sequence
  (define (val->ins val)
    (match val
      [(? int64?) val]
      [(? label?) (~a (sanitize-label val))]
      [_ (loc->ins val)]))

  ;; paren-x64-v8-trg -> x64-instruction-sequence
  (define (trg->ins trg)
    (match trg
      [(? register?) (~a trg)]
      [(? label?) (~a (sanitize-label trg))]))

  ;; I think the use of this function is redundant (was used in the compare case of statement->x64)
  ;   (define (opand->ins opand)
  ;     (match opand
  ;       [(? int64?) opand]
  ;       [_ (~a opand)]))

  ;; paren-x64-v8-s -> x64-instruction-sequence
  ;; Compiles a Paren-x64 v4 set!-expression into a x64 instruction sequence represented as a string.
  (define (statement->x64 s)
    (match s
      [`(set! ,reg1 (,binop ,reg1 ,val))
       (format "~a ~a, ~a\n" (binop->ins binop) reg1 (val->ins val))]
      [`(set! ,loc ,label)
       #:when (label? label)
       (format "lea ~a, [rel ~a]\n" (loc->ins loc) (sanitize-label label))]
      [`(set! ,loc ,val) (format "mov ~a, ~a\n" (loc->ins loc) (val->ins val))]
      [`(with-label ,l ,s) (format "~a:\n~a\n" (sanitize-label l) (statement->x64 s))]
      [`(jump ,trg) (format "jmp ~a\n" (trg->ins trg))]
      [`(compare ,reg ,opand) (format "cmp ~a, ~a\n" reg opand)]
      [`(jump-if ,relop ,l) (format "~a ~a\n" (relop->ins relop) (sanitize-label l))]))

  (define (relop->ins relop)
    (match relop
      [`< "jl"]
      [`<= "jle"]
      [`= "je"]
      [`>= "jge"]
      [`> "jg"]
      [`!= "jne"]))

  ;; (paren-x64-v8 binop)-> x64-instruction
  ;; returns the corresponding x64 operator for the given binop
  (define (binop->ins b)
    (match b
      ['+ "add"]
      ['* "imul"]
      ['- "sub"]
      ['bitwise-and "and"]
      ['bitwise-ior "or"]
      ['bitwise-xor "xor"]
      ['arithmetic-shift-right "sar"]))
  (program->x64 p))
