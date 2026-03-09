#lang racket

(require cpsc411/compiler-lib)

(provide expose-basic-blocks)

; nested-asm-lang-v5
;  p	 	::=	 	(module (define label tail) ... tail)
;   pred	 	::=	 	(relop loc opand)
;  	 	|	 	(true)
;  	 	|	 	(false)
;  	 	|	 	(not pred)
;  	 	|	 	(begin effect ... pred)
;  	 	|	 	(if pred pred pred)
;   tail	 	::=	 	(halt opand)
;  	 	|	 	(jump trg)
;  	 	|	 	(begin effect ... tail)
;  	 	|	 	(if pred tail tail)
;   effect	 	::=	 	(set! loc triv)
;  	 	|	 	(set! loc_1 (binop loc_1 opand))
;  	 	|	 	(begin effect ... effect)
;  	 	|	 	(if pred effect effect)
;   triv	 	::=	 	opand
;  	 	|	 	label
;   opand	 	::=	 	int64
;  	 	|	 	loc
;   loc	 	::=	 	reg
;  	 	|	 	fvar
;   trg	 	::=	 	label
;  	 	|	 	loc
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
;   fvar	 	::=	 	fvar?
;   label	 	::=	 	label?
;   int64	 	::=	 	int64?
;;------------------------------
; Block-pred-lang v5
;   p	 	::=	 	(module b ... b)
;   b	 	::=	 	(define label tail)
;   pred	 	::=	 	(relop loc opand)
;  	 	|	 	(true)
;  	 	|	 	(false)
;  	 	|	 	(not pred)
;   tail	 	::=	 	(halt opand)
;  	 	|	 	(jump trg)
;  	 	|	 	(begin effect ... tail)
;  	 	|	 	(if pred (jump trg) (jump trg))
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

;;nested-asm-lang-v5 -> block-pred-lang-v5
;; Compile the Nested-asm-lang v5 to Block-pred-lang v5,
;;   eliminating all nested expressions by generating fresh basic blocks and jumps.
(define (expose-basic-blocks p)
  (define blocks '())
  (define (create-block! label tail)
    (set! blocks (cons `(define ,label ,tail) blocks))
    label)
  ;; nested-pred label label -> label
  ;; effect: creates a block with pred
  (define (expose-pred! pred truelab falselab)
    (define label (fresh-label 'pred))
    (match pred
      [`(not ,pred) (expose-pred! pred falselab truelab)]
      [`(begin
          ,fx* ...
          ,pred)
       (foldr expose-effect! (expose-pred! pred truelab falselab) fx*)]
      [`(if ,pred ,pred1 ,pred2)
       (expose-pred! pred
                     (expose-pred! pred1 truelab falselab)
                     (expose-pred! pred2 truelab falselab))]
      [`(,relop ,loc ,triv)
       (create-block! label
                      `(if ,pred
                           (jump ,truelab)
                           (jump ,falselab)))]
      [`(true)
       (create-block! label
                      `(if ,pred
                           (jump ,truelab)
                           (jump ,falselab)))]
      [`(false)
       (create-block! label
                      `(if ,pred
                           (jump ,truelab)
                           (jump ,falselab)))]))
  ;; nested-effect label -> label
  ;; effect: creates a block with the effect
  (define (expose-effect! fx next)
    (define label (fresh-label 'fx))
    (match fx
      [`(set! ,loc ,triv)
       (create-block! label
                      `(begin
                         ,fx
                         (jump ,next)))]
      [`(set! ,loc (,binop ,loc ,triv))
       (create-block! label
                      `(begin
                         ,fx
                         (jump ,next)))]
      [`(begin
          ,fx* ...
          ,fx)
       (foldr expose-effect! (expose-effect! fx next) fx*)]
      [`(if ,pred ,fx1 ,fx2)
       (expose-pred! pred (expose-effect! fx1 next) (expose-effect! fx2 next))]))
  ;; nested-tail (block-tail -> X) -> X
  (define (nested-tail->block-tail& tail [k identity])
    (match tail
      [`(halt ,_) (k tail)]
      [`(jump ,_) (k tail)]
      [`(begin
          ,fx* ...
          ,tail)
       (k `(jump ,(foldr expose-effect! (expose-tail! tail) fx*)))]
      [`(if ,pred ,tail1 ,tail2)
       (k `(jump ,(expose-pred! pred (expose-tail! tail1) (expose-tail! tail2))))]))

  ;; nested-tail -> label
  ;; effect: creates a block
  (define (expose-tail! tail)
    ;;block-tail -> label
    (define (expose-block-label! tail)
      (define label (fresh-label 'tail))
      (match tail
        [`(jump ,trg) trg]
        [_ (create-block! label tail)]))
    (nested-tail->block-tail& tail expose-block-label!))
  (match p
    [`(module (define ,label* ,tail*) ...
        ,tail)
     (begin
       (for-each create-block! label* (map (λ (tail) `(jump ,(expose-tail! tail))) tail*))
       (nested-tail->block-tail& tail (λ (bt) (create-block! (fresh-label 'start) bt)))
       `(module ,@blocks))]))

(module+ test
  (require rackunit
           cpsc411/langs/v5)

  (define (peek x)
    ;(pretty-display x)
    x)
  (define-syntax-rule (check-by-interp nal5)
    (check-eq? (interp-nested-asm-lang-v5 nal5)
               (interp-block-pred-lang-v5 (peek (expose-basic-blocks nal5)))))
  ;; M5 tests; Added by Trevor on March 8th 2026, multiple bindings allowed per let
  (check-by-interp '(module (define L.fn.0.1
                              (begin
                                (set! r15 rdi)
                                (set! r15 rsi)
                                (set! r14 rdx)
                                (set! r13 rcx)
                                (set! r8 r8)
                                (set! r9 r9)
                                (if (begin
                                      (set! r13 -502092639)
                                      (= r13 r15))
                                    (if (>= r14 1)
                                        (halt 1852032564)
                                        (halt -106704231))
                                    (begin
                                      (set! r15 r9)
                                      (set! r15 (+ r15 1))
                                      (set! r15 r15)
                                      (halt r15)))))
                            (if (begin
                                  (set! r15 -9223372036854775808)
                                  (set! r14 0)
                                  (false))
                                (halt -9223372036854775808)
                                (begin
                                  (set! r15 -9223372036854775808)
                                  (set! r15 1)
                                  (set! r15 1)
                                  (halt 1)))
                      ))
  (check-by-interp '(module (define L.tmp.0.1
                              (begin
                                (set! r15 rdi)
                                (set! r15 rsi)
                                (set! r13 rdx)
                                (set! r14 rcx)
                                (set! r14 r8)
                                (set! r9 r9)
                                (begin
                                  (set! r15 r15)
                                  (set! r15 (* r15 -1194246923))
                                  (set! r15 r15))
                                (if (begin
                                      (set! r13 r13)
                                      (set! r9 r9)
                                      (= r13 422731415))
                                    (if (begin
                                          (set! r13 9223372036854775807)
                                          (true))
                                        (set! r13 9223372036854775807)
                                        (set! r13 9223372036854775807))
                                    (begin
                                      (set! r13 r9)
                                      (set! r13 (+ r13 52582991))
                                      (set! r13 r13)))
                                (set! r9 r9)
                                (set! r8 r14)
                                (set! rcx 0)
                                (set! rdx -1002513727)
                                (set! rsi -191435828)
                                (set! rdi r15)
                                (jump L.tmp.0.1)))
                            (begin
                              (set! r15 -9223372036854775808)
                              (set! r15 (+ r15 937267391))
                              (set! r15 r15)
                              (set! r14 -9223372036854775808)
                              (set! r14 (+ r14 -9223372036854775808))
                              (set! r14 r14)
                              (halt -335809824))
                      ))
  (check-by-interp '(module (define L.proc.0.1
                              (begin
                                (set! r14 rdi)
                                (set! r15 rsi)
                                (set! r13 rdx)
                                (begin
                                  (set! r9 1554173211)
                                  (set! r9 616342412)
                                  (set! r9 r9)
                                  (if (= r13 r14)
                                      (set! r14 r13)
                                      (set! r14 r15))
                                  (if (begin
                                        (set! r14 1)
                                        (false))
                                      (set! r15 r15)
                                      (set! r15 0))
                                  (if (begin
                                        (set! r15 1320805275)
                                        (true))
                                      (halt 0)
                                      (halt 0)))))
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
                                (jump L.proc.0.1)))
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
                        (halt 0))))
  (check-by-interp '(module (begin
                              (set! r15 0)
                              (set! r15 (+ r15 9223372036854775807))
                              (set! r15 r15)
                              (set! r14 -678062995)
                              (if (begin
                                    (set! r14 0)
                                    (true))
                                  (set! r14 -2004574473)
                                  (set! r14 9223372036854775807))
                              (set! r14 1)
                              (set! r14 (* r14 r15))
                              (set! r15 r14)
                              (halt 9223372036854775807))))
  (check-by-interp '(module (define L.fn.0.1
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
                      (begin
                        (set! r15 -9223372036854775808)
                        (set! r14 9223372036854775807)
                        (set! r15 r15)
                        (if (begin
                              (set! r15 -1846550218)
                              (false))
                            (set! r15 -186139937)
                            (set! r15 1))
                        (set! r15 1884722986)
                        (set! r15 9223372036854775807)
                        (halt 0))))
  (check-by-interp '(module (define L.func.0.1
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
                                    (set! r14 -9223372036854775808)
                                    (set! r14 r14))
                                (set! r15 r15)
                                (halt r14)))
                      (begin
                        (set! rsi 0)
                        (set! rdi -9223372036854775808)
                        (jump L.func.1.2))))
  (check-by-interp '(module (define L.tmp.0.1
                              (begin
                                (set! r15 rdi)
                                (set! r14 rsi)
                                (set! r14 rdx)
                                (set! rdi rcx)
                                (set! r13 r8)
                                (set! r9 r9)
                                (set! r9 rdi)
                                (set! r9 1)
                                (if (if (!= r9 r15)
                                        (begin
                                          (set! r15 -494940107)
                                          (<= r15 r13))
                                        (begin
                                          (set! r15 0)
                                          (true)))
                                    (halt -777687734)
                                    (if (begin
                                          (set! r15 -9223372036854775808)
                                          (> r15 r14))
                                        (halt 9223372036854775807)
                                        (halt -9223372036854775808)))))
                            (halt 9223372036854775807)
                      ))
  (check-by-interp '(module (begin
                              (set! r15 1)
                              (set! r15 0)
                              (halt 356048754))))
  (check-by-interp '(module (define L.fn.0.1
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
                                (if (begin
                                      (set! r9 1)
                                      (true))
                                    (set! r14 r14)
                                    (set! r14 r13))
                                (set! r13 9223372036854775807)
                                (set! r13 1)
                                (set! r15 r15)
                                (set! r15 r13)
                                (set! r15 r14)
                                (set! r15 -80057626)
                                (set! r15 451403960)
                                (set! r15 0)
                                (set! r15 -9223372036854775808)
                                (if (begin
                                      (set! r15 0)
                                      (= r15 r14))
                                    (halt 1)
                                    (halt -9223372036854775808))))
                            (define L.func.1.2
                              (begin
                                (set! r15 rdi)
                                (set! r15 rsi)
                                (set! r15 rdx)
                                (set! r14 rcx)
                                (set! r14 r8)
                                (set! r14 r9)
                                (set! r14 fv0)
                                (if (begin
                                      (set! r14 -68053908)
                                      (false))
                                    (begin
                                      (set! rcx r15)
                                      (set! rdx 2037093174)
                                      (set! rsi 2020389049)
                                      (set! rdi 0)
                                      (jump L.func.2.3))
                                    (jump L.fn.0.1))))
                      (define L.func.2.3
                        (begin
                          (set! r14 rdi)
                          (set! r15 rsi)
                          (set! r13 rdx)
                          (set! r9 rcx)
                          (set! r9 1683456577)
                          (set! r9 0)
                          (set! r9 572391381)
                          (if (begin
                                (set! r9 9223372036854775807)
                                (>= r9 r14))
                              (set! r14 -2023903597)
                              (set! r14 -15104029))
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
                      (if (not (begin
                                 (set! r15 512244517)
                                 (true)))
                          (begin
                            (set! r15 1283186732)
                            (set! r14 99039009)
                            (set! r14 1811100583)
                            (halt 1283186732))
                          (begin
                            (set! r15 1)
                            (set! r15 -9223372036854775808)
                            (set! r15 1)
                            (halt 1)))))
  (check-by-interp '(module (define L.proc.0.1
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
                                (begin
                                  (if (< r14 r14)
                                      (set! r15 r14)
                                      (set! r15 r14))
                                  (set! r14 r14)
                                  (set! r14 (* r14 -1298566605))
                                  (set! r14 r14)
                                  (set! r14 0)
                                  (set! r15 r15)
                                  (set! r15 (* r15 r15))
                                  (set! r15 r15)
                                  (halt r15))))
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
                      (if (begin
                            (set! r15 1)
                            (true))
                          (halt -9223372036854775808)
                          (halt -1627211406))))
  (check-by-interp '(module (define L.x.0.1
                              (begin
                                (set! r15 rdi)
                                (begin
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
                                  (halt 1))))
                            (begin
                              (set! r15 -1755065230)
                              (set! r15 9223372036854775807)
                              (set! r14 0)
                              (set! r15 r15)
                              (set! r15 -9223372036854775808)
                              (set! r14 -9223372036854775808)
                              (if (begin
                                    (set! r14 1)
                                    (false))
                                  (halt -9223372036854775808)
                                  (halt -9223372036854775808)))
                      ))
  (check-by-interp '(module (begin
                              (set! r15 993422572)
                              (set! r15 (* r15 1))
                              (set! r15 r15)
                              (if (begin
                                    (set! r14 92310708)
                                    (true))
                                  (set! r14 1)
                                  (set! r14 0))
                              (set! r14 9223372036854775807)
                              (set! r14 (+ r14 -1759699484))
                              (set! r14 r14)
                              (set! r15 r15)
                              (set! r14 -9223372036854775808)
                              (halt 993422572))))
  (check-by-interp '(module (define L.func.0.1
                              (begin
                                (set! r15 rdi)
                                (set! r14 -9223372036854775808)
                                (set! r14 (+ r14 -9223372036854775808))
                                (set! r14 r14)
                                (set! r14 r15)
                                (set! r14 (+ r14 1312056768))
                                (set! r14 r14)
                                (if (begin
                                      (set! r13 1)
                                      (<= r13 r14))
                                    (set! r13 -9223372036854775808)
                                    (set! r13 -50606571))
                                (set! r15 r15)
                                (set! r14 r15)
                                (if (if (>= r15 r15)
                                        (begin
                                          (set! r9 0)
                                          (< r9 r15))
                                        (begin
                                          (set! r9 1880363761)
                                          (true)))
                                    (begin
                                      (set! r13 1)
                                      (set! r14 r14)
                                      (halt r15))
                                    (begin
                                      (set! r14 r13)
                                      (set! r14 (+ r14 r15))
                                      (set! r15 r14)
                                      (halt r15)))))
                            (define L.x.1.2 (halt -9223372036854775808))
                      (jump L.x.1.2)))
  (check-by-interp '(module (define L.x.0.1
                              (begin
                                (set! r15 rdi)
                                (set! r14 rsi)
                                (set! r14 rdx)
                                (set! rdx 0)
                                (set! rsi r15)
                                (set! rdi r14)
                                (jump L.x.0.1)))
                            (if (begin
                                  (set! r15 9223372036854775807)
                                  (true))
                                (begin
                                  (set! r15 0)
                                  (set! r15 213435043)
                                  (halt -9223372036854775808))
                                (halt 0))
                      ))
  (check-by-interp '(module (if (not (begin
                                       (set! r15 1946235623)
                                       (false)))
                                (begin
                                  (set! r15 -135046761)
                                  (set! r14 1453915451)
                                  (set! r15 257292075)
                                  (halt 1453915451))
                                (halt -9223372036854775808))))
  (check-by-interp '(module (define L.proc.0.1
                              (begin
                                (set! r15 rdi)
                                (set! r15 rsi)
                                (set! r14 rdx)
                                (halt r15)))
                            (begin
                              (set! r15 1)
                              (set! r15 (* r15 9223372036854775807))
                              (set! r15 r15)
                              (halt 9223372036854775807))
                      ))
  (check-by-interp '(module (define L.proc.0.1
                              (begin
                                (set! r15 rdi)
                                (set! r14 rsi)
                                (set! r14 rdx)
                                (set! r14 rcx)
                                (set! r13 r8)
                                (set! r13 r9)
                                (begin
                                  (set! fv0 1165846535)
                                  (set! r9 r14)
                                  (set! r8 r15)
                                  (set! rcx 1407333795)
                                  (set! rdx 0)
                                  (set! rsi r15)
                                  (set! rdi 1843221563)
                                  (jump L.func.1.2))))
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
                                (jump L.func.1.2)))
                      (halt -1263415267)))
  (check-by-interp '(module (define L.proc.0.1
                              (begin
                                (set! r15 rdi)
                                (set! r15 rsi)
                                (set! rdi -9223372036854775808)
                                (jump L.tmp.1.2)))
                            (define L.tmp.1.2
                              (begin
                                (set! r15 rdi)
                                (if (begin
                                      (set! r14 9223372036854775807)
                                      (!= r14 r15))
                                    (begin
                                      (set! r14 2026709313)
                                      (set! r15 r15)
                                      (set! r15 r15)
                                      (halt r15))
                                    (halt 9223372036854775807))))
                      (begin
                        (set! r15 0)
                        (set! r15 (* r15 1192307430))
                        (set! r15 r15)
                        (if (begin
                              (set! r14 -9223372036854775808)
                              (true))
                            (set! r14 -9223372036854775808)
                            (set! r14 2088471563))
                        (set! r14 1)
                        (set! r14 9223372036854775807)
                        (set! r14 1861500702)
                        (if (begin
                              (set! r14 9223372036854775807)
                              (true))
                            (halt 0)
                            (halt 0)))))
  (check-by-interp '(module (define L.proc.0.1
                              (begin
                                (set! r15 rdi)
                                (if (begin
                                      (set! r14 1)
                                      (> r14 r15))
                                    (halt 822960898)
                                    (halt r15))))
                            (define L.fn.1.2
                              (begin
                                (set! r13 rdi)
                                (set! r15 rsi)
                                (set! r14 rdx)
                                (begin
                                  (set! r15 -1983872386)
                                  (set! r15 r13)
                                  (set! r15 r15)
                                  (set! r14 9223372036854775807)
                                  (set! r14 -9223372036854775808)
                                  (set! r14 1)
                                  (set! r14 0)
                                  (if (>= r15 r15)
                                      (halt -9223372036854775808)
                                      (halt 0)))))
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
                          (jump L.fn.2.3)))
                      (halt 9223372036854775807)))
  (check-by-interp '(module (if (not (begin
                                       (set! r15 1622421353)
                                       (true)))
                                (begin
                                  (set! r15 -2027378735)
                                  (set! r15 9223372036854775807)
                                  (halt 9223372036854775807))
                                (begin
                                  (set! r15 -9223372036854775808)
                                  (set! r15 1)
                                  (halt 9223372036854775807)))))
  (check-by-interp '(module (begin
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
                              (halt -9223372036854775808))))
  (check-by-interp '(module (define L.func.0.1
                              (begin
                                (set! r13 rdi)
                                (set! r15 rsi)
                                (set! rdi rdx)
                                (set! rdx rcx)
                                (set! rsi r8)
                                (set! r14 r9)
                                (if (if (> r15 r13)
                                        (if (begin
                                              (set! r13 -1032056006)
                                              (= r13 rsi))
                                            (>= rdx r14)
                                            (< rdi 1))
                                        (begin
                                          (set! r13 1)
                                          (>= r13 rdi)))
                                    (begin
                                      (set! r9 rdi)
                                      (set! r8 r14)
                                      (set! rcx 1807204646)
                                      (set! rdx r15)
                                      (set! rsi -675302553)
                                      (set! rdi 0)
                                      (jump L.func.0.1))
                                    (begin
                                      (set! r9 9223372036854775807)
                                      (set! r8 -9223372036854775808)
                                      (set! rcx rsi)
                                      (set! rdx r14)
                                      (set! rsi -41674885)
                                      (set! rdi r14)
                                      (jump L.func.0.1)))))
                            (if (begin
                                  (set! r15 -9223372036854775808)
                                  (true))
                                (begin
                                  (set! r15 9223372036854775807)
                                  (set! r15 0)
                                  (set! r15 9223372036854775807)
                                  (halt 9223372036854775807))
                                (if (begin
                                      (set! r15 -235413122)
                                      (false))
                                    (halt 0)
                                    (halt 9223372036854775807)))
                      ))
  (check-by-interp '(module (define L.fn.0.1
                              (begin
                                (set! r15 rdi)
                                (set! rsi r15)
                                (set! rdi r15)
                                (jump L.x.1.2)))
                            (define L.x.1.2
                              (begin
                                (set! r15 rdi)
                                (set! r14 rsi)
                                (begin
                                  (set! r14 r14)
                                  (set! r14 9223372036854775807)
                                  (set! r15 r15)
                                  (set! r15 9223372036854775807)
                                  (set! r15 -2115998024)
                                  (halt -1101891150))))
                      (if (if (begin
                                (set! r15 1)
                                (false))
                              (begin
                                (set! r15 -9223372036854775808)
                                (false))
                              (begin
                                (set! r15 -1520052689)
                                (true)))
                          (begin
                            (set! r15 -9223372036854775808)
                            (set! r14 9223372036854775807)
                            (set! r14 744570222)
                            (halt -9223372036854775808))
                          (begin
                            (set! r15 -133225634)
                            (set! r14 -9223372036854775808)
                            (set! r14 -9223372036854775808)
                            (halt -133225634)))))
  (check-by-interp '(module (begin
                              (set! r15 9223372036854775807)
                              (set! r14 1)
                              (set! r14 -9223372036854775808)
                              (set! r14 9223372036854775807)
                              (set! r14 1)
                              (set! r14 -1722042928)
                              (set! r14 0)
                              (set! r14 1)
                              (if (begin
                                    (set! r14 -1508403451)
                                    (true))
                                  (halt 447579047)
                                  (halt 9223372036854775807)))))
  (check-by-interp '(module (define L.tmp.0.1
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
                            (begin
                              (set! r15 9223372036854775807)
                              (set! r15 (+ r15 -1932027129))
                              (set! r15 r15)
                              (halt 9223372034922748678))
                      ))
  (check-by-interp '(module (define L.func.0.1
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
                                (if (if (begin
                                          (set! r15 182929845)
                                          (> r15 r13))
                                        (>= r14 1)
                                        (begin
                                          (set! r15 -767224240)
                                          (true)))
                                    (begin
                                      (set! r15 r14)
                                      (set! r15 (+ r15 -9223372036854775808))
                                      (set! r15 r15)
                                      (halt r15))
                                    (halt r14))))
                      (define L.x.2.3
                        (if (begin
                              (set! r15 0)
                              (true))
                            (halt 1083014636)
                            (begin
                              (if (begin
                                    (set! r15 1)
                                    (true))
                                  (set! r15 9223372036854775807)
                                  (set! r15 1))
                              (set! r14 0)
                              (set! r14 (* r14 0))
                              (set! r14 r14)
                              (set! r14 1942355770)
                              (set! r14 (* r14 9223372036854775807))
                              (set! r14 r14)
                              (if (>= r15 9223372036854775807)
                                  (halt -9223372036854775808)
                                  (halt 1)))))
                      (begin
                        (set! rsi 9223372036854775807)
                        (set! rdi -1129269775)
                        (jump L.func.0.1))))
  (check-by-interp '(module (define L.proc.0.1
                              (if (begin
                                    (begin
                                      (set! r15 1)
                                      (set! r15 (* r15 0))
                                      (set! r14 r15))
                                    (set! r15 -9223372036854775808)
                                    (true))
                                  (halt -9223372036854775808)
                                  (begin
                                    (set! rdx 0)
                                    (set! rsi 1)
                                    (set! rdi 0)
                                    (jump L.proc.2.3))))
                            (define L.fn.1.2
                              (begin
                                (set! r15 rdi)
                                (set! r14 rsi)
                                (set! r13 rdx)
                                (set! rdi rcx)
                                (set! r13 r8)
                                (set! r8 r9)
                                (set! r9 fv0)
                                (if (if (begin
                                          (set! r8 -1156972119)
                                          (!= r8 r13))
                                        (begin
                                          (set! r14 9223372036854775807)
                                          (> r14 r15))
                                        (begin
                                          (set! r8 1703616983)
                                          (!= r8 r14)))
                                    (begin
                                      (set! r14 r9)
                                      (set! r14 -144518674)
                                      (set! r14 rdi)
                                      (set! r14 r13)
                                      (if (< r15 9223372036854775807)
                                          (set! r14 0)
                                          (set! r14 -9223372036854775808))
                                      (if (>= r15 -2080421634)
                                          (halt 9223372036854775807)
                                          (halt 0)))
                                    (halt -274219017))))
                      (define L.proc.2.3
                        (begin
                          (set! r15 rdi)
                          (set! r15 rsi)
                          (set! r14 rdx)
                          (set! r15 r15)
                          (set! r15 (+ r15 9223372036854775807))
                          (set! r15 r15)
                          (halt r15)))
                      (begin
                        (set! r15 1)
                        (set! r15 (+ r15 -1806804688))
                        (set! r15 r15)
                        (set! r14 1880531761)
                        (set! r14 (+ r14 1))
                        (set! r14 r14)
                        (if (begin
                              (set! r14 0)
                              (false))
                            (halt 0)
                            (halt 9223372036854775807)))))
  (check-by-interp '(module (if (begin
                                  (set! r15 -107521481)
                                  (true))
                                (begin
                                  (set! r15 1275956981)
                                  (set! r15 (* r15 1))
                                  (set! r15 r15)
                                  (halt 1275956981))
                                (begin
                                  (set! r15 1318401057)
                                  (set! r15 -542033033)
                                  (halt -288327503)))))
  (check-by-interp '(module (define L.fn.0.1
                              (begin
                                (set! r15 9223372036854775807)
                                (set! r14 684249837)
                                (set! r14 1)
                                (if (begin
                                      (set! r13 2084897481)
                                      (false))
                                    (set! r15 r15)
                                    (set! r15 r14))
                                (if (begin
                                      (set! r15 0)
                                      (set! r15 1774106288)
                                      (begin
                                        (set! r14 0)
                                        (false)))
                                    (begin
                                      (set! r15 9223372036854775807)
                                      (set! r14 811516044)
                                      (set! r15 r15))
                                    (if (begin
                                          (set! r15 -1327371506)
                                          (true))
                                        (set! r15 -9223372036854775808)
                                        (set! r15 9223372036854775807)))
                                (jump L.fn.0.1)))
                            (begin
                              (if (begin
                                    (set! r15 1517267005)
                                    (false))
                                  (set! r15 -1228391641)
                                  (set! r15 -1926002282))
                              (if (begin
                                    (set! r15 0)
                                    (false))
                                  (set! r15 9223372036854775807)
                                  (set! r15 0))
                              (set! r15 25767341)
                              (set! r15 (* r15 0))
                              (set! r15 r15)
                              (halt 0))
                      ))
  (check-by-interp '(module (define L.func.0.1 (halt 9223372036854775807))
                            (define L.fn.1.2
                              (begin
                                (set! r14 rdi)
                                (set! r15 rsi)
                                (if (if (begin
                                          (set! r13 0)
                                          (false))
                                        (begin
                                          (set! r13 1)
                                          (false))
                                        (begin
                                          (set! r13 0)
                                          (> r13 r14)))
                                    (if (not (begin
                                               (set! r15 -9223372036854775808)
                                               (false)))
                                        (if (begin
                                              (set! r15 0)
                                              (<= r15 r14))
                                            (halt -9223372036854775808)
                                            (halt r14))
                                        (if (begin
                                              (set! r15 -9223372036854775808)
                                              (true))
                                            (halt 592053094)
                                            (halt -1824096668)))
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
                      (begin
                        (set! r15 -1536502942)
                        (set! r14 -1557455680)
                        (set! r13 -1112875927)
                        (set! r13 9223372036854775807)
                        (set! r9 9223372036854775807)
                        (set! r13 r13)
                        (halt 0))))
  (check-by-interp '(module (begin
                              (set! r14 -9223372036854775808)
                              (set! r15 9223372036854775807)
                              (halt -9223372036854775808))))
  (check-by-interp '(module (begin
                              (if (begin
                                    (set! r15 9223372036854775807)
                                    (true))
                                  (set! r15 9223372036854775807)
                                  (set! r15 9223372036854775807))
                              (set! r14 0)
                              (set! r14 -9223372036854775808)
                              (set! r14 -1747244286)
                              (set! r14 r14)
                              (set! r14 -1923830755)
                              (set! r15 r15)
                              (halt 9223372036854775807))))
  (check-by-interp '(module (define L.proc.0.1
                              (begin
                                (set! r15 0)
                                (set! r15 -9223372036854775808)
                                (set! r15 672116958)
                                (set! r15 (* r15 1))
                                (set! r15 r15)
                                (begin
                                  (set! r14 9223372036854775807)
                                  (set! r14 (+ r14 r15))
                                  (set! r15 r14)
                                  (halt -9223372036182658851))))
                            (define L.proc.1.2
                              (if (if (begin
                                        (set! r15 0)
                                        (false))
                                      (begin
                                        (set! r15 0)
                                        (false))
                                      (begin
                                        (set! r15 9223372036854775807)
                                        (true)))
                                  (halt -935154891)
                                  (begin
                                    (set! r15 -1449852093)
                                    (set! r15 -9223372036854775808)
                                    (halt 1))))
                      (if (begin
                            (set! r15 1)
                            (true))
                          (halt 313960847)
                          (halt 0))))
  (check-by-interp '(module (if (if (begin
                                      (set! r15 -500842013)
                                      (false))
                                    (begin
                                      (set! r15 -1785958547)
                                      (true))
                                    (begin
                                      (set! r15 904902616)
                                      (false)))
                                (if (begin
                                      (set! r15 -1568723397)
                                      (false))
                                    (halt 1)
                                    (halt -9223372036854775808))
                                (halt 1))))
  (check-by-interp '(module (if (begin
                                  (set! r15 1)
                                  (true))
                                (halt 281602960)
                                (halt 9223372036854775807))))
  (check-by-interp '(module (begin
                              (set! r15 -1267155910)
                              (set! r15 (+ r15 -9223372036854775808))
                              (set! r15 r15)
                              (halt 9223372035587619898))))
  (check-by-interp '(module (halt 9223372036854775807)))
  (check-by-interp '(module (begin
                              (set! r15 -9223372036854775808)
                              (set! r15 (+ r15 1965973068))
                              (set! r15 r15)
                              (halt -9223372034888802740))))

  ;;
  ;; !!! Added by Trevor on March 2nd 2026

  (check-by-interp '(module (define L.L.func.0.1.4 (halt 0))
                            (define L.L.tmp.1.2.5
                              (begin
                                (set! r15 rdi)
                                (jump L.L.func.0.1.4)))
                      (define L.L.func.2.3.6
                        (begin
                          (begin
                            (set! r15 1)
                            (set! r15 r15))
                          (if (begin
                                (set! r14 1)
                                (true))
                              (set! r15 156890122)
                              (set! r15 r15))
                          (halt 0)))
                      (begin
                        (set! rdi -1860620182)
                        (jump L.L.tmp.1.2.5))))
  (check-by-interp '(module (define L.L.tmp.0.1.4
                              (if (begin
                                    (set! r15 9223372036854775807)
                                    (true))
                                  (jump L.L.x.2.3.6)
                                  (begin
                                    (set! r15 1)
                                    (set! r15 (* r15 0))
                                    (set! r15 r15)
                                    (halt 0))))
                            (define L.L.func.1.2.5
                              (begin
                                (set! r14 -9223372036854775808)
                                (if (not (begin
                                           (set! r15 9223372036854775807)
                                           (true)))
                                    (halt 1309557052)
                                    (halt -9223372036854775808))))
                      (define L.L.x.2.3.6
                        (if (not (begin
                                   (set! r15 0)
                                   (false)))
                            (if (begin
                                  (set! r15 0)
                                  (false))
                                (if (begin
                                      (set! r15 9223372036854775807)
                                      (false))
                                    (halt 9223372036854775807)
                                    (halt -260353756))
                                (begin
                                  (set! r15 0)
                                  (halt 0)))
                            (begin
                              (if (begin
                                    (set! r15 -302047143)
                                    (true))
                                  (set! r15 9223372036854775807)
                                  (set! r15 102036653))
                              (if (begin
                                    (set! r14 0)
                                    (= r14 r15))
                                  (halt r15)
                                  (halt -362331747)))))
                      (begin
                        (set! r15 -9223372036854775808)
                        (set! r15 (* r15 -9223372036854775808))
                        (set! r15 r15)
                        (set! r15 r15)
                        (set! r15 (+ r15 0))
                        (set! r15 r15)
                        (halt 0))))
  (check-by-interp '(module (define L.L.proc.0.1.4
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
                          (begin
                            (if (begin
                                  (set! r15 -2033705372)
                                  (true))
                                (set! r15 -1853172774)
                                (set! r15 1133506028))
                            (set! r15 1)
                            (halt 1236904416))))
                      (begin
                        (set! rdi 1)
                        (jump L.L.proc.0.1.4))))
  (check-by-interp '(module (define L.fn.0.1
                              (begin
                                (begin
                                  (set! r15 1)
                                  (set! r15 1))
                                (if (if (begin
                                          (set! r14 9223372036854775807)
                                          (true))
                                        (begin
                                          (set! r14 -248968641)
                                          (false))
                                        (true))
                                    (begin
                                      (set! r15 r15)
                                      (halt 1622965009))
                                    (begin
                                      (set! r15 r15)
                                      (halt 1)))))
                            (jump L.fn.0.1)
                      ))
  (check-by-interp '(module (begin
                              (set! r15 -9223372036854775808)
                              (set! r15 (+ r15 -1465538260))
                              (set! r15 r15)
                              (halt 9223372035389237548))))
  (check-by-interp '(module (define L.fn.0.1
                              (begin
                                (set! r15 1)
                                (set! r15 (+ r15 9223372036854775807))
                                (set! r15 r15)
                                (set! r15 r15)
                                (set! r14 r15)
                                (halt -9223372036854775808)))
                            (define L.func.1.2
                              (begin
                                (if (begin
                                      (set! r15 1)
                                      (begin
                                        (set! r14 1)
                                        (false)))
                                    (begin
                                      (set! r15 406779451)
                                      (set! r15 1200977699))
                                    (begin
                                      (set! r15 0)
                                      (set! r15 r15)))
                                (set! r15 r15)
                                (set! r15 (* r15 r15))
                                (set! r15 r15)
                                (halt r15)))
                      (begin
                        (set! r15 1)
                        (set! r14 0)
                        (halt 1))))
  (check-by-interp '(module (define L.x.0.1
                              (begin
                                (set! r15 rdi)
                                (set! r15 rsi)
                                (jump L.tmp.1.2)))
                            (define L.tmp.1.2
                              (if (if (if (begin
                                            (set! r15 -765445006)
                                            (true))
                                          (begin
                                            (set! r15 0)
                                            (true))
                                          (begin
                                            (set! r15 9223372036854775807)
                                            (false)))
                                      (false)
                                      (true))
                                  (begin
                                    (set! r15 -9223372036854775808)
                                    (set! r15 r15)
                                    (halt -9223372036854775808))
                                  (begin
                                    (if (begin
                                          (set! r15 1)
                                          (true))
                                        (set! r15 -9223372036854775808)
                                        (set! r15 -9223372036854775808))
                                    (if (begin
                                          (set! r14 0)
                                          (false))
                                        (halt 0)
                                        (halt 9223372036854775807)))))
                      (define L.func.2.3
                        (begin
                          (set! r15 rdi)
                          (set! r15 rsi)
                          (jump L.tmp.1.2)))
                      (if (begin
                            (set! r15 0)
                            (true))
                          (halt -1271132888)
                          (halt 2101306416))))
  (check-by-interp '(module (define L.proc.0.1
                              (begin
                                (set! r15 rdi)
                                (begin
                                  (set! r14 -818241658)
                                  (set! r14 r14))
                                (set! r13 -1769976594)
                                (set! r13 (* r13 r14))
                                (set! r14 r13)
                                (if (!= r15 r15)
                                    (halt 1)
                                    (halt r15))))
                            (if (begin
                                  (set! r15 0)
                                  (true))
                                (halt 1764584349)
                                (halt -9223372036854775808))
                      ))
  (check-by-interp '(module (define L.proc.0.1
                              (begin
                                (set! r15 rdi)
                                (jump L.x.1.2)))
                            (define L.x.1.2 (halt 1))
                      (begin
                        (set! r15 453798193)
                        (set! r14 r15)
                        (if (begin
                              (set! r15 9223372036854775807)
                              (true))
                            (halt 0)
                            (halt -1617493587)))))
  (check-by-interp '(module (define L.func.0.1
                              (begin
                                (set! r15 rdi)
                                (if (begin
                                      (begin
                                        (set! r14 9223372036854775807)
                                        (set! r14 (* r14 r15))
                                        (set! r14 r14))
                                      (true))
                                    (if (< r15 -9223372036854775808)
                                        (halt r15)
                                        (halt r15))
                                    (jump L.proc.1.2))))
                            (define L.proc.1.2
                              (begin
                                (set! rdi 954069433)
                                (jump L.func.0.1)))
                      (jump L.proc.1.2)))
  (check-by-interp '(module (if (not (begin
                                       (set! r15 1)
                                       (false)))
                                (if (begin
                                      (set! r15 1)
                                      (false))
                                    (halt 9223372036854775807)
                                    (halt 1))
                                (halt 1))))
  (check-by-interp '(module (define L.func.0.1
                              (begin
                                (set! r15 rdi)
                                (set! r15 rsi)
                                (set! r15 rdx)
                                (set! r15 rcx)
                                (set! r15 r8)
                                (halt -1458025903)))
                            (begin
                              (set! r8 0)
                              (set! rcx -9223372036854775808)
                              (set! rdx -808937821)
                              (set! rsi 1)
                              (set! rdi -9223372036854775808)
                              (jump L.func.0.1))
                      ))
  (check-by-interp '(module (define L.tmp.0.1
                              (begin
                                (set! r14 rdi)
                                (set! r15 rsi)
                                (set! r13 rdx)
                                (set! r13 rcx)
                                (set! r14 r14)
                                (if (if (begin
                                          (set! r13 -9223372036854775808)
                                          (<= r13 r15))
                                        (begin
                                          (set! r13 -9223372036854775808)
                                          (>= r13 r14))
                                        (>= r15 2025307007))
                                    (begin
                                      (set! r15 r14)
                                      (set! r15 (+ r15 9223372036854775807))
                                      (set! r15 r15)
                                      (halt r15))
                                    (if (<= r15 -9223372036854775808)
                                        (halt 9223372036854775807)
                                        (halt 0)))))
                            (begin
                              (set! r15 0)
                              (halt 0))
                      ))
  (check-by-interp '(module (define L.func.0.1
                              (begin
                                (set! r15 rdi)
                                (set! r14 rsi)
                                (if (begin
                                      (set! r13 0)
                                      (= r13 r14))
                                    (begin
                                      (set! r15 -9223372036854775808)
                                      (set! r15 (+ r15 -9223372036854775808))
                                      (set! r15 r15)
                                      (halt 0))
                                    (if (if (< r15 r15)
                                            (<= r14 r14)
                                            (= r14 r15))
                                        (begin
                                          (set! r15 r14)
                                          (set! r15 (+ r15 r14))
                                          (set! r15 r15)
                                          (halt r15))
                                        (if (begin
                                              (set! r13 1)
                                              (= r13 r14))
                                            (halt r15)
                                            (halt r14))))))
                            (define L.x.1.2
                              (begin
                                (set! r15 rdi)
                                (set! r14 1757280127)
                                (set! r14 r14)
                                (set! r14 1)
                                (set! r14 -1128483887)
                                (if (begin
                                      (set! r15 r15)
                                      (> r15 r15))
                                    (halt -1128483887)
                                    (begin
                                      (set! r14 r14)
                                      (set! r14 (+ r14 r15))
                                      (set! r15 r14)
                                      (halt r15)))))
                      (define L.fn.2.3
                        (if (begin
                              (begin
                                (set! r15 -9223372036854775808)
                                (set! r15 (+ r15 -1421853645))
                                (set! r15 r15))
                              (not (begin
                                     (set! r15 0)
                                     (true))))
                            (begin
                              (set! r15 -167927521)
                              (set! r15 (+ r15 1))
                              (set! r15 r15)
                              (halt -167927520))
                            (begin
                              (set! r15 1041085683)
                              (set! r15 (* r15 9223372036854775807))
                              (set! r15 r15)
                              (set! r15 r15)
                              (halt 770292232))))
                      (begin
                        (set! rdi 1840464414)
                        (jump L.x.1.2))))
  (check-by-interp '(module (define L.proc.0.1
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
                                (jump L.proc.0.1)))
                      (begin
                        (set! r15 -579691794)
                        (halt 953357957))))
  (check-by-interp '(module (begin
                              (set! r15 9223372036854775807)
                              (set! r15 -546026276)
                              (halt 9223372036854775807))))
  (check-by-interp '(module (define L.func.0.1
                              (begin
                                (set! r14 rdi)
                                (set! r15 rsi)
                                (if (not (begin
                                           (set! r14 r14)
                                           (= r14 0)))
                                    (begin
                                      (set! r15 r14)
                                      (set! r15 (+ r15 0))
                                      (set! r15 r15)
                                      (set! r15 0)
                                      (set! r15 (* r15 9223372036854775807))
                                      (set! r15 r15)
                                      (halt 0))
                                    (begin
                                      (set! r14 0)
                                      (set! r14 (* r14 r15))
                                      (set! r14 r14)
                                      (halt r15)))))
                            (if (begin
                                  (set! r15 9223372036854775807)
                                  (false))
                                (halt 1)
                                (halt -9223372036854775808))
                      ))
  (check-by-interp '(module (define L.fn.0.1
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
                                (if (begin
                                      (set! r13 1)
                                      (true))
                                    (halt 9223372036854775807)
                                    (halt r15))))
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
                          (halt 956544412)))
                      (begin
                        (set! r15 979460199)
                        (set! r15 (+ r15 -1697959716))
                        (set! r15 r15)
                        (halt -718499517))))
  (check-by-interp '(module (define L.proc.0.1
                              (begin
                                (set! r15 rdi)
                                (set! r15 rsi)
                                (set! r15 rdx)
                                (set! r13 rcx)
                                (set! r14 r8)
                                (set! r9 r9)
                                (if (begin
                                      (set! r8 -669410514)
                                      (< r14 r14))
                                    (begin
                                      (set! r9 r9)
                                      (set! r9 (+ r9 r13))
                                      (set! r9 r9))
                                    (set! r9 r15))
                                (set! r13 r13)
                                (set! r13 1)
                                (if (<= r15 1)
                                    (halt 9223372036854775807)
                                    (halt r14))))
                            (begin
                              (set! r9 9223372036854775807)
                              (set! r8 -1891086346)
                              (set! rcx -1371550930)
                              (set! rdx 0)
                              (set! rsi 9223372036854775807)
                              (set! rdi 0)
                              (jump L.proc.0.1))
                      ))
  (check-by-interp '(module (define L.x.0.1
                              (begin
                                (set! r15 rdi)
                                (set! r15 rsi)
                                (set! r14 rdx)
                                (set! r13 rcx)
                                (set! r8 r8)
                                (set! r9 r9)
                                (set! rdi fv0)
                                (if (not (if (begin
                                               (set! rdi 388494724)
                                               (>= rdi r15))
                                             (> r13 -9223372036854775808)
                                             (< r14 r13)))
                                    (if (<= r8 r9)
                                        (halt 0)
                                        (begin
                                          (set! r15 r13)
                                          (halt 1887946265)))
                                    (halt r14))))
                            (define L.tmp.1.2
                              (begin
                                (set! r15 rdi)
                                (set! r15 rsi)
                                (set! r15 rdx)
                                (set! r14 rcx)
                                (set! r13 r8)
                                (set! r9 r9)
                                (begin
                                  (set! r15 r14)
                                  (set! r15 (* r15 9223372036854775807))
                                  (set! r15 r15)
                                  (halt r15))))
                      (define L.tmp.2.3
                        (begin
                          (set! r15 rdi)
                          (set! r15 rsi)
                          (set! r14 rdx)
                          (set! r13 rcx)
                          (set! r8 r8)
                          (set! r13 r9)
                          (if (begin
                                (set! r13 258314756)
                                (!= r8 0))
                              (set! r13 r8)
                              (begin
                                (set! r13 -1809848824)
                                (set! r13 9223372036854775807)))
                          (if (begin
                                (set! r9 1525021420)
                                (false))
                              (begin
                                (set! r9 1067478227)
                                (set! r8 -768559462)
                                (set! rcx r14)
                                (set! rdx -1256996529)
                                (set! rsi 1)
                                (set! rdi r13)
                                (jump L.tmp.1.2))
                              (if (begin
                                    (set! r14 389818959)
                                    (false))
                                  (halt r8)
                                  (halt r15)))))
                      (begin
                        (set! r15 1)
                        (halt 1))))
  (check-by-interp '(module (define L.tmp.0.1
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
                              (if (= r13 r13)
                                  (set! r14 r15)
                                  (set! r14 214741259))
                              (begin
                                (set! r14 1683358713)
                                (set! r14 (+ r14 r15))
                                (set! r14 r14)))
                          (set! fv0 -2043460455)
                          (set! r9 r13)
                          (set! r8 9223372036854775807)
                          (set! rcx r13)
                          (set! rdx 0)
                          (set! rsi r15)
                          (set! rdi r14)
                          (jump L.tmp.0.1)))
                      (begin
                        (set! fv0 -9223372036854775808)
                        (set! r9 1)
                        (set! r8 -9223372036854775808)
                        (set! rcx 9223372036854775807)
                        (set! rdx -9223372036854775808)
                        (set! rsi -9223372036854775808)
                        (set! rdi -9223372036854775808)
                        (jump L.tmp.0.1))))
  (check-by-interp '(module (begin
                              (set! r15 1)
                              (set! r15 (+ r15 -9223372036854775808))
                              (set! r15 r15)
                              (halt -9223372036854775807))))
  (check-by-interp '(module (define L.x.0.1
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
                                (if (begin
                                      (set! r15 -577997854)
                                      (false))
                                    (halt -9223372036854775808)
                                    (halt 9223372036854775807))))
                      (define L.fn.2.3
                        (begin
                          (set! r15 1)
                          (set! r15 (+ r15 1))
                          (set! r15 r15)
                          (begin
                            (set! r15 r15)
                            (halt 1969054361))))
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
                          (if (begin
                                (set! r8 rdi)
                                (> r14 r15))
                              (begin
                                (set! fv0 -1819248150)
                                (set! r9 r9)
                                (set! r8 r14)
                                (set! rcx r9)
                                (set! rdx r13)
                                (set! rsi 9223372036854775807)
                                (set! rdi -1863740769)
                                (jump L.x.0.1))
                              (halt 1))))
                      (define L.func.6.7
                        (begin
                          (set! r15 rdi)
                          (set! r14 rsi)
                          (set! r14 rdx)
                          (set! r14 rcx)
                          (set! r14 r8)
                          (set! r14 r9)
                          (set! r14 fv0)
                          (if (begin
                                (set! r15 r15)
                                (begin
                                  (set! r14 -1497437069)
                                  (true)))
                              (begin
                                (set! r15 r15)
                                (set! r15 (+ r15 r15))
                                (set! r15 r15)
                                (set! r15 0)
                                (halt 0))
                              (halt 1))))
                      (define L.fn.7.8
                        (if (not (begin
                                   (set! r15 0)
                                   (false)))
                            (begin
                              (set! r9 -1579752260)
                              (set! r8 0)
                              (set! rcx -1248542300)
                              (set! rdx 0)
                              (set! rsi 16140507)
                              (set! rdi -9223372036854775808)
                              (jump L.x.5.6))
                            (if (begin
                                  (set! r15 -9223372036854775808)
                                  (false))
                                (halt 1)
                                (halt 0))))
                      (if (begin
                            (if (begin
                                  (set! r15 -9223372036854775808)
                                  (true))
                                (begin
                                  (if (begin
                                        (set! r15 9223372036854775807)
                                        (true))
                                      (set! r15 -1444900091)
                                      (set! r15 -9223372036854775808))
                                  (set! r15 r15))
                                (begin
                                  (set! r15 9223372036854775807)
                                  (set! r15 r15)))
                            (begin
                              (set! r15 0)
                              (true)))
                          (halt 1)
                          (if (begin
                                (set! r15 1)
                                (false))
                              (jump L.fn.2.3)
                              (jump L.fn.2.3)))))
  ;; !!!

  (check-by-interp `(module (halt 1)))
  (check-by-interp `(module (define L.a.0 (halt 1)) (define L.b.0 (halt 2))
                      (jump L.a.0)))
  (check-by-interp `(module (begin
                              (halt 1))))

  (check-by-interp `(module (define L.a.0
                              (begin
                                (halt 1)))
                            (define L.b.0
                              (begin
                                (jump L.a.0)))
                      (jump L.b.0)))
  (check-by-interp `(module (begin
                              (begin
                                (halt 1)))))

  (check-by-interp `(module (define L.end.0
                              (begin
                                (halt rax)))
                            (define L.fact.0
                              (if (> rdi 0)
                                  (begin
                                    (set! rax (* rax rdi))
                                    (set! rdi (+ rdi -1))
                                    (jump L.fact.0))
                                  (jump L.end.0)))
                      (begin
                        (set! rax 1)
                        (set! rdi 5)
                        (jump L.fact.0))))

  (check-by-interp `(module (begin
                              (set! rax 1)
                              (set! rdi 5)
                              (halt rdi))))
  (check-by-interp `(module (begin
                              (set! rax 1)
                              (set! rdi 5)
                              (if (> rax rdi)
                                  (halt rdi)
                                  (halt rax)))))
  (check-by-interp `(module (begin
                              (set! rax 1)
                              (begin
                                (set! rsp 5)
                                (set! rdi 5))
                              (if (> rax rdi)
                                  (halt rdi)
                                  (halt rax)))))
  (check-by-interp `(module (begin
                              (set! rax 1)
                              (if (begin
                                    (set! rdi 5)
                                    (> rax rdi))
                                  (halt rdi)
                                  (halt rax)))))
  (check-by-interp `(module (begin
                              (set! rax 1)
                              (set! rdi 5)
                              (set! rsp 9)
                              (if (if (< rsp rdi)
                                      (> rax rdi)
                                      (> rax rsp))
                                  (halt rdi)
                                  (halt rax))))))
