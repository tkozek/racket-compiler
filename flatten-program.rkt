#lang racket

(require cpsc411/compiler-lib)

(provide flatten-program)

;; block-asm-lang-v4
; p	 	::=	 	(module b ... b)
;   b	 	::=	 	(define label tail)
;   tail	 	::=	 	(halt opand)
;  	 	|	 	(jump trg)
;  	 	|	 	(begin effect ... tail)
;  	 	|	 	(if (relop loc opand) (jump trg) (jump trg))
;   effect	 	::=	 	(set! loc triv)
;  	 	|	 	(set! loc_1 (binop loc_1 opand))
;   triv	 	::=	 	opand
;  	 	|	 	label
;   opand	 	::=	 	int64
;  	 	|	 	loc
;   trg	 	::=	 	label
;  	 	|	 	loc
;   loc	 	::=	 	reg
;  	 	|	 	fvar
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
;   binop	 	::=	 	*
;  	 	|	 	+
;   relop	 	::=	 	<
;  	 	|	 	<=
;  	 	|	 	=
;  	 	|	 	>=
;  	 	|	 	>
;  	 	|	 	!=
;   int64	 	::=	 	int64?
;   fvar	 	::=	 	fvar?
;   label	 	::=	 	label?
;; --------------------------
;; para-asm-lang-v4
; p	 	::=	 	(begin s ...)
;   s	 	::=	 	(halt opand)
;  	 	|	 	(set! loc triv)
;  	 	|	 	(set! loc_1 (binop loc_1 opand))
;  	 	|	 	(jump trg)
;  	 	|	 	(with-label label s)
;  	 	|	 	(compare loc opand)
;  	 	|	 	(jump-if relop trg)
;   triv	 	::=	 	opand
;  	 	|	 	label
;   opand	 	::=	 	int64
;  	 	|	 	loc
;   trg	 	::=	 	label
;  	 	|	 	loc
;   loc	 	::=	 	reg
;  	 	|	 	fvar
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
;   binop	 	::=	 	*
;  	 	|	 	+
;   relop	 	::=	 	<
;  	 	|	 	<=
;  	 	|	 	=
;  	 	|	 	>=
;  	 	|	 	>
;  	 	|	 	!=
;   int64	 	::=	 	int64?
;   fvar	 	::=	 	fvar?
;   label	 	::=	 	label?

(define reg? register?)
(define loc? (or/c reg? fvar?))
(define opand? (or/c int64? loc?))
(define triv? (or/c opand? label?))
(define trg? (or/c label? loc?))
(define (binop? b)
  (or (eq? b '+) (eq? b '*)))
;; block-asm-lang-v4 -> para-asm-lang-v4
;; Compile Block-asm-lang v4 to Para-asm-lang v4 by flattening basic blocks into labeled instructions.
(define (flatten-program bal4)
  (define flatten-effect identity)

  (define (flatten-tail tail)
    (match tail
      [`(halt ,(? opand?)) (list tail)]
      [`(jump ,(? trg?)) (list tail)]
      [`(begin
          ,fx* ...
          ,tail)
       (append (map flatten-effect fx*) (flatten-tail tail))]
      [`(if (,relop ,loc ,opand)
            (jump ,trg)
            (jump ,trg2))
       `((compare ,loc ,opand) (jump-if ,relop ,trg) (jump ,trg2))]))
  (define (flatten-b b)
    (match b
      [`(define ,(? label? label)
          ,tail)
       (let ([s* (flatten-tail tail)]) `((with-label ,label ,(first s*)) ,@(rest s*)))]))
  (define (flatten-p p)
    (match p
      [`(module ,b* ...
          ,b)
       `(begin
          ,@(foldr append '() (map flatten-b b*))
          ,@(flatten-b b))]))
  (flatten-p bal4))
(module+ test
  (require rackunit
           cpsc411/langs/v5)
  (define-syntax-rule (check-flatten-program bal4 pal4)
    (check-equal? (flatten-program bal4) pal4))
  (define-syntax-rule (check-by-interp bal4)
    (check-equal? (interp-block-asm-lang-v4 bal4) (interp-para-asm-lang-v4 (flatten-program bal4))))

  ;; M5 tests; Added by Trevor on March 8th 2026, multiple bindings allowed per let
  (check-by-interp '(module (define L.__main.4
                              (begin
                                (set! r15 -9223372036854775808)
                                (set! r14 0)
                                (jump L.__nested.3)))
                            (define L.fn.0.1
                              (begin
                                (set! r15 rdi)
                                (set! r15 rsi)
                                (set! r14 rdx)
                                (set! r13 rcx)
                                (set! r8 r8)
                                (set! r9 r9)
                                (set! r13 -502092639)
                                (if (= r13 r15)
                                    (jump L.__nested.5)
                                    (jump L.__nested.6))))
                      (define L.__nested.7 (halt 1852032564))
                      (define L.__nested.8 (halt -106704231))
                      (define L.__nested.5
                        (if (>= r14 1)
                            (jump L.__nested.7)
                            (jump L.__nested.8)))
                      (define L.__nested.6
                        (begin
                          (set! r15 r9)
                          (set! r15 (+ r15 1))
                          (set! r15 r15)
                          (halt r15)))
                      (define L.__nested.2 (halt -9223372036854775808))
                      (define L.__nested.3
                        (begin
                          (set! r15 -9223372036854775808)
                          (set! r15 1)
                          (set! r15 1)
                          (halt 1)))))
  (check-by-interp '(module (define L.__main.2
                              (begin
                                (set! r15 -9223372036854775808)
                                (set! r15 (+ r15 937267391))
                                (set! r15 r15)
                                (set! r14 -9223372036854775808)
                                (set! r14 (+ r14 -9223372036854775808))
                                (set! r14 r14)
                                (halt -335809824)))
                            (define L.tmp.0.1
                              (begin
                                (set! r15 rdi)
                                (set! r15 rsi)
                                (set! r13 rdx)
                                (set! r14 rcx)
                                (set! r14 r8)
                                (set! r9 r9)
                                (set! r15 r15)
                                (set! r15 (* r15 -1194246923))
                                (set! r15 r15)
                                (set! r13 r13)
                                (set! r9 r9)
                                (if (= r13 422731415)
                                    (jump L.tmp.3)
                                    (jump L.tmp.4))))
                      (define L.tmp.6
                        (begin
                          (set! r13 9223372036854775807)
                          (jump L.tmp.8)))
                      (define L.tmp.7
                        (begin
                          (set! r13 9223372036854775807)
                          (jump L.tmp.8)))
                      (define L.tmp.8 (jump L.tmp.5))
                      (define L.tmp.3
                        (begin
                          (set! r13 9223372036854775807)
                          (jump L.tmp.6)))
                      (define L.tmp.4
                        (begin
                          (set! r13 r9)
                          (set! r13 (+ r13 52582991))
                          (set! r13 r13)
                          (jump L.tmp.5)))
                      (define L.tmp.5
                        (begin
                          (set! r9 r9)
                          (set! r8 r14)
                          (set! rcx 0)
                          (set! rdx -1002513727)
                          (set! rsi -191435828)
                          (set! rdi r15)
                          (jump L.tmp.0.1)))))
  (check-by-interp '(module (define L.__main.3
                              (begin
                                (set! r15 2142022224)
                                (set! r15 0)
                                (set! r14 1)
                                (set! r15 r15)
                                (set! r15 1)
                                (set! r15 (+ r15 121573080))
                                (set! r15 r15)
                                (set! r15 9223372036854775807)
                                (set! r15 (* r15 -1355489058))
                                (set! r15 r15)
                                (halt 0)))
                            (define L.proc.0.1
                              (begin
                                (set! r14 rdi)
                                (set! r15 rsi)
                                (set! r13 rdx)
                                (set! r9 1554173211)
                                (set! r9 616342412)
                                (set! r9 r9)
                                (if (= r13 r14)
                                    (jump L.tmp.9)
                                    (jump L.tmp.10))))
                      (define L.__nested.4 (halt 0))
                      (define L.__nested.5 (halt 0))
                      (define L.tmp.9
                        (begin
                          (set! r14 r13)
                          (jump L.tmp.11)))
                      (define L.tmp.10
                        (begin
                          (set! r14 r15)
                          (jump L.tmp.11)))
                      (define L.tmp.11
                        (begin
                          (set! r14 1)
                          (jump L.tmp.7)))
                      (define L.tmp.6
                        (begin
                          (set! r15 r15)
                          (jump L.tmp.8)))
                      (define L.tmp.7
                        (begin
                          (set! r15 0)
                          (jump L.tmp.8)))
                      (define L.tmp.8
                        (begin
                          (set! r15 1320805275)
                          (jump L.__nested.4)))
                      (define L.tmp.1.2
                        (begin
                          (set! r15 rdi)
                          (set! r15 rsi)
                          (set! r15 rdx)
                          (set! r15 rcx)
                          (set! r14 r8)
                          (set! rdx r14)
                          (set! rsi 9223372036854775807)
                          (set! rdi r15)
                          (jump L.proc.0.1)))))
  (check-by-interp '(module (define L.__main.4
                              (begin
                                (set! r15 0)
                                (set! r15 (+ r15 9223372036854775807))
                                (set! r15 r15)
                                (set! r14 -678062995)
                                (set! r14 0)
                                (jump L.tmp.1)))
                            (define L.tmp.1
                              (begin
                                (set! r14 -2004574473)
                                (jump L.tmp.3)))
                      (define L.tmp.2
                        (begin
                          (set! r14 9223372036854775807)
                          (jump L.tmp.3)))
                      (define L.tmp.3
                        (begin
                          (set! r14 1)
                          (set! r14 (* r14 r15))
                          (set! r15 r14)
                          (halt 9223372036854775807)))))
  (check-by-interp '(module (define L.__main.6
                              (begin
                                (set! r15 -9223372036854775808)
                                (set! r14 9223372036854775807)
                                (set! r15 r15)
                                (set! r15 -1846550218)
                                (jump L.tmp.4)))
                            (define L.fn.0.1
                              (begin
                                (set! r15 rdi)
                                (set! r15 rsi)
                                (set! r14 rdx)
                                (set! rdx r15)
                                (set! rsi r14)
                                (set! rdi r15)
                                (jump L.fn.0.1)))
                      (define L.tmp.1.2
                        (begin
                          (set! r15 -918704320)
                          (set! r15 -1822595193)
                          (set! r15 r15)
                          (set! r15 0)
                          (set! r15 9223372036854775807)
                          (set! r15 (* r15 810114007))
                          (set! r14 r15)
                          (set! r15 1)
                          (set! r15 r14)
                          (set! r15 1)
                          (halt 1271317139)))
                      (define L.tmp.3
                        (begin
                          (set! r15 -186139937)
                          (jump L.tmp.5)))
                      (define L.tmp.4
                        (begin
                          (set! r15 1)
                          (jump L.tmp.5)))
                      (define L.tmp.5
                        (begin
                          (set! r15 1884722986)
                          (set! r15 9223372036854775807)
                          (halt 0)))))
  (check-by-interp '(module (define L.__main.3
                              (begin
                                (set! rsi 0)
                                (set! rdi -9223372036854775808)
                                (jump L.func.1.2)))
                            (define L.func.0.1
                              (begin
                                (set! r15 rdi)
                                (set! r14 rsi)
                                (set! r14 rdx)
                                (set! r14 rcx)
                                (set! r14 r8)
                                (set! r14 r9)
                                (halt r15)))
                      (define L.func.1.2
                        (begin
                          (set! r15 rdi)
                          (set! r14 rsi)
                          (set! r13 0)
                          (set! r15 r15)
                          (set! r13 1492712685)
                          (set! r15 r15)
                          (set! r13 9223372036854775807)
                          (set! r13 r13)
                          (set! r14 r14)
                          (set! r15 r15)
                          (set! r13 -383652955)
                          (set! r13 -9223372036854775808)
                          (set! r13 r14)
                          (set! r13 (+ r13 566306668))
                          (set! r13 r13)
                          (if (!= r14 0)
                              (jump L.tmp.4)
                              (jump L.tmp.5))))
                      (define L.tmp.4
                        (begin
                          (set! r14 -9223372036854775808)
                          (jump L.tmp.6)))
                      (define L.tmp.5
                        (begin
                          (set! r14 r14)
                          (jump L.tmp.6)))
                      (define L.tmp.6
                        (begin
                          (set! r15 r15)
                          (halt r14)))))
  (check-by-interp '(module (define L.__main.2 (halt 9223372036854775807))
                            (define L.tmp.0.1
                              (begin
                                (set! r15 rdi)
                                (set! r14 rsi)
                                (set! r14 rdx)
                                (set! rdi rcx)
                                (set! r13 r8)
                                (set! r9 r9)
                                (set! r9 rdi)
                                (set! r9 1)
                                (if (!= r9 r15)
                                    (jump L.tmp.7)
                                    (jump L.tmp.8))))
                      (define L.tmp.7
                        (begin
                          (set! r15 -494940107)
                          (if (<= r15 r13)
                              (jump L.__nested.3)
                              (jump L.__nested.4))))
                      (define L.tmp.8
                        (begin
                          (set! r15 0)
                          (jump L.__nested.3)))
                      (define L.__nested.5 (halt 9223372036854775807))
                      (define L.__nested.6 (halt -9223372036854775808))
                      (define L.__nested.3 (halt -777687734))
                      (define L.__nested.4
                        (begin
                          (set! r15 -9223372036854775808)
                          (if (> r15 r14)
                              (jump L.__nested.5)
                              (jump L.__nested.6))))))
  (check-by-interp '(module (define L.__main.1
                              (begin
                                (set! r15 1)
                                (set! r15 0)
                                (halt 356048754)))))
  (check-by-interp '(module (define L.__main.6
                              (begin
                                (set! r15 512244517)
                                (jump L.__nested.5)))
                            (define L.fn.0.1
                              (begin
                                (set! r15 -9223372036854775808)
                                (set! r15 (* r15 0))
                                (set! r15 r15)
                                (set! r14 0)
                                (set! r13 9223372036854775807)
                                (set! r14 r14)
                                (set! r14 1)
                                (set! r14 -9223372036854775808)
                                (set! r14 0)
                                (set! r14 0)
                                (set! r13 2146083242)
                                (set! r13 (+ r13 1877941467))
                                (set! r13 r13)
                                (set! r9 1)
                                (jump L.tmp.9)))
                      (define L.__nested.7 (halt 1))
                      (define L.__nested.8 (halt -9223372036854775808))
                      (define L.tmp.9
                        (begin
                          (set! r14 r14)
                          (jump L.tmp.11)))
                      (define L.tmp.10
                        (begin
                          (set! r14 r13)
                          (jump L.tmp.11)))
                      (define L.tmp.11
                        (begin
                          (set! r13 9223372036854775807)
                          (set! r13 1)
                          (set! r15 r15)
                          (set! r15 r13)
                          (set! r15 r14)
                          (set! r15 -80057626)
                          (set! r15 451403960)
                          (set! r15 0)
                          (set! r15 -9223372036854775808)
                          (set! r15 0)
                          (if (= r15 r14)
                              (jump L.__nested.7)
                              (jump L.__nested.8))))
                      (define L.func.1.2
                        (begin
                          (set! r15 rdi)
                          (set! r15 rsi)
                          (set! r15 rdx)
                          (set! r14 rcx)
                          (set! r14 r8)
                          (set! r14 r9)
                          (set! r14 fv0)
                          (set! r14 -68053908)
                          (jump L.__nested.13)))
                      (define L.__nested.12
                        (begin
                          (set! rcx r15)
                          (set! rdx 2037093174)
                          (set! rsi 2020389049)
                          (set! rdi 0)
                          (jump L.func.2.3)))
                      (define L.__nested.13 (jump L.fn.0.1))
                      (define L.func.2.3
                        (begin
                          (set! r14 rdi)
                          (set! r15 rsi)
                          (set! r13 rdx)
                          (set! r9 rcx)
                          (set! r9 1683456577)
                          (set! r9 0)
                          (set! r9 572391381)
                          (set! r9 9223372036854775807)
                          (if (>= r9 r14)
                              (jump L.tmp.14)
                              (jump L.tmp.15))))
                      (define L.tmp.14
                        (begin
                          (set! r14 -2023903597)
                          (jump L.tmp.16)))
                      (define L.tmp.15
                        (begin
                          (set! r14 -15104029)
                          (jump L.tmp.16)))
                      (define L.tmp.16
                        (begin
                          (set! r14 1)
                          (set! r14 r13)
                          (set! r14 0)
                          (set! r14 r15)
                          (set! r14 (+ r14 r15))
                          (set! r14 r14)
                          (set! r14 1)
                          (set! r14 (+ r14 r15))
                          (set! r15 r14)
                          (halt r15)))
                      (define L.__nested.4
                        (begin
                          (set! r15 1283186732)
                          (set! r14 99039009)
                          (set! r14 1811100583)
                          (halt 1283186732)))
                      (define L.__nested.5
                        (begin
                          (set! r15 1)
                          (set! r15 -9223372036854775808)
                          (set! r15 1)
                          (halt 1)))))
  (check-by-interp '(module (define L.__main.6
                              (begin
                                (set! r15 1)
                                (jump L.__nested.4)))
                            (define L.proc.0.1
                              (begin
                                (set! r15 rdi)
                                (set! r14 rsi)
                                (set! r13 rdx)
                                (set! r13 rcx)
                                (set! r13 r8)
                                (set! r9 9223372036854775807)
                                (set! r8 r15)
                                (set! rcx -9223372036854775808)
                                (set! rdx 1)
                                (set! rsi r14)
                                (set! rdi r13)
                                (jump L.proc.2.3)))
                      (define L.x.1.2
                        (begin
                          (set! r14 rdi)
                          (set! r15 rsi)
                          (if (< r14 r14)
                              (jump L.tmp.7)
                              (jump L.tmp.8))))
                      (define L.tmp.7
                        (begin
                          (set! r15 r14)
                          (jump L.tmp.9)))
                      (define L.tmp.8
                        (begin
                          (set! r15 r14)
                          (jump L.tmp.9)))
                      (define L.tmp.9
                        (begin
                          (set! r14 r14)
                          (set! r14 (* r14 -1298566605))
                          (set! r14 r14)
                          (set! r14 0)
                          (set! r15 r15)
                          (set! r15 (* r15 r15))
                          (set! r15 r15)
                          (halt r15)))
                      (define L.proc.2.3
                        (begin
                          (set! r15 rdi)
                          (set! r15 rsi)
                          (set! r15 rdx)
                          (set! r15 rcx)
                          (set! r15 r8)
                          (set! r14 r9)
                          (set! r15 r15)
                          (set! r15 (+ r15 -9223372036854775808))
                          (set! r15 r15)
                          (halt r15)))
                      (define L.__nested.4 (halt -9223372036854775808))
                      (define L.__nested.5 (halt -1627211406))))
  (check-by-interp '(module (define L.__main.4
                              (begin
                                (set! r15 -1755065230)
                                (set! r15 9223372036854775807)
                                (set! r14 0)
                                (set! r15 r15)
                                (set! r15 -9223372036854775808)
                                (set! r14 -9223372036854775808)
                                (set! r14 1)
                                (jump L.__nested.3)))
                            (define L.x.0.1
                              (begin
                                (set! r15 rdi)
                                (set! r14 -508084756)
                                (set! r15 r15)
                                (set! r13 1)
                                (set! r14 r14)
                                (set! r15 r15)
                                (set! r14 1120136428)
                                (set! r14 606194936)
                                (set! r14 -908142049)
                                (set! r14 600266106)
                                (set! r14 (+ r14 r15))
                                (set! r14 r14)
                                (set! r15 r15)
                                (set! r15 0)
                                (halt 1)))
                      (define L.__nested.2 (halt -9223372036854775808))
                      (define L.__nested.3 (halt -9223372036854775808))))
  (check-by-interp '(module (define L.__main.4
                              (begin
                                (set! r15 993422572)
                                (set! r15 (* r15 1))
                                (set! r15 r15)
                                (set! r14 92310708)
                                (jump L.tmp.1)))
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
                          (set! r14 9223372036854775807)
                          (set! r14 (+ r14 -1759699484))
                          (set! r14 r14)
                          (set! r15 r15)
                          (set! r14 -9223372036854775808)
                          (halt 993422572)))))
  (check-by-interp '(module (define L.__main.3 (jump L.x.1.2))
                            (define L.func.0.1
                              (begin
                                (set! r15 rdi)
                                (set! r14 -9223372036854775808)
                                (set! r14 (+ r14 -9223372036854775808))
                                (set! r14 r14)
                                (set! r14 r15)
                                (set! r14 (+ r14 1312056768))
                                (set! r14 r14)
                                (set! r13 1)
                                (if (<= r13 r14)
                                    (jump L.tmp.8)
                                    (jump L.tmp.9))))
                      (define L.tmp.6
                        (begin
                          (set! r9 0)
                          (if (< r9 r15)
                              (jump L.__nested.4)
                              (jump L.__nested.5))))
                      (define L.tmp.7
                        (begin
                          (set! r9 1880363761)
                          (jump L.__nested.4)))
                      (define L.__nested.4
                        (begin
                          (set! r13 1)
                          (set! r14 r14)
                          (halt r15)))
                      (define L.__nested.5
                        (begin
                          (set! r14 r13)
                          (set! r14 (+ r14 r15))
                          (set! r15 r14)
                          (halt r15)))
                      (define L.tmp.8
                        (begin
                          (set! r13 -9223372036854775808)
                          (jump L.tmp.10)))
                      (define L.tmp.9
                        (begin
                          (set! r13 -50606571)
                          (jump L.tmp.10)))
                      (define L.tmp.10
                        (begin
                          (set! r15 r15)
                          (set! r14 r15)
                          (if (>= r15 r15)
                              (jump L.tmp.6)
                              (jump L.tmp.7))))
                      (define L.x.1.2 (halt -9223372036854775808))))
  (check-by-interp '(module (define L.__main.4
                              (begin
                                (set! r15 9223372036854775807)
                                (jump L.__nested.2)))
                            (define L.x.0.1
                              (begin
                                (set! r15 rdi)
                                (set! r14 rsi)
                                (set! r14 rdx)
                                (set! rdx 0)
                                (set! rsi r15)
                                (set! rdi r14)
                                (jump L.x.0.1)))
                      (define L.__nested.2
                        (begin
                          (set! r15 0)
                          (set! r15 213435043)
                          (halt -9223372036854775808)))
                      (define L.__nested.3 (halt 0))))
  (check-by-interp '(module (define L.__main.3
                              (begin
                                (set! r15 1946235623)
                                (jump L.__nested.1)))
                            (define L.__nested.1
                              (begin
                                (set! r15 -135046761)
                                (set! r14 1453915451)
                                (set! r15 257292075)
                                (halt 1453915451)))
                      (define L.__nested.2 (halt -9223372036854775808))))
  (check-by-interp '(module (define L.__main.2
                              (begin
                                (set! r15 1)
                                (set! r15 (* r15 9223372036854775807))
                                (set! r15 r15)
                                (halt 9223372036854775807)))
                            (define L.proc.0.1
                              (begin
                                (set! r15 rdi)
                                (set! r15 rsi)
                                (set! r14 rdx)
                                (halt r15)))
                      ))
  (check-by-interp '(module (define L.__main.3 (halt -1263415267))
                            (define L.proc.0.1
                              (begin
                                (set! r15 rdi)
                                (set! r14 rsi)
                                (set! r14 rdx)
                                (set! r14 rcx)
                                (set! r13 r8)
                                (set! r13 r9)
                                (set! fv0 1165846535)
                                (set! r9 r14)
                                (set! r8 r15)
                                (set! rcx 1407333795)
                                (set! rdx 0)
                                (set! rsi r15)
                                (set! rdi 1843221563)
                                (jump L.func.1.2)))
                      (define L.func.1.2
                        (begin
                          (set! r15 rdi)
                          (set! r15 rsi)
                          (set! r15 rdx)
                          (set! r15 rcx)
                          (set! r14 r8)
                          (set! r14 r9)
                          (set! r13 fv0)
                          (set! r13 -9223372036854775808)
                          (set! r13 (* r13 r14))
                          (set! r13 r13)
                          (set! r14 r14)
                          (set! r15 r15)
                          (set! fv0 r14)
                          (set! r9 -811936434)
                          (set! r8 r14)
                          (set! rcx r14)
                          (set! rdx r14)
                          (set! rsi 0)
                          (set! rdi -9223372036854775808)
                          (jump L.func.1.2)))))
  (check-by-interp '(module (define L.__main.8
                              (begin
                                (set! r15 0)
                                (set! r15 (* r15 1192307430))
                                (set! r15 r15)
                                (set! r14 -9223372036854775808)
                                (jump L.tmp.5)))
                            (define L.proc.0.1
                              (begin
                                (set! r15 rdi)
                                (set! r15 rsi)
                                (set! rdi -9223372036854775808)
                                (jump L.tmp.1.2)))
                      (define L.tmp.1.2
                        (begin
                          (set! r15 rdi)
                          (set! r14 9223372036854775807)
                          (if (!= r14 r15)
                              (jump L.__nested.9)
                              (jump L.__nested.10))))
                      (define L.__nested.9
                        (begin
                          (set! r14 2026709313)
                          (set! r15 r15)
                          (set! r15 r15)
                          (halt r15)))
                      (define L.__nested.10 (halt 9223372036854775807))
                      (define L.__nested.3 (halt 0))
                      (define L.__nested.4 (halt 0))
                      (define L.tmp.5
                        (begin
                          (set! r14 -9223372036854775808)
                          (jump L.tmp.7)))
                      (define L.tmp.6
                        (begin
                          (set! r14 2088471563)
                          (jump L.tmp.7)))
                      (define L.tmp.7
                        (begin
                          (set! r14 1)
                          (set! r14 9223372036854775807)
                          (set! r14 1861500702)
                          (set! r14 9223372036854775807)
                          (jump L.__nested.3)))))
  (check-by-interp '(module (define L.__main.4 (halt 9223372036854775807))
                            (define L.proc.0.1
                              (begin
                                (set! r15 rdi)
                                (set! r14 1)
                                (if (> r14 r15)
                                    (jump L.__nested.5)
                                    (jump L.__nested.6))))
                      (define L.__nested.5 (halt 822960898))
                      (define L.__nested.6 (halt r15))
                      (define L.fn.1.2
                        (begin
                          (set! r13 rdi)
                          (set! r15 rsi)
                          (set! r14 rdx)
                          (set! r15 -1983872386)
                          (set! r15 r13)
                          (set! r15 r15)
                          (set! r14 9223372036854775807)
                          (set! r14 -9223372036854775808)
                          (set! r14 1)
                          (set! r14 0)
                          (if (>= r15 r15)
                              (jump L.__nested.7)
                              (jump L.__nested.8))))
                      (define L.__nested.7 (halt -9223372036854775808))
                      (define L.__nested.8 (halt 0))
                      (define L.fn.2.3
                        (begin
                          (set! r15 rdi)
                          (set! r14 rsi)
                          (set! r13 rdx)
                          (set! rdi rcx)
                          (set! r8 r8)
                          (set! r9 r9)
                          (set! r9 r14)
                          (set! r8 r13)
                          (set! rcx 968969801)
                          (set! rdx r14)
                          (set! rsi r14)
                          (set! rdi r15)
                          (jump L.fn.2.3)))))
  (check-by-interp '(module (define L.__main.3
                              (begin
                                (set! r15 1622421353)
                                (jump L.__nested.2)))
                            (define L.__nested.1
                              (begin
                                (set! r15 -2027378735)
                                (set! r15 9223372036854775807)
                                (halt 9223372036854775807)))
                      (define L.__nested.2
                        (begin
                          (set! r15 -9223372036854775808)
                          (set! r15 1)
                          (halt 9223372036854775807)))))
  (check-by-interp '(module (define L.__main.1
                              (begin
                                (set! r15 -1915251883)
                                (set! r15 (* r15 1))
                                (set! r15 r15)
                                (set! r14 -9223372036854775808)
                                (set! r14 356482613)
                                (set! r14 9223372036854775807)
                                (set! r14 r14)
                                (set! r14 r14)
                                (set! r15 r15)
                                (set! r15 -1601764542)
                                (halt -9223372036854775808)))))
  (check-by-interp '(module (define L.__main.6
                              (begin
                                (set! r15 -9223372036854775808)
                                (jump L.__nested.2)))
                            (define L.func.0.1
                              (begin
                                (set! r13 rdi)
                                (set! r15 rsi)
                                (set! rdi rdx)
                                (set! rdx rcx)
                                (set! rsi r8)
                                (set! r14 r9)
                                (if (> r15 r13)
                                    (jump L.tmp.9)
                                    (jump L.tmp.10))))
                      (define L.tmp.11
                        (if (>= rdx r14)
                            (jump L.__nested.7)
                            (jump L.__nested.8)))
                      (define L.tmp.12
                        (if (< rdi 1)
                            (jump L.__nested.7)
                            (jump L.__nested.8)))
                      (define L.tmp.9
                        (begin
                          (set! r13 -1032056006)
                          (if (= r13 rsi)
                              (jump L.tmp.11)
                              (jump L.tmp.12))))
                      (define L.tmp.10
                        (begin
                          (set! r13 1)
                          (if (>= r13 rdi)
                              (jump L.__nested.7)
                              (jump L.__nested.8))))
                      (define L.__nested.7
                        (begin
                          (set! r9 rdi)
                          (set! r8 r14)
                          (set! rcx 1807204646)
                          (set! rdx r15)
                          (set! rsi -675302553)
                          (set! rdi 0)
                          (jump L.func.0.1)))
                      (define L.__nested.8
                        (begin
                          (set! r9 9223372036854775807)
                          (set! r8 -9223372036854775808)
                          (set! rcx rsi)
                          (set! rdx r14)
                          (set! rsi -41674885)
                          (set! rdi r14)
                          (jump L.func.0.1)))
                      (define L.__nested.4 (halt 0))
                      (define L.__nested.5 (halt 9223372036854775807))
                      (define L.__nested.2
                        (begin
                          (set! r15 9223372036854775807)
                          (set! r15 0)
                          (set! r15 9223372036854775807)
                          (halt 9223372036854775807)))
                      (define L.__nested.3
                        (begin
                          (set! r15 -235413122)
                          (jump L.__nested.5)))))
  (check-by-interp '(module (define L.__main.7
                              (begin
                                (set! r15 1)
                                (jump L.tmp.6)))
                            (define L.fn.0.1
                              (begin
                                (set! r15 rdi)
                                (set! rsi r15)
                                (set! rdi r15)
                                (jump L.x.1.2)))
                      (define L.x.1.2
                        (begin
                          (set! r15 rdi)
                          (set! r14 rsi)
                          (set! r14 r14)
                          (set! r14 9223372036854775807)
                          (set! r15 r15)
                          (set! r15 9223372036854775807)
                          (set! r15 -2115998024)
                          (halt -1101891150)))
                      (define L.tmp.5
                        (begin
                          (set! r15 -9223372036854775808)
                          (jump L.__nested.4)))
                      (define L.tmp.6
                        (begin
                          (set! r15 -1520052689)
                          (jump L.__nested.3)))
                      (define L.__nested.3
                        (begin
                          (set! r15 -9223372036854775808)
                          (set! r14 9223372036854775807)
                          (set! r14 744570222)
                          (halt -9223372036854775808)))
                      (define L.__nested.4
                        (begin
                          (set! r15 -133225634)
                          (set! r14 -9223372036854775808)
                          (set! r14 -9223372036854775808)
                          (halt -133225634)))))
  (check-by-interp '(module (define L.__main.3
                              (begin
                                (set! r15 9223372036854775807)
                                (set! r14 1)
                                (set! r14 -9223372036854775808)
                                (set! r14 9223372036854775807)
                                (set! r14 1)
                                (set! r14 -1722042928)
                                (set! r14 0)
                                (set! r14 1)
                                (set! r14 -1508403451)
                                (jump L.__nested.1)))
                            (define L.__nested.1 (halt 447579047))
                      (define L.__nested.2 (halt 9223372036854775807))))
  (check-by-interp '(module (define L.__main.2
                              (begin
                                (set! r15 9223372036854775807)
                                (set! r15 (+ r15 -1932027129))
                                (set! r15 r15)
                                (halt 9223372034922748678)))
                            (define L.tmp.0.1
                              (begin
                                (set! r15 rdi)
                                (set! r14 rsi)
                                (set! r14 rdx)
                                (set! r13 rcx)
                                (set! rcx r15)
                                (set! rdx r14)
                                (set! rsi r14)
                                (set! rdi 9223372036854775807)
                                (jump L.tmp.0.1)))
                      ))
  (check-by-interp '(module (define L.__main.4
                              (begin
                                (set! rsi 9223372036854775807)
                                (set! rdi -1129269775)
                                (jump L.func.0.1)))
                            (define L.func.0.1
                              (begin
                                (set! r15 rdi)
                                (set! r14 rsi)
                                (set! rcx r15)
                                (set! rdx -436836322)
                                (set! rsi r14)
                                (set! rdi r15)
                                (jump L.fn.1.2)))
                      (define L.fn.1.2
                        (begin
                          (set! r15 rdi)
                          (set! r13 rsi)
                          (set! r14 rdx)
                          (set! r9 rcx)
                          (set! r15 182929845)
                          (if (> r15 r13)
                              (jump L.tmp.7)
                              (jump L.tmp.8))))
                      (define L.tmp.7
                        (if (>= r14 1)
                            (jump L.__nested.5)
                            (jump L.__nested.6)))
                      (define L.tmp.8
                        (begin
                          (set! r15 -767224240)
                          (jump L.__nested.5)))
                      (define L.__nested.5
                        (begin
                          (set! r15 r14)
                          (set! r15 (+ r15 -9223372036854775808))
                          (set! r15 r15)
                          (halt r15)))
                      (define L.__nested.6 (halt r14))
                      (define L.x.2.3
                        (begin
                          (set! r15 0)
                          (jump L.__nested.9)))
                      (define L.__nested.11 (halt -9223372036854775808))
                      (define L.__nested.12 (halt 1))
                      (define L.tmp.13
                        (begin
                          (set! r15 9223372036854775807)
                          (jump L.tmp.15)))
                      (define L.tmp.14
                        (begin
                          (set! r15 1)
                          (jump L.tmp.15)))
                      (define L.tmp.15
                        (begin
                          (set! r14 0)
                          (set! r14 (* r14 0))
                          (set! r14 r14)
                          (set! r14 1942355770)
                          (set! r14 (* r14 9223372036854775807))
                          (set! r14 r14)
                          (if (>= r15 9223372036854775807)
                              (jump L.__nested.11)
                              (jump L.__nested.12))))
                      (define L.__nested.9 (halt 1083014636))
                      (define L.__nested.10
                        (begin
                          (set! r15 1)
                          (jump L.tmp.13)))))
  (check-by-interp '(module (define L.__main.6
                              (begin
                                (set! r15 1)
                                (set! r15 (+ r15 -1806804688))
                                (set! r15 r15)
                                (set! r14 1880531761)
                                (set! r14 (+ r14 1))
                                (set! r14 r14)
                                (set! r14 0)
                                (jump L.__nested.5)))
                            (define L.proc.0.1
                              (begin
                                (set! r15 1)
                                (set! r15 (* r15 0))
                                (set! r14 r15)
                                (set! r15 -9223372036854775808)
                                (jump L.__nested.7)))
                      (define L.__nested.7 (halt -9223372036854775808))
                      (define L.__nested.8
                        (begin
                          (set! rdx 0)
                          (set! rsi 1)
                          (set! rdi 0)
                          (jump L.proc.2.3)))
                      (define L.fn.1.2
                        (begin
                          (set! r15 rdi)
                          (set! r14 rsi)
                          (set! r13 rdx)
                          (set! rdi rcx)
                          (set! r13 r8)
                          (set! r8 r9)
                          (set! r9 fv0)
                          (set! r8 -1156972119)
                          (if (!= r8 r13)
                              (jump L.tmp.16)
                              (jump L.tmp.17))))
                      (define L.tmp.16
                        (begin
                          (set! r14 9223372036854775807)
                          (if (> r14 r15)
                              (jump L.__nested.9)
                              (jump L.__nested.10))))
                      (define L.tmp.17
                        (begin
                          (set! r8 1703616983)
                          (if (!= r8 r14)
                              (jump L.__nested.9)
                              (jump L.__nested.10))))
                      (define L.__nested.11 (halt 9223372036854775807))
                      (define L.__nested.12 (halt 0))
                      (define L.tmp.13
                        (begin
                          (set! r14 0)
                          (jump L.tmp.15)))
                      (define L.tmp.14
                        (begin
                          (set! r14 -9223372036854775808)
                          (jump L.tmp.15)))
                      (define L.tmp.15
                        (if (>= r15 -2080421634)
                            (jump L.__nested.11)
                            (jump L.__nested.12)))
                      (define L.__nested.9
                        (begin
                          (set! r14 r9)
                          (set! r14 -144518674)
                          (set! r14 rdi)
                          (set! r14 r13)
                          (if (< r15 9223372036854775807)
                              (jump L.tmp.13)
                              (jump L.tmp.14))))
                      (define L.__nested.10 (halt -274219017))
                      (define L.proc.2.3
                        (begin
                          (set! r15 rdi)
                          (set! r15 rsi)
                          (set! r14 rdx)
                          (set! r15 r15)
                          (set! r15 (+ r15 9223372036854775807))
                          (set! r15 r15)
                          (halt r15)))
                      (define L.__nested.4 (halt 0))
                      (define L.__nested.5 (halt 9223372036854775807))))
  (check-by-interp '(module (define L.__main.3
                              (begin
                                (set! r15 -107521481)
                                (jump L.__nested.1)))
                            (define L.__nested.1
                              (begin
                                (set! r15 1275956981)
                                (set! r15 (* r15 1))
                                (set! r15 r15)
                                (halt 1275956981)))
                      (define L.__nested.2
                        (begin
                          (set! r15 1318401057)
                          (set! r15 -542033033)
                          (halt -288327503)))))
  (check-by-interp '(module (define L.__main.8
                              (begin
                                (set! r15 1517267005)
                                (jump L.tmp.6)))
                            (define L.fn.0.1
                              (begin
                                (set! r15 9223372036854775807)
                                (set! r14 684249837)
                                (set! r14 1)
                                (set! r13 2084897481)
                                (jump L.tmp.16)))
                      (define L.tmp.15
                        (begin
                          (set! r15 r15)
                          (jump L.tmp.17)))
                      (define L.tmp.16
                        (begin
                          (set! r15 r14)
                          (jump L.tmp.17)))
                      (define L.tmp.17
                        (begin
                          (set! r15 0)
                          (set! r15 1774106288)
                          (set! r14 0)
                          (jump L.tmp.10)))
                      (define L.tmp.12
                        (begin
                          (set! r15 -9223372036854775808)
                          (jump L.tmp.14)))
                      (define L.tmp.13
                        (begin
                          (set! r15 9223372036854775807)
                          (jump L.tmp.14)))
                      (define L.tmp.14 (jump L.tmp.11))
                      (define L.tmp.9
                        (begin
                          (set! r15 9223372036854775807)
                          (set! r14 811516044)
                          (set! r15 r15)
                          (jump L.tmp.11)))
                      (define L.tmp.10
                        (begin
                          (set! r15 -1327371506)
                          (jump L.tmp.12)))
                      (define L.tmp.11 (jump L.fn.0.1))
                      (define L.tmp.5
                        (begin
                          (set! r15 -1228391641)
                          (jump L.tmp.7)))
                      (define L.tmp.6
                        (begin
                          (set! r15 -1926002282)
                          (jump L.tmp.7)))
                      (define L.tmp.7
                        (begin
                          (set! r15 0)
                          (jump L.tmp.3)))
                      (define L.tmp.2
                        (begin
                          (set! r15 9223372036854775807)
                          (jump L.tmp.4)))
                      (define L.tmp.3
                        (begin
                          (set! r15 0)
                          (jump L.tmp.4)))
                      (define L.tmp.4
                        (begin
                          (set! r15 25767341)
                          (set! r15 (* r15 0))
                          (set! r15 r15)
                          (halt 0)))))
  (check-by-interp '(module (define L.__main.3
                              (begin
                                (set! r15 -1536502942)
                                (set! r14 -1557455680)
                                (set! r13 -1112875927)
                                (set! r13 9223372036854775807)
                                (set! r9 9223372036854775807)
                                (set! r13 r13)
                                (halt 0)))
                            (define L.func.0.1 (halt 9223372036854775807))
                      (define L.fn.1.2
                        (begin
                          (set! r14 rdi)
                          (set! r15 rsi)
                          (set! r13 0)
                          (jump L.tmp.13)))
                      (define L.tmp.12
                        (begin
                          (set! r13 1)
                          (jump L.__nested.5)))
                      (define L.tmp.13
                        (begin
                          (set! r13 0)
                          (if (> r13 r14)
                              (jump L.__nested.4)
                              (jump L.__nested.5))))
                      (define L.__nested.8 (halt -9223372036854775808))
                      (define L.__nested.9 (halt r14))
                      (define L.__nested.10 (halt 592053094))
                      (define L.__nested.11 (halt -1824096668))
                      (define L.__nested.6
                        (begin
                          (set! r15 0)
                          (if (<= r15 r14)
                              (jump L.__nested.8)
                              (jump L.__nested.9))))
                      (define L.__nested.7
                        (begin
                          (set! r15 -9223372036854775808)
                          (jump L.__nested.10)))
                      (define L.__nested.4
                        (begin
                          (set! r15 -9223372036854775808)
                          (jump L.__nested.6)))
                      (define L.__nested.5
                        (begin
                          (set! r14 r14)
                          (set! r15 r15)
                          (set! r13 r14)
                          (set! r13 1995506902)
                          (set! r13 (+ r13 -677333479))
                          (set! r13 r13)
                          (set! r14 r14)
                          (set! r13 -1273465885)
                          (set! r14 148631858)
                          (set! r14 r13)
                          (halt r15)))))
  (check-by-interp '(module (define L.__main.1
                              (begin
                                (set! r14 -9223372036854775808)
                                (set! r15 9223372036854775807)
                                (halt -9223372036854775808)))))
  (check-by-interp '(module (define L.__main.4
                              (begin
                                (set! r15 9223372036854775807)
                                (jump L.tmp.1)))
                            (define L.tmp.1
                              (begin
                                (set! r15 9223372036854775807)
                                (jump L.tmp.3)))
                      (define L.tmp.2
                        (begin
                          (set! r15 9223372036854775807)
                          (jump L.tmp.3)))
                      (define L.tmp.3
                        (begin
                          (set! r14 0)
                          (set! r14 -9223372036854775808)
                          (set! r14 -1747244286)
                          (set! r14 r14)
                          (set! r14 -1923830755)
                          (set! r15 r15)
                          (halt 9223372036854775807)))))
  (check-by-interp '(module (define L.__main.5
                              (begin
                                (set! r15 1)
                                (jump L.__nested.3)))
                            (define L.proc.0.1
                              (begin
                                (set! r15 0)
                                (set! r15 -9223372036854775808)
                                (set! r15 672116958)
                                (set! r15 (* r15 1))
                                (set! r15 r15)
                                (set! r14 9223372036854775807)
                                (set! r14 (+ r14 r15))
                                (set! r15 r14)
                                (halt -9223372036182658851)))
                      (define L.proc.1.2
                        (begin
                          (set! r15 0)
                          (jump L.tmp.9)))
                      (define L.tmp.8
                        (begin
                          (set! r15 0)
                          (jump L.__nested.7)))
                      (define L.tmp.9
                        (begin
                          (set! r15 9223372036854775807)
                          (jump L.__nested.6)))
                      (define L.__nested.6 (halt -935154891))
                      (define L.__nested.7
                        (begin
                          (set! r15 -1449852093)
                          (set! r15 -9223372036854775808)
                          (halt 1)))
                      (define L.__nested.3 (halt 313960847))
                      (define L.__nested.4 (halt 0))))
  (check-by-interp '(module (define L.__main.7
                              (begin
                                (set! r15 -500842013)
                                (jump L.tmp.6)))
                            (define L.tmp.5
                              (begin
                                (set! r15 -1785958547)
                                (jump L.__nested.1)))
                      (define L.tmp.6
                        (begin
                          (set! r15 904902616)
                          (jump L.__nested.2)))
                      (define L.__nested.3 (halt 1))
                      (define L.__nested.4 (halt -9223372036854775808))
                      (define L.__nested.1
                        (begin
                          (set! r15 -1568723397)
                          (jump L.__nested.4)))
                      (define L.__nested.2 (halt 1))))
  (check-by-interp '(module (define L.__main.3
                              (begin
                                (set! r15 1)
                                (jump L.__nested.1)))
                            (define L.__nested.1 (halt 281602960))
                      (define L.__nested.2 (halt 9223372036854775807))))
  (check-by-interp '(module (define L.__main.1
                              (begin
                                (set! r15 -1267155910)
                                (set! r15 (+ r15 -9223372036854775808))
                                (set! r15 r15)
                                (halt 9223372035587619898)))))
  (check-by-interp '(module (define L.__main.1 (halt 9223372036854775807))))
  (check-by-interp '(module (define L.__main.1
                              (begin
                                (set! r15 -9223372036854775808)
                                (set! r15 (+ r15 1965973068))
                                (set! r15 r15)
                                (halt -9223372034888802740)))))

  ;;
  ;; !!! Added by Trevor on March 2nd 2026
  (check-by-interp '(module (define L.__main.7
                              (begin
                                (set! rdi -1860620182)
                                (jump L.L.tmp.1.2.5)))
                            (define L.L.func.0.1.4 (halt 0))
                      (define L.L.tmp.1.2.5
                        (begin
                          (set! r15 rdi)
                          (jump L.L.func.0.1.4)))
                      (define L.L.func.2.3.6
                        (begin
                          (set! r15 1)
                          (set! r15 r15)
                          (set! r14 1)
                          (jump L.tmp.8)))
                      (define L.tmp.8
                        (begin
                          (set! r15 156890122)
                          (jump L.tmp.10)))
                      (define L.tmp.9
                        (begin
                          (set! r15 r15)
                          (jump L.tmp.10)))
                      (define L.tmp.10 (halt 0))))
  (check-by-interp '(module (define L.__main.7
                              (begin
                                (set! r15 -9223372036854775808)
                                (set! r15 (* r15 -9223372036854775808))
                                (set! r15 r15)
                                (set! r15 r15)
                                (set! r15 (+ r15 0))
                                (set! r15 r15)
                                (halt 0)))
                            (define L.L.tmp.0.1.4
                              (begin
                                (set! r15 9223372036854775807)
                                (jump L.__nested.8)))
                      (define L.__nested.8 (jump L.L.x.2.3.6))
                      (define L.__nested.9
                        (begin
                          (set! r15 1)
                          (set! r15 (* r15 0))
                          (set! r15 r15)
                          (halt 0)))
                      (define L.L.func.1.2.5
                        (begin
                          (set! r14 -9223372036854775808)
                          (set! r15 9223372036854775807)
                          (jump L.__nested.11)))
                      (define L.__nested.10 (halt 1309557052))
                      (define L.__nested.11 (halt -9223372036854775808))
                      (define L.L.x.2.3.6
                        (begin
                          (set! r15 0)
                          (jump L.__nested.12)))
                      (define L.__nested.16 (halt 9223372036854775807))
                      (define L.__nested.17 (halt -260353756))
                      (define L.__nested.14
                        (begin
                          (set! r15 9223372036854775807)
                          (jump L.__nested.17)))
                      (define L.__nested.15
                        (begin
                          (set! r15 0)
                          (halt 0)))
                      (define L.__nested.18 (halt r15))
                      (define L.__nested.19 (halt -362331747))
                      (define L.tmp.20
                        (begin
                          (set! r15 9223372036854775807)
                          (jump L.tmp.22)))
                      (define L.tmp.21
                        (begin
                          (set! r15 102036653)
                          (jump L.tmp.22)))
                      (define L.tmp.22
                        (begin
                          (set! r14 0)
                          (if (= r14 r15)
                              (jump L.__nested.18)
                              (jump L.__nested.19))))
                      (define L.__nested.12
                        (begin
                          (set! r15 0)
                          (jump L.__nested.15)))
                      (define L.__nested.13
                        (begin
                          (set! r15 -302047143)
                          (jump L.tmp.20)))))
  (check-by-interp '(module (define L.__main.7
                              (begin
                                (set! rdi 1)
                                (jump L.L.proc.0.1.4)))
                            (define L.L.proc.0.1.4
                              (begin
                                (set! r15 rdi)
                                (jump L.L.func.1.2.5)))
                      (define L.L.func.1.2.5
                        (begin
                          (set! r15 1)
                          (set! r15 (* r15 0))
                          (set! r15 r15)
                          (halt 0)))
                      (define L.L.fn.2.3.6
                        (begin
                          (set! r15 rdi)
                          (set! r15 -2033705372)
                          (jump L.tmp.8)))
                      (define L.tmp.8
                        (begin
                          (set! r15 -1853172774)
                          (jump L.tmp.10)))
                      (define L.tmp.9
                        (begin
                          (set! r15 1133506028)
                          (jump L.tmp.10)))
                      (define L.tmp.10
                        (begin
                          (set! r15 1)
                          (halt 1236904416)))))
  (check-by-interp '(module (define L.__main.2 (jump L.fn.0.1))
                            (define L.fn.0.1
                              (begin
                                (set! r15 1)
                                (set! r15 1)
                                (set! r14 9223372036854775807)
                                (jump L.tmp.5)))
                      (define L.tmp.5
                        (begin
                          (set! r14 -248968641)
                          (jump L.__nested.4)))
                      (define L.tmp.6 (jump L.__nested.3))
                      (define L.__nested.3
                        (begin
                          (set! r15 r15)
                          (halt 1622965009)))
                      (define L.__nested.4
                        (begin
                          (set! r15 r15)
                          (halt 1)))))
  (check-by-interp '(module (define L.__main.1
                              (begin
                                (set! r15 -9223372036854775808)
                                (set! r15 (+ r15 -1465538260))
                                (set! r15 r15)
                                (halt 9223372035389237548)))))
  (check-by-interp '(module (define L.__main.3
                              (begin
                                (set! r15 1)
                                (set! r14 0)
                                (halt 1)))
                            (define L.fn.0.1
                              (begin
                                (set! r15 1)
                                (set! r15 (+ r15 9223372036854775807))
                                (set! r15 r15)
                                (set! r15 r15)
                                (set! r14 r15)
                                (halt -9223372036854775808)))
                      (define L.func.1.2
                        (begin
                          (set! r15 1)
                          (set! r14 1)
                          (jump L.tmp.5)))
                      (define L.tmp.4
                        (begin
                          (set! r15 406779451)
                          (set! r15 1200977699)
                          (jump L.tmp.6)))
                      (define L.tmp.5
                        (begin
                          (set! r15 0)
                          (set! r15 r15)
                          (jump L.tmp.6)))
                      (define L.tmp.6
                        (begin
                          (set! r15 r15)
                          (set! r15 (* r15 r15))
                          (set! r15 r15)
                          (halt r15)))))
  (check-by-interp '(module (define L.__main.6
                              (begin
                                (set! r15 0)
                                (jump L.__nested.4)))
                            (define L.x.0.1
                              (begin
                                (set! r15 rdi)
                                (set! r15 rsi)
                                (jump L.tmp.1.2)))
                      (define L.tmp.1.2
                        (begin
                          (set! r15 -765445006)
                          (jump L.tmp.16)))
                      (define L.tmp.16
                        (begin
                          (set! r15 0)
                          (jump L.tmp.14)))
                      (define L.tmp.17
                        (begin
                          (set! r15 9223372036854775807)
                          (jump L.tmp.15)))
                      (define L.tmp.14 (jump L.__nested.8))
                      (define L.tmp.15 (jump L.__nested.7))
                      (define L.__nested.9 (halt 0))
                      (define L.__nested.10 (halt 9223372036854775807))
                      (define L.tmp.11
                        (begin
                          (set! r15 -9223372036854775808)
                          (jump L.tmp.13)))
                      (define L.tmp.12
                        (begin
                          (set! r15 -9223372036854775808)
                          (jump L.tmp.13)))
                      (define L.tmp.13
                        (begin
                          (set! r14 0)
                          (jump L.__nested.10)))
                      (define L.__nested.7
                        (begin
                          (set! r15 -9223372036854775808)
                          (set! r15 r15)
                          (halt -9223372036854775808)))
                      (define L.__nested.8
                        (begin
                          (set! r15 1)
                          (jump L.tmp.11)))
                      (define L.func.2.3
                        (begin
                          (set! r15 rdi)
                          (set! r15 rsi)
                          (jump L.tmp.1.2)))
                      (define L.__nested.4 (halt -1271132888))
                      (define L.__nested.5 (halt 2101306416))))
  (check-by-interp '(module (define L.__main.4
                              (begin
                                (set! r15 0)
                                (jump L.__nested.2)))
                            (define L.proc.0.1
                              (begin
                                (set! r15 rdi)
                                (set! r14 -818241658)
                                (set! r14 r14)
                                (set! r13 -1769976594)
                                (set! r13 (* r13 r14))
                                (set! r14 r13)
                                (if (!= r15 r15)
                                    (jump L.__nested.5)
                                    (jump L.__nested.6))))
                      (define L.__nested.5 (halt 1))
                      (define L.__nested.6 (halt r15))
                      (define L.__nested.2 (halt 1764584349))
                      (define L.__nested.3 (halt -9223372036854775808))))
  (check-by-interp '(module (define L.__main.5
                              (begin
                                (set! r15 453798193)
                                (set! r14 r15)
                                (set! r15 9223372036854775807)
                                (jump L.__nested.3)))
                            (define L.proc.0.1
                              (begin
                                (set! r15 rdi)
                                (jump L.x.1.2)))
                      (define L.x.1.2 (halt 1))
                      (define L.__nested.3 (halt 0))
                      (define L.__nested.4 (halt -1617493587))))
  (check-by-interp '(module (define L.__main.3 (jump L.proc.1.2))
                            (define L.func.0.1
                              (begin
                                (set! r15 rdi)
                                (set! r14 9223372036854775807)
                                (set! r14 (* r14 r15))
                                (set! r14 r14)
                                (jump L.__nested.4)))
                      (define L.__nested.6 (halt r15))
                      (define L.__nested.7 (halt r15))
                      (define L.__nested.4
                        (if (< r15 -9223372036854775808)
                            (jump L.__nested.6)
                            (jump L.__nested.7)))
                      (define L.__nested.5 (jump L.proc.1.2))
                      (define L.proc.1.2
                        (begin
                          (set! rdi 954069433)
                          (jump L.func.0.1)))))
  (check-by-interp '(module (define L.__main.5
                              (begin
                                (set! r15 1)
                                (jump L.__nested.1)))
                            (define L.__nested.3 (halt 9223372036854775807))
                      (define L.__nested.4 (halt 1))
                      (define L.__nested.1
                        (begin
                          (set! r15 1)
                          (jump L.__nested.4)))
                      (define L.__nested.2 (halt 1))))
  (check-by-interp '(module (define L.__main.2
                              (begin
                                (set! r8 0)
                                (set! rcx -9223372036854775808)
                                (set! rdx -808937821)
                                (set! rsi 1)
                                (set! rdi -9223372036854775808)
                                (jump L.func.0.1)))
                            (define L.func.0.1
                              (begin
                                (set! r15 rdi)
                                (set! r15 rsi)
                                (set! r15 rdx)
                                (set! r15 rcx)
                                (set! r15 r8)
                                (halt -1458025903)))
                      ))
  (check-by-interp '(module (define L.__main.2
                              (begin
                                (set! r15 0)
                                (halt 0)))
                            (define L.tmp.0.1
                              (begin
                                (set! r14 rdi)
                                (set! r15 rsi)
                                (set! r13 rdx)
                                (set! r13 rcx)
                                (set! r14 r14)
                                (set! r13 -9223372036854775808)
                                (if (<= r13 r15)
                                    (jump L.tmp.7)
                                    (jump L.tmp.8))))
                      (define L.tmp.7
                        (begin
                          (set! r13 -9223372036854775808)
                          (if (>= r13 r14)
                              (jump L.__nested.3)
                              (jump L.__nested.4))))
                      (define L.tmp.8
                        (if (>= r15 2025307007)
                            (jump L.__nested.3)
                            (jump L.__nested.4)))
                      (define L.__nested.5 (halt 9223372036854775807))
                      (define L.__nested.6 (halt 0))
                      (define L.__nested.3
                        (begin
                          (set! r15 r14)
                          (set! r15 (+ r15 9223372036854775807))
                          (set! r15 r15)
                          (halt r15)))
                      (define L.__nested.4
                        (if (<= r15 -9223372036854775808)
                            (jump L.__nested.5)
                            (jump L.__nested.6)))))
  (check-by-interp '(module (define L.__main.4
                              (begin
                                (set! rdi 1840464414)
                                (jump L.x.1.2)))
                            (define L.func.0.1
                              (begin
                                (set! r15 rdi)
                                (set! r14 rsi)
                                (set! r13 0)
                                (if (= r13 r14)
                                    (jump L.__nested.5)
                                    (jump L.__nested.6))))
                      (define L.tmp.11
                        (if (<= r14 r14)
                            (jump L.__nested.7)
                            (jump L.__nested.8)))
                      (define L.tmp.12
                        (if (= r14 r15)
                            (jump L.__nested.7)
                            (jump L.__nested.8)))
                      (define L.__nested.9 (halt r15))
                      (define L.__nested.10 (halt r14))
                      (define L.__nested.7
                        (begin
                          (set! r15 r14)
                          (set! r15 (+ r15 r14))
                          (set! r15 r15)
                          (halt r15)))
                      (define L.__nested.8
                        (begin
                          (set! r13 1)
                          (if (= r13 r14)
                              (jump L.__nested.9)
                              (jump L.__nested.10))))
                      (define L.__nested.5
                        (begin
                          (set! r15 -9223372036854775808)
                          (set! r15 (+ r15 -9223372036854775808))
                          (set! r15 r15)
                          (halt 0)))
                      (define L.__nested.6
                        (if (< r15 r15)
                            (jump L.tmp.11)
                            (jump L.tmp.12)))
                      (define L.x.1.2
                        (begin
                          (set! r15 rdi)
                          (set! r14 1757280127)
                          (set! r14 r14)
                          (set! r14 1)
                          (set! r14 -1128483887)
                          (set! r15 r15)
                          (if (> r15 r15)
                              (jump L.__nested.13)
                              (jump L.__nested.14))))
                      (define L.__nested.13 (halt -1128483887))
                      (define L.__nested.14
                        (begin
                          (set! r14 r14)
                          (set! r14 (+ r14 r15))
                          (set! r15 r14)
                          (halt r15)))
                      (define L.fn.2.3
                        (begin
                          (set! r15 -9223372036854775808)
                          (set! r15 (+ r15 -1421853645))
                          (set! r15 r15)
                          (set! r15 0)
                          (jump L.__nested.16)))
                      (define L.__nested.15
                        (begin
                          (set! r15 -167927521)
                          (set! r15 (+ r15 1))
                          (set! r15 r15)
                          (halt -167927520)))
                      (define L.__nested.16
                        (begin
                          (set! r15 1041085683)
                          (set! r15 (* r15 9223372036854775807))
                          (set! r15 r15)
                          (set! r15 r15)
                          (halt 770292232)))))
  (check-by-interp '(module (define L.__main.3
                              (begin
                                (set! r15 -579691794)
                                (halt 953357957)))
                            (define L.proc.0.1
                              (begin
                                (set! r15 rdi)
                                (set! r15 rsi)
                                (set! r14 rdx)
                                (set! rdx r15)
                                (set! rsi r14)
                                (set! rdi 9223372036854775807)
                                (jump L.proc.0.1)))
                      (define L.func.1.2
                        (begin
                          (set! r15 rdi)
                          (set! r14 rsi)
                          (set! r14 rdx)
                          (set! r13 rcx)
                          (set! r13 r8)
                          (set! r13 r9)
                          (set! r14 r14)
                          (set! r15 r15)
                          (set! r15 -9223372036854775808)
                          (set! rdx r15)
                          (set! rsi -780648786)
                          (set! rdi r15)
                          (jump L.proc.0.1)))))
  (check-by-interp '(module (define L.__main.1
                              (begin
                                (set! r15 9223372036854775807)
                                (set! r15 -546026276)
                                (halt 9223372036854775807)))))
  (check-by-interp '(module (define L.__main.4
                              (begin
                                (set! r15 9223372036854775807)
                                (jump L.__nested.3)))
                            (define L.func.0.1
                              (begin
                                (set! r14 rdi)
                                (set! r15 rsi)
                                (set! r14 r14)
                                (if (= r14 0)
                                    (jump L.__nested.6)
                                    (jump L.__nested.5))))
                      (define L.__nested.5
                        (begin
                          (set! r15 r14)
                          (set! r15 (+ r15 0))
                          (set! r15 r15)
                          (set! r15 0)
                          (set! r15 (* r15 9223372036854775807))
                          (set! r15 r15)
                          (halt 0)))
                      (define L.__nested.6
                        (begin
                          (set! r14 0)
                          (set! r14 (* r14 r15))
                          (set! r14 r14)
                          (halt r15)))
                      (define L.__nested.2 (halt 1))
                      (define L.__nested.3 (halt -9223372036854775808))))
  (check-by-interp '(module (define L.__main.4
                              (begin
                                (set! r15 979460199)
                                (set! r15 (+ r15 -1697959716))
                                (set! r15 r15)
                                (halt -718499517)))
                            (define L.fn.0.1
                              (begin
                                (set! r15 rdi)
                                (set! r15 rsi)
                                (set! r14 1)
                                (set! r14 (* r14 9223372036854775807))
                                (set! r14 r14)
                                (set! r13 -9223372036854775808)
                                (set! r13 (+ r13 r14))
                                (set! r14 r13)
                                (set! r13 9223372036854775807)
                                (set! r13 1)
                                (jump L.__nested.5)))
                      (define L.__nested.5 (halt 9223372036854775807))
                      (define L.__nested.6 (halt r15))
                      (define L.x.1.2
                        (begin
                          (set! r15 rdi)
                          (set! r14 -1410706204)
                          (set! r14 (+ r14 r15))
                          (set! r15 r14)
                          (set! r15 1)
                          (set! r15 -9223372036854775808)
                          (set! r15 -152436426)
                          (set! r15 (* r15 0))
                          (set! r15 r15)
                          (halt 0)))
                      (define L.proc.2.3
                        (begin
                          (set! r15 rdi)
                          (set! r14 rsi)
                          (set! r14 rdx)
                          (set! r14 rcx)
                          (set! r15 r15)
                          (set! r15 956544411)
                          (set! r15 (+ r15 1))
                          (set! r15 r15)
                          (halt 956544412)))))
  (check-by-interp '(module (define L.__main.2
                              (begin
                                (set! r9 9223372036854775807)
                                (set! r8 -1891086346)
                                (set! rcx -1371550930)
                                (set! rdx 0)
                                (set! rsi 9223372036854775807)
                                (set! rdi 0)
                                (jump L.proc.0.1)))
                            (define L.proc.0.1
                              (begin
                                (set! r15 rdi)
                                (set! r15 rsi)
                                (set! r15 rdx)
                                (set! r13 rcx)
                                (set! r14 r8)
                                (set! r9 r9)
                                (set! r8 -669410514)
                                (if (< r14 r14)
                                    (jump L.tmp.5)
                                    (jump L.tmp.6))))
                      (define L.__nested.3 (halt 9223372036854775807))
                      (define L.__nested.4 (halt r14))
                      (define L.tmp.5
                        (begin
                          (set! r9 r9)
                          (set! r9 (+ r9 r13))
                          (set! r9 r9)
                          (jump L.tmp.7)))
                      (define L.tmp.6
                        (begin
                          (set! r9 r15)
                          (jump L.tmp.7)))
                      (define L.tmp.7
                        (begin
                          (set! r13 r13)
                          (set! r13 1)
                          (if (<= r15 1)
                              (jump L.__nested.3)
                              (jump L.__nested.4))))))
  (check-by-interp '(module (define L.__main.4
                              (begin
                                (set! r15 1)
                                (halt 1)))
                            (define L.x.0.1
                              (begin
                                (set! r15 rdi)
                                (set! r15 rsi)
                                (set! r14 rdx)
                                (set! r13 rcx)
                                (set! r8 r8)
                                (set! r9 r9)
                                (set! rdi fv0)
                                (set! rdi 388494724)
                                (if (>= rdi r15)
                                    (jump L.tmp.9)
                                    (jump L.tmp.10))))
                      (define L.tmp.9
                        (if (> r13 -9223372036854775808)
                            (jump L.__nested.6)
                            (jump L.__nested.5)))
                      (define L.tmp.10
                        (if (< r14 r13)
                            (jump L.__nested.6)
                            (jump L.__nested.5)))
                      (define L.__nested.7 (halt 0))
                      (define L.__nested.8
                        (begin
                          (set! r15 r13)
                          (halt 1887946265)))
                      (define L.__nested.5
                        (if (<= r8 r9)
                            (jump L.__nested.7)
                            (jump L.__nested.8)))
                      (define L.__nested.6 (halt r14))
                      (define L.tmp.1.2
                        (begin
                          (set! r15 rdi)
                          (set! r15 rsi)
                          (set! r15 rdx)
                          (set! r14 rcx)
                          (set! r13 r8)
                          (set! r9 r9)
                          (set! r15 r14)
                          (set! r15 (* r15 9223372036854775807))
                          (set! r15 r15)
                          (halt r15)))
                      (define L.tmp.2.3
                        (begin
                          (set! r15 rdi)
                          (set! r15 rsi)
                          (set! r14 rdx)
                          (set! r13 rcx)
                          (set! r8 r8)
                          (set! r13 r9)
                          (set! r13 258314756)
                          (if (!= r8 0)
                              (jump L.tmp.15)
                              (jump L.tmp.16))))
                      (define L.__nested.13 (halt r8))
                      (define L.__nested.14 (halt r15))
                      (define L.__nested.11
                        (begin
                          (set! r9 1067478227)
                          (set! r8 -768559462)
                          (set! rcx r14)
                          (set! rdx -1256996529)
                          (set! rsi 1)
                          (set! rdi r13)
                          (jump L.tmp.1.2)))
                      (define L.__nested.12
                        (begin
                          (set! r14 389818959)
                          (jump L.__nested.14)))
                      (define L.tmp.15
                        (begin
                          (set! r13 r8)
                          (jump L.tmp.17)))
                      (define L.tmp.16
                        (begin
                          (set! r13 -1809848824)
                          (set! r13 9223372036854775807)
                          (jump L.tmp.17)))
                      (define L.tmp.17
                        (begin
                          (set! r9 1525021420)
                          (jump L.__nested.12)))))
  (check-by-interp '(module (define L.__main.4
                              (begin
                                (set! fv0 -9223372036854775808)
                                (set! r9 1)
                                (set! r8 -9223372036854775808)
                                (set! rcx 9223372036854775807)
                                (set! rdx -9223372036854775808)
                                (set! rsi -9223372036854775808)
                                (set! rdi -9223372036854775808)
                                (jump L.tmp.0.1)))
                            (define L.tmp.0.1
                              (begin
                                (set! r15 rdi)
                                (set! r15 rsi)
                                (set! r15 rdx)
                                (set! r15 rcx)
                                (set! r14 r8)
                                (set! r14 r9)
                                (set! r13 fv0)
                                (set! r15 r15)
                                (set! r15 (* r15 r14))
                                (set! r15 r15)
                                (halt r15)))
                      (define L.func.1.2
                        (begin
                          (set! r15 rdi)
                          (set! r15 rsi)
                          (set! r15 rdx)
                          (set! r15 rcx)
                          (set! r15 r8)
                          (set! r15 1)
                          (halt 9223372036854775807)))
                      (define L.fn.2.3
                        (begin
                          (set! r13 rdi)
                          (set! r15 rsi)
                          (if (>= r13 1)
                              (jump L.tmp.5)
                              (jump L.tmp.6))))
                      (define L.tmp.8
                        (begin
                          (set! r14 r15)
                          (jump L.tmp.10)))
                      (define L.tmp.9
                        (begin
                          (set! r14 214741259)
                          (jump L.tmp.10)))
                      (define L.tmp.10 (jump L.tmp.7))
                      (define L.tmp.5
                        (if (= r13 r13)
                            (jump L.tmp.8)
                            (jump L.tmp.9)))
                      (define L.tmp.6
                        (begin
                          (set! r14 1683358713)
                          (set! r14 (+ r14 r15))
                          (set! r14 r14)
                          (jump L.tmp.7)))
                      (define L.tmp.7
                        (begin
                          (set! fv0 -2043460455)
                          (set! r9 r13)
                          (set! r8 9223372036854775807)
                          (set! rcx r13)
                          (set! rdx 0)
                          (set! rsi r15)
                          (set! rdi r14)
                          (jump L.tmp.0.1)))))
  (check-by-interp '(module (define L.__main.1
                              (begin
                                (set! r15 1)
                                (set! r15 (+ r15 -9223372036854775808))
                                (set! r15 r15)
                                (halt -9223372036854775807)))))
  (check-by-interp '(module (define L.__main.19
                              (begin
                                (set! r15 -9223372036854775808)
                                (jump L.tmp.13)))
                            (define L.x.0.1
                              (begin
                                (set! r15 rdi)
                                (set! r15 rsi)
                                (set! r15 rdx)
                                (set! r15 rcx)
                                (set! r15 r8)
                                (set! r15 r9)
                                (set! r15 fv0)
                                (set! rdi 1)
                                (jump L.x.4.5)))
                      (define L.func.1.2
                        (begin
                          (set! r14 9223372036854775807)
                          (set! r14 r14)
                          (set! r15 -577997854)
                          (jump L.__nested.21)))
                      (define L.__nested.20 (halt -9223372036854775808))
                      (define L.__nested.21 (halt 9223372036854775807))
                      (define L.fn.2.3
                        (begin
                          (set! r15 1)
                          (set! r15 (+ r15 1))
                          (set! r15 r15)
                          (set! r15 r15)
                          (halt 1969054361)))
                      (define L.x.3.4
                        (begin
                          (set! r15 rdi)
                          (set! r14 rsi)
                          (set! r14 rdx)
                          (set! r14 rcx)
                          (set! r14 r8)
                          (set! r14 r9)
                          (set! r14 fv0)
                          (set! fv0 -9223372036854775808)
                          (set! r9 r15)
                          (set! r8 9223372036854775807)
                          (set! rcx 25911444)
                          (set! rdx 9223372036854775807)
                          (set! rsi -9223372036854775808)
                          (set! rdi 0)
                          (jump L.func.6.7)))
                      (define L.x.4.5
                        (begin
                          (set! r15 rdi)
                          (set! fv0 r15)
                          (set! r9 r15)
                          (set! r8 r15)
                          (set! rcx 1)
                          (set! rdx r15)
                          (set! rsi r15)
                          (set! rdi 0)
                          (jump L.x.3.4)))
                      (define L.x.5.6
                        (begin
                          (set! r15 rdi)
                          (set! r14 rsi)
                          (set! r13 rdx)
                          (set! rdi rcx)
                          (set! r8 r8)
                          (set! r9 r9)
                          (set! r9 rdi)
                          (set! r14 r14)
                          (set! r9 r9)
                          (set! r8 rdi)
                          (if (> r14 r15)
                              (jump L.__nested.22)
                              (jump L.__nested.23))))
                      (define L.__nested.22
                        (begin
                          (set! fv0 -1819248150)
                          (set! r9 r9)
                          (set! r8 r14)
                          (set! rcx r9)
                          (set! rdx r13)
                          (set! rsi 9223372036854775807)
                          (set! rdi -1863740769)
                          (jump L.x.0.1)))
                      (define L.__nested.23 (halt 1))
                      (define L.func.6.7
                        (begin
                          (set! r15 rdi)
                          (set! r14 rsi)
                          (set! r14 rdx)
                          (set! r14 rcx)
                          (set! r14 r8)
                          (set! r14 r9)
                          (set! r14 fv0)
                          (set! r15 r15)
                          (set! r14 -1497437069)
                          (jump L.__nested.24)))
                      (define L.__nested.24
                        (begin
                          (set! r15 r15)
                          (set! r15 (+ r15 r15))
                          (set! r15 r15)
                          (set! r15 0)
                          (halt 0)))
                      (define L.__nested.25 (halt 1))
                      (define L.fn.7.8
                        (begin
                          (set! r15 0)
                          (jump L.__nested.26)))
                      (define L.__nested.28 (halt 1))
                      (define L.__nested.29 (halt 0))
                      (define L.__nested.26
                        (begin
                          (set! r9 -1579752260)
                          (set! r8 0)
                          (set! rcx -1248542300)
                          (set! rdx 0)
                          (set! rsi 16140507)
                          (set! rdi -9223372036854775808)
                          (jump L.x.5.6)))
                      (define L.__nested.27
                        (begin
                          (set! r15 -9223372036854775808)
                          (jump L.__nested.29)))
                      (define L.tmp.16
                        (begin
                          (set! r15 -1444900091)
                          (jump L.tmp.18)))
                      (define L.tmp.17
                        (begin
                          (set! r15 -9223372036854775808)
                          (jump L.tmp.18)))
                      (define L.tmp.18
                        (begin
                          (set! r15 r15)
                          (jump L.tmp.15)))
                      (define L.tmp.13
                        (begin
                          (set! r15 9223372036854775807)
                          (jump L.tmp.16)))
                      (define L.tmp.14
                        (begin
                          (set! r15 9223372036854775807)
                          (set! r15 r15)
                          (jump L.tmp.15)))
                      (define L.tmp.15
                        (begin
                          (set! r15 0)
                          (jump L.__nested.9)))
                      (define L.__nested.11 (jump L.fn.2.3))
                      (define L.__nested.12 (jump L.fn.2.3))
                      (define L.__nested.9 (halt 1))
                      (define L.__nested.10
                        (begin
                          (set! r15 1)
                          (jump L.__nested.12)))))
  ;; !!!

  (check-flatten-program `(module (define L.start.1 (halt 4)))
                         `(begin
                            (with-label L.start.1 (halt 4))))

  (check-flatten-program `(module (define L.start.1 (jump L.start.1)))
                         `(begin
                            (with-label L.start.1 (jump L.start.1))))
  (check-flatten-program `(module (define L.start.1
                                    (begin
                                      (set! rax L.start.1)
                                      (jump rax))))
                         `(begin
                            (with-label L.start.1 (set! rax L.start.1))
                            (jump rax)))
  (check-flatten-program `(module (define L.start.1
                                    (begin
                                      (set! rax L.start.1)
                                      (jump rax)))
                                  (define L.end.1 (halt 5))
                            )
                         `(begin
                            (with-label L.start.1 (set! rax L.start.1))
                            (jump rax)
                            (with-label L.end.1 (halt 5))))
  (check-flatten-program `(module (define L.start.1
                                    (begin
                                      (set! rax 5)
                                      (if (> rax 2)
                                          (jump L.start.1)
                                          (jump L.end.1))))
                                  (define L.end.1 (halt 5))
                            )
                         `(begin
                            (with-label L.start.1 (set! rax 5))
                            (compare rax 2)
                            (jump-if > L.start.1)
                            (jump L.end.1)
                            (with-label L.end.1 (halt 5))))
  (check-flatten-program `(module (define L.start.1
                                    (begin
                                      (set! rdi 5)
                                      (set! rax 1)
                                      (jump L.fact.1)))
                                  (define L.fact.1
                                    (begin
                                      (set! rax (* rax rdi))
                                      (set! rdi (+ rdi -1))
                                      (if (> rdi 0)
                                          (jump L.fact.1)
                                          (jump L.end.1))))
                            (define L.end.1 (halt rax)))
                         `(begin
                            (with-label L.start.1 (set! rdi 5))
                            (set! rax 1)
                            (jump L.fact.1)
                            (with-label L.fact.1 (set! rax (* rax rdi)))
                            (set! rdi (+ rdi -1))
                            (compare rdi 0)
                            (jump-if > L.fact.1)
                            (jump L.end.1)
                            (with-label L.end.1 (halt rax))))
  (check-by-interp `(module (define L.start.1
                              (begin
                                (set! rdi 5)
                                (set! rax 1)
                                (jump L.fact.1)))
                            (define L.fact.1
                              (begin
                                (set! rax (* rax rdi))
                                (set! rdi (+ rdi -1))
                                (if (> rdi 0)
                                    (jump L.fact.1)
                                    (jump L.end.1))))
                      (define L.end.1 (halt rax))))
  (check-by-interp `(module (define L.start.1
                              (begin
                                (set! rax 5)
                                (if (< rax 2)
                                    (jump L.start.1)
                                    (jump L.end.1))))
                            (define L.end.1 (halt 5))
                      ))
  (check-by-interp `(module (define L.end.1 (halt 5)))))
