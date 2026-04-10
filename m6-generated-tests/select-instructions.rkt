#lang racket
(require rackunit
         cpsc411/langs/v6
         cpsc411/compiler-lib
         "../select-instructions.rkt")

(define (check-input p)
  (if (imp-cmf-lang-v6? p)
      p
      (error (~a (pretty-format p) "\n is not a semantically valid " "imp-cmf-lang-v6" " program"))))

(define (check-output p)
  (if (asm-pred-lang-v6? p)
      p
      (error (~a (pretty-format p) "\n is not a semantically valid " "asm-pred-lang-v6" " program"))))

(define-syntax-rule (check-by-interp p)
  (check-equal? (interp-asm-pred-lang-v6 (check-output (select-instructions p)))
                (interp-imp-cmf-lang-v6 (check-input p))))

;; M6 tests; Added by Trevor on March 6th 2026, at most one binding per let
(check-by-interp '(module ((new-frames ()))
                          (begin
                            (set! tmp-ra.4 r15)
                            (begin
                              (begin
                                (set! bat.9.2 -422317085)
                                (set! foobar.3.1 bat.9.2))
                              (begin
                                (set! ball.2.3 foobar.3.1)
                                (begin
                                  (set! rax foobar.3.1)
                                  (jump tmp-ra.4 rbp rax)))))
                    ))
(check-by-interp '(module ((new-frames ()))
                          (define L.func.0.1
                            ((new-frames ()))
                            (begin
                              (set! tmp-ra.12 r15)
                              (begin
                                (set! ball.3.5 rdi)
                                (set! ball.4.4 rsi)
                                (set! bat.0.3 rdx)
                                (set! bat.5.2 rcx)
                                (set! foobar.2.1 r8)
                                (begin
                                  (set! rax 9223372036854775807)
                                  (jump tmp-ra.12 rbp rax)))))
                    (define L.proc.1.2
                      ((new-frames (())))
                      (begin
                        (set! tmp-ra.13 r15)
                        (begin
                          (set! bat.0.7 rdi)
                          (set! bar.7.6 rsi)
                          (begin
                            (set! bar.7.8 bat.0.7)
                            (begin
                              (begin
                                (return-point L.rp.3
                                              (begin
                                                (set! rsi bar.7.8)
                                                (set! rdi bar.7.8)
                                                (set! r15 L.rp.3)
                                                (jump L.proc.1.2 rbp r15 rdi rsi)))
                                (set! ball.8.9 rax))
                              (if (= -59730991 bat.0.7)
                                  (begin
                                    (set! rax 0)
                                    (jump tmp-ra.13 rbp rax))
                                  (begin
                                    (set! rax bar.7.8)
                                    (jump tmp-ra.13 rbp rax))))))))
                    (begin
                      (set! tmp-ra.14 r15)
                      (begin
                        (if (false)
                            (set! foobar.9.10 9223372036854775807)
                            (set! foobar.9.10 (* 1 -9223372036854775808)))
                        (if (not (> foobar.9.10 foobar.9.10))
                            (begin
                              (set! ball.6.11 foobar.9.10)
                              (begin
                                (set! rax -1510146984)
                                (jump tmp-ra.14 rbp rax)))
                            (begin
                              (set! rsi foobar.9.10)
                              (set! rdi -9223372036854775808)
                              (set! r15 tmp-ra.14)
                              (jump L.proc.1.2 rbp r15 rdi rsi)))))))
(check-by-interp '(module ((new-frames ()))
                          (begin
                            (set! tmp-ra.6 r15)
                            (begin
                              (if (begin
                                    (set! bat.8.2 -1418594624)
                                    (false))
                                  (begin
                                    (if (> -1123833745 1)
                                        (set! bat.9.3 1)
                                        (set! bat.9.3 0))
                                    (begin
                                      (set! bat.9.4 767736686)
                                      (set! bat.9.1 bat.9.4)))
                                  (if (true)
                                      (begin
                                        (set! bat.3.5 1942655457)
                                        (set! bat.9.1 bat.3.5))
                                      (set! bat.9.1 (+ -9223372036854775808 1))))
                              (begin
                                (set! rax (- bat.9.1 bat.9.1))
                                (jump tmp-ra.6 rbp rax))))
                    ))
(check-by-interp '(module ((new-frames ()))
                          (define L.func.0.1
                            ((new-frames (())))
                            (begin
                              (set! tmp-ra.8 r15)
                              (begin
                                (set! foobar.8.5 rdi)
                                (set! foobar.9.4 rsi)
                                (set! bat.2.3 rdx)
                                (set! foo.7.2 rcx)
                                (set! bat.0.1 r8)
                                (begin
                                  (begin
                                    (return-point L.rp.2
                                                  (begin
                                                    (set! r8 bat.0.1)
                                                    (set! rcx foo.7.2)
                                                    (set! rdx foobar.9.4)
                                                    (set! rsi -9223372036854775808)
                                                    (set! rdi -1343541856)
                                                    (set! r15 L.rp.2)
                                                    (jump L.func.0.1 rbp r15 rdi rsi rdx rcx r8)))
                                    (set! foo.3.6 rax))
                                  (if (!= 0 9223372036854775807)
                                      (if (= 1346978436 bat.0.1)
                                          (begin
                                            (set! rax 0)
                                            (jump tmp-ra.8 rbp rax))
                                          (begin
                                            (set! rax bat.0.1)
                                            (jump tmp-ra.8 rbp rax)))
                                      (begin
                                        (set! r8 foo.7.2)
                                        (set! rcx 9223372036854775807)
                                        (set! rdx 1)
                                        (set! rsi bat.0.1)
                                        (set! rdi -1402588641)
                                        (set! r15 tmp-ra.8)
                                        (jump L.func.0.1 rbp r15 rdi rsi rdx rcx r8)))))))
                    (begin
                      (set! tmp-ra.9 r15)
                      (begin
                        (if (< 824269768 9223372036854775807)
                            (set! foobar.5.7 -9223372036854775808)
                            (set! foobar.5.7 709343632))
                        (begin
                          (set! rax foobar.5.7)
                          (jump tmp-ra.9 rbp rax))))))
(check-by-interp '(module ((new-frames ()))
                          (begin
                            (set! tmp-ra.2 r15)
                            (begin
                              (set! foo.6.1 -356902212)
                              (begin
                                (set! rax (+ -979281755 9223372036854775807))
                                (jump tmp-ra.2 rbp rax))))
                    ))
(check-by-interp '(module ((new-frames ()))
                          (define L.tmp.0.1
                            ((new-frames ()))
                            (begin
                              (set! tmp-ra.4 r15)
                              (begin
                                (set! ball.6.3 rdi)
                                (set! foobar.9.2 rsi)
                                (set! foo.5.1 rdx)
                                (begin
                                  (set! rdx foo.5.1)
                                  (set! rsi 182548382)
                                  (set! rdi 0)
                                  (set! r15 tmp-ra.4)
                                  (jump L.tmp.0.1 rbp r15 rdi rsi rdx)))))
                    (begin
                      (set! tmp-ra.5 r15)
                      (if (= 1 -444572554)
                          (begin
                            (set! rax -9223372036854775808)
                            (jump tmp-ra.5 rbp rax))
                          (begin
                            (set! rax 0)
                            (jump tmp-ra.5 rbp rax))))))
(check-by-interp '(module ((new-frames ()))
                          (define L.x.0.1
                            ((new-frames (())))
                            (begin
                              (set! tmp-ra.14 r15)
                              (begin
                                (set! ball.3.5 rdi)
                                (set! bar.7.4 rsi)
                                (set! bat.6.3 rdx)
                                (set! ball.4.2 rcx)
                                (set! bat.5.1 r8)
                                (if (not (<= bat.6.3 9223372036854775807))
                                    (begin
                                      (begin
                                        (set! bat.6.7 -18835826)
                                        (set! foobar.9.6 bat.6.7))
                                      (if (>= bat.6.3 ball.4.2)
                                          (begin
                                            (set! rax bat.6.3)
                                            (jump tmp-ra.14 rbp rax))
                                          (begin
                                            (set! rax bar.7.4)
                                            (jump tmp-ra.14 rbp rax))))
                                    (begin
                                      (begin
                                        (return-point L.rp.3
                                                      (begin
                                                        (set! r8 0)
                                                        (set! rcx bat.5.1)
                                                        (set! rdx bat.6.3)
                                                        (set! rsi 9223372036854775807)
                                                        (set! rdi bat.5.1)
                                                        (set! r15 L.rp.3)
                                                        (jump L.x.0.1 rbp r15 rdi rsi rdx rcx r8)))
                                        (set! bat.5.8 rax))
                                      (if (<= bar.7.4 -186024487)
                                          (begin
                                            (set! rax bat.5.8)
                                            (jump tmp-ra.14 rbp rax))
                                          (begin
                                            (set! rax bat.6.3)
                                            (jump tmp-ra.14 rbp rax))))))))
                    (define L.func.1.2
                      ((new-frames ()))
                      (begin
                        (set! tmp-ra.15 r15)
                        (begin
                          (set! bar.8.10 rdi)
                          (set! ball.4.9 rsi)
                          (begin
                            (set! bar.7.11 -932453002)
                            (begin
                              (if (>= -1133252869 9223372036854775807)
                                  (set! foobar.9.12 479665611)
                                  (set! foobar.9.12 bar.8.10))
                              (begin
                                (set! bat.5.13 bar.7.11)
                                (begin
                                  (set! rax bar.7.11)
                                  (jump tmp-ra.15 rbp rax))))))))
                    (begin
                      (set! tmp-ra.16 r15)
                      (if (>= 1588211020 1)
                          (begin
                            (set! rax 9223372036854775807)
                            (jump tmp-ra.16 rbp rax))
                          (begin
                            (set! rax -9223372036854775808)
                            (jump tmp-ra.16 rbp rax))))))

(check-by-interp '(module ((new-frames ()))
                          (begin
                            (set! tmp-ra.1 r15)
                            (if (>= 1 -9223372036854775808)
                                (begin
                                  (set! rax 234292566)
                                  (jump tmp-ra.1 rbp rax))
                                (begin
                                  (set! rax -1579825632)
                                  (jump tmp-ra.1 rbp rax))))
                    ))

(check-by-interp '(module ((new-frames ()))
                          (begin
                            (set! tmp-ra.1 r15)
                            (begin
                              (set! rax 1)
                              (jump tmp-ra.1 rbp rax)))
                    ))
(check-by-interp '(module ((new-frames ()))
                          (define L.fn.0.1
                            ((new-frames ()))
                            (begin
                              (set! tmp-ra.18 r15)
                              (begin
                                (set! ball.9.2 rdi)
                                (set! bat.0.1 rsi)
                                (begin
                                  (set! foobar.4.3 ball.9.2)
                                  (begin
                                    (set! rax (* 0 0))
                                    (jump tmp-ra.18 rbp rax))))))
                    (define L.fn.1.2
                      ((new-frames ()))
                      (begin
                        (set! tmp-ra.19 r15)
                        (begin
                          (if (>= -9223372036854775808 9223372036854775807)
                              (begin
                                (set! rax -1098447432)
                                (jump tmp-ra.19 rbp rax))
                              (begin
                                (set! ball.9.4 (+ -9223372036854775808 -9223372036854775808))
                                (if (< 857729561 9223372036854775807)
                                    (begin
                                      (set! rax 9223372036854775807)
                                      (jump tmp-ra.19 rbp rax))
                                    (begin
                                      (set! rax 1)
                                      (jump tmp-ra.19 rbp rax))))))))
                    (define L.fn.2.3
                      ((new-frames ()))
                      (begin
                        (set! tmp-ra.20 r15)
                        (begin
                          (set! bat.5.11 rdi)
                          (set! bat.0.10 rsi)
                          (set! ball.9.9 rdx)
                          (set! foobar.4.8 rcx)
                          (set! bar.7.7 r8)
                          (set! bat.3.6 r9)
                          (set! bar.2.5 fv0)
                          (if (not (true))
                              (begin
                                (if (>= foobar.4.8 -9223372036854775808)
                                    (set! bar.2.12 1)
                                    (set! bar.2.12 1))
                                (begin
                                  (set! rsi bar.2.12)
                                  (set! rdi bat.0.10)
                                  (set! r15 tmp-ra.20)
                                  (jump L.fn.0.1 rbp r15 rdi rsi)))
                              (if (true)
                                  (begin
                                    (set! rax (* bat.3.6 foobar.4.8))
                                    (jump tmp-ra.20 rbp rax))
                                  (begin
                                    (set! bat.6.13 bat.5.11)
                                    (begin
                                      (set! rax 674342291)
                                      (jump tmp-ra.20 rbp rax))))))))
                    (begin
                      (set! tmp-ra.21 r15)
                      (if (begin
                            (begin
                              (begin
                                (set! bar.2.16 1)
                                (set! bar.2.15 -9223372036854775808))
                              (begin
                                (set! foobar.8.17 bar.2.15)
                                (set! bat.0.14 9223372036854775807)))
                            (if (true)
                                (if (= bat.0.14 bat.0.14)
                                    (>= -1195644570 bat.0.14)
                                    (= bat.0.14 bat.0.14))
                                (if (> bat.0.14 bat.0.14)
                                    (>= bat.0.14 bat.0.14)
                                    (= 0 bat.0.14))))
                          (begin
                            (set! fv0 0)
                            (set! r9 9223372036854775807)
                            (set! r8 -2036437657)
                            (set! rcx 0)
                            (set! rdx 0)
                            (set! rsi -1663007716)
                            (set! rdi 1453047515)
                            (set! r15 tmp-ra.21)
                            (jump L.fn.2.3 rbp r15 rdi rsi rdx rcx r8 r9 fv0))
                          (begin
                            (set! rsi -1792916675)
                            (set! rdi 1)
                            (set! r15 tmp-ra.21)
                            (jump L.fn.0.1 rbp r15 rdi rsi))))))
(check-by-interp '(module ((new-frames ()))
                          (begin
                            (set! tmp-ra.5 r15)
                            (begin
                              (if (> -9223372036854775808 9223372036854775807)
                                  (begin
                                    (if (!= 1 9223372036854775807)
                                        (set! bar.5.2 9223372036854775807)
                                        (set! bar.5.2 463110926))
                                    (set! bat.4.1 0))
                                  (begin
                                    (set! bar.3.3 0)
                                    (set! bat.4.1 (- -1584028825 -9223372036854775808))))
                              (if (not (> bat.4.1 1))
                                  (if (begin
                                        (set! ball.6.4 -9223372036854775808)
                                        (>= ball.6.4 ball.6.4))
                                      (if (> bat.4.1 491128034)
                                          (begin
                                            (set! rax bat.4.1)
                                            (jump tmp-ra.5 rbp rax))
                                          (begin
                                            (set! rax 1)
                                            (jump tmp-ra.5 rbp rax)))
                                      (if (= 1050399943 bat.4.1)
                                          (begin
                                            (set! rax -1604958676)
                                            (jump tmp-ra.5 rbp rax))
                                          (begin
                                            (set! rax bat.4.1)
                                            (jump tmp-ra.5 rbp rax))))
                                  (begin
                                    (set! rax bat.4.1)
                                    (jump tmp-ra.5 rbp rax)))))
                    ))

(check-by-interp '(module ((new-frames ()))
                          (define L.proc.0.1
                            ((new-frames ()))
                            (begin
                              (set! tmp-ra.18 r15)
                              (begin
                                (set! foo.8.4 rdi)
                                (set! bat.5.3 rsi)
                                (set! foo.6.2 rdx)
                                (set! bar.0.1 rcx)
                                (begin
                                  (set! r8 foo.6.2)
                                  (set! rcx 9223372036854775807)
                                  (set! rdx bat.5.3)
                                  (set! rsi bar.0.1)
                                  (set! rdi 9223372036854775807)
                                  (set! r15 tmp-ra.18)
                                  (jump L.func.1.2 rbp r15 rdi rsi rdx rcx r8)))))
                    (define L.func.1.2
                      ((new-frames ()))
                      (begin
                        (set! tmp-ra.19 r15)
                        (begin
                          (set! bat.3.9 rdi)
                          (set! foo.8.8 rsi)
                          (set! bar.0.7 rdx)
                          (set! foo.9.6 rcx)
                          (set! bat.4.5 r8)
                          (begin
                            (set! fv0 -9223372036854775808)
                            (set! r9 bat.4.5)
                            (set! r8 foo.9.6)
                            (set! rcx bar.0.7)
                            (set! rdx foo.8.8)
                            (set! rsi bar.0.7)
                            (set! rdi 9223372036854775807)
                            (set! r15 tmp-ra.19)
                            (jump L.tmp.2.3 rbp r15 rdi rsi rdx rcx r8 r9 fv0)))))
                    (define L.tmp.2.3
                      ((new-frames ()))
                      (begin
                        (set! tmp-ra.20 r15)
                        (begin
                          (set! foo.7.16 rdi)
                          (set! bat.3.15 rsi)
                          (set! bat.5.14 rdx)
                          (set! bat.4.13 rcx)
                          (set! foo.8.12 r8)
                          (set! foo.2.11 r9)
                          (set! foo.6.10 fv0)
                          (begin
                            (set! rax bat.5.14)
                            (jump tmp-ra.20 rbp rax)))))
                    (begin
                      (set! tmp-ra.21 r15)
                      (if (false)
                          (begin
                            (set! foo.9.17 1281469771)
                            (begin
                              (set! rax 0)
                              (jump tmp-ra.21 rbp rax)))
                          (begin
                            (set! fv0 1)
                            (set! r9 9223372036854775807)
                            (set! r8 1)
                            (set! rcx -282402130)
                            (set! rdx -9223372036854775808)
                            (set! rsi 9223372036854775807)
                            (set! rdi 1)
                            (set! r15 tmp-ra.21)
                            (jump L.tmp.2.3 rbp r15 rdi rsi rdx rcx r8 r9 fv0))))))
(check-by-interp '(module ((new-frames ()))
                          (define L.tmp.0.1
                            ((new-frames ()))
                            (begin
                              (set! tmp-ra.16 r15)
                              (begin
                                (set! bar.8.7 rdi)
                                (set! bar.4.6 rsi)
                                (set! foo.7.5 rdx)
                                (set! foo.6.4 rcx)
                                (set! bat.3.3 r8)
                                (set! foobar.2.2 r9)
                                (set! ball.5.1 fv0)
                                (begin
                                  (set! rdx foo.6.4)
                                  (set! rsi 946654223)
                                  (set! rdi 9223372036854775807)
                                  (set! r15 tmp-ra.16)
                                  (jump L.func.1.2 rbp r15 rdi rsi rdx)))))
                    (define L.func.1.2
                      ((new-frames ()))
                      (begin
                        (set! tmp-ra.17 r15)
                        (begin
                          (set! ball.1.10 rdi)
                          (set! ball.5.9 rsi)
                          (set! bar.8.8 rdx)
                          (begin
                            (set! rdx 9223372036854775807)
                            (set! rsi bar.8.8)
                            (set! rdi ball.5.9)
                            (set! r15 tmp-ra.17)
                            (jump L.func.1.2 rbp r15 rdi rsi rdx)))))
                    (define L.fn.2.3
                      ((new-frames ()))
                      (begin
                        (set! tmp-ra.18 r15)
                        (begin
                          (set! bar.8.13 rdi)
                          (set! ball.0.12 rsi)
                          (set! ball.5.11 rdx)
                          (begin
                            (set! ball.5.14 9223372036854775807)
                            (begin
                              (set! rdx bar.8.13)
                              (set! rsi 0)
                              (set! rdi ball.0.12)
                              (set! r15 tmp-ra.18)
                              (jump L.func.1.2 rbp r15 rdi rsi rdx))))))
                    (begin
                      (set! tmp-ra.19 r15)
                      (begin
                        (set! ball.1.15 0)
                        (begin
                          (set! rax 1)
                          (jump tmp-ra.19 rbp rax))))))
(check-by-interp '(module ((new-frames ()))
                          (define L.func.0.1
                            ((new-frames ()))
                            (begin
                              (set! tmp-ra.8 r15)
                              (begin
                                (set! foo.9.5 rdi)
                                (set! foo.0.4 rsi)
                                (set! foobar.7.3 rdx)
                                (set! bat.2.2 rcx)
                                (set! foo.1.1 r8)
                                (if (false)
                                    (begin
                                      (if (!= -9223372036854775808 0)
                                          (set! ball.3.6 1)
                                          (set! ball.3.6 foo.9.5))
                                      (begin
                                        (set! foo.9.7 9223372036854775807)
                                        (begin
                                          (set! rax 9223372036854775807)
                                          (jump tmp-ra.8 rbp rax))))
                                    (begin
                                      (set! rax 1)
                                      (jump tmp-ra.8 rbp rax))))))
                    (begin
                      (set! tmp-ra.9 r15)
                      (begin
                        (set! r8 1653803490)
                        (set! rcx 1918330809)
                        (set! rdx 1)
                        (set! rsi 9223372036854775807)
                        (set! rdi -9223372036854775808)
                        (set! r15 tmp-ra.9)
                        (jump L.func.0.1 rbp r15 rdi rsi rdx rcx r8)))))
(check-by-interp '(module ((new-frames ()))
                          (define L.fn.0.1
                            ((new-frames ()))
                            (begin
                              (set! tmp-ra.7 r15)
                              (begin
                                (set! bat.8.2 rdi)
                                (set! bat.6.1 rsi)
                                (if (begin
                                      (set! foobar.1.3 559317709)
                                      (not (= foobar.1.3 bat.8.2)))
                                    (begin
                                      (set! rdx -675648818)
                                      (set! rsi -9223372036854775808)
                                      (set! rdi bat.6.1)
                                      (set! r15 tmp-ra.7)
                                      (jump L.func.1.2 rbp r15 rdi rsi rdx))
                                    (begin
                                      (set! r15 tmp-ra.7)
                                      (jump L.tmp.2.3 rbp r15))))))
                    (define L.func.1.2
                      ((new-frames ()))
                      (begin
                        (set! tmp-ra.8 r15)
                        (begin
                          (set! foobar.1.6 rdi)
                          (set! foo.0.5 rsi)
                          (set! foo.5.4 rdx)
                          (begin
                            (set! r15 tmp-ra.8)
                            (jump L.tmp.2.3 rbp r15)))))
                    (define L.tmp.2.3
                      ((new-frames ()))
                      (begin
                        (set! tmp-ra.9 r15)
                        (begin
                          (begin
                            (set! r15 tmp-ra.9)
                            (jump L.tmp.2.3 rbp r15)))))
                    (begin
                      (set! tmp-ra.10 r15)
                      (begin
                        (set! rax 1)
                        (jump tmp-ra.10 rbp rax)))))
(check-by-interp '(module ((new-frames ()))
                          (define L.x.0.1
                            ((new-frames ()))
                            (begin
                              (set! tmp-ra.8 r15)
                              (begin
                                (set! bar.3.4 rdi)
                                (set! ball.0.3 rsi)
                                (set! bat.2.2 rdx)
                                (set! bat.9.1 rcx)
                                (begin
                                  (if (= ball.0.3 bat.9.1)
                                      (set! bat.2.5 ball.0.3)
                                      (set! bat.2.5 -1012326174))
                                  (begin
                                    (begin
                                      (set! bar.3.7 0)
                                      (set! foobar.7.6 bar.3.7))
                                    (begin
                                      (set! rax (- bar.3.4 0))
                                      (jump tmp-ra.8 rbp rax)))))))
                    (begin
                      (set! tmp-ra.9 r15)
                      (begin
                        (set! rcx 1259250868)
                        (set! rdx 1097392993)
                        (set! rsi 0)
                        (set! rdi 1)
                        (set! r15 tmp-ra.9)
                        (jump L.x.0.1 rbp r15 rdi rsi rdx rcx)))))

(check-by-interp '(module ((new-frames ()))
                          (define L.tmp.0.1
                            ((new-frames ()))
                            (begin
                              (set! tmp-ra.10 r15)
                              (begin
                                (set! bar.9.3 rdi)
                                (set! ball.5.2 rsi)
                                (set! bar.4.1 rdx)
                                (begin
                                  (set! r8 bar.4.1)
                                  (set! rcx 1)
                                  (set! rdx ball.5.2)
                                  (set! rsi -1620042780)
                                  (set! rdi 0)
                                  (set! r15 tmp-ra.10)
                                  (jump L.x.1.2 rbp r15 rdi rsi rdx rcx r8)))))
                    (define L.x.1.2
                      ((new-frames ()))
                      (begin
                        (set! tmp-ra.11 r15)
                        (begin
                          (set! ball.8.8 rdi)
                          (set! bar.2.7 rsi)
                          (set! bar.9.6 rdx)
                          (set! bat.0.5 rcx)
                          (set! foo.1.4 r8)
                          (begin
                            (set! foo.6.9 9223372036854775807)
                            (begin
                              (set! rax (+ -9223372036854775808 bat.0.5))
                              (jump tmp-ra.11 rbp rax))))))
                    (begin
                      (set! tmp-ra.12 r15)
                      (begin
                        (set! r8 0)
                        (set! rcx 1)
                        (set! rdx 9223372036854775807)
                        (set! rsi -913438169)
                        (set! rdi -1611188905)
                        (set! r15 tmp-ra.12)
                        (jump L.x.1.2 rbp r15 rdi rsi rdx rcx r8)))))

(check-by-interp '(module ((new-frames (())))
                          (define L.tmp.0.1
                            ((new-frames ()))
                            (begin
                              (set! tmp-ra.8 r15)
                              (begin
                                (set! bar.4.4 rdi)
                                (set! foobar.9.3 rsi)
                                (set! ball.5.2 rdx)
                                (set! bar.8.1 rcx)
                                (begin
                                  (set! rcx ball.5.2)
                                  (set! rdx ball.5.2)
                                  (set! rsi ball.5.2)
                                  (set! rdi foobar.9.3)
                                  (set! r15 tmp-ra.8)
                                  (jump L.tmp.0.1 rbp r15 rdi rsi rdx rcx)))))
                    (begin
                      (set! tmp-ra.9 r15)
                      (if (false)
                          (begin
                            (if (if (> 9223372036854775807 1428972274)
                                    (!= 0 479631559)
                                    (>= 0 1284385619))
                                (begin
                                  (return-point L.rp.2
                                                (begin
                                                  (set! rcx 1)
                                                  (set! rdx 0)
                                                  (set! rsi -1164071576)
                                                  (set! rdi 1550080702)
                                                  (set! r15 L.rp.2)
                                                  (jump L.tmp.0.1 rbp r15 rdi rsi rdx rcx)))
                                  (set! bar.7.5 rax))
                                (set! bar.7.5 -9223372036854775808))
                            (if (if (<= 0 bar.7.5)
                                    (!= bar.7.5 2009350954)
                                    (!= 1170635915 bar.7.5))
                                (begin
                                  (set! foobar.1.6 bar.7.5)
                                  (begin
                                    (set! rax 0)
                                    (jump tmp-ra.9 rbp rax)))
                                (begin
                                  (set! foobar.1.7 -378459323)
                                  (begin
                                    (set! rax bar.7.5)
                                    (jump tmp-ra.9 rbp rax)))))
                          (if (false)
                              (begin
                                (set! rax 0)
                                (jump tmp-ra.9 rbp rax))
                              (begin
                                (set! rax (- 1326448876 360169641))
                                (jump tmp-ra.9 rbp rax)))))))
(check-by-interp '(module ((new-frames ()))
                          (begin
                            (set! tmp-ra.4 r15)
                            (begin
                              (begin
                                (set! foo.5.2 1)
                                (begin
                                  (set! foo.5.3 foo.5.2)
                                  (set! foo.7.1 foo.5.3)))
                              (begin
                                (set! rax foo.7.1)
                                (jump tmp-ra.4 rbp rax))))
                    ))

(check-by-interp '(module ((new-frames ()))
                          (define L.func.0.1
                            ((new-frames ()))
                            (begin
                              (set! tmp-ra.9 r15)
                              (begin
                                (set! bat.7.3 rdi)
                                (set! foo.1.2 rsi)
                                (set! foobar.8.1 rdx)
                                (begin
                                  (set! rax (* 1903463490 -9223372036854775808))
                                  (jump tmp-ra.9 rbp rax)))))
                    (define L.func.1.2
                      ((new-frames ()))
                      (begin
                        (set! tmp-ra.10 r15)
                        (begin
                          (set! foobar.9.7 rdi)
                          (set! bat.7.6 rsi)
                          (set! bar.3.5 rdx)
                          (set! bat.0.4 rcx)
                          (begin
                            (set! foobar.4.8 (- -9223372036854775808 foobar.9.7))
                            (if (> 9223372036854775807 bar.3.5)
                                (if (< bat.7.6 bat.0.4)
                                    (begin
                                      (set! rax foobar.4.8)
                                      (jump tmp-ra.10 rbp rax))
                                    (begin
                                      (set! rax bat.7.6)
                                      (jump tmp-ra.10 rbp rax)))
                                (if (>= bat.0.4 1408489810)
                                    (begin
                                      (set! rax foobar.4.8)
                                      (jump tmp-ra.10 rbp rax))
                                    (begin
                                      (set! rax bat.7.6)
                                      (jump tmp-ra.10 rbp rax))))))))
                    (begin
                      (set! tmp-ra.11 r15)
                      (begin
                        (set! rax (* 977777990 900224161))
                        (jump tmp-ra.11 rbp rax)))))

(check-by-interp '(module ((new-frames ()))
                          (define L.x.0.1
                            ((new-frames (())))
                            (begin
                              (set! tmp-ra.8 r15)
                              (begin
                                (if (<= 0 1773437967)
                                    (begin
                                      (begin
                                        (return-point L.rp.4
                                                      (begin
                                                        (set! rdi 1456910402)
                                                        (set! r15 L.rp.4)
                                                        (jump L.tmp.2.3 rbp r15 rdi)))
                                        (set! foobar.2.1 rax))
                                      (begin
                                        (set! bar.5.2 -9223372036854775808)
                                        (begin
                                          (set! rax 1)
                                          (jump tmp-ra.8 rbp rax))))
                                    (begin
                                      (set! rdi -9223372036854775808)
                                      (set! r15 tmp-ra.8)
                                      (jump L.tmp.2.3 rbp r15 rdi))))))
                    (define L.fn.1.2
                      ((new-frames ()))
                      (begin
                        (set! tmp-ra.9 r15)
                        (begin
                          (set! bat.6.6 rdi)
                          (set! foobar.3.5 rsi)
                          (set! foo.9.4 rdx)
                          (set! bat.1.3 rcx)
                          (begin
                            (set! rdi foo.9.4)
                            (set! r15 tmp-ra.9)
                            (jump L.tmp.2.3 rbp r15 rdi)))))
                    (define L.tmp.2.3
                      ((new-frames ()))
                      (begin
                        (set! tmp-ra.10 r15)
                        (begin
                          (set! bat.1.7 rdi)
                          (begin
                            (set! rax bat.1.7)
                            (jump tmp-ra.10 rbp rax)))))
                    (begin
                      (set! tmp-ra.11 r15)
                      (begin
                        (set! rdi 0)
                        (set! r15 tmp-ra.11)
                        (jump L.tmp.2.3 rbp r15 rdi)))))
(check-by-interp '(module ((new-frames ()))
                          (define L.fn.0.1
                            ((new-frames ()))
                            (begin
                              (set! tmp-ra.16 r15)
                              (begin
                                (set! foobar.4.2 rdi)
                                (set! foo.5.1 rsi)
                                (begin
                                  (begin
                                    (set! foo.5.4 foobar.4.2)
                                    (set! bat.1.3 (+ foobar.4.2 foo.5.4)))
                                  (begin
                                    (set! rsi foo.5.1)
                                    (set! rdi 0)
                                    (set! r15 tmp-ra.16)
                                    (jump L.fn.0.1 rbp r15 rdi rsi))))))
                    (define L.tmp.1.2
                      ((new-frames ()))
                      (begin
                        (set! tmp-ra.17 r15)
                        (begin
                          (set! bat.0.9 rdi)
                          (set! foo.2.8 rsi)
                          (set! foobar.4.7 rdx)
                          (set! bat.1.6 rcx)
                          (set! bat.9.5 r8)
                          (if (if (true)
                                  (< bat.9.5 bat.0.9)
                                  (begin
                                    (set! bar.7.10 bat.0.9)
                                    (<= 0 -508327908)))
                              (begin
                                (if (<= 167876306 bat.0.9)
                                    (set! bat.9.11 44784438)
                                    (set! bat.9.11 -874603706))
                                (begin
                                  (set! r8 foobar.4.7)
                                  (set! rcx foobar.4.7)
                                  (set! rdx 0)
                                  (set! rsi 696038140)
                                  (set! rdi -9223372036854775808)
                                  (set! r15 tmp-ra.17)
                                  (jump L.tmp.1.2 rbp r15 rdi rsi rdx rcx r8)))
                              (if (begin
                                    (set! foobar.3.12 bat.9.5)
                                    (= bat.1.6 0))
                                  (if (< foobar.4.7 foobar.4.7)
                                      (begin
                                        (set! rax foo.2.8)
                                        (jump tmp-ra.17 rbp rax))
                                      (begin
                                        (set! rax -727094500)
                                        (jump tmp-ra.17 rbp rax)))
                                  (begin
                                    (set! rsi -9223372036854775808)
                                    (set! rdi bat.0.9)
                                    (set! r15 tmp-ra.17)
                                    (jump L.fn.0.1 rbp r15 rdi rsi)))))))
                    (begin
                      (set! tmp-ra.18 r15)
                      (begin
                        (begin
                          (if (<= 9223372036854775807 0)
                              (set! bat.0.14 0)
                              (set! bat.0.14 93609173))
                          (begin
                            (set! foo.6.15 bat.0.14)
                            (set! foo.5.13 foo.6.15)))
                        (begin
                          (set! rax foo.5.13)
                          (jump tmp-ra.18 rbp rax))))))
(check-by-interp '(module ((new-frames ()))
                          (begin
                            (set! tmp-ra.6 r15)
                            (begin
                              (begin
                                (set! bat.1.2 -9223372036854775808)
                                (begin
                                  (set! foobar.4.3 0)
                                  (set! bar.7.1 foobar.4.3)))
                              (if (begin
                                    (set! foo.0.4 bar.7.1)
                                    (<= 1 -9223372036854775808))
                                  (begin
                                    (set! rax bar.7.1)
                                    (jump tmp-ra.6 rbp rax))
                                  (begin
                                    (set! foobar.4.5 bar.7.1)
                                    (begin
                                      (set! rax 1974766267)
                                      (jump tmp-ra.6 rbp rax))))))
                    ))
(check-by-interp '(module ((new-frames ()))
                          (define L.func.0.1
                            ((new-frames ()))
                            (begin
                              (set! tmp-ra.11 r15)
                              (begin
                                (set! bar.0.6 rdi)
                                (set! foobar.2.5 rsi)
                                (set! foo.1.4 rdx)
                                (set! foobar.9.3 rcx)
                                (set! bat.5.2 r8)
                                (set! foobar.8.1 r9)
                                (begin
                                  (set! bat.6.7 -951184591)
                                  (if (false)
                                      (begin
                                        (set! foo.1.8 -9223372036854775808)
                                        (begin
                                          (set! rax foo.1.8)
                                          (jump tmp-ra.11 rbp rax)))
                                      (begin
                                        (set! foo.1.9 310790521)
                                        (begin
                                          (set! rax foobar.8.1)
                                          (jump tmp-ra.11 rbp rax))))))))
                    (begin
                      (set! tmp-ra.12 r15)
                      (begin
                        (set! foo.1.10 -1379426851)
                        (begin
                          (set! rax 488563830)
                          (jump tmp-ra.12 rbp rax))))))
(check-by-interp '(module ((new-frames ()))
                          (define L.func.0.1
                            ((new-frames ()))
                            (begin
                              (set! tmp-ra.7 r15)
                              (begin
                                (set! ball.2.3 rdi)
                                (set! foo.5.2 rsi)
                                (set! ball.0.1 rdx)
                                (if (if (= 0 ball.2.3)
                                        (false)
                                        (if (<= ball.0.1 -483103791)
                                            (= foo.5.2 ball.2.3)
                                            (= ball.2.3 foo.5.2)))
                                    (begin
                                      (set! rdx 1)
                                      (set! rsi 1)
                                      (set! rdi foo.5.2)
                                      (set! r15 tmp-ra.7)
                                      (jump L.func.0.1 rbp r15 rdi rsi rdx))
                                    (if (true)
                                        (begin
                                          (set! foo.5.4 ball.2.3)
                                          (begin
                                            (set! rax foo.5.4)
                                            (jump tmp-ra.7 rbp rax)))
                                        (begin
                                          (set! rdx 1)
                                          (set! rsi foo.5.2)
                                          (set! rdi foo.5.2)
                                          (set! r15 tmp-ra.7)
                                          (jump L.func.0.1 rbp r15 rdi rsi rdx)))))))
                    (begin
                      (set! tmp-ra.8 r15)
                      (begin
                        (set! foo.5.5 -1766715399)
                        (if (not (not (< foo.5.5 foo.5.5)))
                            (begin
                              (if (< foo.5.5 0)
                                  (set! foobar.4.6 9223372036854775807)
                                  (set! foobar.4.6 foo.5.5))
                              (begin
                                (set! rax -1170116362)
                                (jump tmp-ra.8 rbp rax)))
                            (begin
                              (set! rax (* 0 0))
                              (jump tmp-ra.8 rbp rax)))))))

(check-by-interp '(module ((new-frames ()))
                          (define L.tmp.0.1
                            ((new-frames ()))
                            (begin
                              (set! tmp-ra.9 r15)
                              (begin
                                (set! bar.0.3 rdi)
                                (set! bar.4.2 rsi)
                                (set! bar.9.1 rdx)
                                (begin
                                  (set! rdi 9223372036854775807)
                                  (set! r15 tmp-ra.9)
                                  (jump L.fn.1.2 rbp r15 rdi)))))
                    (define L.fn.1.2
                      ((new-frames ()))
                      (begin
                        (set! tmp-ra.10 r15)
                        (begin
                          (set! bar.9.4 rdi)
                          (if (> 1 1)
                              (begin
                                (set! rdx -9223372036854775808)
                                (set! rsi -9223372036854775808)
                                (set! rdi bar.9.4)
                                (set! r15 tmp-ra.10)
                                (jump L.x.2.3 rbp r15 rdi rsi rdx))
                              (if (if (> bar.9.4 9223372036854775807)
                                      (<= bar.9.4 2069349298)
                                      (= 327435684 bar.9.4))
                                  (begin
                                    (set! rdx bar.9.4)
                                    (set! rsi bar.9.4)
                                    (set! rdi 937688474)
                                    (set! r15 tmp-ra.10)
                                    (jump L.x.2.3 rbp r15 rdi rsi rdx))
                                  (begin
                                    (set! rax -9223372036854775808)
                                    (jump tmp-ra.10 rbp rax)))))))
                    (define L.x.2.3
                      ((new-frames ()))
                      (begin
                        (set! tmp-ra.11 r15)
                        (begin
                          (set! foobar.6.7 rdi)
                          (set! ball.8.6 rsi)
                          (set! bar.4.5 rdx)
                          (begin
                            (set! rdx bar.4.5)
                            (set! rsi -845528888)
                            (set! rdi foobar.6.7)
                            (set! r15 tmp-ra.11)
                            (jump L.x.2.3 rbp r15 rdi rsi rdx)))))
                    (begin
                      (set! tmp-ra.12 r15)
                      (begin
                        (set! bat.1.8 0)
                        (begin
                          (set! rax bat.1.8)
                          (jump tmp-ra.12 rbp rax))))))
(check-by-interp '(module ((new-frames ()))
                          (define L.x.0.1
                            ((new-frames ()))
                            (begin
                              (set! tmp-ra.18 r15)
                              (begin
                                (set! foobar.4.5 rdi)
                                (set! bar.5.4 rsi)
                                (set! foobar.6.3 rdx)
                                (set! ball.7.2 rcx)
                                (set! bat.1.1 r8)
                                (if (false)
                                    (if (begin
                                          (set! bar.9.6 foobar.6.3)
                                          (< 0 foobar.6.3))
                                        (begin
                                          (set! rsi -9223372036854775808)
                                          (set! rdi 0)
                                          (set! r15 tmp-ra.18)
                                          (jump L.x.1.2 rbp r15 rdi rsi))
                                        (begin
                                          (set! foobar.2.7 bat.1.1)
                                          (begin
                                            (set! rax foobar.4.5)
                                            (jump tmp-ra.18 rbp rax))))
                                    (if (true)
                                        (if (!= -9223372036854775808 1)
                                            (begin
                                              (set! rax 0)
                                              (jump tmp-ra.18 rbp rax))
                                            (begin
                                              (set! rax 849007740)
                                              (jump tmp-ra.18 rbp rax)))
                                        (begin
                                          (set! rax foobar.4.5)
                                          (jump tmp-ra.18 rbp rax)))))))
                    (define L.x.1.2
                      ((new-frames ()))
                      (begin
                        (set! tmp-ra.19 r15)
                        (begin
                          (set! foobar.6.9 rdi)
                          (set! bar.0.8 rsi)
                          (begin
                            (set! foobar.4.10 bar.0.8)
                            (begin
                              (set! r8 9223372036854775807)
                              (set! rcx 0)
                              (set! rdx foobar.4.10)
                              (set! rsi 0)
                              (set! rdi foobar.6.9)
                              (set! r15 tmp-ra.19)
                              (jump L.x.0.1 rbp r15 rdi rsi rdx rcx r8))))))
                    (define L.x.2.3
                      ((new-frames (())))
                      (begin
                        (set! tmp-ra.20 r15)
                        (begin
                          (set! foobar.2.15 rdi)
                          (set! foobar.4.14 rsi)
                          (set! bar.8.13 rdx)
                          (set! ball.3.12 rcx)
                          (set! bar.5.11 r8)
                          (begin
                            (begin
                              (return-point L.rp.4
                                            (begin
                                              (set! rsi bar.5.11)
                                              (set! rdi bar.5.11)
                                              (set! r15 L.rp.4)
                                              (jump L.x.1.2 rbp r15 rdi rsi)))
                              (set! bar.8.16 rax))
                            (begin
                              (set! rsi 1)
                              (set! rdi -1927041153)
                              (set! r15 tmp-ra.20)
                              (jump L.x.1.2 rbp r15 rdi rsi))))))
                    (begin
                      (set! tmp-ra.21 r15)
                      (begin
                        (set! ball.3.17 (* 1 -394936001))
                        (begin
                          (set! r8 ball.3.17)
                          (set! rcx -9223372036854775808)
                          (set! rdx 0)
                          (set! rsi ball.3.17)
                          (set! rdi ball.3.17)
                          (set! r15 tmp-ra.21)
                          (jump L.x.0.1 rbp r15 rdi rsi rdx rcx r8))))))

(check-by-interp '(module ((new-frames (())))
                          (define L.tmp.0.1
                            ((new-frames ()))
                            (begin
                              (set! tmp-ra.7 r15)
                              (begin
                                (set! bat.3.5 rdi)
                                (set! bar.8.4 rsi)
                                (set! ball.4.3 rdx)
                                (set! bar.2.2 rcx)
                                (set! foo.6.1 r8)
                                (begin
                                  (set! rax foo.6.1)
                                  (jump tmp-ra.7 rbp rax)))))
                    (begin
                      (set! tmp-ra.8 r15)
                      (begin
                        (begin
                          (return-point L.rp.2
                                        (begin
                                          (set! r8 -9223372036854775808)
                                          (set! rcx 1)
                                          (set! rdx 0)
                                          (set! rsi -9223372036854775808)
                                          (set! rdi 1)
                                          (set! r15 L.rp.2)
                                          (jump L.tmp.0.1 rbp r15 rdi rsi rdx rcx r8)))
                          (set! foo.5.6 rax))
                        (if (= -9223372036854775808 175566669)
                            (begin
                              (set! rax -1855219983)
                              (jump tmp-ra.8 rbp rax))
                            (begin
                              (set! rax foo.5.6)
                              (jump tmp-ra.8 rbp rax)))))))
(check-by-interp '(module ((new-frames (())))
                          (define L.proc.0.1
                            ((new-frames ()))
                            (begin
                              (set! tmp-ra.11 r15)
                              (begin
                                (set! ball.1.1 rdi)
                                (begin
                                  (if (begin
                                        (set! bar.5.3 1541307282)
                                        (= 9223372036854775807 -194099637))
                                      (set! bar.2.2 (- ball.1.1 -1702731989))
                                      (begin
                                        (set! bar.2.4 ball.1.1)
                                        (set! bar.2.2 ball.1.1)))
                                  (if (not (= -9223372036854775808 bar.2.2))
                                      (begin
                                        (set! bar.6.5 1)
                                        (begin
                                          (set! rax bar.2.2)
                                          (jump tmp-ra.11 rbp rax)))
                                      (begin
                                        (set! rdi 0)
                                        (set! r15 tmp-ra.11)
                                        (jump L.proc.0.1 rbp r15 rdi)))))))
                    (define L.fn.1.2
                      ((new-frames ()))
                      (begin
                        (set! tmp-ra.12 r15)
                        (begin
                          (begin
                            (set! rax (+ 9223372036854775807 1))
                            (jump tmp-ra.12 rbp rax)))))
                    (define L.fn.2.3
                      ((new-frames ()))
                      (begin
                        (set! tmp-ra.13 r15)
                        (begin
                          (set! bat.9.6 rdi)
                          (begin
                            (set! bar.6.7 (* 1 0))
                            (begin
                              (set! r15 tmp-ra.13)
                              (jump L.fn.1.2 rbp r15))))))
                    (begin
                      (set! tmp-ra.14 r15)
                      (if (true)
                          (begin
                            (begin
                              (return-point L.rp.4
                                            (begin
                                              (set! rdi 1)
                                              (set! r15 L.rp.4)
                                              (jump L.fn.2.3 rbp r15 rdi)))
                              (set! bat.3.8 rax))
                            (begin
                              (set! bar.7.9 bat.3.8)
                              (begin
                                (set! rax 1)
                                (jump tmp-ra.14 rbp rax))))
                          (begin
                            (set! bar.5.10 -1579827217)
                            (begin
                              (set! rdi bar.5.10)
                              (set! r15 tmp-ra.14)
                              (jump L.fn.2.3 rbp r15 rdi)))))))
(check-by-interp '(module ((new-frames ()))
                          (define L.x.0.1
                            ((new-frames (())))
                            (begin
                              (set! tmp-ra.17 r15)
                              (begin
                                (set! bar.6.5 rdi)
                                (set! foobar.5.4 rsi)
                                (set! foo.9.3 rdx)
                                (set! foobar.7.2 rcx)
                                (set! ball.4.1 r8)
                                (begin
                                  (begin
                                    (begin
                                      (return-point L.rp.4
                                                    (begin
                                                      (set! r8 1)
                                                      (set! rcx foo.9.3)
                                                      (set! rdx ball.4.1)
                                                      (set! rsi ball.4.1)
                                                      (set! rdi 0)
                                                      (set! r15 L.rp.4)
                                                      (jump L.x.0.1 rbp r15 rdi rsi rdx rcx r8)))
                                      (set! foobar.7.7 rax))
                                    (set! bat.3.6 (- foobar.7.7 foobar.7.7)))
                                  (if (true)
                                      (begin
                                        (set! rax (* -9223372036854775808 foobar.7.2))
                                        (jump tmp-ra.17 rbp rax))
                                      (if (!= -9223372036854775808 bat.3.6)
                                          (begin
                                            (set! rax foobar.7.2)
                                            (jump tmp-ra.17 rbp rax))
                                          (begin
                                            (set! rax 0)
                                            (jump tmp-ra.17 rbp rax))))))))
                    (define L.fn.1.2
                      ((new-frames ()))
                      (begin
                        (set! tmp-ra.18 r15)
                        (begin
                          (set! foo.2.12 rdi)
                          (set! foobar.1.11 rsi)
                          (set! foo.8.10 rdx)
                          (set! ball.4.9 rcx)
                          (set! foobar.7.8 r8)
                          (if (false)
                              (begin
                                (if (!= -1658461695 9223372036854775807)
                                    (set! foo.8.13 -9223372036854775808)
                                    (set! foo.8.13 foobar.1.11))
                                (begin
                                  (set! rax 9223372036854775807)
                                  (jump tmp-ra.18 rbp rax)))
                              (if (false)
                                  (if (= foo.8.10 1)
                                      (begin
                                        (set! rax ball.4.9)
                                        (jump tmp-ra.18 rbp rax))
                                      (begin
                                        (set! rax 9223372036854775807)
                                        (jump tmp-ra.18 rbp rax)))
                                  (begin
                                    (set! ball.0.14 foo.8.10)
                                    (begin
                                      (set! rax 1)
                                      (jump tmp-ra.18 rbp rax))))))))
                    (define L.tmp.2.3
                      ((new-frames ()))
                      (begin
                        (set! tmp-ra.19 r15)
                        (begin
                          (begin
                            (begin
                              (set! foo.8.16 1)
                              (set! foobar.5.15 foo.8.16))
                            (if (if (> 9223372036854775807 foobar.5.15)
                                    (>= foobar.5.15 9223372036854775807)
                                    (<= foobar.5.15 foobar.5.15))
                                (if (> foobar.5.15 foobar.5.15)
                                    (begin
                                      (set! rax 1)
                                      (jump tmp-ra.19 rbp rax))
                                    (begin
                                      (set! rax foobar.5.15)
                                      (jump tmp-ra.19 rbp rax)))
                                (begin
                                  (set! r8 9223372036854775807)
                                  (set! rcx foobar.5.15)
                                  (set! rdx foobar.5.15)
                                  (set! rsi -126978532)
                                  (set! rdi foobar.5.15)
                                  (set! r15 tmp-ra.19)
                                  (jump L.x.0.1 rbp r15 rdi rsi rdx rcx r8)))))))
                    (begin
                      (set! tmp-ra.20 r15)
                      (begin
                        (set! rax (* -1293429216 880066208))
                        (jump tmp-ra.20 rbp rax)))))
(check-by-interp '(module ((new-frames ()))
                          (define L.proc.0.1
                            ((new-frames ()))
                            (begin
                              (set! tmp-ra.14 r15)
                              (begin
                                (set! bar.4.6 rdi)
                                (set! foobar.5.5 rsi)
                                (set! bar.0.4 rdx)
                                (set! foo.7.3 rcx)
                                (set! ball.3.2 r8)
                                (set! ball.8.1 r9)
                                (if (not (if (> 0 701262944)
                                             (!= foo.7.3 9223372036854775807)
                                             (< ball.8.1 ball.8.1)))
                                    (if (true)
                                        (if (= 1779018832 ball.8.1)
                                            (begin
                                              (set! rax -9223372036854775808)
                                              (jump tmp-ra.14 rbp rax))
                                            (begin
                                              (set! rax bar.4.6)
                                              (jump tmp-ra.14 rbp rax)))
                                        (begin
                                          (set! bar.0.7 foo.7.3)
                                          (begin
                                            (set! rax foobar.5.5)
                                            (jump tmp-ra.14 rbp rax))))
                                    (begin
                                      (set! r9 bar.4.6)
                                      (set! r8 ball.3.2)
                                      (set! rcx foo.7.3)
                                      (set! rdx 9223372036854775807)
                                      (set! rsi ball.8.1)
                                      (set! rdi 1)
                                      (set! r15 tmp-ra.14)
                                      (jump L.proc.0.1 rbp r15 rdi rsi rdx rcx r8 r9))))))
                    (define L.proc.1.2
                      ((new-frames ()))
                      (begin
                        (set! tmp-ra.15 r15)
                        (begin
                          (set! bar.1.10 rdi)
                          (set! ball.8.9 rsi)
                          (set! foobar.2.8 rdx)
                          (begin
                            (if (<= -408033154 bar.1.10)
                                (set! ball.3.11 (+ ball.8.9 bar.1.10))
                                (begin
                                  (set! bar.4.12 ball.8.9)
                                  (set! ball.3.11 bar.4.12)))
                            (begin
                              (set! rdx ball.8.9)
                              (set! rsi bar.1.10)
                              (set! rdi ball.8.9)
                              (set! r15 tmp-ra.15)
                              (jump L.proc.1.2 rbp r15 rdi rsi rdx))))))
                    (begin
                      (set! tmp-ra.16 r15)
                      (begin
                        (if (<= 1 899234556)
                            (set! ball.3.13 0)
                            (set! ball.3.13 0))
                        (begin
                          (set! r9 -9223372036854775808)
                          (set! r8 1792291800)
                          (set! rcx ball.3.13)
                          (set! rdx 1961997671)
                          (set! rsi ball.3.13)
                          (set! rdi ball.3.13)
                          (set! r15 tmp-ra.16)
                          (jump L.proc.0.1 rbp r15 rdi rsi rdx rcx r8 r9))))))
(check-by-interp '(module ((new-frames ()))
                          (define L.x.0.1
                            ((new-frames ()))
                            (begin
                              (set! tmp-ra.14 r15)
                              (begin
                                (set! foo.5.4 rdi)
                                (set! foo.0.3 rsi)
                                (set! foo.3.2 rdx)
                                (set! foo.4.1 rcx)
                                (begin
                                  (if (begin
                                        (set! ball.1.6 foo.4.1)
                                        (<= -9223372036854775808 -1549190542))
                                      (begin
                                        (set! foo.0.7 1)
                                        (set! ball.7.5 foo.3.2))
                                      (set! ball.7.5 foo.3.2))
                                  (if (true)
                                      (begin
                                        (set! foo.3.8 foo.0.3)
                                        (begin
                                          (set! rax ball.7.5)
                                          (jump tmp-ra.14 rbp rax)))
                                      (begin
                                        (set! rcx foo.0.3)
                                        (set! rdx -9223372036854775808)
                                        (set! rsi foo.3.2)
                                        (set! rdi foo.3.2)
                                        (set! r15 tmp-ra.14)
                                        (jump L.x.0.1 rbp r15 rdi rsi rdx rcx)))))))
                    (begin
                      (set! tmp-ra.15 r15)
                      (begin
                        (if (true)
                            (set! bat.8.9 480297521)
                            (set! bat.8.9 (- 1 0)))
                        (if (= bat.8.9 0)
                            (begin
                              (begin
                                (set! bat.9.11 bat.8.9)
                                (set! foo.4.10 0))
                              (begin
                                (set! rcx foo.4.10)
                                (set! rdx 0)
                                (set! rsi 9223372036854775807)
                                (set! rdi 9223372036854775807)
                                (set! r15 tmp-ra.15)
                                (jump L.x.0.1 rbp r15 rdi rsi rdx rcx)))
                            (if (begin
                                  (set! bat.9.12 1)
                                  (>= bat.8.9 1434817833))
                                (begin
                                  (set! rax (* -9223372036854775808 -1655015632))
                                  (jump tmp-ra.15 rbp rax))
                                (begin
                                  (set! bat.2.13 -9223372036854775808)
                                  (begin
                                    (set! rax 1398310587)
                                    (jump tmp-ra.15 rbp rax)))))))))
(check-by-interp '(module ((new-frames ()))
                          (define L.func.0.1
                            ((new-frames ()))
                            (begin
                              (set! tmp-ra.10 r15)
                              (begin
                                (set! bat.1.7 rdi)
                                (set! foo.6.6 rsi)
                                (set! ball.0.5 rdx)
                                (set! foo.9.4 rcx)
                                (set! foo.5.3 r8)
                                (set! ball.2.2 r9)
                                (set! foo.4.1 fv0)
                                (if (> 9223372036854775807 -1225978347)
                                    (if (if (> ball.0.5 1)
                                            (> ball.2.2 -9223372036854775808)
                                            (!= foo.5.3 -847185955))
                                        (begin
                                          (set! fv0 -260761950)
                                          (set! r9 0)
                                          (set! r8 -9223372036854775808)
                                          (set! rcx foo.9.4)
                                          (set! rdx foo.6.6)
                                          (set! rsi -144908363)
                                          (set! rdi 9223372036854775807)
                                          (set! r15 tmp-ra.10)
                                          (jump L.func.0.1 rbp r15 rdi rsi rdx rcx r8 r9 fv0))
                                        (if (> foo.9.4 foo.9.4)
                                            (begin
                                              (set! rax 0)
                                              (jump tmp-ra.10 rbp rax))
                                            (begin
                                              (set! rax 1)
                                              (jump tmp-ra.10 rbp rax))))
                                    (begin
                                      (set! foo.3.8 9223372036854775807)
                                      (begin
                                        (set! fv0 0)
                                        (set! r9 foo.6.6)
                                        (set! r8 foo.6.6)
                                        (set! rcx 9223372036854775807)
                                        (set! rdx -9223372036854775808)
                                        (set! rsi -472335653)
                                        (set! rdi -9223372036854775808)
                                        (set! r15 tmp-ra.10)
                                        (jump L.func.0.1 rbp r15 rdi rsi rdx rcx r8 r9 fv0)))))))
                    (begin
                      (set! tmp-ra.11 r15)
                      (if (>= 1 9223372036854775807)
                          (begin
                            (set! bar.8.9 1)
                            (begin
                              (set! rax bar.8.9)
                              (jump tmp-ra.11 rbp rax)))
                          (begin
                            (set! rax -32529780)
                            (jump tmp-ra.11 rbp rax))))))

;   ;;good to above

;   ;; M6 tests; Added by Trevor on March 6th 2026, multiple bindings allowed per let
(check-by-interp '(module ((new-frames ()))
                          (define L.proc.0.1
                            ((new-frames ()))
                            (begin
                              (set! tmp-ra.10 r15)
                              (begin
                                (set! ball.9.7 rdi)
                                (set! foo.5.6 rsi)
                                (set! ball.2.5 rdx)
                                (set! ball.7.4 rcx)
                                (set! foo.0.3 r8)
                                (set! bat.8.2 r9)
                                (set! foobar.1.1 fv0)
                                (begin
                                  (set! r15 tmp-ra.10)
                                  (jump L.tmp.1.2 rbp r15)))))
                    (define L.tmp.1.2
                      ((new-frames ()))
                      (begin
                        (set! tmp-ra.11 r15)
                        (begin
                          (begin
                            (set! rsi 0)
                            (set! rdi 0)
                            (set! r15 tmp-ra.11)
                            (jump L.proc.2.3 rbp r15 rdi rsi)))))
                    (define L.proc.2.3
                      ((new-frames ()))
                      (begin
                        (set! tmp-ra.12 r15)
                        (begin
                          (set! foo.6.9 rdi)
                          (set! bat.8.8 rsi)
                          (begin
                            (set! fv0 1635273112)
                            (set! r9 foo.6.9)
                            (set! r8 bat.8.8)
                            (set! rcx foo.6.9)
                            (set! rdx 445965252)
                            (set! rsi foo.6.9)
                            (set! rdi bat.8.8)
                            (set! r15 tmp-ra.12)
                            (jump L.proc.0.1 rbp r15 rdi rsi rdx rcx r8 r9 fv0)))))
                    (begin
                      (set! tmp-ra.13 r15)
                      (if (if (<= 9223372036854775807 -9223372036854775808)
                              (< 692968731 0)
                              (<= -1490931083 -14809197))
                          (begin
                            (set! rax 1275113131)
                            (jump tmp-ra.13 rbp rax))
                          (if (<= -1702177019 -9223372036854775808)
                              (begin
                                (set! rax 0)
                                (jump tmp-ra.13 rbp rax))
                              (begin
                                (set! rax 1843455920)
                                (jump tmp-ra.13 rbp rax)))))))
(check-by-interp '(module ((new-frames ()))
                          (define L.fn.0.1
                            ((new-frames ()))
                            (begin
                              (set! tmp-ra.11 r15)
                              (begin
                                (set! bat.5.7 rdi)
                                (set! foo.2.6 rsi)
                                (set! bar.9.5 rdx)
                                (set! foo.8.4 rcx)
                                (set! foobar.4.3 r8)
                                (set! bat.3.2 r9)
                                (set! bat.7.1 fv0)
                                (begin
                                  (set! fv0 bat.3.2)
                                  (set! r9 foo.8.4)
                                  (set! r8 foo.8.4)
                                  (set! rcx 9223372036854775807)
                                  (set! rdx bat.5.7)
                                  (set! rsi -9223372036854775808)
                                  (set! rdi bat.3.2)
                                  (set! r15 tmp-ra.11)
                                  (jump L.fn.0.1 rbp r15 rdi rsi rdx rcx r8 r9 fv0)))))
                    (begin
                      (set! tmp-ra.12 r15)
                      (begin
                        (set! bat.6.10 9223372036854775807)
                        (set! foobar.4.9 9223372036854775807)
                        (set! ball.0.8 9223372036854775807)
                        (begin
                          (set! rax foobar.4.9)
                          (jump tmp-ra.12 rbp rax))))))
(check-by-interp '(module ((new-frames ()))
                          (define L.func.0.1
                            ((new-frames (())))
                            (begin
                              (set! tmp-ra.11 r15)
                              (begin
                                (set! bar.2.5 rdi)
                                (set! ball.4.4 rsi)
                                (set! foo.9.3 rdx)
                                (set! foobar.5.2 rcx)
                                (set! foo.6.1 r8)
                                (if (true)
                                    (begin
                                      (set! foo.9.7 bar.2.5)
                                      (begin
                                        (return-point L.rp.3
                                                      (begin
                                                        (set! rdx -1140169546)
                                                        (set! rsi foobar.5.2)
                                                        (set! rdi foo.9.3)
                                                        (set! r15 L.rp.3)
                                                        (jump L.func.1.2 rbp r15 rdi rsi rdx)))
                                        (set! bat.0.6 rax))
                                      (begin
                                        (set! rax (+ foo.6.1 bat.0.6))
                                        (jump tmp-ra.11 rbp rax)))
                                    (begin
                                      (set! rdx 9223372036854775807)
                                      (set! rsi foobar.5.2)
                                      (set! rdi foo.6.1)
                                      (set! r15 tmp-ra.11)
                                      (jump L.func.1.2 rbp r15 rdi rsi rdx))))))
                    (define L.func.1.2
                      ((new-frames ()))
                      (begin
                        (set! tmp-ra.12 r15)
                        (begin
                          (set! bat.0.10 rdi)
                          (set! foo.6.9 rsi)
                          (set! foo.9.8 rdx)
                          (if (!= 9223372036854775807 -47909185)
                              (if (false)
                                  (if (< foo.9.8 foo.9.8)
                                      (begin
                                        (set! rax bat.0.10)
                                        (jump tmp-ra.12 rbp rax))
                                      (begin
                                        (set! rax -9223372036854775808)
                                        (jump tmp-ra.12 rbp rax)))
                                  (begin
                                    (set! rdx foo.9.8)
                                    (set! rsi foo.9.8)
                                    (set! rdi bat.0.10)
                                    (set! r15 tmp-ra.12)
                                    (jump L.func.1.2 rbp r15 rdi rsi rdx)))
                              (begin
                                (set! rax (+ -9223372036854775808 foo.6.9))
                                (jump tmp-ra.12 rbp rax))))))
                    (begin
                      (set! tmp-ra.13 r15)
                      (if (> 9223372036854775807 9223372036854775807)
                          (begin
                            (set! rax -877748660)
                            (jump tmp-ra.13 rbp rax))
                          (begin
                            (set! rax -9223372036854775808)
                            (jump tmp-ra.13 rbp rax))))))
(check-by-interp '(module ((new-frames ()))
                          (begin
                            (set! tmp-ra.1 r15)
                            (begin
                              (set! rax (+ -1640821439 -406700566))
                              (jump tmp-ra.1 rbp rax)))
                    ))
(check-by-interp '(module ((new-frames ()))
                          (define L.fn.0.1
                            ((new-frames ()))
                            (begin
                              (set! tmp-ra.11 r15)
                              (begin
                                (set! foo.2.2 rdi)
                                (set! ball.6.1 rsi)
                                (begin
                                  (set! r9 foo.2.2)
                                  (set! r8 ball.6.1)
                                  (set! rcx -9223372036854775808)
                                  (set! rdx ball.6.1)
                                  (set! rsi foo.2.2)
                                  (set! rdi ball.6.1)
                                  (set! r15 tmp-ra.11)
                                  (jump L.x.1.2 rbp r15 rdi rsi rdx rcx r8 r9)))))
                    (define L.x.1.2
                      ((new-frames ()))
                      (begin
                        (set! tmp-ra.12 r15)
                        (begin
                          (set! ball.0.8 rdi)
                          (set! foo.4.7 rsi)
                          (set! foobar.1.6 rdx)
                          (set! ball.5.5 rcx)
                          (set! foo.2.4 r8)
                          (set! bar.7.3 r9)
                          (begin
                            (set! r9 ball.5.5)
                            (set! r8 1)
                            (set! rcx -984231193)
                            (set! rdx bar.7.3)
                            (set! rsi bar.7.3)
                            (set! rdi 933807622)
                            (set! r15 tmp-ra.12)
                            (jump L.x.1.2 rbp r15 rdi rsi rdx rcx r8 r9)))))
                    (begin
                      (set! tmp-ra.13 r15)
                      (begin
                        (set! bat.9.10 -477286222)
                        (set! bar.7.9 0)
                        (begin
                          (set! rax 643069821)
                          (jump tmp-ra.13 rbp rax))))))
(check-by-interp '(module ((new-frames ()))
                          (define L.func.0.1
                            ((new-frames ()))
                            (begin
                              (set! tmp-ra.15 r15)
                              (begin
                                (set! bar.9.1 rdi)
                                (if (!= bar.9.1 bar.9.1)
                                    (begin
                                      (set! rdi 2058053814)
                                      (set! r15 tmp-ra.15)
                                      (jump L.func.0.1 rbp r15 rdi))
                                    (begin
                                      (set! bat.2.3 (- bar.9.1 bar.9.1))
                                      (begin
                                        (set! bar.9.6 bar.9.1)
                                        (set! bat.0.5 bar.9.1)
                                        (set! ball.4.4 bar.9.1)
                                        (set! bat.0.2 ball.4.4))
                                      (begin
                                        (set! rdi bar.9.1)
                                        (set! r15 tmp-ra.15)
                                        (jump L.x.2.3 rbp r15 rdi)))))))
                    (define L.tmp.1.2
                      ((new-frames ()))
                      (begin
                        (set! tmp-ra.16 r15)
                        (begin
                          (set! bat.8.9 rdi)
                          (set! bat.3.8 rsi)
                          (set! bat.5.7 rdx)
                          (begin
                            (set! rdi bat.8.9)
                            (set! r15 tmp-ra.16)
                            (jump L.x.2.3 rbp r15 rdi)))))
                    (define L.x.2.3
                      ((new-frames (())))
                      (begin
                        (set! tmp-ra.17 r15)
                        (begin
                          (set! bar.9.10 rdi)
                          (begin
                            (begin
                              (return-point L.rp.4
                                            (begin
                                              (set! rdx -1942673900)
                                              (set! rsi bar.9.10)
                                              (set! rdi bar.9.10)
                                              (set! r15 L.rp.4)
                                              (jump L.tmp.1.2 rbp r15 rdi rsi rdx)))
                              (set! bar.9.11 rax))
                            (if (begin
                                  (set! foo.1.14 bar.9.11)
                                  (set! bat.8.13 bar.9.11)
                                  (set! ball.7.12 bar.9.11)
                                  (= ball.7.12 bar.9.11))
                                (begin
                                  (set! rdx -1386061378)
                                  (set! rsi bar.9.11)
                                  (set! rdi bar.9.11)
                                  (set! r15 tmp-ra.17)
                                  (jump L.tmp.1.2 rbp r15 rdi rsi rdx))
                                (begin
                                  (set! rdi bar.9.11)
                                  (set! r15 tmp-ra.17)
                                  (jump L.func.0.1 rbp r15 rdi)))))))
                    (begin
                      (set! tmp-ra.18 r15)
                      (if (true)
                          (begin
                            (set! rax (+ 9223372036854775807 -9223372036854775808))
                            (jump tmp-ra.18 rbp rax))
                          (begin
                            (set! rdi -2107846344)
                            (set! r15 tmp-ra.18)
                            (jump L.func.0.1 rbp r15 rdi))))))
(check-by-interp '(module ((new-frames ()))
                          (begin
                            (set! tmp-ra.1 r15)
                            (if (<= 1 -9223372036854775808)
                                (if (false)
                                    (begin
                                      (set! rax -9223372036854775808)
                                      (jump tmp-ra.1 rbp rax))
                                    (begin
                                      (set! rax 2012039291)
                                      (jump tmp-ra.1 rbp rax)))
                                (begin
                                  (set! rax 9223372036854775807)
                                  (jump tmp-ra.1 rbp rax))))
                    ))
(check-by-interp '(module ((new-frames ()))
                          (define L.func.0.1
                            ((new-frames ()))
                            (begin
                              (set! tmp-ra.22 r15)
                              (begin
                                (set! foo.2.6 rdi)
                                (set! ball.1.5 rsi)
                                (set! foo.4.4 rdx)
                                (set! foobar.7.3 rcx)
                                (set! foo.5.2 r8)
                                (set! foo.9.1 r9)
                                (begin
                                  (set! rax (- foo.2.6 foo.4.4))
                                  (jump tmp-ra.22 rbp rax)))))
                    (define L.proc.1.2
                      ((new-frames (())))
                      (begin
                        (set! tmp-ra.23 r15)
                        (begin
                          (begin
                            (set! foo.6.7 (+ 9223372036854775807 1))
                            (begin
                              (begin
                                (return-point L.rp.4
                                              (begin
                                                (set! r9 foo.6.7)
                                                (set! r8 foo.6.7)
                                                (set! rcx foo.6.7)
                                                (set! rdx foo.6.7)
                                                (set! rsi foo.6.7)
                                                (set! rdi 0)
                                                (set! r15 L.rp.4)
                                                (jump L.func.0.1 rbp r15 rdi rsi rdx rcx r8 r9)))
                                (set! foo.6.10 rax))
                              (set! foobar.7.9 foo.6.7)
                              (if (>= foo.6.7 foo.6.7)
                                  (set! foo.2.8 foo.6.7)
                                  (set! foo.2.8 foo.6.7))
                              (begin
                                (set! foo.4.13 foo.6.10)
                                (set! foobar.7.12 foo.6.10)
                                (set! foo.6.11 -9223372036854775808)
                                (begin
                                  (set! rax 9223372036854775807)
                                  (jump tmp-ra.23 rbp rax))))))))
                    (define L.func.2.3
                      ((new-frames ()))
                      (begin
                        (set! tmp-ra.24 r15)
                        (begin
                          (set! bar.0.17 rdi)
                          (set! foobar.7.16 rsi)
                          (set! foo.4.15 rdx)
                          (set! foo.6.14 rcx)
                          (begin
                            (set! foo.9.18 foobar.7.16)
                            (begin
                              (begin
                                (set! foo.6.21 foo.6.14)
                                (set! foo.9.20 foo.6.14)
                                (set! foo.4.19 foobar.7.16))
                              (if (>= foo.9.18 foo.6.14)
                                  (begin
                                    (set! rax foobar.7.16)
                                    (jump tmp-ra.24 rbp rax))
                                  (begin
                                    (set! rax bar.0.17)
                                    (jump tmp-ra.24 rbp rax))))))))
                    (begin
                      (set! tmp-ra.25 r15)
                      (begin
                        (set! rcx 9223372036854775807)
                        (set! rdx -1735352110)
                        (set! rsi 9223372036854775807)
                        (set! rdi 0)
                        (set! r15 tmp-ra.25)
                        (jump L.func.2.3 rbp r15 rdi rsi rdx rcx)))))
(check-by-interp
 '(module ((new-frames ()))
          (define L.x.0.1
            ((new-frames ((nfv.17))))
            (begin
              (set! tmp-ra.16 r15)
              (begin
                (set! bat.9.7 rdi)
                (set! foobar.7.6 rsi)
                (set! ball.1.5 rdx)
                (set! foo.2.4 rcx)
                (set! ball.6.3 r8)
                (set! bar.0.2 r9)
                (set! foobar.8.1 fv0)
                (begin
                  (begin
                    (return-point L.rp.3
                                  (begin
                                    (set! nfv.17 bar.0.2)
                                    (set! r9 bat.9.7)
                                    (set! r8 bar.0.2)
                                    (set! rcx 0)
                                    (set! rdx foobar.8.1)
                                    (set! rsi foo.2.4)
                                    (set! rdi foo.2.4)
                                    (set! r15 L.rp.3)
                                    (jump L.fn.1.2 rbp r15 rdi rsi rdx rcx r8 r9 nfv.17)))
                    (set! ball.1.8 rax))
                  (if (not (< 0 -9223372036854775808))
                      (begin
                        (set! rax (+ ball.6.3 ball.1.8))
                        (jump tmp-ra.16 rbp rax))
                      (if (<= foo.2.4 0)
                          (begin
                            (set! rax foo.2.4)
                            (jump tmp-ra.16 rbp rax))
                          (begin
                            (set! rax foobar.7.6)
                            (jump tmp-ra.16 rbp rax))))))))
    (define L.fn.1.2
      ((new-frames ()))
      (begin
        (set! tmp-ra.18 r15)
        (begin
          (set! bat.9.15 rdi)
          (set! bar.0.14 rsi)
          (set! foobar.4.13 rdx)
          (set! ball.6.12 rcx)
          (set! bat.5.11 r8)
          (set! foobar.7.10 r9)
          (set! foobar.8.9 fv0)
          (begin
            (set! fv0 0)
            (set! r9 bar.0.14)
            (set! r8 foobar.7.10)
            (set! rcx -9223372036854775808)
            (set! rdx bar.0.14)
            (set! rsi foobar.7.10)
            (set! rdi ball.6.12)
            (set! r15 tmp-ra.18)
            (jump L.fn.1.2 rbp r15 rdi rsi rdx rcx r8 r9 fv0)))))
    (begin
      (set! tmp-ra.19 r15)
      (if (>= -9223372036854775808 -637253177)
          (begin
            (set! rax -9223372036854775808)
            (jump tmp-ra.19 rbp rax))
          (begin
            (set! rax 0)
            (jump tmp-ra.19 rbp rax))))))
(check-by-interp '(module ((new-frames ()))
                          (begin
                            (set! tmp-ra.1 r15)
                            (begin
                              (set! rax 9223372036854775807)
                              (jump tmp-ra.1 rbp rax)))
                    ))
(check-by-interp
 '(module ((new-frames ()))
          (define L.proc.0.1
            ((new-frames ()))
            (begin
              (set! tmp-ra.28 r15)
              (begin
                (set! bat.8.6 rdi)
                (set! foo.7.5 rsi)
                (set! foo.0.4 rdx)
                (set! bat.1.3 rcx)
                (set! bat.5.2 r8)
                (set! bat.6.1 r9)
                (begin
                  (set! r9 bat.1.3)
                  (set! r8 bat.8.6)
                  (set! rcx -635532414)
                  (set! rdx bat.5.2)
                  (set! rsi bat.5.2)
                  (set! rdi bat.5.2)
                  (set! r15 tmp-ra.28)
                  (jump L.proc.0.1 rbp r15 rdi rsi rdx rcx r8 r9)))))
    (define L.tmp.1.2
      ((new-frames ((nfv.31) (nfv.30) ())))
      (begin
        (set! tmp-ra.29 r15)
        (begin
          (set! bat.6.11 rdi)
          (set! foo.0.10 rsi)
          (set! bat.8.9 rdx)
          (set! ball.9.8 rcx)
          (set! foo.7.7 r8)
          (begin
            (begin
              (return-point L.rp.4
                            (begin
                              (set! r8 foo.7.7)
                              (set! rcx ball.9.8)
                              (set! rdx bat.6.11)
                              (set! rsi foo.7.7)
                              (set! rdi ball.9.8)
                              (set! r15 L.rp.4)
                              (jump L.tmp.1.2 rbp r15 rdi rsi rdx rcx r8)))
              (set! foo.0.13 rax))
            (begin
              (begin
                (return-point L.rp.5
                              (begin
                                (set! nfv.30 foo.7.7)
                                (set! r9 bat.8.9)
                                (set! r8 ball.9.8)
                                (set! rcx -501684781)
                                (set! rdx foo.7.7)
                                (set! rsi 9223372036854775807)
                                (set! rdi foo.0.10)
                                (set! r15 L.rp.5)
                                (jump L.func.2.3 rbp r15 rdi rsi rdx rcx r8 r9 nfv.30)))
                (set! bat.5.15 rax))
              (set! bar.3.14 foo.0.10)
              (begin
                (return-point L.rp.6
                              (begin
                                (set! nfv.31 bat.6.11)
                                (set! r9 foo.0.10)
                                (set! r8 bat.8.9)
                                (set! rcx -9223372036854775808)
                                (set! rdx foo.7.7)
                                (set! rsi 1644735104)
                                (set! rdi bat.6.11)
                                (set! r15 L.rp.6)
                                (jump L.func.2.3 rbp r15 rdi rsi rdx rcx r8 r9 nfv.31)))
                (set! ball.4.12 rax)))
            (begin
              (set! ball.9.17 (- foo.0.13 foo.0.13))
              (if (= foo.0.13 ball.4.12)
                  (set! bat.8.16 ball.4.12)
                  (set! bat.8.16 foo.0.13))
              (begin
                (set! fv0 ball.4.12)
                (set! r9 -9223372036854775808)
                (set! r8 bat.6.11)
                (set! rcx bat.8.16)
                (set! rdx foo.7.7)
                (set! rsi foo.7.7)
                (set! rdi ball.4.12)
                (set! r15 tmp-ra.29)
                (jump L.func.2.3 rbp r15 rdi rsi rdx rcx r8 r9 fv0)))))))
    (define L.func.2.3
      ((new-frames ()))
      (begin
        (set! tmp-ra.32 r15)
        (begin
          (set! foo.2.24 rdi)
          (set! bat.5.23 rsi)
          (set! bat.8.22 rdx)
          (set! foo.0.21 rcx)
          (set! bar.3.20 r8)
          (set! bat.1.19 r9)
          (set! ball.4.18 fv0)
          (begin
            (set! fv0 9223372036854775807)
            (set! r9 foo.0.21)
            (set! r8 ball.4.18)
            (set! rcx ball.4.18)
            (set! rdx foo.0.21)
            (set! rsi -9223372036854775808)
            (set! rdi bar.3.20)
            (set! r15 tmp-ra.32)
            (jump L.func.2.3 rbp r15 rdi rsi rdx rcx r8 r9 fv0)))))
    (begin
      (set! tmp-ra.33 r15)
      (begin
        (set! bar.3.27 -9223372036854775808)
        (set! foo.7.26 9223372036854775807)
        (set! foo.0.25 9223372036854775807)
        (begin
          (set! rax bar.3.27)
          (jump tmp-ra.33 rbp rax))))))
(check-by-interp '(module ((new-frames ()))
                          (define L.func.0.1
                            ((new-frames (())))
                            (begin
                              (set! tmp-ra.22 r15)
                              (begin
                                (set! foo.4.5 rdi)
                                (set! ball.5.4 rsi)
                                (set! bar.2.3 rdx)
                                (set! bat.3.2 rcx)
                                (set! bar.1.1 r8)
                                (if (begin
                                      (set! bar.1.8 bar.2.3)
                                      (if (<= bat.3.2 bar.1.1)
                                          (set! bat.3.7 bat.3.2)
                                          (set! bat.3.7 bar.1.1))
                                      (begin
                                        (return-point L.rp.3
                                                      (begin
                                                        (set! r8 bar.1.1)
                                                        (set! rcx foo.4.5)
                                                        (set! rdx foo.4.5)
                                                        (set! rsi bar.2.3)
                                                        (set! rdi 1)
                                                        (set! r15 L.rp.3)
                                                        (jump L.func.0.1 rbp r15 rdi rsi rdx rcx r8)))
                                        (set! foo.4.6 rax))
                                      (false))
                                    (begin
                                      (set! r8 0)
                                      (set! rcx bar.2.3)
                                      (set! rdx 1603961181)
                                      (set! rsi ball.5.4)
                                      (set! rdi bar.1.1)
                                      (set! r15 tmp-ra.22)
                                      (jump L.func.0.1 rbp r15 rdi rsi rdx rcx r8))
                                    (begin
                                      (set! r9 bat.3.2)
                                      (set! r8 bar.1.1)
                                      (set! rcx ball.5.4)
                                      (set! rdx bar.1.1)
                                      (set! rsi -9223372036854775808)
                                      (set! rdi ball.5.4)
                                      (set! r15 tmp-ra.22)
                                      (jump L.fn.1.2 rbp r15 rdi rsi rdx rcx r8 r9))))))
                    (define L.fn.1.2
                      ((new-frames ()))
                      (begin
                        (set! tmp-ra.23 r15)
                        (begin
                          (set! bar.1.14 rdi)
                          (set! bat.7.13 rsi)
                          (set! ball.5.12 rdx)
                          (set! bar.0.11 rcx)
                          (set! bat.3.10 r8)
                          (set! foobar.9.9 r9)
                          (begin
                            (if (if (>= bat.3.10 bar.1.14)
                                    (> bat.7.13 -9223372036854775808)
                                    (>= ball.5.12 bat.3.10))
                                (begin
                                  (set! bat.7.17 bar.0.11)
                                  (set! foobar.9.16 9223372036854775807)
                                  (set! bat.8.15 bar.1.14)
                                  (begin
                                    (set! rax bat.3.10)
                                    (jump tmp-ra.23 rbp rax)))
                                (if (< bat.3.10 bar.1.14)
                                    (begin
                                      (set! rax bar.0.11)
                                      (jump tmp-ra.23 rbp rax))
                                    (begin
                                      (set! rax bat.7.13)
                                      (jump tmp-ra.23 rbp rax))))))))
                    (begin
                      (set! tmp-ra.24 r15)
                      (begin
                        (set! bar.2.20 405359082)
                        (if (not (>= -915730633 0))
                            (begin
                              (set! bat.8.21 -532660031)
                              (set! bat.6.19 -248685178))
                            (set! bat.6.19 0))
                        (set! bat.7.18 1254220652)
                        (begin
                          (set! r9 bar.2.20)
                          (set! r8 bat.6.19)
                          (set! rcx 9223372036854775807)
                          (set! rdx bat.6.19)
                          (set! rsi bat.6.19)
                          (set! rdi -9223372036854775808)
                          (set! r15 tmp-ra.24)
                          (jump L.fn.1.2 rbp r15 rdi rsi rdx rcx r8 r9))))))
(check-by-interp
 '(module ((new-frames ()))
          (define L.proc.0.1
            ((new-frames ()))
            (begin
              (set! tmp-ra.19 r15)
              (begin
                (set! foobar.9.5 rdi)
                (set! foobar.7.4 rsi)
                (set! foo.2.3 rdx)
                (set! foo.5.2 rcx)
                (set! foo.1.1 r8)
                (begin
                  (set! r8 1)
                  (set! rcx -1754605622)
                  (set! rdx -675715652)
                  (set! rsi foo.2.3)
                  (set! rdi foo.1.1)
                  (set! r15 tmp-ra.19)
                  (jump L.proc.0.1 rbp r15 rdi rsi rdx rcx r8)))))
    (define L.func.1.2
      ((new-frames ()))
      (begin
        (set! tmp-ra.20 r15)
        (begin
          (set! foobar.3.7 rdi)
          (set! foo.1.6 rsi)
          (begin
            (set! r8 foo.1.6)
            (set! rcx foo.1.6)
            (set! rdx foobar.3.7)
            (set! rsi foobar.3.7)
            (set! rdi foo.1.6)
            (set! r15 tmp-ra.20)
            (jump L.proc.0.1 rbp r15 rdi rsi rdx rcx r8)))))
    (define L.x.2.3
      ((new-frames ((nfv.22))))
      (begin
        (set! tmp-ra.21 r15)
        (begin
          (set! bar.0.14 rdi)
          (set! foobar.9.13 rsi)
          (set! foo.8.12 rdx)
          (set! bar.4.11 rcx)
          (set! bat.6.10 r8)
          (set! foo.1.9 r9)
          (set! foobar.7.8 fv0)
          (begin
            (if (>= bar.4.11 foobar.7.8)
                (set! foobar.9.16 foobar.9.13)
                (begin
                  (return-point L.rp.4
                                (begin
                                  (set! nfv.22 1783645727)
                                  (set! r9 foo.1.9)
                                  (set! r8 bar.4.11)
                                  (set! rcx bat.6.10)
                                  (set! rdx 0)
                                  (set! rsi foo.8.12)
                                  (set! rdi 1)
                                  (set! r15 L.rp.4)
                                  (jump L.x.2.3 rbp r15 rdi rsi rdx rcx r8 r9 nfv.22)))
                  (set! foobar.9.16 rax)))
            (set! foo.1.15 (* bar.4.11 bar.4.11))
            (begin
              (set! fv0 bar.4.11)
              (set! r9 bar.0.14)
              (set! r8 -922337918)
              (set! rcx foobar.7.8)
              (set! rdx foobar.7.8)
              (set! rsi bar.4.11)
              (set! rdi foobar.7.8)
              (set! r15 tmp-ra.21)
              (jump L.x.2.3 rbp r15 rdi rsi rdx rcx r8 r9 fv0))))))
    (begin
      (set! tmp-ra.23 r15)
      (begin
        (set! bar.0.18 0)
        (set! foo.8.17 1029279872)
        (begin
          (set! rax bar.0.18)
          (jump tmp-ra.23 rbp rax))))))
(check-by-interp '(module ((new-frames ()))
                          (begin
                            (set! tmp-ra.6 r15)
                            (if (if (begin
                                      (set! bat.2.2 1)
                                      (set! foobar.0.1 -1606724555)
                                      (= bat.2.2 bat.2.2))
                                    (begin
                                      (set! ball.5.5 1)
                                      (set! bat.1.4 1)
                                      (set! bar.8.3 -9223372036854775808)
                                      (<= ball.5.5 ball.5.5))
                                    (begin
                                      (!= -1879829070 1981475003)))
                                (begin
                                  (set! rax (- -634246165 -684848771))
                                  (jump tmp-ra.6 rbp rax))
                                (begin
                                  (set! rax 0)
                                  (jump tmp-ra.6 rbp rax))))
                    ))
(check-by-interp '(module ((new-frames ()))
                          (define L.func.0.1
                            ((new-frames ()))
                            (begin
                              (set! tmp-ra.8 r15)
                              (begin
                                (set! bat.2.3 rdi)
                                (set! foo.3.2 rsi)
                                (set! bar.6.1 rdx)
                                (begin
                                  (set! rdx bat.2.3)
                                  (set! rsi -1803672217)
                                  (set! rdi bat.2.3)
                                  (set! r15 tmp-ra.8)
                                  (jump L.proc.1.2 rbp r15 rdi rsi rdx)))))
                    (define L.proc.1.2
                      ((new-frames ()))
                      (begin
                        (set! tmp-ra.9 r15)
                        (begin
                          (set! foo.3.6 rdi)
                          (set! ball.0.5 rsi)
                          (set! bat.1.4 rdx)
                          (begin
                            (set! rdx bat.1.4)
                            (set! rsi ball.0.5)
                            (set! rdi 1)
                            (set! r15 tmp-ra.9)
                            (jump L.proc.1.2 rbp r15 rdi rsi rdx)))))
                    (begin
                      (set! tmp-ra.10 r15)
                      (begin
                        (set! bar.9.7 0)
                        (begin
                          (set! rax bar.9.7)
                          (jump tmp-ra.10 rbp rax))))))
(check-by-interp '(module ((new-frames ()))
                          (begin
                            (set! tmp-ra.6 r15)
                            (begin
                              (begin
                                (begin
                                  (begin
                                    (set! bat.2.5 1550347185)
                                    (set! ball.0.4 9223372036854775807)
                                    (set! foobar.7.3 -9223372036854775808)
                                    (set! bar.6.2 ball.0.4))
                                  (set! ball.0.1 bar.6.2))
                                (begin
                                  (set! rax (- 9223372036854775807 ball.0.1))
                                  (jump tmp-ra.6 rbp rax)))))
                    ))
(check-by-interp '(module ((new-frames ()))
                          (define L.proc.0.1
                            ((new-frames (() () () () ())))
                            (begin
                              (set! tmp-ra.14 r15)
                              (begin
                                (set! bar.6.3 rdi)
                                (set! bar.3.2 rsi)
                                (set! foo.1.1 rdx)
                                (begin
                                  (begin
                                    (return-point L.rp.2
                                                  (begin
                                                    (set! rdx foo.1.1)
                                                    (set! rsi foo.1.1)
                                                    (set! rdi 9223372036854775807)
                                                    (set! r15 L.rp.2)
                                                    (jump L.proc.0.1 rbp r15 rdi rsi rdx)))
                                    (set! bar.3.6 rax))
                                  (begin
                                    (return-point L.rp.3
                                                  (begin
                                                    (set! rdx bar.6.3)
                                                    (set! rsi foo.1.1)
                                                    (set! rdi bar.6.3)
                                                    (set! r15 L.rp.3)
                                                    (jump L.proc.0.1 rbp r15 rdi rsi rdx)))
                                    (set! ball.9.5 rax))
                                  (begin
                                    (begin
                                      (return-point L.rp.4
                                                    (begin
                                                      (set! rdx bar.6.3)
                                                      (set! rsi foo.1.1)
                                                      (set! rdi foo.1.1)
                                                      (set! r15 L.rp.4)
                                                      (jump L.proc.0.1 rbp r15 rdi rsi rdx)))
                                      (set! ball.2.9 rax))
                                    (set! ball.9.8 bar.3.2)
                                    (begin
                                      (return-point L.rp.5
                                                    (begin
                                                      (set! rdx bar.3.2)
                                                      (set! rsi foo.1.1)
                                                      (set! rdi foo.1.1)
                                                      (set! r15 L.rp.5)
                                                      (jump L.proc.0.1 rbp r15 rdi rsi rdx)))
                                      (set! foo.8.7 rax))
                                    (begin
                                      (return-point L.rp.6
                                                    (begin
                                                      (set! rdx ball.2.9)
                                                      (set! rsi foo.8.7)
                                                      (set! rdi foo.8.7)
                                                      (set! r15 L.rp.6)
                                                      (jump L.proc.0.1 rbp r15 rdi rsi rdx)))
                                      (set! bar.6.4 rax)))
                                  (if (> bar.6.4 foo.1.1)
                                      (if (>= bar.3.6 bar.3.6)
                                          (begin
                                            (set! rax foo.1.1)
                                            (jump tmp-ra.14 rbp rax))
                                          (begin
                                            (set! rax bar.6.4)
                                            (jump tmp-ra.14 rbp rax)))
                                      (begin
                                        (set! ball.4.11 -2087609688)
                                        (set! foo.8.10 bar.3.6)
                                        (begin
                                          (set! rax ball.9.5)
                                          (jump tmp-ra.14 rbp rax))))))))
                    (begin
                      (set! tmp-ra.15 r15)
                      (begin
                        (set! ball.9.13 1)
                        (set! foo.1.12 -9223372036854775808)
                        (begin
                          (set! rax foo.1.12)
                          (jump tmp-ra.15 rbp rax))))))
(check-by-interp '(module ((new-frames ()))
                          (define L.fn.0.1
                            ((new-frames ()))
                            (begin
                              (set! tmp-ra.17 r15)
                              (begin
                                (set! bar.0.1 rdi)
                                (if (true)
                                    (begin
                                      (set! rcx 2099518136)
                                      (set! rdx bar.0.1)
                                      (set! rsi bar.0.1)
                                      (set! rdi bar.0.1)
                                      (set! r15 tmp-ra.17)
                                      (jump L.func.2.3 rbp r15 rdi rsi rdx rcx))
                                    (begin
                                      (set! rcx bar.0.1)
                                      (set! rdx bar.0.1)
                                      (set! rsi bar.0.1)
                                      (set! rdi bar.0.1)
                                      (set! r15 tmp-ra.17)
                                      (jump L.func.2.3 rbp r15 rdi rsi rdx rcx))))))
                    (define L.tmp.1.2
                      ((new-frames ()))
                      (begin
                        (set! tmp-ra.18 r15)
                        (begin
                          (set! foobar.6.7 rdi)
                          (set! foobar.3.6 rsi)
                          (set! foo.5.5 rdx)
                          (set! bar.2.4 rcx)
                          (set! ball.8.3 r8)
                          (set! bar.0.2 r9)
                          (begin
                            (set! bar.0.10 9223372036854775807)
                            (set! foo.5.9 (+ foo.5.5 foobar.3.6))
                            (begin
                              (set! ball.1.11 (+ bar.2.4 foobar.3.6))
                              (set! foobar.6.8 foobar.3.6))
                            (begin
                              (set! rdi 0)
                              (set! r15 tmp-ra.18)
                              (jump L.fn.0.1 rbp r15 rdi))))))
                    (define L.func.2.3
                      ((new-frames ()))
                      (begin
                        (set! tmp-ra.19 r15)
                        (begin
                          (set! ball.9.15 rdi)
                          (set! ball.8.14 rsi)
                          (set! bar.0.13 rdx)
                          (set! foobar.6.12 rcx)
                          (begin
                            (set! r9 9223372036854775807)
                            (set! r8 bar.0.13)
                            (set! rcx ball.9.15)
                            (set! rdx foobar.6.12)
                            (set! rsi foobar.6.12)
                            (set! rdi 1)
                            (set! r15 tmp-ra.19)
                            (jump L.tmp.1.2 rbp r15 rdi rsi rdx rcx r8 r9)))))
                    (begin
                      (set! tmp-ra.20 r15)
                      (begin
                        (set! bat.4.16 (+ 1 9223372036854775807))
                        (begin
                          (set! rax bat.4.16)
                          (jump tmp-ra.20 rbp rax))))))
(check-by-interp '(module ((new-frames ()))
                          (begin
                            (set! tmp-ra.3 r15)
                            (begin
                              (set! foobar.1.2 0)
                              (set! bat.0.1 1)
                              (begin
                                (set! rax bat.0.1)
                                (jump tmp-ra.3 rbp rax))))
                    ))
(check-by-interp '(module ((new-frames ()))
                          (define L.func.0.1
                            ((new-frames ()))
                            (begin
                              (set! tmp-ra.7 r15)
                              (begin
                                (begin
                                  (set! r9 0)
                                  (set! r8 1)
                                  (set! rcx 9223372036854775807)
                                  (set! rdx 9223372036854775807)
                                  (set! rsi 1)
                                  (set! rdi 38797657)
                                  (set! r15 tmp-ra.7)
                                  (jump L.x.1.2 rbp r15 rdi rsi rdx rcx r8 r9)))))
                    (define L.x.1.2
                      ((new-frames ()))
                      (begin
                        (set! tmp-ra.8 r15)
                        (begin
                          (set! bat.7.6 rdi)
                          (set! ball.5.5 rsi)
                          (set! bat.3.4 rdx)
                          (set! bar.2.3 rcx)
                          (set! foobar.1.2 r8)
                          (set! bat.9.1 r9)
                          (if (true)
                              (if (if (>= foobar.1.2 foobar.1.2)
                                      (< bat.7.6 bar.2.3)
                                      (< bat.9.1 812242710))
                                  (begin
                                    (set! rax (- foobar.1.2 bar.2.3))
                                    (jump tmp-ra.8 rbp rax))
                                  (begin
                                    (set! r15 tmp-ra.8)
                                    (jump L.func.0.1 rbp r15)))
                              (begin
                                (set! r9 bar.2.3)
                                (set! r8 bat.9.1)
                                (set! rcx bat.9.1)
                                (set! rdx bar.2.3)
                                (set! rsi foobar.1.2)
                                (set! rdi bat.3.4)
                                (set! r15 tmp-ra.8)
                                (jump L.x.1.2 rbp r15 rdi rsi rdx rcx r8 r9))))))
                    (begin
                      (set! tmp-ra.9 r15)
                      (begin
                        (set! r9 -9223372036854775808)
                        (set! r8 0)
                        (set! rcx -9223372036854775808)
                        (set! rdx -9223372036854775808)
                        (set! rsi -2062025435)
                        (set! rdi 0)
                        (set! r15 tmp-ra.9)
                        (jump L.x.1.2 rbp r15 rdi rsi rdx rcx r8 r9)))))
(check-by-interp '(module ((new-frames ()))
                          (define L.func.0.1
                            ((new-frames ()))
                            (begin
                              (set! tmp-ra.8 r15)
                              (begin
                                (set! foo.4.4 rdi)
                                (set! foo.7.3 rsi)
                                (set! foo.3.2 rdx)
                                (set! foo.9.1 rcx)
                                (begin
                                  (set! rdx foo.3.2)
                                  (set! rsi -9223372036854775808)
                                  (set! rdi foo.4.4)
                                  (set! r15 tmp-ra.8)
                                  (jump L.proc.1.2 rbp r15 rdi rsi rdx)))))
                    (define L.proc.1.2
                      ((new-frames ()))
                      (begin
                        (set! tmp-ra.9 r15)
                        (begin
                          (set! foo.9.7 rdi)
                          (set! bat.5.6 rsi)
                          (set! foo.7.5 rdx)
                          (begin
                            (set! rax (- bat.5.6 foo.7.5))
                            (jump tmp-ra.9 rbp rax)))))
                    (begin
                      (set! tmp-ra.10 r15)
                      (begin
                        (begin
                          (set! rax 1)
                          (jump tmp-ra.10 rbp rax))))))
(check-by-interp '(module ((new-frames ()))
                          (begin
                            (set! tmp-ra.3 r15)
                            (begin
                              (set! ball.3.2 -550916464)
                              (set! foobar.9.1 9223372036854775807)
                              (begin
                                (set! rax foobar.9.1)
                                (jump tmp-ra.3 rbp rax))))
                    ))
(check-by-interp '(module ((new-frames ()))
                          (begin
                            (set! tmp-ra.2 r15)
                            (if (false)
                                (if (if (< 9223372036854775807 1646335033)
                                        (>= 9223372036854775807 1)
                                        (!= 9223372036854775807 1))
                                    (if (!= -9223372036854775808 -9223372036854775808)
                                        (begin
                                          (set! rax -9223372036854775808)
                                          (jump tmp-ra.2 rbp rax))
                                        (begin
                                          (set! rax 1282320164)
                                          (jump tmp-ra.2 rbp rax)))
                                    (begin
                                      (set! bar.1.1 -9223372036854775808)
                                      (begin
                                        (set! rax bar.1.1)
                                        (jump tmp-ra.2 rbp rax))))
                                (begin
                                  (set! rax (- 9223372036854775807 1))
                                  (jump tmp-ra.2 rbp rax))))
                    ))
(check-by-interp '(module ((new-frames ()))
                          (define L.tmp.0.1
                            ((new-frames (() ())))
                            (begin
                              (set! tmp-ra.15 r15)
                              (begin
                                (set! bar.1.4 rdi)
                                (set! bat.6.3 rsi)
                                (set! ball.4.2 rdx)
                                (set! bar.0.1 rcx)
                                (begin
                                  (begin
                                    (return-point L.rp.3
                                                  (begin
                                                    (set! rcx bar.1.4)
                                                    (set! rdx bar.0.1)
                                                    (set! rsi bat.6.3)
                                                    (set! rdi bat.6.3)
                                                    (set! r15 L.rp.3)
                                                    (jump L.tmp.0.1 rbp r15 rdi rsi rdx rcx)))
                                    (set! ball.7.6 rax))
                                  (begin
                                    (set! ball.4.5 (- bat.6.3 bar.0.1)))
                                  (begin
                                    (begin
                                      (set! foobar.2.11 bat.6.3)
                                      (set! bar.1.10 1)
                                      (set! foobar.8.9 bar.0.1))
                                    (set! bar.0.8 bar.1.4)
                                    (begin
                                      (return-point L.rp.4
                                                    (begin
                                                      (set! rdx bar.1.4)
                                                      (set! rsi 9223372036854775807)
                                                      (set! rdi bar.0.1)
                                                      (set! r15 L.rp.4)
                                                      (jump L.x.1.2 rbp r15 rdi rsi rdx)))
                                      (set! foobar.2.7 rax))
                                    (begin
                                      (set! rdx bat.6.3)
                                      (set! rsi bat.6.3)
                                      (set! rdi -9223372036854775808)
                                      (set! r15 tmp-ra.15)
                                      (jump L.x.1.2 rbp r15 rdi rsi rdx)))))))
                    (define L.x.1.2
                      ((new-frames ()))
                      (begin
                        (set! tmp-ra.16 r15)
                        (begin
                          (set! bar.3.14 rdi)
                          (set! foobar.8.13 rsi)
                          (set! bat.6.12 rdx)
                          (if (false)
                              (begin
                                (set! rdx foobar.8.13)
                                (set! rsi bat.6.12)
                                (set! rdi 9223372036854775807)
                                (set! r15 tmp-ra.16)
                                (jump L.x.1.2 rbp r15 rdi rsi rdx))
                              (if (false)
                                  (begin
                                    (set! rcx bar.3.14)
                                    (set! rdx foobar.8.13)
                                    (set! rsi bar.3.14)
                                    (set! rdi foobar.8.13)
                                    (set! r15 tmp-ra.16)
                                    (jump L.tmp.0.1 rbp r15 rdi rsi rdx rcx))
                                  (begin
                                    (set! rdx bat.6.12)
                                    (set! rsi 580696126)
                                    (set! rdi bat.6.12)
                                    (set! r15 tmp-ra.16)
                                    (jump L.x.1.2 rbp r15 rdi rsi rdx)))))))
                    (begin
                      (set! tmp-ra.17 r15)
                      (if (<= 9223372036854775807 9223372036854775807)
                          (begin
                            (set! rax -1677147892)
                            (jump tmp-ra.17 rbp rax))
                          (begin
                            (set! rax 874915829)
                            (jump tmp-ra.17 rbp rax))))))
(check-by-interp
 '(module ((new-frames ()))
          (define L.proc.0.1
            ((new-frames (() (nfv.26))))
            (begin
              (set! tmp-ra.25 r15)
              (begin
                (set! foo.2.7 rdi)
                (set! foo.1.6 rsi)
                (set! ball.4.5 rdx)
                (set! ball.7.4 rcx)
                (set! foobar.3.3 r8)
                (set! ball.0.2 r9)
                (set! foo.6.1 fv0)
                (if (not (> foo.6.1 -727829088))
                    (begin
                      (set! ball.4.10 foo.2.7)
                      (begin
                        (return-point L.rp.4
                                      (begin
                                        (set! nfv.26 foo.2.7)
                                        (set! r9 foo.2.7)
                                        (set! r8 ball.7.4)
                                        (set! rcx foo.1.6)
                                        (set! rdx ball.4.5)
                                        (set! rsi foobar.3.3)
                                        (set! rdi foo.1.6)
                                        (set! r15 L.rp.4)
                                        (jump L.proc.0.1 rbp r15 rdi rsi rdx rcx r8 r9 nfv.26)))
                        (set! ball.7.9 rax))
                      (begin
                        (return-point L.rp.5
                                      (begin
                                        (set! r9 foo.6.1)
                                        (set! r8 -9223372036854775808)
                                        (set! rcx foobar.3.3)
                                        (set! rdx 1)
                                        (set! rsi foo.2.7)
                                        (set! rdi ball.4.5)
                                        (set! r15 L.rp.5)
                                        (jump L.fn.1.2 rbp r15 rdi rsi rdx rcx r8 r9)))
                        (set! foo.2.8 rax))
                      (begin
                        (set! foo.2.11 foo.1.6)
                        (begin
                          (set! rax ball.0.2)
                          (jump tmp-ra.25 rbp rax))))
                    (begin
                      (begin
                        (set! rax -774243080)
                        (jump tmp-ra.25 rbp rax)))))))
    (define L.fn.1.2
      ((new-frames ()))
      (begin
        (set! tmp-ra.27 r15)
        (begin
          (set! foo.5.17 rdi)
          (set! ball.4.16 rsi)
          (set! foo.1.15 rdx)
          (set! ball.9.14 rcx)
          (set! foobar.3.13 r8)
          (set! ball.7.12 r9)
          (if (if (if (< foobar.3.13 foo.5.17)
                      (>= foo.5.17 ball.9.14)
                      (!= ball.4.16 ball.4.16))
                  (if (>= ball.7.12 ball.9.14)
                      (< foo.5.17 foo.5.17)
                      (>= foo.1.15 foobar.3.13))
                  (not (> ball.9.14 ball.7.12)))
              (begin
                (set! ball.9.18 (- -1548357748 foobar.3.13))
                (begin
                  (set! r9 ball.9.18)
                  (set! r8 foo.1.15)
                  (set! rcx ball.4.16)
                  (set! rdx foo.1.15)
                  (set! rsi 0)
                  (set! rdi ball.9.18)
                  (set! r15 tmp-ra.27)
                  (jump L.fn.1.2 rbp r15 rdi rsi rdx rcx r8 r9)))
              (begin
                (set! r9 foo.5.17)
                (set! r8 ball.7.12)
                (set! rcx ball.7.12)
                (set! rdx ball.4.16)
                (set! rsi foobar.3.13)
                (set! rdi ball.9.14)
                (set! r15 tmp-ra.27)
                (jump L.fn.2.3 rbp r15 rdi rsi rdx rcx r8 r9))))))
    (define L.fn.2.3
      ((new-frames ()))
      (begin
        (set! tmp-ra.28 r15)
        (begin
          (set! foobar.8.24 rdi)
          (set! foo.1.23 rsi)
          (set! foobar.3.22 rdx)
          (set! foo.2.21 rcx)
          (set! foo.6.20 r8)
          (set! ball.9.19 r9)
          (begin
            (set! r9 0)
            (set! r8 1)
            (set! rcx foo.6.20)
            (set! rdx foo.2.21)
            (set! rsi -9223372036854775808)
            (set! rdi foo.6.20)
            (set! r15 tmp-ra.28)
            (jump L.fn.2.3 rbp r15 rdi rsi rdx rcx r8 r9)))))
    (begin
      (set! tmp-ra.29 r15)
      (if (< -534391580 9223372036854775807)
          (begin
            (set! rax 0)
            (jump tmp-ra.29 rbp rax))
          (begin
            (set! rax 0)
            (jump tmp-ra.29 rbp rax))))))
(check-by-interp '(module ((new-frames ()))
                          (begin
                            (set! tmp-ra.4 r15)
                            (begin
                              (begin
                                (set! ball.7.3 -1762920629)
                                (set! ball.8.2 1)
                                (set! foobar.1.1 9223372036854775807)
                                (begin
                                  (set! rax 0)
                                  (jump tmp-ra.4 rbp rax)))))
                    ))
(check-by-interp '(module ((new-frames ()))
                          (define L.proc.0.1
                            ((new-frames ()))
                            (begin
                              (set! tmp-ra.7 r15)
                              (begin
                                (set! foobar.0.6 rdi)
                                (set! ball.2.5 rsi)
                                (set! ball.3.4 rdx)
                                (set! ball.5.3 rcx)
                                (set! bar.4.2 r8)
                                (set! foobar.8.1 r9)
                                (begin
                                  (set! r9 ball.2.5)
                                  (set! r8 ball.2.5)
                                  (set! rcx ball.5.3)
                                  (set! rdx foobar.0.6)
                                  (set! rsi 15882253)
                                  (set! rdi ball.2.5)
                                  (set! r15 tmp-ra.7)
                                  (jump L.proc.0.1 rbp r15 rdi rsi rdx rcx r8 r9)))))
                    (begin
                      (set! tmp-ra.8 r15)
                      (if (!= 1038395452 1)
                          (begin
                            (set! rax -9223372036854775808)
                            (jump tmp-ra.8 rbp rax))
                          (begin
                            (set! rax 717010255)
                            (jump tmp-ra.8 rbp rax))))))
(check-by-interp '(module ((new-frames ()))
                          (begin
                            (set! tmp-ra.4 r15)
                            (if (true)
                                (if (not (= 0 1))
                                    (if (>= -9223372036854775808 -1744096882)
                                        (begin
                                          (set! rax 0)
                                          (jump tmp-ra.4 rbp rax))
                                        (begin
                                          (set! rax 9223372036854775807)
                                          (jump tmp-ra.4 rbp rax)))
                                    (if (< -9223372036854775808 0)
                                        (begin
                                          (set! rax 1)
                                          (jump tmp-ra.4 rbp rax))
                                        (begin
                                          (set! rax 9223372036854775807)
                                          (jump tmp-ra.4 rbp rax))))
                                (if (false)
                                    (begin
                                      (set! foo.5.2 1032709229)
                                      (set! bat.6.1 1)
                                      (begin
                                        (set! rax foo.5.2)
                                        (jump tmp-ra.4 rbp rax)))
                                    (begin
                                      (set! bat.8.3 9223372036854775807)
                                      (begin
                                        (set! rax bat.8.3)
                                        (jump tmp-ra.4 rbp rax))))))
                    ))
(check-by-interp '(module ((new-frames ()))
                          (begin
                            (set! tmp-ra.1 r15)
                            (if (< 0 9223372036854775807)
                                (begin
                                  (set! rax 1620518798)
                                  (jump tmp-ra.1 rbp rax))
                                (if (!= 0 9223372036854775807)
                                    (begin
                                      (set! rax 0)
                                      (jump tmp-ra.1 rbp rax))
                                    (begin
                                      (set! rax -9223372036854775808)
                                      (jump tmp-ra.1 rbp rax)))))
                    ))
(check-by-interp '(module ((new-frames ()))
                          (define L.func.0.1
                            ((new-frames ()))
                            (begin
                              (set! tmp-ra.12 r15)
                              (begin
                                (set! foobar.2.2 rdi)
                                (set! ball.0.1 rsi)
                                (begin
                                  (set! rdx 9223372036854775807)
                                  (set! rsi foobar.2.2)
                                  (set! rdi foobar.2.2)
                                  (set! r15 tmp-ra.12)
                                  (jump L.tmp.1.2 rbp r15 rdi rsi rdx)))))
                    (define L.tmp.1.2
                      ((new-frames ()))
                      (begin
                        (set! tmp-ra.13 r15)
                        (begin
                          (set! ball.5.5 rdi)
                          (set! foobar.2.4 rsi)
                          (set! foo.6.3 rdx)
                          (if (false)
                              (begin
                                (set! r9 foo.6.3)
                                (set! r8 ball.5.5)
                                (set! rcx 0)
                                (set! rdx foobar.2.4)
                                (set! rsi foobar.2.4)
                                (set! rdi ball.5.5)
                                (set! r15 tmp-ra.13)
                                (jump L.tmp.2.3 rbp r15 rdi rsi rdx rcx r8 r9))
                              (begin
                                (set! rdx ball.5.5)
                                (set! rsi 9223372036854775807)
                                (set! rdi foobar.2.4)
                                (set! r15 tmp-ra.13)
                                (jump L.tmp.1.2 rbp r15 rdi rsi rdx))))))
                    (define L.tmp.2.3
                      ((new-frames ()))
                      (begin
                        (set! tmp-ra.14 r15)
                        (begin
                          (set! foobar.2.11 rdi)
                          (set! foo.6.10 rsi)
                          (set! foobar.7.9 rdx)
                          (set! ball.5.8 rcx)
                          (set! bar.1.7 r8)
                          (set! bat.9.6 r9)
                          (begin
                            (set! r9 foo.6.10)
                            (set! r8 bar.1.7)
                            (set! rcx foobar.2.11)
                            (set! rdx bar.1.7)
                            (set! rsi 1666412948)
                            (set! rdi 273235985)
                            (set! r15 tmp-ra.14)
                            (jump L.tmp.2.3 rbp r15 rdi rsi rdx rcx r8 r9)))))
                    (begin
                      (set! tmp-ra.15 r15)
                      (if (= -9223372036854775808 9223372036854775807)
                          (begin
                            (set! rax 9223372036854775807)
                            (jump tmp-ra.15 rbp rax))
                          (begin
                            (set! rax 1)
                            (jump tmp-ra.15 rbp rax))))))
(check-by-interp '(module ((new-frames ()))
                          (define L.fn.0.1
                            ((new-frames ()))
                            (begin
                              (set! tmp-ra.6 r15)
                              (begin
                                (set! ball.2.5 rdi)
                                (set! ball.4.4 rsi)
                                (set! ball.0.3 rdx)
                                (set! foo.1.2 rcx)
                                (set! foo.8.1 r8)
                                (begin
                                  (set! r8 ball.2.5)
                                  (set! rcx foo.1.2)
                                  (set! rdx ball.4.4)
                                  (set! rsi ball.2.5)
                                  (set! rdi foo.8.1)
                                  (set! r15 tmp-ra.6)
                                  (jump L.fn.0.1 rbp r15 rdi rsi rdx rcx r8)))))
                    (begin
                      (set! tmp-ra.7 r15)
                      (begin
                        (begin
                          (set! rax -167685894)
                          (jump tmp-ra.7 rbp rax))))))

;;; !!! good
(check-by-interp '(module ((new-frames ()))
                          (define L.func.0.1
                            ((new-frames ()))
                            (begin
                              (set! tmp-ra.20 r15)
                              (begin
                                (set! bar.0.2 rdi)
                                (set! foobar.8.1 rsi)
                                (begin
                                  (set! r9 foobar.8.1)
                                  (set! r8 foobar.8.1)
                                  (set! rcx bar.0.2)
                                  (set! rdx foobar.8.1)
                                  (set! rsi bar.0.2)
                                  (set! rdi foobar.8.1)
                                  (set! r15 tmp-ra.20)
                                  (jump L.fn.2.3 rbp r15 rdi rsi rdx rcx r8 r9)))))
                    (define L.fn.1.2
                      ((new-frames ()))
                      (begin
                        (set! tmp-ra.21 r15)
                        (begin
                          (set! foo.6.7 rdi)
                          (set! foobar.2.6 rsi)
                          (set! foobar.1.5 rdx)
                          (set! bat.3.4 rcx)
                          (set! foobar.5.3 r8)
                          (begin
                            (begin
                              (begin
                                (set! foobar.7.10 foobar.5.3))
                              (set! foobar.2.9 (- foobar.1.5 foobar.2.6))
                              (begin
                                (set! bar.0.13 foobar.7.10)
                                (set! bar.9.12 foobar.2.9)
                                (set! foobar.1.11 foobar.1.5)
                                (set! bar.0.8 bat.3.4)))
                            (begin
                              (set! r8 foobar.5.3)
                              (set! rcx bat.3.4)
                              (set! rdx foobar.5.3)
                              (set! rsi -9223372036854775808)
                              (set! rdi bat.3.4)
                              (set! r15 tmp-ra.21)
                              (jump L.fn.1.2 rbp r15 rdi rsi rdx rcx r8))))))
                    (define L.fn.2.3
                      ((new-frames ()))
                      (begin
                        (set! tmp-ra.22 r15)
                        (begin
                          (set! foobar.1.19 rdi)
                          (set! foobar.5.18 rsi)
                          (set! foobar.2.17 rdx)
                          (set! ball.4.16 rcx)
                          (set! foobar.8.15 r8)
                          (set! foobar.7.14 r9)
                          (begin
                            (set! rsi ball.4.16)
                            (set! rdi foobar.1.19)
                            (set! r15 tmp-ra.22)
                            (jump L.func.0.1 rbp r15 rdi rsi)))))
                    (begin
                      (set! tmp-ra.23 r15)
                      (begin
                        (set! rax (+ 1962527269 9223372036854775807))
                        (jump tmp-ra.23 rbp rax)))))
(check-by-interp '(module ((new-frames ()))
                          (define L.func.0.1
                            ((new-frames ()))
                            (begin
                              (set! tmp-ra.2 r15)
                              (begin
                                (set! bat.0.1 rdi)
                                (if (if (true)
                                        (not (> bat.0.1 bat.0.1))
                                        (>= 2020417677 -9223372036854775808))
                                    (if (true)
                                        (if (= bat.0.1 bat.0.1)
                                            (begin
                                              (set! rax bat.0.1)
                                              (jump tmp-ra.2 rbp rax))
                                            (begin
                                              (set! rax bat.0.1)
                                              (jump tmp-ra.2 rbp rax)))
                                        (begin
                                          (set! rdi bat.0.1)
                                          (set! r15 tmp-ra.2)
                                          (jump L.func.0.1 rbp r15 rdi)))
                                    (begin
                                      (set! rdi 9223372036854775807)
                                      (set! r15 tmp-ra.2)
                                      (jump L.func.0.1 rbp r15 rdi))))))
                    (begin
                      (set! tmp-ra.3 r15)
                      (begin
                        (set! rdi 733499244)
                        (set! r15 tmp-ra.3)
                        (jump L.func.0.1 rbp r15 rdi)))))
(check-by-interp '(module ((new-frames ()))
                          (define L.proc.0.1
                            ((new-frames ()))
                            (begin
                              (set! tmp-ra.22 r15)
                              (begin
                                (set! ball.3.4 rdi)
                                (set! foo.8.3 rsi)
                                (set! foobar.4.2 rdx)
                                (set! foobar.1.1 rcx)
                                (begin
                                  (set! r8 foo.8.3)
                                  (set! rcx 1)
                                  (set! rdx 0)
                                  (set! rsi -9223372036854775808)
                                  (set! rdi 835392363)
                                  (set! r15 tmp-ra.22)
                                  (jump L.fn.1.2 rbp r15 rdi rsi rdx rcx r8)))))
                    (define L.fn.1.2
                      ((new-frames ()))
                      (begin
                        (set! tmp-ra.23 r15)
                        (begin
                          (set! bat.0.9 rdi)
                          (set! foobar.7.8 rsi)
                          (set! bar.2.7 rdx)
                          (set! bat.6.6 rcx)
                          (set! foobar.4.5 r8)
                          (begin
                            (set! rdi foobar.7.8)
                            (set! r15 tmp-ra.23)
                            (jump L.x.2.3 rbp r15 rdi)))))
                    (define L.x.2.3
                      ((new-frames (())))
                      (begin
                        (set! tmp-ra.24 r15)
                        (begin
                          (set! foobar.7.10 rdi)
                          (begin
                            (begin
                              (begin
                                (return-point L.rp.4
                                              (begin
                                                (set! rcx foobar.7.10)
                                                (set! rdx foobar.7.10)
                                                (set! rsi foobar.7.10)
                                                (set! rdi foobar.7.10)
                                                (set! r15 L.rp.4)
                                                (jump L.proc.0.1 rbp r15 rdi rsi rdx rcx)))
                                (set! bat.0.12 rax))
                              (set! foo.9.11 (- bat.0.12 bat.0.12)))
                            (begin
                              (if (<= foo.9.11 foobar.7.10)
                                  (set! foo.9.15 foo.9.11)
                                  (set! foo.9.15 foobar.7.10))
                              (begin
                                (set! bat.0.18 foo.9.11)
                                (set! foobar.7.17 foobar.7.10)
                                (set! foobar.1.16 foo.9.11)
                                (set! foobar.7.14 bat.0.18))
                              (set! ball.3.13 foobar.7.10)
                              (begin
                                (set! rdi ball.3.13)
                                (set! r15 tmp-ra.24)
                                (jump L.x.2.3 rbp r15 rdi)))))))
                    (begin
                      (set! tmp-ra.25 r15)
                      (begin
                        (set! ball.3.21 1830309714)
                        (set! foo.8.20 -9223372036854775808)
                        (set! foobar.7.19 -9223372036854775808)
                        (begin
                          (set! rax ball.3.21)
                          (jump tmp-ra.25 rbp rax))))))
(check-by-interp '(module ((new-frames ()))
                          (define L.func.0.1
                            ((new-frames ()))
                            (begin
                              (set! tmp-ra.10 r15)
                              (begin
                                (set! foobar.0.5 rdi)
                                (set! foo.5.4 rsi)
                                (set! bat.6.3 rdx)
                                (set! bat.3.2 rcx)
                                (set! bar.7.1 r8)
                                (begin
                                  (set! rax bat.3.2)
                                  (jump tmp-ra.10 rbp rax)))))
                    (define L.func.1.2
                      ((new-frames (())))
                      (begin
                        (set! tmp-ra.11 r15)
                        (begin
                          (begin
                            (set! bat.2.8 (- -620373304 -68719063))
                            (set! bat.3.7 0)
                            (begin
                              (return-point L.rp.4
                                            (begin
                                              (set! r15 L.rp.4)
                                              (jump L.func.1.2 rbp r15)))
                              (set! foobar.4.6 rax))
                            (begin
                              (set! rax bat.3.7)
                              (jump tmp-ra.11 rbp rax))))))
                    (define L.x.2.3
                      ((new-frames ()))
                      (begin
                        (set! tmp-ra.12 r15)
                        (begin
                          (set! bar.8.9 rdi)
                          (begin
                            (set! r15 tmp-ra.12)
                            (jump L.func.1.2 rbp r15)))))
                    (begin
                      (set! tmp-ra.13 r15)
                      (begin
                        (set! rax -575594324)
                        (jump tmp-ra.13 rbp rax)))))
(check-by-interp '(module ((new-frames ()))
                          (define L.x.0.1
                            ((new-frames ()))
                            (begin
                              (set! tmp-ra.12 r15)
                              (begin
                                (set! foo.3.6 rdi)
                                (set! foobar.0.5 rsi)
                                (set! bat.2.4 rdx)
                                (set! bar.7.3 rcx)
                                (set! bar.5.2 r8)
                                (set! bat.6.1 r9)
                                (begin
                                  (set! rsi 1)
                                  (set! rdi bar.7.3)
                                  (set! r15 tmp-ra.12)
                                  (jump L.x.1.2 rbp r15 rdi rsi)))))
                    (define L.x.1.2
                      ((new-frames ()))
                      (begin
                        (set! tmp-ra.13 r15)
                        (begin
                          (set! foobar.4.8 rdi)
                          (set! foobar.0.7 rsi)
                          (if (<= foobar.0.7 -9223372036854775808)
                              (begin
                                (set! r9 foobar.4.8)
                                (set! r8 foobar.0.7)
                                (set! rcx foobar.0.7)
                                (set! rdx foobar.0.7)
                                (set! rsi foobar.4.8)
                                (set! rdi foobar.4.8)
                                (set! r15 tmp-ra.13)
                                (jump L.x.0.1 rbp r15 rdi rsi rdx rcx r8 r9))
                              (begin
                                (set! rax foobar.0.7)
                                (jump tmp-ra.13 rbp rax))))))
                    (begin
                      (set! tmp-ra.14 r15)
                      (if (not (= 0 -844906965))
                          (begin
                            (set! foo.3.11 996590913)
                            (set! bat.6.10 299367411)
                            (set! foobar.4.9 -9223372036854775808)
                            (begin
                              (set! rax foo.3.11)
                              (jump tmp-ra.14 rbp rax)))
                          (if (> 894536270 1910216157)
                              (begin
                                (set! rax 1)
                                (jump tmp-ra.14 rbp rax))
                              (begin
                                (set! rax 1)
                                (jump tmp-ra.14 rbp rax)))))))
(check-by-interp '(module ((new-frames ()))
                          (define L.tmp.0.1
                            ((new-frames ()))
                            (begin
                              (set! tmp-ra.19 r15)
                              (begin
                                (set! bat.6.5 rdi)
                                (set! bat.2.4 rsi)
                                (set! foobar.8.3 rdx)
                                (set! bar.3.2 rcx)
                                (set! foo.1.1 r8)
                                (if (<= bat.2.4 9223372036854775807)
                                    (if (true)
                                        (begin
                                          (set! fv0 bar.3.2)
                                          (set! r9 -9223372036854775808)
                                          (set! r8 1)
                                          (set! rcx foobar.8.3)
                                          (set! rdx bat.6.5)
                                          (set! rsi foobar.8.3)
                                          (set! rdi bar.3.2)
                                          (set! r15 tmp-ra.19)
                                          (jump L.tmp.1.2 rbp r15 rdi rsi rdx rcx r8 r9 fv0))
                                        (begin
                                          (set! fv0 bat.6.5)
                                          (set! r9 foo.1.1)
                                          (set! r8 bar.3.2)
                                          (set! rcx bar.3.2)
                                          (set! rdx bat.2.4)
                                          (set! rsi foobar.8.3)
                                          (set! rdi bat.2.4)
                                          (set! r15 tmp-ra.19)
                                          (jump L.tmp.1.2 rbp r15 rdi rsi rdx rcx r8 r9 fv0)))
                                    (begin
                                      (set! bar.3.7 foo.1.1)
                                      (begin
                                        (set! bar.4.6 bat.6.5))
                                      (begin
                                        (set! bat.2.8 foobar.8.3)
                                        (begin
                                          (set! rax bat.2.8)
                                          (jump tmp-ra.19 rbp rax))))))))
                    (define L.tmp.1.2
                      ((new-frames (() () ())))
                      (begin
                        (set! tmp-ra.20 r15)
                        (begin
                          (set! bar.3.15 rdi)
                          (set! foo.1.14 rsi)
                          (set! foobar.8.13 rdx)
                          (set! bat.0.12 rcx)
                          (set! bat.2.11 r8)
                          (set! foobar.7.10 r9)
                          (set! bat.6.9 fv0)
                          (begin
                            (if (not (> 1242010444 foobar.8.13))
                                (begin
                                  (return-point L.rp.3
                                                (begin
                                                  (set! r8 foobar.7.10)
                                                  (set! rcx 1)
                                                  (set! rdx bat.0.12)
                                                  (set! rsi foobar.7.10)
                                                  (set! rdi bat.2.11)
                                                  (set! r15 L.rp.3)
                                                  (jump L.tmp.0.1 rbp r15 rdi rsi rdx rcx r8)))
                                  (set! foobar.8.18 rax))
                                (begin
                                  (return-point L.rp.4
                                                (begin
                                                  (set! r8 bat.0.12)
                                                  (set! rcx bat.0.12)
                                                  (set! rdx foo.1.14)
                                                  (set! rsi foobar.8.13)
                                                  (set! rdi foobar.8.13)
                                                  (set! r15 L.rp.4)
                                                  (jump L.tmp.0.1 rbp r15 rdi rsi rdx rcx r8)))
                                  (set! foobar.8.18 rax)))
                            (set! bat.0.17 (* bat.6.9 foo.1.14))
                            (begin
                              (return-point L.rp.5
                                            (begin
                                              (set! r8 bat.2.11)
                                              (set! rcx bat.2.11)
                                              (set! rdx 0)
                                              (set! rsi foo.1.14)
                                              (set! rdi foo.1.14)
                                              (set! r15 L.rp.5)
                                              (jump L.tmp.0.1 rbp r15 rdi rsi rdx rcx r8)))
                              (set! bar.3.16 rax))
                            (begin
                              (set! fv0 foobar.7.10)
                              (set! r9 foobar.8.18)
                              (set! r8 bat.6.9)
                              (set! rcx bar.3.16)
                              (set! rdx 1)
                              (set! rsi foo.1.14)
                              (set! rdi foobar.7.10)
                              (set! r15 tmp-ra.20)
                              (jump L.tmp.1.2 rbp r15 rdi rsi rdx rcx r8 r9 fv0))))))
                    (begin
                      (set! tmp-ra.21 r15)
                      (if (not (< 1973720366 1864083813))
                          (begin
                            (set! rax 9223372036854775807)
                            (jump tmp-ra.21 rbp rax))
                          (begin
                            (set! fv0 379193781)
                            (set! r9 726597669)
                            (set! r8 -264137160)
                            (set! rcx -1022801227)
                            (set! rdx 501537014)
                            (set! rsi 9223372036854775807)
                            (set! rdi 9223372036854775807)
                            (set! r15 tmp-ra.21)
                            (jump L.tmp.1.2 rbp r15 rdi rsi rdx rcx r8 r9 fv0))))))
(check-by-interp '(module ((new-frames ()))
                          (begin
                            (set! tmp-ra.4 r15)
                            (begin
                              (set! ball.8.3 1521957632)
                              (begin
                                (set! bat.6.2 -9223372036854775808))
                              (set! foo.5.1 -9223372036854775808)
                              (if (false)
                                  (if (!= bat.6.2 bat.6.2)
                                      (begin
                                        (set! rax foo.5.1)
                                        (jump tmp-ra.4 rbp rax))
                                      (begin
                                        (set! rax bat.6.2)
                                        (jump tmp-ra.4 rbp rax)))
                                  (if (> ball.8.3 -755834168)
                                      (begin
                                        (set! rax 0)
                                        (jump tmp-ra.4 rbp rax))
                                      (begin
                                        (set! rax bat.6.2)
                                        (jump tmp-ra.4 rbp rax))))))
                    ))
(check-by-interp '(module ((new-frames ()))
                          (begin
                            (set! tmp-ra.9 r15)
                            (begin
                              (set! ball.1.1 -9223372036854775808)
                              (begin
                                (begin
                                  (set! foobar.8.7 0)
                                  (set! bar.7.6 ball.1.1)
                                  (set! ball.9.5 ball.1.1)
                                  (set! bar.0.4 ball.9.5))
                                (set! foo.3.3 ball.1.1)
                                (if (> ball.1.1 ball.1.1)
                                    (set! foo.4.2 ball.1.1)
                                    (set! foo.4.2 ball.1.1))
                                (begin
                                  (set! ball.9.8 bar.0.4)
                                  (begin
                                    (set! rax ball.1.1)
                                    (jump tmp-ra.9 rbp rax))))))
                    ))
(check-by-interp '(module ((new-frames ()))
                          (begin
                            (set! tmp-ra.12 r15)
                            (begin
                              (set! foo.7.1 1)
                              (begin
                                (if (= foo.7.1 foo.7.1)
                                    (begin
                                      (set! foo.8.7 foo.7.1)
                                      (set! foobar.5.6 foo.7.1)
                                      (set! foo.4.5 foo.7.1)
                                      (set! foobar.3.4 foo.7.1))
                                    (begin
                                      (set! foo.4.9 foo.7.1)
                                      (set! foobar.1.8 foo.7.1)
                                      (set! foobar.3.4 foo.7.1)))
                                (set! foo.8.3 foo.7.1)
                                (set! foobar.1.2 (+ foo.7.1 foo.7.1))
                                (begin
                                  (begin
                                    (set! foobar.3.11 foobar.3.4)
                                    (set! foobar.1.10 1648274049)
                                    (begin
                                      (set! rax foo.7.1)
                                      (jump tmp-ra.12 rbp rax)))))))
                    ))
(check-by-interp '(module ((new-frames ()))
                          (define L.func.0.1
                            ((new-frames ()))
                            (begin
                              (set! tmp-ra.3 r15)
                              (begin
                                (set! bat.7.2 rdi)
                                (set! bat.8.1 rsi)
                                (begin
                                  (set! rsi bat.8.1)
                                  (set! rdi 1)
                                  (set! r15 tmp-ra.3)
                                  (jump L.func.0.1 rbp r15 rdi rsi)))))
                    (begin
                      (set! tmp-ra.4 r15)
                      (begin
                        (set! rax 0)
                        (jump tmp-ra.4 rbp rax)))))
(check-by-interp '(module ((new-frames ()))
                          (begin
                            (set! tmp-ra.1 r15)
                            (if (> -9223372036854775808 526950868)
                                (begin
                                  (set! rax -9223372036854775808)
                                  (jump tmp-ra.1 rbp rax))
                                (begin
                                  (set! rax 9223372036854775807)
                                  (jump tmp-ra.1 rbp rax))))
                    ))
(check-by-interp '(module ((new-frames ()))
                          (define L.fn.0.1
                            ((new-frames ()))
                            (begin
                              (set! tmp-ra.16 r15)
                              (begin
                                (set! foobar.6.5 rdi)
                                (set! ball.3.4 rsi)
                                (set! ball.9.3 rdx)
                                (set! bar.7.2 rcx)
                                (set! bat.4.1 r8)
                                (begin
                                  (set! r9 ball.3.4)
                                  (set! r8 bar.7.2)
                                  (set! rcx bat.4.1)
                                  (set! rdx 1064830001)
                                  (set! rsi ball.3.4)
                                  (set! rdi bat.4.1)
                                  (set! r15 tmp-ra.16)
                                  (jump L.func.1.2 rbp r15 rdi rsi rdx rcx r8 r9)))))
                    (define L.func.1.2
                      ((new-frames ()))
                      (begin
                        (set! tmp-ra.17 r15)
                        (begin
                          (set! ball.1.11 rdi)
                          (set! bat.4.10 rsi)
                          (set! foo.5.9 rdx)
                          (set! ball.9.8 rcx)
                          (set! foo.8.7 r8)
                          (set! ball.3.6 r9)
                          (if (if (if (< foo.8.7 foo.8.7)
                                      (= ball.1.11 ball.1.11)
                                      (!= bat.4.10 foo.8.7))
                                  (= ball.3.6 0)
                                  (if (> 0 ball.3.6)
                                      (<= 1 ball.9.8)
                                      (>= 529266316 foo.8.7)))
                              (if (begin
                                    (set! bat.4.12 foo.5.9)
                                    (<= ball.9.8 bat.4.12))
                                  (begin
                                    (set! foo.8.13 ball.3.6)
                                    (begin
                                      (set! rax ball.3.6)
                                      (jump tmp-ra.17 rbp rax)))
                                  (begin
                                    (set! r9 ball.3.6)
                                    (set! r8 foo.5.9)
                                    (set! rcx bat.4.10)
                                    (set! rdx bat.4.10)
                                    (set! rsi ball.1.11)
                                    (set! rdi foo.5.9)
                                    (set! r15 tmp-ra.17)
                                    (jump L.func.1.2 rbp r15 rdi rsi rdx rcx r8 r9)))
                              (begin
                                (begin
                                  (set! ball.3.15 foo.5.9)
                                  (set! ball.1.14 ball.3.15))
                                (begin
                                  (set! r9 foo.5.9)
                                  (set! r8 ball.1.14)
                                  (set! rcx foo.5.9)
                                  (set! rdx ball.3.6)
                                  (set! rsi ball.3.6)
                                  (set! rdi ball.1.14)
                                  (set! r15 tmp-ra.17)
                                  (jump L.func.1.2 rbp r15 rdi rsi rdx rcx r8 r9)))))))
                    (begin
                      (set! tmp-ra.18 r15)
                      (begin
                        (set! r9 0)
                        (set! r8 0)
                        (set! rcx 1)
                        (set! rdx 1)
                        (set! rsi -1337458253)
                        (set! rdi 9223372036854775807)
                        (set! r15 tmp-ra.18)
                        (jump L.func.1.2 rbp r15 rdi rsi rdx rcx r8 r9)))))
(check-by-interp '(module ((new-frames ()))
                          (begin
                            (set! tmp-ra.5 r15)
                            (if (if (!= 9223372036854775807 2124101395)
                                    (true)
                                    (not (<= 9223372036854775807 0)))
                                (begin
                                  (begin
                                    (set! bat.2.3 -9223372036854775808)
                                    (set! bat.2.2 -9223372036854775808))
                                  (set! bar.8.1 (* 9223372036854775807 -9223372036854775808))
                                  (begin
                                    (set! rax bat.2.2)
                                    (jump tmp-ra.5 rbp rax)))
                                (begin
                                  (set! bar.9.4 (+ 1865158198 1))
                                  (if (> bar.9.4 bar.9.4)
                                      (begin
                                        (set! rax bar.9.4)
                                        (jump tmp-ra.5 rbp rax))
                                      (begin
                                        (set! rax bar.9.4)
                                        (jump tmp-ra.5 rbp rax))))))
                    ))
(check-by-interp '(module ((new-frames ()))
                          (begin
                            (set! tmp-ra.1 r15)
                            (if (>= 1069510162 -9223372036854775808)
                                (begin
                                  (set! rax 1)
                                  (jump tmp-ra.1 rbp rax))
                                (begin
                                  (set! rax 323863587)
                                  (jump tmp-ra.1 rbp rax))))
                    ))
(check-by-interp '(module ((new-frames ()))
                          (begin
                            (set! tmp-ra.1 r15)
                            (begin
                              (set! rax (* 379335310 0))
                              (jump tmp-ra.1 rbp rax)))
                    ))
(check-by-interp '(module ((new-frames ()))
                          (begin
                            (set! tmp-ra.1 r15)
                            (begin
                              (set! rax 0)
                              (jump tmp-ra.1 rbp rax)))
                    ))
(check-by-interp '(module ((new-frames ()))
                          (begin
                            (set! tmp-ra.6 r15)
                            (begin
                              (set! bat.2.2 (- -9223372036854775808 0))
                              (set! bat.0.1 -9223372036854775808)
                              (begin
                                (set! ball.3.5 1969620648)
                                (set! foo.5.4 bat.2.2)
                                (set! bat.0.3 bat.0.1)
                                (begin
                                  (set! rax foo.5.4)
                                  (jump tmp-ra.6 rbp rax)))))
                    ))

;;;; !!!! good

; custom select-instructions test
; This test carries on to the v4 tests
;; Begins are not flattened like in the interrogator, we have a seperate pass to flatten.
