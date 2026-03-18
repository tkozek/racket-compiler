#lang racket
(require rackunit
         cpsc411/langs/v4
         (only-in "../undead-analysis.rkt" undead-analysis))

(define (check-asm-pred-lang-v4/locals p)
  (if (asm-pred-lang-v4/locals? p) p #f))

(define (check-asm-pred-lang-v4/undead p)
  (if (asm-pred-lang-v4/undead? p) p #f))

(define-syntax-rule (check-by-interp p)
  (check-equal? (interp-asm-pred-lang-v4/locals (check-asm-pred-lang-v4/locals p))
                (interp-asm-pred-lang-v4/undead (check-asm-pred-lang-v4/undead (undead-analysis p)))))

;;; Added by Trevor on 2026-03-18

(check-by-interp '(module ((locals (tmp.3 tmp.4 tmp.1 tmp.2)))
                          (if (true)
                              (begin
                                (set! tmp.2 -9223372036854775808)
                                (set! tmp.2 (* tmp.2 1919678055))
                                (set! tmp.1 tmp.2)
                                (halt tmp.1))
                              (begin
                                (set! tmp.4 -9223372036854775808)
                                (set! tmp.4 (* tmp.4 1))
                                (set! tmp.3 tmp.4)
                                (halt tmp.3)))
                    ))
(check-by-interp '(module ((locals (ball.4.1 bar.3.3 foobar.1.2)))
                          (begin
                            (set! bar.3.3 -9223372036854775808)
                            (set! foobar.1.2 607177860)
                            (set! ball.4.1 689406262)
                            (halt foobar.1.2))
                    ))
(check-by-interp '(module ((locals (tmp.4 foobar.1.1 foobar.4.3 foo.8.2 tmp.5)))
                          (begin
                            (set! foobar.4.3 293371207)
                            (set! tmp.4 1)
                            (set! tmp.4 (* tmp.4 -1167539343))
                            (set! foo.8.2 tmp.4)
                            (set! foobar.1.1 -9223372036854775808)
                            (if (begin
                                  (set! tmp.5 0)
                                  (< tmp.5 foo.8.2))
                                (halt foobar.4.3)
                                (halt foobar.1.1)))
                    ))
(check-by-interp '(module ((locals (tmp.8 tmp.6 foo.5.1 foobar.4.2 tmp.5 bar.9.3 tmp.4 tmp.7)))
                          (begin
                            (set! tmp.4 1)
                            (set! tmp.4 (+ tmp.4 -9223372036854775808))
                            (set! bar.9.3 tmp.4)
                            (set! tmp.5 1)
                            (set! tmp.5 (+ tmp.5 1))
                            (set! foobar.4.2 tmp.5)
                            (if (begin
                                  (set! tmp.6 722151544)
                                  (< tmp.6 0))
                                (set! foo.5.1 1)
                                (set! foo.5.1 -1807150378))
                            (set! tmp.8 foo.5.1)
                            (set! tmp.8 (* tmp.8 bar.9.3))
                            (set! tmp.7 tmp.8)
                            (halt tmp.7))
                    ))
(check-by-interp '(module ((locals (tmp.4 tmp.3 foobar.7.2 ball.3.1)))
                          (begin
                            (set! tmp.3 0)
                            (set! tmp.3 (* tmp.3 1))
                            (set! foobar.7.2 tmp.3)
                            (if (begin
                                  (set! tmp.4 0)
                                  (<= tmp.4 1))
                                (set! ball.3.1 1204486682)
                                (set! ball.3.1 -9223372036854775808))
                            (if (< ball.3.1 foobar.7.2)
                                (halt ball.3.1)
                                (halt -9223372036854775808)))
                    ))
(check-by-interp '(module ((locals (tmp.5 foobar.2.2 ball.3.4 bar.1.1 bat.5.3)))
                          (if (begin
                                (set! ball.3.4 1445608166)
                                (set! bat.5.3 0)
                                (set! foobar.2.2 0)
                                (set! bar.1.1 1)
                                (= bat.5.3 bar.1.1))
                              (halt -9223372036854775808)
                              (if (begin
                                    (set! tmp.5 0)
                                    (> tmp.5 -356663773))
                                  (halt 1)
                                  (halt -1735070759)))
                    ))
(check-by-interp
 '(module ((locals (bar.2.5 foo.4.6 bar.1.8 bar.1.1 tmp.9 ball.0.2 foo.4.3 foobar.5.4 ball.9.7)))
          (begin
            (set! foobar.5.4 -1840576987)
            (set! foo.4.3 254778871)
            (if (begin
                  (set! tmp.9 756663068)
                  (= tmp.9 2060671731))
                (set! ball.0.2 -2062043463)
                (set! ball.0.2 0))
            (set! bar.1.1 0)
            (set! bar.1.8 bar.1.1)
            (set! ball.9.7 foo.4.3)
            (set! foo.4.6 ball.0.2)
            (set! bar.2.5 ball.0.2)
            (halt ball.9.7))
    ))
(check-by-interp
 '(module ((locals
            (ball.4.8 foo.7.7 ball.3.6 foo.7.1 foobar.8.5 ball.3.4 foobar.2.3 foobar.6.2 tmp.9)))
          (if (not (begin
                     (set! tmp.9 2000695989)
                     (<= tmp.9 -1791099531)))
              (begin
                (set! foobar.8.5 0)
                (set! ball.3.4 0)
                (set! foobar.2.3 0)
                (set! foobar.6.2 -927113299)
                (set! foo.7.1 568308046)
                (halt foo.7.1))
              (begin
                (set! ball.4.8 -983250820)
                (set! foo.7.7 1)
                (set! ball.3.6 1318080036)
                (halt ball.4.8)))
    ))
(check-by-interp
 '(module ((locals (bar.2.8 bat.5.1 bar.2.2 bat.8.3 tmp.10 bar.3.4 bar.7.5 bar.2.6 bar.6.7 bat.5.9)))
          (begin
            (set! bar.6.7 -2009338866)
            (set! bar.2.6 -9223372036854775808)
            (set! bar.7.5 bar.2.6)
            (if (begin
                  (set! tmp.10 2060014662)
                  (!= tmp.10 0))
                (set! bar.3.4 1)
                (set! bar.3.4 1))
            (set! bat.8.3 1)
            (set! bar.2.2 230093260)
            (set! bat.5.1 900177895)
            (set! bat.5.9 bar.7.5)
            (set! bar.2.8 bat.8.3)
            (halt bat.5.9))
    ))
(check-by-interp '(module ((locals (foo.3.8 ball.2.10
                                            foobar.7.9
                                            bar.8.7
                                            foobar.6.5
                                            foobar.7.6
                                            foo.9.4
                                            bat.1.3
                                            bar.8.2
                                            bat.4.1)))
                          (if (false)
                              (begin
                                (set! foobar.7.6 0)
                                (set! foobar.6.5 0)
                                (set! foo.9.4 -486317609)
                                (set! bat.1.3 -57146603)
                                (set! bar.8.2 0)
                                (set! bat.4.1 -1014629037)
                                (halt foobar.6.5))
                              (begin
                                (set! ball.2.10 1)
                                (set! foobar.7.9 -9223372036854775808)
                                (set! foo.3.8 -502362832)
                                (set! bar.8.7 1)
                                (halt foo.3.8)))
                    ))
(check-by-interp '(module ((locals (foobar.2.1 foobar.5.3 bat.4.2 tmp.6 tmp.5 tmp.4)))
                          (if (if (begin
                                    (set! tmp.4 -9223372036854775808)
                                    (<= tmp.4 -9223372036854775808))
                                  (begin
                                    (set! tmp.5 -9223372036854775808)
                                    (<= tmp.5 141552175))
                                  (begin
                                    (set! tmp.6 1099135664)
                                    (= tmp.6 -208530803)))
                              (halt 1)
                              (begin
                                (set! foobar.5.3 0)
                                (set! bat.4.2 -9223372036854775808)
                                (set! foobar.2.1 -1137161966)
                                (halt foobar.2.1)))
                    ))
(check-by-interp
 '(module ((locals (ball.8.7 ball.5.8 bat.2.6 foo.4.4 foobar.6.5 bat.3.3 bat.2.2 ball.1.1)))
          (if (true)
              (begin
                (set! foobar.6.5 509793927)
                (set! foo.4.4 -9223372036854775808)
                (set! bat.3.3 -9223372036854775808)
                (set! bat.2.2 -9223372036854775808)
                (set! ball.1.1 874466679)
                (halt foo.4.4))
              (begin
                (set! ball.5.8 0)
                (set! ball.8.7 -1676103566)
                (set! bat.2.6 -12047510)
                (halt ball.8.7)))
    ))
(check-by-interp '(module ((locals (bat.9.6 bar.5.8
                                            foo.2.9
                                            bat.1.10
                                            ball.3.11
                                            bar.5.1
                                            bar.0.2
                                            bat.1.3
                                            foobar.7.4
                                            ball.3.5
                                            tmp.12
                                            foobar.7.7)))
                          (begin
                            (set! tmp.12 1)
                            (set! tmp.12 (* tmp.12 1742654658))
                            (set! ball.3.5 tmp.12)
                            (set! foobar.7.4 -1437539357)
                            (set! bat.1.3 -9223372036854775808)
                            (set! bar.0.2 1)
                            (set! bar.5.1 -1557481616)
                            (set! ball.3.11 bar.5.1)
                            (set! bat.1.10 bar.0.2)
                            (set! foo.2.9 ball.3.5)
                            (set! bar.5.8 foobar.7.4)
                            (set! foobar.7.7 bar.0.2)
                            (set! bat.9.6 bar.5.1)
                            (halt foobar.7.7))
                    ))
(check-by-interp
 '(module ((locals
            (bat.2.4 bar.7.5 foo.9.6 bar.8.7 bat.4.9 bar.5.1 tmp.11 bat.4.2 tmp.10 bat.2.3 foo.1.8)))
          (begin
            (if (begin
                  (set! tmp.10 1224363849)
                  (>= tmp.10 -9223372036854775808))
                (set! bat.2.3 -1341816285)
                (set! bat.2.3 0))
            (if (begin
                  (set! tmp.11 1)
                  (> tmp.11 0))
                (set! bat.4.2 -1095031)
                (set! bat.4.2 -159334257))
            (set! bar.5.1 0)
            (set! bat.4.9 934456620)
            (set! foo.1.8 0)
            (set! bar.8.7 bat.4.2)
            (set! foo.9.6 bat.2.3)
            (set! bar.7.5 bat.4.2)
            (set! bat.2.4 2034424595)
            (halt foo.1.8))
    ))
(check-by-interp '(module ((locals (tmp.13 foobar.3.5
                                           bat.2.6
                                           bat.9.7
                                           foobar.7.8
                                           tmp.11
                                           bar.8.1
                                           foobar.5.2
                                           tmp.10
                                           foobar.7.3
                                           tmp.9
                                           foobar.3.4
                                           tmp.12)))
                          (begin
                            (set! foobar.3.4 2130780142)
                            (set! tmp.9 -1626380896)
                            (set! tmp.9 (+ tmp.9 -9223372036854775808))
                            (set! foobar.7.3 tmp.9)
                            (set! tmp.10 1)
                            (set! tmp.10 (+ tmp.10 -1358001385))
                            (set! foobar.5.2 tmp.10)
                            (set! bar.8.1 1)
                            (set! tmp.11 bar.8.1)
                            (set! tmp.11 (+ tmp.11 foobar.7.3))
                            (set! foobar.7.8 tmp.11)
                            (set! bat.9.7 foobar.3.4)
                            (set! bat.2.6 foobar.5.2)
                            (set! foobar.3.5 foobar.3.4)
                            (set! tmp.13 foobar.5.2)
                            (set! tmp.13 (+ tmp.13 1394508466))
                            (set! tmp.12 tmp.13)
                            (halt tmp.12))
                    ))
(check-by-interp '(module ((locals (foo.5.1 tmp.12
                                            foo.9.2
                                            foobar.1.3
                                            foobar.7.4
                                            foo.9.6
                                            foobar.7.7
                                            ball.2.8
                                            ball.3.9
                                            foo.8.10
                                            tmp.11
                                            ball.0.5)))
                          (begin
                            (set! tmp.11 1)
                            (set! tmp.11 (+ tmp.11 0))
                            (set! ball.0.5 tmp.11)
                            (set! foo.8.10 0)
                            (set! ball.3.9 -9223372036854775808)
                            (set! ball.2.8 420120758)
                            (set! foobar.7.7 950229390)
                            (set! foo.9.6 -9223372036854775808)
                            (set! foobar.7.4 -1436788709)
                            (set! foobar.1.3 351241708)
                            (set! foo.9.2 -46944546)
                            (set! tmp.12 1)
                            (set! tmp.12 (+ tmp.12 -858099177))
                            (set! foo.5.1 tmp.12)
                            (halt ball.0.5))
                    ))
(check-by-interp
 '(module ((locals (bat.1.1 foo.5.5 foobar.2.6 tmp.8 tmp.7 ball.9.4 ball.7.3 bat.3.2)))
          (begin
            (if (begin
                  (set! tmp.7 0)
                  (= tmp.7 1122085113))
                (set! ball.9.4 1377663341)
                (set! ball.9.4 -1212687808))
            (if (begin
                  (set! tmp.8 359103696)
                  (<= tmp.8 -366451938))
                (set! ball.7.3 0)
                (set! ball.7.3 -9223372036854775808))
            (set! bat.3.2 -9223372036854775808)
            (set! foobar.2.6 0)
            (set! foo.5.5 0)
            (set! bat.1.1 foobar.2.6)
            (if (< bat.3.2 ball.7.3)
                (halt ball.9.4)
                (halt ball.9.4)))
    ))
(check-by-interp
 '(module ((locals (ball.3.1 bat.1.2 tmp.10 tmp.9 foobar.5.3 bat.2.4 foo.0.5 tmp.8 ball.8.6 foo.0.7)))
          (begin
            (if (begin
                  (set! tmp.8 1)
                  (<= tmp.8 1))
                (set! ball.8.6 1)
                (set! ball.8.6 1334663491))
            (set! foo.0.5 433059534)
            (set! bat.2.4 1777050844)
            (if (begin
                  (set! tmp.9 1)
                  (!= tmp.9 -9223372036854775808))
                (set! foobar.5.3 1682963351)
                (set! foobar.5.3 -9223372036854775808))
            (set! tmp.10 -424296474)
            (set! tmp.10 (* tmp.10 -1384099004))
            (set! bat.1.2 tmp.10)
            (set! ball.3.1 -9223372036854775808)
            (set! foo.0.7 bat.2.4)
            (halt foo.0.7))
    ))
(check-by-interp '(module ((locals (ball.3.1 ball.8.9
                                             bar.7.10
                                             bat.5.3
                                             bar.1.6
                                             foobar.4.7
                                             ball.3.8
                                             tmp.11
                                             foobar.4.5
                                             bar.7.4
                                             ball.8.2)))
                          (begin
                            (if (begin
                                  (set! tmp.11 1)
                                  (> tmp.11 960229008))
                                (set! foobar.4.5 -353253341)
                                (set! foobar.4.5 1))
                            (set! ball.3.8 0)
                            (set! foobar.4.7 -1094240881)
                            (set! bar.1.6 1)
                            (set! bar.7.4 ball.3.8)
                            (set! bat.5.3 1)
                            (set! bar.7.10 432749591)
                            (set! ball.8.9 -421411277)
                            (set! ball.8.2 749377747)
                            (set! ball.3.1 -996428766)
                            (if (= ball.8.2 bar.7.4)
                                (halt -198638968)
                                (halt ball.8.2)))
                    ))
(check-by-interp '(module ((locals (foobar.6.12 foo.3.11
                                                foo.8.10
                                                bar.0.9
                                                foobar.7.8
                                                foobar.5.7
                                                bar.0.6
                                                foobar.6.2
                                                foo.4.3
                                                foobar.9.4
                                                bat.1.5
                                                foobar.7.1
                                                tmp.13)))
                          (if (begin
                                (set! bat.1.5 -9223372036854775808)
                                (set! foobar.9.4 1)
                                (set! foo.4.3 0)
                                (set! foobar.6.2 -9223372036854775808)
                                (set! foobar.7.1 1)
                                (begin
                                  (set! tmp.13 0)
                                  (!= tmp.13 foobar.7.1)))
                              (begin
                                (set! bar.0.6 1)
                                (halt -941719640))
                              (begin
                                (set! foobar.6.12 120745579)
                                (set! foo.3.11 -987089435)
                                (set! foo.8.10 -76571663)
                                (set! bar.0.9 1)
                                (set! foobar.7.8 1)
                                (set! foobar.5.7 -1933482026)
                                (halt foobar.6.12)))
                    ))
(check-by-interp '(module ((locals (foo.6.8 foobar.3.9
                                            bar.0.10
                                            foo.2.11
                                            foo.1.12
                                            ball.9.13
                                            foobar.4.1
                                            foobar.3.2
                                            foo.6.7
                                            bar.0.3
                                            ball.9.4
                                            tmp.16
                                            tmp.15
                                            foo.1.6
                                            tmp.14
                                            bar.8.5)))
                          (begin
                            (set! tmp.14 1)
                            (set! tmp.14 (* tmp.14 495756801))
                            (set! foo.1.6 tmp.14)
                            (if (begin
                                  (set! tmp.15 1020300534)
                                  (= tmp.15 0))
                                (set! bar.8.5 1)
                                (set! bar.8.5 1247921698))
                            (set! tmp.16 61219697)
                            (set! tmp.16 (+ tmp.16 1))
                            (set! ball.9.4 tmp.16)
                            (set! bar.0.3 -738667072)
                            (set! foo.6.7 1)
                            (set! foobar.3.2 foo.6.7)
                            (set! foobar.4.1 1)
                            (set! ball.9.13 foo.1.6)
                            (set! foo.1.12 ball.9.4)
                            (set! foo.2.11 foobar.3.2)
                            (set! bar.0.10 bar.0.3)
                            (set! foobar.3.9 bar.0.3)
                            (set! foo.6.8 1)
                            (halt bar.8.5))
                    ))
(check-by-interp '(module ((locals (ball.4.5 bar.0.6
                                             ball.6.4
                                             tmp.11
                                             ball.6.8
                                             ball.4.9
                                             ball.1.7
                                             bar.0.1
                                             ball.4.3
                                             ball.8.2
                                             tmp.10)))
                          (if (false)
                              (begin
                                (set! ball.4.3 0)
                                (set! ball.8.2 -1320062012)
                                (set! tmp.10 0)
                                (set! tmp.10 (+ tmp.10 -9223372036854775808))
                                (set! bar.0.1 tmp.10)
                                (if (< bar.0.1 ball.4.3)
                                    (halt bar.0.1)
                                    (halt ball.4.3)))
                              (if (begin
                                    (set! bar.0.6 -573607979)
                                    (set! ball.4.5 0)
                                    (set! ball.6.4 -915462716)
                                    (<= ball.4.5 bar.0.6))
                                  (if (begin
                                        (set! tmp.11 1388204095)
                                        (!= tmp.11 -1903755946))
                                      (halt 1)
                                      (halt 158515729))
                                  (begin
                                    (set! ball.4.9 1452522364)
                                    (set! ball.6.8 1)
                                    (set! ball.1.7 1)
                                    (halt ball.1.7))))
                    ))
(check-by-interp '(module ((locals (foobar.7.1 ball.6.9
                                               foo.9.10
                                               foobar.8.11
                                               foobar.2.12
                                               tmp.14
                                               bat.5.3
                                               foobar.7.5
                                               bat.5.6
                                               ball.6.7
                                               foo.9.8
                                               foobar.2.4
                                               tmp.13
                                               foobar.8.2)))
                          (begin
                            (set! tmp.13 917166060)
                            (set! tmp.13 (+ tmp.13 1734464315))
                            (set! foobar.2.4 tmp.13)
                            (set! foo.9.8 1)
                            (set! ball.6.7 1)
                            (set! bat.5.6 -1508855828)
                            (set! foobar.7.5 1)
                            (set! bat.5.3 ball.6.7)
                            (if (begin
                                  (set! tmp.14 -9223372036854775808)
                                  (>= tmp.14 0))
                                (set! foobar.8.2 1)
                                (set! foobar.8.2 1637767071))
                            (set! foobar.2.12 1223062971)
                            (set! foobar.8.11 594357257)
                            (set! foo.9.10 1182737157)
                            (set! ball.6.9 -1866987123)
                            (set! foobar.7.1 foobar.8.11)
                            (halt foobar.8.2))
                    ))
(check-by-interp '(module ((locals (ball.9.12 ball.0.13
                                              foo.3.1
                                              foobar.4.7
                                              foo.3.8
                                              bat.2.9
                                              bar.6.10
                                              bar.8.11
                                              tmp.16
                                              bar.5.2
                                              bat.7.3
                                              tmp.15
                                              ball.9.4
                                              tmp.14
                                              bat.2.5
                                              bar.8.6)))
                          (begin
                            (set! bar.8.6 1)
                            (if (begin
                                  (set! tmp.14 0)
                                  (!= tmp.14 0))
                                (set! bat.2.5 1)
                                (set! bat.2.5 82746644))
                            (if (begin
                                  (set! tmp.15 -432462765)
                                  (>= tmp.15 1))
                                (set! ball.9.4 -9223372036854775808)
                                (set! ball.9.4 0))
                            (set! bat.7.3 -1245760310)
                            (if (begin
                                  (set! tmp.16 -9223372036854775808)
                                  (= tmp.16 0))
                                (set! bar.5.2 1)
                                (set! bar.5.2 0))
                            (set! bar.8.11 1)
                            (set! bar.6.10 1356748148)
                            (set! bat.2.9 0)
                            (set! foo.3.8 0)
                            (set! foobar.4.7 -1498191265)
                            (set! foo.3.1 foobar.4.7)
                            (set! ball.0.13 bar.8.6)
                            (set! ball.9.12 bar.5.2)
                            (halt bar.8.6))
                    ))
(check-by-interp '(module ((locals (tmp.18 bar.3.2
                                           foobar.1.3
                                           tmp.17
                                           foo.9.4
                                           bar.3.6
                                           tmp.16
                                           ball.6.7
                                           tmp.15
                                           bat.4.8
                                           bar.3.9
                                           ball.8.10
                                           bat.7.11
                                           foobar.1.12
                                           foobar.5.13
                                           foo.2.5
                                           tmp.14
                                           bat.4.1)))
                          (begin
                            (set! tmp.14 -9223372036854775808)
                            (set! tmp.14 (+ tmp.14 0))
                            (set! foo.2.5 tmp.14)
                            (set! foobar.5.13 -1016442341)
                            (set! foobar.1.12 1416892493)
                            (set! bat.7.11 1)
                            (set! ball.8.10 -1826864241)
                            (set! bar.3.9 -9223372036854775808)
                            (set! bat.4.8 -9223372036854775808)
                            (set! tmp.15 440337125)
                            (set! tmp.15 (* tmp.15 86379188))
                            (set! ball.6.7 tmp.15)
                            (set! tmp.16 1)
                            (set! tmp.16 (+ tmp.16 1432660723))
                            (set! bar.3.6 tmp.16)
                            (set! foo.9.4 bat.4.8)
                            (set! tmp.17 -9223372036854775808)
                            (set! tmp.17 (+ tmp.17 554830987))
                            (set! foobar.1.3 tmp.17)
                            (set! bar.3.2 0)
                            (set! tmp.18 1536405233)
                            (set! tmp.18 (+ tmp.18 0))
                            (set! bat.4.1 tmp.18)
                            (halt bat.4.1))
                    ))
(check-by-interp '(module ((locals (ball.9.14 foo.3.15
                                              foobar.1.16
                                              ball.9.1
                                              foobar.5.2
                                              ball.9.12
                                              ball.8.13
                                              tmp.18
                                              bat.7.4
                                              ball.8.7
                                              ball.9.8
                                              bar.6.9
                                              foo.3.10
                                              ball.4.11
                                              foobar.1.5
                                              foo.2.6
                                              tmp.17
                                              foo.0.3)))
                          (begin
                            (set! tmp.17 -9223372036854775808)
                            (set! tmp.17 (* tmp.17 -1157863409))
                            (set! foo.2.6 tmp.17)
                            (set! foobar.1.5 1744993864)
                            (set! ball.4.11 -1918619273)
                            (set! foo.3.10 -9223372036854775808)
                            (set! bar.6.9 76920539)
                            (set! ball.9.8 0)
                            (set! ball.8.7 1085636044)
                            (set! bat.7.4 ball.8.7)
                            (set! tmp.18 -9223372036854775808)
                            (set! tmp.18 (+ tmp.18 -9223372036854775808))
                            (set! foo.0.3 tmp.18)
                            (set! ball.8.13 -1466502296)
                            (set! ball.9.12 0)
                            (set! foobar.5.2 ball.9.12)
                            (set! ball.9.1 0)
                            (set! foobar.1.16 ball.9.1)
                            (set! foo.3.15 foobar.1.5)
                            (set! ball.9.14 1706452662)
                            (halt foo.0.3))
                    ))
(check-by-interp '(module ((locals (foobar.3.13 bar.7.14
                                                foo.8.15
                                                foobar.9.16
                                                bar.6.17
                                                bar.6.1
                                                tmp.20
                                                tmp.19
                                                bar.7.2
                                                tmp.18
                                                ball.0.3
                                                foobar.3.4
                                                bar.5.5
                                                bar.7.6
                                                foobar.3.7
                                                foobar.9.8
                                                ball.0.9
                                                bar.5.10
                                                ball.2.11
                                                bar.5.12)))
                          (begin
                            (set! ball.2.11 0)
                            (set! bar.5.10 1)
                            (set! ball.0.9 -9223372036854775808)
                            (set! foobar.9.8 668102712)
                            (set! foobar.3.7 0)
                            (set! bar.7.6 -9223372036854775808)
                            (set! bar.5.5 ball.0.9)
                            (set! foobar.3.4 -118645994)
                            (if (begin
                                  (set! tmp.18 -333498877)
                                  (<= tmp.18 1928180618))
                                (set! ball.0.3 1)
                                (set! ball.0.3 1))
                            (if (begin
                                  (set! tmp.19 414168669)
                                  (= tmp.19 1))
                                (set! bar.7.2 0)
                                (set! bar.7.2 -9223372036854775808))
                            (set! tmp.20 -9223372036854775808)
                            (set! tmp.20 (* tmp.20 -9223372036854775808))
                            (set! bar.6.1 tmp.20)
                            (set! bar.6.17 ball.0.3)
                            (set! foobar.9.16 bar.5.5)
                            (set! foo.8.15 bar.7.2)
                            (set! bar.7.14 bar.7.2)
                            (set! foobar.3.13 bar.7.2)
                            (set! bar.5.12 bar.6.1)
                            (halt bar.5.12))
                    ))
(check-by-interp '(module ((locals (foobar.3.1 tmp.21
                                               ball.2.8
                                               tmp.22
                                               tmp.23
                                               bar.4.9
                                               tmp.20
                                               foo.5.10
                                               foo.8.11
                                               foo.1.12
                                               tmp.19
                                               bat.7.2
                                               tmp.17
                                               bat.0.4
                                               tmp.18
                                               foo.5.5
                                               tmp.14
                                               bar.6.6
                                               tmp.15
                                               tmp.16
                                               foo.1.7
                                               tmp.13
                                               bat.0.3)))
                          (begin
                            (set! bat.0.3 -9223372036854775808)
                            (set! tmp.13 -9223372036854775808)
                            (set! tmp.13 (* tmp.13 -9223372036854775808))
                            (set! foo.1.7 tmp.13)
                            (if (begin
                                  (set! tmp.14 0)
                                  (= tmp.14 0))
                                (if (begin
                                      (set! tmp.15 -9223372036854775808)
                                      (!= tmp.15 0))
                                    (set! bar.6.6 571243347)
                                    (set! bar.6.6 610130973))
                                (begin
                                  (set! tmp.16 -9223372036854775808)
                                  (set! tmp.16 (+ tmp.16 1))
                                  (set! bar.6.6 tmp.16)))
                            (set! foo.5.5 1256333532)
                            (if (begin
                                  (set! tmp.17 0)
                                  (= tmp.17 -1835378586))
                                (begin
                                  (set! bat.0.4 1))
                                (begin
                                  (set! tmp.18 -9223372036854775808)
                                  (set! tmp.18 (* tmp.18 -424152180))
                                  (set! bat.0.4 tmp.18)))
                            (set! bat.7.2 bar.6.6)
                            (set! tmp.19 913593729)
                            (set! tmp.19 (+ tmp.19 1))
                            (set! foo.1.12 tmp.19)
                            (if (true)
                                (begin
                                  (set! foo.8.11 1))
                                (set! foo.8.11 0))
                            (set! foo.5.10 0)
                            (set! tmp.20 0)
                            (set! tmp.20 (* tmp.20 -535871239))
                            (set! bar.4.9 tmp.20)
                            (if (begin
                                  (set! tmp.21 -353070992)
                                  (>= tmp.21 -388357885))
                                (begin
                                  (set! tmp.22 1)
                                  (set! tmp.22 (+ tmp.22 0))
                                  (set! ball.2.8 tmp.22))
                                (begin
                                  (set! tmp.23 -9223372036854775808)
                                  (set! tmp.23 (* tmp.23 1))
                                  (set! ball.2.8 tmp.23)))
                            (set! foobar.3.1 ball.2.8)
                            (halt bat.0.3))
                    ))
(check-by-interp '(module ((locals (tmp.17 bat.0.4
                                           bar.4.3
                                           foobar.6.2
                                           tmp.21
                                           tmp.19
                                           bat.9.5
                                           tmp.18
                                           bar.2.6
                                           bar.4.7
                                           bar.2.8
                                           bat.5.9
                                           bat.9.10
                                           bar.4.11
                                           bar.1.12
                                           foobar.6.13
                                           tmp.20
                                           bat.8.1
                                           tmp.16
                                           tmp.15
                                           tmp.14)))
                          (if (begin
                                (set! tmp.14 1)
                                (> tmp.14 -9223372036854775808))
                              (begin
                                (set! bat.8.1 -1486589648)
                                (if (if (= bat.8.1 bat.8.1)
                                        (< bat.8.1 bat.8.1)
                                        (= bat.8.1 -9223372036854775808))
                                    (halt bat.8.1)
                                    (begin
                                      (set! tmp.16 bat.8.1)
                                      (set! tmp.16 (* tmp.16 bat.8.1))
                                      (set! tmp.15 tmp.16)
                                      (halt tmp.15))))
                              (if (false)
                                  (if (false)
                                      (begin
                                        (set! bat.0.4 1)
                                        (set! bar.4.3 1)
                                        (set! foobar.6.2 -9223372036854775808)
                                        (halt bat.0.4))
                                      (if (begin
                                            (set! tmp.17 -286584138)
                                            (!= tmp.17 0))
                                          (halt 1)
                                          (halt 451150392)))
                                  (begin
                                    (set! foobar.6.13 -9223372036854775808)
                                    (set! bar.1.12 -1625696401)
                                    (set! bar.4.11 -15834334)
                                    (set! bat.9.10 1917576020)
                                    (set! bat.5.9 -698078301)
                                    (set! bar.2.8 -2018556296)
                                    (set! bar.4.7 bat.5.9)
                                    (if (begin
                                          (set! tmp.18 1)
                                          (<= tmp.18 1))
                                        (set! bar.2.6 0)
                                        (set! bar.2.6 -1965042386))
                                    (if (begin
                                          (set! tmp.19 0)
                                          (< tmp.19 0))
                                        (set! bat.9.5 -9223372036854775808)
                                        (set! bat.9.5 -9223372036854775808))
                                    (set! tmp.21 bar.2.6)
                                    (set! tmp.21 (* tmp.21 -9223372036854775808))
                                    (set! tmp.20 tmp.21)
                                    (halt tmp.20))))
                    ))
(check-by-interp '(module ((locals (tmp.31 tmp.32
                                           tmp.33
                                           tmp.34
                                           bat.4.11
                                           foobar.5.13
                                           foo.8.14
                                           foo.9.12
                                           foo.3.10
                                           tmp.29
                                           tmp.30
                                           tmp.28
                                           foobar.0.5
                                           tmp.27
                                           tmp.26
                                           foo.8.6
                                           foobar.7.7
                                           bat.4.9
                                           tmp.25
                                           foo.9.8
                                           foo.3.24
                                           foo.8.23
                                           foobar.5.22
                                           bar.1.21
                                           foo.3.3
                                           bat.4.20
                                           foo.2.2
                                           foobar.6.16
                                           foo.2.18
                                           foobar.5.1
                                           bat.4.19
                                           bat.4.4
                                           foo.3.17
                                           foobar.5.15)))
                          (begin
                            (if (begin
                                  (set! tmp.25 1)
                                  (<= tmp.25 -9223372036854775808))
                                (set! foo.9.8 -968056241)
                                (set! foo.9.8 -603018045))
                            (set! bat.4.9 903109867)
                            (set! foobar.7.7 -2096973776)
                            (if (begin
                                  (set! tmp.26 844611670)
                                  (>= tmp.26 -1394444838))
                                (set! foo.8.6 0)
                                (set! foo.8.6 1))
                            (set! tmp.27 1461159574)
                            (set! tmp.27 (* tmp.27 886215187))
                            (set! foobar.0.5 tmp.27)
                            (set! tmp.28 foo.9.8)
                            (set! tmp.28 (+ tmp.28 foobar.0.5))
                            (set! bat.4.4 tmp.28)
                            (if (begin
                                  (set! foo.8.14 1)
                                  (set! foobar.5.13 633639708)
                                  (set! foo.9.12 1169357215)
                                  (set! bat.4.11 1853746647)
                                  (set! foo.3.10 -1584162714)
                                  (< bat.4.11 foobar.5.13))
                                (begin
                                  (set! tmp.29 1)
                                  (set! tmp.29 (* tmp.29 0))
                                  (set! foo.3.3 tmp.29))
                                (if (begin
                                      (set! tmp.30 0)
                                      (= tmp.30 1))
                                    (set! foo.3.3 0)
                                    (set! foo.3.3 1)))
                            (if (if (begin
                                      (set! tmp.31 799518468)
                                      (>= tmp.31 679954644))
                                    (begin
                                      (set! tmp.32 1925095941)
                                      (!= tmp.32 0))
                                    (begin
                                      (set! tmp.33 -1317068388)
                                      (!= tmp.33 -1173413790)))
                                (set! foo.2.2 -1192664449)
                                (begin
                                  (set! tmp.34 1374293415)
                                  (set! tmp.34 (* tmp.34 1))
                                  (set! foo.2.2 tmp.34)))
                            (set! foobar.5.1 -9223372036854775808)
                            (if (begin
                                  (set! bat.4.19 bat.4.4)
                                  (set! foo.2.18 foobar.5.1)
                                  (set! foo.3.17 bat.4.4)
                                  (set! foobar.6.16 430167017)
                                  (set! foobar.5.15 bat.4.4)
                                  (!= foobar.5.15 foo.3.17))
                                (halt foo.2.2)
                                (begin
                                  (set! foo.3.24 foo.2.2)
                                  (set! foo.8.23 foo.2.2)
                                  (set! foobar.5.22 foobar.5.1)
                                  (set! bar.1.21 bat.4.4)
                                  (set! bat.4.20 foo.3.3)
                                  (halt foo.3.24))))
                    ))
(check-by-interp '(module ((locals (foobar.3.28 foo.0.29
                                                bat.1.31
                                                ball.2.32
                                                foo.0.24
                                                ball.8.25
                                                foobar.3.26
                                                foo.4.27
                                                tmp.41
                                                foo.0.1
                                                tmp.40
                                                bat.1.2
                                                foo.6.3
                                                ball.8.4
                                                tmp.39
                                                foobar.3.16
                                                tmp.38
                                                tmp.37
                                                foo.0.17
                                                bat.1.18
                                                bat.1.20
                                                ball.2.21
                                                foo.0.22
                                                foo.4.23
                                                foo.6.19
                                                foo.4.5
                                                foobar.9.7
                                                foobar.9.13
                                                foo.6.14
                                                bat.1.15
                                                foo.4.8
                                                tmp.36
                                                foo.6.9
                                                foobar.5.10
                                                tmp.35
                                                ball.8.11
                                                tmp.34
                                                tmp.33
                                                ball.2.12
                                                foobar.5.6
                                                foobar.5.30)))
                          (begin
                            (set! foobar.5.6 1)
                            (if (begin
                                  (set! tmp.33 -862930824)
                                  (<= tmp.33 -1170986438))
                                (set! ball.2.12 -1031457151)
                                (set! ball.2.12 1))
                            (set! tmp.34 -9223372036854775808)
                            (set! tmp.34 (+ tmp.34 0))
                            (set! ball.8.11 tmp.34)
                            (set! tmp.35 -9223372036854775808)
                            (set! tmp.35 (* tmp.35 0))
                            (set! foobar.5.10 tmp.35)
                            (if (begin
                                  (set! tmp.36 -9223372036854775808)
                                  (= tmp.36 0))
                                (set! foo.6.9 -9223372036854775808)
                                (set! foo.6.9 1938254050))
                            (set! foo.4.8 -9223372036854775808)
                            (set! bat.1.15 -9223372036854775808)
                            (set! foo.6.14 -9223372036854775808)
                            (set! foobar.9.13 0)
                            (set! foobar.9.7 foo.6.14)
                            (set! foo.4.5 foo.6.9)
                            (set! foo.6.19 460545466)
                            (set! foo.4.23 -2033025861)
                            (set! foo.0.22 1)
                            (set! ball.2.21 0)
                            (set! bat.1.20 1)
                            (set! bat.1.18 ball.2.21)
                            (if (begin
                                  (set! tmp.37 -9223372036854775808)
                                  (> tmp.37 -459088038))
                                (set! foo.0.17 0)
                                (set! foo.0.17 0))
                            (set! tmp.38 1521054237)
                            (set! tmp.38 (+ tmp.38 935219322))
                            (set! foobar.3.16 tmp.38)
                            (set! tmp.39 foo.6.19)
                            (set! tmp.39 (+ tmp.39 bat.1.18))
                            (set! ball.8.4 tmp.39)
                            (set! foo.6.3 1)
                            (set! bat.1.2 1)
                            (set! tmp.40 -1391596256)
                            (set! tmp.40 (* tmp.40 218423145))
                            (set! foo.0.1 tmp.40)
                            (set! tmp.41 foo.6.3)
                            (set! tmp.41 (+ tmp.41 ball.8.4))
                            (set! foo.4.27 tmp.41)
                            (set! foobar.3.26 foo.6.3)
                            (if (<= bat.1.2 foo.4.5)
                                (set! ball.8.25 foo.4.5)
                                (set! ball.8.25 foobar.5.6))
                            (set! foo.0.24 foo.6.3)
                            (set! ball.2.32 bat.1.2)
                            (set! bat.1.31 foobar.5.6)
                            (set! foobar.5.30 foobar.5.6)
                            (set! foo.0.29 foobar.5.6)
                            (set! foobar.3.28 foobar.5.6)
                            (halt foobar.5.30))
                    ))
(check-by-interp '(module ((locals (ball.0.23 foobar.5.21
                                              foobar.6.1
                                              tmp.35
                                              ball.9.9
                                              tmp.34
                                              bat.3.10
                                              foobar.7.11
                                              tmp.32
                                              tmp.33
                                              tmp.31
                                              foobar.5.12
                                              ball.8.14
                                              ball.0.15
                                              bar.2.16
                                              foobar.6.17
                                              ball.1.18
                                              ball.9.19
                                              ball.8.20
                                              bat.4.13
                                              tmp.29
                                              tmp.30
                                              ball.0.2
                                              tmp.28
                                              tmp.27
                                              foobar.5.3
                                              tmp.26
                                              ball.0.4
                                              bat.4.5
                                              tmp.25
                                              ball.1.6
                                              tmp.24
                                              foobar.6.7
                                              foobar.7.8
                                              foobar.7.22)))
                          (begin
                            (if (true)
                                (set! ball.0.2 0)
                                (begin
                                  (set! foobar.7.8 1)
                                  (if (begin
                                        (set! tmp.24 -1818434681)
                                        (> tmp.24 -9223372036854775808))
                                      (set! foobar.6.7 -9223372036854775808)
                                      (set! foobar.6.7 -135823380))
                                  (if (begin
                                        (set! tmp.25 -1637731979)
                                        (> tmp.25 -1799338585))
                                      (set! ball.1.6 1283775776)
                                      (set! ball.1.6 0))
                                  (set! bat.4.5 -722132158)
                                  (if (begin
                                        (set! tmp.26 -2054485579)
                                        (>= tmp.26 1))
                                      (set! ball.0.4 0)
                                      (set! ball.0.4 -153435165))
                                  (if (begin
                                        (set! tmp.27 1)
                                        (> tmp.27 -2075859550))
                                      (set! foobar.5.3 2146470798)
                                      (set! foobar.5.3 1))
                                  (set! tmp.28 ball.0.4)
                                  (set! tmp.28 (* tmp.28 ball.0.4))
                                  (set! ball.0.2 tmp.28)))
                            (if (true)
                                (if (begin
                                      (set! tmp.29 -9223372036854775808)
                                      (= tmp.29 0))
                                    (set! bat.4.13 -1162069113)
                                    (set! bat.4.13 -9223372036854775808))
                                (if (begin
                                      (set! tmp.30 0)
                                      (< tmp.30 -362354188))
                                    (set! bat.4.13 1)
                                    (set! bat.4.13 0)))
                            (set! ball.8.20 1)
                            (set! ball.9.19 0)
                            (set! ball.1.18 172724818)
                            (set! foobar.6.17 1)
                            (set! bar.2.16 -9223372036854775808)
                            (set! ball.0.15 0)
                            (set! ball.8.14 ball.1.18)
                            (if (begin
                                  (set! tmp.31 0)
                                  (<= tmp.31 ball.8.14))
                                (set! foobar.5.12 ball.8.14)
                                (set! foobar.5.12 -9223372036854775808))
                            (if (true)
                                (begin
                                  (set! tmp.32 1)
                                  (set! tmp.32 (+ tmp.32 0))
                                  (set! foobar.7.11 tmp.32))
                                (if (begin
                                      (set! tmp.33 0)
                                      (<= tmp.33 1))
                                    (set! foobar.7.11 1030684098)
                                    (set! foobar.7.11 -9223372036854775808)))
                            (set! bat.3.10 869914910)
                            (set! tmp.34 -1692076239)
                            (set! tmp.34 (* tmp.34 -9223372036854775808))
                            (set! ball.9.9 tmp.34)
                            (set! tmp.35 bat.4.13)
                            (set! tmp.35 (* tmp.35 foobar.5.12))
                            (set! foobar.6.1 tmp.35)
                            (if (> foobar.6.1 ball.0.2)
                                (set! foobar.5.21 0)
                                (set! foobar.5.21 ball.0.2))
                            (set! ball.0.23 0)
                            (set! foobar.7.22 ball.0.2)
                            (halt foobar.7.22))
                    ))
;;; Added by Trevor on 2026-03-18
