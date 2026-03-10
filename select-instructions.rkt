#lang racket

(require cpsc411/compiler-lib)

(provide select-instructions)

;; (imp-cmf-lang-v5 p) -> (asm-pred-lang-v5 p)
;; Compiles imp-cmf-lang-v5 to asm-pred-lang-v5 by selecting appropriate sequences of abstract
;; assembly instructions to implement the operations of the source language.
(define (select-instructions p)

  ; (imp-cmf-lang-v5 value) -> (List-of (asm-pred-lang-v5 effect)) and (asm-pred-lang-v5 aloc)
  ; Assigns the value v to a fresh temporary, returning two values: the list of
  ; statements that implement the assignment in asm-pred-lang, and the aloc that the
  ; value is stored in.
  (define (assign-tmp v)
    (define tmp (fresh 'tmp))
    (match v
      [`(,binop ,triv1 ,triv2)
       (list (list `(set! ,tmp ,triv1) `(set! ,tmp (,binop ,tmp ,triv2))) tmp)]
      [_ (list (list `(set! ,tmp ,v)) tmp)]))

  (define (select-pred pred)
    (match pred
      [`(not ,pred) `(not ,(select-pred pred))]
      [`(begin
          ,fxs ...
          ,pred)
       (append `(begin) (foldr append '() (map select-effect fxs)) (list (select-pred pred)))]
      [`(if ,pred1 ,pred2 ,pred3)
       `(if ,(select-pred pred1)
            ,(select-pred pred2)
            ,(select-pred pred3))]
      [`(,relop ,triv1 ,triv2)
       #:when (int64? triv1)
       (match-let ([`(,fxs ,aloc) (assign-tmp triv1)])
         `(begin
            ,@fxs
            (,relop ,aloc ,triv2)))]
      [_ pred]))

  ; (imp-cmf-lang-v5 tail) [bool] -> (asm-pred-lang-v5 tail)
  (define (select-tail e [begun #f])
    (match e
      [`(begin
          ,fxs ...
          ,tail)
       (append (if (not begun)
                   '(begin)
                   '())
               (foldr append '() (map select-effect fxs))
               (select-tail tail #t))]
      [`(if ,pred ,tail1 ,tail2)
       (let ([result `(if ,(select-pred pred)
                          ,(select-tail tail1)
                          ,(select-tail tail2))])
         (if (not begun)
             result
             `(,result)))]
      [`(jump ,trg ,loc ...)
       (if begun
           `(,e)
           e)]
      [_
       (match-let ([`(,fxs ,atail) (select-value e)])
         (append (if (not begun)
                     '(begin)
                     '())
                 fxs
                 (list atail)))]))

  ; (imp-cmf-lang-v5 value) -> (list (listof (asm-pred-lang-v5 effect)) (asm-pred-lang-v5 tail))
  (define (select-value e)
    (match e
      [`(,binop ,triv1 ,triv2)
       (match-let ([`(,fxs ,aloc) (assign-tmp e)])
         (list fxs `(halt ,aloc)))]
      [_ `(() (halt ,e))]))

  ; (imp-cmf-lang-v5 value) -> (listof (asm-pred-lang-v5 effect))
  ;; selects appropriate abstract assembly instructions for values in effect position
  (define (value->effect* loc value)
    (match value
      [`(,binop ,opand1 ,opand2)
       #:when (not (equal? opand1 loc))
       `((set! ,loc ,opand1) (set! ,loc (,binop ,loc ,opand2)))]
      [_ `((set! ,loc ,value))]))

  ; (imp-cmf-lang-v5 effect) -> (listof (asm-pred-lang-v5 effect))
  (define (select-effect e)
    (match e
      [`(set! ,loc ,rest) (value->effect* loc rest)]
      [`(begin
          ,fxs ...)
       (list `(begin
                ,@(foldr append '() (map select-effect fxs))))]
      [`(if ,pred ,effect1 ,effect2)
       (define e1 (select-effect effect1))
       (define e2 (select-effect effect2))
       `((if ,(select-pred pred)
             ,(if (null? (rest e1))
                  (first e1)
                  `(begin
                     ,@e1))
             ,(if (null? (rest e1))
                  (first e2)
                  `(begin
                     ,@e2))))]))

  ;; (imp-cmf-lang-v5 definition) -> (imp-cmf-lang-v5 definition)
  (define (select-def def)
    (match def
      [`(define ,label ,tail)
       `(define ,label
          ()
          ,(select-tail tail))]))

  (define (select-p p)
    (match p
      [`(module ,defs ...
          ,tail)
       `(module () ,@(map select-def defs)
          ,(select-tail tail))]))

  (select-p p))

(module+ test

  (require rackunit
           cpsc411/langs/v5)
  (define-syntax-rule (check-by-interp icmflv5)
    (check-equal? (interp-imp-cmf-lang-v5 icmflv5)
                  (interp-asm-pred-lang-v5 (select-instructions icmflv5))))

  ;; M5 tests; Added by Trevor on March 8th 2026, multiple bindings allowed per let
  (check-by-interp '(module (define L.fn.0.1
                              (begin
                                (set! bat.1.6 rdi)
                                (set! foobar.5.5 rsi)
                                (set! foobar.8.4 rdx)
                                (set! foo.0.3 rcx)
                                (set! foo.3.2 r8)
                                (set! foo.4.1 r9)
                                (if (true)
                                    (if (= -502092639 foobar.5.5)
                                        (if (>= foobar.8.4 1) 1852032564 -106704231)
                                        (+ foo.4.1 1))
                                    (if (true)
                                        (+ -9223372036854775808 0)
                                        (begin
                                          (set! foo.4.8 foobar.5.5)
                                          (set! foo.3.7 0)
                                          foo.0.3)))))
                            (if (begin
                                  (set! foo.4.10 -9223372036854775808)
                                  (set! ball.7.9 0)
                                  (> foo.4.10 ball.7.9))
                                -9223372036854775808
                                (begin
                                  (set! bat.1.13 -9223372036854775808)
                                  (set! foo.4.12 1)
                                  (set! foobar.8.11 1)
                                  foobar.8.11))
                      ))
  (check-by-interp '(module (define L.tmp.0.1
                              (begin
                                (set! bat.2.6 rdi)
                                (set! bat.0.5 rsi)
                                (set! foobar.5.4 rdx)
                                (set! foobar.6.3 rcx)
                                (set! bat.8.2 r8)
                                (set! foo.9.1 r9)
                                (begin
                                  (if (true)
                                      (set! foobar.6.8 (* bat.0.5 -1194246923))
                                      (set! foobar.6.8 foobar.5.4))
                                  (if (begin
                                        (set! bat.2.10 foobar.5.4)
                                        (set! bat.4.9 foo.9.1)
                                        (= bat.2.10 422731415))
                                      (if (<= 9223372036854775807 9223372036854775807)
                                          (set! foobar.5.7 9223372036854775807)
                                          (set! foobar.5.7 9223372036854775807))
                                      (set! foobar.5.7 (+ foo.9.1 52582991)))
                                  (begin
                                    (set! r9 foo.9.1)
                                    (set! r8 bat.8.2)
                                    (set! rcx 0)
                                    (set! rdx -1002513727)
                                    (set! rsi -191435828)
                                    (set! rdi foobar.6.8)
                                    (jump L.tmp.0.1 rbp rdi rsi rdx rcx r8 r9)))))
                            (begin
                              (set! bat.0.12 (+ -9223372036854775808 937267391))
                              (set! bat.2.11 (+ -9223372036854775808 -9223372036854775808))
                              (if (!= bat.2.11 1) -335809824 bat.0.12))
                      ))
  (check-by-interp '(module (define L.proc.0.1
                              (begin
                                (set! ball.1.3 rdi)
                                (set! bat.9.2 rsi)
                                (set! foobar.2.1 rdx)
                                (if (false)
                                    (begin
                                      (set! r8 1)
                                      (set! rcx ball.1.3)
                                      (set! rdx bat.9.2)
                                      (set! rsi 9223372036854775807)
                                      (set! rdi bat.9.2)
                                      (jump L.tmp.1.2 rbp rdi rsi rdx rcx r8))
                                    (begin
                                      (begin
                                        (set! bar.5.8 1554173211)
                                        (set! foobar.2.7 616342412)
                                        (set! bat.7.6 foobar.2.7))
                                      (if (= foobar.2.1 ball.1.3)
                                          (set! ball.1.5 foobar.2.1)
                                          (set! ball.1.5 bat.9.2))
                                      (if (= 1 0)
                                          (set! ball.3.4 bat.9.2)
                                          (set! ball.3.4 0))
                                      (if (< 1320805275 9223372036854775807) 0 0)))))
                            (define L.tmp.1.2
                              (begin
                                (set! bat.7.13 rdi)
                                (set! ball.1.12 rsi)
                                (set! foobar.2.11 rdx)
                                (set! ball.3.10 rcx)
                                (set! ball.8.9 r8)
                                (begin
                                  (set! rdx ball.8.9)
                                  (set! rsi 9223372036854775807)
                                  (set! rdi ball.3.10)
                                  (jump L.proc.0.1 rbp rdi rsi rdx))))
                      (begin
                        (begin
                          (set! foobar.0.19 2142022224)
                          (set! foo.6.18 0)
                          (set! bat.7.17 1)
                          (set! foo.6.16 foo.6.18))
                        (set! foobar.2.15 (+ 1 121573080))
                        (set! bat.9.14 (* 9223372036854775807 -1355489058))
                        0)))
  (check-by-interp '(module (begin
                              (set! ball.5.3 (+ 0 9223372036854775807))
                              (set! ball.7.2 -678062995)
                              (if (!= 0 9223372036854775807)
                                  (set! ball.8.1 -2004574473)
                                  (set! ball.8.1 9223372036854775807))
                              (* 1 ball.5.3))))
  (check-by-interp '(module (define L.fn.0.1
                              (begin
                                (set! foo.3.3 rdi)
                                (set! foo.1.2 rsi)
                                (set! bat.4.1 rdx)
                                (begin
                                  (set! rdx foo.1.2)
                                  (set! rsi bat.4.1)
                                  (set! rdi foo.1.2)
                                  (jump L.fn.0.1 rbp rdi rsi rdx))))
                            (define L.tmp.1.2
                              (begin
                                (if (true)
                                    (begin
                                      (begin
                                        (set! foo.1.8 -918704320)
                                        (set! foo.6.7 -1822595193)
                                        (set! ball.0.6 foo.6.7))
                                      (set! bat.4.5 0)
                                      (set! foo.7.4 (* 9223372036854775807 810114007))
                                      (begin
                                        (set! foo.9.11 1)
                                        (set! foo.7.10 foo.7.4)
                                        (set! bat.8.9 1)
                                        1271317139))
                                    (if (begin
                                          (set! ball.0.13 9223372036854775807)
                                          (set! foobar.5.12 -9223372036854775808)
                                          (< 1474008962 ball.0.13))
                                        (if (!= -566856990 -9223372036854775808) 1 1056302987)
                                        (begin
                                          (jump L.tmp.1.2 rbp))))))
                      (begin
                        (begin
                          (set! bat.4.17 -9223372036854775808)
                          (set! foo.7.16 9223372036854775807)
                          (set! foo.1.15 bat.4.17))
                        (if (>= -1846550218 1836975164)
                            (set! foo.6.14 -186139937)
                            (set! foo.6.14 1))
                        (begin
                          (set! foo.7.19 1884722986)
                          (set! foo.6.18 9223372036854775807)
                          0))))
  (check-by-interp '(module (define L.func.0.1
                              (begin
                                (set! bat.0.6 rdi)
                                (set! bat.7.5 rsi)
                                (set! bar.6.4 rdx)
                                (set! foo.2.3 rcx)
                                (set! foobar.5.2 r8)
                                (set! foo.9.1 r9)
                                bat.0.6))
                            (define L.func.1.2
                              (begin
                                (set! foobar.1.8 rdi)
                                (set! bat.0.7 rsi)
                                (begin
                                  (begin
                                    (set! bat.8.13 0)
                                    (begin
                                      (set! foo.2.16 foobar.1.8)
                                      (set! bat.8.15 1492712685)
                                      (set! foo.4.14 foobar.1.8)
                                      (set! bar.3.12 9223372036854775807))
                                    (set! foobar.1.11 bar.3.12))
                                  (begin
                                    (begin
                                      (set! bat.8.21 bat.0.7)
                                      (set! foo.2.20 foobar.1.8)
                                      (set! foo.4.19 -383652955)
                                      (set! foobar.5.18 -9223372036854775808))
                                    (set! foobar.1.17 (+ bat.0.7 566306668))
                                    (if (!= bat.0.7 0)
                                        (set! bar.3.10 -9223372036854775808)
                                        (set! bar.3.10 bat.0.7)))
                                  (if (false)
                                      (set! bat.0.9 (* 1 0))
                                      (set! bat.0.9 foobar.1.8))
                                  bar.3.10)))
                      (begin
                        (set! rsi 0)
                        (set! rdi -9223372036854775808)
                        (jump L.func.1.2 rbp rdi rsi))))
  (check-by-interp '(module (define L.tmp.0.1
                              (begin
                                (set! foobar.0.6 rdi)
                                (set! bar.7.5 rsi)
                                (set! foo.5.4 rdx)
                                (set! bat.2.3 rcx)
                                (set! bar.3.2 r8)
                                (set! bar.8.1 r9)
                                (begin
                                  (set! bar.8.8 bat.2.3)
                                  (set! bar.7.7 1)
                                  (if (if (!= bar.7.7 foobar.0.6)
                                          (<= -494940107 bar.3.2)
                                          (< 0 1869530139))
                                      (if (<= bar.7.7 0) 0 -777687734)
                                      (if (> -9223372036854775808 foo.5.4)
                                          9223372036854775807
                                          -9223372036854775808)))))
                            9223372036854775807
                      ))
  (check-by-interp '(module (if (true)
                                (begin
                                  (set! foo.0.2 1)
                                  (set! foo.8.1 0)
                                  356048754)
                                (if (<= -1287356538 1126106862) 4712028 349517812))))
  (check-by-interp '(module (define L.fn.0.1
                              (begin
                                (begin
                                  (set! bar.8.2 (* -9223372036854775808 0))
                                  (begin
                                    (begin
                                      (set! foobar.7.7 0)
                                      (set! bar.2.6 9223372036854775807)
                                      (set! ball.3.5 foobar.7.7))
                                    (begin
                                      (set! bar.8.10 1)
                                      (set! ball.3.9 -9223372036854775808)
                                      (set! bat.4.8 0)
                                      (set! foobar.0.4 0))
                                    (set! bar.8.3 (+ 2146083242 1877941467))
                                    (if (>= 1 0)
                                        (set! foobar.1.1 foobar.0.4)
                                        (set! foobar.1.1 bar.8.3)))
                                  (begin
                                    (begin
                                      (set! ball.6.16 9223372036854775807)
                                      (set! ball.3.15 1)
                                      (set! bat.4.14 bar.8.2)
                                      (set! foobar.0.13 ball.3.15))
                                    (begin
                                      (set! foobar.1.19 foobar.1.1)
                                      (set! bar.8.18 -80057626)
                                      (set! bar.5.17 451403960)
                                      (set! bar.2.12 0))
                                    (set! ball.6.11 -9223372036854775808)
                                    (if (= 0 foobar.1.1) 1 -9223372036854775808)))))
                            (define L.func.1.2
                              (begin
                                (set! ball.3.26 rdi)
                                (set! foobar.1.25 rsi)
                                (set! foobar.7.24 rdx)
                                (set! ball.6.23 rcx)
                                (set! foobar.0.22 r8)
                                (set! bar.2.21 r9)
                                (set! bat.4.20 fv0)
                                (if (>= -68053908 1924767324)
                                    (begin
                                      (set! rcx foobar.7.24)
                                      (set! rdx 2037093174)
                                      (set! rsi 2020389049)
                                      (set! rdi 0)
                                      (jump L.func.2.3 rbp rdi rsi rdx rcx))
                                    (begin
                                      (jump L.fn.0.1 rbp)))))
                      (define L.func.2.3
                        (begin
                          (set! foobar.0.30 rdi)
                          (set! bat.4.29 rsi)
                          (set! ball.3.28 rdx)
                          (set! bar.8.27 rcx)
                          (begin
                            (begin
                              (begin
                                (set! bat.4.38 1683456577)
                                (set! ball.3.37 0)
                                (set! bar.2.36 572391381))
                              (if (>= 9223372036854775807 foobar.0.30)
                                  (set! bar.8.35 -2023903597)
                                  (set! bar.8.35 -15104029))
                              (set! foobar.7.34 1)
                              (set! bar.5.33 ball.3.28))
                            (set! ball.3.32 0)
                            (set! bar.8.31 (+ bat.4.29 bat.4.29))
                            (+ 1 bat.4.29))))
                      (if (not (> 512244517 -294049298))
                          (begin
                            (set! bar.5.41 1283186732)
                            (set! bar.2.40 99039009)
                            (set! bat.4.39 1811100583)
                            bar.5.41)
                          (begin
                            (set! bat.4.44 1)
                            (set! foobar.7.43 -9223372036854775808)
                            (set! ball.6.42 1)
                            ball.6.42))))
  (check-by-interp '(module (define L.proc.0.1
                              (begin
                                (set! foobar.8.5 rdi)
                                (set! bat.1.4 rsi)
                                (set! bar.7.3 rdx)
                                (set! foobar.4.2 rcx)
                                (set! foobar.0.1 r8)
                                (begin
                                  (set! r9 9223372036854775807)
                                  (set! r8 foobar.8.5)
                                  (set! rcx -9223372036854775808)
                                  (set! rdx 1)
                                  (set! rsi bat.1.4)
                                  (set! rdi foobar.0.1)
                                  (jump L.proc.2.3 rbp rdi rsi rdx rcx r8 r9))))
                            (define L.x.1.2
                              (begin
                                (set! foobar.4.7 rdi)
                                (set! bar.2.6 rsi)
                                (if (true)
                                    (begin
                                      (if (< foobar.4.7 foobar.4.7)
                                          (set! foobar.0.10 foobar.4.7)
                                          (set! foobar.0.10 foobar.4.7))
                                      (set! foo.5.9 (* foobar.4.7 -1298566605))
                                      (set! bar.2.8 0)
                                      (* foobar.0.10 foobar.0.10))
                                    (begin
                                      (set! foobar.4.12 (+ -1679672366 bar.2.6))
                                      (set! foobar.8.11 (+ 0 foobar.4.7))
                                      (begin
                                        (set! foobar.8.15 0)
                                        (set! foobar.3.14 -511883263)
                                        (set! bat.1.13 bar.2.6)
                                        foobar.3.14)))))
                      (define L.proc.2.3
                        (begin
                          (set! foo.5.21 rdi)
                          (set! bat.1.20 rsi)
                          (set! foobar.4.19 rdx)
                          (set! foobar.3.18 rcx)
                          (set! bar.7.17 r8)
                          (set! foo.9.16 r9)
                          (+ bar.7.17 -9223372036854775808)))
                      (if (> 1 -735340476) -9223372036854775808 -1627211406)))
  (check-by-interp '(module (define L.x.0.1
                              (begin
                                (set! foobar.3.1 rdi)
                                (if (not (false))
                                    (begin
                                      (begin
                                        (set! bat.7.7 -508084756)
                                        (set! foobar.3.6 foobar.3.1)
                                        (set! bar.5.5 1)
                                        (set! bat.7.4 bat.7.7))
                                      (begin
                                        (set! bat.7.10 foobar.3.1)
                                        (set! bar.5.9 1120136428)
                                        (set! foobar.1.8 606194936)
                                        (set! bat.4.3 -908142049))
                                      (set! ball.0.2 (+ 600266106 foobar.3.1))
                                      (begin
                                        (set! foobar.3.12 foobar.3.1)
                                        (set! ball.0.11 0)
                                        1))
                                    (begin
                                      (set! rdi -2072909432)
                                      (jump L.x.0.1 rbp rdi)))))
                            (begin
                              (begin
                                (set! bat.7.18 -1755065230)
                                (set! bar.5.17 9223372036854775807)
                                (set! ball.0.16 0)
                                (set! foobar.3.15 bar.5.17))
                              (set! bar.8.14 -9223372036854775808)
                              (set! bar.5.13 -9223372036854775808)
                              (if (< 1 bar.8.14) bar.8.14 -9223372036854775808))
                      ))
  (check-by-interp '(module (begin
                              (set! bar.4.3 (* 993422572 1))
                              (if (<= 92310708 1290581674)
                                  (set! bar.6.2 1)
                                  (set! bar.6.2 0))
                              (set! bar.1.1 (+ 9223372036854775807 -1759699484))
                              (begin
                                (set! bar.4.5 bar.4.3)
                                (set! foobar.5.4 -9223372036854775808)
                                bar.4.5))))
  (check-by-interp '(module (define L.func.0.1
                              (begin
                                (set! bar.6.1 rdi)
                                (begin
                                  (begin
                                    (set! foo.0.6 (+ -9223372036854775808 -9223372036854775808))
                                    (set! bar.6.5 (+ bar.6.1 1312056768))
                                    (if (<= 1 bar.6.5)
                                        (set! bat.2.4 -9223372036854775808)
                                        (set! bat.2.4 -50606571)))
                                  (set! foo.7.3 bar.6.1)
                                  (set! foobar.4.2 bar.6.1)
                                  (if (if (>= foo.7.3 bar.6.1)
                                          (< 0 foo.7.3)
                                          (!= 1880363761 9223372036854775807))
                                      (begin
                                        (set! bat.3.8 1)
                                        (set! bar.6.7 foobar.4.2)
                                        foo.7.3)
                                      (+ bat.2.4 bar.6.1)))))
                            (define L.x.1.2
                              (begin
                                (if (true)
                                    -9223372036854775808
                                    (+ 0 9223372036854775807))))
                      (begin
                        (jump L.x.1.2 rbp))))
  (check-by-interp '(module (define L.x.0.1
                              (begin
                                (set! ball.8.3 rdi)
                                (set! ball.6.2 rsi)
                                (set! foobar.1.1 rdx)
                                (begin
                                  (set! rdx 0)
                                  (set! rsi ball.8.3)
                                  (set! rdi foobar.1.1)
                                  (jump L.x.0.1 rbp rdi rsi rdx))))
                            (if (> 9223372036854775807 1757631774)
                                (begin
                                  (set! foo.4.5 0)
                                  (set! foobar.2.4 213435043)
                                  -9223372036854775808)
                                0)
                      ))
  (check-by-interp '(module (if (not (< 1946235623 -9223372036854775808))
                                (begin
                                  (set! bat.0.3 -135046761)
                                  (set! bat.2.2 1453915451)
                                  (set! ball.5.1 257292075)
                                  bat.2.2)
                                -9223372036854775808)))
  (check-by-interp '(module (define L.proc.0.1
                              (begin
                                (set! foobar.9.3 rdi)
                                (set! foobar.3.2 rsi)
                                (set! bar.8.1 rdx)
                                foobar.3.2))
                            (* 1 9223372036854775807)
                      ))
  (check-by-interp
   '(module (define L.proc.0.1
              (begin
                (set! foobar.3.6 rdi)
                (set! bar.5.5 rsi)
                (set! bat.1.4 rdx)
                (set! foobar.2.3 rcx)
                (set! foobar.7.2 r8)
                (set! ball.0.1 r9)
                (if (true)
                    (begin
                      (set! fv0 1165846535)
                      (set! r9 foobar.2.3)
                      (set! r8 foobar.3.6)
                      (set! rcx 1407333795)
                      (set! rdx 0)
                      (set! rsi foobar.3.6)
                      (set! rdi 1843221563)
                      (jump L.func.1.2 rbp rdi rsi rdx rcx r8 r9 fv0))
                    (+ -1543779281 1))))
            (define L.func.1.2
              (begin
                (set! bar.5.13 rdi)
                (set! bat.6.12 rsi)
                (set! bar.9.11 rdx)
                (set! bar.4.10 rcx)
                (set! foobar.7.9 r8)
                (set! ball.0.8 r9)
                (set! foobar.2.7 fv0)
                (begin
                  (set! foobar.3.16 (* -9223372036854775808 ball.0.8))
                  (set! foobar.2.15 ball.0.8)
                  (set! bat.6.14 bar.4.10)
                  (begin
                    (set! fv0 foobar.2.15)
                    (set! r9 -811936434)
                    (set! r8 ball.0.8)
                    (set! rcx foobar.2.15)
                    (set! rdx ball.0.8)
                    (set! rsi 0)
                    (set! rdi -9223372036854775808)
                    (jump L.func.1.2 rbp rdi rsi rdx rcx r8 r9 fv0)))))
      (if (true)
          -1263415267
          (if (<= 9223372036854775807 -514434406) 9223372036854775807 9223372036854775807))))
  (check-by-interp '(module (define L.proc.0.1
                              (begin
                                (set! bat.6.2 rdi)
                                (set! bar.8.1 rsi)
                                (begin
                                  (set! rdi -9223372036854775808)
                                  (jump L.tmp.1.2 rbp rdi))))
                            (define L.tmp.1.2
                              (begin
                                (set! bat.6.3 rdi)
                                (if (!= 9223372036854775807 bat.6.3)
                                    (if (true)
                                        (begin
                                          (set! bar.2.6 2026709313)
                                          (set! bat.9.5 bat.6.3)
                                          (set! bat.6.4 bat.6.3)
                                          bat.6.4)
                                        (if (>= 1890937388 bat.6.3) bat.6.3 1616264974))
                                    9223372036854775807)))
                      (begin
                        (set! ball.7.9 (* 0 1192307430))
                        (if (< -9223372036854775808 1)
                            (set! bat.3.8 -9223372036854775808)
                            (set! bat.3.8 2088471563))
                        (begin
                          (set! ball.7.11 1)
                          (set! bat.9.10 9223372036854775807)
                          (set! bar.8.7 1861500702))
                        (if (!= 9223372036854775807 -9223372036854775808) ball.7.9 0))))
  (check-by-interp '(module (define L.proc.0.1
                              (begin
                                (set! foo.9.1 rdi)
                                (if (false)
                                    (begin
                                      (set! r9 foo.9.1)
                                      (set! r8 foo.9.1)
                                      (set! rcx foo.9.1)
                                      (set! rdx -9223372036854775808)
                                      (set! rsi foo.9.1)
                                      (set! rdi foo.9.1)
                                      (jump L.fn.2.3 rbp rdi rsi rdx rcx r8 r9))
                                    (if (false)
                                        (begin
                                          (set! foobar.8.4 9223372036854775807)
                                          (set! foo.2.3 foo.9.1)
                                          (set! foobar.1.2 foo.9.1)
                                          foo.9.1)
                                        (if (> 1 foo.9.1) 822960898 foo.9.1)))))
                            (define L.fn.1.2
                              (begin
                                (set! foobar.1.7 rdi)
                                (set! foo.6.6 rsi)
                                (set! foobar.3.5 rdx)
                                (if (false)
                                    (begin
                                      (set! foobar.1.10 foobar.1.7)
                                      (set! foobar.5.9 (+ -2065189484 foobar.3.5))
                                      (if (< foobar.1.7 -300039187)
                                          (set! foobar.7.8 2115350249)
                                          (set! foobar.7.8 foobar.1.7))
                                      (begin
                                        (set! foobar.1.13 -195312042)
                                        (set! foobar.5.12 foo.6.6)
                                        (set! foo.6.11 foobar.3.5)
                                        foobar.7.8))
                                    (begin
                                      (begin
                                        (set! foobar.3.17 -1983872386)
                                        (set! foobar.7.16 foobar.1.7)
                                        (set! foo.6.15 foobar.7.16))
                                      (begin
                                        (set! foo.6.20 9223372036854775807)
                                        (set! foo.0.19 -9223372036854775808)
                                        (set! foo.9.18 1)
                                        (set! foobar.3.14 0))
                                      (if (>= foo.6.15 foo.6.15) -9223372036854775808 foobar.3.14)))))
                      (define L.fn.2.3
                        (begin
                          (set! foo.6.26 rdi)
                          (set! foo.4.25 rsi)
                          (set! foobar.1.24 rdx)
                          (set! foo.9.23 rcx)
                          (set! foobar.5.22 r8)
                          (set! foo.0.21 r9)
                          (begin
                            (set! r9 foo.4.25)
                            (set! r8 foobar.1.24)
                            (set! rcx 968969801)
                            (set! rdx foo.4.25)
                            (set! rsi foo.4.25)
                            (set! rdi foo.6.26)
                            (jump L.fn.2.3 rbp rdi rsi rdx rcx r8 r9))))
                      9223372036854775807))
  (check-by-interp '(module (if (not (>= 1622421353 94202816))
                                (begin
                                  (set! foobar.7.2 -2027378735)
                                  (set! bar.5.1 9223372036854775807)
                                  9223372036854775807)
                                (begin
                                  (set! foobar.4.4 -9223372036854775808)
                                  (set! bat.8.3 1)
                                  9223372036854775807))))
  (check-by-interp '(module (begin
                              (set! bar.4.2 (* -1915251883 1))
                              (begin
                                (set! ball.9.5 -9223372036854775808)
                                (set! bar.0.4 356482613)
                                (set! foo.7.3 9223372036854775807)
                                (set! foo.7.1 foo.7.3))
                              (begin
                                (set! ball.5.8 foo.7.1)
                                (set! ball.9.7 bar.4.2)
                                (set! bat.3.6 -1601764542)
                                -9223372036854775808))))
  (check-by-interp '(module (define L.func.0.1
                              (begin
                                (set! ball.7.6 rdi)
                                (set! bar.4.5 rsi)
                                (set! foo.9.4 rdx)
                                (set! foo.2.3 rcx)
                                (set! foo.1.2 r8)
                                (set! ball.8.1 r9)
                                (if (if (> bar.4.5 ball.7.6)
                                        (if (= -1032056006 foo.1.2)
                                            (>= foo.2.3 ball.8.1)
                                            (< foo.9.4 1))
                                        (>= 1 foo.9.4))
                                    (begin
                                      (set! r9 foo.9.4)
                                      (set! r8 ball.8.1)
                                      (set! rcx 1807204646)
                                      (set! rdx bar.4.5)
                                      (set! rsi -675302553)
                                      (set! rdi 0)
                                      (jump L.func.0.1 rbp rdi rsi rdx rcx r8 r9))
                                    (begin
                                      (set! r9 9223372036854775807)
                                      (set! r8 -9223372036854775808)
                                      (set! rcx foo.1.2)
                                      (set! rdx ball.8.1)
                                      (set! rsi -41674885)
                                      (set! rdi ball.8.1)
                                      (jump L.func.0.1 rbp rdi rsi rdx rcx r8 r9)))))
                            (if (!= -9223372036854775808 -719419034)
                                (begin
                                  (set! foo.1.9 9223372036854775807)
                                  (set! bar.4.8 0)
                                  (set! foobar.5.7 9223372036854775807)
                                  foobar.5.7)
                                (if (> -235413122 1) 0 9223372036854775807))
                      ))
  (check-by-interp '(module (define L.fn.0.1
                              (begin
                                (set! ball.9.1 rdi)
                                (begin
                                  (set! rsi ball.9.1)
                                  (set! rdi ball.9.1)
                                  (jump L.x.1.2 rbp rdi rsi))))
                            (define L.x.1.2
                              (begin
                                (set! ball.6.3 rdi)
                                (set! ball.9.2 rsi)
                                (if (not (false))
                                    (begin
                                      (set! foobar.4.6 ball.9.2)
                                      (begin
                                        (set! foo.1.8 9223372036854775807)
                                        (set! bar.5.7 ball.6.3)
                                        (set! foo.1.5 9223372036854775807))
                                      (set! ball.9.4 -2115998024)
                                      -1101891150)
                                    (begin
                                      (set! bat.7.11 (* -1594085017 ball.9.2))
                                      (begin
                                        (set! bat.7.13 -999943825)
                                        (set! foobar.0.12 ball.6.3)
                                        (set! ball.9.10 593362223))
                                      (set! foobar.0.9 0)
                                      (if (= bat.7.11 1) foobar.0.9 0)))))
                      (if (if (= 1 -1319463227)
                              (>= -9223372036854775808 1)
                              (!= -1520052689 1))
                          (begin
                            (set! foo.8.16 -9223372036854775808)
                            (set! foobar.0.15 9223372036854775807)
                            (set! ball.2.14 744570222)
                            foo.8.16)
                          (begin
                            (set! bar.5.19 -133225634)
                            (set! foo.8.18 -9223372036854775808)
                            (set! ball.6.17 -9223372036854775808)
                            bar.5.19))))
  (check-by-interp '(module (begin
                              (set! bat.2.3 9223372036854775807)
                              (begin
                                (set! ball.6.6 1)
                                (set! bar.4.5 -9223372036854775808)
                                (set! ball.1.4 9223372036854775807)
                                (set! foobar.3.2 1))
                              (begin
                                (set! foobar.7.8 -1722042928)
                                (set! foobar.9.7 0)
                                (set! bar.4.1 1))
                              (if (!= -1508403451 bat.2.3) 447579047 bat.2.3))))
  (check-by-interp '(module (define L.tmp.0.1
                              (begin
                                (set! foo.4.4 rdi)
                                (set! ball.9.3 rsi)
                                (set! foobar.6.2 rdx)
                                (set! foo.8.1 rcx)
                                (begin
                                  (set! rcx foo.4.4)
                                  (set! rdx foobar.6.2)
                                  (set! rsi foobar.6.2)
                                  (set! rdi 9223372036854775807)
                                  (jump L.tmp.0.1 rbp rdi rsi rdx rcx))))
                            (+ 9223372036854775807 -1932027129)
                      ))
  (check-by-interp '(module (define L.func.0.1
                              (begin
                                (set! bat.4.2 rdi)
                                (set! ball.7.1 rsi)
                                (begin
                                  (set! rcx bat.4.2)
                                  (set! rdx -436836322)
                                  (set! rsi ball.7.1)
                                  (set! rdi bat.4.2)
                                  (jump L.fn.1.2 rbp rdi rsi rdx rcx))))
                            (define L.fn.1.2
                              (begin
                                (set! ball.7.6 rdi)
                                (set! bar.8.5 rsi)
                                (set! bat.1.4 rdx)
                                (set! ball.2.3 rcx)
                                (if (true)
                                    (if (if (> 182929845 bar.8.5)
                                            (>= bat.1.4 1)
                                            (< -767224240 9223372036854775807))
                                        (+ bat.1.4 -9223372036854775808)
                                        bat.1.4)
                                    (begin
                                      (set! bar.5.8 (+ -9223372036854775808 -9223372036854775808))
                                      (begin
                                        (set! bat.1.11 -1747554427)
                                        (set! ball.2.10 ball.7.6)
                                        (set! ball.0.9 9223372036854775807)
                                        (set! ball.0.7 bat.1.11))
                                      ball.0.7))))
                      (define L.x.2.3
                        (begin
                          (if (< 0 9223372036854775807)
                              1083014636
                              (begin
                                (if (<= 1 9223372036854775807)
                                    (set! bat.4.14 9223372036854775807)
                                    (set! bat.4.14 1))
                                (set! bar.5.13 (* 0 0))
                                (set! bat.1.12 (* 1942355770 9223372036854775807))
                                (if (>= bat.4.14 9223372036854775807) -9223372036854775808 1)))))
                      (begin
                        (set! rsi 9223372036854775807)
                        (set! rdi -1129269775)
                        (jump L.func.0.1 rbp rdi rsi))))
  (check-by-interp '(module (define L.proc.0.1
                              (begin
                                (if (begin
                                      (set! bat.2.2 (* 1 0))
                                      (set! ball.8.1 -9223372036854775808)
                                      (if (> ball.8.1 bat.2.2)
                                          (>= 9223372036854775807 ball.8.1)
                                          (= bat.2.2 0)))
                                    -9223372036854775808
                                    (begin
                                      (set! rdx 0)
                                      (set! rsi 1)
                                      (set! rdi 0)
                                      (jump L.proc.2.3 rbp rdi rsi rdx)))))
                            (define L.fn.1.2
                              (begin
                                (set! bat.2.9 rdi)
                                (set! foo.4.8 rsi)
                                (set! foobar.0.7 rdx)
                                (set! foobar.1.6 rcx)
                                (set! bat.3.5 r8)
                                (set! ball.9.4 r9)
                                (set! bar.6.3 fv0)
                                (if (if (true)
                                        (if (!= -1156972119 bat.3.5)
                                            (> 9223372036854775807 bat.2.9)
                                            (!= 1703616983 foo.4.8))
                                        (if (>= ball.9.4 bar.6.3)
                                            (> bat.3.5 bat.3.5)
                                            (< bat.2.9 bat.2.9)))
                                    (begin
                                      (begin
                                        (set! bat.2.14 bar.6.3)
                                        (set! ball.9.13 -144518674)
                                        (set! bar.6.12 foobar.1.6)
                                        (set! foo.4.11 bat.3.5))
                                      (if (< bat.2.9 9223372036854775807)
                                          (set! bat.3.10 0)
                                          (set! bat.3.10 -9223372036854775808))
                                      (if (>= bat.2.9 -2080421634) 9223372036854775807 0))
                                    -274219017)))
                      (define L.proc.2.3
                        (begin
                          (set! ball.5.17 rdi)
                          (set! bat.2.16 rsi)
                          (set! ball.9.15 rdx)
                          (+ bat.2.16 9223372036854775807)))
                      (begin
                        (set! foobar.1.19 (+ 1 -1806804688))
                        (set! ball.7.18 (+ 1880531761 1))
                        (if (<= 0 foobar.1.19) 0 9223372036854775807))))
  (check-by-interp '(module (if (!= -107521481 -1873066368)
                                (* 1275956981 1)
                                (begin
                                  (set! bat.4.2 1318401057)
                                  (set! foobar.7.1 -542033033)
                                  -288327503))))
  (check-by-interp '(module (define L.fn.0.1
                              (begin
                                (begin
                                  (begin
                                    (set! foobar.4.5 9223372036854775807)
                                    (set! bat.0.4 684249837)
                                    (set! bar.7.3 1)
                                    (if (= 2084897481 bar.7.3)
                                        (set! bat.3.2 foobar.4.5)
                                        (set! bat.3.2 bar.7.3)))
                                  (if (begin
                                        (set! ball.1.7 0)
                                        (set! bat.5.6 1774106288)
                                        (> 0 bat.5.6))
                                      (begin
                                        (set! bat.0.9 9223372036854775807)
                                        (set! foo.6.8 811516044)
                                        (set! ball.9.1 bat.0.9))
                                      (if (< -1327371506 9223372036854775807)
                                          (set! ball.9.1 -9223372036854775808)
                                          (set! ball.9.1 9223372036854775807)))
                                  (begin
                                    (jump L.fn.0.1 rbp)))))
                            (begin
                              (if (= 1517267005 605514120)
                                  (set! bat.5.11 -1228391641)
                                  (set! bat.5.11 -1926002282))
                              (if (> 0 1)
                                  (set! ball.9.10 9223372036854775807)
                                  (set! ball.9.10 0))
                              (* 25767341 0))
                      ))
  (check-by-interp
   '(module (define L.func.0.1
              (begin
                (if (false)
                    (if (not (!= -1086072832 9223372036854775807))
                        (begin
                          (set! bar.4.3 793954259)
                          (set! bat.0.2 0)
                          (set! bat.6.1 -9223372036854775808)
                          9223372036854775807)
                        (+ 620579510 1))
                    (if (true)
                        9223372036854775807
                        (begin
                          (set! ball.8.5 716210269)
                          (set! bat.0.4 -524345693)
                          -9223372036854775808)))))
            (define L.fn.1.2
              (begin
                (set! bat.0.7 rdi)
                (set! bat.6.6 rsi)
                (if (if (true)
                        (if (> 0 9223372036854775807)
                            (<= 1 -330770905)
                            (> 0 bat.0.7))
                        (if (>= bat.0.7 bat.0.7)
                            (<= -1763336001 1)
                            (>= 9223372036854775807 -1870920433)))
                    (if (not (= -9223372036854775808 1676706544))
                        (if (<= 0 bat.0.7) -9223372036854775808 bat.0.7)
                        (if (<= -9223372036854775808 1745852904) 592053094 -1824096668))
                    (begin
                      (begin
                        (set! foo.3.12 bat.0.7)
                        (set! ball.5.11 bat.6.6)
                        (set! ball.5.10 foo.3.12))
                      (set! foo.3.9 (+ 1995506902 -677333479))
                      (begin
                        (set! bar.9.15 bat.0.7)
                        (set! bat.0.14 -1273465885)
                        (set! bat.6.13 148631858)
                        (set! bar.4.8 bat.0.14))
                      bat.6.6))))
      (begin
        (set! bar.7.18 -1536502942)
        (set! bat.0.17 -1557455680)
        (begin
          (set! bat.6.21 -1112875927)
          (set! ball.5.20 9223372036854775807)
          (set! foo.3.19 9223372036854775807)
          (set! bat.6.16 ball.5.20))
        (if (<= bar.7.18 bat.0.17) 1132619346 0))))
  (check-by-interp '(module (if (true)
                                (begin
                                  (set! foobar.3.2 -9223372036854775808)
                                  (set! foo.8.1 9223372036854775807)
                                  foobar.3.2)
                                (begin
                                  (set! foo.5.5 -9223372036854775808)
                                  (set! foo.8.4 1929590320)
                                  (set! foobar.2.3 0)
                                  0))))
  (check-by-interp '(module (begin
                              (if (> 9223372036854775807 1398326902)
                                  (set! bar.1.3 9223372036854775807)
                                  (set! bar.1.3 9223372036854775807))
                              (set! bat.3.2 0)
                              (begin
                                (set! bat.3.5 -9223372036854775808)
                                (set! ball.9.4 -1747244286)
                                (set! foo.0.1 ball.9.4))
                              (begin
                                (set! foo.0.7 -1923830755)
                                (set! bat.5.6 bar.1.3)
                                bat.5.6))))
  (check-by-interp '(module (define L.proc.0.1
                              (begin
                                (begin
                                  (if (true)
                                      (set! bat.6.3 0)
                                      (set! bat.6.3 (* 1 1)))
                                  (set! foo.9.2 -9223372036854775808)
                                  (set! bar.0.1 (* 672116958 1))
                                  (if (< bar.0.1 980303276)
                                      (+ 9223372036854775807 bar.0.1)
                                      (begin
                                        (set! bar.2.5 -667597146)
                                        (set! foo.9.4 1438122241)
                                        1900048603)))))
                            (define L.proc.1.2
                              (begin
                                (if (true)
                                    (if (if (< 0 -9223372036854775808)
                                            (<= 0 -9223372036854775808)
                                            (> 9223372036854775807 -1813633866))
                                        -935154891
                                        (begin
                                          (set! ball.3.7 -1449852093)
                                          (set! bat.6.6 -9223372036854775808)
                                          1))
                                    (+ -1450359427 -701676518))))
                      (if (false)
                          (begin
                            (jump L.proc.1.2 rbp))
                          (if (!= 1 9223372036854775807) 313960847 0))))
  (check-by-interp '(module (if (if (< -500842013 -2010375969)
                                    (< -1785958547 9223372036854775807)
                                    (<= 904902616 1))
                                (if (= -1568723397 0) 1 -9223372036854775808)
                                1)))
  (check-by-interp '(module (if (false)
                                0
                                (if (>= 1 0) 281602960 9223372036854775807))))
  (check-by-interp '(module (if (true)
                                (+ -1267155910 -9223372036854775808)
                                (if (>= 901304193 1) 0 -154349390))))
  (check-by-interp '(module 9223372036854775807))
  (check-by-interp '(module (if (true)
                                (+ -9223372036854775808 1965973068)
                                (begin
                                  (set! bar.2.2 -644439618)
                                  (set! foo.7.1 1)
                                  foo.7.1))))

  ;;

  ;; !!! Added by Trevor on March 2nd 2026
  (check-by-interp '(module (define L.L.func.0.1.4
                              (begin
                                0))
                            (define L.L.tmp.1.2.5
                              (begin
                                (set! foo.2.1.5 rdi)
                                (begin
                                  (jump L.L.func.0.1.4 rbp))))
                      (define L.L.func.2.3.6
                        (begin
                          (begin
                            (if (true)
                                (begin
                                  (set! foo.2.3.7 1)
                                  (set! bar.4.2.6 foo.2.3.7))
                                (set! bar.4.2.6 (* -9223372036854775808 1806293504)))
                            (begin
                              (if (> 1 0)
                                  (set! foobar.6.4.8 156890122)
                                  (set! foobar.6.4.8 bar.4.2.6))
                              0))))
                      (begin
                        (set! rdi -1860620182)
                        (jump L.L.tmp.1.2.5 rbp rdi))))
  (check-by-interp
   '(module (define L.L.tmp.0.1.4
              (begin
                (if (>= 9223372036854775807 -1020514810)
                    (begin
                      (jump L.L.x.2.3.6 rbp))
                    (* 1 0))))
            (define L.L.func.1.2.5
              (begin
                (begin
                  (set! bar.1.1.5 -9223372036854775808)
                  (if (not (> 9223372036854775807 0)) 1309557052 bar.1.1.5))))
      (define L.L.x.2.3.6
        (begin
          (if (if (true)
                  (not (> 0 1))
                  (true))
              (if (> 0 0)
                  (if (< 9223372036854775807 9223372036854775807) 9223372036854775807 -260353756)
                  (begin
                    (set! ball.0.2.6 0)
                    ball.0.2.6))
              (begin
                (if (!= -302047143 0)
                    (set! bar.3.3.7 9223372036854775807)
                    (set! bar.3.3.7 102036653))
                (if (= 0 bar.3.3.7) bar.3.3.7 -362331747)))))
      (begin
        (set! ball.0.4.8 (* -9223372036854775808 -9223372036854775808))
        (+ ball.0.4.8 0))))
  (check-by-interp '(module (define L.L.proc.0.1.4
                              (begin
                                (set! ball.6.1.5 rdi)
                                (begin
                                  (jump L.L.func.1.2.5 rbp))))
                            (define L.L.func.1.2.5
                              (begin
                                (* 1 0)))
                      (define L.L.fn.2.3.6
                        (begin
                          (set! ball.3.2.6 rdi)
                          (if (true)
                              (begin
                                (if (<= -2033705372 965540822)
                                    (set! bat.0.3.7 -1853172774)
                                    (set! bat.0.3.7 1133506028))
                                (begin
                                  (set! foo.4.4.8 1)
                                  1236904416))
                              (begin
                                (jump L.L.func.1.2.5 rbp)))))
                      (begin
                        (set! rdi 1)
                        (jump L.L.proc.0.1.4 rbp rdi))))
  (check-by-interp '(module (define L.fn.0.1
                              (begin
                                (begin
                                  (if (false)
                                      (set! bat.9.1 1)
                                      (begin
                                        (set! foo.5.2 1)
                                        (set! bat.9.1 1)))
                                  (if (if (>= 9223372036854775807 -9223372036854775808)
                                          (= -248968641 9223372036854775807)
                                          (!= bat.9.1 -9223372036854775808))
                                      (begin
                                        (set! ball.4.3 bat.9.1)
                                        1622965009)
                                      (begin
                                        (set! foo.5.4 bat.9.1)
                                        bat.9.1)))))
                            (if (false)
                                (if (>= 995853130 1) 1 -9223372036854775808)
                                (begin
                                  (jump L.fn.0.1 rbp)))
                      ))
  (check-by-interp '(module (+ -9223372036854775808 -1465538260)))
  (check-by-interp '(module (define L.fn.0.1
                              (begin
                                (begin
                                  (set! bar.2.1 (+ 1 9223372036854775807))
                                  (begin
                                    (begin
                                      (set! foo.1.3 bar.2.1)
                                      (set! foo.8.2 foo.1.3))
                                    bar.2.1))))
                            (define L.func.1.2
                              (begin
                                (begin
                                  (if (begin
                                        (set! foo.8.5 1)
                                        (< 1 foo.8.5))
                                      (begin
                                        (set! foo.1.6 406779451)
                                        (set! ball.3.4 1200977699))
                                      (begin
                                        (set! foo.8.7 0)
                                        (set! ball.3.4 foo.8.7)))
                                  (* ball.3.4 ball.3.4))))
                      (begin
                        (set! bat.5.8 1)
                        (begin
                          (set! ball.9.9 0)
                          bat.5.8))))
  (check-by-interp '(module (define L.x.0.1
                              (begin
                                (set! ball.1.2 rdi)
                                (set! foo.0.1 rsi)
                                (begin
                                  (jump L.tmp.1.2 rbp))))
                            (define L.tmp.1.2
                              (begin
                                (if (if (if (<= -765445006 0)
                                            (!= 0 -7399083)
                                            (<= 9223372036854775807 1))
                                        (false)
                                        (true))
                                    (begin
                                      (begin
                                        (set! bar.5.4 -9223372036854775808)
                                        (set! ball.4.3 bar.5.4))
                                      (if (> ball.4.3 ball.4.3) -9223372036854775808 ball.4.3))
                                    (begin
                                      (if (>= 1 0)
                                          (set! foobar.9.5 -9223372036854775808)
                                          (set! foobar.9.5 -9223372036854775808))
                                      (if (= 0 foobar.9.5) 0 9223372036854775807)))))
                      (define L.func.2.3
                        (begin
                          (set! ball.4.7 rdi)
                          (set! ball.6.6 rsi)
                          (begin
                            (jump L.tmp.1.2 rbp))))
                      (if (<= 0 1) -1271132888 2101306416)))
  (check-by-interp '(module (define L.proc.0.1
                              (begin
                                (set! bar.8.1 rdi)
                                (begin
                                  (if (false)
                                      (begin
                                        (set! bat.4.3 bar.8.1)
                                        (set! bat.7.2 1733388107))
                                      (begin
                                        (set! foobar.2.4 -818241658)
                                        (set! bat.7.2 foobar.2.4)))
                                  (begin
                                    (set! bat.3.5 (* -1769976594 bat.7.2))
                                    (if (!= bar.8.1 bar.8.1) 1 bar.8.1)))))
                            (if (<= 0 0) 1764584349 -9223372036854775808)
                      ))
  (check-by-interp '(module (define L.proc.0.1
                              (begin
                                (set! ball.3.1 rdi)
                                (if (not (false))
                                    (begin
                                      (jump L.x.1.2 rbp))
                                    (begin
                                      (begin
                                        (set! bat.9.3 ball.3.1)
                                        (set! foobar.4.2 9223372036854775807))
                                      (+ -9223372036854775808 ball.3.1)))))
                            (define L.x.1.2
                              (begin
                                1))
                      (begin
                        (begin
                          (set! ball.1.5 453798193)
                          (set! foobar.4.4 ball.1.5))
                        (if (>= 9223372036854775807 foobar.4.4) 0 -1617493587))))
  (check-by-interp '(module (define L.func.0.1
                              (begin
                                (set! bat.8.1 rdi)
                                (if (begin
                                      (set! bat.2.2 (* 9223372036854775807 bat.8.1))
                                      (true))
                                    (if (true)
                                        (if (< bat.8.1 -9223372036854775808) bat.8.1 bat.8.1)
                                        (if (= -9223372036854775808 bat.8.1) bat.8.1 bat.8.1))
                                    (begin
                                      (jump L.proc.1.2 rbp)))))
                            (define L.proc.1.2
                              (begin
                                (begin
                                  (set! rdi 954069433)
                                  (jump L.func.0.1 rbp rdi))))
                      (if (false)
                          (* 1337690701 9223372036854775807)
                          (begin
                            (jump L.proc.1.2 rbp)))))
  (check-by-interp '(module (if (not (begin
                                       (set! tmp.1 1)
                                       (> tmp.1 9223372036854775807)))
                                (if (begin
                                      (set! tmp.2 1)
                                      (>= tmp.2 1197468889))
                                    (halt 9223372036854775807)
                                    (halt 1))
                                (halt 1))))
  (check-by-interp '(module (define L.func.0.1
                              (begin
                                (set! foo.9.5 rdi)
                                (set! foo.2.4 rsi)
                                (set! bar.1.3 rdx)
                                (set! bat.7.2 rcx)
                                (set! foobar.4.1 r8)
                                -1458025903))
                            (begin
                              (set! r8 0)
                              (set! rcx -9223372036854775808)
                              (set! rdx -808937821)
                              (set! rsi 1)
                              (set! rdi -9223372036854775808)
                              (jump L.func.0.1 rbp rdi rsi rdx rcx r8))
                      ))
  (check-by-interp '(module (define L.tmp.0.1
                              (begin
                                (set! ball.6.4 rdi)
                                (set! bat.5.3 rsi)
                                (set! bar.8.2 rdx)
                                (set! foobar.0.1 rcx)
                                (begin
                                  (set! bat.2.5 ball.6.4)
                                  (if (if (<= -9223372036854775808 bat.5.3)
                                          (>= -9223372036854775808 ball.6.4)
                                          (>= bat.5.3 2025307007))
                                      (+ bat.2.5 9223372036854775807)
                                      (if (<= bat.5.3 -9223372036854775808) 9223372036854775807 0)))))
                            (begin
                              (set! ball.6.6 0)
                              ball.6.6)
                      ))
  (check-by-interp '(module (define L.func.0.1
                              (begin
                                (set! ball.6.2 rdi)
                                (set! foobar.3.1 rsi)
                                (if (= 0 foobar.3.1)
                                    (+ -9223372036854775808 -9223372036854775808)
                                    (if (if (< ball.6.2 ball.6.2)
                                            (<= foobar.3.1 foobar.3.1)
                                            (= foobar.3.1 ball.6.2))
                                        (+ foobar.3.1 foobar.3.1)
                                        (if (= 1 foobar.3.1) ball.6.2 foobar.3.1)))))
                            (define L.x.1.2
                              (begin
                                (set! bar.0.3 rdi)
                                (begin
                                  (begin
                                    (begin
                                      (set! bat.2.6 1757280127)
                                      (set! bat.9.5 bat.2.6))
                                    (begin
                                      (set! ball.5.7 1)
                                      (set! ball.1.4 -1128483887)))
                                  (if (begin
                                        (set! foo.7.8 bar.0.3)
                                        (> foo.7.8 foo.7.8))
                                      ball.1.4
                                      (+ ball.1.4 bar.0.3)))))
                      (define L.fn.2.3
                        (begin
                          (if (begin
                                (set! foobar.8.9 (+ -9223372036854775808 -1421853645))
                                (not (>= 0 -1400373009)))
                              (+ -167927521 1)
                              (begin
                                (set! ball.1.10 (* 1041085683 9223372036854775807))
                                (begin
                                  (set! foo.4.11 ball.1.10)
                                  770292232)))))
                      (begin
                        (set! rdi 1840464414)
                        (jump L.x.1.2 rbp rdi))))
  (check-by-interp '(module (define L.proc.0.1
                              (begin
                                (set! ball.4.3 rdi)
                                (set! foo.7.2 rsi)
                                (set! ball.2.1 rdx)
                                (begin
                                  (set! rdx foo.7.2)
                                  (set! rsi ball.2.1)
                                  (set! rdi 9223372036854775807)
                                  (jump L.proc.0.1 rbp rdi rsi rdx))))
                            (define L.func.1.2
                              (begin
                                (set! ball.1.9 rdi)
                                (set! bat.0.8 rsi)
                                (set! foo.7.7 rdx)
                                (set! ball.4.6 rcx)
                                (set! foobar.6.5 r8)
                                (set! bar.3.4 r9)
                                (begin
                                  (begin
                                    (set! ball.4.11 foo.7.7)
                                    (begin
                                      (set! foobar.5.12 ball.1.9)
                                      (set! bar.3.10 -9223372036854775808)))
                                  (begin
                                    (set! rdx bar.3.10)
                                    (set! rsi -780648786)
                                    (set! rdi bar.3.10)
                                    (jump L.proc.0.1 rbp rdi rsi rdx)))))
                      (begin
                        (set! bat.0.13 -579691794)
                        953357957)))
  (check-by-interp '(module (begin
                              (begin
                                (set! ball.2.2 9223372036854775807)
                                (set! bar.5.1 -546026276))
                              (if (!= bar.5.1 1) 9223372036854775807 2063023986))))
  (check-by-interp '(module (define L.func.0.1
                              (begin
                                (set! foo.8.2 rdi)
                                (set! bar.2.1 rsi)
                                (if (not (begin
                                           (set! foo.8.3 foo.8.2)
                                           (= foo.8.3 0)))
                                    (begin
                                      (set! foobar.6.4 (+ foo.8.2 0))
                                      (* 0 9223372036854775807))
                                    (begin
                                      (set! bat.7.5 (* 0 bar.2.1))
                                      (if (!= bat.7.5 -9223372036854775808) bar.2.1 0)))))
                            (if (= 9223372036854775807 -315897602) 1 -9223372036854775808)
                      ))
  (check-by-interp '(module (define L.fn.0.1
                              (begin
                                (set! foobar.3.2 rdi)
                                (set! ball.7.1 rsi)
                                (begin
                                  (begin
                                    (set! bat.4.4 (* 1 9223372036854775807))
                                    (set! bar.9.3 (+ -9223372036854775808 bat.4.4)))
                                  (begin
                                    (set! bat.4.5 9223372036854775807)
                                    (if (!= 1 bar.9.3) 9223372036854775807 ball.7.1)))))
                            (define L.x.1.2
                              (begin
                                (set! bat.2.6 rdi)
                                (begin
                                  (begin
                                    (set! bat.4.8 (+ -1410706204 bat.2.6))
                                    (begin
                                      (set! bat.2.9 1)
                                      (set! foobar.3.7 -9223372036854775808)))
                                  (* -152436426 0))))
                      (define L.proc.2.3
                        (begin
                          (set! foo.5.13 rdi)
                          (set! ball.7.12 rsi)
                          (set! foo.0.11 rdx)
                          (set! ball.8.10 rcx)
                          (begin
                            (set! foobar.1.14 foo.5.13)
                            (+ 956544411 1))))
                      (+ 979460199 -1697959716)))
  (check-by-interp '(module (define L.proc.0.1
                              (begin
                                (set! foobar.1.6 rdi)
                                (set! bar.0.5 rsi)
                                (set! foobar.2.4 rdx)
                                (set! ball.8.3 rcx)
                                (set! bat.3.2 r8)
                                (set! bar.5.1 r9)
                                (begin
                                  (if (begin
                                        (set! bar.7.8 -669410514)
                                        (< bat.3.2 bat.3.2))
                                      (set! bar.9.7 (+ bar.5.1 ball.8.3))
                                      (set! bar.9.7 foobar.2.4))
                                  (begin
                                    (begin
                                      (set! foo.4.10 ball.8.3)
                                      (set! ball.6.9 1))
                                    (if (<= foobar.2.4 1) 9223372036854775807 bat.3.2)))))
                            (begin
                              (set! r9 9223372036854775807)
                              (set! r8 -1891086346)
                              (set! rcx -1371550930)
                              (set! rdx 0)
                              (set! rsi 9223372036854775807)
                              (set! rdi 0)
                              (jump L.proc.0.1 rbp rdi rsi rdx rcx r8 r9))
                      ))
  (check-by-interp '(module (define L.x.0.1
                              (begin
                                (set! bat.7.7 rdi)
                                (set! ball.9.6 rsi)
                                (set! foobar.3.5 rdx)
                                (set! ball.5.4 rcx)
                                (set! ball.4.3 r8)
                                (set! bar.0.2 r9)
                                (set! ball.2.1 fv0)
                                (if (not (if (>= 388494724 ball.9.6)
                                             (> ball.5.4 -9223372036854775808)
                                             (< foobar.3.5 ball.5.4)))
                                    (if (<= ball.4.3 bar.0.2)
                                        0
                                        (begin
                                          (set! ball.4.8 ball.5.4)
                                          1887946265))
                                    foobar.3.5)))
                            (define L.tmp.1.2
                              (begin
                                (set! bat.7.14 rdi)
                                (set! ball.9.13 rsi)
                                (set! ball.5.12 rdx)
                                (set! foo.6.11 rcx)
                                (set! bar.0.10 r8)
                                (set! ball.2.9 r9)
                                (if (true)
                                    (* foo.6.11 9223372036854775807)
                                    (if (begin
                                          (set! foobar.3.15 1)
                                          (<= bar.0.10 ball.5.12))
                                        (begin
                                          (set! ball.9.16 -9223372036854775808)
                                          ball.9.16)
                                        (begin
                                          (set! bat.7.17 1)
                                          1)))))
                      (define L.tmp.2.3
                        (begin
                          (set! bat.7.23 rdi)
                          (set! ball.2.22 rsi)
                          (set! foo.6.21 rdx)
                          (set! foobar.3.20 rcx)
                          (set! bar.8.19 r8)
                          (set! bar.0.18 r9)
                          (begin
                            (if (begin
                                  (set! ball.2.25 258314756)
                                  (!= bar.8.19 0))
                                (set! foobar.3.24 bar.8.19)
                                (begin
                                  (set! foo.6.26 -1809848824)
                                  (set! foobar.3.24 9223372036854775807)))
                            (if (< 1525021420 1)
                                (begin
                                  (set! r9 1067478227)
                                  (set! r8 -768559462)
                                  (set! rcx foo.6.21)
                                  (set! rdx -1256996529)
                                  (set! rsi 1)
                                  (set! rdi foobar.3.24)
                                  (jump L.tmp.1.2 rbp rdi rsi rdx rcx r8 r9))
                                (if (> 389818959 882297114) bar.8.19 ball.2.22)))))
                      (begin
                        (set! bar.0.27 1)
                        1)))
  (check-by-interp '(module (define L.tmp.0.1
                              (begin
                                (set! foo.1.7 rdi)
                                (set! ball.6.6 rsi)
                                (set! bar.9.5 rdx)
                                (set! bat.3.4 rcx)
                                (set! ball.8.3 r8)
                                (set! bat.0.2 r9)
                                (set! ball.7.1 fv0)
                                (* bat.3.4 bat.0.2)))
                            (define L.func.1.2
                              (begin
                                (set! foo.1.12 rdi)
                                (set! bar.2.11 rsi)
                                (set! foo.5.10 rdx)
                                (set! bat.3.9 rcx)
                                (set! bar.9.8 r8)
                                (begin
                                  (set! bat.3.13 1)
                                  9223372036854775807)))
                      (define L.fn.2.3
                        (begin
                          (set! ball.7.15 rdi)
                          (set! ball.8.14 rsi)
                          (begin
                            (if (>= ball.7.15 1)
                                (if (= ball.7.15 ball.7.15)
                                    (set! bat.3.16 ball.8.14)
                                    (set! bat.3.16 214741259))
                                (set! bat.3.16 (+ 1683358713 ball.8.14)))
                            (begin
                              (set! fv0 -2043460455)
                              (set! r9 ball.7.15)
                              (set! r8 9223372036854775807)
                              (set! rcx ball.7.15)
                              (set! rdx 0)
                              (set! rsi ball.8.14)
                              (set! rdi bat.3.16)
                              (jump L.tmp.0.1 rbp rdi rsi rdx rcx r8 r9 fv0)))))
                      (begin
                        (set! fv0 -9223372036854775808)
                        (set! r9 1)
                        (set! r8 -9223372036854775808)
                        (set! rcx 9223372036854775807)
                        (set! rdx -9223372036854775808)
                        (set! rsi -9223372036854775808)
                        (set! rdi -9223372036854775808)
                        (jump L.tmp.0.1 rbp rdi rsi rdx rcx r8 r9 fv0))))
  (check-by-interp '(module (if (true)
                                (+ 1 -9223372036854775808)
                                (if (> 1383245321 0) 0 1))))
  (check-by-interp '(module (define L.x.0.1
                              (begin
                                (set! ball.0.7 rdi)
                                (set! foobar.1.6 rsi)
                                (set! foo.3.5 rdx)
                                (set! foobar.2.4 rcx)
                                (set! foo.6.3 r8)
                                (set! foobar.5.2 r9)
                                (set! ball.8.1 fv0)
                                (begin
                                  (set! rdi 1)
                                  (jump L.x.4.5 rbp rdi))))
                            (define L.func.1.2
                              (begin
                                (begin
                                  (set! bar.9.8 9223372036854775807)
                                  (begin
                                    (set! foobar.1.9 bar.9.8)
                                    (if (>= -577997854 foobar.1.9) -9223372036854775808 bar.9.8)))))
                      (define L.fn.2.3
                        (begin
                          (begin
                            (set! ball.7.10 (+ 1 1))
                            (if (false)
                                ball.7.10
                                (begin
                                  (set! foobar.1.11 ball.7.10)
                                  1969054361)))))
                      (define L.x.3.4
                        (begin
                          (set! foobar.4.18 rdi)
                          (set! foobar.5.17 rsi)
                          (set! bar.9.16 rdx)
                          (set! foobar.2.15 rcx)
                          (set! ball.8.14 r8)
                          (set! foo.3.13 r9)
                          (set! ball.7.12 fv0)
                          (begin
                            (set! fv0 -9223372036854775808)
                            (set! r9 foobar.4.18)
                            (set! r8 9223372036854775807)
                            (set! rcx 25911444)
                            (set! rdx 9223372036854775807)
                            (set! rsi -9223372036854775808)
                            (set! rdi 0)
                            (jump L.func.6.7 rbp rdi rsi rdx rcx r8 r9 fv0))))
                      (define L.x.4.5
                        (begin
                          (set! foobar.4.19 rdi)
                          (begin
                            (set! fv0 foobar.4.19)
                            (set! r9 foobar.4.19)
                            (set! r8 foobar.4.19)
                            (set! rcx 1)
                            (set! rdx foobar.4.19)
                            (set! rsi foobar.4.19)
                            (set! rdi 0)
                            (jump L.x.3.4 rbp rdi rsi rdx rcx r8 r9 fv0))))
                      (define L.x.5.6
                        (begin
                          (set! foo.6.25 rdi)
                          (set! foo.3.24 rsi)
                          (set! foobar.4.23 rdx)
                          (set! bar.9.22 rcx)
                          (set! foobar.1.21 r8)
                          (set! foobar.5.20 r9)
                          (begin
                            (begin
                              (set! foobar.1.27 bar.9.22)
                              (begin
                                (set! foo.6.28 foo.3.24)
                                (set! foobar.5.26 foobar.1.27)))
                            (if (begin
                                  (set! ball.8.29 bar.9.22)
                                  (> foo.3.24 foo.6.25))
                                (begin
                                  (set! fv0 -1819248150)
                                  (set! r9 foobar.5.26)
                                  (set! r8 foo.3.24)
                                  (set! rcx foobar.5.26)
                                  (set! rdx foobar.4.23)
                                  (set! rsi 9223372036854775807)
                                  (set! rdi -1863740769)
                                  (jump L.x.0.1 rbp rdi rsi rdx rcx r8 r9 fv0))
                                1))))
                      (define L.func.6.7
                        (begin
                          (set! foobar.2.36 rdi)
                          (set! foo.6.35 rsi)
                          (set! ball.0.34 rdx)
                          (set! ball.8.33 rcx)
                          (set! foo.3.32 r8)
                          (set! foobar.1.31 r9)
                          (set! foobar.5.30 fv0)
                          (if (if (true)
                                  (begin
                                    (set! ball.0.37 foobar.2.36)
                                    (> -1497437069 -9223372036854775808))
                                  (not (!= -1101838227 -1416967818)))
                              (begin
                                (set! ball.8.38 (+ foobar.2.36 foobar.2.36))
                                (begin
                                  (set! foobar.1.39 0)
                                  foobar.1.39))
                              1)))
                      (define L.fn.7.8
                        (begin
                          (if (true)
                              (if (not (> 0 100011461))
                                  (begin
                                    (set! r9 -1579752260)
                                    (set! r8 0)
                                    (set! rcx -1248542300)
                                    (set! rdx 0)
                                    (set! rsi 16140507)
                                    (set! rdi -9223372036854775808)
                                    (jump L.x.5.6 rbp rdi rsi rdx rcx r8 r9))
                                  (if (= -9223372036854775808 471889533) 1 0))
                              (if (if (>= 1 0)
                                      (>= 0 -9223372036854775808)
                                      (> 9223372036854775807 0))
                                  (begin
                                    (jump L.fn.7.8 rbp))
                                  (if (> 1 1) -444155079 9223372036854775807)))))
                      (if (begin
                            (if (begin
                                  (set! foobar.2.41 -9223372036854775808)
                                  (true))
                                (begin
                                  (if (> 9223372036854775807 0)
                                      (set! foobar.2.42 -1444900091)
                                      (set! foobar.2.42 -9223372036854775808))
                                  (set! foo.6.40 foobar.2.42))
                                (if (true)
                                    (begin
                                      (set! foobar.5.43 9223372036854775807)
                                      (set! foo.6.40 foobar.5.43))
                                    (if (= -9223372036854775808 1173781558)
                                        (set! foo.6.40 0)
                                        (set! foo.6.40 1))))
                            (if (true)
                                (begin
                                  (set! bar.9.44 0)
                                  (true))
                                (< 858519747 foo.6.40)))
                          1
                          (if (< 1 -1323259230)
                              (begin
                                (jump L.fn.2.3 rbp))
                              (begin
                                (jump L.fn.2.3 rbp))))))

  ;; !!!
  (check-match (select-instructions '(module (+ 2 2)))
               `(module ()
                        (begin
                          (set! ,tmp.1 2)
                          (set! ,tmp.1 (+ ,tmp.1 2))
                          (halt ,tmp.1))
                  )
               (aloc? tmp.1))
  (check-equal? (select-instructions '(module (begin
                                                (set! x.1 5)
                                                x.1)))
                '(module ()
                         (begin
                           (set! x.1 5)
                           (halt x.1))
                   ))
  (check-equal? (select-instructions '(module (begin
                                                (set! x.1 (+ 2 2))
                                                x.1)))
                '(module ()
                         (begin
                           (set! x.1 2)
                           (set! x.1 (+ x.1 2))
                           (halt x.1))
                   ))
  (check-match (select-instructions '(module (begin
                                               (set! x.1 2)
                                               (set! x.2 2)
                                               (+ x.1 x.2))))
               `(module ()
                        (begin
                          (set! x.1 2)
                          (set! x.2 2)
                          (set! ,tmp.2 x.1)
                          (set! ,tmp.2 (+ ,tmp.2 x.2))
                          (halt ,tmp.2))
                  )
               (aloc? tmp.2))
  ; custom select-instructions test
  ; This test carries on to the v4 tests
  ;; Begins are not flattened like in the interrogator, we have a seperate pass to flatten.
  (check-equal? (select-instructions '(module 5))
                '(module ()
                         (begin
                           (halt 5))
                   ))
  (check-match (select-instructions '(module (begin
                                               (set! x.1 1)
                                               (set! x.2 2)
                                               (set! x.3 3)
                                               x.1)))
               '(module ()
                        (begin
                          (set! x.1 1)
                          (set! x.2 2)
                          (set! x.3 3)
                          (halt x.1))
                  ))
  (check-equal? (select-instructions '(module (begin
                                                (set! x.1 1)
                                                (begin
                                                  (set! x.2 2)
                                                  (set! x.3 3))
                                                x.1)))
                '(module ()
                         (begin
                           (set! x.1 1)
                           (begin
                             (set! x.2 2)
                             (set! x.3 3))
                           (halt x.1))
                   ))
  (check-equal? (select-instructions '(module (begin
                                                (set! x.1 1)
                                                (begin
                                                  (set! x.2 2)
                                                  (set! x.3 1)
                                                  (set! x.3 (+ x.3 x.2)))
                                                x.1)))
                '(module ()
                         (begin
                           (set! x.1 1)
                           (begin
                             (set! x.2 2)
                             (set! x.3 1)
                             (set! x.3 (+ x.3 x.2)))
                           (halt x.1))
                   ))

  (check-equal? (select-instructions '(module (begin
                                                (set! x.1 1)
                                                (begin
                                                  (set! x.2 2)
                                                  (set! x.3 1)
                                                  (set! x.3 (+ x.3 x.2)))
                                                (if (true) x.1 x.3))))
                `(module ()
                         (begin
                           (set! x.1 1)
                           (begin
                             (set! x.2 2)
                             (set! x.3 1)
                             (set! x.3 (+ x.3 x.2)))
                           (if (true)
                               (begin
                                 (halt x.1))
                               (begin
                                 (halt x.3))))
                   ))

  (check-equal? (select-instructions '(module (if (true) 3 2)))
                `(module ()
                         (if (true)
                             (begin
                               (halt 3))
                             (begin
                               (halt 2)))
                   ))

  (check-equal? (select-instructions '(module (if (true)
                                                  (begin
                                                    (if (if (false)
                                                            (true)
                                                            (not (false)))
                                                        (begin
                                                          (set! x.1 3)
                                                          x.1)
                                                        (begin
                                                          (set! x.1 4)
                                                          x.1)))
                                                  2)))
                `(module ()
                         (if (true)
                             (begin
                               (if (if (false)
                                       (true)
                                       (not (false)))
                                   (begin
                                     (set! x.1 3)
                                     (halt x.1))
                                   (begin
                                     (set! x.1 4)
                                     (halt x.1))))
                             (begin
                               (halt 2)))
                   ))

  (check-match (select-instructions `(module (if (begin
                                                   (set! x.1 3)
                                                   (< 12 13))
                                                 2
                                                 3)))
               `(module ()
                        (if (begin
                              (set! x.1 3)
                              (begin
                                (set! ,tmp.1 12)
                                (< ,tmp.1 13)))
                            (begin
                              (halt 2))
                            (begin
                              (halt 3)))
                  ))

  (check-equal? (select-instructions '(module (if (begin
                                                    (set! x.1 3)
                                                    (< x.1 13))
                                                  2
                                                  3)))
                `(module ()
                         (if (begin
                               (set! x.1 3)
                               (< x.1 13))
                             (begin
                               (halt 2))
                             (begin
                               (halt 3)))
                   )))
