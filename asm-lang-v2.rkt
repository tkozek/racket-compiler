#lang racket

(require cpsc411/compiler-lib
         "util.rkt")

(provide uncover-locals
         assign-fvars
         replace-locations
         assign-homes)

;; (asm-lang-v2) -> (asm-lang-v2/locals)
;; Analyzes which alocs are used in p and decorates program with set of variables in info field
(define (uncover-locals p)
  (define locals '())

  (define (uncover-aloc aloc)
    (when (and (aloc? aloc) (not (memq aloc locals)))
      (set! locals (cons aloc locals))))

  ; (define (uncover-triv triv)
  ;         (uncover-aloc triv))

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
       (info-set info 'locals locals)
       `(module info ,tail
          )]))
  (uncover-p p))

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
       ;; do I need begin here? I don't think I do
       (init-assignments info)
       (replace-tail tail)]))

  (replace-p p))

;; want to get the pairs from assignments in info.
;; then when we see an aloc we replace it and return it replaced
;;

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

;; (asm-lang-v2) -> (nested-asm-lang-v2)
;; Replaces each aloc its with assigned physical location from assignment info field
(define (assign-homes p)
  (replace-locations (assign-fvars (uncover-locals p))))

(module+ test
  (require rackunit
           cpsc411/langs/v3)
  (define-syntax-rule (check-by-interp p)
    (check-equal? (interp-values-lang-v3 p) (interp-values-unique-lang-v3 (uniquify p))))

  (check-equal? (uncover-locals '(module () (halt 0)
                                   ))
                '(module ((locals ())) (halt 0)
                   ))
  (check-equal? (uncover-locals '(module () (halt 9223372036854775807)
                                   ))
                '(module ((locals ())) (halt 9223372036854775807)
                   ))
  (check-equal? (uncover-locals '(module () (halt -9223372036854775808)
                                   ))
                '(module ((locals ())) (halt -9223372036854775808)
                   ))
  (check-exn exn:fail?
             (lambda ()
               (uncover-locals '(module () (halt x.1)
                                  ))))

  (check-match (uncover-locals '(module ()
                                        (begin
                                          (set! x.1 0)
                                          (halt x.1))
                                  ))
               `(module ((locals (,x)))
                        (begin
                          (set! ,x 0)
                          (halt ,x))
                  ))
  (check-match (uncover-locals '(module ()
                                        (begin
                                          (set! x.1 0)
                                          (set! y.1 x.1)
                                          (set! y.1 (+ y.1 x.1))
                                          (halt y.1))
                                  ))
               `(module ((locals (,x ,y)))
                        (begin
                          (set! ,x 0)
                          (set! ,y ,x)
                          (set! ,y (+ ,y ,x))
                          (halt ,y))
                  ))

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
                  ))

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
