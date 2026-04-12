#lang racket

(require cpsc411/compiler-lib
         "common.rkt")

(provide flatten-program)

;; block-asm-lang-v6 -> para-asm-lang-v6
;; Compile Block-asm-lang v6 to Para-asm-lang v6 by flattening basic blocks into labeled instructions.
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
           cpsc411/langs/v6)
  (define-syntax-rule (check-flatten-program bal4 pal4)
    (check-equal? (flatten-program bal4) pal4))

  (define-syntax-rule (check-by-interp p)
    (check-equal? (interp-block-asm-lang-v6 p) (interp-para-asm-lang-v6 (flatten-program p))))

  ;; M6 tests; Added by Trevor on March 6th 2026, multiple bindings allowed per let
  (check-by-interp '(module (define L.__main.10
                              (begin
                                (set! r15 r15)
                                (set! r14 9223372036854775807)
                                (jump L.tmp.9)))
                            (define L.proc.0.1
                              (begin
                                (set! r15 r15)
                                (set! r14 rdi)
                                (set! r14 rsi)
                                (set! r14 rdx)
                                (set! r14 rcx)
                                (set! r14 r8)
                                (set! r14 r9)
                                (set! r14 (rbp - 0))
                                (set! r15 r15)
                                (jump L.tmp.1.2)))
                      (define L.tmp.1.2
                        (begin
                          (set! r15 r15)
                          (set! rsi 0)
                          (set! rdi 0)
                          (set! r15 r15)
                          (jump L.proc.2.3)))
                      (define L.proc.2.3
                        (begin
                          (set! r15 r15)
                          (set! r13 rdi)
                          (set! r14 rsi)
                          (set! (rbp - 0) 1635273112)
                          (set! r9 r13)
                          (set! r8 r14)
                          (set! rcx r13)
                          (set! rdx 445965252)
                          (set! rsi r13)
                          (set! rdi r14)
                          (set! r15 r15)
                          (jump L.proc.0.1)))
                      (define L.tmp.8
                        (begin
                          (set! r14 692968731)
                          (jump L.__nested.5)))
                      (define L.tmp.9
                        (begin
                          (set! r14 -1490931083)
                          (jump L.__nested.4)))
                      (define L.__nested.6
                        (begin
                          (set! rax 0)
                          (jump r15)))
                      (define L.__nested.7
                        (begin
                          (set! rax 1843455920)
                          (jump r15)))
                      (define L.__nested.4
                        (begin
                          (set! rax 1275113131)
                          (jump r15)))
                      (define L.__nested.5
                        (begin
                          (set! r14 -1702177019)
                          (jump L.__nested.7)))))
  (check-by-interp '(module (define L.__main.2
                              (begin
                                (set! r15 r15)
                                (set! r14 9223372036854775807)
                                (set! r14 9223372036854775807)
                                (set! r13 9223372036854775807)
                                (set! rax r14)
                                (jump r15)))
                            (define L.fn.0.1
                              (begin
                                (set! r15 r15)
                                (set! r14 rdi)
                                (set! r13 rsi)
                                (set! r13 rdx)
                                (set! rdi rcx)
                                (set! r13 r8)
                                (set! r13 r9)
                                (set! r9 (rbp - 0))
                                (set! (rbp - 0) r13)
                                (set! r9 rdi)
                                (set! r8 rdi)
                                (set! rcx 9223372036854775807)
                                (set! rdx r14)
                                (set! rsi -9223372036854775808)
                                (set! rdi r13)
                                (set! r15 r15)
                                (jump L.fn.0.1)))
                      ))
  (check-by-interp '(module (define L.__main.6
                              (begin
                                (set! r15 r15)
                                (set! r14 9223372036854775807)
                                (jump L.__nested.5)))
                            (define L.func.0.1
                              (begin
                                (set! (rbp - 0) r15)
                                (set! r14 rdi)
                                (set! r15 rsi)
                                (set! r15 rdx)
                                (set! r13 rcx)
                                (set! (rbp - 8) r8)
                                (set! r14 r14)
                                (set! rbp (- rbp 16))
                                (set! rdx -1140169546)
                                (set! rsi r13)
                                (set! rdi r15)
                                (set! r15 L.rp.3)
                                (jump L.func.1.2)))
                      (define L.rp.3
                        (begin
                          (set! rbp (+ rbp 16))
                          (set! r15 rax)
                          (set! r14 (rbp - 8))
                          (set! r14 (+ r14 r15))
                          (set! rax r14)
                          (jump (rbp - 0))))
                      (define L.func.1.2
                        (begin
                          (set! r15 r15)
                          (set! r14 rdi)
                          (set! r13 rsi)
                          (set! r8 rdx)
                          (set! r9 9223372036854775807)
                          (jump L.__nested.7)))
                      (define L.__nested.7
                        (begin
                          (set! rdx r8)
                          (set! rsi r8)
                          (set! rdi r14)
                          (set! r15 r15)
                          (jump L.func.1.2)))
                      (define L.__nested.8
                        (begin
                          (set! r14 -9223372036854775808)
                          (set! r14 (+ r14 r13))
                          (set! rax r14)
                          (jump r15)))
                      (define L.__nested.4
                        (begin
                          (set! rax -877748660)
                          (jump r15)))
                      (define L.__nested.5
                        (begin
                          (set! rax -9223372036854775808)
                          (jump r15)))))
  (check-by-interp '(module (define L.__main.1
                              (begin
                                (set! r15 r15)
                                (set! r14 -1640821439)
                                (set! r14 (+ r14 -406700566))
                                (set! rax r14)
                                (jump r15)))))
  (check-by-interp '(module (define L.__main.3
                              (begin
                                (set! r15 r15)
                                (set! r14 -477286222)
                                (set! r14 0)
                                (set! rax 643069821)
                                (jump r15)))
                            (define L.fn.0.1
                              (begin
                                (set! r15 r15)
                                (set! r14 rdi)
                                (set! r13 rsi)
                                (set! r9 r14)
                                (set! r8 r13)
                                (set! rcx -9223372036854775808)
                                (set! rdx r13)
                                (set! rsi r14)
                                (set! rdi r13)
                                (set! r15 r15)
                                (jump L.x.1.2)))
                      (define L.x.1.2
                        (begin
                          (set! r15 r15)
                          (set! r14 rdi)
                          (set! r14 rsi)
                          (set! r14 rdx)
                          (set! r14 rcx)
                          (set! r13 r8)
                          (set! r13 r9)
                          (set! r9 r14)
                          (set! r8 1)
                          (set! rcx -984231193)
                          (set! rdx r13)
                          (set! rsi r13)
                          (set! rdi 933807622)
                          (set! r15 r15)
                          (jump L.x.1.2)))))
  (check-by-interp '(module (define L.__main.5
                              (begin
                                (set! r15 r15)
                                (set! r14 9223372036854775807)
                                (set! r14 (+ r14 -9223372036854775808))
                                (set! rax r14)
                                (jump r15)))
                            (define L.func.0.1
                              (begin
                                (set! r15 r15)
                                (set! r14 rdi)
                                (if (!= r14 r14)
                                    (jump L.__nested.6)
                                    (jump L.__nested.7))))
                      (define L.__nested.6
                        (begin
                          (set! rdi 2058053814)
                          (set! r15 r15)
                          (jump L.func.0.1)))
                      (define L.__nested.7
                        (begin
                          (set! r13 r14)
                          (set! r13 (- r13 r14))
                          (set! r13 r13)
                          (set! r14 r14)
                          (set! r14 r14)
                          (set! r14 r14)
                          (set! r13 r14)
                          (set! rdi r14)
                          (set! r15 r15)
                          (jump L.x.2.3)))
                      (define L.tmp.1.2
                        (begin
                          (set! r15 r15)
                          (set! r14 rdi)
                          (set! r13 rsi)
                          (set! r13 rdx)
                          (set! rdi r14)
                          (set! r15 r15)
                          (jump L.x.2.3)))
                      (define L.x.2.3
                        (begin
                          (set! (rbp - 0) r15)
                          (set! r15 rdi)
                          (set! rbp (- rbp 8))
                          (set! rdx -1942673900)
                          (set! rsi r15)
                          (set! rdi r15)
                          (set! r15 L.rp.4)
                          (jump L.tmp.1.2)))
                      (define L.__nested.8
                        (begin
                          (set! rdx -1386061378)
                          (set! rsi r15)
                          (set! rdi r15)
                          (set! r15 (rbp - 0))
                          (jump L.tmp.1.2)))
                      (define L.__nested.9
                        (begin
                          (set! rdi r15)
                          (set! r15 (rbp - 0))
                          (jump L.func.0.1)))
                      (define L.rp.4
                        (begin
                          (set! rbp (+ rbp 8))
                          (set! r15 rax)
                          (set! r15 r15)
                          (set! r15 r15)
                          (set! r15 r15)
                          (if (= r15 r15)
                              (jump L.__nested.8)
                              (jump L.__nested.9))))))
  (check-by-interp '(module (define L.__main.3
                              (begin
                                (set! r15 r15)
                                (set! r14 1)
                                (jump L.__nested.2)))
                            (define L.__nested.1
                              (begin
                                (set! rax 2012039291)
                                (jump r15)))
                      (define L.__nested.2
                        (begin
                          (set! rax 9223372036854775807)
                          (jump r15)))))
  (check-by-interp '(module (define L.__main.5
                              (begin
                                (set! r15 r15)
                                (set! rcx 9223372036854775807)
                                (set! rdx -1735352110)
                                (set! rsi 9223372036854775807)
                                (set! rdi 0)
                                (set! r15 r15)
                                (jump L.func.2.3)))
                            (define L.func.0.1
                              (begin
                                (set! r15 r15)
                                (set! r14 rdi)
                                (set! r13 rsi)
                                (set! r13 rdx)
                                (set! rdi rcx)
                                (set! r8 r8)
                                (set! r9 r9)
                                (set! r14 r14)
                                (set! r14 (- r14 r13))
                                (set! rax r14)
                                (jump r15)))
                      (define L.proc.1.2
                        (begin
                          (set! (rbp - 0) r15)
                          (set! r15 9223372036854775807)
                          (set! r15 (+ r15 1))
                          (set! (rbp - 8) r15)
                          (set! rbp (- rbp 16))
                          (set! r9 (rbp - -8))
                          (set! r8 (rbp - -8))
                          (set! rcx (rbp - -8))
                          (set! rdx (rbp - -8))
                          (set! rsi (rbp - -8))
                          (set! rdi 0)
                          (set! r15 L.rp.4)
                          (jump L.func.0.1)))
                      (define L.rp.4
                        (begin
                          (set! rbp (+ rbp 16))
                          (set! r15 rax)
                          (set! r14 (rbp - 8))
                          (if (>= (rbp - 8) (rbp - 8))
                              (jump L.tmp.6)
                              (jump L.tmp.7))))
                      (define L.tmp.6
                        (begin
                          (set! r14 (rbp - 8))
                          (jump L.tmp.8)))
                      (define L.tmp.7
                        (begin
                          (set! r14 (rbp - 8))
                          (jump L.tmp.8)))
                      (define L.tmp.8
                        (begin
                          (set! r15 r15)
                          (set! r15 r15)
                          (set! r15 -9223372036854775808)
                          (set! rax 9223372036854775807)
                          (jump (rbp - 0))))
                      (define L.func.2.3
                        (begin
                          (set! r15 r15)
                          (set! r14 rdi)
                          (set! r13 rsi)
                          (set! r9 rdx)
                          (set! r9 rcx)
                          (set! r13 r13)
                          (set! r9 r9)
                          (set! r9 r9)
                          (set! r8 r13)
                          (if (>= r13 r9)
                              (jump L.__nested.9)
                              (jump L.__nested.10))))
                      (define L.__nested.9
                        (begin
                          (set! rax r13)
                          (jump r15)))
                      (define L.__nested.10
                        (begin
                          (set! rax r14)
                          (jump r15)))))
  (check-by-interp '(module (define L.__main.6
                              (begin
                                (set! r15 r15)
                                (set! r14 -9223372036854775808)
                                (jump L.__nested.5)))
                            (define L.x.0.1
                              (begin
                                (set! (rbp - 8) r15)
                                (set! r15 rdi)
                                (set! (rbp - 24) rsi)
                                (set! r14 rdx)
                                (set! (rbp - 32) rcx)
                                (set! (rbp - 16) r8)
                                (set! r13 r9)
                                (set! r14 (rbp - 0))
                                (set! rbp (- rbp 40))
                                (set! (rbp - 0) r13)
                                (set! r9 r15)
                                (set! r8 r13)
                                (set! rcx 0)
                                (set! rdx r14)
                                (set! rsi (rbp - -8))
                                (set! rdi (rbp - -8))
                                (set! r15 L.rp.3)
                                (jump L.fn.1.2)))
                      (define L.__nested.9
                        (begin
                          (set! rax (rbp - 32))
                          (jump (rbp - 8))))
                      (define L.__nested.10
                        (begin
                          (set! rax (rbp - 24))
                          (jump (rbp - 8))))
                      (define L.__nested.7
                        (begin
                          (set! r14 (rbp - 16))
                          (set! r14 (+ r14 r15))
                          (set! rax r14)
                          (jump (rbp - 8))))
                      (define L.__nested.8
                        (if (<= (rbp - 32) 0)
                            (jump L.__nested.9)
                            (jump L.__nested.10)))
                      (define L.rp.3
                        (begin
                          (set! rbp (+ rbp 40))
                          (set! r15 rax)
                          (set! r14 0)
                          (jump L.__nested.7)))
                      (define L.fn.1.2
                        (begin
                          (set! r15 r15)
                          (set! r14 rdi)
                          (set! r14 rsi)
                          (set! r13 rdx)
                          (set! r13 rcx)
                          (set! r8 r8)
                          (set! r8 r9)
                          (set! r9 (rbp - 0))
                          (set! (rbp - 0) 0)
                          (set! r9 r14)
                          (set! r8 r8)
                          (set! rcx -9223372036854775808)
                          (set! rdx r14)
                          (set! rsi r8)
                          (set! rdi r13)
                          (set! r15 r15)
                          (jump L.fn.1.2)))
                      (define L.__nested.4
                        (begin
                          (set! rax -9223372036854775808)
                          (jump r15)))
                      (define L.__nested.5
                        (begin
                          (set! rax 0)
                          (jump r15)))))
  (check-by-interp '(module (define L.__main.1
                              (begin
                                (set! r15 r15)
                                (set! rax 9223372036854775807)
                                (jump r15)))))
  (check-by-interp '(module (define L.__main.7
                              (begin
                                (set! r15 r15)
                                (set! r14 -9223372036854775808)
                                (set! r13 9223372036854775807)
                                (set! r13 9223372036854775807)
                                (set! rax r14)
                                (jump r15)))
                            (define L.proc.0.1
                              (begin
                                (set! r15 r15)
                                (set! r14 rdi)
                                (set! r13 rsi)
                                (set! r13 rdx)
                                (set! rdi rcx)
                                (set! r13 r8)
                                (set! r9 r9)
                                (set! r9 rdi)
                                (set! r8 r14)
                                (set! rcx -635532414)
                                (set! rdx r13)
                                (set! rsi r13)
                                (set! rdi r13)
                                (set! r15 r15)
                                (jump L.proc.0.1)))
                      (define L.tmp.1.2
                        (begin
                          (set! (rbp - 8) r15)
                          (set! (rbp - 24) rdi)
                          (set! (rbp - 0) rsi)
                          (set! (rbp - 32) rdx)
                          (set! (rbp - 40) rcx)
                          (set! (rbp - 16) r8)
                          (set! rbp (- rbp 56))
                          (set! r8 (rbp - -40))
                          (set! rcx (rbp - -16))
                          (set! rdx (rbp - -32))
                          (set! rsi (rbp - -40))
                          (set! rdi (rbp - -16))
                          (set! r15 L.rp.4)
                          (jump L.tmp.1.2)))
                      (define L.rp.4
                        (begin
                          (set! rbp (+ rbp 56))
                          (set! (rbp - 48) rax)
                          (set! rbp (- rbp 56))
                          (set! (rbp - 0) (rbp - -40))
                          (set! r9 (rbp - -24))
                          (set! r8 (rbp - -16))
                          (set! rcx -501684781)
                          (set! rdx (rbp - -40))
                          (set! rsi 9223372036854775807)
                          (set! rdi (rbp - -56))
                          (set! r15 L.rp.5)
                          (jump L.func.2.3)))
                      (define L.rp.5
                        (begin
                          (set! rbp (+ rbp 56))
                          (set! r15 rax)
                          (set! r15 (rbp - 0))
                          (set! rbp (- rbp 56))
                          (set! (rbp - 0) (rbp - -32))
                          (set! r9 (rbp - -56))
                          (set! r8 (rbp - -24))
                          (set! rcx -9223372036854775808)
                          (set! rdx (rbp - -40))
                          (set! rsi 1644735104)
                          (set! rdi (rbp - -32))
                          (set! r15 L.rp.6)
                          (jump L.func.2.3)))
                      (define L.rp.6
                        (begin
                          (set! rbp (+ rbp 56))
                          (set! r15 rax)
                          (set! r14 (rbp - 48))
                          (set! r14 (- r14 (rbp - 48)))
                          (set! r14 r14)
                          (if (= (rbp - 48) r15)
                              (jump L.tmp.8)
                              (jump L.tmp.9))))
                      (define L.tmp.8
                        (begin
                          (set! r14 r15)
                          (jump L.tmp.10)))
                      (define L.tmp.9
                        (begin
                          (set! r14 (rbp - 48))
                          (jump L.tmp.10)))
                      (define L.tmp.10
                        (begin
                          (set! (rbp - 0) r15)
                          (set! r9 -9223372036854775808)
                          (set! r8 (rbp - 24))
                          (set! rcx r14)
                          (set! rdx (rbp - 16))
                          (set! rsi (rbp - 16))
                          (set! rdi r15)
                          (set! r15 (rbp - 8))
                          (jump L.func.2.3)))
                      (define L.func.2.3
                        (begin
                          (set! r15 r15)
                          (set! r14 rdi)
                          (set! r14 rsi)
                          (set! r14 rdx)
                          (set! r13 rcx)
                          (set! r14 r8)
                          (set! r9 r9)
                          (set! r8 (rbp - 0))
                          (set! (rbp - 0) 9223372036854775807)
                          (set! r9 r13)
                          (set! r8 r8)
                          (set! rcx r8)
                          (set! rdx r13)
                          (set! rsi -9223372036854775808)
                          (set! rdi r14)
                          (set! r15 r15)
                          (jump L.func.2.3)))))
  (check-by-interp '(module (define L.__main.7
                              (begin
                                (set! r15 r15)
                                (set! r14 405359082)
                                (set! r13 -915730633)
                                (jump L.tmp.4)))
                            (define L.func.0.1
                              (begin
                                (set! (rbp - 0) r15)
                                (set! r15 rdi)
                                (set! (rbp - 16) rsi)
                                (set! (rbp - 24) rdx)
                                (set! (rbp - 32) rcx)
                                (set! (rbp - 8) r8)
                                (set! r14 (rbp - 24))
                                (if (<= (rbp - 32) (rbp - 8))
                                    (jump L.tmp.10)
                                    (jump L.tmp.11))))
                      (define L.tmp.10
                        (begin
                          (set! r14 (rbp - 32))
                          (jump L.tmp.12)))
                      (define L.tmp.11
                        (begin
                          (set! r14 (rbp - 8))
                          (jump L.tmp.12)))
                      (define L.tmp.12
                        (begin
                          (set! rbp (- rbp 40))
                          (set! r8 (rbp - -32))
                          (set! rcx r15)
                          (set! rdx r15)
                          (set! rsi (rbp - -16))
                          (set! rdi 1)
                          (set! r15 L.rp.3)
                          (jump L.func.0.1)))
                      (define L.rp.3
                        (begin
                          (set! rbp (+ rbp 40))
                          (set! r15 rax)
                          (jump L.__nested.9)))
                      (define L.__nested.8
                        (begin
                          (set! r8 0)
                          (set! rcx (rbp - 24))
                          (set! rdx 1603961181)
                          (set! rsi (rbp - 16))
                          (set! rdi (rbp - 8))
                          (set! r15 (rbp - 0))
                          (jump L.func.0.1)))
                      (define L.__nested.9
                        (begin
                          (set! r9 (rbp - 32))
                          (set! r8 (rbp - 8))
                          (set! rcx (rbp - 16))
                          (set! rdx (rbp - 8))
                          (set! rsi -9223372036854775808)
                          (set! rdi (rbp - 16))
                          (set! r15 (rbp - 0))
                          (jump L.fn.1.2)))
                      (define L.fn.1.2
                        (begin
                          (set! r15 r15)
                          (set! r14 rdi)
                          (set! rdi rsi)
                          (set! rsi rdx)
                          (set! rdx rcx)
                          (set! r13 r8)
                          (set! r9 r9)
                          (if (>= r13 r14)
                              (jump L.tmp.17)
                              (jump L.tmp.18))))
                      (define L.tmp.17
                        (if (> rdi -9223372036854775808)
                            (jump L.__nested.13)
                            (jump L.__nested.14)))
                      (define L.tmp.18
                        (if (>= rsi r13)
                            (jump L.__nested.13)
                            (jump L.__nested.14)))
                      (define L.__nested.15
                        (begin
                          (set! rax rdx)
                          (jump r15)))
                      (define L.__nested.16
                        (begin
                          (set! rax rdi)
                          (jump r15)))
                      (define L.__nested.13
                        (begin
                          (set! r9 rdx)
                          (set! r9 9223372036854775807)
                          (set! r14 r14)
                          (set! rax r13)
                          (jump r15)))
                      (define L.__nested.14
                        (if (< r13 r14)
                            (jump L.__nested.15)
                            (jump L.__nested.16)))
                      (define L.tmp.4
                        (begin
                          (set! r13 -532660031)
                          (set! r13 -248685178)
                          (jump L.tmp.6)))
                      (define L.tmp.5
                        (begin
                          (set! r13 0)
                          (jump L.tmp.6)))
                      (define L.tmp.6
                        (begin
                          (set! r9 1254220652)
                          (set! r9 r14)
                          (set! r8 r13)
                          (set! rcx 9223372036854775807)
                          (set! rdx r13)
                          (set! rsi r13)
                          (set! rdi -9223372036854775808)
                          (set! r15 r15)
                          (jump L.fn.1.2)))))
  (check-by-interp '(module (define L.__main.5
                              (begin
                                (set! r15 r15)
                                (set! r14 0)
                                (set! r13 1029279872)
                                (set! rax r14)
                                (jump r15)))
                            (define L.proc.0.1
                              (begin
                                (set! r15 r15)
                                (set! r14 rdi)
                                (set! r14 rsi)
                                (set! r14 rdx)
                                (set! r13 rcx)
                                (set! r13 r8)
                                (set! r8 1)
                                (set! rcx -1754605622)
                                (set! rdx -675715652)
                                (set! rsi r14)
                                (set! rdi r13)
                                (set! r15 r15)
                                (jump L.proc.0.1)))
                      (define L.func.1.2
                        (begin
                          (set! r15 r15)
                          (set! r14 rdi)
                          (set! r13 rsi)
                          (set! r8 r13)
                          (set! rcx r13)
                          (set! rdx r14)
                          (set! rsi r14)
                          (set! rdi r13)
                          (set! r15 r15)
                          (jump L.proc.0.1)))
                      (define L.x.2.3
                        (begin
                          (set! (rbp - 8) r15)
                          (set! (rbp - 32) rdi)
                          (set! r14 rsi)
                          (set! r15 rdx)
                          (set! (rbp - 24) rcx)
                          (set! r13 r8)
                          (set! r9 r9)
                          (set! (rbp - 16) (rbp - 0))
                          (if (>= (rbp - 24) (rbp - 16))
                              (jump L.tmp.6)
                              (jump L.tmp.7))))
                      (define L.rp.4
                        (begin
                          (set! rbp (+ rbp 40))
                          (set! r15 rax)
                          (jump L.tmp.8)))
                      (define L.tmp.6
                        (begin
                          (set! r15 r14)
                          (jump L.tmp.8)))
                      (define L.tmp.7
                        (begin
                          (set! rbp (- rbp 40))
                          (set! (rbp - 0) 1783645727)
                          (set! r9 r9)
                          (set! r8 (rbp - -16))
                          (set! rcx r13)
                          (set! rdx 0)
                          (set! rsi r15)
                          (set! rdi 1)
                          (set! r15 L.rp.4)
                          (jump L.x.2.3)))
                      (define L.tmp.8
                        (begin
                          (set! r15 (rbp - 24))
                          (set! r15 (* r15 (rbp - 24)))
                          (set! r15 r15)
                          (set! (rbp - 0) (rbp - 24))
                          (set! r9 (rbp - 32))
                          (set! r8 -922337918)
                          (set! rcx (rbp - 16))
                          (set! rdx (rbp - 16))
                          (set! rsi (rbp - 24))
                          (set! rdi (rbp - 16))
                          (set! r15 (rbp - 8))
                          (jump L.x.2.3)))))
  (check-by-interp '(module (define L.__main.5
                              (begin
                                (set! r15 r15)
                                (set! r14 1)
                                (set! r13 -1606724555)
                                (jump L.tmp.3)))
                            (define L.tmp.3
                              (begin
                                (set! r14 1)
                                (set! r13 1)
                                (set! r13 -9223372036854775808)
                                (jump L.__nested.1)))
                      (define L.tmp.4
                        (begin
                          (set! r14 -1879829070)
                          (jump L.__nested.1)))
                      (define L.__nested.1
                        (begin
                          (set! r14 -634246165)
                          (set! r14 (- r14 -684848771))
                          (set! rax r14)
                          (jump r15)))
                      (define L.__nested.2
                        (begin
                          (set! rax 0)
                          (jump r15)))))
  (check-by-interp '(module (define L.__main.3
                              (begin
                                (set! r15 r15)
                                (set! r14 0)
                                (set! rax r14)
                                (jump r15)))
                            (define L.func.0.1
                              (begin
                                (set! r15 r15)
                                (set! r14 rdi)
                                (set! r13 rsi)
                                (set! r13 rdx)
                                (set! rdx r14)
                                (set! rsi -1803672217)
                                (set! rdi r14)
                                (set! r15 r15)
                                (jump L.proc.1.2)))
                      (define L.proc.1.2
                        (begin
                          (set! r15 r15)
                          (set! r14 rdi)
                          (set! r14 rsi)
                          (set! r13 rdx)
                          (set! rdx r13)
                          (set! rsi r14)
                          (set! rdi 1)
                          (set! r15 r15)
                          (jump L.proc.1.2)))))
  (check-by-interp '(module (define L.__main.1
                              (begin
                                (set! r15 r15)
                                (set! r14 1550347185)
                                (set! r14 9223372036854775807)
                                (set! r13 -9223372036854775808)
                                (set! r14 r14)
                                (set! r14 r14)
                                (set! r13 9223372036854775807)
                                (set! r13 (- r13 r14))
                                (set! rax r13)
                                (jump r15)))))
  (check-by-interp '(module (define L.__main.7
                              (begin
                                (set! r15 r15)
                                (set! r14 1)
                                (set! r14 -9223372036854775808)
                                (set! rax r14)
                                (jump r15)))
                            (define L.proc.0.1
                              (begin
                                (set! (rbp - 0) r15)
                                (set! (rbp - 24) rdi)
                                (set! (rbp - 16) rsi)
                                (set! (rbp - 8) rdx)
                                (set! rbp (- rbp 56))
                                (set! rdx (rbp - -48))
                                (set! rsi (rbp - -48))
                                (set! rdi 9223372036854775807)
                                (set! r15 L.rp.2)
                                (jump L.proc.0.1)))
                      (define L.__nested.10
                        (begin
                          (set! rax (rbp - 8))
                          (jump (rbp - 0))))
                      (define L.__nested.11
                        (begin
                          (set! rax r15)
                          (jump (rbp - 0))))
                      (define L.__nested.8
                        (if (>= (rbp - 40) (rbp - 40))
                            (jump L.__nested.10)
                            (jump L.__nested.11)))
                      (define L.__nested.9
                        (begin
                          (set! r15 -2087609688)
                          (set! r15 (rbp - 40))
                          (set! rax (rbp - 32))
                          (jump (rbp - 0))))
                      (define L.rp.2
                        (begin
                          (set! rbp (+ rbp 56))
                          (set! (rbp - 40) rax)
                          (set! rbp (- rbp 56))
                          (set! rdx (rbp - -32))
                          (set! rsi (rbp - -48))
                          (set! rdi (rbp - -32))
                          (set! r15 L.rp.3)
                          (jump L.proc.0.1)))
                      (define L.rp.3
                        (begin
                          (set! rbp (+ rbp 56))
                          (set! (rbp - 32) rax)
                          (set! rbp (- rbp 56))
                          (set! rdx (rbp - -32))
                          (set! rsi (rbp - -48))
                          (set! rdi (rbp - -48))
                          (set! r15 L.rp.4)
                          (jump L.proc.0.1)))
                      (define L.rp.4
                        (begin
                          (set! rbp (+ rbp 56))
                          (set! (rbp - 24) rax)
                          (set! r15 (rbp - 16))
                          (set! rbp (- rbp 56))
                          (set! rdx (rbp - -40))
                          (set! rsi (rbp - -48))
                          (set! rdi (rbp - -48))
                          (set! r15 L.rp.5)
                          (jump L.proc.0.1)))
                      (define L.rp.5
                        (begin
                          (set! rbp (+ rbp 56))
                          (set! r15 rax)
                          (set! rbp (- rbp 56))
                          (set! rdx (rbp - -32))
                          (set! rsi r15)
                          (set! rdi r15)
                          (set! r15 L.rp.6)
                          (jump L.proc.0.1)))
                      (define L.rp.6
                        (begin
                          (set! rbp (+ rbp 56))
                          (set! r15 rax)
                          (if (> r15 (rbp - 8))
                              (jump L.__nested.8)
                              (jump L.__nested.9))))))
  (check-by-interp '(module (define L.__main.4
                              (begin
                                (set! r15 r15)
                                (set! r14 1)
                                (set! r14 (+ r14 9223372036854775807))
                                (set! r14 r14)
                                (set! rax r14)
                                (jump r15)))
                            (define L.fn.0.1
                              (begin
                                (set! r15 r15)
                                (set! r14 rdi)
                                (set! rcx 2099518136)
                                (set! rdx r14)
                                (set! rsi r14)
                                (set! rdi r14)
                                (set! r15 r15)
                                (jump L.func.2.3)))
                      (define L.tmp.1.2
                        (begin
                          (set! r15 r15)
                          (set! r14 rdi)
                          (set! r14 rsi)
                          (set! rdi rdx)
                          (set! r13 rcx)
                          (set! r8 r8)
                          (set! r9 r9)
                          (set! r9 9223372036854775807)
                          (set! r9 rdi)
                          (set! r9 (+ r9 r14))
                          (set! r9 r9)
                          (set! r13 r13)
                          (set! r13 (+ r13 r14))
                          (set! r13 r13)
                          (set! r14 r14)
                          (set! rdi 0)
                          (set! r15 r15)
                          (jump L.fn.0.1)))
                      (define L.func.2.3
                        (begin
                          (set! r15 r15)
                          (set! r14 rdi)
                          (set! r13 rsi)
                          (set! r8 rdx)
                          (set! r13 rcx)
                          (set! r9 9223372036854775807)
                          (set! r8 r8)
                          (set! rcx r14)
                          (set! rdx r13)
                          (set! rsi r13)
                          (set! rdi 1)
                          (set! r15 r15)
                          (jump L.tmp.1.2)))))
  (check-by-interp '(module (define L.__main.1
                              (begin
                                (set! r15 r15)
                                (set! r14 0)
                                (set! r14 1)
                                (set! rax r14)
                                (jump r15)))))
  (check-by-interp '(module (define L.__main.3
                              (begin
                                (set! r15 r15)
                                (set! r9 -9223372036854775808)
                                (set! r8 0)
                                (set! rcx -9223372036854775808)
                                (set! rdx -9223372036854775808)
                                (set! rsi -2062025435)
                                (set! rdi 0)
                                (set! r15 r15)
                                (jump L.x.1.2)))
                            (define L.func.0.1
                              (begin
                                (set! r15 r15)
                                (set! r9 0)
                                (set! r8 1)
                                (set! rcx 9223372036854775807)
                                (set! rdx 9223372036854775807)
                                (set! rsi 1)
                                (set! rdi 38797657)
                                (set! r15 r15)
                                (jump L.x.1.2)))
                      (define L.x.1.2
                        (begin
                          (set! r15 r15)
                          (set! r14 rdi)
                          (set! r13 rsi)
                          (set! r13 rdx)
                          (set! rdi rcx)
                          (set! rsi r8)
                          (set! r8 r9)
                          (if (>= rsi rsi)
                              (jump L.tmp.6)
                              (jump L.tmp.7))))
                      (define L.tmp.6
                        (if (< r14 rdi)
                            (jump L.__nested.4)
                            (jump L.__nested.5)))
                      (define L.tmp.7
                        (if (< r8 812242710)
                            (jump L.__nested.4)
                            (jump L.__nested.5)))
                      (define L.__nested.4
                        (begin
                          (set! r14 rsi)
                          (set! r14 (- r14 rdi))
                          (set! rax r14)
                          (jump r15)))
                      (define L.__nested.5
                        (begin
                          (set! r15 r15)
                          (jump L.func.0.1)))))
  (check-by-interp '(module (define L.__main.3
                              (begin
                                (set! r15 r15)
                                (set! rax 1)
                                (jump r15)))
                            (define L.func.0.1
                              (begin
                                (set! r15 r15)
                                (set! r14 rdi)
                                (set! r13 rsi)
                                (set! r13 rdx)
                                (set! r9 rcx)
                                (set! rdx r13)
                                (set! rsi -9223372036854775808)
                                (set! rdi r14)
                                (set! r15 r15)
                                (jump L.proc.1.2)))
                      (define L.proc.1.2
                        (begin
                          (set! r15 r15)
                          (set! r14 rdi)
                          (set! r14 rsi)
                          (set! r13 rdx)
                          (set! r14 r14)
                          (set! r14 (- r14 r13))
                          (set! rax r14)
                          (jump r15)))))
  (check-by-interp '(module (define L.__main.1
                              (begin
                                (set! r15 r15)
                                (set! r14 -550916464)
                                (set! r14 9223372036854775807)
                                (set! rax r14)
                                (jump r15)))))
  (check-by-interp '(module (define L.__main.1
                              (begin
                                (set! r15 r15)
                                (set! r14 9223372036854775807)
                                (set! r14 (- r14 1))
                                (set! rax r14)
                                (jump r15)))))
  (check-by-interp '(module (define L.__main.7
                              (begin
                                (set! r15 r15)
                                (set! r14 9223372036854775807)
                                (jump L.__nested.5)))
                            (define L.tmp.0.1
                              (begin
                                (set! (rbp - 0) r15)
                                (set! (rbp - 16) rdi)
                                (set! (rbp - 8) rsi)
                                (set! r15 rdx)
                                (set! (rbp - 24) rcx)
                                (set! rbp (- rbp 32))
                                (set! rcx (rbp - -16))
                                (set! rdx (rbp - -8))
                                (set! rsi (rbp - -24))
                                (set! rdi (rbp - -24))
                                (set! r15 L.rp.3)
                                (jump L.tmp.0.1)))
                      (define L.rp.3
                        (begin
                          (set! rbp (+ rbp 32))
                          (set! r15 rax)
                          (set! r15 (rbp - 8))
                          (set! r15 (- r15 (rbp - 24)))
                          (set! r15 r15)
                          (set! r15 (rbp - 8))
                          (set! r15 1)
                          (set! r15 (rbp - 24))
                          (set! r15 (rbp - 16))
                          (set! rbp (- rbp 32))
                          (set! rdx (rbp - -16))
                          (set! rsi 9223372036854775807)
                          (set! rdi (rbp - -8))
                          (set! r15 L.rp.4)
                          (jump L.x.1.2)))
                      (define L.rp.4
                        (begin
                          (set! rbp (+ rbp 32))
                          (set! r15 rax)
                          (set! rdx (rbp - 8))
                          (set! rsi (rbp - 8))
                          (set! rdi -9223372036854775808)
                          (set! r15 (rbp - 0))
                          (jump L.x.1.2)))
                      (define L.x.1.2
                        (begin
                          (set! r15 r15)
                          (set! r9 rdi)
                          (set! r14 rsi)
                          (set! r13 rdx)
                          (set! rdx r13)
                          (set! rsi 580696126)
                          (set! rdi r13)
                          (set! r15 r15)
                          (jump L.x.1.2)))
                      (define L.__nested.5
                        (begin
                          (set! rax -1677147892)
                          (jump r15)))
                      (define L.__nested.6
                        (begin
                          (set! rax 874915829)
                          (jump r15)))))
  (check-by-interp '(module (define L.__main.8
                              (begin
                                (set! r15 r15)
                                (set! r14 -534391580)
                                (jump L.__nested.6)))
                            (define L.proc.0.1
                              (begin
                                (set! (rbp - 8) r15)
                                (set! (rbp - 40) rdi)
                                (set! (rbp - 24) rsi)
                                (set! (rbp - 48) rdx)
                                (set! r15 rcx)
                                (set! (rbp - 32) r8)
                                (set! (rbp - 16) r9)
                                (set! (rbp - 0) (rbp - 0))
                                (if (> (rbp - 0) -727829088)
                                    (jump L.__nested.10)
                                    (jump L.__nested.9))))
                      (define L.rp.4
                        (begin
                          (set! rbp (+ rbp 56))
                          (set! r15 rax)
                          (set! rbp (- rbp 56))
                          (set! r9 (rbp - -56))
                          (set! r8 -9223372036854775808)
                          (set! rcx (rbp - -24))
                          (set! rdx 1)
                          (set! rsi (rbp - -16))
                          (set! rdi (rbp - -8))
                          (set! r15 L.rp.5)
                          (jump L.fn.1.2)))
                      (define L.rp.5
                        (begin
                          (set! rbp (+ rbp 56))
                          (set! r15 rax)
                          (set! r15 (rbp - 24))
                          (set! rax (rbp - 16))
                          (jump (rbp - 8))))
                      (define L.__nested.9
                        (begin
                          (set! r14 (rbp - 40))
                          (set! rbp (- rbp 56))
                          (set! (rbp - 0) (rbp - -16))
                          (set! r9 (rbp - -16))
                          (set! r8 r15)
                          (set! rcx (rbp - -32))
                          (set! rdx (rbp - -8))
                          (set! rsi (rbp - -24))
                          (set! rdi (rbp - -32))
                          (set! r15 L.rp.4)
                          (jump L.proc.0.1)))
                      (define L.__nested.10
                        (begin
                          (set! rax -774243080)
                          (jump (rbp - 8))))
                      (define L.fn.1.2
                        (begin
                          (set! r15 r15)
                          (set! rdi rdi)
                          (set! r14 rsi)
                          (set! rsi rdx)
                          (set! rbx rcx)
                          (set! r13 r8)
                          (set! r8 r9)
                          (if (< r13 rdi)
                              (jump L.tmp.15)
                              (jump L.tmp.16))))
                      (define L.tmp.15
                        (if (>= rdi rbx)
                            (jump L.tmp.13)
                            (jump L.tmp.14)))
                      (define L.tmp.16
                        (if (!= r14 r14)
                            (jump L.tmp.13)
                            (jump L.tmp.14)))
                      (define L.tmp.17
                        (if (< rdi rdi)
                            (jump L.__nested.11)
                            (jump L.__nested.12)))
                      (define L.tmp.18
                        (if (>= rsi r13)
                            (jump L.__nested.11)
                            (jump L.__nested.12)))
                      (define L.tmp.13
                        (if (>= r8 rbx)
                            (jump L.tmp.17)
                            (jump L.tmp.18)))
                      (define L.tmp.14
                        (if (> rbx r8)
                            (jump L.__nested.12)
                            (jump L.__nested.11)))
                      (define L.__nested.11
                        (begin
                          (set! r9 -1548357748)
                          (set! r9 (- r9 r13))
                          (set! r13 r9)
                          (set! r9 r13)
                          (set! r8 rsi)
                          (set! rcx r14)
                          (set! rdx rsi)
                          (set! rsi 0)
                          (set! rdi r13)
                          (set! r15 r15)
                          (jump L.fn.1.2)))
                      (define L.__nested.12
                        (begin
                          (set! r9 rdi)
                          (set! r8 r8)
                          (set! rcx r8)
                          (set! rdx r14)
                          (set! rsi r13)
                          (set! rdi rbx)
                          (set! r15 r15)
                          (jump L.fn.2.3)))
                      (define L.fn.2.3
                        (begin
                          (set! r15 r15)
                          (set! r14 rdi)
                          (set! r14 rsi)
                          (set! r14 rdx)
                          (set! r13 rcx)
                          (set! r14 r8)
                          (set! r9 r9)
                          (set! r9 0)
                          (set! r8 1)
                          (set! rcx r14)
                          (set! rdx r13)
                          (set! rsi -9223372036854775808)
                          (set! rdi r14)
                          (set! r15 r15)
                          (jump L.fn.2.3)))
                      (define L.__nested.6
                        (begin
                          (set! rax 0)
                          (jump r15)))
                      (define L.__nested.7
                        (begin
                          (set! rax 0)
                          (jump r15)))))
  (check-by-interp '(module (define L.__main.1
                              (begin
                                (set! r15 r15)
                                (set! r14 -1762920629)
                                (set! r14 1)
                                (set! r14 9223372036854775807)
                                (set! rax 0)
                                (jump r15)))))
  (check-by-interp '(module (define L.__main.4
                              (begin
                                (set! r15 r15)
                                (set! r14 1038395452)
                                (jump L.__nested.2)))
                            (define L.proc.0.1
                              (begin
                                (set! r15 r15)
                                (set! r14 rdi)
                                (set! r13 rsi)
                                (set! rdi rdx)
                                (set! rdi rcx)
                                (set! r8 r8)
                                (set! r9 r9)
                                (set! r9 r13)
                                (set! r8 r13)
                                (set! rcx rdi)
                                (set! rdx r14)
                                (set! rsi 15882253)
                                (set! rdi r13)
                                (set! r15 r15)
                                (jump L.proc.0.1)))
                      (define L.__nested.2
                        (begin
                          (set! rax -9223372036854775808)
                          (jump r15)))
                      (define L.__nested.3
                        (begin
                          (set! rax 717010255)
                          (jump r15)))))
  (check-by-interp '(module (define L.__main.7
                              (begin
                                (set! r15 r15)
                                (set! r14 0)
                                (jump L.__nested.1)))
                            (define L.__nested.3
                              (begin
                                (set! rax 0)
                                (jump r15)))
                      (define L.__nested.4
                        (begin
                          (set! rax 9223372036854775807)
                          (jump r15)))
                      (define L.__nested.5
                        (begin
                          (set! rax 1)
                          (jump r15)))
                      (define L.__nested.6
                        (begin
                          (set! rax 9223372036854775807)
                          (jump r15)))
                      (define L.__nested.1
                        (begin
                          (set! r14 -9223372036854775808)
                          (jump L.__nested.4)))
                      (define L.__nested.2
                        (begin
                          (set! r14 -9223372036854775808)
                          (jump L.__nested.5)))))
  (check-by-interp '(module (define L.__main.5
                              (begin
                                (set! r15 r15)
                                (set! r14 0)
                                (jump L.__nested.1)))
                            (define L.__nested.3
                              (begin
                                (set! rax 0)
                                (jump r15)))
                      (define L.__nested.4
                        (begin
                          (set! rax -9223372036854775808)
                          (jump r15)))
                      (define L.__nested.1
                        (begin
                          (set! rax 1620518798)
                          (jump r15)))
                      (define L.__nested.2
                        (begin
                          (set! r14 0)
                          (jump L.__nested.3)))))
  (check-by-interp '(module (define L.__main.6
                              (begin
                                (set! r15 r15)
                                (set! r14 -9223372036854775808)
                                (jump L.__nested.5)))
                            (define L.func.0.1
                              (begin
                                (set! r15 r15)
                                (set! r14 rdi)
                                (set! r13 rsi)
                                (set! rdx 9223372036854775807)
                                (set! rsi r14)
                                (set! rdi r14)
                                (set! r15 r15)
                                (jump L.tmp.1.2)))
                      (define L.tmp.1.2
                        (begin
                          (set! r15 r15)
                          (set! r13 rdi)
                          (set! r14 rsi)
                          (set! r9 rdx)
                          (set! rdx r13)
                          (set! rsi 9223372036854775807)
                          (set! rdi r14)
                          (set! r15 r15)
                          (jump L.tmp.1.2)))
                      (define L.tmp.2.3
                        (begin
                          (set! r15 r15)
                          (set! r14 rdi)
                          (set! r13 rsi)
                          (set! rdi rdx)
                          (set! rdi rcx)
                          (set! r8 r8)
                          (set! r9 r9)
                          (set! r9 r13)
                          (set! r8 r8)
                          (set! rcx r14)
                          (set! rdx r8)
                          (set! rsi 1666412948)
                          (set! rdi 273235985)
                          (set! r15 r15)
                          (jump L.tmp.2.3)))
                      (define L.__nested.4
                        (begin
                          (set! rax 9223372036854775807)
                          (jump r15)))
                      (define L.__nested.5
                        (begin
                          (set! rax 1)
                          (jump r15)))))
  (check-by-interp '(module (define L.__main.2
                              (begin
                                (set! r15 r15)
                                (set! rax -167685894)
                                (jump r15)))
                            (define L.fn.0.1
                              (begin
                                (set! r15 r15)
                                (set! r14 rdi)
                                (set! r13 rsi)
                                (set! r9 rdx)
                                (set! rdi rcx)
                                (set! r9 r8)
                                (set! r8 r14)
                                (set! rcx rdi)
                                (set! rdx r13)
                                (set! rsi r14)
                                (set! rdi r9)
                                (set! r15 r15)
                                (jump L.fn.0.1)))
                      ))
  (check-by-interp '(module (define L.__main.4
                              (begin
                                (set! r15 r15)
                                (set! r14 1962527269)
                                (set! r14 (+ r14 9223372036854775807))
                                (set! rax r14)
                                (jump r15)))
                            (define L.func.0.1
                              (begin
                                (set! r15 r15)
                                (set! r14 rdi)
                                (set! r13 rsi)
                                (set! r9 r13)
                                (set! r8 r13)
                                (set! rcx r14)
                                (set! rdx r13)
                                (set! rsi r14)
                                (set! rdi r13)
                                (set! r15 r15)
                                (jump L.fn.2.3)))
                      (define L.fn.1.2
                        (begin
                          (set! r15 r15)
                          (set! r14 rdi)
                          (set! rdi rsi)
                          (set! r13 rdx)
                          (set! r14 rcx)
                          (set! r9 r8)
                          (set! r9 r9)
                          (set! r8 r13)
                          (set! r8 (- r8 rdi))
                          (set! r8 r8)
                          (set! rdi r9)
                          (set! r8 r8)
                          (set! r13 r13)
                          (set! r14 r14)
                          (set! r8 r9)
                          (set! rcx r14)
                          (set! rdx r9)
                          (set! rsi -9223372036854775808)
                          (set! rdi r14)
                          (set! r15 r15)
                          (jump L.fn.1.2)))
                      (define L.fn.2.3
                        (begin
                          (set! r15 r15)
                          (set! r14 rdi)
                          (set! r13 rsi)
                          (set! r13 rdx)
                          (set! r13 rcx)
                          (set! r8 r8)
                          (set! r9 r9)
                          (set! rsi r13)
                          (set! rdi r14)
                          (set! r15 r15)
                          (jump L.func.0.1)))))
  (check-by-interp '(module (define L.__main.2
                              (begin
                                (set! r15 r15)
                                (set! rdi 733499244)
                                (set! r15 r15)
                                (jump L.func.0.1)))
                            (define L.func.0.1
                              (begin
                                (set! r15 r15)
                                (set! r14 rdi)
                                (if (> r14 r14)
                                    (jump L.__nested.4)
                                    (jump L.__nested.3))))
                      (define L.__nested.5
                        (begin
                          (set! rax r14)
                          (jump r15)))
                      (define L.__nested.6
                        (begin
                          (set! rax r14)
                          (jump r15)))
                      (define L.__nested.3
                        (if (= r14 r14)
                            (jump L.__nested.5)
                            (jump L.__nested.6)))
                      (define L.__nested.4
                        (begin
                          (set! rdi 9223372036854775807)
                          (set! r15 r15)
                          (jump L.func.0.1)))))
  (check-by-interp '(module (define L.__main.5
                              (begin
                                (set! r15 r15)
                                (set! r14 1830309714)
                                (set! r13 -9223372036854775808)
                                (set! r13 -9223372036854775808)
                                (set! rax r14)
                                (jump r15)))
                            (define L.proc.0.1
                              (begin
                                (set! r15 r15)
                                (set! r14 rdi)
                                (set! r14 rsi)
                                (set! r13 rdx)
                                (set! r13 rcx)
                                (set! r8 r14)
                                (set! rcx 1)
                                (set! rdx 0)
                                (set! rsi -9223372036854775808)
                                (set! rdi 835392363)
                                (set! r15 r15)
                                (jump L.fn.1.2)))
                      (define L.fn.1.2
                        (begin
                          (set! r15 r15)
                          (set! r14 rdi)
                          (set! r14 rsi)
                          (set! r13 rdx)
                          (set! r13 rcx)
                          (set! r13 r8)
                          (set! rdi r14)
                          (set! r15 r15)
                          (jump L.x.2.3)))
                      (define L.x.2.3
                        (begin
                          (set! (rbp - 0) r15)
                          (set! (rbp - 8) rdi)
                          (set! rbp (- rbp 16))
                          (set! rcx (rbp - -8))
                          (set! rdx (rbp - -8))
                          (set! rsi (rbp - -8))
                          (set! rdi (rbp - -8))
                          (set! r15 L.rp.4)
                          (jump L.proc.0.1)))
                      (define L.rp.4
                        (begin
                          (set! rbp (+ rbp 16))
                          (set! r15 rax)
                          (set! r15 r15)
                          (set! r15 (- r15 r15))
                          (set! r15 r15)
                          (if (<= r15 (rbp - 8))
                              (jump L.tmp.6)
                              (jump L.tmp.7))))
                      (define L.tmp.6
                        (begin
                          (set! r14 r15)
                          (jump L.tmp.8)))
                      (define L.tmp.7
                        (begin
                          (set! r14 (rbp - 8))
                          (jump L.tmp.8)))
                      (define L.tmp.8
                        (begin
                          (set! r15 r15)
                          (set! r14 (rbp - 8))
                          (set! r14 r15)
                          (set! r15 r15)
                          (set! r15 (rbp - 8))
                          (set! rdi r15)
                          (set! r15 (rbp - 0))
                          (jump L.x.2.3)))))
  (check-by-interp '(module (define L.__main.5
                              (begin
                                (set! r15 r15)
                                (set! rax -575594324)
                                (jump r15)))
                            (define L.func.0.1
                              (begin
                                (set! r15 r15)
                                (set! r14 rdi)
                                (set! r14 rsi)
                                (set! r14 rdx)
                                (set! r14 rcx)
                                (set! r13 r8)
                                (set! rax r14)
                                (jump r15)))
                      (define L.func.1.2
                        (begin
                          (set! (rbp - 0) r15)
                          (set! r15 -620373304)
                          (set! r15 (- r15 -68719063))
                          (set! r15 r15)
                          (set! (rbp - 8) 0)
                          (set! rbp (- rbp 16))
                          (set! r15 L.rp.4)
                          (jump L.func.1.2)))
                      (define L.rp.4
                        (begin
                          (set! rbp (+ rbp 16))
                          (set! r15 rax)
                          (set! rax (rbp - 8))
                          (jump (rbp - 0))))
                      (define L.x.2.3
                        (begin
                          (set! r15 r15)
                          (set! r14 rdi)
                          (set! r15 r15)
                          (jump L.func.1.2)))))
  (check-by-interp '(module (define L.__main.7
                              (begin
                                (set! r15 r15)
                                (set! r14 0)
                                (jump L.__nested.3)))
                            (define L.x.0.1
                              (begin
                                (set! r15 r15)
                                (set! r14 rdi)
                                (set! r14 rsi)
                                (set! r14 rdx)
                                (set! r14 rcx)
                                (set! r13 r8)
                                (set! r13 r9)
                                (set! rsi 1)
                                (set! rdi r14)
                                (set! r15 r15)
                                (jump L.x.1.2)))
                      (define L.x.1.2
                        (begin
                          (set! r15 r15)
                          (set! r14 rdi)
                          (set! r13 rsi)
                          (if (<= r13 -9223372036854775808)
                              (jump L.__nested.8)
                              (jump L.__nested.9))))
                      (define L.__nested.8
                        (begin
                          (set! r9 r14)
                          (set! r8 r13)
                          (set! rcx r13)
                          (set! rdx r13)
                          (set! rsi r14)
                          (set! rdi r14)
                          (set! r15 r15)
                          (jump L.x.0.1)))
                      (define L.__nested.9
                        (begin
                          (set! rax r13)
                          (jump r15)))
                      (define L.__nested.5
                        (begin
                          (set! rax 1)
                          (jump r15)))
                      (define L.__nested.6
                        (begin
                          (set! rax 1)
                          (jump r15)))
                      (define L.__nested.3
                        (begin
                          (set! r14 996590913)
                          (set! r13 299367411)
                          (set! r13 -9223372036854775808)
                          (set! rax r14)
                          (jump r15)))
                      (define L.__nested.4
                        (begin
                          (set! r14 894536270)
                          (jump L.__nested.6)))))
  (check-by-interp '(module (define L.__main.8
                              (begin
                                (set! r15 r15)
                                (set! r14 1973720366)
                                (jump L.__nested.6)))
                            (define L.tmp.0.1
                              (begin
                                (set! r15 r15)
                                (set! r13 rdi)
                                (set! rdi rsi)
                                (set! r14 rdx)
                                (set! rbx rcx)
                                (set! r9 r8)
                                (if (<= rdi 9223372036854775807)
                                    (jump L.__nested.9)
                                    (jump L.__nested.10))))
                      (define L.__nested.9
                        (begin
                          (set! (rbp - 0) rbx)
                          (set! r9 -9223372036854775808)
                          (set! r8 1)
                          (set! rcx r14)
                          (set! rdx r13)
                          (set! rsi r14)
                          (set! rdi rbx)
                          (set! r15 r15)
                          (jump L.tmp.1.2)))
                      (define L.__nested.10
                        (begin
                          (set! r9 r9)
                          (set! r13 r13)
                          (set! r14 r14)
                          (set! rax r14)
                          (jump r15)))
                      (define L.tmp.1.2
                        (begin
                          (set! (rbp - 8) r15)
                          (set! r15 rdi)
                          (set! (rbp - 24) rsi)
                          (set! r15 rdx)
                          (set! r14 rcx)
                          (set! (rbp - 40) r8)
                          (set! (rbp - 16) r9)
                          (set! (rbp - 32) (rbp - 0))
                          (set! r13 1242010444)
                          (if (> r13 r15)
                              (jump L.tmp.12)
                              (jump L.tmp.11))))
                      (define L.rp.3
                        (begin
                          (set! rbp (+ rbp 56))
                          (set! (rbp - 48) rax)
                          (jump L.tmp.13)))
                      (define L.rp.4
                        (begin
                          (set! rbp (+ rbp 56))
                          (set! (rbp - 48) rax)
                          (jump L.tmp.13)))
                      (define L.tmp.11
                        (begin
                          (set! rbp (- rbp 56))
                          (set! r8 (rbp - -40))
                          (set! rcx 1)
                          (set! rdx r14)
                          (set! rsi (rbp - -40))
                          (set! rdi (rbp - -16))
                          (set! r15 L.rp.3)
                          (jump L.tmp.0.1)))
                      (define L.tmp.12
                        (begin
                          (set! rbp (- rbp 56))
                          (set! r8 r14)
                          (set! rcx r14)
                          (set! rdx (rbp - -32))
                          (set! rsi r15)
                          (set! rdi r15)
                          (set! r15 L.rp.4)
                          (jump L.tmp.0.1)))
                      (define L.tmp.13
                        (begin
                          (set! r15 (rbp - 32))
                          (set! r15 (* r15 (rbp - 24)))
                          (set! r15 r15)
                          (set! rbp (- rbp 56))
                          (set! r8 (rbp - -16))
                          (set! rcx (rbp - -16))
                          (set! rdx 0)
                          (set! rsi (rbp - -32))
                          (set! rdi (rbp - -32))
                          (set! r15 L.rp.5)
                          (jump L.tmp.0.1)))
                      (define L.rp.5
                        (begin
                          (set! rbp (+ rbp 56))
                          (set! r15 rax)
                          (set! (rbp - 0) (rbp - 16))
                          (set! r9 (rbp - 48))
                          (set! r8 (rbp - 32))
                          (set! rcx r15)
                          (set! rdx 1)
                          (set! rsi (rbp - 24))
                          (set! rdi (rbp - 16))
                          (set! r15 (rbp - 8))
                          (jump L.tmp.1.2)))
                      (define L.__nested.6
                        (begin
                          (set! rax 9223372036854775807)
                          (jump r15)))
                      (define L.__nested.7
                        (begin
                          (set! (rbp - 0) 379193781)
                          (set! r9 726597669)
                          (set! r8 -264137160)
                          (set! rcx -1022801227)
                          (set! rdx 501537014)
                          (set! rsi 9223372036854775807)
                          (set! rdi 9223372036854775807)
                          (set! r15 r15)
                          (jump L.tmp.1.2)))))
  (check-by-interp '(module (define L.__main.1
                              (begin
                                (set! r15 r15)
                                (set! r9 1521957632)
                                (set! r13 -9223372036854775808)
                                (set! r14 -9223372036854775808)
                                (set! rax 0)
                                (jump r15)))))
  (check-by-interp '(module (define L.__main.1
                              (begin
                                (set! r15 r15)
                                (set! r14 -9223372036854775808)
                                (set! r13 0)
                                (set! r14 r14)
                                (set! r14 r14)
                                (set! r13 r14)
                                (set! r14 r14)
                                (set! r14 r14)
                                (set! r13 r13)
                                (set! rax r14)
                                (jump r15)))))
  (check-by-interp '(module (define L.__main.1
                              (begin
                                (set! r15 r15)
                                (set! r14 1)
                                (set! r14 r14)
                                (set! r14 r14)
                                (set! r14 r14)
                                (set! r14 r14)
                                (set! r13 r14)
                                (set! r13 r14)
                                (set! r13 (+ r13 r14))
                                (set! r13 r13)
                                (set! r13 r14)
                                (set! r13 1648274049)
                                (set! rax r14)
                                (jump r15)))))
  (check-by-interp '(module (define L.__main.2
                              (begin
                                (set! r15 r15)
                                (set! rax 0)
                                (jump r15)))
                            (define L.func.0.1
                              (begin
                                (set! r15 r15)
                                (set! r14 rdi)
                                (set! r14 rsi)
                                (set! rsi r14)
                                (set! rdi 1)
                                (set! r15 r15)
                                (jump L.func.0.1)))
                      ))
  (check-by-interp '(module (define L.__main.3
                              (begin
                                (set! r15 r15)
                                (set! r14 -9223372036854775808)
                                (jump L.__nested.2)))
                            (define L.__nested.1
                              (begin
                                (set! rax -9223372036854775808)
                                (jump r15)))
                      (define L.__nested.2
                        (begin
                          (set! rax 9223372036854775807)
                          (jump r15)))))
  (check-by-interp '(module (define L.__main.3
                              (begin
                                (set! r15 r15)
                                (set! r9 0)
                                (set! r8 0)
                                (set! rcx 1)
                                (set! rdx 1)
                                (set! rsi -1337458253)
                                (set! rdi 9223372036854775807)
                                (set! r15 r15)
                                (jump L.func.1.2)))
                            (define L.fn.0.1
                              (begin
                                (set! r15 r15)
                                (set! r14 rdi)
                                (set! r14 rsi)
                                (set! r13 rdx)
                                (set! rdi rcx)
                                (set! r13 r8)
                                (set! r9 r14)
                                (set! r8 rdi)
                                (set! rcx r13)
                                (set! rdx 1064830001)
                                (set! rsi r14)
                                (set! rdi r13)
                                (set! r15 r15)
                                (jump L.func.1.2)))
                      (define L.func.1.2
                        (begin
                          (set! r15 r15)
                          (set! r14 rdi)
                          (set! rsi rsi)
                          (set! rdi rdx)
                          (set! rdx rcx)
                          (set! r8 r8)
                          (set! r13 r9)
                          (if (< r8 r8)
                              (jump L.tmp.10)
                              (jump L.tmp.11))))
                      (define L.tmp.10
                        (if (= r14 r14)
                            (jump L.tmp.8)
                            (jump L.tmp.9)))
                      (define L.tmp.11
                        (if (!= rsi r8)
                            (jump L.tmp.8)
                            (jump L.tmp.9)))
                      (define L.tmp.12
                        (begin
                          (set! r9 1)
                          (if (<= r9 rdx)
                              (jump L.__nested.4)
                              (jump L.__nested.5))))
                      (define L.tmp.13
                        (begin
                          (set! r9 529266316)
                          (if (>= r9 r8)
                              (jump L.__nested.4)
                              (jump L.__nested.5))))
                      (define L.tmp.8
                        (if (= r13 0)
                            (jump L.__nested.4)
                            (jump L.__nested.5)))
                      (define L.tmp.9
                        (begin
                          (set! r9 0)
                          (if (> r9 r13)
                              (jump L.tmp.12)
                              (jump L.tmp.13))))
                      (define L.__nested.6
                        (begin
                          (set! r14 r13)
                          (set! rax r13)
                          (jump r15)))
                      (define L.__nested.7
                        (begin
                          (set! r9 r13)
                          (set! r8 rdi)
                          (set! rcx rsi)
                          (set! rdx rsi)
                          (set! rsi r14)
                          (set! rdi rdi)
                          (set! r15 r15)
                          (jump L.func.1.2)))
                      (define L.__nested.4
                        (begin
                          (set! r9 rdi)
                          (if (<= rdx r9)
                              (jump L.__nested.6)
                              (jump L.__nested.7))))
                      (define L.__nested.5
                        (begin
                          (set! r14 rdi)
                          (set! r14 r14)
                          (set! r9 rdi)
                          (set! r8 r14)
                          (set! rcx rdi)
                          (set! rdx r13)
                          (set! rsi r13)
                          (set! rdi r14)
                          (set! r15 r15)
                          (jump L.func.1.2)))))
  (check-by-interp '(module (define L.__main.5
                              (begin
                                (set! r15 r15)
                                (set! r14 9223372036854775807)
                                (jump L.tmp.3)))
                            (define L.tmp.3 (jump L.__nested.1))
                      (define L.tmp.4
                        (begin
                          (set! r14 9223372036854775807)
                          (jump L.__nested.1)))
                      (define L.__nested.1
                        (begin
                          (set! r14 -9223372036854775808)
                          (set! r14 -9223372036854775808)
                          (set! r13 9223372036854775807)
                          (set! r13 (* r13 -9223372036854775808))
                          (set! r13 r13)
                          (set! rax r14)
                          (jump r15)))
                      (define L.__nested.2
                        (begin
                          (set! r14 1865158198)
                          (set! r14 (+ r14 1))
                          (set! r14 r14)
                          (set! rax r14)
                          (jump r15)))))
  (check-by-interp '(module (define L.__main.3
                              (begin
                                (set! r15 r15)
                                (set! r14 1069510162)
                                (jump L.__nested.1)))
                            (define L.__nested.1
                              (begin
                                (set! rax 1)
                                (jump r15)))
                      (define L.__nested.2
                        (begin
                          (set! rax 323863587)
                          (jump r15)))))
  (check-by-interp '(module (define L.__main.1
                              (begin
                                (set! r15 r15)
                                (set! r14 379335310)
                                (set! r14 (* r14 0))
                                (set! rax r14)
                                (jump r15)))))
  (check-by-interp '(module (define L.__main.1
                              (begin
                                (set! r15 r15)
                                (set! rax 0)
                                (jump r15)))))
  (check-by-interp '(module (define L.__main.1
                              (begin
                                (set! r15 r15)
                                (set! r14 -9223372036854775808)
                                (set! r14 (- r14 0))
                                (set! r13 r14)
                                (set! r14 -9223372036854775808)
                                (set! r9 1969620648)
                                (set! r13 r13)
                                (set! r14 r14)
                                (set! rax r13)
                                (jump r15)))))
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
