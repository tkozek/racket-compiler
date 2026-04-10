#lang racket

(require cpsc411/compiler-lib)
(provide resolve-predicates)

;;
;   p	 	::=	 	(module b ... b)

;   b	 	::=	 	(define label tail)

;   pred	 	::=	 	(relop loc opand)
;  	 	|	 	(true)
;  	 	|	 	(false)
;  	 	|	 	(not pred)

;   tail	 	::=	 	(halt opand)
;  	 	|	 	(jump trg)
;  	 	|	 	(begin effect ... tail)
;  	 	|	 	(if -pred +(relop loc opand) (jump trg) (jump trg))

;   effect	 	::=	 	(set! loc triv)
;  	 	|	 	(set! loc_1 (binop loc_1 opand))

;   opand	 	::=	 	int64
;  	 	|	 	loc

;   loc	 	::=	 	reg
;  	 	|	 	fvar
;; block-pred-lang-v4 ->  block-asm-lang-v4
;; Compile the Block-pred-lang v4 to Block-asm-lang v4 by manipulating the branches of
;; if statements to resolve branches.
(define (resolve-predicates p)
  (match p
    [`(module ,b* ...
        ,b)
     `(module ,@(map resolve-b b*) ,(resolve-b b)
        )]))
(define (resolve-pred pred truecase falsecase)
  (match pred
    [`(,_ ,_ ,_) `(if ,pred ,truecase ,falsecase)]
    [`(true) truecase]
    [`(false) falsecase]
    [`(not ,pred) (resolve-pred pred falsecase truecase)]))
(define (resolve-tail tail)
  (match tail
    [`(halt ,_) tail]
    [`(jump ,_) tail]
    [`(begin
        ,fx* ...
        ,tail)
     `(begin
        ,@fx*
        ,(resolve-tail tail))]
    [`(if ,pred
          (jump ,trg1)
          (jump ,trg2))
     (resolve-pred pred `(jump ,trg1) `(jump ,trg2))]))
(define (resolve-b b)
  (match b
    [`(define ,(? label? label)
        ,tail)
     `(define ,label ,(resolve-tail tail))]))
