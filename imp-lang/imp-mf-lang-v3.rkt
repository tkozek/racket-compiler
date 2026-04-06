#lang racket

(require cpsc411/compiler-lib
         "util.rkt")

(provide normalize-bind)

;; (Imp-mf-lang-v3 effect) -> (Imp-cmf-lang-v3 effect)
(define (normalize-effect effect)
  (match effect
    [`(set! ,aloc
            (begin
              ,effects ...
              ,value))
     `(begin
        ,@(map normalize-effect effects)
        (set! ,aloc ,(normalize-value value)))]
    [`(set! ,aloc ,value) `(set! ,aloc ,(normalize-value value))]
    [`(begin
        ,effects ...
        ,effect2)
     `(begin
        ,@(map normalize-effect effects)
        ,(normalize-effect effect2))]))

;; (Imp-mf-lang-v3 value) -> (Imp-cmf-lang-v3 value)
(define (normalize-value value)
  (match value
    [(? triv?) value]
    [`(,op ,triv1 ,triv2)
     (if (and (binop? op) (triv? triv1) (triv? triv2))
         value
         (error (format "Expected a value, got: ~a" value)))]
    [`(begin
        ,effects ...
        ,body)
     `(begin
        ,@(map normalize-effect effects)
        ,(normalize-value body))]))

;; (Imp-mf-lang-v3 tail) -> (Imp-cmf-lang-v3 tail)
(define (normalize-tail tail)
  (match tail
    [(? triv?) (normalize-value tail)]
    [`(,op ,triv1 ,triv2) (normalize-value tail)]
    [`(begin
        ,effects ...
        ,body)
     `(begin
        ,@(map normalize-effect effects)
        ,(normalize-tail body))]))

;; (imp-mf-lang-v3 p) -> (imp-cmf-lang-v3 p)
;; Pushes 'set!' under 'begin' so that RHS of each 'set!' is a simple value producing operation
(define (normalize-bind p)
  (match p
    [`(module ,tail) `(module ,(normalize-tail tail))]))

(module+ test
  (require rackunit
           cpsc411/langs/v3)
  (define-syntax-rule (check-by-interp p)
    (check-equal? (interp-imp-mf-lang-v3 p) (interp-imp-cmf-lang-v3 (normalize-bind p))))

  ;; Added March 8th, 2026
  (check-by-interp '(module 0))
  (check-by-interp '(module 1672362778))
  (check-by-interp '(module (let () (* 1 0))))
  (check-by-interp '(begin
                      (set! rax 1672362778)))
  (check-by-interp '(module (+ 9223372036854775807 0)))
  (check-by-interp '(module (begin
                              -9223372036854775808)))
  (check-by-interp '(module (+ -379276448 -9223372036854775808)))
  (check-by-interp '(begin
                      (set! fv0 9223372036854775807)
                      (halt fv0)))
  (check-by-interp '(begin
                      (set! fv1 -1622353956)
                      (set! fv0 1)
                      (halt 1)))
  (check-by-interp '(module (begin
                              (set! foo.4.1 9223372036854775807)
                              foo.4.1)))
  (check-by-interp '(module (begin
                              (set! bat.7.1 1843505587)
                              (* bat.7.1 bat.7.1))))
  (check-by-interp '(begin
                      (set! fv0 3)
                      (set! fv0 (* fv0 1))
                      (set! fv1 fv0)
                      (halt fv1)))
  (check-by-interp '(module ()
                            (begin
                              (set! bar.7.1 9223372036854775807)
                              (halt bar.7.1))
                      ))
  (check-by-interp '(begin
                      (set! (rbp - 8) -1259911970)
                      (set! (rbp - 0) -994523723)
                      (set! rax 0)))
  (check-by-interp '(begin
                      (set! r10 9223372036854775807)
                      (set! (rbp - 0) r10)
                      (set! rax (rbp - 0))))
  (check-by-interp '(module (let ([bar.4.1 9223372036854775807])
                              (let ([foobar.0.2 (* 1 bar.4.1)]) bar.4.1))))
  (check-by-interp '(begin
                      (set! fv0 -9223372036854775808)
                      (set! fv0 (+ fv0 0))
                      (set! fv1 fv0)
                      (halt fv1)))
  (check-by-interp '(begin
                      (set! fv0 -379276448)
                      (set! fv0 (+ fv0 -9223372036854775808))
                      (set! fv1 fv0)
                      (halt fv1)))
  (check-by-interp '(module (begin
                              (set! bar.4.1 9223372036854775807)
                              (begin
                                (set! foobar.0.2 (* 1 bar.4.1))
                                bar.4.1))))
  (check-by-interp '(module ()
                            (begin
                              (set! tmp.2 3)
                              (set! tmp.2 (* tmp.2 1))
                              (set! tmp.1 tmp.2)
                              (halt tmp.1))
                      ))
  (check-by-interp '(module ()
                            (begin
                              (set! ball.5.2 -1583518893)
                              (set! foobar.2.1 9223372036854775807)
                              (halt ball.5.2))
                      ))
  (check-by-interp '(module (begin
                              (set! bat.7.3 1)
                              (set! bat.6.2 229035576)
                              (set! bar.0.1 -9223372036854775808)
                              -840991502)))
  (check-by-interp '(module ()
                            (begin
                              (set! ball.6.2 -9223372036854775808)
                              (set! foobar.3.1 -9223372036854775808)
                              (halt 1828326672))
                      ))
  (check-by-interp '(module (let ([bar.8.1 (* 0 0)])
                              (let ([foobar.1.3 -9223372036854775808]
                                    [ball.4.2 (* bar.8.1 bar.8.1)])
                                (let () bar.8.1)))))
  (check-by-interp '(module (let ([bat.7 -9223372036854775808]
                                  [bar.0 (+ 9223372036854775807 1)])
                              (let ([ball.9 bar.0]
                                    [foo.8 bat.7]
                                    [foo.1 1])
                                815346391))))
  (check-by-interp '(begin
                      (set! r10 -9223372036854775808)
                      (set! (rbp - 8) r10)
                      (set! r10 -9223372036854775808)
                      (set! (rbp - 0) r10)
                      (set! rax 1828326672)))
  (check-by-interp '(module (let ([foobar.0 (* 9223372036854775807 1)]
                                  [ball.7 9223372036854775807])
                              (let ([bat.3 9223372036854775807])
                                (let ([foobar.0 -899475693]) bat.3)))))
  (check-by-interp '(module (begin
                              (set! bar.8.1 (* 0 0))
                              (begin
                                (set! foobar.1.3 -9223372036854775808)
                                (set! ball.4.2 (* bar.8.1 bar.8.1))
                                (begin
                                  bar.8.1)))))
  (check-by-interp '(begin
                      (set! fv4 133037836)
                      (set! r10 9223372036854775807)
                      (set! fv3 r10)
                      (set! fv2 2124072059)
                      (set! fv1 503802092)
                      (set! fv0 -1338020867)
                      (set! rax 1)))
  (check-by-interp '(begin
                      (set! fv4 9223372036854775807)
                      (set! fv4 (* fv4 0))
                      (set! fv3 fv4)
                      (set! fv2 0)
                      (set! fv1 0)
                      (set! fv1 (* fv1 1))
                      (set! fv0 fv1)
                      (halt 1126078786)))
  (check-by-interp '(begin
                      (set! r10 -9223372036854775808)
                      (set! fv0 r10)
                      (set! r10 fv0)
                      (set! r10 (* r10 -1879219934))
                      (set! fv0 r10)
                      (set! r10 fv0)
                      (set! fv1 r10)
                      (set! rax fv1)))
  (check-by-interp '(begin
                      (set! fv3 9223372036854775807)
                      (set! fv3 (* fv3 1))
                      (set! fv2 fv3)
                      (set! fv1 9223372036854775807)
                      (set! fv4 9223372036854775807)
                      (set! fv0 -899475693)
                      (halt fv4)))
  (check-by-interp '(module (begin
                              (set! bar.9.3 (+ -1632076199 0))
                              (set! ball.0.2 0)
                              (set! foo.2.1 (+ 1961579359 -1377521797))
                              (begin
                                (set! foo.2.4 bar.9.3)
                                (begin
                                  (set! foobar.1.5 1)
                                  foo.2.4)))))
  (check-by-interp '(begin
                      (set! (rbp - 32) 133037836)
                      (set! r10 9223372036854775807)
                      (set! (rbp - 24) r10)
                      (set! (rbp - 16) 2124072059)
                      (set! (rbp - 8) 503802092)
                      (set! (rbp - 0) -1338020867)
                      (set! rax 1)))
  (check-by-interp '(module (begin
                              (set! bar.5.2 133037836)
                              (set! bat.0.1 9223372036854775807)
                              (begin
                                (set! bar.5.5 2124072059)
                                (set! foobar.7.4 503802092)
                                (set! bat.0.3 -1338020867)
                                1))))
  (check-by-interp '(begin
                      (set! (rbp - 0) -379276448)
                      (set! r10 (rbp - 0))
                      (set! r11 -9223372036854775808)
                      (set! r10 (+ r10 r11))
                      (set! (rbp - 0) r10)
                      (set! r10 (rbp - 0))
                      (set! (rbp - 8) r10)
                      (set! rax (rbp - 8))))
  (check-by-interp '(begin
                      (set! fv5 1)
                      (set! fv4 9223372036854775807)
                      (set! fv3 1)
                      (set! fv3 (+ fv3 -9223372036854775808))
                      (set! fv6 fv3)
                      (set! fv2 fv4)
                      (set! fv2 (+ fv2 fv4))
                      (set! fv1 fv2)
                      (set! fv0 fv6)
                      (halt fv6)))
  (check-by-interp '(begin
                      (set! r10 9223372036854775807)
                      (set! (rbp - 16) r10)
                      (set! (rbp - 8) 1)
                      (set! r10 (rbp - 8))
                      (set! r10 (* r10 (rbp - 16)))
                      (set! (rbp - 8) r10)
                      (set! r10 (rbp - 8))
                      (set! (rbp - 0) r10)
                      (set! rax (rbp - 16))))
  (check-by-interp '(module ()
                            (begin
                              (set! tmp.5 9223372036854775807)
                              (set! tmp.5 (* tmp.5 1))
                              (set! foobar.0.2 tmp.5)
                              (set! ball.7.1 9223372036854775807)
                              (set! bat.3.3 9223372036854775807)
                              (set! foobar.0.4 -899475693)
                              (halt bat.3.3))
                      ))
  (check-by-interp '(module (begin
                              (set! ball.7.3 (* 2135631036 1404162073))
                              (set! bar.1.2 0)
                              (set! ball.2.1 654756935)
                              (begin
                                (set! ball.7.5 (+ bar.1.2 9223372036854775807))
                                (set! bar.3.4 245737528)
                                (begin
                                  (set! ball.2.6 bar.1.2)
                                  ball.2.6)))))
  (check-by-interp '(module (begin
                              (begin
                                (begin
                                  (begin
                                    (set! foobar.8.5 -9223372036854775808)
                                    (set! foobar.6.4 9223372036854775807)
                                    (set! ball.0.3 foobar.8.5))
                                  (set! foo.9.2 (+ ball.0.3 513005733))))
                              (set! bar.1.1 90426798)
                              foo.9.2)))
  (check-by-interp '(begin
                      (set! (rbp - 40) 0)
                      (set! (rbp - 32) 430633110)
                      (set! r10 -9223372036854775808)
                      (set! (rbp - 24) r10)
                      (set! r10 (rbp - 24))
                      (set! (rbp - 16) r10)
                      (set! r10 9223372036854775807)
                      (set! (rbp - 8) r10)
                      (set! r10 (rbp - 16))
                      (set! (rbp - 0) r10)
                      (set! rax -1211501460)))
  (check-by-interp '(module ()
                            (begin
                              (set! tmp.8 0)
                              (set! tmp.8 (+ tmp.8 -996315978))
                              (set! foobar.6.1 tmp.8)
                              (set! bar.3.7 -9223372036854775808)
                              (set! foobar.7.6 190399644)
                              (set! bat.1.5 1)
                              (set! foo.4.4 foobar.6.1)
                              (set! ball.8.3 0)
                              (set! foobar.6.2 foobar.6.1)
                              (halt ball.8.3))
                      ))
  (check-by-interp '(begin
                      (set! r10 -9223372036854775808)
                      (set! fv4 r10)
                      (set! r10 9223372036854775807)
                      (set! fv3 r10)
                      (set! r10 fv4)
                      (set! fv2 r10)
                      (set! r10 fv2)
                      (set! fv1 r10)
                      (set! r10 fv1)
                      (set! r10 (+ r10 513005733))
                      (set! fv1 r10)
                      (set! r10 fv1)
                      (set! fv5 r10)
                      (set! fv0 90426798)
                      (set! rax fv5)))
  (check-by-interp '(module ()
                            (begin
                              (set! tmp.7 2135631036)
                              (set! tmp.7 (* tmp.7 1404162073))
                              (set! ball.7.3 tmp.7)
                              (set! bar.1.2 0)
                              (set! ball.2.1 654756935)
                              (set! tmp.8 bar.1.2)
                              (set! tmp.8 (+ tmp.8 9223372036854775807))
                              (set! ball.7.5 tmp.8)
                              (set! bar.3.4 245737528)
                              (set! ball.2.6 bar.1.2)
                              (halt ball.2.6))
                      ))
  (check-by-interp '(begin
                      (set! fv5 966813755)
                      (set! r10 fv5)
                      (set! r10 (+ r10 -1365911686))
                      (set! fv5 r10)
                      (set! r10 fv5)
                      (set! fv4 r10)
                      (set! r10 -9223372036854775808)
                      (set! fv3 r10)
                      (set! r10 fv3)
                      (set! fv2 r10)
                      (set! r10 fv2)
                      (set! r10 (+ r10 1))
                      (set! fv2 r10)
                      (set! r10 fv2)
                      (set! fv1 r10)
                      (set! r10 fv3)
                      (set! fv0 r10)
                      (set! rax 1)))
  (check-by-interp '(begin
                      (set! r10 -9223372036854775808)
                      (set! (rbp - 40) r10)
                      (set! r10 9223372036854775807)
                      (set! (rbp - 32) r10)
                      (set! r10 (rbp - 32))
                      (set! r10 (+ r10 1))
                      (set! (rbp - 32) r10)
                      (set! r10 (rbp - 32))
                      (set! (rbp - 24) r10)
                      (set! r10 (rbp - 24))
                      (set! (rbp - 16) r10)
                      (set! r10 (rbp - 40))
                      (set! (rbp - 8) r10)
                      (set! (rbp - 0) 1)
                      (set! rax 815346391)))
  (check-by-interp '(begin
                      (set! (rbp - 48) 0)
                      (set! r10 (rbp - 48))
                      (set! r10 (+ r10 -996315978))
                      (set! (rbp - 48) r10)
                      (set! r10 (rbp - 48))
                      (set! (rbp - 40) r10)
                      (set! r10 -9223372036854775808)
                      (set! (rbp - 32) r10)
                      (set! (rbp - 24) 190399644)
                      (set! (rbp - 16) 1)
                      (set! r10 (rbp - 40))
                      (set! (rbp - 8) r10)
                      (set! (rbp - 56) 0)
                      (set! r10 (rbp - 40))
                      (set! (rbp - 0) r10)
                      (set! rax (rbp - 56))))
  (check-by-interp '(module ()
                            (begin
                              (set! tmp.10 1)
                              (set! tmp.10 (* tmp.10 9223372036854775807))
                              (set! bar.3.2 tmp.10)
                              (set! foobar.0.1 -455579519)
                              (set! tmp.11 foobar.0.1)
                              (set! tmp.11 (+ tmp.11 0))
                              (set! foo.6.4 tmp.11)
                              (set! bat.4.6 1)
                              (set! bat.8.5 -9223372036854775808)
                              (set! bar.9.3 foobar.0.1)
                              (set! bar.9.9 0)
                              (set! foo.6.8 -9223372036854775808)
                              (set! bat.4.7 1)
                              (halt -35514184))
                      ))
  (check-by-interp '(module (begin
                              (set! foo.9.2 (* -1154104701 9223372036854775807))
                              (begin
                                (set! ball.1.3 (+ 9223372036854775807 -1520906171))
                                (set! ball.1.1 (* ball.1.3 ball.1.3)))
                              (begin
                                (set! foobar.4.5 (+ -9223372036854775808 9223372036854775807))
                                (begin
                                  (set! foo.5.8 -711901302)
                                  (set! ball.2.7 foo.9.2)
                                  (set! foobar.6.6 1)
                                  (set! bat.7.4 -9223372036854775808))
                                (+ -832221090 1952403775)))))
  (check-by-interp '(module (begin
                              (set! bat.6.3 -9223372036854775808)
                              (begin
                                (set! bat.0.5 (* -1022035607 1))
                                (set! foo.8.4 1)
                                (set! bat.1.2 9223372036854775807))
                              (begin
                                (set! bat.0.8 1070959615)
                                (set! foo.2.7 9223372036854775807)
                                (set! bar.3.6 (+ 2075026749 -9223372036854775808))
                                (set! bar.9.1 9223372036854775807))
                              (begin
                                (begin
                                  (set! bar.3.9 (+ bat.6.3 0))
                                  (begin
                                    (set! bat.1.10 bar.9.1)
                                    -9223372036854775808))))))
  (check-by-interp '(begin
                      (set! (rbp - 56) 1)
                      (set! r10 9223372036854775807)
                      (set! (rbp - 48) r10)
                      (set! r10 (rbp - 48))
                      (set! r10 (* r10 1))
                      (set! (rbp - 48) r10)
                      (set! r10 (rbp - 48))
                      (set! (rbp - 40) r10)
                      (set! (rbp - 32) 92301689)
                      (set! (rbp - 24) 2017243593)
                      (set! r10 9223372036854775807)
                      (set! (rbp - 16) r10)
                      (set! (rbp - 8) -1476120972)
                      (set! (rbp - 0) 0)
                      (set! r10 (rbp - 0))
                      (set! r10 (* r10 1))
                      (set! (rbp - 0) r10)
                      (set! r10 (rbp - 0))
                      (set! (rbp - 64) r10)
                      (set! rax (rbp - 64))))
  (check-by-interp '(module (begin
                              (begin
                                (set! bar.2.3 1)
                                (begin
                                  (set! bar.3.6 118010454)
                                  (set! bar.2.5 1)
                                  (set! bat.9.4 -9223372036854775808)
                                  (set! bat.1.2 bar.2.5))
                                (begin
                                  (set! bat.9.8 bar.2.3)
                                  (set! bat.1.7 bar.2.3)
                                  (set! bar.3.1 -9223372036854775808)))
                              (begin
                                (set! bat.9.11 (* bar.3.1 bar.3.1))
                                (set! bar.3.10 (+ -1846872043 bar.3.1))
                                (begin
                                  (set! bar.5.13 0)
                                  (set! bar.3.12 bar.3.1)
                                  (set! bar.5.9 -9223372036854775808))
                                (begin
                                  (set! bat.9.14 bat.9.11)
                                  1)))))
  (check-by-interp '(begin
                      (set! (rbp - 80) 1)
                      (set! r10 (rbp - 80))
                      (set! r11 9223372036854775807)
                      (set! r10 (* r10 r11))
                      (set! (rbp - 80) r10)
                      (set! r10 (rbp - 80))
                      (set! (rbp - 72) r10)
                      (set! (rbp - 64) -455579519)
                      (set! r10 (rbp - 64))
                      (set! (rbp - 56) r10)
                      (set! r10 (rbp - 56))
                      (set! r10 (+ r10 0))
                      (set! (rbp - 56) r10)
                      (set! r10 (rbp - 56))
                      (set! (rbp - 48) r10)
                      (set! (rbp - 40) 1)
                      (set! r10 -9223372036854775808)
                      (set! (rbp - 32) r10)
                      (set! r10 (rbp - 64))
                      (set! (rbp - 24) r10)
                      (set! (rbp - 16) 0)
                      (set! r10 -9223372036854775808)
                      (set! (rbp - 8) r10)
                      (set! (rbp - 0) 1)
                      (set! rax -35514184)))
  (check-by-interp '(begin
                      (set! r10 9223372036854775807)
                      (set! (rbp - 72) r10)
                      (set! (rbp - 64) 823385985)
                      (set! r10 (rbp - 64))
                      (set! r10 (+ r10 (rbp - 72)))
                      (set! (rbp - 64) r10)
                      (set! r10 (rbp - 64))
                      (set! (rbp - 56) r10)
                      (set! r10 9223372036854775807)
                      (set! (rbp - 48) r10)
                      (set! r10 -9223372036854775808)
                      (set! (rbp - 40) r10)
                      (set! (rbp - 32) 1)
                      (set! r10 9223372036854775807)
                      (set! (rbp - 24) r10)
                      (set! r10 (rbp - 24))
                      (set! r10 (+ r10 0))
                      (set! (rbp - 24) r10)
                      (set! r10 (rbp - 24))
                      (set! (rbp - 16) r10)
                      (set! (rbp - 8) -1226663776)
                      (set! r10 (rbp - 8))
                      (set! (rbp - 0) r10)
                      (set! r10 (rbp - 0))
                      (set! r10 (* r10 (rbp - 8)))
                      (set! (rbp - 0) r10)
                      (set! r10 (rbp - 0))
                      (set! (rbp - 80) r10)
                      (set! rax (rbp - 80))))
  (check-by-interp '(begin
                      (set! (rbp - 120) 1)
                      (set! (rbp - 112) 118010454)
                      (set! (rbp - 104) 1)
                      (set! r10 -9223372036854775808)
                      (set! (rbp - 96) r10)
                      (set! r10 (rbp - 104))
                      (set! (rbp - 88) r10)
                      (set! r10 (rbp - 120))
                      (set! (rbp - 80) r10)
                      (set! r10 (rbp - 120))
                      (set! (rbp - 72) r10)
                      (set! r10 -9223372036854775808)
                      (set! (rbp - 64) r10)
                      (set! r10 (rbp - 64))
                      (set! (rbp - 56) r10)
                      (set! r10 (rbp - 56))
                      (set! r10 (* r10 (rbp - 64)))
                      (set! (rbp - 56) r10)
                      (set! r10 (rbp - 56))
                      (set! (rbp - 48) r10)
                      (set! (rbp - 40) -1846872043)
                      (set! r10 (rbp - 40))
                      (set! r10 (+ r10 (rbp - 64)))
                      (set! (rbp - 40) r10)
                      (set! r10 (rbp - 40))
                      (set! (rbp - 32) r10)
                      (set! (rbp - 24) 0)
                      (set! r10 (rbp - 64))
                      (set! (rbp - 16) r10)
                      (set! r10 -9223372036854775808)
                      (set! (rbp - 8) r10)
                      (set! r10 (rbp - 48))
                      (set! (rbp - 0) r10)
                      (set! rax 1)))
  (check-by-interp '(module (begin
                              (begin
                                (set! bar.6.3 0)
                                (set! foo.4.2 9223372036854775807)
                                (begin
                                  (set! foo.1.6 (* 1617024596 9223372036854775807))
                                  (set! bar.2.5 (* bar.6.3 foo.4.2))
                                  (set! foobar.0.4 (+ bar.6.3 bar.6.3))
                                  (set! bar.8.1 foobar.0.4)))
                              (begin
                                (begin
                                  (set! bar.3.12 -1114020630)
                                  (begin
                                    (set! foo.1.14 -2080084613)
                                    (set! bar.8.13 -9223372036854775808)
                                    (set! foo.1.11 -1656687642))
                                  (begin
                                    (set! foo.1.17 bar.8.1)
                                    (set! bat.5.16 1909787064)
                                    (set! foo.9.15 bar.8.1)
                                    (set! bar.8.10 bat.5.16))
                                  (set! foo.9.9 bar.3.12))
                                (begin
                                  (set! bar.3.8 (* bar.8.1 9223372036854775807)))
                                (set! foo.1.7 (* -9223372036854775808 bar.8.1))
                                (begin
                                  (set! foo.9.19 bar.3.8)
                                  (begin
                                    (set! foo.9.22 748728232)
                                    (set! bar.3.21 foo.9.9)
                                    (set! bar.8.20 foo.9.9)
                                    (set! bar.6.18 9223372036854775807))
                                  (* 1423178087 0))))))
  (check-by-interp '(module ()
                            (begin
                              (set! ball.0.8 -9223372036854775808)
                              (set! ball.1.7 9223372036854775807)
                              (set! foobar.9.6 9223372036854775807)
                              (set! ball.1.10 0)
                              (set! foobar.4.9 0)
                              (set! ball.0.5 276890345)
                              (set! tmp.25 1421159570)
                              (set! tmp.25 (* tmp.25 0))
                              (set! foo.6.4 tmp.25)
                              (set! tmp.26 -1075619650)
                              (set! tmp.26 (* tmp.26 9223372036854775807))
                              (set! ball.0.3 tmp.26)
                              (set! foo.2.12 9223372036854775807)
                              (set! tmp.27 451680725)
                              (set! tmp.27 (+ tmp.27 751914030))
                              (set! ball.1.11 tmp.27)
                              (set! foobar.4.2 ball.1.11)
                              (set! tmp.28 -1362757702)
                              (set! tmp.28 (* tmp.28 738148732))
                              (set! foobar.9.15 tmp.28)
                              (set! foobar.8.17 -9223372036854775808)
                              (set! foobar.4.16 -1049804848)
                              (set! foobar.7.14 foobar.4.16)
                              (set! ball.1.19 0)
                              (set! foobar.7.18 -353965291)
                              (set! foo.6.13 foobar.7.18)
                              (set! foobar.9.21 0)
                              (set! foobar.3.20 -9223372036854775808)
                              (set! foo.6.1 1)
                              (set! ball.0.24 foobar.4.2)
                              (set! foobar.4.23 foo.6.1)
                              (set! foobar.9.22 0)
                              (set! tmp.30 foobar.9.22)
                              (set! tmp.30 (+ tmp.30 -9223372036854775808))
                              (set! tmp.29 tmp.30)
                              (halt tmp.29))
                      ))
  (check-by-interp '(module (begin
                              (set! foo.2.2
                                    (begin
                                      (set! ball.7.5 (+ -1819252534 0))
                                      (set! foo.2.4 (+ 0 0))
                                      (set! foobar.8.3
                                            (begin
                                              (set! bar.1.7 1)
                                              (set! foo.2.6 (+ 1 1878805388))
                                              (+ foo.2.6 bar.1.7)))
                                      ball.7.5))
                              (set! bar.4.1
                                    (begin
                                      (set! bar.5.10
                                            (begin
                                              (set! foobar.8.13
                                                    (begin
                                                      (set! bar.4.15 9223372036854775807)
                                                      (set! bar.3.14 9223372036854775807)
                                                      bar.4.15))
                                              (set! ball.7.12 (* -236700244 9223372036854775807))
                                              (set! bar.3.11
                                                    (begin
                                                      (set! bar.1.18 -162516402)
                                                      (set! bar.4.17 1)
                                                      (set! bar.3.16 -9223372036854775808)
                                                      bar.1.18))
                                              (+ ball.7.12 1)))
                                      (set! bar.9.9 (+ -9223372036854775808 0))
                                      (set! foobar.8.8
                                            (begin
                                              (begin
                                                (set! bar.1.20 -9223372036854775808)
                                                (set! foobar.8.19 9223372036854775807)
                                                -9223372036854775808)))
                                      (begin
                                        (set! foo.2.22 bar.9.9)
                                        (set! bar.3.21 bar.9.9)
                                        (begin
                                          (set! ball.7.25 9223372036854775807)
                                          (set! foo.2.24 1412459164)
                                          (set! bar.4.23 foobar.8.8)
                                          bar.4.23))))
                              (begin
                                (set! bar.3.26 foo.2.2)
                                (begin
                                  (set! foo.2.28 bar.4.1)
                                  (set! bar.3.27 (* foo.2.2 1442357341))
                                  (begin
                                    (set! foobar.8.31 bar.3.27)
                                    (set! bar.4.30 bar.4.1)
                                    (set! bat.6.29 foo.2.28)
                                    -241389399))))))

  ;;

  (check-equal? (normalize-bind '(module 0)) '(module 0))
  (check-equal? (normalize-bind '(module 9223372036854775807)) '(module 9223372036854775807))
  (check-equal? (normalize-bind '(module -9223372036854775808)) '(module -9223372036854775808))
  (check-equal? (normalize-bind '(module (+ 1 2))) '(module (+ 1 2)))
  (check-equal? (normalize-bind '(module (* -2 1))) '(module (* -2 1)))
  (check-equal? (normalize-bind '(module (* 1 9223372036854775807)))
                '(module (* 1 9223372036854775807)))
  (check-equal? (normalize-bind '(module (+ 10 -9223372036854775808)))
                '(module (+ 10 -9223372036854775808)))
  (check-equal? (normalize-bind '(module (begin
                                           (set! x.1 1)
                                           x.1)))
                '(module (begin
                           (set! x.1 1)
                           x.1)))
  (check-equal? (normalize-bind '(module (begin
                                           (set! x.1 2)
                                           (set! x.1 5)
                                           (+ 42 x.1))))
                '(module (begin
                           (set! x.1 2)
                           (set! x.1 5)
                           (+ 42 x.1))))
  (check-equal? (normalize-bind '(module (begin
                                           (set! x.1 (+ 2 4))
                                           (set! x.1 (* 3 3))
                                           (+ 42 x.1))))
                '(module (begin
                           (set! x.1 (+ 2 4))
                           (set! x.1 (* 3 3))
                           (+ 42 x.1))))
  (check-equal? (normalize-bind '(module (begin
                                           (set! x.1 (+ 2 4))
                                           (set! x.2 (* 3 3))
                                           (+ x.2 x.1))))
                '(module (begin
                           (set! x.1 (+ 2 4))
                           (set! x.2 (* 3 3))
                           (+ x.2 x.1))))
  (check-equal? (normalize-bind '(module (begin
                                           (set! x.1 1)
                                           (set! x.2 0)
                                           (* x.2 x.1))))
                '(module (begin
                           (set! x.1 1)
                           (set! x.2 0)
                           (* x.2 x.1))))
  (check-equal? (normalize-bind '(module (begin
                                           (set! x.1 2)
                                           (set! x.1 5)
                                           (+ x.1 x.1))))
                '(module (begin
                           (set! x.1 2)
                           (set! x.1 5)
                           (+ x.1 x.1))))
  (check-equal? (normalize-bind '(module (begin
                                           (set! x.1
                                                 (begin
                                                   ()
                                                   5))
                                           0)))
                '(module (begin
                           (begin
                             (set! x.1 5))
                           0)))
  (check-equal? (normalize-bind '(module (begin
                                           (set! x.1
                                                 (begin
                                                   ()
                                                   5))
                                           x.1)))
                '(module (begin
                           (begin
                             (set! x.1 5))
                           x.1)))
  (check-equal? (normalize-bind '(module (begin
                                           (set! x.1
                                                 (begin
                                                   (set! x.2 5)
                                                   (set! x.1 3)
                                                   1))
                                           2)))
                '(module (begin
                           (begin
                             (set! x.2 5)
                             (set! x.1 3)
                             (set! x.1 1)
                             2))))
  (check-equal? (normalize-bind '(module (begin
                                           (set! x.1
                                                 (begin
                                                   (set! x.2 5)
                                                   (set! x.1 3)
                                                   1))
                                           (+ x.1 x.2))))
                '(module (begin
                           (begin
                             (set! x.2 5)
                             (set! x.1 3)
                             (set! x.1 1)
                             (+ x.1 x.2)))))
  (check-equal? (normalize-bind '(module (begin
                                           (set! x.1
                                                 (begin
                                                   (set! x.2 5)
                                                   (set! x.1 3)
                                                   (+ x.2 x.1)))
                                           (+ x.1 x.2))))
                '(module (begin
                           (begin
                             (set! x.2 5)
                             (set! x.1 3)
                             (set! x.1 (+ x.2 x.1))
                             (+ x.1 x.2)))))
  (check-equal? (normalize-bind '(module (begin
                                           (set! x.1
                                                 (begin
                                                   (set! x.2 5)
                                                   (set! x.1 3)
                                                   (* x.2 x.1)))
                                           (+ x.1 x.2))))
                '(module (begin
                           (begin
                             (set! x.2 5)
                             (set! x.1 3)
                             (set! x.1 (* x.2 x.1))
                             (+ x.1 x.2)))))
  (check-equal? (normalize-bind '(module (begin
                                           (set! x.1
                                                 (begin
                                                   (set! x.2 5)
                                                   (set! x.1 3)
                                                   (* x.2 x.1)))
                                           (* 5 x.2))))
                '(module (begin
                           (begin
                             (set! x.2 5)
                             (set! x.1 3)
                             (set! x.1 (* x.2 x.1))
                             (* 5 x.2)))))
  (check-equal? (normalize-bind '(module (begin
                                           (set! x.1
                                                 (begin
                                                   (set! x.2 5)
                                                   (set! x.1 3)
                                                   (+ x.2 x.1)))
                                           (* 5 x.2))))
                '(module (begin
                           (begin
                             (set! x.2 5)
                             (set! x.1 3)
                             (set! x.1 (+ x.2 x.1))
                             (* 5 x.2)))))
  (check-equal? (normalize-bind '(module (begin
                                           (set! x.1 2)
                                           (set! x.2 3)
                                           (begin
                                             (set! x.1 3)
                                             (set! x.2 1)
                                             1))))
                '(module (begin
                           (set! x.1 2)
                           (set! x.2 3)
                           (begin
                             (set! x.1 3)
                             (set! x.2 1)
                             1))))
  (check-equal? (normalize-bind '(module (begin
                                           (set! x.1 2)
                                           (set! x.2 3)
                                           (begin
                                             (set! x.1 3)
                                             (set! x.2 1)
                                             (+ x.1 x.2)))))
                '(module (begin
                           (set! x.1 2)
                           (set! x.2 3)
                           (begin
                             (set! x.1 3)
                             (set! x.2 1)
                             (+ x.1 x.2)))))
  (check-equal? (normalize-bind '(module (begin
                                           (set! x.1 2)
                                           (set! x.2 3)
                                           (begin
                                             (set! x.1 3)
                                             (set! x.2
                                                   (begin
                                                     4))
                                             (+ x.1 x.2)))))
                '(module (begin
                           (set! x.1 2)
                           (set! x.2 3)
                           (begin
                             (set! x.1 3)
                             (begin
                               (set! x.2 4))
                             (+ x.1 x.2)))))

  (check-equal? (normalize-bind '(module (begin
                                           (set! x.1 2)
                                           (set! x.2 3)
                                           (begin
                                             (set! x.1 3)
                                             (set! x.2
                                                   (begin
                                                     (set! x.1 4)
                                                     (set! x.1 0)
                                                     (+ x.1 x.1))))
                                           (+ x.1 x.2))))
                '(module (begin
                           (set! x.1 2)
                           (set! x.2 3)
                           (begin
                             (set! x.1 3)
                             (begin
                               (set! x.1 4)
                               (set! x.1 0)
                               (set! x.2 (+ x.1 x.1)))
                             (+ x.1 x.2))))))
