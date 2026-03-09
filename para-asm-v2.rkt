#lang racket

(require cpsc411/compiler-lib)

(provide patch-instructions)
;; para-asm-lang-v2
;  p	 	::=	 	(begin effect ... (halt triv))

;   effect	 	::=	 	(set! loc triv) | (set! loc_1 (binop loc_1 triv))
;   triv	 	::=	 	int64 |	loc

;   loc	 	::=	 	reg  | fvar

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
;  	 	|	 	r12
;  	 	|	 	r13
;  	 	|	 	r14
;  	 	|	 	r15
;   binop	 	::=	 	* | +
;   int64	 	::=	 	int64?
;   fvar	 	::=	 	fvar?

;; (para-asm-lang-v2) -> (paren-x64-fvars-v2)
;; Patches instructions in p that have no x64 analogue
(define (patch-instructions p)
  (define aux-reg (current-patch-instructions-registers))
  (define first-reg (first (aux-reg)))

  (define (patch-effect-reg effect)
    (match effect
      [`(set! ,reg1 (,binop ,reg1 ,triv))
       #:when (integer? triv)
       (not (int32? triv))
       `((set! ,first-reg ,triv) (set! ,reg1 (,binop ,reg1 ,first-reg)))]
      [`(set! ,fvar1 ,triv)
       #:when (and (fvar? fvar1) (or (fvar? triv) (and (integer? triv) (not (int32? triv)))))
       `((set! ,first-reg ,triv) (set! ,fvar1 ,first-reg))]
      [_ effect]))

  (define (patch-effect-fvar effect)
    (match effect
      [`(set! ,fvar1 (,binop ,fvar1 ,triv))
       #:when (fvar? fvar1)
       `((set! ,first-reg ,triv) (set! ,first-reg (,binop ,first-reg ,fvar1))
                                 (set! ,fvar1 ,first-reg))]
      [`(set! ,fvar1 ,triv)
       #:when (or (fvar? triv) (and (integer? triv) (not (int32? triv))))
       `((set! ,first-reg ,triv) (set! ,fvar1 ,first-reg))]
      [_ effect]))

  (define (patch-effect effect)
    (match effect
      [`(set! ,loc ,rest)
       #:when (register? loc)
       (patch-effect-reg loc)]
      [`(set! ,loc ,rest) (patch-effect-fvar loc)]))

  (define (patch-p p)
    (match p
      [`(begin
          ,effects ...
          (halt ,triv))
       `(begin
          ,@(map patch-effect effects)
          (set! ,(current-return-value-register) ,triv))]))

  (patch-p p))

(module+ test
  (require rackunit
           cpsc411/langs/v2
           cpsc411/langs/v3)
  (define-syntax-rule (check-by-interp p)
    (check-equal? (interp-para-asm-lang-v2 p) (interp-paren-x64-fvars-v2 (patch-instructions p))))

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
  (check-by-interp '(module (let ([foo.4 9223372036854775807]) foo.4)))
  (check-by-interp '(begin
                      (set! fv0 828152543)
                      (halt 9223372036854775807)))
  (check-by-interp '(begin
                      (set! fv0 828152543)
                      (set! rax 9223372036854775807)))
  (check-by-interp '(begin
                      (set! fv0 1)
                      (set! fv1 -9223372036854775808)
                      (halt fv1)))
  (check-by-interp '(module (let ([bar.6.2 1]
                                  [bar.3.1 -9223372036854775808])
                              bar.3.1)))
  (check-by-interp '(begin
                      (set! fv1 -1583518893)
                      (set! fv0 9223372036854775807)
                      (halt fv1)))
  (check-by-interp '(module (let ([bar.4 9223372036854775807]) (let ([foobar.0 (* 1 bar.4)]) bar.4))))
  (check-by-interp '(module (let ([bat.7 1]
                                  [bat.6 229035576]
                                  [bar.0 -9223372036854775808])
                              -840991502)))
  (check-by-interp '(begin
                      (set! fv0 9223372036854775807)
                      (set! fv0 (* fv0 0))
                      (set! fv1 fv0)
                      (halt fv1)))
  (check-by-interp '(begin
                      (set! fv1 -1583518893)
                      (set! r10 9223372036854775807)
                      (set! fv0 r10)
                      (set! rax fv1)))
  (check-by-interp '(begin
                      (set! fv2 2070989370)
                      (set! fv1 fv2)
                      (set! fv3 -267352716)
                      (set! fv0 fv2)
                      (halt fv3)))
  (check-by-interp '(begin
                      (set! (rbp - 0) 1)
                      (set! r10 -9223372036854775808)
                      (set! (rbp - 8) r10)
                      (set! rax (rbp - 8))))
  (check-by-interp '(begin
                      (set! (rbp - 8) 1560534029)
                      (set! r10 9223372036854775807)
                      (set! (rbp - 0) r10)
                      (set! rax -875855756)))
  (check-by-interp '(begin
                      (set! fv1 77841184)
                      (set! r10 -9223372036854775808)
                      (set! fv0 r10)
                      (set! fv2 699352919)
                      (set! rax fv2)))
  (check-by-interp '(module (let ([foo.3 2110471915]
                                  [bat.0 (* 1294488972 0)])
                              (let ([ball.9 1237875503]
                                    [bat.8 -9223372036854775808])
                                bat.8))))
  (check-by-interp '(module ()
                            (begin
                              (set! tmp.2 9223372036854775807)
                              (set! tmp.2 (* tmp.2 0))
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
                              (set! tmp.2 -379276448)
                              (set! tmp.2 (+ tmp.2 -9223372036854775808))
                              (set! tmp.1 tmp.2)
                              (halt tmp.1))
                      ))
  (check-by-interp '(begin
                      (set! (rbp - 8) 77841184)
                      (set! r10 -9223372036854775808)
                      (set! (rbp - 0) r10)
                      (set! (rbp - 16) 699352919)
                      (set! rax (rbp - 16))))
  (check-by-interp '(module (begin
                              (set! bar.0.3 (* 0 123448674))
                              (set! bar.9.2 -9223372036854775808)
                              (set! bar.3.1 -9223372036854775808)
                              (+ bar.3.1 bar.3.1))))
  (check-by-interp '(begin
                      (set! (rbp - 0) 1)
                      (set! r10 (rbp - 0))
                      (set! r10 (* r10 0))
                      (set! (rbp - 0) r10)
                      (set! r10 (rbp - 0))
                      (set! (rbp - 8) r10)
                      (set! rax (rbp - 8))))
  (check-by-interp '(begin
                      (set! r10 -9223372036854775808)
                      (set! fv0 r10)
                      (set! r10 fv0)
                      (set! r10 (+ r10 0))
                      (set! fv0 r10)
                      (set! r10 fv0)
                      (set! fv1 r10)
                      (set! rax fv1)))
  (check-by-interp '(begin
                      (set! fv4 -9223372036854775808)
                      (set! fv3 fv4)
                      (set! fv5 1)
                      (set! fv2 -49511605)
                      (set! fv2 (+ fv2 1))
                      (set! fv1 fv2)
                      (set! fv0 1610221572)
                      (halt fv5)))
  (check-by-interp '(begin
                      (set! fv1 1843505587)
                      (set! r10 fv1)
                      (set! fv0 r10)
                      (set! r10 fv0)
                      (set! r10 (* r10 fv1))
                      (set! fv0 r10)
                      (set! r10 fv0)
                      (set! fv2 r10)
                      (set! rax fv2)))
  (check-by-interp '(module (begin
                              (set! foo.3.2 2110471915)
                              (set! bat.0.1 (* 1294488972 0))
                              (begin
                                (set! ball.9.4 1237875503)
                                (set! bat.8.3 -9223372036854775808)
                                bat.8.3))))
  (check-by-interp '(begin
                      (set! fv4 -9223372036854775808)
                      (set! fv3 9223372036854775807)
                      (set! fv2 fv4)
                      (set! fv1 fv2)
                      (set! fv1 (+ fv1 513005733))
                      (set! fv5 fv1)
                      (set! fv0 90426798)
                      (halt fv5)))
  (check-by-interp '(begin
                      (set! r10 9223372036854775807)
                      (set! (rbp - 0) r10)
                      (set! r10 (rbp - 0))
                      (set! r10 (+ r10 0))
                      (set! (rbp - 0) r10)
                      (set! r10 (rbp - 0))
                      (set! (rbp - 8) r10)
                      (set! rax (rbp - 8))))
  (check-by-interp '(module (let ([bar.9 (+ -230241463 9223372036854775807)])
                              (let ([bar.5 (+ -805707019 1)]
                                    [bat.8 (let ([bat.8 bar.9]) 0)]
                                    [bat.3 (let () 9223372036854775807)])
                                -9223372036854775808))))
  (check-by-interp '(begin
                      (set! fv4 0)
                      (set! fv4 (* fv4 123448674))
                      (set! fv3 fv4)
                      (set! fv2 -9223372036854775808)
                      (set! fv1 -9223372036854775808)
                      (set! fv0 fv1)
                      (set! fv0 (+ fv0 fv1))
                      (set! fv5 fv0)
                      (halt fv5)))
  (check-by-interp '(module (let ([bar.3.3 0]
                                  [bat.5.2 (let ([foo.9.5 430633110]
                                                 [ball.2.4 -9223372036854775808])
                                             ball.2.4)]
                                  [foobar.1.1 (let () 9223372036854775807)])
                              (let ([bat.5.6 bat.5.2]) -1211501460))))
  (check-by-interp '(begin
                      (set! fv3 2110471915)
                      (set! fv2 1294488972)
                      (set! r10 fv2)
                      (set! r10 (* r10 0))
                      (set! fv2 r10)
                      (set! r10 fv2)
                      (set! fv1 r10)
                      (set! fv0 1237875503)
                      (set! r10 -9223372036854775808)
                      (set! fv4 r10)
                      (set! rax fv4)))
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
  (check-by-interp '(module (let ([foo.3 (let ([ball.9 9223372036854775807]) (+ 823385985 ball.9))])
                              (let ([ball.1 (let ([foo.6 9223372036854775807]
                                                  [ball.5 -9223372036854775808])
                                              1)]
                                    [bar.2 (+ 9223372036854775807 0)]
                                    [foo.6 -1226663776])
                                (* foo.6 foo.6)))))
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
  (check-by-interp '(module (let ([foobar.8 (* 9223372036854775807 610664654)])
                              (let ([ball.2 (let ([ball.2 (* foobar.8 foobar.8)]
                                                  [foobar.6 (let ([ball.2 foobar.8])
                                                              9223372036854775807)])
                                              (let ([bat.0 foobar.8]
                                                    [ball.2 foobar.8])
                                                foobar.8))]
                                    [foobar.1 1628045022])
                                -400120723))))
  (check-by-interp '(module (let ([foo.3.1 (let ([ball.9.2 9223372036854775807])
                                             (+ 823385985 ball.9.2))])
                              (let ([ball.1.5 (let ([foo.6.7 9223372036854775807]
                                                    [ball.5.6 -9223372036854775808])
                                                1)]
                                    [bar.2.4 (+ 9223372036854775807 0)]
                                    [foo.6.3 -1226663776])
                                (* foo.6.3 foo.6.3)))))
  (check-by-interp '(begin
                      (set! fv3 -822533870)
                      (set! r10 fv3)
                      (set! r11 9223372036854775807)
                      (set! r10 (+ r10 r11))
                      (set! fv3 r10)
                      (set! r10 fv3)
                      (set! fv2 r10)
                      (set! r10 9223372036854775807)
                      (set! fv1 r10)
                      (set! r10 fv1)
                      (set! fv0 r10)
                      (set! r10 fv0)
                      (set! r10 (+ r10 0))
                      (set! fv0 r10)
                      (set! r10 fv0)
                      (set! fv4 r10)
                      (set! rax fv4)))
  (check-by-interp '(module (begin
                              (set! foo.3.1
                                    (begin
                                      (set! ball.9.2 9223372036854775807)
                                      (+ 823385985 ball.9.2)))
                              (begin
                                (set! ball.1.5
                                      (begin
                                        (set! foo.6.7 9223372036854775807)
                                        (set! ball.5.6 -9223372036854775808)
                                        1))
                                (set! bar.2.4 (+ 9223372036854775807 0))
                                (set! foo.6.3 -1226663776)
                                (* foo.6.3 foo.6.3)))))
  (check-by-interp '(begin
                      (set! r10 -9223372036854775808)
                      (set! (rbp - 32) r10)
                      (set! r10 9223372036854775807)
                      (set! (rbp - 24) r10)
                      (set! r10 (rbp - 32))
                      (set! (rbp - 16) r10)
                      (set! r10 (rbp - 16))
                      (set! (rbp - 8) r10)
                      (set! r10 (rbp - 8))
                      (set! r10 (+ r10 513005733))
                      (set! (rbp - 8) r10)
                      (set! r10 (rbp - 8))
                      (set! (rbp - 40) r10)
                      (set! (rbp - 0) 90426798)
                      (set! rax (rbp - 40))))
  (check-by-interp '(begin
                      (set! fv6 2135631036)
                      (set! r10 fv6)
                      (set! r10 (* r10 1404162073))
                      (set! fv6 r10)
                      (set! r10 fv6)
                      (set! fv5 r10)
                      (set! fv4 0)
                      (set! fv3 654756935)
                      (set! r10 fv4)
                      (set! fv2 r10)
                      (set! r10 fv2)
                      (set! r11 9223372036854775807)
                      (set! r10 (+ r10 r11))
                      (set! fv2 r10)
                      (set! r10 fv2)
                      (set! fv1 r10)
                      (set! fv0 245737528)
                      (set! r10 fv4)
                      (set! fv7 r10)
                      (set! rax fv7)))
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
  (check-by-interp '(begin
                      (set! fv15 0)
                      (set! fv15 (* fv15 -591471193))
                      (set! fv14 fv15)
                      (set! fv13 -1433160755)
                      (set! fv12 -1630730845)
                      (set! fv11 1)
                      (set! fv10 1)
                      (set! fv9 fv10)
                      (set! fv8 fv9)
                      (set! fv7 -9223372036854775808)
                      (set! fv7 (* fv7 215775010))
                      (set! fv6 fv7)
                      (set! fv5 fv8)
                      (set! fv4 0)
                      (set! fv4 (+ fv4 fv6))
                      (set! fv3 fv4)
                      (set! fv2 1)
                      (set! fv2 (+ fv2 0))
                      (set! fv1 fv2)
                      (set! fv0 0)
                      (halt -9223372036854775808)))
  (check-by-interp '(begin
                      (set! (rbp - 48) -230241463)
                      (set! r10 (rbp - 48))
                      (set! r11 9223372036854775807)
                      (set! r10 (+ r10 r11))
                      (set! (rbp - 48) r10)
                      (set! r10 (rbp - 48))
                      (set! (rbp - 40) r10)
                      (set! (rbp - 32) -805707019)
                      (set! r10 (rbp - 32))
                      (set! r10 (+ r10 1))
                      (set! (rbp - 32) r10)
                      (set! r10 (rbp - 32))
                      (set! (rbp - 24) r10)
                      (set! r10 (rbp - 40))
                      (set! (rbp - 16) r10)
                      (set! (rbp - 8) 0)
                      (set! r10 9223372036854775807)
                      (set! (rbp - 0) r10)
                      (set! rax -9223372036854775808)))
  (check-by-interp '(begin
                      (set! (rbp - 48) 2135631036)
                      (set! r10 (rbp - 48))
                      (set! r10 (* r10 1404162073))
                      (set! (rbp - 48) r10)
                      (set! r10 (rbp - 48))
                      (set! (rbp - 40) r10)
                      (set! (rbp - 32) 0)
                      (set! (rbp - 24) 654756935)
                      (set! r10 (rbp - 32))
                      (set! (rbp - 16) r10)
                      (set! r10 (rbp - 16))
                      (set! r11 9223372036854775807)
                      (set! r10 (+ r10 r11))
                      (set! (rbp - 16) r10)
                      (set! r10 (rbp - 16))
                      (set! (rbp - 8) r10)
                      (set! (rbp - 0) 245737528)
                      (set! r10 (rbp - 32))
                      (set! (rbp - 56) r10)
                      (set! rax (rbp - 56))))
  (check-by-interp '(begin
                      (set! fv22 877774823)
                      (set! fv22 (* fv22 1))
                      (set! fv21 fv22)
                      (set! fv20 0)
                      (set! fv19 9223372036854775807)
                      (set! fv18 9223372036854775807)
                      (set! fv17 1)
                      (set! fv16 -1175234957)
                      (set! fv15 9223372036854775807)
                      (set! fv15 (* fv15 1))
                      (set! fv14 fv15)
                      (set! fv13 9223372036854775807)
                      (set! fv12 fv13)
                      (set! fv11 fv12)
                      (set! fv10 fv12)
                      (set! fv9 1483648895)
                      (set! fv8 fv12)
                      (set! fv7 fv12)
                      (set! fv6 fv7)
                      (set! fv5 fv6)
                      (set! fv4 fv6)
                      (set! fv3 fv12)
                      (set! fv3 (+ fv3 fv12))
                      (set! fv2 fv3)
                      (set! fv1 fv6)
                      (set! fv0 -10623344)
                      (halt 0)))
  (check-by-interp '(begin
                      (set! fv15 1)
                      (set! fv14 118010454)
                      (set! fv13 1)
                      (set! r10 -9223372036854775808)
                      (set! fv12 r10)
                      (set! r10 fv13)
                      (set! fv11 r10)
                      (set! r10 fv15)
                      (set! fv10 r10)
                      (set! r10 fv15)
                      (set! fv9 r10)
                      (set! r10 -9223372036854775808)
                      (set! fv8 r10)
                      (set! r10 fv8)
                      (set! fv7 r10)
                      (set! r10 fv7)
                      (set! r10 (* r10 fv8))
                      (set! fv7 r10)
                      (set! r10 fv7)
                      (set! fv6 r10)
                      (set! fv5 -1846872043)
                      (set! r10 fv5)
                      (set! r10 (+ r10 fv8))
                      (set! fv5 r10)
                      (set! r10 fv5)
                      (set! fv4 r10)
                      (set! fv3 0)
                      (set! r10 fv8)
                      (set! fv2 r10)
                      (set! r10 -9223372036854775808)
                      (set! fv1 r10)
                      (set! r10 fv6)
                      (set! fv0 r10)
                      (set! rax 1)))
  (check-by-interp '(module ()
                            (begin
                              (set! tmp.21 877774823)
                              (set! tmp.21 (* tmp.21 1))
                              (set! foobar.8.3 tmp.21)
                              (set! foo.6.7 0)
                              (set! bat.3.6 9223372036854775807)
                              (set! foobar.8.9 9223372036854775807)
                              (set! bat.2.8 1)
                              (set! bat.2.5 -1175234957)
                              (set! tmp.22 9223372036854775807)
                              (set! tmp.22 (* tmp.22 1))
                              (set! bat.4.4 tmp.22)
                              (set! foo.0.2 9223372036854775807)
                              (set! foo.0.1 foo.0.2)
                              (set! bat.5.14 foo.0.1)
                              (set! foo.0.13 foo.0.1)
                              (set! foo.7.15 1483648895)
                              (set! ball.1.12 foo.0.1)
                              (set! foo.6.11 foo.0.1)
                              (set! bat.2.10 foo.6.11)
                              (set! foo.6.18 bat.2.10)
                              (set! foobar.9.17 bat.2.10)
                              (set! tmp.23 foo.0.1)
                              (set! tmp.23 (+ tmp.23 foo.0.1))
                              (set! foobar.8.16 tmp.23)
                              (set! bat.2.20 bat.2.10)
                              (set! ball.1.19 -10623344)
                              (halt 0))
                      ))
  (check-by-interp '(module (let ([ball.0 (let ([foobar.9 (let ([ball.0 -9223372036854775808]
                                                                [ball.1 9223372036854775807])
                                                            9223372036854775807)]
                                                [ball.0 (let ([ball.1 0]
                                                              [foobar.4 0])
                                                          276890345)]
                                                [foo.6 (* 1421159570 0)])
                                            (* -1075619650 9223372036854775807))]
                                  [foobar.4 (let ([foo.2 9223372036854775807]
                                                  [ball.1 (+ 451680725 751914030)])
                                              ball.1)]
                                  [foo.6 (let ([foobar.9 (* -1362757702 738148732)]
                                               [foobar.7 (let ([foobar.8 -9223372036854775808]
                                                               [foobar.4 -1049804848])
                                                           foobar.4)]
                                               [foo.6 (let ([ball.1 0]
                                                            [foobar.7 -353965291])
                                                        foobar.7)])
                                           (let ([foobar.9 0]
                                                 [foobar.3 -9223372036854775808])
                                             1))])
                              (let ([foobar.9 (let ([ball.0 foobar.4]
                                                    [foobar.4 foo.6])
                                                0)])
                                (+ foobar.9 -9223372036854775808)))))
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
  (check-by-interp
   '(module (let ([foo.2 (let ([ball.7 (+ -1819252534 0)]
                               [foo.2 (+ 0 0)]
                               [foobar.8 (let ([bar.1 1]
                                               [foo.2 (+ 1 1878805388)])
                                           (+ foo.2 bar.1))])
                           ball.7)]
                  [bar.4 (let ([bar.5 (let ([foobar.8 (let ([bar.4 9223372036854775807]
                                                            [bar.3 9223372036854775807])
                                                        bar.4)]
                                            [ball.7 (* -236700244 9223372036854775807)]
                                            [bar.3 (let ([bar.1 -162516402]
                                                         [bar.4 1]
                                                         [bar.3 -9223372036854775808])
                                                     bar.1)])
                                        (+ ball.7 1))]
                               [bar.9 (+ -9223372036854775808 0)]
                               [foobar.8 (let ()
                                           (let ([bar.1 -9223372036854775808]
                                                 [foobar.8 9223372036854775807])
                                             -9223372036854775808))])
                           (let ([foo.2 bar.9]
                                 [bar.3 bar.9])
                             (let ([ball.7 9223372036854775807]
                                   [foo.2 1412459164]
                                   [bar.4 foobar.8])
                               bar.4)))])
              (let ([bar.3 foo.2])
                (let ([foo.2 bar.4]
                      [bar.3 (* foo.2 1442357341)])
                  (let ([foobar.8 bar.3]
                        [bar.4 bar.4]
                        [bat.6 foo.2])
                    -241389399))))))
  (check-by-interp '(begin
                      (set! (rbp - 216) 0)
                      (set! r10 9223372036854775807)
                      (set! (rbp - 208) r10)
                      (set! (rbp - 200) 1617024596)
                      (set! r10 (rbp - 200))
                      (set! r11 9223372036854775807)
                      (set! r10 (* r10 r11))
                      (set! (rbp - 200) r10)
                      (set! r10 (rbp - 200))
                      (set! (rbp - 192) r10)
                      (set! r10 (rbp - 216))
                      (set! (rbp - 184) r10)
                      (set! r10 (rbp - 184))
                      (set! r10 (* r10 (rbp - 208)))
                      (set! (rbp - 184) r10)
                      (set! r10 (rbp - 184))
                      (set! (rbp - 176) r10)
                      (set! r10 (rbp - 216))
                      (set! (rbp - 168) r10)
                      (set! r10 (rbp - 168))
                      (set! r10 (+ r10 (rbp - 216)))
                      (set! (rbp - 168) r10)
                      (set! r10 (rbp - 168))
                      (set! (rbp - 160) r10)
                      (set! r10 (rbp - 160))
                      (set! (rbp - 152) r10)
                      (set! (rbp - 144) -1114020630)
                      (set! (rbp - 136) -2080084613)
                      (set! r10 -9223372036854775808)
                      (set! (rbp - 128) r10)
                      (set! (rbp - 120) -1656687642)
                      (set! r10 (rbp - 152))
                      (set! (rbp - 112) r10)
                      (set! (rbp - 104) 1909787064)
                      (set! r10 (rbp - 152))
                      (set! (rbp - 96) r10)
                      (set! r10 (rbp - 104))
                      (set! (rbp - 88) r10)
                      (set! r10 (rbp - 144))
                      (set! (rbp - 80) r10)
                      (set! r10 (rbp - 152))
                      (set! (rbp - 72) r10)
                      (set! r10 (rbp - 72))
                      (set! r11 9223372036854775807)
                      (set! r10 (* r10 r11))
                      (set! (rbp - 72) r10)
                      (set! r10 (rbp - 72))
                      (set! (rbp - 64) r10)
                      (set! r10 -9223372036854775808)
                      (set! (rbp - 56) r10)
                      (set! r10 (rbp - 56))
                      (set! r10 (* r10 (rbp - 152)))
                      (set! (rbp - 56) r10)
                      (set! r10 (rbp - 56))
                      (set! (rbp - 48) r10)
                      (set! r10 (rbp - 64))
                      (set! (rbp - 40) r10)
                      (set! (rbp - 32) 748728232)
                      (set! r10 (rbp - 80))
                      (set! (rbp - 24) r10)
                      (set! r10 (rbp - 80))
                      (set! (rbp - 16) r10)
                      (set! r10 9223372036854775807)
                      (set! (rbp - 8) r10)
                      (set! (rbp - 0) 1423178087)
                      (set! r10 (rbp - 0))
                      (set! r10 (* r10 0))
                      (set! (rbp - 0) r10)
                      (set! r10 (rbp - 0))
                      (set! (rbp - 224) r10)
                      (set! rax (rbp - 224))))

  ;;

  (check-equal? (patch-instructions '(begin
                                       (set! rbx 42)
                                       (halt rbx)))
                '(begin
                   (set! rbx 42)
                   (set! rax rbx)))
  (check-equal? (patch-instructions '(begin
                                       (set! fv0 0)
                                       (set! fv1 42)
                                       (set! fv0 fv1)
                                       (halt fv0)))
                '(begin
                   (set! fv0 0)
                   (set! fv1 42)
                   (set! r10 fv1)
                   (set! fv0 r10)
                   (set! rax fv0)))
  (check-equal? (patch-instructions '(begin
                                       (set! rbx 0)
                                       (set! rcx 0)
                                       (set! r9 42)
                                       (set! rbx rcx)
                                       (set! rbx (+ rbx r9))
                                       (halt rbx)))
                '(begin
                   (set! rbx 0)
                   (set! rcx 0)
                   (set! r9 42)
                   (set! rbx rcx)
                   (set! rbx (+ rbx r9))
                   (set! rax rbx))))
