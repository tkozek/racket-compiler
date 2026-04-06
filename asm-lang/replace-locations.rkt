#lang racket

(require cpsc411/compiler-lib
         "../util.rkt")

(provide replace-locations)

;; (asm-lang-v2/assignments) -> (nested-asm-lang-v2)
;; Replaces each aloc with its assigned physical location from the assignment info field
(define (replace-locations p)
  (define assignments (make-hash))

  ;; for every assignment pair in info, add an entry to assignments that maps
  ;; the aloc to the fvar
  (define (init-assignments info)
    (for-each (lambda (pair)
                (let ([aloc (first pair)]
                      [fvar (second pair)])
                  (hash-set! assignments aloc fvar)))
              (info-ref info 'assignment)))

  ; (define (replace-aloc aloc)
  ;     (when (and (aloc? aloc)
  ;                 (hash-ref assignments aloc #f))
  ;             (hash-ref assignments aloc)))
  (define (replace-aloc aloc)
    (match aloc
      [(? int64?) aloc]
      [(? aloc?)
       (when (and (aloc? aloc) (hash-ref assignments aloc #f))
         (hash-ref assignments aloc))]))

  (define (replace-effect effect)
    (match effect
      [`(set! ,aloc1 (,binop ,aloc1 ,triv))
       `(set! ,(replace-aloc aloc1) (,binop ,(replace-aloc aloc1) ,(replace-aloc triv)))]
      [`(set! ,aloc ,triv) `(set! ,(replace-aloc aloc) ,(replace-aloc triv))]
      [`(begin
          ,first
          ,rest ...)
       `(begin
          ,(replace-effect first)
          ,@(map replace-effect rest))]))

  (define (replace-tail tail)
    (match tail
      [`(halt ,triv) `(halt ,(replace-aloc triv))]
      [`(begin
          ,effects ...
          ,tail)
       `(begin
          ,@(map replace-effect effects)
          ,(replace-tail tail))]))

  (define (replace-p p)
    (match p
      [`(module ,info ,tail
          )
       (init-assignments info)
       (replace-tail tail)]))

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
