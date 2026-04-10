#lang racket
(require rackunit
         cpsc411/langs/v6
         cpsc411/compiler-lib
         "../sequentialize-let.rkt")

(define (check-input p)
  (if (values-unique-lang-v6? p)
      p
      (error
       (~a (pretty-format p) "\n is not a semantically valid " "values-unique-lang-v6" " program"))))

(define (check-output p)
  (if (imp-mf-lang-v6? p)
      p
      (error (~a (pretty-format p) "\n is not a semantically valid " "imp-mf-lang-v6" " program"))))

(define-syntax-rule (check-by-interp p)
  (check-equal? (interp-imp-mf-lang-v6 (check-output (sequentialize-let p)))
                (interp-values-unique-lang-v6 (check-input p))))

;; M6 tests; Added by Trevor on March 6th 2026, at most one binding per let
(check-by-interp '(module (let ([foobar.3.1 (let ([bat.9.2 -422317085]) bat.9.2)])
                            (let ([ball.2.3 foobar.3.1]) foobar.3.1))))
(check-by-interp '(module (define L.func.0.1
                            (lambda (ball.3.5 ball.4.4 bat.0.3 bat.5.2 foobar.2.1)
                              9223372036854775807))
                          (define L.proc.1.2
                            (lambda (bat.0.7 bar.7.6)
                              (let ([bar.7.8 bat.0.7])
                                (let ([ball.8.9 (call L.proc.1.2 bar.7.8 bar.7.8)])
                                  (if (= -59730991 bat.0.7) 0 bar.7.8)))))
                    (let ([foobar.9.10 (if (false)
                                           9223372036854775807
                                           (* 1 -9223372036854775808))])
                      (if (not (> foobar.9.10 foobar.9.10))
                          (let ([ball.6.11 foobar.9.10]) -1510146984)
                          (call L.proc.1.2 -9223372036854775808 foobar.9.10)))))
(check-by-interp '(module (let ([bat.9.1 (if (let ([bat.8.2 -1418594624]) (false))
                                             (let ([bat.9.3 (if (> -1123833745 1) 1 0)])
                                               (let ([bat.9.4 767736686]) bat.9.4))
                                             (if (true)
                                                 (let ([bat.3.5 1942655457]) bat.3.5)
                                                 (+ -9223372036854775808 1)))])
                            (- bat.9.1 bat.9.1))))
(check-by-interp
 '(module (define L.func.0.1
            (lambda (foobar.8.5 foobar.9.4 bat.2.3 foo.7.2 bat.0.1)
              (let ([foo.3.6
                     (call L.func.0.1 -1343541856 -9223372036854775808 foobar.9.4 foo.7.2 bat.0.1)])
                (if (!= 0 9223372036854775807)
                    (if (= 1346978436 bat.0.1) 0 bat.0.1)
                    (call L.func.0.1 -1402588641 bat.0.1 1 9223372036854775807 foo.7.2)))))
          (let ([foobar.5.7 (if (< 824269768 9223372036854775807) -9223372036854775808 709343632)])
            foobar.5.7)
    ))
(check-by-interp '(module (let ([foo.6.1 -356902212]) (+ -979281755 9223372036854775807))))
(check-by-interp '(module (define L.tmp.0.1
                            (lambda (ball.6.3 foobar.9.2 foo.5.1)
                              (call L.tmp.0.1 0 182548382 foo.5.1)))
                          (if (= 1 -444572554) -9223372036854775808 0)
                    ))
(check-by-interp
 '(module (define L.x.0.1
            (lambda (ball.3.5 bar.7.4 bat.6.3 ball.4.2 bat.5.1)
              (if (not (<= bat.6.3 9223372036854775807))
                  (let ([foobar.9.6 (let ([bat.6.7 -18835826]) bat.6.7)])
                    (if (>= bat.6.3 ball.4.2) bat.6.3 bar.7.4))
                  (let ([bat.5.8 (call L.x.0.1 bat.5.1 9223372036854775807 bat.6.3 bat.5.1 0)])
                    (if (<= bar.7.4 -186024487) bat.5.8 bat.6.3)))))
          (define L.func.1.2
            (lambda (bar.8.10 ball.4.9)
              (let ([bar.7.11 -932453002])
                (let ([foobar.9.12 (if (>= -1133252869 9223372036854775807) 479665611 bar.8.10)])
                  (let ([bat.5.13 bar.7.11]) bar.7.11)))))
    (if (>= 1588211020 1) 9223372036854775807 -9223372036854775808)))
(check-by-interp '(module (if (>= 1 -9223372036854775808) 234292566 -1579825632)))
(check-by-interp '(module 1))
(check-by-interp '(module (define L.fn.0.1
                            (lambda (ball.9.2 bat.0.1) (let ([foobar.4.3 ball.9.2]) (* 0 0))))
                          (define L.fn.1.2
                            (lambda ()
                              (if (>= -9223372036854775808 9223372036854775807)
                                  -1098447432
                                  (let ([ball.9.4 (+ -9223372036854775808 -9223372036854775808)])
                                    (if (< 857729561 9223372036854775807) 9223372036854775807 1)))))
                    (define L.fn.2.3
                      (lambda (bat.5.11 bat.0.10 ball.9.9 foobar.4.8 bar.7.7 bat.3.6 bar.2.5)
                        (if (not (true))
                            (let ([bar.2.12 (if (>= foobar.4.8 -9223372036854775808) 1 1)])
                              (call L.fn.0.1 bat.0.10 bar.2.12))
                            (if (true)
                                (* bat.3.6 foobar.4.8)
                                (let ([bat.6.13 bat.5.11]) 674342291)))))
                    (if (let ([bat.0.14 (let ([bar.2.15 (let ([bar.2.16 1]) -9223372036854775808)])
                                          (let ([foobar.8.17 bar.2.15]) 9223372036854775807))])
                          (if (true)
                              (if (= bat.0.14 bat.0.14)
                                  (>= -1195644570 bat.0.14)
                                  (= bat.0.14 bat.0.14))
                              (if (> bat.0.14 bat.0.14)
                                  (>= bat.0.14 bat.0.14)
                                  (= 0 bat.0.14))))
                        (call L.fn.2.3 1453047515 -1663007716 0 0 -2036437657 9223372036854775807 0)
                        (call L.fn.0.1 1 -1792916675))))
(check-by-interp
 '(module (let ([bat.4.1
                 (if (> -9223372036854775808 9223372036854775807)
                     (let ([bar.5.2 (if (!= 1 9223372036854775807) 9223372036854775807 463110926)]) 0)
                     (let ([bar.3.3 0]) (- -1584028825 -9223372036854775808)))])
            (if (not (> bat.4.1 1))
                (if (let ([ball.6.4 -9223372036854775808]) (>= ball.6.4 ball.6.4))
                    (if (> bat.4.1 491128034) bat.4.1 1)
                    (if (= 1050399943 bat.4.1) -1604958676 bat.4.1))
                bat.4.1))))
(check-by-interp
 '(module (define L.proc.0.1
            (lambda (foo.8.4 bat.5.3 foo.6.2 bar.0.1)
              (call L.func.1.2 9223372036854775807 bar.0.1 bat.5.3 9223372036854775807 foo.6.2)))
          (define L.func.1.2
            (lambda (bat.3.9 foo.8.8 bar.0.7 foo.9.6 bat.4.5)
              (call L.tmp.2.3
                    9223372036854775807
                    bar.0.7
                    foo.8.8
                    bar.0.7
                    foo.9.6
                    bat.4.5
                    -9223372036854775808)))
    (define L.tmp.2.3
      (lambda (foo.7.16 bat.3.15 bat.5.14 bat.4.13 foo.8.12 foo.2.11 foo.6.10) bat.5.14))
    (if (false)
        (let ([foo.9.17 1281469771]) 0)
        (call L.tmp.2.3
              1
              9223372036854775807
              -9223372036854775808
              -282402130
              1
              9223372036854775807
              1))))
(check-by-interp '(module (define L.tmp.0.1
                            (lambda (bar.8.7 bar.4.6 foo.7.5 foo.6.4 bat.3.3 foobar.2.2 ball.5.1)
                              (call L.func.1.2 9223372036854775807 946654223 foo.6.4)))
                          (define L.func.1.2
                            (lambda (ball.1.10 ball.5.9 bar.8.8)
                              (call L.func.1.2 ball.5.9 bar.8.8 9223372036854775807)))
                    (define L.fn.2.3
                      (lambda (bar.8.13 ball.0.12 ball.5.11)
                        (let ([ball.5.14 9223372036854775807])
                          (call L.func.1.2 ball.0.12 0 bar.8.13))))
                    (let ([ball.1.15 0]) 1)))
(check-by-interp
 '(module (define L.func.0.1
            (lambda (foo.9.5 foo.0.4 foobar.7.3 bat.2.2 foo.1.1)
              (if (false)
                  (let ([ball.3.6 (if (!= -9223372036854775808 0) 1 foo.9.5)])
                    (let ([foo.9.7 9223372036854775807]) 9223372036854775807))
                  1)))
          (call L.func.0.1 -9223372036854775808 9223372036854775807 1 1918330809 1653803490)
    ))
(check-by-interp '(module (define L.fn.0.1
                            (lambda (bat.8.2 bat.6.1)
                              (if (let ([foobar.1.3 559317709]) (not (= foobar.1.3 bat.8.2)))
                                  (call L.func.1.2 bat.6.1 -9223372036854775808 -675648818)
                                  (call L.tmp.2.3))))
                          (define L.func.1.2 (lambda (foobar.1.6 foo.0.5 foo.5.4) (call L.tmp.2.3)))
                    (define L.tmp.2.3 (lambda () (call L.tmp.2.3)))
                    1))
(check-by-interp '(module (define L.x.0.1
                            (lambda (bar.3.4 ball.0.3 bat.2.2 bat.9.1)
                              (let ([bat.2.5 (if (= ball.0.3 bat.9.1) ball.0.3 -1012326174)])
                                (let ([foobar.7.6 (let ([bar.3.7 0]) bar.3.7)]) (- bar.3.4 0)))))
                          (call L.x.0.1 1 0 1097392993 1259250868)
                    ))
(check-by-interp '(module (define L.tmp.0.1
                            (lambda (bar.4.4 foobar.9.3 ball.5.2 bar.8.1)
                              (call L.tmp.0.1 foobar.9.3 ball.5.2 ball.5.2 ball.5.2)))
                          (if (false)
                              (let ([bar.7.5 (if (if (> 9223372036854775807 1428972274)
                                                     (!= 0 479631559)
                                                     (>= 0 1284385619))
                                                 (call L.tmp.0.1 1550080702 -1164071576 0 1)
                                                 -9223372036854775808)])
                                (if (if (<= 0 bar.7.5)
                                        (!= bar.7.5 2009350954)
                                        (!= 1170635915 bar.7.5))
                                    (let ([foobar.1.6 bar.7.5]) 0)
                                    (let ([foobar.1.7 -378459323]) bar.7.5)))
                              (if (false)
                                  0
                                  (- 1326448876 360169641)))
                    ))
(check-by-interp '(module (let ([foo.7.1 (let ([foo.5.2 1]) (let ([foo.5.3 foo.5.2]) foo.5.3))])
                            foo.7.1)))
(check-by-interp '(module (define L.func.0.1
                            (lambda (bat.7.3 foo.1.2 foobar.8.1) (* 1903463490 -9223372036854775808)))
                          (define L.func.1.2
                            (lambda (foobar.9.7 bat.7.6 bar.3.5 bat.0.4)
                              (let ([foobar.4.8 (- -9223372036854775808 foobar.9.7)])
                                (if (> 9223372036854775807 bar.3.5)
                                    (if (< bat.7.6 bat.0.4) foobar.4.8 bat.7.6)
                                    (if (>= bat.0.4 1408489810) foobar.4.8 bat.7.6)))))
                    (* 977777990 900224161)))
(check-by-interp '(module (define L.x.0.1
                            (lambda ()
                              (if (<= 0 1773437967)
                                  (let ([foobar.2.1 (call L.tmp.2.3 1456910402)])
                                    (let ([bar.5.2 -9223372036854775808]) 1))
                                  (call L.tmp.2.3 -9223372036854775808))))
                          (define L.fn.1.2
                            (lambda (bat.6.6 foobar.3.5 foo.9.4 bat.1.3) (call L.tmp.2.3 foo.9.4)))
                    (define L.tmp.2.3 (lambda (bat.1.7) bat.1.7))
                    (call L.tmp.2.3 0)))
(check-by-interp
 '(module (define L.fn.0.1
            (lambda (foobar.4.2 foo.5.1)
              (let ([bat.1.3 (let ([foo.5.4 foobar.4.2]) (+ foobar.4.2 foo.5.4))])
                (call L.fn.0.1 0 foo.5.1))))
          (define L.tmp.1.2
            (lambda (bat.0.9 foo.2.8 foobar.4.7 bat.1.6 bat.9.5)
              (if (if (true)
                      (< bat.9.5 bat.0.9)
                      (let ([bar.7.10 bat.0.9]) (<= 0 -508327908)))
                  (let ([bat.9.11 (if (<= 167876306 bat.0.9) 44784438 -874603706)])
                    (call L.tmp.1.2 -9223372036854775808 696038140 0 foobar.4.7 foobar.4.7))
                  (if (let ([foobar.3.12 bat.9.5]) (= bat.1.6 0))
                      (if (< foobar.4.7 foobar.4.7) foo.2.8 -727094500)
                      (call L.fn.0.1 bat.0.9 -9223372036854775808)))))
    (let ([foo.5.13 (let ([bat.0.14 (if (<= 9223372036854775807 0) 0 93609173)])
                      (let ([foo.6.15 bat.0.14]) foo.6.15))])
      foo.5.13)))
(check-by-interp '(module (let ([bar.7.1 (let ([bat.1.2 -9223372036854775808])
                                           (let ([foobar.4.3 0]) foobar.4.3))])
                            (if (let ([foo.0.4 bar.7.1]) (<= 1 -9223372036854775808))
                                bar.7.1
                                (let ([foobar.4.5 bar.7.1]) 1974766267)))))
(check-by-interp '(module (define L.func.0.1
                            (lambda (bar.0.6 foobar.2.5 foo.1.4 foobar.9.3 bat.5.2 foobar.8.1)
                              (let ([bat.6.7 -951184591])
                                (if (false)
                                    (let ([foo.1.8 -9223372036854775808]) foo.1.8)
                                    (let ([foo.1.9 310790521]) foobar.8.1)))))
                          (let ([foo.1.10 -1379426851]) 488563830)
                    ))
(check-by-interp '(module (define L.func.0.1
                            (lambda (ball.2.3 foo.5.2 ball.0.1)
                              (if (if (= 0 ball.2.3)
                                      (false)
                                      (if (<= ball.0.1 -483103791)
                                          (= foo.5.2 ball.2.3)
                                          (= ball.2.3 foo.5.2)))
                                  (call L.func.0.1 foo.5.2 1 1)
                                  (if (true)
                                      (let ([foo.5.4 ball.2.3]) foo.5.4)
                                      (call L.func.0.1 foo.5.2 foo.5.2 1)))))
                          (let ([foo.5.5 -1766715399])
                            (if (not (not (< foo.5.5 foo.5.5)))
                                (let ([foobar.4.6 (if (< foo.5.5 0) 9223372036854775807 foo.5.5)])
                                  -1170116362)
                                (* 0 0)))
                    ))
(check-by-interp
 '(module (define L.tmp.0.1 (lambda (bar.0.3 bar.4.2 bar.9.1) (call L.fn.1.2 9223372036854775807)))
          (define L.fn.1.2
            (lambda (bar.9.4)
              (if (> 1 1)
                  (call L.x.2.3 bar.9.4 -9223372036854775808 -9223372036854775808)
                  (if (if (> bar.9.4 9223372036854775807)
                          (<= bar.9.4 2069349298)
                          (= 327435684 bar.9.4))
                      (call L.x.2.3 937688474 bar.9.4 bar.9.4)
                      -9223372036854775808))))
    (define L.x.2.3
      (lambda (foobar.6.7 ball.8.6 bar.4.5) (call L.x.2.3 foobar.6.7 -845528888 bar.4.5)))
    (let ([bat.1.8 0]) bat.1.8)))
(check-by-interp '(module (define L.x.0.1
                            (lambda (foobar.4.5 bar.5.4 foobar.6.3 ball.7.2 bat.1.1)
                              (if (false)
                                  (if (let ([bar.9.6 foobar.6.3]) (< 0 foobar.6.3))
                                      (call L.x.1.2 0 -9223372036854775808)
                                      (let ([foobar.2.7 bat.1.1]) foobar.4.5))
                                  (if (true)
                                      (if (!= -9223372036854775808 1) 0 849007740)
                                      foobar.4.5))))
                          (define L.x.1.2
                            (lambda (foobar.6.9 bar.0.8)
                              (let ([foobar.4.10 bar.0.8])
                                (call L.x.0.1 foobar.6.9 0 foobar.4.10 0 9223372036854775807))))
                    (define L.x.2.3
                      (lambda (foobar.2.15 foobar.4.14 bar.8.13 ball.3.12 bar.5.11)
                        (let ([bar.8.16 (call L.x.1.2 bar.5.11 bar.5.11)])
                          (call L.x.1.2 -1927041153 1))))
                    (let ([ball.3.17 (* 1 -394936001)])
                      (call L.x.0.1 ball.3.17 ball.3.17 0 -9223372036854775808 ball.3.17))))
(check-by-interp
 '(module (define L.tmp.0.1 (lambda (bat.3.5 bar.8.4 ball.4.3 bar.2.2 foo.6.1) foo.6.1))
          (let ([foo.5.6 (call L.tmp.0.1 1 -9223372036854775808 0 1 -9223372036854775808)])
            (if (= -9223372036854775808 175566669) -1855219983 foo.5.6))
    ))
(check-by-interp '(module (define L.proc.0.1
                            (lambda (ball.1.1)
                              (let ([bar.2.2 (if (let ([bar.5.3 1541307282])
                                                   (= 9223372036854775807 -194099637))
                                                 (- ball.1.1 -1702731989)
                                                 (let ([bar.2.4 ball.1.1]) ball.1.1))])
                                (if (not (= -9223372036854775808 bar.2.2))
                                    (let ([bar.6.5 1]) bar.2.2)
                                    (call L.proc.0.1 0)))))
                          (define L.fn.1.2 (lambda () (+ 9223372036854775807 1)))
                    (define L.fn.2.3 (lambda (bat.9.6) (let ([bar.6.7 (* 1 0)]) (call L.fn.1.2))))
                    (if (true)
                        (let ([bat.3.8 (call L.fn.2.3 1)]) (let ([bar.7.9 bat.3.8]) 1))
                        (let ([bar.5.10 -1579827217]) (call L.fn.2.3 bar.5.10)))))
(check-by-interp
 '(module (define L.x.0.1
            (lambda (bar.6.5 foobar.5.4 foo.9.3 foobar.7.2 ball.4.1)
              (let ([bat.3.6 (let ([foobar.7.7 (call L.x.0.1 0 ball.4.1 ball.4.1 foo.9.3 1)])
                               (- foobar.7.7 foobar.7.7))])
                (if (true)
                    (* -9223372036854775808 foobar.7.2)
                    (if (!= -9223372036854775808 bat.3.6) foobar.7.2 0)))))
          (define L.fn.1.2
            (lambda (foo.2.12 foobar.1.11 foo.8.10 ball.4.9 foobar.7.8)
              (if (false)
                  (let ([foo.8.13
                         (if (!= -1658461695 9223372036854775807) -9223372036854775808 foobar.1.11)])
                    9223372036854775807)
                  (if (false)
                      (if (= foo.8.10 1) ball.4.9 9223372036854775807)
                      (let ([ball.0.14 foo.8.10]) 1)))))
    (define L.tmp.2.3
      (lambda ()
        (let ([foobar.5.15 (let ([foo.8.16 1]) foo.8.16)])
          (if (if (> 9223372036854775807 foobar.5.15)
                  (>= foobar.5.15 9223372036854775807)
                  (<= foobar.5.15 foobar.5.15))
              (if (> foobar.5.15 foobar.5.15) 1 foobar.5.15)
              (call L.x.0.1 foobar.5.15 -126978532 foobar.5.15 foobar.5.15 9223372036854775807)))))
    (* -1293429216 880066208)))
(check-by-interp
 '(module (define L.proc.0.1
            (lambda (bar.4.6 foobar.5.5 bar.0.4 foo.7.3 ball.3.2 ball.8.1)
              (if (not (if (> 0 701262944)
                           (!= foo.7.3 9223372036854775807)
                           (< ball.8.1 ball.8.1)))
                  (if (true)
                      (if (= 1779018832 ball.8.1) -9223372036854775808 bar.4.6)
                      (let ([bar.0.7 foo.7.3]) foobar.5.5))
                  (call L.proc.0.1 1 ball.8.1 9223372036854775807 foo.7.3 ball.3.2 bar.4.6))))
          (define L.proc.1.2
            (lambda (bar.1.10 ball.8.9 foobar.2.8)
              (let ([ball.3.11 (if (<= -408033154 bar.1.10)
                                   (+ ball.8.9 bar.1.10)
                                   (let ([bar.4.12 ball.8.9]) bar.4.12))])
                (call L.proc.1.2 ball.8.9 bar.1.10 ball.8.9))))
    (let ([ball.3.13 (if (<= 1 899234556) 0 0)])
      (call L.proc.0.1 ball.3.13 ball.3.13 1961997671 ball.3.13 1792291800 -9223372036854775808))))
(check-by-interp '(module (define L.x.0.1
                            (lambda (foo.5.4 foo.0.3 foo.3.2 foo.4.1)
                              (let ([ball.7.5 (if (let ([ball.1.6 foo.4.1])
                                                    (<= -9223372036854775808 -1549190542))
                                                  (let ([foo.0.7 1]) foo.3.2)
                                                  foo.3.2)])
                                (if (true)
                                    (let ([foo.3.8 foo.0.3]) ball.7.5)
                                    (call L.x.0.1 foo.3.2 foo.3.2 -9223372036854775808 foo.0.3)))))
                          (let ([bat.8.9 (if (true)
                                             480297521
                                             (- 1 0))])
                            (if (= bat.8.9 0)
                                (let ([foo.4.10 (let ([bat.9.11 bat.8.9]) 0)])
                                  (call L.x.0.1 9223372036854775807 9223372036854775807 0 foo.4.10))
                                (if (let ([bat.9.12 1]) (>= bat.8.9 1434817833))
                                    (* -9223372036854775808 -1655015632)
                                    (let ([bat.2.13 -9223372036854775808]) 1398310587))))
                    ))
(check-by-interp '(module (define L.func.0.1
                            (lambda (bat.1.7 foo.6.6 ball.0.5 foo.9.4 foo.5.3 ball.2.2 foo.4.1)
                              (if (> 9223372036854775807 -1225978347)
                                  (if (if (> ball.0.5 1)
                                          (> ball.2.2 -9223372036854775808)
                                          (!= foo.5.3 -847185955))
                                      (call L.func.0.1
                                            9223372036854775807
                                            -144908363
                                            foo.6.6
                                            foo.9.4
                                            -9223372036854775808
                                            0
                                            -260761950)
                                      (if (> foo.9.4 foo.9.4) 0 1))
                                  (let ([foo.3.8 9223372036854775807])
                                    (call L.func.0.1
                                          -9223372036854775808
                                          -472335653
                                          -9223372036854775808
                                          9223372036854775807
                                          foo.6.6
                                          foo.6.6
                                          0)))))
                          (if (>= 1 9223372036854775807)
                              (let ([bar.8.9 1]) bar.8.9)
                              -32529780)
                    ))
(check-by-interp
 '(module (define L.proc.0.1
            (lambda (ball.9.7 foo.5.6 ball.2.5 ball.7.4 foo.0.3 bat.8.2 foobar.1.1) (call L.tmp.1.2)))
          (define L.tmp.1.2 (lambda () (call L.proc.2.3 0 0)))
    (define L.proc.2.3
      (lambda (foo.6.9 bat.8.8)
        (call L.proc.0.1 bat.8.8 foo.6.9 445965252 foo.6.9 bat.8.8 foo.6.9 1635273112)))
    (if (if (<= 9223372036854775807 -9223372036854775808)
            (< 692968731 0)
            (<= -1490931083 -14809197))
        1275113131
        (if (<= -1702177019 -9223372036854775808) 0 1843455920))))
(check-by-interp '(module (define L.fn.0.1
                            (lambda (bat.5.7 foo.2.6 bar.9.5 foo.8.4 foobar.4.3 bat.3.2 bat.7.1)
                              (call L.fn.0.1
                                    bat.3.2
                                    -9223372036854775808
                                    bat.5.7
                                    9223372036854775807
                                    foo.8.4
                                    foo.8.4
                                    bat.3.2)))
                          (let ([bat.6.10 9223372036854775807]
                                [foobar.4.9 9223372036854775807]
                                [ball.0.8 9223372036854775807])
                            foobar.4.9)
                    ))
(check-by-interp '(module (define L.func.0.1
                            (lambda (bar.2.5 ball.4.4 foo.9.3 foobar.5.2 foo.6.1)
                              (if (true)
                                  (let ([foo.9.7 bar.2.5]
                                        [bat.0.6 (call L.func.1.2 foo.9.3 foobar.5.2 -1140169546)])
                                    (+ foo.6.1 bat.0.6))
                                  (call L.func.1.2 foo.6.1 foobar.5.2 9223372036854775807))))
                          (define L.func.1.2
                            (lambda (bat.0.10 foo.6.9 foo.9.8)
                              (if (!= 9223372036854775807 -47909185)
                                  (if (false)
                                      (if (< foo.9.8 foo.9.8) bat.0.10 -9223372036854775808)
                                      (call L.func.1.2 bat.0.10 foo.9.8 foo.9.8))
                                  (+ -9223372036854775808 foo.6.9))))
                    (if (> 9223372036854775807 9223372036854775807) -877748660 -9223372036854775808)))
(check-by-interp '(module (+ -1640821439 -406700566)))
(check-by-interp
 '(module (define L.fn.0.1
            (lambda (foo.2.2 ball.6.1)
              (call L.x.1.2 ball.6.1 foo.2.2 ball.6.1 -9223372036854775808 ball.6.1 foo.2.2)))
          (define L.x.1.2
            (lambda (ball.0.8 foo.4.7 foobar.1.6 ball.5.5 foo.2.4 bar.7.3)
              (call L.x.1.2 933807622 bar.7.3 bar.7.3 -984231193 1 ball.5.5)))
    (let ([bat.9.10 -477286222]
          [bar.7.9 0])
      643069821)))
(check-by-interp '(module (define L.func.0.1
                            (lambda (bar.9.1)
                              (if (!= bar.9.1 bar.9.1)
                                  (call L.func.0.1 2058053814)
                                  (let ([bat.2.3 (- bar.9.1 bar.9.1)]
                                        [bat.0.2 (let ([bar.9.6 bar.9.1]
                                                       [bat.0.5 bar.9.1]
                                                       [ball.4.4 bar.9.1])
                                                   ball.4.4)])
                                    (call L.x.2.3 bar.9.1)))))
                          (define L.tmp.1.2 (lambda (bat.8.9 bat.3.8 bat.5.7) (call L.x.2.3 bat.8.9)))
                    (define L.x.2.3
                      (lambda (bar.9.10)
                        (let ([bar.9.11 (call L.tmp.1.2 bar.9.10 bar.9.10 -1942673900)])
                          (if (let ([foo.1.14 bar.9.11]
                                    [bat.8.13 bar.9.11]
                                    [ball.7.12 bar.9.11])
                                (= ball.7.12 bar.9.11))
                              (call L.tmp.1.2 bar.9.11 bar.9.11 -1386061378)
                              (call L.func.0.1 bar.9.11)))))
                    (if (true)
                        (+ 9223372036854775807 -9223372036854775808)
                        (call L.func.0.1 -2107846344))))
(check-by-interp '(module (if (<= 1 -9223372036854775808)
                              (if (false) -9223372036854775808 2012039291)
                              9223372036854775807)))
(check-by-interp
 '(module (define L.func.0.1
            (lambda (foo.2.6 ball.1.5 foo.4.4 foobar.7.3 foo.5.2 foo.9.1) (- foo.2.6 foo.4.4)))
          (define L.proc.1.2
            (lambda ()
              (let ([foo.6.7 (+ 9223372036854775807 1)])
                (let ([foo.6.10 (call L.func.0.1 0 foo.6.7 foo.6.7 foo.6.7 foo.6.7 foo.6.7)]
                      [foobar.7.9 foo.6.7]
                      [foo.2.8 (if (>= foo.6.7 foo.6.7) foo.6.7 foo.6.7)])
                  (let ([foo.4.13 foo.6.10]
                        [foobar.7.12 foo.6.10]
                        [foo.6.11 -9223372036854775808])
                    9223372036854775807)))))
    (define L.func.2.3
      (lambda (bar.0.17 foobar.7.16 foo.4.15 foo.6.14)
        (let ([foo.9.18 foobar.7.16])
          (let ([foo.4.19 (let ([foo.6.21 foo.6.14]
                                [foo.9.20 foo.6.14])
                            foobar.7.16)])
            (if (>= foo.9.18 foo.6.14) foobar.7.16 bar.0.17)))))
    (call L.func.2.3 0 9223372036854775807 -1735352110 9223372036854775807)))
(check-by-interp
 '(module (define L.x.0.1
            (lambda (bat.9.7 foobar.7.6 ball.1.5 foo.2.4 ball.6.3 bar.0.2 foobar.8.1)
              (let ([ball.1.8 (call L.fn.1.2 foo.2.4 foo.2.4 foobar.8.1 0 bar.0.2 bat.9.7 bar.0.2)])
                (if (not (< 0 -9223372036854775808))
                    (+ ball.6.3 ball.1.8)
                    (if (<= foo.2.4 0) foo.2.4 foobar.7.6)))))
          (define L.fn.1.2
            (lambda (bat.9.15 bar.0.14 foobar.4.13 ball.6.12 bat.5.11 foobar.7.10 foobar.8.9)
              (call L.fn.1.2
                    ball.6.12
                    foobar.7.10
                    bar.0.14
                    -9223372036854775808
                    foobar.7.10
                    bar.0.14
                    0)))
    (if (>= -9223372036854775808 -637253177) -9223372036854775808 0)))
(check-by-interp '(module 9223372036854775807))
(check-by-interp
 '(module (define L.proc.0.1
            (lambda (bat.8.6 foo.7.5 foo.0.4 bat.1.3 bat.5.2 bat.6.1)
              (call L.proc.0.1 bat.5.2 bat.5.2 bat.5.2 -635532414 bat.8.6 bat.1.3)))
          (define L.tmp.1.2
            (lambda (bat.6.11 foo.0.10 bat.8.9 ball.9.8 foo.7.7)
              (let ([foo.0.13 (call L.tmp.1.2 ball.9.8 foo.7.7 bat.6.11 ball.9.8 foo.7.7)]
                    [ball.4.12 (let ([bat.5.15 (call L.func.2.3
                                                     foo.0.10
                                                     9223372036854775807
                                                     foo.7.7
                                                     -501684781
                                                     ball.9.8
                                                     bat.8.9
                                                     foo.7.7)]
                                     [bar.3.14 foo.0.10])
                                 (call L.func.2.3
                                       bat.6.11
                                       1644735104
                                       foo.7.7
                                       -9223372036854775808
                                       bat.8.9
                                       foo.0.10
                                       bat.6.11))])
                (let ([ball.9.17 (- foo.0.13 foo.0.13)]
                      [bat.8.16 (if (= foo.0.13 ball.4.12) ball.4.12 foo.0.13)])
                  (call L.func.2.3
                        ball.4.12
                        foo.7.7
                        foo.7.7
                        bat.8.16
                        bat.6.11
                        -9223372036854775808
                        ball.4.12)))))
    (define L.func.2.3
      (lambda (foo.2.24 bat.5.23 bat.8.22 foo.0.21 bar.3.20 bat.1.19 ball.4.18)
        (call L.func.2.3
              bar.3.20
              -9223372036854775808
              foo.0.21
              ball.4.18
              ball.4.18
              foo.0.21
              9223372036854775807)))
    (let ([bar.3.27 -9223372036854775808]
          [foo.7.26 9223372036854775807]
          [foo.0.25 9223372036854775807])
      bar.3.27)))
(check-by-interp
 '(module (define L.func.0.1
            (lambda (foo.4.5 ball.5.4 bar.2.3 bat.3.2 bar.1.1)
              (if (let ([bar.1.8 bar.2.3]
                        [bat.3.7 (if (<= bat.3.2 bar.1.1) bat.3.2 bar.1.1)]
                        [foo.4.6 (call L.func.0.1 1 bar.2.3 foo.4.5 foo.4.5 bar.1.1)])
                    (false))
                  (call L.func.0.1 bar.1.1 ball.5.4 1603961181 bar.2.3 0)
                  (call L.fn.1.2 ball.5.4 -9223372036854775808 bar.1.1 ball.5.4 bar.1.1 bat.3.2))))
          (define L.fn.1.2
            (lambda (bar.1.14 bat.7.13 ball.5.12 bar.0.11 bat.3.10 foobar.9.9)
              (let ()
                (if (if (>= bat.3.10 bar.1.14)
                        (> bat.7.13 -9223372036854775808)
                        (>= ball.5.12 bat.3.10))
                    (let ([bat.7.17 bar.0.11]
                          [foobar.9.16 9223372036854775807]
                          [bat.8.15 bar.1.14])
                      bat.3.10)
                    (if (< bat.3.10 bar.1.14) bar.0.11 bat.7.13)))))
    (let ([bar.2.20 405359082]
          [bat.6.19 (if (not (>= -915730633 0))
                        (let ([bat.8.21 -532660031]) -248685178)
                        0)]
          [bat.7.18 1254220652])
      (call L.fn.1.2 -9223372036854775808 bat.6.19 bat.6.19 9223372036854775807 bat.6.19 bar.2.20))))
(check-by-interp
 '(module (define L.proc.0.1
            (lambda (foobar.9.5 foobar.7.4 foo.2.3 foo.5.2 foo.1.1)
              (call L.proc.0.1 foo.1.1 foo.2.3 -675715652 -1754605622 1)))
          (define L.func.1.2
            (lambda (foobar.3.7 foo.1.6)
              (call L.proc.0.1 foo.1.6 foobar.3.7 foobar.3.7 foo.1.6 foo.1.6)))
    (define L.x.2.3
      (lambda (bar.0.14 foobar.9.13 foo.8.12 bar.4.11 bat.6.10 foo.1.9 foobar.7.8)
        (let ([foobar.9.16 (if (>= bar.4.11 foobar.7.8)
                               foobar.9.13
                               (call L.x.2.3 1 foo.8.12 0 bat.6.10 bar.4.11 foo.1.9 1783645727))]
              [foo.1.15 (* bar.4.11 bar.4.11)])
          (call L.x.2.3 foobar.7.8 bar.4.11 foobar.7.8 foobar.7.8 -922337918 bar.0.14 bar.4.11))))
    (let ([bar.0.18 0]
          [foo.8.17 1029279872])
      bar.0.18)))
(check-by-interp '(module (if (if (let ([bat.2.2 1]
                                        [foobar.0.1 -1606724555])
                                    (= bat.2.2 bat.2.2))
                                  (let ([ball.5.5 1]
                                        [bat.1.4 1]
                                        [bar.8.3 -9223372036854775808])
                                    (<= ball.5.5 ball.5.5))
                                  (let () (!= -1879829070 1981475003)))
                              (- -634246165 -684848771)
                              0)))
(check-by-interp
 '(module (define L.func.0.1
            (lambda (bat.2.3 foo.3.2 bar.6.1) (call L.proc.1.2 bat.2.3 -1803672217 bat.2.3)))
          (define L.proc.1.2 (lambda (foo.3.6 ball.0.5 bat.1.4) (call L.proc.1.2 1 ball.0.5 bat.1.4)))
    (let ([bar.9.7 0]) bar.9.7)))
(check-by-interp '(module (let ()
                            (let ([ball.0.1 (let ([bar.6.2 (let ([bat.2.5 1550347185]
                                                                 [ball.0.4 9223372036854775807]
                                                                 [foobar.7.3 -9223372036854775808])
                                                             ball.0.4)])
                                              bar.6.2)])
                              (- 9223372036854775807 ball.0.1)))))
(check-by-interp
 '(module (define L.proc.0.1
            (lambda (bar.6.3 bar.3.2 foo.1.1)
              (let ([bar.3.6 (call L.proc.0.1 9223372036854775807 foo.1.1 foo.1.1)]
                    [ball.9.5 (call L.proc.0.1 bar.6.3 foo.1.1 bar.6.3)]
                    [bar.6.4 (let ([ball.2.9 (call L.proc.0.1 foo.1.1 foo.1.1 bar.6.3)]
                                   [ball.9.8 bar.3.2]
                                   [foo.8.7 (call L.proc.0.1 foo.1.1 foo.1.1 bar.3.2)])
                               (call L.proc.0.1 foo.8.7 foo.8.7 ball.2.9))])
                (if (> bar.6.4 foo.1.1)
                    (if (>= bar.3.6 bar.3.6) foo.1.1 bar.6.4)
                    (let ([ball.4.11 -2087609688]
                          [foo.8.10 bar.3.6])
                      ball.9.5)))))
          (let ([ball.9.13 1]
                [foo.1.12 -9223372036854775808])
            foo.1.12)
    ))
(check-by-interp
 '(module (define L.fn.0.1
            (lambda (bar.0.1)
              (if (true)
                  (call L.func.2.3 bar.0.1 bar.0.1 bar.0.1 2099518136)
                  (call L.func.2.3 bar.0.1 bar.0.1 bar.0.1 bar.0.1))))
          (define L.tmp.1.2
            (lambda (foobar.6.7 foobar.3.6 foo.5.5 bar.2.4 ball.8.3 bar.0.2)
              (let ([bar.0.10 9223372036854775807]
                    [foo.5.9 (+ foo.5.5 foobar.3.6)]
                    [foobar.6.8 (let ([ball.1.11 (+ bar.2.4 foobar.3.6)]) foobar.3.6)])
                (call L.fn.0.1 0))))
    (define L.func.2.3
      (lambda (ball.9.15 ball.8.14 bar.0.13 foobar.6.12)
        (call L.tmp.1.2 1 foobar.6.12 foobar.6.12 ball.9.15 bar.0.13 9223372036854775807)))
    (let ([bat.4.16 (+ 1 9223372036854775807)]) bat.4.16)))
(check-by-interp '(module (let ([foobar.1.2 0]
                                [bat.0.1 1])
                            bat.0.1)))
(check-by-interp
 '(module (define L.func.0.1
            (lambda () (call L.x.1.2 38797657 1 9223372036854775807 9223372036854775807 1 0)))
          (define L.x.1.2
            (lambda (bat.7.6 ball.5.5 bat.3.4 bar.2.3 foobar.1.2 bat.9.1)
              (if (true)
                  (if (if (>= foobar.1.2 foobar.1.2)
                          (< bat.7.6 bar.2.3)
                          (< bat.9.1 812242710))
                      (- foobar.1.2 bar.2.3)
                      (call L.func.0.1))
                  (call L.x.1.2 bat.3.4 foobar.1.2 bar.2.3 bat.9.1 bat.9.1 bar.2.3))))
    (call L.x.1.2 0 -2062025435 -9223372036854775808 -9223372036854775808 0 -9223372036854775808)))
(check-by-interp '(module (define L.func.0.1
                            (lambda (foo.4.4 foo.7.3 foo.3.2 foo.9.1)
                              (call L.proc.1.2 foo.4.4 -9223372036854775808 foo.3.2)))
                          (define L.proc.1.2 (lambda (foo.9.7 bat.5.6 foo.7.5) (- bat.5.6 foo.7.5)))
                    (let () 1)))
(check-by-interp '(module (let ([ball.3.2 -550916464]
                                [foobar.9.1 9223372036854775807])
                            foobar.9.1)))
(check-by-interp
 '(module (if (false)
              (if (if (< 9223372036854775807 1646335033)
                      (>= 9223372036854775807 1)
                      (!= 9223372036854775807 1))
                  (if (!= -9223372036854775808 -9223372036854775808) -9223372036854775808 1282320164)
                  (let ([bar.1.1 -9223372036854775808]) bar.1.1))
              (- 9223372036854775807 1))))
(check-by-interp '(module (define L.tmp.0.1
                            (lambda (bar.1.4 bat.6.3 ball.4.2 bar.0.1)
                              (let ([ball.7.6 (call L.tmp.0.1 bat.6.3 bat.6.3 bar.0.1 bar.1.4)]
                                    [ball.4.5 (let () (- bat.6.3 bar.0.1))])
                                (let ([foobar.8.9 (let ([foobar.2.11 bat.6.3]
                                                        [bar.1.10 1])
                                                    bar.0.1)]
                                      [bar.0.8 bar.1.4]
                                      [foobar.2.7 (call L.x.1.2 bar.0.1 9223372036854775807 bar.1.4)])
                                  (call L.x.1.2 -9223372036854775808 bat.6.3 bat.6.3)))))
                          (define L.x.1.2
                            (lambda (bar.3.14 foobar.8.13 bat.6.12)
                              (if (false)
                                  (call L.x.1.2 9223372036854775807 bat.6.12 foobar.8.13)
                                  (if (false)
                                      (call L.tmp.0.1 foobar.8.13 bar.3.14 foobar.8.13 bar.3.14)
                                      (call L.x.1.2 bat.6.12 580696126 bat.6.12)))))
                    (if (<= 9223372036854775807 9223372036854775807) -1677147892 874915829)))
(check-by-interp
 '(module (define L.proc.0.1
            (lambda (foo.2.7 foo.1.6 ball.4.5 ball.7.4 foobar.3.3 ball.0.2 foo.6.1)
              (if (not (> foo.6.1 -727829088))
                  (let ([ball.4.10 foo.2.7]
                        [ball.7.9 (call L.proc.0.1
                                        foo.1.6
                                        foobar.3.3
                                        ball.4.5
                                        foo.1.6
                                        ball.7.4
                                        foo.2.7
                                        foo.2.7)]
                        [foo.2.8
                         (call L.fn.1.2 ball.4.5 foo.2.7 1 foobar.3.3 -9223372036854775808 foo.6.1)])
                    (let ([foo.2.11 foo.1.6]) ball.0.2))
                  (let () -774243080))))
          (define L.fn.1.2
            (lambda (foo.5.17 ball.4.16 foo.1.15 ball.9.14 foobar.3.13 ball.7.12)
              (if (if (if (< foobar.3.13 foo.5.17)
                          (>= foo.5.17 ball.9.14)
                          (!= ball.4.16 ball.4.16))
                      (if (>= ball.7.12 ball.9.14)
                          (< foo.5.17 foo.5.17)
                          (>= foo.1.15 foobar.3.13))
                      (not (> ball.9.14 ball.7.12)))
                  (let ([ball.9.18 (- -1548357748 foobar.3.13)])
                    (call L.fn.1.2 ball.9.18 0 foo.1.15 ball.4.16 foo.1.15 ball.9.18))
                  (call L.fn.2.3 ball.9.14 foobar.3.13 ball.4.16 ball.7.12 ball.7.12 foo.5.17))))
    (define L.fn.2.3
      (lambda (foobar.8.24 foo.1.23 foobar.3.22 foo.2.21 foo.6.20 ball.9.19)
        (call L.fn.2.3 foo.6.20 -9223372036854775808 foo.2.21 foo.6.20 1 0)))
    (if (< -534391580 9223372036854775807) 0 0)))
(check-by-interp '(module (let ()
                            (let ([ball.7.3 -1762920629]
                                  [ball.8.2 1]
                                  [foobar.1.1 9223372036854775807])
                              0))))
(check-by-interp
 '(module (define L.proc.0.1
            (lambda (foobar.0.6 ball.2.5 ball.3.4 ball.5.3 bar.4.2 foobar.8.1)
              (call L.proc.0.1 ball.2.5 15882253 foobar.0.6 ball.5.3 ball.2.5 ball.2.5)))
          (if (!= 1038395452 1) -9223372036854775808 717010255)
    ))
(check-by-interp '(module (if (true)
                              (if (not (= 0 1))
                                  (if (>= -9223372036854775808 -1744096882) 0 9223372036854775807)
                                  (if (< -9223372036854775808 0) 1 9223372036854775807))
                              (if (false)
                                  (let ([foo.5.2 1032709229]
                                        [bat.6.1 1])
                                    foo.5.2)
                                  (let ([bat.8.3 9223372036854775807]) bat.8.3)))))
(check-by-interp '(module (if (< 0 9223372036854775807)
                              1620518798
                              (if (!= 0 9223372036854775807) 0 -9223372036854775808))))
(check-by-interp '(module (define L.func.0.1
                            (lambda (foobar.2.2 ball.0.1)
                              (call L.tmp.1.2 foobar.2.2 foobar.2.2 9223372036854775807)))
                          (define L.tmp.1.2
                            (lambda (ball.5.5 foobar.2.4 foo.6.3)
                              (if (false)
                                  (call L.tmp.2.3 ball.5.5 foobar.2.4 foobar.2.4 0 ball.5.5 foo.6.3)
                                  (call L.tmp.1.2 foobar.2.4 9223372036854775807 ball.5.5))))
                    (define L.tmp.2.3
                      (lambda (foobar.2.11 foo.6.10 foobar.7.9 ball.5.8 bar.1.7 bat.9.6)
                        (call L.tmp.2.3 273235985 1666412948 bar.1.7 foobar.2.11 bar.1.7 foo.6.10)))
                    (if (= -9223372036854775808 9223372036854775807) 9223372036854775807 1)))
(check-by-interp '(module (define L.fn.0.1
                            (lambda (ball.2.5 ball.4.4 ball.0.3 foo.1.2 foo.8.1)
                              (call L.fn.0.1 foo.8.1 ball.2.5 ball.4.4 foo.1.2 ball.2.5)))
                          (let () -167685894)
                    ))
(check-by-interp
 '(module (define L.func.0.1
            (lambda (bar.0.2 foobar.8.1)
              (call L.fn.2.3 foobar.8.1 bar.0.2 foobar.8.1 bar.0.2 foobar.8.1 foobar.8.1)))
          (define L.fn.1.2
            (lambda (foo.6.7 foobar.2.6 foobar.1.5 bat.3.4 foobar.5.3)
              (let ([bar.0.8 (let ([foobar.7.10 (let () foobar.5.3)]
                                   [foobar.2.9 (- foobar.1.5 foobar.2.6)])
                               (let ([bar.0.13 foobar.7.10]
                                     [bar.9.12 foobar.2.9]
                                     [foobar.1.11 foobar.1.5])
                                 bat.3.4))])
                (call L.fn.1.2 bat.3.4 -9223372036854775808 foobar.5.3 bat.3.4 foobar.5.3))))
    (define L.fn.2.3
      (lambda (foobar.1.19 foobar.5.18 foobar.2.17 ball.4.16 foobar.8.15 foobar.7.14)
        (call L.func.0.1 foobar.1.19 ball.4.16)))
    (+ 1962527269 9223372036854775807)))
(check-by-interp '(module (define L.func.0.1
                            (lambda (bat.0.1)
                              (if (if (true)
                                      (not (> bat.0.1 bat.0.1))
                                      (>= 2020417677 -9223372036854775808))
                                  (if (true)
                                      (if (= bat.0.1 bat.0.1) bat.0.1 bat.0.1)
                                      (call L.func.0.1 bat.0.1))
                                  (call L.func.0.1 9223372036854775807))))
                          (call L.func.0.1 733499244)
                    ))
(check-by-interp
 '(module (define L.proc.0.1
            (lambda (ball.3.4 foo.8.3 foobar.4.2 foobar.1.1)
              (call L.fn.1.2 835392363 -9223372036854775808 0 1 foo.8.3)))
          (define L.fn.1.2
            (lambda (bat.0.9 foobar.7.8 bar.2.7 bat.6.6 foobar.4.5) (call L.x.2.3 foobar.7.8)))
    (define L.x.2.3
      (lambda (foobar.7.10)
        (let ([foo.9.11
               (let ([bat.0.12 (call L.proc.0.1 foobar.7.10 foobar.7.10 foobar.7.10 foobar.7.10)])
                 (- bat.0.12 bat.0.12))])
          (let ([foo.9.15 (if (<= foo.9.11 foobar.7.10) foo.9.11 foobar.7.10)]
                [foobar.7.14 (let ([bat.0.18 foo.9.11]
                                   [foobar.7.17 foobar.7.10]
                                   [foobar.1.16 foo.9.11])
                               bat.0.18)]
                [ball.3.13 foobar.7.10])
            (call L.x.2.3 ball.3.13)))))
    (let ([ball.3.21 1830309714]
          [foo.8.20 -9223372036854775808]
          [foobar.7.19 -9223372036854775808])
      ball.3.21)))
(check-by-interp '(module (define L.func.0.1
                            (lambda (foobar.0.5 foo.5.4 bat.6.3 bat.3.2 bar.7.1) bat.3.2))
                          (define L.func.1.2
                            (lambda ()
                              (let ([bat.2.8 (- -620373304 -68719063)]
                                    [bat.3.7 0]
                                    [foobar.4.6 (call L.func.1.2)])
                                bat.3.7)))
                    (define L.x.2.3 (lambda (bar.8.9) (call L.func.1.2)))
                    -575594324))
(check-by-interp
 '(module (define L.x.0.1
            (lambda (foo.3.6 foobar.0.5 bat.2.4 bar.7.3 bar.5.2 bat.6.1) (call L.x.1.2 bar.7.3 1)))
          (define L.x.1.2
            (lambda (foobar.4.8 foobar.0.7)
              (if (<= foobar.0.7 -9223372036854775808)
                  (call L.x.0.1 foobar.4.8 foobar.4.8 foobar.0.7 foobar.0.7 foobar.0.7 foobar.4.8)
                  foobar.0.7)))
    (if (not (= 0 -844906965))
        (let ([foo.3.11 996590913]
              [bat.6.10 299367411]
              [foobar.4.9 -9223372036854775808])
          foo.3.11)
        (if (> 894536270 1910216157) 1 1))))
(check-by-interp
 '(module (define L.tmp.0.1
            (lambda (bat.6.5 bat.2.4 foobar.8.3 bar.3.2 foo.1.1)
              (if (<= bat.2.4 9223372036854775807)
                  (if (true)
                      (call L.tmp.1.2
                            bar.3.2
                            foobar.8.3
                            bat.6.5
                            foobar.8.3
                            1
                            -9223372036854775808
                            bar.3.2)
                      (call L.tmp.1.2 bat.2.4 foobar.8.3 bat.2.4 bar.3.2 bar.3.2 foo.1.1 bat.6.5))
                  (let ([bar.3.7 foo.1.1]
                        [bar.4.6 (let () bat.6.5)])
                    (let ([bat.2.8 foobar.8.3]) bat.2.8)))))
          (define L.tmp.1.2
            (lambda (bar.3.15 foo.1.14 foobar.8.13 bat.0.12 bat.2.11 foobar.7.10 bat.6.9)
              (let ([foobar.8.18
                     (if (not (> 1242010444 foobar.8.13))
                         (call L.tmp.0.1 bat.2.11 foobar.7.10 bat.0.12 1 foobar.7.10)
                         (call L.tmp.0.1 foobar.8.13 foobar.8.13 foo.1.14 bat.0.12 bat.0.12))]
                    [bat.0.17 (* bat.6.9 foo.1.14)]
                    [bar.3.16 (call L.tmp.0.1 foo.1.14 foo.1.14 0 bat.2.11 bat.2.11)])
                (call L.tmp.1.2 foobar.7.10 foo.1.14 1 bar.3.16 bat.6.9 foobar.8.18 foobar.7.10))))
    (if (not (< 1973720366 1864083813))
        9223372036854775807
        (call L.tmp.1.2
              9223372036854775807
              9223372036854775807
              501537014
              -1022801227
              -264137160
              726597669
              379193781))))
(check-by-interp '(module (let ([ball.8.3 1521957632]
                                [bat.6.2 (let () -9223372036854775808)]
                                [foo.5.1 -9223372036854775808])
                            (if (false)
                                (if (!= bat.6.2 bat.6.2) foo.5.1 bat.6.2)
                                (if (> ball.8.3 -755834168) 0 bat.6.2)))))
(check-by-interp '(module (let ([ball.1.1 -9223372036854775808])
                            (let ([bar.0.4 (let ([foobar.8.7 0]
                                                 [bar.7.6 ball.1.1]
                                                 [ball.9.5 ball.1.1])
                                             ball.9.5)]
                                  [foo.3.3 ball.1.1]
                                  [foo.4.2 (if (> ball.1.1 ball.1.1) ball.1.1 ball.1.1)])
                              (let ([ball.9.8 bar.0.4]) ball.1.1)))))
(check-by-interp '(module (let ([foo.7.1 1])
                            (let ([foobar.3.4 (if (= foo.7.1 foo.7.1)
                                                  (let ([foo.8.7 foo.7.1]
                                                        [foobar.5.6 foo.7.1]
                                                        [foo.4.5 foo.7.1])
                                                    foo.7.1)
                                                  (let ([foo.4.9 foo.7.1]
                                                        [foobar.1.8 foo.7.1])
                                                    foo.7.1))]
                                  [foo.8.3 foo.7.1]
                                  [foobar.1.2 (+ foo.7.1 foo.7.1)])
                              (let ()
                                (let ([foobar.3.11 foobar.3.4]
                                      [foobar.1.10 1648274049])
                                  foo.7.1))))))
(check-by-interp '(module (define L.func.0.1 (lambda (bat.7.2 bat.8.1) (call L.func.0.1 1 bat.8.1))) 0
                    ))
(check-by-interp
 '(module (if (> -9223372036854775808 526950868) -9223372036854775808 9223372036854775807)))
(check-by-interp
 '(module (define L.fn.0.1
            (lambda (foobar.6.5 ball.3.4 ball.9.3 bar.7.2 bat.4.1)
              (call L.func.1.2 bat.4.1 ball.3.4 1064830001 bat.4.1 bar.7.2 ball.3.4)))
          (define L.func.1.2
            (lambda (ball.1.11 bat.4.10 foo.5.9 ball.9.8 foo.8.7 ball.3.6)
              (if (if (if (< foo.8.7 foo.8.7)
                          (= ball.1.11 ball.1.11)
                          (!= bat.4.10 foo.8.7))
                      (= ball.3.6 0)
                      (if (> 0 ball.3.6)
                          (<= 1 ball.9.8)
                          (>= 529266316 foo.8.7)))
                  (if (let ([bat.4.12 foo.5.9]) (<= ball.9.8 bat.4.12))
                      (let ([foo.8.13 ball.3.6]) ball.3.6)
                      (call L.func.1.2 foo.5.9 ball.1.11 bat.4.10 bat.4.10 foo.5.9 ball.3.6))
                  (let ([ball.1.14 (let ([ball.3.15 foo.5.9]) ball.3.15)])
                    (call L.func.1.2 ball.1.14 ball.3.6 ball.3.6 foo.5.9 ball.1.14 foo.5.9)))))
    (call L.func.1.2 9223372036854775807 -1337458253 1 1 0 0)))
(check-by-interp
 '(module (if (if (!= 9223372036854775807 2124101395)
                  (true)
                  (not (<= 9223372036854775807 0)))
              (let ([bat.2.2 (let ([bat.2.3 -9223372036854775808]) -9223372036854775808)]
                    [bar.8.1 (* 9223372036854775807 -9223372036854775808)])
                bat.2.2)
              (let ([bar.9.4 (+ 1865158198 1)]) (if (> bar.9.4 bar.9.4) bar.9.4 bar.9.4)))))
(check-by-interp '(module (if (>= 1069510162 -9223372036854775808) 1 323863587)))
(check-by-interp '(module (* 379335310 0)))
(check-by-interp '(module 0))
(check-by-interp '(module (let ([bat.2.2 (- -9223372036854775808 0)]
                                [bat.0.1 -9223372036854775808])
                            (let ([ball.3.5 1969620648]
                                  [foo.5.4 bat.2.2]
                                  [bat.0.3 bat.0.1])
                              foo.5.4))))
(check-by-interp '(module (define L.proc.0.1
                            (lambda (ball.3.1) (call L.proc.0.1 9223372036854775807)))
                          (define L.x.1.2
                            (lambda (ball.3.3 ball.6.2)
                              (if (if (if (!= ball.6.2 ball.6.2)
                                          (>= ball.3.3 ball.3.3)
                                          (<= -763864902 9223372036854775807))
                                      (< 1 1)
                                      (false))
                                  (let ([ball.1.4 (+ ball.3.3 -9223372036854775808)]) 598366993)
                                  (* 9223372036854775807 ball.3.3))))
                    (define L.tmp.2.3
                      (lambda (ball.6.6 foo.9.5)
                        (if (true)
                            (let ([ball.1.7 (+ 1 -9223372036854775808)]) 1)
                            (* foo.9.5 foo.9.5))))
                    (if (let ([ball.4.8 2083024360]) (<= 1 ball.4.8))
                        (+ 0 1)
                        (call L.x.1.2 -390453851 1))))
(check-by-interp '(module (define L.fn.0.1 (lambda (foo.3.2 bat.7.1) (call L.tmp.1.2 0 bat.7.1)))
                          (define L.tmp.1.2
                            (lambda (ball.2.4 foo.1.3) (call L.func.2.3 9223372036854775807 foo.1.3)))
                    (define L.func.2.3
                      (lambda (foo.6.6 bat.7.5)
                        (let ([foobar.9.7 foo.6.6])
                          (let ([foobar.8.8 (if (< 0 9223372036854775807) 0 -1879014922)])
                            (if (= 1 1) foobar.9.7 foobar.9.7)))))
                    (if (<= 9223372036854775807 9223372036854775807) 0 0)))
(check-by-interp '(module (define L.proc.0.1
                            (lambda (ball.0.2 ball.3.1)
                              (if (if (not (>= 1676206373 ball.0.2))
                                      (not (>= -9223372036854775808 ball.0.2))
                                      (false))
                                  (call L.fn.2.3)
                                  (+ -679407720 -1670539202))))
                          (define L.proc.1.2
                            (lambda (bat.6.4 bar.5.3) (call L.proc.0.1 -2030614437 1)))
                    (define L.fn.2.3
                      (lambda ()
                        (let ([bat.6.5 (* -9223372036854775808 -1564619175)])
                          (if (not (<= bat.6.5 9223372036854775807))
                              (call L.fn.2.3)
                              (call L.proc.1.2 -9223372036854775808 9223372036854775807)))))
                    (let ([bat.7.6 760052997]) (+ 9223372036854775807 9223372036854775807))))
(check-by-interp '(module (define L.x.0.1
                            (lambda (ball.3.2 foobar.2.1)
                              (let ([foobar.4.3 -9223372036854775808])
                                (call L.x.0.1 -939287079 foobar.2.1))))
                          1542811121
                    ))
(check-by-interp '(module (define L.x.0.1
                            (lambda (ball.4.2 ball.5.1)
                              (if (>= -663003513 946817357)
                                  (if (if (> -9223372036854775808 0)
                                          (= 9223372036854775807 ball.4.2)
                                          (< ball.5.1 -9223372036854775808))
                                      (if (>= ball.5.1 9223372036854775807) 0 ball.4.2)
                                      (let ([ball.4.3 -467213902]) ball.4.3))
                                  (if (false)
                                      (if (= ball.4.2 0) -9223372036854775808 -9223372036854775808)
                                      (if (> ball.5.1 0) 271081552 9223372036854775807)))))
                          (define L.tmp.1.2
                            (lambda (ball.5.4)
                              (let ([ball.9.5 ball.5.4])
                                (let ([bat.6.6 9223372036854775807]) (call L.tmp.1.2 ball.9.5)))))
                    (define L.proc.2.3
                      (lambda ()
                        (let ([foo.1.7 (if (if (> 1458486403 645932820)
                                               (!= 1 1594860681)
                                               (< -9223372036854775808 -70861590))
                                           (+ 2099071943 -9223372036854775808)
                                           (if (< -9223372036854775808 881673257) 1 -568199062))])
                          1)))
                    (let ([ball.9.8 -9223372036854775808]) 9223372036854775807)))
(check-by-interp '(module (define L.proc.0.1
                            (lambda (ball.3.1) (call L.proc.0.1 9223372036854775807)))
                          (define L.x.1.2
                            (lambda (ball.3.3 ball.6.2)
                              (if (if (if (!= ball.6.2 ball.6.2)
                                          (>= ball.3.3 ball.3.3)
                                          (<= -763864902 9223372036854775807))
                                      (< 1 1)
                                      (false))
                                  (let ([ball.1.4 (+ ball.3.3 -9223372036854775808)]) 598366993)
                                  (* 9223372036854775807 ball.3.3))))
                    (define L.tmp.2.3
                      (lambda (ball.6.6 foo.9.5)
                        (if (true)
                            (let ([ball.1.7 (+ 1 -9223372036854775808)]) 1)
                            (* foo.9.5 foo.9.5))))
                    (if (let ([ball.4.8 2083024360]) (<= 1 ball.4.8))
                        (+ 0 1)
                        (call L.x.1.2 -390453851 1))))
(check-by-interp '(module (define L.func.0.1
                            (lambda (foobar.1.2 foo.6.1) (call L.x.1.2 foo.6.1 foo.6.1)))
                          (define L.x.1.2 (lambda (foobar.1.4 bar.9.3) bar.9.3))
                    (call L.x.1.2 9223372036854775807 0)))
(check-by-interp '(module (define L.tmp.0.1
                            (lambda (bat.8.2 foo.1.1)
                              (if (if (if (>= bat.8.2 foo.1.1)
                                          (< bat.8.2 0)
                                          (>= bat.8.2 foo.1.1))
                                      (not (>= -9223372036854775808 bat.8.2))
                                      (< 9223372036854775807 9223372036854775807))
                                  (call L.proc.1.2 9223372036854775807)
                                  (call L.tmp.2.3 bat.8.2 bat.8.2))))
                          (define L.proc.1.2
                            (lambda (foobar.3.3)
                              (if (false)
                                  foobar.3.3
                                  (* foobar.3.3 foobar.3.3))))
                    (define L.tmp.2.3 (lambda (foo.1.5 ball.0.4) (call L.proc.1.2 -915763316)))
                    (let ([foo.1.6 (* -864893154 9223372036854775807)])
                      (if (> 1679313251 -9223372036854775808) foo.1.6 -9223372036854775808))))
(check-by-interp
 '(module (define L.fn.0.1
            (lambda (bat.1.2 foo.0.1)
              (let ([bat.5.3 (let ([foobar.8.4 (if (>= 9223372036854775807 -9223372036854775808)
                                                   bat.1.2
                                                   foo.0.1)])
                               (let ([ball.4.5 -9223372036854775808]) foo.0.1))])
                (let ([ball.4.6 (if (<= -1657890681 9223372036854775807) bat.1.2 bat.1.2)])
                  (call L.fn.0.1 bat.1.2 bat.1.2)))))
          (if (<= 1 1) 0 -9223372036854775808)
    ))
(check-by-interp '(module (define L.x.0.1
                            (lambda (bat.1.1)
                              (let ([ball.5.2 (let ([bat.6.3 (+ -1473118393 -9223372036854775808)])
                                                (let ([foo.4.4 9223372036854775807]) 218975616))])
                                (* bat.1.1 bat.1.1))))
                          (define L.tmp.1.2
                            (lambda ()
                              (let ([bat.1.5 (if (not (<= 1 1))
                                                 (* -753830259 -9223372036854775808)
                                                 0)])
                                (if (if (>= bat.1.5 1170112415)
                                        (!= 172014518 bat.1.5)
                                        (<= bat.1.5 540373982))
                                    bat.1.5
                                    (+ bat.1.5 bat.1.5)))))
                    (define L.proc.2.3 (lambda (ball.9.6) (+ -499436274 9223372036854775807)))
                    1))
(check-by-interp '(module (if (> -9223372036854775808 9223372036854775807) 0 -171588084)))
(check-by-interp '(module (if (< -9223372036854775808 1)
                              (let ([ball.0.1 -1183539798]) ball.0.1)
                              (let ([foobar.6.2 -1081284475]) foobar.6.2))))
(check-by-interp '(module (define L.func.0.1
                            (lambda (bar.6.1)
                              (if (false)
                                  bar.6.1
                                  (call L.func.0.1 bar.6.1))))
                          (if (< 1694312373 9223372036854775807)
                              (if (= 1766930141 9223372036854775807) 1 9223372036854775807)
                              (if (<= 1 530802046) 0 -9223372036854775808))
                    ))
(check-by-interp
 '(module (define L.x.0.1 (lambda (bat.2.2 bar.0.1) (call L.x.0.1 1 203659231)))
          (define L.tmp.1.2
            (lambda ()
              (let ([foo.3.3 (let ([bat.2.4 (if (= -9223372036854775808 1) 9223372036854775807 0)])
                               (if (>= -9223372036854775808 784027956) 9223372036854775807 0))])
                (if (false)
                    (if (= -9223372036854775808 foo.3.3) foo.3.3 foo.3.3)
                    (call L.x.0.1 1 foo.3.3)))))
    (let ([foo.6.5 (if (<= -1418225656 0) -750331240 1598097510)])
      (let ([foo.3.6 1]) 9223372036854775807))))
(check-by-interp '(module (define L.tmp.0.1
                            (lambda (bat.7.2 ball.5.1)
                              (let ([bat.8.3 -1468616918]) (* bat.8.3 bat.8.3))))
                          (define L.func.1.2 (lambda (ball.9.5 bar.1.4) 0))
                    (if (<= 1 -9223372036854775808) 0 -1806756174)))
(check-by-interp '(module (let ([ball.3.1 0]) ball.3.1)))
(check-by-interp '(module (define L.func.0.1 (lambda () 0))
                          (define L.tmp.1.2 (lambda (foo.2.1) (call L.func.0.1)))
                    (define L.func.2.3
                      (lambda ()
                        (let ([bar.4.2 (if (true)
                                           (let ([foo.2.3 1]) foo.2.3)
                                           (* -9223372036854775808 1806293504))])
                          (let ([foobar.6.4 (if (> 1 0) 156890122 bar.4.2)]) 0))))
                    (call L.tmp.1.2 -1860620182)))
(check-by-interp
 '(module (define L.L.tmp.0.1.4
            (lambda ()
              (if (>= 9223372036854775807 -1020514810)
                  (call L.L.x.2.3.6)
                  (* 1 0))))
          (define L.L.func.1.2.5
            (lambda ()
              (let ([bar.1.1.5 -9223372036854775808])
                (if (not (> 9223372036854775807 0)) 1309557052 bar.1.1.5))))
    (define L.L.x.2.3.6
      (lambda ()
        (if (if (true)
                (not (> 0 1))
                (true))
            (if (> 0 0)
                (if (< 9223372036854775807 9223372036854775807) 9223372036854775807 -260353756)
                (let ([ball.0.2.6 0]) ball.0.2.6))
            (let ([bar.3.3.7 (if (!= -302047143 0) 9223372036854775807 102036653)])
              (if (= 0 bar.3.3.7) bar.3.3.7 -362331747)))))
    (let ([ball.0.4.8 (* -9223372036854775808 -9223372036854775808)]) (+ ball.0.4.8 0))))
(check-by-interp '(module (define L.L.proc.0.1.4 (lambda (ball.6.1.5) (call L.L.func.1.2.5)))
                          (define L.L.func.1.2.5 (lambda () (* 1 0)))
                    (define L.L.fn.2.3.6
                      (lambda (ball.3.2.6)
                        (if (true)
                            (let ([bat.0.3.7 (if (<= -2033705372 965540822) -1853172774 1133506028)])
                              (let ([foo.4.4.8 1]) 1236904416))
                            (call L.L.func.1.2.5))))
                    (call L.L.proc.0.1.4 1)))
(check-by-interp '(module (define L.fn.0.1
                            (lambda ()
                              (let ([bat.9.1 (if (false)
                                                 1
                                                 (let ([foo.5.2 1]) 1))])
                                (if (if (>= 9223372036854775807 -9223372036854775808)
                                        (= -248968641 9223372036854775807)
                                        (!= bat.9.1 -9223372036854775808))
                                    (let ([ball.4.3 bat.9.1]) 1622965009)
                                    (let ([foo.5.4 bat.9.1]) bat.9.1)))))
                          (if (false)
                              (if (>= 995853130 1) 1 -9223372036854775808)
                              (call L.fn.0.1))
                    ))
(check-by-interp '(module (+ -9223372036854775808 -1465538260)))
(check-by-interp '(module (define L.fn.0.1
                            (lambda ()
                              (let ([bar.2.1 (+ 1 9223372036854775807)])
                                (let ([foo.8.2 (let ([foo.1.3 bar.2.1]) foo.1.3)]) bar.2.1))))
                          (define L.func.1.2
                            (lambda ()
                              (let ([ball.3.4 (if (let ([foo.8.5 1]) (< 1 foo.8.5))
                                                  (let ([foo.1.6 406779451]) 1200977699)
                                                  (let ([foo.8.7 0]) foo.8.7))])
                                (* ball.3.4 ball.3.4))))
                    (let ([bat.5.8 1]) (let ([ball.9.9 0]) bat.5.8))))
(check-by-interp
 '(module (define L.x.0.1 (lambda (ball.1.2 foo.0.1) (call L.tmp.1.2)))
          (define L.tmp.1.2
            (lambda ()
              (if (if (if (<= -765445006 0)
                          (!= 0 -7399083)
                          (<= 9223372036854775807 1))
                      (false)
                      (true))
                  (let ([ball.4.3 (let ([bar.5.4 -9223372036854775808]) bar.5.4)])
                    (if (> ball.4.3 ball.4.3) -9223372036854775808 ball.4.3))
                  (let ([foobar.9.5 (if (>= 1 0) -9223372036854775808 -9223372036854775808)])
                    (if (= 0 foobar.9.5) 0 9223372036854775807)))))
    (define L.func.2.3 (lambda (ball.4.7 ball.6.6) (call L.tmp.1.2)))
    (if (<= 0 1) -1271132888 2101306416)))
(check-by-interp '(module (define L.proc.0.1
                            (lambda (bar.8.1)
                              (let ([bat.7.2 (if (false)
                                                 (let ([bat.4.3 bar.8.1]) 1733388107)
                                                 (let ([foobar.2.4 -818241658]) foobar.2.4))])
                                (let ([bat.3.5 (* -1769976594 bat.7.2)])
                                  (if (!= bar.8.1 bar.8.1) 1 bar.8.1)))))
                          (if (<= 0 0) 1764584349 -9223372036854775808)
                    ))
(check-by-interp '(module (define L.proc.0.1
                            (lambda (ball.3.1)
                              (if (not (false))
                                  (call L.x.1.2)
                                  (let ([foobar.4.2 (let ([bat.9.3 ball.3.1]) 9223372036854775807)])
                                    (+ -9223372036854775808 ball.3.1)))))
                          (define L.x.1.2 (lambda () 1))
                    (let ([foobar.4.4 (let ([ball.1.5 453798193]) ball.1.5)])
                      (if (>= 9223372036854775807 foobar.4.4) 0 -1617493587))))
(check-by-interp '(module (define L.func.0.1
                            (lambda (bat.8.1)
                              (if (let ([bat.2.2 (* 9223372036854775807 bat.8.1)]) (true))
                                  (if (true)
                                      (if (< bat.8.1 -9223372036854775808) bat.8.1 bat.8.1)
                                      (if (= -9223372036854775808 bat.8.1) bat.8.1 bat.8.1))
                                  (call L.proc.1.2))))
                          (define L.proc.1.2 (lambda () (call L.func.0.1 954069433)))
                    (if (false)
                        (* 1337690701 9223372036854775807)
                        (call L.proc.1.2))))
(check-by-interp '(module (if (not (> 1 9223372036854775807))
                              (if (>= 1 1197468889) 9223372036854775807 1)
                              1)))
(check-by-interp '(module (define L.func.0.1
                            (lambda (foo.9.5 foo.2.4 bar.1.3 bat.7.2 foobar.4.1) -1458025903))
                          (call L.func.0.1 -9223372036854775808 1 -808937821 -9223372036854775808 0)
                    ))
(check-by-interp '(module (define L.tmp.0.1
                            (lambda (ball.6.4 bat.5.3 bar.8.2 foobar.0.1)
                              (let ([bat.2.5 ball.6.4])
                                (if (if (<= -9223372036854775808 bat.5.3)
                                        (>= -9223372036854775808 ball.6.4)
                                        (>= bat.5.3 2025307007))
                                    (+ bat.2.5 9223372036854775807)
                                    (if (<= bat.5.3 -9223372036854775808) 9223372036854775807 0)))))
                          (let ([ball.6.6 0]) ball.6.6)
                    ))
(check-by-interp '(module (define L.func.0.1
                            (lambda (ball.6.2 foobar.3.1)
                              (if (= 0 foobar.3.1)
                                  (+ -9223372036854775808 -9223372036854775808)
                                  (if (if (< ball.6.2 ball.6.2)
                                          (<= foobar.3.1 foobar.3.1)
                                          (= foobar.3.1 ball.6.2))
                                      (+ foobar.3.1 foobar.3.1)
                                      (if (= 1 foobar.3.1) ball.6.2 foobar.3.1)))))
                          (define L.x.1.2
                            (lambda (bar.0.3)
                              (let ([ball.1.4 (let ([bat.9.5 (let ([bat.2.6 1757280127]) bat.2.6)])
                                                (let ([ball.5.7 1]) -1128483887))])
                                (if (let ([foo.7.8 bar.0.3]) (> foo.7.8 foo.7.8))
                                    ball.1.4
                                    (+ ball.1.4 bar.0.3)))))
                    (define L.fn.2.3
                      (lambda ()
                        (if (let ([foobar.8.9 (+ -9223372036854775808 -1421853645)])
                              (not (>= 0 -1400373009)))
                            (+ -167927521 1)
                            (let ([ball.1.10 (* 1041085683 9223372036854775807)])
                              (let ([foo.4.11 ball.1.10]) 770292232)))))
                    (call L.x.1.2 1840464414)))
(check-by-interp '(module (define L.proc.0.1
                            (lambda (ball.4.3 foo.7.2 ball.2.1)
                              (call L.proc.0.1 9223372036854775807 ball.2.1 foo.7.2)))
                          (define L.func.1.2
                            (lambda (ball.1.9 bat.0.8 foo.7.7 ball.4.6 foobar.6.5 bar.3.4)
                              (let ([bar.3.10 (let ([ball.4.11 foo.7.7])
                                                (let ([foobar.5.12 ball.1.9]) -9223372036854775808))])
                                (call L.proc.0.1 bar.3.10 -780648786 bar.3.10))))
                    (let ([bat.0.13 -579691794]) 953357957)))
(check-by-interp '(module (let ([bar.5.1 (let ([ball.2.2 9223372036854775807]) -546026276)])
                            (if (!= bar.5.1 1) 9223372036854775807 2063023986))))
(check-by-interp '(module (define L.func.0.1
                            (lambda (foo.8.2 bar.2.1)
                              (if (not (let ([foo.8.3 foo.8.2]) (= foo.8.3 0)))
                                  (let ([foobar.6.4 (+ foo.8.2 0)]) (* 0 9223372036854775807))
                                  (let ([bat.7.5 (* 0 bar.2.1)])
                                    (if (!= bat.7.5 -9223372036854775808) bar.2.1 0)))))
                          (if (= 9223372036854775807 -315897602) 1 -9223372036854775808)
                    ))
(check-by-interp '(module (define L.fn.0.1
                            (lambda (foobar.3.2 ball.7.1)
                              (let ([bar.9.3 (let ([bat.4.4 (* 1 9223372036854775807)])
                                               (+ -9223372036854775808 bat.4.4))])
                                (let ([bat.4.5 9223372036854775807])
                                  (if (!= 1 bar.9.3) 9223372036854775807 ball.7.1)))))
                          (define L.x.1.2
                            (lambda (bat.2.6)
                              (let ([foobar.3.7 (let ([bat.4.8 (+ -1410706204 bat.2.6)])
                                                  (let ([bat.2.9 1]) -9223372036854775808))])
                                (* -152436426 0))))
                    (define L.proc.2.3
                      (lambda (foo.5.13 ball.7.12 foo.0.11 ball.8.10)
                        (let ([foobar.1.14 foo.5.13]) (+ 956544411 1))))
                    (+ 979460199 -1697959716)))
(check-by-interp
 '(module (define L.proc.0.1
            (lambda (foobar.1.6 bar.0.5 foobar.2.4 ball.8.3 bat.3.2 bar.5.1)
              (let ([bar.9.7 (if (let ([bar.7.8 -669410514]) (< bat.3.2 bat.3.2))
                                 (+ bar.5.1 ball.8.3)
                                 foobar.2.4)])
                (let ([ball.6.9 (let ([foo.4.10 ball.8.3]) 1)])
                  (if (<= foobar.2.4 1) 9223372036854775807 bat.3.2)))))
          (call L.proc.0.1 0 9223372036854775807 0 -1371550930 -1891086346 9223372036854775807)
    ))
(check-by-interp
 '(module (define L.x.0.1
            (lambda (bat.7.7 ball.9.6 foobar.3.5 ball.5.4 ball.4.3 bar.0.2 ball.2.1)
              (if (not (if (>= 388494724 ball.9.6)
                           (> ball.5.4 -9223372036854775808)
                           (< foobar.3.5 ball.5.4)))
                  (if (<= ball.4.3 bar.0.2)
                      0
                      (let ([ball.4.8 ball.5.4]) 1887946265))
                  foobar.3.5)))
          (define L.tmp.1.2
            (lambda (bat.7.14 ball.9.13 ball.5.12 foo.6.11 bar.0.10 ball.2.9)
              (if (true)
                  (* foo.6.11 9223372036854775807)
                  (if (let ([foobar.3.15 1]) (<= bar.0.10 ball.5.12))
                      (let ([ball.9.16 -9223372036854775808]) ball.9.16)
                      (let ([bat.7.17 1]) 1)))))
    (define L.tmp.2.3
      (lambda (bat.7.23 ball.2.22 foo.6.21 foobar.3.20 bar.8.19 bar.0.18)
        (let ([foobar.3.24 (if (let ([ball.2.25 258314756]) (!= bar.8.19 0))
                               bar.8.19
                               (let ([foo.6.26 -1809848824]) 9223372036854775807))])
          (if (< 1525021420 1)
              (call L.tmp.1.2 foobar.3.24 1 -1256996529 foo.6.21 -768559462 1067478227)
              (if (> 389818959 882297114) bar.8.19 ball.2.22)))))
    (let ([bar.0.27 1]) 1)))
(check-by-interp
 '(module (define L.tmp.0.1
            (lambda (foo.1.7 ball.6.6 bar.9.5 bat.3.4 ball.8.3 bat.0.2 ball.7.1) (* bat.3.4 bat.0.2)))
          (define L.func.1.2
            (lambda (foo.1.12 bar.2.11 foo.5.10 bat.3.9 bar.9.8)
              (let ([bat.3.13 1]) 9223372036854775807)))
    (define L.fn.2.3
      (lambda (ball.7.15 ball.8.14)
        (let ([bat.3.16 (if (>= ball.7.15 1)
                            (if (= ball.7.15 ball.7.15) ball.8.14 214741259)
                            (+ 1683358713 ball.8.14))])
          (call L.tmp.0.1 bat.3.16 ball.8.14 0 ball.7.15 9223372036854775807 ball.7.15 -2043460455))))
    (call L.tmp.0.1
          -9223372036854775808
          -9223372036854775808
          -9223372036854775808
          9223372036854775807
          -9223372036854775808
          1
          -9223372036854775808)))
(check-by-interp '(module (if (true)
                              (+ 1 -9223372036854775808)
                              (if (> 1383245321 0) 0 1))))
(check-by-interp
 '(module (define L.x.0.1
            (lambda (ball.0.7 foobar.1.6 foo.3.5 foobar.2.4 foo.6.3 foobar.5.2 ball.8.1)
              (call L.x.4.5 1)))
          (define L.func.1.2
            (lambda ()
              (let ([bar.9.8 9223372036854775807])
                (let ([foobar.1.9 bar.9.8])
                  (if (>= -577997854 foobar.1.9) -9223372036854775808 bar.9.8)))))
    (define L.fn.2.3
      (lambda ()
        (let ([ball.7.10 (+ 1 1)])
          (if (false)
              ball.7.10
              (let ([foobar.1.11 ball.7.10]) 1969054361)))))
    (define L.x.3.4
      (lambda (foobar.4.18 foobar.5.17 bar.9.16 foobar.2.15 ball.8.14 foo.3.13 ball.7.12)
        (call L.func.6.7
              0
              -9223372036854775808
              9223372036854775807
              25911444
              9223372036854775807
              foobar.4.18
              -9223372036854775808)))
    (define L.x.4.5
      (lambda (foobar.4.19)
        (call L.x.3.4 0 foobar.4.19 foobar.4.19 1 foobar.4.19 foobar.4.19 foobar.4.19)))
    (define L.x.5.6
      (lambda (foo.6.25 foo.3.24 foobar.4.23 bar.9.22 foobar.1.21 foobar.5.20)
        (let ([foobar.5.26 (let ([foobar.1.27 bar.9.22]) (let ([foo.6.28 foo.3.24]) foobar.1.27))])
          (if (let ([ball.8.29 bar.9.22]) (> foo.3.24 foo.6.25))
              (call L.x.0.1
                    -1863740769
                    9223372036854775807
                    foobar.4.23
                    foobar.5.26
                    foo.3.24
                    foobar.5.26
                    -1819248150)
              1))))
    (define L.func.6.7
      (lambda (foobar.2.36 foo.6.35 ball.0.34 ball.8.33 foo.3.32 foobar.1.31 foobar.5.30)
        (if (if (true)
                (let ([ball.0.37 foobar.2.36]) (> -1497437069 -9223372036854775808))
                (not (!= -1101838227 -1416967818)))
            (let ([ball.8.38 (+ foobar.2.36 foobar.2.36)]) (let ([foobar.1.39 0]) foobar.1.39))
            1)))
    (define L.fn.7.8
      (lambda ()
        (if (true)
            (if (not (> 0 100011461))
                (call L.x.5.6 -9223372036854775808 16140507 0 -1248542300 0 -1579752260)
                (if (= -9223372036854775808 471889533) 1 0))
            (if (if (>= 1 0)
                    (>= 0 -9223372036854775808)
                    (> 9223372036854775807 0))
                (call L.fn.7.8)
                (if (> 1 1) -444155079 9223372036854775807)))))
    (if (let ([foo.6.40 (if (let ([foobar.2.41 -9223372036854775808]) (true))
                            (let ([foobar.2.42
                                   (if (> 9223372036854775807 0) -1444900091 -9223372036854775808)])
                              foobar.2.42)
                            (if (true)
                                (let ([foobar.5.43 9223372036854775807]) foobar.5.43)
                                (if (= -9223372036854775808 1173781558) 0 1)))])
          (if (true)
              (let ([bar.9.44 0]) (true))
              (< 858519747 foo.6.40)))
        1
        (if (< 1 -1323259230)
            (call L.fn.2.3)
            (call L.fn.2.3)))))

;; !!!

; adapted example outputs for sequentialize-let
(check-equal? (sequentialize-let `(module (let ([x.1 5]
                                                [y.2 6])
                                            (+ x.1 y.2))))
              `(module (begin
                         (set! x.1 5)
                         (set! y.2 6)
                         (+ x.1 y.2))))
(check-equal? (sequentialize-let `(module (let ([y.2 6]
                                                [x.1 5])
                                            (+ x.1 y.2))))
              `(module (begin
                         (set! y.2 6)
                         (set! x.1 5)
                         (+ x.1 y.2))))
; custom seq-let tests
(check-equal? (sequentialize-let `(module 5)) `(module 5))
(check-equal? (sequentialize-let `(module (let ([x.1 1]
                                                [y.1 2])
                                            x.1)))
              `(module (begin
                         (set! x.1 1)
                         (set! y.1 2)
                         x.1)))
(check-equal? (sequentialize-let `(module (let ([x.1 1]
                                                [y.1 2])
                                            (let ([x.2 x.1]) x.2))))
              `(module (begin
                         (set! x.1 1)
                         (set! y.1 2)
                         (set! x.2 x.1)
                         x.2)))
(check-equal? (sequentialize-let `(module (if (let ([x.1 1]
                                                    [y.1 2])
                                                (let ([x.2 x.1]) (true)))
                                              (let ([x.1 2]) x.1)
                                              (let ([x.1 1]) x.1))))
              `(module (if (begin
                             (set! x.1 1)
                             (set! y.1 2)
                             (set! x.2 x.1)
                             (true))
                           (begin
                             (set! x.1 2)
                             x.1)
                           (begin
                             (set! x.1 1)
                             x.1))))

(check-equal? (sequentialize-let `(module (define L.label.1 (lambda (x.1 x.2) 3))
                                          (let ([y.1 5]
                                                [y.2 6])
                                            (call L.label.1 y.1 y.2))
                                    ))
              `(module (define L.label.1 (lambda (x.1 x.2) 3))
                       (begin
                         (set! y.1 5)
                         (set! y.2 6)
                         (call L.label.1 y.1 y.2))
                 ))

(check-equal? (sequentialize-let `(module (define L.label.1 (lambda (x.1 x.2) (let ([x.3 x.1]) x.3)))
                                          (let ([y.1 5]
                                                [y.2 6])
                                            (call L.label.1 y.1 y.2))
                                    ))
              `(module (define L.label.1
                         (lambda (x.1 x.2)
                           (begin
                             (set! x.3 x.1)
                             x.3)))
                       (begin
                         (set! y.1 5)
                         (set! y.2 6)
                         (call L.label.1 y.1 y.2))
                 ))
