#lang racket

(require cpsc411/compiler-lib
         "../util.rkt")

(provide select-instructions)

;; (imp-cmf-lang-v3) -> (asm-lang-v2)
;; Selects appropriate sequences of abstract assembly instructions to implement ops of src lang
(define (select-instructions p)
  ; (Imp-cmf-lang-v3 value) -> (List-of (Asm-lang-v2 effect)) and (Asm-lang-v2 aloc)
  ; Assigns the value v to a fresh temporary, returning two values: the list of
  ; statements the implement the assignment in Loc-lang, and the aloc that the
  ; value is stored in.
  (define (assign-tmp v)
    (define tmp (fresh))
    (match v
      [`(,op ,triv1 ,triv2)
       (if (and (binop? op) (triv? triv1) (triv? triv2))
           (values (list `(set! ,tmp ,triv1) `(set! ,tmp (,op ,tmp ,triv2)))
                   tmp) ;; values returns all its args
           (error
            (format "Expected op and two trivial values, got: ~a, ~a and ~a" op triv1 triv2)))]))

  (define (select-tail e)
    (match e
      [(? triv?) `(halt ,e)]
      [`(,op ,triv1 ,triv2)
       (define-values (insts tmp) (select-value e))
       `(begin
          ,@insts
          (halt ,tmp))]
      [`(begin
          ,effects
          ,body)
       `(begin
          ,@(map select-effect effects)
          ,(select-tail body))]))

  (define (select-value e)
    (match e
      [(? triv?) (values '() e)]
      [`(,op ,triv1 ,triv2)
       (if (and (binop? op) (triv? triv1) (triv? triv2))
           (assign-tmp e)
           (error (format "Expected binop and two trivs, got: ~a, ~a, ~a" op triv1 triv2)))]))

  (define (select-effect e)
    (match e
      [`(set! ,aloc ,v)
       (define-values (insts tmp) (select-value v))
       `(begin
          ,@insts
          (set! ,aloc ,tmp))]
      [`(begin
          ,rest ...
          ,last)
       `(begin
          ,@(map select-effect rest)
          ,(select-effect last))]))

  (match p
    [`(module ,tail)
     `(module () ,(select-tail tail)
        )]))

(module+ test
  (require rackunit
           cpsc411/langs/v2
           cpsc411/langs/v3)
  (define-syntax-rule (check-by-interp p)
    (check-equal? (interp-imp-cmf-lang-v3 p) (interp-asm-lang-v2 (select-instructions p))))

  ;; Added March 8th, 2026
  (check-by-interp '(module 0))
  (check-by-interp '(module 1672362778))
  (check-by-interp '(module (let () (* 1 0))))
  (check-by-interp '(begin
                      (set! fv0 1)
                      (halt fv0)))
  (check-by-interp '(module (+ 9223372036854775807 0)))
  (check-by-interp '(module (let () -9223372036854775808)))
  (check-by-interp '(module (+ -379276448 -9223372036854775808)))
  (check-by-interp '(begin
                      (set! fv0 9223372036854775807)
                      (halt fv0)))
  (check-by-interp '(module (let ([foo.4.1 9223372036854775807]) foo.4.1)))
  (check-by-interp '(module (begin
                              (set! bar.7.1 9223372036854775807)
                              bar.7.1)))
  (check-by-interp '(module (begin
                              (set! bat.7.1 1843505587)
                              (* bat.7.1 bat.7.1))))
  (check-by-interp '(begin
                      (set! fv0 3)
                      (set! fv0 (* fv0 1))
                      (set! fv1 fv0)
                      (halt fv1)))
  (check-by-interp '(module ()
                            (begin
                              (set! bat.5.2 -1622353956)
                              (set! bat.4.1 1)
                              (halt 1))
                      ))
  (check-by-interp '(module (begin
                              (set! bar.6.2 1)
                              (set! bar.3.1 -9223372036854775808)
                              bar.3.1)))
  (check-by-interp '(begin
                      (set! r10 9223372036854775807)
                      (set! (rbp - 0) r10)
                      (set! rax (rbp - 0))))
  (check-by-interp '(module (let ([foobar.9 77841184]
                                  [bar.6 -9223372036854775808]
                                  [bat.3 699352919])
                              bat.3)))
  (check-by-interp '(begin
                      (set! fv2 287618957)
                      (set! fv1 1)
                      (set! fv0 -104424799)
                      (set! rax -1788782111)))
  (check-by-interp '(begin
                      (set! fv0 -9223372036854775808)
                      (set! fv0 (* fv0 -1879219934))
                      (set! fv1 fv0)
                      (halt fv1)))
  (check-by-interp '(module (begin
                              (set! bar.4.1 9223372036854775807)
                              (begin
                                (set! foobar.0.2 (* 1 bar.4.1))
                                bar.4.1))))
  (check-by-interp '(module ()
                            (begin
                              (set! tmp.2 1)
                              (set! tmp.2 (* tmp.2 0))
                              (set! tmp.1 tmp.2)
                              (halt tmp.1))
                      ))
  (check-by-interp '(module (let ([foobar.9.3 77841184]
                                  [bar.6.2 -9223372036854775808]
                                  [bat.3.1 699352919])
                              bat.3.1)))
  (check-by-interp '(module (begin
                              (set! bat.7.3 1)
                              (set! bat.6.2 229035576)
                              (set! bar.0.1 -9223372036854775808)
                              -840991502)))
  (check-by-interp '(module (begin
                              (set! foobar.9.3 77841184)
                              (set! bar.6.2 -9223372036854775808)
                              (set! bat.3.1 699352919)
                              bat.3.1)))
  (check-by-interp '(module (let ([bar.5 133037836]
                                  [bat.0 9223372036854775807])
                              (let ([bar.5 2124072059]
                                    [foobar.7 503802092]
                                    [bat.0 -1338020867])
                                1))))
  (check-by-interp '(module ()
                            (begin
                              (set! bat.7.3 1)
                              (set! bat.6.2 229035576)
                              (set! bar.0.1 -9223372036854775808)
                              (halt -840991502))
                      ))
  (check-by-interp '(begin
                      (set! r10 -9223372036854775808)
                      (set! (rbp - 8) r10)
                      (set! r10 -9223372036854775808)
                      (set! (rbp - 0) r10)
                      (set! rax 1828326672)))
  (check-by-interp '(begin
                      (set! fv3 -641168007)
                      (set! r10 -9223372036854775808)
                      (set! fv2 r10)
                      (set! fv1 1)
                      (set! fv0 -921037329)
                      (set! rax 9223372036854775807)))
  (check-by-interp '(module (begin
                              (set! bar.8.1 (* 0 0))
                              (begin
                                (set! foobar.1.3 -9223372036854775808)
                                (set! ball.4.2 (* bar.8.1 bar.8.1))
                                (begin
                                  bar.8.1)))))
  (check-by-interp '(module (let ([bar.9.3 (+ -1632076199 0)]
                                  [ball.0.2 0]
                                  [foo.2.1 (+ 1961579359 -1377521797)])
                              (let ([foo.2.4 bar.9.3]) (let ([foobar.1.5 1]) foo.2.4)))))
  (check-by-interp '(begin
                      (set! fv4 9223372036854775807)
                      (set! fv4 (* fv4 0))
                      (set! fv3 fv4)
                      (set! fv2 0)
                      (set! fv1 0)
                      (set! fv1 (* fv1 1))
                      (set! fv0 fv1)
                      (halt 1126078786)))
  (check-by-interp '(begin
                      (set! (rbp - 24) -641168007)
                      (set! r10 -9223372036854775808)
                      (set! (rbp - 16) r10)
                      (set! (rbp - 8) 1)
                      (set! (rbp - 0) -921037329)
                      (set! rax 9223372036854775807)))
  (check-by-interp '(module (begin
                              (begin
                                (set! bat.8.3 -641168007)
                                (set! ball.7.2 -9223372036854775808)
                                (set! foo.9.1 1))
                              (begin
                                (set! bat.2.4 -921037329)
                                9223372036854775807))))
  (check-by-interp '(module (begin
                              (set! bar.6.3
                                    (begin
                                      (set! ball.7.4 -9223372036854775808)
                                      ball.7.4))
                              (set! foo.9.2 1)
                              (set! ball.7.1 (+ -49511605 1))
                              (begin
                                (set! ball.7.5 1610221572)
                                foo.9.2))))
  (check-by-interp '(begin
                      (set! (rbp - 32) 133037836)
                      (set! r10 9223372036854775807)
                      (set! (rbp - 24) r10)
                      (set! (rbp - 16) 2124072059)
                      (set! (rbp - 8) 503802092)
                      (set! (rbp - 0) -1338020867)
                      (set! rax 1)))
  (check-by-interp '(module (begin
                              (set! bar.5.2 133037836)
                              (set! bat.0.1 9223372036854775807)
                              (begin
                                (set! bar.5.5 2124072059)
                                (set! foobar.7.4 503802092)
                                (set! bat.0.3 -1338020867)
                                1))))
  (check-by-interp '(begin
                      (set! r10 -9223372036854775808)
                      (set! (rbp - 0) r10)
                      (set! r10 (rbp - 0))
                      (set! r10 (* r10 -1879219934))
                      (set! (rbp - 0) r10)
                      (set! r10 (rbp - 0))
                      (set! (rbp - 8) r10)
                      (set! rax (rbp - 8))))
  (check-by-interp '(begin
                      (set! fv5 1)
                      (set! fv4 9223372036854775807)
                      (set! fv3 1)
                      (set! fv3 (+ fv3 -9223372036854775808))
                      (set! fv6 fv3)
                      (set! fv2 fv4)
                      (set! fv2 (+ fv2 fv4))
                      (set! fv1 fv2)
                      (set! fv0 fv6)
                      (halt fv6)))
  (check-by-interp '(module ()
                            (begin
                              (set! bar.3.3 0)
                              (set! foo.9.5 430633110)
                              (set! ball.2.4 -9223372036854775808)
                              (set! bat.5.2 ball.2.4)
                              (set! foobar.1.1 9223372036854775807)
                              (set! bat.5.6 bat.5.2)
                              (halt -1211501460))
                      ))
  (check-by-interp '(module (begin
                              (set! bar.9.1 (+ -230241463 9223372036854775807))
                              (begin
                                (set! bar.5.4 (+ -805707019 1))
                                (set! bat.8.3
                                      (begin
                                        (set! bat.8.5 bar.9.1)
                                        0))
                                (set! bat.3.2
                                      (begin
                                        9223372036854775807))
                                -9223372036854775808))))
  (check-by-interp '(module ()
                            (begin
                              (set! tmp.3 -822533870)
                              (set! tmp.3 (+ tmp.3 9223372036854775807))
                              (set! bat.1.2 tmp.3)
                              (set! bar.7.1 9223372036854775807)
                              (set! tmp.5 bar.7.1)
                              (set! tmp.5 (+ tmp.5 0))
                              (set! tmp.4 tmp.5)
                              (halt tmp.4))
                      ))
  (check-by-interp '(module (let ([foo.9 (let ()
                                           (let ([ball.0 (let ([foobar.8 -9223372036854775808]
                                                               [foobar.6 9223372036854775807])
                                                           foobar.8)])
                                             (+ ball.0 513005733)))]
                                  [bar.1 90426798])
                              foo.9)))
  (check-by-interp '(begin
                      (set! (rbp - 40) 0)
                      (set! (rbp - 32) 430633110)
                      (set! r10 -9223372036854775808)
                      (set! (rbp - 24) r10)
                      (set! r10 (rbp - 24))
                      (set! (rbp - 16) r10)
                      (set! r10 9223372036854775807)
                      (set! (rbp - 8) r10)
                      (set! r10 (rbp - 16))
                      (set! (rbp - 0) r10)
                      (set! rax -1211501460)))
  (check-by-interp '(module ()
                            (begin
                              (set! foo.9.3 1)
                              (set! bar.1.2 9223372036854775807)
                              (set! tmp.6 1)
                              (set! tmp.6 (+ tmp.6 -9223372036854775808))
                              (set! ball.8.1 tmp.6)
                              (set! tmp.7 bar.1.2)
                              (set! tmp.7 (+ tmp.7 bar.1.2))
                              (set! bar.6.5 tmp.7)
                              (set! ball.0.4 ball.8.1)
                              (halt ball.8.1))
                      ))
  (check-by-interp '(module (begin
                              (set! foobar.6.1 (+ 0 -996315978))
                              (begin
                                (set! foo.4.4
                                      (begin
                                        (set! bar.3.7 -9223372036854775808)
                                        (set! foobar.7.6 190399644)
                                        (set! bat.1.5 1)
                                        foobar.6.1))
                                (set! ball.8.3 0)
                                (set! foobar.6.2
                                      (begin
                                        foobar.6.1))
                                ball.8.3))))
  (check-by-interp '(module (begin
                              (begin
                                (set! foobar.4.1 -9223372036854775808)
                                (begin
                                  (begin
                                    (set! bar.3.4 foobar.4.1))
                                  (set! bat.7.3 9223372036854775807)
                                  (begin
                                    (set! bar.1.6 foobar.4.1)
                                    (set! bar.9.5 364088323)
                                    (set! ball.8.2 bar.9.5))
                                  (begin
                                    (set! foobar.5.7 ball.8.2)
                                    bat.7.3))))))
  (check-by-interp '(begin
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
  (check-by-interp '(module (let ([foo.2.1 0])
                              (let ([foo.2.2 (let ([foobar.7.5 (let ([foobar.7.8 foo.2.1]
                                                                     [foo.2.7 foo.2.1]
                                                                     [ball.5.6 -200502468])
                                                                 0)]
                                                   [bat.6.4 (+ foo.2.1 foo.2.1)]
                                                   [bat.1.3 (+ 1 1)])
                                               foobar.7.5)])
                                (* -9223372036854775808 -1026632690)))))
  (check-by-interp '(begin
                      (set! (rbp - 48) 0)
                      (set! r10 (rbp - 48))
                      (set! r10 (+ r10 -996315978))
                      (set! (rbp - 48) r10)
                      (set! r10 (rbp - 48))
                      (set! (rbp - 40) r10)
                      (set! r10 -9223372036854775808)
                      (set! (rbp - 32) r10)
                      (set! (rbp - 24) 190399644)
                      (set! (rbp - 16) 1)
                      (set! r10 (rbp - 40))
                      (set! (rbp - 8) r10)
                      (set! (rbp - 56) 0)
                      (set! r10 (rbp - 40))
                      (set! (rbp - 0) r10)
                      (set! rax (rbp - 56))))
  (check-by-interp '(begin
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
  (check-by-interp '(begin
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
  (check-by-interp '(module (let ([bat.0 (let ([foo.1 (let ([bat.0 (* 0 -591471193)]
                                                            [bar.7 -1433160755]
                                                            [foobar.8 (let ([foobar.3 -1630730845]
                                                                            [ball.5 1]
                                                                            [bat.9 1])
                                                                        bat.9)])
                                                        foobar.8)])
                                           (let ([foo.1 (* -9223372036854775808 215775010)]
                                                 [ball.5 foo.1])
                                             (+ 0 foo.1)))]
                                  [ball.5 (+ 1 0)]
                                  [bar.7 (let () 0)])
                              -9223372036854775808)))
  (check-by-interp '(begin
                      (set! (rbp - 56) 1)
                      (set! r10 9223372036854775807)
                      (set! (rbp - 48) r10)
                      (set! r10 (rbp - 48))
                      (set! r10 (* r10 1))
                      (set! (rbp - 48) r10)
                      (set! r10 (rbp - 48))
                      (set! (rbp - 40) r10)
                      (set! (rbp - 32) 92301689)
                      (set! (rbp - 24) 2017243593)
                      (set! r10 9223372036854775807)
                      (set! (rbp - 16) r10)
                      (set! (rbp - 8) -1476120972)
                      (set! (rbp - 0) 0)
                      (set! r10 (rbp - 0))
                      (set! r10 (* r10 1))
                      (set! (rbp - 0) r10)
                      (set! r10 (rbp - 0))
                      (set! (rbp - 64) r10)
                      (set! rax (rbp - 64))))
  (check-by-interp
   '(module (let ([bat.0.3 (let ([foo.1.4 (let ([bat.0.7 (* 0 -591471193)]
                                                [bar.7.6 -1433160755]
                                                [foobar.8.5 (let ([foobar.3.10 -1630730845]
                                                                  [ball.5.9 1]
                                                                  [bat.9.8 1])
                                                              bat.9.8)])
                                            foobar.8.5)])
                             (let ([foo.1.12 (* -9223372036854775808 215775010)]
                                   [ball.5.11 foo.1.4])
                               (+ 0 foo.1.12)))]
                  [ball.5.2 (+ 1 0)]
                  [bar.7.1 (let () 0)])
              -9223372036854775808)))
  (check-by-interp '(module ()
                            (begin
                              (set! tmp.9 -1154104701)
                              (set! tmp.9 (* tmp.9 9223372036854775807))
                              (set! foo.9.2 tmp.9)
                              (set! tmp.10 9223372036854775807)
                              (set! tmp.10 (+ tmp.10 -1520906171))
                              (set! ball.1.3 tmp.10)
                              (set! tmp.11 ball.1.3)
                              (set! tmp.11 (* tmp.11 ball.1.3))
                              (set! ball.1.1 tmp.11)
                              (set! tmp.12 -9223372036854775808)
                              (set! tmp.12 (+ tmp.12 9223372036854775807))
                              (set! foobar.4.5 tmp.12)
                              (set! foo.5.8 -711901302)
                              (set! ball.2.7 foo.9.2)
                              (set! foobar.6.6 1)
                              (set! bat.7.4 -9223372036854775808)
                              (set! tmp.14 -832221090)
                              (set! tmp.14 (+ tmp.14 1952403775))
                              (set! tmp.13 tmp.14)
                              (halt tmp.13))
                      ))
  (check-by-interp '(begin
                      (set! r10 9223372036854775807)
                      (set! (rbp - 72) r10)
                      (set! (rbp - 64) 823385985)
                      (set! r10 (rbp - 64))
                      (set! r10 (+ r10 (rbp - 72)))
                      (set! (rbp - 64) r10)
                      (set! r10 (rbp - 64))
                      (set! (rbp - 56) r10)
                      (set! r10 9223372036854775807)
                      (set! (rbp - 48) r10)
                      (set! r10 -9223372036854775808)
                      (set! (rbp - 40) r10)
                      (set! (rbp - 32) 1)
                      (set! r10 9223372036854775807)
                      (set! (rbp - 24) r10)
                      (set! r10 (rbp - 24))
                      (set! r10 (+ r10 0))
                      (set! (rbp - 24) r10)
                      (set! r10 (rbp - 24))
                      (set! (rbp - 16) r10)
                      (set! (rbp - 8) -1226663776)
                      (set! r10 (rbp - 8))
                      (set! (rbp - 0) r10)
                      (set! r10 (rbp - 0))
                      (set! r10 (* r10 (rbp - 8)))
                      (set! (rbp - 0) r10)
                      (set! r10 (rbp - 0))
                      (set! (rbp - 80) r10)
                      (set! rax (rbp - 80))))
  (check-by-interp '(begin
                      (set! (rbp - 120) 1)
                      (set! (rbp - 112) 118010454)
                      (set! (rbp - 104) 1)
                      (set! r10 -9223372036854775808)
                      (set! (rbp - 96) r10)
                      (set! r10 (rbp - 104))
                      (set! (rbp - 88) r10)
                      (set! r10 (rbp - 120))
                      (set! (rbp - 80) r10)
                      (set! r10 (rbp - 120))
                      (set! (rbp - 72) r10)
                      (set! r10 -9223372036854775808)
                      (set! (rbp - 64) r10)
                      (set! r10 (rbp - 64))
                      (set! (rbp - 56) r10)
                      (set! r10 (rbp - 56))
                      (set! r10 (* r10 (rbp - 64)))
                      (set! (rbp - 56) r10)
                      (set! r10 (rbp - 56))
                      (set! (rbp - 48) r10)
                      (set! (rbp - 40) -1846872043)
                      (set! r10 (rbp - 40))
                      (set! r10 (+ r10 (rbp - 64)))
                      (set! (rbp - 40) r10)
                      (set! r10 (rbp - 40))
                      (set! (rbp - 32) r10)
                      (set! (rbp - 24) 0)
                      (set! r10 (rbp - 64))
                      (set! (rbp - 16) r10)
                      (set! r10 -9223372036854775808)
                      (set! (rbp - 8) r10)
                      (set! r10 (rbp - 48))
                      (set! (rbp - 0) r10)
                      (set! rax 1)))
  (check-by-interp '(module (let ([ball.0.3 (let ([foobar.9.6 (let ([ball.0.8 -9223372036854775808]
                                                                    [ball.1.7 9223372036854775807])
                                                                9223372036854775807)]
                                                  [ball.0.5 (let ([ball.1.10 0]
                                                                  [foobar.4.9 0])
                                                              276890345)]
                                                  [foo.6.4 (* 1421159570 0)])
                                              (* -1075619650 9223372036854775807))]
                                  [foobar.4.2 (let ([foo.2.12 9223372036854775807]
                                                    [ball.1.11 (+ 451680725 751914030)])
                                                ball.1.11)]
                                  [foo.6.1 (let ([foobar.9.15 (* -1362757702 738148732)]
                                                 [foobar.7.14 (let ([foobar.8.17 -9223372036854775808]
                                                                    [foobar.4.16 -1049804848])
                                                                foobar.4.16)]
                                                 [foo.6.13 (let ([ball.1.19 0]
                                                                 [foobar.7.18 -353965291])
                                                             foobar.7.18)])
                                             (let ([foobar.9.21 0]
                                                   [foobar.3.20 -9223372036854775808])
                                               1))])
                              (let ([foobar.9.22 (let ([ball.0.24 foobar.4.2]
                                                       [foobar.4.23 foo.6.1])
                                                   0)])
                                (+ foobar.9.22 -9223372036854775808)))))
  (check-by-interp '(module (begin
                              (set! ball.0.3
                                    (begin
                                      (set! foobar.9.6
                                            (begin
                                              (set! ball.0.8 -9223372036854775808)
                                              (set! ball.1.7 9223372036854775807)
                                              9223372036854775807))
                                      (set! ball.0.5
                                            (begin
                                              (set! ball.1.10 0)
                                              (set! foobar.4.9 0)
                                              276890345))
                                      (set! foo.6.4 (* 1421159570 0))
                                      (* -1075619650 9223372036854775807)))
                              (set! foobar.4.2
                                    (begin
                                      (set! foo.2.12 9223372036854775807)
                                      (set! ball.1.11 (+ 451680725 751914030))
                                      ball.1.11))
                              (set! foo.6.1
                                    (begin
                                      (set! foobar.9.15 (* -1362757702 738148732))
                                      (set! foobar.7.14
                                            (begin
                                              (set! foobar.8.17 -9223372036854775808)
                                              (set! foobar.4.16 -1049804848)
                                              foobar.4.16))
                                      (set! foo.6.13
                                            (begin
                                              (set! ball.1.19 0)
                                              (set! foobar.7.18 -353965291)
                                              foobar.7.18))
                                      (begin
                                        (set! foobar.9.21 0)
                                        (set! foobar.3.20 -9223372036854775808)
                                        1)))
                              (begin
                                (set! foobar.9.22
                                      (begin
                                        (set! ball.0.24 foobar.4.2)
                                        (set! foobar.4.23 foo.6.1)
                                        0))
                                (+ foobar.9.22 -9223372036854775808)))))
  (check-by-interp '(begin
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
  (check-equal? (select-instructions '(module 0))
                '(module () (halt 0)
                   ))
  (check-equal? (select-instructions '(module 9223372036854775807))
                '(module () (halt 9223372036854775807)
                   ))
  (check-equal? (select-instructions '(module -9223372036854775808))
                '(module () (halt -9223372036854775808)
                   ))
  (check-match (select-instructions '(module (+ 2 2)))
               '(module ()
                        (begin
                          (set! ,t 2)
                          (set! ,t (+ ,t 2))
                          (halt ,t))
                  ))
  (check-match (select-instructions '(module (* -3 2)))
               '(module ()
                        (begin
                          (set! ,t -3)
                          (set! ,t (* ,t 2))
                          (halt ,t))
                  ))
  (check-match (select-instructions '(module (+ 9223372036854775807 9223372036854775807)))
               '(module ()
                        (begin
                          (set! ,t 9223372036854775807)
                          (set! ,t (+ ,t 9223372036854775807))
                          (halt ,t))
                  ))
  (check-match (select-instructions '(module (* -9223372036854775808 9223372036854775807)))
               '(module ()
                        (begin
                          (set! ,t -9223372036854775808)
                          (set! ,t (* ,t 9223372036854775807))
                          (halt ,t))
                  ))
  (check-match (select-instructions '(module (begin
                                               (set! ,t 5)
                                               ,t)))
               '(module ()
                        (begin
                          (set! ,t 5)
                          (halt ,t))
                  ))
  (check-equal? (select-instructions '(module (begin
                                                (set! x.1 (+ 2 2))
                                                x.1)))
                '(module ()
                         (begin
                           (set! x.1 2)
                           (set! x.1 (+ x.1 2))
                           (halt x.1))
                   ))
  (check-match (select-instructions '(module (begin
                                               (set! x.1 2)
                                               (set! x.2 2)
                                               (+ x.1 x.2))))
               '(module ()
                        (begin
                          (set! x.1 2)
                          (set! x.2 2)
                          (set! ,t x.1)
                          (set! ,t (+ ,t x.2))
                          (halt ,t))
                  ))
  (check-match (select-instructions '(module (begin
                                               (begin
                                                 (set! ,t 3))
                                               ,t)))
               '(module ()
                        (begin
                          (begin
                            (set! ,t 3))
                          (halt ,t))
                  )))
