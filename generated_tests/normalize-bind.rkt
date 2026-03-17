#lang racket
(require rackunit
         cpsc411/langs/v3
         (only-in "../normalize-bind.rkt" normalize-bind))
(define-syntax-rule (check-by-interp p)
  (check-equal? (interp-imp-mf-lang-v3 (imp-cmf-lang-v3? p))
                (interp-imp-cmf-lang-v3 (imp-cmf-lang-v3? (normalize-bind p)))))

;;; Added by Trevor on 2026-03-17

(check-by-interp '(module (begin
                            (begin
                              (set! bat.2.3 -221497923)
                              (set! foo.5.2 1011344925)
                              (set! ball.0.1 -379038455)
                              -9223372036854775808))))
(check-by-interp '(module (begin
                            (set! bat.9.3 (+ 0 1629516643))
                            (set! bar.7.2 -205891862)
                            (set! bat.6.1 (* 9223372036854775807 1))
                            (begin
                              (set! bar.0.5 0)
                              (set! bat.9.4 bat.6.1)
                              bat.9.4))))
(check-by-interp '(module (begin
                            (set! foobar.9.3
                                  (begin
                                    (set! ball.3.5 -1777136459)
                                    (set! foo.2.4 -9223372036854775808)
                                    1))
                            (set! foo.2.2 -9223372036854775808)
                            (set! ball.6.1 -9223372036854775808)
                            foobar.9.3)))
(check-by-interp '(module (begin
                            (set! foo.3.2 (* -9223372036854775808 9223372036854775807))
                            (set! foo.0.1 -914342082)
                            (begin
                              (set! bar.1.5 (+ foo.0.1 -885417376))
                              (set! bat.2.4 0)
                              (set! bat.4.3 foo.3.2)
                              bat.4.3))))
(check-by-interp '(module (begin
                            (set! bar.0.3 -9223372036854775808)
                            (set! bar.6.2 (* 0 9223372036854775807))
                            (set! foo.9.1 (* 1 9223372036854775807))
                            (begin
                              (set! ball.1.5 -1841344930)
                              (set! bat.2.4 441144174)
                              bar.0.3))))
(check-by-interp '(module (begin
                            (set! bat.5.2
                                  (begin
                                    (set! foo.8.8 9223372036854775807)
                                    (set! bat.5.7 -506684787)
                                    (set! bat.6.6 9223372036854775807)
                                    (set! bar.0.5 -1645783834)
                                    (set! foo.3.4 9223372036854775807)
                                    (set! bar.2.3 9223372036854775807)
                                    bat.6.6))
                            (set! bar.2.1 0)
                            (begin
                              0))))
(check-by-interp '(module (begin
                            (set! foo.5.4 (+ -9223372036854775808 1))
                            (set! ball.7.3 (* 0 -2016805289))
                            (set! foo.2.2 (+ 9223372036854775807 -9223372036854775808))
                            (set! bat.3.1
                                  (begin
                                    (set! foo.5.5 -1474679710)
                                    foo.5.5))
                            (begin
                              (set! bat.3.7 0)
                              (set! bat.0.6 foo.5.4)
                              ball.7.3))))
(check-by-interp '(module (begin
                            (set! bar.2.4
                                  (begin
                                    (set! ball.9.7 0)
                                    (set! foobar.1.6 2101277471)
                                    (set! foo.7.5 9223372036854775807)
                                    ball.9.7))
                            (set! foo.7.3 1)
                            (set! foobar.1.2 (* -278219884 1))
                            (set! foo.0.1 (* 1794895836 1))
                            (begin
                              (set! foo.7.10 foo.0.1)
                              (set! foobar.1.9 foobar.1.2)
                              (set! foo.4.8 bar.2.4)
                              282723720))))
(check-by-interp '(module (begin
                            (set! bat.6.5 (* 233038019 -9223372036854775808))
                            (set! bat.5.4 (+ 9223372036854775807 -9223372036854775808))
                            (set! bat.9.3 (+ -9223372036854775808 0))
                            (set! foo.4.2 (+ -1433008054 1))
                            (set! foo.8.1 -9223372036854775808)
                            (begin
                              -9223372036854775808))))
(check-by-interp '(module (begin
                            (set! foo.1.3
                                  (begin
                                    (set! bar.6.8 1)
                                    (set! bat.5.7 9223372036854775807)
                                    (set! foo.8.6 9223372036854775807)
                                    (set! bat.2.5 -1200806160)
                                    (set! ball.3.4 9223372036854775807)
                                    foo.8.6))
                            (set! bar.6.2
                                  (begin
                                    (set! bat.7.9 9223372036854775807)
                                    bat.7.9))
                            (set! ball.3.1 9223372036854775807)
                            bar.6.2)))
(check-by-interp '(module (begin
                            (set! bar.0.3 (+ 9223372036854775807 1))
                            (set! bat.7.2
                                  (begin
                                    (set! foobar.2.9 9223372036854775807)
                                    (set! foo.3.8 9223372036854775807)
                                    (set! ball.4.7 9223372036854775807)
                                    (set! bat.7.6 -9223372036854775808)
                                    (set! bat.9.5 9223372036854775807)
                                    (set! bar.5.4 -9223372036854775808)
                                    0))
                            (set! bar.5.1 0)
                            (* bar.5.1 bat.7.2))))
(check-by-interp '(module (begin
                            (set! foobar.0.5 0)
                            (set! bat.8.4 (* -1618983501 65976537))
                            (set! bar.3.3 (+ 1 -9223372036854775808))
                            (set! bar.9.2
                                  (begin
                                    (set! bat.8.6 -1002622587)
                                    1))
                            (set! bar.5.1 (* -953737273 9223372036854775807))
                            (begin
                              (set! bar.9.11 bat.8.4)
                              (set! foobar.0.10 bar.9.2)
                              (set! bat.8.9 bar.3.3)
                              (set! bat.7.8 foobar.0.5)
                              (set! bar.4.7 bar.5.1)
                              932461802))))
(check-by-interp '(module (begin
                            (set! bar.7.2
                                  (begin
                                    (set! foobar.1.7 -9223372036854775808)
                                    (set! foobar.0.6 0)
                                    (set! ball.3.5 0)
                                    (set! bar.7.4 -9223372036854775808)
                                    (set! bat.4.3 -9223372036854775808)
                                    ball.3.5))
                            (set! foobar.9.1 -9223372036854775808)
                            (begin
                              (set! bat.4.11 bar.7.2)
                              (set! bar.7.10 bar.7.2)
                              (set! foobar.1.9 bar.7.2)
                              (set! bar.5.8 -2053680267)
                              9223372036854775807))))
(check-by-interp '(module (begin
                            (set! bat.7.6 (+ 9223372036854775807 9223372036854775807))
                            (set! ball.6.5 1)
                            (set! ball.9.4 1)
                            (set! foobar.5.3 1)
                            (set! bat.4.2 (+ -9223372036854775808 -9223372036854775808))
                            (set! bar.0.1
                                  (begin
                                    (set! ball.9.9 1)
                                    (set! bar.1.8 -9223372036854775808)
                                    (set! bar.2.7 -1715152588)
                                    bar.1.8))
                            (begin
                              (set! foobar.5.11 -369809588)
                              (set! bat.7.10 1)
                              -1836735779))))
(check-by-interp '(module (begin
                            (set! foo.3.5
                                  (begin
                                    (set! bar.0.7
                                          (begin
                                            (set! bar.6.10 0)
                                            (set! foo.3.9 (* 1965244460 -9223372036854775808))
                                            (set! bat.4.8 -9223372036854775808)
                                            bar.6.10))
                                    (set! ball.2.6 (* 1 9223372036854775807))
                                    (begin
                                      (set! bar.6.12 -1754290607)
                                      (set! bar.0.11 0)
                                      (+ 1 9223372036854775807))))
                            (set! bar.0.4 -677579451)
                            (set! foo.1.3 1063885642)
                            (set! foobar.8.2 (* 9223372036854775807 -9223372036854775808))
                            (set! bar.6.1 (* 9223372036854775807 9223372036854775807))
                            bar.0.4)))
(check-by-interp '(module (begin
                            (set! bat.9.5 (* -2117808739 1))
                            (set! foobar.3.4 (* 9223372036854775807 9223372036854775807))
                            (set! ball.0.3 -9223372036854775808)
                            (set! bat.4.2 -9223372036854775808)
                            (set! foobar.1.1
                                  (begin
                                    (set! ball.8.11 1)
                                    (set! bat.2.10 -9223372036854775808)
                                    (set! bat.4.9 1)
                                    (set! foo.5.8 9223372036854775807)
                                    (set! bat.9.7 1866204504)
                                    (set! foobar.1.6 0)
                                    bat.4.9))
                            (begin
                              (set! bat.2.17 bat.9.5)
                              (set! foo.5.16 bat.9.5)
                              (set! foobar.3.15 bat.4.2)
                              (set! foobar.1.14 -9223372036854775808)
                              (set! bat.7.13 ball.0.3)
                              (set! ball.0.12 foobar.3.4)
                              foo.5.16))))
(check-by-interp '(module (begin
                            (set! foobar.6.3
                                  (begin
                                    (set! ball.7.4 -9223372036854775808)
                                    (+ -9223372036854775808 ball.7.4)))
                            (set! foobar.1.2 (* 1 0))
                            (set! foo.9.1 -9223372036854775808)
                            (begin
                              (set! foobar.0.9 (* foo.9.1 foobar.1.2))
                              (set! foo.9.8
                                    (begin
                                      (set! foobar.5.14 0)
                                      (set! bat.2.13 -1065627391)
                                      (set! foo.8.12 foobar.1.2)
                                      (set! foobar.6.11 9223372036854775807)
                                      (set! foobar.0.10 1)
                                      9223372036854775807))
                              (set! foo.8.7 (* foobar.1.2 9223372036854775807))
                              (set! foobar.6.6 foobar.1.2)
                              (set! bat.2.5 (+ foobar.1.2 foobar.6.3))
                              (+ foobar.1.2 772107177)))))
(check-by-interp '(module (begin
                            (set! ball.6.5 (+ -9223372036854775808 -1314852090))
                            (set! bar.2.4
                                  (begin
                                    (set! bat.8.11 1191242744)
                                    (set! foobar.0.10 9223372036854775807)
                                    (set! bar.4.9 0)
                                    (set! foo.7.8 9223372036854775807)
                                    (set! foobar.5.7 -9223372036854775808)
                                    (set! foo.3.6 -9223372036854775808)
                                    9223372036854775807))
                            (set! foo.7.3 (+ 9223372036854775807 -9223372036854775808))
                            (set! bar.4.2 -9223372036854775808)
                            (set! foobar.5.1 -1802377507)
                            (begin
                              (set! foo.3.15 ball.6.5)
                              (set! bar.4.14 -84655658)
                              (set! ball.6.13 1)
                              (set! foo.7.12 1)
                              -9223372036854775808))))
(check-by-interp '(module (begin
                            (set! foo.1.4 (+ 0 613576602))
                            (set! foo.9.3 (* -2013943027 9223372036854775807))
                            (set! bar.2.2 -9223372036854775808)
                            (set! ball.5.1 (* 1 1))
                            (begin
                              (set! bat.6.6 foo.9.3)
                              (set! bar.2.5
                                    (begin
                                      (set! bat.6.10
                                            (begin
                                              (set! foo.9.15 bar.2.2)
                                              (set! ball.7.14 -9223372036854775808)
                                              (set! bat.4.13 foo.9.3)
                                              (set! bat.6.12 bar.2.2)
                                              (set! bat.0.11 0)
                                              ball.7.14))
                                      (set! bar.2.9
                                            (begin
                                              1580420111))
                                      (set! foo.1.8 bar.2.2)
                                      (set! ball.3.7 (* bar.2.2 bar.2.2))
                                      (begin
                                        (set! ball.5.19 1857002781)
                                        (set! foo.1.18 1)
                                        (set! bar.2.17 bar.2.9)
                                        (set! ball.3.16 -9223372036854775808)
                                        0)))
                              (* bar.2.5 bat.6.6)))))
(check-by-interp '(module (begin
                            (set! bar.3.5
                                  (begin
                                    (begin
                                      (set! bar.2.8 (* -768531464 1))
                                      (set! bat.4.7 (+ 838574190 9223372036854775807))
                                      (set! bat.5.6
                                            (begin
                                              (set! foo.7.13 1)
                                              (set! bat.8.12 -1369048151)
                                              (set! bar.3.11 1)
                                              (set! foobar.6.10 -587573745)
                                              (set! bar.2.9 -9223372036854775808)
                                              foobar.6.10))
                                      (+ -1082669922 bar.2.8))))
                            (set! foo.9.4 1)
                            (set! bat.1.3
                                  (begin
                                    (begin
                                      (* -259719214 1))))
                            (set! bat.0.2 (+ 0 -9223372036854775808))
                            (set! foo.7.1 (* 0 -898625705))
                            (begin
                              (set! bar.3.15 134583888)
                              (set! foobar.6.14 bat.1.3)
                              (begin
                                (set! bat.0.17 foo.9.4)
                                (set! bat.4.16 -198430279)
                                bat.1.3)))))
(check-by-interp '(module (begin
                            (begin
                              (set! foo.3.3 (* 534052538 2140352763))
                              (set! bat.7.2
                                    (begin
                                      (set! foo.5.9 -9223372036854775808)
                                      (set! foo.3.8 0)
                                      (set! ball.2.7
                                            (begin
                                              (set! bat.0.12 1)
                                              (set! foo.3.11 -9223372036854775808)
                                              (set! foobar.8.10 0)
                                              -9223372036854775808))
                                      (set! foobar.1.6 1294878375)
                                      (set! bat.6.5 1034438977)
                                      (set! bat.0.4
                                            (begin
                                              (set! foo.3.18 0)
                                              (set! bat.7.17 2106732367)
                                              (set! ball.2.16 1)
                                              (set! bat.9.15 0)
                                              (set! foobar.1.14 -9223372036854775808)
                                              (set! bat.6.13 1115209632)
                                              foobar.1.14))
                                      (* 1043987471 -1675678395)))
                              (set! ball.2.1 (+ 0 0))
                              (begin
                                (set! foo.5.20 (* ball.2.1 9223372036854775807))
                                (set! bat.0.19 0)
                                (begin
                                  (set! foo.5.21 0)
                                  -151265445))))))
(check-by-interp '(module (begin
                            (set! ball.3.2 (* 0 -1349273457))
                            (set! ball.8.1
                                  (begin
                                    (set! ball.2.6
                                          (begin
                                            (set! foo.7.8 (+ 133471369 9223372036854775807))
                                            (set! ball.2.7 1)
                                            (+ 0 foo.7.8)))
                                    (set! foo.1.5
                                          (begin
                                            (set! bar.4.14
                                                  (begin
                                                    (set! foo.9.17 9223372036854775807)
                                                    (set! ball.2.16 1)
                                                    (set! ball.0.15 -83458641)
                                                    -9223372036854775808))
                                            (set! foobar.6.13 9223372036854775807)
                                            (set! foo.9.12 -9223372036854775808)
                                            (set! ball.3.11 (* 0 884526982))
                                            (set! foo.1.10 (+ 337160526 1))
                                            (set! bat.5.9
                                                  (begin
                                                    (set! foo.9.20 9223372036854775807)
                                                    (set! foo.1.19 -9223372036854775808)
                                                    (set! ball.3.18 0)
                                                    ball.3.18))
                                            9223372036854775807))
                                    (set! ball.8.4 0)
                                    (set! foobar.6.3 1)
                                    ball.8.4))
                            (+ 456159787 1))))
(check-by-interp '(module (begin
                            (set! foobar.8.2 (* 0 -1850345870))
                            (set! bat.0.1 (* 9223372036854775807 1))
                            (begin
                              (begin
                                (set! bar.6.8 (+ bat.0.1 1400550314))
                                (set! bar.1.7
                                      (begin
                                        (set! bar.6.13 bat.0.1)
                                        (set! bar.9.12 foobar.8.2)
                                        (set! foo.5.11 foobar.8.2)
                                        (set! foobar.8.10 -9223372036854775808)
                                        (set! bat.0.9 foobar.8.2)
                                        -1410965560))
                                (set! bar.9.6 bat.0.1)
                                (set! foobar.8.5 foobar.8.2)
                                (set! bar.2.4 -339016950)
                                (set! foo.5.3
                                      (begin
                                        (set! bat.0.19 -9223372036854775808)
                                        (set! foobar.8.18 187755814)
                                        (set! bat.3.17 bat.0.1)
                                        (set! bat.7.16 9223372036854775807)
                                        (set! bar.2.15 foobar.8.2)
                                        (set! foo.5.14 bat.0.1)
                                        -9223372036854775808))
                                (begin
                                  (set! bar.2.23 -9223372036854775808)
                                  (set! bar.9.22 0)
                                  (set! bar.1.21 1935752451)
                                  (set! bat.0.20 0)
                                  1))))))
(check-by-interp '(module (begin
                            (set! foobar.2.2
                                  (begin
                                    (set! foo.1.5
                                          (begin
                                            (set! foobar.5.10 9223372036854775807)
                                            (set! foo.4.9 1)
                                            (set! bat.3.8 1102731392)
                                            (set! foobar.2.7 -846952656)
                                            (set! foobar.8.6 -9223372036854775808)
                                            foobar.2.7))
                                    (set! bar.7.4 (* 1 1))
                                    (set! foobar.9.3
                                          (begin
                                            (set! foo.1.15 1)
                                            (set! bat.3.14 -9223372036854775808)
                                            (set! ball.6.13 1567155926)
                                            (set! foo.0.12 9223372036854775807)
                                            (set! foobar.5.11 2056829097)
                                            -373355769))
                                    foo.1.5))
                            (set! ball.6.1
                                  (begin
                                    (set! foobar.9.20 0)
                                    (set! foobar.8.19
                                          (begin
                                            (set! foobar.9.25 -9223372036854775808)
                                            (set! foo.4.24 9223372036854775807)
                                            (set! foobar.8.23 9223372036854775807)
                                            (set! foobar.5.22 0)
                                            (set! foo.0.21 -253096569)
                                            1055832437))
                                    (set! foo.0.18 (+ 468411223 9223372036854775807))
                                    (set! ball.6.17
                                          (begin
                                            0))
                                    (set! foo.1.16 (* -9223372036854775808 -9223372036854775808))
                                    foo.0.18))
                            foobar.2.2)))
(check-by-interp '(module (begin
                            (set! bar.2.4
                                  (begin
                                    (set! bat.0.10 (* 0 0))
                                    (set! foobar.5.9
                                          (begin
                                            (set! bat.8.13 1)
                                            (set! foobar.5.12 -9223372036854775808)
                                            (set! ball.4.11 -1802204297)
                                            -9223372036854775808))
                                    (set! bat.8.8 (+ 1 1))
                                    (set! bat.7.7 (+ 9223372036854775807 9223372036854775807))
                                    (set! ball.6.6 0)
                                    (set! bar.1.5 (+ 9223372036854775807 -1764768646))
                                    (+ bat.0.10 bat.7.7)))
                            (set! ball.6.3 -1875098768)
                            (set! bat.0.2
                                  (begin
                                    (set! bar.2.18
                                          (begin
                                            (set! ball.4.23 232028953)
                                            (set! bat.0.22 121511599)
                                            (set! bat.8.21 9223372036854775807)
                                            (set! ball.6.20 9223372036854775807)
                                            (set! foobar.3.19 -1833293021)
                                            9223372036854775807))
                                    (set! ball.4.17 (+ 1581698950 -1372666896))
                                    (set! ball.6.16 1)
                                    (set! bar.1.15 9223372036854775807)
                                    (set! bat.0.14 9223372036854775807)
                                    (* 846793481 0)))
                            (set! bar.1.1 -9223372036854775808)
                            (begin
                              (set! foobar.9.29 bar.1.1)
                              (set! foobar.3.28 bar.2.4)
                              (set! bar.2.27 (* ball.6.3 0))
                              (set! bat.8.26 (* bat.0.2 9223372036854775807))
                              (set! ball.6.25 (* 9223372036854775807 bar.2.4))
                              (set! foobar.5.24 -9223372036854775808)
                              (begin
                                -9223372036854775808)))))
(check-by-interp '(module (begin
                            (set! foobar.0.3
                                  (begin
                                    (set! foobar.7.7
                                          (begin
                                            (set! foobar.7.8 1)
                                            foobar.7.8))
                                    (set! foobar.3.6 (* 0 192619849))
                                    (set! ball.1.5
                                          (begin
                                            (set! ball.9.10 1265590086)
                                            (set! ball.1.9 (+ -540244731 -1657894554))
                                            (begin
                                              (set! foobar.7.15 1)
                                              (set! bar.5.14 ball.9.10)
                                              (set! foobar.0.13 ball.9.10)
                                              (set! ball.8.12 ball.1.9)
                                              (set! bat.4.11 ball.9.10)
                                              bar.5.14)))
                                    (set! foobar.2.4 -1220846864)
                                    (begin
                                      (set! foobar.3.17 9223372036854775807)
                                      (set! ball.8.16 foobar.2.4)
                                      (+ foobar.7.7 foobar.7.7))))
                            (set! bat.4.2 9223372036854775807)
                            (set! foobar.2.1
                                  (begin
                                    (set! bar.5.21 9223372036854775807)
                                    (set! ball.9.20 (* -192662005 1862849867))
                                    (set! ball.1.19 (+ 1 0))
                                    (set! bat.4.18
                                          (begin
                                            (set! bar.6.24
                                                  (begin
                                                    335331711))
                                            (set! bar.5.23 -9223372036854775808)
                                            (set! bat.4.22 (* 0 401581662))
                                            bar.5.23))
                                    ball.9.20))
                            (begin
                              (set! foobar.3.27 1)
                              (set! ball.1.26
                                    (begin
                                      (set! bat.4.31 (+ foobar.2.1 1135301111))
                                      (set! bar.6.30 9223372036854775807)
                                      (set! foobar.3.29
                                            (begin
                                              (set! foobar.0.33 foobar.0.3)
                                              (set! foobar.2.32 9223372036854775807)
                                              1))
                                      (set! foobar.7.28
                                            (begin
                                              (set! ball.8.35 952233824)
                                              (set! foobar.7.34 -2111195078)
                                              foobar.2.1))
                                      (* bar.6.30 foobar.0.3)))
                              (set! foobar.7.25 (* 1616789004 bat.4.2))
                              -1178679529))))
(check-by-interp '(module (begin
                            (set! bat.8.6 (* -13807710 1))
                            (set! bat.4.5 (* 1019382047 -179932253))
                            (set! bar.1.4
                                  (begin
                                    (set! bat.9.11 (* -1687486692 947016218))
                                    (set! foo.5.10
                                          (begin
                                            (set! bat.3.17 -9223372036854775808)
                                            (set! bat.7.16 -9223372036854775808)
                                            (set! foo.0.15 -9223372036854775808)
                                            (set! bat.9.14 -9223372036854775808)
                                            (set! foo.5.13 -1067551656)
                                            (set! bat.6.12 -9223372036854775808)
                                            -503143250))
                                    (set! bat.8.9
                                          (begin
                                            0))
                                    (set! bar.2.8 1)
                                    (set! bat.6.7 0)
                                    (begin
                                      (set! bat.3.20 -1875852760)
                                      (set! bar.1.19 0)
                                      (set! bat.9.18 bat.8.9)
                                      427327514)))
                            (set! foo.5.3 (+ 2074324450 9223372036854775807))
                            (set! bat.3.2 -550850365)
                            (set! bat.9.1
                                  (begin
                                    (set! bar.1.22
                                          (begin
                                            (set! bat.8.28 0)
                                            (set! bat.3.27 -9223372036854775808)
                                            (set! bar.1.26 -9223372036854775808)
                                            (set! foo.5.25 -9223372036854775808)
                                            (set! bat.4.24 -9223372036854775808)
                                            (set! bat.9.23 9223372036854775807)
                                            0))
                                    (set! foo.5.21 -9223372036854775808)
                                    (* bar.1.22 9223372036854775807)))
                            (begin
                              (set! bat.3.30 bat.3.2)
                              (set! bar.1.29
                                    (begin
                                      (set! bat.7.34 foo.5.3)
                                      (set! bat.4.33 foo.5.3)
                                      (set! bat.9.32 -350477212)
                                      (set! bar.1.31 1)
                                      bat.9.32))
                              (begin
                                (set! bat.6.40 -517791605)
                                (set! foo.5.39 -9223372036854775808)
                                (set! bar.1.38 bat.8.6)
                                (set! bat.7.37 -548263825)
                                (set! bat.8.36 bat.8.6)
                                (set! bat.3.35 0)
                                bat.6.40)))))
(check-by-interp '(module (begin
                            (set! foo.6.5 (+ 1 0))
                            (set! bar.5.4 (+ 0 -9223372036854775808))
                            (set! bat.2.3 (+ 9223372036854775807 1))
                            (set! bar.9.2
                                  (begin
                                    (set! ball.7.11
                                          (begin
                                            (set! bar.4.13 (+ -442142681 -9223372036854775808))
                                            (set! bat.2.12 1)
                                            (* bar.4.13 bar.4.13)))
                                    (set! foobar.3.10
                                          (begin
                                            (set! bar.9.17 (+ 1 0))
                                            (set! bat.2.16
                                                  (begin
                                                    -1205692777))
                                            (set! bar.4.15
                                                  (begin
                                                    (set! bat.2.23 1)
                                                    (set! ball.0.22 1)
                                                    (set! foo.6.21 0)
                                                    (set! bar.1.20 -9223372036854775808)
                                                    (set! bar.9.19 0)
                                                    (set! bar.5.18 -9223372036854775808)
                                                    bar.9.19))
                                            (set! foobar.3.14
                                                  (* 9223372036854775807 -9223372036854775808))
                                            -484745084))
                                    (set! ball.0.9 -662878042)
                                    (set! bat.2.8
                                          (begin
                                            (set! ball.7.28
                                                  (begin
                                                    (set! bar.1.32 1844407077)
                                                    (set! bar.4.31 -2070095618)
                                                    (set! bar.5.30 -1309481621)
                                                    (set! bar.9.29 1)
                                                    629020382))
                                            (set! bar.4.27 9223372036854775807)
                                            (set! ball.0.26 (* 1846876045 0))
                                            (set! bar.9.25 (+ 9223372036854775807 1226538433))
                                            (set! bar.1.24 (* 1 1))
                                            9223372036854775807))
                                    (set! bar.5.7 (* 9223372036854775807 9223372036854775807))
                                    (set! bar.9.6 (* 4937010 630672788))
                                    (+ 0 0)))
                            (set! ball.0.1 (* -9223372036854775808 1))
                            (begin
                              (set! foo.6.34 1791888646)
                              (set! bar.5.33 bat.2.3)
                              (begin
                                (set! bar.9.37
                                      (begin
                                        (set! ball.7.40 bar.5.33)
                                        (set! bar.5.39 -440561963)
                                        (set! foobar.3.38 0)
                                        1401811470))
                                (set! ball.7.36
                                      (begin
                                        (set! ball.0.44 bar.9.2)
                                        (set! bar.9.43 foo.6.34)
                                        (set! foobar.3.42 bar.9.2)
                                        (set! ball.7.41 bar.9.2)
                                        1))
                                (set! foo.6.35
                                      (begin
                                        (set! bar.8.48 -820821795)
                                        (set! foo.6.47 bar.5.33)
                                        (set! foobar.3.46 ball.0.1)
                                        (set! ball.0.45 bar.9.2)
                                        9223372036854775807))
                                bat.2.3)))))
(check-by-interp '(module (begin
                            (set! bar.8.5
                                  (begin
                                    (set! bar.4.7 (+ 9223372036854775807 -1212198797))
                                    (set! bar.8.6 (+ 9223372036854775807 1))
                                    (begin
                                      9223372036854775807)))
                            (set! ball.7.4
                                  (begin
                                    (set! foo.5.10 (* 1529253120 9223372036854775807))
                                    (set! ball.6.9 (+ 0 9223372036854775807))
                                    (set! ball.7.8
                                          (begin
                                            (set! ball.9.15 -9223372036854775808)
                                            (set! foo.5.14 9223372036854775807)
                                            (set! foobar.1.13 -2093039399)
                                            (set! foo.0.12 -1081129047)
                                            (set! ball.7.11 0)
                                            0))
                                    (begin
                                      (set! bar.4.17 ball.6.9)
                                      (set! bar.3.16 foo.5.10)
                                      1)))
                            (set! foo.5.3
                                  (begin
                                    (set! foobar.2.22
                                          (begin
                                            (set! ball.9.27 -9223372036854775808)
                                            (set! bar.4.26 -1289638610)
                                            (set! bar.8.25 -9223372036854775808)
                                            (set! bar.3.24 1614628954)
                                            (set! foo.5.23 1)
                                            bar.4.26))
                                    (set! bar.8.21 (+ -9223372036854775808 1461327539))
                                    (set! ball.7.20 (+ 1440631451 1132111900))
                                    (set! foo.5.19
                                          (begin
                                            (set! foobar.2.33 -9223372036854775808)
                                            (set! ball.9.32 1341007166)
                                            (set! bar.3.31 -658807257)
                                            (set! bar.4.30 1)
                                            (set! ball.7.29 9223372036854775807)
                                            (set! ball.6.28 -9223372036854775808)
                                            9223372036854775807))
                                    (set! foobar.1.18 (* 9223372036854775807 1))
                                    (begin
                                      (set! bar.8.37 bar.8.21)
                                      (set! ball.9.36 bar.8.21)
                                      (set! foobar.1.35 9223372036854775807)
                                      (set! bar.4.34 foo.5.19)
                                      -1814912251)))
                            (set! foobar.2.2
                                  (begin
                                    (set! ball.9.43
                                          (begin
                                            (set! bar.4.49 -9223372036854775808)
                                            (set! ball.6.48 1)
                                            (set! bar.3.47 512940234)
                                            (set! ball.7.46 1772212511)
                                            (set! foo.0.45 -2115152373)
                                            (set! foobar.1.44 -1548236728)
                                            463370592))
                                    (set! bar.4.42 -9223372036854775808)
                                    (set! foo.5.41 1)
                                    (set! foobar.2.40 (* -58352298 -1558994687))
                                    (set! ball.6.39 (+ -9223372036854775808 -1739342441))
                                    (set! bar.3.38 -9223372036854775808)
                                    (* bar.4.42 -364939322)))
                            (set! bar.4.1
                                  (begin
                                    (set! foo.5.50 9223372036854775807)
                                    1))
                            bar.4.1)))
(check-by-interp
 '(module (begin
            (set! bat.1.6
                  (begin
                    (set! ball.4.12 (+ 9223372036854775807 9223372036854775807))
                    (set! foo.7.11
                          (begin
                            (set! ball.0.18
                                  (begin
                                    (set! foo.3.19 1917866959)
                                    foo.3.19))
                            (set! bar.8.17
                                  (begin
                                    9223372036854775807))
                            (set! ball.9.16
                                  (begin
                                    1389926391))
                            (set! foobar.5.15
                                  (begin
                                    (set! ball.6.25 1)
                                    (set! ball.9.24 9223372036854775807)
                                    (set! foo.3.23 -9223372036854775808)
                                    (set! foo.7.22 -9223372036854775808)
                                    (set! foobar.5.21 -9223372036854775808)
                                    (set! bar.8.20 0)
                                    1))
                            (set! ball.4.14
                                  (begin
                                    (set! ball.9.28 773974794)
                                    (set! foo.3.27 -9223372036854775808)
                                    (set! ball.0.26 -813916406)
                                    ball.9.28))
                            (set! bat.1.13
                                  (begin
                                    (set! ball.4.32 1)
                                    (set! ball.6.31 9223372036854775807)
                                    (set! bar.8.30 9223372036854775807)
                                    (set! foo.3.29 257488356)
                                    foo.3.29))
                            (* 0 1)))
                    (set! foo.3.10 378773588)
                    (set! ball.9.9 -554098288)
                    (set! bar.8.8 (+ 9223372036854775807 -2072008758))
                    (set! ball.0.7 (+ 9223372036854775807 363003411))
                    9223372036854775807))
            (set! foo.7.5 0)
            (set! ball.0.4 (* -9223372036854775808 1))
            (set! bar.2.3 1)
            (set! bar.8.2
                  (begin
                    (set! ball.4.37
                          (begin
                            (set! ball.6.40
                                  (begin
                                    (set! bar.2.46 -9223372036854775808)
                                    (set! ball.6.45 -2054498336)
                                    (set! ball.4.44 -1865590209)
                                    (set! foo.7.43 0)
                                    (set! ball.0.42 9223372036854775807)
                                    (set! foo.3.41 1470777638)
                                    ball.6.45))
                            (set! ball.4.39 (* 0 685917859))
                            (set! foo.7.38 -9223372036854775808)
                            (begin
                              (set! ball.6.49 foo.7.38)
                              (set! foo.3.48 ball.4.39)
                              (set! foobar.5.47 0)
                              ball.4.39)))
                    (set! ball.9.36
                          (begin
                            (set! bar.2.55 0)
                            (set! ball.6.54 (+ 9223372036854775807 9223372036854775807))
                            (set! foobar.5.53 (+ -14864072 -643585862))
                            (set! bar.8.52
                                  (begin
                                    (set! foo.7.59 0)
                                    (set! ball.6.58 1)
                                    (set! bar.2.57 0)
                                    (set! ball.0.56 1)
                                    1))
                            (set! ball.0.51 9223372036854775807)
                            (set! foo.3.50 (* 1 472881265))
                            9223372036854775807))
                    (set! bat.1.35
                          (begin
                            (set! foo.7.64
                                  (begin
                                    (set! foobar.5.66 9223372036854775807)
                                    (set! bat.1.65 -1755928127)
                                    604585921))
                            (set! foo.3.63 -9223372036854775808)
                            (set! bat.1.62 (+ 9223372036854775807 1747797968))
                            (set! ball.4.61
                                  (begin
                                    (set! bar.2.72 0)
                                    (set! foobar.5.71 0)
                                    (set! ball.0.70 1)
                                    (set! foo.3.69 0)
                                    (set! ball.9.68 664254548)
                                    (set! bar.8.67 0)
                                    ball.9.68))
                            (set! ball.6.60 9223372036854775807)
                            bat.1.62))
                    (set! foo.3.34
                          (begin
                            (set! ball.4.75 -1572200756)
                            (set! foo.3.74 (+ -9223372036854775808 -9223372036854775808))
                            (set! bar.8.73 (* -1847446968 9223372036854775807))
                            bar.8.73))
                    (set! bar.8.33 (* -9223372036854775808 -565159604))
                    ball.4.37))
            (set! foobar.5.1
                  (begin
                    (set! ball.4.76
                          (begin
                            (set! ball.9.78 0)
                            (set! ball.0.77 -9223372036854775808)
                            1))
                    (begin
                      (set! ball.6.81 (* ball.4.76 ball.4.76))
                      (set! foo.7.80 (* ball.4.76 -1389305375))
                      (set! bar.8.79 (+ -2022017332 -9223372036854775808))
                      -642381767)))
            1)))
;;; Added by Trevor on 2026-03-17
