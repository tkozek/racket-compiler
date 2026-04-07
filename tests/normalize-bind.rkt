#lang racket
(require rackunit
         cpsc411/langs/v2
         cpsc411/langs/v3
         (only-in "../imp-lang/normalize-bind.rkt" normalize-bind))

(define (check-imp-mf-lang-v3 p)
  (if (imp-mf-lang-v3? p) p #f))

(define (check-imp-cmf-lang-v3 p)
  (if (imp-cmf-lang-v3? p) p #f))

(define-syntax-rule (check-by-interp p)
  (check-equal? (interp-imp-cmf-lang-v3 (check-imp-cmf-lang-v3 (normalize-bind p)))
                (interp-imp-mf-lang-v3 (check-imp-mf-lang-v3 p))))

;;; Added by Trevor on 2026-03-18

(check-by-interp '(module (begin
                            (begin
                              (set! ball.4.2 -9223372036854775808)
                              (set! foo.1.1 1)
                              foo.1.1))))
(check-by-interp '(module (begin
                            (set! ball.7.2 (+ 1 9223372036854775807))
                            (set! ball.6.1 996577960)
                            -1528452922)))
(check-by-interp '(module (begin
                            (set! foobar.5.3 -9223372036854775808)
                            (set! bar.1.2 0)
                            (set! foobar.4.1 (+ 9223372036854775807 1))
                            foobar.5.3)))
(check-by-interp '(module (begin
                            (set! foobar.7.3 (+ 9223372036854775807 -68144516))
                            (set! foo.2.2 -612735698)
                            (set! bar.9.1 (* -937851344 1))
                            bar.9.1)))
(check-by-interp '(module (begin
                            (set! bar.8.2 (* 1768876961 2091480106))
                            (set! foo.0.1 -2078188405)
                            (begin
                              (set! bat.6.4 -830843178)
                              (set! bat.5.3 1)
                              bat.5.3))))
(check-by-interp '(module (begin
                            (set! ball.0.3 -9223372036854775808)
                            (set! bat.6.2 -9223372036854775808)
                            (set! bat.5.1 -9223372036854775808)
                            (* 1 bat.6.2))))
(check-by-interp '(module (begin
                            (begin
                              (set! foo.5.5 0)
                              (set! ball.6.4 9223372036854775807)
                              (set! foo.2.3 -9223372036854775808)
                              (set! bat.4.2 1)
                              (set! foo.7.1 1827770844)
                              1))))
(check-by-interp '(module (begin
                            (set! ball.4.1 1140216125)
                            (begin
                              (set! ball.4.7 ball.4.1)
                              (set! foobar.6.6 ball.4.1)
                              (set! foobar.3.5 ball.4.1)
                              (set! ball.0.4 ball.4.1)
                              (set! bat.5.3 ball.4.1)
                              (set! bat.1.2 ball.4.1)
                              foobar.3.5))))
(check-by-interp '(module (begin
                            (set! ball.4.2 9223372036854775807)
                            (set! foobar.7.1 -9223372036854775808)
                            (begin
                              (set! ball.4.5 0)
                              (set! foobar.3.4 9223372036854775807)
                              (set! bat.2.3 401318453)
                              ball.4.5))))
(check-by-interp '(module (begin
                            (set! bar.4.4 0)
                            (set! foobar.5.3 1833841538)
                            (set! ball.0.2 1)
                            (set! ball.1.1
                                  (begin
                                    (set! bat.3.8 1220973327)
                                    (set! bar.4.7 904195701)
                                    (set! ball.7.6 -541165341)
                                    (set! ball.1.5 -173234253)
                                    bar.4.7))
                            0)))
(check-by-interp '(module (begin
                            (set! bar.7.1
                                  (begin
                                    (set! bar.4.3 -75894610)
                                    (set! bar.7.2 -1246875017)
                                    bar.4.3))
                            (begin
                              (set! bar.9.8 -9223372036854775808)
                              (set! foo.8.7 bar.7.1)
                              (set! foobar.3.6 -1110697710)
                              (set! bat.2.5 bar.7.1)
                              (set! bat.5.4 1)
                              0))))
(check-by-interp '(module (begin
                            (set! bar.8.1
                                  (begin
                                    (set! foobar.4.6 1)
                                    (set! bar.8.5 -9223372036854775808)
                                    (set! ball.2.4 2047036712)
                                    (set! foobar.3.3 1919359218)
                                    (set! ball.6.2 -9223372036854775808)
                                    foobar.3.3))
                            (begin
                              (set! ball.1.8 0)
                              (set! ball.6.7 2126399608)
                              ball.1.8))))
(check-by-interp '(module (begin
                            (set! bat.1.2 9223372036854775807)
                            (set! foo.0.1 (+ 1458156976 1))
                            (begin
                              (set! bar.4.4 bat.1.2)
                              (set! ball.3.3
                                    (begin
                                      (set! bat.8.7 (* 1 1729076944))
                                      (set! foo.0.6 foo.0.1)
                                      (set! bat.1.5 (+ 0 -9223372036854775808))
                                      (* foo.0.6 bat.8.7)))
                              (begin
                                (set! bat.1.9 (* foo.0.1 bat.1.2))
                                (set! ball.7.8 bar.4.4)
                                (* 0 1))))))
(check-by-interp '(module (begin
                            (set! bar.0.4 (+ 1 -9223372036854775808))
                            (set! bat.7.3 -9223372036854775808)
                            (set! foo.9.2
                                  (begin
                                    (set! bar.6.6 9223372036854775807)
                                    (set! bar.0.5 -134004656)
                                    1))
                            (set! foo.8.1 (* 1 0))
                            (begin
                              (set! foo.3.10 983863554)
                              (set! ball.4.9 -9223372036854775808)
                              (set! foo.9.8 9223372036854775807)
                              (set! foo.8.7 foo.8.1)
                              foo.9.8))))
(check-by-interp '(module (begin
                            (set! foobar.8.3
                                  (begin
                                    (set! ball.1.8 -2056929169)
                                    (set! ball.3.7 -579595654)
                                    (set! bar.4.6 9223372036854775807)
                                    (set! ball.6.5 -9223372036854775808)
                                    (set! foobar.8.4 -9223372036854775808)
                                    ball.1.8))
                            (set! bat.0.2 (* -128242590 0))
                            (set! bar.5.1 -1070972855)
                            (begin
                              (set! bar.5.11 bat.0.2)
                              (set! ball.6.10 foobar.8.3)
                              (set! foobar.8.9 1)
                              bar.5.11))))
(check-by-interp '(module (begin
                            (set! foobar.4.4 -9223372036854775808)
                            (set! foobar.2.3
                                  (begin
                                    (set! foobar.4.8 -1164390901)
                                    (set! foobar.2.7 -13264410)
                                    (set! bar.1.6 1)
                                    (set! foobar.8.5 9223372036854775807)
                                    foobar.4.8))
                            (set! ball.6.2
                                  (begin
                                    (set! ball.6.11 1)
                                    (set! foobar.2.10 527653430)
                                    (set! ball.0.9 1855454698)
                                    -177762459))
                            (set! bar.1.1 9223372036854775807)
                            1254958062)))
(check-by-interp '(module (begin
                            (set! bar.0.6 (* -9223372036854775808 -9223372036854775808))
                            (set! bat.3.5 -9223372036854775808)
                            (set! bat.5.4 (* -9223372036854775808 9223372036854775807))
                            (set! foobar.8.3 -282715271)
                            (set! foo.2.2 1079535546)
                            (set! ball.1.1 0)
                            (begin
                              (set! ball.1.9 9223372036854775807)
                              (set! bar.0.8 9223372036854775807)
                              (set! bat.3.7 bat.3.5)
                              foobar.8.3))))
(check-by-interp '(module (begin
                            (set! foobar.3.3
                                  (begin
                                    (set! foobar.3.7 0)
                                    (set! foobar.1.6 (* -44807523 9223372036854775807))
                                    (set! foobar.7.5 9223372036854775807)
                                    (set! foobar.2.4 (* -9223372036854775808 9223372036854775807))
                                    foobar.3.7))
                            (set! foobar.1.2
                                  (begin
                                    (set! foobar.0.9 (* -9223372036854775808 9223372036854775807))
                                    (set! foobar.1.8 -9223372036854775808)
                                    -1026539425))
                            (set! foobar.0.1 (+ -432307559 0))
                            foobar.0.1)))
(check-by-interp '(module (begin
                            (begin
                              (set! ball.5.4
                                    (begin
                                      9223372036854775807))
                              (set! bat.8.3
                                    (begin
                                      (set! ball.0.7 -9223372036854775808)
                                      (set! bat.2.6 9223372036854775807)
                                      (set! ball.9.5 -9223372036854775808)
                                      ball.9.5))
                              (set! foo.3.2
                                    (begin
                                      (set! bat.7.9 9223372036854775807)
                                      (set! bat.8.8 -567636434)
                                      bat.8.8))
                              (set! bar.4.1 (+ 9223372036854775807 0))
                              (begin
                                (set! bat.7.12 0)
                                (set! ball.6.11 9223372036854775807)
                                (set! ball.5.10 -1293214889)
                                0)))))
(check-by-interp '(module (begin
                            (set! foo.8.2 -9223372036854775808)
                            (set! bar.6.1
                                  (begin
                                    (set! bar.6.6 -9223372036854775808)
                                    (set! ball.0.5
                                          (begin
                                            (set! bar.6.7 -9223372036854775808)
                                            bar.6.7))
                                    (set! ball.1.4 (+ -1436005507 1112271375))
                                    (set! foo.8.3 (* -9223372036854775808 -9223372036854775808))
                                    (* ball.1.4 1553839939)))
                            (begin
                              (set! foo.8.10 -1233593104)
                              (set! bar.6.9 0)
                              (set! bar.9.8 (* -1860181312 foo.8.2))
                              (+ -9223372036854775808 bar.9.8)))))
(check-by-interp '(module (begin
                            (set! bar.7.4
                                  (begin
                                    (begin
                                      (set! bat.4.6 9223372036854775807)
                                      (set! ball.8.5
                                            (begin
                                              (set! bat.4.11 -9223372036854775808)
                                              (set! bar.7.10 1822009732)
                                              (set! foobar.9.9 9223372036854775807)
                                              (set! bar.2.8 1)
                                              (set! bar.5.7 682989919)
                                              bar.7.10))
                                      (begin
                                        (set! bar.2.12 ball.8.5)
                                        ball.8.5))))
                            (set! ball.8.3 (+ 0 1))
                            (set! bar.2.2 (+ 9223372036854775807 -1050604408))
                            (set! foobar.9.1 (* -9223372036854775808 0))
                            (* -9223372036854775808 bar.2.2))))
(check-by-interp '(module (begin
                            (set! bat.3.5
                                  (begin
                                    (set! bat.3.8 1980064593)
                                    (set! foo.4.7 -9223372036854775808)
                                    (set! foobar.2.6 -1495882824)
                                    -737835353))
                            (set! ball.8.4 -9223372036854775808)
                            (set! bat.1.3 -9223372036854775808)
                            (set! foo.0.2 (+ -574027986 1926740047))
                            (set! foo.4.1
                                  (begin
                                    (set! foo.4.12 1142228157)
                                    (set! bat.3.11 -1751002496)
                                    (set! ball.9.10 9223372036854775807)
                                    (set! foobar.2.9 0)
                                    9223372036854775807))
                            (begin
                              (set! bat.3.13 bat.1.3)
                              -9223372036854775808))))
(check-by-interp '(module (begin
                            (begin
                              (set! bat.1.5 0)
                              (set! ball.3.4
                                    (begin
                                      (set! bat.8.10 0)
                                      (set! ball.0.9 -1954098237)
                                      (set! bar.6.8 0)
                                      (set! ball.3.7 9223372036854775807)
                                      (set! foo.7.6 1)
                                      ball.0.9))
                              (set! bar.6.3 1)
                              (set! ball.5.2
                                    (begin
                                      9223372036854775807))
                              (set! foo.7.1
                                    (begin
                                      (set! foo.2.16 1)
                                      (set! ball.3.15 1)
                                      (set! bat.4.14 1330702566)
                                      (set! bar.6.13 208041436)
                                      (set! foo.7.12 -9223372036854775808)
                                      (set! ball.0.11 9223372036854775807)
                                      1))
                              (begin
                                (set! bar.6.20 1)
                                (set! bat.8.19 foo.7.1)
                                (set! bat.1.18 bat.1.5)
                                (set! foo.2.17 ball.3.4)
                                2098290172)))))
(check-by-interp '(module (begin
                            (set! bat.6.6 1298534774)
                            (set! foobar.8.5
                                  (begin
                                    (set! foo.2.9 9223372036854775807)
                                    (set! bar.7.8 0)
                                    (set! bat.6.7 9223372036854775807)
                                    9223372036854775807))
                            (set! ball.0.4 (* 1 0))
                            (set! bar.4.3 (* 44651403 0))
                            (set! foo.2.2 (* 1 -859255124))
                            (set! foobar.5.1
                                  (begin
                                    (set! foobar.5.14 889520210)
                                    (set! bar.7.13 -2029578185)
                                    (set! foobar.8.12 1)
                                    (set! bar.4.11 -1045099983)
                                    (set! bat.6.10 1134122890)
                                    0))
                            (begin
                              (set! bar.7.18 bar.4.3)
                              (set! bat.1.17 foobar.8.5)
                              (set! foobar.5.16 bar.4.3)
                              (set! foobar.8.15 -9223372036854775808)
                              bar.4.3))))
(check-by-interp '(module (begin
                            (set! bat.1.3 (* 510727775 -9223372036854775808))
                            (set! bat.4.2 (* 0 -9223372036854775808))
                            (set! ball.2.1
                                  (begin
                                    (set! ball.2.5 490025338)
                                    (set! bar.5.4
                                          (begin
                                            (set! bat.1.11 1)
                                            (set! bat.4.10 -9223372036854775808)
                                            (set! bar.5.9 1)
                                            (set! ball.3.8 1)
                                            (set! bar.8.7 0)
                                            (set! bat.6.6 -322254623)
                                            -1276525534))
                                    (* bar.5.4 bar.5.4)))
                            (begin
                              (set! bat.1.13 (+ bat.1.3 -9223372036854775808))
                              (set! ball.2.12
                                    (begin
                                      (set! ball.0.15 1135101160)
                                      (set! bat.1.14 0)
                                      0))
                              (begin
                                (set! bat.6.18 1085391631)
                                (set! bat.9.17 ball.2.12)
                                (set! bat.1.16 bat.4.2)
                                bat.4.2)))))
(check-by-interp '(module (begin
                            (set! bar.7.3 (* -1698914420 1))
                            (set! bar.4.2 (* 1 0))
                            (set! bar.0.1 (* -9223372036854775808 -9223372036854775808))
                            (begin
                              (set! bar.4.4 9223372036854775807)
                              (begin
                                (set! bat.8.9 (* bar.4.4 bar.4.4))
                                (set! bar.7.8 13192944)
                                (set! bar.2.7
                                      (begin
                                        (set! foobar.5.14 9223372036854775807)
                                        (set! foo.6.13 -1745801350)
                                        (set! foobar.9.12 1511145156)
                                        (set! bar.7.11 bar.0.1)
                                        (set! bar.0.10 bar.4.4)
                                        foobar.5.14))
                                (set! ball.3.6
                                      (begin
                                        (set! bar.2.16 bar.7.3)
                                        (set! bat.1.15 0)
                                        1))
                                (set! bar.0.5
                                      (begin
                                        (set! foobar.5.20 bar.4.4)
                                        (set! foo.6.19 1)
                                        (set! ball.3.18 bar.7.3)
                                        (set! bat.8.17 bar.7.3)
                                        1))
                                1)))))
(check-by-interp '(module (begin
                            (set! bat.6.6 (+ 9223372036854775807 9223372036854775807))
                            (set! bar.5.5 0)
                            (set! foobar.0.4 (+ 9223372036854775807 0))
                            (set! ball.1.3 (+ 149382600 1))
                            (set! foobar.9.2 -9223372036854775808)
                            (set! bar.3.1 (+ 9223372036854775807 -9223372036854775808))
                            (begin
                              (set! bar.3.8
                                    (begin
                                      (set! bar.3.12 0)
                                      (set! foobar.9.11 foobar.9.2)
                                      (set! ball.1.10 1)
                                      (set! bar.5.9 1085340665)
                                      0))
                              (set! bar.5.7
                                    (begin
                                      (set! bar.8.14 foobar.9.2)
                                      (set! ball.1.13 foobar.9.2)
                                      -9223372036854775808))
                              (begin
                                (set! foo.2.19 1)
                                (set! bar.5.18 bar.5.7)
                                (set! ball.1.17 bat.6.6)
                                (set! foobar.9.16 bat.6.6)
                                (set! foobar.0.15 1)
                                foo.2.19)))))
(check-by-interp '(module (begin
                            (set! foobar.1.6 (+ 221377605 -1076871737))
                            (set! bar.8.5
                                  (begin
                                    (set! bar.5.10 (+ 0 1))
                                    (set! ball.6.9
                                          (begin
                                            (set! bar.5.16 -1463044307)
                                            (set! ball.2.15 1)
                                            (set! bar.8.14
                                                  (begin
                                                    (set! ball.6.19 0)
                                                    (set! bat.7.18 9223372036854775807)
                                                    (set! bar.8.17 -9223372036854775808)
                                                    1343302930))
                                            (set! ball.4.13 (+ -438824419 -1777497567))
                                            (set! bat.3.12 -885273077)
                                            (set! bat.7.11 (* 1 1))
                                            (+ -1921282404 0)))
                                    (set! bat.9.8 1)
                                    (set! ball.2.7 -134738152)
                                    (+ 0 bat.9.8)))
                            (set! bat.7.4 -9223372036854775808)
                            (set! ball.4.3 (* 1 1))
                            (set! bat.9.2 (* -9223372036854775808 1))
                            (set! bat.0.1
                                  (begin
                                    1877569491))
                            0)))
(check-by-interp '(module (begin
                            (set! ball.1.2
                                  (begin
                                    (set! ball.1.8
                                          (begin
                                            (set! ball.5.11 0)
                                            (set! bat.0.10 0)
                                            (set! foo.8.9 0)
                                            bat.0.10))
                                    (set! bat.0.7
                                          (begin
                                            (set! bat.0.15 233203269)
                                            (set! foobar.4.14 9223372036854775807)
                                            (set! bar.9.13 1)
                                            (set! ball.5.12 -9223372036854775808)
                                            -9223372036854775808))
                                    (set! foobar.4.6 (* 9223372036854775807 0))
                                    (set! foo.8.5 (+ 1 -2129718472))
                                    (set! foobar.6.4 (+ 417598272 -504836775))
                                    (set! ball.5.3 (+ -252477011 1937594448))
                                    (begin
                                      (set! foo.2.19 foobar.4.6)
                                      (set! foobar.6.18 -226843481)
                                      (set! ball.1.17 foobar.4.6)
                                      (set! foobar.4.16 foobar.6.4)
                                      ball.1.17)))
                            (set! foobar.4.1 -603343741)
                            (begin
                              (set! ball.1.22 (+ 1114260743 ball.1.2))
                              (set! foo.8.21 (+ 1 1))
                              (set! foobar.6.20 ball.1.2)
                              (begin
                                (set! bar.3.26 ball.1.22)
                                (set! ball.1.25 foo.8.21)
                                (set! foo.8.24 ball.1.22)
                                (set! bat.0.23 foobar.6.20)
                                0)))))
(check-by-interp '(module (begin
                            (set! bar.1.5 (+ -9223372036854775808 1))
                            (set! bar.9.4 -1263740488)
                            (set! bat.2.3
                                  (begin
                                    (set! foo.5.8 (* 998929959 -9223372036854775808))
                                    (set! bat.8.7 -2034793604)
                                    (set! bat.2.6
                                          (begin
                                            (set! foo.5.10 -9223372036854775808)
                                            (set! bar.6.9 2110479097)
                                            bar.6.9))
                                    (begin
                                      (set! bar.6.15 -1235010588)
                                      (set! bar.9.14 9223372036854775807)
                                      (set! bat.7.13 9223372036854775807)
                                      (set! foo.5.12 0)
                                      (set! bat.8.11 1)
                                      bar.6.15)))
                            (set! foo.3.2 (+ -9223372036854775808 1))
                            (set! bat.8.1
                                  (begin
                                    (set! bat.7.19 -1568444655)
                                    (set! foo.4.18 -9223372036854775808)
                                    (set! bat.0.17
                                          (begin
                                            (set! foo.3.22 1)
                                            (set! bar.9.21 -528292093)
                                            (set! bar.1.20 0)
                                            -1447541200))
                                    (set! bar.1.16 -1613855170)
                                    (* 9223372036854775807 bat.7.19)))
                            (begin
                              (set! foo.3.25 1513905621)
                              (set! bar.1.24
                                    (begin
                                      9223372036854775807))
                              (set! bat.0.23 0)
                              (begin
                                (set! bat.2.28 bar.1.24)
                                (set! bar.9.27 1)
                                (set! foo.3.26 bar.1.24)
                                1070018088)))))
(check-by-interp '(module (begin
                            (set! bar.0.6 0)
                            (set! ball.6.5
                                  (begin
                                    (set! bar.0.10
                                          (begin
                                            (set! foo.3.13 0)
                                            (set! foo.1.12 0)
                                            (set! foobar.7.11 -1502967641)
                                            0))
                                    (set! bar.5.9 9223372036854775807)
                                    (set! ball.9.8
                                          (begin
                                            (set! bar.4.19 -9223372036854775808)
                                            (set! ball.6.18 0)
                                            (set! ball.9.17 9223372036854775807)
                                            (set! foobar.2.16 -9223372036854775808)
                                            (set! bar.0.15 -9223372036854775808)
                                            (set! foobar.7.14 1)
                                            -9223372036854775808))
                                    (set! foo.1.7
                                          (begin
                                            (set! foobar.7.24 0)
                                            (set! bar.0.23 -9223372036854775808)
                                            (set! foobar.2.22 -9223372036854775808)
                                            (set! bat.8.21 -1938910922)
                                            (set! ball.9.20 995325664)
                                            1))
                                    bar.0.10))
                            (set! foobar.7.4
                                  (begin
                                    (set! ball.9.29 1)
                                    (set! bar.5.28 9223372036854775807)
                                    (set! foo.1.27
                                          (begin
                                            (set! ball.9.34 -1417838415)
                                            (set! bar.0.33 9223372036854775807)
                                            (set! bar.5.32 -286768514)
                                            (set! foobar.7.31 0)
                                            (set! foobar.2.30 -9223372036854775808)
                                            385534009))
                                    (set! bat.8.26 1641860413)
                                    (set! bar.4.25 (* -9223372036854775808 1))
                                    (* 0 2040049431)))
                            (set! bar.5.3 (+ 9223372036854775807 9223372036854775807))
                            (set! foobar.2.2 -9223372036854775808)
                            (set! bat.8.1 -9223372036854775808)
                            (begin
                              (set! bar.0.36
                                    (begin
                                      (set! bar.4.39 ball.6.5)
                                      (set! foobar.2.38 0)
                                      (set! bar.0.37 bat.8.1)
                                      1))
                              (set! foo.1.35 (+ foobar.2.2 -9223372036854775808))
                              (begin
                                (set! ball.6.42 foobar.2.2)
                                (set! foo.3.41 bat.8.1)
                                (set! ball.9.40 bat.8.1)
                                0)))))
(check-by-interp '(module (begin
                            (set! bar.1.4 1145225124)
                            (set! bat.9.3 (* 0 -9223372036854775808))
                            (set! bar.7.2
                                  (begin
                                    (set! bar.1.8
                                          (begin
                                            (set! foo.0.10 -9223372036854775808)
                                            (set! ball.4.9
                                                  (begin
                                                    (set! foo.0.16 -746190367)
                                                    (set! foobar.5.15 -876251589)
                                                    (set! foo.6.14 0)
                                                    (set! bar.7.13 -9223372036854775808)
                                                    (set! bar.3.12 9223372036854775807)
                                                    (set! bar.1.11 1)
                                                    -1057057431))
                                            (* 0 -9223372036854775808)))
                                    (set! bat.8.7 1)
                                    (set! bar.7.6 (* -9223372036854775808 -1581008192))
                                    (set! foobar.2.5
                                          (begin
                                            (set! bar.1.21
                                                  (begin
                                                    (set! bat.9.23 -1606195130)
                                                    (set! foo.0.22 1)
                                                    -1755998681))
                                            (set! foo.6.20 0)
                                            (set! foobar.5.19 (* 9223372036854775807 51983263))
                                            (set! foobar.2.18 (+ 1 -9223372036854775808))
                                            (set! ball.4.17
                                                  (begin
                                                    (set! bar.7.29 0)
                                                    (set! bar.1.28 -849060432)
                                                    (set! foo.6.27 9223372036854775807)
                                                    (set! bat.9.26 1)
                                                    (set! foo.0.25 1866960197)
                                                    (set! bat.8.24 -862348842)
                                                    -9223372036854775808))
                                            (+ -1762859866 -1973749130)))
                                    (begin
                                      (set! foobar.5.35
                                            (begin
                                              (set! ball.4.40 1)
                                              (set! bat.8.39 985023473)
                                              (set! foo.6.38 1335237925)
                                              (set! foobar.2.37 bar.1.8)
                                              (set! bar.1.36 1873552019)
                                              9223372036854775807))
                                      (set! bar.7.34
                                            (begin
                                              (set! bar.7.43 -1084213429)
                                              (set! bat.9.42 foobar.2.5)
                                              (set! foobar.2.41 9223372036854775807)
                                              79735053))
                                      (set! bat.8.33
                                            (begin
                                              (set! foobar.2.47 -1284398587)
                                              (set! foo.0.46 -9223372036854775808)
                                              (set! ball.4.45 1515555315)
                                              (set! bar.1.44 foobar.2.5)
                                              bat.8.7))
                                      (set! bar.3.32 (+ bat.8.7 1))
                                      (set! foo.0.31 -727438556)
                                      (set! bar.1.30 bar.7.6)
                                      (* foobar.2.5 foo.0.31))))
                            (set! bat.8.1 9223372036854775807)
                            (begin
                              (set! bar.3.52 (+ -9223372036854775808 -9223372036854775808))
                              (set! foobar.2.51 (+ 0 1))
                              (set! bar.1.50 (* bar.1.4 bat.8.1))
                              (set! bar.7.49
                                    (begin
                                      (set! bar.3.55 (+ 1345476858 844796380))
                                      (set! bar.7.54 (* 1464754713 -9223372036854775808))
                                      (set! bat.8.53 1241238073)
                                      bar.3.55))
                              (set! foo.6.48 -220903261)
                              (begin
                                (begin
                                  1))))))
;;; Added by Trevor on 2026-03-18
