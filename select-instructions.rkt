#lang racket

(require cpsc411/compiler-lib)

(provide select-instructions)

;; (imp-cmf-lang-v5 p) -> (asm-pred-lang-v5 p)
;; Compiles imp-cmf-lang-v5 to asm-pred-lang-v5 by selecting appropriate sequences of abstract
;; assembly instructions to implement the operations of the source language.
(define (select-instructions p)

  ; (imp-cmf-lang-v5 value) -> (List-of (asm-pred-lang-v5 effect)) and (asm-pred-lang-v5 aloc)
  ; Assigns the value v to a fresh temporary, returning two values: the list of
  ; statements that implement the assignment in asm-pred-lang, and the aloc that the
  ; value is stored in.
  (define (assign-tmp v)
    (define tmp (fresh 'tmp))
    (match v
      [`(,binop ,triv1 ,triv2)
       (list (list `(set! ,tmp ,triv1) `(set! ,tmp (,binop ,tmp ,triv2))) tmp)]
      [_ (list (list `(set! ,tmp ,v)) tmp)]))

  (define (select-pred pred)
    (match pred
      [`(not ,pred) `(not ,(select-pred pred))]
      [`(begin
          ,fxs ...
          ,pred)
       (append `(begin) (foldr append '() (map select-effect fxs)) (list (select-pred pred)))]
      [`(if ,pred1 ,pred2 ,pred3)
       `(if ,(select-pred pred1)
            ,(select-pred pred2)
            ,(select-pred pred3))]
      [`(,relop ,triv1 ,triv2)
       #:when (int64? triv1)
       (match-let ([`(,fxs ,aloc) (assign-tmp triv1)])
         `(begin
            ,@fxs
            (,relop ,aloc ,triv2)))]
      [_ pred]))

  ; (imp-cmf-lang-v5 tail) [bool] -> (asm-pred-lang-v5 tail)
  (define (select-tail e [begun #f])
    (match e
      [`(begin
          ,fxs ...
          ,tail)
       (append (if (not begun)
                   '(begin)
                   '())
               (foldr append '() (map select-effect fxs))
               (select-tail tail #t))]
      [`(if ,pred ,tail1 ,tail2)
       (let ([result `(if ,(select-pred pred)
                          ,(select-tail tail1)
                          ,(select-tail tail2))])
         (if (not begun)
             result
             `(,result)))]
      [`(jump ,trg ,loc ...)
       (if begun
           `(,e)
           e)]
      [_
       (match-let ([`(,fxs ,atail) (select-value e)])
         (append (if (not begun)
                     '(begin)
                     '())
                 fxs
                 (list atail)))]))

  ; (imp-cmf-lang-v5 value) -> (list (listof (asm-pred-lang-v5 effect)) (asm-pred-lang-v5 tail))
  (define (select-value e)
    (match e
      [`(,binop ,triv1 ,triv2)
       (match-let ([`(,fxs ,aloc) (assign-tmp e)])
         (list fxs `(halt ,aloc)))]
      [_ `(() (halt ,e))]))

  ; (imp-cmf-lang-v5 value) -> (listof (asm-pred-lang-v5 effect))
  ;; selects appropriate abstract assembly instructions for values in effect position
  (define (value->effect* loc value)
    (match value
      [`(,binop ,opand1 ,opand2)
       #:when (not (equal? opand1 loc))
       `((set! ,loc ,opand1) (set! ,loc (,binop ,loc ,opand2)))]
      [_ `((set! ,loc ,value))]))

  ; (imp-cmf-lang-v5 effect) -> (listof (asm-pred-lang-v5 effect))
  (define (select-effect e)
    (match e
      [`(set! ,loc ,rest) (value->effect* loc rest)]
      [`(begin
          ,fxs ...)
       (list `(begin
                ,@(foldr append '() (map select-effect fxs))))]
      [`(if ,pred ,effect1 ,effect2)
       (define e1 (select-effect effect1))
       (define e2 (select-effect effect2))
       `((if ,(select-pred pred)
             ,(if (null? (rest e1))
                  (first e1)
                  `(begin
                     ,@e1))
             ,(if (null? (rest e2))
                  (first e2)
                  `(begin
                     ,@e2))))]))

  ;; (imp-cmf-lang-v5 definition) -> (imp-cmf-lang-v5 definition)
  (define (select-def def)
    (match def
      [`(define ,label ,tail)
       `(define ,label
          ()
          ,(select-tail tail))]))

  (define (select-p p)
    (match p
      [`(module ,defs ...
          ,tail)
       `(module () ,@(map select-def defs)
          ,(select-tail tail))]))

  (select-p p))
