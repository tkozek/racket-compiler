#lang racket
(require rackunit
         cpsc411/langs/v5
         cpsc411/compiler-lib
         "../target-nested-asm-lang-v2/assign-registers.rkt")

(define (check-input p)
  (if (asm-pred-lang-v5/conflicts? p)
      p
      (error (~a (pretty-format p)
                 "\n is not a semantically valid "
                 "asm-pred-lang-v8/spilled"
                 " program"))))

(define (check-output p)
  (if (asm-pred-lang-v5/assignments? p)
      p
      (error (~a (pretty-format p)
                 "\n is not a semantically valid "
                 "asm-pred-lang-v5/assignments"
                 " program"))))

(define-syntax-rule (check-by-interp p)
  (check-equal? (interp-asm-pred-lang-v5/conflicts (check-input p))
                (interp-asm-pred-lang-v5/assignments (check-output (assign-registers p)))))

;; M5 tests; Added by Trevor on March 8th 2026, multiple bindings allowed per let
(check-by-interp
 '(module ((locals (foobar.8.11 bat.1.13 foo.4.12 ball.7.9 foo.4.10))
           (undead-out (((foo.4.10) (ball.7.9 foo.4.10) ()) () (() () (foobar.8.11) ())))
           (conflicts ((foo.4.10 (ball.7.9)) (ball.7.9 (foo.4.10))
                                             (foo.4.12 ())
                                             (bat.1.13 ())
                                             (foobar.8.11 ()))))
          (define L.fn.0.1
            ((locals (foo.3.2 bat.1.6
                              tmp.18
                              tmp.17
                              foo.3.7
                              foo.4.8
                              foo.0.3
                              tmp.14
                              foobar.5.5
                              foobar.8.4
                              tmp.16
                              foo.4.1
                              tmp.15))
             (undead-out ((rsi rdx rcx r8 r9)
                          (rdx rcx r8 r9 foobar.5.5)
                          (rcx r8 r9 foobar.5.5 foobar.8.4)
                          (r8 r9 foo.0.3 foobar.5.5 foobar.8.4)
                          (r9 foo.0.3 foobar.5.5 foobar.8.4)
                          (foo.0.3 foobar.5.5 foo.4.1 foobar.8.4)
                          ((foo.0.3 foobar.5.5 foo.4.1 foobar.8.4)
                           (((foobar.5.5 tmp.14 foo.4.1 foobar.8.4) (foo.4.1 foobar.8.4))
                            (() () ())
                            ((tmp.16) (tmp.16) (tmp.15) ()))
                           ((foo.0.3 foobar.5.5) ((tmp.18) (tmp.18) (tmp.17) ())
                                                 ((foo.0.3) (foo.0.3) ())))))
             (conflicts ((tmp.15 ())
                         (foo.4.1 (foobar.8.4 foobar.5.5 foo.0.3 tmp.14))
                         (tmp.16 ())
                         (foobar.8.4 (foo.4.1 foo.3.2 foo.0.3 foobar.5.5 r9 r8 rcx tmp.14))
                         (foobar.5.5 (foo.4.1 foo.3.2 foo.0.3 foobar.8.4 r9 r8 rcx rdx tmp.14))
                         (tmp.14 (foobar.8.4 foo.4.1 foobar.5.5))
                         (foo.0.3 (foo.4.1 foo.3.2 foobar.8.4 foobar.5.5 r9 r8 foo.3.7 foo.4.8))
                         (foo.4.8 (foo.0.3))
                         (foo.3.7 (foo.0.3))
                         (tmp.17 ())
                         (tmp.18 ())
                         (bat.1.6 (r9 r8 rcx rdx rsi))
                         (foo.3.2 (foobar.8.4 foobar.5.5 foo.0.3 r9))
                         (rsi (bat.1.6))
                         (rdx (foobar.5.5 bat.1.6))
                         (rcx (foobar.8.4 foobar.5.5 bat.1.6))
                         (r8 (foo.0.3 foobar.8.4 foobar.5.5 bat.1.6))
                         (r9 (foo.3.2 foo.0.3 foobar.8.4 foobar.5.5 bat.1.6)))))
            (begin
              (set! bat.1.6 rdi)
              (set! foobar.5.5 rsi)
              (set! foobar.8.4 rdx)
              (set! foo.0.3 rcx)
              (set! foo.3.2 r8)
              (set! foo.4.1 r9)
              (if (true)
                  (if (begin
                        (set! tmp.14 -502092639)
                        (= tmp.14 foobar.5.5))
                      (if (>= foobar.8.4 1)
                          (halt 1852032564)
                          (halt -106704231))
                      (begin
                        (set! tmp.16 foo.4.1)
                        (set! tmp.16 (+ tmp.16 1))
                        (set! tmp.15 tmp.16)
                        (halt tmp.15)))
                  (if (true)
                      (begin
                        (set! tmp.18 -9223372036854775808)
                        (set! tmp.18 (+ tmp.18 0))
                        (set! tmp.17 tmp.18)
                        (halt tmp.17))
                      (begin
                        (set! foo.4.8 foobar.5.5)
                        (set! foo.3.7 0)
                        (halt foo.0.3))))))
    (if (begin
          (set! foo.4.10 -9223372036854775808)
          (set! ball.7.9 0)
          (> foo.4.10 ball.7.9))
        (halt -9223372036854775808)
        (begin
          (set! bat.1.13 -9223372036854775808)
          (set! foo.4.12 1)
          (set! foobar.8.11 1)
          (halt foobar.8.11)))))
(check-by-interp
 '(module ((locals (tmp.17 tmp.16 bat.0.12 bat.2.11))
           (undead-out ((tmp.16) (tmp.16)
                                 (bat.0.12)
                                 (tmp.17 bat.0.12)
                                 (tmp.17 bat.0.12)
                                 (bat.2.11 bat.0.12)
                                 ((bat.0.12) () ())))
           (conflicts
            ((bat.2.11 (bat.0.12)) (bat.0.12 (bat.2.11 tmp.17)) (tmp.16 ()) (tmp.17 (bat.0.12)))))
          (define L.tmp.0.1
            ((locals (bat.2.10 bat.4.9
                               foobar.5.7
                               tmp.14
                               tmp.15
                               foobar.6.8
                               tmp.13
                               foo.9.1
                               bat.8.2
                               foobar.6.3
                               foobar.5.4
                               bat.0.5
                               bat.2.6))
             (undead-out
              ((rsi rdx rcx r8 r9 rbp)
               (rdx rcx r8 r9 bat.0.5 rbp)
               (rcx r8 r9 bat.0.5 foobar.5.4 rbp)
               (r8 r9 bat.0.5 foobar.5.4 rbp)
               (r9 bat.0.5 foobar.5.4 bat.8.2 rbp)
               (bat.0.5 foobar.5.4 foo.9.1 bat.8.2 rbp)
               ((bat.0.5 foobar.5.4 foo.9.1 bat.8.2 rbp)
                ((tmp.13 foobar.5.4 foo.9.1 bat.8.2 rbp) (tmp.13 foobar.5.4 foo.9.1 bat.8.2 rbp)
                                                         (foobar.5.4 foo.9.1 bat.8.2 foobar.6.8 rbp))
                (foobar.5.4 foo.9.1 bat.8.2 foobar.6.8 rbp))
               (((bat.2.10 foo.9.1 bat.8.2 foobar.6.8 rbp) (bat.2.10 foo.9.1 bat.8.2 foobar.6.8 rbp)
                                                           (foo.9.1 bat.8.2 foobar.6.8 rbp))
                (((tmp.14 foo.9.1 bat.8.2 foobar.6.8 rbp) (foo.9.1 bat.8.2 foobar.6.8 rbp))
                 (foo.9.1 bat.8.2 foobar.6.8 rbp)
                 (foo.9.1 bat.8.2 foobar.6.8 rbp))
                ((tmp.15 foo.9.1 bat.8.2 foobar.6.8 rbp) (tmp.15 foo.9.1 bat.8.2 foobar.6.8 rbp)
                                                         (foo.9.1 bat.8.2 foobar.6.8 rbp)))
               (bat.8.2 foobar.6.8 r9 rbp)
               (foobar.6.8 r9 r8 rbp)
               (foobar.6.8 r9 r8 rcx rbp)
               (foobar.6.8 r9 r8 rcx rdx rbp)
               (foobar.6.8 r9 r8 rcx rdx rsi rbp)
               (r9 r8 rcx rdx rsi rdi rbp)
               (r9 r8 rcx rdx rsi rdi rbp)))
             (conflicts
              ((bat.2.6 (rbp r9 r8 rcx rdx rsi))
               (bat.0.5 (foo.9.1 bat.8.2 foobar.6.3 foobar.5.4 rbp r9 r8 rcx rdx))
               (foobar.5.4 (tmp.13 foobar.6.8 foo.9.1 bat.8.2 foobar.6.3 rbp bat.0.5 r9 r8 rcx))
               (foobar.6.3 (rbp foobar.5.4 bat.0.5 r9 r8))
               (bat.8.2 (bat.4.9 bat.2.10
                                 tmp.14
                                 tmp.15
                                 foobar.5.7
                                 tmp.13
                                 foobar.6.8
                                 foo.9.1
                                 rbp
                                 foobar.5.4
                                 bat.0.5
                                 r9))
               (foo.9.1
                (bat.2.10 tmp.14 tmp.15 foobar.5.7 tmp.13 foobar.6.8 rbp bat.8.2 foobar.5.4 bat.0.5))
               (tmp.13 (rbp bat.8.2 foo.9.1 foobar.5.4))
               (foobar.6.8 (rsi rdx
                                rcx
                                r8
                                r9
                                bat.4.9
                                bat.2.10
                                tmp.14
                                tmp.15
                                foobar.5.7
                                foobar.5.4
                                rbp
                                bat.8.2
                                foo.9.1))
               (tmp.15 (foo.9.1 rbp foobar.6.8 bat.8.2))
               (tmp.14 (rbp foobar.6.8 bat.8.2 foo.9.1))
               (foobar.5.7 (rbp foobar.6.8 bat.8.2 foo.9.1))
               (bat.4.9 (rbp foobar.6.8 bat.8.2 bat.2.10))
               (bat.2.10 (bat.4.9 rbp foobar.6.8 bat.8.2 foo.9.1))
               (rsi (rdi rbp rdx rcx r8 r9 foobar.6.8 bat.2.6))
               (rdx (rdi rsi rbp rcx r8 r9 foobar.6.8 bat.0.5 bat.2.6))
               (rcx (rdi rsi rdx rbp r8 r9 foobar.6.8 foobar.5.4 bat.0.5 bat.2.6))
               (r8 (rdi rsi rdx rcx rbp r9 foobar.6.8 foobar.6.3 foobar.5.4 bat.0.5 bat.2.6))
               (r9 (rdi rsi rdx rcx r8 rbp foobar.6.8 bat.8.2 foobar.6.3 foobar.5.4 bat.0.5 bat.2.6))
               (rbp (rdi rsi
                         rdx
                         rcx
                         r8
                         r9
                         bat.4.9
                         bat.2.10
                         tmp.14
                         tmp.15
                         foobar.5.7
                         tmp.13
                         foobar.6.8
                         foo.9.1
                         bat.8.2
                         foobar.6.3
                         foobar.5.4
                         bat.0.5
                         bat.2.6))
               (rdi (rbp rsi rdx rcx r8 r9)))))
            (begin
              (set! bat.2.6 rdi)
              (set! bat.0.5 rsi)
              (set! foobar.5.4 rdx)
              (set! foobar.6.3 rcx)
              (set! bat.8.2 r8)
              (set! foo.9.1 r9)
              (if (true)
                  (begin
                    (set! tmp.13 bat.0.5)
                    (set! tmp.13 (* tmp.13 -1194246923))
                    (set! foobar.6.8 tmp.13))
                  (set! foobar.6.8 foobar.5.4))
              (if (begin
                    (set! bat.2.10 foobar.5.4)
                    (set! bat.4.9 foo.9.1)
                    (= bat.2.10 422731415))
                  (if (begin
                        (set! tmp.14 9223372036854775807)
                        (<= tmp.14 9223372036854775807))
                      (set! foobar.5.7 9223372036854775807)
                      (set! foobar.5.7 9223372036854775807))
                  (begin
                    (set! tmp.15 foo.9.1)
                    (set! tmp.15 (+ tmp.15 52582991))
                    (set! foobar.5.7 tmp.15)))
              (set! r9 foo.9.1)
              (set! r8 bat.8.2)
              (set! rcx 0)
              (set! rdx -1002513727)
              (set! rsi -191435828)
              (set! rdi foobar.6.8)
              (jump L.tmp.0.1 rbp rdi rsi rdx rcx r8 r9)))
    (begin
      (set! tmp.16 -9223372036854775808)
      (set! tmp.16 (+ tmp.16 937267391))
      (set! bat.0.12 tmp.16)
      (set! tmp.17 -9223372036854775808)
      (set! tmp.17 (+ tmp.17 -9223372036854775808))
      (set! bat.2.11 tmp.17)
      (if (!= bat.2.11 1)
          (halt -335809824)
          (halt bat.0.12)))))
(check-by-interp
 '(module ((locals (bat.9.14 tmp.23 foobar.2.15 tmp.22 foo.6.16 bat.7.17 foo.6.18 foobar.0.19))
           (undead-out (() (foo.6.18) (foo.6.18) () (tmp.22) (tmp.22) () (tmp.23) (tmp.23) () ()))
           (conflicts ((foobar.0.19 ()) (foo.6.18 (bat.7.17))
                                        (bat.7.17 (foo.6.18))
                                        (foo.6.16 ())
                                        (tmp.22 ())
                                        (foobar.2.15 ())
                                        (tmp.23 ())
                                        (bat.9.14 ()))))
          (define L.proc.0.1
            ((locals (tmp.21 bar.5.8
                             foobar.2.7
                             bat.7.6
                             ball.1.5
                             foobar.2.1
                             ball.3.4
                             tmp.20
                             ball.1.3
                             bat.9.2))
             (undead-out ((rsi rdx ball.1.3 rbp)
                          (rdx ball.1.3 bat.9.2 rbp)
                          (foobar.2.1 ball.1.3 bat.9.2 rbp)
                          ((foobar.2.1 ball.1.3 bat.9.2 rbp)
                           ((ball.1.3 bat.9.2 r8 rbp) (bat.9.2 r8 rcx rbp)
                                                      (bat.9.2 r8 rcx rdx rbp)
                                                      (bat.9.2 r8 rcx rdx rsi rbp)
                                                      (r8 rcx rdx rsi rdi rbp)
                                                      (r8 rcx rdx rsi rdi rbp))
                           ((ball.1.3 foobar.2.1 bat.9.2) (foobar.2.7 ball.1.3 foobar.2.1 bat.9.2)
                                                          (ball.1.3 foobar.2.1 bat.9.2)
                                                          ((foobar.2.1 bat.9.2) (bat.9.2) (bat.9.2))
                                                          (((tmp.20 bat.9.2) (bat.9.2)) () ())
                                                          (((tmp.21) ()) () ())))))
             (conflicts
              ((bat.9.2
                (foobar.2.1 rbp ball.1.3 rdx rsi rcx r8 tmp.20 ball.1.5 bat.7.6 foobar.2.7 bar.5.8))
               (ball.1.3 (foobar.2.1 bat.9.2 rbp rdx rsi r8 bat.7.6 foobar.2.7 bar.5.8))
               (tmp.20 (bat.9.2))
               (ball.3.4 ())
               (foobar.2.1 (rbp bat.9.2 ball.1.3 bat.7.6 foobar.2.7 bar.5.8))
               (ball.1.5 (bat.9.2))
               (bat.7.6 (bat.9.2 foobar.2.1 ball.1.3))
               (foobar.2.7 (bat.9.2 foobar.2.1 ball.1.3))
               (bar.5.8 (bat.9.2 foobar.2.1 ball.1.3))
               (tmp.21 ())
               (r8 (rdi rsi rdx rcx rbp bat.9.2 ball.1.3))
               (rbp (foobar.2.1 bat.9.2 ball.1.3 rdi rsi rdx rcx r8))
               (rcx (rdi rsi rdx rbp r8 bat.9.2))
               (rdx (bat.9.2 ball.1.3 rdi rsi rbp rcx r8))
               (rsi (ball.1.3 rdi rbp rdx rcx r8 bat.9.2))
               (rdi (rbp rsi rdx rcx r8)))))
            (begin
              (set! ball.1.3 rdi)
              (set! bat.9.2 rsi)
              (set! foobar.2.1 rdx)
              (if (false)
                  (begin
                    (set! r8 1)
                    (set! rcx ball.1.3)
                    (set! rdx bat.9.2)
                    (set! rsi 9223372036854775807)
                    (set! rdi bat.9.2)
                    (jump L.tmp.1.2 rbp rdi rsi rdx rcx r8))
                  (begin
                    (set! bar.5.8 1554173211)
                    (set! foobar.2.7 616342412)
                    (set! bat.7.6 foobar.2.7)
                    (if (= foobar.2.1 ball.1.3)
                        (set! ball.1.5 foobar.2.1)
                        (set! ball.1.5 bat.9.2))
                    (if (begin
                          (set! tmp.20 1)
                          (= tmp.20 0))
                        (set! ball.3.4 bat.9.2)
                        (set! ball.3.4 0))
                    (if (begin
                          (set! tmp.21 1320805275)
                          (< tmp.21 9223372036854775807))
                        (halt 0)
                        (halt 0))))))
    (define L.tmp.1.2
      ((locals (ball.8.9 ball.3.10 foobar.2.11 ball.1.12 bat.7.13))
       (undead-out ((rsi rdx rcx r8 rbp) (rdx rcx r8 rbp)
                                         (rcx r8 rbp)
                                         (r8 ball.3.10 rbp)
                                         (ball.8.9 ball.3.10 rbp)
                                         (ball.3.10 rdx rbp)
                                         (ball.3.10 rdx rsi rbp)
                                         (rdx rsi rdi rbp)
                                         (rdx rsi rdi rbp)))
       (conflicts ((bat.7.13 (rbp r8 rcx rdx rsi))
                   (ball.1.12 (rbp r8 rcx rdx))
                   (foobar.2.11 (rbp r8 rcx))
                   (ball.3.10 (rsi rdx ball.8.9 rbp r8))
                   (ball.8.9 (rbp ball.3.10))
                   (rsi (rdi rbp rdx ball.3.10 bat.7.13))
                   (rdx (rdi rsi rbp ball.3.10 ball.1.12 bat.7.13))
                   (rcx (foobar.2.11 ball.1.12 bat.7.13))
                   (r8 (ball.3.10 foobar.2.11 ball.1.12 bat.7.13))
                   (rbp (rdi rsi rdx ball.8.9 ball.3.10 foobar.2.11 ball.1.12 bat.7.13))
                   (rdi (rbp rsi rdx)))))
      (begin
        (set! bat.7.13 rdi)
        (set! ball.1.12 rsi)
        (set! foobar.2.11 rdx)
        (set! ball.3.10 rcx)
        (set! ball.8.9 r8)
        (set! rdx ball.8.9)
        (set! rsi 9223372036854775807)
        (set! rdi ball.3.10)
        (jump L.proc.0.1 rbp rdi rsi rdx)))
    (begin
      (set! foobar.0.19 2142022224)
      (set! foo.6.18 0)
      (set! bat.7.17 1)
      (set! foo.6.16 foo.6.18)
      (set! tmp.22 1)
      (set! tmp.22 (+ tmp.22 121573080))
      (set! foobar.2.15 tmp.22)
      (set! tmp.23 9223372036854775807)
      (set! tmp.23 (* tmp.23 -1355489058))
      (set! bat.9.14 tmp.23)
      (halt 0))))
(check-by-interp '(module ((locals (tmp.7 tmp.5 ball.8.1 ball.7.2 ball.5.3 tmp.4 tmp.6))
                           (undead-out ((tmp.4) (tmp.4)
                                                (ball.5.3)
                                                (ball.5.3)
                                                (((tmp.5 ball.5.3) (ball.5.3)) (ball.5.3) (ball.5.3))
                                                (ball.5.3 tmp.7)
                                                (tmp.7)
                                                (tmp.6)
                                                ()))
                           (conflicts ((tmp.6 ()) (tmp.4 ())
                                                  (ball.5.3 (tmp.7 tmp.5 ball.8.1 ball.7.2))
                                                  (ball.7.2 (ball.5.3))
                                                  (ball.8.1 (ball.5.3))
                                                  (tmp.5 (ball.5.3))
                                                  (tmp.7 (ball.5.3)))))
                          (begin
                            (set! tmp.4 0)
                            (set! tmp.4 (+ tmp.4 9223372036854775807))
                            (set! ball.5.3 tmp.4)
                            (set! ball.7.2 -678062995)
                            (if (begin
                                  (set! tmp.5 0)
                                  (!= tmp.5 9223372036854775807))
                                (set! ball.8.1 -2004574473)
                                (set! ball.8.1 9223372036854775807))
                            (set! tmp.7 1)
                            (set! tmp.7 (* tmp.7 ball.5.3))
                            (set! tmp.6 tmp.7)
                            (halt tmp.6))
                    ))
(check-by-interp
 '(module ((locals (foo.6.18 foo.7.19 tmp.23 foo.6.14 foo.1.15 foo.7.16 bat.4.17))
           (undead-out ((bat.4.17) (bat.4.17) () (((tmp.23) ()) () ()) () () ()))
           (conflicts ((bat.4.17 (foo.7.16)) (foo.7.16 (bat.4.17))
                                             (foo.1.15 ())
                                             (foo.6.14 ())
                                             (tmp.23 ())
                                             (foo.7.19 ())
                                             (foo.6.18 ()))))
          (define L.fn.0.1
            ((locals (bat.4.1 foo.1.2 foo.3.3))
             (undead-out ((rsi rdx rbp) (rdx foo.1.2 rbp)
                                        (bat.4.1 foo.1.2 rbp)
                                        (bat.4.1 foo.1.2 rdx rbp)
                                        (foo.1.2 rdx rsi rbp)
                                        (rdx rsi rdi rbp)
                                        (rdx rsi rdi rbp)))
             (conflicts ((foo.3.3 (rbp rdx rsi)) (foo.1.2 (rsi bat.4.1 rbp rdx))
                                                 (bat.4.1 (rdx rbp foo.1.2))
                                                 (rsi (rdi rbp rdx foo.1.2 foo.3.3))
                                                 (rdx (rdi rsi rbp bat.4.1 foo.1.2 foo.3.3))
                                                 (rbp (rdi rsi rdx bat.4.1 foo.1.2 foo.3.3))
                                                 (rdi (rbp rsi rdx)))))
            (begin
              (set! foo.3.3 rdi)
              (set! foo.1.2 rsi)
              (set! bat.4.1 rdx)
              (set! rdx foo.1.2)
              (set! rsi bat.4.1)
              (set! rdi foo.1.2)
              (jump L.fn.0.1 rbp rdi rsi rdx)))
    (define L.tmp.1.2
      ((locals (tmp.21 ball.0.13
                       foobar.5.12
                       tmp.22
                       foo.1.8
                       foo.6.7
                       ball.0.6
                       bat.4.5
                       tmp.20
                       foo.7.4
                       foo.9.11
                       foo.7.10
                       bat.8.9))
       (undead-out ((rbp) (() (foo.6.7) () () (tmp.20) (tmp.20) (foo.7.4) (foo.7.4) () () ())
                          (((ball.0.13 rbp) (ball.0.13 rbp) ((ball.0.13 tmp.21 rbp) (rbp)))
                           (((tmp.22) ()) () ())
                           (rbp))))
       (conflicts ((bat.8.9 ()) (foo.7.10 ())
                                (foo.9.11 (foo.7.4))
                                (foo.7.4 (foo.9.11))
                                (tmp.20 ())
                                (bat.4.5 ())
                                (ball.0.6 ())
                                (foo.6.7 ())
                                (foo.1.8 ())
                                (tmp.22 ())
                                (foobar.5.12 (rbp ball.0.13))
                                (ball.0.13 (foobar.5.12 rbp tmp.21))
                                (tmp.21 (rbp ball.0.13))
                                (rbp (foobar.5.12 ball.0.13 tmp.21)))))
      (if (true)
          (begin
            (set! foo.1.8 -918704320)
            (set! foo.6.7 -1822595193)
            (set! ball.0.6 foo.6.7)
            (set! bat.4.5 0)
            (set! tmp.20 9223372036854775807)
            (set! tmp.20 (* tmp.20 810114007))
            (set! foo.7.4 tmp.20)
            (set! foo.9.11 1)
            (set! foo.7.10 foo.7.4)
            (set! bat.8.9 1)
            (halt 1271317139))
          (if (begin
                (set! ball.0.13 9223372036854775807)
                (set! foobar.5.12 -9223372036854775808)
                (begin
                  (set! tmp.21 1474008962)
                  (< tmp.21 ball.0.13)))
              (if (begin
                    (set! tmp.22 -566856990)
                    (!= tmp.22 -9223372036854775808))
                  (halt 1)
                  (halt 1056302987))
              (jump L.tmp.1.2 rbp))))
    (begin
      (set! bat.4.17 -9223372036854775808)
      (set! foo.7.16 9223372036854775807)
      (set! foo.1.15 bat.4.17)
      (if (begin
            (set! tmp.23 -1846550218)
            (>= tmp.23 1836975164))
          (set! foo.6.14 -186139937)
          (set! foo.6.14 1))
      (set! foo.7.19 1884722986)
      (set! foo.6.18 9223372036854775807)
      (halt 0))))
(check-by-interp
 '(module ((locals ()) (undead-out ((rsi rbp) (rsi rdi rbp) (rsi rdi rbp)))
                       (conflicts ((rsi (rdi rbp)) (rbp (rdi rsi)) (rdi (rbp rsi)))))
          (define L.func.0.1
            ((locals (foo.9.1 foobar.5.2 foo.2.3 bar.6.4 bat.7.5 bat.0.6))
             (undead-out ((rsi rdx rcx r8 r9 bat.0.6) (rdx rcx r8 r9 bat.0.6)
                                                      (rcx r8 r9 bat.0.6)
                                                      (r8 r9 bat.0.6)
                                                      (r9 bat.0.6)
                                                      (bat.0.6)
                                                      ()))
             (conflicts ((bat.0.6 (foo.9.1 foobar.5.2 foo.2.3 bar.6.4 bat.7.5 r9 r8 rcx rdx rsi))
                         (bat.7.5 (bat.0.6 r9 r8 rcx rdx))
                         (bar.6.4 (bat.0.6 r9 r8 rcx))
                         (foo.2.3 (bat.0.6 r9 r8))
                         (foobar.5.2 (bat.0.6 r9))
                         (foo.9.1 (bat.0.6))
                         (rsi (bat.0.6))
                         (rdx (bat.7.5 bat.0.6))
                         (rcx (bar.6.4 bat.7.5 bat.0.6))
                         (r8 (foo.2.3 bar.6.4 bat.7.5 bat.0.6))
                         (r9 (foobar.5.2 foo.2.3 bar.6.4 bat.7.5 bat.0.6)))))
            (begin
              (set! bat.0.6 rdi)
              (set! bat.7.5 rsi)
              (set! bar.6.4 rdx)
              (set! foo.2.3 rcx)
              (set! foobar.5.2 r8)
              (set! foo.9.1 r9)
              (halt bat.0.6)))
    (define L.func.1.2
      ((locals (bat.0.9 tmp.23
                        foobar.1.17
                        tmp.22
                        foobar.5.18
                        foo.4.19
                        foo.2.20
                        bat.8.21
                        foobar.1.11
                        bar.3.12
                        foo.4.14
                        bat.8.15
                        foo.2.16
                        bat.8.13
                        bat.0.7
                        foobar.1.8
                        bar.3.10))
       (undead-out ((rsi foobar.1.8)
                    (bat.0.7 foobar.1.8)
                    (bat.0.7 foobar.1.8)
                    (bat.0.7 foobar.1.8)
                    (bat.0.7 foobar.1.8)
                    (bat.0.7 foobar.1.8)
                    (bar.3.12 bat.0.7 foobar.1.8)
                    (bat.0.7 foobar.1.8)
                    (bat.0.7 foobar.1.8)
                    (bat.0.7 foobar.1.8)
                    (bat.0.7 foobar.1.8)
                    (bat.0.7 foobar.1.8)
                    (tmp.22 bat.0.7 foobar.1.8)
                    (tmp.22 bat.0.7 foobar.1.8)
                    (bat.0.7 foobar.1.8)
                    ((bat.0.7 foobar.1.8) (foobar.1.8 bar.3.10) (foobar.1.8 bar.3.10))
                    ((foobar.1.8 bar.3.10) ((tmp.23 bar.3.10) (tmp.23 bar.3.10) (bar.3.10))
                                           (bar.3.10))
                    ()))
       (conflicts ((bar.3.10 (tmp.23 bat.0.9 foobar.1.8)) (foobar.1.8 (bar.3.10 foobar.1.17
                                                                                tmp.22
                                                                                foobar.5.18
                                                                                foo.4.19
                                                                                bat.8.21
                                                                                foobar.1.11
                                                                                bar.3.12
                                                                                bat.8.15
                                                                                bat.8.13
                                                                                bat.0.7
                                                                                rsi))
                                                          (bat.0.7 (foobar.1.17 tmp.22
                                                                                foobar.5.18
                                                                                foo.4.19
                                                                                foo.2.20
                                                                                foobar.1.11
                                                                                bar.3.12
                                                                                foo.4.14
                                                                                bat.8.15
                                                                                foo.2.16
                                                                                bat.8.13
                                                                                foobar.1.8))
                                                          (bat.8.13 (foobar.1.8 bat.0.7))
                                                          (foo.2.16 (bat.0.7))
                                                          (bat.8.15 (foobar.1.8 bat.0.7))
                                                          (foo.4.14 (bat.0.7))
                                                          (bar.3.12 (foobar.1.8 bat.0.7))
                                                          (foobar.1.11 (foobar.1.8 bat.0.7))
                                                          (bat.8.21 (foobar.1.8))
                                                          (foo.2.20 (bat.0.7))
                                                          (foo.4.19 (foobar.1.8 bat.0.7))
                                                          (foobar.5.18 (foobar.1.8 bat.0.7))
                                                          (tmp.22 (bat.0.7 foobar.1.8))
                                                          (foobar.1.17 (foobar.1.8 bat.0.7))
                                                          (tmp.23 (bar.3.10))
                                                          (bat.0.9 (bar.3.10))
                                                          (rsi (foobar.1.8)))))
      (begin
        (set! foobar.1.8 rdi)
        (set! bat.0.7 rsi)
        (set! bat.8.13 0)
        (set! foo.2.16 foobar.1.8)
        (set! bat.8.15 1492712685)
        (set! foo.4.14 foobar.1.8)
        (set! bar.3.12 9223372036854775807)
        (set! foobar.1.11 bar.3.12)
        (set! bat.8.21 bat.0.7)
        (set! foo.2.20 foobar.1.8)
        (set! foo.4.19 -383652955)
        (set! foobar.5.18 -9223372036854775808)
        (set! tmp.22 bat.0.7)
        (set! tmp.22 (+ tmp.22 566306668))
        (set! foobar.1.17 tmp.22)
        (if (!= bat.0.7 0)
            (set! bar.3.10 -9223372036854775808)
            (set! bar.3.10 bat.0.7))
        (if (false)
            (begin
              (set! tmp.23 1)
              (set! tmp.23 (* tmp.23 0))
              (set! bat.0.9 tmp.23))
            (set! bat.0.9 foobar.1.8))
        (halt bar.3.10)))
    (begin
      (set! rsi 0)
      (set! rdi -9223372036854775808)
      (jump L.func.1.2 rbp rdi rsi))))
(check-by-interp
 '(module ((locals ()) (undead-out ()) (conflicts ()))
          (define L.tmp.0.1
            ((locals (bar.8.8 bar.8.1
                              bat.2.3
                              bar.7.5
                              tmp.11
                              foo.5.4
                              tmp.10
                              tmp.9
                              bar.3.2
                              foobar.0.6
                              bar.7.7))
             (undead-out
              ((rsi rdx rcx r8 r9 foobar.0.6)
               (rdx rcx r8 r9 foobar.0.6)
               (rcx r8 r9 foobar.0.6 foo.5.4)
               (r8 r9 bat.2.3 foobar.0.6 foo.5.4)
               (r9 bat.2.3 foobar.0.6 bar.3.2 foo.5.4)
               (bat.2.3 foobar.0.6 bar.3.2 foo.5.4)
               (foobar.0.6 bar.3.2 foo.5.4)
               (foobar.0.6 bar.3.2 foo.5.4 bar.7.7)
               (((bar.3.2 foo.5.4 bar.7.7) ((bar.3.2 tmp.9 foo.5.4 bar.7.7) (foo.5.4 bar.7.7))
                                           ((tmp.10 foo.5.4 bar.7.7) (foo.5.4 bar.7.7)))
                (() () ())
                (((foo.5.4 tmp.11) ()) () ()))))
             (conflicts
              ((bar.7.7 (foo.5.4 bar.3.2 foobar.0.6 tmp.9 tmp.10))
               (foobar.0.6
                (bar.7.7 bar.8.8 bar.8.1 bar.3.2 bat.2.3 foo.5.4 bar.7.5 r9 r8 rcx rdx rsi))
               (bar.3.2 (bar.7.7 bar.8.8 bar.8.1 foo.5.4 foobar.0.6 bat.2.3 r9 tmp.9))
               (tmp.9 (bar.7.7 foo.5.4 bar.3.2))
               (tmp.10 (bar.7.7 foo.5.4))
               (foo.5.4
                (bar.7.7 bar.8.8 bar.8.1 bar.3.2 bat.2.3 foobar.0.6 r9 r8 rcx tmp.9 tmp.10 tmp.11))
               (tmp.11 (foo.5.4))
               (bar.7.5 (foobar.0.6 r9 r8 rcx rdx))
               (bat.2.3 (bar.8.1 bar.3.2 foo.5.4 foobar.0.6 r9 r8))
               (bar.8.1 (foo.5.4 bar.3.2 foobar.0.6 bat.2.3))
               (bar.8.8 (foo.5.4 bar.3.2 foobar.0.6))
               (rsi (foobar.0.6))
               (rdx (bar.7.5 foobar.0.6))
               (rcx (foo.5.4 bar.7.5 foobar.0.6))
               (r8 (bat.2.3 foo.5.4 bar.7.5 foobar.0.6))
               (r9 (bar.3.2 bat.2.3 foo.5.4 bar.7.5 foobar.0.6)))))
            (begin
              (set! foobar.0.6 rdi)
              (set! bar.7.5 rsi)
              (set! foo.5.4 rdx)
              (set! bat.2.3 rcx)
              (set! bar.3.2 r8)
              (set! bar.8.1 r9)
              (set! bar.8.8 bat.2.3)
              (set! bar.7.7 1)
              (if (if (!= bar.7.7 foobar.0.6)
                      (begin
                        (set! tmp.9 -494940107)
                        (<= tmp.9 bar.3.2))
                      (begin
                        (set! tmp.10 0)
                        (< tmp.10 1869530139)))
                  (if (<= bar.7.7 0)
                      (halt 0)
                      (halt -777687734))
                  (if (begin
                        (set! tmp.11 -9223372036854775808)
                        (> tmp.11 foo.5.4))
                      (halt 9223372036854775807)
                      (halt -9223372036854775808)))))
    (halt 9223372036854775807)))
(check-by-interp
 '(module ((locals (tmp.3 foo.0.2 foo.8.1)) (undead-out (() (() () ()) (((tmp.3) ()) () ())))
                                            (conflicts ((foo.8.1 ()) (foo.0.2 ()) (tmp.3 ()))))
          (if (true)
              (begin
                (set! foo.0.2 1)
                (set! foo.8.1 0)
                (halt 356048754))
              (if (begin
                    (set! tmp.3 -1287356538)
                    (<= tmp.3 1126106862))
                  (halt 4712028)
                  (halt 349517812)))
    ))
(check-by-interp
 '(module ((locals (ball.6.42 bat.4.44 foobar.7.43 bar.5.41 bar.2.40 bat.4.39 tmp.54))
           (undead-out (((tmp.54) ()) ((bar.5.41) (bar.5.41) (bar.5.41) ()) (() () (ball.6.42) ())))
           (conflicts ((tmp.54 ()) (bat.4.39 (bar.5.41))
                                   (bar.2.40 (bar.5.41))
                                   (bar.5.41 (bat.4.39 bar.2.40))
                                   (foobar.7.43 ())
                                   (bat.4.44 ())
                                   (ball.6.42 ()))))
          (define L.fn.0.1
            ((locals (ball.6.11 bar.2.12
                                bar.5.17
                                bar.8.18
                                foobar.1.19
                                foobar.0.13
                                bat.4.14
                                ball.3.15
                                ball.6.16
                                tmp.47
                                bar.8.3
                                tmp.46
                                foobar.0.4
                                bat.4.8
                                ball.3.9
                                bar.8.10
                                ball.3.5
                                bar.2.6
                                foobar.7.7
                                bar.8.2
                                tmp.45
                                foobar.1.1
                                tmp.48))
             (undead-out ((tmp.45) (tmp.45)
                                   (bar.8.2)
                                   (foobar.7.7 bar.8.2)
                                   (foobar.7.7 bar.8.2)
                                   (bar.8.2)
                                   (bar.8.2)
                                   (bar.8.2)
                                   (bar.8.2)
                                   (foobar.0.4 bar.8.2)
                                   (tmp.46 foobar.0.4 bar.8.2)
                                   (tmp.46 foobar.0.4 bar.8.2)
                                   (bar.8.3 foobar.0.4 bar.8.2)
                                   (((tmp.47 bar.8.3 foobar.0.4 bar.8.2) (bar.8.3 foobar.0.4 bar.8.2))
                                    (bar.8.2 foobar.1.1)
                                    (bar.8.2 foobar.1.1))
                                   (bar.8.2 foobar.1.1)
                                   (bar.8.2 ball.3.15 foobar.1.1)
                                   (ball.3.15 foobar.1.1)
                                   (foobar.1.1)
                                   (foobar.1.1)
                                   (foobar.1.1)
                                   (foobar.1.1)
                                   (foobar.1.1)
                                   (foobar.1.1)
                                   (((foobar.1.1 tmp.48) ()) () ())))
             (conflicts ((tmp.48 (foobar.1.1)) (foobar.1.1 (ball.6.11 bar.2.12
                                                                      bar.5.17
                                                                      bar.8.18
                                                                      foobar.0.13
                                                                      bat.4.14
                                                                      ball.3.15
                                                                      ball.6.16
                                                                      bar.8.2
                                                                      tmp.48))
                                               (tmp.45 ())
                                               (bar.8.2 (ball.3.15 ball.6.16
                                                                   tmp.47
                                                                   foobar.1.1
                                                                   bar.8.3
                                                                   tmp.46
                                                                   foobar.0.4
                                                                   bat.4.8
                                                                   ball.3.9
                                                                   bar.8.10
                                                                   ball.3.5
                                                                   bar.2.6
                                                                   foobar.7.7))
                                               (foobar.7.7 (bar.2.6 bar.8.2))
                                               (bar.2.6 (bar.8.2 foobar.7.7))
                                               (ball.3.5 (bar.8.2))
                                               (bar.8.10 (bar.8.2))
                                               (ball.3.9 (bar.8.2))
                                               (bat.4.8 (bar.8.2))
                                               (foobar.0.4 (tmp.47 bar.8.3 tmp.46 bar.8.2))
                                               (tmp.46 (bar.8.2 foobar.0.4))
                                               (bar.8.3 (tmp.47 bar.8.2 foobar.0.4))
                                               (tmp.47 (bar.8.2 foobar.0.4 bar.8.3))
                                               (ball.6.16 (foobar.1.1 bar.8.2))
                                               (ball.3.15 (bat.4.14 foobar.1.1 bar.8.2))
                                               (bat.4.14 (foobar.1.1 ball.3.15))
                                               (foobar.0.13 (foobar.1.1))
                                               (foobar.1.19 ())
                                               (bar.8.18 (foobar.1.1))
                                               (bar.5.17 (foobar.1.1))
                                               (bar.2.12 (foobar.1.1))
                                               (ball.6.11 (foobar.1.1)))))
            (begin
              (set! tmp.45 -9223372036854775808)
              (set! tmp.45 (* tmp.45 0))
              (set! bar.8.2 tmp.45)
              (set! foobar.7.7 0)
              (set! bar.2.6 9223372036854775807)
              (set! ball.3.5 foobar.7.7)
              (set! bar.8.10 1)
              (set! ball.3.9 -9223372036854775808)
              (set! bat.4.8 0)
              (set! foobar.0.4 0)
              (set! tmp.46 2146083242)
              (set! tmp.46 (+ tmp.46 1877941467))
              (set! bar.8.3 tmp.46)
              (if (begin
                    (set! tmp.47 1)
                    (>= tmp.47 0))
                  (set! foobar.1.1 foobar.0.4)
                  (set! foobar.1.1 bar.8.3))
              (set! ball.6.16 9223372036854775807)
              (set! ball.3.15 1)
              (set! bat.4.14 bar.8.2)
              (set! foobar.0.13 ball.3.15)
              (set! foobar.1.19 foobar.1.1)
              (set! bar.8.18 -80057626)
              (set! bar.5.17 451403960)
              (set! bar.2.12 0)
              (set! ball.6.11 -9223372036854775808)
              (if (begin
                    (set! tmp.48 0)
                    (= tmp.48 foobar.1.1))
                  (halt 1)
                  (halt -9223372036854775808))))
    (define L.func.1.2
      ((locals (bat.4.20 bar.2.21 foobar.0.22 ball.6.23 foobar.1.25 ball.3.26 foobar.7.24 tmp.49))
       (undead-out
        ((rsi rdx rcx r8 r9 fv0 rbp)
         (rdx rcx r8 r9 fv0 rbp)
         (rcx r8 r9 fv0 foobar.7.24 rbp)
         (r8 r9 fv0 foobar.7.24 rbp)
         (r9 fv0 foobar.7.24 rbp)
         (fv0 foobar.7.24 rbp)
         (foobar.7.24 rbp)
         (((tmp.49 foobar.7.24 rbp) (foobar.7.24 rbp))
          ((rcx rbp) (rcx rdx rbp) (rcx rdx rsi rbp) (rcx rdx rsi rdi rbp) (rcx rdx rsi rdi rbp))
          (rbp))))
       (conflicts ((tmp.49 (rbp foobar.7.24))
                   (foobar.7.24 (bat.4.20 bar.2.21 foobar.0.22 ball.6.23 rbp fv0 r9 r8 rcx tmp.49))
                   (ball.3.26 (rbp fv0 r9 r8 rcx rdx rsi))
                   (foobar.1.25 (rbp fv0 r9 r8 rcx rdx))
                   (ball.6.23 (rbp foobar.7.24 fv0 r9 r8))
                   (foobar.0.22 (rbp foobar.7.24 fv0 r9))
                   (bar.2.21 (rbp foobar.7.24 fv0))
                   (bat.4.20 (rbp foobar.7.24))
                   (rcx (foobar.7.24 foobar.1.25 ball.3.26 rdi rsi rdx rbp))
                   (rbp (bat.4.20 bar.2.21
                                  foobar.0.22
                                  ball.6.23
                                  foobar.7.24
                                  foobar.1.25
                                  ball.3.26
                                  tmp.49
                                  rdi
                                  rsi
                                  rdx
                                  rcx))
                   (rdx (foobar.1.25 ball.3.26 rdi rsi rbp rcx))
                   (rsi (ball.3.26 rdi rbp rdx rcx))
                   (rdi (rbp rsi rdx rcx))
                   (r8 (ball.6.23 foobar.7.24 foobar.1.25 ball.3.26))
                   (r9 (foobar.0.22 ball.6.23 foobar.7.24 foobar.1.25 ball.3.26))
                   (fv0 (bar.2.21 foobar.0.22 ball.6.23 foobar.7.24 foobar.1.25 ball.3.26)))))
      (begin
        (set! ball.3.26 rdi)
        (set! foobar.1.25 rsi)
        (set! foobar.7.24 rdx)
        (set! ball.6.23 rcx)
        (set! foobar.0.22 r8)
        (set! bar.2.21 r9)
        (set! bat.4.20 fv0)
        (if (begin
              (set! tmp.49 -68053908)
              (>= tmp.49 1924767324))
            (begin
              (set! rcx foobar.7.24)
              (set! rdx 2037093174)
              (set! rsi 2020389049)
              (set! rdi 0)
              (jump L.func.2.3 rbp rdi rsi rdx rcx))
            (jump L.fn.0.1 rbp))))
    (define L.func.2.3
      ((locals (tmp.53 bar.8.31
                       tmp.51
                       ball.3.32
                       bar.5.33
                       foobar.7.34
                       tmp.50
                       bar.8.35
                       bar.2.36
                       ball.3.37
                       bat.4.38
                       bar.8.27
                       ball.3.28
                       bat.4.29
                       foobar.0.30
                       tmp.52))
       (undead-out
        ((rsi rdx rcx foobar.0.30)
         (rdx rcx foobar.0.30 bat.4.29)
         (rcx foobar.0.30 ball.3.28 bat.4.29)
         (foobar.0.30 ball.3.28 bat.4.29)
         (foobar.0.30 ball.3.28 bat.4.29)
         (foobar.0.30 ball.3.28 bat.4.29)
         (foobar.0.30 ball.3.28 bat.4.29)
         (((foobar.0.30 tmp.50 ball.3.28 bat.4.29) (ball.3.28 bat.4.29)) (ball.3.28 bat.4.29)
                                                                         (ball.3.28 bat.4.29))
         (ball.3.28 bat.4.29)
         (bat.4.29)
         (bat.4.29)
         (tmp.51 bat.4.29)
         (tmp.51 bat.4.29)
         (bat.4.29)
         (bat.4.29 tmp.53)
         (tmp.53)
         (tmp.52)
         ()))
       (conflicts
        ((tmp.52 ())
         (foobar.0.30 (tmp.50 bar.2.36 ball.3.37 bat.4.38 bar.8.27 ball.3.28 bat.4.29 rcx rdx rsi))
         (bat.4.29 (tmp.53 bar.8.31
                           tmp.51
                           ball.3.32
                           bar.5.33
                           foobar.7.34
                           tmp.50
                           bar.8.35
                           bar.2.36
                           ball.3.37
                           bat.4.38
                           bar.8.27
                           ball.3.28
                           foobar.0.30
                           rcx
                           rdx))
         (ball.3.28
          (foobar.7.34 tmp.50 bar.8.35 bar.2.36 ball.3.37 bat.4.38 bar.8.27 bat.4.29 foobar.0.30 rcx))
         (bar.8.27 (bat.4.29 ball.3.28 foobar.0.30))
         (bat.4.38 (bat.4.29 ball.3.28 foobar.0.30))
         (ball.3.37 (bat.4.29 ball.3.28 foobar.0.30))
         (bar.2.36 (bat.4.29 ball.3.28 foobar.0.30))
         (bar.8.35 (bat.4.29 ball.3.28))
         (tmp.50 (bat.4.29 ball.3.28 foobar.0.30))
         (foobar.7.34 (bat.4.29 ball.3.28))
         (bar.5.33 (bat.4.29))
         (ball.3.32 (bat.4.29))
         (tmp.51 (bat.4.29))
         (bar.8.31 (bat.4.29))
         (tmp.53 (bat.4.29))
         (rsi (foobar.0.30))
         (rdx (bat.4.29 foobar.0.30))
         (rcx (ball.3.28 bat.4.29 foobar.0.30)))))
      (begin
        (set! foobar.0.30 rdi)
        (set! bat.4.29 rsi)
        (set! ball.3.28 rdx)
        (set! bar.8.27 rcx)
        (set! bat.4.38 1683456577)
        (set! ball.3.37 0)
        (set! bar.2.36 572391381)
        (if (begin
              (set! tmp.50 9223372036854775807)
              (>= tmp.50 foobar.0.30))
            (set! bar.8.35 -2023903597)
            (set! bar.8.35 -15104029))
        (set! foobar.7.34 1)
        (set! bar.5.33 ball.3.28)
        (set! ball.3.32 0)
        (set! tmp.51 bat.4.29)
        (set! tmp.51 (+ tmp.51 bat.4.29))
        (set! bar.8.31 tmp.51)
        (set! tmp.53 1)
        (set! tmp.53 (+ tmp.53 bat.4.29))
        (set! tmp.52 tmp.53)
        (halt tmp.52)))
    (if (not (begin
               (set! tmp.54 512244517)
               (> tmp.54 -294049298)))
        (begin
          (set! bar.5.41 1283186732)
          (set! bar.2.40 99039009)
          (set! bat.4.39 1811100583)
          (halt bar.5.41))
        (begin
          (set! bat.4.44 1)
          (set! foobar.7.43 -9223372036854775808)
          (set! ball.6.42 1)
          (halt ball.6.42)))))
(check-by-interp
 '(module ((locals (tmp.29)) (undead-out (((tmp.29) ()) () ())) (conflicts ((tmp.29 ()))))
          (define L.proc.0.1
            ((locals (foobar.0.1 foobar.4.2 bar.7.3 bat.1.4 foobar.8.5))
             (undead-out ((rsi rdx rcx r8 foobar.8.5 rbp) (rdx rcx r8 foobar.8.5 bat.1.4 rbp)
                                                          (rcx r8 foobar.8.5 bat.1.4 rbp)
                                                          (r8 foobar.8.5 bat.1.4 rbp)
                                                          (foobar.8.5 bat.1.4 foobar.0.1 rbp)
                                                          (foobar.8.5 bat.1.4 foobar.0.1 r9 rbp)
                                                          (bat.1.4 foobar.0.1 r9 r8 rbp)
                                                          (bat.1.4 foobar.0.1 r9 r8 rcx rbp)
                                                          (bat.1.4 foobar.0.1 r9 r8 rcx rdx rbp)
                                                          (foobar.0.1 r9 r8 rcx rdx rsi rbp)
                                                          (r9 r8 rcx rdx rsi rdi rbp)
                                                          (r9 r8 rcx rdx rsi rdi rbp)))
             (conflicts
              ((foobar.8.5 (r9 foobar.0.1 foobar.4.2 bar.7.3 bat.1.4 rbp r8 rcx rdx rsi))
               (bat.1.4 (r9 foobar.0.1 foobar.4.2 bar.7.3 rbp foobar.8.5 r8 rcx rdx))
               (bar.7.3 (rbp bat.1.4 foobar.8.5 r8 rcx))
               (foobar.4.2 (rbp bat.1.4 foobar.8.5 r8))
               (foobar.0.1 (rsi rdx rcx r8 r9 rbp bat.1.4 foobar.8.5))
               (rsi (rdi rbp rdx rcx r8 r9 foobar.0.1 foobar.8.5))
               (rdx (rdi rsi rbp rcx r8 r9 foobar.0.1 bat.1.4 foobar.8.5))
               (rcx (rdi rsi rdx rbp r8 r9 foobar.0.1 bar.7.3 bat.1.4 foobar.8.5))
               (r8 (rdi rsi rdx rcx rbp r9 foobar.0.1 foobar.4.2 bar.7.3 bat.1.4 foobar.8.5))
               (rbp (rdi rsi rdx rcx r8 r9 foobar.0.1 foobar.4.2 bar.7.3 bat.1.4 foobar.8.5))
               (r9 (rdi rsi rdx rcx r8 rbp foobar.0.1 bat.1.4 foobar.8.5))
               (rdi (rbp rsi rdx rcx r8 r9)))))
            (begin
              (set! foobar.8.5 rdi)
              (set! bat.1.4 rsi)
              (set! bar.7.3 rdx)
              (set! foobar.4.2 rcx)
              (set! foobar.0.1 r8)
              (set! r9 9223372036854775807)
              (set! r8 foobar.8.5)
              (set! rcx -9223372036854775808)
              (set! rdx 1)
              (set! rsi bat.1.4)
              (set! rdi foobar.0.1)
              (jump L.proc.2.3 rbp rdi rsi rdx rcx r8 r9)))
    (define L.x.1.2
      ((locals (foobar.3.14 tmp.25
                            bar.2.6
                            foobar.4.12
                            tmp.26
                            foobar.8.11
                            foobar.8.15
                            bat.1.13
                            tmp.23
                            foobar.0.10
                            foobar.4.7
                            tmp.22
                            foo.5.9
                            bar.2.8
                            tmp.24))
       (undead-out ((rsi foobar.4.7) (bar.2.6 foobar.4.7)
                                     ((bar.2.6 foobar.4.7) (((foobar.4.7) (foobar.4.7 foobar.0.10)
                                                                          (foobar.4.7 foobar.0.10))
                                                            (tmp.22 foobar.0.10)
                                                            (tmp.22 foobar.0.10)
                                                            (foobar.0.10)
                                                            (foobar.0.10)
                                                            (foobar.0.10 tmp.24)
                                                            (tmp.24)
                                                            (tmp.23)
                                                            ())
                                                           ((tmp.25 foobar.4.7 bar.2.6)
                                                            (tmp.25 foobar.4.7 bar.2.6)
                                                            (foobar.4.7 bar.2.6)
                                                            (foobar.4.7 tmp.26 bar.2.6)
                                                            (tmp.26 bar.2.6)
                                                            (bar.2.6)
                                                            (bar.2.6)
                                                            (bar.2.6 foobar.3.14)
                                                            (foobar.3.14)
                                                            ()))))
       (conflicts
        ((tmp.24 ())
         (bar.2.8 (foobar.0.10))
         (foo.5.9 (foobar.0.10))
         (tmp.22 (foobar.0.10))
         (foobar.4.7 (bar.2.6 rsi tmp.26 foobar.4.12 tmp.25))
         (foobar.0.10 (bar.2.8 foo.5.9 tmp.22))
         (tmp.23 ())
         (bat.1.13 (foobar.3.14))
         (foobar.8.15 (bar.2.6))
         (foobar.8.11 (bar.2.6))
         (tmp.26 (bar.2.6 foobar.4.7))
         (foobar.4.12 (bar.2.6 foobar.4.7))
         (bar.2.6 (foobar.4.7 foobar.3.14 foobar.8.15 foobar.8.11 tmp.26 foobar.4.12 tmp.25))
         (tmp.25 (bar.2.6 foobar.4.7))
         (foobar.3.14 (bat.1.13 bar.2.6))
         (rsi (foobar.4.7)))))
      (begin
        (set! foobar.4.7 rdi)
        (set! bar.2.6 rsi)
        (if (true)
            (begin
              (if (< foobar.4.7 foobar.4.7)
                  (set! foobar.0.10 foobar.4.7)
                  (set! foobar.0.10 foobar.4.7))
              (set! tmp.22 foobar.4.7)
              (set! tmp.22 (* tmp.22 -1298566605))
              (set! foo.5.9 tmp.22)
              (set! bar.2.8 0)
              (set! tmp.24 foobar.0.10)
              (set! tmp.24 (* tmp.24 foobar.0.10))
              (set! tmp.23 tmp.24)
              (halt tmp.23))
            (begin
              (set! tmp.25 -1679672366)
              (set! tmp.25 (+ tmp.25 bar.2.6))
              (set! foobar.4.12 tmp.25)
              (set! tmp.26 0)
              (set! tmp.26 (+ tmp.26 foobar.4.7))
              (set! foobar.8.11 tmp.26)
              (set! foobar.8.15 0)
              (set! foobar.3.14 -511883263)
              (set! bat.1.13 bar.2.6)
              (halt foobar.3.14)))))
    (define L.proc.2.3
      ((locals (tmp.28 foo.9.16 bar.7.17 foobar.3.18 foobar.4.19 bat.1.20 foo.5.21 tmp.27))
       (undead-out ((rsi rdx rcx r8 r9) (rdx rcx r8 r9)
                                        (rcx r8 r9)
                                        (r8 r9)
                                        (r9 bar.7.17)
                                        (bar.7.17)
                                        (tmp.28)
                                        (tmp.28)
                                        (tmp.27)
                                        ()))
       (conflicts ((tmp.27 ()) (foo.5.21 (r9 r8 rcx rdx rsi))
                               (bat.1.20 (r9 r8 rcx rdx))
                               (foobar.4.19 (r9 r8 rcx))
                               (foobar.3.18 (r9 r8))
                               (bar.7.17 (foo.9.16 r9))
                               (foo.9.16 (bar.7.17))
                               (tmp.28 ())
                               (rsi (foo.5.21))
                               (rdx (bat.1.20 foo.5.21))
                               (rcx (foobar.4.19 bat.1.20 foo.5.21))
                               (r8 (foobar.3.18 foobar.4.19 bat.1.20 foo.5.21))
                               (r9 (bar.7.17 foobar.3.18 foobar.4.19 bat.1.20 foo.5.21)))))
      (begin
        (set! foo.5.21 rdi)
        (set! bat.1.20 rsi)
        (set! foobar.4.19 rdx)
        (set! foobar.3.18 rcx)
        (set! bar.7.17 r8)
        (set! foo.9.16 r9)
        (set! tmp.28 bar.7.17)
        (set! tmp.28 (+ tmp.28 -9223372036854775808))
        (set! tmp.27 tmp.28)
        (halt tmp.27)))
    (if (begin
          (set! tmp.29 1)
          (> tmp.29 -735340476))
        (halt -9223372036854775808)
        (halt -1627211406))))
(check-by-interp
 '(module ((locals (bar.5.13 foobar.3.15 ball.0.16 bar.5.17 bat.7.18 bar.8.14 tmp.20))
           (undead-out (() (bar.5.17)
                           (bar.5.17)
                           ()
                           (bar.8.14)
                           (bar.8.14)
                           (((tmp.20 bar.8.14) (bar.8.14)) () ())))
           (conflicts ((tmp.20 (bar.8.14)) (bar.8.14 (bar.5.13 tmp.20))
                                           (bat.7.18 ())
                                           (bar.5.17 (ball.0.16))
                                           (ball.0.16 (bar.5.17))
                                           (foobar.3.15 ())
                                           (bar.5.13 (bar.8.14)))))
          (define L.x.0.1
            ((locals (bat.7.7 foobar.3.1
                              foobar.3.6
                              bar.5.5
                              bat.7.4
                              bat.7.10
                              bar.5.9
                              foobar.1.8
                              bat.4.3
                              tmp.19
                              ball.0.2
                              foobar.3.12
                              ball.0.11))
             (undead-out ((rbp foobar.3.1)
                          ((rbp foobar.3.1) ((bat.7.7 foobar.3.1) (bat.7.7 foobar.3.1)
                                                                  (bat.7.7 foobar.3.1)
                                                                  (foobar.3.1)
                                                                  (foobar.3.1)
                                                                  (foobar.3.1)
                                                                  (foobar.3.1)
                                                                  (foobar.3.1)
                                                                  (tmp.19 foobar.3.1)
                                                                  (tmp.19 foobar.3.1)
                                                                  (foobar.3.1)
                                                                  ()
                                                                  ()
                                                                  ())
                                            ((rdi rbp) (rdi rbp)))))
             (conflicts
              ((ball.0.11 ())
               (foobar.3.12 ())
               (ball.0.2 (foobar.3.1))
               (tmp.19 (foobar.3.1))
               (bat.4.3 (foobar.3.1))
               (foobar.1.8 (foobar.3.1))
               (bar.5.9 (foobar.3.1))
               (bat.7.10 ())
               (bat.7.4 (foobar.3.1))
               (bar.5.5 (foobar.3.1 bat.7.7))
               (foobar.3.6 (bat.7.7))
               (foobar.3.1 (rbp ball.0.2 tmp.19 bat.4.3 foobar.1.8 bar.5.9 bat.7.4 bar.5.5 bat.7.7))
               (bat.7.7 (bar.5.5 foobar.3.6 foobar.3.1))
               (rdi (rbp))
               (rbp (foobar.3.1 rdi)))))
            (begin
              (set! foobar.3.1 rdi)
              (if (not (false))
                  (begin
                    (set! bat.7.7 -508084756)
                    (set! foobar.3.6 foobar.3.1)
                    (set! bar.5.5 1)
                    (set! bat.7.4 bat.7.7)
                    (set! bat.7.10 foobar.3.1)
                    (set! bar.5.9 1120136428)
                    (set! foobar.1.8 606194936)
                    (set! bat.4.3 -908142049)
                    (set! tmp.19 600266106)
                    (set! tmp.19 (+ tmp.19 foobar.3.1))
                    (set! ball.0.2 tmp.19)
                    (set! foobar.3.12 foobar.3.1)
                    (set! ball.0.11 0)
                    (halt 1))
                  (begin
                    (set! rdi -2072909432)
                    (jump L.x.0.1 rbp rdi)))))
    (begin
      (set! bat.7.18 -1755065230)
      (set! bar.5.17 9223372036854775807)
      (set! ball.0.16 0)
      (set! foobar.3.15 bar.5.17)
      (set! bar.8.14 -9223372036854775808)
      (set! bar.5.13 -9223372036854775808)
      (if (begin
            (set! tmp.20 1)
            (< tmp.20 bar.8.14))
          (halt bar.8.14)
          (halt -9223372036854775808)))))
(check-by-interp '(module ((locals (foobar.5.4 bar.1.1 tmp.8 tmp.7 bar.6.2 bar.4.3 tmp.6 bar.4.5))
                           (undead-out ((tmp.6) (tmp.6)
                                                (bar.4.3)
                                                (((tmp.7 bar.4.3) (bar.4.3)) (bar.4.3) (bar.4.3))
                                                (tmp.8 bar.4.3)
                                                (tmp.8 bar.4.3)
                                                (bar.4.3)
                                                (bar.4.5)
                                                (bar.4.5)
                                                ()))
                           (conflicts ((bar.4.5 (foobar.5.4)) (tmp.6 ())
                                                              (bar.4.3 (bar.1.1 tmp.8 tmp.7 bar.6.2))
                                                              (bar.6.2 (bar.4.3))
                                                              (tmp.7 (bar.4.3))
                                                              (tmp.8 (bar.4.3))
                                                              (bar.1.1 (bar.4.3))
                                                              (foobar.5.4 (bar.4.5)))))
                          (begin
                            (set! tmp.6 993422572)
                            (set! tmp.6 (* tmp.6 1))
                            (set! bar.4.3 tmp.6)
                            (if (begin
                                  (set! tmp.7 92310708)
                                  (<= tmp.7 1290581674))
                                (set! bar.6.2 1)
                                (set! bar.6.2 0))
                            (set! tmp.8 9223372036854775807)
                            (set! tmp.8 (+ tmp.8 -1759699484))
                            (set! bar.1.1 tmp.8)
                            (set! bar.4.5 bar.4.3)
                            (set! foobar.5.4 -9223372036854775808)
                            (halt bar.4.5))
                    ))
(check-by-interp
 '(module ((locals ()) (undead-out (rbp)) (conflicts ()))
          (define L.func.0.1
            ((locals (tmp.11 bar.6.5
                             tmp.10
                             foo.0.6
                             tmp.9
                             tmp.14
                             bat.2.4
                             tmp.15
                             bat.3.8
                             foobar.4.2
                             bar.6.7
                             tmp.13
                             tmp.12
                             bar.6.1
                             foo.7.3))
             (undead-out
              ((bar.6.1)
               (tmp.9 bar.6.1)
               (tmp.9 bar.6.1)
               (bar.6.1)
               (tmp.10 bar.6.1)
               (tmp.10 bar.6.1)
               (bar.6.5 bar.6.1)
               (((bar.6.5 tmp.11 bar.6.1) (bar.6.1)) (bar.6.1 bat.2.4) (bar.6.1 bat.2.4))
               (bar.6.1 bat.2.4 foo.7.3)
               (bar.6.1 bat.2.4 foobar.4.2 foo.7.3)
               (((bar.6.1 bat.2.4 foobar.4.2 foo.7.3)
                 ((tmp.12 bar.6.1 bat.2.4 foobar.4.2 foo.7.3) (bar.6.1 bat.2.4 foobar.4.2 foo.7.3))
                 ((tmp.13 bar.6.1 bat.2.4 foobar.4.2 foo.7.3) (bar.6.1 bat.2.4 foobar.4.2 foo.7.3)))
                ((foobar.4.2 foo.7.3) (foo.7.3) ())
                ((bar.6.1 tmp.15) (tmp.15) (tmp.14) ()))))
             (conflicts ((foo.7.3 (foobar.4.2 bat.2.4 tmp.12 tmp.13 bar.6.7 bat.3.8))
                         (bar.6.1 (tmp.11 bat.2.4 bar.6.5 tmp.10 foo.0.6 tmp.9 tmp.12 tmp.13 tmp.15))
                         (tmp.12 (foo.7.3 foobar.4.2 bat.2.4 bar.6.1))
                         (tmp.13 (foo.7.3 foobar.4.2 bat.2.4 bar.6.1))
                         (bar.6.7 (foo.7.3))
                         (foobar.4.2 (foo.7.3 bat.2.4 tmp.12 tmp.13 bat.3.8))
                         (bat.3.8 (foo.7.3 foobar.4.2))
                         (tmp.15 (bar.6.1))
                         (bat.2.4 (foobar.4.2 foo.7.3 bar.6.1 tmp.12 tmp.13))
                         (tmp.14 ())
                         (tmp.9 (bar.6.1))
                         (foo.0.6 (bar.6.1))
                         (tmp.10 (bar.6.1))
                         (bar.6.5 (tmp.11 bar.6.1))
                         (tmp.11 (bar.6.1 bar.6.5)))))
            (begin
              (set! bar.6.1 rdi)
              (set! tmp.9 -9223372036854775808)
              (set! tmp.9 (+ tmp.9 -9223372036854775808))
              (set! foo.0.6 tmp.9)
              (set! tmp.10 bar.6.1)
              (set! tmp.10 (+ tmp.10 1312056768))
              (set! bar.6.5 tmp.10)
              (if (begin
                    (set! tmp.11 1)
                    (<= tmp.11 bar.6.5))
                  (set! bat.2.4 -9223372036854775808)
                  (set! bat.2.4 -50606571))
              (set! foo.7.3 bar.6.1)
              (set! foobar.4.2 bar.6.1)
              (if (if (>= foo.7.3 bar.6.1)
                      (begin
                        (set! tmp.12 0)
                        (< tmp.12 foo.7.3))
                      (begin
                        (set! tmp.13 1880363761)
                        (!= tmp.13 9223372036854775807)))
                  (begin
                    (set! bat.3.8 1)
                    (set! bar.6.7 foobar.4.2)
                    (halt foo.7.3))
                  (begin
                    (set! tmp.15 bat.2.4)
                    (set! tmp.15 (+ tmp.15 bar.6.1))
                    (set! tmp.14 tmp.15)
                    (halt tmp.14)))))
    (define L.x.1.2
      ((locals (tmp.16 tmp.17)) (undead-out (() () ((tmp.17) (tmp.17) (tmp.16) ())))
                                (conflicts ((tmp.17 ()) (tmp.16 ()))))
      (if (true)
          (halt -9223372036854775808)
          (begin
            (set! tmp.17 0)
            (set! tmp.17 (+ tmp.17 9223372036854775807))
            (set! tmp.16 tmp.17)
            (halt tmp.16))))
    (jump L.x.1.2 rbp)))
(check-by-interp
 '(module ((locals (foo.4.5 foobar.2.4 tmp.6)) (undead-out (((tmp.6) ()) (() () ()) ()))
                                               (conflicts ((tmp.6 ()) (foobar.2.4 ()) (foo.4.5 ()))))
          (define L.x.0.1
            ((locals (foobar.1.1 ball.6.2 ball.8.3))
             (undead-out ((rsi rdx ball.8.3 rbp) (rdx ball.8.3 rbp)
                                                 (ball.8.3 foobar.1.1 rbp)
                                                 (ball.8.3 foobar.1.1 rdx rbp)
                                                 (foobar.1.1 rdx rsi rbp)
                                                 (rdx rsi rdi rbp)
                                                 (rdx rsi rdi rbp)))
             (conflicts ((ball.8.3 (foobar.1.1 ball.6.2 rbp rdx rsi))
                         (ball.6.2 (rbp ball.8.3 rdx))
                         (foobar.1.1 (rsi rdx rbp ball.8.3))
                         (rsi (rdi rbp rdx foobar.1.1 ball.8.3))
                         (rdx (rdi rsi rbp foobar.1.1 ball.6.2 ball.8.3))
                         (rbp (rdi rsi rdx foobar.1.1 ball.6.2 ball.8.3))
                         (rdi (rbp rsi rdx)))))
            (begin
              (set! ball.8.3 rdi)
              (set! ball.6.2 rsi)
              (set! foobar.1.1 rdx)
              (set! rdx 0)
              (set! rsi ball.8.3)
              (set! rdi foobar.1.1)
              (jump L.x.0.1 rbp rdi rsi rdx)))
    (if (begin
          (set! tmp.6 9223372036854775807)
          (> tmp.6 1757631774))
        (begin
          (set! foo.4.5 0)
          (set! foobar.2.4 213435043)
          (halt -9223372036854775808))
        (halt 0))))
(check-by-interp
 '(module ((locals (bat.2.2 bat.0.3 ball.5.1 tmp.4))
           (undead-out (((tmp.4) ()) (() (bat.2.2) (bat.2.2) ()) ()))
           (conflicts ((tmp.4 ()) (ball.5.1 (bat.2.2)) (bat.0.3 ()) (bat.2.2 (ball.5.1)))))
          (if (not (begin
                     (set! tmp.4 1946235623)
                     (< tmp.4 -9223372036854775808)))
              (begin
                (set! bat.0.3 -135046761)
                (set! bat.2.2 1453915451)
                (set! ball.5.1 257292075)
                (halt bat.2.2))
              (halt -9223372036854775808))
    ))
(check-by-interp '(module ((locals (tmp.5 tmp.4)) (undead-out ((tmp.5) (tmp.5) (tmp.4) ()))
                                                  (conflicts ((tmp.4 ()) (tmp.5 ()))))
                          (define L.proc.0.1
                            ((locals (bar.8.1 foobar.9.3 foobar.3.2))
                             (undead-out ((rsi rdx) (rdx foobar.3.2) (foobar.3.2) ()))
                             (conflicts ((foobar.3.2 (bar.8.1 rdx)) (foobar.9.3 (rdx rsi))
                                                                    (bar.8.1 (foobar.3.2))
                                                                    (rsi (foobar.9.3))
                                                                    (rdx (foobar.3.2 foobar.9.3)))))
                            (begin
                              (set! foobar.9.3 rdi)
                              (set! foobar.3.2 rsi)
                              (set! bar.8.1 rdx)
                              (halt foobar.3.2)))
                    (begin
                      (set! tmp.5 1)
                      (set! tmp.5 (* tmp.5 9223372036854775807))
                      (set! tmp.4 tmp.5)
                      (halt tmp.4))))
(check-by-interp
 '(module ((locals (tmp.20)) (undead-out (() () (((tmp.20) ()) () ()))) (conflicts ((tmp.20 ()))))
          (define L.proc.0.1
            ((locals (ball.0.1 foobar.7.2 bat.1.4 bar.5.5 tmp.17 tmp.18 foobar.2.3 foobar.3.6))
             (undead-out ((rsi rdx rcx r8 r9 foobar.3.6 rbp)
                          (rdx rcx r8 r9 foobar.3.6 rbp)
                          (rcx r8 r9 foobar.3.6 rbp)
                          (r8 r9 foobar.2.3 foobar.3.6 rbp)
                          (r9 foobar.2.3 foobar.3.6 rbp)
                          (foobar.2.3 foobar.3.6 rbp)
                          ((foobar.2.3 foobar.3.6 rbp)
                           ((foobar.2.3 foobar.3.6 fv0 rbp) (foobar.3.6 fv0 r9 rbp)
                                                            (foobar.3.6 fv0 r9 r8 rbp)
                                                            (foobar.3.6 fv0 r9 r8 rcx rbp)
                                                            (foobar.3.6 fv0 r9 r8 rcx rdx rbp)
                                                            (fv0 r9 r8 rcx rdx rsi rbp)
                                                            (fv0 r9 r8 rcx rdx rsi rdi rbp)
                                                            (fv0 r9 r8 rcx rdx rsi rdi rbp))
                           ((tmp.18) (tmp.18) (tmp.17) ()))))
             (conflicts
              ((foobar.3.6 (ball.0.1 foobar.7.2 foobar.2.3 bat.1.4 bar.5.5 rbp r8 rsi rdx rcx r9 fv0))
               (foobar.2.3 (ball.0.1 foobar.7.2 rbp foobar.3.6 r9 r8 fv0))
               (tmp.18 ())
               (tmp.17 ())
               (bar.5.5 (rbp foobar.3.6 r9 r8 rcx rdx))
               (bat.1.4 (rbp foobar.3.6 r9 r8 rcx))
               (foobar.7.2 (rbp foobar.3.6 foobar.2.3 r9))
               (ball.0.1 (rbp foobar.3.6 foobar.2.3))
               (fv0 (rdi rsi rdx rcx r8 r9 rbp foobar.3.6 foobar.2.3))
               (rbp
                (ball.0.1 foobar.7.2 foobar.2.3 bat.1.4 bar.5.5 foobar.3.6 rdi rsi rdx rcx r8 r9 fv0))
               (r9 (foobar.7.2 foobar.2.3 bat.1.4 bar.5.5 rdi rsi rdx rcx r8 rbp fv0 foobar.3.6))
               (r8 (foobar.2.3 bat.1.4 bar.5.5 foobar.3.6 rdi rsi rdx rcx rbp r9 fv0))
               (rcx (bat.1.4 bar.5.5 rdi rsi rdx rbp r8 r9 fv0 foobar.3.6))
               (rdx (bar.5.5 rdi rsi rbp rcx r8 r9 fv0 foobar.3.6))
               (rsi (foobar.3.6 rdi rbp rdx rcx r8 r9 fv0))
               (rdi (rbp rsi rdx rcx r8 r9 fv0)))))
            (begin
              (set! foobar.3.6 rdi)
              (set! bar.5.5 rsi)
              (set! bat.1.4 rdx)
              (set! foobar.2.3 rcx)
              (set! foobar.7.2 r8)
              (set! ball.0.1 r9)
              (if (true)
                  (begin
                    (set! fv0 1165846535)
                    (set! r9 foobar.2.3)
                    (set! r8 foobar.3.6)
                    (set! rcx 1407333795)
                    (set! rdx 0)
                    (set! rsi foobar.3.6)
                    (set! rdi 1843221563)
                    (jump L.func.1.2 rbp rdi rsi rdx rcx r8 r9 fv0))
                  (begin
                    (set! tmp.18 -1543779281)
                    (set! tmp.18 (+ tmp.18 1))
                    (set! tmp.17 tmp.18)
                    (halt tmp.17)))))
    (define L.func.1.2
      ((locals (bat.6.14 foobar.2.15
                         foobar.3.16
                         tmp.19
                         foobar.2.7
                         ball.0.8
                         foobar.7.9
                         bar.4.10
                         bar.9.11
                         bat.6.12
                         bar.5.13))
       (undead-out ((rsi rdx rcx r8 r9 fv0 rbp) (rdx rcx r8 r9 fv0 rbp)
                                                (rcx r8 r9 fv0 rbp)
                                                (r8 r9 fv0 bar.4.10 rbp)
                                                (r9 fv0 bar.4.10 rbp)
                                                (fv0 bar.4.10 ball.0.8 rbp)
                                                (bar.4.10 ball.0.8 rbp)
                                                (tmp.19 bar.4.10 ball.0.8 rbp)
                                                (tmp.19 bar.4.10 ball.0.8 rbp)
                                                (bar.4.10 ball.0.8 rbp)
                                                (bar.4.10 foobar.2.15 ball.0.8 rbp)
                                                (foobar.2.15 ball.0.8 rbp)
                                                (foobar.2.15 ball.0.8 fv0 rbp)
                                                (foobar.2.15 ball.0.8 fv0 r9 rbp)
                                                (foobar.2.15 ball.0.8 fv0 r9 r8 rbp)
                                                (ball.0.8 fv0 r9 r8 rcx rbp)
                                                (fv0 r9 r8 rcx rdx rbp)
                                                (fv0 r9 r8 rcx rdx rsi rbp)
                                                (fv0 r9 r8 rcx rdx rsi rdi rbp)
                                                (fv0 r9 r8 rcx rdx rsi rdi rbp)))
       (conflicts
        ((bar.5.13 (rbp fv0 r9 r8 rcx rdx rsi))
         (bat.6.12 (rbp fv0 r9 r8 rcx rdx))
         (bar.9.11 (rbp fv0 r9 r8 rcx))
         (bar.4.10 (foobar.2.15 foobar.3.16 tmp.19 foobar.2.7 ball.0.8 foobar.7.9 rbp fv0 r9 r8))
         (foobar.7.9 (rbp bar.4.10 fv0 r9))
         (ball.0.8 (rcx r9 bat.6.14 foobar.3.16 tmp.19 foobar.2.7 rbp bar.4.10 fv0))
         (foobar.2.7 (rbp ball.0.8 bar.4.10))
         (tmp.19 (rbp ball.0.8 bar.4.10))
         (foobar.3.16 (rbp ball.0.8 bar.4.10))
         (foobar.2.15 (r8 r9 bat.6.14 rbp bar.4.10))
         (bat.6.14 (rbp ball.0.8 foobar.2.15))
         (rsi (rdi rbp rdx rcx r8 r9 fv0 bar.5.13))
         (rdx (rdi rsi rbp rcx r8 r9 fv0 bat.6.12 bar.5.13))
         (rcx (rdi rsi rdx rbp r8 r9 fv0 ball.0.8 bar.9.11 bat.6.12 bar.5.13))
         (r8 (rdi rsi rdx rcx rbp r9 fv0 foobar.2.15 bar.4.10 bar.9.11 bat.6.12 bar.5.13))
         (r9 (rdi rsi
                  rdx
                  rcx
                  r8
                  rbp
                  fv0
                  ball.0.8
                  foobar.2.15
                  foobar.7.9
                  bar.4.10
                  bar.9.11
                  bat.6.12
                  bar.5.13))
         (fv0 (rdi rsi rdx rcx r8 r9 rbp ball.0.8 foobar.7.9 bar.4.10 bar.9.11 bat.6.12 bar.5.13))
         (rbp (rdi rsi
                   rdx
                   rcx
                   r8
                   r9
                   fv0
                   bat.6.14
                   foobar.2.15
                   foobar.3.16
                   tmp.19
                   foobar.2.7
                   ball.0.8
                   foobar.7.9
                   bar.4.10
                   bar.9.11
                   bat.6.12
                   bar.5.13))
         (rdi (rbp rsi rdx rcx r8 r9 fv0)))))
      (begin
        (set! bar.5.13 rdi)
        (set! bat.6.12 rsi)
        (set! bar.9.11 rdx)
        (set! bar.4.10 rcx)
        (set! foobar.7.9 r8)
        (set! ball.0.8 r9)
        (set! foobar.2.7 fv0)
        (set! tmp.19 -9223372036854775808)
        (set! tmp.19 (* tmp.19 ball.0.8))
        (set! foobar.3.16 tmp.19)
        (set! foobar.2.15 ball.0.8)
        (set! bat.6.14 bar.4.10)
        (set! fv0 foobar.2.15)
        (set! r9 -811936434)
        (set! r8 ball.0.8)
        (set! rcx foobar.2.15)
        (set! rdx ball.0.8)
        (set! rsi 0)
        (set! rdi -9223372036854775808)
        (jump L.func.1.2 rbp rdi rsi rdx rcx r8 r9 fv0)))
    (if (true)
        (halt -1263415267)
        (if (begin
              (set! tmp.20 9223372036854775807)
              (<= tmp.20 -514434406))
            (halt 9223372036854775807)
            (halt 9223372036854775807)))))
(check-by-interp
 '(module ((locals (bar.8.7 bat.9.10 ball.7.11 tmp.15 bat.3.8 tmp.14 ball.7.9 tmp.16))
           (undead-out ((tmp.14) (tmp.14)
                                 (ball.7.9)
                                 (((tmp.15 ball.7.9) (ball.7.9)) (ball.7.9) (ball.7.9))
                                 (ball.7.9)
                                 (ball.7.9)
                                 (ball.7.9)
                                 (((tmp.16 ball.7.9) (ball.7.9)) () ())))
           (conflicts ((tmp.16 (ball.7.9))
                       (ball.7.9 (bar.8.7 bat.9.10 ball.7.11 tmp.15 bat.3.8 tmp.16))
                       (tmp.14 ())
                       (bat.3.8 (ball.7.9))
                       (tmp.15 (ball.7.9))
                       (ball.7.11 (ball.7.9))
                       (bat.9.10 (ball.7.9))
                       (bar.8.7 (ball.7.9)))))
          (define L.proc.0.1
            ((locals (bar.8.1 bat.6.2)) (undead-out ((rsi rbp) (rbp) (rdi rbp) (rdi rbp)))
                                        (conflicts ((bat.6.2 (rbp rsi)) (bar.8.1 (rbp))
                                                                        (rsi (bat.6.2))
                                                                        (rbp (rdi bar.8.1 bat.6.2))
                                                                        (rdi (rbp)))))
            (begin
              (set! bat.6.2 rdi)
              (set! bar.8.1 rsi)
              (set! rdi -9223372036854775808)
              (jump L.tmp.1.2 rbp rdi)))
    (define L.tmp.1.2
      ((locals (bat.9.5 bar.2.6 bat.6.4 tmp.13 bat.6.3 tmp.12))
       (undead-out ((bat.6.3) (((tmp.12 bat.6.3) (bat.6.3))
                               ((bat.6.3) ((bat.6.3) (bat.6.3) (bat.6.4) ())
                                          (((tmp.13 bat.6.3) (bat.6.3)) () ()))
                               ())))
       (conflicts ((tmp.12 (bat.6.3)) (bat.6.3 (tmp.12 bar.2.6 tmp.13))
                                      (tmp.13 (bat.6.3))
                                      (bat.6.4 ())
                                      (bar.2.6 (bat.6.3))
                                      (bat.9.5 ()))))
      (begin
        (set! bat.6.3 rdi)
        (if (begin
              (set! tmp.12 9223372036854775807)
              (!= tmp.12 bat.6.3))
            (if (true)
                (begin
                  (set! bar.2.6 2026709313)
                  (set! bat.9.5 bat.6.3)
                  (set! bat.6.4 bat.6.3)
                  (halt bat.6.4))
                (if (begin
                      (set! tmp.13 1890937388)
                      (>= tmp.13 bat.6.3))
                    (halt bat.6.3)
                    (halt 1616264974)))
            (halt 9223372036854775807))))
    (begin
      (set! tmp.14 0)
      (set! tmp.14 (* tmp.14 1192307430))
      (set! ball.7.9 tmp.14)
      (if (begin
            (set! tmp.15 -9223372036854775808)
            (< tmp.15 1))
          (set! bat.3.8 -9223372036854775808)
          (set! bat.3.8 2088471563))
      (set! ball.7.11 1)
      (set! bat.9.10 9223372036854775807)
      (set! bar.8.7 1861500702)
      (if (begin
            (set! tmp.16 9223372036854775807)
            (!= tmp.16 -9223372036854775808))
          (halt ball.7.9)
          (halt 0)))))
(check-by-interp
 '(module ((locals ()) (undead-out ()) (conflicts ()))
          (define L.proc.0.1
            ((locals (foobar.1.2 foo.2.3 foobar.8.4 tmp.27 foo.9.1))
             (undead-out ((foo.9.1 rbp)
                          ((foo.9.1 rbp) ((foo.9.1 r9 rbp) (foo.9.1 r9 r8 rbp)
                                                           (foo.9.1 r9 r8 rcx rbp)
                                                           (foo.9.1 r9 r8 rcx rdx rbp)
                                                           (foo.9.1 r9 r8 rcx rdx rsi rbp)
                                                           (r9 r8 rcx rdx rsi rdi rbp)
                                                           (r9 r8 rcx rdx rsi rdi rbp))
                                         ((foo.9.1) ((foo.9.1) (foo.9.1) (foo.9.1) ())
                                                    (((tmp.27 foo.9.1) (foo.9.1)) () ())))))
             (conflicts ((foo.9.1 (rbp rdx foobar.8.4 tmp.27)) (tmp.27 (foo.9.1))
                                                               (foobar.8.4 (foo.9.1))
                                                               (foo.2.3 ())
                                                               (foobar.1.2 ())
                                                               (r9 (rdi rsi rdx rcx r8 rbp))
                                                               (rbp (foo.9.1 rdi rsi rdx rcx r8 r9))
                                                               (r8 (rdi rsi rdx rcx rbp r9))
                                                               (rcx (rdi rsi rdx rbp r8 r9))
                                                               (rdx (rdi rsi rbp rcx r8 r9 foo.9.1))
                                                               (rsi (rdi rbp rdx rcx r8 r9))
                                                               (rdi (rbp rsi rdx rcx r8 r9)))))
            (begin
              (set! foo.9.1 rdi)
              (if (false)
                  (begin
                    (set! r9 foo.9.1)
                    (set! r8 foo.9.1)
                    (set! rcx foo.9.1)
                    (set! rdx -9223372036854775808)
                    (set! rsi foo.9.1)
                    (set! rdi foo.9.1)
                    (jump L.fn.2.3 rbp rdi rsi rdx rcx r8 r9))
                  (if (false)
                      (begin
                        (set! foobar.8.4 9223372036854775807)
                        (set! foo.2.3 foo.9.1)
                        (set! foobar.1.2 foo.9.1)
                        (halt foo.9.1))
                      (if (begin
                            (set! tmp.27 1)
                            (> tmp.27 foo.9.1))
                          (halt 822960898)
                          (halt foo.9.1))))))
    (define L.fn.1.2
      ((locals (foo.6.15 foobar.3.14
                         foobar.3.17
                         foobar.7.16
                         foo.6.20
                         foo.0.19
                         foo.9.18
                         foobar.7.8
                         foobar.1.7
                         foobar.1.10
                         tmp.28
                         foobar.3.5
                         foobar.5.9
                         foobar.1.13
                         foo.6.6
                         foobar.5.12
                         foo.6.11))
       (undead-out ((rsi rdx foobar.1.7)
                    (rdx foobar.1.7 foo.6.6)
                    (foobar.1.7 foo.6.6 foobar.3.5)
                    ((foobar.1.7 foo.6.6 foobar.3.5)
                     ((foobar.1.7 foo.6.6 foobar.3.5)
                      (tmp.28 foobar.1.7 foo.6.6 foobar.3.5)
                      (tmp.28 foobar.1.7 foo.6.6 foobar.3.5)
                      (foobar.1.7 foo.6.6 foobar.3.5)
                      ((foobar.1.7 foo.6.6 foobar.3.5) (foo.6.6 foobar.3.5 foobar.7.8)
                                                       (foo.6.6 foobar.3.5 foobar.7.8))
                      (foo.6.6 foobar.3.5 foobar.7.8)
                      (foobar.3.5 foobar.7.8)
                      (foobar.7.8)
                      ())
                     ((foobar.1.7) (foobar.7.16)
                                   (foo.6.15)
                                   (foo.6.15)
                                   (foo.6.15)
                                   (foo.6.15)
                                   (foo.6.15 foobar.3.14)
                                   ((foobar.3.14) () ())))))
       (conflicts
        ((foo.6.11 (foobar.7.8))
         (foobar.5.12 (foobar.7.8 foobar.3.5))
         (foo.6.6 (foobar.3.5 foobar.1.7 rdx foobar.1.13 foobar.7.8 foobar.5.9 tmp.28 foobar.1.10))
         (foobar.1.13 (foobar.7.8 foobar.3.5 foo.6.6))
         (foobar.5.9 (foobar.3.5 foo.6.6 foobar.1.7))
         (foobar.3.5
          (foo.6.6 foobar.1.7 foobar.5.12 foobar.1.13 foobar.7.8 foobar.5.9 tmp.28 foobar.1.10))
         (tmp.28 (foobar.3.5 foo.6.6 foobar.1.7))
         (foobar.1.10 (foobar.3.5 foo.6.6))
         (foobar.1.7 (foobar.3.5 foo.6.6 rdx rsi foobar.5.9 tmp.28 foobar.3.17))
         (foobar.7.8 (foo.6.11 foobar.5.12 foobar.1.13 foobar.3.5 foo.6.6))
         (foo.9.18 (foo.6.15))
         (foo.0.19 (foo.6.15))
         (foo.6.20 (foo.6.15))
         (foobar.7.16 ())
         (foobar.3.17 (foobar.1.7))
         (foobar.3.14 (foo.6.15))
         (foo.6.15 (foobar.3.14 foo.9.18 foo.0.19 foo.6.20))
         (rsi (foobar.1.7))
         (rdx (foo.6.6 foobar.1.7)))))
      (begin
        (set! foobar.1.7 rdi)
        (set! foo.6.6 rsi)
        (set! foobar.3.5 rdx)
        (if (false)
            (begin
              (set! foobar.1.10 foobar.1.7)
              (set! tmp.28 -2065189484)
              (set! tmp.28 (+ tmp.28 foobar.3.5))
              (set! foobar.5.9 tmp.28)
              (if (< foobar.1.7 -300039187)
                  (set! foobar.7.8 2115350249)
                  (set! foobar.7.8 foobar.1.7))
              (set! foobar.1.13 -195312042)
              (set! foobar.5.12 foo.6.6)
              (set! foo.6.11 foobar.3.5)
              (halt foobar.7.8))
            (begin
              (set! foobar.3.17 -1983872386)
              (set! foobar.7.16 foobar.1.7)
              (set! foo.6.15 foobar.7.16)
              (set! foo.6.20 9223372036854775807)
              (set! foo.0.19 -9223372036854775808)
              (set! foo.9.18 1)
              (set! foobar.3.14 0)
              (if (>= foo.6.15 foo.6.15)
                  (halt -9223372036854775808)
                  (halt foobar.3.14))))))
    (define L.fn.2.3
      ((locals (foo.0.21 foobar.5.22 foo.9.23 foobar.1.24 foo.4.25 foo.6.26))
       (undead-out ((rsi rdx rcx r8 r9 foo.6.26 rbp) (rdx rcx r8 r9 foo.4.25 foo.6.26 rbp)
                                                     (rcx r8 r9 foobar.1.24 foo.4.25 foo.6.26 rbp)
                                                     (r8 r9 foobar.1.24 foo.4.25 foo.6.26 rbp)
                                                     (r9 foobar.1.24 foo.4.25 foo.6.26 rbp)
                                                     (foobar.1.24 foo.4.25 foo.6.26 rbp)
                                                     (foobar.1.24 foo.4.25 foo.6.26 r9 rbp)
                                                     (foo.4.25 foo.6.26 r9 r8 rbp)
                                                     (foo.4.25 foo.6.26 r9 r8 rcx rbp)
                                                     (foo.4.25 foo.6.26 r9 r8 rcx rdx rbp)
                                                     (foo.6.26 r9 r8 rcx rdx rsi rbp)
                                                     (r9 r8 rcx rdx rsi rdi rbp)
                                                     (r9 r8 rcx rdx rsi rdi rbp)))
       (conflicts
        ((foo.6.26 (foo.0.21 foobar.5.22 foo.9.23 foobar.1.24 foo.4.25 rbp r9 r8 rcx rdx rsi))
         (foo.4.25 (foo.0.21 foobar.5.22 foo.9.23 foobar.1.24 rbp foo.6.26 r9 r8 rcx rdx))
         (foobar.1.24 (foo.0.21 foobar.5.22 foo.9.23 rbp foo.6.26 foo.4.25 r9 r8 rcx))
         (foo.9.23 (rbp foo.6.26 foo.4.25 foobar.1.24 r9 r8))
         (foobar.5.22 (rbp foo.6.26 foo.4.25 foobar.1.24 r9))
         (foo.0.21 (rbp foo.6.26 foo.4.25 foobar.1.24))
         (rsi (rdi rbp rdx rcx r8 r9 foo.6.26))
         (rdx (rdi rsi rbp rcx r8 r9 foo.4.25 foo.6.26))
         (rcx (rdi rsi rdx rbp r8 r9 foobar.1.24 foo.4.25 foo.6.26))
         (r8 (rdi rsi rdx rcx rbp r9 foo.9.23 foobar.1.24 foo.4.25 foo.6.26))
         (r9 (rdi rsi rdx rcx r8 rbp foobar.5.22 foo.9.23 foobar.1.24 foo.4.25 foo.6.26))
         (rbp (rdi rsi rdx rcx r8 r9 foo.0.21 foobar.5.22 foo.9.23 foobar.1.24 foo.4.25 foo.6.26))
         (rdi (rbp rsi rdx rcx r8 r9)))))
      (begin
        (set! foo.6.26 rdi)
        (set! foo.4.25 rsi)
        (set! foobar.1.24 rdx)
        (set! foo.9.23 rcx)
        (set! foobar.5.22 r8)
        (set! foo.0.21 r9)
        (set! r9 foo.4.25)
        (set! r8 foobar.1.24)
        (set! rcx 968969801)
        (set! rdx foo.4.25)
        (set! rsi foo.4.25)
        (set! rdi foo.6.26)
        (jump L.fn.2.3 rbp rdi rsi rdx rcx r8 r9)))
    (halt 9223372036854775807)))
(check-by-interp
 '(module ((locals (foobar.4.4 bat.8.3 foobar.7.2 bar.5.1 tmp.5))
           (undead-out (((tmp.5) ()) (() () ()) (() () ())))
           (conflicts ((tmp.5 ()) (bar.5.1 ()) (foobar.7.2 ()) (bat.8.3 ()) (foobar.4.4 ()))))
          (if (not (begin
                     (set! tmp.5 1622421353)
                     (>= tmp.5 94202816)))
              (begin
                (set! foobar.7.2 -2027378735)
                (set! bar.5.1 9223372036854775807)
                (halt 9223372036854775807))
              (begin
                (set! foobar.4.4 -9223372036854775808)
                (set! bat.8.3 1)
                (halt 9223372036854775807)))
    ))
(check-by-interp
 '(module ((locals (bat.3.6 ball.9.7 ball.5.8 foo.7.1 foo.7.3 bar.0.4 ball.9.5 bar.4.2 tmp.9))
           (undead-out ((tmp.9) (tmp.9)
                                (bar.4.2)
                                (bar.4.2)
                                (bar.4.2)
                                (foo.7.3 bar.4.2)
                                (foo.7.1 bar.4.2)
                                (bar.4.2)
                                ()
                                ()
                                ()))
           (conflicts ((tmp.9 ()) (bar.4.2 (ball.5.8 foo.7.1 foo.7.3 bar.0.4 ball.9.5))
                                  (ball.9.5 (bar.4.2))
                                  (bar.0.4 (bar.4.2))
                                  (foo.7.3 (bar.4.2))
                                  (foo.7.1 (bar.4.2))
                                  (ball.5.8 (bar.4.2))
                                  (ball.9.7 ())
                                  (bat.3.6 ()))))
          (begin
            (set! tmp.9 -1915251883)
            (set! tmp.9 (* tmp.9 1))
            (set! bar.4.2 tmp.9)
            (set! ball.9.5 -9223372036854775808)
            (set! bar.0.4 356482613)
            (set! foo.7.3 9223372036854775807)
            (set! foo.7.1 foo.7.3)
            (set! ball.5.8 foo.7.1)
            (set! ball.9.7 bar.4.2)
            (set! bat.3.6 -1601764542)
            (halt -9223372036854775808))
    ))
(check-by-interp
 '(module ((locals (tmp.13 foobar.5.7 foo.1.9 bar.4.8 tmp.12))
           (undead-out (((tmp.12) ()) (() () (foobar.5.7) ()) (((tmp.13) ()) () ())))
           (conflicts ((tmp.12 ()) (bar.4.8 ()) (foo.1.9 ()) (foobar.5.7 ()) (tmp.13 ()))))
          (define L.func.0.1
            ((locals (tmp.11 tmp.10 foo.1.2 ball.8.1 foo.2.3 foo.9.4 ball.7.6 bar.4.5))
             (undead-out ((rsi rdx rcx r8 r9 ball.7.6 rbp)
                          (rdx rcx r8 r9 ball.7.6 bar.4.5 rbp)
                          (rcx r8 r9 ball.7.6 foo.9.4 bar.4.5 rbp)
                          (r8 r9 ball.7.6 foo.2.3 foo.9.4 bar.4.5 rbp)
                          (r9 ball.7.6 foo.2.3 foo.1.2 foo.9.4 bar.4.5 rbp)
                          (ball.7.6 foo.2.3 foo.1.2 foo.9.4 ball.8.1 bar.4.5 rbp)
                          (((foo.2.3 foo.1.2 foo.9.4 ball.8.1 bar.4.5 rbp)
                            (((tmp.10 foo.2.3 foo.1.2 foo.9.4 ball.8.1 bar.4.5 rbp)
                              (foo.2.3 foo.1.2 foo.9.4 ball.8.1 bar.4.5 rbp))
                             (foo.1.2 foo.9.4 ball.8.1 bar.4.5 rbp)
                             (foo.1.2 foo.9.4 ball.8.1 bar.4.5 rbp))
                            ((tmp.11 foo.1.2 foo.9.4 ball.8.1 bar.4.5 rbp)
                             (foo.1.2 foo.9.4 ball.8.1 bar.4.5 rbp)))
                           ((ball.8.1 bar.4.5 r9 rbp) (bar.4.5 r9 r8 rbp)
                                                      (bar.4.5 r9 r8 rcx rbp)
                                                      (r9 r8 rcx rdx rbp)
                                                      (r9 r8 rcx rdx rsi rbp)
                                                      (r9 r8 rcx rdx rsi rdi rbp)
                                                      (r9 r8 rcx rdx rsi rdi rbp))
                           ((foo.1.2 ball.8.1 r9 rbp) (foo.1.2 ball.8.1 r9 r8 rbp)
                                                      (ball.8.1 r9 r8 rcx rbp)
                                                      (ball.8.1 r9 r8 rcx rdx rbp)
                                                      (ball.8.1 r9 r8 rcx rdx rsi rbp)
                                                      (r9 r8 rcx rdx rsi rdi rbp)
                                                      (r9 r8 rcx rdx rsi rdi rbp)))))
             (conflicts
              ((bar.4.5 (ball.8.1 foo.1.2 foo.2.3 foo.9.4 rbp ball.7.6 rdx tmp.10 tmp.11 rcx r8 r9))
               (ball.7.6 (ball.8.1 foo.1.2 foo.2.3 foo.9.4 bar.4.5 rbp r9 r8 rcx rdx rsi))
               (foo.9.4 (ball.8.1 foo.1.2 foo.2.3 rbp bar.4.5 ball.7.6 r9 r8 rcx tmp.10 tmp.11))
               (foo.2.3 (ball.8.1 foo.1.2 rbp bar.4.5 foo.9.4 ball.7.6 r9 r8 tmp.10))
               (ball.8.1 (rbp bar.4.5 foo.9.4 foo.1.2 foo.2.3 ball.7.6 tmp.10 tmp.11 rsi rcx r8 r9))
               (foo.1.2 (ball.8.1 rbp bar.4.5 foo.9.4 foo.2.3 ball.7.6 tmp.10 tmp.11 r8 r9))
               (tmp.10 (rbp bar.4.5 ball.8.1 foo.9.4 foo.1.2 foo.2.3))
               (tmp.11 (rbp bar.4.5 ball.8.1 foo.9.4 foo.1.2))
               (r9 (foo.2.3 foo.9.4 ball.7.6 bar.4.5 rdi rsi rdx rcx r8 rbp ball.8.1 foo.1.2))
               (rbp (ball.8.1 foo.1.2
                              foo.2.3
                              foo.9.4
                              bar.4.5
                              ball.7.6
                              tmp.10
                              tmp.11
                              rdi
                              rsi
                              rdx
                              rcx
                              r8
                              r9))
               (r8 (foo.2.3 foo.9.4 ball.7.6 bar.4.5 rdi rsi rdx rcx rbp r9 ball.8.1 foo.1.2))
               (rcx (foo.9.4 ball.7.6 bar.4.5 rdi rsi rdx rbp r8 r9 ball.8.1))
               (rdx (bar.4.5 ball.7.6 rdi rsi rbp rcx r8 r9))
               (rsi (ball.7.6 rdi rbp rdx rcx r8 r9 ball.8.1))
               (rdi (rbp rsi rdx rcx r8 r9)))))
            (begin
              (set! ball.7.6 rdi)
              (set! bar.4.5 rsi)
              (set! foo.9.4 rdx)
              (set! foo.2.3 rcx)
              (set! foo.1.2 r8)
              (set! ball.8.1 r9)
              (if (if (> bar.4.5 ball.7.6)
                      (if (begin
                            (set! tmp.10 -1032056006)
                            (= tmp.10 foo.1.2))
                          (>= foo.2.3 ball.8.1)
                          (< foo.9.4 1))
                      (begin
                        (set! tmp.11 1)
                        (>= tmp.11 foo.9.4)))
                  (begin
                    (set! r9 foo.9.4)
                    (set! r8 ball.8.1)
                    (set! rcx 1807204646)
                    (set! rdx bar.4.5)
                    (set! rsi -675302553)
                    (set! rdi 0)
                    (jump L.func.0.1 rbp rdi rsi rdx rcx r8 r9))
                  (begin
                    (set! r9 9223372036854775807)
                    (set! r8 -9223372036854775808)
                    (set! rcx foo.1.2)
                    (set! rdx ball.8.1)
                    (set! rsi -41674885)
                    (set! rdi ball.8.1)
                    (jump L.func.0.1 rbp rdi rsi rdx rcx r8 r9)))))
    (if (begin
          (set! tmp.12 -9223372036854775808)
          (!= tmp.12 -719419034))
        (begin
          (set! foo.1.9 9223372036854775807)
          (set! bar.4.8 0)
          (set! foobar.5.7 9223372036854775807)
          (halt foobar.5.7))
        (if (begin
              (set! tmp.13 -235413122)
              (> tmp.13 1))
            (halt 0)
            (halt 9223372036854775807)))))
(check-by-interp
 '(module ((locals (bar.5.19 foo.8.18 ball.6.17 foo.8.16 foobar.0.15 ball.2.14 tmp.23 tmp.22 tmp.21))
           (undead-out ((((tmp.21) ()) ((tmp.22) ()) ((tmp.23) ()))
                        ((foo.8.16) (foo.8.16) (foo.8.16) ())
                        ((bar.5.19) (bar.5.19) (bar.5.19) ())))
           (conflicts ((tmp.21 ()) (tmp.22 ())
                                   (tmp.23 ())
                                   (ball.2.14 (foo.8.16))
                                   (foobar.0.15 (foo.8.16))
                                   (foo.8.16 (ball.2.14 foobar.0.15))
                                   (ball.6.17 (bar.5.19))
                                   (foo.8.18 (bar.5.19))
                                   (bar.5.19 (ball.6.17 foo.8.18)))))
          (define L.fn.0.1
            ((locals (ball.9.1))
             (undead-out ((ball.9.1 rbp) (ball.9.1 rsi rbp) (rsi rdi rbp) (rsi rdi rbp)))
             (conflicts ((ball.9.1 (rbp)) (rbp (rdi rsi ball.9.1)) (rsi (rdi rbp)) (rdi (rbp rsi)))))
            (begin
              (set! ball.9.1 rdi)
              (set! rsi ball.9.1)
              (set! rdi ball.9.1)
              (jump L.x.1.2 rbp rdi rsi)))
    (define L.x.1.2
      ((locals (bat.7.11 foobar.0.9
                         tmp.20
                         bat.7.13
                         foobar.0.12
                         ball.9.10
                         ball.9.2
                         foobar.4.6
                         foo.1.8
                         ball.6.3
                         bar.5.7
                         foo.1.5
                         ball.9.4))
       (undead-out ((rsi ball.6.3) (ball.9.2 ball.6.3)
                                   ((ball.9.2 ball.6.3) ((ball.6.3) (ball.6.3) () () () ())
                                                        ((ball.9.2 tmp.20 ball.6.3)
                                                         (tmp.20 ball.6.3)
                                                         (ball.6.3 bat.7.11)
                                                         (ball.6.3 bat.7.11)
                                                         (bat.7.11)
                                                         (bat.7.11)
                                                         (bat.7.11 foobar.0.9)
                                                         ((foobar.0.9) () ())))))
       (conflicts ((ball.9.4 ()) (foo.1.5 ())
                                 (bar.5.7 ())
                                 (ball.6.3 (ball.9.2 rsi foo.1.8 foobar.4.6 bat.7.13 bat.7.11 tmp.20))
                                 (foo.1.8 (ball.6.3))
                                 (foobar.4.6 (ball.6.3))
                                 (ball.9.2 (ball.6.3 tmp.20))
                                 (ball.9.10 (bat.7.11))
                                 (foobar.0.12 (bat.7.11))
                                 (bat.7.13 (bat.7.11 ball.6.3))
                                 (tmp.20 (ball.6.3 ball.9.2))
                                 (foobar.0.9 (bat.7.11))
                                 (bat.7.11 (foobar.0.9 ball.9.10 foobar.0.12 bat.7.13 ball.6.3))
                                 (rsi (ball.6.3)))))
      (begin
        (set! ball.6.3 rdi)
        (set! ball.9.2 rsi)
        (if (not (false))
            (begin
              (set! foobar.4.6 ball.9.2)
              (set! foo.1.8 9223372036854775807)
              (set! bar.5.7 ball.6.3)
              (set! foo.1.5 9223372036854775807)
              (set! ball.9.4 -2115998024)
              (halt -1101891150))
            (begin
              (set! tmp.20 -1594085017)
              (set! tmp.20 (* tmp.20 ball.9.2))
              (set! bat.7.11 tmp.20)
              (set! bat.7.13 -999943825)
              (set! foobar.0.12 ball.6.3)
              (set! ball.9.10 593362223)
              (set! foobar.0.9 0)
              (if (= bat.7.11 1)
                  (halt foobar.0.9)
                  (halt 0))))))
    (if (if (begin
              (set! tmp.21 1)
              (= tmp.21 -1319463227))
            (begin
              (set! tmp.22 -9223372036854775808)
              (>= tmp.22 1))
            (begin
              (set! tmp.23 -1520052689)
              (!= tmp.23 1)))
        (begin
          (set! foo.8.16 -9223372036854775808)
          (set! foobar.0.15 9223372036854775807)
          (set! ball.2.14 744570222)
          (halt foo.8.16))
        (begin
          (set! bar.5.19 -133225634)
          (set! foo.8.18 -9223372036854775808)
          (set! ball.6.17 -9223372036854775808)
          (halt bar.5.19)))))
(check-by-interp
 '(module ((locals (bar.4.1 foobar.9.7 foobar.7.8 foobar.3.2 ball.1.4 bar.4.5 ball.6.6 bat.2.3 tmp.9))
           (undead-out ((bat.2.3) (bat.2.3)
                                  (bat.2.3)
                                  (bat.2.3)
                                  (bat.2.3)
                                  (bat.2.3)
                                  (bat.2.3)
                                  (bat.2.3)
                                  (((tmp.9 bat.2.3) (bat.2.3)) () ())))
           (conflicts
            ((tmp.9 (bat.2.3))
             (bat.2.3 (bar.4.1 foobar.9.7 foobar.7.8 foobar.3.2 ball.1.4 bar.4.5 ball.6.6 tmp.9))
             (ball.6.6 (bat.2.3))
             (bar.4.5 (bat.2.3))
             (ball.1.4 (bat.2.3))
             (foobar.3.2 (bat.2.3))
             (foobar.7.8 (bat.2.3))
             (foobar.9.7 (bat.2.3))
             (bar.4.1 (bat.2.3)))))
          (begin
            (set! bat.2.3 9223372036854775807)
            (set! ball.6.6 1)
            (set! bar.4.5 -9223372036854775808)
            (set! ball.1.4 9223372036854775807)
            (set! foobar.3.2 1)
            (set! foobar.7.8 -1722042928)
            (set! foobar.9.7 0)
            (set! bar.4.1 1)
            (if (begin
                  (set! tmp.9 -1508403451)
                  (!= tmp.9 bat.2.3))
                (halt 447579047)
                (halt bat.2.3)))
    ))
(check-by-interp '(module ((locals (tmp.6 tmp.5)) (undead-out ((tmp.6) (tmp.6) (tmp.5) ()))
                                                  (conflicts ((tmp.5 ()) (tmp.6 ()))))
                          (define L.tmp.0.1
                            ((locals (foo.8.1 foobar.6.2 ball.9.3 foo.4.4))
                             (undead-out ((rsi rdx rcx foo.4.4 rbp) (rdx rcx foo.4.4 rbp)
                                                                    (rcx foo.4.4 foobar.6.2 rbp)
                                                                    (foo.4.4 foobar.6.2 rbp)
                                                                    (foobar.6.2 rcx rbp)
                                                                    (foobar.6.2 rcx rdx rbp)
                                                                    (rcx rdx rsi rbp)
                                                                    (rcx rdx rsi rdi rbp)
                                                                    (rcx rdx rsi rdi rbp)))
                             (conflicts ((foo.4.4 (foo.8.1 foobar.6.2 ball.9.3 rbp rcx rdx rsi))
                                         (ball.9.3 (rbp foo.4.4 rcx rdx))
                                         (foobar.6.2 (foo.8.1 rbp foo.4.4 rcx))
                                         (foo.8.1 (rbp foobar.6.2 foo.4.4))
                                         (rsi (rdi rbp rdx rcx foo.4.4))
                                         (rdx (rdi rsi rbp rcx ball.9.3 foo.4.4))
                                         (rcx (rdi rsi rdx rbp foobar.6.2 ball.9.3 foo.4.4))
                                         (rbp (rdi rsi rdx rcx foo.8.1 foobar.6.2 ball.9.3 foo.4.4))
                                         (rdi (rbp rsi rdx rcx)))))
                            (begin
                              (set! foo.4.4 rdi)
                              (set! ball.9.3 rsi)
                              (set! foobar.6.2 rdx)
                              (set! foo.8.1 rcx)
                              (set! rcx foo.4.4)
                              (set! rdx foobar.6.2)
                              (set! rsi foobar.6.2)
                              (set! rdi 9223372036854775807)
                              (jump L.tmp.0.1 rbp rdi rsi rdx rcx)))
                    (begin
                      (set! tmp.6 9223372036854775807)
                      (set! tmp.6 (+ tmp.6 -1932027129))
                      (set! tmp.5 tmp.6)
                      (halt tmp.5))))
(check-by-interp
 '(module ((locals ()) (undead-out ((rsi rbp) (rsi rdi rbp) (rsi rdi rbp)))
                       (conflicts ((rsi (rdi rbp)) (rbp (rdi rsi)) (rdi (rbp rsi)))))
          (define L.func.0.1
            ((locals (ball.7.1 bat.4.2)) (undead-out ((rsi bat.4.2 rbp) (ball.7.1 bat.4.2 rbp)
                                                                        (ball.7.1 bat.4.2 rcx rbp)
                                                                        (ball.7.1 bat.4.2 rcx rdx rbp)
                                                                        (bat.4.2 rcx rdx rsi rbp)
                                                                        (rcx rdx rsi rdi rbp)
                                                                        (rcx rdx rsi rdi rbp)))
                                         (conflicts ((bat.4.2 (rdx ball.7.1 rbp rsi))
                                                     (ball.7.1 (rdx rcx rbp bat.4.2))
                                                     (rsi (rdi rbp rdx rcx bat.4.2))
                                                     (rbp (rdi rsi rdx rcx ball.7.1 bat.4.2))
                                                     (rcx (rdi rsi rdx rbp ball.7.1))
                                                     (rdx (rdi rsi rbp rcx bat.4.2 ball.7.1))
                                                     (rdi (rbp rsi rdx rcx)))))
            (begin
              (set! bat.4.2 rdi)
              (set! ball.7.1 rsi)
              (set! rcx bat.4.2)
              (set! rdx -436836322)
              (set! rsi ball.7.1)
              (set! rdi bat.4.2)
              (jump L.fn.1.2 rbp rdi rsi rdx rcx)))
    (define L.fn.1.2
      ((locals (ball.2.3 ball.0.7
                         tmp.19
                         bar.5.8
                         bat.1.11
                         ball.7.6
                         ball.2.10
                         ball.0.9
                         tmp.15
                         bar.8.5
                         bat.1.4
                         tmp.16
                         tmp.18
                         tmp.17))
       (undead-out ((rsi rdx rcx ball.7.6)
                    (rdx rcx ball.7.6 bar.8.5)
                    (rcx ball.7.6 bar.8.5 bat.1.4)
                    (ball.7.6 bar.8.5 bat.1.4)
                    ((ball.7.6 bar.8.5 bat.1.4)
                     ((((bar.8.5 tmp.15 bat.1.4) (bat.1.4)) (bat.1.4) ((tmp.16 bat.1.4) (bat.1.4)))
                      ((tmp.18) (tmp.18) (tmp.17) ())
                      ())
                     ((tmp.19 ball.7.6) (tmp.19 ball.7.6)
                                        (ball.7.6)
                                        (ball.7.6 bat.1.11)
                                        (bat.1.11)
                                        (bat.1.11)
                                        (ball.0.7)
                                        ()))))
       (conflicts ((tmp.17 ())
                   (tmp.18 ())
                   (tmp.16 (bat.1.4))
                   (bat.1.4 (ball.2.3 bar.8.5 ball.7.6 rcx tmp.15 tmp.16))
                   (bar.8.5 (ball.2.3 bat.1.4 ball.7.6 rcx rdx tmp.15))
                   (tmp.15 (bat.1.4 bar.8.5))
                   (ball.0.9 (bat.1.11))
                   (ball.2.10 (bat.1.11))
                   (ball.7.6 (ball.2.3 bat.1.4 bar.8.5 rcx rdx rsi bat.1.11 bar.5.8 tmp.19))
                   (bat.1.11 (ball.0.9 ball.2.10 ball.7.6))
                   (bar.5.8 (ball.7.6))
                   (tmp.19 (ball.7.6))
                   (ball.0.7 ())
                   (ball.2.3 (bat.1.4 bar.8.5 ball.7.6))
                   (rsi (ball.7.6))
                   (rdx (bar.8.5 ball.7.6))
                   (rcx (bat.1.4 bar.8.5 ball.7.6)))))
      (begin
        (set! ball.7.6 rdi)
        (set! bar.8.5 rsi)
        (set! bat.1.4 rdx)
        (set! ball.2.3 rcx)
        (if (true)
            (if (if (begin
                      (set! tmp.15 182929845)
                      (> tmp.15 bar.8.5))
                    (>= bat.1.4 1)
                    (begin
                      (set! tmp.16 -767224240)
                      (< tmp.16 9223372036854775807)))
                (begin
                  (set! tmp.18 bat.1.4)
                  (set! tmp.18 (+ tmp.18 -9223372036854775808))
                  (set! tmp.17 tmp.18)
                  (halt tmp.17))
                (halt bat.1.4))
            (begin
              (set! tmp.19 -9223372036854775808)
              (set! tmp.19 (+ tmp.19 -9223372036854775808))
              (set! bar.5.8 tmp.19)
              (set! bat.1.11 -1747554427)
              (set! ball.2.10 ball.7.6)
              (set! ball.0.9 9223372036854775807)
              (set! ball.0.7 bat.1.11)
              (halt ball.0.7)))))
    (define L.x.2.3
      ((locals (bat.4.14 tmp.21 tmp.22 bar.5.13 tmp.23 bat.1.12 tmp.20))
       (undead-out (((tmp.20) ()) ()
                                  ((((tmp.21) ()) (bat.4.14) (bat.4.14)) (tmp.22 bat.4.14)
                                                                         (tmp.22 bat.4.14)
                                                                         (bat.4.14)
                                                                         (tmp.23 bat.4.14)
                                                                         (tmp.23 bat.4.14)
                                                                         (bat.4.14)
                                                                         (() () ()))))
       (conflicts ((tmp.20 ()) (bat.1.12 (bat.4.14))
                               (tmp.23 (bat.4.14))
                               (bar.5.13 (bat.4.14))
                               (tmp.22 (bat.4.14))
                               (tmp.21 ())
                               (bat.4.14 (bat.1.12 tmp.23 bar.5.13 tmp.22)))))
      (if (begin
            (set! tmp.20 0)
            (< tmp.20 9223372036854775807))
          (halt 1083014636)
          (begin
            (if (begin
                  (set! tmp.21 1)
                  (<= tmp.21 9223372036854775807))
                (set! bat.4.14 9223372036854775807)
                (set! bat.4.14 1))
            (set! tmp.22 0)
            (set! tmp.22 (* tmp.22 0))
            (set! bar.5.13 tmp.22)
            (set! tmp.23 1942355770)
            (set! tmp.23 (* tmp.23 9223372036854775807))
            (set! bat.1.12 tmp.23)
            (if (>= bat.4.14 9223372036854775807)
                (halt -9223372036854775808)
                (halt 1)))))
    (begin
      (set! rsi 9223372036854775807)
      (set! rdi -1129269775)
      (jump L.func.0.1 rbp rdi rsi))))
(check-by-interp
 '(module ((locals (ball.7.18 tmp.28 tmp.27 foobar.1.19 tmp.29))
           (undead-out ((tmp.27) (tmp.27)
                                 (foobar.1.19)
                                 (tmp.28 foobar.1.19)
                                 (tmp.28 foobar.1.19)
                                 (foobar.1.19)
                                 (((foobar.1.19 tmp.29) ()) () ())))
           (conflicts ((tmp.29 (foobar.1.19)) (foobar.1.19 (ball.7.18 tmp.28 tmp.29))
                                              (tmp.27 ())
                                              (tmp.28 (foobar.1.19))
                                              (ball.7.18 (foobar.1.19)))))
          (define L.proc.0.1
            ((locals (tmp.20 tmp.21 bat.2.2 ball.8.1))
             (undead-out ((((tmp.20 rbp) (tmp.20 rbp) (bat.2.2 rbp))
                           (bat.2.2 ball.8.1 rbp)
                           ((bat.2.2 ball.8.1 rbp) ((ball.8.1 tmp.21 rbp) (rbp)) (rbp)))
                          ()
                          ((rdx rbp) (rdx rsi rbp) (rdx rsi rdi rbp) (rdx rsi rdi rbp))))
             (conflicts ((ball.8.1 (rbp bat.2.2 tmp.21))
                         (bat.2.2 (ball.8.1 rbp))
                         (tmp.21 (rbp ball.8.1))
                         (tmp.20 (rbp))
                         (rdx (rdi rsi rbp))
                         (rbp (ball.8.1 tmp.20 bat.2.2 tmp.21 rdi rsi rdx))
                         (rsi (rdi rbp rdx))
                         (rdi (rbp rsi rdx)))))
            (if (begin
                  (begin
                    (set! tmp.20 1)
                    (set! tmp.20 (* tmp.20 0))
                    (set! bat.2.2 tmp.20))
                  (set! ball.8.1 -9223372036854775808)
                  (if (> ball.8.1 bat.2.2)
                      (begin
                        (set! tmp.21 9223372036854775807)
                        (>= tmp.21 ball.8.1))
                      (= bat.2.2 0)))
                (halt -9223372036854775808)
                (begin
                  (set! rdx 0)
                  (set! rsi 1)
                  (set! rdi 0)
                  (jump L.proc.2.3 rbp rdi rsi rdx))))
    (define L.fn.1.2
      ((locals (foobar.0.7 bat.2.14
                           ball.9.13
                           foobar.1.6
                           bar.6.12
                           foo.4.11
                           bat.3.10
                           ball.9.4
                           bar.6.3
                           tmp.22
                           bat.3.5
                           bat.2.9
                           tmp.23
                           foo.4.8
                           tmp.24))
       (undead-out
        ((rsi rdx rcx r8 r9 fv0 bat.2.9)
         (rdx rcx r8 r9 fv0 foo.4.8 bat.2.9)
         (rcx r8 r9 fv0 foo.4.8 bat.2.9)
         (r8 r9 fv0 foo.4.8 foobar.1.6 bat.2.9)
         (r9 fv0 foo.4.8 foobar.1.6 bat.3.5 bat.2.9)
         (fv0 ball.9.4 foo.4.8 foobar.1.6 bat.3.5 bat.2.9)
         (ball.9.4 foo.4.8 bar.6.3 foobar.1.6 bat.3.5 bat.2.9)
         (((ball.9.4 foo.4.8 bar.6.3 foobar.1.6 bat.3.5 bat.2.9)
           (((tmp.22 foo.4.8 bar.6.3 foobar.1.6 bat.3.5 bat.2.9)
             (foo.4.8 bar.6.3 foobar.1.6 bat.3.5 bat.2.9))
            ((tmp.23 bar.6.3 foobar.1.6 bat.3.5 bat.2.9) (bar.6.3 foobar.1.6 bat.3.5 bat.2.9))
            ((foo.4.8 tmp.24 bar.6.3 foobar.1.6 bat.3.5 bat.2.9)
             (bar.6.3 foobar.1.6 bat.3.5 bat.2.9)))
           ((bar.6.3 foobar.1.6 bat.3.5 bat.2.9) (bar.6.3 foobar.1.6 bat.3.5 bat.2.9)
                                                 (bar.6.3 foobar.1.6 bat.3.5 bat.2.9)))
          ((foobar.1.6 bat.3.5 bat.2.9) (foobar.1.6 bat.3.5 bat.2.9)
                                        (bat.3.5 bat.2.9)
                                        (bat.2.9)
                                        ((bat.2.9) (bat.2.9) (bat.2.9))
                                        (() () ()))
          ())))
       (conflicts
        ((tmp.24 (bat.2.9 bat.3.5 foobar.1.6 bar.6.3 foo.4.8))
         (foo.4.8
          (bar.6.3 ball.9.4 bat.3.5 foobar.1.6 foobar.0.7 bat.2.9 fv0 r9 r8 rcx rdx tmp.22 tmp.24))
         (tmp.23 (bat.2.9 bat.3.5 foobar.1.6 bar.6.3))
         (bat.2.9 (bar.6.3 ball.9.4
                           bat.3.5
                           foobar.1.6
                           foobar.0.7
                           foo.4.8
                           fv0
                           r9
                           r8
                           rcx
                           rdx
                           rsi
                           tmp.22
                           tmp.23
                           tmp.24
                           bat.3.10
                           foo.4.11
                           bar.6.12
                           ball.9.13
                           bat.2.14))
         (bat.3.5 (bar.6.3 ball.9.4
                           bat.2.9
                           foobar.1.6
                           foo.4.8
                           fv0
                           r9
                           tmp.22
                           tmp.23
                           tmp.24
                           bar.6.12
                           ball.9.13
                           bat.2.14))
         (tmp.22 (bat.2.9 bat.3.5 foobar.1.6 bar.6.3 foo.4.8))
         (bar.6.3 (bat.2.9 bat.3.5 foobar.1.6 foo.4.8 ball.9.4 tmp.22 tmp.23 tmp.24))
         (ball.9.4 (bar.6.3 bat.2.9 bat.3.5 foobar.1.6 foo.4.8 fv0))
         (bat.3.10 (bat.2.9))
         (foo.4.11 (bat.2.9))
         (bar.6.12 (bat.2.9 bat.3.5))
         (foobar.1.6 (bar.6.3 ball.9.4
                              bat.3.5
                              bat.2.9
                              foo.4.8
                              fv0
                              r9
                              r8
                              tmp.22
                              tmp.23
                              tmp.24
                              ball.9.13
                              bat.2.14))
         (ball.9.13 (bat.2.9 bat.3.5 foobar.1.6))
         (bat.2.14 (bat.2.9 bat.3.5 foobar.1.6))
         (foobar.0.7 (bat.2.9 foo.4.8 fv0 r9 r8 rcx))
         (rsi (bat.2.9))
         (rdx (foo.4.8 bat.2.9))
         (rcx (foobar.0.7 foo.4.8 bat.2.9))
         (r8 (foobar.1.6 foobar.0.7 foo.4.8 bat.2.9))
         (r9 (bat.3.5 foobar.1.6 foobar.0.7 foo.4.8 bat.2.9))
         (fv0 (ball.9.4 bat.3.5 foobar.1.6 foobar.0.7 foo.4.8 bat.2.9)))))
      (begin
        (set! bat.2.9 rdi)
        (set! foo.4.8 rsi)
        (set! foobar.0.7 rdx)
        (set! foobar.1.6 rcx)
        (set! bat.3.5 r8)
        (set! ball.9.4 r9)
        (set! bar.6.3 fv0)
        (if (if (true)
                (if (begin
                      (set! tmp.22 -1156972119)
                      (!= tmp.22 bat.3.5))
                    (begin
                      (set! tmp.23 9223372036854775807)
                      (> tmp.23 bat.2.9))
                    (begin
                      (set! tmp.24 1703616983)
                      (!= tmp.24 foo.4.8)))
                (if (>= ball.9.4 bar.6.3)
                    (> bat.3.5 bat.3.5)
                    (< bat.2.9 bat.2.9)))
            (begin
              (set! bat.2.14 bar.6.3)
              (set! ball.9.13 -144518674)
              (set! bar.6.12 foobar.1.6)
              (set! foo.4.11 bat.3.5)
              (if (< bat.2.9 9223372036854775807)
                  (set! bat.3.10 0)
                  (set! bat.3.10 -9223372036854775808))
              (if (>= bat.2.9 -2080421634)
                  (halt 9223372036854775807)
                  (halt 0)))
            (halt -274219017))))
    (define L.proc.2.3
      ((locals (tmp.26 ball.9.15 bat.2.16 ball.5.17 tmp.25))
       (undead-out ((rsi rdx) (rdx bat.2.16) (bat.2.16) (tmp.26) (tmp.26) (tmp.25) ()))
       (conflicts ((tmp.25 ()) (ball.5.17 (rdx rsi))
                               (bat.2.16 (ball.9.15 rdx))
                               (ball.9.15 (bat.2.16))
                               (tmp.26 ())
                               (rsi (ball.5.17))
                               (rdx (bat.2.16 ball.5.17)))))
      (begin
        (set! ball.5.17 rdi)
        (set! bat.2.16 rsi)
        (set! ball.9.15 rdx)
        (set! tmp.26 bat.2.16)
        (set! tmp.26 (+ tmp.26 9223372036854775807))
        (set! tmp.25 tmp.26)
        (halt tmp.25)))
    (begin
      (set! tmp.27 1)
      (set! tmp.27 (+ tmp.27 -1806804688))
      (set! foobar.1.19 tmp.27)
      (set! tmp.28 1880531761)
      (set! tmp.28 (+ tmp.28 1))
      (set! ball.7.18 tmp.28)
      (if (begin
            (set! tmp.29 0)
            (<= tmp.29 foobar.1.19))
          (halt 0)
          (halt 9223372036854775807)))))
(check-by-interp
 '(module ((locals (bat.4.2 foobar.7.1 tmp.4 tmp.5 tmp.3))
           (undead-out (((tmp.3) ()) ((tmp.5) (tmp.5) (tmp.4) ()) (() () ())))
           (conflicts ((tmp.3 ()) (tmp.5 ()) (tmp.4 ()) (foobar.7.1 ()) (bat.4.2 ()))))
          (if (begin
                (set! tmp.3 -107521481)
                (!= tmp.3 -1873066368))
              (begin
                (set! tmp.5 1275956981)
                (set! tmp.5 (* tmp.5 1))
                (set! tmp.4 tmp.5)
                (halt tmp.4))
              (begin
                (set! bat.4.2 1318401057)
                (set! foobar.7.1 -542033033)
                (halt -288327503)))
    ))
(check-by-interp
 '(module ((locals (tmp.18 tmp.16 ball.9.10 tmp.15 bat.5.11 tmp.17))
           (undead-out ((((tmp.15) ()) () ()) (((tmp.16) ()) () ()) (tmp.18) (tmp.18) (tmp.17) ()))
           (conflicts ((tmp.17 ()) (bat.5.11 ()) (tmp.15 ()) (ball.9.10 ()) (tmp.16 ()) (tmp.18 ()))))
          (define L.fn.0.1
            ((locals (tmp.13 bat.5.6
                             ball.1.7
                             ball.9.1
                             foo.6.8
                             bat.0.9
                             tmp.14
                             tmp.12
                             bat.3.2
                             bar.7.3
                             bat.0.4
                             foobar.4.5))
             (undead-out
              ((foobar.4.5 rbp)
               (foobar.4.5 rbp)
               (bar.7.3 foobar.4.5 rbp)
               (((tmp.12 bar.7.3 foobar.4.5 rbp) (bar.7.3 foobar.4.5 rbp)) (rbp) (rbp))
               (((rbp) (bat.5.6 rbp) ((bat.5.6 tmp.13 rbp) (rbp))) ((bat.0.9 rbp) (bat.0.9 rbp) (rbp))
                                                                   (((tmp.14 rbp) (rbp)) (rbp) (rbp)))
               (rbp)))
             (conflicts ((foobar.4.5 (tmp.12 bar.7.3 bat.0.4 rbp)) (bat.0.4 (rbp foobar.4.5))
                                                                   (bar.7.3 (tmp.12 rbp foobar.4.5))
                                                                   (bat.3.2 (rbp))
                                                                   (tmp.12 (rbp foobar.4.5 bar.7.3))
                                                                   (tmp.14 (rbp))
                                                                   (bat.0.9 (foo.6.8 rbp))
                                                                   (foo.6.8 (rbp bat.0.9))
                                                                   (ball.9.1 (rbp))
                                                                   (ball.1.7 (rbp))
                                                                   (bat.5.6 (rbp tmp.13))
                                                                   (tmp.13 (rbp bat.5.6))
                                                                   (rbp (bat.5.6 ball.1.7
                                                                                 tmp.13
                                                                                 foo.6.8
                                                                                 bat.0.9
                                                                                 tmp.14
                                                                                 ball.9.1
                                                                                 tmp.12
                                                                                 bat.3.2
                                                                                 bar.7.3
                                                                                 bat.0.4
                                                                                 foobar.4.5)))))
            (begin
              (set! foobar.4.5 9223372036854775807)
              (set! bat.0.4 684249837)
              (set! bar.7.3 1)
              (if (begin
                    (set! tmp.12 2084897481)
                    (= tmp.12 bar.7.3))
                  (set! bat.3.2 foobar.4.5)
                  (set! bat.3.2 bar.7.3))
              (if (begin
                    (set! ball.1.7 0)
                    (set! bat.5.6 1774106288)
                    (begin
                      (set! tmp.13 0)
                      (> tmp.13 bat.5.6)))
                  (begin
                    (set! bat.0.9 9223372036854775807)
                    (set! foo.6.8 811516044)
                    (set! ball.9.1 bat.0.9))
                  (if (begin
                        (set! tmp.14 -1327371506)
                        (< tmp.14 9223372036854775807))
                      (set! ball.9.1 -9223372036854775808)
                      (set! ball.9.1 9223372036854775807)))
              (jump L.fn.0.1 rbp)))
    (begin
      (if (begin
            (set! tmp.15 1517267005)
            (= tmp.15 605514120))
          (set! bat.5.11 -1228391641)
          (set! bat.5.11 -1926002282))
      (if (begin
            (set! tmp.16 0)
            (> tmp.16 1))
          (set! ball.9.10 9223372036854775807)
          (set! ball.9.10 0))
      (set! tmp.18 25767341)
      (set! tmp.18 (* tmp.18 0))
      (set! tmp.17 tmp.18)
      (halt tmp.17))))
(check-by-interp
 '(module ((locals (bat.6.16 foo.3.19 ball.5.20 bat.6.21 bat.0.17 bar.7.18))
           (undead-out ((bar.7.18) (bat.0.17 bar.7.18)
                                   (bat.0.17 bar.7.18)
                                   (ball.5.20 bat.0.17 bar.7.18)
                                   (ball.5.20 bat.0.17 bar.7.18)
                                   (bat.0.17 bar.7.18)
                                   (() () ())))
           (conflicts ((bar.7.18 (bat.6.16 foo.3.19 ball.5.20 bat.6.21 bat.0.17))
                       (bat.0.17 (bat.6.16 foo.3.19 ball.5.20 bat.6.21 bar.7.18))
                       (bat.6.21 (bar.7.18 bat.0.17))
                       (ball.5.20 (foo.3.19 bar.7.18 bat.0.17))
                       (foo.3.19 (bar.7.18 bat.0.17 ball.5.20))
                       (bat.6.16 (bar.7.18 bat.0.17)))))
          (define L.func.0.1
            ((locals (bat.0.4 ball.8.5 tmp.22 bat.6.1 bat.0.2 bar.4.3 tmp.24 tmp.23))
             (undead-out (() (((tmp.22) ()) (() () () ()) ((tmp.24) (tmp.24) (tmp.23) ()))
                             (() () (() () ()))))
             (conflicts ((tmp.23 ()) (tmp.24 ())
                                     (bar.4.3 ())
                                     (bat.0.2 ())
                                     (bat.6.1 ())
                                     (tmp.22 ())
                                     (ball.8.5 ())
                                     (bat.0.4 ()))))
            (if (false)
                (if (not (begin
                           (set! tmp.22 -1086072832)
                           (!= tmp.22 9223372036854775807)))
                    (begin
                      (set! bar.4.3 793954259)
                      (set! bat.0.2 0)
                      (set! bat.6.1 -9223372036854775808)
                      (halt 9223372036854775807))
                    (begin
                      (set! tmp.24 620579510)
                      (set! tmp.24 (+ tmp.24 1))
                      (set! tmp.23 tmp.24)
                      (halt tmp.23)))
                (if (true)
                    (halt 9223372036854775807)
                    (begin
                      (set! ball.8.5 716210269)
                      (set! bat.0.4 -524345693)
                      (halt -9223372036854775808)))))
    (define L.fn.1.2
      ((locals (bat.6.6 foo.3.12
                        ball.5.11
                        ball.5.10
                        tmp.33
                        foo.3.9
                        bar.9.15
                        bat.0.14
                        bat.6.13
                        bar.4.8
                        tmp.30
                        tmp.31
                        tmp.32
                        tmp.28
                        tmp.29
                        tmp.25
                        tmp.26
                        bat.0.7
                        tmp.27))
       (undead-out ((rsi bat.0.7) (bat.6.6 bat.0.7)
                                  (((bat.6.6 bat.0.7)
                                    (((tmp.25 bat.6.6 bat.0.7) (bat.6.6 bat.0.7))
                                     ((tmp.26 bat.6.6 bat.0.7) (bat.6.6 bat.0.7))
                                     ((tmp.27 bat.6.6 bat.0.7) (bat.6.6 bat.0.7)))
                                    ((bat.6.6 bat.0.7) ((tmp.28 bat.6.6 bat.0.7) (bat.6.6 bat.0.7))
                                                       ((tmp.29 bat.6.6 bat.0.7) (bat.6.6 bat.0.7))))
                                   (((tmp.30 bat.0.7) (bat.0.7)) (((tmp.31 bat.0.7) (bat.0.7)) () ())
                                                                 (((tmp.32) ()) () ()))
                                   ((foo.3.12 bat.0.7 bat.6.6) (foo.3.12 bat.0.7 bat.6.6)
                                                               (bat.0.7 bat.6.6)
                                                               (tmp.33 bat.0.7 bat.6.6)
                                                               (tmp.33 bat.0.7 bat.6.6)
                                                               (bat.0.7 bat.6.6)
                                                               (bat.6.6)
                                                               (bat.0.14 bat.6.6)
                                                               (bat.0.14 bat.6.6)
                                                               (bat.6.6)
                                                               ()))))
       (conflicts ((tmp.27 (bat.0.7 bat.6.6)) (bat.0.7 (bat.6.6 rsi
                                                                tmp.25
                                                                tmp.26
                                                                tmp.27
                                                                tmp.28
                                                                tmp.29
                                                                tmp.30
                                                                tmp.31
                                                                foo.3.9
                                                                tmp.33
                                                                ball.5.10
                                                                ball.5.11))
                                              (tmp.26 (bat.0.7 bat.6.6))
                                              (tmp.25 (bat.0.7 bat.6.6))
                                              (tmp.29 (bat.0.7 bat.6.6))
                                              (tmp.28 (bat.0.7 bat.6.6))
                                              (tmp.32 ())
                                              (tmp.31 (bat.0.7))
                                              (tmp.30 (bat.0.7))
                                              (bar.4.8 (bat.6.6))
                                              (bat.6.13 (bat.6.6 bat.0.14))
                                              (bat.0.14 (bat.6.13 bat.6.6))
                                              (bar.9.15 (bat.6.6))
                                              (foo.3.9 (bat.6.6 bat.0.7))
                                              (tmp.33 (bat.6.6 bat.0.7))
                                              (ball.5.10 (bat.6.6 bat.0.7))
                                              (ball.5.11 (bat.0.7 foo.3.12))
                                              (foo.3.12 (ball.5.11 bat.6.6))
                                              (bat.6.6 (bat.0.7 tmp.25
                                                                tmp.26
                                                                tmp.27
                                                                tmp.28
                                                                tmp.29
                                                                bar.4.8
                                                                bat.6.13
                                                                bat.0.14
                                                                bar.9.15
                                                                foo.3.9
                                                                tmp.33
                                                                ball.5.10
                                                                foo.3.12))
                                              (rsi (bat.0.7)))))
      (begin
        (set! bat.0.7 rdi)
        (set! bat.6.6 rsi)
        (if (if (true)
                (if (begin
                      (set! tmp.25 0)
                      (> tmp.25 9223372036854775807))
                    (begin
                      (set! tmp.26 1)
                      (<= tmp.26 -330770905))
                    (begin
                      (set! tmp.27 0)
                      (> tmp.27 bat.0.7)))
                (if (>= bat.0.7 bat.0.7)
                    (begin
                      (set! tmp.28 -1763336001)
                      (<= tmp.28 1))
                    (begin
                      (set! tmp.29 9223372036854775807)
                      (>= tmp.29 -1870920433))))
            (if (not (begin
                       (set! tmp.30 -9223372036854775808)
                       (= tmp.30 1676706544)))
                (if (begin
                      (set! tmp.31 0)
                      (<= tmp.31 bat.0.7))
                    (halt -9223372036854775808)
                    (halt bat.0.7))
                (if (begin
                      (set! tmp.32 -9223372036854775808)
                      (<= tmp.32 1745852904))
                    (halt 592053094)
                    (halt -1824096668)))
            (begin
              (set! foo.3.12 bat.0.7)
              (set! ball.5.11 bat.6.6)
              (set! ball.5.10 foo.3.12)
              (set! tmp.33 1995506902)
              (set! tmp.33 (+ tmp.33 -677333479))
              (set! foo.3.9 tmp.33)
              (set! bar.9.15 bat.0.7)
              (set! bat.0.14 -1273465885)
              (set! bat.6.13 148631858)
              (set! bar.4.8 bat.0.14)
              (halt bat.6.6)))))
    (begin
      (set! bar.7.18 -1536502942)
      (set! bat.0.17 -1557455680)
      (set! bat.6.21 -1112875927)
      (set! ball.5.20 9223372036854775807)
      (set! foo.3.19 9223372036854775807)
      (set! bat.6.16 ball.5.20)
      (if (<= bar.7.18 bat.0.17)
          (halt 1132619346)
          (halt 0)))))
(check-by-interp '(module ((locals (foo.5.5 foo.8.4 foobar.2.3 foobar.3.2 foo.8.1))
                           (undead-out (() ((foobar.3.2) (foobar.3.2) ()) (() () () ())))
                           (conflicts ((foo.8.1 (foobar.3.2)) (foobar.3.2 (foo.8.1))
                                                              (foobar.2.3 ())
                                                              (foo.8.4 ())
                                                              (foo.5.5 ()))))
                          (if (true)
                              (begin
                                (set! foobar.3.2 -9223372036854775808)
                                (set! foo.8.1 9223372036854775807)
                                (halt foobar.3.2))
                              (begin
                                (set! foo.5.5 -9223372036854775808)
                                (set! foo.8.4 1929590320)
                                (set! foobar.2.3 0)
                                (halt 0)))
                    ))
(check-by-interp
 '(module ((locals (foo.0.7 foo.0.1 ball.9.4 bat.3.5 bat.3.2 tmp.8 bar.1.3 bat.5.6))
           (undead-out ((((tmp.8) ()) (bar.1.3) (bar.1.3)) (bar.1.3)
                                                           (bar.1.3)
                                                           (ball.9.4 bar.1.3)
                                                           (bar.1.3)
                                                           (bar.1.3)
                                                           (bat.5.6)
                                                           ()))
           (conflicts ((bat.5.6 ()) (bar.1.3 (foo.0.7 foo.0.1 ball.9.4 bat.3.5 bat.3.2))
                                    (tmp.8 ())
                                    (bat.3.2 (bar.1.3))
                                    (bat.3.5 (bar.1.3))
                                    (ball.9.4 (bar.1.3))
                                    (foo.0.1 (bar.1.3))
                                    (foo.0.7 (bar.1.3)))))
          (begin
            (if (begin
                  (set! tmp.8 9223372036854775807)
                  (> tmp.8 1398326902))
                (set! bar.1.3 9223372036854775807)
                (set! bar.1.3 9223372036854775807))
            (set! bat.3.2 0)
            (set! bat.3.5 -9223372036854775808)
            (set! ball.9.4 -1747244286)
            (set! foo.0.1 ball.9.4)
            (set! foo.0.7 -1923830755)
            (set! bat.5.6 bar.1.3)
            (halt bat.5.6))
    ))
(check-by-interp
 '(module ((locals (tmp.17)) (undead-out ((rbp) (rbp) (((tmp.17) ()) () ())))
                             (conflicts ((tmp.17 ()))))
          (define L.proc.0.1
            ((locals (tmp.9 foo.9.2 bat.6.3 tmp.8 bar.2.5 foo.9.4 tmp.10 tmp.11 bar.0.1))
             (undead-out ((() () ((tmp.8) (tmp.8) ()))
                          ()
                          (tmp.9)
                          (tmp.9)
                          (bar.0.1)
                          ((bar.0.1) ((bar.0.1 tmp.11) (tmp.11) (tmp.10) ()) (() () ()))))
             (conflicts ((bar.0.1 (tmp.11)) (tmp.11 (bar.0.1))
                                            (tmp.10 ())
                                            (foo.9.4 ())
                                            (bar.2.5 ())
                                            (tmp.8 ())
                                            (bat.6.3 ())
                                            (foo.9.2 ())
                                            (tmp.9 ()))))
            (begin
              (if (true)
                  (set! bat.6.3 0)
                  (begin
                    (set! tmp.8 1)
                    (set! tmp.8 (* tmp.8 1))
                    (set! bat.6.3 tmp.8)))
              (set! foo.9.2 -9223372036854775808)
              (set! tmp.9 672116958)
              (set! tmp.9 (* tmp.9 1))
              (set! bar.0.1 tmp.9)
              (if (< bar.0.1 980303276)
                  (begin
                    (set! tmp.11 9223372036854775807)
                    (set! tmp.11 (+ tmp.11 bar.0.1))
                    (set! tmp.10 tmp.11)
                    (halt tmp.10))
                  (begin
                    (set! bar.2.5 -667597146)
                    (set! foo.9.4 1438122241)
                    (halt 1900048603)))))
    (define L.proc.1.2
      ((locals (tmp.15 tmp.16 tmp.12 tmp.13 tmp.14 bat.6.6 ball.3.7))
       (undead-out (() ((((tmp.12) ()) ((tmp.13) ()) ((tmp.14) ())) () (() () ()))
                       ((tmp.16) (tmp.16) (tmp.15) ())))
       (conflicts
        ((ball.3.7 ()) (bat.6.6 ()) (tmp.14 ()) (tmp.13 ()) (tmp.12 ()) (tmp.16 ()) (tmp.15 ()))))
      (if (true)
          (if (if (begin
                    (set! tmp.12 0)
                    (< tmp.12 -9223372036854775808))
                  (begin
                    (set! tmp.13 0)
                    (<= tmp.13 -9223372036854775808))
                  (begin
                    (set! tmp.14 9223372036854775807)
                    (> tmp.14 -1813633866)))
              (halt -935154891)
              (begin
                (set! ball.3.7 -1449852093)
                (set! bat.6.6 -9223372036854775808)
                (halt 1)))
          (begin
            (set! tmp.16 -1450359427)
            (set! tmp.16 (+ tmp.16 -701676518))
            (set! tmp.15 tmp.16)
            (halt tmp.15))))
    (if (false)
        (jump L.proc.1.2 rbp)
        (if (begin
              (set! tmp.17 1)
              (!= tmp.17 9223372036854775807))
            (halt 313960847)
            (halt 0)))))
(check-by-interp '(module ((locals (tmp.4 tmp.3 tmp.2 tmp.1))
                           (undead-out ((((tmp.1) ()) ((tmp.2) ()) ((tmp.3) ())) (((tmp.4) ()) () ())
                                                                                 ()))
                           (conflicts ((tmp.1 ()) (tmp.2 ()) (tmp.3 ()) (tmp.4 ()))))
                          (if (if (begin
                                    (set! tmp.1 -500842013)
                                    (< tmp.1 -2010375969))
                                  (begin
                                    (set! tmp.2 -1785958547)
                                    (< tmp.2 9223372036854775807))
                                  (begin
                                    (set! tmp.3 904902616)
                                    (<= tmp.3 1)))
                              (if (begin
                                    (set! tmp.4 -1568723397)
                                    (= tmp.4 0))
                                  (halt 1)
                                  (halt -9223372036854775808))
                              (halt 1))
                    ))
(check-by-interp '(module ((locals (tmp.1)) (undead-out (() () (((tmp.1) ()) () ())))
                                            (conflicts ((tmp.1 ()))))
                          (if (false)
                              (halt 0)
                              (if (begin
                                    (set! tmp.1 1)
                                    (>= tmp.1 0))
                                  (halt 281602960)
                                  (halt 9223372036854775807)))
                    ))
(check-by-interp '(module ((locals (tmp.3 tmp.1 tmp.2))
                           (undead-out (() ((tmp.2) (tmp.2) (tmp.1) ()) (((tmp.3) ()) () ())))
                           (conflicts ((tmp.2 ()) (tmp.1 ()) (tmp.3 ()))))
                          (if (true)
                              (begin
                                (set! tmp.2 -1267155910)
                                (set! tmp.2 (+ tmp.2 -9223372036854775808))
                                (set! tmp.1 tmp.2)
                                (halt tmp.1))
                              (if (begin
                                    (set! tmp.3 901304193)
                                    (>= tmp.3 1))
                                  (halt 0)
                                  (halt -154349390)))
                    ))
(check-by-interp '(module ((locals ()) (undead-out ()) (conflicts ())) (halt 9223372036854775807)
                    ))
(check-by-interp '(module ((locals (foo.7.1 bar.2.2 tmp.3 tmp.4))
                           (undead-out (() ((tmp.4) (tmp.4) (tmp.3) ()) (() (foo.7.1) ())))
                           (conflicts ((tmp.4 ()) (tmp.3 ()) (bar.2.2 ()) (foo.7.1 ()))))
                          (if (true)
                              (begin
                                (set! tmp.4 -9223372036854775808)
                                (set! tmp.4 (+ tmp.4 1965973068))
                                (set! tmp.3 tmp.4)
                                (halt tmp.3))
                              (begin
                                (set! bar.2.2 -644439618)
                                (set! foo.7.1 1)
                                (halt foo.7.1)))
                    ))

;;

;; !!! Added by Trevor on March 2nd 2026
(check-by-interp
 '(module ((locals ()) (undead-out ((rdi rbp) (rdi rbp))) (conflicts ((rdi (rbp)) (rbp (rdi)))))
          (define L.L.func.0.1.4
            ((locals ()) (undead-out ()) (conflicts ()))
            (halt 0))
    (define L.L.tmp.1.2.5
      ((locals (foo.2.1.5)) (undead-out ((rbp) (rbp)))
                            (conflicts ((foo.2.1.5 (rbp)) (rbp (foo.2.1.5)))))
      (begin
        (set! foo.2.1.5 rdi)
        (jump L.L.func.0.1.4 rbp)))
    (define L.L.func.2.3.6
      ((locals (tmp.10 foobar.6.4.8 bar.4.2.6 foo.2.3.7 tmp.9))
       (undead-out ((() ((foo.2.3.7) (bar.4.2.6)) ((tmp.9) (tmp.9) (bar.4.2.6)))
                    (((tmp.10 bar.4.2.6) (bar.4.2.6)) () ())
                    ()))
       (conflicts
        ((tmp.9 ()) (foo.2.3.7 ()) (bar.4.2.6 (tmp.10)) (foobar.6.4.8 ()) (tmp.10 (bar.4.2.6)))))
      (begin
        (if (true)
            (begin
              (set! foo.2.3.7 1)
              (set! bar.4.2.6 foo.2.3.7))
            (begin
              (set! tmp.9 -9223372036854775808)
              (set! tmp.9 (* tmp.9 1806293504))
              (set! bar.4.2.6 tmp.9)))
        (if (begin
              (set! tmp.10 1)
              (> tmp.10 0))
            (set! foobar.6.4.8 156890122)
            (set! foobar.6.4.8 bar.4.2.6))
        (halt 0)))
    (begin
      (set! rdi -1860620182)
      (jump L.L.tmp.1.2.5 rbp rdi))))
(check-by-interp
 '(module ((locals (tmp.20 ball.0.4.8 tmp.18 tmp.19))
           (undead-out ((tmp.18) (tmp.18) (ball.0.4.8) (tmp.20) (tmp.20) (tmp.19) ()))
           (conflicts ((tmp.19 ()) (tmp.18 ()) (ball.0.4.8 ()) (tmp.20 ()))))
          (define L.L.tmp.0.1.4
            ((locals (tmp.10 tmp.11 tmp.9))
             (undead-out (((tmp.9 rbp) (rbp)) (rbp) ((tmp.11) (tmp.11) (tmp.10) ())))
             (conflicts ((tmp.9 (rbp)) (tmp.11 ()) (tmp.10 ()) (rbp (tmp.9)))))
            (if (begin
                  (set! tmp.9 9223372036854775807)
                  (>= tmp.9 -1020514810))
                (jump L.L.x.2.3.6 rbp)
                (begin
                  (set! tmp.11 1)
                  (set! tmp.11 (* tmp.11 0))
                  (set! tmp.10 tmp.11)
                  (halt tmp.10))))
    (define L.L.func.1.2.5
      ((locals (bar.1.1.5 tmp.12)) (undead-out ((bar.1.1.5) (((tmp.12 bar.1.1.5) (bar.1.1.5)) () ())))
                                   (conflicts ((tmp.12 (bar.1.1.5)) (bar.1.1.5 (tmp.12)))))
      (begin
        (set! bar.1.1.5 -9223372036854775808)
        (if (not (begin
                   (set! tmp.12 9223372036854775807)
                   (> tmp.12 0)))
            (halt 1309557052)
            (halt bar.1.1.5))))
    (define L.L.x.2.3.6
      ((locals (tmp.17 bar.3.3.7 tmp.16 tmp.14 tmp.15 ball.0.2.6 tmp.13))
       (undead-out ((() ((tmp.13) ()) ()) (((tmp.14) ()) (((tmp.15) ()) () ()) ((ball.0.2.6) ()))
                                          ((((tmp.16) ()) (bar.3.3.7) (bar.3.3.7))
                                           (((tmp.17 bar.3.3.7) (bar.3.3.7)) () ()))))
       (conflicts ((tmp.13 ()) (ball.0.2.6 ())
                               (tmp.15 ())
                               (tmp.14 ())
                               (tmp.16 ())
                               (bar.3.3.7 (tmp.17))
                               (tmp.17 (bar.3.3.7)))))
      (if (if (true)
              (not (begin
                     (set! tmp.13 0)
                     (> tmp.13 1)))
              (true))
          (if (begin
                (set! tmp.14 0)
                (> tmp.14 0))
              (if (begin
                    (set! tmp.15 9223372036854775807)
                    (< tmp.15 9223372036854775807))
                  (halt 9223372036854775807)
                  (halt -260353756))
              (begin
                (set! ball.0.2.6 0)
                (halt ball.0.2.6)))
          (begin
            (if (begin
                  (set! tmp.16 -302047143)
                  (!= tmp.16 0))
                (set! bar.3.3.7 9223372036854775807)
                (set! bar.3.3.7 102036653))
            (if (begin
                  (set! tmp.17 0)
                  (= tmp.17 bar.3.3.7))
                (halt bar.3.3.7)
                (halt -362331747)))))
    (begin
      (set! tmp.18 -9223372036854775808)
      (set! tmp.18 (* tmp.18 -9223372036854775808))
      (set! ball.0.4.8 tmp.18)
      (set! tmp.20 ball.0.4.8)
      (set! tmp.20 (+ tmp.20 0))
      (set! tmp.19 tmp.20)
      (halt tmp.19))))
(check-by-interp
 '(module ((locals ()) (undead-out ((rdi rbp) (rdi rbp))) (conflicts ((rdi (rbp)) (rbp (rdi)))))
          (define L.L.proc.0.1.4
            ((locals (ball.6.1.5)) (undead-out ((rbp) (rbp)))
                                   (conflicts ((ball.6.1.5 (rbp)) (rbp (ball.6.1.5)))))
            (begin
              (set! ball.6.1.5 rdi)
              (jump L.L.func.1.2.5 rbp)))
    (define L.L.func.1.2.5
      ((locals (tmp.10 tmp.9)) (undead-out ((tmp.10) (tmp.10) (tmp.9) ()))
                               (conflicts ((tmp.9 ()) (tmp.10 ()))))
      (begin
        (set! tmp.10 1)
        (set! tmp.10 (* tmp.10 0))
        (set! tmp.9 tmp.10)
        (halt tmp.9)))
    (define L.L.fn.2.3.6
      ((locals (ball.3.2.6 bat.0.3.7 tmp.11 foo.4.4.8))
       (undead-out ((rbp) ((rbp) ((((tmp.11) ()) () ()) () ()) (rbp))))
       (conflicts ((foo.4.4.8 ()) (tmp.11 ()) (bat.0.3.7 ()) (ball.3.2.6 (rbp)) (rbp (ball.3.2.6)))))
      (begin
        (set! ball.3.2.6 rdi)
        (if (true)
            (begin
              (if (begin
                    (set! tmp.11 -2033705372)
                    (<= tmp.11 965540822))
                  (set! bat.0.3.7 -1853172774)
                  (set! bat.0.3.7 1133506028))
              (set! foo.4.4.8 1)
              (halt 1236904416))
            (jump L.L.func.1.2.5 rbp))))
    (begin
      (set! rdi 1)
      (jump L.L.proc.0.1.4 rbp rdi))))
(check-by-interp
 '(module ((locals (tmp.7)) (undead-out ((rbp) (((tmp.7) ()) () ()) (rbp))) (conflicts ((tmp.7 ()))))
          (define L.fn.0.1
            ((locals (foo.5.2 foo.5.4 ball.4.3 bat.9.1 tmp.6 tmp.5))
             (undead-out ((() (bat.9.1) (() (bat.9.1)))
                          ((((tmp.5 bat.9.1) (bat.9.1)) ((tmp.6 bat.9.1) (bat.9.1)) (bat.9.1))
                           (() ())
                           ((bat.9.1) ()))))
             (conflicts ((tmp.5 (bat.9.1)) (tmp.6 (bat.9.1))
                                           (bat.9.1 (tmp.5 tmp.6))
                                           (ball.4.3 ())
                                           (foo.5.4 ())
                                           (foo.5.2 ()))))
            (begin
              (if (false)
                  (set! bat.9.1 1)
                  (begin
                    (set! foo.5.2 1)
                    (set! bat.9.1 1)))
              (if (if (begin
                        (set! tmp.5 9223372036854775807)
                        (>= tmp.5 -9223372036854775808))
                      (begin
                        (set! tmp.6 -248968641)
                        (= tmp.6 9223372036854775807))
                      (!= bat.9.1 -9223372036854775808))
                  (begin
                    (set! ball.4.3 bat.9.1)
                    (halt 1622965009))
                  (begin
                    (set! foo.5.4 bat.9.1)
                    (halt bat.9.1)))))
    (if (false)
        (if (begin
              (set! tmp.7 995853130)
              (>= tmp.7 1))
            (halt 1)
            (halt -9223372036854775808))
        (jump L.fn.0.1 rbp))))
(check-by-interp '(module ((locals (tmp.2 tmp.1)) (undead-out ((tmp.2) (tmp.2) (tmp.1) ()))
                                                  (conflicts ((tmp.1 ()) (tmp.2 ()))))
                          (begin
                            (set! tmp.2 -9223372036854775808)
                            (set! tmp.2 (+ tmp.2 -1465538260))
                            (set! tmp.1 tmp.2)
                            (halt tmp.1))
                    ))
(check-by-interp
 '(module ((locals (ball.9.9 bat.5.8)) (undead-out ((bat.5.8) (bat.5.8) ()))
                                       (conflicts ((bat.5.8 (ball.9.9)) (ball.9.9 (bat.5.8)))))
          (define L.fn.0.1
            ((locals (foo.8.2 foo.1.3 tmp.10 bar.2.1))
             (undead-out ((tmp.10) (tmp.10) (bar.2.1) (foo.1.3 bar.2.1) (bar.2.1) ()))
             (conflicts ((bar.2.1 (foo.8.2)) (tmp.10 ()) (foo.1.3 ()) (foo.8.2 (bar.2.1)))))
            (begin
              (set! tmp.10 1)
              (set! tmp.10 (+ tmp.10 9223372036854775807))
              (set! bar.2.1 tmp.10)
              (set! foo.1.3 bar.2.1)
              (set! foo.8.2 foo.1.3)
              (halt bar.2.1)))
    (define L.func.1.2
      ((locals (tmp.13 tmp.11 foo.8.5 ball.3.4 foo.1.6 foo.8.7 tmp.12))
       (undead-out ((((foo.8.5) ((foo.8.5 tmp.11) ())) (() (ball.3.4)) ((foo.8.7) (ball.3.4)))
                    (ball.3.4 tmp.13)
                    (tmp.13)
                    (tmp.12)
                    ()))
       (conflicts ((tmp.12 ()) (foo.8.7 ())
                               (foo.1.6 ())
                               (ball.3.4 ())
                               (foo.8.5 (tmp.11))
                               (tmp.11 (foo.8.5))
                               (tmp.13 ()))))
      (begin
        (if (begin
              (set! foo.8.5 1)
              (begin
                (set! tmp.11 1)
                (< tmp.11 foo.8.5)))
            (begin
              (set! foo.1.6 406779451)
              (set! ball.3.4 1200977699))
            (begin
              (set! foo.8.7 0)
              (set! ball.3.4 foo.8.7)))
        (set! tmp.13 ball.3.4)
        (set! tmp.13 (* tmp.13 ball.3.4))
        (set! tmp.12 tmp.13)
        (halt tmp.12)))
    (begin
      (set! bat.5.8 1)
      (set! ball.9.9 0)
      (halt bat.5.8))))
(check-by-interp
 '(module ((locals (tmp.13)) (undead-out (((tmp.13) ()) () ())) (conflicts ((tmp.13 ()))))
          (define L.x.0.1
            ((locals (foo.0.1 ball.1.2)) (undead-out ((rsi rbp) (rbp) (rbp)))
                                         (conflicts ((ball.1.2 (rbp rsi)) (foo.0.1 (rbp))
                                                                          (rsi (ball.1.2))
                                                                          (rbp (foo.0.1 ball.1.2)))))
            (begin
              (set! ball.1.2 rdi)
              (set! foo.0.1 rsi)
              (jump L.tmp.1.2 rbp)))
    (define L.tmp.1.2
      ((locals (tmp.12 foobar.9.5 tmp.11 ball.4.3 bar.5.4 tmp.10 tmp.9 tmp.8))
       (undead-out (((((tmp.8) ()) ((tmp.9) ()) ((tmp.10) ())) () ())
                    ((bar.5.4) (ball.4.3) ((ball.4.3) () ()))
                    ((((tmp.11) ()) (foobar.9.5) (foobar.9.5)) (((foobar.9.5 tmp.12) ()) () ()))))
       (conflicts ((tmp.8 ()) (tmp.9 ())
                              (tmp.10 ())
                              (bar.5.4 ())
                              (ball.4.3 ())
                              (tmp.11 ())
                              (foobar.9.5 (tmp.12))
                              (tmp.12 (foobar.9.5)))))
      (if (if (if (begin
                    (set! tmp.8 -765445006)
                    (<= tmp.8 0))
                  (begin
                    (set! tmp.9 0)
                    (!= tmp.9 -7399083))
                  (begin
                    (set! tmp.10 9223372036854775807)
                    (<= tmp.10 1)))
              (false)
              (true))
          (begin
            (set! bar.5.4 -9223372036854775808)
            (set! ball.4.3 bar.5.4)
            (if (> ball.4.3 ball.4.3)
                (halt -9223372036854775808)
                (halt ball.4.3)))
          (begin
            (if (begin
                  (set! tmp.11 1)
                  (>= tmp.11 0))
                (set! foobar.9.5 -9223372036854775808)
                (set! foobar.9.5 -9223372036854775808))
            (if (begin
                  (set! tmp.12 0)
                  (= tmp.12 foobar.9.5))
                (halt 0)
                (halt 9223372036854775807)))))
    (define L.func.2.3
      ((locals (ball.6.6 ball.4.7))
       (undead-out ((rsi rbp) (rbp) (rbp)))
       (conflicts ((ball.4.7 (rbp rsi)) (ball.6.6 (rbp)) (rsi (ball.4.7)) (rbp (ball.6.6 ball.4.7)))))
      (begin
        (set! ball.4.7 rdi)
        (set! ball.6.6 rsi)
        (jump L.tmp.1.2 rbp)))
    (if (begin
          (set! tmp.13 0)
          (<= tmp.13 1))
        (halt -1271132888)
        (halt 2101306416))))
(check-by-interp
 '(module ((locals (tmp.7)) (undead-out (((tmp.7) ()) () ())) (conflicts ((tmp.7 ()))))
          (define L.proc.0.1
            ((locals (bat.3.5 tmp.6 bat.7.2 bat.4.3 foobar.2.4 bar.8.1))
             (undead-out ((bar.8.1) ((bar.8.1) ((bar.8.1) (bat.7.2 bar.8.1))
                                               ((foobar.2.4 bar.8.1) (bat.7.2 bar.8.1)))
                                    (bat.7.2 tmp.6 bar.8.1)
                                    (tmp.6 bar.8.1)
                                    (bar.8.1)
                                    ((bar.8.1) () ())))
             (conflicts ((bar.8.1 (bat.3.5 tmp.6 foobar.2.4 bat.7.2)) (foobar.2.4 (bar.8.1))
                                                                      (bat.4.3 ())
                                                                      (bat.7.2 (tmp.6 bar.8.1))
                                                                      (tmp.6 (bar.8.1 bat.7.2))
                                                                      (bat.3.5 (bar.8.1)))))
            (begin
              (set! bar.8.1 rdi)
              (if (false)
                  (begin
                    (set! bat.4.3 bar.8.1)
                    (set! bat.7.2 1733388107))
                  (begin
                    (set! foobar.2.4 -818241658)
                    (set! bat.7.2 foobar.2.4)))
              (set! tmp.6 -1769976594)
              (set! tmp.6 (* tmp.6 bat.7.2))
              (set! bat.3.5 tmp.6)
              (if (!= bar.8.1 bar.8.1)
                  (halt 1)
                  (halt bar.8.1))))
    (if (begin
          (set! tmp.7 0)
          (<= tmp.7 0))
        (halt 1764584349)
        (halt -9223372036854775808))))
(check-by-interp
 '(module ((locals (ball.1.5 foobar.4.4 tmp.8))
           (undead-out ((ball.1.5) (foobar.4.4) (((foobar.4.4 tmp.8) ()) () ())))
           (conflicts ((tmp.8 (foobar.4.4)) (foobar.4.4 (tmp.8)) (ball.1.5 ()))))
          (define L.proc.0.1
            ((locals (tmp.6 ball.3.1 bat.9.3 foobar.4.2 tmp.7))
             (undead-out
              ((ball.3.1 rbp)
               ((ball.3.1 rbp) (rbp) ((ball.3.1) (ball.3.1) (ball.3.1 tmp.7) (tmp.7) (tmp.6) ()))))
             (conflicts ((tmp.7 (ball.3.1)) (foobar.4.2 (ball.3.1))
                                            (bat.9.3 ())
                                            (ball.3.1 (rbp tmp.7 foobar.4.2))
                                            (tmp.6 ())
                                            (rbp (ball.3.1)))))
            (begin
              (set! ball.3.1 rdi)
              (if (not (false))
                  (jump L.x.1.2 rbp)
                  (begin
                    (set! bat.9.3 ball.3.1)
                    (set! foobar.4.2 9223372036854775807)
                    (set! tmp.7 -9223372036854775808)
                    (set! tmp.7 (+ tmp.7 ball.3.1))
                    (set! tmp.6 tmp.7)
                    (halt tmp.6)))))
    (define L.x.1.2
      ((locals ()) (undead-out ()) (conflicts ()))
      (halt 1))
    (begin
      (set! ball.1.5 453798193)
      (set! foobar.4.4 ball.1.5)
      (if (begin
            (set! tmp.8 9223372036854775807)
            (>= tmp.8 foobar.4.4))
          (halt 0)
          (halt -1617493587)))))
(check-by-interp
 '(module ((locals (tmp.5 tmp.6)) (undead-out ((rbp) ((tmp.6) (tmp.6) (tmp.5) ()) (rbp)))
                                  (conflicts ((tmp.6 ()) (tmp.5 ()))))
          (define L.func.0.1
            ((locals (tmp.4 tmp.3 bat.8.1 bat.2.2))
             (undead-out ((rbp bat.8.1)
                          ((((tmp.3 rbp bat.8.1) (tmp.3 rbp bat.8.1) (rbp bat.8.1)) (rbp bat.8.1))
                           ((bat.8.1) ((bat.8.1) () ()) (((tmp.4 bat.8.1) (bat.8.1)) () ()))
                           (rbp))))
             (conflicts ((bat.2.2 (bat.8.1 rbp)) (bat.8.1 (rbp tmp.3 bat.2.2 tmp.4))
                                                 (tmp.3 (bat.8.1 rbp))
                                                 (tmp.4 (bat.8.1))
                                                 (rbp (bat.8.1 tmp.3 bat.2.2)))))
            (begin
              (set! bat.8.1 rdi)
              (if (begin
                    (begin
                      (set! tmp.3 9223372036854775807)
                      (set! tmp.3 (* tmp.3 bat.8.1))
                      (set! bat.2.2 tmp.3))
                    (true))
                  (if (true)
                      (if (< bat.8.1 -9223372036854775808)
                          (halt bat.8.1)
                          (halt bat.8.1))
                      (if (begin
                            (set! tmp.4 -9223372036854775808)
                            (= tmp.4 bat.8.1))
                          (halt bat.8.1)
                          (halt bat.8.1)))
                  (jump L.proc.1.2 rbp))))
    (define L.proc.1.2
      ((locals ()) (undead-out ((rdi rbp) (rdi rbp))) (conflicts ((rdi (rbp)) (rbp (rdi)))))
      (begin
        (set! rdi 954069433)
        (jump L.func.0.1 rbp rdi)))
    (if (false)
        (begin
          (set! tmp.6 1337690701)
          (set! tmp.6 (* tmp.6 9223372036854775807))
          (set! tmp.5 tmp.6)
          (halt tmp.5))
        (jump L.proc.1.2 rbp))))
(check-by-interp '(module ((locals (tmp.2 tmp.1)) (undead-out (((tmp.1) ()) (((tmp.2) ()) () ()) ()))
                                                  (conflicts ((tmp.1 ()) (tmp.2 ()))))
                          (if (not (begin
                                     (set! tmp.1 1)
                                     (> tmp.1 9223372036854775807)))
                              (if (begin
                                    (set! tmp.2 1)
                                    (>= tmp.2 1197468889))
                                  (halt 9223372036854775807)
                                  (halt 1))
                              (halt 1))
                    ))
(check-by-interp
 '(module ((locals ()) (undead-out ((r8 rbp) (r8 rcx rbp)
                                             (r8 rcx rdx rbp)
                                             (r8 rcx rdx rsi rbp)
                                             (r8 rcx rdx rsi rdi rbp)
                                             (r8 rcx rdx rsi rdi rbp)))
                       (conflicts ((r8 (rdi rsi rdx rcx rbp)) (rbp (rdi rsi rdx rcx r8))
                                                              (rcx (rdi rsi rdx rbp r8))
                                                              (rdx (rdi rsi rbp rcx r8))
                                                              (rsi (rdi rbp rdx rcx r8))
                                                              (rdi (rbp rsi rdx rcx r8)))))
          (define L.func.0.1
            ((locals (foobar.4.1 bat.7.2 bar.1.3 foo.2.4 foo.9.5))
             (undead-out ((rsi rdx rcx r8) (rdx rcx r8) (rcx r8) (r8) () ()))
             (conflicts ((foo.9.5 (r8 rcx rdx rsi)) (foo.2.4 (r8 rcx rdx))
                                                    (bar.1.3 (r8 rcx))
                                                    (bat.7.2 (r8))
                                                    (foobar.4.1 ())
                                                    (rsi (foo.9.5))
                                                    (rdx (foo.2.4 foo.9.5))
                                                    (rcx (bar.1.3 foo.2.4 foo.9.5))
                                                    (r8 (bat.7.2 bar.1.3 foo.2.4 foo.9.5)))))
            (begin
              (set! foo.9.5 rdi)
              (set! foo.2.4 rsi)
              (set! bar.1.3 rdx)
              (set! bat.7.2 rcx)
              (set! foobar.4.1 r8)
              (halt -1458025903)))
    (begin
      (set! r8 0)
      (set! rcx -9223372036854775808)
      (set! rdx -808937821)
      (set! rsi 1)
      (set! rdi -9223372036854775808)
      (jump L.func.0.1 rbp rdi rsi rdx rcx r8))))
(check-by-interp
 '(module ((locals (ball.6.6)) (undead-out ((ball.6.6) ())) (conflicts ((ball.6.6 ()))))
          (define L.tmp.0.1
            ((locals (foobar.0.1 bar.8.2 tmp.9 bat.2.5 tmp.10 tmp.8 ball.6.4 bat.5.3 tmp.7))
             (undead-out ((rsi rdx rcx ball.6.4)
                          (rdx rcx ball.6.4 bat.5.3)
                          (rcx ball.6.4 bat.5.3)
                          (ball.6.4 bat.5.3)
                          (ball.6.4 bat.5.3 bat.2.5)
                          ((((tmp.7 ball.6.4 bat.5.3 bat.2.5) (ball.6.4 bat.5.3 bat.2.5))
                            ((ball.6.4 tmp.8 bat.5.3 bat.2.5) (bat.5.3 bat.2.5))
                            (bat.5.3 bat.2.5))
                           ((tmp.10) (tmp.10) (tmp.9) ())
                           (() () ()))))
             (conflicts ((tmp.7 (bat.2.5 bat.5.3 ball.6.4))
                         (bat.5.3 (bat.2.5 foobar.0.1 bar.8.2 ball.6.4 rcx rdx tmp.7 tmp.8))
                         (ball.6.4 (foobar.0.1 bar.8.2 bat.5.3 rcx rdx rsi tmp.7 tmp.8))
                         (tmp.8 (bat.2.5 bat.5.3 ball.6.4))
                         (tmp.10 ())
                         (bat.2.5 (bat.5.3 tmp.7 tmp.8))
                         (tmp.9 ())
                         (bar.8.2 (bat.5.3 ball.6.4 rcx))
                         (foobar.0.1 (bat.5.3 ball.6.4))
                         (rsi (ball.6.4))
                         (rdx (bat.5.3 ball.6.4))
                         (rcx (bar.8.2 bat.5.3 ball.6.4)))))
            (begin
              (set! ball.6.4 rdi)
              (set! bat.5.3 rsi)
              (set! bar.8.2 rdx)
              (set! foobar.0.1 rcx)
              (set! bat.2.5 ball.6.4)
              (if (if (begin
                        (set! tmp.7 -9223372036854775808)
                        (<= tmp.7 bat.5.3))
                      (begin
                        (set! tmp.8 -9223372036854775808)
                        (>= tmp.8 ball.6.4))
                      (>= bat.5.3 2025307007))
                  (begin
                    (set! tmp.10 bat.2.5)
                    (set! tmp.10 (+ tmp.10 9223372036854775807))
                    (set! tmp.9 tmp.10)
                    (halt tmp.9))
                  (if (<= bat.5.3 -9223372036854775808)
                      (halt 9223372036854775807)
                      (halt 0)))))
    (begin
      (set! ball.6.6 0)
      (halt ball.6.6))))
(check-by-interp
 '(module ((locals ()) (undead-out ((rdi rbp) (rdi rbp))) (conflicts ((rdi (rbp)) (rbp (rdi)))))
          (define L.func.0.1
            ((locals (ball.6.2 tmp.16 tmp.15 tmp.17 tmp.13 tmp.14 foobar.3.1 tmp.12))
             (undead-out ((rsi ball.6.2)
                          (foobar.3.1 ball.6.2)
                          (((tmp.12 foobar.3.1 ball.6.2) (foobar.3.1 ball.6.2))
                           ((tmp.14) (tmp.14) (tmp.13) ())
                           (((ball.6.2 foobar.3.1) (ball.6.2 foobar.3.1) (ball.6.2 foobar.3.1))
                            ((foobar.3.1 tmp.16) (tmp.16) (tmp.15) ())
                            (((tmp.17 foobar.3.1 ball.6.2) (foobar.3.1 ball.6.2)) () ())))))
             (conflicts ((tmp.12 (ball.6.2 foobar.3.1)) (foobar.3.1 (ball.6.2 tmp.12 tmp.17))
                                                        (tmp.14 ())
                                                        (tmp.13 ())
                                                        (tmp.17 (ball.6.2 foobar.3.1))
                                                        (tmp.15 ())
                                                        (tmp.16 ())
                                                        (ball.6.2 (foobar.3.1 rsi tmp.12 tmp.17))
                                                        (rsi (ball.6.2)))))
            (begin
              (set! ball.6.2 rdi)
              (set! foobar.3.1 rsi)
              (if (begin
                    (set! tmp.12 0)
                    (= tmp.12 foobar.3.1))
                  (begin
                    (set! tmp.14 -9223372036854775808)
                    (set! tmp.14 (+ tmp.14 -9223372036854775808))
                    (set! tmp.13 tmp.14)
                    (halt tmp.13))
                  (if (if (< ball.6.2 ball.6.2)
                          (<= foobar.3.1 foobar.3.1)
                          (= foobar.3.1 ball.6.2))
                      (begin
                        (set! tmp.16 foobar.3.1)
                        (set! tmp.16 (+ tmp.16 foobar.3.1))
                        (set! tmp.15 tmp.16)
                        (halt tmp.15))
                      (if (begin
                            (set! tmp.17 1)
                            (= tmp.17 foobar.3.1))
                          (halt ball.6.2)
                          (halt foobar.3.1))))))
    (define L.x.1.2
      ((locals (ball.5.7 bat.9.5 bat.2.6 tmp.18 tmp.19 ball.1.4 bar.0.3 foo.7.8))
       (undead-out ((bar.0.3) (bat.2.6 bar.0.3)
                              (bar.0.3)
                              (bar.0.3)
                              (bar.0.3 ball.1.4)
                              (((foo.7.8 bar.0.3 ball.1.4) (bar.0.3 ball.1.4))
                               ()
                               ((bar.0.3 tmp.19) (tmp.19) (tmp.18) ()))))
       (conflicts ((foo.7.8 (ball.1.4)) (bar.0.3 (ball.1.4 ball.5.7 bat.9.5 bat.2.6 tmp.19))
                                        (ball.1.4 (bar.0.3 foo.7.8))
                                        (tmp.19 (bar.0.3))
                                        (tmp.18 ())
                                        (bat.2.6 (bar.0.3))
                                        (bat.9.5 (bar.0.3))
                                        (ball.5.7 (bar.0.3)))))
      (begin
        (set! bar.0.3 rdi)
        (set! bat.2.6 1757280127)
        (set! bat.9.5 bat.2.6)
        (set! ball.5.7 1)
        (set! ball.1.4 -1128483887)
        (if (begin
              (set! foo.7.8 bar.0.3)
              (> foo.7.8 foo.7.8))
            (halt ball.1.4)
            (begin
              (set! tmp.19 ball.1.4)
              (set! tmp.19 (+ tmp.19 bar.0.3))
              (set! tmp.18 tmp.19)
              (halt tmp.18)))))
    (define L.fn.2.3
      ((locals (tmp.24 ball.1.10 foo.4.11 tmp.22 tmp.23 tmp.20 foobar.8.9 tmp.21))
       (undead-out ((((tmp.20) (tmp.20) ()) ((tmp.21) ())) ((tmp.23) (tmp.23) (tmp.22) ())
                                                           ((tmp.24) (tmp.24) (ball.1.10) () ())))
       (conflicts ((tmp.21 ()) (foobar.8.9 ())
                               (tmp.20 ())
                               (tmp.23 ())
                               (tmp.22 ())
                               (foo.4.11 ())
                               (ball.1.10 ())
                               (tmp.24 ()))))
      (if (begin
            (begin
              (set! tmp.20 -9223372036854775808)
              (set! tmp.20 (+ tmp.20 -1421853645))
              (set! foobar.8.9 tmp.20))
            (not (begin
                   (set! tmp.21 0)
                   (>= tmp.21 -1400373009))))
          (begin
            (set! tmp.23 -167927521)
            (set! tmp.23 (+ tmp.23 1))
            (set! tmp.22 tmp.23)
            (halt tmp.22))
          (begin
            (set! tmp.24 1041085683)
            (set! tmp.24 (* tmp.24 9223372036854775807))
            (set! ball.1.10 tmp.24)
            (set! foo.4.11 ball.1.10)
            (halt 770292232))))
    (begin
      (set! rdi 1840464414)
      (jump L.x.1.2 rbp rdi))))
(check-by-interp
 '(module ((locals (bat.0.13)) (undead-out (() ())) (conflicts ((bat.0.13 ()))))
          (define L.proc.0.1
            ((locals (ball.2.1 foo.7.2 ball.4.3))
             (undead-out ((rsi rdx rbp) (rdx foo.7.2 rbp)
                                        (foo.7.2 ball.2.1 rbp)
                                        (ball.2.1 rdx rbp)
                                        (rdx rsi rbp)
                                        (rdx rsi rdi rbp)
                                        (rdx rsi rdi rbp)))
             (conflicts ((ball.4.3 (rbp rdx rsi)) (foo.7.2 (ball.2.1 rbp rdx))
                                                  (ball.2.1 (rdx rbp foo.7.2))
                                                  (rsi (rdi rbp rdx ball.4.3))
                                                  (rdx (rdi rsi rbp ball.2.1 foo.7.2 ball.4.3))
                                                  (rbp (rdi rsi rdx ball.2.1 foo.7.2 ball.4.3))
                                                  (rdi (rbp rsi rdx)))))
            (begin
              (set! ball.4.3 rdi)
              (set! foo.7.2 rsi)
              (set! ball.2.1 rdx)
              (set! rdx foo.7.2)
              (set! rsi ball.2.1)
              (set! rdi 9223372036854775807)
              (jump L.proc.0.1 rbp rdi rsi rdx)))
    (define L.func.1.2
      ((locals (bar.3.10 foobar.5.12 ball.4.11 bar.3.4 foobar.6.5 ball.4.6 foo.7.7 bat.0.8 ball.1.9))
       (undead-out ((rsi rdx rcx r8 r9 ball.1.9 rbp) (rdx rcx r8 r9 ball.1.9 rbp)
                                                     (rcx r8 r9 foo.7.7 ball.1.9 rbp)
                                                     (r8 r9 foo.7.7 ball.1.9 rbp)
                                                     (r9 foo.7.7 ball.1.9 rbp)
                                                     (foo.7.7 ball.1.9 rbp)
                                                     (ball.1.9 rbp)
                                                     (rbp)
                                                     (bar.3.10 rbp)
                                                     (bar.3.10 rdx rbp)
                                                     (bar.3.10 rdx rsi rbp)
                                                     (rdx rsi rdi rbp)
                                                     (rdx rsi rdi rbp)))
       (conflicts
        ((ball.1.9 (ball.4.11 bar.3.4 foobar.6.5 ball.4.6 foo.7.7 bat.0.8 rbp r9 r8 rcx rdx rsi))
         (bat.0.8 (rbp ball.1.9 r9 r8 rcx rdx))
         (foo.7.7 (bar.3.4 foobar.6.5 ball.4.6 rbp ball.1.9 r9 r8 rcx))
         (ball.4.6 (rbp ball.1.9 foo.7.7 r9 r8))
         (foobar.6.5 (rbp ball.1.9 foo.7.7 r9))
         (bar.3.4 (rbp ball.1.9 foo.7.7))
         (ball.4.11 (rbp ball.1.9))
         (foobar.5.12 (rbp))
         (bar.3.10 (rsi rbp))
         (rsi (rdi rbp rdx bar.3.10 ball.1.9))
         (rdx (rdi rsi rbp bat.0.8 ball.1.9))
         (rcx (foo.7.7 bat.0.8 ball.1.9))
         (r8 (ball.4.6 foo.7.7 bat.0.8 ball.1.9))
         (r9 (foobar.6.5 ball.4.6 foo.7.7 bat.0.8 ball.1.9))
         (rbp (rdi rsi
                   rdx
                   bar.3.10
                   foobar.5.12
                   ball.4.11
                   bar.3.4
                   foobar.6.5
                   ball.4.6
                   foo.7.7
                   bat.0.8
                   ball.1.9))
         (rdi (rbp rsi rdx)))))
      (begin
        (set! ball.1.9 rdi)
        (set! bat.0.8 rsi)
        (set! foo.7.7 rdx)
        (set! ball.4.6 rcx)
        (set! foobar.6.5 r8)
        (set! bar.3.4 r9)
        (set! ball.4.11 foo.7.7)
        (set! foobar.5.12 ball.1.9)
        (set! bar.3.10 -9223372036854775808)
        (set! rdx bar.3.10)
        (set! rsi -780648786)
        (set! rdi bar.3.10)
        (jump L.proc.0.1 rbp rdi rsi rdx)))
    (begin
      (set! bat.0.13 -579691794)
      (halt 953357957))))
(check-by-interp '(module ((locals (ball.2.2 bar.5.1)) (undead-out (() (bar.5.1) (() () ())))
                                                       (conflicts ((bar.5.1 ()) (ball.2.2 ()))))
                          (begin
                            (set! ball.2.2 9223372036854775807)
                            (set! bar.5.1 -546026276)
                            (if (!= bar.5.1 1)
                                (halt 9223372036854775807)
                                (halt 2063023986)))
                    ))
(check-by-interp
 '(module ((locals (tmp.10)) (undead-out (((tmp.10) ()) () ())) (conflicts ((tmp.10 ()))))
          (define L.func.0.1
            ((locals (bat.7.5 bar.2.1 tmp.9 tmp.7 tmp.6 foobar.6.4 tmp.8 foo.8.2 foo.8.3))
             (undead-out ((rsi foo.8.2)
                          (bar.2.1 foo.8.2)
                          (((foo.8.3 bar.2.1 foo.8.2) (bar.2.1 foo.8.2))
                           ((tmp.6) (tmp.6) () (tmp.8) (tmp.8) (tmp.7) ())
                           ((tmp.9 bar.2.1) (tmp.9 bar.2.1) (bat.7.5 bar.2.1) ((bar.2.1) () ())))))
             (conflicts ((foo.8.3 (bar.2.1)) (foo.8.2 (bar.2.1 rsi))
                                             (tmp.8 ())
                                             (foobar.6.4 ())
                                             (tmp.6 ())
                                             (tmp.7 ())
                                             (tmp.9 (bar.2.1))
                                             (bar.2.1 (foo.8.2 foo.8.3 bat.7.5 tmp.9))
                                             (bat.7.5 (bar.2.1))
                                             (rsi (foo.8.2)))))
            (begin
              (set! foo.8.2 rdi)
              (set! bar.2.1 rsi)
              (if (not (begin
                         (set! foo.8.3 foo.8.2)
                         (= foo.8.3 0)))
                  (begin
                    (set! tmp.6 foo.8.2)
                    (set! tmp.6 (+ tmp.6 0))
                    (set! foobar.6.4 tmp.6)
                    (set! tmp.8 0)
                    (set! tmp.8 (* tmp.8 9223372036854775807))
                    (set! tmp.7 tmp.8)
                    (halt tmp.7))
                  (begin
                    (set! tmp.9 0)
                    (set! tmp.9 (* tmp.9 bar.2.1))
                    (set! bat.7.5 tmp.9)
                    (if (!= bat.7.5 -9223372036854775808)
                        (halt bar.2.1)
                        (halt 0))))))
    (if (begin
          (set! tmp.10 9223372036854775807)
          (= tmp.10 -315897602))
        (halt 1)
        (halt -9223372036854775808))))
(check-by-interp
 '(module ((locals (tmp.24 tmp.23)) (undead-out ((tmp.24) (tmp.24) (tmp.23) ()))
                                    (conflicts ((tmp.23 ()) (tmp.24 ()))))
          (define L.fn.0.1
            ((locals (bat.4.5 tmp.16 bat.4.4 tmp.15 foobar.3.2 ball.7.1 bar.9.3 tmp.17))
             (undead-out ((rsi) (ball.7.1)
                                (tmp.15 ball.7.1)
                                (tmp.15 ball.7.1)
                                (bat.4.4 ball.7.1)
                                (bat.4.4 tmp.16 ball.7.1)
                                (tmp.16 ball.7.1)
                                (bar.9.3 ball.7.1)
                                (bar.9.3 ball.7.1)
                                (((bar.9.3 tmp.17 ball.7.1) (ball.7.1)) () ())))
             (conflicts ((tmp.17 (ball.7.1 bar.9.3))
                         (bar.9.3 (bat.4.5 ball.7.1 tmp.17))
                         (ball.7.1 (bat.4.5 bar.9.3 tmp.16 bat.4.4 tmp.15 tmp.17))
                         (foobar.3.2 (rsi))
                         (tmp.15 (ball.7.1))
                         (bat.4.4 (tmp.16 ball.7.1))
                         (tmp.16 (ball.7.1 bat.4.4))
                         (bat.4.5 (ball.7.1 bar.9.3))
                         (rsi (foobar.3.2)))))
            (begin
              (set! foobar.3.2 rdi)
              (set! ball.7.1 rsi)
              (set! tmp.15 1)
              (set! tmp.15 (* tmp.15 9223372036854775807))
              (set! bat.4.4 tmp.15)
              (set! tmp.16 -9223372036854775808)
              (set! tmp.16 (+ tmp.16 bat.4.4))
              (set! bar.9.3 tmp.16)
              (set! bat.4.5 9223372036854775807)
              (if (begin
                    (set! tmp.17 1)
                    (!= tmp.17 bar.9.3))
                  (halt 9223372036854775807)
                  (halt ball.7.1))))
    (define L.x.1.2
      ((locals (tmp.20 foobar.3.7 bat.2.9 bat.4.8 tmp.18 bat.2.6 tmp.19))
       (undead-out ((bat.2.6) (bat.2.6 tmp.18) (tmp.18) () () () (tmp.20) (tmp.20) (tmp.19) ()))
       (conflicts ((tmp.19 ()) (bat.2.6 (tmp.18))
                               (tmp.18 (bat.2.6))
                               (bat.4.8 ())
                               (bat.2.9 ())
                               (foobar.3.7 ())
                               (tmp.20 ()))))
      (begin
        (set! bat.2.6 rdi)
        (set! tmp.18 -1410706204)
        (set! tmp.18 (+ tmp.18 bat.2.6))
        (set! bat.4.8 tmp.18)
        (set! bat.2.9 1)
        (set! foobar.3.7 -9223372036854775808)
        (set! tmp.20 -152436426)
        (set! tmp.20 (* tmp.20 0))
        (set! tmp.19 tmp.20)
        (halt tmp.19)))
    (define L.proc.2.3
      ((locals (tmp.22 foobar.1.14 ball.8.10 foo.0.11 ball.7.12 foo.5.13 tmp.21))
       (undead-out ((rsi rdx rcx foo.5.13) (rdx rcx foo.5.13)
                                           (rcx foo.5.13)
                                           (foo.5.13)
                                           ()
                                           (tmp.22)
                                           (tmp.22)
                                           (tmp.21)
                                           ()))
       (conflicts ((tmp.21 ()) (foo.5.13 (ball.8.10 foo.0.11 ball.7.12 rcx rdx rsi))
                               (ball.7.12 (foo.5.13 rcx rdx))
                               (foo.0.11 (foo.5.13 rcx))
                               (ball.8.10 (foo.5.13))
                               (foobar.1.14 ())
                               (tmp.22 ())
                               (rsi (foo.5.13))
                               (rdx (ball.7.12 foo.5.13))
                               (rcx (foo.0.11 ball.7.12 foo.5.13)))))
      (begin
        (set! foo.5.13 rdi)
        (set! ball.7.12 rsi)
        (set! foo.0.11 rdx)
        (set! ball.8.10 rcx)
        (set! foobar.1.14 foo.5.13)
        (set! tmp.22 956544411)
        (set! tmp.22 (+ tmp.22 1))
        (set! tmp.21 tmp.22)
        (halt tmp.21)))
    (begin
      (set! tmp.24 979460199)
      (set! tmp.24 (+ tmp.24 -1697959716))
      (set! tmp.23 tmp.24)
      (halt tmp.23))))
(check-by-interp
 '(module ((locals ()) (undead-out ((r9 rbp) (r9 r8 rbp)
                                             (r9 r8 rcx rbp)
                                             (r9 r8 rcx rdx rbp)
                                             (r9 r8 rcx rdx rsi rbp)
                                             (r9 r8 rcx rdx rsi rdi rbp)
                                             (r9 r8 rcx rdx rsi rdi rbp)))
                       (conflicts ((r9 (rdi rsi rdx rcx r8 rbp)) (rbp (rdi rsi rdx rcx r8 r9))
                                                                 (r8 (rdi rsi rdx rcx rbp r9))
                                                                 (rcx (rdi rsi rdx rbp r8 r9))
                                                                 (rdx (rdi rsi rbp rcx r8 r9))
                                                                 (rsi (rdi rbp rdx rcx r8 r9))
                                                                 (rdi (rbp rsi rdx rcx r8 r9)))))
          (define L.proc.0.1
            ((locals (ball.6.9 foo.4.10
                               bar.7.8
                               bar.9.7
                               tmp.11
                               bar.5.1
                               ball.8.3
                               bar.0.5
                               foobar.1.6
                               bat.3.2
                               foobar.2.4))
             (undead-out
              ((rsi rdx rcx r8 r9)
               (rdx rcx r8 r9)
               (rcx r8 r9 foobar.2.4)
               (r8 r9 ball.8.3 foobar.2.4)
               (r9 ball.8.3 foobar.2.4 bat.3.2)
               (bar.5.1 ball.8.3 foobar.2.4 bat.3.2)
               (((bar.5.1 ball.8.3 foobar.2.4 bat.3.2) (bar.5.1 ball.8.3 foobar.2.4 bat.3.2))
                ((tmp.11 ball.8.3 foobar.2.4 bat.3.2) (tmp.11 ball.8.3 foobar.2.4 bat.3.2)
                                                      (ball.8.3 foobar.2.4 bat.3.2))
                (ball.8.3 foobar.2.4 bat.3.2))
               (foobar.2.4 bat.3.2)
               (foobar.2.4 bat.3.2)
               ((bat.3.2) () ())))
             (conflicts
              ((foobar.2.4
                (ball.6.9 foo.4.10 bar.7.8 tmp.11 bar.9.7 bar.5.1 bat.3.2 ball.8.3 r9 r8 rcx))
               (bat.3.2 (ball.6.9 foo.4.10 bar.7.8 tmp.11 bar.9.7 bar.5.1 foobar.2.4 ball.8.3 r9))
               (foobar.1.6 (r9 r8 rcx rdx rsi))
               (bar.0.5 (r9 r8 rcx rdx))
               (ball.8.3 (bar.7.8 tmp.11 bar.9.7 bar.5.1 bat.3.2 foobar.2.4 r9 r8))
               (bar.5.1 (bar.7.8 bat.3.2 foobar.2.4 ball.8.3))
               (tmp.11 (bat.3.2 foobar.2.4 ball.8.3))
               (bar.9.7 (foobar.2.4 bat.3.2 ball.8.3))
               (bar.7.8 (bat.3.2 foobar.2.4 ball.8.3 bar.5.1))
               (foo.4.10 (bat.3.2 foobar.2.4))
               (ball.6.9 (bat.3.2 foobar.2.4))
               (rsi (foobar.1.6))
               (rdx (bar.0.5 foobar.1.6))
               (rcx (foobar.2.4 bar.0.5 foobar.1.6))
               (r8 (ball.8.3 foobar.2.4 bar.0.5 foobar.1.6))
               (r9 (bat.3.2 ball.8.3 foobar.2.4 bar.0.5 foobar.1.6)))))
            (begin
              (set! foobar.1.6 rdi)
              (set! bar.0.5 rsi)
              (set! foobar.2.4 rdx)
              (set! ball.8.3 rcx)
              (set! bat.3.2 r8)
              (set! bar.5.1 r9)
              (if (begin
                    (set! bar.7.8 -669410514)
                    (< bat.3.2 bat.3.2))
                  (begin
                    (set! tmp.11 bar.5.1)
                    (set! tmp.11 (+ tmp.11 ball.8.3))
                    (set! bar.9.7 tmp.11))
                  (set! bar.9.7 foobar.2.4))
              (set! foo.4.10 ball.8.3)
              (set! ball.6.9 1)
              (if (<= foobar.2.4 1)
                  (halt 9223372036854775807)
                  (halt bat.3.2))))
    (begin
      (set! r9 9223372036854775807)
      (set! r8 -1891086346)
      (set! rcx -1371550930)
      (set! rdx 0)
      (set! rsi 9223372036854775807)
      (set! rdi 0)
      (jump L.proc.0.1 rbp rdi rsi rdx rcx r8 r9))))
(check-by-interp
 '(module ((locals (bar.0.27)) (undead-out (() ())) (conflicts ((bar.0.27 ()))))
          (define L.x.0.1
            ((locals (ball.2.1 bat.7.7 ball.4.3 bar.0.2 ball.4.8 foobar.3.5 ball.5.4 ball.9.6 tmp.28))
             (undead-out ((rsi rdx rcx r8 r9 fv0)
                          (rdx rcx r8 r9 fv0 ball.9.6)
                          (rcx r8 r9 fv0 ball.9.6 foobar.3.5)
                          (r8 r9 fv0 ball.9.6 foobar.3.5 ball.5.4)
                          (r9 fv0 ball.9.6 foobar.3.5 ball.4.3 ball.5.4)
                          (fv0 ball.9.6 foobar.3.5 bar.0.2 ball.4.3 ball.5.4)
                          (ball.9.6 foobar.3.5 bar.0.2 ball.4.3 ball.5.4)
                          ((((ball.9.6 tmp.28 foobar.3.5 bar.0.2 ball.4.3 ball.5.4)
                             (foobar.3.5 bar.0.2 ball.4.3 ball.5.4))
                            (foobar.3.5 bar.0.2 ball.4.3 ball.5.4)
                            (foobar.3.5 bar.0.2 ball.4.3 ball.5.4))
                           ((ball.5.4) () (() ()))
                           ())))
             (conflicts
              ((tmp.28 (ball.5.4 ball.4.3 bar.0.2 foobar.3.5 ball.9.6))
               (ball.9.6 (ball.2.1 bar.0.2 ball.4.3 ball.5.4 foobar.3.5 fv0 r9 r8 rcx rdx tmp.28))
               (ball.5.4 (ball.2.1 bar.0.2 ball.4.3 foobar.3.5 ball.9.6 fv0 r9 r8 tmp.28))
               (foobar.3.5 (ball.2.1 bar.0.2 ball.4.3 ball.5.4 ball.9.6 fv0 r9 r8 rcx tmp.28))
               (ball.4.8 ())
               (bar.0.2 (ball.2.1 ball.5.4 ball.4.3 foobar.3.5 ball.9.6 fv0 tmp.28))
               (ball.4.3 (ball.2.1 bar.0.2 ball.5.4 foobar.3.5 ball.9.6 fv0 r9 tmp.28))
               (bat.7.7 (fv0 r9 r8 rcx rdx rsi))
               (ball.2.1 (ball.5.4 ball.4.3 bar.0.2 foobar.3.5 ball.9.6))
               (rsi (bat.7.7))
               (rdx (ball.9.6 bat.7.7))
               (rcx (foobar.3.5 ball.9.6 bat.7.7))
               (r8 (ball.5.4 foobar.3.5 ball.9.6 bat.7.7))
               (r9 (ball.4.3 ball.5.4 foobar.3.5 ball.9.6 bat.7.7))
               (fv0 (bar.0.2 ball.4.3 ball.5.4 foobar.3.5 ball.9.6 bat.7.7)))))
            (begin
              (set! bat.7.7 rdi)
              (set! ball.9.6 rsi)
              (set! foobar.3.5 rdx)
              (set! ball.5.4 rcx)
              (set! ball.4.3 r8)
              (set! bar.0.2 r9)
              (set! ball.2.1 fv0)
              (if (not (if (begin
                             (set! tmp.28 388494724)
                             (>= tmp.28 ball.9.6))
                           (> ball.5.4 -9223372036854775808)
                           (< foobar.3.5 ball.5.4)))
                  (if (<= ball.4.3 bar.0.2)
                      (halt 0)
                      (begin
                        (set! ball.4.8 ball.5.4)
                        (halt 1887946265)))
                  (halt foobar.3.5))))
    (define L.tmp.1.2
      ((locals (ball.2.9 ball.9.13
                         bat.7.14
                         bar.0.10
                         ball.5.12
                         foobar.3.15
                         ball.9.16
                         bat.7.17
                         tmp.29
                         foo.6.11
                         tmp.30))
       (undead-out ((rsi rdx rcx r8 r9) (rdx rcx r8 r9)
                                        (rcx r8 r9 ball.5.12)
                                        (r8 r9 ball.5.12 foo.6.11)
                                        (r9 bar.0.10 ball.5.12 foo.6.11)
                                        (bar.0.10 ball.5.12 foo.6.11)
                                        ((bar.0.10 ball.5.12 foo.6.11)
                                         ((tmp.30) (tmp.30) (tmp.29) ())
                                         (((ball.5.12 bar.0.10) ()) ((ball.9.16) ()) (() ())))))
       (conflicts ((tmp.30 ()) (foo.6.11 (ball.2.9 bar.0.10 ball.5.12 r9 r8))
                               (tmp.29 ())
                               (bat.7.17 ())
                               (ball.9.16 ())
                               (foobar.3.15 (bar.0.10 ball.5.12))
                               (ball.5.12 (ball.2.9 bar.0.10 foo.6.11 r9 r8 rcx foobar.3.15))
                               (bar.0.10 (ball.2.9 foo.6.11 ball.5.12 r9 foobar.3.15))
                               (bat.7.14 (r9 r8 rcx rdx rsi))
                               (ball.9.13 (r9 r8 rcx rdx))
                               (ball.2.9 (foo.6.11 ball.5.12 bar.0.10))
                               (rsi (bat.7.14))
                               (rdx (ball.9.13 bat.7.14))
                               (rcx (ball.5.12 ball.9.13 bat.7.14))
                               (r8 (foo.6.11 ball.5.12 ball.9.13 bat.7.14))
                               (r9 (bar.0.10 foo.6.11 ball.5.12 ball.9.13 bat.7.14)))))
      (begin
        (set! bat.7.14 rdi)
        (set! ball.9.13 rsi)
        (set! ball.5.12 rdx)
        (set! foo.6.11 rcx)
        (set! bar.0.10 r8)
        (set! ball.2.9 r9)
        (if (true)
            (begin
              (set! tmp.30 foo.6.11)
              (set! tmp.30 (* tmp.30 9223372036854775807))
              (set! tmp.29 tmp.30)
              (halt tmp.29))
            (if (begin
                  (set! foobar.3.15 1)
                  (<= bar.0.10 ball.5.12))
                (begin
                  (set! ball.9.16 -9223372036854775808)
                  (halt ball.9.16))
                (begin
                  (set! bat.7.17 1)
                  (halt 1))))))
    (define L.tmp.2.3
      ((locals (ball.2.25 foo.6.26
                          bar.0.18
                          foobar.3.20
                          bat.7.23
                          tmp.32
                          bar.8.19
                          ball.2.22
                          foo.6.21
                          foobar.3.24
                          tmp.31))
       (undead-out
        ((rsi rdx rcx r8 r9 rbp)
         (rdx rcx r8 r9 ball.2.22 rbp)
         (rcx r8 r9 ball.2.22 foo.6.21 rbp)
         (r8 r9 ball.2.22 foo.6.21 rbp)
         (r9 bar.8.19 ball.2.22 foo.6.21 rbp)
         (bar.8.19 ball.2.22 foo.6.21 rbp)
         (((bar.8.19 ball.2.22 foo.6.21 rbp) (bar.8.19 ball.2.22 foo.6.21 rbp))
          (bar.8.19 ball.2.22 foo.6.21 foobar.3.24 rbp)
          ((bar.8.19 ball.2.22 foo.6.21 rbp) (bar.8.19 ball.2.22 foo.6.21 foobar.3.24 rbp)))
         (((tmp.31 bar.8.19 ball.2.22 foo.6.21 foobar.3.24 rbp)
           (bar.8.19 ball.2.22 foo.6.21 foobar.3.24 rbp))
          ((foo.6.21 foobar.3.24 r9 rbp) (foo.6.21 foobar.3.24 r9 r8 rbp)
                                         (foobar.3.24 r9 r8 rcx rbp)
                                         (foobar.3.24 r9 r8 rcx rdx rbp)
                                         (foobar.3.24 r9 r8 rcx rdx rsi rbp)
                                         (r9 r8 rcx rdx rsi rdi rbp)
                                         (r9 r8 rcx rdx rsi rdi rbp))
          (((tmp.32 ball.2.22 bar.8.19) (ball.2.22 bar.8.19)) () ()))))
       (conflicts
        ((tmp.31 (rbp foobar.3.24 foo.6.21 ball.2.22 bar.8.19))
         (foobar.3.24 (rbp foo.6.21 ball.2.22 bar.8.19 tmp.31 rsi rdx rcx r8 r9))
         (foo.6.21 (ball.2.25 foo.6.26
                              foobar.3.24
                              bar.0.18
                              bar.8.19
                              foobar.3.20
                              rbp
                              ball.2.22
                              rcx
                              tmp.31
                              r8
                              r9))
         (ball.2.22 (ball.2.25 foo.6.26
                               foobar.3.24
                               bar.0.18
                               bar.8.19
                               foobar.3.20
                               foo.6.21
                               rbp
                               r9
                               r8
                               rcx
                               rdx
                               tmp.31
                               tmp.32))
         (bar.8.19 (ball.2.25 foo.6.26 foobar.3.24 bar.0.18 rbp foo.6.21 ball.2.22 r9 tmp.31 tmp.32))
         (tmp.32 (bar.8.19 ball.2.22))
         (bat.7.23 (rbp r9 r8 rcx rdx rsi))
         (foobar.3.20 (rbp foo.6.21 ball.2.22 r9 r8))
         (bar.0.18 (rbp foo.6.21 ball.2.22 bar.8.19))
         (foo.6.26 (rbp foo.6.21 ball.2.22 bar.8.19))
         (ball.2.25 (rbp foo.6.21 ball.2.22 bar.8.19))
         (r9 (bar.8.19 foobar.3.20 ball.2.22 bat.7.23 rdi rsi rdx rcx r8 rbp foobar.3.24 foo.6.21))
         (rbp (ball.2.25 foo.6.26
                         foobar.3.24
                         bar.0.18
                         bar.8.19
                         foobar.3.20
                         foo.6.21
                         ball.2.22
                         bat.7.23
                         tmp.31
                         rdi
                         rsi
                         rdx
                         rcx
                         r8
                         r9))
         (r8 (foobar.3.20 ball.2.22 bat.7.23 rdi rsi rdx rcx rbp r9 foobar.3.24 foo.6.21))
         (rcx (foo.6.21 ball.2.22 bat.7.23 rdi rsi rdx rbp r8 r9 foobar.3.24))
         (rdx (ball.2.22 bat.7.23 rdi rsi rbp rcx r8 r9 foobar.3.24))
         (rsi (bat.7.23 rdi rbp rdx rcx r8 r9 foobar.3.24))
         (rdi (rbp rsi rdx rcx r8 r9)))))
      (begin
        (set! bat.7.23 rdi)
        (set! ball.2.22 rsi)
        (set! foo.6.21 rdx)
        (set! foobar.3.20 rcx)
        (set! bar.8.19 r8)
        (set! bar.0.18 r9)
        (if (begin
              (set! ball.2.25 258314756)
              (!= bar.8.19 0))
            (set! foobar.3.24 bar.8.19)
            (begin
              (set! foo.6.26 -1809848824)
              (set! foobar.3.24 9223372036854775807)))
        (if (begin
              (set! tmp.31 1525021420)
              (< tmp.31 1))
            (begin
              (set! r9 1067478227)
              (set! r8 -768559462)
              (set! rcx foo.6.21)
              (set! rdx -1256996529)
              (set! rsi 1)
              (set! rdi foobar.3.24)
              (jump L.tmp.1.2 rbp rdi rsi rdx rcx r8 r9))
            (if (begin
                  (set! tmp.32 389818959)
                  (> tmp.32 882297114))
                (halt bar.8.19)
                (halt ball.2.22)))))
    (begin
      (set! bar.0.27 1)
      (halt 1))))
(check-by-interp
 '(module ((locals ()) (undead-out ((fv0 rbp) (fv0 r9 rbp)
                                              (fv0 r9 r8 rbp)
                                              (fv0 r9 r8 rcx rbp)
                                              (fv0 r9 r8 rcx rdx rbp)
                                              (fv0 r9 r8 rcx rdx rsi rbp)
                                              (fv0 r9 r8 rcx rdx rsi rdi rbp)
                                              (fv0 r9 r8 rcx rdx rsi rdi rbp)))
                       (conflicts ((fv0 (rdi rsi rdx rcx r8 r9 rbp))
                                   (rbp (rdi rsi rdx rcx r8 r9 fv0))
                                   (r9 (rdi rsi rdx rcx r8 rbp fv0))
                                   (r8 (rdi rsi rdx rcx rbp r9 fv0))
                                   (rcx (rdi rsi rdx rbp r8 r9 fv0))
                                   (rdx (rdi rsi rbp rcx r8 r9 fv0))
                                   (rsi (rdi rbp rdx rcx r8 r9 fv0))
                                   (rdi (rbp rsi rdx rcx r8 r9 fv0)))))
          (define L.tmp.0.1
            ((locals (tmp.18 ball.7.1 bat.0.2 ball.8.3 bat.3.4 bar.9.5 ball.6.6 foo.1.7 tmp.17))
             (undead-out ((rsi rdx rcx r8 r9 fv0) (rdx rcx r8 r9 fv0)
                                                  (rcx r8 r9 fv0)
                                                  (r8 r9 fv0 bat.3.4)
                                                  (r9 fv0 bat.3.4)
                                                  (fv0 bat.3.4 bat.0.2)
                                                  (bat.3.4 bat.0.2)
                                                  (bat.0.2 tmp.18)
                                                  (tmp.18)
                                                  (tmp.17)
                                                  ()))
             (conflicts ((tmp.17 ()) (foo.1.7 (fv0 r9 r8 rcx rdx rsi))
                                     (ball.6.6 (fv0 r9 r8 rcx rdx))
                                     (bar.9.5 (fv0 r9 r8 rcx))
                                     (bat.3.4 (ball.7.1 bat.0.2 ball.8.3 fv0 r9 r8))
                                     (ball.8.3 (bat.3.4 fv0 r9))
                                     (bat.0.2 (tmp.18 ball.7.1 bat.3.4 fv0))
                                     (ball.7.1 (bat.0.2 bat.3.4))
                                     (tmp.18 (bat.0.2))
                                     (rsi (foo.1.7))
                                     (rdx (ball.6.6 foo.1.7))
                                     (rcx (bar.9.5 ball.6.6 foo.1.7))
                                     (r8 (bat.3.4 bar.9.5 ball.6.6 foo.1.7))
                                     (r9 (ball.8.3 bat.3.4 bar.9.5 ball.6.6 foo.1.7))
                                     (fv0 (bat.0.2 ball.8.3 bat.3.4 bar.9.5 ball.6.6 foo.1.7)))))
            (begin
              (set! foo.1.7 rdi)
              (set! ball.6.6 rsi)
              (set! bar.9.5 rdx)
              (set! bat.3.4 rcx)
              (set! ball.8.3 r8)
              (set! bat.0.2 r9)
              (set! ball.7.1 fv0)
              (set! tmp.18 bat.3.4)
              (set! tmp.18 (* tmp.18 bat.0.2))
              (set! tmp.17 tmp.18)
              (halt tmp.17)))
    (define L.func.1.2
      ((locals (bat.3.13 bar.9.8 bat.3.9 foo.5.10 bar.2.11 foo.1.12))
       (undead-out ((rsi rdx rcx r8) (rdx rcx r8) (rcx r8) (r8) () () ()))
       (conflicts ((foo.1.12 (r8 rcx rdx rsi)) (bar.2.11 (r8 rcx rdx))
                                               (foo.5.10 (r8 rcx))
                                               (bat.3.9 (r8))
                                               (bar.9.8 ())
                                               (bat.3.13 ())
                                               (rsi (foo.1.12))
                                               (rdx (bar.2.11 foo.1.12))
                                               (rcx (foo.5.10 bar.2.11 foo.1.12))
                                               (r8 (bat.3.9 foo.5.10 bar.2.11 foo.1.12)))))
      (begin
        (set! foo.1.12 rdi)
        (set! bar.2.11 rsi)
        (set! foo.5.10 rdx)
        (set! bat.3.9 rcx)
        (set! bar.9.8 r8)
        (set! bat.3.13 1)
        (halt 9223372036854775807)))
    (define L.fn.2.3
      ((locals (bat.3.16 tmp.19 ball.8.14 ball.7.15))
       (undead-out ((rsi ball.7.15 rbp)
                    (ball.7.15 ball.8.14 rbp)
                    ((ball.7.15 ball.8.14 rbp)
                     ((ball.7.15 ball.8.14 rbp) (ball.7.15 ball.8.14 bat.3.16 rbp)
                                                (ball.7.15 ball.8.14 bat.3.16 rbp))
                     ((tmp.19 ball.7.15 ball.8.14 rbp) (tmp.19 ball.7.15 ball.8.14 rbp)
                                                       (ball.7.15 ball.8.14 bat.3.16 rbp)))
                    (ball.7.15 ball.8.14 bat.3.16 fv0 rbp)
                    (ball.7.15 ball.8.14 bat.3.16 fv0 r9 rbp)
                    (ball.7.15 ball.8.14 bat.3.16 fv0 r9 r8 rbp)
                    (ball.8.14 bat.3.16 fv0 r9 r8 rcx rbp)
                    (ball.8.14 bat.3.16 fv0 r9 r8 rcx rdx rbp)
                    (bat.3.16 fv0 r9 r8 rcx rdx rsi rbp)
                    (fv0 r9 r8 rcx rdx rsi rdi rbp)
                    (fv0 r9 r8 rcx rdx rsi rdi rbp)))
       (conflicts ((ball.7.15 (r8 fv0 tmp.19 bat.3.16 ball.8.14 rbp rsi))
                   (ball.8.14 (rdx rcx r8 r9 fv0 tmp.19 bat.3.16 rbp ball.7.15))
                   (tmp.19 (rbp ball.8.14 ball.7.15))
                   (bat.3.16 (rsi rdx rcx r8 r9 fv0 rbp ball.8.14 ball.7.15))
                   (rsi (rdi rbp rdx rcx r8 r9 fv0 bat.3.16 ball.7.15))
                   (rbp (rdi rsi rdx rcx r8 r9 fv0 tmp.19 bat.3.16 ball.8.14 ball.7.15))
                   (fv0 (rdi rsi rdx rcx r8 r9 rbp bat.3.16 ball.8.14 ball.7.15))
                   (r9 (rdi rsi rdx rcx r8 rbp fv0 bat.3.16 ball.8.14))
                   (r8 (rdi rsi rdx rcx rbp r9 fv0 bat.3.16 ball.8.14 ball.7.15))
                   (rcx (rdi rsi rdx rbp r8 r9 fv0 bat.3.16 ball.8.14))
                   (rdx (rdi rsi rbp rcx r8 r9 fv0 bat.3.16 ball.8.14))
                   (rdi (rbp rsi rdx rcx r8 r9 fv0)))))
      (begin
        (set! ball.7.15 rdi)
        (set! ball.8.14 rsi)
        (if (>= ball.7.15 1)
            (if (= ball.7.15 ball.7.15)
                (set! bat.3.16 ball.8.14)
                (set! bat.3.16 214741259))
            (begin
              (set! tmp.19 1683358713)
              (set! tmp.19 (+ tmp.19 ball.8.14))
              (set! bat.3.16 tmp.19)))
        (set! fv0 -2043460455)
        (set! r9 ball.7.15)
        (set! r8 9223372036854775807)
        (set! rcx ball.7.15)
        (set! rdx 0)
        (set! rsi ball.8.14)
        (set! rdi bat.3.16)
        (jump L.tmp.0.1 rbp rdi rsi rdx rcx r8 r9 fv0)))
    (begin
      (set! fv0 -9223372036854775808)
      (set! r9 1)
      (set! r8 -9223372036854775808)
      (set! rcx 9223372036854775807)
      (set! rdx -9223372036854775808)
      (set! rsi -9223372036854775808)
      (set! rdi -9223372036854775808)
      (jump L.tmp.0.1 rbp rdi rsi rdx rcx r8 r9 fv0))))
(check-by-interp '(module ((locals (tmp.3 tmp.1 tmp.2))
                           (undead-out (() ((tmp.2) (tmp.2) (tmp.1) ()) (((tmp.3) ()) () ())))
                           (conflicts ((tmp.2 ()) (tmp.1 ()) (tmp.3 ()))))
                          (if (true)
                              (begin
                                (set! tmp.2 1)
                                (set! tmp.2 (+ tmp.2 -9223372036854775808))
                                (set! tmp.1 tmp.2)
                                (halt tmp.1))
                              (if (begin
                                    (set! tmp.3 1383245321)
                                    (> tmp.3 0))
                                  (halt 0)
                                  (halt 1)))
                    ))
(check-by-interp
 '(module ((locals
            (tmp.59 foobar.2.41 foobar.2.42 tmp.56 tmp.57 foobar.5.43 tmp.58 foo.6.40 bar.9.44))
           (undead-out (((((rbp) (rbp))
                          ((((tmp.56 rbp) (rbp)) (foobar.2.42 rbp) (foobar.2.42 rbp)) (foo.6.40 rbp))
                          ((rbp) ((foobar.5.43 rbp) (foo.6.40 rbp))
                                 (((tmp.57 rbp) (rbp)) (foo.6.40 rbp) (foo.6.40 rbp))))
                         ((foo.6.40 rbp) ((rbp) (rbp)) ((foo.6.40 tmp.58 rbp) (rbp))))
                        ()
                        (((tmp.59 rbp) (rbp)) (rbp) (rbp))))
           (conflicts
            ((bar.9.44 (rbp))
             (foo.6.40 (rbp tmp.58))
             (tmp.58 (rbp foo.6.40))
             (foobar.5.43 (rbp))
             (tmp.57 (rbp))
             (tmp.56 (rbp))
             (foobar.2.42 (rbp))
             (foobar.2.41 (rbp))
             (tmp.59 (rbp))
             (rbp
              (foobar.2.41 tmp.56 foobar.2.42 foobar.5.43 tmp.57 foo.6.40 bar.9.44 tmp.58 tmp.59)))))
          (define L.x.0.1
            ((locals (ball.8.1 foobar.5.2 foo.6.3 foobar.2.4 foo.3.5 foobar.1.6 ball.0.7))
             (undead-out ((rsi rdx rcx r8 r9 fv0 rbp) (rdx rcx r8 r9 fv0 rbp)
                                                      (rcx r8 r9 fv0 rbp)
                                                      (r8 r9 fv0 rbp)
                                                      (r9 fv0 rbp)
                                                      (fv0 rbp)
                                                      (rbp)
                                                      (rdi rbp)
                                                      (rdi rbp)))
             (conflicts
              ((ball.0.7 (rbp fv0 r9 r8 rcx rdx rsi))
               (foobar.1.6 (rbp fv0 r9 r8 rcx rdx))
               (foo.3.5 (rbp fv0 r9 r8 rcx))
               (foobar.2.4 (rbp fv0 r9 r8))
               (foo.6.3 (rbp fv0 r9))
               (foobar.5.2 (rbp fv0))
               (ball.8.1 (rbp))
               (rsi (ball.0.7))
               (rdx (foobar.1.6 ball.0.7))
               (rcx (foo.3.5 foobar.1.6 ball.0.7))
               (r8 (foobar.2.4 foo.3.5 foobar.1.6 ball.0.7))
               (r9 (foo.6.3 foobar.2.4 foo.3.5 foobar.1.6 ball.0.7))
               (fv0 (foobar.5.2 foo.6.3 foobar.2.4 foo.3.5 foobar.1.6 ball.0.7))
               (rbp (rdi ball.8.1 foobar.5.2 foo.6.3 foobar.2.4 foo.3.5 foobar.1.6 ball.0.7))
               (rdi (rbp)))))
            (begin
              (set! ball.0.7 rdi)
              (set! foobar.1.6 rsi)
              (set! foo.3.5 rdx)
              (set! foobar.2.4 rcx)
              (set! foo.6.3 r8)
              (set! foobar.5.2 r9)
              (set! ball.8.1 fv0)
              (set! rdi 1)
              (jump L.x.4.5 rbp rdi)))
    (define L.func.1.2
      ((locals (bar.9.8 foobar.1.9 tmp.45))
       (undead-out ((bar.9.8) (foobar.1.9 bar.9.8) (((foobar.1.9 tmp.45 bar.9.8) (bar.9.8)) () ())))
       (conflicts ((tmp.45 (bar.9.8 foobar.1.9)) (foobar.1.9 (tmp.45)) (bar.9.8 (tmp.45)))))
      (begin
        (set! bar.9.8 9223372036854775807)
        (set! foobar.1.9 bar.9.8)
        (if (begin
              (set! tmp.45 -577997854)
              (>= tmp.45 foobar.1.9))
            (halt -9223372036854775808)
            (halt bar.9.8))))
    (define L.fn.2.3
      ((locals (tmp.46 foobar.1.11 ball.7.10))
       (undead-out ((tmp.46) (tmp.46) (ball.7.10) ((ball.7.10) () (() ()))))
       (conflicts ((ball.7.10 ()) (foobar.1.11 ()) (tmp.46 ()))))
      (begin
        (set! tmp.46 1)
        (set! tmp.46 (+ tmp.46 1))
        (set! ball.7.10 tmp.46)
        (if (false)
            (halt ball.7.10)
            (begin
              (set! foobar.1.11 ball.7.10)
              (halt 1969054361)))))
    (define L.x.3.4
      ((locals (ball.7.12 foo.3.13 ball.8.14 foobar.2.15 bar.9.16 foobar.5.17 foobar.4.18))
       (undead-out ((rsi rdx rcx r8 r9 fv0 foobar.4.18 rbp) (rdx rcx r8 r9 fv0 foobar.4.18 rbp)
                                                            (rcx r8 r9 fv0 foobar.4.18 rbp)
                                                            (r8 r9 fv0 foobar.4.18 rbp)
                                                            (r9 fv0 foobar.4.18 rbp)
                                                            (fv0 foobar.4.18 rbp)
                                                            (foobar.4.18 rbp)
                                                            (foobar.4.18 fv0 rbp)
                                                            (fv0 r9 rbp)
                                                            (fv0 r9 r8 rbp)
                                                            (fv0 r9 r8 rcx rbp)
                                                            (fv0 r9 r8 rcx rdx rbp)
                                                            (fv0 r9 r8 rcx rdx rsi rbp)
                                                            (fv0 r9 r8 rcx rdx rsi rdi rbp)
                                                            (fv0 r9 r8 rcx rdx rsi rdi rbp)))
       (conflicts
        ((foobar.4.18
          (ball.7.12 foo.3.13 ball.8.14 foobar.2.15 bar.9.16 foobar.5.17 rbp fv0 r9 r8 rcx rdx rsi))
         (foobar.5.17 (rbp foobar.4.18 fv0 r9 r8 rcx rdx))
         (bar.9.16 (rbp foobar.4.18 fv0 r9 r8 rcx))
         (foobar.2.15 (rbp foobar.4.18 fv0 r9 r8))
         (ball.8.14 (rbp foobar.4.18 fv0 r9))
         (foo.3.13 (rbp foobar.4.18 fv0))
         (ball.7.12 (rbp foobar.4.18))
         (rsi (rdi rbp rdx rcx r8 r9 fv0 foobar.4.18))
         (rdx (rdi rsi rbp rcx r8 r9 fv0 foobar.5.17 foobar.4.18))
         (rcx (rdi rsi rdx rbp r8 r9 fv0 bar.9.16 foobar.5.17 foobar.4.18))
         (r8 (rdi rsi rdx rcx rbp r9 fv0 foobar.2.15 bar.9.16 foobar.5.17 foobar.4.18))
         (r9 (rdi rsi rdx rcx r8 rbp fv0 ball.8.14 foobar.2.15 bar.9.16 foobar.5.17 foobar.4.18))
         (fv0
          (rdi rsi rdx rcx r8 r9 rbp foo.3.13 ball.8.14 foobar.2.15 bar.9.16 foobar.5.17 foobar.4.18))
         (rbp (rdi rsi
                   rdx
                   rcx
                   r8
                   r9
                   fv0
                   ball.7.12
                   foo.3.13
                   ball.8.14
                   foobar.2.15
                   bar.9.16
                   foobar.5.17
                   foobar.4.18))
         (rdi (rbp rsi rdx rcx r8 r9 fv0)))))
      (begin
        (set! foobar.4.18 rdi)
        (set! foobar.5.17 rsi)
        (set! bar.9.16 rdx)
        (set! foobar.2.15 rcx)
        (set! ball.8.14 r8)
        (set! foo.3.13 r9)
        (set! ball.7.12 fv0)
        (set! fv0 -9223372036854775808)
        (set! r9 foobar.4.18)
        (set! r8 9223372036854775807)
        (set! rcx 25911444)
        (set! rdx 9223372036854775807)
        (set! rsi -9223372036854775808)
        (set! rdi 0)
        (jump L.func.6.7 rbp rdi rsi rdx rcx r8 r9 fv0)))
    (define L.x.4.5
      ((locals (foobar.4.19)) (undead-out ((foobar.4.19 rbp) (foobar.4.19 fv0 rbp)
                                                             (foobar.4.19 fv0 r9 rbp)
                                                             (foobar.4.19 fv0 r9 r8 rbp)
                                                             (foobar.4.19 fv0 r9 r8 rcx rbp)
                                                             (foobar.4.19 fv0 r9 r8 rcx rdx rbp)
                                                             (fv0 r9 r8 rcx rdx rsi rbp)
                                                             (fv0 r9 r8 rcx rdx rsi rdi rbp)
                                                             (fv0 r9 r8 rcx rdx rsi rdi rbp)))
                              (conflicts ((foobar.4.19 (rcx rbp))
                                          (rbp (rdi rsi rdx rcx r8 r9 fv0 foobar.4.19))
                                          (fv0 (rdi rsi rdx rcx r8 r9 rbp))
                                          (r9 (rdi rsi rdx rcx r8 rbp fv0))
                                          (r8 (rdi rsi rdx rcx rbp r9 fv0))
                                          (rcx (rdi rsi rdx rbp r8 r9 fv0 foobar.4.19))
                                          (rdx (rdi rsi rbp rcx r8 r9 fv0))
                                          (rsi (rdi rbp rdx rcx r8 r9 fv0))
                                          (rdi (rbp rsi rdx rcx r8 r9 fv0)))))
      (begin
        (set! foobar.4.19 rdi)
        (set! fv0 foobar.4.19)
        (set! r9 foobar.4.19)
        (set! r8 foobar.4.19)
        (set! rcx 1)
        (set! rdx foobar.4.19)
        (set! rsi foobar.4.19)
        (set! rdi 0)
        (jump L.x.3.4 rbp rdi rsi rdx rcx r8 r9 fv0)))
    (define L.x.5.6
      ((locals (foo.6.28 foobar.1.27
                         foobar.5.20
                         foobar.1.21
                         foobar.5.26
                         foobar.4.23
                         ball.8.29
                         bar.9.22
                         foo.6.25
                         foo.3.24))
       (undead-out
        ((rsi rdx rcx r8 r9 foo.6.25 rbp)
         (rdx rcx r8 r9 foo.6.25 foo.3.24 rbp)
         (rcx r8 r9 foo.6.25 foo.3.24 foobar.4.23 rbp)
         (r8 r9 bar.9.22 foo.6.25 foo.3.24 foobar.4.23 rbp)
         (r9 bar.9.22 foo.6.25 foo.3.24 foobar.4.23 rbp)
         (bar.9.22 foo.6.25 foo.3.24 foobar.4.23 rbp)
         (foobar.1.27 bar.9.22 foo.6.25 foo.3.24 foobar.4.23 rbp)
         (foobar.1.27 bar.9.22 foo.6.25 foo.3.24 foobar.4.23 rbp)
         (bar.9.22 foo.6.25 foo.3.24 foobar.5.26 foobar.4.23 rbp)
         (((foo.6.25 foo.3.24 foobar.5.26 foobar.4.23 rbp) (foo.3.24 foobar.5.26 foobar.4.23 rbp))
          ((foo.3.24 foobar.5.26 foobar.4.23 fv0 rbp) (foo.3.24 foobar.5.26 foobar.4.23 fv0 r9 rbp)
                                                      (foobar.5.26 foobar.4.23 fv0 r9 r8 rbp)
                                                      (foobar.4.23 fv0 r9 r8 rcx rbp)
                                                      (fv0 r9 r8 rcx rdx rbp)
                                                      (fv0 r9 r8 rcx rdx rsi rbp)
                                                      (fv0 r9 r8 rcx rdx rsi rdi rbp)
                                                      (fv0 r9 r8 rcx rdx rsi rdi rbp))
          ())))
       (conflicts
        ((foo.3.24 (foobar.5.26 foobar.1.27
                                foobar.5.20
                                foobar.1.21
                                bar.9.22
                                foobar.4.23
                                rbp
                                foo.6.25
                                r8
                                rcx
                                rdx
                                ball.8.29
                                r9
                                fv0))
         (foo.6.25 (foobar.5.26 foo.6.28
                                foobar.1.27
                                foobar.5.20
                                foobar.1.21
                                bar.9.22
                                foobar.4.23
                                foo.3.24
                                rbp
                                r9
                                r8
                                rcx
                                rdx
                                rsi
                                ball.8.29))
         (bar.9.22
          (foobar.5.26 foo.6.28 foobar.5.20 foobar.1.21 rbp foobar.4.23 foo.3.24 foo.6.25 r9 r8))
         (ball.8.29 (rbp foobar.4.23 foobar.5.26 foo.3.24 foo.6.25))
         (foobar.4.23 (foobar.5.26 foo.6.28
                                   foobar.1.27
                                   foobar.5.20
                                   foobar.1.21
                                   bar.9.22
                                   rbp
                                   foo.3.24
                                   foo.6.25
                                   ball.8.29
                                   rcx
                                   r8
                                   r9
                                   fv0))
         (foobar.5.26 (rbp foobar.4.23 foo.3.24 foo.6.25 bar.9.22 ball.8.29 r8 fv0))
         (foobar.1.21 (rbp foobar.4.23 foo.3.24 foo.6.25 bar.9.22 r9))
         (foobar.5.20 (rbp foobar.4.23 foo.3.24 foo.6.25 bar.9.22))
         (foobar.1.27 (foo.6.28 rbp foobar.4.23 foo.3.24 foo.6.25))
         (foo.6.28 (rbp foobar.4.23 foo.6.25 bar.9.22 foobar.1.27))
         (fv0 (rdi rsi rdx rcx r8 r9 rbp foobar.4.23 foobar.5.26 foo.3.24))
         (rbp (foobar.5.26 foo.6.28
                           foobar.1.27
                           foobar.5.20
                           foobar.1.21
                           bar.9.22
                           foobar.4.23
                           foo.3.24
                           foo.6.25
                           ball.8.29
                           rdi
                           rsi
                           rdx
                           rcx
                           r8
                           r9
                           fv0))
         (r9 (foobar.1.21 bar.9.22 foo.6.25 rdi rsi rdx rcx r8 rbp fv0 foobar.4.23 foo.3.24))
         (r8 (bar.9.22 foo.3.24 foo.6.25 rdi rsi rdx rcx rbp r9 fv0 foobar.4.23 foobar.5.26))
         (rcx (foo.3.24 foo.6.25 rdi rsi rdx rbp r8 r9 fv0 foobar.4.23))
         (rdx (foo.3.24 foo.6.25 rdi rsi rbp rcx r8 r9 fv0))
         (rsi (foo.6.25 rdi rbp rdx rcx r8 r9 fv0))
         (rdi (rbp rsi rdx rcx r8 r9 fv0)))))
      (begin
        (set! foo.6.25 rdi)
        (set! foo.3.24 rsi)
        (set! foobar.4.23 rdx)
        (set! bar.9.22 rcx)
        (set! foobar.1.21 r8)
        (set! foobar.5.20 r9)
        (set! foobar.1.27 bar.9.22)
        (set! foo.6.28 foo.3.24)
        (set! foobar.5.26 foobar.1.27)
        (if (begin
              (set! ball.8.29 bar.9.22)
              (> foo.3.24 foo.6.25))
            (begin
              (set! fv0 -1819248150)
              (set! r9 foobar.5.26)
              (set! r8 foo.3.24)
              (set! rcx foobar.5.26)
              (set! rdx foobar.4.23)
              (set! rsi 9223372036854775807)
              (set! rdi -1863740769)
              (jump L.x.0.1 rbp rdi rsi rdx rcx r8 r9 fv0))
            (halt 1))))
    (define L.func.6.7
      ((locals (foobar.5.30 foobar.1.31
                            foo.3.32
                            ball.8.33
                            ball.0.34
                            foo.6.35
                            foobar.1.39
                            tmp.49
                            ball.8.38
                            tmp.48
                            tmp.47
                            foobar.2.36
                            ball.0.37))
       (undead-out ((rsi rdx rcx r8 r9 fv0 foobar.2.36)
                    (rdx rcx r8 r9 fv0 foobar.2.36)
                    (rcx r8 r9 fv0 foobar.2.36)
                    (r8 r9 fv0 foobar.2.36)
                    (r9 fv0 foobar.2.36)
                    (fv0 foobar.2.36)
                    (foobar.2.36)
                    (((foobar.2.36) ((foobar.2.36) ((tmp.47 foobar.2.36) (foobar.2.36)))
                                    ((tmp.48 foobar.2.36) (foobar.2.36)))
                     ((foobar.2.36 tmp.49) (tmp.49) () (foobar.1.39) ())
                     ())))
       (conflicts ((ball.0.37 ())
                   (foobar.2.36 (foobar.5.30 foobar.1.31
                                             foo.3.32
                                             ball.8.33
                                             ball.0.34
                                             foo.6.35
                                             fv0
                                             r9
                                             r8
                                             rcx
                                             rdx
                                             rsi
                                             tmp.47
                                             tmp.48))
                   (tmp.47 (foobar.2.36))
                   (tmp.48 (foobar.2.36))
                   (ball.8.38 ())
                   (tmp.49 ())
                   (foobar.1.39 ())
                   (foo.6.35 (foobar.2.36 fv0 r9 r8 rcx rdx))
                   (ball.0.34 (foobar.2.36 fv0 r9 r8 rcx))
                   (ball.8.33 (foobar.2.36 fv0 r9 r8))
                   (foo.3.32 (foobar.2.36 fv0 r9))
                   (foobar.1.31 (foobar.2.36 fv0))
                   (foobar.5.30 (foobar.2.36))
                   (rsi (foobar.2.36))
                   (rdx (foo.6.35 foobar.2.36))
                   (rcx (ball.0.34 foo.6.35 foobar.2.36))
                   (r8 (ball.8.33 ball.0.34 foo.6.35 foobar.2.36))
                   (r9 (foo.3.32 ball.8.33 ball.0.34 foo.6.35 foobar.2.36))
                   (fv0 (foobar.1.31 foo.3.32 ball.8.33 ball.0.34 foo.6.35 foobar.2.36)))))
      (begin
        (set! foobar.2.36 rdi)
        (set! foo.6.35 rsi)
        (set! ball.0.34 rdx)
        (set! ball.8.33 rcx)
        (set! foo.3.32 r8)
        (set! foobar.1.31 r9)
        (set! foobar.5.30 fv0)
        (if (if (true)
                (begin
                  (set! ball.0.37 foobar.2.36)
                  (begin
                    (set! tmp.47 -1497437069)
                    (> tmp.47 -9223372036854775808)))
                (not (begin
                       (set! tmp.48 -1101838227)
                       (!= tmp.48 -1416967818))))
            (begin
              (set! tmp.49 foobar.2.36)
              (set! tmp.49 (+ tmp.49 foobar.2.36))
              (set! ball.8.38 tmp.49)
              (set! foobar.1.39 0)
              (halt foobar.1.39))
            (halt 1))))
    (define L.fn.7.8
      ((locals (tmp.52 tmp.53 tmp.54 tmp.55 tmp.50 tmp.51))
       (undead-out ((rbp) (((tmp.50 rbp) (rbp)) ((r9 rbp) (r9 r8 rbp)
                                                          (r9 r8 rcx rbp)
                                                          (r9 r8 rcx rdx rbp)
                                                          (r9 r8 rcx rdx rsi rbp)
                                                          (r9 r8 rcx rdx rsi rdi rbp)
                                                          (r9 r8 rcx rdx rsi rdi rbp))
                                                (((tmp.51) ()) () ()))
                          ((((tmp.52 rbp) (rbp)) ((tmp.53 rbp) (rbp)) ((tmp.54 rbp) (rbp)))
                           (rbp)
                           (((tmp.55) ()) () ()))))
       (conflicts ((tmp.51 ()) (tmp.50 (rbp))
                               (tmp.55 ())
                               (tmp.54 (rbp))
                               (tmp.53 (rbp))
                               (tmp.52 (rbp))
                               (rbp (tmp.50 rdi rsi rdx rcx r8 r9 tmp.52 tmp.53 tmp.54))
                               (r9 (rdi rsi rdx rcx r8 rbp))
                               (r8 (rdi rsi rdx rcx rbp r9))
                               (rcx (rdi rsi rdx rbp r8 r9))
                               (rdx (rdi rsi rbp rcx r8 r9))
                               (rsi (rdi rbp rdx rcx r8 r9))
                               (rdi (rbp rsi rdx rcx r8 r9)))))
      (if (true)
          (if (not (begin
                     (set! tmp.50 0)
                     (> tmp.50 100011461)))
              (begin
                (set! r9 -1579752260)
                (set! r8 0)
                (set! rcx -1248542300)
                (set! rdx 0)
                (set! rsi 16140507)
                (set! rdi -9223372036854775808)
                (jump L.x.5.6 rbp rdi rsi rdx rcx r8 r9))
              (if (begin
                    (set! tmp.51 -9223372036854775808)
                    (= tmp.51 471889533))
                  (halt 1)
                  (halt 0)))
          (if (if (begin
                    (set! tmp.52 1)
                    (>= tmp.52 0))
                  (begin
                    (set! tmp.53 0)
                    (>= tmp.53 -9223372036854775808))
                  (begin
                    (set! tmp.54 9223372036854775807)
                    (> tmp.54 0)))
              (jump L.fn.7.8 rbp)
              (if (begin
                    (set! tmp.55 1)
                    (> tmp.55 1))
                  (halt -444155079)
                  (halt 9223372036854775807)))))
    (if (begin
          (if (begin
                (set! foobar.2.41 -9223372036854775808)
                (true))
              (begin
                (if (begin
                      (set! tmp.56 9223372036854775807)
                      (> tmp.56 0))
                    (set! foobar.2.42 -1444900091)
                    (set! foobar.2.42 -9223372036854775808))
                (set! foo.6.40 foobar.2.42))
              (if (true)
                  (begin
                    (set! foobar.5.43 9223372036854775807)
                    (set! foo.6.40 foobar.5.43))
                  (if (begin
                        (set! tmp.57 -9223372036854775808)
                        (= tmp.57 1173781558))
                      (set! foo.6.40 0)
                      (set! foo.6.40 1))))
          (if (true)
              (begin
                (set! bar.9.44 0)
                (true))
              (begin
                (set! tmp.58 858519747)
                (< tmp.58 foo.6.40))))
        (halt 1)
        (if (begin
              (set! tmp.59 1)
              (< tmp.59 -1323259230))
            (jump L.fn.2.3 rbp)
            (jump L.fn.2.3 rbp)))))

;; !!!

(define-syntax-rule (check-minimum& lst valueof kont expected)
  (check-equal?
   (minimum& lst valueof kont)
   expected
   (format "checking minimum&: \n (check-equal? (minimum& ~a ~a ~a) ~a)" lst valueof kont expected)))

(check-minimum& '() identity identity (void))
(check-minimum& '(1) identity identity 1)
(check-minimum& '(1 2 3) - identity 3)
(check-minimum& '(1 2 3) - add1 4)
(check-minimum& '(1 2 3) sub1 identity 1)

(define-syntax-rule (check-num-values lst expected)
  (check-equal? (num-values lst)
                expected
                (format "checking num-values: \n (check-equal? (num-values ~a) ~a)" lst expected)))

(check-num-values `(x ()) 0)
(check-num-values `(x (1)) 1)
(check-num-values `(x (1 2)) 2)
(check-num-values `(x (1 2 3)) 3)
(check-num-values `(x (x y z)) 3)
(check-num-values (list ":)"
                        (list "We are no stranger to love"
                              "You know the rules and so do I"
                              "a full commitment's what I'm thinking of"
                              "You wouldn't get this from any other guy"
                              "I / Just want to tell you how I am feeling"
                              "Gotta make you understand"
                              "Never gonna give you up"
                              "Never gonna let you down"
                              "Never gonna run around and"
                              "desert you."))
                  10)

(define (check-remove-from-loy pair val expected)
  (check-equal? (remove-from-loy pair val)
                expected
                (format "checking remove-from-loy: (remove-from-loy ~a ~a) = ~a" pair val expected)))

(check-remove-from-loy '(x ()) 'x '(x ()))
(check-remove-from-loy '(x (x y)) 'x '(x (y)))
(check-remove-from-loy '(x (x x)) 'x '(x (x)))
(check-remove-from-loy '(x (x y)) 'z '(x (x y)))
