#lang racket
(require rackunit
         cpsc411/langs/v4
         (only-in "../normalize-bind.rkt" normalize-bind))
(define-syntax-rule (check-by-interp p)
  (check-equal? (interp-imp-mf-lang-v4 (imp-cmf-lang-v4? p))
                (interp-imp-cmf-lang-v4 (imp-cmf-lang-v4? (normalize-bind p)))))

;;; Added by Trevor on 2026-03-17

(check-by-interp '(module (if (true)
                              (* -9223372036854775808 1919678055)
                              (* -9223372036854775808 1))))
(check-by-interp '(module (begin
                            (begin
                              (set! bar.3.3 -9223372036854775808)
                              (set! foobar.1.2 607177860)
                              (set! ball.4.1 689406262)
                              foobar.1.2))))
(check-by-interp '(module (begin
                            (set! foobar.4.3 293371207)
                            (set! foo.8.2 (* 1 -1167539343))
                            (set! foobar.1.1 -9223372036854775808)
                            (if (< 0 foo.8.2) foobar.4.3 foobar.1.1))))
(check-by-interp '(module (begin
                            (set! bar.9.3 (+ 1 -9223372036854775808))
                            (set! foobar.4.2 (+ 1 1))
                            (set! foo.5.1
                                  (begin
                                    (if (< 722151544 0) 1 -1807150378)))
                            (* foo.5.1 bar.9.3))))
(check-by-interp '(module (begin
                            (set! foobar.7.2 (* 0 1))
                            (set! ball.3.1 (if (<= 0 1) 1204486682 -9223372036854775808))
                            (if (< ball.3.1 foobar.7.2) ball.3.1 -9223372036854775808))))
(check-by-interp '(module (if (begin
                                (set! ball.3.4 1445608166)
                                (set! bat.5.3 0)
                                (set! foobar.2.2 0)
                                (set! bar.1.1 1)
                                (= bat.5.3 bar.1.1))
                              -9223372036854775808
                              (if (> 0 -356663773) 1 -1735070759))))
(check-by-interp '(module (begin
                            (set! foo.4.3
                                  (begin
                                    (set! foobar.5.4 -1840576987)
                                    254778871))
                            (set! ball.0.2 (if (= 756663068 2060671731) -2062043463 0))
                            (set! bar.1.1 0)
                            (begin
                              (set! bar.1.8 bar.1.1)
                              (set! ball.9.7 foo.4.3)
                              (set! foo.4.6 ball.0.2)
                              (set! bar.2.5 ball.0.2)
                              ball.9.7))))
(check-by-interp '(module (if (not (<= 2000695989 -1791099531))
                              (begin
                                (set! foobar.8.5 0)
                                (set! ball.3.4 0)
                                (set! foobar.2.3 0)
                                (set! foobar.6.2 -927113299)
                                (set! foo.7.1 568308046)
                                foo.7.1)
                              (begin
                                (set! ball.4.8 -983250820)
                                (set! foo.7.7 1)
                                (set! ball.3.6 1318080036)
                                ball.4.8))))
(check-by-interp '(module (begin
                            (set! bar.7.5
                                  (begin
                                    (set! bar.6.7 -2009338866)
                                    (set! bar.2.6 -9223372036854775808)
                                    bar.2.6))
                            (set! bar.3.4 (if (!= 2060014662 0) 1 1))
                            (set! bat.8.3 1)
                            (set! bar.2.2 230093260)
                            (set! bat.5.1 900177895)
                            (begin
                              (set! bat.5.9 bar.7.5)
                              (set! bar.2.8 bat.8.3)
                              bat.5.9))))
(check-by-interp '(module (if (false)
                              (begin
                                (set! foobar.7.6 0)
                                (set! foobar.6.5 0)
                                (set! foo.9.4 -486317609)
                                (set! bat.1.3 -57146603)
                                (set! bar.8.2 0)
                                (set! bat.4.1 -1014629037)
                                foobar.6.5)
                              (begin
                                (set! ball.2.10 1)
                                (set! foobar.7.9 -9223372036854775808)
                                (set! foo.3.8 -502362832)
                                (set! bar.8.7 1)
                                foo.3.8))))
(check-by-interp '(module (if (if (<= -9223372036854775808 -9223372036854775808)
                                  (<= -9223372036854775808 141552175)
                                  (= 1099135664 -208530803))
                              (begin
                                1)
                              (begin
                                (set! foobar.5.3 0)
                                (set! bat.4.2 -9223372036854775808)
                                (set! foobar.2.1 -1137161966)
                                foobar.2.1))))
(check-by-interp '(module (if (true)
                              (begin
                                (set! foobar.6.5 509793927)
                                (set! foo.4.4 -9223372036854775808)
                                (set! bat.3.3 -9223372036854775808)
                                (set! bat.2.2 -9223372036854775808)
                                (set! ball.1.1 874466679)
                                foo.4.4)
                              (begin
                                (set! ball.5.8 0)
                                (set! ball.8.7 -1676103566)
                                (set! bat.2.6 -12047510)
                                ball.8.7))))
(check-by-interp '(module (begin
                            (set! ball.3.5 (* 1 1742654658))
                            (set! foobar.7.4 -1437539357)
                            (set! bat.1.3 -9223372036854775808)
                            (set! bar.0.2 1)
                            (set! bar.5.1 -1557481616)
                            (begin
                              (set! ball.3.11 bar.5.1)
                              (set! bat.1.10 bar.0.2)
                              (set! foo.2.9 ball.3.5)
                              (set! bar.5.8 foobar.7.4)
                              (set! foobar.7.7 bar.0.2)
                              (set! bat.9.6 bar.5.1)
                              foobar.7.7))))
(check-by-interp '(module (begin
                            (set! bat.2.3 (if (>= 1224363849 -9223372036854775808) -1341816285 0))
                            (set! bat.4.2 (if (> 1 0) -1095031 -159334257))
                            (set! bar.5.1 0)
                            (begin
                              (set! bat.4.9 934456620)
                              (set! foo.1.8 0)
                              (set! bar.8.7 bat.4.2)
                              (set! foo.9.6 bat.2.3)
                              (set! bar.7.5 bat.4.2)
                              (set! bat.2.4 2034424595)
                              foo.1.8))))
(check-by-interp '(module (begin
                            (set! foobar.3.4 2130780142)
                            (set! foobar.7.3 (+ -1626380896 -9223372036854775808))
                            (set! foobar.5.2 (+ 1 -1358001385))
                            (set! bar.8.1 1)
                            (begin
                              (set! foobar.7.8 (+ bar.8.1 foobar.7.3))
                              (set! bat.9.7 foobar.3.4)
                              (set! bat.2.6 foobar.5.2)
                              (set! foobar.3.5 foobar.3.4)
                              (+ foobar.5.2 1394508466)))))
(check-by-interp '(module (begin
                            (set! ball.0.5 (+ 1 0))
                            (set! foobar.7.4
                                  (begin
                                    (set! foo.8.10 0)
                                    (set! ball.3.9 -9223372036854775808)
                                    (set! ball.2.8 420120758)
                                    (set! foobar.7.7 950229390)
                                    (set! foo.9.6 -9223372036854775808)
                                    -1436788709))
                            (set! foobar.1.3 351241708)
                            (set! foo.9.2 -46944546)
                            (set! foo.5.1 (+ 1 -858099177))
                            ball.0.5)))
(check-by-interp '(module (begin
                            (set! ball.9.4 (if (= 0 1122085113) 1377663341 -1212687808))
                            (set! ball.7.3 (if (<= 359103696 -366451938) 0 -9223372036854775808))
                            (set! bat.3.2 -9223372036854775808)
                            (set! bat.1.1
                                  (begin
                                    (set! foobar.2.6 0)
                                    (set! foo.5.5 0)
                                    foobar.2.6))
                            (if (< bat.3.2 ball.7.3) ball.9.4 ball.9.4))))
(check-by-interp '(module (begin
                            (set! ball.8.6 (if (<= 1 1) 1 1334663491))
                            (set! foo.0.5 433059534)
                            (set! bat.2.4 1777050844)
                            (set! foobar.5.3
                                  (if (!= 1 -9223372036854775808) 1682963351 -9223372036854775808))
                            (set! bat.1.2 (* -424296474 -1384099004))
                            (set! ball.3.1 -9223372036854775808)
                            (begin
                              (set! foo.0.7 bat.2.4)
                              foo.0.7))))
(check-by-interp '(module (begin
                            (set! foobar.4.5 (if (> 1 960229008) -353253341 1))
                            (set! bar.7.4
                                  (begin
                                    (set! ball.3.8 0)
                                    (set! foobar.4.7 -1094240881)
                                    (set! bar.1.6 1)
                                    ball.3.8))
                            (set! bat.5.3 1)
                            (set! ball.8.2
                                  (begin
                                    (set! bar.7.10 432749591)
                                    (set! ball.8.9 -421411277)
                                    749377747))
                            (set! ball.3.1 -996428766)
                            (if (= ball.8.2 bar.7.4) -198638968 ball.8.2))))
(check-by-interp '(module (if (begin
                                (set! bat.1.5 -9223372036854775808)
                                (set! foobar.9.4 1)
                                (set! foo.4.3 0)
                                (set! foobar.6.2 -9223372036854775808)
                                (set! foobar.7.1 1)
                                (!= 0 foobar.7.1))
                              (begin
                                (set! bar.0.6 1)
                                -941719640)
                              (begin
                                (set! foobar.6.12 120745579)
                                (set! foo.3.11 -987089435)
                                (set! foo.8.10 -76571663)
                                (set! bar.0.9 1)
                                (set! foobar.7.8 1)
                                (set! foobar.5.7 -1933482026)
                                foobar.6.12))))
(check-by-interp '(module (begin
                            (set! foo.1.6 (* 1 495756801))
                            (set! bar.8.5 (if (= 1020300534 0) 1 1247921698))
                            (set! ball.9.4 (+ 61219697 1))
                            (set! bar.0.3 -738667072)
                            (set! foobar.3.2
                                  (begin
                                    (set! foo.6.7 1)
                                    foo.6.7))
                            (set! foobar.4.1
                                  (begin
                                    1))
                            (begin
                              (set! ball.9.13 foo.1.6)
                              (set! foo.1.12 ball.9.4)
                              (set! foo.2.11 foobar.3.2)
                              (set! bar.0.10 bar.0.3)
                              (set! foobar.3.9 bar.0.3)
                              (set! foo.6.8 1)
                              bar.8.5))))
(check-by-interp '(module (if (false)
                              (begin
                                (set! ball.4.3 0)
                                (set! ball.8.2 -1320062012)
                                (set! bar.0.1 (+ 0 -9223372036854775808))
                                (if (< bar.0.1 ball.4.3) bar.0.1 ball.4.3))
                              (if (begin
                                    (set! bar.0.6 -573607979)
                                    (set! ball.4.5 0)
                                    (set! ball.6.4 -915462716)
                                    (<= ball.4.5 bar.0.6))
                                  (if (!= 1388204095 -1903755946) 1 158515729)
                                  (begin
                                    (set! ball.4.9 1452522364)
                                    (set! ball.6.8 1)
                                    (set! ball.1.7 1)
                                    ball.1.7)))))
(check-by-interp '(module (begin
                            (set! foobar.2.4 (+ 917166060 1734464315))
                            (set! bat.5.3
                                  (begin
                                    (set! foo.9.8 1)
                                    (set! ball.6.7 1)
                                    (set! bat.5.6 -1508855828)
                                    (set! foobar.7.5 1)
                                    ball.6.7))
                            (set! foobar.8.2 (if (>= -9223372036854775808 0) 1 1637767071))
                            (set! foobar.7.1
                                  (begin
                                    (set! foobar.2.12 1223062971)
                                    (set! foobar.8.11 594357257)
                                    (set! foo.9.10 1182737157)
                                    (set! ball.6.9 -1866987123)
                                    foobar.8.11))
                            (begin
                              foobar.8.2))))
(check-by-interp '(module (begin
                            (set! bar.8.6 1)
                            (set! bat.2.5 (if (!= 0 0) 1 82746644))
                            (set! ball.9.4 (if (>= -432462765 1) -9223372036854775808 0))
                            (set! bat.7.3 -1245760310)
                            (set! bar.5.2 (if (= -9223372036854775808 0) 1 0))
                            (set! foo.3.1
                                  (begin
                                    (set! bar.8.11 1)
                                    (set! bar.6.10 1356748148)
                                    (set! bat.2.9 0)
                                    (set! foo.3.8 0)
                                    (set! foobar.4.7 -1498191265)
                                    foobar.4.7))
                            (begin
                              (set! ball.0.13 bar.8.6)
                              (set! ball.9.12 bar.5.2)
                              bar.8.6))))
(check-by-interp '(module (begin
                            (set! foo.2.5 (+ -9223372036854775808 0))
                            (set! foo.9.4
                                  (begin
                                    (set! bat.4.8
                                          (begin
                                            (begin
                                              (set! foobar.5.13 -1016442341)
                                              (set! foobar.1.12 1416892493)
                                              (set! bat.7.11 1)
                                              (set! ball.8.10 -1826864241)
                                              (set! bar.3.9 -9223372036854775808)
                                              -9223372036854775808)))
                                    (set! ball.6.7 (* 440337125 86379188))
                                    (set! bar.3.6 (+ 1 1432660723))
                                    bat.4.8))
                            (set! foobar.1.3 (+ -9223372036854775808 554830987))
                            (set! bar.3.2 0)
                            (set! bat.4.1 (+ 1536405233 0))
                            bat.4.1)))
(check-by-interp '(module (begin
                            (set! foo.2.6 (* -9223372036854775808 -1157863409))
                            (set! foobar.1.5 1744993864)
                            (set! bat.7.4
                                  (begin
                                    (set! ball.4.11 -1918619273)
                                    (set! foo.3.10 -9223372036854775808)
                                    (set! bar.6.9 76920539)
                                    (set! ball.9.8 0)
                                    (set! ball.8.7 1085636044)
                                    ball.8.7))
                            (set! foo.0.3 (+ -9223372036854775808 -9223372036854775808))
                            (set! foobar.5.2
                                  (begin
                                    (set! ball.8.13 -1466502296)
                                    (set! ball.9.12 0)
                                    ball.9.12))
                            (set! ball.9.1 0)
                            (begin
                              (set! foobar.1.16 ball.9.1)
                              (set! foo.3.15 foobar.1.5)
                              (set! ball.9.14 1706452662)
                              foo.0.3))))
(check-by-interp '(module (begin
                            (set! bar.5.5
                                  (begin
                                    (set! ball.2.11 0)
                                    (set! bar.5.10 1)
                                    (set! ball.0.9 -9223372036854775808)
                                    (set! foobar.9.8 668102712)
                                    (set! foobar.3.7 0)
                                    (set! bar.7.6 -9223372036854775808)
                                    ball.0.9))
                            (set! foobar.3.4 -118645994)
                            (set! ball.0.3 (if (<= -333498877 1928180618) 1 1))
                            (set! bar.7.2 (if (= 414168669 1) 0 -9223372036854775808))
                            (set! bar.6.1 (* -9223372036854775808 -9223372036854775808))
                            (begin
                              (set! bar.6.17 ball.0.3)
                              (set! foobar.9.16 bar.5.5)
                              (set! foo.8.15 bar.7.2)
                              (set! bar.7.14 bar.7.2)
                              (set! foobar.3.13 bar.7.2)
                              (set! bar.5.12 bar.6.1)
                              bar.5.12))))
(check-by-interp '(module (begin
                            (set! bat.0.3 -9223372036854775808)
                            (set! bat.7.2
                                  (begin
                                    (set! foo.1.7
                                          (begin
                                            (* -9223372036854775808 -9223372036854775808)))
                                    (set! bar.6.6
                                          (if (= 0 0)
                                              (if (!= -9223372036854775808 0) 571243347 610130973)
                                              (+ -9223372036854775808 1)))
                                    (set! foo.5.5 1256333532)
                                    (set! bat.0.4
                                          (if (= 0 -1835378586)
                                              (begin
                                                1)
                                              (* -9223372036854775808 -424152180)))
                                    bar.6.6))
                            (set! foobar.3.1
                                  (begin
                                    (set! foo.1.12 (+ 913593729 1))
                                    (set! foo.8.11
                                          (if (true)
                                              (begin
                                                1)
                                              0))
                                    (set! foo.5.10 0)
                                    (set! bar.4.9 (* 0 -535871239))
                                    (set! ball.2.8
                                          (if (>= -353070992 -388357885)
                                              (+ 1 0)
                                              (* -9223372036854775808 1)))
                                    ball.2.8))
                            bat.0.3)))
(check-by-interp '(module (if (> 1 -9223372036854775808)
                              (begin
                                (set! bat.8.1 -1486589648)
                                (if (if (= bat.8.1 bat.8.1)
                                        (< bat.8.1 bat.8.1)
                                        (= bat.8.1 -9223372036854775808))
                                    bat.8.1
                                    (* bat.8.1 bat.8.1)))
                              (if (false)
                                  (if (false)
                                      (begin
                                        (set! bat.0.4 1)
                                        (set! bar.4.3 1)
                                        (set! foobar.6.2 -9223372036854775808)
                                        bat.0.4)
                                      (if (!= -286584138 0) 1 451150392))
                                  (begin
                                    (set! bar.4.7
                                          (begin
                                            (set! foobar.6.13 -9223372036854775808)
                                            (set! bar.1.12 -1625696401)
                                            (set! bar.4.11 -15834334)
                                            (set! bat.9.10 1917576020)
                                            (set! bat.5.9 -698078301)
                                            (set! bar.2.8 -2018556296)
                                            bat.5.9))
                                    (set! bar.2.6 (if (<= 1 1) 0 -1965042386))
                                    (set! bat.9.5
                                          (if (< 0 0) -9223372036854775808 -9223372036854775808))
                                    (* bar.2.6 -9223372036854775808))))))
(check-by-interp '(module (begin
                            (set! bat.4.4
                                  (begin
                                    (set! foo.9.8
                                          (if (<= 1 -9223372036854775808) -968056241 -603018045))
                                    (set! foobar.7.7
                                          (begin
                                            (set! bat.4.9 903109867)
                                            -2096973776))
                                    (set! foo.8.6 (if (>= 844611670 -1394444838) 0 1))
                                    (set! foobar.0.5 (* 1461159574 886215187))
                                    (+ foo.9.8 foobar.0.5)))
                            (set! foo.3.3
                                  (if (begin
                                        (set! foo.8.14 1)
                                        (set! foobar.5.13 633639708)
                                        (set! foo.9.12 1169357215)
                                        (set! bat.4.11 1853746647)
                                        (set! foo.3.10 -1584162714)
                                        (< bat.4.11 foobar.5.13))
                                      (* 1 0)
                                      (if (= 0 1) 0 1)))
                            (set! foo.2.2
                                  (if (if (>= 799518468 679954644)
                                          (!= 1925095941 0)
                                          (!= -1317068388 -1173413790))
                                      -1192664449
                                      (* 1374293415 1)))
                            (set! foobar.5.1 -9223372036854775808)
                            (if (begin
                                  (set! bat.4.19 bat.4.4)
                                  (set! foo.2.18 foobar.5.1)
                                  (set! foo.3.17 bat.4.4)
                                  (set! foobar.6.16 430167017)
                                  (set! foobar.5.15 bat.4.4)
                                  (!= foobar.5.15 foo.3.17))
                                (begin
                                  foo.2.2)
                                (begin
                                  (set! foo.3.24 foo.2.2)
                                  (set! foo.8.23 foo.2.2)
                                  (set! foobar.5.22 foobar.5.1)
                                  (set! bar.1.21 bat.4.4)
                                  (set! bat.4.20 foo.3.3)
                                  foo.3.24)))))
(check-by-interp
 '(module (begin
            (set! foobar.5.6 1)
            (set! foo.4.5
                  (begin
                    (set! ball.2.12 (if (<= -862930824 -1170986438) -1031457151 1))
                    (set! ball.8.11 (+ -9223372036854775808 0))
                    (set! foobar.5.10 (* -9223372036854775808 0))
                    (set! foo.6.9 (if (= -9223372036854775808 0) -9223372036854775808 1938254050))
                    (set! foo.4.8 -9223372036854775808)
                    (set! foobar.9.7
                          (begin
                            (set! bat.1.15 -9223372036854775808)
                            (set! foo.6.14 -9223372036854775808)
                            (set! foobar.9.13 0)
                            foo.6.14))
                    foo.6.9))
            (set! ball.8.4
                  (begin
                    (set! foo.6.19 460545466)
                    (set! bat.1.18
                          (begin
                            (set! foo.4.23 -2033025861)
                            (set! foo.0.22 1)
                            (set! ball.2.21 0)
                            (set! bat.1.20 1)
                            ball.2.21))
                    (set! foo.0.17 (if (> -9223372036854775808 -459088038) 0 0))
                    (set! foobar.3.16 (+ 1521054237 935219322))
                    (+ foo.6.19 bat.1.18)))
            (set! foo.6.3 1)
            (set! bat.1.2 1)
            (set! foo.0.1 (* -1391596256 218423145))
            (begin
              (set! foo.4.27 (+ foo.6.3 ball.8.4))
              (set! foobar.3.26 foo.6.3)
              (set! ball.8.25 (if (<= bat.1.2 foo.4.5) foo.4.5 foobar.5.6))
              (set! foo.0.24 foo.6.3)
              (begin
                (set! ball.2.32 bat.1.2)
                (set! bat.1.31 foobar.5.6)
                (set! foobar.5.30 foobar.5.6)
                (set! foo.0.29 foobar.5.6)
                (set! foobar.3.28 foobar.5.6)
                foobar.5.30)))))
(check-by-interp
 '(module
   (begin
     (set! ball.0.2
           (if (true)
               0
               (begin
                 (set! foobar.7.8 1)
                 (set! foobar.6.7
                       (if (> -1818434681 -9223372036854775808) -9223372036854775808 -135823380))
                 (set! ball.1.6 (if (> -1637731979 -1799338585) 1283775776 0))
                 (set! bat.4.5 -722132158)
                 (set! ball.0.4 (if (>= -2054485579 1) 0 -153435165))
                 (set! foobar.5.3 (if (> 1 -2075859550) 2146470798 1))
                 (* ball.0.4 ball.0.4))))
     (set! foobar.6.1
           (begin
             (set! bat.4.13
                   (if (true)
                       (if (= -9223372036854775808 0) -1162069113 -9223372036854775808)
                       (if (< 0 -362354188) 1 0)))
             (set! foobar.5.12
                   (begin
                     (set! ball.8.14
                           (begin
                             (set! ball.8.20 1)
                             (set! ball.9.19 0)
                             (set! ball.1.18 172724818)
                             (set! foobar.6.17 1)
                             (set! bar.2.16 -9223372036854775808)
                             (set! ball.0.15 0)
                             ball.1.18))
                     (if (<= 0 ball.8.14) ball.8.14 -9223372036854775808)))
             (set! foobar.7.11
                   (if (true)
                       (+ 1 0)
                       (if (<= 0 1) 1030684098 -9223372036854775808)))
             (set! bat.3.10 869914910)
             (set! ball.9.9 (* -1692076239 -9223372036854775808))
             (* bat.4.13 foobar.5.12)))
     (begin
       (begin
         (set! foobar.5.21 (if (> foobar.6.1 ball.0.2) 0 ball.0.2))
         (begin
           (set! ball.0.23 0)
           (set! foobar.7.22 ball.0.2)
           foobar.7.22))))))
;;; Added by Trevor on 2026-03-17
