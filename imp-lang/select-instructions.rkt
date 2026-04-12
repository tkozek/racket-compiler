#lang racket

(require cpsc411/compiler-lib
         cpsc411/langs/v2
         "../util.rkt")

(provide select-instructions)

;; (imp-cmf-lang-v3) -> (asm-lang-v2)
;; Selects appropriate sequences of abstract assembly instructions to implement the operations
;; of the source language
(define (select-instructions p)

  ; Assigns value to a fresh temporary, returning two values: the list of
  ; statements that implement the assignment in asm-lang, and the aloc that the
  ; value is stored in
  ; (imp-cmf-lang-v3 value) -> (values '(asm-lang-v2 effect) (asm-lang-v2 aloc))
  (define (select-non-triv-value value)
    (define tmp (fresh))
    (match value
      [`(,binop ,triv1 ,triv2)
       (values (list `(set! ,tmp ,triv1) `(set! ,tmp (,binop ,tmp ,triv2))) tmp)]))

  ;; (imp-cmf-lang-v3 value) -> (asm-lang-v2 tail)
  (define (select-value/tail value)
    (match value
      [`(,binop ,triv1 ,triv2)
       #:when (binop? binop)
       (define-values (insts tmp) (select-non-triv-value value))
       `(begin
          ,@insts
          (halt ,tmp))]
      [_ `(halt ,value)]))

  ;; ((imp-cmf-lang-v3 value) aloc) -> (list of (asm-lang-v2 effect))
  (define (select-value/effect value aloc)
    (match value
      [`(,binop ,triv1 ,triv2)
       #:when (equal? triv1 aloc)
       (list `(set! ,aloc (,binop ,aloc ,triv2)))]
      [`(,binop ,triv1 ,triv2)
       (define-values (insts tmp) (select-non-triv-value value))
       (append insts (list `(set! ,aloc ,tmp)))]
      [triv (list `(set! ,aloc ,triv))]))

  ;; (imp-cmf-lang-v3 tail) -> (asm-lang-v2 tail)
  (define (select-tail e)
    (match e
      [`(begin
          ,effects ...
          ,tail)
       `(begin
          ,@(append-map select-effect effects)
          ,(select-tail tail))]
      [_ (select-value/tail e)]))

  ;; (imp-cmf-lang-v3 effect) -> (list of (asm-lang-v2 effect))
  (define (select-effect e)
    (match e
      [`(set! ,aloc ,value) (select-value/effect value aloc)]
      [`(begin
          ,effects ...)
       (list `(begin
                ,@(append-map select-effect effects)))]))

  ;; (imp-cmf-lang-v3 p) -> (asm-lang-v2 p)
  (define (select-p p)
    (match p
      [`(module ,tail)
       `(module () ,(select-tail tail)
          )]))

  (select-p p))
