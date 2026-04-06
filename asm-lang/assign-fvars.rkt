#lang racket

(require cpsc411/compiler-lib
         "../util.rkt")

(provide assign-fvars)

;; (asm-lang-v2/locals) -> (asm-lang-v2/assignments)
;; Assigns each aloc from the locals info field to a fresh frame variable
(define (assign-fvars p)
  (define fvar-counter 0)
  (define assignments (make-hash))
  (define (assign-aloc aloc)
    (when (and (aloc? aloc) (not (hash-has-key? assignments aloc)))
      (hash-set! assignments aloc (make-fvar fvar-counter))
      (set! fvar-counter (add1 fvar-counter))))

  (define (assign-effect effect)
    (match effect
      [`(set! ,aloc1 (,binop ,aloc1 ,triv))
       (assign-aloc aloc1)
       (assign-aloc triv)]
      [`(set! ,aloc ,triv)
       (assign-aloc aloc)
       (assign-aloc triv)]
      [`(begin
          ,first
          ,rest)
       (assign-effect first)
       (for-each assign-effect rest)]))

  (define (assign-tail tail)
    (match tail
      [`(halt ,triv)
       #:when (triv? triv)
       (assign-aloc triv)]
      [`(begin
          ,effects ...
          ,tail)
       (for-each assign-effect effects)
       (assign-tail tail)]))

  (define (assign-p p)
    (match p
      [`(module ,info ,tail
          )
       (assign-tail tail) ; (list (k v)) for k, v in assignments
       (info-set info 'assignment (hash->list assignments))
       `(module info tail
          )]))
  (assign-p p))

(module+ test
  (require rackunit
           cpsc411/langs/v2
           cpsc411/langs/v3)
  (define-syntax-rule (check-by-interp-assign-homes p)
    (check-equal? (interp-asm-lang-v2 p) (interp-nested-asm-lang-v2 (assign-homes p))))

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
