#lang racket

(require cpsc411/compiler-lib
         cpsc411/langs/v2
         "../util.rkt")

(provide assign-fvars)

;; (asm-lang-v2/locals) -> (asm-lang-v2/assignments)
;; Assigns each aloc from the locals info field to a fresh frame variable
(define (assign-fvars p)

  ;; '(aloc) -> '((aloc . fvar))
  ;; assigns each aloc in locals to an fvar
  (define (make-assignment locals)
    (for/list ([aloc locals]
               [i (range (length locals))])
      `(,aloc ,(make-fvar i))))

  (define (assign-p p)
    (match p
      [`(module ,info ,tail
          )
       (define locals (info-ref info 'locals))
       `(module ,(info-set info 'assignment (make-assignment locals)) ,tail
          )]))
  (assign-p p))

(module+ test
  (require rackunit
           cpsc411/langs/v2
           cpsc411/langs/v3)

  (check-match (assign-fvars '(module ((locals (x.1)))
                                      (begin
                                        (set! x.1 0)
                                        (halt x.1))
                                ))
               `(module ((locals (,x.1)) (assignment ((,x.1 ,fv0))))
                        (begin
                          (set! ,x.1 0)
                          (halt ,x.1))
                  ))
  (check-match (assign-fvars '(module ((locals (x.1 y.1 w.1)))
                                      (begin
                                        (set! x.1 0)
                                        (set! y.1 x.1)
                                        (set! w.1 1)
                                        (set! w.1 (+ w.1 y.1))
                                        (halt w.1))
                                ))
               `(module ((locals (,x.1 ,y.1 ,w.1)) (assignment ((,x.1 ,fv0) (,y.1 ,fv1) (,w.1 ,fv2))))
                        (begin
                          (set! ,x.1 0)
                          (set! ,y.1 ,x.1)
                          (set! ,w.1 1)
                          (set! ,w.1 (+ ,w.1 ,y.1))
                          (halt ,w.1))
                  )))
