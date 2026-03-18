#lang racket
(require rackunit
         cpsc411/langs/v4
         (only-in "../optimize-jumps.rkt" optimize-jumps))

(define (check-block-asm-lang-v4 p)
  (if (block-asm-lang-v4? p) p #f))

(define (check-block-asm-lang-v4 p)
  (if (block-asm-lang-v4? p) p #f))

(define-syntax-rule (check-by-interp p)
  (check-equal? (interp-block-asm-lang-v4 (check-block-asm-lang-v4 p))
                (interp-block-asm-lang-v4 (check-block-asm-lang-v4 (optimize-jumps p)))))

;;; Added by Trevor on 2026-03-18

(check-by-interp '(module (define L.__main.1
                            (begin
                              (set! r15 -9223372036854775808)
                              (set! r15 (* r15 1919678055))
                              (set! r15 r15)
                              (halt -9223372036854775808)))))
(check-by-interp '(module (define L.__main.1
                            (begin
                              (set! r15 -9223372036854775808)
                              (set! r15 607177860)
                              (set! r14 689406262)
                              (halt 607177860)))))
(check-by-interp '(module (define L.__main.3
                            (begin
                              (set! r15 293371207)
                              (set! r14 1)
                              (set! r14 (* r14 -1167539343))
                              (set! r13 r14)
                              (set! r9 -9223372036854775808)
                              (set! r14 0)
                              (jump L.__nested.2)))
                          (define L.__nested.1 (halt 293371207))
                    (define L.__nested.2 (halt -9223372036854775808))))
(check-by-interp '(module (define L.__main.4
                            (begin
                              (set! r15 1)
                              (set! r15 (+ r15 -9223372036854775808))
                              (set! r15 r15)
                              (set! r14 1)
                              (set! r14 (+ r14 1))
                              (set! r14 r14)
                              (set! r14 722151544)
                              (jump L.tmp.2)))
                          (define L.tmp.1
                            (begin
                              (set! r14 1)
                              (jump L.tmp.3)))
                    (define L.tmp.2
                      (begin
                        (set! r14 -1807150378)
                        (jump L.tmp.3)))
                    (define L.tmp.3
                      (begin
                        (set! r14 r14)
                        (set! r14 (* r14 r15))
                        (set! r15 r14)
                        (halt r15)))))
(check-by-interp '(module (define L.__main.6
                            (begin
                              (set! r15 0)
                              (set! r15 (* r15 1))
                              (set! r15 r15)
                              (set! r14 0)
                              (jump L.tmp.3)))
                          (define L.__nested.1 (halt r14))
                    (define L.__nested.2 (halt -9223372036854775808))
                    (define L.tmp.3
                      (begin
                        (set! r14 1204486682)
                        (jump L.tmp.5)))
                    (define L.tmp.4
                      (begin
                        (set! r14 -9223372036854775808)
                        (jump L.tmp.5)))
                    (define L.tmp.5
                      (if (< r14 r15)
                          (jump L.__nested.1)
                          (jump L.__nested.2)))))
(check-by-interp '(module (define L.__main.5
                            (begin
                              (set! r15 1445608166)
                              (set! r15 0)
                              (set! r14 0)
                              (set! r14 1)
                              (jump L.__nested.2)))
                          (define L.__nested.3 (halt 1))
                    (define L.__nested.4 (halt -1735070759))
                    (define L.__nested.1 (halt -9223372036854775808))
                    (define L.__nested.2
                      (begin
                        (set! r15 0)
                        (jump L.__nested.3)))))
(check-by-interp '(module (define L.__main.4
                            (begin
                              (set! r15 -1840576987)
                              (set! r15 254778871)
                              (set! r14 756663068)
                              (jump L.tmp.2)))
                          (define L.tmp.1
                            (begin
                              (set! r14 -2062043463)
                              (jump L.tmp.3)))
                    (define L.tmp.2
                      (begin
                        (set! r14 0)
                        (jump L.tmp.3)))
                    (define L.tmp.3
                      (begin
                        (set! r13 0)
                        (set! r13 r13)
                        (set! r15 r15)
                        (set! r14 r14)
                        (set! r14 r14)
                        (halt 254778871)))))
(check-by-interp '(module (define L.__main.3
                            (begin
                              (set! r15 2000695989)
                              (jump L.__nested.1)))
                          (define L.__nested.1
                            (begin
                              (set! r15 0)
                              (set! r15 0)
                              (set! r15 0)
                              (set! r15 -927113299)
                              (set! r15 568308046)
                              (halt 568308046)))
                    (define L.__nested.2
                      (begin
                        (set! r15 -983250820)
                        (set! r14 1)
                        (set! r14 1318080036)
                        (halt -983250820)))))
(check-by-interp '(module (define L.__main.4
                            (begin
                              (set! r15 -2009338866)
                              (set! r15 -9223372036854775808)
                              (set! r15 r15)
                              (set! r14 2060014662)
                              (jump L.tmp.1)))
                          (define L.tmp.1
                            (begin
                              (set! r14 1)
                              (jump L.tmp.3)))
                    (define L.tmp.2
                      (begin
                        (set! r14 1)
                        (jump L.tmp.3)))
                    (define L.tmp.3
                      (begin
                        (set! r14 1)
                        (set! r13 230093260)
                        (set! r13 900177895)
                        (set! r15 r15)
                        (set! r14 r14)
                        (halt -9223372036854775808)))))
(check-by-interp '(module (define L.__main.1
                            (begin
                              (set! r15 1)
                              (set! r15 -9223372036854775808)
                              (set! r14 -502362832)
                              (set! r15 1)
                              (halt -502362832)))))
(check-by-interp '(module (define L.__main.5
                            (begin
                              (set! r15 -9223372036854775808)
                              (jump L.tmp.3)))
                          (define L.tmp.3
                            (begin
                              (set! r15 -9223372036854775808)
                              (jump L.__nested.1)))
                    (define L.tmp.4
                      (begin
                        (set! r15 1099135664)
                        (jump L.__nested.2)))
                    (define L.__nested.1 (halt 1))
                    (define L.__nested.2
                      (begin
                        (set! r15 0)
                        (set! r15 -9223372036854775808)
                        (set! r15 -1137161966)
                        (halt -1137161966)))))
(check-by-interp '(module (define L.__main.1
                            (begin
                              (set! r15 509793927)
                              (set! r15 -9223372036854775808)
                              (set! r14 -9223372036854775808)
                              (set! r14 -9223372036854775808)
                              (set! r14 874466679)
                              (halt -9223372036854775808)))))
(check-by-interp '(module (define L.__main.1
                            (begin
                              (set! r15 1)
                              (set! r15 (* r15 1742654658))
                              (set! r13 r15)
                              (set! r15 -1437539357)
                              (set! r14 -9223372036854775808)
                              (set! r9 1)
                              (set! r14 -1557481616)
                              (set! r14 r14)
                              (set! r9 r9)
                              (set! r13 r13)
                              (set! r15 r15)
                              (set! r15 r9)
                              (set! r14 r14)
                              (halt 1)))))
(check-by-interp '(module (define L.__main.7
                            (begin
                              (set! r15 1224363849)
                              (jump L.tmp.4)))
                          (define L.tmp.4
                            (begin
                              (set! r14 -1341816285)
                              (jump L.tmp.6)))
                    (define L.tmp.5
                      (begin
                        (set! r14 0)
                        (jump L.tmp.6)))
                    (define L.tmp.6
                      (begin
                        (set! r15 1)
                        (jump L.tmp.1)))
                    (define L.tmp.1
                      (begin
                        (set! r13 -1095031)
                        (jump L.tmp.3)))
                    (define L.tmp.2
                      (begin
                        (set! r13 -159334257)
                        (jump L.tmp.3)))
                    (define L.tmp.3
                      (begin
                        (set! r15 0)
                        (set! r15 934456620)
                        (set! r15 0)
                        (set! r13 r13)
                        (set! r14 r14)
                        (set! r14 r13)
                        (set! r14 2034424595)
                        (halt 0)))))
(check-by-interp '(module (define L.__main.1
                            (begin
                              (set! r15 2130780142)
                              (set! r14 -1626380896)
                              (set! r14 (+ r14 -9223372036854775808))
                              (set! r13 r14)
                              (set! r14 1)
                              (set! r14 (+ r14 -1358001385))
                              (set! r14 r14)
                              (set! r9 1)
                              (set! r9 r9)
                              (set! r9 (+ r9 r13))
                              (set! r13 r9)
                              (set! r15 r15)
                              (set! r14 r14)
                              (set! r15 r15)
                              (set! r15 r14)
                              (set! r15 (+ r15 1394508466))
                              (set! r15 r15)
                              (halt 36507082)))))
(check-by-interp '(module (define L.__main.1
                            (begin
                              (set! r15 1)
                              (set! r15 (+ r15 0))
                              (set! r15 r15)
                              (set! r14 0)
                              (set! r14 -9223372036854775808)
                              (set! r14 420120758)
                              (set! r14 950229390)
                              (set! r14 -9223372036854775808)
                              (set! r14 -1436788709)
                              (set! r14 351241708)
                              (set! r14 -46944546)
                              (set! r14 1)
                              (set! r14 (+ r14 -858099177))
                              (set! r14 r14)
                              (halt 1)))))
(check-by-interp '(module (define L.__main.9
                            (begin
                              (set! r15 0)
                              (jump L.tmp.7)))
                          (define L.__nested.1 (halt r15))
                    (define L.__nested.2 (halt r15))
                    (define L.tmp.6
                      (begin
                        (set! r15 1377663341)
                        (jump L.tmp.8)))
                    (define L.tmp.7
                      (begin
                        (set! r15 -1212687808)
                        (jump L.tmp.8)))
                    (define L.tmp.8
                      (begin
                        (set! r14 359103696)
                        (jump L.tmp.4)))
                    (define L.tmp.3
                      (begin
                        (set! r13 0)
                        (jump L.tmp.5)))
                    (define L.tmp.4
                      (begin
                        (set! r13 -9223372036854775808)
                        (jump L.tmp.5)))
                    (define L.tmp.5
                      (begin
                        (set! r14 -9223372036854775808)
                        (set! r9 0)
                        (set! r8 0)
                        (set! r9 r9)
                        (if (< r14 r13)
                            (jump L.__nested.1)
                            (jump L.__nested.2))))))
(check-by-interp '(module (define L.__main.7
                            (begin
                              (set! r15 1)
                              (jump L.tmp.4)))
                          (define L.tmp.4
                            (begin
                              (set! r15 1)
                              (jump L.tmp.6)))
                    (define L.tmp.5
                      (begin
                        (set! r15 1334663491)
                        (jump L.tmp.6)))
                    (define L.tmp.6
                      (begin
                        (set! r15 433059534)
                        (set! r15 1777050844)
                        (set! r14 1)
                        (jump L.tmp.1)))
                    (define L.tmp.1
                      (begin
                        (set! r14 1682963351)
                        (jump L.tmp.3)))
                    (define L.tmp.2
                      (begin
                        (set! r14 -9223372036854775808)
                        (jump L.tmp.3)))
                    (define L.tmp.3
                      (begin
                        (set! r14 -424296474)
                        (set! r14 (* r14 -1384099004))
                        (set! r14 r14)
                        (set! r14 -9223372036854775808)
                        (set! r15 r15)
                        (halt 1777050844)))))
(check-by-interp '(module (define L.__main.4
                            (begin
                              (set! r15 1)
                              (jump L.tmp.2)))
                          (define L.tmp.1
                            (begin
                              (set! r15 -353253341)
                              (jump L.tmp.3)))
                    (define L.tmp.2
                      (begin
                        (set! r15 1)
                        (jump L.tmp.3)))
                    (define L.tmp.3
                      (begin
                        (set! r15 0)
                        (set! r14 -1094240881)
                        (set! r14 1)
                        (set! r15 r15)
                        (set! r14 1)
                        (set! r14 432749591)
                        (set! r14 -421411277)
                        (set! r14 749377747)
                        (set! r13 -996428766)
                        (halt 749377747)))))
(check-by-interp '(module (define L.__main.3
                            (begin
                              (set! r15 -9223372036854775808)
                              (set! r15 1)
                              (set! r15 0)
                              (set! r15 -9223372036854775808)
                              (set! r14 1)
                              (set! r15 0)
                              (jump L.__nested.1)))
                          (define L.__nested.1
                            (begin
                              (set! r15 1)
                              (halt -941719640)))
                    (define L.__nested.2
                      (begin
                        (set! r15 120745579)
                        (set! r14 -987089435)
                        (set! r14 -76571663)
                        (set! r14 1)
                        (set! r14 1)
                        (set! r14 -1933482026)
                        (halt 120745579)))))
(check-by-interp '(module (define L.__main.4
                            (begin
                              (set! r15 1)
                              (set! r15 (* r15 495756801))
                              (set! r13 r15)
                              (set! r15 1020300534)
                              (jump L.tmp.2)))
                          (define L.tmp.1
                            (begin
                              (set! r15 1)
                              (jump L.tmp.3)))
                    (define L.tmp.2
                      (begin
                        (set! r15 1247921698)
                        (jump L.tmp.3)))
                    (define L.tmp.3
                      (begin
                        (set! r14 61219697)
                        (set! r14 (+ r14 1))
                        (set! r9 r14)
                        (set! r14 -738667072)
                        (set! r8 1)
                        (set! r8 r8)
                        (set! rdi 1)
                        (set! r13 r13)
                        (set! r13 r9)
                        (set! r13 r8)
                        (set! r14 r14)
                        (set! r14 r14)
                        (set! r14 1)
                        (halt r15)))))
(check-by-interp '(module (define L.__main.5
                            (begin
                              (set! r14 -573607979)
                              (set! r13 0)
                              (set! r15 -915462716)
                              (jump L.__nested.2)))
                          (define L.__nested.3 (halt 1))
                    (define L.__nested.4 (halt 158515729))
                    (define L.__nested.1
                      (begin
                        (set! r15 1388204095)
                        (jump L.__nested.3)))
                    (define L.__nested.2
                      (begin
                        (set! r15 1452522364)
                        (set! r15 1)
                        (set! r15 1)
                        (halt 1)))))
(check-by-interp '(module (define L.__main.4
                            (begin
                              (set! r15 917166060)
                              (set! r15 (+ r15 1734464315))
                              (set! r15 r15)
                              (set! r15 1)
                              (set! r15 1)
                              (set! r14 -1508855828)
                              (set! r14 1)
                              (set! r15 r15)
                              (set! r15 -9223372036854775808)
                              (jump L.tmp.2)))
                          (define L.tmp.1
                            (begin
                              (set! r15 1)
                              (jump L.tmp.3)))
                    (define L.tmp.2
                      (begin
                        (set! r15 1637767071)
                        (jump L.tmp.3)))
                    (define L.tmp.3
                      (begin
                        (set! r14 1223062971)
                        (set! r14 594357257)
                        (set! r13 1182737157)
                        (set! r13 -1866987123)
                        (set! r14 r14)
                        (halt r15)))))
(check-by-interp '(module (define L.__main.10
                            (begin
                              (set! r15 1)
                              (set! r14 0)
                              (jump L.tmp.8)))
                          (define L.tmp.7
                            (begin
                              (set! r14 1)
                              (jump L.tmp.9)))
                    (define L.tmp.8
                      (begin
                        (set! r14 82746644)
                        (jump L.tmp.9)))
                    (define L.tmp.9
                      (begin
                        (set! r14 -432462765)
                        (jump L.tmp.5)))
                    (define L.tmp.4
                      (begin
                        (set! r14 -9223372036854775808)
                        (jump L.tmp.6)))
                    (define L.tmp.5
                      (begin
                        (set! r14 0)
                        (jump L.tmp.6)))
                    (define L.tmp.6
                      (begin
                        (set! r14 -1245760310)
                        (set! r14 -9223372036854775808)
                        (jump L.tmp.2)))
                    (define L.tmp.1
                      (begin
                        (set! r14 1)
                        (jump L.tmp.3)))
                    (define L.tmp.2
                      (begin
                        (set! r14 0)
                        (jump L.tmp.3)))
                    (define L.tmp.3
                      (begin
                        (set! r13 1)
                        (set! r13 1356748148)
                        (set! r13 0)
                        (set! r13 0)
                        (set! r13 -1498191265)
                        (set! r13 r13)
                        (set! r15 r15)
                        (set! r14 r14)
                        (halt 1)))))
(check-by-interp '(module (define L.__main.1
                            (begin
                              (set! r15 -9223372036854775808)
                              (set! r15 (+ r15 0))
                              (set! r15 r15)
                              (set! r15 -1016442341)
                              (set! r15 1416892493)
                              (set! r15 1)
                              (set! r15 -1826864241)
                              (set! r15 -9223372036854775808)
                              (set! r15 -9223372036854775808)
                              (set! r14 440337125)
                              (set! r14 (* r14 86379188))
                              (set! r14 r14)
                              (set! r14 1)
                              (set! r14 (+ r14 1432660723))
                              (set! r14 r14)
                              (set! r15 r15)
                              (set! r15 -9223372036854775808)
                              (set! r15 (+ r15 554830987))
                              (set! r15 r15)
                              (set! r15 0)
                              (set! r15 1536405233)
                              (set! r15 (+ r15 0))
                              (set! r15 r15)
                              (halt 1536405233)))))
(check-by-interp '(module (define L.__main.1
                            (begin
                              (set! r15 -9223372036854775808)
                              (set! r15 (* r15 -1157863409))
                              (set! r15 r15)
                              (set! r15 1744993864)
                              (set! r14 -1918619273)
                              (set! r14 -9223372036854775808)
                              (set! r14 76920539)
                              (set! r14 0)
                              (set! r14 1085636044)
                              (set! r14 r14)
                              (set! r14 -9223372036854775808)
                              (set! r14 (+ r14 -9223372036854775808))
                              (set! r14 r14)
                              (set! r13 -1466502296)
                              (set! r13 0)
                              (set! r13 r13)
                              (set! r13 0)
                              (set! r13 r13)
                              (set! r15 r15)
                              (set! r15 1706452662)
                              (halt 0)))))
(check-by-interp '(module (define L.__main.7
                            (begin
                              (set! r15 0)
                              (set! r15 1)
                              (set! r15 -9223372036854775808)
                              (set! r14 668102712)
                              (set! r14 0)
                              (set! r14 -9223372036854775808)
                              (set! r15 r15)
                              (set! r14 -118645994)
                              (set! r14 -333498877)
                              (jump L.tmp.4)))
                          (define L.tmp.4
                            (begin
                              (set! r9 1)
                              (jump L.tmp.6)))
                    (define L.tmp.5
                      (begin
                        (set! r9 1)
                        (jump L.tmp.6)))
                    (define L.tmp.6
                      (begin
                        (set! r14 414168669)
                        (jump L.tmp.2)))
                    (define L.tmp.1
                      (begin
                        (set! r13 0)
                        (jump L.tmp.3)))
                    (define L.tmp.2
                      (begin
                        (set! r13 -9223372036854775808)
                        (jump L.tmp.3)))
                    (define L.tmp.3
                      (begin
                        (set! r14 -9223372036854775808)
                        (set! r14 (* r14 -9223372036854775808))
                        (set! r14 r14)
                        (set! r9 r9)
                        (set! r15 r15)
                        (set! r15 r13)
                        (set! r15 r13)
                        (set! r15 r13)
                        (set! r15 r14)
                        (halt 0)))))
(check-by-interp '(module (define L.__main.13
                            (begin
                              (set! r15 -9223372036854775808)
                              (set! r14 -9223372036854775808)
                              (set! r14 (* r14 -9223372036854775808))
                              (set! r14 r14)
                              (set! r14 0)
                              (jump L.tmp.7)))
                          (define L.tmp.10
                            (begin
                              (set! r14 571243347)
                              (jump L.tmp.12)))
                    (define L.tmp.11
                      (begin
                        (set! r14 610130973)
                        (jump L.tmp.12)))
                    (define L.tmp.12 (jump L.tmp.9))
                    (define L.tmp.7
                      (begin
                        (set! r14 -9223372036854775808)
                        (jump L.tmp.10)))
                    (define L.tmp.8
                      (begin
                        (set! r14 -9223372036854775808)
                        (set! r14 (+ r14 1))
                        (set! r14 r14)
                        (jump L.tmp.9)))
                    (define L.tmp.9
                      (begin
                        (set! r13 1256333532)
                        (set! r13 0)
                        (jump L.tmp.5)))
                    (define L.tmp.4
                      (begin
                        (set! r13 1)
                        (jump L.tmp.6)))
                    (define L.tmp.5
                      (begin
                        (set! r13 -9223372036854775808)
                        (set! r13 (* r13 -424152180))
                        (set! r13 r13)
                        (jump L.tmp.6)))
                    (define L.tmp.6
                      (begin
                        (set! r14 r14)
                        (set! r14 913593729)
                        (set! r14 (+ r14 1))
                        (set! r14 r14)
                        (set! r14 1)
                        (set! r14 0)
                        (set! r14 0)
                        (set! r14 (* r14 -535871239))
                        (set! r14 r14)
                        (set! r14 -353070992)
                        (jump L.tmp.1)))
                    (define L.tmp.1
                      (begin
                        (set! r14 1)
                        (set! r14 (+ r14 0))
                        (set! r14 r14)
                        (jump L.tmp.3)))
                    (define L.tmp.2
                      (begin
                        (set! r14 -9223372036854775808)
                        (set! r14 (* r14 1))
                        (set! r14 r14)
                        (jump L.tmp.3)))
                    (define L.tmp.3
                      (begin
                        (set! r14 r14)
                        (halt -9223372036854775808)))))
(check-by-interp '(module (define L.__main.9
                            (begin
                              (set! r15 1)
                              (jump L.__nested.1)))
                          (define L.tmp.6
                            (begin
                              (set! r15 0)
                              (jump L.tmp.8)))
                    (define L.tmp.7
                      (begin
                        (set! r15 -1965042386)
                        (jump L.tmp.8)))
                    (define L.tmp.8
                      (begin
                        (set! r14 0)
                        (jump L.tmp.4)))
                    (define L.tmp.3
                      (begin
                        (set! r14 -9223372036854775808)
                        (jump L.tmp.5)))
                    (define L.tmp.4
                      (begin
                        (set! r14 -9223372036854775808)
                        (jump L.tmp.5)))
                    (define L.tmp.5
                      (begin
                        (set! r15 r15)
                        (set! r15 (* r15 -9223372036854775808))
                        (set! r15 r15)
                        (halt r15)))
                    (define L.__nested.1
                      (begin
                        (set! r15 -1486589648)
                        (set! r15 r15)
                        (set! r15 (* r15 r15))
                        (set! r15 r15)
                        (halt 2209948781540763904)))
                    (define L.__nested.2
                      (begin
                        (set! r15 -9223372036854775808)
                        (set! r15 -1625696401)
                        (set! r15 -15834334)
                        (set! r15 1917576020)
                        (set! r15 -698078301)
                        (set! r14 -2018556296)
                        (set! r15 r15)
                        (set! r15 1)
                        (jump L.tmp.6)))))
(check-by-interp '(module (define L.__main.20
                            (begin
                              (set! r15 1)
                              (jump L.tmp.18)))
                          (define L.__nested.1 (halt r9))
                    (define L.__nested.2
                      (begin
                        (set! r9 r9)
                        (set! r8 r9)
                        (set! r13 r13)
                        (set! r15 r15)
                        (set! r15 r14)
                        (halt r9)))
                    (define L.tmp.17
                      (begin
                        (set! r15 -968056241)
                        (jump L.tmp.19)))
                    (define L.tmp.18
                      (begin
                        (set! r15 -603018045)
                        (jump L.tmp.19)))
                    (define L.tmp.19
                      (begin
                        (set! r14 903109867)
                        (set! r14 -2096973776)
                        (set! r14 844611670)
                        (jump L.tmp.14)))
                    (define L.tmp.14
                      (begin
                        (set! r14 0)
                        (jump L.tmp.16)))
                    (define L.tmp.15
                      (begin
                        (set! r14 1)
                        (jump L.tmp.16)))
                    (define L.tmp.16
                      (begin
                        (set! r14 1461159574)
                        (set! r14 (* r14 886215187))
                        (set! r14 r14)
                        (set! r15 r15)
                        (set! r15 (+ r15 r14))
                        (set! r15 r15)
                        (set! r14 1)
                        (set! r14 633639708)
                        (set! r13 1169357215)
                        (set! r9 1853746647)
                        (set! r13 -1584162714)
                        (jump L.tmp.9)))
                    (define L.tmp.11
                      (begin
                        (set! r14 0)
                        (jump L.tmp.13)))
                    (define L.tmp.12
                      (begin
                        (set! r14 1)
                        (jump L.tmp.13)))
                    (define L.tmp.13 (jump L.tmp.10))
                    (define L.tmp.8
                      (begin
                        (set! r14 1)
                        (set! r14 (* r14 0))
                        (set! r14 r14)
                        (jump L.tmp.10)))
                    (define L.tmp.9
                      (begin
                        (set! r14 0)
                        (jump L.tmp.12)))
                    (define L.tmp.10
                      (begin
                        (set! r13 799518468)
                        (jump L.tmp.6)))
                    (define L.tmp.6
                      (begin
                        (set! r13 1925095941)
                        (jump L.tmp.3)))
                    (define L.tmp.7
                      (begin
                        (set! r13 -1317068388)
                        (jump L.tmp.3)))
                    (define L.tmp.3
                      (begin
                        (set! r9 -1192664449)
                        (jump L.tmp.5)))
                    (define L.tmp.4
                      (begin
                        (set! r13 1374293415)
                        (set! r13 (* r13 1))
                        (set! r9 r13)
                        (jump L.tmp.5)))
                    (define L.tmp.5
                      (begin
                        (set! r13 -9223372036854775808)
                        (set! r15 r15)
                        (set! r13 r13)
                        (set! r15 r15)
                        (set! r8 430167017)
                        (set! r8 r15)
                        (if (!= r8 r15)
                            (jump L.__nested.1)
                            (jump L.__nested.2))))))
(check-by-interp '(module (define L.__main.13
                            (begin
                              (set! r15 1)
                              (set! r14 -862930824)
                              (jump L.tmp.11)))
                          (define L.tmp.10
                            (begin
                              (set! r14 -1031457151)
                              (jump L.tmp.12)))
                    (define L.tmp.11
                      (begin
                        (set! r14 1)
                        (jump L.tmp.12)))
                    (define L.tmp.12
                      (begin
                        (set! r14 -9223372036854775808)
                        (set! r14 (+ r14 0))
                        (set! r14 r14)
                        (set! r14 -9223372036854775808)
                        (set! r14 (* r14 0))
                        (set! r14 r14)
                        (set! r14 -9223372036854775808)
                        (jump L.tmp.8)))
                    (define L.tmp.7
                      (begin
                        (set! r14 -9223372036854775808)
                        (jump L.tmp.9)))
                    (define L.tmp.8
                      (begin
                        (set! r14 1938254050)
                        (jump L.tmp.9)))
                    (define L.tmp.9
                      (begin
                        (set! r13 -9223372036854775808)
                        (set! r13 -9223372036854775808)
                        (set! r13 -9223372036854775808)
                        (set! r9 0)
                        (set! r13 r13)
                        (set! r14 r14)
                        (set! r13 460545466)
                        (set! r9 -2033025861)
                        (set! r9 1)
                        (set! r9 0)
                        (set! r8 1)
                        (set! r9 r9)
                        (set! r8 -9223372036854775808)
                        (jump L.tmp.5)))
                    (define L.tmp.4
                      (begin
                        (set! r8 0)
                        (jump L.tmp.6)))
                    (define L.tmp.5
                      (begin
                        (set! r8 0)
                        (jump L.tmp.6)))
                    (define L.tmp.6
                      (begin
                        (set! r8 1521054237)
                        (set! r8 (+ r8 935219322))
                        (set! r8 r8)
                        (set! r13 r13)
                        (set! r13 (+ r13 r9))
                        (set! r8 r13)
                        (set! r9 1)
                        (set! r13 1)
                        (set! rdi -1391596256)
                        (set! rdi (* rdi 218423145))
                        (set! rdi rdi)
                        (set! rdi r9)
                        (set! rdi (+ rdi r8))
                        (set! r8 rdi)
                        (set! r9 r9)
                        (if (<= r13 r14)
                            (jump L.tmp.1)
                            (jump L.tmp.2))))
                    (define L.tmp.1
                      (begin
                        (set! r14 r14)
                        (jump L.tmp.3)))
                    (define L.tmp.2
                      (begin
                        (set! r14 r15)
                        (jump L.tmp.3)))
                    (define L.tmp.3
                      (begin
                        (set! r14 r9)
                        (set! r14 r13)
                        (set! r15 r15)
                        (set! r15 r15)
                        (set! r14 r15)
                        (set! r14 r15)
                        (halt 1)))))
(check-by-interp '(module (define L.__main.10
                            (begin
                              (set! r15 0)
                              (set! r14 -9223372036854775808)
                              (jump L.tmp.8)))
                          (define L.tmp.7
                            (begin
                              (set! r14 -1162069113)
                              (jump L.tmp.9)))
                    (define L.tmp.8
                      (begin
                        (set! r14 -9223372036854775808)
                        (jump L.tmp.9)))
                    (define L.tmp.9
                      (begin
                        (set! r13 1)
                        (set! r13 0)
                        (set! r13 172724818)
                        (set! r9 1)
                        (set! r9 -9223372036854775808)
                        (set! r9 0)
                        (set! r13 r13)
                        (set! r9 0)
                        (jump L.tmp.4)))
                    (define L.tmp.4
                      (begin
                        (set! r13 r13)
                        (jump L.tmp.6)))
                    (define L.tmp.5
                      (begin
                        (set! r13 -9223372036854775808)
                        (jump L.tmp.6)))
                    (define L.tmp.6
                      (begin
                        (set! r9 1)
                        (set! r9 (+ r9 0))
                        (set! r9 r9)
                        (set! r9 869914910)
                        (set! r9 -1692076239)
                        (set! r9 (* r9 -9223372036854775808))
                        (set! r9 r9)
                        (set! r14 r14)
                        (set! r14 (* r14 r13))
                        (set! r14 r14)
                        (if (> r14 r15)
                            (jump L.tmp.1)
                            (jump L.tmp.2))))
                    (define L.tmp.1
                      (begin
                        (set! r14 0)
                        (jump L.tmp.3)))
                    (define L.tmp.2
                      (begin
                        (set! r14 r15)
                        (jump L.tmp.3)))
                    (define L.tmp.3
                      (begin
                        (set! r14 0)
                        (set! r15 r15)
                        (halt 0)))))
;;; Added by Trevor on 2026-03-18
