#lang racket

(require cpsc411/compiler-lib
         "../util.rkt")

(provide select-instructions)

;; (imp-cmf-lang-v3) -> (asm-lang-v2)
;; Selects appropriate sequences of abstract assembly instructions to implement ops of src lang
(define (select-instructions p)
  ; (Imp-cmf-lang-v3 value) -> (List-of (Asm-lang-v2 effect)) and (Asm-lang-v2 aloc)
  ; Assigns the value v to a fresh temporary, returning two values: the list of
  ; statements the implement the assignment in Loc-lang, and the aloc that the
  ; value is stored in.
  (define (assign-tmp v)
    (define tmp (fresh))
    (match v
      [`(,op ,triv1 ,triv2)
       (if (and (binop? op) (triv? triv1) (triv? triv2))
           (values (list `(set! ,tmp ,triv1) `(set! ,tmp (,op ,tmp ,triv2)))
                   tmp) ;; values returns all its args
           (error
            (format "Expected op and two trivial values, got: ~a, ~a and ~a" op triv1 triv2)))]))

  (define (select-tail e)
    (match e
      [(? triv?) `(halt ,e)]
      [`(,op ,triv1 ,triv2)
       (define-values (insts tmp) (select-value e))
       `(begin
          ,@insts
          (halt ,tmp))]
      [`(begin
          ,effects
          ,body)
       `(begin
          ,@(map select-effect effects)
          ,(select-tail body))]))

  (define (select-value e)
    (match e
      [(? triv?) (values '() e)]
      [`(,op ,triv1 ,triv2)
       (if (and (binop? op) (triv? triv1) (triv? triv2))
           (assign-tmp e)
           (error (format "Expected binop and two trivs, got: ~a, ~a, ~a" op triv1 triv2)))]))

  (define (select-effect e)
    (match e
      [`(set! ,aloc ,v)
       (define-values (insts tmp) (select-value v))
       `(begin
          ,@insts
          (set! ,aloc ,tmp))]
      [`(begin
          ,rest ...
          ,last)
       `(begin
          ,@(map select-effect rest)
          ,(select-effect last))]))

  (match p
    [`(module ,tail)
     `(module () ,(select-tail tail)
        )]))

(module+ test
  (require rackunit
           cpsc411/langs/v2
           cpsc411/langs/v3)
  (define-syntax-rule (check-by-interp p)
    (check-equal? (interp-imp-cmf-lang-v3 p) (interp-asm-lang-v2 (select-instructions p)))))
