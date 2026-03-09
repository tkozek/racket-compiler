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
           cpsc411/langs/v2
           cpsc411/langs/v3)
  (define-syntax-rule (check-by-interp-assign-homes p)
    (check-equal? (interp-asm-lang-v2 p) (interp-nested-asm-lang-v2 (uniquify p))))

  ;; Added March 8th, 2026
  (check-by-interp-assign-homes '(module 0))
  (check-by-interp-assign-homes '(module 1672362778))
  (check-by-interp-assign-homes '(module (+ 1 -1637029370)))
  (check-by-interp-assign-homes '(begin
                                   (set! fv0 1)
                                   (halt fv0)))
  (check-by-interp-assign-homes '(begin
                                   (set! fv0 1)
                                   (set! rax fv0)))
  (check-by-interp-assign-homes '(module (let () -9223372036854775808)))
  (check-by-interp-assign-homes '(module (+ -379276448 -9223372036854775808)))
  (check-by-interp-assign-homes '(begin
                                   (set! fv0 9223372036854775807)
                                   (halt fv0)))
  (check-by-interp-assign-homes '(module (let ([bar.7.1 9223372036854775807]) bar.7.1)))
  (check-by-interp-assign-homes '(module (begin
                                           (set! bar.7.1 9223372036854775807)
                                           bar.7.1)))
  (check-by-interp-assign-homes '(module (let ([bar.0.2 -1259911970]
                                               [ball.2.1 -994523723])
                                           0)))
  (check-by-interp-assign-homes '(begin
                                   (set! fv0 1)
                                   (set! fv0 (* fv0 0))
                                   (set! fv1 fv0)
                                   (halt fv1)))
  (check-by-interp-assign-homes '(module (begin
                                           (set! bar.0.2 -1259911970)
                                           (set! ball.2.1 -994523723)
                                           0)))
  (check-by-interp-assign-homes '(module (begin
                                           (set! bar.6.2 1)
                                           (set! bar.3.1 -9223372036854775808)
                                           bar.3.1)))
  (check-by-interp-assign-homes '(module (let ([bat.5.3 287618957]
                                               [foobar.3.2 1]
                                               [bat.4.1 -104424799])
                                           -1788782111)))
  (check-by-interp-assign-homes '(module (let ([bat.7.3 1]
                                               [bat.6.2 229035576]
                                               [bar.0.1 -9223372036854775808])
                                           -840991502)))
  (check-by-interp-assign-homes '(begin
                                   (set! fv2 1)
                                   (set! fv1 229035576)
                                   (set! fv0 -9223372036854775808)
                                   (halt -840991502)))
  (check-by-interp-assign-homes '(begin
                                   (set! fv0 -9223372036854775808)
                                   (set! fv0 (* fv0 -1879219934))
                                   (set! fv1 fv0)
                                   (halt fv1)))
  (check-by-interp-assign-homes '(module (let ([foobar.9.1 (* 9223372036854775807 0)])
                                           (let ([foo.3.3 0]
                                                 [ball.4.2 (* 0 1)])
                                             1126078786))))
  (check-by-interp-assign-homes '(module ()
                                         (begin
                                           (set! bar.6.2 1560534029)
                                           (set! ball.4.1 9223372036854775807)
                                           (halt -875855756))
                                   ))
  (check-by-interp-assign-homes '(module (let ([ball.6 -9223372036854775808]
                                               [foobar.3 (let () -9223372036854775808)])
                                           (let () 1828326672))))
  (check-by-interp-assign-homes '(module (begin
                                           (begin
                                             (set! ball.5.2 -1583518893)
                                             (set! foobar.2.1 9223372036854775807)
                                             ball.5.2))))
  (check-by-interp-assign-homes '(module (begin
                                           (set! foobar.9.3 77841184)
                                           (set! bar.6.2 -9223372036854775808)
                                           (set! bat.3.1 699352919)
                                           bat.3.1)))
  (check-by-interp-assign-homes '(begin
                                   (set! r10 -9223372036854775808)
                                   (set! fv1 r10)
                                   (set! r10 -9223372036854775808)
                                   (set! fv0 r10)
                                   (set! rax 1828326672)))
  (check-by-interp-assign-homes '(begin
                                   (set! (rbp - 16) 1)
                                   (set! (rbp - 8) 229035576)
                                   (set! r10 -9223372036854775808)
                                   (set! (rbp - 0) r10)
                                   (set! rax -840991502)))
  (check-by-interp-assign-homes '(module (let ([ball.1.2 (+ 966813755 -1365911686)]
                                               [foo.5.1 -9223372036854775808])
                                           (let ([ball.1.3 (+ foo.5.1 1)])
                                             (let ([foo.3.4 foo.5.1]) 1)))))
  (check-by-interp-assign-homes '(module ()
                                         (begin
                                           (set! bat.7.1 1843505587)
                                           (set! tmp.3 bat.7.1)
                                           (set! tmp.3 (* tmp.3 bat.7.1))
                                           (set! tmp.2 tmp.3)
                                           (halt tmp.2))
                                   ))
  (check-by-interp-assign-homes '(begin
                                   (set! (rbp - 0) 3)
                                   (set! r10 (rbp - 0))
                                   (set! r10 (* r10 1))
                                   (set! (rbp - 0) r10)
                                   (set! r10 (rbp - 0))
                                   (set! (rbp - 8) r10)
                                   (set! rax (rbp - 8))))
  (check-by-interp-assign-homes '(begin
                                   (set! fv5 0)
                                   (set! fv4 430633110)
                                   (set! fv3 -9223372036854775808)
                                   (set! fv2 fv3)
                                   (set! fv1 9223372036854775807)
                                   (set! fv0 fv2)
                                   (halt -1211501460)))
  (check-by-interp-assign-homes '(module (begin
                                           (set! ball.1.2 (+ 966813755 -1365911686))
                                           (set! foo.5.1 -9223372036854775808)
                                           (begin
                                             (set! ball.1.3 (+ foo.5.1 1))
                                             (begin
                                               (set! foo.3.4 foo.5.1)
                                               1)))))
  (check-by-interp-assign-homes '(begin
                                   (set! (rbp - 24) -641168007)
                                   (set! r10 -9223372036854775808)
                                   (set! (rbp - 16) r10)
                                   (set! (rbp - 8) 1)
                                   (set! (rbp - 0) -921037329)
                                   (set! rax 9223372036854775807)))
  (check-by-interp-assign-homes '(begin
                                   (set! fv5 -9223372036854775808)
                                   (set! fv4 9223372036854775807)
                                   (set! fv4 (+ fv4 1))
                                   (set! fv3 fv4)
                                   (set! fv2 fv3)
                                   (set! fv1 fv5)
                                   (set! fv0 1)
                                   (halt 815346391)))
  (check-by-interp-assign-homes '(module (begin
                                           (begin
                                             (set! ball.7.4 -9223372036854775808)
                                             (set! bar.6.3 ball.7.4))
                                           (set! foo.9.2 1)
                                           (set! ball.7.1 (+ -49511605 1))
                                           (begin
                                             (set! ball.7.5 1610221572)
                                             foo.9.2))))
  (check-by-interp-assign-homes '(begin
                                   (set! r10 9223372036854775807)
                                   (set! (rbp - 0) r10)
                                   (set! r10 (rbp - 0))
                                   (set! r10 (* r10 0))
                                   (set! (rbp - 0) r10)
                                   (set! r10 (rbp - 0))
                                   (set! (rbp - 8) r10)
                                   (set! rax (rbp - 8))))
  (check-by-interp-assign-homes '(module (begin
                                           (set! foobar.0.2 (* 9223372036854775807 1))
                                           (set! ball.7.1 9223372036854775807)
                                           (begin
                                             (set! bat.3.3 9223372036854775807)
                                             (begin
                                               (set! foobar.0.4 -899475693)
                                               bat.3.3)))))
  (check-by-interp-assign-homes '(begin
                                   (set! r10 -9223372036854775808)
                                   (set! (rbp - 0) r10)
                                   (set! r10 (rbp - 0))
                                   (set! r10 (* r10 -1879219934))
                                   (set! (rbp - 0) r10)
                                   (set! r10 (rbp - 0))
                                   (set! (rbp - 8) r10)
                                   (set! rax (rbp - 8))))
  (check-by-interp-assign-homes '(module (begin
                                           (set! foo.9.3 1)
                                           (set! bar.1.2 9223372036854775807)
                                           (set! ball.8.1 (+ 1 -9223372036854775808))
                                           (begin
                                             (set! bar.6.5 (+ bar.1.2 bar.1.2))
                                             (set! ball.0.4 ball.8.1)
                                             ball.8.1))))
  (check-by-interp-assign-homes '(module ()
                                         (begin
                                           (set! tmp.4 9223372036854775807)
                                           (set! tmp.4 (* tmp.4 0))
                                           (set! foobar.9.1 tmp.4)
                                           (set! foo.3.3 0)
                                           (set! tmp.5 0)
                                           (set! tmp.5 (* tmp.5 1))
                                           (set! ball.4.2 tmp.5)
                                           (halt 1126078786))
                                   ))
  (check-by-interp-assign-homes '(module (begin
                                           (set! bar.9.1 (+ -230241463 9223372036854775807))
                                           (begin
                                             (set! bar.5.4 (+ -805707019 1))
                                             (begin
                                               (set! bat.8.5 bar.9.1)
                                               (set! bat.8.3 0))
                                             (begin
                                               (set! bat.3.2 9223372036854775807))
                                             -9223372036854775808))))
  (check-by-interp-assign-homes '(module (begin
                                           (set! bar.3.3 0)
                                           (set! bat.5.2
                                                 (begin
                                                   (set! foo.9.5 430633110)
                                                   (set! ball.2.4 -9223372036854775808)
                                                   ball.2.4))
                                           (set! foobar.1.1
                                                 (begin
                                                   9223372036854775807))
                                           (begin
                                             (set! bat.5.6 bat.5.2)
                                             -1211501460))))
  (check-by-interp-assign-homes '(module (let ()
                                           (let ([foobar.4.1 -9223372036854775808])
                                             (let ([bar.3.4 (let () foobar.4.1)]
                                                   [bat.7.3 9223372036854775807]
                                                   [ball.8.2 (let ([bar.1.6 foobar.4.1]
                                                                   [bar.9.5 364088323])
                                                               bar.9.5)])
                                               (let ([foobar.5.7 ball.8.2]) bat.7.3))))))
  (check-by-interp-assign-homes '(module (begin
                                           (set! ball.8.2 1)
                                           (set! foobar.2.1
                                                 (begin
                                                   (set! bat.9.4 (* 9223372036854775807 1))
                                                   (set! foobar.3.3 92301689)
                                                   (begin
                                                     (set! bat.9.6 2017243593)
                                                     (set! foobar.3.5 9223372036854775807)
                                                     -1476120972)))
                                           (* 0 1))))
  (check-by-interp-assign-homes '(module (let ([foo.2 0])
                                           (let ([foo.2 (let ([foobar.7 (let ([foobar.7 foo.2]
                                                                              [foo.2 foo.2]
                                                                              [ball.5 -200502468])
                                                                          0)]
                                                              [bat.6 (+ foo.2 foo.2)]
                                                              [bat.1 (+ 1 1)])
                                                          foobar.7)])
                                             (* -9223372036854775808 -1026632690)))))
  (check-by-interp-assign-homes '(module (begin
                                           (begin
                                             (set! foobar.4.1 -9223372036854775808)
                                             (begin
                                               (set! bar.3.4
                                                     (begin
                                                       foobar.4.1))
                                               (set! bat.7.3 9223372036854775807)
                                               (set! ball.8.2
                                                     (begin
                                                       (set! bar.1.6 foobar.4.1)
                                                       (set! bar.9.5 364088323)
                                                       bar.9.5))
                                               (begin
                                                 (set! foobar.5.7 ball.8.2)
                                                 bat.7.3))))))
  (check-by-interp-assign-homes '(begin
                                   (set! r10 9223372036854775807)
                                   (set! (rbp - 24) r10)
                                   (set! r10 (rbp - 24))
                                   (set! r10 (* r10 1))
                                   (set! (rbp - 24) r10)
                                   (set! r10 (rbp - 24))
                                   (set! (rbp - 16) r10)
                                   (set! r10 9223372036854775807)
                                   (set! (rbp - 8) r10)
                                   (set! r10 9223372036854775807)
                                   (set! (rbp - 32) r10)
                                   (set! (rbp - 0) -899475693)
                                   (set! rax (rbp - 32))))
  (check-by-interp-assign-homes '(begin
                                   (set! r10 -9223372036854775808)
                                   (set! (rbp - 40) r10)
                                   (set! r10 (rbp - 40))
                                   (set! (rbp - 32) r10)
                                   (set! r10 9223372036854775807)
                                   (set! (rbp - 48) r10)
                                   (set! r10 (rbp - 40))
                                   (set! (rbp - 24) r10)
                                   (set! (rbp - 16) 364088323)
                                   (set! r10 (rbp - 16))
                                   (set! (rbp - 8) r10)
                                   (set! r10 (rbp - 8))
                                   (set! (rbp - 0) r10)
                                   (set! rax (rbp - 48))))
  (check-by-interp-assign-homes '(module (begin
                                           (set! bar.3.2 (* 1 9223372036854775807))
                                           (set! foobar.0.1 -455579519)
                                           (begin
                                             (set! foo.6.4 (+ foobar.0.1 0))
                                             (begin
                                               (set! bat.4.6 1)
                                               (set! bat.8.5 -9223372036854775808)
                                               (set! bar.9.3 foobar.0.1))
                                             (begin
                                               (set! bar.9.9 0)
                                               (set! foo.6.8 -9223372036854775808)
                                               (set! bat.4.7 1)
                                               -35514184)))))
  (check-by-interp-assign-homes
   '(module (let ([bat.6 -9223372036854775808]
                  [bat.1 (let ([bat.0 (* -1022035607 1)]
                               [foo.8 1])
                           9223372036854775807)]
                  [bar.9 (let ([bat.0 1070959615]
                               [foo.2 9223372036854775807]
                               [bar.3 (+ 2075026749 -9223372036854775808)])
                           9223372036854775807)])
              (let () (let ([bar.3 (+ bat.6 0)]) (let ([bat.1 bar.9]) -9223372036854775808))))))
  (check-by-interp-assign-homes '(begin
                                   (set! (rbp - 40) -1632076199)
                                   (set! r10 (rbp - 40))
                                   (set! r10 (+ r10 0))
                                   (set! (rbp - 40) r10)
                                   (set! r10 (rbp - 40))
                                   (set! (rbp - 32) r10)
                                   (set! (rbp - 24) 0)
                                   (set! (rbp - 16) 1961579359)
                                   (set! r10 (rbp - 16))
                                   (set! r10 (+ r10 -1377521797))
                                   (set! (rbp - 16) r10)
                                   (set! r10 (rbp - 16))
                                   (set! (rbp - 8) r10)
                                   (set! r10 (rbp - 32))
                                   (set! (rbp - 48) r10)
                                   (set! (rbp - 0) 1)
                                   (set! rax (rbp - 48))))
  (check-by-interp-assign-homes '(begin
                                   (set! (rbp - 40) 966813755)
                                   (set! r10 (rbp - 40))
                                   (set! r10 (+ r10 -1365911686))
                                   (set! (rbp - 40) r10)
                                   (set! r10 (rbp - 40))
                                   (set! (rbp - 32) r10)
                                   (set! r10 -9223372036854775808)
                                   (set! (rbp - 24) r10)
                                   (set! r10 (rbp - 24))
                                   (set! (rbp - 16) r10)
                                   (set! r10 (rbp - 16))
                                   (set! r10 (+ r10 1))
                                   (set! (rbp - 16) r10)
                                   (set! r10 (rbp - 16))
                                   (set! (rbp - 8) r10)
                                   (set! r10 (rbp - 24))
                                   (set! (rbp - 0) r10)
                                   (set! rax 1)))
  (check-by-interp-assign-homes '(module ()
                                         (begin
                                           (set! ball.9.2 9223372036854775807)
                                           (set! tmp.8 823385985)
                                           (set! tmp.8 (+ tmp.8 ball.9.2))
                                           (set! foo.3.1 tmp.8)
                                           (set! foo.6.7 9223372036854775807)
                                           (set! ball.5.6 -9223372036854775808)
                                           (set! ball.1.5 1)
                                           (set! tmp.9 9223372036854775807)
                                           (set! tmp.9 (+ tmp.9 0))
                                           (set! bar.2.4 tmp.9)
                                           (set! foo.6.3 -1226663776)
                                           (set! tmp.11 foo.6.3)
                                           (set! tmp.11 (* tmp.11 foo.6.3))
                                           (set! tmp.10 tmp.11)
                                           (halt tmp.10))
                                   ))
  (check-by-interp-assign-homes '(begin
                                   (set! fv10 1)
                                   (set! r10 fv10)
                                   (set! r11 9223372036854775807)
                                   (set! r10 (* r10 r11))
                                   (set! fv10 r10)
                                   (set! r10 fv10)
                                   (set! fv9 r10)
                                   (set! fv8 -455579519)
                                   (set! r10 fv8)
                                   (set! fv7 r10)
                                   (set! r10 fv7)
                                   (set! r10 (+ r10 0))
                                   (set! fv7 r10)
                                   (set! r10 fv7)
                                   (set! fv6 r10)
                                   (set! fv5 1)
                                   (set! r10 -9223372036854775808)
                                   (set! fv4 r10)
                                   (set! r10 fv8)
                                   (set! fv3 r10)
                                   (set! fv2 0)
                                   (set! r10 -9223372036854775808)
                                   (set! fv1 r10)
                                   (set! fv0 1)
                                   (set! rax -35514184)))
  (check-by-interp-assign-homes '(begin
                                   (set! fv10 0)
                                   (set! r10 fv10)
                                   (set! fv9 r10)
                                   (set! r10 fv10)
                                   (set! fv8 r10)
                                   (set! fv7 -200502468)
                                   (set! fv6 0)
                                   (set! r10 fv10)
                                   (set! fv5 r10)
                                   (set! r10 fv5)
                                   (set! r10 (+ r10 fv10))
                                   (set! fv5 r10)
                                   (set! r10 fv5)
                                   (set! fv4 r10)
                                   (set! fv3 1)
                                   (set! r10 fv3)
                                   (set! r10 (+ r10 1))
                                   (set! fv3 r10)
                                   (set! r10 fv3)
                                   (set! fv2 r10)
                                   (set! r10 fv6)
                                   (set! fv1 r10)
                                   (set! r10 -9223372036854775808)
                                   (set! fv0 r10)
                                   (set! r10 fv0)
                                   (set! r10 (* r10 -1026632690))
                                   (set! fv0 r10)
                                   (set! r10 fv0)
                                   (set! fv11 r10)
                                   (set! rax fv11)))
  (check-by-interp-assign-homes '(begin
                                   (set! r10 9223372036854775807)
                                   (set! (rbp - 72) r10)
                                   (set! r10 (rbp - 72))
                                   (set! r10 (* r10 610664654))
                                   (set! (rbp - 72) r10)
                                   (set! r10 (rbp - 72))
                                   (set! (rbp - 64) r10)
                                   (set! r10 (rbp - 64))
                                   (set! (rbp - 56) r10)
                                   (set! r10 (rbp - 56))
                                   (set! r10 (* r10 (rbp - 64)))
                                   (set! (rbp - 56) r10)
                                   (set! r10 (rbp - 56))
                                   (set! (rbp - 48) r10)
                                   (set! r10 (rbp - 64))
                                   (set! (rbp - 40) r10)
                                   (set! r10 9223372036854775807)
                                   (set! (rbp - 32) r10)
                                   (set! r10 (rbp - 64))
                                   (set! (rbp - 24) r10)
                                   (set! r10 (rbp - 64))
                                   (set! (rbp - 16) r10)
                                   (set! r10 (rbp - 64))
                                   (set! (rbp - 8) r10)
                                   (set! (rbp - 0) 1628045022)
                                   (set! rax -400120723)))
  (check-by-interp-assign-homes
   '(module (let ([foo.0.1 (let ([foobar.8.3 (* 877774823 1)]
                                 [foo.0.2 (let ([bat.3.6 (let ([foo.6.7 0]) 9223372036854775807)]
                                                [bat.2.5 (let ([foobar.8.9 9223372036854775807]
                                                               [bat.2.8 1])
                                                           -1175234957)]
                                                [bat.4.4 (* 9223372036854775807 1)])
                                            9223372036854775807)])
                             foo.0.2)])
              (let ([bat.2.10 (let ([foo.0.13 (let ([bat.5.14 foo.0.1]) foo.0.1)]
                                    [ball.1.12 (let ([foo.7.15 1483648895]) foo.0.1)]
                                    [foo.6.11 foo.0.1])
                                foo.6.11)])
                (let ([foo.6.18 bat.2.10]
                      [foobar.9.17 bat.2.10]
                      [foobar.8.16 (+ foo.0.1 foo.0.1)])
                  (let ([bat.2.20 bat.2.10]
                        [ball.1.19 -10623344])
                    0))))))
  (check-by-interp-assign-homes '(begin
                                   (set! fv28 -9223372036854775808)
                                   (set! fv27 9223372036854775807)
                                   (set! fv26 9223372036854775807)
                                   (set! fv25 0)
                                   (set! fv24 0)
                                   (set! fv23 276890345)
                                   (set! fv22 1421159570)
                                   (set! fv22 (* fv22 0))
                                   (set! fv21 fv22)
                                   (set! fv20 -1075619650)
                                   (set! fv20 (* fv20 9223372036854775807))
                                   (set! fv19 fv20)
                                   (set! fv18 9223372036854775807)
                                   (set! fv17 451680725)
                                   (set! fv17 (+ fv17 751914030))
                                   (set! fv16 fv17)
                                   (set! fv15 fv16)
                                   (set! fv14 -1362757702)
                                   (set! fv14 (* fv14 738148732))
                                   (set! fv13 fv14)
                                   (set! fv12 -9223372036854775808)
                                   (set! fv11 -1049804848)
                                   (set! fv10 fv11)
                                   (set! fv9 0)
                                   (set! fv8 -353965291)
                                   (set! fv7 fv8)
                                   (set! fv6 0)
                                   (set! fv5 -9223372036854775808)
                                   (set! fv4 1)
                                   (set! fv3 fv15)
                                   (set! fv2 fv4)
                                   (set! fv1 0)
                                   (set! fv0 fv1)
                                   (set! fv0 (+ fv0 -9223372036854775808))
                                   (set! fv29 fv0)
                                   (halt fv29)))
  (check-by-interp-assign-homes
   '(module (let ([bar.8.1 (let ([bar.6.3 0]
                                 [foo.4.2 9223372036854775807])
                             (let ([foo.1.6 (* 1617024596 9223372036854775807)]
                                   [bar.2.5 (* bar.6.3 foo.4.2)]
                                   [foobar.0.4 (+ bar.6.3 bar.6.3)])
                               foobar.0.4))])
              (let ([foo.9.9 (let ([bar.3.12 -1114020630]
                                   [foo.1.11 (let ([foo.1.14 -2080084613]
                                                   [bar.8.13 -9223372036854775808])
                                               -1656687642)]
                                   [bar.8.10 (let ([foo.1.17 bar.8.1]
                                                   [bat.5.16 1909787064]
                                                   [foo.9.15 bar.8.1])
                                               bat.5.16)])
                               bar.3.12)]
                    [bar.3.8 (let () (* bar.8.1 9223372036854775807))]
                    [foo.1.7 (* -9223372036854775808 bar.8.1)])
                (let ([foo.9.19 bar.3.8]
                      [bar.6.18 (let ([foo.9.22 748728232]
                                      [bar.3.21 foo.9.9]
                                      [bar.8.20 foo.9.9])
                                  9223372036854775807)])
                  (* 1423178087 0))))))
  (check-by-interp-assign-homes '(begin
                                   (set! (rbp - 176) 877774823)
                                   (set! r10 (rbp - 176))
                                   (set! r10 (* r10 1))
                                   (set! (rbp - 176) r10)
                                   (set! r10 (rbp - 176))
                                   (set! (rbp - 168) r10)
                                   (set! (rbp - 160) 0)
                                   (set! r10 9223372036854775807)
                                   (set! (rbp - 152) r10)
                                   (set! r10 9223372036854775807)
                                   (set! (rbp - 144) r10)
                                   (set! (rbp - 136) 1)
                                   (set! (rbp - 128) -1175234957)
                                   (set! r10 9223372036854775807)
                                   (set! (rbp - 120) r10)
                                   (set! r10 (rbp - 120))
                                   (set! r10 (* r10 1))
                                   (set! (rbp - 120) r10)
                                   (set! r10 (rbp - 120))
                                   (set! (rbp - 112) r10)
                                   (set! r10 9223372036854775807)
                                   (set! (rbp - 104) r10)
                                   (set! r10 (rbp - 104))
                                   (set! (rbp - 96) r10)
                                   (set! r10 (rbp - 96))
                                   (set! (rbp - 88) r10)
                                   (set! r10 (rbp - 96))
                                   (set! (rbp - 80) r10)
                                   (set! (rbp - 72) 1483648895)
                                   (set! r10 (rbp - 96))
                                   (set! (rbp - 64) r10)
                                   (set! r10 (rbp - 96))
                                   (set! (rbp - 56) r10)
                                   (set! r10 (rbp - 56))
                                   (set! (rbp - 48) r10)
                                   (set! r10 (rbp - 48))
                                   (set! (rbp - 40) r10)
                                   (set! r10 (rbp - 48))
                                   (set! (rbp - 32) r10)
                                   (set! r10 (rbp - 96))
                                   (set! (rbp - 24) r10)
                                   (set! r10 (rbp - 24))
                                   (set! r10 (+ r10 (rbp - 96)))
                                   (set! (rbp - 24) r10)
                                   (set! r10 (rbp - 24))
                                   (set! (rbp - 16) r10)
                                   (set! r10 (rbp - 48))
                                   (set! (rbp - 8) r10)
                                   (set! (rbp - 0) -10623344)
                                   (set! rax 0)))
  (check-by-interp-assign-homes '(begin
                                   (set! r10 -9223372036854775808)
                                   (set! (rbp - 224) r10)
                                   (set! r10 9223372036854775807)
                                   (set! (rbp - 216) r10)
                                   (set! r10 9223372036854775807)
                                   (set! (rbp - 208) r10)
                                   (set! (rbp - 200) 0)
                                   (set! (rbp - 192) 0)
                                   (set! (rbp - 184) 276890345)
                                   (set! (rbp - 176) 1421159570)
                                   (set! r10 (rbp - 176))
                                   (set! r10 (* r10 0))
                                   (set! (rbp - 176) r10)
                                   (set! r10 (rbp - 176))
                                   (set! (rbp - 168) r10)
                                   (set! (rbp - 160) -1075619650)
                                   (set! r10 (rbp - 160))
                                   (set! r11 9223372036854775807)
                                   (set! r10 (* r10 r11))
                                   (set! (rbp - 160) r10)
                                   (set! r10 (rbp - 160))
                                   (set! (rbp - 152) r10)
                                   (set! r10 9223372036854775807)
                                   (set! (rbp - 144) r10)
                                   (set! (rbp - 136) 451680725)
                                   (set! r10 (rbp - 136))
                                   (set! r10 (+ r10 751914030))
                                   (set! (rbp - 136) r10)
                                   (set! r10 (rbp - 136))
                                   (set! (rbp - 128) r10)
                                   (set! r10 (rbp - 128))
                                   (set! (rbp - 120) r10)
                                   (set! (rbp - 112) -1362757702)
                                   (set! r10 (rbp - 112))
                                   (set! r10 (* r10 738148732))
                                   (set! (rbp - 112) r10)
                                   (set! r10 (rbp - 112))
                                   (set! (rbp - 104) r10)
                                   (set! r10 -9223372036854775808)
                                   (set! (rbp - 96) r10)
                                   (set! (rbp - 88) -1049804848)
                                   (set! r10 (rbp - 88))
                                   (set! (rbp - 80) r10)
                                   (set! (rbp - 72) 0)
                                   (set! (rbp - 64) -353965291)
                                   (set! r10 (rbp - 64))
                                   (set! (rbp - 56) r10)
                                   (set! (rbp - 48) 0)
                                   (set! r10 -9223372036854775808)
                                   (set! (rbp - 40) r10)
                                   (set! (rbp - 32) 1)
                                   (set! r10 (rbp - 120))
                                   (set! (rbp - 24) r10)
                                   (set! r10 (rbp - 32))
                                   (set! (rbp - 16) r10)
                                   (set! (rbp - 8) 0)
                                   (set! r10 (rbp - 8))
                                   (set! (rbp - 0) r10)
                                   (set! r10 (rbp - 0))
                                   (set! r11 -9223372036854775808)
                                   (set! r10 (+ r10 r11))
                                   (set! (rbp - 0) r10)
                                   (set! r10 (rbp - 0))
                                   (set! (rbp - 232) r10)
                                   (set! rax (rbp - 232))))

  ;;

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
