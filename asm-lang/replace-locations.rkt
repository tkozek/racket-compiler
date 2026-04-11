#lang racket

(require cpsc411/compiler-lib
         cpsc411/langs/v2
         "../util.rkt")

(provide replace-locations)

;; (asm-lang-v2/assignments) -> (nested-asm-lang-v2)
;; Replaces each aloc with its assigned physical location from the assignment info field
(define (replace-locations p)

  (define (replace-triv triv assignment)
    (match triv
      [(? int64?) triv]
      [(? aloc?) (replace-aloc triv assignment)]))

  (define (replace-aloc aloc assignment)
    (info-ref assignment aloc))

  (define (replace-effect effect assignment)
    (match effect
      [`(set! ,aloc1 (,binop ,aloc1 ,triv))
       (define loc (replace-aloc aloc1 assignment))
       `(set! ,loc (,binop ,loc ,(replace-triv triv assignment)))]
      [`(set! ,aloc ,triv) `(set! ,(replace-aloc aloc assignment) ,(replace-triv triv assignment))]
      [`(begin
          ,effects ...)
       `(begin
          ,@(map (λ (e) (replace-effect e assignment)) effects))]))

  (define (replace-tail tail assignment)
    (match tail
      [`(halt ,triv) `(halt ,(replace-triv triv assignment))]
      [`(begin
          ,effects ...
          ,tail)
       `(begin
          ,@(map (λ (e) (replace-effect e assignment)) effects)
          ,(replace-tail tail assignment))]))
  (define (replace-p p)
    (match p
      [`(module ,info ,tail
          )
       (replace-tail tail (info-ref info 'assignment))]))

  (replace-p p))

(module+ test
  (require rackunit
           cpsc411/langs/v2
           cpsc411/langs/v3)
  (define-syntax-rule (check-by-interp-assign-homes p)
    (check-equal? (interp-asm-lang-v2 p) (interp-nested-asm-lang-v2 (assign-homes p))))

  (check-equal? (replace-locations '(module ((locals (x.1)) (assignment ((x.1 rax))))
                                            (begin
                                              (set! x.1 0)
                                              (halt x.1))
                                      ))
                '(begin
                   (set! rax 0)
                   (halt rax)))
  (check-equal? (replace-locations '(module ((locals (x.1 y.1 w.1)) (assignment ((x.1 rax) (y.1 rbx)
                                                                                           (w.1 r9))))
                                            (begin
                                              (set! x.1 0)
                                              (set! y.1 x.1)
                                              (set! w.1 1)
                                              (set! w.1 (+ w.1 y.1))
                                              (halt w.1))
                                      ))
                '(begin
                   (set! rax 0)
                   (set! rbx rax)
                   (set! r9 1)
                   (set! r9 (+ r9 rbx))
                   (halt r9))))
