#lang racket

(require cpsc411/compiler-lib
         "../util.rkt")

(provide uncover-locals)

;; (asm-lang-v2) -> (asm-lang-v2/locals)
;; Analyzes which alocs are used in p and decorates program with set of variables in info field
(define (uncover-locals p)
  (define locals '())

  (define (uncover-aloc aloc)
    (when (and (aloc? aloc) (not (memq aloc locals)))
      (set! locals (cons aloc locals))))

  (define (uncover-effect effect)
    (match effect
      [`(set! ,aloc1 (,binop ,aloc1 ,triv))
       (uncover-aloc aloc1)
       (uncover-aloc triv)]
      [`(set! ,aloc ,triv)
       (uncover-aloc aloc)
       (uncover-aloc triv)]
      [`(begin
          ,first
          ,rest ...)
       (uncover-effect first)
       (for-each uncover-effect rest)]))

  (define (uncover-tails tail)
    (match tail
      [`(halt ,triv) (uncover-aloc triv)]
      [`(begin
          ,effect ...
          ,tail)
       (for-each uncover-effect effect)
       (uncover-tails tail)]))

  (define (uncover-p p)
    (match p
      [`(module ,info ,tail
          )
       (uncover-tails tail)
       (let ([new-info (info-set info 'locals locals)])
         `(module ,new-info ,tail
            ))]))
  (uncover-p p))

(module+ test
  ;   (require rackunit
  ;            cpsc411/langs/v2
  ;            cpsc411/langs/v3)
  ;   ;   (define-syntax-rule (check-by-interp-assign-homes p)
  ;   ;     (check-equal? (interp-asm-lang-v2 p) (interp-nested-asm-lang-v2 (assign-homes p))))

  ;   (check-equal? (uncover-locals '(module () (halt 0)
  ;                                    ))
  ;                 '(module ((locals ())) (halt 0)
  ;                    ))
  ;   (check-equal? (uncover-locals '(module () (halt 9223372036854775807)
  ;                                    ))
  ;                 '(module ((locals ())) (halt 9223372036854775807)
  ;                    ))
  ;   (check-equal? (uncover-locals '(module () (halt -9223372036854775808)
  ;                                    ))
  ;                 '(module ((locals ())) (halt -9223372036854775808)
  ;                    ))
  ;   (check-exn exn:fail?
  ;              (lambda ()
  ;                (uncover-locals '(module () (halt x.1)
  ;                                   ))))

  ;   (check-match (uncover-locals '(module ()
  ;                                         (begin
  ;                                           (set! x.1 0)
  ;                                           (halt x.1))
  ;                                   ))
  ;                `(module ((locals (,x)))
  ;                         (begin
  ;                           (set! ,x 0)
  ;                           (halt ,x))
  ;                   ))
  ;   (check-match (uncover-locals '(module ()
  ;                                         (begin
  ;                                           (set! x.1 0)
  ;                                           (set! y.1 x.1)
  ;                                           (set! y.1 (+ y.1 x.1))
  ;                                           (halt y.1))
  ;                                   ))
  ;                `(module ((locals (,x ,y)))
  ;                         (begin
  ;                           (set! ,x 0)
  ;                           (set! ,y ,x)
  ;                           (set! ,y (+ ,y ,x))
  ;                           (halt ,y))
  ;   ))
  )
