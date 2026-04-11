#lang racket

(require cpsc411/compiler-lib
         cpsc411/langs/v2
         "../util.rkt")

(provide select-instructions)

;; (imp-cmf-lang-v3) -> (asm-lang-v2)
;; Selects appropriate sequences of abstract assembly instructions to implement ops of src lang
(define (select-instructions p)

  ; (imp-cmf-lang-v3 value) -> (values '(asm-lang-v2 effect) (asm-lang-v2 aloc))
  ; Assigns the value v to a fresh temporary, returning two values: the list of
  ; statements that implement the assignment in asm-lang, and the aloc that the
  ; value is stored in.
  (define (assign-tmp v)
    (define tmp (fresh))
    (match v
      [`(,binop ,triv1 ,triv2)
       (values (list `(set! ,tmp ,triv1) `(set! ,tmp (,binop ,tmp ,triv2))) tmp)]))

  (define (select-tail e)
    (match e
      [`(begin
          ,effects ...
          ,tail)
       `(begin
          ,@(append-map select-effect effects)
          ,(select-tail tail))]
      [`(,binop ,triv1 ,triv2)
       (define-values (insts tmp) (assign-tmp e))
       `(begin
          ,@insts
          (halt ,tmp))]
      [_ `(halt ,e)]))

  (define (select-effect e)
    (match e
      [`(set! ,aloc (,binop ,aloc ,triv)) (list e)]
      [`(set! ,aloc (,binop ,triv1 ,triv2))
       (define-values (insts tmp) (assign-tmp `(,binop ,triv1 ,triv2)))
       (append insts (list `(set! ,aloc ,tmp)))]
      [`(set! ,aloc ,triv) (list e)]
      [`(begin
          ,effects ...)
       (list `(begin
                ,@(append-map select-effect effects)))]))

  (define (select-p p)
    (match p
      [`(module ,tail)
       `(module () ,(select-tail tail)
          )]))
  (select-p p))


