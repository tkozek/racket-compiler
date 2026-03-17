#lang racket
(require rackunit
         cpsc411/langs/v4
         (only-in "../uniquify.rkt" uniquify))
(define-syntax-rule (check-by-interp p)
  (check-equal? (interp-values-lang-v4 (values-unique-lang-v4? p))
                (interp-values-unique-lang-v4 (values-unique-lang-v4? (uniquify p)))))

;;; Added by Trevor on 2026-03-17

(check-by-interp '(module (if (true)
                              (* -9223372036854775808 1919678055)
                              (* -9223372036854775808 1))))
(check-by-interp '(module (let ()
                            (let ([bar.3 -9223372036854775808]
                                  [foobar.1 607177860]
                                  [ball.4 689406262])
                              foobar.1))))
(check-by-interp '(module (let ([foobar.4 293371207]
                                [foo.8 (* 1 -1167539343)]
                                [foobar.1 -9223372036854775808])
                            (if (< 0 foo.8) foobar.4 foobar.1))))
(check-by-interp '(module (let ([bar.9 (+ 1 -9223372036854775808)]
                                [foobar.4 (+ 1 1)]
                                [foo.5 (let () (if (< 722151544 0) 1 -1807150378))])
                            (* foo.5 bar.9))))
(check-by-interp '(module (let ([foobar.7 (* 0 1)]
                                [ball.3 (if (<= 0 1) 1204486682 -9223372036854775808)])
                            (if (< ball.3 foobar.7) ball.3 -9223372036854775808))))
(check-by-interp '(module (if (let ([ball.3 1445608166]
                                    [bat.5 0]
                                    [foobar.2 0]
                                    [bar.1 1])
                                (= bat.5 bar.1))
                              -9223372036854775808
                              (if (> 0 -356663773) 1 -1735070759))))
(check-by-interp '(module (let ([foo.4 (let ([foobar.5 -1840576987]) 254778871)]
                                [ball.0 (if (= 756663068 2060671731) -2062043463 0)]
                                [bar.1 0])
                            (let ([bar.1 bar.1]
                                  [ball.9 foo.4]
                                  [foo.4 ball.0]
                                  [bar.2 ball.0])
                              ball.9))))
(check-by-interp '(module (if (not (<= 2000695989 -1791099531))
                              (let ([foobar.8 0]
                                    [ball.3 0]
                                    [foobar.2 0]
                                    [foobar.6 -927113299]
                                    [foo.7 568308046])
                                foo.7)
                              (let ([ball.4 -983250820]
                                    [foo.7 1]
                                    [ball.3 1318080036])
                                ball.4))))
(check-by-interp '(module (let ([bar.7 (let ([bar.6 -2009338866]
                                             [bar.2 -9223372036854775808])
                                         bar.2)]
                                [bar.3 (if (!= 2060014662 0) 1 1)]
                                [bat.8 1]
                                [bar.2 230093260]
                                [bat.5 900177895])
                            (let ([bat.5 bar.7]
                                  [bar.2 bat.8])
                              bat.5))))
(check-by-interp '(module (if (false)
                              (let ([foobar.7 0]
                                    [foobar.6 0]
                                    [foo.9 -486317609]
                                    [bat.1 -57146603]
                                    [bar.8 0]
                                    [bat.4 -1014629037])
                                foobar.6)
                              (let ([ball.2 1]
                                    [foobar.7 -9223372036854775808]
                                    [foo.3 -502362832]
                                    [bar.8 1])
                                foo.3))))
(check-by-interp '(module (if (if (<= -9223372036854775808 -9223372036854775808)
                                  (<= -9223372036854775808 141552175)
                                  (= 1099135664 -208530803))
                              (let () 1)
                              (let ([foobar.5 0]
                                    [bat.4 -9223372036854775808]
                                    [foobar.2 -1137161966])
                                foobar.2))))
(check-by-interp '(module (if (true)
                              (let ([foobar.6 509793927]
                                    [foo.4 -9223372036854775808]
                                    [bat.3 -9223372036854775808]
                                    [bat.2 -9223372036854775808]
                                    [ball.1 874466679])
                                foo.4)
                              (let ([ball.5 0]
                                    [ball.8 -1676103566]
                                    [bat.2 -12047510])
                                ball.8))))
(check-by-interp '(module (let ([ball.3 (* 1 1742654658)]
                                [foobar.7 -1437539357]
                                [bat.1 -9223372036854775808]
                                [bar.0 1]
                                [bar.5 -1557481616])
                            (let ([ball.3 bar.5]
                                  [bat.1 bar.0]
                                  [foo.2 ball.3]
                                  [bar.5 foobar.7]
                                  [foobar.7 bar.0]
                                  [bat.9 bar.5])
                              foobar.7))))
(check-by-interp '(module (let ([bat.2 (if (>= 1224363849 -9223372036854775808) -1341816285 0)]
                                [bat.4 (if (> 1 0) -1095031 -159334257)]
                                [bar.5 0])
                            (let ([bat.4 934456620]
                                  [foo.1 0]
                                  [bar.8 bat.4]
                                  [foo.9 bat.2]
                                  [bar.7 bat.4]
                                  [bat.2 2034424595])
                              foo.1))))
(check-by-interp '(module (let ([foobar.3 2130780142]
                                [foobar.7 (+ -1626380896 -9223372036854775808)]
                                [foobar.5 (+ 1 -1358001385)]
                                [bar.8 1])
                            (let ([foobar.7 (+ bar.8 foobar.7)]
                                  [bat.9 foobar.3]
                                  [bat.2 foobar.5]
                                  [foobar.3 foobar.3])
                              (+ foobar.5 1394508466)))))
(check-by-interp '(module (let ([ball.0 (+ 1 0)]
                                [foobar.7 (let ([foo.8 0]
                                                [ball.3 -9223372036854775808]
                                                [ball.2 420120758]
                                                [foobar.7 950229390]
                                                [foo.9 -9223372036854775808])
                                            -1436788709)]
                                [foobar.1 351241708]
                                [foo.9 -46944546]
                                [foo.5 (+ 1 -858099177)])
                            ball.0)))
(check-by-interp '(module (let ([ball.9 (if (= 0 1122085113) 1377663341 -1212687808)]
                                [ball.7 (if (<= 359103696 -366451938) 0 -9223372036854775808)]
                                [bat.3 -9223372036854775808]
                                [bat.1 (let ([foobar.2 0]
                                             [foo.5 0])
                                         foobar.2)])
                            (if (< bat.3 ball.7) ball.9 ball.9))))
(check-by-interp
 '(module (let ([ball.8 (if (<= 1 1) 1 1334663491)]
                [foo.0 433059534]
                [bat.2 1777050844]
                [foobar.5 (if (!= 1 -9223372036854775808) 1682963351 -9223372036854775808)]
                [bat.1 (* -424296474 -1384099004)]
                [ball.3 -9223372036854775808])
            (let ([foo.0 bat.2]) foo.0))))
(check-by-interp '(module (let ([foobar.4 (if (> 1 960229008) -353253341 1)]
                                [bar.7 (let ([ball.3 0]
                                             [foobar.4 -1094240881]
                                             [bar.1 1])
                                         ball.3)]
                                [bat.5 1]
                                [ball.8 (let ([bar.7 432749591]
                                              [ball.8 -421411277])
                                          749377747)]
                                [ball.3 -996428766])
                            (if (= ball.8 bar.7) -198638968 ball.8))))
(check-by-interp '(module (if (let ([bat.1 -9223372036854775808]
                                    [foobar.9 1]
                                    [foo.4 0]
                                    [foobar.6 -9223372036854775808]
                                    [foobar.7 1])
                                (!= 0 foobar.7))
                              (let ([bar.0 1]) -941719640)
                              (let ([foobar.6 120745579]
                                    [foo.3 -987089435]
                                    [foo.8 -76571663]
                                    [bar.0 1]
                                    [foobar.7 1]
                                    [foobar.5 -1933482026])
                                foobar.6))))
(check-by-interp '(module (let ([foo.1 (* 1 495756801)]
                                [bar.8 (if (= 1020300534 0) 1 1247921698)]
                                [ball.9 (+ 61219697 1)]
                                [bar.0 -738667072]
                                [foobar.3 (let ([foo.6 1]) foo.6)]
                                [foobar.4 (let () 1)])
                            (let ([ball.9 foo.1]
                                  [foo.1 ball.9]
                                  [foo.2 foobar.3]
                                  [bar.0 bar.0]
                                  [foobar.3 bar.0]
                                  [foo.6 1])
                              bar.8))))
(check-by-interp '(module (if (false)
                              (let ([ball.4 0]
                                    [ball.8 -1320062012]
                                    [bar.0 (+ 0 -9223372036854775808)])
                                (if (< bar.0 ball.4) bar.0 ball.4))
                              (if (let ([bar.0 -573607979]
                                        [ball.4 0]
                                        [ball.6 -915462716])
                                    (<= ball.4 bar.0))
                                  (if (!= 1388204095 -1903755946) 1 158515729)
                                  (let ([ball.4 1452522364]
                                        [ball.6 1]
                                        [ball.1 1])
                                    ball.1)))))
(check-by-interp '(module (let ([foobar.2 (+ 917166060 1734464315)]
                                [bat.5 (let ([foo.9 1]
                                             [ball.6 1]
                                             [bat.5 -1508855828]
                                             [foobar.7 1])
                                         ball.6)]
                                [foobar.8 (if (>= -9223372036854775808 0) 1 1637767071)]
                                [foobar.7 (let ([foobar.2 1223062971]
                                                [foobar.8 594357257]
                                                [foo.9 1182737157]
                                                [ball.6 -1866987123])
                                            foobar.8)])
                            (let () foobar.8))))
(check-by-interp '(module (let ([bar.8 1]
                                [bat.2 (if (!= 0 0) 1 82746644)]
                                [ball.9 (if (>= -432462765 1) -9223372036854775808 0)]
                                [bat.7 -1245760310]
                                [bar.5 (if (= -9223372036854775808 0) 1 0)]
                                [foo.3 (let ([bar.8 1]
                                             [bar.6 1356748148]
                                             [bat.2 0]
                                             [foo.3 0]
                                             [foobar.4 -1498191265])
                                         foobar.4)])
                            (let ([ball.0 bar.8]
                                  [ball.9 bar.5])
                              bar.8))))
(check-by-interp '(module (let ([foo.2 (+ -9223372036854775808 0)]
                                [foo.9 (let ([bat.4 (let ()
                                                      (let ([foobar.5 -1016442341]
                                                            [foobar.1 1416892493]
                                                            [bat.7 1]
                                                            [ball.8 -1826864241]
                                                            [bar.3 -9223372036854775808])
                                                        -9223372036854775808))]
                                             [ball.6 (* 440337125 86379188)]
                                             [bar.3 (+ 1 1432660723)])
                                         bat.4)]
                                [foobar.1 (+ -9223372036854775808 554830987)]
                                [bar.3 0]
                                [bat.4 (+ 1536405233 0)])
                            bat.4)))
(check-by-interp '(module (let ([foo.2 (* -9223372036854775808 -1157863409)]
                                [foobar.1 1744993864]
                                [bat.7 (let ([ball.4 -1918619273]
                                             [foo.3 -9223372036854775808]
                                             [bar.6 76920539]
                                             [ball.9 0]
                                             [ball.8 1085636044])
                                         ball.8)]
                                [foo.0 (+ -9223372036854775808 -9223372036854775808)]
                                [foobar.5 (let ([ball.8 -1466502296]
                                                [ball.9 0])
                                            ball.9)]
                                [ball.9 0])
                            (let ([foobar.1 ball.9]
                                  [foo.3 foobar.1]
                                  [ball.9 1706452662])
                              foo.0))))
(check-by-interp '(module (let ([bar.5 (let ([ball.2 0]
                                             [bar.5 1]
                                             [ball.0 -9223372036854775808]
                                             [foobar.9 668102712]
                                             [foobar.3 0]
                                             [bar.7 -9223372036854775808])
                                         ball.0)]
                                [foobar.3 -118645994]
                                [ball.0 (if (<= -333498877 1928180618) 1 1)]
                                [bar.7 (if (= 414168669 1) 0 -9223372036854775808)]
                                [bar.6 (* -9223372036854775808 -9223372036854775808)])
                            (let ([bar.6 ball.0]
                                  [foobar.9 bar.5]
                                  [foo.8 bar.7]
                                  [bar.7 bar.7]
                                  [foobar.3 bar.7]
                                  [bar.5 bar.6])
                              bar.5))))
(check-by-interp
 '(module (let ([bat.0 -9223372036854775808]
                [bat.7 (let ([foo.1 (let () (* -9223372036854775808 -9223372036854775808))]
                             [bar.6 (if (= 0 0)
                                        (if (!= -9223372036854775808 0) 571243347 610130973)
                                        (+ -9223372036854775808 1))]
                             [foo.5 1256333532]
                             [bat.0 (if (= 0 -1835378586)
                                        (let () 1)
                                        (* -9223372036854775808 -424152180))])
                         bar.6)]
                [foobar.3 (let ([foo.1 (+ 913593729 1)]
                                [foo.8 (if (true)
                                           (let () 1)
                                           0)]
                                [foo.5 0]
                                [bar.4 (* 0 -535871239)]
                                [ball.2 (if (>= -353070992 -388357885)
                                            (+ 1 0)
                                            (* -9223372036854775808 1))])
                            ball.2)])
            bat.0)))
(check-by-interp
 '(module (if (> 1 -9223372036854775808)
              (let ([bat.8 -1486589648])
                (if (if (= bat.8 bat.8)
                        (< bat.8 bat.8)
                        (= bat.8 -9223372036854775808))
                    bat.8
                    (* bat.8 bat.8)))
              (if (false)
                  (if (false)
                      (let ([bat.0 1]
                            [bar.4 1]
                            [foobar.6 -9223372036854775808])
                        bat.0)
                      (if (!= -286584138 0) 1 451150392))
                  (let ([bar.4 (let ([foobar.6 -9223372036854775808]
                                     [bar.1 -1625696401]
                                     [bar.4 -15834334]
                                     [bat.9 1917576020]
                                     [bat.5 -698078301]
                                     [bar.2 -2018556296])
                                 bat.5)]
                        [bar.2 (if (<= 1 1) 0 -1965042386)]
                        [bat.9 (if (< 0 0) -9223372036854775808 -9223372036854775808)])
                    (* bar.2 -9223372036854775808))))))
(check-by-interp
 '(module (let ([bat.4 (let ([foo.9 (if (<= 1 -9223372036854775808) -968056241 -603018045)]
                             [foobar.7 (let ([bat.4 903109867]) -2096973776)]
                             [foo.8 (if (>= 844611670 -1394444838) 0 1)]
                             [foobar.0 (* 1461159574 886215187)])
                         (+ foo.9 foobar.0))]
                [foo.3 (if (let ([foo.8 1]
                                 [foobar.5 633639708]
                                 [foo.9 1169357215]
                                 [bat.4 1853746647]
                                 [foo.3 -1584162714])
                             (< bat.4 foobar.5))
                           (* 1 0)
                           (if (= 0 1) 0 1))]
                [foo.2 (if (if (>= 799518468 679954644)
                               (!= 1925095941 0)
                               (!= -1317068388 -1173413790))
                           -1192664449
                           (* 1374293415 1))]
                [foobar.5 -9223372036854775808])
            (if (let ([bat.4 bat.4]
                      [foo.2 foobar.5]
                      [foo.3 bat.4]
                      [foobar.6 430167017]
                      [foobar.5 bat.4])
                  (!= foobar.5 foo.3))
                (let () foo.2)
                (let ([foo.3 foo.2]
                      [foo.8 foo.2]
                      [foobar.5 foobar.5]
                      [bar.1 bat.4]
                      [bat.4 foo.3])
                  foo.3)))))
(check-by-interp
 '(module (let ([foobar.5 1]
                [foo.4 (let ([ball.2 (if (<= -862930824 -1170986438) -1031457151 1)]
                             [ball.8 (+ -9223372036854775808 0)]
                             [foobar.5 (* -9223372036854775808 0)]
                             [foo.6 (if (= -9223372036854775808 0) -9223372036854775808 1938254050)]
                             [foo.4 -9223372036854775808]
                             [foobar.9 (let ([bat.1 -9223372036854775808]
                                             [foo.6 -9223372036854775808]
                                             [foobar.9 0])
                                         foo.6)])
                         foo.6)]
                [ball.8 (let ([foo.6 460545466]
                              [bat.1 (let ([foo.4 -2033025861]
                                           [foo.0 1]
                                           [ball.2 0]
                                           [bat.1 1])
                                       ball.2)]
                              [foo.0 (if (> -9223372036854775808 -459088038) 0 0)]
                              [foobar.3 (+ 1521054237 935219322)])
                          (+ foo.6 bat.1))]
                [foo.6 1]
                [bat.1 1]
                [foo.0 (* -1391596256 218423145)])
            (let ([foo.4 (+ foo.6 ball.8)]
                  [foobar.3 foo.6]
                  [ball.8 (if (<= bat.1 foo.4) foo.4 foobar.5)]
                  [foo.0 foo.6])
              (let ([ball.2 bat.1]
                    [bat.1 foobar.5]
                    [foobar.5 foobar.5]
                    [foo.0 foobar.5]
                    [foobar.3 foobar.5])
                foobar.5)))))
(check-by-interp
 '(module
   (let ([ball.0 (if (true)
                     0
                     (let ([foobar.7 1]
                           [foobar.6
                            (if (> -1818434681 -9223372036854775808) -9223372036854775808 -135823380)]
                           [ball.1 (if (> -1637731979 -1799338585) 1283775776 0)]
                           [bat.4 -722132158]
                           [ball.0 (if (>= -2054485579 1) 0 -153435165)]
                           [foobar.5 (if (> 1 -2075859550) 2146470798 1)])
                       (* ball.0 ball.0)))]
         [foobar.6 (let ([bat.4 (if (true)
                                    (if (= -9223372036854775808 0) -1162069113 -9223372036854775808)
                                    (if (< 0 -362354188) 1 0))]
                         [foobar.5 (let ([ball.8 (let ([ball.8 1]
                                                       [ball.9 0]
                                                       [ball.1 172724818]
                                                       [foobar.6 1]
                                                       [bar.2 -9223372036854775808]
                                                       [ball.0 0])
                                                   ball.1)])
                                     (if (<= 0 ball.8) ball.8 -9223372036854775808))]
                         [foobar.7 (if (true)
                                       (+ 1 0)
                                       (if (<= 0 1) 1030684098 -9223372036854775808))]
                         [bat.3 869914910]
                         [ball.9 (* -1692076239 -9223372036854775808)])
                     (* bat.4 foobar.5))])
     (let ()
       (let ([foobar.5 (if (> foobar.6 ball.0) 0 ball.0)])
         (let ([ball.0 0]
               [foobar.7 ball.0])
           foobar.7))))))
;;; Added by Trevor on 2026-03-17
