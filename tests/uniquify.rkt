#lang racket
(require rackunit
         cpsc411/langs/v2
         cpsc411/langs/v3
         (only-in "../values-lang/uniquify.rkt" uniquify))

(define (check-values-lang-v3 p)
  (if (values-lang-v3? p) p #f))

(define (check-values-unique-lang-v3 p)
  (if (values-unique-lang-v3? p) p #f))

(define-syntax-rule (check-by-interp p)
  (check-equal? (interp-values-unique-lang-v3 (check-values-unique-lang-v3 (uniquify p)))
                (interp-values-lang-v3 (check-values-lang-v3 p))))

;;; Added by Trevor on 2026-03-18

(check-by-interp '(module (let ()
                            (let ([ball.4 -9223372036854775808]
                                  [foo.1 1])
                              foo.1))))
(check-by-interp '(module (let ([ball.7 (+ 1 9223372036854775807)]
                                [ball.6 996577960])
                            -1528452922)))
(check-by-interp '(module (let ([foobar.5 -9223372036854775808]
                                [bar.1 0]
                                [foobar.4 (+ 9223372036854775807 1)])
                            foobar.5)))
(check-by-interp '(module (let ([foobar.7 (+ 9223372036854775807 -68144516)]
                                [foo.2 -612735698]
                                [bar.9 (* -937851344 1)])
                            bar.9)))
(check-by-interp '(module (let ([bar.8 (* 1768876961 2091480106)]
                                [foo.0 -2078188405])
                            (let ([bat.6 -830843178]
                                  [bat.5 1])
                              bat.5))))
(check-by-interp '(module (let ([ball.0 -9223372036854775808]
                                [bat.6 -9223372036854775808]
                                [bat.5 -9223372036854775808])
                            (* 1 bat.6))))
(check-by-interp '(module (let ()
                            (let ([foo.5 0]
                                  [ball.6 9223372036854775807]
                                  [foo.2 -9223372036854775808]
                                  [bat.4 1]
                                  [foo.7 1827770844])
                              1))))
(check-by-interp '(module (let ([ball.4 1140216125])
                            (let ([ball.4 ball.4]
                                  [foobar.6 ball.4]
                                  [foobar.3 ball.4]
                                  [ball.0 ball.4]
                                  [bat.5 ball.4]
                                  [bat.1 ball.4])
                              foobar.3))))
(check-by-interp '(module (let ([ball.4 9223372036854775807]
                                [foobar.7 -9223372036854775808])
                            (let ([ball.4 0]
                                  [foobar.3 9223372036854775807]
                                  [bat.2 401318453])
                              ball.4))))
(check-by-interp '(module (let ([bar.4 0]
                                [foobar.5 1833841538]
                                [ball.0 1]
                                [ball.1 (let ([bat.3 1220973327]
                                              [bar.4 904195701]
                                              [ball.7 -541165341]
                                              [ball.1 -173234253])
                                          bar.4)])
                            0)))
(check-by-interp '(module (let ([bar.7 (let ([bar.4 -75894610]
                                             [bar.7 -1246875017])
                                         bar.4)])
                            (let ([bar.9 -9223372036854775808]
                                  [foo.8 bar.7]
                                  [foobar.3 -1110697710]
                                  [bat.2 bar.7]
                                  [bat.5 1])
                              0))))
(check-by-interp '(module (let ([bar.8 (let ([foobar.4 1]
                                             [bar.8 -9223372036854775808]
                                             [ball.2 2047036712]
                                             [foobar.3 1919359218]
                                             [ball.6 -9223372036854775808])
                                         foobar.3)])
                            (let ([ball.1 0]
                                  [ball.6 2126399608])
                              ball.1))))
(check-by-interp '(module (let ([bat.1 9223372036854775807]
                                [foo.0 (+ 1458156976 1)])
                            (let ([bar.4 bat.1]
                                  [ball.3 (let ([bat.8 (* 1 1729076944)]
                                                [foo.0 foo.0]
                                                [bat.1 (+ 0 -9223372036854775808)])
                                            (* foo.0 bat.8))])
                              (let ([bat.1 (* foo.0 bat.1)]
                                    [ball.7 bar.4])
                                (* 0 1))))))
(check-by-interp '(module (let ([bar.0 (+ 1 -9223372036854775808)]
                                [bat.7 -9223372036854775808]
                                [foo.9 (let ([bar.6 9223372036854775807]
                                             [bar.0 -134004656])
                                         1)]
                                [foo.8 (* 1 0)])
                            (let ([foo.3 983863554]
                                  [ball.4 -9223372036854775808]
                                  [foo.9 9223372036854775807]
                                  [foo.8 foo.8])
                              foo.9))))
(check-by-interp '(module (let ([foobar.8 (let ([ball.1 -2056929169]
                                                [ball.3 -579595654]
                                                [bar.4 9223372036854775807]
                                                [ball.6 -9223372036854775808]
                                                [foobar.8 -9223372036854775808])
                                            ball.1)]
                                [bat.0 (* -128242590 0)]
                                [bar.5 -1070972855])
                            (let ([bar.5 bat.0]
                                  [ball.6 foobar.8]
                                  [foobar.8 1])
                              bar.5))))
(check-by-interp '(module (let ([foobar.4 -9223372036854775808]
                                [foobar.2 (let ([foobar.4 -1164390901]
                                                [foobar.2 -13264410]
                                                [bar.1 1]
                                                [foobar.8 9223372036854775807])
                                            foobar.4)]
                                [ball.6 (let ([ball.6 1]
                                              [foobar.2 527653430]
                                              [ball.0 1855454698])
                                          -177762459)]
                                [bar.1 9223372036854775807])
                            1254958062)))
(check-by-interp '(module (let ([bar.0 (* -9223372036854775808 -9223372036854775808)]
                                [bat.3 -9223372036854775808]
                                [bat.5 (* -9223372036854775808 9223372036854775807)]
                                [foobar.8 -282715271]
                                [foo.2 1079535546]
                                [ball.1 0])
                            (let ([ball.1 9223372036854775807]
                                  [bar.0 9223372036854775807]
                                  [bat.3 bat.3])
                              foobar.8))))
(check-by-interp
 '(module (let ([foobar.3 (let ([foobar.3 0]
                                [foobar.1 (* -44807523 9223372036854775807)]
                                [foobar.7 9223372036854775807]
                                [foobar.2 (* -9223372036854775808 9223372036854775807)])
                            foobar.3)]
                [foobar.1 (let ([foobar.0 (* -9223372036854775808 9223372036854775807)]
                                [foobar.1 -9223372036854775808])
                            -1026539425)]
                [foobar.0 (+ -432307559 0)])
            foobar.0)))
(check-by-interp '(module (let ()
                            (let ([ball.5 (let () 9223372036854775807)]
                                  [bat.8 (let ([ball.0 -9223372036854775808]
                                               [bat.2 9223372036854775807]
                                               [ball.9 -9223372036854775808])
                                           ball.9)]
                                  [foo.3 (let ([bat.7 9223372036854775807]
                                               [bat.8 -567636434])
                                           bat.8)]
                                  [bar.4 (+ 9223372036854775807 0)])
                              (let ([bat.7 0]
                                    [ball.6 9223372036854775807]
                                    [ball.5 -1293214889])
                                0)))))
(check-by-interp '(module (let ([foo.8 -9223372036854775808]
                                [bar.6 (let ([bar.6 -9223372036854775808]
                                             [ball.0 (let ([bar.6 -9223372036854775808]) bar.6)]
                                             [ball.1 (+ -1436005507 1112271375)]
                                             [foo.8 (* -9223372036854775808 -9223372036854775808)])
                                         (* ball.1 1553839939))])
                            (let ([foo.8 -1233593104]
                                  [bar.6 0]
                                  [bar.9 (* -1860181312 foo.8)])
                              (+ -9223372036854775808 bar.9)))))
(check-by-interp '(module (let ([bar.7 (let ()
                                         (let ([bat.4 9223372036854775807]
                                               [ball.8 (let ([bat.4 -9223372036854775808]
                                                             [bar.7 1822009732]
                                                             [foobar.9 9223372036854775807]
                                                             [bar.2 1]
                                                             [bar.5 682989919])
                                                         bar.7)])
                                           (let ([bar.2 ball.8]) ball.8)))]
                                [ball.8 (+ 0 1)]
                                [bar.2 (+ 9223372036854775807 -1050604408)]
                                [foobar.9 (* -9223372036854775808 0)])
                            (* -9223372036854775808 bar.2))))
(check-by-interp '(module (let ([bat.3 (let ([bat.3 1980064593]
                                             [foo.4 -9223372036854775808]
                                             [foobar.2 -1495882824])
                                         -737835353)]
                                [ball.8 -9223372036854775808]
                                [bat.1 -9223372036854775808]
                                [foo.0 (+ -574027986 1926740047)]
                                [foo.4 (let ([foo.4 1142228157]
                                             [bat.3 -1751002496]
                                             [ball.9 9223372036854775807]
                                             [foobar.2 0])
                                         9223372036854775807)])
                            (let ([bat.3 bat.1]) -9223372036854775808))))
(check-by-interp '(module (let ()
                            (let ([bat.1 0]
                                  [ball.3 (let ([bat.8 0]
                                                [ball.0 -1954098237]
                                                [bar.6 0]
                                                [ball.3 9223372036854775807]
                                                [foo.7 1])
                                            ball.0)]
                                  [bar.6 1]
                                  [ball.5 (let () 9223372036854775807)]
                                  [foo.7 (let ([foo.2 1]
                                               [ball.3 1]
                                               [bat.4 1330702566]
                                               [bar.6 208041436]
                                               [foo.7 -9223372036854775808]
                                               [ball.0 9223372036854775807])
                                           1)])
                              (let ([bar.6 1]
                                    [bat.8 foo.7]
                                    [bat.1 bat.1]
                                    [foo.2 ball.3])
                                2098290172)))))
(check-by-interp '(module (let ([bat.6 1298534774]
                                [foobar.8 (let ([foo.2 9223372036854775807]
                                                [bar.7 0]
                                                [bat.6 9223372036854775807])
                                            9223372036854775807)]
                                [ball.0 (* 1 0)]
                                [bar.4 (* 44651403 0)]
                                [foo.2 (* 1 -859255124)]
                                [foobar.5 (let ([foobar.5 889520210]
                                                [bar.7 -2029578185]
                                                [foobar.8 1]
                                                [bar.4 -1045099983]
                                                [bat.6 1134122890])
                                            0)])
                            (let ([bar.7 bar.4]
                                  [bat.1 foobar.8]
                                  [foobar.5 bar.4]
                                  [foobar.8 -9223372036854775808])
                              bar.4))))
(check-by-interp '(module (let ([bat.1 (* 510727775 -9223372036854775808)]
                                [bat.4 (* 0 -9223372036854775808)]
                                [ball.2 (let ([ball.2 490025338]
                                              [bar.5 (let ([bat.1 1]
                                                           [bat.4 -9223372036854775808]
                                                           [bar.5 1]
                                                           [ball.3 1]
                                                           [bar.8 0]
                                                           [bat.6 -322254623])
                                                       -1276525534)])
                                          (* bar.5 bar.5))])
                            (let ([bat.1 (+ bat.1 -9223372036854775808)]
                                  [ball.2 (let ([ball.0 1135101160]
                                                [bat.1 0])
                                            0)])
                              (let ([bat.6 1085391631]
                                    [bat.9 ball.2]
                                    [bat.1 bat.4])
                                bat.4)))))
(check-by-interp '(module (let ([bar.7 (* -1698914420 1)]
                                [bar.4 (* 1 0)]
                                [bar.0 (* -9223372036854775808 -9223372036854775808)])
                            (let ([bar.4 9223372036854775807])
                              (let ([bat.8 (* bar.4 bar.4)]
                                    [bar.7 13192944]
                                    [bar.2 (let ([foobar.5 9223372036854775807]
                                                 [foo.6 -1745801350]
                                                 [foobar.9 1511145156]
                                                 [bar.7 bar.0]
                                                 [bar.0 bar.4])
                                             foobar.5)]
                                    [ball.3 (let ([bar.2 bar.7]
                                                  [bat.1 0])
                                              1)]
                                    [bar.0 (let ([foobar.5 bar.4]
                                                 [foo.6 1]
                                                 [ball.3 bar.7]
                                                 [bat.8 bar.7])
                                             1)])
                                1)))))
(check-by-interp '(module (let ([bat.6 (+ 9223372036854775807 9223372036854775807)]
                                [bar.5 0]
                                [foobar.0 (+ 9223372036854775807 0)]
                                [ball.1 (+ 149382600 1)]
                                [foobar.9 -9223372036854775808]
                                [bar.3 (+ 9223372036854775807 -9223372036854775808)])
                            (let ([bar.3 (let ([bar.3 0]
                                               [foobar.9 foobar.9]
                                               [ball.1 1]
                                               [bar.5 1085340665])
                                           0)]
                                  [bar.5 (let ([bar.8 foobar.9]
                                               [ball.1 foobar.9])
                                           -9223372036854775808)])
                              (let ([foo.2 1]
                                    [bar.5 bar.5]
                                    [ball.1 bat.6]
                                    [foobar.9 bat.6]
                                    [foobar.0 1])
                                foo.2)))))
(check-by-interp '(module (let ([foobar.1 (+ 221377605 -1076871737)]
                                [bar.8 (let ([bar.5 (+ 0 1)]
                                             [ball.6 (let ([bar.5 -1463044307]
                                                           [ball.2 1]
                                                           [bar.8 (let ([ball.6 0]
                                                                        [bat.7 9223372036854775807]
                                                                        [bar.8 -9223372036854775808])
                                                                    1343302930)]
                                                           [ball.4 (+ -438824419 -1777497567)]
                                                           [bat.3 -885273077]
                                                           [bat.7 (* 1 1)])
                                                       (+ -1921282404 0))]
                                             [bat.9 1]
                                             [ball.2 -134738152])
                                         (+ 0 bat.9))]
                                [bat.7 -9223372036854775808]
                                [ball.4 (* 1 1)]
                                [bat.9 (* -9223372036854775808 1)]
                                [bat.0 (let () 1877569491)])
                            0)))
(check-by-interp '(module (let ([ball.1 (let ([ball.1 (let ([ball.5 0]
                                                            [bat.0 0]
                                                            [foo.8 0])
                                                        bat.0)]
                                              [bat.0 (let ([bat.0 233203269]
                                                           [foobar.4 9223372036854775807]
                                                           [bar.9 1]
                                                           [ball.5 -9223372036854775808])
                                                       -9223372036854775808)]
                                              [foobar.4 (* 9223372036854775807 0)]
                                              [foo.8 (+ 1 -2129718472)]
                                              [foobar.6 (+ 417598272 -504836775)]
                                              [ball.5 (+ -252477011 1937594448)])
                                          (let ([foo.2 foobar.4]
                                                [foobar.6 -226843481]
                                                [ball.1 foobar.4]
                                                [foobar.4 foobar.6])
                                            ball.1))]
                                [foobar.4 -603343741])
                            (let ([ball.1 (+ 1114260743 ball.1)]
                                  [foo.8 (+ 1 1)]
                                  [foobar.6 ball.1])
                              (let ([bar.3 ball.1]
                                    [ball.1 foo.8]
                                    [foo.8 ball.1]
                                    [bat.0 foobar.6])
                                0)))))
(check-by-interp '(module (let ([bar.1 (+ -9223372036854775808 1)]
                                [bar.9 -1263740488]
                                [bat.2 (let ([foo.5 (* 998929959 -9223372036854775808)]
                                             [bat.8 -2034793604]
                                             [bat.2 (let ([foo.5 -9223372036854775808]
                                                          [bar.6 2110479097])
                                                      bar.6)])
                                         (let ([bar.6 -1235010588]
                                               [bar.9 9223372036854775807]
                                               [bat.7 9223372036854775807]
                                               [foo.5 0]
                                               [bat.8 1])
                                           bar.6))]
                                [foo.3 (+ -9223372036854775808 1)]
                                [bat.8 (let ([bat.7 -1568444655]
                                             [foo.4 -9223372036854775808]
                                             [bat.0 (let ([foo.3 1]
                                                          [bar.9 -528292093]
                                                          [bar.1 0])
                                                      -1447541200)]
                                             [bar.1 -1613855170])
                                         (* 9223372036854775807 bat.7))])
                            (let ([foo.3 1513905621]
                                  [bar.1 (let () 9223372036854775807)]
                                  [bat.0 0])
                              (let ([bat.2 bar.1]
                                    [bar.9 1]
                                    [foo.3 bar.1])
                                1070018088)))))
(check-by-interp '(module (let ([bar.0 0]
                                [ball.6 (let ([bar.0 (let ([foo.3 0]
                                                           [foo.1 0]
                                                           [foobar.7 -1502967641])
                                                       0)]
                                              [bar.5 9223372036854775807]
                                              [ball.9 (let ([bar.4 -9223372036854775808]
                                                            [ball.6 0]
                                                            [ball.9 9223372036854775807]
                                                            [foobar.2 -9223372036854775808]
                                                            [bar.0 -9223372036854775808]
                                                            [foobar.7 1])
                                                        -9223372036854775808)]
                                              [foo.1 (let ([foobar.7 0]
                                                           [bar.0 -9223372036854775808]
                                                           [foobar.2 -9223372036854775808]
                                                           [bat.8 -1938910922]
                                                           [ball.9 995325664])
                                                       1)])
                                          bar.0)]
                                [foobar.7 (let ([ball.9 1]
                                                [bar.5 9223372036854775807]
                                                [foo.1 (let ([ball.9 -1417838415]
                                                             [bar.0 9223372036854775807]
                                                             [bar.5 -286768514]
                                                             [foobar.7 0]
                                                             [foobar.2 -9223372036854775808])
                                                         385534009)]
                                                [bat.8 1641860413]
                                                [bar.4 (* -9223372036854775808 1)])
                                            (* 0 2040049431))]
                                [bar.5 (+ 9223372036854775807 9223372036854775807)]
                                [foobar.2 -9223372036854775808]
                                [bat.8 -9223372036854775808])
                            (let ([bar.0 (let ([bar.4 ball.6]
                                               [foobar.2 0]
                                               [bar.0 bat.8])
                                           1)]
                                  [foo.1 (+ foobar.2 -9223372036854775808)])
                              (let ([ball.6 foobar.2]
                                    [foo.3 bat.8]
                                    [ball.9 bat.8])
                                0)))))
(check-by-interp '(module (let ([bar.1 1145225124]
                                [bat.9 (* 0 -9223372036854775808)]
                                [bar.7 (let ([bar.1 (let ([foo.0 -9223372036854775808]
                                                          [ball.4 (let ([foo.0 -746190367]
                                                                        [foobar.5 -876251589]
                                                                        [foo.6 0]
                                                                        [bar.7 -9223372036854775808]
                                                                        [bar.3 9223372036854775807]
                                                                        [bar.1 1])
                                                                    -1057057431)])
                                                      (* 0 -9223372036854775808))]
                                             [bat.8 1]
                                             [bar.7 (* -9223372036854775808 -1581008192)]
                                             [foobar.2 (let ([bar.1 (let ([bat.9 -1606195130]
                                                                          [foo.0 1])
                                                                      -1755998681)]
                                                             [foo.6 0]
                                                             [foobar.5 (* 9223372036854775807
                                                                          51983263)]
                                                             [foobar.2 (+ 1 -9223372036854775808)]
                                                             [ball.4 (let ([bar.7 0]
                                                                           [bar.1 -849060432]
                                                                           [foo.6 9223372036854775807]
                                                                           [bat.9 1]
                                                                           [foo.0 1866960197]
                                                                           [bat.8 -862348842])
                                                                       -9223372036854775808)])
                                                         (+ -1762859866 -1973749130))])
                                         (let ([foobar.5 (let ([ball.4 1]
                                                               [bat.8 985023473]
                                                               [foo.6 1335237925]
                                                               [foobar.2 bar.1]
                                                               [bar.1 1873552019])
                                                           9223372036854775807)]
                                               [bar.7 (let ([bar.7 -1084213429]
                                                            [bat.9 foobar.2]
                                                            [foobar.2 9223372036854775807])
                                                        79735053)]
                                               [bat.8 (let ([foobar.2 -1284398587]
                                                            [foo.0 -9223372036854775808]
                                                            [ball.4 1515555315]
                                                            [bar.1 foobar.2])
                                                        bat.8)]
                                               [bar.3 (+ bat.8 1)]
                                               [foo.0 -727438556]
                                               [bar.1 bar.7])
                                           (* foobar.2 foo.0)))]
                                [bat.8 9223372036854775807])
                            (let ([bar.3 (+ -9223372036854775808 -9223372036854775808)]
                                  [foobar.2 (+ 0 1)]
                                  [bar.1 (* bar.1 bat.8)]
                                  [bar.7 (let ([bar.3 (+ 1345476858 844796380)]
                                               [bar.7 (* 1464754713 -9223372036854775808)]
                                               [bat.8 1241238073])
                                           bar.3)]
                                  [foo.6 -220903261])
                              (let () (let () 1))))))
;;; Added by Trevor on 2026-03-18
