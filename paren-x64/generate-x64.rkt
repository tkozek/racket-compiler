#lang racket

(require cpsc411/compiler-lib)

(provide generate-x64
         interp-paren-x64)
; p	 	::=	 	(begin s ...)

;   s	 	::=	 	(set! addr int32)
;  	 	|	 	(set! addr reg)
;  	 	|	 	(set! reg loc)
;  	 	|	 	(set! reg triv)
;  	 	|	 	(set! reg_1 (binop reg_1 int32))
;  	 	|	 	(set! reg_1 (binop reg_1 loc))

;   triv	 	::=	 	reg
;  	 	|	 	int64

;   loc	 	::=	 	reg
;  	 	|	 	addr

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

;   addr	 	::=	 	(fbp - dispoffset)

;   fbp	 	::=	 	frame-base-pointer-register?

;   binop	 	::=	 	*
;  	 	|	 	+

;   int64	 	::=	 	int64?

;   int32	 	::=	 	int32?

;   dispoffset	 	::=	 	dispoffset?

;; (paren-x64-v2 p) -> x64-instruction-sequence
;; Compiles a Paren-x64 v2 program into x64 instruction sequence, represented as a string
(define (generate-x64 p)

  ;; (paren-x64-v2 addr) -> (paren-x64-v2 dispoffset)
  ;; returns displacement offset for a given address.
  (define (addr->dispoffset addr)
    (match addr
      [`[,(current-frame-base-pointer-register) - dispoffset] dispoffset]))

  ;; (paren-x64-v2 dispoffset) -> (x64 displacement mode operand)
  ;; Takes an offset and produces: QWORD [fbp - offset]
  (define (dispoffset->dmo offset)
    (format "QWORD [~a - ~a]" (current-frame-base-pointer-register) offset))

  ;; (paren-x64-v2 addr) -> (x64 displacement mode operand)
  ;; Takes address of the form: (fbp - offset), and produces: QWORD [fbp - offset]
  (define (addr->dmo addr)
    (dispoffset->dmo (addr->dispoffset addr)))

  (define (binop->ins op)
    (match op
      ['+ "add"]
      ['* "imul"]))

  ;   (define (loc->x64 loc)
  ;     (TODO "generate-x64"))

  ; (paren-x64-v2 s) -> x64-instruction-sequence
  (define (statement->x64 s)
    (match s
      [`(set! ,reg1 (,op ,reg1 ,val))
       #:when (or (int32? val) (register? val))
       (format "~a ~a, ~a\n" (binop->ins op) reg1 val)]
      [`(set! ,reg1 (,op ,reg1 ,addr)) (format "~a ~a, ~a\n" (binop->ins op) reg1 (addr->dmo addr))]
      [`(set! ,reg ,val)
       #:when (and (register? reg) (or (register? val) (int64? val)))
       (format "mov ~a, ~a\n" reg val)]
      [`(set! ,reg ,addr)
       #:when (register? reg)
       (format "mov ~a, ~a\n" reg (addr->dmo addr))]
      [`(set! ,addr ,val) (format "mov ~a, ~a\n" (addr->dmo addr) val)]))

  ; (paren-x64-v2 p) -> x64-instruction-sequence
  (define (program->x64 p)
    (match p
      [`(begin
          ,s ...)
       (string-join (map statement->x64 s) "")]))

  (program->x64 p))

(define (interp-paren-x64 p)
  ; Environment (List-of (paren-x64-v2 Statements)) -> Integer
  (define (eval-instruction-sequence env sls)
    (if (empty? sls)
        (dict-ref env 'rax)
        (TODO "Implement the fold over a sequence of Paren-x64-v2 /s/.")))

  ; Environment Statement -> Environment
  (define (eval-statement env s)
    (TODO "Implement the transition function evaluating a Paren-x64-v2 /s/."))

  ; (Paren-x64-v2 binop) -> procedure?
  (define (eval-binop b)
    (TODO "Implement the interpreter for Paren-x64-v2 /binop/."))

  ; Environment (Paren-x64-v2 triv) -> Integer
  (define (eval-triv regfile t)
    (TODO "Implement the interpreter for Paren-x64-v2 /triv/."))

  (TODO "Implement the interpreter for Paren-x64-v2 /p/."))

(module+ test
  (require rackunit
           cpsc411/2c-run-time
           cpsc411/langs/v2
           cpsc411/langs/v3)

  (define-syntax-rule (check-by-interp p)
    (check-equal? (interp-paren-x64-v2 p) (execute (wrap-x64-boilerplate (generate-x64 p)))))

  ;; Added March 8th, 2026
  (check-by-interp '(module (* 3 1)))
  (check-by-interp '(module (begin
                              (* 1 0))))
  (check-by-interp '(module () (halt 1672362778)
                      ))
  (check-by-interp '(module (* 9223372036854775807 0)))
  (check-by-interp '(begin
                      (halt -9223372036854775808)))
  (check-by-interp '(module (begin
                              (set! bat.6.1 1)
                              bat.6.1)))
  (check-by-interp '(begin
                      (set! (rbp - 0) 1)
                      (set! rax (rbp - 0))))
  (check-by-interp '(module (let ([bat.7 1843505587]) (* bat.7 bat.7))))
  (check-by-interp '(module (let ([foobar.4 828152543]) 9223372036854775807)))
  (check-by-interp '(module (let ([bar.6 1]
                                  [bar.3 -9223372036854775808])
                              bar.3)))
  (check-by-interp '(begin
                      (set! (rbp - 0) 828152543)
                      (set! rax 9223372036854775807)))
  (check-by-interp '(begin
                      (set! r10 9223372036854775807)
                      (set! fv0 r10)
                      (set! rax fv0)))
  (check-by-interp '(begin
                      (set! fv0 1)
                      (set! fv0 (+ fv0 -1637029370))
                      (set! fv1 fv0)
                      (halt fv1)))
  (check-by-interp '(begin
                      (set! fv1 1560534029)
                      (set! fv0 9223372036854775807)
                      (halt -875855756)))
  (check-by-interp '(begin
                      (set! fv2 287618957)
                      (set! fv1 1)
                      (set! fv0 -104424799)
                      (halt -1788782111)))
  (check-by-interp '(begin
                      (set! fv1 -9223372036854775808)
                      (set! fv0 -9223372036854775808)
                      (halt 1828326672)))
  (check-by-interp '(module (let ()
                              (let ([ball.5.2 -1583518893]
                                    [foobar.2.1 9223372036854775807])
                                ball.5.2))))
  (check-by-interp '(module ()
                            (begin
                              (set! bar.6.2 1)
                              (set! bar.3.1 -9223372036854775808)
                              (halt bar.3.1))
                      ))
  (check-by-interp '(begin
                      (set! fv2 9223372036854775807)
                      (set! fv1 1)
                      (set! fv1 (* fv1 fv2))
                      (set! fv0 fv1)
                      (halt fv2)))
  (check-by-interp '(module (let ([bat.1.2 (+ -822533870 9223372036854775807)]
                                  [bar.7.1 9223372036854775807])
                              (+ bar.7.1 0))))
  (check-by-interp '(module (begin
                              (begin
                                (set! bar.6.2 1560534029)
                                (set! ball.4.1 9223372036854775807)
                                -875855756))))
  (check-by-interp '(module (begin
                              (set! foobar.9.1 (* 9223372036854775807 0))
                              (begin
                                (set! foo.3.3 0)
                                (set! ball.4.2 (* 0 1))
                                1126078786))))
  (check-by-interp '(module (begin
                              (set! ball.6.2 -9223372036854775808)
                              (set! foobar.3.1
                                    (begin
                                      -9223372036854775808))
                              (begin
                                1828326672))))
  (check-by-interp '(begin
                      (set! fv0 3)
                      (set! r10 fv0)
                      (set! r10 (* r10 1))
                      (set! fv0 r10)
                      (set! r10 fv0)
                      (set! fv1 r10)
                      (set! rax fv1)))
  (check-by-interp '(module ()
                            (begin
                              (set! foobar.9.3 77841184)
                              (set! bar.6.2 -9223372036854775808)
                              (set! bat.3.1 699352919)
                              (halt bat.3.1))
                      ))
  (check-by-interp '(module (let ([foo.9.1 (let ([bat.8.3 -641168007]
                                                 [ball.7.2 -9223372036854775808])
                                             1)])
                              (let ([bat.2.4 -921037329]) 9223372036854775807))))
  (check-by-interp '(module (let ([foo.9 1]
                                  [bar.1 9223372036854775807]
                                  [ball.8 (+ 1 -9223372036854775808)])
                              (let ([bar.6 (+ bar.1 bar.1)]
                                    [ball.0 ball.8])
                                ball.8))))
  (check-by-interp '(begin
                      (set! fv3 2110471915)
                      (set! fv2 1294488972)
                      (set! fv2 (* fv2 0))
                      (set! fv1 fv2)
                      (set! fv0 1237875503)
                      (set! fv4 -9223372036854775808)
                      (halt fv4)))
  (check-by-interp '(begin
                      (set! fv3 0)
                      (set! fv3 (* fv3 0))
                      (set! fv4 fv3)
                      (set! fv2 -9223372036854775808)
                      (set! fv1 fv4)
                      (set! fv1 (* fv1 fv4))
                      (set! fv0 fv1)
                      (halt fv4)))
  (check-by-interp '(begin
                      (set! (rbp - 0) 1)
                      (set! r10 (rbp - 0))
                      (set! r10 (+ r10 -1637029370))
                      (set! (rbp - 0) r10)
                      (set! r10 (rbp - 0))
                      (set! (rbp - 8) r10)
                      (set! rax (rbp - 8))))
  (check-by-interp '(begin
                      (set! fv5 -9223372036854775808)
                      (set! fv4 fv5)
                      (set! fv6 9223372036854775807)
                      (set! fv3 fv5)
                      (set! fv2 364088323)
                      (set! fv1 fv2)
                      (set! fv0 fv1)
                      (halt fv6)))
  (check-by-interp '(begin
                      (set! (rbp - 16) 2070989370)
                      (set! r10 (rbp - 16))
                      (set! (rbp - 8) r10)
                      (set! (rbp - 24) -267352716)
                      (set! r10 (rbp - 16))
                      (set! (rbp - 0) r10)
                      (set! rax (rbp - 24))))
  (check-by-interp '(module (begin
                              (set! foo.9.1
                                    (begin
                                      (set! bat.8.3 -641168007)
                                      (set! ball.7.2 -9223372036854775808)
                                      1))
                              (begin
                                (set! bat.2.4 -921037329)
                                9223372036854775807))))
  (check-by-interp '(begin
                      (set! fv5 966813755)
                      (set! fv5 (+ fv5 -1365911686))
                      (set! fv4 fv5)
                      (set! fv3 -9223372036854775808)
                      (set! fv2 fv3)
                      (set! fv2 (+ fv2 1))
                      (set! fv1 fv2)
                      (set! fv0 fv3)
                      (halt 1)))
  (check-by-interp '(begin
                      (set! fv5 -1632076199)
                      (set! fv5 (+ fv5 0))
                      (set! fv4 fv5)
                      (set! fv3 0)
                      (set! fv2 1961579359)
                      (set! fv2 (+ fv2 -1377521797))
                      (set! fv1 fv2)
                      (set! fv6 fv4)
                      (set! fv0 1)
                      (halt fv6)))
  (check-by-interp '(module (let ([ball.7.3 (* 2135631036 1404162073)]
                                  [bar.1.2 0]
                                  [ball.2.1 654756935])
                              (let ([ball.7.5 (+ bar.1.2 9223372036854775807)]
                                    [bar.3.4 245737528])
                                (let ([ball.2.6 bar.1.2]) ball.2.6)))))
  (check-by-interp '(begin
                      (set! (rbp - 8) 1843505587)
                      (set! r10 (rbp - 8))
                      (set! (rbp - 0) r10)
                      (set! r10 (rbp - 0))
                      (set! r10 (* r10 (rbp - 8)))
                      (set! (rbp - 0) r10)
                      (set! r10 (rbp - 0))
                      (set! (rbp - 16) r10)
                      (set! rax (rbp - 16))))
  (check-by-interp '(module (let ([bar.3 (* 1 9223372036854775807)]
                                  [foobar.0 -455579519])
                              (let ([foo.6 (+ foobar.0 0)]
                                    [bar.9 (let ([bat.4 1]
                                                 [bat.8 -9223372036854775808])
                                             foobar.0)])
                                (let ([bar.9 0]
                                      [foo.6 -9223372036854775808]
                                      [bat.4 1])
                                  -35514184)))))
  (check-by-interp '(begin
                      (set! fv6 -230241463)
                      (set! fv6 (+ fv6 9223372036854775807))
                      (set! fv5 fv6)
                      (set! fv4 -805707019)
                      (set! fv4 (+ fv4 1))
                      (set! fv3 fv4)
                      (set! fv2 fv5)
                      (set! fv1 0)
                      (set! fv0 9223372036854775807)
                      (halt -9223372036854775808)))
  (check-by-interp '(module ()
                            (begin
                              (set! foobar.8.5 -9223372036854775808)
                              (set! foobar.6.4 9223372036854775807)
                              (set! ball.0.3 foobar.8.5)
                              (set! tmp.6 ball.0.3)
                              (set! tmp.6 (+ tmp.6 513005733))
                              (set! foo.9.2 tmp.6)
                              (set! bar.1.1 90426798)
                              (halt foo.9.2))
                      ))
  (check-by-interp '(begin
                      (set! r10 -9223372036854775808)
                      (set! fv5 r10)
                      (set! r10 fv5)
                      (set! fv4 r10)
                      (set! r10 9223372036854775807)
                      (set! fv6 r10)
                      (set! r10 fv5)
                      (set! fv3 r10)
                      (set! fv2 364088323)
                      (set! r10 fv2)
                      (set! fv1 r10)
                      (set! r10 fv1)
                      (set! fv0 r10)
                      (set! rax fv6)))
  (check-by-interp '(begin
                      (set! (rbp - 24) 2110471915)
                      (set! (rbp - 16) 1294488972)
                      (set! r10 (rbp - 16))
                      (set! r10 (* r10 0))
                      (set! (rbp - 16) r10)
                      (set! r10 (rbp - 16))
                      (set! (rbp - 8) r10)
                      (set! (rbp - 0) 1237875503)
                      (set! r10 -9223372036854775808)
                      (set! (rbp - 32) r10)
                      (set! rax (rbp - 32))))
  (check-by-interp '(begin
                      (set! fv10 1)
                      (set! fv10 (* fv10 9223372036854775807))
                      (set! fv9 fv10)
                      (set! fv8 -455579519)
                      (set! fv7 fv8)
                      (set! fv7 (+ fv7 0))
                      (set! fv6 fv7)
                      (set! fv5 1)
                      (set! fv4 -9223372036854775808)
                      (set! fv3 fv8)
                      (set! fv2 0)
                      (set! fv1 -9223372036854775808)
                      (set! fv0 1)
                      (halt -35514184)))
  (check-by-interp '(begin
                      (set! fv5 -1632076199)
                      (set! r10 fv5)
                      (set! r10 (+ r10 0))
                      (set! fv5 r10)
                      (set! r10 fv5)
                      (set! fv4 r10)
                      (set! fv3 0)
                      (set! fv2 1961579359)
                      (set! r10 fv2)
                      (set! r10 (+ r10 -1377521797))
                      (set! fv2 r10)
                      (set! r10 fv2)
                      (set! fv1 r10)
                      (set! r10 fv4)
                      (set! fv6 r10)
                      (set! fv0 1)
                      (set! rax fv6)))
  (check-by-interp '(module ()
                            (begin
                              (set! ball.8.2 1)
                              (set! tmp.7 9223372036854775807)
                              (set! tmp.7 (* tmp.7 1))
                              (set! bat.9.4 tmp.7)
                              (set! foobar.3.3 92301689)
                              (set! bat.9.6 2017243593)
                              (set! foobar.3.5 9223372036854775807)
                              (set! foobar.2.1 -1476120972)
                              (set! tmp.9 0)
                              (set! tmp.9 (* tmp.9 1))
                              (set! tmp.8 tmp.9)
                              (halt tmp.8))
                      ))
  (check-by-interp '(begin
                      (set! fv4 0)
                      (set! r10 fv4)
                      (set! r10 (* r10 123448674))
                      (set! fv4 r10)
                      (set! r10 fv4)
                      (set! fv3 r10)
                      (set! r10 -9223372036854775808)
                      (set! fv2 r10)
                      (set! r10 -9223372036854775808)
                      (set! fv1 r10)
                      (set! r10 fv1)
                      (set! fv0 r10)
                      (set! r10 fv0)
                      (set! r10 (+ r10 fv1))
                      (set! fv0 r10)
                      (set! r10 fv0)
                      (set! fv5 r10)
                      (set! rax fv5)))
  (check-by-interp '(begin
                      (set! (rbp - 24) 0)
                      (set! r10 (rbp - 24))
                      (set! r10 (* r10 0))
                      (set! (rbp - 24) r10)
                      (set! r10 (rbp - 24))
                      (set! (rbp - 32) r10)
                      (set! r10 -9223372036854775808)
                      (set! (rbp - 16) r10)
                      (set! r10 (rbp - 32))
                      (set! (rbp - 8) r10)
                      (set! r10 (rbp - 8))
                      (set! r10 (* r10 (rbp - 32)))
                      (set! (rbp - 8) r10)
                      (set! r10 (rbp - 8))
                      (set! (rbp - 0) r10)
                      (set! rax (rbp - 32))))
  (check-by-interp '(begin
                      (set! fv15 1)
                      (set! fv14 118010454)
                      (set! fv13 1)
                      (set! fv12 -9223372036854775808)
                      (set! fv11 fv13)
                      (set! fv10 fv15)
                      (set! fv9 fv15)
                      (set! fv8 -9223372036854775808)
                      (set! fv7 fv8)
                      (set! fv7 (* fv7 fv8))
                      (set! fv6 fv7)
                      (set! fv5 -1846872043)
                      (set! fv5 (+ fv5 fv8))
                      (set! fv4 fv5)
                      (set! fv3 0)
                      (set! fv2 fv8)
                      (set! fv1 -9223372036854775808)
                      (set! fv0 fv6)
                      (halt 1)))
  (check-by-interp '(module ()
                            (begin
                              (set! tmp.9 9223372036854775807)
                              (set! tmp.9 (* tmp.9 610664654))
                              (set! foobar.8.1 tmp.9)
                              (set! tmp.10 foobar.8.1)
                              (set! tmp.10 (* tmp.10 foobar.8.1))
                              (set! ball.2.5 tmp.10)
                              (set! ball.2.6 foobar.8.1)
                              (set! foobar.6.4 9223372036854775807)
                              (set! bat.0.8 foobar.8.1)
                              (set! ball.2.7 foobar.8.1)
                              (set! ball.2.3 foobar.8.1)
                              (set! foobar.1.2 1628045022)
                              (halt -400120723))
                      ))
  (check-by-interp '(begin
                      (set! (rbp - 32) 0)
                      (set! r10 (rbp - 32))
                      (set! r10 (* r10 123448674))
                      (set! (rbp - 32) r10)
                      (set! r10 (rbp - 32))
                      (set! (rbp - 24) r10)
                      (set! r10 -9223372036854775808)
                      (set! (rbp - 16) r10)
                      (set! r10 -9223372036854775808)
                      (set! (rbp - 8) r10)
                      (set! r10 (rbp - 8))
                      (set! (rbp - 0) r10)
                      (set! r10 (rbp - 0))
                      (set! r10 (+ r10 (rbp - 8)))
                      (set! (rbp - 0) r10)
                      (set! r10 (rbp - 0))
                      (set! (rbp - 40) r10)
                      (set! rax (rbp - 40))))
  (check-by-interp '(begin
                      (set! (rbp - 40) 1)
                      (set! r10 9223372036854775807)
                      (set! (rbp - 32) r10)
                      (set! (rbp - 24) 1)
                      (set! r10 (rbp - 24))
                      (set! r11 -9223372036854775808)
                      (set! r10 (+ r10 r11))
                      (set! (rbp - 24) r10)
                      (set! r10 (rbp - 24))
                      (set! (rbp - 48) r10)
                      (set! r10 (rbp - 32))
                      (set! (rbp - 16) r10)
                      (set! r10 (rbp - 16))
                      (set! r10 (+ r10 (rbp - 32)))
                      (set! (rbp - 16) r10)
                      (set! r10 (rbp - 16))
                      (set! (rbp - 8) r10)
                      (set! r10 (rbp - 48))
                      (set! (rbp - 0) r10)
                      (set! rax (rbp - 48))))
  (check-by-interp '(module (let ([bar.3.1 (let ([bar.2.3 1]
                                                 [bat.1.2 (let ([bar.3.6 118010454]
                                                                [bar.2.5 1]
                                                                [bat.9.4 -9223372036854775808])
                                                            bar.2.5)])
                                             (let ([bat.9.8 bar.2.3]
                                                   [bat.1.7 bar.2.3])
                                               -9223372036854775808))])
                              (let ([bat.9.11 (* bar.3.1 bar.3.1)]
                                    [bar.3.10 (+ -1846872043 bar.3.1)]
                                    [bar.5.9 (let ([bar.5.13 0]
                                                   [bar.3.12 bar.3.1])
                                               -9223372036854775808)])
                                (let ([bat.9.14 bat.9.11]) 1)))))
  (check-by-interp '(module ()
                            (begin
                              (set! tmp.13 0)
                              (set! tmp.13 (* tmp.13 -591471193))
                              (set! bat.0.7 tmp.13)
                              (set! bar.7.6 -1433160755)
                              (set! foobar.3.10 -1630730845)
                              (set! ball.5.9 1)
                              (set! bat.9.8 1)
                              (set! foobar.8.5 bat.9.8)
                              (set! foo.1.4 foobar.8.5)
                              (set! tmp.14 -9223372036854775808)
                              (set! tmp.14 (* tmp.14 215775010))
                              (set! foo.1.12 tmp.14)
                              (set! ball.5.11 foo.1.4)
                              (set! tmp.15 0)
                              (set! tmp.15 (+ tmp.15 foo.1.12))
                              (set! bat.0.3 tmp.15)
                              (set! tmp.16 1)
                              (set! tmp.16 (+ tmp.16 0))
                              (set! ball.5.2 tmp.16)
                              (set! bar.7.1 0)
                              (halt -9223372036854775808))
                      ))
  (check-by-interp '(begin
                      (set! fv15 0)
                      (set! r10 fv15)
                      (set! r10 (* r10 -591471193))
                      (set! fv15 r10)
                      (set! r10 fv15)
                      (set! fv14 r10)
                      (set! fv13 -1433160755)
                      (set! fv12 -1630730845)
                      (set! fv11 1)
                      (set! fv10 1)
                      (set! r10 fv10)
                      (set! fv9 r10)
                      (set! r10 fv9)
                      (set! fv8 r10)
                      (set! r10 -9223372036854775808)
                      (set! fv7 r10)
                      (set! r10 fv7)
                      (set! r10 (* r10 215775010))
                      (set! fv7 r10)
                      (set! r10 fv7)
                      (set! fv6 r10)
                      (set! r10 fv8)
                      (set! fv5 r10)
                      (set! fv4 0)
                      (set! r10 fv4)
                      (set! r10 (+ r10 fv6))
                      (set! fv4 r10)
                      (set! r10 fv4)
                      (set! fv3 r10)
                      (set! fv2 1)
                      (set! r10 fv2)
                      (set! r10 (+ r10 0))
                      (set! fv2 r10)
                      (set! r10 fv2)
                      (set! fv1 r10)
                      (set! fv0 0)
                      (set! rax -9223372036854775808)))
  (check-by-interp '(begin
                      (set! fv27 0)
                      (set! fv26 9223372036854775807)
                      (set! fv25 1617024596)
                      (set! fv25 (* fv25 9223372036854775807))
                      (set! fv24 fv25)
                      (set! fv23 fv27)
                      (set! fv23 (* fv23 fv26))
                      (set! fv22 fv23)
                      (set! fv21 fv27)
                      (set! fv21 (+ fv21 fv27))
                      (set! fv20 fv21)
                      (set! fv19 fv20)
                      (set! fv18 -1114020630)
                      (set! fv17 -2080084613)
                      (set! fv16 -9223372036854775808)
                      (set! fv15 -1656687642)
                      (set! fv14 fv19)
                      (set! fv13 1909787064)
                      (set! fv12 fv19)
                      (set! fv11 fv13)
                      (set! fv10 fv18)
                      (set! fv9 fv19)
                      (set! fv9 (* fv9 9223372036854775807))
                      (set! fv8 fv9)
                      (set! fv7 -9223372036854775808)
                      (set! fv7 (* fv7 fv19))
                      (set! fv6 fv7)
                      (set! fv5 fv8)
                      (set! fv4 748728232)
                      (set! fv3 fv10)
                      (set! fv2 fv10)
                      (set! fv1 9223372036854775807)
                      (set! fv0 1423178087)
                      (set! fv0 (* fv0 0))
                      (set! fv28 fv0)
                      (halt fv28)))
  (check-by-interp '(begin
                      (set! (rbp - 120) 0)
                      (set! r10 (rbp - 120))
                      (set! r10 (* r10 -591471193))
                      (set! (rbp - 120) r10)
                      (set! r10 (rbp - 120))
                      (set! (rbp - 112) r10)
                      (set! (rbp - 104) -1433160755)
                      (set! (rbp - 96) -1630730845)
                      (set! (rbp - 88) 1)
                      (set! (rbp - 80) 1)
                      (set! r10 (rbp - 80))
                      (set! (rbp - 72) r10)
                      (set! r10 (rbp - 72))
                      (set! (rbp - 64) r10)
                      (set! r10 -9223372036854775808)
                      (set! (rbp - 56) r10)
                      (set! r10 (rbp - 56))
                      (set! r10 (* r10 215775010))
                      (set! (rbp - 56) r10)
                      (set! r10 (rbp - 56))
                      (set! (rbp - 48) r10)
                      (set! r10 (rbp - 64))
                      (set! (rbp - 40) r10)
                      (set! (rbp - 32) 0)
                      (set! r10 (rbp - 32))
                      (set! r10 (+ r10 (rbp - 48)))
                      (set! (rbp - 32) r10)
                      (set! r10 (rbp - 32))
                      (set! (rbp - 24) r10)
                      (set! (rbp - 16) 1)
                      (set! r10 (rbp - 16))
                      (set! r10 (+ r10 0))
                      (set! (rbp - 16) r10)
                      (set! r10 (rbp - 16))
                      (set! (rbp - 8) r10)
                      (set! (rbp - 0) 0)
                      (set! rax -9223372036854775808)))
  (check-by-interp '(module ()
                            (begin
                              (set! bar.6.3 0)
                              (set! foo.4.2 9223372036854775807)
                              (set! tmp.23 1617024596)
                              (set! tmp.23 (* tmp.23 9223372036854775807))
                              (set! foo.1.6 tmp.23)
                              (set! tmp.24 bar.6.3)
                              (set! tmp.24 (* tmp.24 foo.4.2))
                              (set! bar.2.5 tmp.24)
                              (set! tmp.25 bar.6.3)
                              (set! tmp.25 (+ tmp.25 bar.6.3))
                              (set! foobar.0.4 tmp.25)
                              (set! bar.8.1 foobar.0.4)
                              (set! bar.3.12 -1114020630)
                              (set! foo.1.14 -2080084613)
                              (set! bar.8.13 -9223372036854775808)
                              (set! foo.1.11 -1656687642)
                              (set! foo.1.17 bar.8.1)
                              (set! bat.5.16 1909787064)
                              (set! foo.9.15 bar.8.1)
                              (set! bar.8.10 bat.5.16)
                              (set! foo.9.9 bar.3.12)
                              (set! tmp.26 bar.8.1)
                              (set! tmp.26 (* tmp.26 9223372036854775807))
                              (set! bar.3.8 tmp.26)
                              (set! tmp.27 -9223372036854775808)
                              (set! tmp.27 (* tmp.27 bar.8.1))
                              (set! foo.1.7 tmp.27)
                              (set! foo.9.19 bar.3.8)
                              (set! foo.9.22 748728232)
                              (set! bar.3.21 foo.9.9)
                              (set! bar.8.20 foo.9.9)
                              (set! bar.6.18 9223372036854775807)
                              (set! tmp.29 1423178087)
                              (set! tmp.29 (* tmp.29 0))
                              (set! tmp.28 tmp.29)
                              (halt tmp.28))
                      ))
  (check-by-interp
   '(module (let ([foo.2.2 (let ([ball.7.5 (+ -1819252534 0)]
                                 [foo.2.4 (+ 0 0)]
                                 [foobar.8.3 (let ([bar.1.7 1]
                                                   [foo.2.6 (+ 1 1878805388)])
                                               (+ foo.2.6 bar.1.7))])
                             ball.7.5)]
                  [bar.4.1 (let ([bar.5.10 (let ([foobar.8.13 (let ([bar.4.15 9223372036854775807]
                                                                    [bar.3.14 9223372036854775807])
                                                                bar.4.15)]
                                                 [ball.7.12 (* -236700244 9223372036854775807)]
                                                 [bar.3.11 (let ([bar.1.18 -162516402]
                                                                 [bar.4.17 1]
                                                                 [bar.3.16 -9223372036854775808])
                                                             bar.1.18)])
                                             (+ ball.7.12 1))]
                                 [bar.9.9 (+ -9223372036854775808 0)]
                                 [foobar.8.8 (let ()
                                               (let ([bar.1.20 -9223372036854775808]
                                                     [foobar.8.19 9223372036854775807])
                                                 -9223372036854775808))])
                             (let ([foo.2.22 bar.9.9]
                                   [bar.3.21 bar.9.9])
                               (let ([ball.7.25 9223372036854775807]
                                     [foo.2.24 1412459164]
                                     [bar.4.23 foobar.8.8])
                                 bar.4.23)))])
              (let ([bar.3.26 foo.2.2])
                (let ([foo.2.28 bar.4.1]
                      [bar.3.27 (* foo.2.2 1442357341)])
                  (let ([foobar.8.31 bar.3.27]
                        [bar.4.30 bar.4.1]
                        [bat.6.29 foo.2.28])
                    -241389399))))))
  (check-by-interp '(begin
                      (set! (rbp - 304) -1819252534)
                      (set! r10 (rbp - 304))
                      (set! r10 (+ r10 0))
                      (set! (rbp - 304) r10)
                      (set! r10 (rbp - 304))
                      (set! (rbp - 296) r10)
                      (set! (rbp - 288) 0)
                      (set! r10 (rbp - 288))
                      (set! r10 (+ r10 0))
                      (set! (rbp - 288) r10)
                      (set! r10 (rbp - 288))
                      (set! (rbp - 280) r10)
                      (set! (rbp - 272) 1)
                      (set! (rbp - 264) 1)
                      (set! r10 (rbp - 264))
                      (set! r10 (+ r10 1878805388))
                      (set! (rbp - 264) r10)
                      (set! r10 (rbp - 264))
                      (set! (rbp - 256) r10)
                      (set! r10 (rbp - 256))
                      (set! (rbp - 248) r10)
                      (set! r10 (rbp - 248))
                      (set! r10 (+ r10 (rbp - 272)))
                      (set! (rbp - 248) r10)
                      (set! r10 (rbp - 248))
                      (set! (rbp - 240) r10)
                      (set! r10 (rbp - 296))
                      (set! (rbp - 232) r10)
                      (set! r10 9223372036854775807)
                      (set! (rbp - 224) r10)
                      (set! r10 9223372036854775807)
                      (set! (rbp - 216) r10)
                      (set! r10 (rbp - 224))
                      (set! (rbp - 208) r10)
                      (set! (rbp - 200) -236700244)
                      (set! r10 (rbp - 200))
                      (set! r11 9223372036854775807)
                      (set! r10 (* r10 r11))
                      (set! (rbp - 200) r10)
                      (set! r10 (rbp - 200))
                      (set! (rbp - 192) r10)
                      (set! (rbp - 184) -162516402)
                      (set! (rbp - 176) 1)
                      (set! r10 -9223372036854775808)
                      (set! (rbp - 168) r10)
                      (set! r10 (rbp - 184))
                      (set! (rbp - 160) r10)
                      (set! r10 (rbp - 192))
                      (set! (rbp - 152) r10)
                      (set! r10 (rbp - 152))
                      (set! r10 (+ r10 1))
                      (set! (rbp - 152) r10)
                      (set! r10 (rbp - 152))
                      (set! (rbp - 144) r10)
                      (set! r10 -9223372036854775808)
                      (set! (rbp - 136) r10)
                      (set! r10 (rbp - 136))
                      (set! r10 (+ r10 0))
                      (set! (rbp - 136) r10)
                      (set! r10 (rbp - 136))
                      (set! (rbp - 128) r10)
                      (set! r10 -9223372036854775808)
                      (set! (rbp - 120) r10)
                      (set! r10 9223372036854775807)
                      (set! (rbp - 112) r10)
                      (set! r10 -9223372036854775808)
                      (set! (rbp - 104) r10)
                      (set! r10 (rbp - 128))
                      (set! (rbp - 96) r10)
                      (set! r10 (rbp - 128))
                      (set! (rbp - 88) r10)
                      (set! r10 9223372036854775807)
                      (set! (rbp - 80) r10)
                      (set! (rbp - 72) 1412459164)
                      (set! r10 (rbp - 104))
                      (set! (rbp - 64) r10)
                      (set! r10 (rbp - 64))
                      (set! (rbp - 56) r10)
                      (set! r10 (rbp - 232))
                      (set! (rbp - 48) r10)
                      (set! r10 (rbp - 56))
                      (set! (rbp - 40) r10)
                      (set! r10 (rbp - 232))
                      (set! (rbp - 32) r10)
                      (set! r10 (rbp - 32))
                      (set! r10 (* r10 1442357341))
                      (set! (rbp - 32) r10)
                      (set! r10 (rbp - 32))
                      (set! (rbp - 24) r10)
                      (set! r10 (rbp - 24))
                      (set! (rbp - 16) r10)
                      (set! r10 (rbp - 56))
                      (set! (rbp - 8) r10)
                      (set! r10 (rbp - 40))
                      (set! (rbp - 0) r10)
                      (set! rax -241389399)))

  ;;
  ;; START OF MILESTONE-1 generate-x64 TESTS
  (check-equal? (generate-x64 `(begin
                                 (set! rax 0)))
                "mov rax, 0\n")
  (check-equal? (generate-x64 `(begin
                                 (set! rax 0)
                                 (set! rax (+ rax 42))))
                "mov rax, 0\nadd rax, 42\n")
  (check-equal? (generate-x64 `(begin
                                 (set! rax ,(max-int 64))
                                 (set! rdi ,(min-int 64))
                                 (set! rdi rax)))
                "mov rax, 9223372036854775807\nmov rdi, -9223372036854775808\nmov rdi, rax\n")

  (check-equal? (generate-x64 `(begin
                                 (set! rax ,(max-int 64))
                                 (set! rdi ,(min-int 64))
                                 (set! rdi (+ rdi rax))))
                "mov rax, 9223372036854775807\nmov rdi, -9223372036854775808\nadd rdi, rax\n")
  (check-equal? (generate-x64 `(begin
                                 (set! rax 3)
                                 (set! rdi 2)
                                 (set! rdi (* rdi rax))))
                "mov rax, 3\nmov rdi, 2\nimul rdi, rax\n")

  (check-equal? (generate-x64 `(begin
                                 (set! rax -1)
                                 (set! rbx -1)
                                 (set! rbx (+ rbx ,(max-int 32)))))
                "mov rax, -1\nmov rbx, -1\nadd rbx, 2147483647\n")
  (check-equal? (generate-x64 `(begin
                                 (set! rcx -1)
                                 (set! rax rcx)
                                 (set! rcx (+ rcx ,(min-int 32)))))
                "mov rcx, -1\nmov rax, rcx\nadd rcx, -2147483648\n")
  (check-equal?
   (generate-x64 `(begin
                    (set! rdx 2)
                    (set! rsi 3)
                    (set! r11 4)
                    (set! rsi (* rsi rdx))
                    (set! r11 (+ r11 -1))
                    (set! r12 (+ r12 r11))
                    (set! rax r12)))
   "mov rdx, 2\nmov rsi, 3\nmov r11, 4\nimul rsi, rdx\nadd r11, -1\nadd r12, r11\nmov rax, r12\n")

  ;; END OF MILESTONE-1 generate-x64 TESTS
  (check-equal (generate-x64 '(begin
                                (set! (rbp - 0) 0)
                                (set! (rbp - 8) 42)
                                (set! rax (rbp - 0))
                                (set! rax (+ rax (rbp - 8)))))
               (~a "mov QWORD [rbp - 0], 0"
                   "mov QWORD [rbp - 8], 42"
                   "mov rax, QWORD [rbp - 0]"
                   "add rax, QWORD [rbp - 8]"
                   #:separator "\n"))
  (check-equal (generate-x64 '(begin
                                (set! (rbp - 0) -1)
                                (set! (rbp - 8) 42)
                                (set! rax (rbp - 0))
                                (set! rax (* rax (rbp - 8)))))
               (~a "mov QWORD [rbp - 0], -1"
                   "mov QWORD [rbp - 8], 42"
                   "mov rax, QWORD [rbp - 0]"
                   "imul rax, QWORD [rbp - 8]"
                   #:separator "\n"))

  (check-equal (generate-x64 '(begin
                                (set! (rbp - 8) ,(max-int 32))
                                (set! (rbp - 0) ,(min-int 32))
                                (set! rax (rbp - 0))
                                (set! rax (+ rax (rbp - 8)))))
               (~a "mov QWORD [rbp - 8], 2147483647\n"
                   "mov QWORD [rbp - 0], -2147483648\n"
                   "mov rax, QWORD [rbp - 0]"
                   "add rax, QWORD [rbp - 8]"
                   #:separator "\n")))
