#lang racket

(require cpsc411/compiler-lib
         "common.rkt")

(provide flatten-program)

;; (Block-asm-lang-v8 p) -> (Para-asm-lang-v8 p)
;; Compile Block-asm-lang v8 to Para-asm-lang v8 by flattening basic blocks into labeled instructions.
(define (flatten-program bal4)
  (define flatten-effect identity)

  (define (flatten-tail tail)
    (match tail
      [`(halt ,(? opand?)) (list tail)]
      [`(jump ,(? trg?)) (list tail)]
      [`(begin
          ,fx* ...
          ,tail)
       (append (map flatten-effect fx*) (flatten-tail tail))]
      [`(if (,relop ,loc ,opand)
            (jump ,trg)
            (jump ,trg2))
       `((compare ,loc ,opand) (jump-if ,relop ,trg) (jump ,trg2))]))
  (define (flatten-b b)
    (match b
      [`(define ,(? label? label)
          ,tail)
       (let ([s* (flatten-tail tail)]) `((with-label ,label ,(first s*)) ,@(rest s*)))]))
  (define (flatten-p p)
    (match p
      [`(module ,b* ...
          ,b)
       `(begin
          ,@(foldr append '() (map flatten-b b*))
          ,@(flatten-b b))]))
  (flatten-p bal4))

#;
(module+ test
  (require rackunit
           cpsc411/langs/v6)
  (define-syntax-rule (check-flatten-program bal4 pal4)
    (check-equal? (flatten-program bal4) pal4))

  (define-syntax-rule (check-by-interp p)
    (check-equal? (interp-block-asm-lang-v6 p) (interp-para-asm-lang-v6 (flatten-program p)))))
