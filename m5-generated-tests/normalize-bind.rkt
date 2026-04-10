#lang racket
(require rackunit
         cpsc411/langs/v5
         cpsc411/compiler-lib
         "../normalize-bind.rkt")

(define (check-input p)
  (if (imp-mf-lang-v5? p)
      p
      (error
       (~a (pretty-format p) "\n is not a semantically valid " "imp-mf-lang-v5?" " program"))))

(define (check-output p)
  (if (proc-imp-cmf-lang-v5? p)
      p
      (error (~a (pretty-format p) "\n is not a semantically valid " "proc-imp-cmf-lang-v5" " program"))))


(define-syntax-rule (check-by-interp p)
  (check-equal? (interp-imp-mf-lang-v5 (check-input p))
                (interp-proc-imp-cmf-lang-v5 (check-output (normalize-bind p)))))

;; M5 tests; Added by Trevor on March 8th 2026, multiple bindings allowed per let
(check-by-interp '(module (define L.fn.0.1
                            (lambda (bat.1.6 foobar.5.5 foobar.8.4 foo.0.3 foo.3.2 foo.4.1)
                              (if (true)
                                  (if (= -502092639 foobar.5.5)
                                      (if (>= foobar.8.4 1) 1852032564 -106704231)
                                      (+ foo.4.1 1))
                                  (if (true)
                                      (+ -9223372036854775808 0)
                                      (begin
                                        (set! foo.4.8 foobar.5.5)
                                        (set! foo.3.7 0)
                                        foo.0.3)))))
                          (if (begin
                                (set! foo.4.10 -9223372036854775808)
                                (set! ball.7.9 0)
                                (> foo.4.10 ball.7.9))
                              -9223372036854775808
                              (begin
                                (set! bat.1.13 -9223372036854775808)
                                (set! foo.4.12 1)
                                (set! foobar.8.11 1)
                                foobar.8.11))
                    ))
(check-by-interp
 '(module (define L.tmp.0.1
            (lambda (bat.2.6 bat.0.5 foobar.5.4 foobar.6.3 bat.8.2 foo.9.1)
              (begin
                (set! foobar.6.8
                      (if (true)
                          (* bat.0.5 -1194246923)
                          foobar.5.4))
                (set! foobar.5.7
                      (if (begin
                            (set! bat.2.10 foobar.5.4)
                            (set! bat.4.9 foo.9.1)
                            (= bat.2.10 422731415))
                          (if (<= 9223372036854775807 9223372036854775807)
                              9223372036854775807
                              9223372036854775807)
                          (+ foo.9.1 52582991)))
                (call L.tmp.0.1 foobar.6.8 -191435828 -1002513727 0 bat.8.2 foo.9.1))))
          (begin
            (set! bat.0.12 (+ -9223372036854775808 937267391))
            (set! bat.2.11 (+ -9223372036854775808 -9223372036854775808))
            (if (!= bat.2.11 1) -335809824 bat.0.12))
    ))
(check-by-interp '(module (define L.proc.0.1
                            (lambda (ball.1.3 bat.9.2 foobar.2.1)
                              (if (false)
                                  (call L.tmp.1.2 bat.9.2 9223372036854775807 bat.9.2 ball.1.3 1)
                                  (begin
                                    (set! bat.7.6
                                          (begin
                                            (set! bar.5.8 1554173211)
                                            (set! foobar.2.7 616342412)
                                            foobar.2.7))
                                    (set! ball.1.5 (if (= foobar.2.1 ball.1.3) foobar.2.1 bat.9.2))
                                    (set! ball.3.4 (if (= 1 0) bat.9.2 0))
                                    (if (< 1320805275 9223372036854775807) 0 0)))))
                          (define L.tmp.1.2
                            (lambda (bat.7.13 ball.1.12 foobar.2.11 ball.3.10 ball.8.9)
                              (call L.proc.0.1 ball.3.10 9223372036854775807 ball.8.9)))
                    (begin
                      (set! foo.6.16
                            (begin
                              (set! foobar.0.19 2142022224)
                              (set! foo.6.18 0)
                              (set! bat.7.17 1)
                              foo.6.18))
                      (set! foobar.2.15 (+ 1 121573080))
                      (set! bat.9.14 (* 9223372036854775807 -1355489058))
                      0)))
(check-by-interp '(module (begin
                            (set! ball.5.3 (+ 0 9223372036854775807))
                            (set! ball.7.2 -678062995)
                            (set! ball.8.1
                                  (if (!= 0 9223372036854775807) -2004574473 9223372036854775807))
                            (* 1 ball.5.3))))
(check-by-interp
 '(module (define L.fn.0.1 (lambda (foo.3.3 foo.1.2 bat.4.1) (call L.fn.0.1 foo.1.2 bat.4.1 foo.1.2)))
          (define L.tmp.1.2
            (lambda ()
              (if (true)
                  (begin
                    (set! ball.0.6
                          (begin
                            (set! foo.1.8 -918704320)
                            (set! foo.6.7 -1822595193)
                            foo.6.7))
                    (set! bat.4.5 0)
                    (set! foo.7.4 (* 9223372036854775807 810114007))
                    (begin
                      (set! foo.9.11 1)
                      (set! foo.7.10 foo.7.4)
                      (set! bat.8.9 1)
                      1271317139))
                  (if (begin
                        (set! ball.0.13 9223372036854775807)
                        (set! foobar.5.12 -9223372036854775808)
                        (< 1474008962 ball.0.13))
                      (if (!= -566856990 -9223372036854775808) 1 1056302987)
                      (call L.tmp.1.2)))))
    (begin
      (set! foo.1.15
            (begin
              (set! bat.4.17 -9223372036854775808)
              (set! foo.7.16 9223372036854775807)
              bat.4.17))
      (set! foo.6.14 (if (>= -1846550218 1836975164) -186139937 1))
      (begin
        (set! foo.7.19 1884722986)
        (set! foo.6.18 9223372036854775807)
        0))))
(check-by-interp '(module (define L.func.0.1
                            (lambda (bat.0.6 bat.7.5 bar.6.4 foo.2.3 foobar.5.2 foo.9.1) bat.0.6))
                          (define L.func.1.2
                            (lambda (foobar.1.8 bat.0.7)
                              (begin
                                (set! foobar.1.11
                                      (begin
                                        (set! bat.8.13 0)
                                        (set! bar.3.12
                                              (begin
                                                (set! foo.2.16 foobar.1.8)
                                                (set! bat.8.15 1492712685)
                                                (set! foo.4.14 foobar.1.8)
                                                9223372036854775807))
                                        bar.3.12))
                                (set! bar.3.10
                                      (begin
                                        (set! foobar.5.18
                                              (begin
                                                (set! bat.8.21 bat.0.7)
                                                (set! foo.2.20 foobar.1.8)
                                                (set! foo.4.19 -383652955)
                                                -9223372036854775808))
                                        (set! foobar.1.17 (+ bat.0.7 566306668))
                                        (if (!= bat.0.7 0) -9223372036854775808 bat.0.7)))
                                (set! bat.0.9
                                      (if (false)
                                          (* 1 0)
                                          foobar.1.8))
                                bar.3.10)))
                    (call L.func.1.2 -9223372036854775808 0)))
(check-by-interp
 '(module (define L.tmp.0.1
            (lambda (foobar.0.6 bar.7.5 foo.5.4 bat.2.3 bar.3.2 bar.8.1)
              (begin
                (set! bar.8.8 bat.2.3)
                (set! bar.7.7 1)
                (if (if (!= bar.7.7 foobar.0.6)
                        (<= -494940107 bar.3.2)
                        (< 0 1869530139))
                    (if (<= bar.7.7 0) 0 -777687734)
                    (if (> -9223372036854775808 foo.5.4) 9223372036854775807 -9223372036854775808)))))
          9223372036854775807
    ))
(check-by-interp '(module (if (true)
                              (begin
                                (set! foo.0.2 1)
                                (set! foo.8.1 0)
                                356048754)
                              (if (<= -1287356538 1126106862) 4712028 349517812))))
(check-by-interp
 '(module (define L.fn.0.1
            (lambda ()
              (begin
                (set! bar.8.2 (* -9223372036854775808 0))
                (set! foobar.1.1
                      (begin
                        (set! ball.3.5
                              (begin
                                (set! foobar.7.7 0)
                                (set! bar.2.6 9223372036854775807)
                                foobar.7.7))
                        (set! foobar.0.4
                              (begin
                                (set! bar.8.10 1)
                                (set! ball.3.9 -9223372036854775808)
                                (set! bat.4.8 0)
                                0))
                        (set! bar.8.3 (+ 2146083242 1877941467))
                        (if (>= 1 0) foobar.0.4 bar.8.3)))
                (begin
                  (set! foobar.0.13
                        (begin
                          (set! ball.6.16 9223372036854775807)
                          (set! ball.3.15 1)
                          (set! bat.4.14 bar.8.2)
                          ball.3.15))
                  (set! bar.2.12
                        (begin
                          (set! foobar.1.19 foobar.1.1)
                          (set! bar.8.18 -80057626)
                          (set! bar.5.17 451403960)
                          0))
                  (set! ball.6.11 -9223372036854775808)
                  (if (= 0 foobar.1.1) 1 -9223372036854775808)))))
          (define L.func.1.2
            (lambda (ball.3.26 foobar.1.25 foobar.7.24 ball.6.23 foobar.0.22 bar.2.21 bat.4.20)
              (if (>= -68053908 1924767324)
                  (call L.func.2.3 0 2020389049 2037093174 foobar.7.24)
                  (call L.fn.0.1))))
    (define L.func.2.3
      (lambda (foobar.0.30 bat.4.29 ball.3.28 bar.8.27)
        (begin
          (set! bar.5.33
                (begin
                  (set! bar.2.36
                        (begin
                          (set! bat.4.38 1683456577)
                          (set! ball.3.37 0)
                          572391381))
                  (set! bar.8.35 (if (>= 9223372036854775807 foobar.0.30) -2023903597 -15104029))
                  (set! foobar.7.34 1)
                  ball.3.28))
          (set! ball.3.32 0)
          (set! bar.8.31 (+ bat.4.29 bat.4.29))
          (+ 1 bat.4.29))))
    (if (not (> 512244517 -294049298))
        (begin
          (set! bar.5.41 1283186732)
          (set! bar.2.40 99039009)
          (set! bat.4.39 1811100583)
          bar.5.41)
        (begin
          (set! bat.4.44 1)
          (set! foobar.7.43 -9223372036854775808)
          (set! ball.6.42 1)
          ball.6.42))))
(check-by-interp '(module (define L.proc.0.1
                            (lambda (foobar.8.5 bat.1.4 bar.7.3 foobar.4.2 foobar.0.1)
                              (call L.proc.2.3
                                    foobar.0.1
                                    bat.1.4
                                    1
                                    -9223372036854775808
                                    foobar.8.5
                                    9223372036854775807)))
                          (define L.x.1.2
                            (lambda (foobar.4.7 bar.2.6)
                              (if (true)
                                  (begin
                                    (set! foobar.0.10
                                          (if (< foobar.4.7 foobar.4.7) foobar.4.7 foobar.4.7))
                                    (set! foo.5.9 (* foobar.4.7 -1298566605))
                                    (set! bar.2.8 0)
                                    (* foobar.0.10 foobar.0.10))
                                  (begin
                                    (set! foobar.4.12 (+ -1679672366 bar.2.6))
                                    (set! foobar.8.11 (+ 0 foobar.4.7))
                                    (begin
                                      (set! foobar.8.15 0)
                                      (set! foobar.3.14 -511883263)
                                      (set! bat.1.13 bar.2.6)
                                      foobar.3.14)))))
                    (define L.proc.2.3
                      (lambda (foo.5.21 bat.1.20 foobar.4.19 foobar.3.18 bar.7.17 foo.9.16)
                        (+ bar.7.17 -9223372036854775808)))
                    (if (> 1 -735340476) -9223372036854775808 -1627211406)))
(check-by-interp '(module (define L.x.0.1
                            (lambda (foobar.3.1)
                              (if (not (false))
                                  (begin
                                    (set! bat.7.4
                                          (begin
                                            (set! bat.7.7 -508084756)
                                            (set! foobar.3.6 foobar.3.1)
                                            (set! bar.5.5 1)
                                            bat.7.7))
                                    (set! bat.4.3
                                          (begin
                                            (set! bat.7.10 foobar.3.1)
                                            (set! bar.5.9 1120136428)
                                            (set! foobar.1.8 606194936)
                                            -908142049))
                                    (set! ball.0.2 (+ 600266106 foobar.3.1))
                                    (begin
                                      (set! foobar.3.12 foobar.3.1)
                                      (set! ball.0.11 0)
                                      1))
                                  (call L.x.0.1 -2072909432))))
                          (begin
                            (set! foobar.3.15
                                  (begin
                                    (set! bat.7.18 -1755065230)
                                    (set! bar.5.17 9223372036854775807)
                                    (set! ball.0.16 0)
                                    bar.5.17))
                            (set! bar.8.14 -9223372036854775808)
                            (set! bar.5.13 -9223372036854775808)
                            (if (< 1 bar.8.14) bar.8.14 -9223372036854775808))
                    ))
(check-by-interp '(module (begin
                            (set! bar.4.3 (* 993422572 1))
                            (set! bar.6.2 (if (<= 92310708 1290581674) 1 0))
                            (set! bar.1.1 (+ 9223372036854775807 -1759699484))
                            (begin
                              (set! bar.4.5 bar.4.3)
                              (set! foobar.5.4 -9223372036854775808)
                              bar.4.5))))
(check-by-interp '(module (define L.func.0.1
                            (lambda (bar.6.1)
                              (begin
                                (set! bat.2.4
                                      (begin
                                        (set! foo.0.6 (+ -9223372036854775808 -9223372036854775808))
                                        (set! bar.6.5 (+ bar.6.1 1312056768))
                                        (if (<= 1 bar.6.5) -9223372036854775808 -50606571)))
                                (set! foo.7.3 bar.6.1)
                                (set! foobar.4.2 bar.6.1)
                                (if (if (>= foo.7.3 bar.6.1)
                                        (< 0 foo.7.3)
                                        (!= 1880363761 9223372036854775807))
                                    (begin
                                      (set! bat.3.8 1)
                                      (set! bar.6.7 foobar.4.2)
                                      foo.7.3)
                                    (+ bat.2.4 bar.6.1)))))
                          (define L.x.1.2
                            (lambda ()
                              (if (true)
                                  -9223372036854775808
                                  (+ 0 9223372036854775807))))
                    (call L.x.1.2)))
(check-by-interp '(module (define L.x.0.1
                            (lambda (ball.8.3 ball.6.2 foobar.1.1)
                              (call L.x.0.1 foobar.1.1 ball.8.3 0)))
                          (if (> 9223372036854775807 1757631774)
                              (begin
                                (set! foo.4.5 0)
                                (set! foobar.2.4 213435043)
                                -9223372036854775808)
                              0)
                    ))
(check-by-interp '(module (if (not (< 1946235623 -9223372036854775808))
                              (begin
                                (set! bat.0.3 -135046761)
                                (set! bat.2.2 1453915451)
                                (set! ball.5.1 257292075)
                                bat.2.2)
                              -9223372036854775808)))
(check-by-interp '(module (define L.proc.0.1 (lambda (foobar.9.3 foobar.3.2 bar.8.1) foobar.3.2))
                          (* 1 9223372036854775807)
                    ))
(check-by-interp
 '(module (define L.proc.0.1
            (lambda (foobar.3.6 bar.5.5 bat.1.4 foobar.2.3 foobar.7.2 ball.0.1)
              (if (true)
                  (call L.func.1.2
                        1843221563
                        foobar.3.6
                        0
                        1407333795
                        foobar.3.6
                        foobar.2.3
                        1165846535)
                  (+ -1543779281 1))))
          (define L.func.1.2
            (lambda (bar.5.13 bat.6.12 bar.9.11 bar.4.10 foobar.7.9 ball.0.8 foobar.2.7)
              (begin
                (set! foobar.3.16 (* -9223372036854775808 ball.0.8))
                (set! foobar.2.15 ball.0.8)
                (set! bat.6.14 bar.4.10)
                (call L.func.1.2
                      -9223372036854775808
                      0
                      ball.0.8
                      foobar.2.15
                      ball.0.8
                      -811936434
                      foobar.2.15))))
    (if (true)
        -1263415267
        (if (<= 9223372036854775807 -514434406) 9223372036854775807 9223372036854775807))))
(check-by-interp '(module (define L.proc.0.1
                            (lambda (bat.6.2 bar.8.1) (call L.tmp.1.2 -9223372036854775808)))
                          (define L.tmp.1.2
                            (lambda (bat.6.3)
                              (if (!= 9223372036854775807 bat.6.3)
                                  (if (true)
                                      (begin
                                        (set! bar.2.6 2026709313)
                                        (set! bat.9.5 bat.6.3)
                                        (set! bat.6.4 bat.6.3)
                                        bat.6.4)
                                      (if (>= 1890937388 bat.6.3) bat.6.3 1616264974))
                                  9223372036854775807)))
                    (begin
                      (set! ball.7.9 (* 0 1192307430))
                      (set! bat.3.8 (if (< -9223372036854775808 1) -9223372036854775808 2088471563))
                      (set! bar.8.7
                            (begin
                              (set! ball.7.11 1)
                              (set! bat.9.10 9223372036854775807)
                              1861500702))
                      (if (!= 9223372036854775807 -9223372036854775808) ball.7.9 0))))
(check-by-interp
 '(module (define L.proc.0.1
            (lambda (foo.9.1)
              (if (false)
                  (call L.fn.2.3 foo.9.1 foo.9.1 -9223372036854775808 foo.9.1 foo.9.1 foo.9.1)
                  (if (false)
                      (begin
                        (set! foobar.8.4 9223372036854775807)
                        (set! foo.2.3 foo.9.1)
                        (set! foobar.1.2 foo.9.1)
                        foo.9.1)
                      (if (> 1 foo.9.1) 822960898 foo.9.1)))))
          (define L.fn.1.2
            (lambda (foobar.1.7 foo.6.6 foobar.3.5)
              (if (false)
                  (begin
                    (set! foobar.1.10 foobar.1.7)
                    (set! foobar.5.9 (+ -2065189484 foobar.3.5))
                    (set! foobar.7.8 (if (< foobar.1.7 -300039187) 2115350249 foobar.1.7))
                    (begin
                      (set! foobar.1.13 -195312042)
                      (set! foobar.5.12 foo.6.6)
                      (set! foo.6.11 foobar.3.5)
                      foobar.7.8))
                  (begin
                    (set! foo.6.15
                          (begin
                            (set! foobar.3.17 -1983872386)
                            (set! foobar.7.16 foobar.1.7)
                            foobar.7.16))
                    (set! foobar.3.14
                          (begin
                            (set! foo.6.20 9223372036854775807)
                            (set! foo.0.19 -9223372036854775808)
                            (set! foo.9.18 1)
                            0))
                    (if (>= foo.6.15 foo.6.15) -9223372036854775808 foobar.3.14)))))
    (define L.fn.2.3
      (lambda (foo.6.26 foo.4.25 foobar.1.24 foo.9.23 foobar.5.22 foo.0.21)
        (call L.fn.2.3 foo.6.26 foo.4.25 foo.4.25 968969801 foobar.1.24 foo.4.25)))
    9223372036854775807))
(check-by-interp '(module (if (not (>= 1622421353 94202816))
                              (begin
                                (set! foobar.7.2 -2027378735)
                                (set! bar.5.1 9223372036854775807)
                                9223372036854775807)
                              (begin
                                (set! foobar.4.4 -9223372036854775808)
                                (set! bat.8.3 1)
                                9223372036854775807))))
(check-by-interp '(module (begin
                            (set! bar.4.2 (* -1915251883 1))
                            (set! foo.7.1
                                  (begin
                                    (set! ball.9.5 -9223372036854775808)
                                    (set! bar.0.4 356482613)
                                    (set! foo.7.3 9223372036854775807)
                                    foo.7.3))
                            (begin
                              (set! ball.5.8 foo.7.1)
                              (set! ball.9.7 bar.4.2)
                              (set! bat.3.6 -1601764542)
                              -9223372036854775808))))
(check-by-interp '(module (define L.func.0.1
                            (lambda (ball.7.6 bar.4.5 foo.9.4 foo.2.3 foo.1.2 ball.8.1)
                              (if (if (> bar.4.5 ball.7.6)
                                      (if (= -1032056006 foo.1.2)
                                          (>= foo.2.3 ball.8.1)
                                          (< foo.9.4 1))
                                      (>= 1 foo.9.4))
                                  (call L.func.0.1 0 -675302553 bar.4.5 1807204646 ball.8.1 foo.9.4)
                                  (call L.func.0.1
                                        ball.8.1
                                        -41674885
                                        ball.8.1
                                        foo.1.2
                                        -9223372036854775808
                                        9223372036854775807))))
                          (if (!= -9223372036854775808 -719419034)
                              (begin
                                (set! foo.1.9 9223372036854775807)
                                (set! bar.4.8 0)
                                (set! foobar.5.7 9223372036854775807)
                                foobar.5.7)
                              (if (> -235413122 1) 0 9223372036854775807))
                    ))
(check-by-interp '(module (define L.fn.0.1 (lambda (ball.9.1) (call L.x.1.2 ball.9.1 ball.9.1)))
                          (define L.x.1.2
                            (lambda (ball.6.3 ball.9.2)
                              (if (not (false))
                                  (begin
                                    (set! foobar.4.6 ball.9.2)
                                    (set! foo.1.5
                                          (begin
                                            (set! foo.1.8 9223372036854775807)
                                            (set! bar.5.7 ball.6.3)
                                            9223372036854775807))
                                    (set! ball.9.4 -2115998024)
                                    -1101891150)
                                  (begin
                                    (set! bat.7.11 (* -1594085017 ball.9.2))
                                    (set! ball.9.10
                                          (begin
                                            (set! bat.7.13 -999943825)
                                            (set! foobar.0.12 ball.6.3)
                                            593362223))
                                    (set! foobar.0.9 0)
                                    (if (= bat.7.11 1) foobar.0.9 0)))))
                    (if (if (= 1 -1319463227)
                            (>= -9223372036854775808 1)
                            (!= -1520052689 1))
                        (begin
                          (set! foo.8.16 -9223372036854775808)
                          (set! foobar.0.15 9223372036854775807)
                          (set! ball.2.14 744570222)
                          foo.8.16)
                        (begin
                          (set! bar.5.19 -133225634)
                          (set! foo.8.18 -9223372036854775808)
                          (set! ball.6.17 -9223372036854775808)
                          bar.5.19))))
(check-by-interp '(module (begin
                            (set! bat.2.3 9223372036854775807)
                            (set! foobar.3.2
                                  (begin
                                    (set! ball.6.6 1)
                                    (set! bar.4.5 -9223372036854775808)
                                    (set! ball.1.4 9223372036854775807)
                                    1))
                            (set! bar.4.1
                                  (begin
                                    (set! foobar.7.8 -1722042928)
                                    (set! foobar.9.7 0)
                                    1))
                            (if (!= -1508403451 bat.2.3) 447579047 bat.2.3))))
(check-by-interp '(module (define L.tmp.0.1
                            (lambda (foo.4.4 ball.9.3 foobar.6.2 foo.8.1)
                              (call L.tmp.0.1 9223372036854775807 foobar.6.2 foobar.6.2 foo.4.4)))
                          (+ 9223372036854775807 -1932027129)
                    ))
(check-by-interp '(module (define L.func.0.1
                            (lambda (bat.4.2 ball.7.1)
                              (call L.fn.1.2 bat.4.2 ball.7.1 -436836322 bat.4.2)))
                          (define L.fn.1.2
                            (lambda (ball.7.6 bar.8.5 bat.1.4 ball.2.3)
                              (if (true)
                                  (if (if (> 182929845 bar.8.5)
                                          (>= bat.1.4 1)
                                          (< -767224240 9223372036854775807))
                                      (+ bat.1.4 -9223372036854775808)
                                      bat.1.4)
                                  (begin
                                    (set! bar.5.8 (+ -9223372036854775808 -9223372036854775808))
                                    (set! ball.0.7
                                          (begin
                                            (set! bat.1.11 -1747554427)
                                            (set! ball.2.10 ball.7.6)
                                            (set! ball.0.9 9223372036854775807)
                                            bat.1.11))
                                    ball.0.7))))
                    (define L.x.2.3
                      (lambda ()
                        (if (< 0 9223372036854775807)
                            1083014636
                            (begin
                              (set! bat.4.14 (if (<= 1 9223372036854775807) 9223372036854775807 1))
                              (set! bar.5.13 (* 0 0))
                              (set! bat.1.12 (* 1942355770 9223372036854775807))
                              (if (>= bat.4.14 9223372036854775807) -9223372036854775808 1)))))
                    (call L.func.0.1 -1129269775 9223372036854775807)))
(check-by-interp
 '(module (define L.proc.0.1
            (lambda ()
              (if (begin
                    (set! bat.2.2 (* 1 0))
                    (set! ball.8.1 -9223372036854775808)
                    (if (> ball.8.1 bat.2.2)
                        (>= 9223372036854775807 ball.8.1)
                        (= bat.2.2 0)))
                  -9223372036854775808
                  (call L.proc.2.3 0 1 0))))
          (define L.fn.1.2
            (lambda (bat.2.9 foo.4.8 foobar.0.7 foobar.1.6 bat.3.5 ball.9.4 bar.6.3)
              (if (if (true)
                      (if (!= -1156972119 bat.3.5)
                          (> 9223372036854775807 bat.2.9)
                          (!= 1703616983 foo.4.8))
                      (if (>= ball.9.4 bar.6.3)
                          (> bat.3.5 bat.3.5)
                          (< bat.2.9 bat.2.9)))
                  (begin
                    (set! foo.4.11
                          (begin
                            (set! bat.2.14 bar.6.3)
                            (set! ball.9.13 -144518674)
                            (set! bar.6.12 foobar.1.6)
                            bat.3.5))
                    (set! bat.3.10 (if (< bat.2.9 9223372036854775807) 0 -9223372036854775808))
                    (if (>= bat.2.9 -2080421634) 9223372036854775807 0))
                  -274219017)))
    (define L.proc.2.3 (lambda (ball.5.17 bat.2.16 ball.9.15) (+ bat.2.16 9223372036854775807)))
    (begin
      (set! foobar.1.19 (+ 1 -1806804688))
      (set! ball.7.18 (+ 1880531761 1))
      (if (<= 0 foobar.1.19) 0 9223372036854775807))))
(check-by-interp '(module (if (!= -107521481 -1873066368)
                              (* 1275956981 1)
                              (begin
                                (set! bat.4.2 1318401057)
                                (set! foobar.7.1 -542033033)
                                -288327503))))
(check-by-interp '(module (define L.fn.0.1
                            (lambda ()
                              (begin
                                (set! bat.3.2
                                      (begin
                                        (set! foobar.4.5 9223372036854775807)
                                        (set! bat.0.4 684249837)
                                        (set! bar.7.3 1)
                                        (if (= 2084897481 bar.7.3) foobar.4.5 bar.7.3)))
                                (set! ball.9.1
                                      (if (begin
                                            (set! ball.1.7 0)
                                            (set! bat.5.6 1774106288)
                                            (> 0 bat.5.6))
                                          (begin
                                            (set! bat.0.9 9223372036854775807)
                                            (set! foo.6.8 811516044)
                                            bat.0.9)
                                          (if (< -1327371506 9223372036854775807)
                                              -9223372036854775808
                                              9223372036854775807)))
                                (call L.fn.0.1))))
                          (begin
                            (set! bat.5.11 (if (= 1517267005 605514120) -1228391641 -1926002282))
                            (set! ball.9.10 (if (> 0 1) 9223372036854775807 0))
                            (* 25767341 0))
                    ))
(check-by-interp '(module (define L.func.0.1
                            (lambda ()
                              (if (false)
                                  (if (not (!= -1086072832 9223372036854775807))
                                      (begin
                                        (set! bar.4.3 793954259)
                                        (set! bat.0.2 0)
                                        (set! bat.6.1 -9223372036854775808)
                                        9223372036854775807)
                                      (+ 620579510 1))
                                  (if (true)
                                      9223372036854775807
                                      (begin
                                        (set! ball.8.5 716210269)
                                        (set! bat.0.4 -524345693)
                                        -9223372036854775808)))))
                          (define L.fn.1.2
                            (lambda (bat.0.7 bat.6.6)
                              (if (if (true)
                                      (if (> 0 9223372036854775807)
                                          (<= 1 -330770905)
                                          (> 0 bat.0.7))
                                      (if (>= bat.0.7 bat.0.7)
                                          (<= -1763336001 1)
                                          (>= 9223372036854775807 -1870920433)))
                                  (if (not (= -9223372036854775808 1676706544))
                                      (if (<= 0 bat.0.7) -9223372036854775808 bat.0.7)
                                      (if (<= -9223372036854775808 1745852904) 592053094 -1824096668))
                                  (begin
                                    (set! ball.5.10
                                          (begin
                                            (set! foo.3.12 bat.0.7)
                                            (set! ball.5.11 bat.6.6)
                                            foo.3.12))
                                    (set! foo.3.9 (+ 1995506902 -677333479))
                                    (set! bar.4.8
                                          (begin
                                            (set! bar.9.15 bat.0.7)
                                            (set! bat.0.14 -1273465885)
                                            (set! bat.6.13 148631858)
                                            bat.0.14))
                                    bat.6.6))))
                    (begin
                      (set! bar.7.18 -1536502942)
                      (set! bat.0.17 -1557455680)
                      (set! bat.6.16
                            (begin
                              (set! bat.6.21 -1112875927)
                              (set! ball.5.20 9223372036854775807)
                              (set! foo.3.19 9223372036854775807)
                              ball.5.20))
                      (if (<= bar.7.18 bat.0.17) 1132619346 0))))
(check-by-interp '(module (if (true)
                              (begin
                                (set! foobar.3.2 -9223372036854775808)
                                (set! foo.8.1 9223372036854775807)
                                foobar.3.2)
                              (begin
                                (set! foo.5.5 -9223372036854775808)
                                (set! foo.8.4 1929590320)
                                (set! foobar.2.3 0)
                                0))))
(check-by-interp
 '(module (begin
            (set! bar.1.3
                  (if (> 9223372036854775807 1398326902) 9223372036854775807 9223372036854775807))
            (set! bat.3.2 0)
            (set! foo.0.1
                  (begin
                    (set! bat.3.5 -9223372036854775808)
                    (set! ball.9.4 -1747244286)
                    ball.9.4))
            (begin
              (set! foo.0.7 -1923830755)
              (set! bat.5.6 bar.1.3)
              bat.5.6))))
(check-by-interp '(module (define L.proc.0.1
                            (lambda ()
                              (begin
                                (set! bat.6.3
                                      (if (true)
                                          0
                                          (* 1 1)))
                                (set! foo.9.2 -9223372036854775808)
                                (set! bar.0.1 (* 672116958 1))
                                (if (< bar.0.1 980303276)
                                    (+ 9223372036854775807 bar.0.1)
                                    (begin
                                      (set! bar.2.5 -667597146)
                                      (set! foo.9.4 1438122241)
                                      1900048603)))))
                          (define L.proc.1.2
                            (lambda ()
                              (if (true)
                                  (if (if (< 0 -9223372036854775808)
                                          (<= 0 -9223372036854775808)
                                          (> 9223372036854775807 -1813633866))
                                      -935154891
                                      (begin
                                        (set! ball.3.7 -1449852093)
                                        (set! bat.6.6 -9223372036854775808)
                                        1))
                                  (+ -1450359427 -701676518))))
                    (if (false)
                        (call L.proc.1.2)
                        (if (!= 1 9223372036854775807) 313960847 0))))
(check-by-interp '(module (if (if (< -500842013 -2010375969)
                                  (< -1785958547 9223372036854775807)
                                  (<= 904902616 1))
                              (if (= -1568723397 0) 1 -9223372036854775808)
                              1)))
(check-by-interp '(module (if (false)
                              0
                              (if (>= 1 0) 281602960 9223372036854775807))))
(check-by-interp '(module (if (true)
                              (+ -1267155910 -9223372036854775808)
                              (if (>= 901304193 1) 0 -154349390))))
(check-by-interp '(module 9223372036854775807))
(check-by-interp '(module (if (true)
                              (+ -9223372036854775808 1965973068)
                              (begin
                                (set! bar.2.2 -644439618)
                                (set! foo.7.1 1)
                                foo.7.1))))

;;
;; !!! Added by Trevor on March 2nd 2026
(check-by-interp '(module (define L.L.func.0.1.4 (lambda () 0))
                          (define L.L.tmp.1.2.5 (lambda (foo.2.1.5) (call L.L.func.0.1.4)))
                    (define L.L.func.2.3.6
                      (lambda ()
                        (begin
                          (set! bar.4.2.6
                                (if (true)
                                    (begin
                                      (set! foo.2.3.7 1)
                                      foo.2.3.7)
                                    (* -9223372036854775808 1806293504)))
                          (begin
                            (set! foobar.6.4.8 (if (> 1 0) 156890122 bar.4.2.6))
                            0))))
                    (call L.L.tmp.1.2.5 -1860620182)))
(check-by-interp
 '(module (define L.L.tmp.0.1.4
            (lambda ()
              (if (>= 9223372036854775807 -1020514810)
                  (call L.L.x.2.3.6)
                  (* 1 0))))
          (define L.L.func.1.2.5
            (lambda ()
              (begin
                (set! bar.1.1.5 -9223372036854775808)
                (if (not (> 9223372036854775807 0)) 1309557052 bar.1.1.5))))
    (define L.L.x.2.3.6
      (lambda ()
        (if (if (true)
                (not (> 0 1))
                (true))
            (if (> 0 0)
                (if (< 9223372036854775807 9223372036854775807) 9223372036854775807 -260353756)
                (begin
                  (set! ball.0.2.6 0)
                  ball.0.2.6))
            (begin
              (set! bar.3.3.7 (if (!= -302047143 0) 9223372036854775807 102036653))
              (if (= 0 bar.3.3.7) bar.3.3.7 -362331747)))))
    (begin
      (set! ball.0.4.8 (* -9223372036854775808 -9223372036854775808))
      (+ ball.0.4.8 0))))
(check-by-interp '(module (define L.L.proc.0.1.4 (lambda (ball.6.1.5) (call L.L.func.1.2.5)))
                          (define L.L.func.1.2.5 (lambda () (* 1 0)))
                    (define L.L.fn.2.3.6
                      (lambda (ball.3.2.6)
                        (if (true)
                            (begin
                              (set! bat.0.3.7 (if (<= -2033705372 965540822) -1853172774 1133506028))
                              (begin
                                (set! foo.4.4.8 1)
                                1236904416))
                            (call L.L.func.1.2.5))))
                    (call L.L.proc.0.1.4 1)))
(check-by-interp '(module (define L.fn.0.1
                            (lambda ()
                              (begin
                                (set! bat.9.1
                                      (if (false)
                                          1
                                          (begin
                                            (set! foo.5.2 1)
                                            1)))
                                (if (if (>= 9223372036854775807 -9223372036854775808)
                                        (= -248968641 9223372036854775807)
                                        (!= bat.9.1 -9223372036854775808))
                                    (begin
                                      (set! ball.4.3 bat.9.1)
                                      1622965009)
                                    (begin
                                      (set! foo.5.4 bat.9.1)
                                      bat.9.1)))))
                          (if (false)
                              (if (>= 995853130 1) 1 -9223372036854775808)
                              (call L.fn.0.1))
                    ))
(check-by-interp '(module (+ -9223372036854775808 -1465538260)))
(check-by-interp '(module (define L.fn.0.1
                            (lambda ()
                              (begin
                                (set! bar.2.1 (+ 1 9223372036854775807))
                                (begin
                                  (set! foo.8.2
                                        (begin
                                          (set! foo.1.3 bar.2.1)
                                          foo.1.3))
                                  bar.2.1))))
                          (define L.func.1.2
                            (lambda ()
                              (begin
                                (set! ball.3.4
                                      (if (begin
                                            (set! foo.8.5 1)
                                            (< 1 foo.8.5))
                                          (begin
                                            (set! foo.1.6 406779451)
                                            1200977699)
                                          (begin
                                            (set! foo.8.7 0)
                                            foo.8.7)))
                                (* ball.3.4 ball.3.4))))
                    (begin
                      (set! bat.5.8 1)
                      (begin
                        (set! ball.9.9 0)
                        bat.5.8))))
(check-by-interp '(module (define L.x.0.1 (lambda (ball.1.2 foo.0.1) (call L.tmp.1.2)))
                          (define L.tmp.1.2
                            (lambda ()
                              (if (if (if (<= -765445006 0)
                                          (!= 0 -7399083)
                                          (<= 9223372036854775807 1))
                                      (false)
                                      (true))
                                  (begin
                                    (set! ball.4.3
                                          (begin
                                            (set! bar.5.4 -9223372036854775808)
                                            bar.5.4))
                                    (if (> ball.4.3 ball.4.3) -9223372036854775808 ball.4.3))
                                  (begin
                                    (set! foobar.9.5
                                          (if (>= 1 0) -9223372036854775808 -9223372036854775808))
                                    (if (= 0 foobar.9.5) 0 9223372036854775807)))))
                    (define L.func.2.3 (lambda (ball.4.7 ball.6.6) (call L.tmp.1.2)))
                    (if (<= 0 1) -1271132888 2101306416)))
(check-by-interp '(module (define L.proc.0.1
                            (lambda (bar.8.1)
                              (begin
                                (set! bat.7.2
                                      (if (false)
                                          (begin
                                            (set! bat.4.3 bar.8.1)
                                            1733388107)
                                          (begin
                                            (set! foobar.2.4 -818241658)
                                            foobar.2.4)))
                                (begin
                                  (set! bat.3.5 (* -1769976594 bat.7.2))
                                  (if (!= bar.8.1 bar.8.1) 1 bar.8.1)))))
                          (if (<= 0 0) 1764584349 -9223372036854775808)
                    ))
(check-by-interp '(module (define L.proc.0.1
                            (lambda (ball.3.1)
                              (if (not (false))
                                  (call L.x.1.2)
                                  (begin
                                    (set! foobar.4.2
                                          (begin
                                            (set! bat.9.3 ball.3.1)
                                            9223372036854775807))
                                    (+ -9223372036854775808 ball.3.1)))))
                          (define L.x.1.2 (lambda () 1))
                    (begin
                      (set! foobar.4.4
                            (begin
                              (set! ball.1.5 453798193)
                              ball.1.5))
                      (if (>= 9223372036854775807 foobar.4.4) 0 -1617493587))))
(check-by-interp '(module (define L.func.0.1
                            (lambda (bat.8.1)
                              (if (begin
                                    (set! bat.2.2 (* 9223372036854775807 bat.8.1))
                                    (true))
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
                              (begin
                                (set! bat.2.5 ball.6.4)
                                (if (if (<= -9223372036854775808 bat.5.3)
                                        (>= -9223372036854775808 ball.6.4)
                                        (>= bat.5.3 2025307007))
                                    (+ bat.2.5 9223372036854775807)
                                    (if (<= bat.5.3 -9223372036854775808) 9223372036854775807 0)))))
                          (begin
                            (set! ball.6.6 0)
                            ball.6.6)
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
                              (begin
                                (set! ball.1.4
                                      (begin
                                        (set! bat.9.5
                                              (begin
                                                (set! bat.2.6 1757280127)
                                                bat.2.6))
                                        (begin
                                          (set! ball.5.7 1)
                                          -1128483887)))
                                (if (begin
                                      (set! foo.7.8 bar.0.3)
                                      (> foo.7.8 foo.7.8))
                                    ball.1.4
                                    (+ ball.1.4 bar.0.3)))))
                    (define L.fn.2.3
                      (lambda ()
                        (if (begin
                              (set! foobar.8.9 (+ -9223372036854775808 -1421853645))
                              (not (>= 0 -1400373009)))
                            (+ -167927521 1)
                            (begin
                              (set! ball.1.10 (* 1041085683 9223372036854775807))
                              (begin
                                (set! foo.4.11 ball.1.10)
                                770292232)))))
                    (call L.x.1.2 1840464414)))
(check-by-interp '(module (define L.proc.0.1
                            (lambda (ball.4.3 foo.7.2 ball.2.1)
                              (call L.proc.0.1 9223372036854775807 ball.2.1 foo.7.2)))
                          (define L.func.1.2
                            (lambda (ball.1.9 bat.0.8 foo.7.7 ball.4.6 foobar.6.5 bar.3.4)
                              (begin
                                (set! bar.3.10
                                      (begin
                                        (set! ball.4.11 foo.7.7)
                                        (begin
                                          (set! foobar.5.12 ball.1.9)
                                          -9223372036854775808)))
                                (call L.proc.0.1 bar.3.10 -780648786 bar.3.10))))
                    (begin
                      (set! bat.0.13 -579691794)
                      953357957)))
(check-by-interp '(module (begin
                            (set! bar.5.1
                                  (begin
                                    (set! ball.2.2 9223372036854775807)
                                    -546026276))
                            (if (!= bar.5.1 1) 9223372036854775807 2063023986))))
(check-by-interp '(module (define L.func.0.1
                            (lambda (foo.8.2 bar.2.1)
                              (if (not (begin
                                         (set! foo.8.3 foo.8.2)
                                         (= foo.8.3 0)))
                                  (begin
                                    (set! foobar.6.4 (+ foo.8.2 0))
                                    (* 0 9223372036854775807))
                                  (begin
                                    (set! bat.7.5 (* 0 bar.2.1))
                                    (if (!= bat.7.5 -9223372036854775808) bar.2.1 0)))))
                          (if (= 9223372036854775807 -315897602) 1 -9223372036854775808)
                    ))
(check-by-interp '(module (define L.fn.0.1
                            (lambda (foobar.3.2 ball.7.1)
                              (begin
                                (set! bar.9.3
                                      (begin
                                        (set! bat.4.4 (* 1 9223372036854775807))
                                        (+ -9223372036854775808 bat.4.4)))
                                (begin
                                  (set! bat.4.5 9223372036854775807)
                                  (if (!= 1 bar.9.3) 9223372036854775807 ball.7.1)))))
                          (define L.x.1.2
                            (lambda (bat.2.6)
                              (begin
                                (set! foobar.3.7
                                      (begin
                                        (set! bat.4.8 (+ -1410706204 bat.2.6))
                                        (begin
                                          (set! bat.2.9 1)
                                          -9223372036854775808)))
                                (* -152436426 0))))
                    (define L.proc.2.3
                      (lambda (foo.5.13 ball.7.12 foo.0.11 ball.8.10)
                        (begin
                          (set! foobar.1.14 foo.5.13)
                          (+ 956544411 1))))
                    (+ 979460199 -1697959716)))
(check-by-interp
 '(module (define L.proc.0.1
            (lambda (foobar.1.6 bar.0.5 foobar.2.4 ball.8.3 bat.3.2 bar.5.1)
              (begin
                (set! bar.9.7
                      (if (begin
                            (set! bar.7.8 -669410514)
                            (< bat.3.2 bat.3.2))
                          (+ bar.5.1 ball.8.3)
                          foobar.2.4))
                (begin
                  (set! ball.6.9
                        (begin
                          (set! foo.4.10 ball.8.3)
                          1))
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
                      (begin
                        (set! ball.4.8 ball.5.4)
                        1887946265))
                  foobar.3.5)))
          (define L.tmp.1.2
            (lambda (bat.7.14 ball.9.13 ball.5.12 foo.6.11 bar.0.10 ball.2.9)
              (if (true)
                  (* foo.6.11 9223372036854775807)
                  (if (begin
                        (set! foobar.3.15 1)
                        (<= bar.0.10 ball.5.12))
                      (begin
                        (set! ball.9.16 -9223372036854775808)
                        ball.9.16)
                      (begin
                        (set! bat.7.17 1)
                        1)))))
    (define L.tmp.2.3
      (lambda (bat.7.23 ball.2.22 foo.6.21 foobar.3.20 bar.8.19 bar.0.18)
        (begin
          (set! foobar.3.24
                (if (begin
                      (set! ball.2.25 258314756)
                      (!= bar.8.19 0))
                    bar.8.19
                    (begin
                      (set! foo.6.26 -1809848824)
                      9223372036854775807)))
          (if (< 1525021420 1)
              (call L.tmp.1.2 foobar.3.24 1 -1256996529 foo.6.21 -768559462 1067478227)
              (if (> 389818959 882297114) bar.8.19 ball.2.22)))))
    (begin
      (set! bar.0.27 1)
      1)))
(check-by-interp
 '(module (define L.tmp.0.1
            (lambda (foo.1.7 ball.6.6 bar.9.5 bat.3.4 ball.8.3 bat.0.2 ball.7.1) (* bat.3.4 bat.0.2)))
          (define L.func.1.2
            (lambda (foo.1.12 bar.2.11 foo.5.10 bat.3.9 bar.9.8)
              (begin
                (set! bat.3.13 1)
                9223372036854775807)))
    (define L.fn.2.3
      (lambda (ball.7.15 ball.8.14)
        (begin
          (set! bat.3.16
                (if (>= ball.7.15 1)
                    (if (= ball.7.15 ball.7.15) ball.8.14 214741259)
                    (+ 1683358713 ball.8.14)))
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
              (begin
                (set! bar.9.8 9223372036854775807)
                (begin
                  (set! foobar.1.9 bar.9.8)
                  (if (>= -577997854 foobar.1.9) -9223372036854775808 bar.9.8)))))
    (define L.fn.2.3
      (lambda ()
        (begin
          (set! ball.7.10 (+ 1 1))
          (if (false)
              ball.7.10
              (begin
                (set! foobar.1.11 ball.7.10)
                1969054361)))))
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
        (begin
          (set! foobar.5.26
                (begin
                  (set! foobar.1.27 bar.9.22)
                  (begin
                    (set! foo.6.28 foo.3.24)
                    foobar.1.27)))
          (if (begin
                (set! ball.8.29 bar.9.22)
                (> foo.3.24 foo.6.25))
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
                (begin
                  (set! ball.0.37 foobar.2.36)
                  (> -1497437069 -9223372036854775808))
                (not (!= -1101838227 -1416967818)))
            (begin
              (set! ball.8.38 (+ foobar.2.36 foobar.2.36))
              (begin
                (set! foobar.1.39 0)
                foobar.1.39))
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
    (if (begin
          (set! foo.6.40
                (if (begin
                      (set! foobar.2.41 -9223372036854775808)
                      (true))
                    (begin
                      (set! foobar.2.42
                            (if (> 9223372036854775807 0) -1444900091 -9223372036854775808))
                      foobar.2.42)
                    (if (true)
                        (begin
                          (set! foobar.5.43 9223372036854775807)
                          foobar.5.43)
                        (if (= -9223372036854775808 1173781558) 0 1))))
          (if (true)
              (begin
                (set! bar.9.44 0)
                (true))
              (< 858519747 foo.6.40)))
        1
        (if (< 1 -1323259230)
            (call L.fn.2.3)
            (call L.fn.2.3)))))
;; !!!

; adapted example outputs for normalize-bind
(check-equal? (normalize-bind `(module (begin
                                         (set! x.1
                                               (begin
                                                 (set! x.2 2)
                                                 x.2))
                                         x.1)))
              `(module (begin
                         (begin
                           (set! x.2 2)
                           (set! x.1 x.2))
                         x.1)))
; a few normalize-bind test for sanity
(check-equal? (normalize-bind `(module (begin
                                         (set! x.1 0)
                                         (+ 1 1))))
              `(module (begin
                         (set! x.1 0)
                         (+ 1 1))))
(check-equal? (normalize-bind `(module (begin
                                         (set! x.1 1)
                                         (+ x.1 0))))
              `(module (begin
                         (set! x.1 1)
                         (+ x.1 0))))
(check-equal? (normalize-bind `(module (begin
                                         (set! x.1
                                               (begin
                                                 (set! x.2
                                                       (begin
                                                         (set! x.3 3)
                                                         x.3))
                                                 x.2))
                                         x.1)))
              `(module (begin
                         (begin
                           (begin
                             (set! x.3 3)
                             (set! x.2 x.3))
                           (set! x.1 x.2))
                         x.1)))
(check-equal? (normalize-bind `(module (begin
                                         (set! x.1 (if (true) 1 3))
                                         x.1)))
              `(module (begin
                         (if (true)
                             (set! x.1 1)
                             (set! x.1 3))
                         x.1)))
(check-equal? (normalize-bind `(module (begin
                                         (set! x.1
                                               (if (begin
                                                     (set! x.2
                                                           (begin
                                                             (set! x.4 1)
                                                             5))
                                                     (true))
                                                   1
                                                   3))
                                         x.1)))
              `(module (begin
                         (if (begin
                               (begin
                                 (set! x.4 1)
                                 (set! x.2 5))
                               (true))
                             (set! x.1 1)
                             (set! x.1 3))
                         x.1)))

(check-equal? (normalize-bind `(module (define L.label.1 (lambda (x.1 x.2) 3))
                                       (begin
                                         (set! y.1 5)
                                         (set! y.2 6)
                                         (call L.label.1 y.1 y.2))
                                 ))
              `(module (define L.label.1 (lambda (x.1 x.2) 3))
                       (begin
                         (set! y.1 5)
                         (set! y.2 6)
                         (call L.label.1 y.1 y.2))
                 ))

(check-equal? (normalize-bind `(module (define L.label.2
                                         (lambda ()
                                           (begin
                                             (set! x.1
                                                   (begin
                                                     (set! x.2 2)
                                                     x.2))
                                             x.1)))
                                       (call L.label.2)
                                 ))
              `(module (define L.label.2
                         (lambda ()
                           (begin
                             (begin
                               (set! x.2 2)
                               (set! x.1 x.2))
                             x.1)))
                       (call L.label.2)
                 ))
