#lang racket

(require cpsc411/compiler-lib)
(provide resolve-predicates)

;; block-pred-lang-v6 ->  block-asm-lang-v6
;; Compile the Block-pred-lang v6 to Block-asm-lang v6 by manipulating the branches of
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
