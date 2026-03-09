#lang racket

(require cpsc411/compiler-lib)

(provide implement-fvars)

;  p	 	::=	 	(begin s ...)
;   s	 	::=	 	(set! fvar int32)
;  	 	|	 	(set! fvar reg)
;  	 	|	 	(set! reg loc)
;  	 	|	 	(set! reg triv)
;  	 	|	 	(set! reg_1 (binop reg_1 int32))
;  	 	|	 	(set! reg_1 (binop reg_1 loc))
;   triv	 	::=	 	reg  | 	int64

;   loc	 	::=	 	reg | fvar
;   reg	 	::=	 	rsp
;  	 	|	 	rbp
;  	 	|	 	rax
;  	 	|	 	rbx
;  	 	|	 	rcx
;  	 	|	 	rdx
;  	 	|	 	rsi
;  	 	|	 	rdi
;  	 	|	 	r8
;  	 	|	 	r9
;  	 	|	 	r10
;  	 	|	 	r11
;  	 	|	 	r12
;  	 	|	 	r13
;  	 	|	 	r14
;  	 	|	 	r15
;   binop	 	::=	 	* |	+
;   int64	 	::=	 	int64?
;   int32	 	::=	 	int32?
;   fvar	 	::=	 	fvar?

;; (paren-x64-fvars-v2) -> (paren-x64-v2)
;; Reifies fvars into displacement mode operands
(define (implement-fvars p)
  ;; (paren-x64-fvars-v2 fvar) -> (paren-x64-v2 addr)
  ;; converts an fvar into an address
  (define (implement-fvar fvar)
    `(,(current-frame-base-pointer-register) - ,(* 8 (fvar->index fvar))))

  (define (implement-s s)
    (match s
      [`(set! ,(? fvar? fvar) ,rest) `(set! ,(implement-fvar fvar) ,rest)]
      [`(set! ,reg1 (,binop ,reg1 ,(? fvar? fvar)))
       `(set! ,reg1 (,binop ,reg1 ,(implement-fvar fvar)))]
      [`(set! ,reg (? fvar? fvar)) `(set! ,reg ,(implement-fvar fvar))]
      [_ s]))

  (define (implement-p)
    (match p
      [`(begin
          ,s ...)
       `(begin
          ,@(map implement-s s))]))
  (implement-p p))

(module+ test
  (require rackunit
           cpsc411/langs/v2
           cpsc411/langs/v3)
  (define-syntax-rule (check-by-interp p)
    (check-equal? (interp-paren-x64-fvars-v2 p) (interp-paren-x64-v2 (uniquify p))))

  ;; Added March 8th, 2026
  (check-by-interp '(module (* 3 1)))
  (check-by-interp '(begin
                      (set! rax 0)))
  (check-by-interp '(module (+ 1 -1637029370)))
  (check-by-interp '(module (* 9223372036854775807 0)))
  (check-by-interp '(module (+ -9223372036854775808 0)))
  (check-by-interp '(begin
                      (set! rax -9223372036854775808)))
  (check-by-interp '(module (* -9223372036854775808 -1879219934)))
  (check-by-interp '(module (let ([bar.7 9223372036854775807]) bar.7)))
  (check-by-interp '(begin
                      (set! fv1 -1622353956)
                      (set! fv0 1)
                      (set! rax 1)))
  (check-by-interp '(begin
                      (set! fv1 -1259911970)
                      (set! fv0 -994523723)
                      (halt 0)))
  (check-by-interp '(module (begin
                              (set! foobar.4.1 828152543)
                              9223372036854775807)))
  (check-by-interp '(begin
                      (set! (rbp - 8) -1622353956)
                      (set! (rbp - 0) 1)
                      (set! rax 1)))
  (check-by-interp '(begin
                      (set! fv1 -1583518893)
                      (set! fv0 9223372036854775807)
                      (halt fv1)))
  (check-by-interp '(module ()
                            (begin
                              (set! bar.0.2 -1259911970)
                              (set! ball.2.1 -994523723)
                              (halt 0))
                      ))
  (check-by-interp '(module (let ()
                              (let ([ball.5 -1583518893]
                                    [foobar.2 9223372036854775807])
                                ball.5))))
  (check-by-interp '(begin
                      (set! fv0 9223372036854775807)
                      (set! fv0 (+ fv0 0))
                      (set! fv1 fv0)
                      (halt fv1)))
  (check-by-interp '(begin
                      (set! fv1 77841184)
                      (set! fv0 -9223372036854775808)
                      (set! fv2 699352919)
                      (halt fv2)))
  (check-by-interp '(begin
                      (set! fv1 1843505587)
                      (set! fv0 fv1)
                      (set! fv0 (* fv0 fv1))
                      (set! fv2 fv0)
                      (halt fv2)))
  (check-by-interp '(module (let ([bat.1 (+ -822533870 9223372036854775807)]
                                  [bar.7 9223372036854775807])
                              (+ bar.7 0))))
  (check-by-interp '(begin
                      (set! (rbp - 8) -1583518893)
                      (set! r10 9223372036854775807)
                      (set! (rbp - 0) r10)
                      (set! rax (rbp - 8))))
  (check-by-interp '(module (let ([bar.8 (* 0 0)])
                              (let ([foobar.1 -9223372036854775808]
                                    [ball.4 (* bar.8 bar.8)])
                                (let () bar.8)))))
  (check-by-interp '(module (let ([ball.1.1 2070989370])
                              (let ([foobar.8.4 ball.1.1]
                                    [bar.0.3 -267352716]
                                    [ball.1.2 ball.1.1])
                                bar.0.3))))
  (check-by-interp '(module ()
                            (begin
                              (set! tmp.2 9223372036854775807)
                              (set! tmp.2 (+ tmp.2 0))
                              (set! tmp.1 tmp.2)
                              (halt tmp.1))
                      ))
  (check-by-interp '(begin
                      (set! fv3 -641168007)
                      (set! fv2 -9223372036854775808)
                      (set! fv1 1)
                      (set! fv0 -921037329)
                      (halt 9223372036854775807)))
  (check-by-interp '(module ()
                            (begin
                              (set! tmp.2 -9223372036854775808)
                              (set! tmp.2 (* tmp.2 -1879219934))
                              (set! tmp.1 tmp.2)
                              (halt tmp.1))
                      ))
  (check-by-interp '(begin
                      (set! fv4 133037836)
                      (set! fv3 9223372036854775807)
                      (set! fv2 2124072059)
                      (set! fv1 503802092)
                      (set! fv0 -1338020867)
                      (halt 1)))
  (check-by-interp '(module (let ([bar.9 (+ -1632076199 0)]
                                  [ball.0 0]
                                  [foo.2 (+ 1961579359 -1377521797)])
                              (let ([foo.2 bar.9]) (let ([foobar.1 1]) foo.2)))))
  (check-by-interp '(begin
                      (set! (rbp - 0) 1)
                      (set! r10 (rbp - 0))
                      (set! r10 (* r10 0))
                      (set! (rbp - 0) r10)
                      (set! r10 (rbp - 0))
                      (set! (rbp - 8) r10)
                      (set! rax (rbp - 8))))
  (check-by-interp '(module (let ([bar.6.3 (let ([ball.7.4 -9223372036854775808]) ball.7.4)]
                                  [foo.9.2 1]
                                  [ball.7.1 (+ -49511605 1)])
                              (let ([ball.7.5 1610221572]) foo.9.2))))
  (check-by-interp '(begin
                      (set! fv4 -9223372036854775808)
                      (set! fv3 fv4)
                      (set! fv5 1)
                      (set! fv2 -49511605)
                      (set! fv2 (+ fv2 1))
                      (set! fv1 fv2)
                      (set! fv0 1610221572)
                      (halt fv5)))
  (check-by-interp '(module (let ([foo.9.3 1]
                                  [bar.1.2 9223372036854775807]
                                  [ball.8.1 (+ 1 -9223372036854775808)])
                              (let ([bar.6.5 (+ bar.1.2 bar.1.2)]
                                    [ball.0.4 ball.8.1])
                                ball.8.1))))
  (check-by-interp '(module (begin
                              (set! foo.3.2 2110471915)
                              (set! bat.0.1 (* 1294488972 0))
                              (begin
                                (set! ball.9.4 1237875503)
                                (set! bat.8.3 -9223372036854775808)
                                bat.8.3))))
  (check-by-interp '(begin
                      (set! fv3 -822533870)
                      (set! fv3 (+ fv3 9223372036854775807))
                      (set! fv2 fv3)
                      (set! fv1 9223372036854775807)
                      (set! fv0 fv1)
                      (set! fv0 (+ fv0 0))
                      (set! fv4 fv0)
                      (halt fv4)))
  (check-by-interp '(begin
                      (set! r10 9223372036854775807)
                      (set! (rbp - 0) r10)
                      (set! r10 (rbp - 0))
                      (set! r10 (+ r10 0))
                      (set! (rbp - 0) r10)
                      (set! r10 (rbp - 0))
                      (set! (rbp - 8) r10)
                      (set! rax (rbp - 8))))
  (check-by-interp '(begin
                      (set! fv6 0)
                      (set! fv6 (+ fv6 -996315978))
                      (set! fv5 fv6)
                      (set! fv4 -9223372036854775808)
                      (set! fv3 190399644)
                      (set! fv2 1)
                      (set! fv1 fv5)
                      (set! fv7 0)
                      (set! fv0 fv5)
                      (halt fv7)))
  (check-by-interp '(module (begin
                              (set! bat.7.2 -9223372036854775808)
                              (set! bar.0.1 (+ 9223372036854775807 1))
                              (begin
                                (set! ball.9.5 bar.0.1)
                                (set! foo.8.4 bat.7.2)
                                (set! foo.1.3 1)
                                815346391))))
  (check-by-interp '(module ()
                            (begin
                              (set! foo.3.2 2110471915)
                              (set! tmp.5 1294488972)
                              (set! tmp.5 (* tmp.5 0))
                              (set! bat.0.1 tmp.5)
                              (set! ball.9.4 1237875503)
                              (set! bat.8.3 -9223372036854775808)
                              (halt bat.8.3))
                      ))
  (check-by-interp '(begin
                      (set! fv5 0)
                      (set! fv4 430633110)
                      (set! r10 -9223372036854775808)
                      (set! fv3 r10)
                      (set! r10 fv3)
                      (set! fv2 r10)
                      (set! r10 9223372036854775807)
                      (set! fv1 r10)
                      (set! r10 fv2)
                      (set! fv0 r10)
                      (set! rax -1211501460)))
  (check-by-interp '(begin
                      (set! fv6 2135631036)
                      (set! fv6 (* fv6 1404162073))
                      (set! fv5 fv6)
                      (set! fv4 0)
                      (set! fv3 654756935)
                      (set! fv2 fv4)
                      (set! fv2 (+ fv2 9223372036854775807))
                      (set! fv1 fv2)
                      (set! fv0 245737528)
                      (set! fv7 fv4)
                      (halt fv7)))
  (check-by-interp '(begin
                      (set! fv7 1)
                      (set! fv6 9223372036854775807)
                      (set! fv6 (* fv6 1))
                      (set! fv5 fv6)
                      (set! fv4 92301689)
                      (set! fv3 2017243593)
                      (set! fv2 9223372036854775807)
                      (set! fv1 -1476120972)
                      (set! fv0 0)
                      (set! fv0 (* fv0 1))
                      (set! fv8 fv0)
                      (halt fv8)))
  (check-by-interp '(module (let ([bar.3.2 (* 1 9223372036854775807)]
                                  [foobar.0.1 -455579519])
                              (let ([foo.6.4 (+ foobar.0.1 0)]
                                    [bar.9.3 (let ([bat.4.6 1]
                                                   [bat.8.5 -9223372036854775808])
                                               foobar.0.1)])
                                (let ([bar.9.9 0]
                                      [foo.6.8 -9223372036854775808]
                                      [bat.4.7 1])
                                  -35514184)))))
  (check-by-interp '(begin
                      (set! fv9 9223372036854775807)
                      (set! fv9 (* fv9 610664654))
                      (set! fv8 fv9)
                      (set! fv7 fv8)
                      (set! fv7 (* fv7 fv8))
                      (set! fv6 fv7)
                      (set! fv5 fv8)
                      (set! fv4 9223372036854775807)
                      (set! fv3 fv8)
                      (set! fv2 fv8)
                      (set! fv1 fv8)
                      (set! fv0 1628045022)
                      (halt -400120723)))
  (check-by-interp '(begin
                      (set! fv3 0)
                      (set! r10 fv3)
                      (set! r10 (* r10 0))
                      (set! fv3 r10)
                      (set! r10 fv3)
                      (set! fv4 r10)
                      (set! r10 -9223372036854775808)
                      (set! fv2 r10)
                      (set! r10 fv4)
                      (set! fv1 r10)
                      (set! r10 fv1)
                      (set! r10 (* r10 fv4))
                      (set! fv1 r10)
                      (set! r10 fv1)
                      (set! fv0 r10)
                      (set! rax fv4)))
  (check-by-interp '(begin
                      (set! fv10 0)
                      (set! fv9 fv10)
                      (set! fv8 fv10)
                      (set! fv7 -200502468)
                      (set! fv6 0)
                      (set! fv5 fv10)
                      (set! fv5 (+ fv5 fv10))
                      (set! fv4 fv5)
                      (set! fv3 1)
                      (set! fv3 (+ fv3 1))
                      (set! fv2 fv3)
                      (set! fv1 fv6)
                      (set! fv0 -9223372036854775808)
                      (set! fv0 (* fv0 -1026632690))
                      (set! fv11 fv0)
                      (halt fv11)))
  (check-by-interp '(module (let ([foobar.8.1 (* 9223372036854775807 610664654)])
                              (let ([ball.2.3 (let ([ball.2.5 (* foobar.8.1 foobar.8.1)]
                                                    [foobar.6.4 (let ([ball.2.6 foobar.8.1])
                                                                  9223372036854775807)])
                                                (let ([bat.0.8 foobar.8.1]
                                                      [ball.2.7 foobar.8.1])
                                                  foobar.8.1))]
                                    [foobar.1.2 1628045022])
                                -400120723))))
  (check-by-interp '(begin
                      (set! r10 9223372036854775807)
                      (set! (rbp - 32) r10)
                      (set! r10 (rbp - 32))
                      (set! r10 (* r10 0))
                      (set! (rbp - 32) r10)
                      (set! r10 (rbp - 32))
                      (set! (rbp - 24) r10)
                      (set! (rbp - 16) 0)
                      (set! (rbp - 8) 0)
                      (set! r10 (rbp - 8))
                      (set! r10 (* r10 1))
                      (set! (rbp - 8) r10)
                      (set! r10 (rbp - 8))
                      (set! (rbp - 0) r10)
                      (set! rax 1126078786)))
  (check-by-interp '(module (let ([foo.9.2 (* -1154104701 9223372036854775807)]
                                  [ball.1.1 (let ([ball.1.3 (+ 9223372036854775807 -1520906171)])
                                              (* ball.1.3 ball.1.3))])
                              (let ([foobar.4.5 (+ -9223372036854775808 9223372036854775807)]
                                    [bat.7.4 (let ([foo.5.8 -711901302]
                                                   [ball.2.7 foo.9.2]
                                                   [foobar.6.6 1])
                                               -9223372036854775808)])
                                (+ -832221090 1952403775)))))
  (check-by-interp '(begin
                      (set! fv6 -230241463)
                      (set! r10 fv6)
                      (set! r11 9223372036854775807)
                      (set! r10 (+ r10 r11))
                      (set! fv6 r10)
                      (set! r10 fv6)
                      (set! fv5 r10)
                      (set! fv4 -805707019)
                      (set! r10 fv4)
                      (set! r10 (+ r10 1))
                      (set! fv4 r10)
                      (set! r10 fv4)
                      (set! fv3 r10)
                      (set! r10 fv5)
                      (set! fv2 r10)
                      (set! fv1 0)
                      (set! r10 9223372036854775807)
                      (set! fv0 r10)
                      (set! rax -9223372036854775808)))
  (check-by-interp '(begin
                      (set! (rbp - 24) -822533870)
                      (set! r10 (rbp - 24))
                      (set! r11 9223372036854775807)
                      (set! r10 (+ r10 r11))
                      (set! (rbp - 24) r10)
                      (set! r10 (rbp - 24))
                      (set! (rbp - 16) r10)
                      (set! r10 9223372036854775807)
                      (set! (rbp - 8) r10)
                      (set! r10 (rbp - 8))
                      (set! (rbp - 0) r10)
                      (set! r10 (rbp - 0))
                      (set! r10 (+ r10 0))
                      (set! (rbp - 0) r10)
                      (set! r10 (rbp - 0))
                      (set! (rbp - 32) r10)
                      (set! rax (rbp - 32))))
  (check-by-interp '(module (let ([bar.3 (let ([bar.2 1]
                                               [bat.1 (let ([bar.3 118010454]
                                                            [bar.2 1]
                                                            [bat.9 -9223372036854775808])
                                                        bar.2)])
                                           (let ([bat.9 bar.2]
                                                 [bat.1 bar.2])
                                             -9223372036854775808))])
                              (let ([bat.9 (* bar.3 bar.3)]
                                    [bar.3 (+ -1846872043 bar.3)]
                                    [bar.5 (let ([bar.5 0]
                                                 [bar.3 bar.3])
                                             -9223372036854775808)])
                                (let ([bat.9 bat.9]) 1)))))
  (check-by-interp '(module (begin
                              (set! bat.6.3 -9223372036854775808)
                              (set! bat.1.2
                                    (begin
                                      (set! bat.0.5 (* -1022035607 1))
                                      (set! foo.8.4 1)
                                      9223372036854775807))
                              (set! bar.9.1
                                    (begin
                                      (set! bat.0.8 1070959615)
                                      (set! foo.2.7 9223372036854775807)
                                      (set! bar.3.6 (+ 2075026749 -9223372036854775808))
                                      9223372036854775807))
                              (begin
                                (begin
                                  (set! bar.3.9 (+ bat.6.3 0))
                                  (begin
                                    (set! bat.1.10 bar.9.1)
                                    -9223372036854775808))))))
  (check-by-interp '(module (begin
                              (begin
                                (begin
                                  (set! bat.0.7 (* 0 -591471193))
                                  (set! bar.7.6 -1433160755)
                                  (begin
                                    (set! foobar.3.10 -1630730845)
                                    (set! ball.5.9 1)
                                    (set! bat.9.8 1)
                                    (set! foobar.8.5 bat.9.8))
                                  (set! foo.1.4 foobar.8.5))
                                (begin
                                  (set! foo.1.12 (* -9223372036854775808 215775010))
                                  (set! ball.5.11 foo.1.4)
                                  (set! bat.0.3 (+ 0 foo.1.12))))
                              (set! ball.5.2 (+ 1 0))
                              (begin
                                (set! bar.7.1 0))
                              -9223372036854775808)))
  (check-by-interp '(module (begin
                              (set! bat.0.3
                                    (begin
                                      (set! foo.1.4
                                            (begin
                                              (set! bat.0.7 (* 0 -591471193))
                                              (set! bar.7.6 -1433160755)
                                              (set! foobar.8.5
                                                    (begin
                                                      (set! foobar.3.10 -1630730845)
                                                      (set! ball.5.9 1)
                                                      (set! bat.9.8 1)
                                                      bat.9.8))
                                              foobar.8.5))
                                      (begin
                                        (set! foo.1.12 (* -9223372036854775808 215775010))
                                        (set! ball.5.11 foo.1.4)
                                        (+ 0 foo.1.12))))
                              (set! ball.5.2 (+ 1 0))
                              (set! bar.7.1
                                    (begin
                                      0))
                              -9223372036854775808)))
  (check-by-interp
   '(module (let ([foo.0 (let ([foobar.8 (* 877774823 1)]
                               [foo.0 (let ([bat.3 (let ([foo.6 0]) 9223372036854775807)]
                                            [bat.2 (let ([foobar.8 9223372036854775807]
                                                         [bat.2 1])
                                                     -1175234957)]
                                            [bat.4 (* 9223372036854775807 1)])
                                        9223372036854775807)])
                           foo.0)])
              (let ([bat.2 (let ([foo.0 (let ([bat.5 foo.0]) foo.0)]
                                 [ball.1 (let ([foo.7 1483648895]) foo.0)]
                                 [foo.6 foo.0])
                             foo.6)])
                (let ([foo.6 bat.2]
                      [foobar.9 bat.2]
                      [foobar.8 (+ foo.0 foo.0)])
                  (let ([bat.2 bat.2]
                        [ball.1 -10623344])
                    0))))))
  (check-by-interp '(module (let ([bar.8 (let ([bar.6 0]
                                               [foo.4 9223372036854775807])
                                           (let ([foo.1 (* 1617024596 9223372036854775807)]
                                                 [bar.2 (* bar.6 foo.4)]
                                                 [foobar.0 (+ bar.6 bar.6)])
                                             foobar.0))])
                              (let ([foo.9 (let ([bar.3 -1114020630]
                                                 [foo.1 (let ([foo.1 -2080084613]
                                                              [bar.8 -9223372036854775808])
                                                          -1656687642)]
                                                 [bar.8 (let ([foo.1 bar.8]
                                                              [bat.5 1909787064]
                                                              [foo.9 bar.8])
                                                          bat.5)])
                                             bar.3)]
                                    [bar.3 (let () (* bar.8 9223372036854775807))]
                                    [foo.1 (* -9223372036854775808 bar.8)])
                                (let ([foo.9 bar.3]
                                      [bar.6 (let ([foo.9 748728232]
                                                   [bar.3 foo.9]
                                                   [bar.8 foo.9])
                                               9223372036854775807)])
                                  (* 1423178087 0))))))
  (check-by-interp '(module (begin
                              (set! foo.0.1
                                    (begin
                                      (set! foobar.8.3 (* 877774823 1))
                                      (set! foo.0.2
                                            (begin
                                              (set! bat.3.6
                                                    (begin
                                                      (set! foo.6.7 0)
                                                      9223372036854775807))
                                              (set! bat.2.5
                                                    (begin
                                                      (set! foobar.8.9 9223372036854775807)
                                                      (set! bat.2.8 1)
                                                      -1175234957))
                                              (set! bat.4.4 (* 9223372036854775807 1))
                                              9223372036854775807))
                                      foo.0.2))
                              (begin
                                (set! bat.2.10
                                      (begin
                                        (set! foo.0.13
                                              (begin
                                                (set! bat.5.14 foo.0.1)
                                                foo.0.1))
                                        (set! ball.1.12
                                              (begin
                                                (set! foo.7.15 1483648895)
                                                foo.0.1))
                                        (set! foo.6.11 foo.0.1)
                                        foo.6.11))
                                (begin
                                  (set! foo.6.18 bat.2.10)
                                  (set! foobar.9.17 bat.2.10)
                                  (set! foobar.8.16 (+ foo.0.1 foo.0.1))
                                  (begin
                                    (set! bat.2.20 bat.2.10)
                                    (set! ball.1.19 -10623344)
                                    0))))))
  (check-by-interp '(begin
                      (set! (rbp - 96) -1154104701)
                      (set! r10 (rbp - 96))
                      (set! r11 9223372036854775807)
                      (set! r10 (* r10 r11))
                      (set! (rbp - 96) r10)
                      (set! r10 (rbp - 96))
                      (set! (rbp - 88) r10)
                      (set! r10 9223372036854775807)
                      (set! (rbp - 80) r10)
                      (set! r10 (rbp - 80))
                      (set! r10 (+ r10 -1520906171))
                      (set! (rbp - 80) r10)
                      (set! r10 (rbp - 80))
                      (set! (rbp - 72) r10)
                      (set! r10 (rbp - 72))
                      (set! (rbp - 64) r10)
                      (set! r10 (rbp - 64))
                      (set! r10 (* r10 (rbp - 72)))
                      (set! (rbp - 64) r10)
                      (set! r10 (rbp - 64))
                      (set! (rbp - 56) r10)
                      (set! r10 -9223372036854775808)
                      (set! (rbp - 48) r10)
                      (set! r10 (rbp - 48))
                      (set! r11 9223372036854775807)
                      (set! r10 (+ r10 r11))
                      (set! (rbp - 48) r10)
                      (set! r10 (rbp - 48))
                      (set! (rbp - 40) r10)
                      (set! (rbp - 32) -711901302)
                      (set! r10 (rbp - 88))
                      (set! (rbp - 24) r10)
                      (set! (rbp - 16) 1)
                      (set! r10 -9223372036854775808)
                      (set! (rbp - 8) r10)
                      (set! (rbp - 0) -832221090)
                      (set! r10 (rbp - 0))
                      (set! r10 (+ r10 1952403775))
                      (set! (rbp - 0) r10)
                      (set! r10 (rbp - 0))
                      (set! (rbp - 104) r10)
                      (set! rax (rbp - 104))))
  (check-by-interp '(begin
                      (set! r10 -9223372036854775808)
                      (set! fv28 r10)
                      (set! r10 9223372036854775807)
                      (set! fv27 r10)
                      (set! r10 9223372036854775807)
                      (set! fv26 r10)
                      (set! fv25 0)
                      (set! fv24 0)
                      (set! fv23 276890345)
                      (set! fv22 1421159570)
                      (set! r10 fv22)
                      (set! r10 (* r10 0))
                      (set! fv22 r10)
                      (set! r10 fv22)
                      (set! fv21 r10)
                      (set! fv20 -1075619650)
                      (set! r10 fv20)
                      (set! r11 9223372036854775807)
                      (set! r10 (* r10 r11))
                      (set! fv20 r10)
                      (set! r10 fv20)
                      (set! fv19 r10)
                      (set! r10 9223372036854775807)
                      (set! fv18 r10)
                      (set! fv17 451680725)
                      (set! r10 fv17)
                      (set! r10 (+ r10 751914030))
                      (set! fv17 r10)
                      (set! r10 fv17)
                      (set! fv16 r10)
                      (set! r10 fv16)
                      (set! fv15 r10)
                      (set! fv14 -1362757702)
                      (set! r10 fv14)
                      (set! r10 (* r10 738148732))
                      (set! fv14 r10)
                      (set! r10 fv14)
                      (set! fv13 r10)
                      (set! r10 -9223372036854775808)
                      (set! fv12 r10)
                      (set! fv11 -1049804848)
                      (set! r10 fv11)
                      (set! fv10 r10)
                      (set! fv9 0)
                      (set! fv8 -353965291)
                      (set! r10 fv8)
                      (set! fv7 r10)
                      (set! fv6 0)
                      (set! r10 -9223372036854775808)
                      (set! fv5 r10)
                      (set! fv4 1)
                      (set! r10 fv15)
                      (set! fv3 r10)
                      (set! r10 fv4)
                      (set! fv2 r10)
                      (set! fv1 0)
                      (set! r10 fv1)
                      (set! fv0 r10)
                      (set! r10 fv0)
                      (set! r11 -9223372036854775808)
                      (set! r10 (+ r10 r11))
                      (set! fv0 r10)
                      (set! r10 fv0)
                      (set! fv29 r10)
                      (set! rax fv29)))
  (check-by-interp '(begin
                      (set! fv38 -1819252534)
                      (set! r10 fv38)
                      (set! r10 (+ r10 0))
                      (set! fv38 r10)
                      (set! r10 fv38)
                      (set! fv37 r10)
                      (set! fv36 0)
                      (set! r10 fv36)
                      (set! r10 (+ r10 0))
                      (set! fv36 r10)
                      (set! r10 fv36)
                      (set! fv35 r10)
                      (set! fv34 1)
                      (set! fv33 1)
                      (set! r10 fv33)
                      (set! r10 (+ r10 1878805388))
                      (set! fv33 r10)
                      (set! r10 fv33)
                      (set! fv32 r10)
                      (set! r10 fv32)
                      (set! fv31 r10)
                      (set! r10 fv31)
                      (set! r10 (+ r10 fv34))
                      (set! fv31 r10)
                      (set! r10 fv31)
                      (set! fv30 r10)
                      (set! r10 fv37)
                      (set! fv29 r10)
                      (set! r10 9223372036854775807)
                      (set! fv28 r10)
                      (set! r10 9223372036854775807)
                      (set! fv27 r10)
                      (set! r10 fv28)
                      (set! fv26 r10)
                      (set! fv25 -236700244)
                      (set! r10 fv25)
                      (set! r11 9223372036854775807)
                      (set! r10 (* r10 r11))
                      (set! fv25 r10)
                      (set! r10 fv25)
                      (set! fv24 r10)
                      (set! fv23 -162516402)
                      (set! fv22 1)
                      (set! r10 -9223372036854775808)
                      (set! fv21 r10)
                      (set! r10 fv23)
                      (set! fv20 r10)
                      (set! r10 fv24)
                      (set! fv19 r10)
                      (set! r10 fv19)
                      (set! r10 (+ r10 1))
                      (set! fv19 r10)
                      (set! r10 fv19)
                      (set! fv18 r10)
                      (set! r10 -9223372036854775808)
                      (set! fv17 r10)
                      (set! r10 fv17)
                      (set! r10 (+ r10 0))
                      (set! fv17 r10)
                      (set! r10 fv17)
                      (set! fv16 r10)
                      (set! r10 -9223372036854775808)
                      (set! fv15 r10)
                      (set! r10 9223372036854775807)
                      (set! fv14 r10)
                      (set! r10 -9223372036854775808)
                      (set! fv13 r10)
                      (set! r10 fv16)
                      (set! fv12 r10)
                      (set! r10 fv16)
                      (set! fv11 r10)
                      (set! r10 9223372036854775807)
                      (set! fv10 r10)
                      (set! fv9 1412459164)
                      (set! r10 fv13)
                      (set! fv8 r10)
                      (set! r10 fv8)
                      (set! fv7 r10)
                      (set! r10 fv29)
                      (set! fv6 r10)
                      (set! r10 fv7)
                      (set! fv5 r10)
                      (set! r10 fv29)
                      (set! fv4 r10)
                      (set! r10 fv4)
                      (set! r10 (* r10 1442357341))
                      (set! fv4 r10)
                      (set! r10 fv4)
                      (set! fv3 r10)
                      (set! r10 fv3)
                      (set! fv2 r10)
                      (set! r10 fv7)
                      (set! fv1 r10)
                      (set! r10 fv5)
                      (set! fv0 r10)
                      (set! rax -241389399)))

  ;;
  (check-equal? (implement-fvars '(begin)) '(begin)))
