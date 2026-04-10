#lang racket

(require cpsc411/compiler-lib)
(provide uncover-locals)

;; redesigning to pass around locals instead of using global mutable state
#;(define (uncover-locals al2)
    ; (displayln "running uncover-locals")
    (define locals '())
    (define (uncover-aloc aloc)
      (set! locals (set-union locals `(,aloc)))
      aloc)
    (define (uncover-triv triv)
      (match triv
        [(? int64?) triv]
        [(? aloc?) (uncover-aloc triv)]))
    (define (uncover-pred pred)
      (match pred
        [`(,relop ,aloc ,triv)
         #:when (memq relop '(< <= = >= > !=))
         `(,relop ,(uncover-aloc aloc) ,(uncover-triv triv))]
        [`(true) pred]
        [`(false) pred]
        [`(not ,pred) `(not ,(uncover-pred pred))]
        [`(begin
            ,fxs ...
            ,pred)
         (append '(begin) (map uncover-effect fxs) (list (uncover-pred pred)))]
        [`(if ,pred1 ,pred2 ,pred3)
         `(if ,(uncover-pred pred1)
              ,(uncover-pred pred2)
              ,(uncover-pred pred3))]))

    (define (uncover-effect effect)
      (match effect
        [`(set! ,aloc (,binop ,aloc ,triv))
         `(set! ,(uncover-aloc aloc) (,binop ,aloc ,(uncover-triv triv)))]
        [`(set! ,aloc ,triv) `(set! ,(uncover-aloc aloc) ,(uncover-triv triv))]
        [`(begin
            ,fxs ...
            ,fx)
         (append '(begin) (map uncover-effect fxs) (list (uncover-effect fx)))]
        [`(if ,pred ,effect1 ,effect2)
         `(if ,(uncover-pred pred)
              ,(uncover-effect effect1)
              ,(uncover-effect effect2))]))
    (define (uncover-tail tail)
      (match tail
        [`(begin
            ,fxs ...
            ,tail)
         (append '(begin) (map uncover-effect fxs) (list (uncover-tail tail)))]
        [`(halt ,triv) `(halt ,(uncover-triv triv))]
        [`(if ,pred ,tail1 ,tail2)
         `(if ,(uncover-pred pred)
              ,(uncover-tail tail1)
              ,(uncover-tail tail2))]))
    (define (uncover-p p)
      (match p
        [`(module ,info ,definitions
            ...
            ,tail)

         (let ([utail (uncover-tail tail)])
           `(module ,(info-set info 'locals locals) ,utail
              ))]))
    (uncover-p al2))

;; asm-pred-lang-v5 p -> asm-pred-lang-v5/locals p
;; Compiles Asm-pred-lang v5 to Asm-pred-lang v5/locals,
;; analysing which abstract locations are used in each block,
;; and updating each block and the module with the set of variables
;; in an info? fields.
(define (uncover-locals p)

  (define (uncover-defintiions def)
    (match def
      [`(define ,label
          ,info
          ,tail)
       `(define ,label
          ,(info-set info 'locals (set->list (uncover-tail tail)))
          ,tail)]))

  (define (uncover-triv triv)
    (match triv
      [(? (or/c int64? register? fvar?)) (set)]
      [(? aloc?) (set triv)]))

  (define (uncover-loc loc)
    (match loc
      [(? aloc?) (set loc)]
      [_ (set)]))

  (define (uncover-pred pred)
    (match pred
      [`(,relop ,loc ,triv)
       #:when (memq relop '(< <= = >= > !=))
       (set-union (uncover-loc loc) (uncover-triv triv))]
      [`(true) (set)]
      [`(false) (set)]
      [`(not ,p) (uncover-pred p)]
      [`(begin
          ,fxs ...
          ,p)
       (set-union (uncover-effects fxs) (uncover-pred p))]
      [`(if ,p1 ,p2 ,p3) (set-union (uncover-pred p1) (uncover-pred p2) (uncover-pred p3))]))

  (define (uncover-effect effect)
    (match effect
      [`(set! ,loc (,binop ,loc ,triv)) (set-union (uncover-loc loc) (uncover-triv triv))]
      [`(set! ,loc ,triv) (set-union (uncover-loc loc) (uncover-triv triv))]
      [`(begin
          ,fxs ...
          ,fx)
       (set-union (uncover-effects fxs) (uncover-effect fx))]
      [`(if ,pred ,e1 ,e2) (set-union (uncover-pred pred) (uncover-effect e1) (uncover-effect e2))]))

  (define (uncover-effects fxs)
    (for/fold ([locals (set)]) ([fx fxs])
      (set-union locals (uncover-effect fx))))

  (define (uncover-tail tail)
    (match tail
      [`(begin
          ,fxs ...
          ,t)
       (set-union (uncover-effects fxs) (uncover-tail t))]
      [`(halt ,triv) (uncover-triv triv)]
      [`(if ,pred ,t1 ,t2) (set-union (uncover-pred pred) (uncover-tail t1) (uncover-tail t2))]
      [`(jump ,trg ,loc ...) (foldr (lambda (cur acc) (set-union (uncover-loc cur) acc)) (set) loc)]))

  (define (uncover-p p)
    (match p
      [`(module ,info ,definitions
          ...
          ,tail)
       `(module ,(info-set info 'locals (set->list (uncover-tail tail)))
                ,@(map uncover-defintiions definitions)
          ,tail)]))
  (uncover-p p))
