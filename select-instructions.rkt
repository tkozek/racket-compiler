#lang racket

(require cpsc411/compiler-lib)

(provide select-instructions)

;; (Imp-cmf-lang-v8 p) -> (Asm-alloc-lang-v8 p)
;; Selects appropriate sequences of abstract assembly instructions to implement
;; the operations of the source language.
(define (select-instructions p)

  ; (imp-cmf-lang-v8 opand) -> (List-of (asm-alloc-lang-v8 effect)) and (asm-alloc-lang-v8 aloc)
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

  ; (imp-cmf-lang-v8 tail) [bool] -> (asm-alloc-lang-v8 tail)
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
           e)]))

  ; (imp-cmf-lang-v8 value) -> (listof (asm-alloc-lang-v8 effect))
  ;; selects appropriate abstract assembly instructions for values in effect position
  (define (value->effect* loc value)
    (match value

      [`(,binop ,opand1 ,opand2)
       #:when (not (equal? opand1 loc))
       `((set! ,loc ,opand1) (set! ,loc (,binop ,loc ,opand2)))]
      ;;[`(alloc ,opand)] opand in src is same as index in target
      ;; likewise with the [`(mref ,loc ,opand)] case, and this loc doesnt have to match the loc
      ;; first loc in hte generated set!
      [_ `((set! ,loc ,value))]))

  ; (imp-cmf-lang-v8 effect) -> (listof (asm-alloc-lang-v8 effect))
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
                     ,@e2))))]
      [`(return-point ,label ,tail) `((return-point ,label ,(select-tail tail)))]
      [`(mset! ,loc ,opand ,triv) `(,e)]))

  ;; (imp-cmf-lang-v8 definition) -> (asm-alloc-lang-v8 definition)
  (define (select-def def)
    (match def
      [`(define ,label
          ,info
          ,tail)
       `(define ,label
          ,info
          ,(select-tail tail))]))

  (define (select-p p)
    (match p
      [`(module ,info ,defs
          ...
          ,tail)
       `(module ,info ,@(map select-def defs)
          ,(select-tail tail))]))

  (select-p p))

(module+ test
  (require rackunit
           cpsc411/langs/v8
           cpsc411/test-suite/public/v8
           cpsc411/compiler-lib)
  (define-syntax-rule (check-by-interp p)
    (check-equal? p p))
  (v8-public-test-suite '(select-instructions) '(interp-imp-cmf-lang-v8))

  ;   (check-match (select-instructions '(module ((new-frames ()))
  ;                         (begin (set! ))
  ;                 ))
  ;                 `(module ((new-frames ()))
  ;                     )

  ;   )
  )
