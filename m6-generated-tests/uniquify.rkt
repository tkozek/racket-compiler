#lang racket
(require rackunit
         cpsc411/langs/v6
         cpsc411/compiler-lib
         "../uniquify.rkt")

(define (check-input p)
  (if (values-lang-v6? p)
      p
      (error (~a (pretty-format p) "\n is not a semantically valid " "values-lang-v6" " program"))))

(define (check-output p)
  (if (values-unique-lang-v6? p)
      p
      (error
       (~a (pretty-format p) "\n is not a semantically valid " "values-unique-lang-v6" " program"))))

(define-syntax-rule (check-by-interp p)
  (check-equal? (interp-values-unique-lang-v6 (check-output (uniquify p)))
                (interp-values-lang-v6 (check-input p))))

;; M6 tests; Added by Trevor on March 6th 2026, multiple bindings allowed per let
(check-by-interp
 '(module (define proc.0 (lambda (ball.9 foo.5 ball.2 ball.7 foo.0 bat.8 foobar.1) (call tmp.1)))
          (define tmp.1 (lambda () (call proc.2 0 0)))
    (define proc.2
      (lambda (foo.6 bat.8) (call proc.0 bat.8 foo.6 445965252 foo.6 bat.8 foo.6 1635273112)))
    (if (if (<= 9223372036854775807 -9223372036854775808)
            (< 692968731 0)
            (<= -1490931083 -14809197))
        1275113131
        (if (<= -1702177019 -9223372036854775808) 0 1843455920))))
(check-by-interp
 '(module (define fn.0
            (lambda (bat.5 foo.2 bar.9 foo.8 foobar.4 bat.3 bat.7)
              (call fn.0 bat.3 -9223372036854775808 bat.5 9223372036854775807 foo.8 foo.8 bat.3)))
          (let ([bat.6 9223372036854775807]
                [foobar.4 9223372036854775807]
                [ball.0 9223372036854775807])
            foobar.4)
    ))
(check-by-interp '(module (define func.0
                            (lambda (bar.2 ball.4 foo.9 foobar.5 foo.6)
                              (if (true)
                                  (let ([foo.9 bar.2]
                                        [bat.0 (call func.1 foo.9 foobar.5 -1140169546)])
                                    (+ foo.6 bat.0))
                                  (call func.1 foo.6 foobar.5 9223372036854775807))))
                          (define func.1
                            (lambda (bat.0 foo.6 foo.9)
                              (if (!= 9223372036854775807 -47909185)
                                  (if (false)
                                      (if (< foo.9 foo.9) bat.0 -9223372036854775808)
                                      (call func.1 bat.0 foo.9 foo.9))
                                  (+ -9223372036854775808 foo.6))))
                    (if (> 9223372036854775807 9223372036854775807) -877748660 -9223372036854775808)))
(check-by-interp '(module (+ -1640821439 -406700566)))
(check-by-interp '(module (define fn.0
                            (lambda (foo.2 ball.6)
                              (call x.1 ball.6 foo.2 ball.6 -9223372036854775808 ball.6 foo.2)))
                          (define x.1
                            (lambda (ball.0 foo.4 foobar.1 ball.5 foo.2 bar.7)
                              (call x.1 933807622 bar.7 bar.7 -984231193 1 ball.5)))
                    (let ([bat.9 -477286222]
                          [bar.7 0])
                      643069821)))
(check-by-interp '(module (define func.0
                            (lambda (bar.9)
                              (if (!= bar.9 bar.9)
                                  (call func.0 2058053814)
                                  (let ([bat.2 (- bar.9 bar.9)]
                                        [bat.0 (let ([bar.9 bar.9]
                                                     [bat.0 bar.9]
                                                     [ball.4 bar.9])
                                                 ball.4)])
                                    (call x.2 bar.9)))))
                          (define tmp.1 (lambda (bat.8 bat.3 bat.5) (call x.2 bat.8)))
                    (define x.2
                      (lambda (bar.9)
                        (let ([bar.9 (call tmp.1 bar.9 bar.9 -1942673900)])
                          (if (let ([foo.1 bar.9]
                                    [bat.8 bar.9]
                                    [ball.7 bar.9])
                                (= ball.7 bar.9))
                              (call tmp.1 bar.9 bar.9 -1386061378)
                              (call func.0 bar.9)))))
                    (if (true)
                        (+ 9223372036854775807 -9223372036854775808)
                        (call func.0 -2107846344))))
(check-by-interp '(module (if (<= 1 -9223372036854775808)
                              (if (false) -9223372036854775808 2012039291)
                              9223372036854775807)))
(check-by-interp '(module (define func.0
                            (lambda (foo.2 ball.1 foo.4 foobar.7 foo.5 foo.9) (- foo.2 foo.4)))
                          (define proc.1
                            (lambda ()
                              (let ([foo.6 (+ 9223372036854775807 1)])
                                (let ([foo.6 (call func.0 0 foo.6 foo.6 foo.6 foo.6 foo.6)]
                                      [foobar.7 foo.6]
                                      [foo.2 (if (>= foo.6 foo.6) foo.6 foo.6)])
                                  (let ([foo.4 foo.6]
                                        [foobar.7 foo.6]
                                        [foo.6 -9223372036854775808])
                                    9223372036854775807)))))
                    (define func.2
                      (lambda (bar.0 foobar.7 foo.4 foo.6)
                        (let ([foo.9 foobar.7])
                          (let ([foo.4 (let ([foo.6 foo.6]
                                             [foo.9 foo.6])
                                         foobar.7)])
                            (if (>= foo.9 foo.6) foobar.7 bar.0)))))
                    (call func.2 0 9223372036854775807 -1735352110 9223372036854775807)))
(check-by-interp
 '(module (define x.0
            (lambda (bat.9 foobar.7 ball.1 foo.2 ball.6 bar.0 foobar.8)
              (let ([ball.1 (call fn.1 foo.2 foo.2 foobar.8 0 bar.0 bat.9 bar.0)])
                (if (not (< 0 -9223372036854775808))
                    (+ ball.6 ball.1)
                    (if (<= foo.2 0) foo.2 foobar.7)))))
          (define fn.1
            (lambda (bat.9 bar.0 foobar.4 ball.6 bat.5 foobar.7 foobar.8)
              (call fn.1 ball.6 foobar.7 bar.0 -9223372036854775808 foobar.7 bar.0 0)))
    (if (>= -9223372036854775808 -637253177) -9223372036854775808 0)))
(check-by-interp '(module 9223372036854775807))
(check-by-interp
 '(module (define proc.0
            (lambda (bat.8 foo.7 foo.0 bat.1 bat.5 bat.6)
              (call proc.0 bat.5 bat.5 bat.5 -635532414 bat.8 bat.1)))
          (define tmp.1
            (lambda (bat.6 foo.0 bat.8 ball.9 foo.7)
              (let ([foo.0 (call tmp.1 ball.9 foo.7 bat.6 ball.9 foo.7)]
                    [ball.4
                     (let ([bat.5 (call func.2
                                        foo.0
                                        9223372036854775807
                                        foo.7
                                        -501684781
                                        ball.9
                                        bat.8
                                        foo.7)]
                           [bar.3 foo.0])
                       (call func.2 bat.6 1644735104 foo.7 -9223372036854775808 bat.8 foo.0 bat.6))])
                (let ([ball.9 (- foo.0 foo.0)]
                      [bat.8 (if (= foo.0 ball.4) ball.4 foo.0)])
                  (call func.2 ball.4 foo.7 foo.7 bat.8 bat.6 -9223372036854775808 ball.4)))))
    (define func.2
      (lambda (foo.2 bat.5 bat.8 foo.0 bar.3 bat.1 ball.4)
        (call func.2 bar.3 -9223372036854775808 foo.0 ball.4 ball.4 foo.0 9223372036854775807)))
    (let ([bar.3 -9223372036854775808]
          [foo.7 9223372036854775807]
          [foo.0 9223372036854775807])
      bar.3)))
(check-by-interp '(module (define func.0
                            (lambda (foo.4 ball.5 bar.2 bat.3 bar.1)
                              (if (let ([bar.1 bar.2]
                                        [bat.3 (if (<= bat.3 bar.1) bat.3 bar.1)]
                                        [foo.4 (call func.0 1 bar.2 foo.4 foo.4 bar.1)])
                                    (false))
                                  (call func.0 bar.1 ball.5 1603961181 bar.2 0)
                                  (call fn.1 ball.5 -9223372036854775808 bar.1 ball.5 bar.1 bat.3))))
                          (define fn.1
                            (lambda (bar.1 bat.7 ball.5 bar.0 bat.3 foobar.9)
                              (let ()
                                (if (if (>= bat.3 bar.1)
                                        (> bat.7 -9223372036854775808)
                                        (>= ball.5 bat.3))
                                    (let ([bat.7 bar.0]
                                          [foobar.9 9223372036854775807]
                                          [bat.8 bar.1])
                                      bat.3)
                                    (if (< bat.3 bar.1) bar.0 bat.7)))))
                    (let ([bar.2 405359082]
                          [bat.6 (if (not (>= -915730633 0))
                                     (let ([bat.8 -532660031]) -248685178)
                                     0)]
                          [bat.7 1254220652])
                      (call fn.1 -9223372036854775808 bat.6 bat.6 9223372036854775807 bat.6 bar.2))))
(check-by-interp
 '(module (define proc.0
            (lambda (foobar.9 foobar.7 foo.2 foo.5 foo.1)
              (call proc.0 foo.1 foo.2 -675715652 -1754605622 1)))
          (define func.1 (lambda (foobar.3 foo.1) (call proc.0 foo.1 foobar.3 foobar.3 foo.1 foo.1)))
    (define x.2
      (lambda (bar.0 foobar.9 foo.8 bar.4 bat.6 foo.1 foobar.7)
        (let ([foobar.9 (if (>= bar.4 foobar.7)
                            foobar.9
                            (call x.2 1 foo.8 0 bat.6 bar.4 foo.1 1783645727))]
              [foo.1 (* bar.4 bar.4)])
          (call x.2 foobar.7 bar.4 foobar.7 foobar.7 -922337918 bar.0 bar.4))))
    (let ([bar.0 0]
          [foo.8 1029279872])
      bar.0)))
(check-by-interp '(module (if (if (let ([bat.2 1]
                                        [foobar.0 -1606724555])
                                    (= bat.2 bat.2))
                                  (let ([ball.5 1]
                                        [bat.1 1]
                                        [bar.8 -9223372036854775808])
                                    (<= ball.5 ball.5))
                                  (let () (!= -1879829070 1981475003)))
                              (- -634246165 -684848771)
                              0)))
(check-by-interp '(module (define func.0
                            (lambda (bat.2 foo.3 bar.6) (call proc.1 bat.2 -1803672217 bat.2)))
                          (define proc.1 (lambda (foo.3 ball.0 bat.1) (call proc.1 1 ball.0 bat.1)))
                    (let ([bar.9 0]) bar.9)))
(check-by-interp '(module (let ()
                            (let ([ball.0 (let ([bar.6 (let ([bat.2 1550347185]
                                                             [ball.0 9223372036854775807]
                                                             [foobar.7 -9223372036854775808])
                                                         ball.0)])
                                            bar.6)])
                              (- 9223372036854775807 ball.0)))))
(check-by-interp '(module (define proc.0
                            (lambda (bar.6 bar.3 foo.1)
                              (let ([bar.3 (call proc.0 9223372036854775807 foo.1 foo.1)]
                                    [ball.9 (call proc.0 bar.6 foo.1 bar.6)]
                                    [bar.6 (let ([ball.2 (call proc.0 foo.1 foo.1 bar.6)]
                                                 [ball.9 bar.3]
                                                 [foo.8 (call proc.0 foo.1 foo.1 bar.3)])
                                             (call proc.0 foo.8 foo.8 ball.2))])
                                (if (> bar.6 foo.1)
                                    (if (>= bar.3 bar.3) foo.1 bar.6)
                                    (let ([ball.4 -2087609688]
                                          [foo.8 bar.3])
                                      ball.9)))))
                          (let ([ball.9 1]
                                [foo.1 -9223372036854775808])
                            foo.1)
                    ))
(check-by-interp '(module (define fn.0
                            (lambda (bar.0)
                              (if (true)
                                  (call func.2 bar.0 bar.0 bar.0 2099518136)
                                  (call func.2 bar.0 bar.0 bar.0 bar.0))))
                          (define tmp.1
                            (lambda (foobar.6 foobar.3 foo.5 bar.2 ball.8 bar.0)
                              (let ([bar.0 9223372036854775807]
                                    [foo.5 (+ foo.5 foobar.3)]
                                    [foobar.6 (let ([ball.1 (+ bar.2 foobar.3)]) foobar.3)])
                                (call fn.0 0))))
                    (define func.2
                      (lambda (ball.9 ball.8 bar.0 foobar.6)
                        (call tmp.1 1 foobar.6 foobar.6 ball.9 bar.0 9223372036854775807)))
                    (let ([bat.4 (+ 1 9223372036854775807)]) bat.4)))
(check-by-interp '(module (let ([foobar.1 0]
                                [bat.0 1])
                            bat.0)))
(check-by-interp
 '(module (define func.0
            (lambda () (call x.1 38797657 1 9223372036854775807 9223372036854775807 1 0)))
          (define x.1
            (lambda (bat.7 ball.5 bat.3 bar.2 foobar.1 bat.9)
              (if (true)
                  (if (if (>= foobar.1 foobar.1)
                          (< bat.7 bar.2)
                          (< bat.9 812242710))
                      (- foobar.1 bar.2)
                      (call func.0))
                  (call x.1 bat.3 foobar.1 bar.2 bat.9 bat.9 bar.2))))
    (call x.1 0 -2062025435 -9223372036854775808 -9223372036854775808 0 -9223372036854775808)))
(check-by-interp '(module (define func.0
                            (lambda (foo.4 foo.7 foo.3 foo.9)
                              (call proc.1 foo.4 -9223372036854775808 foo.3)))
                          (define proc.1 (lambda (foo.9 bat.5 foo.7) (- bat.5 foo.7)))
                    (let () 1)))
(check-by-interp '(module (let ([ball.3 -550916464]
                                [foobar.9 9223372036854775807])
                            foobar.9)))
(check-by-interp
 '(module (if (false)
              (if (if (< 9223372036854775807 1646335033)
                      (>= 9223372036854775807 1)
                      (!= 9223372036854775807 1))
                  (if (!= -9223372036854775808 -9223372036854775808) -9223372036854775808 1282320164)
                  (let ([bar.1 -9223372036854775808]) bar.1))
              (- 9223372036854775807 1))))
(check-by-interp '(module (define tmp.0
                            (lambda (bar.1 bat.6 ball.4 bar.0)
                              (let ([ball.7 (call tmp.0 bat.6 bat.6 bar.0 bar.1)]
                                    [ball.4 (let () (- bat.6 bar.0))])
                                (let ([foobar.8 (let ([foobar.2 bat.6]
                                                      [bar.1 1])
                                                  bar.0)]
                                      [bar.0 bar.1]
                                      [foobar.2 (call x.1 bar.0 9223372036854775807 bar.1)])
                                  (call x.1 -9223372036854775808 bat.6 bat.6)))))
                          (define x.1
                            (lambda (bar.3 foobar.8 bat.6)
                              (if (false)
                                  (call x.1 9223372036854775807 bat.6 foobar.8)
                                  (if (false)
                                      (call tmp.0 foobar.8 bar.3 foobar.8 bar.3)
                                      (call x.1 bat.6 580696126 bat.6)))))
                    (if (<= 9223372036854775807 9223372036854775807) -1677147892 874915829)))
(check-by-interp
 '(module (define proc.0
            (lambda (foo.2 foo.1 ball.4 ball.7 foobar.3 ball.0 foo.6)
              (if (not (> foo.6 -727829088))
                  (let ([ball.4 foo.2]
                        [ball.7 (call proc.0 foo.1 foobar.3 ball.4 foo.1 ball.7 foo.2 foo.2)]
                        [foo.2 (call fn.1 ball.4 foo.2 1 foobar.3 -9223372036854775808 foo.6)])
                    (let ([foo.2 foo.1]) ball.0))
                  (let () -774243080))))
          (define fn.1
            (lambda (foo.5 ball.4 foo.1 ball.9 foobar.3 ball.7)
              (if (if (if (< foobar.3 foo.5)
                          (>= foo.5 ball.9)
                          (!= ball.4 ball.4))
                      (if (>= ball.7 ball.9)
                          (< foo.5 foo.5)
                          (>= foo.1 foobar.3))
                      (not (> ball.9 ball.7)))
                  (let ([ball.9 (- -1548357748 foobar.3)])
                    (call fn.1 ball.9 0 foo.1 ball.4 foo.1 ball.9))
                  (call fn.2 ball.9 foobar.3 ball.4 ball.7 ball.7 foo.5))))
    (define fn.2
      (lambda (foobar.8 foo.1 foobar.3 foo.2 foo.6 ball.9)
        (call fn.2 foo.6 -9223372036854775808 foo.2 foo.6 1 0)))
    (if (< -534391580 9223372036854775807) 0 0)))
(check-by-interp '(module (let ()
                            (let ([ball.7 -1762920629]
                                  [ball.8 1]
                                  [foobar.1 9223372036854775807])
                              0))))
(check-by-interp '(module (define proc.0
                            (lambda (foobar.0 ball.2 ball.3 ball.5 bar.4 foobar.8)
                              (call proc.0 ball.2 15882253 foobar.0 ball.5 ball.2 ball.2)))
                          (if (!= 1038395452 1) -9223372036854775808 717010255)
                    ))
(check-by-interp '(module (if (true)
                              (if (not (= 0 1))
                                  (if (>= -9223372036854775808 -1744096882) 0 9223372036854775807)
                                  (if (< -9223372036854775808 0) 1 9223372036854775807))
                              (if (false)
                                  (let ([foo.5 1032709229]
                                        [bat.6 1])
                                    foo.5)
                                  (let ([bat.8 9223372036854775807]) bat.8)))))
(check-by-interp '(module (if (< 0 9223372036854775807)
                              1620518798
                              (if (!= 0 9223372036854775807) 0 -9223372036854775808))))
(check-by-interp '(module (define func.0
                            (lambda (foobar.2 ball.0)
                              (call tmp.1 foobar.2 foobar.2 9223372036854775807)))
                          (define tmp.1
                            (lambda (ball.5 foobar.2 foo.6)
                              (if (false)
                                  (call tmp.2 ball.5 foobar.2 foobar.2 0 ball.5 foo.6)
                                  (call tmp.1 foobar.2 9223372036854775807 ball.5))))
                    (define tmp.2
                      (lambda (foobar.2 foo.6 foobar.7 ball.5 bar.1 bat.9)
                        (call tmp.2 273235985 1666412948 bar.1 foobar.2 bar.1 foo.6)))
                    (if (= -9223372036854775808 9223372036854775807) 9223372036854775807 1)))
(check-by-interp '(module (define fn.0
                            (lambda (ball.2 ball.4 ball.0 foo.1 foo.8)
                              (call fn.0 foo.8 ball.2 ball.4 foo.1 ball.2)))
                          (let () -167685894)
                    ))
(check-by-interp
 '(module (define func.0
            (lambda (bar.0 foobar.8) (call fn.2 foobar.8 bar.0 foobar.8 bar.0 foobar.8 foobar.8)))
          (define fn.1
            (lambda (foo.6 foobar.2 foobar.1 bat.3 foobar.5)
              (let ([bar.0 (let ([foobar.7 (let () foobar.5)]
                                 [foobar.2 (- foobar.1 foobar.2)])
                             (let ([bar.0 foobar.7]
                                   [bar.9 foobar.2]
                                   [foobar.1 foobar.1])
                               bat.3))])
                (call fn.1 bat.3 -9223372036854775808 foobar.5 bat.3 foobar.5))))
    (define fn.2
      (lambda (foobar.1 foobar.5 foobar.2 ball.4 foobar.8 foobar.7) (call func.0 foobar.1 ball.4)))
    (+ 1962527269 9223372036854775807)))
(check-by-interp '(module (define func.0
                            (lambda (bat.0)
                              (if (if (true)
                                      (not (> bat.0 bat.0))
                                      (>= 2020417677 -9223372036854775808))
                                  (if (true)
                                      (if (= bat.0 bat.0) bat.0 bat.0)
                                      (call func.0 bat.0))
                                  (call func.0 9223372036854775807))))
                          (call func.0 733499244)
                    ))
(check-by-interp '(module (define proc.0
                            (lambda (ball.3 foo.8 foobar.4 foobar.1)
                              (call fn.1 835392363 -9223372036854775808 0 1 foo.8)))
                          (define fn.1
                            (lambda (bat.0 foobar.7 bar.2 bat.6 foobar.4) (call x.2 foobar.7)))
                    (define x.2
                      (lambda (foobar.7)
                        (let ([foo.9 (let ([bat.0 (call proc.0 foobar.7 foobar.7 foobar.7 foobar.7)])
                                       (- bat.0 bat.0))])
                          (let ([foo.9 (if (<= foo.9 foobar.7) foo.9 foobar.7)]
                                [foobar.7 (let ([bat.0 foo.9]
                                                [foobar.7 foobar.7]
                                                [foobar.1 foo.9])
                                            bat.0)]
                                [ball.3 foobar.7])
                            (call x.2 ball.3)))))
                    (let ([ball.3 1830309714]
                          [foo.8 -9223372036854775808]
                          [foobar.7 -9223372036854775808])
                      ball.3)))
(check-by-interp '(module (define func.0 (lambda (foobar.0 foo.5 bat.6 bat.3 bar.7) bat.3))
                          (define func.1
                            (lambda ()
                              (let ([bat.2 (- -620373304 -68719063)]
                                    [bat.3 0]
                                    [foobar.4 (call func.1)])
                                bat.3)))
                    (define x.2 (lambda (bar.8) (call func.1)))
                    -575594324))
(check-by-interp '(module (define x.0
                            (lambda (foo.3 foobar.0 bat.2 bar.7 bar.5 bat.6) (call x.1 bar.7 1)))
                          (define x.1
                            (lambda (foobar.4 foobar.0)
                              (if (<= foobar.0 -9223372036854775808)
                                  (call x.0 foobar.4 foobar.4 foobar.0 foobar.0 foobar.0 foobar.4)
                                  foobar.0)))
                    (if (not (= 0 -844906965))
                        (let ([foo.3 996590913]
                              [bat.6 299367411]
                              [foobar.4 -9223372036854775808])
                          foo.3)
                        (if (> 894536270 1910216157) 1 1))))
(check-by-interp
 '(module (define tmp.0
            (lambda (bat.6 bat.2 foobar.8 bar.3 foo.1)
              (if (<= bat.2 9223372036854775807)
                  (if (true)
                      (call tmp.1 bar.3 foobar.8 bat.6 foobar.8 1 -9223372036854775808 bar.3)
                      (call tmp.1 bat.2 foobar.8 bat.2 bar.3 bar.3 foo.1 bat.6))
                  (let ([bar.3 foo.1]
                        [bar.4 (let () bat.6)])
                    (let ([bat.2 foobar.8]) bat.2)))))
          (define tmp.1
            (lambda (bar.3 foo.1 foobar.8 bat.0 bat.2 foobar.7 bat.6)
              (let ([foobar.8 (if (not (> 1242010444 foobar.8))
                                  (call tmp.0 bat.2 foobar.7 bat.0 1 foobar.7)
                                  (call tmp.0 foobar.8 foobar.8 foo.1 bat.0 bat.0))]
                    [bat.0 (* bat.6 foo.1)]
                    [bar.3 (call tmp.0 foo.1 foo.1 0 bat.2 bat.2)])
                (call tmp.1 foobar.7 foo.1 1 bar.3 bat.6 foobar.8 foobar.7))))
    (if (not (< 1973720366 1864083813))
        9223372036854775807
        (call tmp.1
              9223372036854775807
              9223372036854775807
              501537014
              -1022801227
              -264137160
              726597669
              379193781))))
(check-by-interp '(module (let ([ball.8 1521957632]
                                [bat.6 (let () -9223372036854775808)]
                                [foo.5 -9223372036854775808])
                            (if (false)
                                (if (!= bat.6 bat.6) foo.5 bat.6)
                                (if (> ball.8 -755834168) 0 bat.6)))))
(check-by-interp '(module (let ([ball.1 -9223372036854775808])
                            (let ([bar.0 (let ([foobar.8 0]
                                               [bar.7 ball.1]
                                               [ball.9 ball.1])
                                           ball.9)]
                                  [foo.3 ball.1]
                                  [foo.4 (if (> ball.1 ball.1) ball.1 ball.1)])
                              (let ([ball.9 bar.0]) ball.1)))))
(check-by-interp '(module (let ([foo.7 1])
                            (let ([foobar.3 (if (= foo.7 foo.7)
                                                (let ([foo.8 foo.7]
                                                      [foobar.5 foo.7]
                                                      [foo.4 foo.7])
                                                  foo.7)
                                                (let ([foo.4 foo.7]
                                                      [foobar.1 foo.7])
                                                  foo.7))]
                                  [foo.8 foo.7]
                                  [foobar.1 (+ foo.7 foo.7)])
                              (let ()
                                (let ([foobar.3 foobar.3]
                                      [foobar.1 1648274049])
                                  foo.7))))))
(check-by-interp '(module (define func.0 (lambda (bat.7 bat.8) (call func.0 1 bat.8))) 0
                    ))
(check-by-interp
 '(module (if (> -9223372036854775808 526950868) -9223372036854775808 9223372036854775807)))
(check-by-interp '(module (define fn.0
                            (lambda (foobar.6 ball.3 ball.9 bar.7 bat.4)
                              (call func.1 bat.4 ball.3 1064830001 bat.4 bar.7 ball.3)))
                          (define func.1
                            (lambda (ball.1 bat.4 foo.5 ball.9 foo.8 ball.3)
                              (if (if (if (< foo.8 foo.8)
                                          (= ball.1 ball.1)
                                          (!= bat.4 foo.8))
                                      (= ball.3 0)
                                      (if (> 0 ball.3)
                                          (<= 1 ball.9)
                                          (>= 529266316 foo.8)))
                                  (if (let ([bat.4 foo.5]) (<= ball.9 bat.4))
                                      (let ([foo.8 ball.3]) ball.3)
                                      (call func.1 foo.5 ball.1 bat.4 bat.4 foo.5 ball.3))
                                  (let ([ball.1 (let ([ball.3 foo.5]) ball.3)])
                                    (call func.1 ball.1 ball.3 ball.3 foo.5 ball.1 foo.5)))))
                    (call func.1 9223372036854775807 -1337458253 1 1 0 0)))
(check-by-interp '(module (if (if (!= 9223372036854775807 2124101395)
                                  (true)
                                  (not (<= 9223372036854775807 0)))
                              (let ([bat.2 (let ([bat.2 -9223372036854775808]) -9223372036854775808)]
                                    [bar.8 (* 9223372036854775807 -9223372036854775808)])
                                bat.2)
                              (let ([bar.9 (+ 1865158198 1)]) (if (> bar.9 bar.9) bar.9 bar.9)))))
(check-by-interp '(module (if (>= 1069510162 -9223372036854775808) 1 323863587)))
(check-by-interp '(module (* 379335310 0)))
(check-by-interp '(module 0))
(check-by-interp '(module (let ([bat.2 (- -9223372036854775808 0)]
                                [bat.0 -9223372036854775808])
                            (let ([ball.3 1969620648]
                                  [foo.5 bat.2]
                                  [bat.0 bat.0])
                              foo.5))))

;;
(check-by-interp '(module (define proc.0 (lambda (ball.3) (call proc.0 9223372036854775807)))
                          (define x.1
                            (lambda (ball.3 ball.6)
                              (if (if (if (!= ball.6 ball.6)
                                          (>= ball.3 ball.3)
                                          (<= -763864902 9223372036854775807))
                                      (< 1 1)
                                      (false))
                                  (let ([ball.1 (+ ball.3 -9223372036854775808)]) 598366993)
                                  (* 9223372036854775807 ball.3))))
                    (define tmp.2
                      (lambda (ball.6 foo.9)
                        (if (true)
                            (let ([ball.1 (+ 1 -9223372036854775808)]) 1)
                            (* foo.9 foo.9))))
                    (if (let ([ball.4 2083024360]) (<= 1 ball.4))
                        (+ 0 1)
                        (call x.1 -390453851 1))))

(check-by-interp '(module (define fn.0 (lambda (foo.3 bat.7) (call tmp.1 0 bat.7)))
                          (define tmp.1
                            (lambda (ball.2 foo.1) (call func.2 9223372036854775807 foo.1)))
                    (define func.2
                      (lambda (foo.6 bat.7)
                        (let ([foobar.9 foo.6])
                          (let ([foobar.8 (if (< 0 9223372036854775807) 0 -1879014922)])
                            (if (= 1 1) foobar.9 foobar.9)))))
                    (if (<= 9223372036854775807 9223372036854775807) 0 0)))

(check-by-interp '(module (define proc.0
                            (lambda (ball.0 ball.3)
                              (if (if (not (>= 1676206373 ball.0))
                                      (not (>= -9223372036854775808 ball.0))
                                      (false))
                                  (call fn.2)
                                  (+ -679407720 -1670539202))))
                          (define proc.1 (lambda (bat.6 bar.5) (call proc.0 -2030614437 1)))
                    (define fn.2
                      (lambda ()
                        (let ([bat.6 (* -9223372036854775808 -1564619175)])
                          (if (not (<= bat.6 9223372036854775807))
                              (call fn.2)
                              (call proc.1 -9223372036854775808 9223372036854775807)))))
                    (let ([bat.7 760052997]) (+ 9223372036854775807 9223372036854775807))))

(check-by-interp '(module (define x.0
                            (lambda (ball.3 foobar.2)
                              (let ([foobar.4 -9223372036854775808]) (call x.0 -939287079 foobar.2))))
                          1542811121
                    ))

(check-by-interp '(module (define x.0
                            (lambda (ball.4 ball.5)
                              (if (>= -663003513 946817357)
                                  (if (if (> -9223372036854775808 0)
                                          (= 9223372036854775807 ball.4)
                                          (< ball.5 -9223372036854775808))
                                      (if (>= ball.5 9223372036854775807) 0 ball.4)
                                      (let ([ball.4 -467213902]) ball.4))
                                  (if (false)
                                      (if (= ball.4 0) -9223372036854775808 -9223372036854775808)
                                      (if (> ball.5 0) 271081552 9223372036854775807)))))
                          (define tmp.1
                            (lambda (ball.5)
                              (let ([ball.9 ball.5])
                                (let ([bat.6 9223372036854775807]) (call tmp.1 ball.9)))))
                    (define proc.2
                      (lambda ()
                        (let ([foo.1 (if (if (> 1458486403 645932820)
                                             (!= 1 1594860681)
                                             (< -9223372036854775808 -70861590))
                                         (+ 2099071943 -9223372036854775808)
                                         (if (< -9223372036854775808 881673257) 1 -568199062))])
                          1)))
                    (let ([ball.9 -9223372036854775808]) 9223372036854775807)))

(check-by-interp '(module (define proc.0 (lambda (ball.3) (call proc.0 9223372036854775807)))
                          (define x.1
                            (lambda (ball.3 ball.6)
                              (if (if (if (!= ball.6 ball.6)
                                          (>= ball.3 ball.3)
                                          (<= -763864902 9223372036854775807))
                                      (< 1 1)
                                      (false))
                                  (let ([ball.1 (+ ball.3 -9223372036854775808)]) 598366993)
                                  (* 9223372036854775807 ball.3))))
                    (define tmp.2
                      (lambda (ball.6 foo.9)
                        (if (true)
                            (let ([ball.1 (+ 1 -9223372036854775808)]) 1)
                            (* foo.9 foo.9))))
                    (if (let ([ball.4 2083024360]) (<= 1 ball.4))
                        (+ 0 1)
                        (call x.1 -390453851 1))))
(check-by-interp '(module (define func.0 (lambda (foobar.1 foo.6) (call x.1 foo.6 foo.6)))
                          (define x.1 (lambda (foobar.1 bar.9) bar.9))
                    (call x.1 9223372036854775807 0)))
(check-by-interp '(module (define tmp.0
                            (lambda (bat.8 foo.1)
                              (if (if (if (>= bat.8 foo.1)
                                          (< bat.8 0)
                                          (>= bat.8 foo.1))
                                      (not (>= -9223372036854775808 bat.8))
                                      (< 9223372036854775807 9223372036854775807))
                                  (call proc.1 9223372036854775807)
                                  (call tmp.2 bat.8 bat.8))))
                          (define proc.1
                            (lambda (foobar.3)
                              (if (false)
                                  foobar.3
                                  (* foobar.3 foobar.3))))
                    (define tmp.2 (lambda (foo.1 ball.0) (call proc.1 -915763316)))
                    (let ([foo.1 (* -864893154 9223372036854775807)])
                      (if (> 1679313251 -9223372036854775808) foo.1 -9223372036854775808))))

(check-by-interp
 '(module (define fn.0
            (lambda (bat.1 foo.0)
              (let ([bat.5
                     (let ([foobar.8 (if (>= 9223372036854775807 -9223372036854775808) bat.1 foo.0)])
                       (let ([ball.4 -9223372036854775808]) foo.0))])
                (let ([ball.4 (if (<= -1657890681 9223372036854775807) bat.1 bat.1)])
                  (call fn.0 bat.1 bat.1)))))
          (if (<= 1 1) 0 -9223372036854775808)
    ))

(check-by-interp '(module (define x.0
                            (lambda (bat.1)
                              (let ([ball.5 (let ([bat.6 (+ -1473118393 -9223372036854775808)])
                                              (let ([foo.4 9223372036854775807]) 218975616))])
                                (* bat.1 bat.1))))
                          (define tmp.1
                            (lambda ()
                              (let ([bat.1 (if (not (<= 1 1))
                                               (* -753830259 -9223372036854775808)
                                               0)])
                                (if (if (>= bat.1 1170112415)
                                        (!= 172014518 bat.1)
                                        (<= bat.1 540373982))
                                    bat.1
                                    (+ bat.1 bat.1)))))
                    (define proc.2 (lambda (ball.9) (+ -499436274 9223372036854775807)))
                    1))

(check-by-interp '(module (if (> -9223372036854775808 9223372036854775807) 0 -171588084)))

(check-by-interp '(module (if (< -9223372036854775808 1)
                              (let ([ball.0 -1183539798]) ball.0)
                              (let ([foobar.6 -1081284475]) foobar.6))))
(check-by-interp '(module (define func.0
                            (lambda (bar.6)
                              (if (false)
                                  bar.6
                                  (call func.0 bar.6))))
                          (if (< 1694312373 9223372036854775807)
                              (if (= 1766930141 9223372036854775807) 1 9223372036854775807)
                              (if (<= 1 530802046) 0 -9223372036854775808))
                    ))
;;   added March 2nd 2026
(check-by-interp
 '(module (define x.0 (lambda (bat.2 bar.0) (call x.0 1 203659231)))
          (define tmp.1
            (lambda ()
              (let ([foo.3 (let ([bat.2 (if (= -9223372036854775808 1) 9223372036854775807 0)])
                             (if (>= -9223372036854775808 784027956) 9223372036854775807 0))])
                (if (false)
                    (if (= -9223372036854775808 foo.3) foo.3 foo.3)
                    (call x.0 1 foo.3)))))
    (let ([foo.6 (if (<= -1418225656 0) -750331240 1598097510)])
      (let ([foo.3 1]) 9223372036854775807))))

(check-by-interp '(module (define tmp.0
                            (lambda (bat.7 ball.5) (let ([bat.8 -1468616918]) (* bat.8 bat.8))))
                          (define func.1 (lambda (ball.9 bar.1) 0))
                    (if (<= 1 -9223372036854775808) 0 -1806756174)))

(check-by-interp '(module (let ([ball.3 0]) ball.3)))

(check-by-interp '(module (define tmp.0
                            (lambda (foo.5 foobar.8)
                              (let ([ball.3 (+ foo.5 1)])
                                (if (= 1760100976 9223372036854775807)
                                    (if (< foo.5 0) foo.5 -2034842933)
                                    (+ ball.3 1)))))
                          (define fn.1 (lambda (foo.2 bat.7) bat.7))
                    (define func.2 (lambda (foobar.8) (call fn.1 -9223372036854775808 foobar.8)))
                    (let ([foo.2 (* 9223372036854775807 -1278565935)])
                      (if (<= 9223372036854775807 0) 9223372036854775807 1))))

(check-by-interp '(module (define func.0 (lambda () 0)) (define tmp.1 (lambda (foo.2) (call func.0)))
                    (define func.2
                      (lambda ()
                        (let ([bar.4 (if (true)
                                         (let ([foo.2 1]) foo.2)
                                         (* -9223372036854775808 1806293504))])
                          (let ([foobar.6 (if (> 1 0) 156890122 bar.4)]) 0))))
                    (call tmp.1 -1860620182)))

(check-by-interp
 '(module (define tmp.0
            (lambda ()
              (if (>= 9223372036854775807 -1020514810)
                  (call x.2)
                  (* 1 0))))
          (define func.1
            (lambda ()
              (let ([bar.1 -9223372036854775808])
                (if (not (> 9223372036854775807 0)) 1309557052 bar.1))))
    (define x.2
      (lambda ()
        (if (if (true)
                (not (> 0 1))
                (true))
            (if (> 0 0)
                (if (< 9223372036854775807 9223372036854775807) 9223372036854775807 -260353756)
                (let ([ball.0 0]) ball.0))
            (let ([bar.3 (if (!= -302047143 0) 9223372036854775807 102036653)])
              (if (= 0 bar.3) bar.3 -362331747)))))
    (let ([ball.0 (* -9223372036854775808 -9223372036854775808)]) (+ ball.0 0))))

(check-by-interp '(module (define proc.0 (lambda (ball.6) (call func.1)))
                          (define func.1 (lambda () (* 1 0)))
                    (define fn.2
                      (lambda (ball.3)
                        (if (true)
                            (let ([bat.0 (if (<= -2033705372 965540822) -1853172774 1133506028)])
                              (let ([foo.4 1]) 1236904416))
                            (call func.1))))
                    (call proc.0 1)))

(check-by-interp '(module (define fn.0
                            (lambda ()
                              (let ([bat.9 (if (false)
                                               1
                                               (let ([foo.5 1]) 1))])
                                (if (if (>= 9223372036854775807 -9223372036854775808)
                                        (= -248968641 9223372036854775807)
                                        (!= bat.9 -9223372036854775808))
                                    (let ([ball.4 bat.9]) 1622965009)
                                    (let ([foo.5 bat.9]) bat.9)))))
                          (if (false)
                              (if (>= 995853130 1) 1 -9223372036854775808)
                              (call fn.0))
                    ))

(check-by-interp '(module (+ -9223372036854775808 -1465538260)))

(check-by-interp '(module (define fn.0
                            (lambda ()
                              (let ([bar.2 (+ 1 9223372036854775807)])
                                (let ([foo.8 (let ([foo.1 bar.2]) foo.1)]) bar.2))))
                          (define func.1
                            (lambda ()
                              (let ([ball.3 (if (let ([foo.8 1]) (< 1 foo.8))
                                                (let ([foo.1 406779451]) 1200977699)
                                                (let ([foo.8 0]) foo.8))])
                                (* ball.3 ball.3))))
                    (let ([bat.5 1]) (let ([ball.9 0]) bat.5))))

(check-by-interp
 '(module (define x.0 (lambda (ball.1 foo.0) (call tmp.1)))
          (define tmp.1
            (lambda ()
              (if (if (if (<= -765445006 0)
                          (!= 0 -7399083)
                          (<= 9223372036854775807 1))
                      (false)
                      (true))
                  (let ([ball.4 (let ([bar.5 -9223372036854775808]) bar.5)])
                    (if (> ball.4 ball.4) -9223372036854775808 ball.4))
                  (let ([foobar.9 (if (>= 1 0) -9223372036854775808 -9223372036854775808)])
                    (if (= 0 foobar.9) 0 9223372036854775807)))))
    (define func.2 (lambda (ball.4 ball.6) (call tmp.1)))
    (if (<= 0 1) -1271132888 2101306416)))

(check-by-interp '(module (define proc.0
                            (lambda (bar.8)
                              (let ([bat.7 (if (false)
                                               (let ([bat.4 bar.8]) 1733388107)
                                               (let ([foobar.2 -818241658]) foobar.2))])
                                (let ([bat.3 (* -1769976594 bat.7)]) (if (!= bar.8 bar.8) 1 bar.8)))))
                          (if (<= 0 0) 1764584349 -9223372036854775808)
                    ))

(check-by-interp '(module (define proc.0
                            (lambda (ball.3)
                              (if (not (false))
                                  (call x.1)
                                  (let ([foobar.4 (let ([bat.9 ball.3]) 9223372036854775807)])
                                    (+ -9223372036854775808 ball.3)))))
                          (define x.1 (lambda () 1))
                    (let ([foobar.4 (let ([ball.1 453798193]) ball.1)])
                      (if (>= 9223372036854775807 foobar.4) 0 -1617493587))))

(check-by-interp '(module (define func.0
                            (lambda (bat.8)
                              (if (let ([bat.2 (* 9223372036854775807 bat.8)]) (true))
                                  (if (true)
                                      (if (< bat.8 -9223372036854775808) bat.8 bat.8)
                                      (if (= -9223372036854775808 bat.8) bat.8 bat.8))
                                  (call proc.1))))
                          (define proc.1 (lambda () (call func.0 954069433)))
                    (if (false)
                        (* 1337690701 9223372036854775807)
                        (call proc.1))))

(check-by-interp '(module (if (not (> 1 9223372036854775807))
                              (if (>= 1 1197468889) 9223372036854775807 1)
                              1)))

(check-by-interp '(module (define func.0 (lambda (foo.9 foo.2 bar.1 bat.7 foobar.4) -1458025903))
                          (call func.0 -9223372036854775808 1 -808937821 -9223372036854775808 0)
                    ))

(check-by-interp '(module (define tmp.0
                            (lambda (ball.6 bat.5 bar.8 foobar.0)
                              (let ([bat.2 ball.6])
                                (if (if (<= -9223372036854775808 bat.5)
                                        (>= -9223372036854775808 ball.6)
                                        (>= bat.5 2025307007))
                                    (+ bat.2 9223372036854775807)
                                    (if (<= bat.5 -9223372036854775808) 9223372036854775807 0)))))
                          (let ([ball.6 0]) ball.6)
                    ))

(check-by-interp
 '(module (define func.0
            (lambda (ball.6 foobar.3)
              (if (= 0 foobar.3)
                  (+ -9223372036854775808 -9223372036854775808)
                  (if (if (< ball.6 ball.6)
                          (<= foobar.3 foobar.3)
                          (= foobar.3 ball.6))
                      (+ foobar.3 foobar.3)
                      (if (= 1 foobar.3) ball.6 foobar.3)))))
          (define x.1
            (lambda (bar.0)
              (let ([ball.1 (let ([bat.9 (let ([bat.2 1757280127]) bat.2)])
                              (let ([ball.5 1]) -1128483887))])
                (if (let ([foo.7 bar.0]) (> foo.7 foo.7))
                    ball.1
                    (+ ball.1 bar.0)))))
    (define fn.2
      (lambda ()
        (if (let ([foobar.8 (+ -9223372036854775808 -1421853645)]) (not (>= 0 -1400373009)))
            (+ -167927521 1)
            (let ([ball.1 (* 1041085683 9223372036854775807)]) (let ([foo.4 ball.1]) 770292232)))))
    (call x.1 1840464414)))

(check-by-interp
 '(module (define proc.0
            (lambda (ball.4 foo.7 ball.2) (call proc.0 9223372036854775807 ball.2 foo.7)))
          (define func.1
            (lambda (ball.1 bat.0 foo.7 ball.4 foobar.6 bar.3)
              (let ([bar.3 (let ([ball.4 foo.7]) (let ([foobar.5 ball.1]) -9223372036854775808))])
                (call proc.0 bar.3 -780648786 bar.3))))
    (let ([bat.0 -579691794]) 953357957)))

(check-by-interp '(module (+ 609364271 -9223372036854775808)))

(check-by-interp '(module (let ([bar.5 (let ([ball.2 9223372036854775807]) -546026276)])
                            (if (!= bar.5 1) 9223372036854775807 2063023986))))

(check-by-interp '(module (define func.0
                            (lambda (foo.8 bar.2)
                              (if (not (let ([foo.8 foo.8]) (= foo.8 0)))
                                  (let ([foobar.6 (+ foo.8 0)]) (* 0 9223372036854775807))
                                  (let ([bat.7 (* 0 bar.2)])
                                    (if (!= bat.7 -9223372036854775808) bar.2 0)))))
                          (if (= 9223372036854775807 -315897602) 1 -9223372036854775808)
                    ))

(check-by-interp
 '(module (define fn.0
            (lambda (foobar.3 ball.7)
              (let ([bar.9 (let ([bat.4 (* 1 9223372036854775807)]) (+ -9223372036854775808 bat.4))])
                (let ([bat.4 9223372036854775807]) (if (!= 1 bar.9) 9223372036854775807 ball.7)))))
          (define x.1
            (lambda (bat.2)
              (let ([foobar.3 (let ([bat.4 (+ -1410706204 bat.2)])
                                (let ([bat.2 1]) -9223372036854775808))])
                (* -152436426 0))))
    (define proc.2 (lambda (foo.5 ball.7 foo.0 ball.8) (let ([foobar.1 foo.5]) (+ 956544411 1))))
    (+ 979460199 -1697959716)))

(check-by-interp
 '(module (define proc.0
            (lambda (foobar.1 bar.0 foobar.2 ball.8 bat.3 bar.5)
              (let ([bar.9 (if (let ([bar.7 -669410514]) (< bat.3 bat.3))
                               (+ bar.5 ball.8)
                               foobar.2)])
                (let ([ball.6 (let ([foo.4 ball.8]) 1)])
                  (if (<= foobar.2 1) 9223372036854775807 bat.3)))))
          (call proc.0 0 9223372036854775807 0 -1371550930 -1891086346 9223372036854775807)
    ))

(check-by-interp '(module (define x.0
                            (lambda (bat.7 ball.9 foobar.3 ball.5 ball.4 bar.0 ball.2)
                              (if (not (if (>= 388494724 ball.9)
                                           (> ball.5 -9223372036854775808)
                                           (< foobar.3 ball.5)))
                                  (if (<= ball.4 bar.0)
                                      0
                                      (let ([ball.4 ball.5]) 1887946265))
                                  foobar.3)))
                          (define tmp.1
                            (lambda (bat.7 ball.9 ball.5 foo.6 bar.0 ball.2)
                              (if (true)
                                  (* foo.6 9223372036854775807)
                                  (if (let ([foobar.3 1]) (<= bar.0 ball.5))
                                      (let ([ball.9 -9223372036854775808]) ball.9)
                                      (let ([bat.7 1]) 1)))))
                    (define tmp.2
                      (lambda (bat.7 ball.2 foo.6 foobar.3 bar.8 bar.0)
                        (let ([foobar.3 (if (let ([ball.2 258314756]) (!= bar.8 0))
                                            bar.8
                                            (let ([foo.6 -1809848824]) 9223372036854775807))])
                          (if (< 1525021420 1)
                              (call tmp.1 foobar.3 1 -1256996529 foo.6 -768559462 1067478227)
                              (if (> 389818959 882297114) bar.8 ball.2)))))
                    (let ([bar.0 1]) 1)))

(check-by-interp
 '(module (define tmp.0 (lambda (foo.1 ball.6 bar.9 bat.3 ball.8 bat.0 ball.7) (* bat.3 bat.0)))
          (define func.1
            (lambda (foo.1 bar.2 foo.5 bat.3 bar.9) (let ([bat.3 1]) 9223372036854775807)))
    (define fn.2
      (lambda (ball.7 ball.8)
        (let ([bat.3 (if (>= ball.7 1)
                         (if (= ball.7 ball.7) ball.8 214741259)
                         (+ 1683358713 ball.8))])
          (call tmp.0 bat.3 ball.8 0 ball.7 9223372036854775807 ball.7 -2043460455))))
    (call tmp.0
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
 '(module (define func.0
            (lambda (ball.1 foobar.0 ball.7 bat.9)
              (let ([foo.6 (* 0 ball.7)])
                (if (let ([foo.2 0]) (!= 0 1))
                    (call func.0 foobar.0 1 0 ball.1)
                    (call func.0 foobar.0 9223372036854775807 -1987151411 1)))))
          (if (>= -935340714 -9223372036854775808) -9223372036854775808 9223372036854775807)
    ))

(check-by-interp
 '(module (define fn.0
            (lambda (bar.2 bat.3)
              (if (not (let ([foo.7 bar.2]) (<= 0 989218265)))
                  (call fn.0 bat.3 bar.2)
                  (let ([bar.9 (let ([bat.0 -9223372036854775808]) bat.3)]) 2108201156))))
          (define func.1
            (lambda ()
              (if (<= 106243304 0)
                  -9223372036854775808
                  (let ([foobar.5 (let ([foobar.5 9223372036854775807]) 9223372036854775807)])
                    (+ foobar.5 -211580633)))))
    (define x.2
      (lambda (bat.1 bat.3 ball.8 foobar.6 bar.2)
        (if (false)
            (let ([ball.8 foobar.6]) (if (<= 1 9223372036854775807) 1924763751 ball.8))
            bat.1)))
    (let ([bar.9 (+ 1471174001 779392821)]) (if (<= bar.9 1) bar.9 -9223372036854775808))))
;; Extra large tests

(check-by-interp
 '(module (define tmp.0 (lambda (bat.1 bar.2 bat.4 foo.7) bar.2))
          (define tmp.1 (lambda (foo.7 bat.5 bat.4 foobar.0) (* foo.7 -520057153)))
    (define proc.2
      (lambda (bar.2 bat.5 bat.4 bat.1 ball.6)
        (let ([foobar.3 (* -1313115038 -9223372036854775808)]) ball.6)))
    (define fn.3
      (lambda ()
        (let ([bat.1 -9223372036854775808])
          (let ([ball.6 (* 1512642431 bat.1)]) (if (> bat.1 9223372036854775807) ball.6 ball.6)))))
    (define func.4
      (lambda (bat.8 bar.2 bat.5 ball.9 bat.1 foobar.0)
        (let ([bat.4 (* 9223372036854775807 ball.9)]) -1238090268)))
    (define x.5 (lambda (bat.1 bat.8 bat.4 ball.6 ball.9 foo.7) (+ 1 1)))
    (define tmp.6 (lambda (foobar.3) (let ([foobar.3 (+ foobar.3 foobar.3)]) foobar.3)))
    (define x.7
      (lambda (foobar.3 ball.6 bat.1 foo.7 bat.8 bar.2)
        (if (> bar.2 ball.6)
            bat.1
            (* bar.2 bat.8))))
    (call fn.3)))

(check-by-interp
 '(module (define x.0 (lambda (ball.0 foobar.1 foo.3 foobar.2 foo.6 foobar.5 ball.8) (call x.4 1)))
          (define func.1
            (lambda ()
              (let ([bar.9 9223372036854775807])
                (let ([foobar.1 bar.9]) (if (>= -577997854 foobar.1) -9223372036854775808 bar.9)))))
    (define fn.2
      (lambda ()
        (let ([ball.7 (+ 1 1)])
          (if (false)
              ball.7
              (let ([foobar.1 ball.7]) 1969054361)))))
    (define x.3
      (lambda (foobar.4 foobar.5 bar.9 foobar.2 ball.8 foo.3 ball.7)
        (call func.6
              0
              -9223372036854775808
              9223372036854775807
              25911444
              9223372036854775807
              foobar.4
              -9223372036854775808)))
    (define x.4 (lambda (foobar.4) (call x.3 0 foobar.4 foobar.4 1 foobar.4 foobar.4 foobar.4)))
    (define x.5
      (lambda (foo.6 foo.3 foobar.4 bar.9 foobar.1 foobar.5)
        (let ([foobar.5 (let ([foobar.1 bar.9]) (let ([foo.6 foo.3]) foobar.1))])
          (if (let ([ball.8 bar.9]) (> foo.3 foo.6))
              (call x.0 -1863740769 9223372036854775807 foobar.4 foobar.5 foo.3 foobar.5 -1819248150)
              1))))
    (define func.6
      (lambda (foobar.2 foo.6 ball.0 ball.8 foo.3 foobar.1 foobar.5)
        (if (if (true)
                (let ([ball.0 foobar.2]) (> -1497437069 -9223372036854775808))
                (not (!= -1101838227 -1416967818)))
            (let ([ball.8 (+ foobar.2 foobar.2)]) (let ([foobar.1 0]) foobar.1))
            1)))
    (define fn.7
      (lambda ()
        (if (true)
            (if (not (> 0 100011461))
                (call x.5 -9223372036854775808 16140507 0 -1248542300 0 -1579752260)
                (if (= -9223372036854775808 471889533) 1 0))
            (if (if (>= 1 0)
                    (>= 0 -9223372036854775808)
                    (> 9223372036854775807 0))
                (call fn.7)
                (if (> 1 1) -444155079 9223372036854775807)))))
    (if (let ([foo.6
               (if (let ([foobar.2 -9223372036854775808]) (true))
                   (let ([foobar.2 (if (> 9223372036854775807 0) -1444900091 -9223372036854775808)])
                     foobar.2)
                   (if (true)
                       (let ([foobar.5 9223372036854775807]) foobar.5)
                       (if (= -9223372036854775808 1173781558) 0 1)))])
          (if (true)
              (let ([bar.9 0]) (true))
              (< 858519747 foo.6)))
        1
        (if (< 1 -1323259230)
            (call fn.2)
            (call fn.2)))))

(check-by-interp
 '(module (define fn.0
            (lambda (foobar.5 foo.4 bat.9 bar.1 foobar.6)
              (if (>= -9223372036854775808 bar.1)
                  1
                  (if (true)
                      (let ([ball.0 bat.9]) 272878342)
                      (let ([bat.9 foo.4]) 1621698237)))))
          (define x.1
            (lambda ()
              (let ([bar.1 (if (if (< -9223372036854775808 -9223372036854775808)
                                   (!= 1373678353 9223372036854775807)
                                   (= -9223372036854775808 9223372036854775807))
                               9223372036854775807
                               1)])
                (let ([bar.8 bar.1]) (if (<= bar.8 1832962769) -1179877563 bar.8)))))
    (define tmp.2 (lambda (foobar.7 foobar.6 bat.9 foobar.5 ball.2 bar.1) (+ 1614414513 0)))
    (define tmp.3
      (lambda (bar.8 foobar.3 ball.2 foobar.7 foobar.5)
        (let ([ball.2 (if (let ([bar.8 0]) (<= ball.2 foobar.5))
                          foobar.5
                          (* -9223372036854775808 2143760394))])
          (let ([ball.2 (let ([foobar.3 1560147081]) ball.2)])
            (let ([foo.4 0]) -9223372036854775808)))))
    (define func.4
      (lambda (foobar.5 ball.0 bar.8 bat.9 foobar.3 foobar.6)
        (let ([bar.1 (let ([foobar.6 (* 0 0)]) (* ball.0 672300375))]) (+ 599851097 ball.0))))
    (define fn.5
      (lambda (foo.4)
        (if (>= 9223372036854775807 532145951)
            (if (let ([bar.1 9223372036854775807]) (< foo.4 -9223372036854775808))
                (let ([ball.0 0]) ball.0)
                (if (!= foo.4 0) 0 940835989))
            (call tmp.3 foo.4 0 1817052000 -9223372036854775808 872683016))))
    (let ([bat.9 (let ([ball.2 (* -9223372036854775808 -1620764170)])
                   (+ 1515105242 9223372036854775807))])
      (let ([ball.0 bat.9])
        (if (false)
            (if (!= ball.0 -98359895) ball.0 -1192498197)
            (let ([bar.8 bat.9]) ball.0))))))
(check-by-interp
 '(module (define fn.0
            (lambda (ball.4 foobar.1 foobar.6 bar.7 ball.5 foo.8 ball.9)
              (let ([ball.5 (if (= -99505426 ball.4)
                                (let ([ball.4 1]) (+ bar.7 foobar.6))
                                (* 1 foobar.6))])
                (if (if (if (not (let ([bat.3 foo.8]) (<= 0 1)))
                            (let ([foo.8 (* 0 foo.8)])
                              (let ([foobar.0 429372017]) (>= -2010637217 bar.7)))
                            (false))
                        (true)
                        (not (false)))
                    1
                    foobar.6))))
          (define tmp.1 (lambda (foobar.6) (call tmp.1 foobar.6)))
    (define tmp.2
      (lambda (foobar.1 foobar.0 foobar.6)
        (call func.3 foobar.0 foobar.0 foobar.1 foobar.6 foobar.1 foobar.1 0)))
    (define func.3
      (lambda (foobar.1 foobar.0 ball.5 foo.2 foo.8 ball.4 bat.3)
        (if (let ([foobar.0 (let ([foo.8 (if (if (>= 0 foobar.0)
                                                 (true)
                                                 (if (<= 1 1856622568)
                                                     (>= bat.3 bat.3)
                                                     (= ball.5 -9223372036854775808)))
                                             1037087964
                                             (if (let ([bat.3 -1794855172]) (< -355327964 ball.5))
                                                 foo.2
                                                 (let ([foo.8 695562651]) 0)))])
                              (if (false)
                                  (+ ball.4 9223372036854775807)
                                  (if (true)
                                      (+ -9223372036854775808 foobar.0)
                                      foobar.1)))])
              (false))
            (+ bat.3 foobar.1)
            (let ([bat.3 foo.2])
              (if (false)
                  (+ 218056169 ball.5)
                  (let ([bat.3 (* 939433463 9223372036854775807)])
                    (let ([bat.3 (+ ball.5 bat.3)]) -9223372036854775808)))))))
    (define fn.4
      (lambda ()
        (if (not (true))
            (let ([bat.3 (if (not (false))
                             -9223372036854775808
                             (if (true)
                                 -582767426
                                 (if (false)
                                     (* 0 -9223372036854775808)
                                     0)))])
              bat.3)
            (+ -924459426 0))))
    (define tmp.5 (lambda (ball.4 foo.8 bar.7 foobar.0 foobar.6 ball.5 bat.3) 9223372036854775807))
    (if (true)
        (+ 1 95298529)
        0)))

(check-by-interp
 '(module (define x.0
            (lambda ()
              (let ([ball.0 (let ([ball.0 (let ([foobar.6 -1510419750])
                                            (let ([ball.0 (if (false)
                                                              1880825961
                                                              (let ([foo.2 41183491]) foo.2))])
                                              (+ 1 ball.0)))])
                              (let ([ball.9 (if (false)
                                                (if (not (>= 1 1964968205))
                                                    (if (>= ball.0 ball.0) -1473992388 0)
                                                    (* 1 ball.0))
                                                (if (true)
                                                    (let ([foo.2 0]) 9223372036854775807)
                                                    (let ([foo.3 9223372036854775807])
                                                      -9223372036854775808)))])
                                (let ([foo.2 (let ([foobar.6 (if (!= ball.9 ball.9) -1054245420 1)])
                                               (let ([ball.0 ball.9]) ball.0))])
                                  -399220545)))])
                (+ ball.0 ball.0))))
          (define fn.1 (lambda (foo.1) (+ foo.1 1)))
    (define proc.2 (lambda (foo.2 ball.0 ball.7) (call fn.5 ball.0 foo.2 foo.2 0)))
    (define x.3
      (lambda (foo.2 ball.7 ball.9)
        (if (> ball.7 ball.9)
            (let ([foo.3 (let ([foo.3 ball.9]) (let ([foo.8 ball.7]) (* 1 ball.9)))]) (* foo.3 foo.2))
            (if (if (false)
                    (let ([ball.0 -9223372036854775808])
                      (if (if (< foo.2 9223372036854775807)
                              (< ball.7 ball.7)
                              (<= foo.2 884043998))
                          (false)
                          (not (<= ball.7 1))))
                    (true))
                foo.2
                (+ ball.9 foo.2)))))
    (define x.4 (lambda (foo.2 foo.1) (call proc.2 -672138667 foo.1 foo.1)))
    (define fn.5 (lambda (ball.4 foobar.6 ball.0 foo.1) (+ foobar.6 0)))
    (let ([foo.1 -9223372036854775808]) (call x.4 foo.1 foo.1))))

(check-by-interp
 '(module (define x.0
            (lambda (ball.5 foobar.2 foo.3 ball.4 bat.1)
              (call fn.1 -9223372036854775808 9223372036854775807 1 ball.5 ball.4 ball.4)))
          (define fn.1 (lambda (ball.9 bat.1 foo.7 foo.3 ball.5 foo.0) foo.0))
    (define tmp.2
      (lambda (ball.4 foo.3 bar.6)
        (let ([foobar.2 (* ball.4 9223372036854775807)]) (+ foo.3 767883438))))
    (define func.3
      (lambda (ball.9 bar.8 foo.3 bat.1) (call tmp.2 164105141 foo.3 -9223372036854775808)))
    (define fn.4 (lambda (foo.7 ball.9 foo.3 bar.6) (+ 518721108 0)))
    (define tmp.5
      (lambda (ball.9 foo.3 ball.5 bar.8 ball.4 foo.0)
        (let ([foo.3 (let ([ball.4
                            (if (let ([ball.9 (if (not (<= ball.9 71239012))
                                                  1
                                                  (if (<= 0 9223372036854775807) foo.3 -1037460705))])
                                  (false))
                                (if (not (if (<= ball.5 885580486)
                                             (< bar.8 ball.9)
                                             (> 0 ball.4)))
                                    (if (if (!= 0 ball.5)
                                            (< ball.9 ball.5)
                                            (!= bar.8 foo.3))
                                        bar.8
                                        bar.8)
                                    (+ 1 0))
                                0)])
                       (let ([bar.8 (let ([ball.9 (if (<= 1 ball.4)
                                                      (if (= bar.8 foo.0) ball.4 0)
                                                      (if (<= foo.0 foo.3) ball.9 1))])
                                      9223372036854775807)])
                         (+ 1 9223372036854775807)))])
          (let ([foo.3 1917454727])
            (if (not (< 1229284432 9223372036854775807))
                foo.3
                (+ 1274698633 foo.0))))))
    (define fn.6
      (lambda (foobar.2 bar.6 foo.7) (let ([foobar.2 (* -9223372036854775808 bar.6)]) 690826547)))
    (let ([bar.6 (if (if (true)
                         (not (true))
                         (true))
                     (* 1791882774 0)
                     0)])
      (if (false)
          (if (true)
              (let ([ball.4 (* bar.6 1)])
                (let ([bat.1 (let ([foo.3 (* bar.6 -9223372036854775808)])
                               (+ bar.6 -9223372036854775808))])
                  (call x.0 0 1 -9223372036854775808 1 44798641)))
              (if (let ([bar.8 (if (= bar.6 bar.6)
                                   (+ 1 bar.6)
                                   0)])
                    (if (let ([foo.0 -335382762]) (>= foo.0 198878680))
                        (< 9223372036854775807 bar.8)
                        (false)))
                  (let ([foobar.2 (if (let ([ball.5 1]) (= 0 9223372036854775807))
                                      (if (= 1 355925562) 1 9223372036854775807)
                                      (let ([bar.8 0]) 1))])
                    (call x.0 foobar.2 bar.6 foobar.2 9223372036854775807 bar.6))
                  (if (false)
                      (if (not (= bar.6 1505519823))
                          (call fn.6 bar.6 bar.6 -1389936468)
                          0)
                      (call fn.6 -1026710181 bar.6 0))))
          (let ([ball.9 (if (false)
                            (if (let ([bar.6 (let ([foobar.2 1572624047]) foobar.2)])
                                  (not (<= -728694911 -403064853)))
                                (if (if (>= bar.6 bar.6)
                                        (>= bar.6 bar.6)
                                        (>= bar.6 1))
                                    (* bar.6 -1072326562)
                                    (+ bar.6 -9223372036854775808))
                                bar.6)
                            (if (true)
                                (let ([bar.8 (if (>= 9223372036854775807 bar.6) bar.6 bar.6)])
                                  (let ([foo.7 bar.8]) -9223372036854775808))
                                (if (if (< -9223372036854775808 bar.6)
                                        (<= bar.6 bar.6)
                                        (< 107040658 bar.6))
                                    (* bar.6 1)
                                    0)))])
            (let ([foo.0 (let ([foo.3 (if (!= 0 1)
                                          (let ([ball.5 ball.9]) -9223372036854775808)
                                          (let ([foo.7 bar.6]) bar.6))])
                           foo.3)])
              (call fn.6 -704490852 ball.9 9223372036854775807)))))))

(check-by-interp
 '(module (define L.tmp.0.1
            (lambda ()
              (if (>= 9223372036854775807 -1020514810)
                  (call L.x.2.3)
                  (* 1 0))))
          (define L.func.1.2
            (lambda ()
              (let ([bar.1.1 -9223372036854775808])
                (if (not (> 9223372036854775807 0)) 1309557052 bar.1.1))))
    (define L.x.2.3
      (lambda ()
        (if (if (true)
                (not (> 0 1))
                (true))
            (if (> 0 0)
                (if (< 9223372036854775807 9223372036854775807) 9223372036854775807 -260353756)
                (let ([ball.0.2 0]) ball.0.2))
            (let ([bar.3.3 (if (!= -302047143 0) 9223372036854775807 102036653)])
              (if (= 0 bar.3.3) bar.3.3 -362331747)))))
    (let ([ball.0.4 (* -9223372036854775808 -9223372036854775808)]) (+ ball.0.4 0))))

(check-by-interp '(module (define L.proc.0.1 (lambda (ball.6.1) (call L.func.1.2)))
                          (define L.func.1.2 (lambda () (* 1 0)))
                    (define L.fn.2.3
                      (lambda (ball.3.2)
                        (if (true)
                            (let ([bat.0.3 (if (<= -2033705372 965540822) -1853172774 1133506028)])
                              (let ([foo.4.4 1]) 1236904416))
                            (call L.func.1.2))))
                    (call L.proc.0.1 1)))
(check-by-interp '(module (define fn.0
                            (lambda ()
                              (let ([bat.9 (if (false)
                                               1
                                               (let ([foo.5 1]) 1))])
                                (if (if (>= 9223372036854775807 -9223372036854775808)
                                        (= -248968641 9223372036854775807)
                                        (!= bat.9 -9223372036854775808))
                                    (let ([ball.4 bat.9]) 1622965009)
                                    (let ([foo.5 bat.9]) bat.9)))))
                          (if (false)
                              (if (>= 995853130 1) 1 -9223372036854775808)
                              (call fn.0))
                    ))
(check-by-interp '(module (+ -9223372036854775808 -1465538260)))
(check-by-interp '(module (define fn.0
                            (lambda ()
                              (let ([bar.2 (+ 1 9223372036854775807)])
                                (let ([foo.8 (let ([foo.1 bar.2]) foo.1)]) bar.2))))
                          (define func.1
                            (lambda ()
                              (let ([ball.3 (if (let ([foo.8 1]) (< 1 foo.8))
                                                (let ([foo.1 406779451]) 1200977699)
                                                (let ([foo.8 0]) foo.8))])
                                (* ball.3 ball.3))))
                    (let ([bat.5 1]) (let ([ball.9 0]) bat.5))))
(check-by-interp
 '(module (define x.0 (lambda (ball.1 foo.0) (call tmp.1)))
          (define tmp.1
            (lambda ()
              (if (if (if (<= -765445006 0)
                          (!= 0 -7399083)
                          (<= 9223372036854775807 1))
                      (false)
                      (true))
                  (let ([ball.4 (let ([bar.5 -9223372036854775808]) bar.5)])
                    (if (> ball.4 ball.4) -9223372036854775808 ball.4))
                  (let ([foobar.9 (if (>= 1 0) -9223372036854775808 -9223372036854775808)])
                    (if (= 0 foobar.9) 0 9223372036854775807)))))
    (define func.2 (lambda (ball.4 ball.6) (call tmp.1)))
    (if (<= 0 1) -1271132888 2101306416)))
(check-by-interp '(module (define proc.0
                            (lambda (bar.8)
                              (let ([bat.7 (if (false)
                                               (let ([bat.4 bar.8]) 1733388107)
                                               (let ([foobar.2 -818241658]) foobar.2))])
                                (let ([bat.3 (* -1769976594 bat.7)]) (if (!= bar.8 bar.8) 1 bar.8)))))
                          (if (<= 0 0) 1764584349 -9223372036854775808)
                    ))
(check-by-interp '(module (define proc.0
                            (lambda (ball.3)
                              (if (not (false))
                                  (call x.1)
                                  (let ([foobar.4 (let ([bat.9 ball.3]) 9223372036854775807)])
                                    (+ -9223372036854775808 ball.3)))))
                          (define x.1 (lambda () 1))
                    (let ([foobar.4 (let ([ball.1 453798193]) ball.1)])
                      (if (>= 9223372036854775807 foobar.4) 0 -1617493587))))
(check-by-interp '(module (define func.0
                            (lambda (bat.8)
                              (if (let ([bat.2 (* 9223372036854775807 bat.8)]) (true))
                                  (if (true)
                                      (if (< bat.8 -9223372036854775808) bat.8 bat.8)
                                      (if (= -9223372036854775808 bat.8) bat.8 bat.8))
                                  (call proc.1))))
                          (define proc.1 (lambda () (call func.0 954069433)))
                    (if (false)
                        (* 1337690701 9223372036854775807)
                        (call proc.1))))
(check-by-interp '(module (if (not (> 1 9223372036854775807))
                              (if (>= 1 1197468889) 9223372036854775807 1)
                              1)))
(check-by-interp '(module (define func.0 (lambda (foo.9 foo.2 bar.1 bat.7 foobar.4) -1458025903))
                          (call func.0 -9223372036854775808 1 -808937821 -9223372036854775808 0)
                    ))
(check-by-interp '(module (define tmp.0
                            (lambda (ball.6 bat.5 bar.8 foobar.0)
                              (let ([bat.2 ball.6])
                                (if (if (<= -9223372036854775808 bat.5)
                                        (>= -9223372036854775808 ball.6)
                                        (>= bat.5 2025307007))
                                    (+ bat.2 9223372036854775807)
                                    (if (<= bat.5 -9223372036854775808) 9223372036854775807 0)))))
                          (let ([ball.6 0]) ball.6)
                    ))
(check-by-interp
 '(module (define func.0
            (lambda (ball.6 foobar.3)
              (if (= 0 foobar.3)
                  (+ -9223372036854775808 -9223372036854775808)
                  (if (if (< ball.6 ball.6)
                          (<= foobar.3 foobar.3)
                          (= foobar.3 ball.6))
                      (+ foobar.3 foobar.3)
                      (if (= 1 foobar.3) ball.6 foobar.3)))))
          (define x.1
            (lambda (bar.0)
              (let ([ball.1 (let ([bat.9 (let ([bat.2 1757280127]) bat.2)])
                              (let ([ball.5 1]) -1128483887))])
                (if (let ([foo.7 bar.0]) (> foo.7 foo.7))
                    ball.1
                    (+ ball.1 bar.0)))))
    (define fn.2
      (lambda ()
        (if (let ([foobar.8 (+ -9223372036854775808 -1421853645)]) (not (>= 0 -1400373009)))
            (+ -167927521 1)
            (let ([ball.1 (* 1041085683 9223372036854775807)]) (let ([foo.4 ball.1]) 770292232)))))
    (call x.1 1840464414)))
(check-by-interp
 '(module (define proc.0
            (lambda (ball.4 foo.7 ball.2) (call proc.0 9223372036854775807 ball.2 foo.7)))
          (define func.1
            (lambda (ball.1 bat.0 foo.7 ball.4 foobar.6 bar.3)
              (let ([bar.3 (let ([ball.4 foo.7]) (let ([foobar.5 ball.1]) -9223372036854775808))])
                (call proc.0 bar.3 -780648786 bar.3))))
    (let ([bat.0 -579691794]) 953357957)))
(check-by-interp '(module (let ([bar.5 (let ([ball.2 9223372036854775807]) -546026276)])
                            (if (!= bar.5 1) 9223372036854775807 2063023986))))
(check-by-interp '(module (define func.0
                            (lambda (foo.8 bar.2)
                              (if (not (let ([foo.8 foo.8]) (= foo.8 0)))
                                  (let ([foobar.6 (+ foo.8 0)]) (* 0 9223372036854775807))
                                  (let ([bat.7 (* 0 bar.2)])
                                    (if (!= bat.7 -9223372036854775808) bar.2 0)))))
                          (if (= 9223372036854775807 -315897602) 1 -9223372036854775808)
                    ))
(check-by-interp
 '(module (define fn.0
            (lambda (foobar.3 ball.7)
              (let ([bar.9 (let ([bat.4 (* 1 9223372036854775807)]) (+ -9223372036854775808 bat.4))])
                (let ([bat.4 9223372036854775807]) (if (!= 1 bar.9) 9223372036854775807 ball.7)))))
          (define x.1
            (lambda (bat.2)
              (let ([foobar.3 (let ([bat.4 (+ -1410706204 bat.2)])
                                (let ([bat.2 1]) -9223372036854775808))])
                (* -152436426 0))))
    (define proc.2 (lambda (foo.5 ball.7 foo.0 ball.8) (let ([foobar.1 foo.5]) (+ 956544411 1))))
    (+ 979460199 -1697959716)))
(check-by-interp
 '(module (define proc.0
            (lambda (foobar.1 bar.0 foobar.2 ball.8 bat.3 bar.5)
              (let ([bar.9 (if (let ([bar.7 -669410514]) (< bat.3 bat.3))
                               (+ bar.5 ball.8)
                               foobar.2)])
                (let ([ball.6 (let ([foo.4 ball.8]) 1)])
                  (if (<= foobar.2 1) 9223372036854775807 bat.3)))))
          (call proc.0 0 9223372036854775807 0 -1371550930 -1891086346 9223372036854775807)
    ))
(check-by-interp '(module (define x.0
                            (lambda (bat.7 ball.9 foobar.3 ball.5 ball.4 bar.0 ball.2)
                              (if (not (if (>= 388494724 ball.9)
                                           (> ball.5 -9223372036854775808)
                                           (< foobar.3 ball.5)))
                                  (if (<= ball.4 bar.0)
                                      0
                                      (let ([ball.4 ball.5]) 1887946265))
                                  foobar.3)))
                          (define tmp.1
                            (lambda (bat.7 ball.9 ball.5 foo.6 bar.0 ball.2)
                              (if (true)
                                  (* foo.6 9223372036854775807)
                                  (if (let ([foobar.3 1]) (<= bar.0 ball.5))
                                      (let ([ball.9 -9223372036854775808]) ball.9)
                                      (let ([bat.7 1]) 1)))))
                    (define tmp.2
                      (lambda (bat.7 ball.2 foo.6 foobar.3 bar.8 bar.0)
                        (let ([foobar.3 (if (let ([ball.2 258314756]) (!= bar.8 0))
                                            bar.8
                                            (let ([foo.6 -1809848824]) 9223372036854775807))])
                          (if (< 1525021420 1)
                              (call tmp.1 foobar.3 1 -1256996529 foo.6 -768559462 1067478227)
                              (if (> 389818959 882297114) bar.8 ball.2)))))
                    (let ([bar.0 1]) 1)))
(check-by-interp
 '(module (define tmp.0 (lambda (foo.1 ball.6 bar.9 bat.3 ball.8 bat.0 ball.7) (* bat.3 bat.0)))
          (define func.1
            (lambda (foo.1 bar.2 foo.5 bat.3 bar.9) (let ([bat.3 1]) 9223372036854775807)))
    (define fn.2
      (lambda (ball.7 ball.8)
        (let ([bat.3 (if (>= ball.7 1)
                         (if (= ball.7 ball.7) ball.8 214741259)
                         (+ 1683358713 ball.8))])
          (call tmp.0 bat.3 ball.8 0 ball.7 9223372036854775807 ball.7 -2043460455))))
    (call tmp.0
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
 '(module (define x.0 (lambda (ball.0 foobar.1 foo.3 foobar.2 foo.6 foobar.5 ball.8) (call x.4 1)))
          (define func.1
            (lambda ()
              (let ([bar.9 9223372036854775807])
                (let ([foobar.1 bar.9]) (if (>= -577997854 foobar.1) -9223372036854775808 bar.9)))))
    (define fn.2
      (lambda ()
        (let ([ball.7 (+ 1 1)])
          (if (false)
              ball.7
              (let ([foobar.1 ball.7]) 1969054361)))))
    (define x.3
      (lambda (foobar.4 foobar.5 bar.9 foobar.2 ball.8 foo.3 ball.7)
        (call func.6
              0
              -9223372036854775808
              9223372036854775807
              25911444
              9223372036854775807
              foobar.4
              -9223372036854775808)))
    (define x.4 (lambda (foobar.4) (call x.3 0 foobar.4 foobar.4 1 foobar.4 foobar.4 foobar.4)))
    (define x.5
      (lambda (foo.6 foo.3 foobar.4 bar.9 foobar.1 foobar.5)
        (let ([foobar.5 (let ([foobar.1 bar.9]) (let ([foo.6 foo.3]) foobar.1))])
          (if (let ([ball.8 bar.9]) (> foo.3 foo.6))
              (call x.0 -1863740769 9223372036854775807 foobar.4 foobar.5 foo.3 foobar.5 -1819248150)
              1))))
    (define func.6
      (lambda (foobar.2 foo.6 ball.0 ball.8 foo.3 foobar.1 foobar.5)
        (if (if (true)
                (let ([ball.0 foobar.2]) (> -1497437069 -9223372036854775808))
                (not (!= -1101838227 -1416967818)))
            (let ([ball.8 (+ foobar.2 foobar.2)]) (let ([foobar.1 0]) foobar.1))
            1)))
    (define fn.7
      (lambda ()
        (if (true)
            (if (not (> 0 100011461))
                (call x.5 -9223372036854775808 16140507 0 -1248542300 0 -1579752260)
                (if (= -9223372036854775808 471889533) 1 0))
            (if (if (>= 1 0)
                    (>= 0 -9223372036854775808)
                    (> 9223372036854775807 0))
                (call fn.7)
                (if (> 1 1) -444155079 9223372036854775807)))))
    (if (let ([foo.6
               (if (let ([foobar.2 -9223372036854775808]) (true))
                   (let ([foobar.2 (if (> 9223372036854775807 0) -1444900091 -9223372036854775808)])
                     foobar.2)
                   (if (true)
                       (let ([foobar.5 9223372036854775807]) foobar.5)
                       (if (= -9223372036854775808 1173781558) 0 1)))])
          (if (true)
              (let ([bar.9 0]) (true))
              (< 858519747 foo.6)))
        1
        (if (< 1 -1323259230)
            (call fn.2)
            (call fn.2)))))
; (module+ test
;   (require rackunit)
;   ; example outputs for uniquify
;   (check-equal? (uniquify '(module (+ 2 2))) '(module (+ 2 2)))
;   (check-match (uniquify '(module (let ([x 5]) x))) `(module (let ([,x 5]) ,x)) (aloc? x))
;   (check-match (uniquify '(module (let ([x (+ 2 2)]) x))) `(module (let ([,x (+ 2 2)]) ,x)) (aloc? x))
;   (check-match (uniquify '(module (let ([x 2]) (let ([y 2]) (+ x y)))))
;                `(module (let ([,x.5 2]) (let ([,y.6 2]) (+ ,x.5 ,y.6))))
;                (andmap aloc? `(,x.5 ,y.6)))
;   (check-match (uniquify '(module (let ([x 2]) (let ([x 2]) (+ x x)))))
;                `(module (let ([,x.7 2]) (let ([,x.8 2]) (+ ,x.8 ,x.8))))
;                (andmap aloc? `(,x.7 ,x.8)))
;   (check-equal? (uniquify '(module 1)) `(module 1))
;   (check-exn exn:fail? (λ () (uniquify '(module x))))
;   (check-match (uniquify '(module (let ([x 5]) 1))) `(module (let ([,x 5]) 1)) (aloc? x))
;   (check-match (uniquify '(module (let ([y 2]
;                                         [x 3])
;                                     (+ x x))))
;                `(module (let ([,x.7 2]
;                               [,x.8 3])
;                           (+ ,x.8 ,x.8)))
;                (andmap aloc? `(,x.7 ,x.8)))
;   (check-match (uniquify '(module (let ([x 2]
;                                         [y 3])
;                                     (let ([y (+ y y)]
;                                           [x 3])
;                                       (+ x x)))))
;                `(module (let ([,x.7 2]
;                               [,x.8 3])
;                           (let ([,x.9 (+ ,x.8 ,x.8)]
;                                 [,x.10 3])
;                             (+ ,x.10 ,x.10))))
;                (andmap aloc? `(,x.7 ,x.8 ,x.9 ,x.10)))
;   (check-match (uniquify '(module (let ([y (let ([x 1]) x)]
;                                         [x 3])
;                                     (let ([y (+ x x)]
;                                           [x 3])
;                                       (+ x x)))))
;                `(module (let ([,x.7 (let ([,x.1 1]) ,x.1)]
;                               [,x.8 3])
;                           (let ([,x.9 (+ ,x.8 ,x.8)]
;                                 [,x.10 3])
;                             (+ ,x.10 ,x.10))))
;                (andmap aloc? `(,x.1 ,x.7 ,x.8 ,x.9 ,x.10)))
;   (check-exn exn:fail?
;              (λ ()
;                (uniquify '(module (let ([t (let ([x 1]) x)]
;                                         [x x])
;                                     (let ([x (+ x x)]
;                                           [x 3])
;                                       (+ x x)))))))
;   (check-match (uniquify '(module (let ([y 2]
;                                         [x 3])
;                                     (if (true)
;                                         (let ([z 3]) z)
;                                         (let ([z 3]) z)))))
;                `(module (let ([,y.2 2]
;                               [,x.1 3])
;                           (if (true)
;                               (let ([,z.3 3]) ,z.3)
;                               (let ([,z.4 3]) ,z.4))))
;                (andmap aloc? `(,x.1 ,y.2 ,z.3 ,z.4))))
