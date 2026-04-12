#lang racket
(require cpsc411/compiler-lib
         cpsc411/langs/v8
         "common.rkt")

(provide implement-mops)

;; (paren-x64-mops-v8 p) -> (paren-x64-v8 p)
;; Compiles mops to instructions on pointers with index- and displacement-mode operands.
(define (implement-mops p)

  (define (implement-s s)
    (match s
      [`(with-label ,label ,labelled-s) `(with-label ,label ,(implement-s labelled-s))]
      [`(mset! ,reg1 ,index ,trg-or-int) `(set! (,reg1 + ,index) ,trg-or-int)]
      [`(set! ,(? register? reg1) (mref ,(? register? reg2) ,index)) `(set! ,reg1 (,reg2 + ,index))]
      [_ s]))

  (define (implement-p p)
    (match p
      [`(begin
          ,ss ...)
       `(begin
          ,@(map implement-s ss))]))

  (implement-p p))

(module+ test
  (require rackunit
           cpsc411/langs/v8
           cpsc411/test-suite/public/v8
           cpsc411/compiler-lib)
  (define-syntax-rule (check-by-interp p)
    (check-equal? p p))
  (v8-public-test-suite '(implement-mops) '(interp-paren-x64-mops-v8)))
