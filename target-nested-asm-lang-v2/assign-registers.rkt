#lang racket

(require cpsc411/compiler-lib
         cpsc411/graph-lib
         cpsc411/info-lib)
; Asm-pred-lang-v6/framed
; p	 	::=	 	(module info (define label info tail) ... tail)
;   info	 ::=	 (#:from-contract (info/c (locals (aloc ...)) (conflicts ((loc (loc ...)) ...)) (assignment ((aloc fvar) ...))))
;----------------
;  Asm-pred-lang-v6/spilled
; p		 	::=	 	(module info (define label info tail) ... tail)
;   info	 ::=	 	(#:from-contract (info/c (locals (aloc ...)) (conflicts ((loc (loc ...)) ...)) (assignment ((aloc rloc) ...))))

(provide assign-registers)

;; (list X (listof Y)) -> Number
;; returns the number of Y in the given pair
(define (num-values pair)
  ; list traversal in Racket moment
  (length (cadr pair)))

;; (list X (listof Y)) Y -> (list X (listof Y))
;; remove one occurence the given Y from the list of Y
;;     if given Y does not exists in the list of Y, do nothing
(define (remove-from-loy pair val)
  (list (car pair) (remove val (cadr pair))))

;; (Asm-pred-lang-v8/framed p) -> (Asm-pred-lang-v8/spilled p)
;; Performs graph-colouring register allocation, compiling Asm-pred-lang v8/framed
;; to Asm-pred-lang v8/spilled by decorating programs with their register assignments.
(define (assign-registers p)
  (define spilled '())

  (define (assign-register alocs conflicts)
    (if (empty? alocs)
        '()
        (let* ([cur-aloc (car alocs)]
               [assigned-rest (assign-register (cdr alocs) (remove-vertex conflicts cur-aloc))]
               [incompatible-registers (get-incompatible-registers cur-aloc assigned-rest conflicts)]
               [available (filter (lambda (rloc) (not (set-member? incompatible-registers rloc)))
                                  (current-assignable-registers))])
          ;(displayln available)
          (if (empty? available)
              ;; spill if nothing is available
              (begin
                (set! spilled (cons cur-aloc spilled))
                assigned-rest)
              (cons (list cur-aloc (car available)) assigned-rest)))))

  (define (get-incompatible-registers cur-var assignments conflicts)
    (let* ([directly-conflicting (get-neighbors conflicts cur-var)]
           [incompatible-registers (mutable-set (filter register? directly-conflicting))])
      (for ([assignment assignments]
            ;; when the assigned aloc is conflicting with the unassigned aloc, we add
            ;; the assigned aloc's register to the list of incompitable registers
            #:when (memq (first assignment) directly-conflicting))
        (set-add! incompatible-registers (second assignment)))
      incompatible-registers))

  ;; ((listof aloc) (listof (loc (listof loc)))) -> (listof aloc)
  ;; Sorts alocs in non-decreasing order, where comparisons are based on conflict graph size
  (define (sort-by-degree alocs conflicts)
    (sort alocs
          (lambda (u v)
            (< (length (get-neighbors conflicts u)) (length (get-neighbors conflicts v))))))

  (define (update-info info)
    ;; Each info needs its own spilled list
    (set! spilled '())
    (let* ([locals (info-ref info 'locals)]
           [conflicts (info-ref info 'conflicts)]
           [existing-assignments (info-ref info 'assignment)]
           [already-assigned-alocs (map car existing-assignments)]
           [unassigned-alocs (filter (lambda (aloc) (not (memq aloc already-assigned-alocs))) locals)]
           [sorted (sort-by-degree unassigned-alocs conflicts)]
           [new-assignments (assign-register sorted conflicts)]
           [all-assignments (append existing-assignments new-assignments)])
      (info-set (info-set info 'locals spilled) 'assignment all-assignments)))

  (define (assign-definition def)
    (match def
      [`(define ,label
          ,info
          ,tail)
       `(define ,label
          ,(update-info info)
          ,tail)]))
  (match p
    [`(module ,info ,defs
        ...
        ,tail)
     ; Replaces the locals set with just the alocs that spilled
     `(module ,(update-info info) ,@(map assign-definition defs)
        ,tail)]))

;; HaYdEnS WacKy DebUGgEr
#;(module+ test
    (require rackunit
             cpsc411/langs/v6)
    (check-match
     (assign-registers '(module ((locals (tmp.1539 tmp-ra.1524 y.1494))
                                 (conflicts ((y.1494 (rbp tmp-ra.1524)) (tmp-ra.1524 (rax y.1494 rbp))
                                                                        (tmp.1539 ())
                                                                        (rbp (rax y.1494 tmp-ra.1524))
                                                                        (rax (rbp tmp-ra.1524))))
                                 (assignment ()))
                                (begin
                                  (set! tmp-ra.1524 r15)
                                  (set! y.1494 200)
                                  (if (begin
                                        (set! tmp.1539 3)
                                        (< tmp.1539 y.1494))
                                      (begin
                                        (set! rax 1)
                                        (jump tmp-ra.1524 rbp rax))
                                      (begin
                                        (set! rax 0)
                                        (jump tmp-ra.1524 rbp rax))))
                          ))
     '(module ((locals ()) (conflicts ((y.1494 (rbp tmp-ra.1524)) (tmp-ra.1524 (rax y.1494 rbp))
                                                                  (tmp.1539 ())
                                                                  (rbp (rax y.1494 tmp-ra.1524))
                                                                  (rax (rbp tmp-ra.1524))))
                           (assignment ((tmp-ra.1524 r15) (y.1494 r14) (tmp.1539 r15))))
              (begin
                (set! tmp-ra.1524 r15)
                (set! y.1494 200)
                (if (begin
                      (set! tmp.1539 3)
                      (< tmp.1539 y.1494))
                    (begin
                      (set! rax 1)
                      (jump tmp-ra.1524 rbp rax))
                    (begin
                      (set! rax 0)
                      (jump tmp-ra.1524 rbp rax))))
        ))

    (check-match
     (assign-registers `(module ((locals (tmp.1540 tmp-ra.1529))
                                 (conflicts ((tmp-ra.1529 (rax rbp)) (tmp.1540 ())
                                                                     (rbp (rax tmp-ra.1529))
                                                                     (rax (rbp tmp-ra.1529))))
                                 (assignment ()))
                                (begin
                                  (set! tmp-ra.1529 r15)
                                  (if (begin
                                        (set! tmp.1540 0)
                                        (= tmp.1540 0))
                                      (begin
                                        (set! rax 0)
                                        (jump tmp-ra.1529 rbp rax))
                                      (begin
                                        (set! rax 1)
                                        (jump tmp-ra.1529 rbp rax))))
                          ))
     `(module ((locals ()) (conflicts ((tmp-ra.1529 (rax rbp)) (tmp.1540 ())
                                                               (rbp (rax tmp-ra.1529))
                                                               (rax (rbp tmp-ra.1529))))
                           (assignment ((tmp-ra.1529 r15) (tmp.1540 r15))))
              (begin
                (set! tmp-ra.1529 r15)
                (if (begin
                      (set! tmp.1540 0)
                      (= tmp.1540 0))
                    (begin
                      (set! rax 0)
                      (jump tmp-ra.1529 rbp rax))
                    (begin
                      (set! rax 1)
                      (jump tmp-ra.1529 rbp rax))))
        ))

    (displayln (interp-asm-pred-lang-v6/framed
                '(module ((locals (tmp.1539 tmp-ra.1524 y.1494))
                          (conflicts ((y.1494 (rbp tmp-ra.1524)) (tmp-ra.1524 (rax y.1494 rbp))
                                                                 (tmp.1539 ())
                                                                 (rbp (rax y.1494 tmp-ra.1524))
                                                                 (rax (rbp tmp-ra.1524))))
                          (assignment ()))
                         (begin
                           (set! tmp-ra.1524 r15)
                           (set! y.1494 200)
                           (if (begin
                                 (set! tmp.1539 3)
                                 (< tmp.1539 y.1494))
                               (begin
                                 (set! rax 1)
                                 (jump tmp-ra.1524 rbp rax))
                               (begin
                                 (set! rax 0)
                                 (jump tmp-ra.1524 rbp rax))))
                   )))

    #;(displayln
       (interp-asm-pred-lang-v6/spilled
        '(module ((locals ()) (conflicts ((y.1494 (rbp tmp-ra.1524)) (tmp-ra.1524 (rax y.1494 rbp))
                                                                     (tmp.1539 ())
                                                                     (rbp (rax y.1494 tmp-ra.1524))
                                                                     (rax (rbp tmp-ra.1524))))
                              (assignment ((tmp.1539 rsp) (y.1494 rbx) (tmp-ra.1524 rsp))))
                 (begin
                   (set! tmp-ra.1524 r15)
                   (set! y.1494 200)
                   (if (begin
                         (set! tmp.1539 3)
                         (< tmp.1539 y.1494))
                       (begin
                         (set! rax 1)
                         (jump tmp-ra.1524 rbp rax))
                       (begin
                         (set! rax 0)
                         (jump tmp-ra.1524 rbp rax))))
           )))
    #;(displayln
       (interp-asm-pred-lang-v6/spilled
        '(module ((locals ()) (conflicts ((y.1494 (rbp tmp-ra.1524)) (tmp-ra.1524 (rax y.1494 rbp))
                                                                     (tmp.1539 ())
                                                                     (rbp (rax y.1494 tmp-ra.1524))
                                                                     (rax (rbp tmp-ra.1524))))
                              (assignment ((tmp-ra.1524 r15) (y.1494 r14) (tmp.1539 r15))))
                 (begin
                   (set! tmp-ra.1524 r15)
                   (set! y.1494 200)
                   (if (begin
                         (set! tmp.1539 3)
                         (< tmp.1539 y.1494))
                       (begin
                         (set! rax 1)
                         (jump tmp-ra.1524 rbp rax))
                       (begin
                         (set! rax 0)
                         (jump tmp-ra.1524 rbp rax))))
           )))

    (displayln (interp-asm-pred-lang-v6/framed
                `(module ((locals (tmp.1540 tmp-ra.1529))
                          (conflicts ((tmp-ra.1529 (rax rbp)) (tmp.1540 ())
                                                              (rbp (rax tmp-ra.1529))
                                                              (rax (rbp tmp-ra.1529))))
                          (assignment ()))
                         (begin
                           (set! tmp-ra.1529 r15)
                           (if (begin
                                 (set! tmp.1540 0)
                                 (= tmp.1540 0))
                               (begin
                                 (set! rax 0)
                                 (jump tmp-ra.1529 rbp rax))
                               (begin
                                 (set! rax 1)
                                 (jump tmp-ra.1529 rbp rax))))
                   )))

    (displayln (aloc? `tmp.1540))

    (displayln (interp-asm-pred-lang-v6/spilled
                `(module ((locals ()) (conflicts ((tmp-ra.1529 (rax rbp)) (tmp.1540 ())
                                                                          (rbp (rax tmp-ra.1529))
                                                                          (rax (rbp tmp-ra.1529))))
                                      (assignment ((tmp.1540 rsp) (tmp-ra.1529 rsp))))
                         (begin
                           (set! tmp-ra.1529 r15)
                           (if (begin
                                 (set! tmp.1540 0)
                                 (= tmp.1540 0))
                               (begin
                                 (set! rax 0)
                                 (jump tmp-ra.1529 rbp rax))
                               (begin
                                 (set! rax 1)
                                 (jump tmp-ra.1529 rbp rax))))
                   ))))

(module+ test
  (require rackunit
           cpsc411/langs/v6)
  (define-syntax-rule (check-by-interp p)
    (check-equal? (interp-asm-pred-lang-v6/pre-framed p)
                  (interp-asm-pred-lang-v6/framed (assign-registers p))))
  ;; M6 tests; Added by Trevor on March 6th 2026, at most one binding per let
  (check-by-interp '(module ((locals (ball.2.3 foobar.3.1 bat.9.2 tmp-ra.4))
                             (conflicts ((tmp-ra.4 (rax ball.2.3 foobar.3.1 bat.9.2 rbp))
                                         (bat.9.2 (rbp tmp-ra.4))
                                         (foobar.3.1 (rbp tmp-ra.4))
                                         (ball.2.3 (rbp tmp-ra.4))
                                         (rbp (rax ball.2.3 foobar.3.1 bat.9.2 tmp-ra.4))
                                         (rax (rbp tmp-ra.4))))
                             (assignment ()))
                            (begin
                              (set! tmp-ra.4 r15)
                              (set! bat.9.2 -422317085)
                              (set! foobar.3.1 bat.9.2)
                              (set! ball.2.3 foobar.3.1)
                              (set! rax foobar.3.1)
                              (jump tmp-ra.4 rbp rax))
                      ))
  (check-by-interp
   '(module ((locals (tmp.16 tmp-ra.14 ball.6.11 foobar.9.10))
             (conflicts ((foobar.9.10 (rbp tmp-ra.14))
                         (ball.6.11 (rbp tmp-ra.14))
                         (tmp-ra.14 (tmp.16 foobar.9.10 rbp rax ball.6.11 rdi rsi))
                         (tmp.16 (rbp tmp-ra.14))
                         (rsi (r15 rdi rbp tmp-ra.14))
                         (rbp (tmp.16 foobar.9.10 tmp-ra.14 rax ball.6.11 r15 rdi rsi))
                         (rdi (r15 rbp rsi tmp-ra.14))
                         (r15 (rbp rdi rsi))
                         (rax (rbp tmp-ra.14))))
             (assignment ()))
            (define L.func.0.1
              ((locals (foobar.2.1 bat.5.2 bat.0.3 ball.4.4 ball.3.5 tmp-ra.12))
               (conflicts
                ((tmp-ra.12 (rax foobar.2.1 bat.5.2 bat.0.3 ball.4.4 ball.3.5 rbp r8 rcx rdx rsi rdi))
                 (ball.3.5 (rbp tmp-ra.12 r8 rcx rdx rsi))
                 (ball.4.4 (rbp tmp-ra.12 r8 rcx rdx))
                 (bat.0.3 (rbp tmp-ra.12 r8 rcx))
                 (bat.5.2 (rbp tmp-ra.12 r8))
                 (foobar.2.1 (rbp tmp-ra.12))
                 (rdi (tmp-ra.12))
                 (rsi (ball.3.5 tmp-ra.12))
                 (rdx (ball.4.4 ball.3.5 tmp-ra.12))
                 (rcx (bat.0.3 ball.4.4 ball.3.5 tmp-ra.12))
                 (r8 (bat.5.2 bat.0.3 ball.4.4 ball.3.5 tmp-ra.12))
                 (rbp (rax foobar.2.1 bat.5.2 bat.0.3 ball.4.4 ball.3.5 tmp-ra.12))
                 (rax (rbp tmp-ra.12))))
               (assignment ()))
              (begin
                (set! tmp-ra.12 r15)
                (set! ball.3.5 rdi)
                (set! ball.4.4 rsi)
                (set! bat.0.3 rdx)
                (set! bat.5.2 rcx)
                (set! foobar.2.1 r8)
                (set! rax 9223372036854775807)
                (jump tmp-ra.12 rbp rax)))
      (define L.proc.1.2
        ((locals (ball.8.9 bar.7.6 tmp.15))
         (conflicts ((tmp.15 (rbp tmp-ra.13 bar.7.8 bat.0.7))
                     (bat.0.7 (ball.8.9 rax bar.7.6 rbp tmp-ra.13 rsi tmp.15))
                     (tmp-ra.13 (ball.8.9 bar.7.8 bar.7.6 bat.0.7 rbp rsi rdi tmp.15 rax))
                     (bar.7.8 (ball.8.9 rax rbp tmp-ra.13 tmp.15))
                     (bar.7.6 (rbp tmp-ra.13 bat.0.7))
                     (ball.8.9 (rbp tmp-ra.13 bar.7.8 bat.0.7))
                     (rax (bar.7.8 bat.0.7 rbp tmp-ra.13))
                     (rbp (ball.8.9 r15 rdi rsi bar.7.8 bar.7.6 bat.0.7 tmp-ra.13 tmp.15 rax))
                     (rdi (r15 rbp rsi tmp-ra.13))
                     (rsi (r15 rdi rbp bat.0.7 tmp-ra.13))
                     (r15 (rbp rdi rsi))))
         (assignment ((tmp-ra.13 fv0) (bar.7.8 fv1) (bat.0.7 fv1))))
        (begin
          (set! tmp-ra.13 r15)
          (set! bat.0.7 rdi)
          (set! bar.7.6 rsi)
          (set! bar.7.8 bat.0.7)
          (begin
            (set! rbp (- rbp 24))
            (return-point L.rp.3
                          (begin
                            (set! rsi bar.7.8)
                            (set! rdi bar.7.8)
                            (set! r15 L.rp.3)
                            (jump L.proc.1.2 rbp r15 rdi rsi)))
            (set! rbp (+ rbp 24)))
          (set! ball.8.9 rax)
          (if (begin
                (set! tmp.15 -59730991)
                (= tmp.15 bat.0.7))
              (begin
                (set! rax 0)
                (jump tmp-ra.13 rbp rax))
              (begin
                (set! rax bar.7.8)
                (jump tmp-ra.13 rbp rax)))))
      (begin
        (set! tmp-ra.14 r15)
        (if (false)
            (set! foobar.9.10 9223372036854775807)
            (begin
              (set! tmp.16 1)
              (set! tmp.16 (* tmp.16 -9223372036854775808))
              (set! foobar.9.10 tmp.16)))
        (if (not (> foobar.9.10 foobar.9.10))
            (begin
              (set! ball.6.11 foobar.9.10)
              (set! rax -1510146984)
              (jump tmp-ra.14 rbp rax))
            (begin
              (set! rsi foobar.9.10)
              (set! rdi -9223372036854775808)
              (set! r15 tmp-ra.14)
              (jump L.proc.1.2 rbp r15 rdi rsi))))))
  (check-by-interp
   '(module ((locals (tmp.9 bat.8.2 bat.9.1 bat.9.4 bat.9.3 tmp.7 tmp.8 bat.3.5 tmp-ra.6))
             (conflicts
              ((tmp-ra.6 (rax tmp.9 bat.8.2 bat.9.4 tmp.7 bat.9.3 bat.3.5 tmp.8 bat.9.1 rbp))
               (bat.3.5 (rbp tmp-ra.6))
               (tmp.8 (rbp tmp-ra.6))
               (tmp.7 (rbp tmp-ra.6))
               (bat.9.3 (rbp tmp-ra.6))
               (bat.9.4 (rbp tmp-ra.6))
               (bat.9.1 (rbp tmp-ra.6))
               (bat.8.2 (rbp tmp-ra.6))
               (tmp.9 (rbp tmp-ra.6))
               (rbp (rax tmp.9 bat.8.2 bat.9.4 tmp.7 bat.9.3 bat.3.5 tmp.8 bat.9.1 tmp-ra.6))
               (rax (rbp tmp-ra.6))))
             (assignment ()))
            (begin
              (set! tmp-ra.6 r15)
              (if (begin
                    (set! bat.8.2 -1418594624)
                    (false))
                  (begin
                    (if (begin
                          (set! tmp.7 -1123833745)
                          (> tmp.7 1))
                        (set! bat.9.3 1)
                        (set! bat.9.3 0))
                    (set! bat.9.4 767736686)
                    (set! bat.9.1 bat.9.4))
                  (if (true)
                      (begin
                        (set! bat.3.5 1942655457)
                        (set! bat.9.1 bat.3.5))
                      (begin
                        (set! tmp.8 -9223372036854775808)
                        (set! tmp.8 (+ tmp.8 1))
                        (set! bat.9.1 tmp.8))))
              (set! tmp.9 bat.9.1)
              (set! tmp.9 (- tmp.9 bat.9.1))
              (set! rax tmp.9)
              (jump tmp-ra.6 rbp rax))
      ))
  (check-by-interp
   '(module ((locals (tmp.12 foobar.5.7 tmp-ra.9))
             (conflicts ((tmp-ra.9 (rax tmp.12 foobar.5.7 rbp)) (foobar.5.7 (rbp tmp-ra.9))
                                                                (tmp.12 (rbp tmp-ra.9))
                                                                (rbp (rax tmp.12 foobar.5.7 tmp-ra.9))
                                                                (rax (rbp tmp-ra.9))))
             (assignment ()))
            (define L.func.0.1
              ((locals (foo.3.6 bat.2.3 foobar.9.4 foobar.8.5 tmp.11 tmp.10))
               (conflicts
                ((tmp.10 (rbp tmp-ra.8 bat.0.1 foo.7.2))
                 (tmp-ra.8 (foo.3.6 bat.0.1
                                    foo.7.2
                                    bat.2.3
                                    foobar.9.4
                                    foobar.8.5
                                    rbp
                                    tmp.10
                                    tmp.11
                                    rax
                                    rdi
                                    rsi
                                    rdx
                                    rcx
                                    r8))
                 (bat.0.1 (foo.3.6 rax rbp tmp-ra.8 foo.7.2 foobar.9.4 tmp.10 tmp.11 rdx rcx r8))
                 (tmp.11 (rbp tmp-ra.8 bat.0.1))
                 (foo.7.2 (foo.3.6 rax bat.0.1 rbp tmp-ra.8 foobar.9.4 r8 tmp.10))
                 (foobar.8.5 (rbp tmp-ra.8 r8 rcx rdx rsi))
                 (foobar.9.4 (bat.0.1 foo.7.2 bat.2.3 rbp tmp-ra.8 r8 rcx rdx))
                 (bat.2.3 (rbp tmp-ra.8 foobar.9.4 r8 rcx))
                 (foo.3.6 (rbp tmp-ra.8 bat.0.1 foo.7.2))
                 (r8 (foo.7.2 bat.2.3 foobar.9.4 foobar.8.5 r15 rdi rsi rdx rcx rbp tmp-ra.8 bat.0.1))
                 (rbp (foo.3.6 bat.0.1
                               foo.7.2
                               bat.2.3
                               foobar.9.4
                               foobar.8.5
                               tmp-ra.8
                               tmp.10
                               tmp.11
                               rax
                               r15
                               rdi
                               rsi
                               rdx
                               rcx
                               r8))
                 (rcx (bat.2.3 foobar.9.4 foobar.8.5 r15 rdi rsi rdx rbp r8 tmp-ra.8 bat.0.1))
                 (rdx (foobar.9.4 foobar.8.5 r15 rdi rsi rbp rcx r8 tmp-ra.8 bat.0.1))
                 (rsi (foobar.8.5 r15 rdi rbp rdx rcx r8 tmp-ra.8))
                 (rdi (r15 rbp rsi rdx rcx r8 tmp-ra.8))
                 (r15 (rbp rdi rsi rdx rcx r8))
                 (rax (bat.0.1 foo.7.2 rbp tmp-ra.8))))
               (assignment ((tmp-ra.8 fv0) (bat.0.1 fv1) (foo.7.2 fv2))))
              (begin
                (set! tmp-ra.8 r15)
                (set! foobar.8.5 rdi)
                (set! foobar.9.4 rsi)
                (set! bat.2.3 rdx)
                (set! foo.7.2 rcx)
                (set! bat.0.1 r8)
                (begin
                  (set! rbp (- rbp 24))
                  (return-point L.rp.2
                                (begin
                                  (set! r8 bat.0.1)
                                  (set! rcx foo.7.2)
                                  (set! rdx foobar.9.4)
                                  (set! rsi -9223372036854775808)
                                  (set! rdi -1343541856)
                                  (set! r15 L.rp.2)
                                  (jump L.func.0.1 rbp r15 rdi rsi rdx rcx r8)))
                  (set! rbp (+ rbp 24)))
                (set! foo.3.6 rax)
                (if (begin
                      (set! tmp.10 0)
                      (!= tmp.10 9223372036854775807))
                    (if (begin
                          (set! tmp.11 1346978436)
                          (= tmp.11 bat.0.1))
                        (begin
                          (set! rax 0)
                          (jump tmp-ra.8 rbp rax))
                        (begin
                          (set! rax bat.0.1)
                          (jump tmp-ra.8 rbp rax)))
                    (begin
                      (set! r8 foo.7.2)
                      (set! rcx 9223372036854775807)
                      (set! rdx 1)
                      (set! rsi bat.0.1)
                      (set! rdi -1402588641)
                      (set! r15 tmp-ra.8)
                      (jump L.func.0.1 rbp r15 rdi rsi rdx rcx r8)))))
      (begin
        (set! tmp-ra.9 r15)
        (if (begin
              (set! tmp.12 824269768)
              (< tmp.12 9223372036854775807))
            (set! foobar.5.7 -9223372036854775808)
            (set! foobar.5.7 709343632))
        (set! rax foobar.5.7)
        (jump tmp-ra.9 rbp rax))))
  (check-by-interp
   '(module ((locals (tmp.3 foo.6.1 tmp-ra.2))
             (conflicts ((tmp-ra.2 (rax tmp.3 foo.6.1 rbp)) (foo.6.1 (rbp tmp-ra.2))
                                                            (tmp.3 (rbp tmp-ra.2))
                                                            (rbp (rax tmp.3 foo.6.1 tmp-ra.2))
                                                            (rax (rbp tmp-ra.2))))
             (assignment ()))
            (begin
              (set! tmp-ra.2 r15)
              (set! foo.6.1 -356902212)
              (set! tmp.3 -979281755)
              (set! tmp.3 (+ tmp.3 9223372036854775807))
              (set! rax tmp.3)
              (jump tmp-ra.2 rbp rax))
      ))
  (check-by-interp
   '(module ((locals (tmp-ra.5 tmp.6)) (conflicts ((tmp.6 (rbp tmp-ra.5)) (tmp-ra.5 (rbp tmp.6 rax))
                                                                          (rax (rbp tmp-ra.5))
                                                                          (rbp (tmp-ra.5 tmp.6 rax))))
                                       (assignment ()))
            (define L.tmp.0.1
              ((locals (foo.5.1 foobar.9.2 ball.6.3 tmp-ra.4))
               (conflicts ((tmp-ra.4 (foo.5.1 foobar.9.2 ball.6.3 rbp rdx rsi rdi))
                           (ball.6.3 (rbp tmp-ra.4 rdx rsi))
                           (foobar.9.2 (rbp tmp-ra.4 rdx))
                           (foo.5.1 (rbp tmp-ra.4))
                           (rdi (r15 rbp rsi rdx tmp-ra.4))
                           (rsi (r15 rdi rbp rdx ball.6.3 tmp-ra.4))
                           (rdx (r15 rdi rsi rbp foobar.9.2 ball.6.3 tmp-ra.4))
                           (rbp (r15 rdi rsi rdx foo.5.1 foobar.9.2 ball.6.3 tmp-ra.4))
                           (r15 (rbp rdi rsi rdx))))
               (assignment ()))
              (begin
                (set! tmp-ra.4 r15)
                (set! ball.6.3 rdi)
                (set! foobar.9.2 rsi)
                (set! foo.5.1 rdx)
                (set! rdx foo.5.1)
                (set! rsi 182548382)
                (set! rdi 0)
                (set! r15 tmp-ra.4)
                (jump L.tmp.0.1 rbp r15 rdi rsi rdx)))
      (begin
        (set! tmp-ra.5 r15)
        (if (begin
              (set! tmp.6 1)
              (= tmp.6 -444572554))
            (begin
              (set! rax -9223372036854775808)
              (jump tmp-ra.5 rbp rax))
            (begin
              (set! rax 0)
              (jump tmp-ra.5 rbp rax))))))
  (check-by-interp
   '(module ((locals (tmp-ra.16 tmp.18))
             (conflicts ((tmp.18 (rbp tmp-ra.16)) (tmp-ra.16 (rbp tmp.18 rax))
                                                  (rax (rbp tmp-ra.16))
                                                  (rbp (tmp-ra.16 tmp.18 rax))))
             (assignment ()))
            (define L.x.0.1
              ((locals (ball.3.5 bat.5.8 bat.5.1 ball.4.2 bat.6.7 foobar.9.6))
               (conflicts
                ((bat.6.3
                  (bat.5.1 ball.4.2 rbp tmp-ra.14 bar.7.4 foobar.9.6 bat.6.7 bat.5.8 rcx r8 rax))
                 (foobar.9.6 (rbp tmp-ra.14 bat.6.3 bar.7.4 ball.4.2))
                 (bat.6.7 (rbp tmp-ra.14 bat.6.3 bar.7.4 ball.4.2))
                 (bar.7.4
                  (bat.5.1 ball.4.2 bat.6.3 rbp tmp-ra.14 r8 rcx rdx foobar.9.6 bat.6.7 bat.5.8 rax))
                 (tmp-ra.14 (bat.5.1 ball.4.2
                                     bat.6.3
                                     bar.7.4
                                     ball.3.5
                                     rbp
                                     r8
                                     rcx
                                     rdx
                                     rsi
                                     rdi
                                     foobar.9.6
                                     bat.6.7
                                     bat.5.8
                                     rax))
                 (ball.4.2 (bat.5.1 rbp tmp-ra.14 bat.6.3 bar.7.4 r8 foobar.9.6 bat.6.7))
                 (bat.5.1 (rbp tmp-ra.14 bat.6.3 bar.7.4 ball.4.2 rsi rdx r8))
                 (bat.5.8 (rbp tmp-ra.14 bat.6.3 bar.7.4))
                 (ball.3.5 (rbp tmp-ra.14 r8 rcx rdx rsi))
                 (rax (bat.6.3 bar.7.4 rbp tmp-ra.14))
                 (rbp (bat.5.1 ball.4.2
                               bat.6.3
                               bar.7.4
                               ball.3.5
                               tmp-ra.14
                               foobar.9.6
                               bat.6.7
                               bat.5.8
                               r15
                               rdi
                               rsi
                               rdx
                               rcx
                               r8
                               rax))
                 (r8 (ball.4.2 bar.7.4 ball.3.5 tmp-ra.14 r15 rdi rsi rdx rcx rbp bat.5.1 bat.6.3))
                 (rcx (bar.7.4 ball.3.5 tmp-ra.14 r15 rdi rsi rdx rbp r8 bat.6.3))
                 (rdx (bar.7.4 ball.3.5 tmp-ra.14 r15 rdi rsi rbp rcx r8 bat.5.1))
                 (rsi (ball.3.5 tmp-ra.14 r15 rdi rbp rdx rcx r8 bat.5.1))
                 (rdi (tmp-ra.14 r15 rbp rsi rdx rcx r8))
                 (r15 (rbp rdi rsi rdx rcx r8))))
               (assignment ((tmp-ra.14 fv0) (bat.6.3 fv1) (bar.7.4 fv2))))
              (begin
                (set! tmp-ra.14 r15)
                (set! ball.3.5 rdi)
                (set! bar.7.4 rsi)
                (set! bat.6.3 rdx)
                (set! ball.4.2 rcx)
                (set! bat.5.1 r8)
                (if (not (<= bat.6.3 9223372036854775807))
                    (begin
                      (set! bat.6.7 -18835826)
                      (set! foobar.9.6 bat.6.7)
                      (if (>= bat.6.3 ball.4.2)
                          (begin
                            (set! rax bat.6.3)
                            (jump tmp-ra.14 rbp rax))
                          (begin
                            (set! rax bar.7.4)
                            (jump tmp-ra.14 rbp rax))))
                    (begin
                      (begin
                        (set! rbp (- rbp 24))
                        (return-point L.rp.3
                                      (begin
                                        (set! r8 0)
                                        (set! rcx bat.5.1)
                                        (set! rdx bat.6.3)
                                        (set! rsi 9223372036854775807)
                                        (set! rdi bat.5.1)
                                        (set! r15 L.rp.3)
                                        (jump L.x.0.1 rbp r15 rdi rsi rdx rcx r8)))
                        (set! rbp (+ rbp 24)))
                      (set! bat.5.8 rax)
                      (if (<= bar.7.4 -186024487)
                          (begin
                            (set! rax bat.5.8)
                            (jump tmp-ra.14 rbp rax))
                          (begin
                            (set! rax bat.6.3)
                            (jump tmp-ra.14 rbp rax)))))))
      (define L.func.1.2
        ((locals (bat.5.13 tmp.17 foobar.9.12 bar.7.11 ball.4.9 bar.8.10 tmp-ra.15))
         (conflicts
          ((tmp-ra.15 (rax bat.5.13 tmp.17 foobar.9.12 bar.7.11 ball.4.9 bar.8.10 rbp rsi rdi))
           (bar.8.10 (tmp.17 bar.7.11 ball.4.9 rbp tmp-ra.15 rsi))
           (ball.4.9 (rbp tmp-ra.15 bar.8.10))
           (bar.7.11 (tmp.17 foobar.9.12 rbp tmp-ra.15 bar.8.10))
           (foobar.9.12 (rbp tmp-ra.15 bar.7.11))
           (tmp.17 (rbp tmp-ra.15 bar.7.11 bar.8.10))
           (bat.5.13 (rbp tmp-ra.15))
           (rdi (tmp-ra.15))
           (rsi (bar.8.10 tmp-ra.15))
           (rbp (rax bat.5.13 tmp.17 foobar.9.12 bar.7.11 ball.4.9 bar.8.10 tmp-ra.15))
           (rax (rbp tmp-ra.15))))
         (assignment ()))
        (begin
          (set! tmp-ra.15 r15)
          (set! bar.8.10 rdi)
          (set! ball.4.9 rsi)
          (set! bar.7.11 -932453002)
          (if (begin
                (set! tmp.17 -1133252869)
                (>= tmp.17 9223372036854775807))
              (set! foobar.9.12 479665611)
              (set! foobar.9.12 bar.8.10))
          (set! bat.5.13 bar.7.11)
          (set! rax bar.7.11)
          (jump tmp-ra.15 rbp rax)))
      (begin
        (set! tmp-ra.16 r15)
        (if (begin
              (set! tmp.18 1588211020)
              (>= tmp.18 1))
            (begin
              (set! rax 9223372036854775807)
              (jump tmp-ra.16 rbp rax))
            (begin
              (set! rax -9223372036854775808)
              (jump tmp-ra.16 rbp rax))))))

  (check-by-interp
   '(module ((locals (tmp-ra.1)) (conflicts ((tmp-ra.1 (rax rbp)) (rbp (rax tmp-ra.1))
                                                                  (rax (rbp tmp-ra.1))))
                                 (assignment ()))
            (begin
              (set! tmp-ra.1 r15)
              (set! rax 1)
              (jump tmp-ra.1 rbp rax))
      ))
  (check-by-interp
   '(module ((locals (tmp-ra.21 bar.2.16 bar.2.15 foobar.8.17 tmp.28 bat.0.14 tmp.27))
             (conflicts
              ((tmp.27 (rbp tmp-ra.21 bat.0.14))
               (bat.0.14 (rbp tmp-ra.21 tmp.27 tmp.28))
               (tmp.28 (rbp tmp-ra.21 bat.0.14))
               (foobar.8.17 (rbp tmp-ra.21))
               (bar.2.15 (rbp tmp-ra.21))
               (bar.2.16 (rbp tmp-ra.21))
               (tmp-ra.21
                (rbp foobar.8.17 bar.2.15 bar.2.16 bat.0.14 tmp.27 tmp.28 rdx rcx r8 r9 fv0 rdi rsi))
               (rsi (rdx rcx r8 r9 fv0 r15 rdi rbp tmp-ra.21))
               (rbp (tmp-ra.21 foobar.8.17
                               bar.2.15
                               bar.2.16
                               bat.0.14
                               tmp.27
                               tmp.28
                               rdx
                               rcx
                               r8
                               r9
                               fv0
                               r15
                               rdi
                               rsi))
               (rdi (rdx rcx r8 r9 fv0 r15 rbp rsi tmp-ra.21))
               (r15 (rdx rcx r8 r9 fv0 rbp rdi rsi))
               (fv0 (r15 rdi rsi rdx rcx r8 r9 rbp tmp-ra.21))
               (r9 (r15 rdi rsi rdx rcx r8 rbp fv0 tmp-ra.21))
               (r8 (r15 rdi rsi rdx rcx rbp r9 fv0 tmp-ra.21))
               (rcx (r15 rdi rsi rdx rbp r8 r9 fv0 tmp-ra.21))
               (rdx (r15 rdi rsi rbp rcx r8 r9 fv0 tmp-ra.21))))
             (assignment ()))
            (define L.fn.0.1
              ((locals (tmp.22 foobar.4.3 bat.0.1 ball.9.2 tmp-ra.18))
               (conflicts ((tmp-ra.18 (rax tmp.22 foobar.4.3 bat.0.1 ball.9.2 rbp rsi rdi))
                           (ball.9.2 (bat.0.1 rbp tmp-ra.18 rsi))
                           (bat.0.1 (rbp tmp-ra.18 ball.9.2))
                           (foobar.4.3 (rbp tmp-ra.18))
                           (tmp.22 (rbp tmp-ra.18))
                           (rdi (tmp-ra.18))
                           (rsi (ball.9.2 tmp-ra.18))
                           (rbp (rax tmp.22 foobar.4.3 bat.0.1 ball.9.2 tmp-ra.18))
                           (rax (rbp tmp-ra.18))))
               (assignment ()))
              (begin
                (set! tmp-ra.18 r15)
                (set! ball.9.2 rdi)
                (set! bat.0.1 rsi)
                (set! foobar.4.3 ball.9.2)
                (set! tmp.22 0)
                (set! tmp.22 (* tmp.22 0))
                (set! rax tmp.22)
                (jump tmp-ra.18 rbp rax)))
      (define L.fn.1.2
        ((locals (tmp.25 tmp.24 ball.9.4 tmp-ra.19 tmp.23))
         (conflicts ((tmp.23 (rbp tmp-ra.19)) (tmp-ra.19 (rbp tmp.23 ball.9.4 tmp.24 tmp.25 rax))
                                              (ball.9.4 (rbp tmp-ra.19))
                                              (tmp.24 (rbp tmp-ra.19))
                                              (tmp.25 (rbp tmp-ra.19))
                                              (rax (rbp tmp-ra.19))
                                              (rbp (tmp-ra.19 tmp.23 ball.9.4 tmp.24 tmp.25 rax))))
         (assignment ()))
        (begin
          (set! tmp-ra.19 r15)
          (if (begin
                (set! tmp.23 -9223372036854775808)
                (>= tmp.23 9223372036854775807))
              (begin
                (set! rax -1098447432)
                (jump tmp-ra.19 rbp rax))
              (begin
                (set! tmp.24 -9223372036854775808)
                (set! tmp.24 (+ tmp.24 -9223372036854775808))
                (set! ball.9.4 tmp.24)
                (if (begin
                      (set! tmp.25 857729561)
                      (< tmp.25 9223372036854775807))
                    (begin
                      (set! rax 9223372036854775807)
                      (jump tmp-ra.19 rbp rax))
                    (begin
                      (set! rax 1)
                      (jump tmp-ra.19 rbp rax)))))))
      (define L.fn.2.3
        ((locals (bar.2.5 bar.7.7
                          ball.9.9
                          tmp.26
                          bat.3.6
                          bat.6.13
                          bat.5.11
                          bar.2.12
                          foobar.4.8
                          bat.0.10
                          tmp-ra.20))
         (conflicts
          ((tmp-ra.20 (bar.2.5 bat.3.6
                               bar.7.7
                               foobar.4.8
                               ball.9.9
                               bat.0.10
                               bat.5.11
                               rbp
                               fv0
                               r9
                               r8
                               rcx
                               rdx
                               rdi
                               rsi
                               bar.2.12
                               tmp.26
                               rax
                               bat.6.13))
           (bat.0.10 (bar.2.5 bat.3.6
                              bar.7.7
                              foobar.4.8
                              ball.9.9
                              rbp
                              tmp-ra.20
                              bat.5.11
                              fv0
                              r9
                              r8
                              rcx
                              rdx
                              rsi
                              bar.2.12))
           (foobar.4.8 (bar.2.5 bat.3.6 bar.7.7 rbp tmp-ra.20 bat.0.10 bat.5.11 fv0 r9 r8 tmp.26))
           (bar.2.12 (rbp tmp-ra.20 bat.0.10))
           (bat.5.11 (bar.2.5 bat.3.6
                              bar.7.7
                              foobar.4.8
                              ball.9.9
                              bat.0.10
                              rbp
                              tmp-ra.20
                              fv0
                              r9
                              r8
                              rcx
                              rdx
                              rsi))
           (bat.6.13 (rbp tmp-ra.20))
           (bat.3.6 (bar.2.5 rbp tmp-ra.20 bat.0.10 foobar.4.8 bat.5.11 fv0))
           (tmp.26 (rbp tmp-ra.20 foobar.4.8))
           (ball.9.9 (rbp tmp-ra.20 bat.0.10 bat.5.11 fv0 r9 r8 rcx))
           (bar.7.7 (rbp tmp-ra.20 bat.0.10 foobar.4.8 bat.5.11 fv0 r9))
           (bar.2.5 (rbp tmp-ra.20 bat.0.10 foobar.4.8 bat.5.11 bat.3.6))
           (rbp (bar.2.5 bat.3.6
                         bar.7.7
                         foobar.4.8
                         ball.9.9
                         bat.0.10
                         bat.5.11
                         tmp-ra.20
                         r15
                         rdi
                         rsi
                         bar.2.12
                         tmp.26
                         rax
                         bat.6.13))
           (rax (rbp tmp-ra.20))
           (rsi (bat.5.11 r15 rdi rbp tmp-ra.20 bat.0.10))
           (rdi (r15 rbp rsi tmp-ra.20))
           (r15 (rbp rdi rsi))
           (rdx (bat.0.10 bat.5.11 tmp-ra.20))
           (rcx (ball.9.9 bat.0.10 bat.5.11 tmp-ra.20))
           (r8 (foobar.4.8 ball.9.9 bat.0.10 bat.5.11 tmp-ra.20))
           (r9 (bar.7.7 foobar.4.8 ball.9.9 bat.0.10 bat.5.11 tmp-ra.20))
           (fv0 (bat.3.6 bar.7.7 foobar.4.8 ball.9.9 bat.0.10 bat.5.11 tmp-ra.20))))
         (assignment ()))
        (begin
          (set! tmp-ra.20 r15)
          (set! bat.5.11 rdi)
          (set! bat.0.10 rsi)
          (set! ball.9.9 rdx)
          (set! foobar.4.8 rcx)
          (set! bar.7.7 r8)
          (set! bat.3.6 r9)
          (set! bar.2.5 fv0)
          (if (not (true))
              (begin
                (if (>= foobar.4.8 -9223372036854775808)
                    (set! bar.2.12 1)
                    (set! bar.2.12 1))
                (set! rsi bar.2.12)
                (set! rdi bat.0.10)
                (set! r15 tmp-ra.20)
                (jump L.fn.0.1 rbp r15 rdi rsi))
              (if (true)
                  (begin
                    (set! tmp.26 bat.3.6)
                    (set! tmp.26 (* tmp.26 foobar.4.8))
                    (set! rax tmp.26)
                    (jump tmp-ra.20 rbp rax))
                  (begin
                    (set! bat.6.13 bat.5.11)
                    (set! rax 674342291)
                    (jump tmp-ra.20 rbp rax))))))
      (begin
        (set! tmp-ra.21 r15)
        (if (begin
              (begin
                (set! bar.2.16 1)
                (set! bar.2.15 -9223372036854775808)
                (set! foobar.8.17 bar.2.15)
                (set! bat.0.14 9223372036854775807))
              (if (true)
                  (if (= bat.0.14 bat.0.14)
                      (begin
                        (set! tmp.27 -1195644570)
                        (>= tmp.27 bat.0.14))
                      (= bat.0.14 bat.0.14))
                  (if (> bat.0.14 bat.0.14)
                      (>= bat.0.14 bat.0.14)
                      (begin
                        (set! tmp.28 0)
                        (= tmp.28 bat.0.14)))))
            (begin
              (set! fv0 0)
              (set! r9 9223372036854775807)
              (set! r8 -2036437657)
              (set! rcx 0)
              (set! rdx 0)
              (set! rsi -1663007716)
              (set! rdi 1453047515)
              (set! r15 tmp-ra.21)
              (jump L.fn.2.3 rbp r15 rdi rsi rdx rcx r8 r9 fv0))
            (begin
              (set! rsi -1792916675)
              (set! rdi 1)
              (set! r15 tmp-ra.21)
              (jump L.fn.0.1 rbp r15 rdi rsi))))))

  (check-by-interp
   '(module ((locals (ball.1.15 tmp-ra.19))
             (conflicts ((tmp-ra.19 (rax ball.1.15 rbp)) (ball.1.15 (rbp tmp-ra.19))
                                                         (rbp (rax ball.1.15 tmp-ra.19))
                                                         (rax (rbp tmp-ra.19))))
             (assignment ()))
            (define L.tmp.0.1
              ((locals (ball.5.1 foobar.2.2 bat.3.3 foo.6.4 foo.7.5 bar.4.6 bar.8.7 tmp-ra.16))
               (conflicts ((tmp-ra.16 (ball.5.1 foobar.2.2
                                                bat.3.3
                                                foo.6.4
                                                foo.7.5
                                                bar.4.6
                                                bar.8.7
                                                rbp
                                                fv0
                                                r9
                                                r8
                                                rcx
                                                rdx
                                                rsi
                                                rdi))
                           (bar.8.7 (rbp tmp-ra.16 fv0 r9 r8 rcx rdx rsi))
                           (bar.4.6 (rbp tmp-ra.16 fv0 r9 r8 rcx rdx))
                           (foo.7.5 (rbp tmp-ra.16 fv0 r9 r8 rcx))
                           (foo.6.4 (ball.5.1 foobar.2.2 bat.3.3 rbp tmp-ra.16 fv0 r9 r8))
                           (bat.3.3 (rbp tmp-ra.16 foo.6.4 fv0 r9))
                           (foobar.2.2 (rbp tmp-ra.16 foo.6.4 fv0))
                           (ball.5.1 (rbp tmp-ra.16 foo.6.4))
                           (rdi (r15 rbp rsi rdx tmp-ra.16))
                           (rsi (r15 rdi rbp rdx bar.8.7 tmp-ra.16))
                           (rdx (r15 rdi rsi rbp bar.4.6 bar.8.7 tmp-ra.16))
                           (rcx (foo.7.5 bar.4.6 bar.8.7 tmp-ra.16))
                           (r8 (foo.6.4 foo.7.5 bar.4.6 bar.8.7 tmp-ra.16))
                           (r9 (bat.3.3 foo.6.4 foo.7.5 bar.4.6 bar.8.7 tmp-ra.16))
                           (fv0 (foobar.2.2 bat.3.3 foo.6.4 foo.7.5 bar.4.6 bar.8.7 tmp-ra.16))
                           (rbp (r15 rdi
                                     rsi
                                     rdx
                                     ball.5.1
                                     foobar.2.2
                                     bat.3.3
                                     foo.6.4
                                     foo.7.5
                                     bar.4.6
                                     bar.8.7
                                     tmp-ra.16))
                           (r15 (rbp rdi rsi rdx))))
               (assignment ()))
              (begin
                (set! tmp-ra.16 r15)
                (set! bar.8.7 rdi)
                (set! bar.4.6 rsi)
                (set! foo.7.5 rdx)
                (set! foo.6.4 rcx)
                (set! bat.3.3 r8)
                (set! foobar.2.2 r9)
                (set! ball.5.1 fv0)
                (set! rdx foo.6.4)
                (set! rsi 946654223)
                (set! rdi 9223372036854775807)
                (set! r15 tmp-ra.16)
                (jump L.func.1.2 rbp r15 rdi rsi rdx)))
      (define L.func.1.2
        ((locals (bar.8.8 ball.5.9 ball.1.10 tmp-ra.17))
         (conflicts ((tmp-ra.17 (bar.8.8 ball.5.9 ball.1.10 rbp rdx rsi rdi))
                     (ball.1.10 (rbp tmp-ra.17 rdx rsi))
                     (ball.5.9 (rsi bar.8.8 rbp tmp-ra.17 rdx))
                     (bar.8.8 (rdx rbp tmp-ra.17 ball.5.9))
                     (rdi (r15 rbp rsi rdx tmp-ra.17))
                     (rsi (r15 rdi rbp rdx ball.5.9 ball.1.10 tmp-ra.17))
                     (rdx (r15 rdi rsi rbp bar.8.8 ball.5.9 ball.1.10 tmp-ra.17))
                     (rbp (r15 rdi rsi rdx bar.8.8 ball.5.9 ball.1.10 tmp-ra.17))
                     (r15 (rbp rdi rsi rdx))))
         (assignment ()))
        (begin
          (set! tmp-ra.17 r15)
          (set! ball.1.10 rdi)
          (set! ball.5.9 rsi)
          (set! bar.8.8 rdx)
          (set! rdx 9223372036854775807)
          (set! rsi bar.8.8)
          (set! rdi ball.5.9)
          (set! r15 tmp-ra.17)
          (jump L.func.1.2 rbp r15 rdi rsi rdx)))
      (define L.fn.2.3
        ((locals (ball.5.14 ball.5.11 ball.0.12 bar.8.13 tmp-ra.18))
         (conflicts ((tmp-ra.18 (ball.5.14 ball.5.11 ball.0.12 bar.8.13 rbp rdx rsi rdi))
                     (bar.8.13 (ball.5.14 ball.5.11 ball.0.12 rbp tmp-ra.18 rdx rsi))
                     (ball.0.12 (rsi ball.5.14 ball.5.11 rbp tmp-ra.18 bar.8.13 rdx))
                     (ball.5.11 (rbp tmp-ra.18 ball.0.12 bar.8.13))
                     (ball.5.14 (rbp tmp-ra.18 ball.0.12 bar.8.13))
                     (rdi (r15 rbp rsi rdx tmp-ra.18))
                     (rsi (r15 rdi rbp rdx ball.0.12 bar.8.13 tmp-ra.18))
                     (rdx (r15 rdi rsi rbp ball.0.12 bar.8.13 tmp-ra.18))
                     (rbp (r15 rdi rsi rdx ball.5.14 ball.5.11 ball.0.12 bar.8.13 tmp-ra.18))
                     (r15 (rbp rdi rsi rdx))))
         (assignment ()))
        (begin
          (set! tmp-ra.18 r15)
          (set! bar.8.13 rdi)
          (set! ball.0.12 rsi)
          (set! ball.5.11 rdx)
          (set! ball.5.14 9223372036854775807)
          (set! rdx bar.8.13)
          (set! rsi 0)
          (set! rdi ball.0.12)
          (set! r15 tmp-ra.18)
          (jump L.func.1.2 rbp r15 rdi rsi rdx)))
      (begin
        (set! tmp-ra.19 r15)
        (set! ball.1.15 0)
        (set! rax 1)
        (jump tmp-ra.19 rbp rax))))
  (check-by-interp
   '(module ((locals (tmp-ra.9))
             (conflicts ((tmp-ra.9 (rdi rsi rdx rcx r8 rbp)) (rbp (r15 rdi rsi rdx rcx r8 tmp-ra.9))
                                                             (r8 (r15 rdi rsi rdx rcx rbp tmp-ra.9))
                                                             (rcx (r15 rdi rsi rdx rbp r8 tmp-ra.9))
                                                             (rdx (r15 rdi rsi rbp rcx r8 tmp-ra.9))
                                                             (rsi (r15 rdi rbp rdx rcx r8 tmp-ra.9))
                                                             (rdi (r15 rbp rsi rdx rcx r8 tmp-ra.9))
                                                             (r15 (rbp rdi rsi rdx rcx r8))))
             (assignment ()))
            (define L.func.0.1
              ((locals (foo.1.1 bat.2.2 foobar.7.3 foo.0.4 tmp-ra.8 foo.9.5 ball.3.6 tmp.10 foo.9.7))
               (conflicts
                ((foo.9.7 (rbp tmp-ra.8))
                 (tmp.10 (rbp tmp-ra.8 foo.9.5))
                 (ball.3.6 (rbp tmp-ra.8))
                 (foo.9.5 (foo.1.1 bat.2.2 foobar.7.3 foo.0.4 rbp tmp-ra.8 r8 rcx rdx rsi tmp.10))
                 (tmp-ra.8 (foo.1.1 bat.2.2
                                    foobar.7.3
                                    foo.0.4
                                    foo.9.5
                                    rbp
                                    r8
                                    rcx
                                    rdx
                                    rsi
                                    rdi
                                    foo.9.7
                                    tmp.10
                                    ball.3.6
                                    rax))
                 (foo.0.4 (rbp tmp-ra.8 foo.9.5 r8 rcx rdx))
                 (foobar.7.3 (rbp tmp-ra.8 foo.9.5 r8 rcx))
                 (bat.2.2 (rbp tmp-ra.8 foo.9.5 r8))
                 (foo.1.1 (rbp tmp-ra.8 foo.9.5))
                 (rax (rbp tmp-ra.8))
                 (rbp
                  (foo.1.1 bat.2.2 foobar.7.3 foo.0.4 foo.9.5 tmp-ra.8 foo.9.7 tmp.10 ball.3.6 rax))
                 (rdi (tmp-ra.8))
                 (rsi (foo.9.5 tmp-ra.8))
                 (rdx (foo.0.4 foo.9.5 tmp-ra.8))
                 (rcx (foobar.7.3 foo.0.4 foo.9.5 tmp-ra.8))
                 (r8 (bat.2.2 foobar.7.3 foo.0.4 foo.9.5 tmp-ra.8))))
               (assignment ()))
              (begin
                (set! tmp-ra.8 r15)
                (set! foo.9.5 rdi)
                (set! foo.0.4 rsi)
                (set! foobar.7.3 rdx)
                (set! bat.2.2 rcx)
                (set! foo.1.1 r8)
                (if (false)
                    (begin
                      (if (begin
                            (set! tmp.10 -9223372036854775808)
                            (!= tmp.10 0))
                          (set! ball.3.6 1)
                          (set! ball.3.6 foo.9.5))
                      (set! foo.9.7 9223372036854775807)
                      (set! rax 9223372036854775807)
                      (jump tmp-ra.8 rbp rax))
                    (begin
                      (set! rax 1)
                      (jump tmp-ra.8 rbp rax)))))
      (begin
        (set! tmp-ra.9 r15)
        (set! r8 1653803490)
        (set! rcx 1918330809)
        (set! rdx 1)
        (set! rsi 9223372036854775807)
        (set! rdi -9223372036854775808)
        (set! r15 tmp-ra.9)
        (jump L.func.0.1 rbp r15 rdi rsi rdx rcx r8))))
  (check-by-interp
   '(module ((locals (tmp-ra.10)) (conflicts ((tmp-ra.10 (rax rbp)) (rbp (rax tmp-ra.10))
                                                                    (rax (rbp tmp-ra.10))))
                                  (assignment ()))
            (define L.fn.0.1
              ((locals (bat.6.1 tmp-ra.7 bat.8.2 foobar.1.3))
               (conflicts ((foobar.1.3 (rbp tmp-ra.7 bat.6.1 bat.8.2))
                           (bat.8.2 (bat.6.1 rbp tmp-ra.7 rsi foobar.1.3))
                           (tmp-ra.7 (bat.6.1 bat.8.2 rbp foobar.1.3 rdi rsi rdx))
                           (bat.6.1 (rbp tmp-ra.7 bat.8.2 foobar.1.3 rsi rdx))
                           (r15 (rdi rsi rdx rbp))
                           (rbp (bat.6.1 bat.8.2 tmp-ra.7 foobar.1.3 rdi rsi rdx r15))
                           (rdx (r15 rdi rsi rbp tmp-ra.7 bat.6.1))
                           (rsi (bat.8.2 r15 rdi rbp rdx tmp-ra.7 bat.6.1))
                           (rdi (r15 rbp rsi rdx tmp-ra.7))))
               (assignment ()))
              (begin
                (set! tmp-ra.7 r15)
                (set! bat.8.2 rdi)
                (set! bat.6.1 rsi)
                (if (begin
                      (set! foobar.1.3 559317709)
                      (not (= foobar.1.3 bat.8.2)))
                    (begin
                      (set! rdx -675648818)
                      (set! rsi -9223372036854775808)
                      (set! rdi bat.6.1)
                      (set! r15 tmp-ra.7)
                      (jump L.func.1.2 rbp r15 rdi rsi rdx))
                    (begin
                      (set! r15 tmp-ra.7)
                      (jump L.tmp.2.3 rbp r15)))))
      (define L.func.1.2
        ((locals (foo.5.4 foo.0.5 foobar.1.6 tmp-ra.8))
         (conflicts ((tmp-ra.8 (foo.5.4 foo.0.5 foobar.1.6 rbp rdx rsi rdi))
                     (foobar.1.6 (rbp tmp-ra.8 rdx rsi))
                     (foo.0.5 (rbp tmp-ra.8 rdx))
                     (foo.5.4 (rbp tmp-ra.8))
                     (rdi (tmp-ra.8))
                     (rsi (foobar.1.6 tmp-ra.8))
                     (rdx (foo.0.5 foobar.1.6 tmp-ra.8))
                     (rbp (r15 foo.5.4 foo.0.5 foobar.1.6 tmp-ra.8))
                     (r15 (rbp))))
         (assignment ()))
        (begin
          (set! tmp-ra.8 r15)
          (set! foobar.1.6 rdi)
          (set! foo.0.5 rsi)
          (set! foo.5.4 rdx)
          (set! r15 tmp-ra.8)
          (jump L.tmp.2.3 rbp r15)))
      (define L.tmp.2.3
        ((locals (tmp-ra.9)) (conflicts ((tmp-ra.9 (rbp)) (rbp (r15 tmp-ra.9)) (r15 (rbp))))
                             (assignment ()))
        (begin
          (set! tmp-ra.9 r15)
          (set! r15 tmp-ra.9)
          (jump L.tmp.2.3 rbp r15)))
      (begin
        (set! tmp-ra.10 r15)
        (set! rax 1)
        (jump tmp-ra.10 rbp rax))))
  (check-by-interp
   '(module ((locals (tmp-ra.9))
             (conflicts ((tmp-ra.9 (rdi rsi rdx rcx rbp)) (rbp (r15 rdi rsi rdx rcx tmp-ra.9))
                                                          (rcx (r15 rdi rsi rdx rbp tmp-ra.9))
                                                          (rdx (r15 rdi rsi rbp rcx tmp-ra.9))
                                                          (rsi (r15 rdi rbp rdx rcx tmp-ra.9))
                                                          (rdi (r15 rbp rsi rdx rcx tmp-ra.9))
                                                          (r15 (rbp rdi rsi rdx rcx))))
             (assignment ()))
            (define L.x.0.1
              ((locals (tmp.10 foobar.7.6 bar.3.7 bat.2.5 bat.9.1 bat.2.2 ball.0.3 bar.3.4 tmp-ra.8))
               (conflicts
                ((tmp-ra.8 (rax tmp.10
                                foobar.7.6
                                bar.3.7
                                bat.2.5
                                bat.9.1
                                bat.2.2
                                ball.0.3
                                bar.3.4
                                rbp
                                rcx
                                rdx
                                rsi
                                rdi))
                 (bar.3.4
                  (foobar.7.6 bar.3.7 bat.2.5 bat.9.1 bat.2.2 ball.0.3 rbp tmp-ra.8 rcx rdx rsi))
                 (ball.0.3 (bat.9.1 bat.2.2 rbp tmp-ra.8 bar.3.4 rcx rdx))
                 (bat.2.2 (rbp tmp-ra.8 bar.3.4 ball.0.3 rcx))
                 (bat.9.1 (rbp tmp-ra.8 bar.3.4 ball.0.3))
                 (bat.2.5 (rbp tmp-ra.8 bar.3.4))
                 (bar.3.7 (rbp tmp-ra.8 bar.3.4))
                 (foobar.7.6 (rbp tmp-ra.8 bar.3.4))
                 (tmp.10 (rbp tmp-ra.8))
                 (rdi (tmp-ra.8))
                 (rsi (bar.3.4 tmp-ra.8))
                 (rdx (ball.0.3 bar.3.4 tmp-ra.8))
                 (rcx (bat.2.2 ball.0.3 bar.3.4 tmp-ra.8))
                 (rbp
                  (rax tmp.10 foobar.7.6 bar.3.7 bat.2.5 bat.9.1 bat.2.2 ball.0.3 bar.3.4 tmp-ra.8))
                 (rax (rbp tmp-ra.8))))
               (assignment ()))
              (begin
                (set! tmp-ra.8 r15)
                (set! bar.3.4 rdi)
                (set! ball.0.3 rsi)
                (set! bat.2.2 rdx)
                (set! bat.9.1 rcx)
                (if (= ball.0.3 bat.9.1)
                    (set! bat.2.5 ball.0.3)
                    (set! bat.2.5 -1012326174))
                (set! bar.3.7 0)
                (set! foobar.7.6 bar.3.7)
                (set! tmp.10 bar.3.4)
                (set! tmp.10 (- tmp.10 0))
                (set! rax tmp.10)
                (jump tmp-ra.8 rbp rax)))
      (begin
        (set! tmp-ra.9 r15)
        (set! rcx 1259250868)
        (set! rdx 1097392993)
        (set! rsi 0)
        (set! rdi 1)
        (set! r15 tmp-ra.9)
        (jump L.x.0.1 rbp r15 rdi rsi rdx rcx))))

  (check-by-interp
   '(module ((locals (tmp-ra.12))
             (conflicts ((tmp-ra.12 (rdi rsi rdx rcx r8 rbp)) (rbp (r15 rdi rsi rdx rcx r8 tmp-ra.12))
                                                              (r8 (r15 rdi rsi rdx rcx rbp tmp-ra.12))
                                                              (rcx (r15 rdi rsi rdx rbp r8 tmp-ra.12))
                                                              (rdx (r15 rdi rsi rbp rcx r8 tmp-ra.12))
                                                              (rsi (r15 rdi rbp rdx rcx r8 tmp-ra.12))
                                                              (rdi (r15 rbp rsi rdx rcx r8 tmp-ra.12))
                                                              (r15 (rbp rdi rsi rdx rcx r8))))
             (assignment ()))
            (define L.tmp.0.1
              ((locals (bar.4.1 ball.5.2 bar.9.3 tmp-ra.10))
               (conflicts ((tmp-ra.10 (rcx r8 bar.4.1 ball.5.2 bar.9.3 rbp rdx rsi rdi))
                           (bar.9.3 (rbp tmp-ra.10 rdx rsi))
                           (ball.5.2 (rcx r8 bar.4.1 rbp tmp-ra.10 rdx))
                           (bar.4.1 (rbp tmp-ra.10 ball.5.2))
                           (rdi (r15 rbp rsi rdx rcx r8 tmp-ra.10))
                           (rsi (r15 rdi rbp rdx rcx r8 bar.9.3 tmp-ra.10))
                           (rdx (r15 rdi rsi rbp rcx r8 ball.5.2 bar.9.3 tmp-ra.10))
                           (rbp (r15 rdi rsi rdx rcx r8 bar.4.1 ball.5.2 bar.9.3 tmp-ra.10))
                           (r8 (r15 rdi rsi rdx rcx rbp tmp-ra.10 ball.5.2))
                           (rcx (r15 rdi rsi rdx rbp r8 tmp-ra.10 ball.5.2))
                           (r15 (rbp rdi rsi rdx rcx r8))))
               (assignment ()))
              (begin
                (set! tmp-ra.10 r15)
                (set! bar.9.3 rdi)
                (set! ball.5.2 rsi)
                (set! bar.4.1 rdx)
                (set! r8 bar.4.1)
                (set! rcx 1)
                (set! rdx ball.5.2)
                (set! rsi -1620042780)
                (set! rdi 0)
                (set! r15 tmp-ra.10)
                (jump L.x.1.2 rbp r15 rdi rsi rdx rcx r8)))
      (define L.x.1.2
        ((locals (tmp.13 foo.6.9 foo.1.4 bat.0.5 bar.9.6 bar.2.7 ball.8.8 tmp-ra.11))
         (conflicts
          ((tmp-ra.11
            (rax tmp.13 foo.6.9 foo.1.4 bat.0.5 bar.9.6 bar.2.7 ball.8.8 rbp r8 rcx rdx rsi rdi))
           (ball.8.8 (rbp tmp-ra.11 r8 rcx rdx rsi))
           (bar.2.7 (rbp tmp-ra.11 r8 rcx rdx))
           (bar.9.6 (rbp tmp-ra.11 r8 rcx))
           (bat.0.5 (tmp.13 foo.6.9 foo.1.4 rbp tmp-ra.11 r8))
           (foo.1.4 (rbp tmp-ra.11 bat.0.5))
           (foo.6.9 (rbp tmp-ra.11 bat.0.5))
           (tmp.13 (rbp tmp-ra.11 bat.0.5))
           (rdi (tmp-ra.11))
           (rsi (ball.8.8 tmp-ra.11))
           (rdx (bar.2.7 ball.8.8 tmp-ra.11))
           (rcx (bar.9.6 bar.2.7 ball.8.8 tmp-ra.11))
           (r8 (bat.0.5 bar.9.6 bar.2.7 ball.8.8 tmp-ra.11))
           (rbp (rax tmp.13 foo.6.9 foo.1.4 bat.0.5 bar.9.6 bar.2.7 ball.8.8 tmp-ra.11))
           (rax (rbp tmp-ra.11))))
         (assignment ()))
        (begin
          (set! tmp-ra.11 r15)
          (set! ball.8.8 rdi)
          (set! bar.2.7 rsi)
          (set! bar.9.6 rdx)
          (set! bat.0.5 rcx)
          (set! foo.1.4 r8)
          (set! foo.6.9 9223372036854775807)
          (set! tmp.13 -9223372036854775808)
          (set! tmp.13 (+ tmp.13 bat.0.5))
          (set! rax tmp.13)
          (jump tmp-ra.11 rbp rax)))
      (begin
        (set! tmp-ra.12 r15)
        (set! r8 0)
        (set! rcx 1)
        (set! rdx 9223372036854775807)
        (set! rsi -913438169)
        (set! rdi -1611188905)
        (set! r15 tmp-ra.12)
        (jump L.x.1.2 rbp r15 rdi rsi rdx rcx r8))))

  (check-by-interp
   '(module ((locals (tmp.15 tmp.13 bar.7.5 tmp.14 foobar.1.6 foobar.1.7 tmp.12 tmp.11 tmp.10))
             (conflicts
              ((tmp.10 (rbp tmp-ra.9))
               (tmp.11 (rbp tmp-ra.9))
               (tmp.12 (rbp tmp-ra.9))
               (foobar.1.7 (rbp tmp-ra.9 bar.7.5))
               (tmp-ra.9
                (rbp tmp.10 tmp.11 tmp.12 bar.7.5 tmp.13 tmp.14 foobar.1.6 foobar.1.7 rax tmp.15))
               (foobar.1.6 (rbp tmp-ra.9))
               (tmp.14 (rbp tmp-ra.9 bar.7.5))
               (bar.7.5 (rbp tmp-ra.9 tmp.13 tmp.14 foobar.1.7))
               (tmp.13 (rbp tmp-ra.9 bar.7.5))
               (tmp.15 (rbp tmp-ra.9))
               (rbp (tmp-ra.9 tmp.10
                              tmp.11
                              tmp.12
                              r15
                              rdi
                              rsi
                              rdx
                              rcx
                              bar.7.5
                              tmp.13
                              tmp.14
                              foobar.1.6
                              foobar.1.7
                              rax
                              tmp.15))
               (rax (rbp tmp-ra.9))
               (rcx (r15 rdi rsi rdx rbp))
               (rdx (r15 rdi rsi rbp rcx))
               (rsi (r15 rdi rbp rdx rcx))
               (rdi (r15 rbp rsi rdx rcx))
               (r15 (rbp rdi rsi rdx rcx))))
             (assignment ((tmp-ra.9 fv0))))
            (define L.tmp.0.1
              ((locals (bar.8.1 ball.5.2 foobar.9.3 bar.4.4 tmp-ra.8))
               (conflicts ((tmp-ra.8 (bar.8.1 ball.5.2 foobar.9.3 bar.4.4 rbp rcx rdx rsi rdi))
                           (bar.4.4 (rbp tmp-ra.8 rcx rdx rsi))
                           (foobar.9.3 (rsi bar.8.1 ball.5.2 rbp tmp-ra.8 rcx rdx))
                           (ball.5.2 (bar.8.1 rbp tmp-ra.8 foobar.9.3 rcx))
                           (bar.8.1 (rbp tmp-ra.8 foobar.9.3 ball.5.2))
                           (rdi (r15 rbp rsi rdx rcx tmp-ra.8))
                           (rsi (r15 rdi rbp rdx rcx foobar.9.3 bar.4.4 tmp-ra.8))
                           (rdx (r15 rdi rsi rbp rcx foobar.9.3 bar.4.4 tmp-ra.8))
                           (rcx (r15 rdi rsi rdx rbp ball.5.2 foobar.9.3 bar.4.4 tmp-ra.8))
                           (rbp (r15 rdi rsi rdx rcx bar.8.1 ball.5.2 foobar.9.3 bar.4.4 tmp-ra.8))
                           (r15 (rbp rdi rsi rdx rcx))))
               (assignment ()))
              (begin
                (set! tmp-ra.8 r15)
                (set! bar.4.4 rdi)
                (set! foobar.9.3 rsi)
                (set! ball.5.2 rdx)
                (set! bar.8.1 rcx)
                (set! rcx ball.5.2)
                (set! rdx ball.5.2)
                (set! rsi ball.5.2)
                (set! rdi foobar.9.3)
                (set! r15 tmp-ra.8)
                (jump L.tmp.0.1 rbp r15 rdi rsi rdx rcx)))
      (begin
        (set! tmp-ra.9 r15)
        (if (false)
            (begin
              (if (if (begin
                        (set! tmp.10 9223372036854775807)
                        (> tmp.10 1428972274))
                      (begin
                        (set! tmp.11 0)
                        (!= tmp.11 479631559))
                      (begin
                        (set! tmp.12 0)
                        (>= tmp.12 1284385619)))
                  (begin
                    (begin
                      (set! rbp (- rbp 8))
                      (return-point L.rp.2
                                    (begin
                                      (set! rcx 1)
                                      (set! rdx 0)
                                      (set! rsi -1164071576)
                                      (set! rdi 1550080702)
                                      (set! r15 L.rp.2)
                                      (jump L.tmp.0.1 rbp r15 rdi rsi rdx rcx)))
                      (set! rbp (+ rbp 8)))
                    (set! bar.7.5 rax))
                  (set! bar.7.5 -9223372036854775808))
              (if (if (begin
                        (set! tmp.13 0)
                        (<= tmp.13 bar.7.5))
                      (!= bar.7.5 2009350954)
                      (begin
                        (set! tmp.14 1170635915)
                        (!= tmp.14 bar.7.5)))
                  (begin
                    (set! foobar.1.6 bar.7.5)
                    (set! rax 0)
                    (jump tmp-ra.9 rbp rax))
                  (begin
                    (set! foobar.1.7 -378459323)
                    (set! rax bar.7.5)
                    (jump tmp-ra.9 rbp rax))))
            (if (false)
                (begin
                  (set! rax 0)
                  (jump tmp-ra.9 rbp rax))
                (begin
                  (set! tmp.15 1326448876)
                  (set! tmp.15 (- tmp.15 360169641))
                  (set! rax tmp.15)
                  (jump tmp-ra.9 rbp rax)))))))
  (check-by-interp '(module ((locals (foo.7.1 foo.5.3 foo.5.2 tmp-ra.4))
                             (conflicts ((tmp-ra.4 (rax foo.7.1 foo.5.3 foo.5.2 rbp))
                                         (foo.5.2 (rbp tmp-ra.4))
                                         (foo.5.3 (rbp tmp-ra.4))
                                         (foo.7.1 (rbp tmp-ra.4))
                                         (rbp (rax foo.7.1 foo.5.3 foo.5.2 tmp-ra.4))
                                         (rax (rbp tmp-ra.4))))
                             (assignment ()))
                            (begin
                              (set! tmp-ra.4 r15)
                              (set! foo.5.2 1)
                              (set! foo.5.3 foo.5.2)
                              (set! foo.7.1 foo.5.3)
                              (set! rax foo.7.1)
                              (jump tmp-ra.4 rbp rax))
                      ))

  (check-by-interp
   '(module ((locals (tmp.15 tmp-ra.11))
             (conflicts ((tmp-ra.11 (rax tmp.15 rbp)) (tmp.15 (rbp tmp-ra.11))
                                                      (rbp (rax tmp.15 tmp-ra.11))
                                                      (rax (rbp tmp-ra.11))))
             (assignment ()))
            (define L.func.0.1
              ((locals (tmp.12 foobar.8.1 foo.1.2 bat.7.3 tmp-ra.9))
               (conflicts ((tmp-ra.9 (rax tmp.12 foobar.8.1 foo.1.2 bat.7.3 rbp rdx rsi rdi))
                           (bat.7.3 (rbp tmp-ra.9 rdx rsi))
                           (foo.1.2 (rbp tmp-ra.9 rdx))
                           (foobar.8.1 (rbp tmp-ra.9))
                           (tmp.12 (rbp tmp-ra.9))
                           (rdi (tmp-ra.9))
                           (rsi (bat.7.3 tmp-ra.9))
                           (rdx (foo.1.2 bat.7.3 tmp-ra.9))
                           (rbp (rax tmp.12 foobar.8.1 foo.1.2 bat.7.3 tmp-ra.9))
                           (rax (rbp tmp-ra.9))))
               (assignment ()))
              (begin
                (set! tmp-ra.9 r15)
                (set! bat.7.3 rdi)
                (set! foo.1.2 rsi)
                (set! foobar.8.1 rdx)
                (set! tmp.12 1903463490)
                (set! tmp.12 (* tmp.12 -9223372036854775808))
                (set! rax tmp.12)
                (jump tmp-ra.9 rbp rax)))
      (define L.func.1.2
        ((locals (tmp.13 foobar.9.7 bat.7.6 bat.0.4 foobar.4.8 tmp-ra.10 bar.3.5 tmp.14))
         (conflicts
          ((tmp.14 (rbp tmp-ra.10 foobar.4.8 bat.7.6 bat.0.4 bar.3.5))
           (bar.3.5 (foobar.4.8 tmp.13 bat.0.4 rbp tmp-ra.10 bat.7.6 foobar.9.7 rcx tmp.14))
           (tmp-ra.10
            (foobar.4.8 tmp.13 bat.0.4 bar.3.5 bat.7.6 foobar.9.7 rbp rcx rdx rsi rdi tmp.14 rax))
           (foobar.4.8 (rbp tmp-ra.10 bat.7.6 bat.0.4 bar.3.5 tmp.14))
           (bat.0.4 (foobar.4.8 tmp.13 rbp tmp-ra.10 bat.7.6 bar.3.5 foobar.9.7 tmp.14))
           (bat.7.6 (foobar.4.8 tmp.13 bat.0.4 bar.3.5 rbp tmp-ra.10 foobar.9.7 rcx rdx tmp.14))
           (foobar.9.7 (tmp.13 bat.0.4 bar.3.5 bat.7.6 rbp tmp-ra.10 rcx rdx rsi))
           (tmp.13 (rbp tmp-ra.10 bat.7.6 bat.0.4 bar.3.5 foobar.9.7))
           (rax (rbp tmp-ra.10))
           (rbp (foobar.4.8 tmp.13 bat.0.4 bar.3.5 bat.7.6 foobar.9.7 tmp-ra.10 tmp.14 rax))
           (rdi (tmp-ra.10))
           (rsi (foobar.9.7 tmp-ra.10))
           (rdx (bat.7.6 foobar.9.7 tmp-ra.10))
           (rcx (bar.3.5 bat.7.6 foobar.9.7 tmp-ra.10))))
         (assignment ()))
        (begin
          (set! tmp-ra.10 r15)
          (set! foobar.9.7 rdi)
          (set! bat.7.6 rsi)
          (set! bar.3.5 rdx)
          (set! bat.0.4 rcx)
          (set! tmp.13 -9223372036854775808)
          (set! tmp.13 (- tmp.13 foobar.9.7))
          (set! foobar.4.8 tmp.13)
          (if (begin
                (set! tmp.14 9223372036854775807)
                (> tmp.14 bar.3.5))
              (if (< bat.7.6 bat.0.4)
                  (begin
                    (set! rax foobar.4.8)
                    (jump tmp-ra.10 rbp rax))
                  (begin
                    (set! rax bat.7.6)
                    (jump tmp-ra.10 rbp rax)))
              (if (>= bat.0.4 1408489810)
                  (begin
                    (set! rax foobar.4.8)
                    (jump tmp-ra.10 rbp rax))
                  (begin
                    (set! rax bat.7.6)
                    (jump tmp-ra.10 rbp rax))))))
      (begin
        (set! tmp-ra.11 r15)
        (set! tmp.15 977777990)
        (set! tmp.15 (* tmp.15 900224161))
        (set! rax tmp.15)
        (jump tmp-ra.11 rbp rax))))

  (check-by-interp
   '(module ((locals (tmp-ra.11)) (conflicts ((tmp-ra.11 (rdi rbp)) (rbp (r15 rdi tmp-ra.11))
                                                                    (rdi (r15 rbp tmp-ra.11))
                                                                    (r15 (rbp rdi))))
                                  (assignment ()))
            (define L.x.0.1
              ((locals (foobar.2.1 bar.5.2 tmp.12))
               (conflicts ((tmp.12 (rbp tmp-ra.8))
                           (bar.5.2 (rbp tmp-ra.8))
                           (foobar.2.1 (rbp tmp-ra.8))
                           (tmp-ra.8 (rbp tmp.12 bar.5.2 foobar.2.1 rax rdi))
                           (rdi (r15 rbp tmp-ra.8))
                           (rbp (tmp-ra.8 tmp.12 bar.5.2 foobar.2.1 rax r15 rdi))
                           (r15 (rbp rdi))
                           (rax (rbp tmp-ra.8))))
               (assignment ((tmp-ra.8 fv0))))
              (begin
                (set! tmp-ra.8 r15)
                (if (begin
                      (set! tmp.12 0)
                      (<= tmp.12 1773437967))
                    (begin
                      (begin
                        (set! rbp (- rbp 8))
                        (return-point L.rp.4
                                      (begin
                                        (set! rdi 1456910402)
                                        (set! r15 L.rp.4)
                                        (jump L.tmp.2.3 rbp r15 rdi)))
                        (set! rbp (+ rbp 8)))
                      (set! foobar.2.1 rax)
                      (set! bar.5.2 -9223372036854775808)
                      (set! rax 1)
                      (jump tmp-ra.8 rbp rax))
                    (begin
                      (set! rdi -9223372036854775808)
                      (set! r15 tmp-ra.8)
                      (jump L.tmp.2.3 rbp r15 rdi)))))
      (define L.fn.1.2
        ((locals (bat.1.3 foo.9.4 foobar.3.5 bat.6.6 tmp-ra.9))
         (conflicts ((tmp-ra.9 (bat.1.3 foo.9.4 foobar.3.5 bat.6.6 rbp rcx rdx rsi rdi))
                     (bat.6.6 (rbp tmp-ra.9 rcx rdx rsi))
                     (foobar.3.5 (rbp tmp-ra.9 rcx rdx))
                     (foo.9.4 (bat.1.3 rbp tmp-ra.9 rcx))
                     (bat.1.3 (rbp tmp-ra.9 foo.9.4))
                     (rdi (r15 rbp tmp-ra.9))
                     (rsi (bat.6.6 tmp-ra.9))
                     (rdx (foobar.3.5 bat.6.6 tmp-ra.9))
                     (rcx (foo.9.4 foobar.3.5 bat.6.6 tmp-ra.9))
                     (rbp (r15 rdi bat.1.3 foo.9.4 foobar.3.5 bat.6.6 tmp-ra.9))
                     (r15 (rbp rdi))))
         (assignment ()))
        (begin
          (set! tmp-ra.9 r15)
          (set! bat.6.6 rdi)
          (set! foobar.3.5 rsi)
          (set! foo.9.4 rdx)
          (set! bat.1.3 rcx)
          (set! rdi foo.9.4)
          (set! r15 tmp-ra.9)
          (jump L.tmp.2.3 rbp r15 rdi)))
      (define L.tmp.2.3
        ((locals (bat.1.7 tmp-ra.10))
         (conflicts ((tmp-ra.10 (rax bat.1.7 rbp rdi)) (bat.1.7 (rbp tmp-ra.10))
                                                       (rdi (tmp-ra.10))
                                                       (rbp (rax bat.1.7 tmp-ra.10))
                                                       (rax (rbp tmp-ra.10))))
         (assignment ()))
        (begin
          (set! tmp-ra.10 r15)
          (set! bat.1.7 rdi)
          (set! rax bat.1.7)
          (jump tmp-ra.10 rbp rax)))
      (begin
        (set! tmp-ra.11 r15)
        (set! rdi 0)
        (set! r15 tmp-ra.11)
        (jump L.tmp.2.3 rbp r15 rdi))))

  (check-by-interp
   '(module ((locals (foo.1.10 tmp-ra.12))
             (conflicts ((tmp-ra.12 (rax foo.1.10 rbp)) (foo.1.10 (rbp tmp-ra.12))
                                                        (rbp (rax foo.1.10 tmp-ra.12))
                                                        (rax (rbp tmp-ra.12))))
             (assignment ()))
            (define L.func.0.1
              ((locals (bat.6.7 bat.5.2
                                foobar.9.3
                                foo.1.4
                                foobar.2.5
                                bar.0.6
                                foo.1.9
                                foobar.8.1
                                tmp-ra.11
                                foo.1.8))
               (conflicts ((foo.1.8 (rbp tmp-ra.11))
                           (tmp-ra.11 (bat.6.7 foobar.8.1
                                               bat.5.2
                                               foobar.9.3
                                               foo.1.4
                                               foobar.2.5
                                               bar.0.6
                                               rbp
                                               r9
                                               r8
                                               rcx
                                               rdx
                                               rsi
                                               rdi
                                               foo.1.8
                                               rax
                                               foo.1.9))
                           (foobar.8.1 (bat.6.7 rbp tmp-ra.11 foo.1.9))
                           (foo.1.9 (rbp tmp-ra.11 foobar.8.1))
                           (bar.0.6 (rbp tmp-ra.11 r9 r8 rcx rdx rsi))
                           (foobar.2.5 (rbp tmp-ra.11 r9 r8 rcx rdx))
                           (foo.1.4 (rbp tmp-ra.11 r9 r8 rcx))
                           (foobar.9.3 (rbp tmp-ra.11 r9 r8))
                           (bat.5.2 (rbp tmp-ra.11 r9))
                           (bat.6.7 (rbp tmp-ra.11 foobar.8.1))
                           (rbp (bat.6.7 foobar.8.1
                                         bat.5.2
                                         foobar.9.3
                                         foo.1.4
                                         foobar.2.5
                                         bar.0.6
                                         tmp-ra.11
                                         foo.1.8
                                         rax
                                         foo.1.9))
                           (rax (rbp tmp-ra.11))
                           (rdi (tmp-ra.11))
                           (rsi (bar.0.6 tmp-ra.11))
                           (rdx (foobar.2.5 bar.0.6 tmp-ra.11))
                           (rcx (foo.1.4 foobar.2.5 bar.0.6 tmp-ra.11))
                           (r8 (foobar.9.3 foo.1.4 foobar.2.5 bar.0.6 tmp-ra.11))
                           (r9 (bat.5.2 foobar.9.3 foo.1.4 foobar.2.5 bar.0.6 tmp-ra.11))))
               (assignment ()))
              (begin
                (set! tmp-ra.11 r15)
                (set! bar.0.6 rdi)
                (set! foobar.2.5 rsi)
                (set! foo.1.4 rdx)
                (set! foobar.9.3 rcx)
                (set! bat.5.2 r8)
                (set! foobar.8.1 r9)
                (set! bat.6.7 -951184591)
                (if (false)
                    (begin
                      (set! foo.1.8 -9223372036854775808)
                      (set! rax foo.1.8)
                      (jump tmp-ra.11 rbp rax))
                    (begin
                      (set! foo.1.9 310790521)
                      (set! rax foobar.8.1)
                      (jump tmp-ra.11 rbp rax)))))
      (begin
        (set! tmp-ra.12 r15)
        (set! foo.1.10 -1379426851)
        (set! rax 488563830)
        (jump tmp-ra.12 rbp rax))))
  (check-by-interp
   '(module ((locals (tmp.10 tmp-ra.8 foobar.4.6 foo.5.5))
             (conflicts ((foo.5.5 (rbp tmp-ra.8)) (foobar.4.6 (rbp tmp-ra.8))
                                                  (tmp-ra.8 (foo.5.5 rbp foobar.4.6 rax tmp.10))
                                                  (tmp.10 (rbp tmp-ra.8))
                                                  (rbp (foo.5.5 tmp-ra.8 foobar.4.6 rax tmp.10))
                                                  (rax (rbp tmp-ra.8))))
             (assignment ()))
            (define L.func.0.1
              ((locals (foo.5.4 tmp-ra.7 ball.0.1 foo.5.2 ball.2.3 tmp.9))
               (conflicts
                ((tmp.9 (rbp tmp-ra.7 foo.5.2 ball.2.3 ball.0.1))
                 (ball.2.3 (ball.0.1 foo.5.2 rbp tmp-ra.7 rdx rsi tmp.9))
                 (foo.5.2 (ball.0.1 rbp tmp-ra.7 ball.2.3 tmp.9 rsi rdx))
                 (ball.0.1 (rbp tmp-ra.7 foo.5.2 ball.2.3 tmp.9))
                 (tmp-ra.7 (ball.0.1 foo.5.2 ball.2.3 rbp tmp.9 rax foo.5.4 rdi rsi rdx))
                 (foo.5.4 (rbp tmp-ra.7))
                 (rdx (ball.2.3 r15 rdi rsi rbp tmp-ra.7 foo.5.2))
                 (rbp (ball.0.1 foo.5.2 ball.2.3 tmp-ra.7 tmp.9 rax foo.5.4 r15 rdi rsi rdx))
                 (rsi (ball.2.3 foo.5.2 r15 rdi rbp rdx tmp-ra.7))
                 (rdi (r15 rbp rsi rdx tmp-ra.7))
                 (r15 (rbp rdi rsi rdx))
                 (rax (rbp tmp-ra.7))))
               (assignment ()))
              (begin
                (set! tmp-ra.7 r15)
                (set! ball.2.3 rdi)
                (set! foo.5.2 rsi)
                (set! ball.0.1 rdx)
                (if (if (begin
                          (set! tmp.9 0)
                          (= tmp.9 ball.2.3))
                        (false)
                        (if (<= ball.0.1 -483103791)
                            (= foo.5.2 ball.2.3)
                            (= ball.2.3 foo.5.2)))
                    (begin
                      (set! rdx 1)
                      (set! rsi 1)
                      (set! rdi foo.5.2)
                      (set! r15 tmp-ra.7)
                      (jump L.func.0.1 rbp r15 rdi rsi rdx))
                    (if (true)
                        (begin
                          (set! foo.5.4 ball.2.3)
                          (set! rax foo.5.4)
                          (jump tmp-ra.7 rbp rax))
                        (begin
                          (set! rdx 1)
                          (set! rsi foo.5.2)
                          (set! rdi foo.5.2)
                          (set! r15 tmp-ra.7)
                          (jump L.func.0.1 rbp r15 rdi rsi rdx))))))
      (begin
        (set! tmp-ra.8 r15)
        (set! foo.5.5 -1766715399)
        (if (not (not (< foo.5.5 foo.5.5)))
            (begin
              (if (< foo.5.5 0)
                  (set! foobar.4.6 9223372036854775807)
                  (set! foobar.4.6 foo.5.5))
              (set! rax -1170116362)
              (jump tmp-ra.8 rbp rax))
            (begin
              (set! tmp.10 0)
              (set! tmp.10 (* tmp.10 0))
              (set! rax tmp.10)
              (jump tmp-ra.8 rbp rax))))))

  (check-by-interp '(module ((locals (bat.1.8 tmp-ra.12))
                             (conflicts ((tmp-ra.12 (rax bat.1.8 rbp)) (bat.1.8 (rbp tmp-ra.12))
                                                                       (rbp (rax bat.1.8 tmp-ra.12))
                                                                       (rax (rbp tmp-ra.12))))
                             (assignment ()))
                            (define L.tmp.0.1
                              ((locals (bar.9.1 bar.4.2 bar.0.3 tmp-ra.9))
                               (conflicts ((tmp-ra.9 (bar.9.1 bar.4.2 bar.0.3 rbp rdx rsi rdi))
                                           (bar.0.3 (rbp tmp-ra.9 rdx rsi))
                                           (bar.4.2 (rbp tmp-ra.9 rdx))
                                           (bar.9.1 (rbp tmp-ra.9))
                                           (rdi (r15 rbp tmp-ra.9))
                                           (rsi (bar.0.3 tmp-ra.9))
                                           (rdx (bar.4.2 bar.0.3 tmp-ra.9))
                                           (rbp (r15 rdi bar.9.1 bar.4.2 bar.0.3 tmp-ra.9))
                                           (r15 (rbp rdi))))
                               (assignment ()))
                              (begin
                                (set! tmp-ra.9 r15)
                                (set! bar.0.3 rdi)
                                (set! bar.4.2 rsi)
                                (set! bar.9.1 rdx)
                                (set! rdi 9223372036854775807)
                                (set! r15 tmp-ra.9)
                                (jump L.fn.1.2 rbp r15 rdi)))
                      (define L.fn.1.2
                        ((locals (tmp.14 bar.9.4 tmp-ra.10 tmp.13))
                         (conflicts ((tmp.13 (rbp tmp-ra.10 bar.9.4))
                                     (tmp-ra.10 (bar.9.4 rbp tmp.13 tmp.14 rdi rsi rdx rax))
                                     (bar.9.4 (rbp tmp-ra.10 tmp.13 rsi rdx tmp.14))
                                     (tmp.14 (rbp tmp-ra.10 bar.9.4))
                                     (rax (rbp tmp-ra.10))
                                     (rbp (bar.9.4 tmp-ra.10 tmp.13 tmp.14 r15 rdi rsi rdx rax))
                                     (rdx (bar.9.4 r15 rdi rsi rbp tmp-ra.10))
                                     (rsi (bar.9.4 r15 rdi rbp rdx tmp-ra.10))
                                     (rdi (r15 rbp rsi rdx tmp-ra.10))
                                     (r15 (rbp rdi rsi rdx))))
                         (assignment ()))
                        (begin
                          (set! tmp-ra.10 r15)
                          (set! bar.9.4 rdi)
                          (if (begin
                                (set! tmp.13 1)
                                (> tmp.13 1))
                              (begin
                                (set! rdx -9223372036854775808)
                                (set! rsi -9223372036854775808)
                                (set! rdi bar.9.4)
                                (set! r15 tmp-ra.10)
                                (jump L.x.2.3 rbp r15 rdi rsi rdx))
                              (if (if (> bar.9.4 9223372036854775807)
                                      (<= bar.9.4 2069349298)
                                      (begin
                                        (set! tmp.14 327435684)
                                        (= tmp.14 bar.9.4)))
                                  (begin
                                    (set! rdx bar.9.4)
                                    (set! rsi bar.9.4)
                                    (set! rdi 937688474)
                                    (set! r15 tmp-ra.10)
                                    (jump L.x.2.3 rbp r15 rdi rsi rdx))
                                  (begin
                                    (set! rax -9223372036854775808)
                                    (jump tmp-ra.10 rbp rax))))))
                      (define L.x.2.3
                        ((locals (bar.4.5 ball.8.6 foobar.6.7 tmp-ra.11))
                         (conflicts ((tmp-ra.11 (bar.4.5 ball.8.6 foobar.6.7 rbp rdx rsi rdi))
                                     (foobar.6.7 (bar.4.5 ball.8.6 rbp tmp-ra.11 rdx rsi))
                                     (ball.8.6 (rbp tmp-ra.11 foobar.6.7 rdx))
                                     (bar.4.5 (rbp tmp-ra.11 foobar.6.7))
                                     (rdi (r15 rbp rsi rdx tmp-ra.11))
                                     (rsi (r15 rdi rbp rdx foobar.6.7 tmp-ra.11))
                                     (rdx (r15 rdi rsi rbp ball.8.6 foobar.6.7 tmp-ra.11))
                                     (rbp (r15 rdi rsi rdx bar.4.5 ball.8.6 foobar.6.7 tmp-ra.11))
                                     (r15 (rbp rdi rsi rdx))))
                         (assignment ()))
                        (begin
                          (set! tmp-ra.11 r15)
                          (set! foobar.6.7 rdi)
                          (set! ball.8.6 rsi)
                          (set! bar.4.5 rdx)
                          (set! rdx bar.4.5)
                          (set! rsi -845528888)
                          (set! rdi foobar.6.7)
                          (set! r15 tmp-ra.11)
                          (jump L.x.2.3 rbp r15 rdi rsi rdx)))
                      (begin
                        (set! tmp-ra.12 r15)
                        (set! bat.1.8 0)
                        (set! rax bat.1.8)
                        (jump tmp-ra.12 rbp rax))))
  (check-by-interp
   '(module ((locals (ball.3.17 tmp.24 tmp-ra.21))
             (conflicts ((tmp-ra.21 (rdi rsi rdx rcx r8 ball.3.17 tmp.24 rbp))
                         (tmp.24 (rbp tmp-ra.21))
                         (ball.3.17 (rdx rcx rbp tmp-ra.21))
                         (rbp (r15 rdi rsi rdx rcx r8 ball.3.17 tmp.24 tmp-ra.21))
                         (r8 (r15 rdi rsi rdx rcx rbp tmp-ra.21))
                         (rcx (r15 rdi rsi rdx rbp r8 tmp-ra.21 ball.3.17))
                         (rdx (r15 rdi rsi rbp rcx r8 tmp-ra.21 ball.3.17))
                         (rsi (r15 rdi rbp rdx rcx r8 tmp-ra.21))
                         (rdi (r15 rbp rsi rdx rcx r8 tmp-ra.21))
                         (r15 (rbp rdi rsi rdx rcx r8))))
             (assignment ()))
            (define L.x.0.1
              ((locals (ball.7.2 bar.5.4
                                 tmp.23
                                 tmp.22
                                 foobar.6.3
                                 bar.9.6
                                 tmp-ra.18
                                 foobar.4.5
                                 foobar.2.7
                                 bat.1.1))
               (conflicts ((bat.1.1 (rbp tmp-ra.18 foobar.4.5 foobar.6.3 bar.9.6 tmp.22))
                           (foobar.2.7 (rbp tmp-ra.18 foobar.4.5))
                           (foobar.4.5 (bat.1.1 ball.7.2
                                                foobar.6.3
                                                bar.5.4
                                                rbp
                                                tmp-ra.18
                                                r8
                                                rcx
                                                rdx
                                                rsi
                                                bar.9.6
                                                tmp.22
                                                foobar.2.7))
                           (tmp-ra.18 (bat.1.1 ball.7.2
                                               foobar.6.3
                                               bar.5.4
                                               foobar.4.5
                                               rbp
                                               r8
                                               rcx
                                               rdx
                                               bar.9.6
                                               tmp.22
                                               rdi
                                               rsi
                                               foobar.2.7
                                               tmp.23
                                               rax))
                           (bar.9.6 (rbp tmp-ra.18 bat.1.1 foobar.4.5))
                           (foobar.6.3 (bat.1.1 ball.7.2 rbp tmp-ra.18 foobar.4.5 r8 rcx tmp.22))
                           (tmp.22 (rbp tmp-ra.18 bat.1.1 foobar.4.5 foobar.6.3))
                           (tmp.23 (rbp tmp-ra.18))
                           (bar.5.4 (rbp tmp-ra.18 foobar.4.5 r8 rcx rdx))
                           (ball.7.2 (rbp tmp-ra.18 foobar.4.5 foobar.6.3 r8))
                           (rax (rbp tmp-ra.18))
                           (rbp (bat.1.1 ball.7.2
                                         foobar.6.3
                                         bar.5.4
                                         foobar.4.5
                                         tmp-ra.18
                                         bar.9.6
                                         tmp.22
                                         r15
                                         rdi
                                         rsi
                                         foobar.2.7
                                         tmp.23
                                         rax))
                           (rsi (foobar.4.5 r15 rdi rbp tmp-ra.18))
                           (rdi (r15 rbp rsi tmp-ra.18))
                           (r15 (rbp rdi rsi))
                           (rdx (bar.5.4 foobar.4.5 tmp-ra.18))
                           (rcx (foobar.6.3 bar.5.4 foobar.4.5 tmp-ra.18))
                           (r8 (ball.7.2 foobar.6.3 bar.5.4 foobar.4.5 tmp-ra.18))))
               (assignment ()))
              (begin
                (set! tmp-ra.18 r15)
                (set! foobar.4.5 rdi)
                (set! bar.5.4 rsi)
                (set! foobar.6.3 rdx)
                (set! ball.7.2 rcx)
                (set! bat.1.1 r8)
                (if (false)
                    (if (begin
                          (set! bar.9.6 foobar.6.3)
                          (begin
                            (set! tmp.22 0)
                            (< tmp.22 foobar.6.3)))
                        (begin
                          (set! rsi -9223372036854775808)
                          (set! rdi 0)
                          (set! r15 tmp-ra.18)
                          (jump L.x.1.2 rbp r15 rdi rsi))
                        (begin
                          (set! foobar.2.7 bat.1.1)
                          (set! rax foobar.4.5)
                          (jump tmp-ra.18 rbp rax)))
                    (if (true)
                        (if (begin
                              (set! tmp.23 -9223372036854775808)
                              (!= tmp.23 1))
                            (begin
                              (set! rax 0)
                              (jump tmp-ra.18 rbp rax))
                            (begin
                              (set! rax 849007740)
                              (jump tmp-ra.18 rbp rax)))
                        (begin
                          (set! rax foobar.4.5)
                          (jump tmp-ra.18 rbp rax))))))
      (define L.x.1.2
        ((locals (foobar.4.10 bar.0.8 foobar.6.9 tmp-ra.19))
         (conflicts ((tmp-ra.19 (rdx rcx r8 foobar.4.10 bar.0.8 foobar.6.9 rbp rsi rdi))
                     (foobar.6.9 (rdx rcx r8 foobar.4.10 bar.0.8 rbp tmp-ra.19 rsi))
                     (bar.0.8 (rbp tmp-ra.19 foobar.6.9))
                     (foobar.4.10 (rcx r8 rbp tmp-ra.19 foobar.6.9))
                     (rdi (r15 rbp rsi rdx rcx r8 tmp-ra.19))
                     (rsi (r15 rdi rbp rdx rcx r8 foobar.6.9 tmp-ra.19))
                     (rbp (r15 rdi rsi rdx rcx r8 foobar.4.10 bar.0.8 foobar.6.9 tmp-ra.19))
                     (r8 (r15 rdi rsi rdx rcx rbp tmp-ra.19 foobar.6.9 foobar.4.10))
                     (rcx (r15 rdi rsi rdx rbp r8 tmp-ra.19 foobar.6.9 foobar.4.10))
                     (rdx (r15 rdi rsi rbp rcx r8 tmp-ra.19 foobar.6.9))
                     (r15 (rbp rdi rsi rdx rcx r8))))
         (assignment ()))
        (begin
          (set! tmp-ra.19 r15)
          (set! foobar.6.9 rdi)
          (set! bar.0.8 rsi)
          (set! foobar.4.10 bar.0.8)
          (set! r8 9223372036854775807)
          (set! rcx 0)
          (set! rdx foobar.4.10)
          (set! rsi 0)
          (set! rdi foobar.6.9)
          (set! r15 tmp-ra.19)
          (jump L.x.0.1 rbp r15 rdi rsi rdx rcx r8)))
      (define L.x.2.3
        ((locals (bar.8.16 bar.5.11 ball.3.12 bar.8.13 foobar.4.14 foobar.2.15))
         (conflicts
          ((tmp-ra.20
            (bar.8.16 rax bar.5.11 ball.3.12 bar.8.13 foobar.4.14 foobar.2.15 rbp r8 rcx rdx rsi rdi))
           (foobar.2.15 (rbp tmp-ra.20 r8 rcx rdx rsi))
           (foobar.4.14 (rbp tmp-ra.20 r8 rcx rdx))
           (bar.8.13 (rbp tmp-ra.20 r8 rcx))
           (ball.3.12 (rbp tmp-ra.20 r8))
           (bar.5.11 (rbp tmp-ra.20))
           (bar.8.16 (rbp tmp-ra.20))
           (rdi (r15 rbp rsi tmp-ra.20))
           (rsi (r15 rdi rbp foobar.2.15 tmp-ra.20))
           (rdx (foobar.4.14 foobar.2.15 tmp-ra.20))
           (rcx (bar.8.13 foobar.4.14 foobar.2.15 tmp-ra.20))
           (r8 (ball.3.12 bar.8.13 foobar.4.14 foobar.2.15 tmp-ra.20))
           (rbp
            (bar.8.16 r15 rdi rsi rax bar.5.11 ball.3.12 bar.8.13 foobar.4.14 foobar.2.15 tmp-ra.20))
           (rax (rbp tmp-ra.20))
           (r15 (rbp rdi rsi))))
         (assignment ((tmp-ra.20 fv0))))
        (begin
          (set! tmp-ra.20 r15)
          (set! foobar.2.15 rdi)
          (set! foobar.4.14 rsi)
          (set! bar.8.13 rdx)
          (set! ball.3.12 rcx)
          (set! bar.5.11 r8)
          (begin
            (set! rbp (- rbp 8))
            (return-point L.rp.4
                          (begin
                            (set! rsi bar.5.11)
                            (set! rdi bar.5.11)
                            (set! r15 L.rp.4)
                            (jump L.x.1.2 rbp r15 rdi rsi)))
            (set! rbp (+ rbp 8)))
          (set! bar.8.16 rax)
          (set! rsi 1)
          (set! rdi -1927041153)
          (set! r15 tmp-ra.20)
          (jump L.x.1.2 rbp r15 rdi rsi)))
      (begin
        (set! tmp-ra.21 r15)
        (set! tmp.24 1)
        (set! tmp.24 (* tmp.24 -394936001))
        (set! ball.3.17 tmp.24)
        (set! r8 ball.3.17)
        (set! rcx -9223372036854775808)
        (set! rdx 0)
        (set! rsi ball.3.17)
        (set! rdi ball.3.17)
        (set! r15 tmp-ra.21)
        (jump L.x.0.1 rbp r15 rdi rsi rdx rcx r8))))

  (check-by-interp
   '(module ((locals (bar.5.10 bat.3.8 bar.7.9))
             (conflicts ((bar.7.9 (rbp tmp-ra.14))
                         (bat.3.8 (rbp tmp-ra.14))
                         (tmp-ra.14 (rbp bar.7.9 bat.3.8 rax rdi bar.5.10))
                         (bar.5.10 (rbp tmp-ra.14))
                         (rbp (tmp-ra.14 bar.7.9 bat.3.8 rax r15 rdi bar.5.10))
                         (rdi (r15 rbp tmp-ra.14))
                         (r15 (rbp rdi))
                         (rax (rbp tmp-ra.14))))
             (assignment ((tmp-ra.14 fv0))))
            (define L.proc.0.1
              ((locals (tmp.15 bar.5.3 tmp.16 bar.2.4 ball.1.1 tmp-ra.11 bar.6.5 bar.2.2 tmp.17))
               (conflicts
                ((tmp.17 (rbp tmp-ra.11 bar.2.2))
                 (bar.2.2 (rbp tmp-ra.11 tmp.17 bar.6.5))
                 (bar.6.5 (rbp tmp-ra.11 bar.2.2))
                 (tmp-ra.11
                  (bar.5.3 tmp.15 tmp.16 bar.2.4 bar.2.2 ball.1.1 rbp tmp.17 rax bar.6.5 rdi))
                 (ball.1.1 (bar.5.3 tmp.15 rbp tmp-ra.11))
                 (bar.2.4 (rbp tmp-ra.11))
                 (tmp.16 (rbp tmp-ra.11))
                 (bar.5.3 (rbp tmp-ra.11 ball.1.1))
                 (tmp.15 (rbp tmp-ra.11 ball.1.1))
                 (rdi (r15 rbp tmp-ra.11))
                 (rbp (bar.5.3 tmp.15
                               tmp.16
                               bar.2.4
                               bar.2.2
                               ball.1.1
                               tmp-ra.11
                               tmp.17
                               rax
                               bar.6.5
                               r15
                               rdi))
                 (r15 (rbp rdi))
                 (rax (rbp tmp-ra.11))))
               (assignment ()))
              (begin
                (set! tmp-ra.11 r15)
                (set! ball.1.1 rdi)
                (if (begin
                      (set! bar.5.3 1541307282)
                      (begin
                        (set! tmp.15 9223372036854775807)
                        (= tmp.15 -194099637)))
                    (begin
                      (set! tmp.16 ball.1.1)
                      (set! tmp.16 (- tmp.16 -1702731989))
                      (set! bar.2.2 tmp.16))
                    (begin
                      (set! bar.2.4 ball.1.1)
                      (set! bar.2.2 ball.1.1)))
                (if (not (begin
                           (set! tmp.17 -9223372036854775808)
                           (= tmp.17 bar.2.2)))
                    (begin
                      (set! bar.6.5 1)
                      (set! rax bar.2.2)
                      (jump tmp-ra.11 rbp rax))
                    (begin
                      (set! rdi 0)
                      (set! r15 tmp-ra.11)
                      (jump L.proc.0.1 rbp r15 rdi)))))
      (define L.fn.1.2
        ((locals (tmp.18 tmp-ra.12)) (conflicts ((tmp-ra.12 (rax tmp.18 rbp)) (tmp.18 (rbp tmp-ra.12))
                                                                              (rbp (rax tmp.18
                                                                                        tmp-ra.12))
                                                                              (rax (rbp tmp-ra.12))))
                                     (assignment ()))
        (begin
          (set! tmp-ra.12 r15)
          (set! tmp.18 9223372036854775807)
          (set! tmp.18 (+ tmp.18 1))
          (set! rax tmp.18)
          (jump tmp-ra.12 rbp rax)))
      (define L.fn.2.3
        ((locals (bar.6.7 tmp.19 bat.9.6 tmp-ra.13))
         (conflicts ((tmp-ra.13 (bar.6.7 tmp.19 bat.9.6 rbp rdi))
                     (bat.9.6 (rbp tmp-ra.13))
                     (tmp.19 (rbp tmp-ra.13))
                     (bar.6.7 (rbp tmp-ra.13))
                     (rdi (tmp-ra.13))
                     (rbp (r15 bar.6.7 tmp.19 bat.9.6 tmp-ra.13))
                     (r15 (rbp))))
         (assignment ()))
        (begin
          (set! tmp-ra.13 r15)
          (set! bat.9.6 rdi)
          (set! tmp.19 1)
          (set! tmp.19 (* tmp.19 0))
          (set! bar.6.7 tmp.19)
          (set! r15 tmp-ra.13)
          (jump L.fn.1.2 rbp r15)))
      (begin
        (set! tmp-ra.14 r15)
        (if (true)
            (begin
              (begin
                (set! rbp (- rbp 8))
                (return-point L.rp.4
                              (begin
                                (set! rdi 1)
                                (set! r15 L.rp.4)
                                (jump L.fn.2.3 rbp r15 rdi)))
                (set! rbp (+ rbp 8)))
              (set! bat.3.8 rax)
              (set! bar.7.9 bat.3.8)
              (set! rax 1)
              (jump tmp-ra.14 rbp rax))
            (begin
              (set! bar.5.10 -1579827217)
              (set! rdi bar.5.10)
              (set! r15 tmp-ra.14)
              (jump L.fn.2.3 rbp r15 rdi))))))
  (check-by-interp
   '(module ((locals (tmp.26 tmp-ra.20))
             (conflicts ((tmp-ra.20 (rax tmp.26 rbp)) (tmp.26 (rbp tmp-ra.20))
                                                      (rbp (rax tmp.26 tmp-ra.20))
                                                      (rax (rbp tmp-ra.20))))
             (assignment ()))
            (define L.x.0.1
              ((locals (tmp.21 foobar.7.7 ball.4.1 foo.9.3 foobar.5.4 bar.6.5 tmp.23 bat.3.6 tmp.22))
               (conflicts
                ((foobar.7.2
                  (bat.3.6 tmp.21 foobar.7.7 rax ball.4.1 rbp tmp-ra.17 foo.9.3 r8 tmp.22 tmp.23))
                 (tmp.22 (rbp tmp-ra.17 foobar.7.2))
                 (tmp-ra.17 (bat.3.6 tmp.21
                                     foobar.7.7
                                     ball.4.1
                                     foobar.7.2
                                     foo.9.3
                                     foobar.5.4
                                     bar.6.5
                                     rbp
                                     r8
                                     rcx
                                     rdx
                                     rsi
                                     rdi
                                     tmp.22
                                     tmp.23
                                     rax))
                 (bat.3.6 (rbp tmp-ra.17 foobar.7.2 tmp.23))
                 (tmp.23 (rbp tmp-ra.17 foobar.7.2 bat.3.6))
                 (bar.6.5 (rbp tmp-ra.17 r8 rcx rdx rsi))
                 (foobar.5.4 (rbp tmp-ra.17 r8 rcx rdx))
                 (foo.9.3 (ball.4.1 foobar.7.2 rbp tmp-ra.17 r8 rcx))
                 (ball.4.1 (rcx r8 rbp tmp-ra.17 foobar.7.2 foo.9.3))
                 (foobar.7.7 (rbp tmp-ra.17 foobar.7.2))
                 (tmp.21 (rbp tmp-ra.17 foobar.7.2))
                 (rax (foobar.7.2 rbp tmp-ra.17))
                 (rbp (bat.3.6 tmp.21
                               foobar.7.7
                               r15
                               rdi
                               rsi
                               rdx
                               rcx
                               r8
                               ball.4.1
                               foobar.7.2
                               foo.9.3
                               foobar.5.4
                               bar.6.5
                               tmp-ra.17
                               tmp.22
                               tmp.23
                               rax))
                 (rdi (r15 rbp rsi rdx rcx r8 tmp-ra.17))
                 (rsi (r15 rdi rbp rdx rcx r8 bar.6.5 tmp-ra.17))
                 (rdx (r15 rdi rsi rbp rcx r8 foobar.5.4 bar.6.5 tmp-ra.17))
                 (rcx (r15 rdi rsi rdx rbp r8 ball.4.1 foo.9.3 foobar.5.4 bar.6.5 tmp-ra.17))
                 (r8
                  (r15 rdi rsi rdx rcx rbp ball.4.1 foobar.7.2 foo.9.3 foobar.5.4 bar.6.5 tmp-ra.17))
                 (r15 (rbp rdi rsi rdx rcx r8))))
               (assignment ((tmp-ra.17 fv0) (foobar.7.2 fv1))))
              (begin
                (set! tmp-ra.17 r15)
                (set! bar.6.5 rdi)
                (set! foobar.5.4 rsi)
                (set! foo.9.3 rdx)
                (set! foobar.7.2 rcx)
                (set! ball.4.1 r8)
                (begin
                  (set! rbp (- rbp 16))
                  (return-point L.rp.4
                                (begin
                                  (set! r8 1)
                                  (set! rcx foo.9.3)
                                  (set! rdx ball.4.1)
                                  (set! rsi ball.4.1)
                                  (set! rdi 0)
                                  (set! r15 L.rp.4)
                                  (jump L.x.0.1 rbp r15 rdi rsi rdx rcx r8)))
                  (set! rbp (+ rbp 16)))
                (set! foobar.7.7 rax)
                (set! tmp.21 foobar.7.7)
                (set! tmp.21 (- tmp.21 foobar.7.7))
                (set! bat.3.6 tmp.21)
                (if (true)
                    (begin
                      (set! tmp.22 -9223372036854775808)
                      (set! tmp.22 (* tmp.22 foobar.7.2))
                      (set! rax tmp.22)
                      (jump tmp-ra.17 rbp rax))
                    (if (begin
                          (set! tmp.23 -9223372036854775808)
                          (!= tmp.23 bat.3.6))
                        (begin
                          (set! rax foobar.7.2)
                          (jump tmp-ra.17 rbp rax))
                        (begin
                          (set! rax 0)
                          (jump tmp-ra.17 rbp rax))))))
      (define L.fn.1.2
        ((locals
          (foobar.7.8 foo.2.12 ball.4.9 foo.8.10 ball.0.14 tmp-ra.18 foobar.1.11 foo.8.13 tmp.24))
         (conflicts ((tmp.24 (rbp tmp-ra.18 foobar.1.11))
                     (foo.8.13 (rbp tmp-ra.18))
                     (foobar.1.11 (foobar.7.8 ball.4.9 foo.8.10 rbp tmp-ra.18 r8 rcx rdx tmp.24))
                     (tmp-ra.18 (foobar.7.8 ball.4.9
                                            foo.8.10
                                            foobar.1.11
                                            foo.2.12
                                            rbp
                                            r8
                                            rcx
                                            rdx
                                            rsi
                                            rdi
                                            tmp.24
                                            foo.8.13
                                            rax
                                            ball.0.14))
                     (ball.0.14 (rbp tmp-ra.18))
                     (foo.8.10 (foobar.7.8 ball.4.9 rbp tmp-ra.18 foobar.1.11 r8 rcx))
                     (ball.4.9 (foobar.7.8 rbp tmp-ra.18 foobar.1.11 foo.8.10 r8))
                     (foo.2.12 (rbp tmp-ra.18 r8 rcx rdx rsi))
                     (foobar.7.8 (rbp tmp-ra.18 foobar.1.11 foo.8.10 ball.4.9))
                     (rbp (foobar.7.8 ball.4.9
                                      foo.8.10
                                      foobar.1.11
                                      foo.2.12
                                      tmp-ra.18
                                      tmp.24
                                      foo.8.13
                                      rax
                                      ball.0.14))
                     (rax (rbp tmp-ra.18))
                     (rdi (tmp-ra.18))
                     (rsi (foo.2.12 tmp-ra.18))
                     (rdx (foobar.1.11 foo.2.12 tmp-ra.18))
                     (rcx (foo.8.10 foobar.1.11 foo.2.12 tmp-ra.18))
                     (r8 (ball.4.9 foo.8.10 foobar.1.11 foo.2.12 tmp-ra.18))))
         (assignment ()))
        (begin
          (set! tmp-ra.18 r15)
          (set! foo.2.12 rdi)
          (set! foobar.1.11 rsi)
          (set! foo.8.10 rdx)
          (set! ball.4.9 rcx)
          (set! foobar.7.8 r8)
          (if (false)
              (begin
                (if (begin
                      (set! tmp.24 -1658461695)
                      (!= tmp.24 9223372036854775807))
                    (set! foo.8.13 -9223372036854775808)
                    (set! foo.8.13 foobar.1.11))
                (set! rax 9223372036854775807)
                (jump tmp-ra.18 rbp rax))
              (if (false)
                  (if (= foo.8.10 1)
                      (begin
                        (set! rax ball.4.9)
                        (jump tmp-ra.18 rbp rax))
                      (begin
                        (set! rax 9223372036854775807)
                        (jump tmp-ra.18 rbp rax)))
                  (begin
                    (set! ball.0.14 foo.8.10)
                    (set! rax 1)
                    (jump tmp-ra.18 rbp rax))))))
      (define L.tmp.2.3
        ((locals (foo.8.16 tmp-ra.19 foobar.5.15 tmp.25))
         (conflicts ((tmp.25 (rbp tmp-ra.19 foobar.5.15))
                     (foobar.5.15 (rbp tmp-ra.19 tmp.25 rsi r8))
                     (tmp-ra.19 (foobar.5.15 foo.8.16 rbp tmp.25 rax rdi rsi rdx rcx r8))
                     (foo.8.16 (rbp tmp-ra.19))
                     (r8 (r15 rdi rsi rdx rcx rbp tmp-ra.19 foobar.5.15))
                     (rbp (foobar.5.15 foo.8.16 tmp-ra.19 tmp.25 rax r15 rdi rsi rdx rcx r8))
                     (rcx (r15 rdi rsi rdx rbp r8 tmp-ra.19))
                     (rdx (r15 rdi rsi rbp rcx r8 tmp-ra.19))
                     (rsi (r15 rdi rbp rdx rcx r8 tmp-ra.19 foobar.5.15))
                     (rdi (r15 rbp rsi rdx rcx r8 tmp-ra.19))
                     (r15 (rbp rdi rsi rdx rcx r8))
                     (rax (rbp tmp-ra.19))))
         (assignment ()))
        (begin
          (set! tmp-ra.19 r15)
          (set! foo.8.16 1)
          (set! foobar.5.15 foo.8.16)
          (if (if (begin
                    (set! tmp.25 9223372036854775807)
                    (> tmp.25 foobar.5.15))
                  (>= foobar.5.15 9223372036854775807)
                  (<= foobar.5.15 foobar.5.15))
              (if (> foobar.5.15 foobar.5.15)
                  (begin
                    (set! rax 1)
                    (jump tmp-ra.19 rbp rax))
                  (begin
                    (set! rax foobar.5.15)
                    (jump tmp-ra.19 rbp rax)))
              (begin
                (set! r8 9223372036854775807)
                (set! rcx foobar.5.15)
                (set! rdx foobar.5.15)
                (set! rsi -126978532)
                (set! rdi foobar.5.15)
                (set! r15 tmp-ra.19)
                (jump L.x.0.1 rbp r15 rdi rsi rdx rcx r8)))))
      (begin
        (set! tmp-ra.20 r15)
        (set! tmp.26 -1293429216)
        (set! tmp.26 (* tmp.26 880066208))
        (set! rax tmp.26)
        (jump tmp-ra.20 rbp rax))))
  (check-by-interp
   '(module ((locals (tmp.21 ball.3.13 tmp-ra.16))
             (conflicts ((tmp-ra.16 (rdi rsi rdx rcx r8 r9 tmp.21 ball.3.13 rbp))
                         (ball.3.13 (rdx r8 r9 rbp tmp-ra.16))
                         (tmp.21 (rbp tmp-ra.16))
                         (rbp (r15 rdi rsi rdx rcx r8 r9 tmp.21 ball.3.13 tmp-ra.16))
                         (r9 (r15 rdi rsi rdx rcx r8 rbp tmp-ra.16 ball.3.13))
                         (r8 (r15 rdi rsi rdx rcx rbp r9 tmp-ra.16 ball.3.13))
                         (rcx (r15 rdi rsi rdx rbp r8 r9 tmp-ra.16))
                         (rdx (r15 rdi rsi rbp rcx r8 r9 tmp-ra.16 ball.3.13))
                         (rsi (r15 rdi rbp rdx rcx r8 r9 tmp-ra.16))
                         (rdi (r15 rbp rsi rdx rcx r8 r9 tmp-ra.16))
                         (r15 (rbp rdi rsi rdx rcx r8 r9))))
             (assignment ()))
            (define L.proc.0.1
              ((locals (bar.0.4 ball.3.2
                                bar.4.6
                                tmp-ra.14
                                tmp.18
                                foobar.5.5
                                bar.0.7
                                ball.8.1
                                foo.7.3
                                tmp.17))
               (conflicts
                ((tmp.17 (rbp tmp-ra.14 bar.4.6 ball.8.1 foo.7.3 foobar.5.5 ball.3.2))
                 (foo.7.3 (ball.8.1 ball.3.2 rbp tmp-ra.14 bar.4.6 foobar.5.5 tmp.17 r8 r9))
                 (ball.8.1
                  (rbp tmp-ra.14 bar.4.6 foo.7.3 foobar.5.5 ball.3.2 tmp.17 tmp.18 rdx rcx r8 r9))
                 (bar.0.7 (rbp tmp-ra.14 foobar.5.5))
                 (foobar.5.5 (ball.8.1 ball.3.2
                                       foo.7.3
                                       bar.0.4
                                       rbp
                                       tmp-ra.14
                                       bar.4.6
                                       r9
                                       r8
                                       rcx
                                       rdx
                                       tmp.17
                                       bar.0.7))
                 (tmp.18 (rbp tmp-ra.14 bar.4.6 ball.8.1))
                 (tmp-ra.14 (ball.8.1 ball.3.2
                                      foo.7.3
                                      bar.0.4
                                      foobar.5.5
                                      bar.4.6
                                      rbp
                                      tmp.17
                                      tmp.18
                                      rax
                                      bar.0.7
                                      rdi
                                      rsi
                                      rdx
                                      rcx
                                      r8
                                      r9))
                 (bar.4.6 (ball.8.1 ball.3.2
                                    foo.7.3
                                    bar.0.4
                                    foobar.5.5
                                    rbp
                                    tmp-ra.14
                                    r9
                                    r8
                                    rcx
                                    rdx
                                    rsi
                                    tmp.17
                                    tmp.18))
                 (ball.3.2 (ball.8.1 rbp tmp-ra.14 bar.4.6 foo.7.3 foobar.5.5 tmp.17 r9))
                 (bar.0.4 (rbp tmp-ra.14 bar.4.6 foobar.5.5 r9 r8 rcx))
                 (r9 (bar.0.4 foobar.5.5
                              bar.4.6
                              r15
                              rdi
                              rsi
                              rdx
                              rcx
                              r8
                              rbp
                              tmp-ra.14
                              ball.8.1
                              foo.7.3
                              ball.3.2))
                 (rbp (ball.8.1 ball.3.2
                                foo.7.3
                                bar.0.4
                                foobar.5.5
                                bar.4.6
                                tmp-ra.14
                                tmp.17
                                tmp.18
                                rax
                                bar.0.7
                                r15
                                rdi
                                rsi
                                rdx
                                rcx
                                r8
                                r9))
                 (r8
                  (bar.0.4 foobar.5.5 bar.4.6 r15 rdi rsi rdx rcx rbp r9 tmp-ra.14 ball.8.1 foo.7.3))
                 (rcx (bar.0.4 foobar.5.5 bar.4.6 r15 rdi rsi rdx rbp r8 r9 tmp-ra.14 ball.8.1))
                 (rdx (foobar.5.5 bar.4.6 r15 rdi rsi rbp rcx r8 r9 tmp-ra.14 ball.8.1))
                 (rsi (bar.4.6 r15 rdi rbp rdx rcx r8 r9 tmp-ra.14))
                 (rdi (r15 rbp rsi rdx rcx r8 r9 tmp-ra.14))
                 (r15 (rbp rdi rsi rdx rcx r8 r9))
                 (rax (rbp tmp-ra.14))))
               (assignment ()))
              (begin
                (set! tmp-ra.14 r15)
                (set! bar.4.6 rdi)
                (set! foobar.5.5 rsi)
                (set! bar.0.4 rdx)
                (set! foo.7.3 rcx)
                (set! ball.3.2 r8)
                (set! ball.8.1 r9)
                (if (not (if (begin
                               (set! tmp.17 0)
                               (> tmp.17 701262944))
                             (!= foo.7.3 9223372036854775807)
                             (< ball.8.1 ball.8.1)))
                    (if (true)
                        (if (begin
                              (set! tmp.18 1779018832)
                              (= tmp.18 ball.8.1))
                            (begin
                              (set! rax -9223372036854775808)
                              (jump tmp-ra.14 rbp rax))
                            (begin
                              (set! rax bar.4.6)
                              (jump tmp-ra.14 rbp rax)))
                        (begin
                          (set! bar.0.7 foo.7.3)
                          (set! rax foobar.5.5)
                          (jump tmp-ra.14 rbp rax)))
                    (begin
                      (set! r9 bar.4.6)
                      (set! r8 ball.3.2)
                      (set! rcx foo.7.3)
                      (set! rdx 9223372036854775807)
                      (set! rsi ball.8.1)
                      (set! rdi 1)
                      (set! r15 tmp-ra.14)
                      (jump L.proc.0.1 rbp r15 rdi rsi rdx rcx r8 r9)))))
      (define L.proc.1.2
        ((locals (tmp.19 ball.3.11 tmp.20 bar.4.12 foobar.2.8 ball.8.9 bar.1.10 tmp-ra.15))
         (conflicts
          ((tmp-ra.15 (tmp.19 tmp.20 bar.4.12 ball.3.11 foobar.2.8 ball.8.9 bar.1.10 rbp rdx rsi rdi))
           (bar.1.10 (tmp.19 tmp.20 bar.4.12 ball.3.11 foobar.2.8 ball.8.9 rbp tmp-ra.15 rdx rsi))
           (ball.8.9 (rsi tmp.19 tmp.20 ball.3.11 foobar.2.8 rbp tmp-ra.15 bar.1.10 rdx))
           (foobar.2.8 (rbp tmp-ra.15 ball.8.9 bar.1.10))
           (bar.4.12 (rbp tmp-ra.15 bar.1.10))
           (tmp.20 (ball.8.9 rbp tmp-ra.15 bar.1.10))
           (ball.3.11 (rbp tmp-ra.15 ball.8.9 bar.1.10))
           (tmp.19 (rbp tmp-ra.15 ball.8.9 bar.1.10))
           (rdi (r15 rbp rsi rdx tmp-ra.15))
           (rsi (r15 rdi rbp rdx ball.8.9 bar.1.10 tmp-ra.15))
           (rdx (r15 rdi rsi rbp ball.8.9 bar.1.10 tmp-ra.15))
           (rbp
            (r15 rdi rsi rdx tmp.19 tmp.20 bar.4.12 ball.3.11 foobar.2.8 ball.8.9 bar.1.10 tmp-ra.15))
           (r15 (rbp rdi rsi rdx))))
         (assignment ()))
        (begin
          (set! tmp-ra.15 r15)
          (set! bar.1.10 rdi)
          (set! ball.8.9 rsi)
          (set! foobar.2.8 rdx)
          (if (begin
                (set! tmp.19 -408033154)
                (<= tmp.19 bar.1.10))
              (begin
                (set! tmp.20 ball.8.9)
                (set! tmp.20 (+ tmp.20 bar.1.10))
                (set! ball.3.11 tmp.20))
              (begin
                (set! bar.4.12 ball.8.9)
                (set! ball.3.11 bar.4.12)))
          (set! rdx ball.8.9)
          (set! rsi bar.1.10)
          (set! rdi ball.8.9)
          (set! r15 tmp-ra.15)
          (jump L.proc.1.2 rbp r15 rdi rsi rdx)))
      (begin
        (set! tmp-ra.16 r15)
        (if (begin
              (set! tmp.21 1)
              (<= tmp.21 899234556))
            (set! ball.3.13 0)
            (set! ball.3.13 0))
        (set! r9 -9223372036854775808)
        (set! r8 1792291800)
        (set! rcx ball.3.13)
        (set! rdx 1961997671)
        (set! rsi ball.3.13)
        (set! rdi ball.3.13)
        (set! r15 tmp-ra.16)
        (jump L.proc.0.1 rbp r15 rdi rsi rdx rcx r8 r9))))
  (check-by-interp
   '(module ((locals (tmp.17 bat.9.12 tmp.18 bat.2.13 bat.9.11 foo.4.10 tmp-ra.15 bat.8.9))
             (conflicts
              ((bat.8.9 (rbp tmp-ra.15 bat.9.12))
               (tmp-ra.15
                (tmp.17 bat.8.9 rbp rdi rsi rdx rcx foo.4.10 bat.9.11 bat.9.12 tmp.18 rax bat.2.13))
               (foo.4.10 (rbp tmp-ra.15))
               (bat.9.11 (rbp tmp-ra.15))
               (bat.2.13 (rbp tmp-ra.15))
               (tmp.18 (rbp tmp-ra.15))
               (bat.9.12 (rbp tmp-ra.15 bat.8.9))
               (tmp.17 (rbp tmp-ra.15))
               (rbp (tmp.17 bat.8.9
                            tmp-ra.15
                            r15
                            rdi
                            rsi
                            rdx
                            rcx
                            foo.4.10
                            bat.9.11
                            bat.9.12
                            tmp.18
                            rax
                            bat.2.13))
               (rax (rbp tmp-ra.15))
               (rcx (r15 rdi rsi rdx rbp tmp-ra.15))
               (rdx (r15 rdi rsi rbp rcx tmp-ra.15))
               (rsi (r15 rdi rbp rdx rcx tmp-ra.15))
               (rdi (r15 rbp rsi rdx rcx tmp-ra.15))
               (r15 (rbp rdi rsi rdx rcx))))
             (assignment ()))
            (define L.x.0.1
              ((locals
                (tmp.16 ball.1.6 foo.0.7 foo.4.1 foo.5.4 foo.3.2 tmp-ra.14 foo.0.3 foo.3.8 ball.7.5))
               (conflicts
                ((ball.7.5 (rbp tmp-ra.14 foo.0.3 foo.3.8))
                 (foo.3.8 (rbp tmp-ra.14 ball.7.5))
                 (foo.0.3 (ball.1.6 tmp.16 foo.0.7 ball.7.5 foo.4.1 foo.3.2 rbp tmp-ra.14 rcx rdx))
                 (tmp-ra.14 (ball.1.6 tmp.16
                                      foo.0.7
                                      ball.7.5
                                      foo.4.1
                                      foo.3.2
                                      foo.0.3
                                      foo.5.4
                                      rbp
                                      rax
                                      foo.3.8
                                      rdi
                                      rsi
                                      rdx
                                      rcx))
                 (foo.3.2 (ball.1.6 tmp.16 foo.0.7 foo.4.1 rbp tmp-ra.14 foo.0.3 rdx rcx))
                 (foo.5.4 (rbp tmp-ra.14 rcx rdx rsi))
                 (foo.4.1 (rbp tmp-ra.14 foo.0.3 foo.3.2))
                 (foo.0.7 (rbp tmp-ra.14 foo.0.3 foo.3.2))
                 (ball.1.6 (rbp tmp-ra.14 foo.0.3 foo.3.2))
                 (tmp.16 (rbp tmp-ra.14 foo.0.3 foo.3.2))
                 (rcx (foo.0.3 foo.5.4 r15 rdi rsi rdx rbp tmp-ra.14 foo.3.2))
                 (rbp (ball.1.6 tmp.16
                                foo.0.7
                                ball.7.5
                                foo.4.1
                                foo.3.2
                                foo.0.3
                                foo.5.4
                                tmp-ra.14
                                rax
                                foo.3.8
                                r15
                                rdi
                                rsi
                                rdx
                                rcx))
                 (rdx (foo.0.3 foo.5.4 r15 rdi rsi rbp rcx tmp-ra.14 foo.3.2))
                 (rsi (foo.5.4 r15 rdi rbp rdx rcx tmp-ra.14))
                 (rdi (r15 rbp rsi rdx rcx tmp-ra.14))
                 (r15 (rbp rdi rsi rdx rcx))
                 (rax (rbp tmp-ra.14))))
               (assignment ()))
              (begin
                (set! tmp-ra.14 r15)
                (set! foo.5.4 rdi)
                (set! foo.0.3 rsi)
                (set! foo.3.2 rdx)
                (set! foo.4.1 rcx)
                (if (begin
                      (set! ball.1.6 foo.4.1)
                      (begin
                        (set! tmp.16 -9223372036854775808)
                        (<= tmp.16 -1549190542)))
                    (begin
                      (set! foo.0.7 1)
                      (set! ball.7.5 foo.3.2))
                    (set! ball.7.5 foo.3.2))
                (if (true)
                    (begin
                      (set! foo.3.8 foo.0.3)
                      (set! rax ball.7.5)
                      (jump tmp-ra.14 rbp rax))
                    (begin
                      (set! rcx foo.0.3)
                      (set! rdx -9223372036854775808)
                      (set! rsi foo.3.2)
                      (set! rdi foo.3.2)
                      (set! r15 tmp-ra.14)
                      (jump L.x.0.1 rbp r15 rdi rsi rdx rcx)))))
      (begin
        (set! tmp-ra.15 r15)
        (if (true)
            (set! bat.8.9 480297521)
            (begin
              (set! tmp.17 1)
              (set! tmp.17 (- tmp.17 0))
              (set! bat.8.9 tmp.17)))
        (if (= bat.8.9 0)
            (begin
              (set! bat.9.11 bat.8.9)
              (set! foo.4.10 0)
              (set! rcx foo.4.10)
              (set! rdx 0)
              (set! rsi 9223372036854775807)
              (set! rdi 9223372036854775807)
              (set! r15 tmp-ra.15)
              (jump L.x.0.1 rbp r15 rdi rsi rdx rcx))
            (if (begin
                  (set! bat.9.12 1)
                  (>= bat.8.9 1434817833))
                (begin
                  (set! tmp.18 -9223372036854775808)
                  (set! tmp.18 (* tmp.18 -1655015632))
                  (set! rax tmp.18)
                  (jump tmp-ra.15 rbp rax))
                (begin
                  (set! bat.2.13 -9223372036854775808)
                  (set! rax 1398310587)
                  (jump tmp-ra.15 rbp rax)))))))
  (check-by-interp
   '(module ((locals (tmp-ra.11 bar.8.9 tmp.13))
             (conflicts ((tmp.13 (rbp tmp-ra.11)) (bar.8.9 (rbp tmp-ra.11))
                                                  (tmp-ra.11 (rbp tmp.13 bar.8.9 rax))
                                                  (rax (rbp tmp-ra.11))
                                                  (rbp (tmp-ra.11 tmp.13 bar.8.9 rax))))
             (assignment ()))
            (define L.func.0.1
              ((locals
                (foo.4.1 bat.1.7 foo.3.8 ball.0.5 ball.2.2 foo.5.3 tmp-ra.10 foo.6.6 foo.9.4 tmp.12))
               (conflicts
                ((tmp.12 (rbp tmp-ra.10 foo.6.6 foo.9.4 ball.2.2 foo.5.3 ball.0.5))
                 (foo.9.4 (foo.4.1 ball.2.2 foo.5.3 rbp tmp-ra.10 foo.6.6 ball.0.5 tmp.12 r8 r9 fv0))
                 (foo.6.6 (foo.4.1 ball.2.2
                                   foo.5.3
                                   foo.9.4
                                   ball.0.5
                                   rbp
                                   tmp-ra.10
                                   rdx
                                   tmp.12
                                   rcx
                                   r8
                                   r9
                                   fv0
                                   foo.3.8))
                 (tmp-ra.10 (foo.4.1 ball.2.2
                                     foo.5.3
                                     foo.9.4
                                     ball.0.5
                                     foo.6.6
                                     bat.1.7
                                     rbp
                                     tmp.12
                                     rax
                                     rdi
                                     rsi
                                     rdx
                                     rcx
                                     r8
                                     r9
                                     fv0
                                     foo.3.8))
                 (foo.5.3 (foo.4.1 ball.2.2 rbp tmp-ra.10 foo.6.6 foo.9.4 ball.0.5 fv0 r9 tmp.12))
                 (ball.2.2 (foo.4.1 rbp tmp-ra.10 foo.6.6 foo.9.4 foo.5.3 ball.0.5 fv0 tmp.12))
                 (ball.0.5
                  (foo.4.1 ball.2.2 foo.5.3 foo.9.4 rbp tmp-ra.10 foo.6.6 fv0 r9 r8 rcx tmp.12))
                 (foo.3.8 (rbp tmp-ra.10 foo.6.6))
                 (bat.1.7 (rbp tmp-ra.10 fv0 r9 r8 rcx rdx rsi))
                 (foo.4.1 (rbp tmp-ra.10 foo.6.6 foo.9.4 ball.2.2 foo.5.3 ball.0.5))
                 (rbp (foo.4.1 ball.2.2
                               foo.5.3
                               foo.9.4
                               ball.0.5
                               foo.6.6
                               bat.1.7
                               tmp-ra.10
                               tmp.12
                               rax
                               r15
                               rdi
                               rsi
                               rdx
                               rcx
                               r8
                               r9
                               fv0
                               foo.3.8))
                 (fv0 (ball.2.2 foo.5.3
                                ball.0.5
                                bat.1.7
                                foo.9.4
                                r15
                                rdi
                                rsi
                                rdx
                                rcx
                                r8
                                r9
                                rbp
                                tmp-ra.10
                                foo.6.6))
                 (r9
                  (foo.5.3 ball.0.5 bat.1.7 foo.6.6 foo.9.4 r15 rdi rsi rdx rcx r8 rbp fv0 tmp-ra.10))
                 (r8 (ball.0.5 bat.1.7 foo.6.6 foo.9.4 r15 rdi rsi rdx rcx rbp r9 fv0 tmp-ra.10))
                 (rcx (ball.0.5 bat.1.7 foo.6.6 r15 rdi rsi rdx rbp r8 r9 fv0 tmp-ra.10))
                 (rdx (foo.6.6 bat.1.7 r15 rdi rsi rbp rcx r8 r9 fv0 tmp-ra.10))
                 (rsi (bat.1.7 r15 rdi rbp rdx rcx r8 r9 fv0 tmp-ra.10))
                 (rdi (r15 rbp rsi rdx rcx r8 r9 fv0 tmp-ra.10))
                 (r15 (rbp rdi rsi rdx rcx r8 r9 fv0))
                 (rax (rbp tmp-ra.10))))
               (assignment ()))
              (begin
                (set! tmp-ra.10 r15)
                (set! bat.1.7 rdi)
                (set! foo.6.6 rsi)
                (set! ball.0.5 rdx)
                (set! foo.9.4 rcx)
                (set! foo.5.3 r8)
                (set! ball.2.2 r9)
                (set! foo.4.1 fv0)
                (if (begin
                      (set! tmp.12 9223372036854775807)
                      (> tmp.12 -1225978347))
                    (if (if (> ball.0.5 1)
                            (> ball.2.2 -9223372036854775808)
                            (!= foo.5.3 -847185955))
                        (begin
                          (set! fv0 -260761950)
                          (set! r9 0)
                          (set! r8 -9223372036854775808)
                          (set! rcx foo.9.4)
                          (set! rdx foo.6.6)
                          (set! rsi -144908363)
                          (set! rdi 9223372036854775807)
                          (set! r15 tmp-ra.10)
                          (jump L.func.0.1 rbp r15 rdi rsi rdx rcx r8 r9 fv0))
                        (if (> foo.9.4 foo.9.4)
                            (begin
                              (set! rax 0)
                              (jump tmp-ra.10 rbp rax))
                            (begin
                              (set! rax 1)
                              (jump tmp-ra.10 rbp rax))))
                    (begin
                      (set! foo.3.8 9223372036854775807)
                      (set! fv0 0)
                      (set! r9 foo.6.6)
                      (set! r8 foo.6.6)
                      (set! rcx 9223372036854775807)
                      (set! rdx -9223372036854775808)
                      (set! rsi -472335653)
                      (set! rdi -9223372036854775808)
                      (set! r15 tmp-ra.10)
                      (jump L.func.0.1 rbp r15 rdi rsi rdx rcx r8 r9 fv0)))))
      (begin
        (set! tmp-ra.11 r15)
        (if (begin
              (set! tmp.13 1)
              (>= tmp.13 9223372036854775807))
            (begin
              (set! bar.8.9 1)
              (set! rax bar.8.9)
              (jump tmp-ra.11 rbp rax))
            (begin
              (set! rax -32529780)
              (jump tmp-ra.11 rbp rax))))))

  ;   ;; M6 tests; Added by Trevor on March 6th 2026, multiple bindings allowed per let
  (check-by-interp
   '(module ((locals (tmp.17 tmp-ra.13 tmp.16 tmp.15 tmp.14))
             (conflicts ((tmp.14 (rbp tmp-ra.13)) (tmp.15 (rbp tmp-ra.13))
                                                  (tmp.16 (rbp tmp-ra.13))
                                                  (tmp-ra.13 (rbp tmp.14 tmp.15 tmp.16 tmp.17 rax))
                                                  (tmp.17 (rbp tmp-ra.13))
                                                  (rax (rbp tmp-ra.13))
                                                  (rbp (tmp-ra.13 tmp.14 tmp.15 tmp.16 tmp.17 rax))))
             (assignment ()))
            (define L.proc.0.1
              ((locals (foobar.1.1 bat.8.2 foo.0.3 ball.7.4 ball.2.5 foo.5.6 ball.9.7 tmp-ra.10))
               (conflicts
                ((tmp-ra.10 (foobar.1.1 bat.8.2
                                        foo.0.3
                                        ball.7.4
                                        ball.2.5
                                        foo.5.6
                                        ball.9.7
                                        rbp
                                        fv0
                                        r9
                                        r8
                                        rcx
                                        rdx
                                        rsi
                                        rdi))
                 (ball.9.7 (rbp tmp-ra.10 fv0 r9 r8 rcx rdx rsi))
                 (foo.5.6 (rbp tmp-ra.10 fv0 r9 r8 rcx rdx))
                 (ball.2.5 (rbp tmp-ra.10 fv0 r9 r8 rcx))
                 (ball.7.4 (rbp tmp-ra.10 fv0 r9 r8))
                 (foo.0.3 (rbp tmp-ra.10 fv0 r9))
                 (bat.8.2 (rbp tmp-ra.10 fv0))
                 (foobar.1.1 (rbp tmp-ra.10))
                 (rdi (tmp-ra.10))
                 (rsi (ball.9.7 tmp-ra.10))
                 (rdx (foo.5.6 ball.9.7 tmp-ra.10))
                 (rcx (ball.2.5 foo.5.6 ball.9.7 tmp-ra.10))
                 (r8 (ball.7.4 ball.2.5 foo.5.6 ball.9.7 tmp-ra.10))
                 (r9 (foo.0.3 ball.7.4 ball.2.5 foo.5.6 ball.9.7 tmp-ra.10))
                 (fv0 (bat.8.2 foo.0.3 ball.7.4 ball.2.5 foo.5.6 ball.9.7 tmp-ra.10))
                 (rbp (r15 foobar.1.1 bat.8.2 foo.0.3 ball.7.4 ball.2.5 foo.5.6 ball.9.7 tmp-ra.10))
                 (r15 (rbp))))
               (assignment ()))
              (begin
                (set! tmp-ra.10 r15)
                (set! ball.9.7 rdi)
                (set! foo.5.6 rsi)
                (set! ball.2.5 rdx)
                (set! ball.7.4 rcx)
                (set! foo.0.3 r8)
                (set! bat.8.2 r9)
                (set! foobar.1.1 fv0)
                (set! r15 tmp-ra.10)
                (jump L.tmp.1.2 rbp r15)))
      (define L.tmp.1.2
        ((locals (tmp-ra.11)) (conflicts ((tmp-ra.11 (rdi rsi rbp)) (rbp (r15 rdi rsi tmp-ra.11))
                                                                    (rsi (r15 rdi rbp tmp-ra.11))
                                                                    (rdi (r15 rbp rsi tmp-ra.11))
                                                                    (r15 (rbp rdi rsi))))
                              (assignment ()))
        (begin
          (set! tmp-ra.11 r15)
          (set! rsi 0)
          (set! rdi 0)
          (set! r15 tmp-ra.11)
          (jump L.proc.2.3 rbp r15 rdi rsi)))
      (define L.proc.2.3
        ((locals (bat.8.8 foo.6.9 tmp-ra.12))
         (conflicts ((tmp-ra.12 (rdx rcx r8 r9 fv0 bat.8.8 foo.6.9 rbp rsi rdi))
                     (foo.6.9 (rdx r8 fv0 bat.8.8 rbp tmp-ra.12 rsi))
                     (bat.8.8 (rsi rdx rcx r9 fv0 rbp tmp-ra.12 foo.6.9))
                     (rdi (r15 rbp rsi rdx rcx r8 r9 fv0 tmp-ra.12))
                     (rsi (r15 rdi rbp rdx rcx r8 r9 fv0 bat.8.8 foo.6.9 tmp-ra.12))
                     (rbp (r15 rdi rsi rdx rcx r8 r9 fv0 bat.8.8 foo.6.9 tmp-ra.12))
                     (fv0 (r15 rdi rsi rdx rcx r8 r9 rbp tmp-ra.12 bat.8.8 foo.6.9))
                     (r9 (r15 rdi rsi rdx rcx r8 rbp fv0 tmp-ra.12 bat.8.8))
                     (r8 (r15 rdi rsi rdx rcx rbp r9 fv0 tmp-ra.12 foo.6.9))
                     (rcx (r15 rdi rsi rdx rbp r8 r9 fv0 tmp-ra.12 bat.8.8))
                     (rdx (r15 rdi rsi rbp rcx r8 r9 fv0 tmp-ra.12 bat.8.8 foo.6.9))
                     (r15 (rbp rdi rsi rdx rcx r8 r9 fv0))))
         (assignment ()))
        (begin
          (set! tmp-ra.12 r15)
          (set! foo.6.9 rdi)
          (set! bat.8.8 rsi)
          (set! fv0 1635273112)
          (set! r9 foo.6.9)
          (set! r8 bat.8.8)
          (set! rcx foo.6.9)
          (set! rdx 445965252)
          (set! rsi foo.6.9)
          (set! rdi bat.8.8)
          (set! r15 tmp-ra.12)
          (jump L.proc.0.1 rbp r15 rdi rsi rdx rcx r8 r9 fv0)))
      (begin
        (set! tmp-ra.13 r15)
        (if (if (begin
                  (set! tmp.14 9223372036854775807)
                  (<= tmp.14 -9223372036854775808))
                (begin
                  (set! tmp.15 692968731)
                  (< tmp.15 0))
                (begin
                  (set! tmp.16 -1490931083)
                  (<= tmp.16 -14809197)))
            (begin
              (set! rax 1275113131)
              (jump tmp-ra.13 rbp rax))
            (if (begin
                  (set! tmp.17 -1702177019)
                  (<= tmp.17 -9223372036854775808))
                (begin
                  (set! rax 0)
                  (jump tmp-ra.13 rbp rax))
                (begin
                  (set! rax 1843455920)
                  (jump tmp-ra.13 rbp rax)))))))
  (check-by-interp
   '(module ((locals (ball.0.8 foobar.4.9 bat.6.10 tmp-ra.12))
             (conflicts ((tmp-ra.12 (rax ball.0.8 foobar.4.9 bat.6.10 rbp))
                         (bat.6.10 (rbp tmp-ra.12))
                         (foobar.4.9 (ball.0.8 rbp tmp-ra.12))
                         (ball.0.8 (rbp tmp-ra.12 foobar.4.9))
                         (rbp (rax ball.0.8 foobar.4.9 bat.6.10 tmp-ra.12))
                         (rax (rbp tmp-ra.12))))
             (assignment ()))
            (define L.fn.0.1
              ((locals (bat.7.1 bat.3.2 foobar.4.3 foo.8.4 bar.9.5 foo.2.6 bat.5.7 tmp-ra.11))
               (conflicts
                ((tmp-ra.11 (bat.7.1 bat.3.2
                                     foobar.4.3
                                     foo.8.4
                                     bar.9.5
                                     foo.2.6
                                     bat.5.7
                                     rbp
                                     fv0
                                     r9
                                     r8
                                     rcx
                                     rdx
                                     rsi
                                     rdi))
                 (bat.5.7 (bat.7.1 bat.3.2
                                   foobar.4.3
                                   foo.8.4
                                   bar.9.5
                                   foo.2.6
                                   rbp
                                   tmp-ra.11
                                   fv0
                                   r9
                                   r8
                                   rcx
                                   rdx
                                   rsi))
                 (foo.2.6 (rbp tmp-ra.11 bat.5.7 fv0 r9 r8 rcx rdx))
                 (bar.9.5 (rbp tmp-ra.11 bat.5.7 fv0 r9 r8 rcx))
                 (foo.8.4 (bat.7.1 bat.3.2 foobar.4.3 rbp tmp-ra.11 bat.5.7 fv0 r9 r8))
                 (foobar.4.3 (rbp tmp-ra.11 bat.5.7 foo.8.4 fv0 r9))
                 (bat.3.2 (rsi rdx rcx r8 r9 bat.7.1 rbp tmp-ra.11 bat.5.7 foo.8.4 fv0))
                 (bat.7.1 (rbp tmp-ra.11 bat.3.2 bat.5.7 foo.8.4))
                 (rdi (r15 rbp rsi rdx rcx r8 r9 fv0 tmp-ra.11))
                 (rsi (r15 rdi rbp rdx rcx r8 r9 fv0 bat.3.2 bat.5.7 tmp-ra.11))
                 (rdx (r15 rdi rsi rbp rcx r8 r9 fv0 bat.3.2 foo.2.6 bat.5.7 tmp-ra.11))
                 (rcx (r15 rdi rsi rdx rbp r8 r9 fv0 bat.3.2 bar.9.5 foo.2.6 bat.5.7 tmp-ra.11))
                 (r8
                  (r15 rdi rsi rdx rcx rbp r9 fv0 bat.3.2 foo.8.4 bar.9.5 foo.2.6 bat.5.7 tmp-ra.11))
                 (r9 (r15 rdi
                          rsi
                          rdx
                          rcx
                          r8
                          rbp
                          fv0
                          bat.3.2
                          foobar.4.3
                          foo.8.4
                          bar.9.5
                          foo.2.6
                          bat.5.7
                          tmp-ra.11))
                 (fv0 (r15 rdi
                           rsi
                           rdx
                           rcx
                           r8
                           r9
                           rbp
                           bat.3.2
                           foobar.4.3
                           foo.8.4
                           bar.9.5
                           foo.2.6
                           bat.5.7
                           tmp-ra.11))
                 (rbp (r15 rdi
                           rsi
                           rdx
                           rcx
                           r8
                           r9
                           fv0
                           bat.7.1
                           bat.3.2
                           foobar.4.3
                           foo.8.4
                           bar.9.5
                           foo.2.6
                           bat.5.7
                           tmp-ra.11))
                 (r15 (rbp rdi rsi rdx rcx r8 r9 fv0))))
               (assignment ()))
              (begin
                (set! tmp-ra.11 r15)
                (set! bat.5.7 rdi)
                (set! foo.2.6 rsi)
                (set! bar.9.5 rdx)
                (set! foo.8.4 rcx)
                (set! foobar.4.3 r8)
                (set! bat.3.2 r9)
                (set! bat.7.1 fv0)
                (set! fv0 bat.3.2)
                (set! r9 foo.8.4)
                (set! r8 foo.8.4)
                (set! rcx 9223372036854775807)
                (set! rdx bat.5.7)
                (set! rsi -9223372036854775808)
                (set! rdi bat.3.2)
                (set! r15 tmp-ra.11)
                (jump L.fn.0.1 rbp r15 rdi rsi rdx rcx r8 r9 fv0)))
      (begin
        (set! tmp-ra.12 r15)
        (set! bat.6.10 9223372036854775807)
        (set! foobar.4.9 9223372036854775807)
        (set! ball.0.8 9223372036854775807)
        (set! rax foobar.4.9)
        (jump tmp-ra.12 rbp rax))))
  (check-by-interp
   '(module ((locals (tmp-ra.13 tmp.17))
             (conflicts ((tmp.17 (rbp tmp-ra.13)) (tmp-ra.13 (rbp tmp.17 rax))
                                                  (rax (rbp tmp-ra.13))
                                                  (rbp (tmp-ra.13 tmp.17 rax))))
             (assignment ()))
            (define L.func.0.1
              ((locals (ball.4.4 bar.2.5 foo.9.7 foo.9.3 foobar.5.2 bat.0.6 tmp.14))
               (conflicts
                ((tmp.14 (rbp tmp-ra.11 bat.0.6))
                 (foo.6.1 (rbp tmp-ra.11 foobar.5.2 foo.9.3 bar.2.5 bat.0.6 rax foo.9.7 rsi rdx))
                 (bat.0.6 (tmp.14 rbp tmp-ra.11 foo.6.1))
                 (foobar.5.2 (foo.6.1 rbp tmp-ra.11 foo.9.3 bar.2.5 r8 foo.9.7 rdx))
                 (foo.9.3 (foo.6.1 foobar.5.2 rbp tmp-ra.11 bar.2.5 r8 rcx rsi rdx foo.9.7))
                 (foo.9.7 (rbp tmp-ra.11 foo.6.1 foobar.5.2 foo.9.3))
                 (bar.2.5 (foo.6.1 foobar.5.2 foo.9.3 ball.4.4 rbp tmp-ra.11 r8 rcx rdx rsi))
                 (tmp-ra.11 (foo.6.1 foobar.5.2
                                     foo.9.3
                                     ball.4.4
                                     bar.2.5
                                     rbp
                                     r8
                                     rcx
                                     tmp.14
                                     bat.0.6
                                     rax
                                     foo.9.7
                                     rdi
                                     rsi
                                     rdx))
                 (ball.4.4 (rbp tmp-ra.11 bar.2.5 r8 rcx rdx))
                 (rdx (ball.4.4 bar.2.5 foo.9.3 r15 rdi rsi rbp tmp-ra.11 foo.6.1 foobar.5.2))
                 (rbp (foo.6.1 foobar.5.2
                               foo.9.3
                               ball.4.4
                               bar.2.5
                               tmp-ra.11
                               tmp.14
                               bat.0.6
                               rax
                               foo.9.7
                               r15
                               rdi
                               rsi
                               rdx))
                 (rsi (bar.2.5 foo.9.3 r15 rdi rbp rdx tmp-ra.11 foo.6.1))
                 (rdi (r15 rbp rsi rdx tmp-ra.11))
                 (r15 (rbp rdi rsi rdx))
                 (rax (rbp tmp-ra.11 foo.6.1))
                 (rcx (foo.9.3 ball.4.4 bar.2.5 tmp-ra.11))
                 (r8 (foobar.5.2 foo.9.3 ball.4.4 bar.2.5 tmp-ra.11))))
               (assignment ((tmp-ra.11 fv0) (foo.6.1 fv1))))
              (begin
                (set! tmp-ra.11 r15)
                (set! bar.2.5 rdi)
                (set! ball.4.4 rsi)
                (set! foo.9.3 rdx)
                (set! foobar.5.2 rcx)
                (set! foo.6.1 r8)
                (if (true)
                    (begin
                      (set! foo.9.7 bar.2.5)
                      (begin
                        (set! rbp (- rbp 16))
                        (return-point L.rp.3
                                      (begin
                                        (set! rdx -1140169546)
                                        (set! rsi foobar.5.2)
                                        (set! rdi foo.9.3)
                                        (set! r15 L.rp.3)
                                        (jump L.func.1.2 rbp r15 rdi rsi rdx)))
                        (set! rbp (+ rbp 16)))
                      (set! bat.0.6 rax)
                      (set! tmp.14 foo.6.1)
                      (set! tmp.14 (+ tmp.14 bat.0.6))
                      (set! rax tmp.14)
                      (jump tmp-ra.11 rbp rax))
                    (begin
                      (set! rdx 9223372036854775807)
                      (set! rsi foobar.5.2)
                      (set! rdi foo.6.1)
                      (set! r15 tmp-ra.11)
                      (jump L.func.1.2 rbp r15 rdi rsi rdx)))))
      (define L.func.1.2
        ((locals (tmp.16 foo.6.9 tmp-ra.12 bat.0.10 foo.9.8 tmp.15))
         (conflicts ((tmp.15 (rbp tmp-ra.12 bat.0.10 foo.9.8 foo.6.9))
                     (foo.9.8 (rbp tmp-ra.12 bat.0.10 foo.6.9 tmp.15))
                     (bat.0.10 (foo.9.8 foo.6.9 rbp tmp-ra.12 tmp.15 rsi rdx))
                     (tmp-ra.12 (foo.9.8 foo.6.9 bat.0.10 rbp tmp.15 rdi rsi rdx rax tmp.16))
                     (foo.6.9 (foo.9.8 rbp tmp-ra.12 bat.0.10 rdx tmp.15 tmp.16))
                     (tmp.16 (rbp tmp-ra.12 foo.6.9))
                     (rbp (foo.9.8 foo.6.9 bat.0.10 tmp-ra.12 tmp.15 r15 rdi rsi rdx rax tmp.16))
                     (rax (rbp tmp-ra.12))
                     (rdx (foo.6.9 r15 rdi rsi rbp tmp-ra.12 bat.0.10))
                     (rsi (r15 rdi rbp rdx tmp-ra.12 bat.0.10))
                     (rdi (r15 rbp rsi rdx tmp-ra.12))
                     (r15 (rbp rdi rsi rdx))))
         (assignment ()))
        (begin
          (set! tmp-ra.12 r15)
          (set! bat.0.10 rdi)
          (set! foo.6.9 rsi)
          (set! foo.9.8 rdx)
          (if (begin
                (set! tmp.15 9223372036854775807)
                (!= tmp.15 -47909185))
              (if (false)
                  (if (< foo.9.8 foo.9.8)
                      (begin
                        (set! rax bat.0.10)
                        (jump tmp-ra.12 rbp rax))
                      (begin
                        (set! rax -9223372036854775808)
                        (jump tmp-ra.12 rbp rax)))
                  (begin
                    (set! rdx foo.9.8)
                    (set! rsi foo.9.8)
                    (set! rdi bat.0.10)
                    (set! r15 tmp-ra.12)
                    (jump L.func.1.2 rbp r15 rdi rsi rdx)))
              (begin
                (set! tmp.16 -9223372036854775808)
                (set! tmp.16 (+ tmp.16 foo.6.9))
                (set! rax tmp.16)
                (jump tmp-ra.12 rbp rax)))))
      (begin
        (set! tmp-ra.13 r15)
        (if (begin
              (set! tmp.17 9223372036854775807)
              (> tmp.17 9223372036854775807))
            (begin
              (set! rax -877748660)
              (jump tmp-ra.13 rbp rax))
            (begin
              (set! rax -9223372036854775808)
              (jump tmp-ra.13 rbp rax))))))
  (check-by-interp '(module ((locals (tmp.2 tmp-ra.1))
                             (conflicts ((tmp-ra.1 (rax tmp.2 rbp)) (tmp.2 (rbp tmp-ra.1))
                                                                    (rbp (rax tmp.2 tmp-ra.1))
                                                                    (rax (rbp tmp-ra.1))))
                             (assignment ()))
                            (begin
                              (set! tmp-ra.1 r15)
                              (set! tmp.2 -1640821439)
                              (set! tmp.2 (+ tmp.2 -406700566))
                              (set! rax tmp.2)
                              (jump tmp-ra.1 rbp rax))
                      ))
  (check-by-interp
   '(module ((locals (bar.7.9 bat.9.10 tmp-ra.13))
             (conflicts ((tmp-ra.13 (rax bar.7.9 bat.9.10 rbp)) (bat.9.10 (rbp tmp-ra.13))
                                                                (bar.7.9 (rbp tmp-ra.13))
                                                                (rbp (rax bar.7.9 bat.9.10 tmp-ra.13))
                                                                (rax (rbp tmp-ra.13))))
             (assignment ()))
            (define L.fn.0.1
              ((locals (ball.6.1 foo.2.2 tmp-ra.11))
               (conflicts ((tmp-ra.11 (rdx rcx r8 r9 ball.6.1 foo.2.2 rbp rsi rdi))
                           (foo.2.2 (rdx rcx r8 ball.6.1 rbp tmp-ra.11 rsi))
                           (ball.6.1 (rsi rcx r9 rbp tmp-ra.11 foo.2.2))
                           (rdi (r15 rbp rsi rdx rcx r8 r9 tmp-ra.11))
                           (rsi (r15 rdi rbp rdx rcx r8 r9 ball.6.1 foo.2.2 tmp-ra.11))
                           (rbp (r15 rdi rsi rdx rcx r8 r9 ball.6.1 foo.2.2 tmp-ra.11))
                           (r9 (r15 rdi rsi rdx rcx r8 rbp tmp-ra.11 ball.6.1))
                           (r8 (r15 rdi rsi rdx rcx rbp r9 tmp-ra.11 foo.2.2))
                           (rcx (r15 rdi rsi rdx rbp r8 r9 tmp-ra.11 ball.6.1 foo.2.2))
                           (rdx (r15 rdi rsi rbp rcx r8 r9 tmp-ra.11 foo.2.2))
                           (r15 (rbp rdi rsi rdx rcx r8 r9))))
               (assignment ()))
              (begin
                (set! tmp-ra.11 r15)
                (set! foo.2.2 rdi)
                (set! ball.6.1 rsi)
                (set! r9 foo.2.2)
                (set! r8 ball.6.1)
                (set! rcx -9223372036854775808)
                (set! rdx ball.6.1)
                (set! rsi foo.2.2)
                (set! rdi ball.6.1)
                (set! r15 tmp-ra.11)
                (jump L.x.1.2 rbp r15 rdi rsi rdx rcx r8 r9)))
      (define L.x.1.2
        ((locals (bar.7.3 foo.2.4 ball.5.5 foobar.1.6 foo.4.7 ball.0.8 tmp-ra.12))
         (conflicts
          ((tmp-ra.12
            (bar.7.3 foo.2.4 ball.5.5 foobar.1.6 foo.4.7 ball.0.8 rbp r9 r8 rcx rdx rsi rdi))
           (ball.0.8 (rbp tmp-ra.12 r9 r8 rcx rdx rsi))
           (foo.4.7 (rbp tmp-ra.12 r9 r8 rcx rdx))
           (foobar.1.6 (rbp tmp-ra.12 r9 r8 rcx))
           (ball.5.5 (bar.7.3 foo.2.4 rbp tmp-ra.12 r9 r8))
           (foo.2.4 (rbp tmp-ra.12 ball.5.5 r9))
           (bar.7.3 (rcx r8 r9 rbp tmp-ra.12 ball.5.5))
           (rdi (r15 rbp rsi rdx rcx r8 r9 tmp-ra.12))
           (rsi (r15 rdi rbp rdx rcx r8 r9 ball.0.8 tmp-ra.12))
           (rdx (r15 rdi rsi rbp rcx r8 r9 foo.4.7 ball.0.8 tmp-ra.12))
           (rcx (r15 rdi rsi rdx rbp r8 r9 bar.7.3 foobar.1.6 foo.4.7 ball.0.8 tmp-ra.12))
           (r8 (r15 rdi rsi rdx rcx rbp r9 bar.7.3 ball.5.5 foobar.1.6 foo.4.7 ball.0.8 tmp-ra.12))
           (r9 (r15 rdi
                    rsi
                    rdx
                    rcx
                    r8
                    rbp
                    bar.7.3
                    foo.2.4
                    ball.5.5
                    foobar.1.6
                    foo.4.7
                    ball.0.8
                    tmp-ra.12))
           (rbp (r15 rdi
                     rsi
                     rdx
                     rcx
                     r8
                     r9
                     bar.7.3
                     foo.2.4
                     ball.5.5
                     foobar.1.6
                     foo.4.7
                     ball.0.8
                     tmp-ra.12))
           (r15 (rbp rdi rsi rdx rcx r8 r9))))
         (assignment ()))
        (begin
          (set! tmp-ra.12 r15)
          (set! ball.0.8 rdi)
          (set! foo.4.7 rsi)
          (set! foobar.1.6 rdx)
          (set! ball.5.5 rcx)
          (set! foo.2.4 r8)
          (set! bar.7.3 r9)
          (set! r9 ball.5.5)
          (set! r8 1)
          (set! rcx -984231193)
          (set! rdx bar.7.3)
          (set! rsi bar.7.3)
          (set! rdi 933807622)
          (set! r15 tmp-ra.12)
          (jump L.x.1.2 rbp r15 rdi rsi rdx rcx r8 r9)))
      (begin
        (set! tmp-ra.13 r15)
        (set! bat.9.10 -477286222)
        (set! bar.7.9 0)
        (set! rax 643069821)
        (jump tmp-ra.13 rbp rax))))
  (check-by-interp
   '(module ((locals (tmp-ra.18 tmp.20))
             (conflicts ((tmp.20 (rbp tmp-ra.18)) (tmp-ra.18 (rbp rax tmp.20 rdi))
                                                  (rdi (r15 rbp tmp-ra.18))
                                                  (rbp (tmp-ra.18 rax tmp.20 r15 rdi))
                                                  (r15 (rbp rdi))
                                                  (rax (rbp tmp-ra.18))))
             (assignment ()))
            (define L.func.0.1
              ((locals (tmp.19 bat.2.3 bar.9.6 bat.0.5 ball.4.4 bat.0.2 tmp-ra.15 bar.9.1))
               (conflicts
                ((bar.9.1 (rbp tmp-ra.15 bat.0.2 bat.2.3 tmp.19))
                 (tmp-ra.15 (bar.9.1 rbp rdi bat.0.2 ball.4.4 bat.0.5 bar.9.6 bat.2.3 tmp.19))
                 (bat.0.2 (rbp tmp-ra.15 bar.9.1))
                 (ball.4.4 (rbp tmp-ra.15))
                 (bat.0.5 (rbp tmp-ra.15))
                 (bar.9.6 (rbp tmp-ra.15))
                 (bat.2.3 (rbp tmp-ra.15 bar.9.1))
                 (tmp.19 (bar.9.1 rbp tmp-ra.15))
                 (rbp (bar.9.1 tmp-ra.15 r15 rdi bat.0.2 ball.4.4 bat.0.5 bar.9.6 bat.2.3 tmp.19))
                 (rdi (r15 rbp tmp-ra.15))
                 (r15 (rbp rdi))))
               (assignment ()))
              (begin
                (set! tmp-ra.15 r15)
                (set! bar.9.1 rdi)
                (if (!= bar.9.1 bar.9.1)
                    (begin
                      (set! rdi 2058053814)
                      (set! r15 tmp-ra.15)
                      (jump L.func.0.1 rbp r15 rdi))
                    (begin
                      (set! tmp.19 bar.9.1)
                      (set! tmp.19 (- tmp.19 bar.9.1))
                      (set! bat.2.3 tmp.19)
                      (set! bar.9.6 bar.9.1)
                      (set! bat.0.5 bar.9.1)
                      (set! ball.4.4 bar.9.1)
                      (set! bat.0.2 ball.4.4)
                      (set! rdi bar.9.1)
                      (set! r15 tmp-ra.15)
                      (jump L.x.2.3 rbp r15 rdi)))))
      (define L.tmp.1.2
        ((locals (bat.5.7 bat.3.8 bat.8.9 tmp-ra.16))
         (conflicts ((tmp-ra.16 (bat.5.7 bat.3.8 bat.8.9 rbp rdx rsi rdi))
                     (bat.8.9 (bat.5.7 bat.3.8 rbp tmp-ra.16 rdx rsi))
                     (bat.3.8 (rbp tmp-ra.16 bat.8.9 rdx))
                     (bat.5.7 (rbp tmp-ra.16 bat.8.9))
                     (rdi (r15 rbp tmp-ra.16))
                     (rsi (bat.8.9 tmp-ra.16))
                     (rdx (bat.3.8 bat.8.9 tmp-ra.16))
                     (rbp (r15 rdi bat.5.7 bat.3.8 bat.8.9 tmp-ra.16))
                     (r15 (rbp rdi))))
         (assignment ()))
        (begin
          (set! tmp-ra.16 r15)
          (set! bat.8.9 rdi)
          (set! bat.3.8 rsi)
          (set! bat.5.7 rdx)
          (set! rdi bat.8.9)
          (set! r15 tmp-ra.16)
          (jump L.x.2.3 rbp r15 rdi)))
      (define L.x.2.3
        ((locals (bar.9.10 bat.8.13 foo.1.14 bar.9.11 ball.7.12))
         (conflicts
          ((ball.7.12 (rbp tmp-ra.17))
           (bar.9.11 (rbp tmp-ra.17 rdx))
           (foo.1.14 (rbp tmp-ra.17))
           (bat.8.13 (rbp tmp-ra.17))
           (tmp-ra.17 (bar.9.11 rax bar.9.10 rbp ball.7.12 bat.8.13 foo.1.14 rsi rdx rdi))
           (bar.9.10 (rdx rbp tmp-ra.17))
           (rdi (rsi rdx r15 rbp tmp-ra.17))
           (rbp (bar.9.11 rax bar.9.10 tmp-ra.17 ball.7.12 bat.8.13 foo.1.14 rsi rdx r15 rdi))
           (r15 (rsi rdx rbp rdi))
           (rdx (bar.9.10 r15 rdi rsi rbp tmp-ra.17 bar.9.11))
           (rsi (r15 rdi rbp rdx tmp-ra.17))
           (rax (rbp tmp-ra.17))))
         (assignment ((tmp-ra.17 fv0))))
        (begin
          (set! tmp-ra.17 r15)
          (set! bar.9.10 rdi)
          (begin
            (set! rbp (- rbp 8))
            (return-point L.rp.4
                          (begin
                            (set! rdx -1942673900)
                            (set! rsi bar.9.10)
                            (set! rdi bar.9.10)
                            (set! r15 L.rp.4)
                            (jump L.tmp.1.2 rbp r15 rdi rsi rdx)))
            (set! rbp (+ rbp 8)))
          (set! bar.9.11 rax)
          (if (begin
                (set! foo.1.14 bar.9.11)
                (set! bat.8.13 bar.9.11)
                (set! ball.7.12 bar.9.11)
                (= ball.7.12 bar.9.11))
              (begin
                (set! rdx -1386061378)
                (set! rsi bar.9.11)
                (set! rdi bar.9.11)
                (set! r15 tmp-ra.17)
                (jump L.tmp.1.2 rbp r15 rdi rsi rdx))
              (begin
                (set! rdi bar.9.11)
                (set! r15 tmp-ra.17)
                (jump L.func.0.1 rbp r15 rdi)))))
      (begin
        (set! tmp-ra.18 r15)
        (if (true)
            (begin
              (set! tmp.20 9223372036854775807)
              (set! tmp.20 (+ tmp.20 -9223372036854775808))
              (set! rax tmp.20)
              (jump tmp-ra.18 rbp rax))
            (begin
              (set! rdi -2107846344)
              (set! r15 tmp-ra.18)
              (jump L.func.0.1 rbp r15 rdi))))))
  (check-by-interp
   '(module ((locals (tmp-ra.1 tmp.2)) (conflicts ((tmp.2 (rbp tmp-ra.1)) (tmp-ra.1 (rbp tmp.2 rax))
                                                                          (rax (rbp tmp-ra.1))
                                                                          (rbp (tmp-ra.1 tmp.2 rax))))
                                       (assignment ()))
            (begin
              (set! tmp-ra.1 r15)
              (if (begin
                    (set! tmp.2 1)
                    (<= tmp.2 -9223372036854775808))
                  (if (false)
                      (begin
                        (set! rax -9223372036854775808)
                        (jump tmp-ra.1 rbp rax))
                      (begin
                        (set! rax 2012039291)
                        (jump tmp-ra.1 rbp rax)))
                  (begin
                    (set! rax 9223372036854775807)
                    (jump tmp-ra.1 rbp rax))))
      ))
  (check-by-interp
   '(module ((locals (tmp-ra.25))
             (conflicts ((tmp-ra.25 (rdi rsi rdx rcx rbp)) (rbp (r15 rdi rsi rdx rcx tmp-ra.25))
                                                           (rcx (r15 rdi rsi rdx rbp tmp-ra.25))
                                                           (rdx (r15 rdi rsi rbp rcx tmp-ra.25))
                                                           (rsi (r15 rdi rbp rdx rcx tmp-ra.25))
                                                           (rdi (r15 rbp rsi rdx rcx tmp-ra.25))
                                                           (r15 (rbp rdi rsi rdx rcx))))
             (assignment ()))
            (define L.func.0.1
              ((locals (tmp.26 foo.9.1 foo.5.2 foobar.7.3 foo.4.4 ball.1.5 foo.2.6 tmp-ra.22))
               (conflicts
                ((tmp-ra.22 (rax tmp.26
                                 foo.9.1
                                 foo.5.2
                                 foobar.7.3
                                 foo.4.4
                                 ball.1.5
                                 foo.2.6
                                 rbp
                                 r9
                                 r8
                                 rcx
                                 rdx
                                 rsi
                                 rdi))
                 (foo.2.6
                  (foo.9.1 foo.5.2 foobar.7.3 foo.4.4 ball.1.5 rbp tmp-ra.22 r9 r8 rcx rdx rsi))
                 (ball.1.5 (rbp tmp-ra.22 foo.2.6 r9 r8 rcx rdx))
                 (foo.4.4 (tmp.26 foo.9.1 foo.5.2 foobar.7.3 rbp tmp-ra.22 foo.2.6 r9 r8 rcx))
                 (foobar.7.3 (rbp tmp-ra.22 foo.4.4 foo.2.6 r9 r8))
                 (foo.5.2 (rbp tmp-ra.22 foo.4.4 foo.2.6 r9))
                 (foo.9.1 (rbp tmp-ra.22 foo.4.4 foo.2.6))
                 (tmp.26 (rbp tmp-ra.22 foo.4.4))
                 (rdi (tmp-ra.22))
                 (rsi (foo.2.6 tmp-ra.22))
                 (rdx (ball.1.5 foo.2.6 tmp-ra.22))
                 (rcx (foo.4.4 ball.1.5 foo.2.6 tmp-ra.22))
                 (r8 (foobar.7.3 foo.4.4 ball.1.5 foo.2.6 tmp-ra.22))
                 (r9 (foo.5.2 foobar.7.3 foo.4.4 ball.1.5 foo.2.6 tmp-ra.22))
                 (rbp (rax tmp.26 foo.9.1 foo.5.2 foobar.7.3 foo.4.4 ball.1.5 foo.2.6 tmp-ra.22))
                 (rax (rbp tmp-ra.22))))
               (assignment ()))
              (begin
                (set! tmp-ra.22 r15)
                (set! foo.2.6 rdi)
                (set! ball.1.5 rsi)
                (set! foo.4.4 rdx)
                (set! foobar.7.3 rcx)
                (set! foo.5.2 r8)
                (set! foo.9.1 r9)
                (set! tmp.26 foo.2.6)
                (set! tmp.26 (- tmp.26 foo.4.4))
                (set! rax tmp.26)
                (jump tmp-ra.22 rbp rax)))
      (define L.proc.1.2
        ((locals (foo.6.11 foobar.7.12 foo.4.13 foo.2.8 foobar.7.9 foo.6.10 tmp.27))
         (conflicts
          ((tmp-ra.23
            (foo.6.11 foobar.7.12 foo.4.13 foo.2.8 foobar.7.9 foo.6.10 rax foo.6.7 tmp.27 rbp))
           (tmp.27 (rbp tmp-ra.23))
           (foo.6.7 (foo.6.10 rax rbp tmp-ra.23))
           (foo.6.10 (foo.2.8 foobar.7.9 rbp tmp-ra.23 foo.6.7))
           (foobar.7.9 (rbp tmp-ra.23 foo.6.10))
           (foo.2.8 (rbp tmp-ra.23 foo.6.10))
           (foo.4.13 (rbp tmp-ra.23))
           (foobar.7.12 (rbp tmp-ra.23))
           (foo.6.11 (rbp tmp-ra.23))
           (rbp (foo.6.11 foobar.7.12
                          foo.4.13
                          foo.2.8
                          foobar.7.9
                          foo.6.10
                          r15
                          rdi
                          rsi
                          rdx
                          rcx
                          r8
                          r9
                          rax
                          foo.6.7
                          tmp.27
                          tmp-ra.23))
           (rax (rbp tmp-ra.23 foo.6.7))
           (r9 (r15 rdi rsi rdx rcx r8 rbp))
           (r8 (r15 rdi rsi rdx rcx rbp r9))
           (rcx (r15 rdi rsi rdx rbp r8 r9))
           (rdx (r15 rdi rsi rbp rcx r8 r9))
           (rsi (r15 rdi rbp rdx rcx r8 r9))
           (rdi (r15 rbp rsi rdx rcx r8 r9))
           (r15 (rbp rdi rsi rdx rcx r8 r9))))
         (assignment ((tmp-ra.23 fv0) (foo.6.7 fv1))))
        (begin
          (set! tmp-ra.23 r15)
          (set! tmp.27 9223372036854775807)
          (set! tmp.27 (+ tmp.27 1))
          (set! foo.6.7 tmp.27)
          (begin
            (set! rbp (- rbp 16))
            (return-point L.rp.4
                          (begin
                            (set! r9 foo.6.7)
                            (set! r8 foo.6.7)
                            (set! rcx foo.6.7)
                            (set! rdx foo.6.7)
                            (set! rsi foo.6.7)
                            (set! rdi 0)
                            (set! r15 L.rp.4)
                            (jump L.func.0.1 rbp r15 rdi rsi rdx rcx r8 r9)))
            (set! rbp (+ rbp 16)))
          (set! foo.6.10 rax)
          (set! foobar.7.9 foo.6.7)
          (if (>= foo.6.7 foo.6.7)
              (set! foo.2.8 foo.6.7)
              (set! foo.2.8 foo.6.7))
          (set! foo.4.13 foo.6.10)
          (set! foobar.7.12 foo.6.10)
          (set! foo.6.11 -9223372036854775808)
          (set! rax 9223372036854775807)
          (jump tmp-ra.23 rbp rax)))
      (define L.func.2.3
        ((locals
          (foo.4.19 foo.9.20 foo.6.21 foo.4.15 bar.0.17 tmp-ra.24 foobar.7.16 foo.6.14 foo.9.18))
         (conflicts
          ((foo.9.18 (foo.4.19 foo.9.20 foo.6.21 rbp tmp-ra.24 bar.0.17 foo.6.14))
           (foo.6.14 (foo.4.19 foo.9.18 rbp tmp-ra.24 foobar.7.16 bar.0.17))
           (foobar.7.16 (foo.9.20 foo.6.21 foo.6.14 foo.4.15 rbp tmp-ra.24 bar.0.17 rcx rdx))
           (tmp-ra.24 (foo.4.19 foo.9.20
                                foo.6.21
                                foo.9.18
                                foo.6.14
                                foo.4.15
                                foobar.7.16
                                bar.0.17
                                rbp
                                rcx
                                rdx
                                rsi
                                rdi
                                rax))
           (bar.0.17 (foo.4.19 foo.9.20
                               foo.6.21
                               foo.9.18
                               foo.6.14
                               foo.4.15
                               foobar.7.16
                               rbp
                               tmp-ra.24
                               rcx
                               rdx
                               rsi))
           (foo.4.15 (rbp tmp-ra.24 foobar.7.16 bar.0.17 rcx))
           (foo.6.21 (rbp tmp-ra.24 foobar.7.16 bar.0.17 foo.9.18))
           (foo.9.20 (rbp tmp-ra.24 foobar.7.16 bar.0.17 foo.9.18))
           (foo.4.19 (rbp tmp-ra.24 bar.0.17 foo.9.18 foo.6.14))
           (rax (rbp tmp-ra.24))
           (rbp (foo.4.19 foo.9.20
                          foo.6.21
                          foo.9.18
                          foo.6.14
                          foo.4.15
                          foobar.7.16
                          bar.0.17
                          tmp-ra.24
                          rax))
           (rdi (tmp-ra.24))
           (rsi (bar.0.17 tmp-ra.24))
           (rdx (foobar.7.16 bar.0.17 tmp-ra.24))
           (rcx (foo.4.15 foobar.7.16 bar.0.17 tmp-ra.24))))
         (assignment ()))
        (begin
          (set! tmp-ra.24 r15)
          (set! bar.0.17 rdi)
          (set! foobar.7.16 rsi)
          (set! foo.4.15 rdx)
          (set! foo.6.14 rcx)
          (set! foo.9.18 foobar.7.16)
          (set! foo.6.21 foo.6.14)
          (set! foo.9.20 foo.6.14)
          (set! foo.4.19 foobar.7.16)
          (if (>= foo.9.18 foo.6.14)
              (begin
                (set! rax foobar.7.16)
                (jump tmp-ra.24 rbp rax))
              (begin
                (set! rax bar.0.17)
                (jump tmp-ra.24 rbp rax)))))
      (begin
        (set! tmp-ra.25 r15)
        (set! rcx 9223372036854775807)
        (set! rdx -1735352110)
        (set! rsi 9223372036854775807)
        (set! rdi 0)
        (set! r15 tmp-ra.25)
        (jump L.func.2.3 rbp r15 rdi rsi rdx rcx))))
  (check-by-interp
   '(module ((locals (tmp-ra.19 tmp.22))
             (conflicts ((tmp.22 (rbp tmp-ra.19)) (tmp-ra.19 (rbp tmp.22 rax))
                                                  (rax (rbp tmp-ra.19))
                                                  (rbp (tmp-ra.19 tmp.22 rax))))
             (assignment ()))
            (define L.x.0.1
              ((locals (foobar.8.1 bar.0.2 ball.1.5 bat.9.7 tmp.21 ball.1.8 tmp.20))
               (conflicts
                ((tmp.20 (rbp tmp-ra.16 ball.1.8 ball.6.3 foobar.7.6 foo.2.4))
                 (ball.1.8 (rbp tmp-ra.16 ball.6.3 foobar.7.6 foo.2.4 tmp.20 tmp.21))
                 (tmp.21 (rbp tmp-ra.16 ball.1.8))
                 (ball.6.3 (ball.1.8 rax
                                     foobar.8.1
                                     bar.0.2
                                     rbp
                                     tmp-ra.16
                                     foobar.7.6
                                     foo.2.4
                                     bat.9.7
                                     fv0
                                     r9
                                     tmp.20))
                 (tmp-ra.16 (ball.1.8 foobar.8.1
                                      bar.0.2
                                      ball.6.3
                                      foo.2.4
                                      ball.1.5
                                      foobar.7.6
                                      bat.9.7
                                      rbp
                                      fv0
                                      r9
                                      r8
                                      rcx
                                      rdx
                                      rsi
                                      rdi
                                      tmp.20
                                      tmp.21
                                      rax))
                 (foobar.7.6 (ball.1.8 rax
                                       foobar.8.1
                                       bar.0.2
                                       ball.6.3
                                       foo.2.4
                                       ball.1.5
                                       rbp
                                       tmp-ra.16
                                       bat.9.7
                                       fv0
                                       r9
                                       r8
                                       rcx
                                       rdx
                                       tmp.20))
                 (foo.2.4 (ball.1.8 rdx
                                    rcx
                                    nfv.17
                                    rax
                                    foobar.8.1
                                    bar.0.2
                                    ball.6.3
                                    rbp
                                    tmp-ra.16
                                    foobar.7.6
                                    bat.9.7
                                    fv0
                                    r9
                                    r8
                                    tmp.20))
                 (bat.9.7 (nfv.17 foobar.8.1
                                  bar.0.2
                                  ball.6.3
                                  foo.2.4
                                  ball.1.5
                                  foobar.7.6
                                  rbp
                                  tmp-ra.16
                                  fv0
                                  r9
                                  r8
                                  rcx
                                  rdx
                                  rsi))
                 (ball.1.5 (rbp tmp-ra.16 foobar.7.6 bat.9.7 fv0 r9 r8 rcx))
                 (bar.0.2 (r9 foobar.8.1 rbp tmp-ra.16 ball.6.3 foobar.7.6 foo.2.4 bat.9.7 fv0))
                 (foobar.8.1
                  (rcx r8 r9 nfv.17 rbp tmp-ra.16 ball.6.3 foobar.7.6 foo.2.4 bat.9.7 bar.0.2))
                 (nfv.17 (r15 rdi rsi rdx rcx r8 r9 rbp foo.2.4 foobar.8.1 bat.9.7))
                 (rax (ball.6.3 foobar.7.6 foo.2.4 rbp tmp-ra.16))
                 (rbp (ball.1.8 r15
                                rdi
                                rsi
                                rdx
                                rcx
                                r8
                                r9
                                nfv.17
                                foobar.8.1
                                bar.0.2
                                ball.6.3
                                foo.2.4
                                ball.1.5
                                foobar.7.6
                                bat.9.7
                                tmp-ra.16
                                tmp.20
                                tmp.21
                                rax))
                 (rdi (r15 rbp rsi rdx rcx r8 r9 nfv.17 tmp-ra.16))
                 (rsi (r15 rdi rbp rdx rcx r8 r9 nfv.17 bat.9.7 tmp-ra.16))
                 (rdx (r15 rdi rsi rbp rcx r8 r9 nfv.17 foo.2.4 foobar.7.6 bat.9.7 tmp-ra.16))
                 (rcx (r15 rdi
                           rsi
                           rdx
                           rbp
                           r8
                           r9
                           nfv.17
                           foo.2.4
                           foobar.8.1
                           ball.1.5
                           foobar.7.6
                           bat.9.7
                           tmp-ra.16))
                 (r8 (r15 rdi
                          rsi
                          rdx
                          rcx
                          rbp
                          r9
                          nfv.17
                          foobar.8.1
                          foo.2.4
                          ball.1.5
                          foobar.7.6
                          bat.9.7
                          tmp-ra.16))
                 (r9 (r15 rdi
                          rsi
                          rdx
                          rcx
                          r8
                          rbp
                          nfv.17
                          foobar.8.1
                          bar.0.2
                          ball.6.3
                          foo.2.4
                          ball.1.5
                          foobar.7.6
                          bat.9.7
                          tmp-ra.16))
                 (fv0 (bar.0.2 ball.6.3 foo.2.4 ball.1.5 foobar.7.6 bat.9.7 tmp-ra.16))
                 (r15 (rbp rdi rsi rdx rcx r8 r9 nfv.17))))
               (assignment
                ((tmp-ra.16 fv1) (ball.6.3 fv2) (foobar.7.6 fv3) (foo.2.4 fv4) (nfv.17 fv5))))
              (begin
                (set! tmp-ra.16 r15)
                (set! bat.9.7 rdi)
                (set! foobar.7.6 rsi)
                (set! ball.1.5 rdx)
                (set! foo.2.4 rcx)
                (set! ball.6.3 r8)
                (set! bar.0.2 r9)
                (set! foobar.8.1 fv0)
                (begin
                  (set! rbp (- rbp 40))
                  (return-point L.rp.3
                                (begin
                                  (set! nfv.17 bar.0.2)
                                  (set! r9 bat.9.7)
                                  (set! r8 bar.0.2)
                                  (set! rcx 0)
                                  (set! rdx foobar.8.1)
                                  (set! rsi foo.2.4)
                                  (set! rdi foo.2.4)
                                  (set! r15 L.rp.3)
                                  (jump L.fn.1.2 rbp r15 rdi rsi rdx rcx r8 r9 nfv.17)))
                  (set! rbp (+ rbp 40)))
                (set! ball.1.8 rax)
                (if (not (begin
                           (set! tmp.20 0)
                           (< tmp.20 -9223372036854775808)))
                    (begin
                      (set! tmp.21 ball.6.3)
                      (set! tmp.21 (+ tmp.21 ball.1.8))
                      (set! rax tmp.21)
                      (jump tmp-ra.16 rbp rax))
                    (if (<= foo.2.4 0)
                        (begin
                          (set! rax foo.2.4)
                          (jump tmp-ra.16 rbp rax))
                        (begin
                          (set! rax foobar.7.6)
                          (jump tmp-ra.16 rbp rax))))))
      (define L.fn.1.2
        ((locals (foobar.8.9 foobar.7.10 bat.5.11 ball.6.12 foobar.4.13 bar.0.14 bat.9.15 tmp-ra.18))
         (conflicts
          ((tmp-ra.18 (foobar.8.9 foobar.7.10
                                  bat.5.11
                                  ball.6.12
                                  foobar.4.13
                                  bar.0.14
                                  bat.9.15
                                  rbp
                                  fv0
                                  r9
                                  r8
                                  rcx
                                  rdx
                                  rsi
                                  rdi))
           (bat.9.15 (rbp tmp-ra.18 fv0 r9 r8 rcx rdx rsi))
           (bar.0.14
            (foobar.8.9 foobar.7.10 bat.5.11 ball.6.12 foobar.4.13 rbp tmp-ra.18 fv0 r9 r8 rcx rdx))
           (foobar.4.13 (rbp tmp-ra.18 bar.0.14 fv0 r9 r8 rcx))
           (ball.6.12 (rsi rdx rcx foobar.8.9 foobar.7.10 bat.5.11 rbp tmp-ra.18 bar.0.14 fv0 r9 r8))
           (bat.5.11 (rbp tmp-ra.18 ball.6.12 bar.0.14 fv0 r9))
           (foobar.7.10 (rdx rcx r9 foobar.8.9 rbp tmp-ra.18 ball.6.12 bar.0.14 fv0))
           (foobar.8.9 (rbp tmp-ra.18 ball.6.12 foobar.7.10 bar.0.14))
           (rdi (r15 rbp rsi rdx rcx r8 r9 fv0 tmp-ra.18))
           (rsi (r15 rdi rbp rdx rcx r8 r9 fv0 ball.6.12 bat.9.15 tmp-ra.18))
           (rdx (r15 rdi rsi rbp rcx r8 r9 fv0 ball.6.12 foobar.7.10 bar.0.14 bat.9.15 tmp-ra.18))
           (rcx (r15 rdi
                     rsi
                     rdx
                     rbp
                     r8
                     r9
                     fv0
                     ball.6.12
                     foobar.7.10
                     foobar.4.13
                     bar.0.14
                     bat.9.15
                     tmp-ra.18))
           (r8 (r15 rdi rsi rdx rcx rbp r9 fv0 ball.6.12 foobar.4.13 bar.0.14 bat.9.15 tmp-ra.18))
           (r9 (r15 rdi
                    rsi
                    rdx
                    rcx
                    r8
                    rbp
                    fv0
                    foobar.7.10
                    bat.5.11
                    ball.6.12
                    foobar.4.13
                    bar.0.14
                    bat.9.15
                    tmp-ra.18))
           (fv0 (r15 rdi
                     rsi
                     rdx
                     rcx
                     r8
                     r9
                     rbp
                     foobar.7.10
                     bat.5.11
                     ball.6.12
                     foobar.4.13
                     bar.0.14
                     bat.9.15
                     tmp-ra.18))
           (rbp (r15 rdi
                     rsi
                     rdx
                     rcx
                     r8
                     r9
                     fv0
                     foobar.8.9
                     foobar.7.10
                     bat.5.11
                     ball.6.12
                     foobar.4.13
                     bar.0.14
                     bat.9.15
                     tmp-ra.18))
           (r15 (rbp rdi rsi rdx rcx r8 r9 fv0))))
         (assignment ()))
        (begin
          (set! tmp-ra.18 r15)
          (set! bat.9.15 rdi)
          (set! bar.0.14 rsi)
          (set! foobar.4.13 rdx)
          (set! ball.6.12 rcx)
          (set! bat.5.11 r8)
          (set! foobar.7.10 r9)
          (set! foobar.8.9 fv0)
          (set! fv0 0)
          (set! r9 bar.0.14)
          (set! r8 foobar.7.10)
          (set! rcx -9223372036854775808)
          (set! rdx bar.0.14)
          (set! rsi foobar.7.10)
          (set! rdi ball.6.12)
          (set! r15 tmp-ra.18)
          (jump L.fn.1.2 rbp r15 rdi rsi rdx rcx r8 r9 fv0)))
      (begin
        (set! tmp-ra.19 r15)
        (if (begin
              (set! tmp.22 -9223372036854775808)
              (>= tmp.22 -637253177))
            (begin
              (set! rax -9223372036854775808)
              (jump tmp-ra.19 rbp rax))
            (begin
              (set! rax 0)
              (jump tmp-ra.19 rbp rax))))))
  (check-by-interp
   '(module ((locals (tmp-ra.1)) (conflicts ((tmp-ra.1 (rax rbp)) (rbp (rax tmp-ra.1))
                                                                  (rax (rbp tmp-ra.1))))
                                 (assignment ()))
            (begin
              (set! tmp-ra.1 r15)
              (set! rax 9223372036854775807)
              (jump tmp-ra.1 rbp rax))
      ))
  (check-by-interp
   '(module ((locals (foo.0.25 foo.7.26 bar.3.27 tmp-ra.33))
             (conflicts ((tmp-ra.33 (rax foo.0.25 foo.7.26 bar.3.27 rbp))
                         (bar.3.27 (foo.0.25 foo.7.26 rbp tmp-ra.33))
                         (foo.7.26 (rbp tmp-ra.33 bar.3.27))
                         (foo.0.25 (rbp tmp-ra.33 bar.3.27))
                         (rbp (rax foo.0.25 foo.7.26 bar.3.27 tmp-ra.33))
                         (rax (rbp tmp-ra.33))))
             (assignment ()))
            (define L.proc.0.1
              ((locals (bat.6.1 bat.5.2 bat.1.3 foo.0.4 foo.7.5 bat.8.6 tmp-ra.28))
               (conflicts
                ((tmp-ra.28
                  (bat.6.1 bat.5.2 bat.1.3 foo.0.4 foo.7.5 bat.8.6 rbp r9 r8 rcx rdx rsi rdi))
                 (bat.8.6 (bat.6.1 bat.5.2 bat.1.3 foo.0.4 foo.7.5 rbp tmp-ra.28 r9 r8 rcx rdx rsi))
                 (foo.7.5 (rbp tmp-ra.28 bat.8.6 r9 r8 rcx rdx))
                 (foo.0.4 (rbp tmp-ra.28 bat.8.6 r9 r8 rcx))
                 (bat.1.3 (bat.6.1 bat.5.2 rbp tmp-ra.28 bat.8.6 r9 r8))
                 (bat.5.2 (rcx r8 bat.6.1 rbp tmp-ra.28 bat.8.6 bat.1.3 r9))
                 (bat.6.1 (rbp tmp-ra.28 bat.5.2 bat.8.6 bat.1.3))
                 (rdi (r15 rbp rsi rdx rcx r8 r9 tmp-ra.28))
                 (rsi (r15 rdi rbp rdx rcx r8 r9 bat.8.6 tmp-ra.28))
                 (rdx (r15 rdi rsi rbp rcx r8 r9 foo.7.5 bat.8.6 tmp-ra.28))
                 (rcx (r15 rdi rsi rdx rbp r8 r9 bat.5.2 foo.0.4 foo.7.5 bat.8.6 tmp-ra.28))
                 (r8 (r15 rdi rsi rdx rcx rbp r9 bat.5.2 bat.1.3 foo.0.4 foo.7.5 bat.8.6 tmp-ra.28))
                 (r9 (r15 rdi rsi rdx rcx r8 rbp bat.5.2 bat.1.3 foo.0.4 foo.7.5 bat.8.6 tmp-ra.28))
                 (rbp (r15 rdi
                           rsi
                           rdx
                           rcx
                           r8
                           r9
                           bat.6.1
                           bat.5.2
                           bat.1.3
                           foo.0.4
                           foo.7.5
                           bat.8.6
                           tmp-ra.28))
                 (r15 (rbp rdi rsi rdx rcx r8 r9))))
               (assignment ()))
              (begin
                (set! tmp-ra.28 r15)
                (set! bat.8.6 rdi)
                (set! foo.7.5 rsi)
                (set! foo.0.4 rdx)
                (set! bat.1.3 rcx)
                (set! bat.5.2 r8)
                (set! bat.6.1 r9)
                (set! r9 bat.1.3)
                (set! r8 bat.8.6)
                (set! rcx -635532414)
                (set! rdx bat.5.2)
                (set! rsi bat.5.2)
                (set! rdi bat.5.2)
                (set! r15 tmp-ra.28)
                (jump L.proc.0.1 rbp r15 rdi rsi rdx rcx r8 r9)))
      (define L.tmp.1.2
        ((locals (bat.8.16 ball.9.17 tmp.34 ball.4.12 bar.3.14 bat.5.15))
         (conflicts
          ((tmp-ra.29 (r9 fv0
                          bat.8.16
                          ball.9.17
                          tmp.34
                          ball.4.12
                          bar.3.14
                          bat.5.15
                          foo.0.13
                          rax
                          foo.7.7
                          ball.9.8
                          bat.8.9
                          foo.0.10
                          bat.6.11
                          rbp
                          r8
                          rcx
                          rdx
                          rsi
                          rdi))
           (bat.6.11 (fv0 bat.8.16
                          ball.9.17
                          tmp.34
                          ball.4.12
                          r9
                          bar.3.14
                          bat.5.15
                          foo.0.13
                          rax
                          foo.7.7
                          ball.9.8
                          bat.8.9
                          foo.0.10
                          rbp
                          tmp-ra.29
                          r8
                          rcx
                          rdx
                          rsi))
           (foo.0.10 (nfv.31 bat.5.15
                             rsi
                             r9
                             nfv.30
                             foo.0.13
                             rax
                             foo.7.7
                             ball.9.8
                             bat.8.9
                             rbp
                             tmp-ra.29
                             bat.6.11
                             r8
                             rcx
                             rdx))
           (bat.8.9 (r9 nfv.31
                        bar.3.14
                        bat.5.15
                        nfv.30
                        foo.0.13
                        rax
                        foo.7.7
                        ball.9.8
                        rbp
                        tmp-ra.29
                        bat.6.11
                        foo.0.10
                        r8
                        rcx))
           (ball.9.8
            (r9 nfv.30 foo.0.13 rsi rdx rax foo.7.7 rbp tmp-ra.29 bat.6.11 foo.0.10 bat.8.9 r8))
           (foo.7.7 (fv0 bat.8.16
                         ball.9.17
                         tmp.34
                         ball.4.12
                         nfv.31
                         bar.3.14
                         bat.5.15
                         r8
                         r9
                         foo.0.13
                         rdx
                         rcx
                         rax
                         rbp
                         tmp-ra.29
                         bat.6.11
                         foo.0.10
                         bat.8.9
                         ball.9.8))
           (foo.0.13 (ball.9.17 tmp.34
                                ball.4.12
                                bar.3.14
                                bat.5.15
                                rax
                                rbp
                                tmp-ra.29
                                foo.7.7
                                bat.6.11
                                foo.0.10
                                bat.8.9
                                ball.9.8))
           (nfv.30 (r15 rdi rsi rdx rcx r8 r9 rbp foo.0.10 ball.9.8 bat.8.9))
           (bat.5.15 (rbp tmp-ra.29 foo.7.7 bat.6.11 foo.0.13 foo.0.10 bat.8.9))
           (bar.3.14 (rbp tmp-ra.29 foo.7.7 bat.6.11 foo.0.13 bat.8.9))
           (nfv.31 (r15 rdi rsi rdx rcx r8 r9 rbp foo.7.7 bat.8.9 foo.0.10))
           (ball.4.12
            (rsi rdx rcx r8 r9 bat.8.16 ball.9.17 tmp.34 rbp tmp-ra.29 foo.7.7 bat.6.11 foo.0.13))
           (tmp.34 (foo.0.13 rbp tmp-ra.29 ball.4.12 foo.7.7 bat.6.11))
           (ball.9.17 (rbp tmp-ra.29 ball.4.12 foo.7.7 bat.6.11 foo.0.13))
           (bat.8.16 (r8 r9 fv0 rbp tmp-ra.29 ball.4.12 foo.7.7 bat.6.11))
           (rdi (fv0 nfv.31 r9 nfv.30 r15 rbp rsi rdx rcx r8 tmp-ra.29))
           (rsi (fv0 ball.4.12
                     nfv.31
                     r9
                     nfv.30
                     foo.0.10
                     r15
                     rdi
                     rbp
                     rdx
                     rcx
                     r8
                     ball.9.8
                     bat.6.11
                     tmp-ra.29))
           (rdx (fv0 ball.4.12
                     nfv.31
                     r9
                     nfv.30
                     r15
                     rdi
                     rsi
                     rbp
                     rcx
                     r8
                     ball.9.8
                     foo.7.7
                     foo.0.10
                     bat.6.11
                     tmp-ra.29))
           (rcx (fv0 ball.4.12
                     nfv.31
                     r9
                     nfv.30
                     r15
                     rdi
                     rsi
                     rdx
                     rbp
                     r8
                     foo.7.7
                     bat.8.9
                     foo.0.10
                     bat.6.11
                     tmp-ra.29))
           (r8 (fv0 ball.4.12
                    bat.8.16
                    nfv.31
                    r9
                    nfv.30
                    foo.7.7
                    r15
                    rdi
                    rsi
                    rdx
                    rcx
                    rbp
                    ball.9.8
                    bat.8.9
                    foo.0.10
                    bat.6.11
                    tmp-ra.29))
           (rbp (fv0 bat.8.16
                     ball.9.17
                     tmp.34
                     ball.4.12
                     nfv.31
                     bar.3.14
                     bat.5.15
                     r9
                     nfv.30
                     foo.0.13
                     r15
                     rdi
                     rsi
                     rdx
                     rcx
                     r8
                     rax
                     foo.7.7
                     ball.9.8
                     bat.8.9
                     foo.0.10
                     bat.6.11
                     tmp-ra.29))
           (rax (foo.0.13 rbp tmp-ra.29 foo.7.7 bat.6.11 foo.0.10 bat.8.9 ball.9.8))
           (r15 (fv0 nfv.31 r9 nfv.30 rbp rdi rsi rdx rcx r8))
           (r9 (fv0 tmp-ra.29
                    ball.4.12
                    bat.8.16
                    nfv.31
                    bat.6.11
                    bat.8.9
                    r15
                    rdi
                    rsi
                    rdx
                    rcx
                    r8
                    rbp
                    nfv.30
                    foo.0.10
                    foo.7.7
                    ball.9.8))
           (fv0 (r15 rdi rsi rdx rcx r8 r9 rbp tmp-ra.29 foo.7.7 bat.8.16 bat.6.11))))
         (assignment ((tmp-ra.29 fv1) (foo.7.7 fv2)
                                      (bat.6.11 fv3)
                                      (foo.0.10 fv0)
                                      (bat.8.9 fv4)
                                      (ball.9.8 fv5)
                                      (foo.0.13 fv6)
                                      (nfv.30 fv7)
                                      (nfv.31 fv7))))
        (begin
          (set! tmp-ra.29 r15)
          (set! bat.6.11 rdi)
          (set! foo.0.10 rsi)
          (set! bat.8.9 rdx)
          (set! ball.9.8 rcx)
          (set! foo.7.7 r8)
          (begin
            (set! rbp (- rbp 56))
            (return-point L.rp.4
                          (begin
                            (set! r8 foo.7.7)
                            (set! rcx ball.9.8)
                            (set! rdx bat.6.11)
                            (set! rsi foo.7.7)
                            (set! rdi ball.9.8)
                            (set! r15 L.rp.4)
                            (jump L.tmp.1.2 rbp r15 rdi rsi rdx rcx r8)))
            (set! rbp (+ rbp 56)))
          (set! foo.0.13 rax)
          (begin
            (set! rbp (- rbp 56))
            (return-point L.rp.5
                          (begin
                            (set! nfv.30 foo.7.7)
                            (set! r9 bat.8.9)
                            (set! r8 ball.9.8)
                            (set! rcx -501684781)
                            (set! rdx foo.7.7)
                            (set! rsi 9223372036854775807)
                            (set! rdi foo.0.10)
                            (set! r15 L.rp.5)
                            (jump L.func.2.3 rbp r15 rdi rsi rdx rcx r8 r9 nfv.30)))
            (set! rbp (+ rbp 56)))
          (set! bat.5.15 rax)
          (set! bar.3.14 foo.0.10)
          (begin
            (set! rbp (- rbp 56))
            (return-point L.rp.6
                          (begin
                            (set! nfv.31 bat.6.11)
                            (set! r9 foo.0.10)
                            (set! r8 bat.8.9)
                            (set! rcx -9223372036854775808)
                            (set! rdx foo.7.7)
                            (set! rsi 1644735104)
                            (set! rdi bat.6.11)
                            (set! r15 L.rp.6)
                            (jump L.func.2.3 rbp r15 rdi rsi rdx rcx r8 r9 nfv.31)))
            (set! rbp (+ rbp 56)))
          (set! ball.4.12 rax)
          (set! tmp.34 foo.0.13)
          (set! tmp.34 (- tmp.34 foo.0.13))
          (set! ball.9.17 tmp.34)
          (if (= foo.0.13 ball.4.12)
              (set! bat.8.16 ball.4.12)
              (set! bat.8.16 foo.0.13))
          (set! fv0 ball.4.12)
          (set! r9 -9223372036854775808)
          (set! r8 bat.6.11)
          (set! rcx bat.8.16)
          (set! rdx foo.7.7)
          (set! rsi foo.7.7)
          (set! rdi ball.4.12)
          (set! r15 tmp-ra.29)
          (jump L.func.2.3 rbp r15 rdi rsi rdx rcx r8 r9 fv0)))
      (define L.func.2.3
        ((locals (ball.4.18 bat.1.19 bar.3.20 foo.0.21 bat.8.22 bat.5.23 foo.2.24 tmp-ra.32))
         (conflicts
          ((tmp-ra.32 (ball.4.18 bat.1.19
                                 bar.3.20
                                 foo.0.21
                                 bat.8.22
                                 bat.5.23
                                 foo.2.24
                                 rbp
                                 fv0
                                 r9
                                 r8
                                 rcx
                                 rdx
                                 rsi
                                 rdi))
           (foo.2.24 (rbp tmp-ra.32 fv0 r9 r8 rcx rdx rsi))
           (bat.5.23 (rbp tmp-ra.32 fv0 r9 r8 rcx rdx))
           (bat.8.22 (rbp tmp-ra.32 fv0 r9 r8 rcx))
           (foo.0.21 (rcx ball.4.18 bat.1.19 bar.3.20 rbp tmp-ra.32 fv0 r9 r8))
           (bar.3.20 (rsi rdx rcx r8 ball.4.18 bat.1.19 rbp tmp-ra.32 foo.0.21 fv0 r9))
           (bat.1.19 (rbp tmp-ra.32 bar.3.20 foo.0.21 fv0))
           (ball.4.18 (r9 fv0 rbp tmp-ra.32 bar.3.20 foo.0.21))
           (rdi (r15 rbp rsi rdx rcx r8 r9 fv0 tmp-ra.32))
           (rsi (r15 rdi rbp rdx rcx r8 r9 fv0 bar.3.20 foo.2.24 tmp-ra.32))
           (rdx (r15 rdi rsi rbp rcx r8 r9 fv0 bar.3.20 bat.5.23 foo.2.24 tmp-ra.32))
           (rcx
            (r15 rdi rsi rdx rbp r8 r9 fv0 bar.3.20 foo.0.21 bat.8.22 bat.5.23 foo.2.24 tmp-ra.32))
           (r8
            (r15 rdi rsi rdx rcx rbp r9 fv0 bar.3.20 foo.0.21 bat.8.22 bat.5.23 foo.2.24 tmp-ra.32))
           (r9 (r15 rdi
                    rsi
                    rdx
                    rcx
                    r8
                    rbp
                    fv0
                    ball.4.18
                    bar.3.20
                    foo.0.21
                    bat.8.22
                    bat.5.23
                    foo.2.24
                    tmp-ra.32))
           (fv0 (r15 rdi
                     rsi
                     rdx
                     rcx
                     r8
                     r9
                     rbp
                     ball.4.18
                     bat.1.19
                     bar.3.20
                     foo.0.21
                     bat.8.22
                     bat.5.23
                     foo.2.24
                     tmp-ra.32))
           (rbp (r15 rdi
                     rsi
                     rdx
                     rcx
                     r8
                     r9
                     fv0
                     ball.4.18
                     bat.1.19
                     bar.3.20
                     foo.0.21
                     bat.8.22
                     bat.5.23
                     foo.2.24
                     tmp-ra.32))
           (r15 (rbp rdi rsi rdx rcx r8 r9 fv0))))
         (assignment ()))
        (begin
          (set! tmp-ra.32 r15)
          (set! foo.2.24 rdi)
          (set! bat.5.23 rsi)
          (set! bat.8.22 rdx)
          (set! foo.0.21 rcx)
          (set! bar.3.20 r8)
          (set! bat.1.19 r9)
          (set! ball.4.18 fv0)
          (set! fv0 9223372036854775807)
          (set! r9 foo.0.21)
          (set! r8 ball.4.18)
          (set! rcx ball.4.18)
          (set! rdx foo.0.21)
          (set! rsi -9223372036854775808)
          (set! rdi bar.3.20)
          (set! r15 tmp-ra.32)
          (jump L.func.2.3 rbp r15 rdi rsi rdx rcx r8 r9 fv0)))
      (begin
        (set! tmp-ra.33 r15)
        (set! bar.3.27 -9223372036854775808)
        (set! foo.7.26 9223372036854775807)
        (set! foo.0.25 9223372036854775807)
        (set! rax bar.3.27)
        (jump tmp-ra.33 rbp rax))))
  (check-by-interp
   '(module ((locals (bat.7.18 tmp.25 bat.6.19 bat.8.21 bar.2.20 tmp-ra.24))
             (conflicts
              ((tmp-ra.24 (rdi rsi rdx rcx r8 r9 bat.7.18 tmp.25 bat.8.21 bat.6.19 bar.2.20 rbp))
               (bar.2.20 (bat.7.18 tmp.25 bat.8.21 bat.6.19 rbp tmp-ra.24))
               (bat.8.21 (rbp tmp-ra.24 bar.2.20))
               (bat.6.19 (rcx r9 bat.7.18 rbp tmp-ra.24 bar.2.20))
               (tmp.25 (rbp tmp-ra.24 bar.2.20))
               (bat.7.18 (rbp tmp-ra.24 bat.6.19 bar.2.20))
               (rbp (r15 rdi rsi rdx rcx r8 r9 bat.7.18 tmp.25 bat.8.21 bat.6.19 bar.2.20 tmp-ra.24))
               (r9 (r15 rdi rsi rdx rcx r8 rbp tmp-ra.24 bat.6.19))
               (r8 (r15 rdi rsi rdx rcx rbp r9 tmp-ra.24))
               (rcx (r15 rdi rsi rdx rbp r8 r9 tmp-ra.24 bat.6.19))
               (rdx (r15 rdi rsi rbp rcx r8 r9 tmp-ra.24))
               (rsi (r15 rdi rbp rdx rcx r8 r9 tmp-ra.24))
               (rdi (r15 rbp rsi rdx rcx r8 r9 tmp-ra.24))
               (r15 (rbp rdi rsi rdx rcx r8 r9))))
             (assignment ()))
            (define L.func.0.1
              ((locals (foo.4.5 foo.4.6 bat.3.7 bar.1.8))
               (conflicts
                ((bar.2.3
                  (bar.1.1 bat.3.2 rbp tmp-ra.22 ball.5.4 foo.4.5 rdx rcx rax foo.4.6 bat.3.7 r8))
                 (bar.1.8 (rbp tmp-ra.22 bar.1.1 ball.5.4 bat.3.2 foo.4.5))
                 (bat.3.7 (bar.1.1 rbp tmp-ra.22 ball.5.4 bar.2.3 bat.3.2 foo.4.5))
                 (bar.1.1 (rbp tmp-ra.22
                               ball.5.4
                               bar.2.3
                               bat.3.2
                               foo.4.5
                               rax
                               foo.4.6
                               bat.3.7
                               bar.1.8
                               rsi
                               rdx
                               r8
                               rcx
                               r9))
                 (bat.3.2
                  (bar.1.1 rbp tmp-ra.22 ball.5.4 bar.2.3 foo.4.5 r8 rax foo.4.6 bat.3.7 bar.1.8))
                 (foo.4.6 (rbp tmp-ra.22 bar.1.1 ball.5.4 bar.2.3 bat.3.2))
                 (foo.4.5
                  (bar.1.1 bat.3.2 bar.2.3 ball.5.4 rbp tmp-ra.22 rcx rdx rsi r8 bat.3.7 bar.1.8))
                 (tmp-ra.22 (bar.1.1 bat.3.2
                                     bar.2.3
                                     ball.5.4
                                     foo.4.5
                                     rbp
                                     rax
                                     foo.4.6
                                     bat.3.7
                                     bar.1.8
                                     rdi
                                     rsi
                                     rdx
                                     rcx
                                     r8
                                     r9))
                 (ball.5.4 (bar.1.1 bat.3.2
                                    bar.2.3
                                    rbp
                                    tmp-ra.22
                                    foo.4.5
                                    rax
                                    foo.4.6
                                    bat.3.7
                                    bar.1.8
                                    rcx
                                    rsi
                                    rdx
                                    r8
                                    r9))
                 (r9 (r15 rdi rsi rdx rcx r8 rbp tmp-ra.22 ball.5.4 bar.1.1))
                 (rbp (bar.1.1 bat.3.2
                               bar.2.3
                               ball.5.4
                               foo.4.5
                               tmp-ra.22
                               rax
                               foo.4.6
                               bat.3.7
                               bar.1.8
                               r15
                               rdi
                               rsi
                               rdx
                               rcx
                               r8
                               r9))
                 (r8 (bat.3.2 foo.4.5 bar.1.1 bar.2.3 r15 rdi rsi rdx rcx rbp r9 tmp-ra.22 ball.5.4))
                 (rcx (foo.4.5 bar.2.3 ball.5.4 r15 rdi rsi rdx rbp r8 r9 tmp-ra.22 bar.1.1))
                 (rdx (foo.4.5 bar.2.3 bar.1.1 r15 rdi rsi rbp rcx r8 r9 tmp-ra.22 ball.5.4))
                 (rsi (foo.4.5 bar.1.1 r15 rdi rbp rdx rcx r8 r9 tmp-ra.22 ball.5.4))
                 (rdi (r15 rbp rsi rdx rcx r8 r9 tmp-ra.22))
                 (r15 (rbp rdi rsi rdx rcx r8 r9))
                 (rax (rbp tmp-ra.22 bar.1.1 ball.5.4 bar.2.3 bat.3.2))))
               (assignment
                ((tmp-ra.22 fv0) (bar.1.1 fv1) (ball.5.4 fv2) (bar.2.3 fv3) (bat.3.2 fv4))))
              (begin
                (set! tmp-ra.22 r15)
                (set! foo.4.5 rdi)
                (set! ball.5.4 rsi)
                (set! bar.2.3 rdx)
                (set! bat.3.2 rcx)
                (set! bar.1.1 r8)
                (if (begin
                      (set! bar.1.8 bar.2.3)
                      (if (<= bat.3.2 bar.1.1)
                          (set! bat.3.7 bat.3.2)
                          (set! bat.3.7 bar.1.1))
                      (begin
                        (begin
                          (set! rbp (- rbp 40))
                          (return-point L.rp.3
                                        (begin
                                          (set! r8 bar.1.1)
                                          (set! rcx foo.4.5)
                                          (set! rdx foo.4.5)
                                          (set! rsi bar.2.3)
                                          (set! rdi 1)
                                          (set! r15 L.rp.3)
                                          (jump L.func.0.1 rbp r15 rdi rsi rdx rcx r8)))
                          (set! rbp (+ rbp 40)))
                        (set! foo.4.6 rax))
                      (false))
                    (begin
                      (set! r8 0)
                      (set! rcx bar.2.3)
                      (set! rdx 1603961181)
                      (set! rsi ball.5.4)
                      (set! rdi bar.1.1)
                      (set! r15 tmp-ra.22)
                      (jump L.func.0.1 rbp r15 rdi rsi rdx rcx r8))
                    (begin
                      (set! r9 bat.3.2)
                      (set! r8 bar.1.1)
                      (set! rcx ball.5.4)
                      (set! rdx bar.1.1)
                      (set! rsi -9223372036854775808)
                      (set! rdi ball.5.4)
                      (set! r15 tmp-ra.22)
                      (jump L.fn.1.2 rbp r15 rdi rsi rdx rcx r8 r9)))))
      (define L.fn.1.2
        ((locals (foobar.9.9 tmp-ra.23
                             bar.0.11
                             bat.7.17
                             foobar.9.16
                             bat.8.15
                             ball.5.12
                             bat.7.13
                             bar.1.14
                             bat.3.10))
         (conflicts
          ((bat.3.10 (foobar.9.9 rbp
                                 tmp-ra.23
                                 bar.1.14
                                 bar.0.11
                                 bat.7.13
                                 ball.5.12
                                 r9
                                 bat.8.15
                                 foobar.9.16
                                 bat.7.17))
           (bar.1.14 (foobar.9.9 bat.3.10
                                 bar.0.11
                                 ball.5.12
                                 bat.7.13
                                 rbp
                                 tmp-ra.23
                                 r9
                                 r8
                                 rcx
                                 rdx
                                 rsi
                                 foobar.9.16
                                 bat.7.17))
           (bat.7.13 (foobar.9.9 bat.3.10 bar.0.11 ball.5.12 rbp tmp-ra.23 bar.1.14 r9 r8 rcx rdx))
           (ball.5.12 (foobar.9.9 bat.3.10 bar.0.11 rbp tmp-ra.23 bar.1.14 bat.7.13 r9 r8 rcx))
           (bat.8.15 (rbp tmp-ra.23 bat.3.10))
           (foobar.9.16 (rbp tmp-ra.23 bat.3.10 bar.1.14))
           (bat.7.17 (rbp tmp-ra.23 bat.3.10 bar.1.14))
           (bar.0.11 (foobar.9.9 bat.3.10 rbp tmp-ra.23 bar.1.14 bat.7.13 ball.5.12 r9 r8))
           (tmp-ra.23 (foobar.9.9 bat.3.10
                                  bar.0.11
                                  ball.5.12
                                  bat.7.13
                                  bar.1.14
                                  rbp
                                  r9
                                  r8
                                  rcx
                                  rdx
                                  rsi
                                  rdi
                                  bat.8.15
                                  foobar.9.16
                                  bat.7.17
                                  rax))
           (foobar.9.9 (rbp tmp-ra.23 bat.3.10 bar.1.14 bar.0.11 bat.7.13 ball.5.12))
           (rax (rbp tmp-ra.23))
           (rbp (foobar.9.9 bat.3.10
                            bar.0.11
                            ball.5.12
                            bat.7.13
                            bar.1.14
                            tmp-ra.23
                            bat.8.15
                            foobar.9.16
                            bat.7.17
                            rax))
           (rdi (tmp-ra.23))
           (rsi (bar.1.14 tmp-ra.23))
           (rdx (bat.7.13 bar.1.14 tmp-ra.23))
           (rcx (ball.5.12 bat.7.13 bar.1.14 tmp-ra.23))
           (r8 (bar.0.11 ball.5.12 bat.7.13 bar.1.14 tmp-ra.23))
           (r9 (bat.3.10 bar.0.11 ball.5.12 bat.7.13 bar.1.14 tmp-ra.23))))
         (assignment ()))
        (begin
          (set! tmp-ra.23 r15)
          (set! bar.1.14 rdi)
          (set! bat.7.13 rsi)
          (set! ball.5.12 rdx)
          (set! bar.0.11 rcx)
          (set! bat.3.10 r8)
          (set! foobar.9.9 r9)
          (if (if (>= bat.3.10 bar.1.14)
                  (> bat.7.13 -9223372036854775808)
                  (>= ball.5.12 bat.3.10))
              (begin
                (set! bat.7.17 bar.0.11)
                (set! foobar.9.16 9223372036854775807)
                (set! bat.8.15 bar.1.14)
                (set! rax bat.3.10)
                (jump tmp-ra.23 rbp rax))
              (if (< bat.3.10 bar.1.14)
                  (begin
                    (set! rax bar.0.11)
                    (jump tmp-ra.23 rbp rax))
                  (begin
                    (set! rax bat.7.13)
                    (jump tmp-ra.23 rbp rax))))))
      (begin
        (set! tmp-ra.24 r15)
        (set! bar.2.20 405359082)
        (if (not (begin
                   (set! tmp.25 -915730633)
                   (>= tmp.25 0)))
            (begin
              (set! bat.8.21 -532660031)
              (set! bat.6.19 -248685178))
            (set! bat.6.19 0))
        (set! bat.7.18 1254220652)
        (set! r9 bar.2.20)
        (set! r8 bat.6.19)
        (set! rcx 9223372036854775807)
        (set! rdx bat.6.19)
        (set! rsi bat.6.19)
        (set! rdi -9223372036854775808)
        (set! r15 tmp-ra.24)
        (jump L.fn.1.2 rbp r15 rdi rsi rdx rcx r8 r9))))
  (check-by-interp
   '(module ((locals (foo.8.17 bar.0.18 tmp-ra.23))
             (conflicts ((tmp-ra.23 (rax foo.8.17 bar.0.18 rbp))
                         (bar.0.18 (foo.8.17 rbp tmp-ra.23))
                         (foo.8.17 (rbp tmp-ra.23 bar.0.18))
                         (rbp (rax foo.8.17 bar.0.18 tmp-ra.23))
                         (rax (rbp tmp-ra.23))))
             (assignment ()))
            (define L.proc.0.1
              ((locals (foo.1.1 foo.5.2 foo.2.3 foobar.7.4 foobar.9.5 tmp-ra.19))
               (conflicts
                ((tmp-ra.19 (foo.1.1 foo.5.2 foo.2.3 foobar.7.4 foobar.9.5 rbp r8 rcx rdx rsi rdi))
                 (foobar.9.5 (rbp tmp-ra.19 r8 rcx rdx rsi))
                 (foobar.7.4 (rbp tmp-ra.19 r8 rcx rdx))
                 (foo.2.3 (rdx foo.1.1 foo.5.2 rbp tmp-ra.19 r8 rcx))
                 (foo.5.2 (rbp tmp-ra.19 foo.2.3 r8))
                 (foo.1.1 (rsi rdx rcx r8 rbp tmp-ra.19 foo.2.3))
                 (rdi (r15 rbp rsi rdx rcx r8 tmp-ra.19))
                 (rsi (r15 rdi rbp rdx rcx r8 foo.1.1 foobar.9.5 tmp-ra.19))
                 (rdx (r15 rdi rsi rbp rcx r8 foo.1.1 foo.2.3 foobar.7.4 foobar.9.5 tmp-ra.19))
                 (rcx (r15 rdi rsi rdx rbp r8 foo.1.1 foo.2.3 foobar.7.4 foobar.9.5 tmp-ra.19))
                 (r8
                  (r15 rdi rsi rdx rcx rbp foo.1.1 foo.5.2 foo.2.3 foobar.7.4 foobar.9.5 tmp-ra.19))
                 (rbp
                  (r15 rdi rsi rdx rcx r8 foo.1.1 foo.5.2 foo.2.3 foobar.7.4 foobar.9.5 tmp-ra.19))
                 (r15 (rbp rdi rsi rdx rcx r8))))
               (assignment ()))
              (begin
                (set! tmp-ra.19 r15)
                (set! foobar.9.5 rdi)
                (set! foobar.7.4 rsi)
                (set! foo.2.3 rdx)
                (set! foo.5.2 rcx)
                (set! foo.1.1 r8)
                (set! r8 1)
                (set! rcx -1754605622)
                (set! rdx -675715652)
                (set! rsi foo.2.3)
                (set! rdi foo.1.1)
                (set! r15 tmp-ra.19)
                (jump L.proc.0.1 rbp r15 rdi rsi rdx rcx r8)))
      (define L.func.1.2
        ((locals (foo.1.6 foobar.3.7 tmp-ra.20))
         (conflicts ((tmp-ra.20 (rdx rcx r8 foo.1.6 foobar.3.7 rbp rsi rdi))
                     (foobar.3.7 (rcx r8 foo.1.6 rbp tmp-ra.20 rsi))
                     (foo.1.6 (rsi rdx rbp tmp-ra.20 foobar.3.7))
                     (rdi (r15 rbp rsi rdx rcx r8 tmp-ra.20))
                     (rsi (r15 rdi rbp rdx rcx r8 foo.1.6 foobar.3.7 tmp-ra.20))
                     (rbp (r15 rdi rsi rdx rcx r8 foo.1.6 foobar.3.7 tmp-ra.20))
                     (r8 (r15 rdi rsi rdx rcx rbp tmp-ra.20 foobar.3.7))
                     (rcx (r15 rdi rsi rdx rbp r8 tmp-ra.20 foobar.3.7))
                     (rdx (r15 rdi rsi rbp rcx r8 tmp-ra.20 foo.1.6))
                     (r15 (rbp rdi rsi rdx rcx r8))))
         (assignment ()))
        (begin
          (set! tmp-ra.20 r15)
          (set! foobar.3.7 rdi)
          (set! foo.1.6 rsi)
          (set! r8 foo.1.6)
          (set! rcx foo.1.6)
          (set! rdx foobar.3.7)
          (set! rsi foobar.3.7)
          (set! rdi foo.1.6)
          (set! r15 tmp-ra.20)
          (jump L.proc.0.1 rbp r15 rdi rsi rdx rcx r8)))
      (define L.x.2.3
        ((locals (foo.1.15 tmp.24 foobar.9.16 foo.1.9 bat.6.10 foo.8.12 foobar.9.13))
         (conflicts
          ((tmp-ra.21 (foo.1.15 tmp.24
                                rax
                                foobar.9.16
                                foobar.7.8
                                foo.1.9
                                bat.6.10
                                bar.4.11
                                foo.8.12
                                foobar.9.13
                                bar.0.14
                                rbp
                                fv0
                                r9
                                r8
                                rcx
                                rdx
                                rsi
                                rdi))
           (bar.0.14 (foo.1.15 tmp.24
                               rax
                               foobar.9.16
                               foobar.7.8
                               foo.1.9
                               bat.6.10
                               bar.4.11
                               foo.8.12
                               foobar.9.13
                               rbp
                               tmp-ra.21
                               fv0
                               r9
                               r8
                               rcx
                               rdx
                               rsi))
           (foobar.9.13
            (foobar.7.8 foo.1.9 bat.6.10 bar.4.11 foo.8.12 rbp tmp-ra.21 bar.0.14 fv0 r9 r8 rcx rdx))
           (foo.8.12 (rdx nfv.22
                          foobar.7.8
                          foo.1.9
                          bat.6.10
                          bar.4.11
                          rbp
                          tmp-ra.21
                          bar.0.14
                          foobar.9.13
                          fv0
                          r9
                          r8
                          rcx))
           (bar.4.11 (rdx rcx
                          foo.1.15
                          tmp.24
                          nfv.22
                          rax
                          foobar.9.16
                          foobar.7.8
                          foo.1.9
                          bat.6.10
                          rbp
                          tmp-ra.21
                          bar.0.14
                          foobar.9.13
                          foo.8.12
                          fv0
                          r9
                          r8))
           (bat.6.10 (r8 nfv.22
                         foobar.7.8
                         foo.1.9
                         rbp
                         tmp-ra.21
                         bar.4.11
                         bar.0.14
                         foobar.9.13
                         foo.8.12
                         fv0
                         r9))
           (foo.1.9
            (nfv.22 foobar.7.8 rbp tmp-ra.21 bar.4.11 bar.0.14 foobar.9.13 foo.8.12 bat.6.10 fv0))
           (foobar.7.8 (rsi r8
                            r9
                            fv0
                            foo.1.15
                            tmp.24
                            rax
                            foobar.9.16
                            rbp
                            tmp-ra.21
                            bar.4.11
                            bar.0.14
                            foobar.9.13
                            foo.8.12
                            bat.6.10
                            foo.1.9))
           (nfv.22 (r15 rdi rsi rdx rcx r8 r9 rbp foo.8.12 bat.6.10 bar.4.11 foo.1.9))
           (foobar.9.16 (rbp tmp-ra.21 foobar.7.8 bar.4.11 bar.0.14))
           (tmp.24 (bar.4.11 rbp tmp-ra.21 foobar.7.8 bar.0.14))
           (foo.1.15 (rbp tmp-ra.21 foobar.7.8 bar.4.11 bar.0.14))
           (rdi (fv0 r15 rbp rsi rdx rcx r8 r9 nfv.22 tmp-ra.21))
           (rsi (fv0 foobar.7.8 r15 rdi rbp rdx rcx r8 r9 nfv.22 bar.0.14 tmp-ra.21))
           (rdx
            (fv0 bar.4.11 r15 rdi rsi rbp rcx r8 r9 nfv.22 foo.8.12 foobar.9.13 bar.0.14 tmp-ra.21))
           (rcx
            (fv0 bar.4.11 r15 rdi rsi rdx rbp r8 r9 nfv.22 foo.8.12 foobar.9.13 bar.0.14 tmp-ra.21))
           (r8 (fv0 foobar.7.8
                    r15
                    rdi
                    rsi
                    rdx
                    rcx
                    rbp
                    r9
                    nfv.22
                    bat.6.10
                    bar.4.11
                    foo.8.12
                    foobar.9.13
                    bar.0.14
                    tmp-ra.21))
           (r9 (fv0 foobar.7.8
                    r15
                    rdi
                    rsi
                    rdx
                    rcx
                    r8
                    rbp
                    nfv.22
                    bat.6.10
                    bar.4.11
                    foo.8.12
                    foobar.9.13
                    bar.0.14
                    tmp-ra.21))
           (fv0 (r15 rdi
                     rsi
                     rdx
                     rcx
                     r8
                     r9
                     rbp
                     foobar.7.8
                     foo.1.9
                     bat.6.10
                     bar.4.11
                     foo.8.12
                     foobar.9.13
                     bar.0.14
                     tmp-ra.21))
           (rbp (fv0 foo.1.15
                     tmp.24
                     r15
                     rdi
                     rsi
                     rdx
                     rcx
                     r8
                     r9
                     nfv.22
                     rax
                     foobar.9.16
                     foobar.7.8
                     foo.1.9
                     bat.6.10
                     bar.4.11
                     foo.8.12
                     foobar.9.13
                     bar.0.14
                     tmp-ra.21))
           (rax (rbp tmp-ra.21 foobar.7.8 bar.4.11 bar.0.14))
           (r15 (fv0 rbp rdi rsi rdx rcx r8 r9 nfv.22))))
         (assignment ((tmp-ra.21 fv1) (foobar.7.8 fv2) (bar.4.11 fv3) (bar.0.14 fv4) (nfv.22 fv5))))
        (begin
          (set! tmp-ra.21 r15)
          (set! bar.0.14 rdi)
          (set! foobar.9.13 rsi)
          (set! foo.8.12 rdx)
          (set! bar.4.11 rcx)
          (set! bat.6.10 r8)
          (set! foo.1.9 r9)
          (set! foobar.7.8 fv0)
          (if (>= bar.4.11 foobar.7.8)
              (set! foobar.9.16 foobar.9.13)
              (begin
                (begin
                  (set! rbp (- rbp 40))
                  (return-point L.rp.4
                                (begin
                                  (set! nfv.22 1783645727)
                                  (set! r9 foo.1.9)
                                  (set! r8 bar.4.11)
                                  (set! rcx bat.6.10)
                                  (set! rdx 0)
                                  (set! rsi foo.8.12)
                                  (set! rdi 1)
                                  (set! r15 L.rp.4)
                                  (jump L.x.2.3 rbp r15 rdi rsi rdx rcx r8 r9 nfv.22)))
                  (set! rbp (+ rbp 40)))
                (set! foobar.9.16 rax)))
          (set! tmp.24 bar.4.11)
          (set! tmp.24 (* tmp.24 bar.4.11))
          (set! foo.1.15 tmp.24)
          (set! fv0 bar.4.11)
          (set! r9 bar.0.14)
          (set! r8 -922337918)
          (set! rcx foobar.7.8)
          (set! rdx foobar.7.8)
          (set! rsi bar.4.11)
          (set! rdi foobar.7.8)
          (set! r15 tmp-ra.21)
          (jump L.x.2.3 rbp r15 rdi rsi rdx rcx r8 r9 fv0)))
      (begin
        (set! tmp-ra.23 r15)
        (set! bar.0.18 0)
        (set! foo.8.17 1029279872)
        (set! rax bar.0.18)
        (jump tmp-ra.23 rbp rax))))
  (check-by-interp
   '(module ((locals (tmp-ra.6 tmp.8 tmp.7 ball.5.5 bat.1.4 bar.8.3 foobar.0.1 bat.2.2))
             (conflicts
              ((bat.2.2 (foobar.0.1 rbp tmp-ra.6))
               (foobar.0.1 (rbp tmp-ra.6 bat.2.2))
               (bar.8.3 (rbp tmp-ra.6 ball.5.5))
               (bat.1.4 (rbp tmp-ra.6 ball.5.5))
               (ball.5.5 (bar.8.3 bat.1.4 rbp tmp-ra.6))
               (tmp.7 (rbp tmp-ra.6))
               (tmp.8 (rbp tmp-ra.6))
               (tmp-ra.6 (rbp foobar.0.1 bat.2.2 bar.8.3 bat.1.4 ball.5.5 tmp.7 tmp.8 rax))
               (rax (rbp tmp-ra.6))
               (rbp (tmp-ra.6 foobar.0.1 bat.2.2 bar.8.3 bat.1.4 ball.5.5 tmp.7 tmp.8 rax))))
             (assignment ()))
            (begin
              (set! tmp-ra.6 r15)
              (if (if (begin
                        (set! bat.2.2 1)
                        (set! foobar.0.1 -1606724555)
                        (= bat.2.2 bat.2.2))
                      (begin
                        (set! ball.5.5 1)
                        (set! bat.1.4 1)
                        (set! bar.8.3 -9223372036854775808)
                        (<= ball.5.5 ball.5.5))
                      (begin
                        (begin
                          (set! tmp.7 -1879829070)
                          (!= tmp.7 1981475003))))
                  (begin
                    (set! tmp.8 -634246165)
                    (set! tmp.8 (- tmp.8 -684848771))
                    (set! rax tmp.8)
                    (jump tmp-ra.6 rbp rax))
                  (begin
                    (set! rax 0)
                    (jump tmp-ra.6 rbp rax))))
      ))
  (check-by-interp '(module ((locals (bar.9.7 tmp-ra.10))
                             (conflicts ((tmp-ra.10 (rax bar.9.7 rbp)) (bar.9.7 (rbp tmp-ra.10))
                                                                       (rbp (rax bar.9.7 tmp-ra.10))
                                                                       (rax (rbp tmp-ra.10))))
                             (assignment ()))
                            (define L.func.0.1
                              ((locals (bar.6.1 foo.3.2 bat.2.3 tmp-ra.8))
                               (conflicts ((tmp-ra.8 (bar.6.1 foo.3.2 bat.2.3 rbp rdx rsi rdi))
                                           (bat.2.3 (bar.6.1 foo.3.2 rbp tmp-ra.8 rdx rsi))
                                           (foo.3.2 (rbp tmp-ra.8 bat.2.3 rdx))
                                           (bar.6.1 (rbp tmp-ra.8 bat.2.3))
                                           (rdi (r15 rbp rsi rdx tmp-ra.8))
                                           (rsi (r15 rdi rbp rdx bat.2.3 tmp-ra.8))
                                           (rdx (r15 rdi rsi rbp foo.3.2 bat.2.3 tmp-ra.8))
                                           (rbp (r15 rdi rsi rdx bar.6.1 foo.3.2 bat.2.3 tmp-ra.8))
                                           (r15 (rbp rdi rsi rdx))))
                               (assignment ()))
                              (begin
                                (set! tmp-ra.8 r15)
                                (set! bat.2.3 rdi)
                                (set! foo.3.2 rsi)
                                (set! bar.6.1 rdx)
                                (set! rdx bat.2.3)
                                (set! rsi -1803672217)
                                (set! rdi bat.2.3)
                                (set! r15 tmp-ra.8)
                                (jump L.proc.1.2 rbp r15 rdi rsi rdx)))
                      (define L.proc.1.2
                        ((locals (bat.1.4 ball.0.5 foo.3.6 tmp-ra.9))
                         (conflicts ((tmp-ra.9 (bat.1.4 ball.0.5 foo.3.6 rbp rdx rsi rdi))
                                     (foo.3.6 (rbp tmp-ra.9 rdx rsi))
                                     (ball.0.5 (bat.1.4 rbp tmp-ra.9 rdx))
                                     (bat.1.4 (rbp tmp-ra.9 ball.0.5))
                                     (rdi (r15 rbp rsi rdx tmp-ra.9))
                                     (rsi (r15 rdi rbp rdx foo.3.6 tmp-ra.9))
                                     (rdx (r15 rdi rsi rbp ball.0.5 foo.3.6 tmp-ra.9))
                                     (rbp (r15 rdi rsi rdx bat.1.4 ball.0.5 foo.3.6 tmp-ra.9))
                                     (r15 (rbp rdi rsi rdx))))
                         (assignment ()))
                        (begin
                          (set! tmp-ra.9 r15)
                          (set! foo.3.6 rdi)
                          (set! ball.0.5 rsi)
                          (set! bat.1.4 rdx)
                          (set! rdx bat.1.4)
                          (set! rsi ball.0.5)
                          (set! rdi 1)
                          (set! r15 tmp-ra.9)
                          (jump L.proc.1.2 rbp r15 rdi rsi rdx)))
                      (begin
                        (set! tmp-ra.10 r15)
                        (set! bar.9.7 0)
                        (set! rax bar.9.7)
                        (jump tmp-ra.10 rbp rax))))
  (check-by-interp
   '(module ((locals (tmp.7 ball.0.1 bar.6.2 foobar.7.3 ball.0.4 bat.2.5 tmp-ra.6))
             (conflicts ((tmp-ra.6 (rax tmp.7 ball.0.1 bar.6.2 foobar.7.3 ball.0.4 bat.2.5 rbp))
                         (bat.2.5 (rbp tmp-ra.6))
                         (ball.0.4 (foobar.7.3 rbp tmp-ra.6))
                         (foobar.7.3 (rbp tmp-ra.6 ball.0.4))
                         (bar.6.2 (rbp tmp-ra.6))
                         (ball.0.1 (tmp.7 rbp tmp-ra.6))
                         (tmp.7 (rbp tmp-ra.6 ball.0.1))
                         (rbp (rax tmp.7 ball.0.1 bar.6.2 foobar.7.3 ball.0.4 bat.2.5 tmp-ra.6))
                         (rax (rbp tmp-ra.6))))
             (assignment ()))
            (begin
              (set! tmp-ra.6 r15)
              (set! bat.2.5 1550347185)
              (set! ball.0.4 9223372036854775807)
              (set! foobar.7.3 -9223372036854775808)
              (set! bar.6.2 ball.0.4)
              (set! ball.0.1 bar.6.2)
              (set! tmp.7 9223372036854775807)
              (set! tmp.7 (- tmp.7 ball.0.1))
              (set! rax tmp.7)
              (jump tmp-ra.6 rbp rax))
      ))
  (check-by-interp
   '(module ((locals (foo.1.12 ball.9.13 tmp-ra.15))
             (conflicts ((tmp-ra.15 (rax foo.1.12 ball.9.13 rbp))
                         (ball.9.13 (rbp tmp-ra.15))
                         (foo.1.12 (rbp tmp-ra.15))
                         (rbp (rax foo.1.12 ball.9.13 tmp-ra.15))
                         (rax (rbp tmp-ra.15))))
             (assignment ()))
            (define L.proc.0.1
              ((locals (foo.8.7 ball.9.8 ball.4.11 foo.8.10 bar.6.4))
               (conflicts
                ((bar.6.4 (rbp tmp-ra.14 foo.1.1 bar.3.6 ball.9.5))
                 (foo.1.1 (bar.6.4 foo.8.7
                                   ball.9.8
                                   ball.2.9
                                   ball.9.5
                                   rdx
                                   bar.3.6
                                   rax
                                   rbp
                                   tmp-ra.14
                                   bar.3.2
                                   bar.6.3))
                 (tmp-ra.14 (bar.6.4 foo.8.7
                                     ball.9.8
                                     ball.2.9
                                     ball.9.5
                                     bar.3.6
                                     foo.1.1
                                     bar.3.2
                                     bar.6.3
                                     rbp
                                     rdx
                                     rsi
                                     rdi
                                     rax
                                     foo.8.10
                                     ball.4.11))
                 (bar.3.6 (bar.6.4 foo.8.7
                                   ball.9.8
                                   ball.2.9
                                   ball.9.5
                                   rax
                                   rbp
                                   tmp-ra.14
                                   foo.1.1
                                   bar.3.2
                                   bar.6.3
                                   ball.4.11))
                 (ball.9.5 (bar.6.4 foo.8.7
                                    ball.9.8
                                    ball.2.9
                                    rax
                                    rbp
                                    tmp-ra.14
                                    foo.1.1
                                    bar.3.6
                                    bar.3.2
                                    bar.6.3
                                    foo.8.10
                                    ball.4.11))
                 (foo.8.10 (rbp tmp-ra.14 ball.9.5))
                 (ball.4.11 (rbp tmp-ra.14 ball.9.5 bar.3.6))
                 (bar.6.3 (ball.9.5 bar.3.6 rax foo.1.1 bar.3.2 rbp tmp-ra.14 rdx rsi))
                 (bar.3.2 (ball.2.9 ball.9.5 bar.3.6 rax foo.1.1 rbp tmp-ra.14 bar.6.3 rdx))
                 (ball.2.9 (foo.8.7 rax ball.9.8 rbp tmp-ra.14 foo.1.1 bar.3.6 ball.9.5 bar.3.2))
                 (ball.9.8 (rbp tmp-ra.14 foo.1.1 bar.3.6 ball.9.5 ball.2.9))
                 (foo.8.7 (rdx rbp tmp-ra.14 foo.1.1 bar.3.6 ball.9.5 ball.2.9))
                 (rbp (bar.6.4 foo.8.7
                               ball.9.8
                               ball.2.9
                               ball.9.5
                               bar.3.6
                               r15
                               rdi
                               rsi
                               rdx
                               foo.1.1
                               bar.3.2
                               bar.6.3
                               tmp-ra.14
                               rax
                               foo.8.10
                               ball.4.11))
                 (rax (ball.2.9 ball.9.5 bar.3.6 foo.1.1 bar.3.2 bar.6.3 rbp tmp-ra.14))
                 (rdi (r15 rbp rsi rdx tmp-ra.14))
                 (rsi (r15 rdi rbp rdx bar.6.3 tmp-ra.14))
                 (rdx (foo.8.7 foo.1.1 r15 rdi rsi rbp bar.3.2 bar.6.3 tmp-ra.14))
                 (r15 (rbp rdi rsi rdx))))
               (assignment ((tmp-ra.14 fv0) (foo.1.1 fv1)
                                            (bar.3.2 fv2)
                                            (bar.6.3 fv3)
                                            (ball.9.5 fv4)
                                            (ball.2.9 fv3)
                                            (bar.3.6 fv5))))
              (begin
                (set! tmp-ra.14 r15)
                (set! bar.6.3 rdi)
                (set! bar.3.2 rsi)
                (set! foo.1.1 rdx)
                (begin
                  (set! rbp (- rbp 56))
                  (return-point L.rp.2
                                (begin
                                  (set! rdx foo.1.1)
                                  (set! rsi foo.1.1)
                                  (set! rdi 9223372036854775807)
                                  (set! r15 L.rp.2)
                                  (jump L.proc.0.1 rbp r15 rdi rsi rdx)))
                  (set! rbp (+ rbp 56)))
                (set! bar.3.6 rax)
                (begin
                  (set! rbp (- rbp 56))
                  (return-point L.rp.3
                                (begin
                                  (set! rdx bar.6.3)
                                  (set! rsi foo.1.1)
                                  (set! rdi bar.6.3)
                                  (set! r15 L.rp.3)
                                  (jump L.proc.0.1 rbp r15 rdi rsi rdx)))
                  (set! rbp (+ rbp 56)))
                (set! ball.9.5 rax)
                (begin
                  (set! rbp (- rbp 56))
                  (return-point L.rp.4
                                (begin
                                  (set! rdx bar.6.3)
                                  (set! rsi foo.1.1)
                                  (set! rdi foo.1.1)
                                  (set! r15 L.rp.4)
                                  (jump L.proc.0.1 rbp r15 rdi rsi rdx)))
                  (set! rbp (+ rbp 56)))
                (set! ball.2.9 rax)
                (set! ball.9.8 bar.3.2)
                (begin
                  (set! rbp (- rbp 56))
                  (return-point L.rp.5
                                (begin
                                  (set! rdx bar.3.2)
                                  (set! rsi foo.1.1)
                                  (set! rdi foo.1.1)
                                  (set! r15 L.rp.5)
                                  (jump L.proc.0.1 rbp r15 rdi rsi rdx)))
                  (set! rbp (+ rbp 56)))
                (set! foo.8.7 rax)
                (begin
                  (set! rbp (- rbp 56))
                  (return-point L.rp.6
                                (begin
                                  (set! rdx ball.2.9)
                                  (set! rsi foo.8.7)
                                  (set! rdi foo.8.7)
                                  (set! r15 L.rp.6)
                                  (jump L.proc.0.1 rbp r15 rdi rsi rdx)))
                  (set! rbp (+ rbp 56)))
                (set! bar.6.4 rax)
                (if (> bar.6.4 foo.1.1)
                    (if (>= bar.3.6 bar.3.6)
                        (begin
                          (set! rax foo.1.1)
                          (jump tmp-ra.14 rbp rax))
                        (begin
                          (set! rax bar.6.4)
                          (jump tmp-ra.14 rbp rax)))
                    (begin
                      (set! ball.4.11 -2087609688)
                      (set! foo.8.10 bar.3.6)
                      (set! rax ball.9.5)
                      (jump tmp-ra.14 rbp rax)))))
      (begin
        (set! tmp-ra.15 r15)
        (set! ball.9.13 1)
        (set! foo.1.12 -9223372036854775808)
        (set! rax foo.1.12)
        (jump tmp-ra.15 rbp rax))))
  (check-by-interp
   '(module ((locals (bat.4.16 tmp.23 tmp-ra.20))
             (conflicts ((tmp-ra.20 (rax bat.4.16 tmp.23 rbp)) (tmp.23 (rbp tmp-ra.20))
                                                               (bat.4.16 (rbp tmp-ra.20))
                                                               (rbp (rax bat.4.16 tmp.23 tmp-ra.20))
                                                               (rax (rbp tmp-ra.20))))
             (assignment ()))
            (define L.fn.0.1
              ((locals (bar.0.1 tmp-ra.17)) (conflicts ((tmp-ra.17 (bar.0.1 rbp rdi rsi rdx rcx))
                                                        (bar.0.1 (rbp tmp-ra.17 rcx))
                                                        (rcx (bar.0.1 r15 rdi rsi rdx rbp tmp-ra.17))
                                                        (rbp (bar.0.1 tmp-ra.17 r15 rdi rsi rdx rcx))
                                                        (rdx (r15 rdi rsi rbp rcx tmp-ra.17))
                                                        (rsi (r15 rdi rbp rdx rcx tmp-ra.17))
                                                        (rdi (r15 rbp rsi rdx rcx tmp-ra.17))
                                                        (r15 (rbp rdi rsi rdx rcx))))
                                            (assignment ()))
              (begin
                (set! tmp-ra.17 r15)
                (set! bar.0.1 rdi)
                (if (true)
                    (begin
                      (set! rcx 2099518136)
                      (set! rdx bar.0.1)
                      (set! rsi bar.0.1)
                      (set! rdi bar.0.1)
                      (set! r15 tmp-ra.17)
                      (jump L.func.2.3 rbp r15 rdi rsi rdx rcx))
                    (begin
                      (set! rcx bar.0.1)
                      (set! rdx bar.0.1)
                      (set! rsi bar.0.1)
                      (set! rdi bar.0.1)
                      (set! r15 tmp-ra.17)
                      (jump L.func.2.3 rbp r15 rdi rsi rdx rcx)))))
      (define L.tmp.1.2
        ((locals (foobar.6.8 ball.1.11
                             tmp.22
                             foo.5.9
                             tmp.21
                             bar.0.10
                             bar.0.2
                             ball.8.3
                             bar.2.4
                             foo.5.5
                             foobar.3.6
                             foobar.6.7
                             tmp-ra.18))
         (conflicts
          ((tmp-ra.18 (foobar.6.8 ball.1.11
                                  tmp.22
                                  foo.5.9
                                  tmp.21
                                  bar.0.10
                                  bar.0.2
                                  ball.8.3
                                  bar.2.4
                                  foo.5.5
                                  foobar.3.6
                                  foobar.6.7
                                  rbp
                                  r9
                                  r8
                                  rcx
                                  rdx
                                  rsi
                                  rdi))
           (foobar.6.7 (rbp tmp-ra.18 r9 r8 rcx rdx rsi))
           (foobar.3.6 (ball.1.11 tmp.22
                                  foo.5.9
                                  tmp.21
                                  bar.0.10
                                  bar.0.2
                                  ball.8.3
                                  bar.2.4
                                  foo.5.5
                                  rbp
                                  tmp-ra.18
                                  r9
                                  r8
                                  rcx
                                  rdx))
           (foo.5.5 (bar.0.10 bar.0.2 ball.8.3 bar.2.4 rbp tmp-ra.18 foobar.3.6 r9 r8 rcx))
           (bar.2.4 (foo.5.9 tmp.21 bar.0.10 bar.0.2 ball.8.3 rbp tmp-ra.18 foobar.3.6 foo.5.5 r9 r8))
           (ball.8.3 (rbp tmp-ra.18 foobar.3.6 bar.2.4 foo.5.5 r9))
           (bar.0.2 (rbp tmp-ra.18 foobar.3.6 bar.2.4 foo.5.5))
           (bar.0.10 (rbp tmp-ra.18 foobar.3.6 bar.2.4 foo.5.5))
           (tmp.21 (rbp tmp-ra.18 foobar.3.6 bar.2.4))
           (foo.5.9 (rbp tmp-ra.18 foobar.3.6 bar.2.4))
           (tmp.22 (rbp tmp-ra.18 foobar.3.6))
           (ball.1.11 (rbp tmp-ra.18 foobar.3.6))
           (foobar.6.8 (rbp tmp-ra.18))
           (rdi (r15 rbp tmp-ra.18))
           (rsi (foobar.6.7 tmp-ra.18))
           (rdx (foobar.3.6 foobar.6.7 tmp-ra.18))
           (rcx (foo.5.5 foobar.3.6 foobar.6.7 tmp-ra.18))
           (r8 (bar.2.4 foo.5.5 foobar.3.6 foobar.6.7 tmp-ra.18))
           (r9 (ball.8.3 bar.2.4 foo.5.5 foobar.3.6 foobar.6.7 tmp-ra.18))
           (rbp (r15 rdi
                     foobar.6.8
                     ball.1.11
                     tmp.22
                     foo.5.9
                     tmp.21
                     bar.0.10
                     bar.0.2
                     ball.8.3
                     bar.2.4
                     foo.5.5
                     foobar.3.6
                     foobar.6.7
                     tmp-ra.18))
           (r15 (rbp rdi))))
         (assignment ()))
        (begin
          (set! tmp-ra.18 r15)
          (set! foobar.6.7 rdi)
          (set! foobar.3.6 rsi)
          (set! foo.5.5 rdx)
          (set! bar.2.4 rcx)
          (set! ball.8.3 r8)
          (set! bar.0.2 r9)
          (set! bar.0.10 9223372036854775807)
          (set! tmp.21 foo.5.5)
          (set! tmp.21 (+ tmp.21 foobar.3.6))
          (set! foo.5.9 tmp.21)
          (set! tmp.22 bar.2.4)
          (set! tmp.22 (+ tmp.22 foobar.3.6))
          (set! ball.1.11 tmp.22)
          (set! foobar.6.8 foobar.3.6)
          (set! rdi 0)
          (set! r15 tmp-ra.18)
          (jump L.fn.0.1 rbp r15 rdi)))
      (define L.func.2.3
        ((locals (foobar.6.12 bar.0.13 ball.8.14 ball.9.15 tmp-ra.19))
         (conflicts
          ((tmp-ra.19 (r8 r9 foobar.6.12 bar.0.13 ball.8.14 ball.9.15 rbp rcx rdx rsi rdi))
           (ball.9.15 (r8 r9 foobar.6.12 bar.0.13 ball.8.14 rbp tmp-ra.19 rcx rdx rsi))
           (ball.8.14 (rbp tmp-ra.19 ball.9.15 rcx rdx))
           (bar.0.13 (r9 foobar.6.12 rbp tmp-ra.19 ball.9.15 rcx))
           (foobar.6.12 (rcx r8 r9 rbp tmp-ra.19 ball.9.15 bar.0.13))
           (rdi (r15 rbp rsi rdx rcx r8 r9 tmp-ra.19))
           (rsi (r15 rdi rbp rdx rcx r8 r9 ball.9.15 tmp-ra.19))
           (rdx (r15 rdi rsi rbp rcx r8 r9 ball.8.14 ball.9.15 tmp-ra.19))
           (rcx (r15 rdi rsi rdx rbp r8 r9 foobar.6.12 bar.0.13 ball.8.14 ball.9.15 tmp-ra.19))
           (rbp (r15 rdi rsi rdx rcx r8 r9 foobar.6.12 bar.0.13 ball.8.14 ball.9.15 tmp-ra.19))
           (r9 (r15 rdi rsi rdx rcx r8 rbp tmp-ra.19 foobar.6.12 ball.9.15 bar.0.13))
           (r8 (r15 rdi rsi rdx rcx rbp r9 tmp-ra.19 foobar.6.12 ball.9.15))
           (r15 (rbp rdi rsi rdx rcx r8 r9))))
         (assignment ()))
        (begin
          (set! tmp-ra.19 r15)
          (set! ball.9.15 rdi)
          (set! ball.8.14 rsi)
          (set! bar.0.13 rdx)
          (set! foobar.6.12 rcx)
          (set! r9 9223372036854775807)
          (set! r8 bar.0.13)
          (set! rcx ball.9.15)
          (set! rdx foobar.6.12)
          (set! rsi foobar.6.12)
          (set! rdi 1)
          (set! r15 tmp-ra.19)
          (jump L.tmp.1.2 rbp r15 rdi rsi rdx rcx r8 r9)))
      (begin
        (set! tmp-ra.20 r15)
        (set! tmp.23 1)
        (set! tmp.23 (+ tmp.23 9223372036854775807))
        (set! bat.4.16 tmp.23)
        (set! rax bat.4.16)
        (jump tmp-ra.20 rbp rax))))

  (check-by-interp '(module ((locals (bat.0.1 foobar.1.2 tmp-ra.3))
                             (conflicts ((tmp-ra.3 (rax bat.0.1 foobar.1.2 rbp))
                                         (foobar.1.2 (rbp tmp-ra.3))
                                         (bat.0.1 (rbp tmp-ra.3))
                                         (rbp (rax bat.0.1 foobar.1.2 tmp-ra.3))
                                         (rax (rbp tmp-ra.3))))
                             (assignment ()))
                            (begin
                              (set! tmp-ra.3 r15)
                              (set! foobar.1.2 0)
                              (set! bat.0.1 1)
                              (set! rax bat.0.1)
                              (jump tmp-ra.3 rbp rax))
                      ))
  (check-by-interp
   '(module ((locals (tmp-ra.9)) (conflicts ((tmp-ra.9 (rdi rsi rdx rcx r8 r9 rbp))
                                             (rbp (r15 rdi rsi rdx rcx r8 r9 tmp-ra.9))
                                             (r9 (r15 rdi rsi rdx rcx r8 rbp tmp-ra.9))
                                             (r8 (r15 rdi rsi rdx rcx rbp r9 tmp-ra.9))
                                             (rcx (r15 rdi rsi rdx rbp r8 r9 tmp-ra.9))
                                             (rdx (r15 rdi rsi rbp rcx r8 r9 tmp-ra.9))
                                             (rsi (r15 rdi rbp rdx rcx r8 r9 tmp-ra.9))
                                             (rdi (r15 rbp rsi rdx rcx r8 r9 tmp-ra.9))
                                             (r15 (rbp rdi rsi rdx rcx r8 r9))))
                                 (assignment ()))
            (define L.func.0.1
              ((locals (tmp-ra.7)) (conflicts ((tmp-ra.7 (rdi rsi rdx rcx r8 r9 rbp))
                                               (rbp (r15 rdi rsi rdx rcx r8 r9 tmp-ra.7))
                                               (r9 (r15 rdi rsi rdx rcx r8 rbp tmp-ra.7))
                                               (r8 (r15 rdi rsi rdx rcx rbp r9 tmp-ra.7))
                                               (rcx (r15 rdi rsi rdx rbp r8 r9 tmp-ra.7))
                                               (rdx (r15 rdi rsi rbp rcx r8 r9 tmp-ra.7))
                                               (rsi (r15 rdi rbp rdx rcx r8 r9 tmp-ra.7))
                                               (rdi (r15 rbp rsi rdx rcx r8 r9 tmp-ra.7))
                                               (r15 (rbp rdi rsi rdx rcx r8 r9))))
                                   (assignment ()))
              (begin
                (set! tmp-ra.7 r15)
                (set! r9 0)
                (set! r8 1)
                (set! rcx 9223372036854775807)
                (set! rdx 9223372036854775807)
                (set! rsi 1)
                (set! rdi 38797657)
                (set! r15 tmp-ra.7)
                (jump L.x.1.2 rbp r15 rdi rsi rdx rcx r8 r9)))
      (define L.x.1.2
        ((locals (ball.5.5 bat.3.4 foobar.1.2 bar.2.3 bat.7.6 bat.9.1 tmp.10 tmp-ra.8))
         (conflicts
          ((tmp-ra.8 (bat.9.1 foobar.1.2
                              bar.2.3
                              bat.3.4
                              ball.5.5
                              bat.7.6
                              rbp
                              rax
                              tmp.10
                              rdi
                              rsi
                              rdx
                              rcx
                              r8
                              r9))
           (tmp.10 (rbp tmp-ra.8 bar.2.3))
           (bat.9.1 (rbp tmp-ra.8 bar.2.3 foobar.1.2 bat.7.6 bat.3.4 r9))
           (bat.7.6 (bat.9.1 foobar.1.2 bar.2.3 bat.3.4 ball.5.5 rbp tmp-ra.8 r9 r8 rcx rdx rsi))
           (bar.2.3 (bat.9.1 foobar.1.2 rbp tmp-ra.8 bat.7.6 bat.3.4 r9 tmp.10 rcx r8))
           (foobar.1.2 (bat.9.1 rbp tmp-ra.8 bar.2.3 bat.7.6 bat.3.4 rdx rcx r8 r9))
           (bat.3.4 (bat.9.1 foobar.1.2 bar.2.3 rbp tmp-ra.8 bat.7.6 rsi rdx rcx r8 r9))
           (ball.5.5 (rbp tmp-ra.8 bat.7.6 r9 r8 rcx rdx))
           (r9
            (bar.2.3 ball.5.5 bat.7.6 r15 rdi rsi rdx rcx r8 rbp tmp-ra.8 bat.3.4 foobar.1.2 bat.9.1))
           (rbp (bat.9.1 foobar.1.2
                         bar.2.3
                         bat.3.4
                         ball.5.5
                         bat.7.6
                         tmp-ra.8
                         rax
                         tmp.10
                         r15
                         rdi
                         rsi
                         rdx
                         rcx
                         r8
                         r9))
           (r8 (ball.5.5 bat.7.6 r15 rdi rsi rdx rcx rbp r9 tmp-ra.8 bat.3.4 foobar.1.2 bar.2.3))
           (rcx (ball.5.5 bat.7.6 r15 rdi rsi rdx rbp r8 r9 tmp-ra.8 bat.3.4 foobar.1.2 bar.2.3))
           (rdx (ball.5.5 bat.7.6 r15 rdi rsi rbp rcx r8 r9 tmp-ra.8 bat.3.4 foobar.1.2))
           (rsi (bat.7.6 r15 rdi rbp rdx rcx r8 r9 tmp-ra.8 bat.3.4))
           (rdi (r15 rbp rsi rdx rcx r8 r9 tmp-ra.8))
           (r15 (rbp rdi rsi rdx rcx r8 r9))
           (rax (rbp tmp-ra.8))))
         (assignment ()))
        (begin
          (set! tmp-ra.8 r15)
          (set! bat.7.6 rdi)
          (set! ball.5.5 rsi)
          (set! bat.3.4 rdx)
          (set! bar.2.3 rcx)
          (set! foobar.1.2 r8)
          (set! bat.9.1 r9)
          (if (true)
              (if (if (>= foobar.1.2 foobar.1.2)
                      (< bat.7.6 bar.2.3)
                      (< bat.9.1 812242710))
                  (begin
                    (set! tmp.10 foobar.1.2)
                    (set! tmp.10 (- tmp.10 bar.2.3))
                    (set! rax tmp.10)
                    (jump tmp-ra.8 rbp rax))
                  (begin
                    (set! r15 tmp-ra.8)
                    (jump L.func.0.1 rbp r15)))
              (begin
                (set! r9 bar.2.3)
                (set! r8 bat.9.1)
                (set! rcx bat.9.1)
                (set! rdx bar.2.3)
                (set! rsi foobar.1.2)
                (set! rdi bat.3.4)
                (set! r15 tmp-ra.8)
                (jump L.x.1.2 rbp r15 rdi rsi rdx rcx r8 r9)))))
      (begin
        (set! tmp-ra.9 r15)
        (set! r9 -9223372036854775808)
        (set! r8 0)
        (set! rcx -9223372036854775808)
        (set! rdx -9223372036854775808)
        (set! rsi -2062025435)
        (set! rdi 0)
        (set! r15 tmp-ra.9)
        (jump L.x.1.2 rbp r15 rdi rsi rdx rcx r8 r9))))
  (check-by-interp
   '(module ((locals (tmp-ra.10)) (conflicts ((tmp-ra.10 (rax rbp)) (rbp (rax tmp-ra.10))
                                                                    (rax (rbp tmp-ra.10))))
                                  (assignment ()))
            (define L.func.0.1
              ((locals (foo.9.1 foo.3.2 foo.7.3 foo.4.4 tmp-ra.8))
               (conflicts ((tmp-ra.8 (foo.9.1 foo.3.2 foo.7.3 foo.4.4 rbp rcx rdx rsi rdi))
                           (foo.4.4 (foo.9.1 foo.3.2 foo.7.3 rbp tmp-ra.8 rcx rdx rsi))
                           (foo.7.3 (rbp tmp-ra.8 foo.4.4 rcx rdx))
                           (foo.3.2 (foo.9.1 rbp tmp-ra.8 foo.4.4 rcx))
                           (foo.9.1 (rbp tmp-ra.8 foo.4.4 foo.3.2))
                           (rdi (r15 rbp rsi rdx tmp-ra.8))
                           (rsi (r15 rdi rbp rdx foo.4.4 tmp-ra.8))
                           (rdx (r15 rdi rsi rbp foo.7.3 foo.4.4 tmp-ra.8))
                           (rcx (foo.3.2 foo.7.3 foo.4.4 tmp-ra.8))
                           (rbp (r15 rdi rsi rdx foo.9.1 foo.3.2 foo.7.3 foo.4.4 tmp-ra.8))
                           (r15 (rbp rdi rsi rdx))))
               (assignment ()))
              (begin
                (set! tmp-ra.8 r15)
                (set! foo.4.4 rdi)
                (set! foo.7.3 rsi)
                (set! foo.3.2 rdx)
                (set! foo.9.1 rcx)
                (set! rdx foo.3.2)
                (set! rsi -9223372036854775808)
                (set! rdi foo.4.4)
                (set! r15 tmp-ra.8)
                (jump L.proc.1.2 rbp r15 rdi rsi rdx)))
      (define L.proc.1.2
        ((locals (tmp.11 foo.7.5 bat.5.6 foo.9.7 tmp-ra.9))
         (conflicts ((tmp-ra.9 (rax tmp.11 foo.7.5 bat.5.6 foo.9.7 rbp rdx rsi rdi))
                     (foo.9.7 (rbp tmp-ra.9 rdx rsi))
                     (bat.5.6 (foo.7.5 rbp tmp-ra.9 rdx))
                     (foo.7.5 (tmp.11 rbp tmp-ra.9 bat.5.6))
                     (tmp.11 (rbp tmp-ra.9 foo.7.5))
                     (rdi (tmp-ra.9))
                     (rsi (foo.9.7 tmp-ra.9))
                     (rdx (bat.5.6 foo.9.7 tmp-ra.9))
                     (rbp (rax tmp.11 foo.7.5 bat.5.6 foo.9.7 tmp-ra.9))
                     (rax (rbp tmp-ra.9))))
         (assignment ()))
        (begin
          (set! tmp-ra.9 r15)
          (set! foo.9.7 rdi)
          (set! bat.5.6 rsi)
          (set! foo.7.5 rdx)
          (set! tmp.11 bat.5.6)
          (set! tmp.11 (- tmp.11 foo.7.5))
          (set! rax tmp.11)
          (jump tmp-ra.9 rbp rax)))
      (begin
        (set! tmp-ra.10 r15)
        (set! rax 1)
        (jump tmp-ra.10 rbp rax))))
  (check-by-interp '(module ((locals (foobar.9.1 ball.3.2 tmp-ra.3))
                             (conflicts ((tmp-ra.3 (rax foobar.9.1 ball.3.2 rbp))
                                         (ball.3.2 (rbp tmp-ra.3))
                                         (foobar.9.1 (rbp tmp-ra.3))
                                         (rbp (rax foobar.9.1 ball.3.2 tmp-ra.3))
                                         (rax (rbp tmp-ra.3))))
                             (assignment ()))
                            (begin
                              (set! tmp-ra.3 r15)
                              (set! ball.3.2 -550916464)
                              (set! foobar.9.1 9223372036854775807)
                              (set! rax foobar.9.1)
                              (jump tmp-ra.3 rbp rax))
                      ))
  (check-by-interp '(module ((locals (tmp.7 tmp.3 tmp.4 tmp.5 tmp-ra.2 tmp.6 bar.1.1))
                             (conflicts ((bar.1.1 (rbp tmp-ra.2))
                                         (tmp.6 (rbp tmp-ra.2))
                                         (tmp-ra.2 (rbp tmp.3 tmp.4 tmp.5 tmp.6 bar.1.1 rax tmp.7))
                                         (tmp.5 (rbp tmp-ra.2))
                                         (tmp.4 (rbp tmp-ra.2))
                                         (tmp.3 (rbp tmp-ra.2))
                                         (tmp.7 (rbp tmp-ra.2))
                                         (rbp (tmp-ra.2 tmp.3 tmp.4 tmp.5 tmp.6 bar.1.1 rax tmp.7))
                                         (rax (rbp tmp-ra.2))))
                             (assignment ()))
                            (begin
                              (set! tmp-ra.2 r15)
                              (if (false)
                                  (if (if (begin
                                            (set! tmp.3 9223372036854775807)
                                            (< tmp.3 1646335033))
                                          (begin
                                            (set! tmp.4 9223372036854775807)
                                            (>= tmp.4 1))
                                          (begin
                                            (set! tmp.5 9223372036854775807)
                                            (!= tmp.5 1)))
                                      (if (begin
                                            (set! tmp.6 -9223372036854775808)
                                            (!= tmp.6 -9223372036854775808))
                                          (begin
                                            (set! rax -9223372036854775808)
                                            (jump tmp-ra.2 rbp rax))
                                          (begin
                                            (set! rax 1282320164)
                                            (jump tmp-ra.2 rbp rax)))
                                      (begin
                                        (set! bar.1.1 -9223372036854775808)
                                        (set! rax bar.1.1)
                                        (jump tmp-ra.2 rbp rax)))
                                  (begin
                                    (set! tmp.7 9223372036854775807)
                                    (set! tmp.7 (- tmp.7 1))
                                    (set! rax tmp.7)
                                    (jump tmp-ra.2 rbp rax))))
                      ))
  (check-by-interp
   '(module ((locals (tmp-ra.17 tmp.19))
             (conflicts ((tmp.19 (rbp tmp-ra.17)) (tmp-ra.17 (rbp tmp.19 rax))
                                                  (rax (rbp tmp-ra.17))
                                                  (rbp (tmp-ra.17 tmp.19 rax))))
             (assignment ()))
            (define L.tmp.0.1
              ((locals (foobar.2.7 bar.0.8
                                   foobar.8.9
                                   bar.1.10
                                   foobar.2.11
                                   ball.4.5
                                   tmp.18
                                   ball.7.6
                                   ball.4.2))
               (conflicts ((tmp-ra.15 (foobar.2.7 bar.0.8
                                                  foobar.8.9
                                                  bar.1.10
                                                  foobar.2.11
                                                  ball.4.5
                                                  tmp.18
                                                  ball.7.6
                                                  rax
                                                  bar.0.1
                                                  ball.4.2
                                                  bat.6.3
                                                  bar.1.4
                                                  rbp
                                                  rcx
                                                  rdx
                                                  rsi
                                                  rdi))
                           (bar.1.4 (foobar.8.9 bar.1.10
                                                foobar.2.11
                                                ball.4.5
                                                tmp.18
                                                ball.7.6
                                                rax
                                                bar.0.1
                                                ball.4.2
                                                bat.6.3
                                                rbp
                                                tmp-ra.15
                                                rcx
                                                rdx
                                                rsi))
                           (bat.6.3 (foobar.2.7 bar.0.8
                                                foobar.8.9
                                                bar.1.10
                                                ball.4.5
                                                tmp.18
                                                ball.7.6
                                                rax
                                                bar.0.1
                                                ball.4.2
                                                rbp
                                                tmp-ra.15
                                                bar.1.4
                                                rcx
                                                rdx))
                           (ball.4.2 (rbp tmp-ra.15 bat.6.3 bar.1.4 rcx))
                           (bar.0.1 (rsi rdx
                                         bar.0.8
                                         bar.1.10
                                         foobar.2.11
                                         ball.4.5
                                         tmp.18
                                         ball.7.6
                                         rcx
                                         rax
                                         rbp
                                         tmp-ra.15
                                         bat.6.3
                                         bar.1.4))
                           (ball.7.6 (rbp tmp-ra.15 bat.6.3 bar.1.4 bar.0.1))
                           (tmp.18 (bat.6.3 rbp tmp-ra.15 bar.1.4 bar.0.1))
                           (ball.4.5 (rbp tmp-ra.15 bat.6.3 bar.1.4 bar.0.1))
                           (foobar.2.11 (rbp tmp-ra.15 bar.1.4 bar.0.1))
                           (bar.1.10 (rbp tmp-ra.15 bat.6.3 bar.1.4 bar.0.1))
                           (foobar.8.9 (rbp tmp-ra.15 bat.6.3 bar.1.4))
                           (bar.0.8 (rbp tmp-ra.15 bat.6.3 bar.0.1))
                           (foobar.2.7 (rbp tmp-ra.15 bat.6.3))
                           (rdi (r15 rbp rsi rdx rcx tmp-ra.15))
                           (rsi (bar.0.1 r15 rdi rbp rdx rcx bar.1.4 tmp-ra.15))
                           (rdx (bar.0.1 r15 rdi rsi rbp rcx bat.6.3 bar.1.4 tmp-ra.15))
                           (rcx (r15 rdi rsi rdx rbp bar.0.1 ball.4.2 bat.6.3 bar.1.4 tmp-ra.15))
                           (rbp (foobar.2.7 bar.0.8
                                            foobar.8.9
                                            bar.1.10
                                            foobar.2.11
                                            ball.4.5
                                            tmp.18
                                            ball.7.6
                                            r15
                                            rdi
                                            rsi
                                            rdx
                                            rcx
                                            rax
                                            bar.0.1
                                            ball.4.2
                                            bat.6.3
                                            bar.1.4
                                            tmp-ra.15))
                           (rax (rbp tmp-ra.15 bat.6.3 bar.1.4 bar.0.1))
                           (r15 (rbp rdi rsi rdx rcx))))
               (assignment ((tmp-ra.15 fv0) (bat.6.3 fv1) (bar.1.4 fv2) (bar.0.1 fv3))))
              (begin
                (set! tmp-ra.15 r15)
                (set! bar.1.4 rdi)
                (set! bat.6.3 rsi)
                (set! ball.4.2 rdx)
                (set! bar.0.1 rcx)
                (begin
                  (set! rbp (- rbp 32))
                  (return-point L.rp.3
                                (begin
                                  (set! rcx bar.1.4)
                                  (set! rdx bar.0.1)
                                  (set! rsi bat.6.3)
                                  (set! rdi bat.6.3)
                                  (set! r15 L.rp.3)
                                  (jump L.tmp.0.1 rbp r15 rdi rsi rdx rcx)))
                  (set! rbp (+ rbp 32)))
                (set! ball.7.6 rax)
                (set! tmp.18 bat.6.3)
                (set! tmp.18 (- tmp.18 bar.0.1))
                (set! ball.4.5 tmp.18)
                (set! foobar.2.11 bat.6.3)
                (set! bar.1.10 1)
                (set! foobar.8.9 bar.0.1)
                (set! bar.0.8 bar.1.4)
                (begin
                  (set! rbp (- rbp 32))
                  (return-point L.rp.4
                                (begin
                                  (set! rdx bar.1.4)
                                  (set! rsi 9223372036854775807)
                                  (set! rdi bar.0.1)
                                  (set! r15 L.rp.4)
                                  (jump L.x.1.2 rbp r15 rdi rsi rdx)))
                  (set! rbp (+ rbp 32)))
                (set! foobar.2.7 rax)
                (set! rdx bat.6.3)
                (set! rsi bat.6.3)
                (set! rdi -9223372036854775808)
                (set! r15 tmp-ra.15)
                (jump L.x.1.2 rbp r15 rdi rsi rdx)))
      (define L.x.1.2
        ((locals (bar.3.14 foobar.8.13 bat.6.12 tmp-ra.16))
         (conflicts ((tmp-ra.16 (bat.6.12 foobar.8.13 bar.3.14 rbp rcx rdi rsi rdx))
                     (bat.6.12 (rbp tmp-ra.16 foobar.8.13 bar.3.14 rdx rsi))
                     (foobar.8.13 (bat.6.12 rbp tmp-ra.16 bar.3.14 rdx rsi rcx))
                     (bar.3.14 (bat.6.12 foobar.8.13 rbp tmp-ra.16 rsi rdx))
                     (rdx (foobar.8.13 bat.6.12 rcx bar.3.14 r15 rdi rsi rbp tmp-ra.16))
                     (rbp (bat.6.12 foobar.8.13 bar.3.14 tmp-ra.16 rcx r15 rdi rsi rdx))
                     (rsi (bar.3.14 rcx foobar.8.13 r15 rdi rbp rdx tmp-ra.16 bat.6.12))
                     (rdi (rcx r15 rbp rsi rdx tmp-ra.16))
                     (r15 (rcx rbp rdi rsi rdx))
                     (rcx (r15 rdi rsi rdx rbp tmp-ra.16 foobar.8.13))))
         (assignment ()))
        (begin
          (set! tmp-ra.16 r15)
          (set! bar.3.14 rdi)
          (set! foobar.8.13 rsi)
          (set! bat.6.12 rdx)
          (if (false)
              (begin
                (set! rdx foobar.8.13)
                (set! rsi bat.6.12)
                (set! rdi 9223372036854775807)
                (set! r15 tmp-ra.16)
                (jump L.x.1.2 rbp r15 rdi rsi rdx))
              (if (false)
                  (begin
                    (set! rcx bar.3.14)
                    (set! rdx foobar.8.13)
                    (set! rsi bar.3.14)
                    (set! rdi foobar.8.13)
                    (set! r15 tmp-ra.16)
                    (jump L.tmp.0.1 rbp r15 rdi rsi rdx rcx))
                  (begin
                    (set! rdx bat.6.12)
                    (set! rsi 580696126)
                    (set! rdi bat.6.12)
                    (set! r15 tmp-ra.16)
                    (jump L.x.1.2 rbp r15 rdi rsi rdx))))))
      (begin
        (set! tmp-ra.17 r15)
        (if (begin
              (set! tmp.19 9223372036854775807)
              (<= tmp.19 9223372036854775807))
            (begin
              (set! rax -1677147892)
              (jump tmp-ra.17 rbp rax))
            (begin
              (set! rax 874915829)
              (jump tmp-ra.17 rbp rax))))))
  (check-by-interp
   '(module ((locals (tmp-ra.29 tmp.31))
             (conflicts ((tmp.31 (rbp tmp-ra.29)) (tmp-ra.29 (rbp tmp.31 rax))
                                                  (rax (rbp tmp-ra.29))
                                                  (rbp (tmp-ra.29 tmp.31 rax))))
             (assignment ()))
            (define L.proc.0.1
              ((locals (ball.4.10 ball.7.4 ball.7.9 foo.2.8 foo.2.11))
               (conflicts
                ((foo.6.1 (rbp tmp-ra.25
                               ball.0.2
                               foo.1.6
                               foobar.3.3
                               foo.2.7
                               ball.4.5
                               ball.7.4
                               ball.7.9
                               rax
                               ball.4.10))
                 (ball.0.2 (foo.6.1 rbp
                                    tmp-ra.25
                                    foo.1.6
                                    foobar.3.3
                                    foo.2.7
                                    ball.4.5
                                    ball.7.4
                                    fv0
                                    foo.2.11
                                    foo.2.8
                                    ball.7.9
                                    rax
                                    ball.4.10))
                 (foo.2.11 (rbp tmp-ra.25 ball.0.2))
                 (foo.2.8 (rbp tmp-ra.25 ball.0.2 foo.1.6))
                 (ball.7.9 (rbp tmp-ra.25 ball.0.2 foo.1.6 foo.6.1 foobar.3.3 foo.2.7 ball.4.5))
                 (nfv.26 (r15 rdi rsi rdx rcx r8 r9 rbp foo.1.6 foobar.3.3 ball.4.5 ball.7.4))
                 (ball.7.4 (foo.6.1 ball.0.2
                                    foobar.3.3
                                    rbp
                                    tmp-ra.25
                                    foo.1.6
                                    foo.2.7
                                    ball.4.5
                                    fv0
                                    r8
                                    r9
                                    nfv.26
                                    ball.4.10))
                 (foo.1.6 (foo.6.1 ball.0.2
                                   foobar.3.3
                                   ball.7.4
                                   ball.4.5
                                   rbp
                                   tmp-ra.25
                                   foo.2.7
                                   fv0
                                   rcx
                                   foo.2.8
                                   ball.7.9
                                   rsi
                                   rdx
                                   r8
                                   r9
                                   nfv.26
                                   rax
                                   ball.4.10))
                 (ball.4.5 (foo.6.1 ball.0.2
                                    foobar.3.3
                                    ball.7.4
                                    rbp
                                    tmp-ra.25
                                    foo.1.6
                                    foo.2.7
                                    fv0
                                    rsi
                                    rdx
                                    ball.7.9
                                    rcx
                                    r8
                                    r9
                                    nfv.26
                                    rax
                                    ball.4.10))
                 (foobar.3.3 (foo.6.1 ball.0.2
                                      rbp
                                      tmp-ra.25
                                      foo.1.6
                                      foo.2.7
                                      ball.4.5
                                      ball.7.4
                                      fv0
                                      ball.7.9
                                      rdx
                                      rcx
                                      r8
                                      r9
                                      nfv.26
                                      rax
                                      ball.4.10))
                 (ball.4.10 (rbp tmp-ra.25 ball.0.2 foo.1.6 foo.6.1 foobar.3.3 ball.4.5 ball.7.4))
                 (foo.2.7 (foo.6.1 ball.0.2
                                   foobar.3.3
                                   ball.7.4
                                   ball.4.5
                                   foo.1.6
                                   rbp
                                   tmp-ra.25
                                   fv0
                                   rsi
                                   rdx
                                   rcx
                                   r8
                                   r9
                                   ball.7.9
                                   rax))
                 (tmp-ra.25 (foo.6.1 ball.0.2
                                     foobar.3.3
                                     ball.7.4
                                     ball.4.5
                                     foo.1.6
                                     foo.2.7
                                     rbp
                                     fv0
                                     r9
                                     r8
                                     rcx
                                     rdx
                                     rsi
                                     rdi
                                     foo.2.11
                                     foo.2.8
                                     ball.7.9
                                     ball.4.10
                                     rax))
                 (rax (ball.0.2 foo.1.6 foo.6.1 foobar.3.3 foo.2.7 ball.4.5 rbp tmp-ra.25))
                 (rbp (foo.6.1 ball.0.2
                               foobar.3.3
                               ball.7.4
                               ball.4.5
                               foo.1.6
                               foo.2.7
                               tmp-ra.25
                               foo.2.11
                               foo.2.8
                               ball.7.9
                               r15
                               rdi
                               rsi
                               rdx
                               rcx
                               r8
                               r9
                               nfv.26
                               ball.4.10
                               rax))
                 (r9 (tmp-ra.25 foo.2.7
                                r15
                                rdi
                                rsi
                                rdx
                                rcx
                                r8
                                rbp
                                nfv.26
                                foo.1.6
                                foobar.3.3
                                ball.4.5
                                ball.7.4))
                 (r8 (ball.7.4 tmp-ra.25
                               foo.2.7
                               r15
                               rdi
                               rsi
                               rdx
                               rcx
                               rbp
                               r9
                               nfv.26
                               foo.1.6
                               foobar.3.3
                               ball.4.5))
                 (rcx
                  (foo.1.6 tmp-ra.25 foo.2.7 r15 rdi rsi rdx rbp r8 r9 nfv.26 foobar.3.3 ball.4.5))
                 (rdx
                  (tmp-ra.25 ball.4.5 foo.2.7 r15 rdi rsi rbp rcx r8 r9 nfv.26 foo.1.6 foobar.3.3))
                 (rsi (foo.2.7 tmp-ra.25 ball.4.5 r15 rdi rbp rdx rcx r8 r9 nfv.26 foo.1.6))
                 (rdi (tmp-ra.25 r15 rbp rsi rdx rcx r8 r9 nfv.26))
                 (r15 (rbp rdi rsi rdx rcx r8 r9 nfv.26))
                 (fv0 (ball.0.2 foobar.3.3 ball.7.4 ball.4.5 foo.1.6 foo.2.7 tmp-ra.25))))
               (assignment ((tmp-ra.25 fv1) (ball.0.2 fv2)
                                            (foo.1.6 fv3)
                                            (foo.6.1 fv0)
                                            (foobar.3.3 fv4)
                                            (foo.2.7 fv5)
                                            (ball.4.5 fv6)
                                            (nfv.26 fv7))))
              (begin
                (set! tmp-ra.25 r15)
                (set! foo.2.7 rdi)
                (set! foo.1.6 rsi)
                (set! ball.4.5 rdx)
                (set! ball.7.4 rcx)
                (set! foobar.3.3 r8)
                (set! ball.0.2 r9)
                (set! foo.6.1 fv0)
                (if (not (> foo.6.1 -727829088))
                    (begin
                      (set! ball.4.10 foo.2.7)
                      (begin
                        (set! rbp (- rbp 56))
                        (return-point L.rp.4
                                      (begin
                                        (set! nfv.26 foo.2.7)
                                        (set! r9 foo.2.7)
                                        (set! r8 ball.7.4)
                                        (set! rcx foo.1.6)
                                        (set! rdx ball.4.5)
                                        (set! rsi foobar.3.3)
                                        (set! rdi foo.1.6)
                                        (set! r15 L.rp.4)
                                        (jump L.proc.0.1 rbp r15 rdi rsi rdx rcx r8 r9 nfv.26)))
                        (set! rbp (+ rbp 56)))
                      (set! ball.7.9 rax)
                      (begin
                        (set! rbp (- rbp 56))
                        (return-point L.rp.5
                                      (begin
                                        (set! r9 foo.6.1)
                                        (set! r8 -9223372036854775808)
                                        (set! rcx foobar.3.3)
                                        (set! rdx 1)
                                        (set! rsi foo.2.7)
                                        (set! rdi ball.4.5)
                                        (set! r15 L.rp.5)
                                        (jump L.fn.1.2 rbp r15 rdi rsi rdx rcx r8 r9)))
                        (set! rbp (+ rbp 56)))
                      (set! foo.2.8 rax)
                      (set! foo.2.11 foo.1.6)
                      (set! rax ball.0.2)
                      (jump tmp-ra.25 rbp rax))
                    (begin
                      (set! rax -774243080)
                      (jump tmp-ra.25 rbp rax)))))
      (define L.fn.1.2
        ((locals
          (tmp.30 ball.9.18 tmp-ra.27 ball.7.12 foo.1.15 ball.4.16 ball.9.14 foo.5.17 foobar.3.13))
         (conflicts
          ((foobar.3.13
            (ball.7.12 rbp tmp-ra.27 foo.1.15 ball.4.16 foo.5.17 ball.9.14 tmp.30 rdx rcx r8 r9))
           (foo.5.17
            (ball.7.12 foobar.3.13 ball.9.14 foo.1.15 ball.4.16 rbp tmp-ra.27 r9 r8 rcx rdx rsi))
           (ball.9.14
            (ball.7.12 foobar.3.13 rbp tmp-ra.27 foo.1.15 ball.4.16 foo.5.17 rsi rdx rcx r8 r9))
           (ball.4.16 (ball.7.12 foobar.3.13
                                 ball.9.14
                                 foo.1.15
                                 rbp
                                 tmp-ra.27
                                 foo.5.17
                                 rdx
                                 ball.9.18
                                 tmp.30
                                 rcx
                                 r8
                                 r9))
           (foo.1.15 (ball.7.12 foobar.3.13
                                ball.9.14
                                rbp
                                tmp-ra.27
                                ball.4.16
                                foo.5.17
                                r8
                                rcx
                                r9
                                ball.9.18
                                tmp.30))
           (ball.7.12 (rbp tmp-ra.27 foo.1.15 ball.4.16 foobar.3.13 foo.5.17 ball.9.14 r9))
           (tmp-ra.27 (ball.7.12 foobar.3.13
                                 ball.9.14
                                 foo.1.15
                                 ball.4.16
                                 foo.5.17
                                 rbp
                                 ball.9.18
                                 tmp.30
                                 rdi
                                 rsi
                                 rdx
                                 rcx
                                 r8
                                 r9))
           (ball.9.18 (rsi rdx rcx r8 rbp tmp-ra.27 foo.1.15 ball.4.16))
           (tmp.30 (rbp tmp-ra.27 foo.1.15 ball.4.16 foobar.3.13))
           (r9 (foo.5.17 foo.1.15
                         r15
                         rdi
                         rsi
                         rdx
                         rcx
                         r8
                         rbp
                         tmp-ra.27
                         ball.9.14
                         foobar.3.13
                         ball.4.16
                         ball.7.12))
           (rbp (ball.7.12 foobar.3.13
                           ball.9.14
                           foo.1.15
                           ball.4.16
                           foo.5.17
                           tmp-ra.27
                           ball.9.18
                           tmp.30
                           r15
                           rdi
                           rsi
                           rdx
                           rcx
                           r8
                           r9))
           (r8 (foo.1.15 foo.5.17
                         ball.9.18
                         r15
                         rdi
                         rsi
                         rdx
                         rcx
                         rbp
                         r9
                         tmp-ra.27
                         ball.9.14
                         foobar.3.13
                         ball.4.16))
           (rcx (foo.5.17 ball.9.18
                          foo.1.15
                          r15
                          rdi
                          rsi
                          rdx
                          rbp
                          r8
                          r9
                          tmp-ra.27
                          ball.9.14
                          foobar.3.13
                          ball.4.16))
           (rdx
            (ball.4.16 foo.5.17 ball.9.18 r15 rdi rsi rbp rcx r8 r9 tmp-ra.27 ball.9.14 foobar.3.13))
           (rsi (foo.5.17 ball.9.18 r15 rdi rbp rdx rcx r8 r9 tmp-ra.27 ball.9.14))
           (rdi (r15 rbp rsi rdx rcx r8 r9 tmp-ra.27))
           (r15 (rbp rdi rsi rdx rcx r8 r9))))
         (assignment ()))
        (begin
          (set! tmp-ra.27 r15)
          (set! foo.5.17 rdi)
          (set! ball.4.16 rsi)
          (set! foo.1.15 rdx)
          (set! ball.9.14 rcx)
          (set! foobar.3.13 r8)
          (set! ball.7.12 r9)
          (if (if (if (< foobar.3.13 foo.5.17)
                      (>= foo.5.17 ball.9.14)
                      (!= ball.4.16 ball.4.16))
                  (if (>= ball.7.12 ball.9.14)
                      (< foo.5.17 foo.5.17)
                      (>= foo.1.15 foobar.3.13))
                  (not (> ball.9.14 ball.7.12)))
              (begin
                (set! tmp.30 -1548357748)
                (set! tmp.30 (- tmp.30 foobar.3.13))
                (set! ball.9.18 tmp.30)
                (set! r9 ball.9.18)
                (set! r8 foo.1.15)
                (set! rcx ball.4.16)
                (set! rdx foo.1.15)
                (set! rsi 0)
                (set! rdi ball.9.18)
                (set! r15 tmp-ra.27)
                (jump L.fn.1.2 rbp r15 rdi rsi rdx rcx r8 r9))
              (begin
                (set! r9 foo.5.17)
                (set! r8 ball.7.12)
                (set! rcx ball.7.12)
                (set! rdx ball.4.16)
                (set! rsi foobar.3.13)
                (set! rdi ball.9.14)
                (set! r15 tmp-ra.27)
                (jump L.fn.2.3 rbp r15 rdi rsi rdx rcx r8 r9)))))
      (define L.fn.2.3
        ((locals (ball.9.19 foo.6.20 foo.2.21 foobar.3.22 foo.1.23 foobar.8.24 tmp-ra.28))
         (conflicts
          ((tmp-ra.28
            (ball.9.19 foo.6.20 foo.2.21 foobar.3.22 foo.1.23 foobar.8.24 rbp r9 r8 rcx rdx rsi rdi))
           (foobar.8.24 (rbp tmp-ra.28 r9 r8 rcx rdx rsi))
           (foo.1.23 (rbp tmp-ra.28 r9 r8 rcx rdx))
           (foobar.3.22 (rbp tmp-ra.28 r9 r8 rcx))
           (foo.2.21 (rcx ball.9.19 foo.6.20 rbp tmp-ra.28 r9 r8))
           (foo.6.20 (rsi rdx r8 ball.9.19 rbp tmp-ra.28 foo.2.21 r9))
           (ball.9.19 (rbp tmp-ra.28 foo.6.20 foo.2.21))
           (rdi (r15 rbp rsi rdx rcx r8 r9 tmp-ra.28))
           (rsi (r15 rdi rbp rdx rcx r8 r9 foo.6.20 foobar.8.24 tmp-ra.28))
           (rdx (r15 rdi rsi rbp rcx r8 r9 foo.6.20 foo.1.23 foobar.8.24 tmp-ra.28))
           (rcx (r15 rdi rsi rdx rbp r8 r9 foo.2.21 foobar.3.22 foo.1.23 foobar.8.24 tmp-ra.28))
           (r8
            (r15 rdi rsi rdx rcx rbp r9 foo.6.20 foo.2.21 foobar.3.22 foo.1.23 foobar.8.24 tmp-ra.28))
           (r9
            (r15 rdi rsi rdx rcx r8 rbp foo.6.20 foo.2.21 foobar.3.22 foo.1.23 foobar.8.24 tmp-ra.28))
           (rbp (r15 rdi
                     rsi
                     rdx
                     rcx
                     r8
                     r9
                     ball.9.19
                     foo.6.20
                     foo.2.21
                     foobar.3.22
                     foo.1.23
                     foobar.8.24
                     tmp-ra.28))
           (r15 (rbp rdi rsi rdx rcx r8 r9))))
         (assignment ()))
        (begin
          (set! tmp-ra.28 r15)
          (set! foobar.8.24 rdi)
          (set! foo.1.23 rsi)
          (set! foobar.3.22 rdx)
          (set! foo.2.21 rcx)
          (set! foo.6.20 r8)
          (set! ball.9.19 r9)
          (set! r9 0)
          (set! r8 1)
          (set! rcx foo.6.20)
          (set! rdx foo.2.21)
          (set! rsi -9223372036854775808)
          (set! rdi foo.6.20)
          (set! r15 tmp-ra.28)
          (jump L.fn.2.3 rbp r15 rdi rsi rdx rcx r8 r9)))
      (begin
        (set! tmp-ra.29 r15)
        (if (begin
              (set! tmp.31 -534391580)
              (< tmp.31 9223372036854775807))
            (begin
              (set! rax 0)
              (jump tmp-ra.29 rbp rax))
            (begin
              (set! rax 0)
              (jump tmp-ra.29 rbp rax))))))
  (check-by-interp '(module ((locals (foobar.1.1 ball.8.2 ball.7.3 tmp-ra.4))
                             (conflicts ((tmp-ra.4 (rax foobar.1.1 ball.8.2 ball.7.3 rbp))
                                         (ball.7.3 (rbp tmp-ra.4))
                                         (ball.8.2 (rbp tmp-ra.4))
                                         (foobar.1.1 (rbp tmp-ra.4))
                                         (rbp (rax foobar.1.1 ball.8.2 ball.7.3 tmp-ra.4))
                                         (rax (rbp tmp-ra.4))))
                             (assignment ()))
                            (begin
                              (set! tmp-ra.4 r15)
                              (set! ball.7.3 -1762920629)
                              (set! ball.8.2 1)
                              (set! foobar.1.1 9223372036854775807)
                              (set! rax 0)
                              (jump tmp-ra.4 rbp rax))
                      ))
  (check-by-interp
   '(module ((locals (tmp-ra.8 tmp.9)) (conflicts ((tmp.9 (rbp tmp-ra.8)) (tmp-ra.8 (rbp tmp.9 rax))
                                                                          (rax (rbp tmp-ra.8))
                                                                          (rbp (tmp-ra.8 tmp.9 rax))))
                                       (assignment ()))
            (define L.proc.0.1
              ((locals (foobar.8.1 bar.4.2 ball.5.3 ball.3.4 ball.2.5 foobar.0.6 tmp-ra.7))
               (conflicts
                ((tmp-ra.7 (foobar.8.1 bar.4.2
                                       ball.5.3
                                       ball.3.4
                                       ball.2.5
                                       foobar.0.6
                                       rbp
                                       r9
                                       r8
                                       rcx
                                       rdx
                                       rsi
                                       rdi))
                 (foobar.0.6
                  (foobar.8.1 bar.4.2 ball.5.3 ball.3.4 ball.2.5 rbp tmp-ra.7 r9 r8 rcx rdx rsi))
                 (ball.2.5
                  (rsi foobar.8.1 bar.4.2 ball.5.3 ball.3.4 rbp tmp-ra.7 foobar.0.6 r9 r8 rcx rdx))
                 (ball.3.4 (rbp tmp-ra.7 ball.2.5 foobar.0.6 r9 r8 rcx))
                 (ball.5.3 (foobar.8.1 bar.4.2 rbp tmp-ra.7 ball.2.5 foobar.0.6 r9 r8))
                 (bar.4.2 (rbp tmp-ra.7 ball.2.5 foobar.0.6 ball.5.3 r9))
                 (foobar.8.1 (rbp tmp-ra.7 ball.2.5 foobar.0.6 ball.5.3))
                 (rdi (r15 rbp rsi rdx rcx r8 r9 tmp-ra.7))
                 (rsi (r15 rdi rbp rdx rcx r8 r9 ball.2.5 foobar.0.6 tmp-ra.7))
                 (rdx (r15 rdi rsi rbp rcx r8 r9 ball.2.5 foobar.0.6 tmp-ra.7))
                 (rcx (r15 rdi rsi rdx rbp r8 r9 ball.3.4 ball.2.5 foobar.0.6 tmp-ra.7))
                 (r8 (r15 rdi rsi rdx rcx rbp r9 ball.5.3 ball.3.4 ball.2.5 foobar.0.6 tmp-ra.7))
                 (r9
                  (r15 rdi rsi rdx rcx r8 rbp bar.4.2 ball.5.3 ball.3.4 ball.2.5 foobar.0.6 tmp-ra.7))
                 (rbp (r15 rdi
                           rsi
                           rdx
                           rcx
                           r8
                           r9
                           foobar.8.1
                           bar.4.2
                           ball.5.3
                           ball.3.4
                           ball.2.5
                           foobar.0.6
                           tmp-ra.7))
                 (r15 (rbp rdi rsi rdx rcx r8 r9))))
               (assignment ()))
              (begin
                (set! tmp-ra.7 r15)
                (set! foobar.0.6 rdi)
                (set! ball.2.5 rsi)
                (set! ball.3.4 rdx)
                (set! ball.5.3 rcx)
                (set! bar.4.2 r8)
                (set! foobar.8.1 r9)
                (set! r9 ball.2.5)
                (set! r8 ball.2.5)
                (set! rcx ball.5.3)
                (set! rdx foobar.0.6)
                (set! rsi 15882253)
                (set! rdi ball.2.5)
                (set! r15 tmp-ra.7)
                (jump L.proc.0.1 rbp r15 rdi rsi rdx rcx r8 r9)))
      (begin
        (set! tmp-ra.8 r15)
        (if (begin
              (set! tmp.9 1038395452)
              (!= tmp.9 1))
            (begin
              (set! rax -9223372036854775808)
              (jump tmp-ra.8 rbp rax))
            (begin
              (set! rax 717010255)
              (jump tmp-ra.8 rbp rax))))))
  (check-by-interp
   '(module ((locals (bat.6.1 foo.5.2 bat.8.3 tmp.5 tmp-ra.4 tmp.6 tmp.7))
             (conflicts ((tmp.7 (rbp tmp-ra.4))
                         (tmp.6 (rbp tmp-ra.4))
                         (tmp-ra.4 (rbp tmp.5 tmp.6 tmp.7 bat.6.1 foo.5.2 rax bat.8.3))
                         (tmp.5 (rbp tmp-ra.4))
                         (bat.8.3 (rbp tmp-ra.4))
                         (foo.5.2 (bat.6.1 rbp tmp-ra.4))
                         (bat.6.1 (rbp tmp-ra.4 foo.5.2))
                         (rbp (tmp-ra.4 tmp.5 tmp.6 tmp.7 bat.6.1 foo.5.2 rax bat.8.3))
                         (rax (rbp tmp-ra.4))))
             (assignment ()))
            (begin
              (set! tmp-ra.4 r15)
              (if (true)
                  (if (not (begin
                             (set! tmp.5 0)
                             (= tmp.5 1)))
                      (if (begin
                            (set! tmp.6 -9223372036854775808)
                            (>= tmp.6 -1744096882))
                          (begin
                            (set! rax 0)
                            (jump tmp-ra.4 rbp rax))
                          (begin
                            (set! rax 9223372036854775807)
                            (jump tmp-ra.4 rbp rax)))
                      (if (begin
                            (set! tmp.7 -9223372036854775808)
                            (< tmp.7 0))
                          (begin
                            (set! rax 1)
                            (jump tmp-ra.4 rbp rax))
                          (begin
                            (set! rax 9223372036854775807)
                            (jump tmp-ra.4 rbp rax))))
                  (if (false)
                      (begin
                        (set! foo.5.2 1032709229)
                        (set! bat.6.1 1)
                        (set! rax foo.5.2)
                        (jump tmp-ra.4 rbp rax))
                      (begin
                        (set! bat.8.3 9223372036854775807)
                        (set! rax bat.8.3)
                        (jump tmp-ra.4 rbp rax)))))
      ))
  (check-by-interp '(module ((locals (tmp.3 tmp-ra.1 tmp.2))
                             (conflicts ((tmp.2 (rbp tmp-ra.1)) (tmp-ra.1 (rbp tmp.2 tmp.3 rax))
                                                                (tmp.3 (rbp tmp-ra.1))
                                                                (rax (rbp tmp-ra.1))
                                                                (rbp (tmp-ra.1 tmp.2 tmp.3 rax))))
                             (assignment ()))
                            (begin
                              (set! tmp-ra.1 r15)
                              (if (begin
                                    (set! tmp.2 0)
                                    (< tmp.2 9223372036854775807))
                                  (begin
                                    (set! rax 1620518798)
                                    (jump tmp-ra.1 rbp rax))
                                  (if (begin
                                        (set! tmp.3 0)
                                        (!= tmp.3 9223372036854775807))
                                      (begin
                                        (set! rax 0)
                                        (jump tmp-ra.1 rbp rax))
                                      (begin
                                        (set! rax -9223372036854775808)
                                        (jump tmp-ra.1 rbp rax)))))
                      ))
  (check-by-interp
   '(module ((locals (tmp-ra.15 tmp.16))
             (conflicts ((tmp.16 (rbp tmp-ra.15)) (tmp-ra.15 (rbp tmp.16 rax))
                                                  (rax (rbp tmp-ra.15))
                                                  (rbp (tmp-ra.15 tmp.16 rax))))
             (assignment ()))
            (define L.func.0.1
              ((locals (ball.0.1 foobar.2.2 tmp-ra.12))
               (conflicts ((tmp-ra.12 (rdx ball.0.1 foobar.2.2 rbp rsi rdi))
                           (foobar.2.2 (rdx ball.0.1 rbp tmp-ra.12 rsi))
                           (ball.0.1 (rbp tmp-ra.12 foobar.2.2))
                           (rdi (r15 rbp rsi rdx tmp-ra.12))
                           (rsi (r15 rdi rbp rdx foobar.2.2 tmp-ra.12))
                           (rbp (r15 rdi rsi rdx ball.0.1 foobar.2.2 tmp-ra.12))
                           (rdx (r15 rdi rsi rbp tmp-ra.12 foobar.2.2))
                           (r15 (rbp rdi rsi rdx))))
               (assignment ()))
              (begin
                (set! tmp-ra.12 r15)
                (set! foobar.2.2 rdi)
                (set! ball.0.1 rsi)
                (set! rdx 9223372036854775807)
                (set! rsi foobar.2.2)
                (set! rdi foobar.2.2)
                (set! r15 tmp-ra.12)
                (jump L.tmp.1.2 rbp r15 rdi rsi rdx)))
      (define L.tmp.1.2
        ((locals (foo.6.3 ball.5.5 foobar.2.4 tmp-ra.13))
         (conflicts ((tmp-ra.13 (foo.6.3 foobar.2.4 ball.5.5 rbp rcx r8 r9 rdi rsi rdx))
                     (foobar.2.4 (foo.6.3 rbp tmp-ra.13 ball.5.5 rcx r8 r9 rsi rdx))
                     (ball.5.5 (foo.6.3 foobar.2.4 rbp tmp-ra.13 rsi rdx rcx r9))
                     (foo.6.3 (rbp tmp-ra.13 ball.5.5 foobar.2.4))
                     (rdx (rcx r8 r9 ball.5.5 r15 rdi rsi rbp tmp-ra.13 foobar.2.4))
                     (rbp (foo.6.3 foobar.2.4 ball.5.5 tmp-ra.13 rcx r8 r9 r15 rdi rsi rdx))
                     (rsi (rcx r8 r9 ball.5.5 r15 rdi rbp rdx tmp-ra.13 foobar.2.4))
                     (rdi (rcx r8 r9 r15 rbp rsi rdx tmp-ra.13))
                     (r15 (rcx r8 r9 rbp rdi rsi rdx))
                     (r9 (r15 rdi rsi rdx rcx r8 rbp tmp-ra.13 ball.5.5 foobar.2.4))
                     (r8 (r15 rdi rsi rdx rcx rbp r9 tmp-ra.13 foobar.2.4))
                     (rcx (r15 rdi rsi rdx rbp r8 r9 tmp-ra.13 ball.5.5 foobar.2.4))))
         (assignment ()))
        (begin
          (set! tmp-ra.13 r15)
          (set! ball.5.5 rdi)
          (set! foobar.2.4 rsi)
          (set! foo.6.3 rdx)
          (if (false)
              (begin
                (set! r9 foo.6.3)
                (set! r8 ball.5.5)
                (set! rcx 0)
                (set! rdx foobar.2.4)
                (set! rsi foobar.2.4)
                (set! rdi ball.5.5)
                (set! r15 tmp-ra.13)
                (jump L.tmp.2.3 rbp r15 rdi rsi rdx rcx r8 r9))
              (begin
                (set! rdx ball.5.5)
                (set! rsi 9223372036854775807)
                (set! rdi foobar.2.4)
                (set! r15 tmp-ra.13)
                (jump L.tmp.1.2 rbp r15 rdi rsi rdx)))))
      (define L.tmp.2.3
        ((locals (bat.9.6 bar.1.7 ball.5.8 foobar.7.9 foo.6.10 foobar.2.11 tmp-ra.14))
         (conflicts
          ((tmp-ra.14
            (bat.9.6 bar.1.7 ball.5.8 foobar.7.9 foo.6.10 foobar.2.11 rbp r9 r8 rcx rdx rsi rdi))
           (foobar.2.11
            (bat.9.6 bar.1.7 ball.5.8 foobar.7.9 foo.6.10 rbp tmp-ra.14 r9 r8 rcx rdx rsi))
           (foo.6.10 (bat.9.6 bar.1.7 ball.5.8 foobar.7.9 rbp tmp-ra.14 foobar.2.11 r9 r8 rcx rdx))
           (foobar.7.9 (rbp tmp-ra.14 foobar.2.11 foo.6.10 r9 r8 rcx))
           (ball.5.8 (rbp tmp-ra.14 foobar.2.11 foo.6.10 r9 r8))
           (bar.1.7 (rcx bat.9.6 rbp tmp-ra.14 foobar.2.11 foo.6.10 r9))
           (bat.9.6 (rbp tmp-ra.14 bar.1.7 foobar.2.11 foo.6.10))
           (rdi (r15 rbp rsi rdx rcx r8 r9 tmp-ra.14))
           (rsi (r15 rdi rbp rdx rcx r8 r9 foobar.2.11 tmp-ra.14))
           (rdx (r15 rdi rsi rbp rcx r8 r9 foo.6.10 foobar.2.11 tmp-ra.14))
           (rcx (r15 rdi rsi rdx rbp r8 r9 bar.1.7 foobar.7.9 foo.6.10 foobar.2.11 tmp-ra.14))
           (r8 (r15 rdi rsi rdx rcx rbp r9 ball.5.8 foobar.7.9 foo.6.10 foobar.2.11 tmp-ra.14))
           (r9
            (r15 rdi rsi rdx rcx r8 rbp bar.1.7 ball.5.8 foobar.7.9 foo.6.10 foobar.2.11 tmp-ra.14))
           (rbp (r15 rdi
                     rsi
                     rdx
                     rcx
                     r8
                     r9
                     bat.9.6
                     bar.1.7
                     ball.5.8
                     foobar.7.9
                     foo.6.10
                     foobar.2.11
                     tmp-ra.14))
           (r15 (rbp rdi rsi rdx rcx r8 r9))))
         (assignment ()))
        (begin
          (set! tmp-ra.14 r15)
          (set! foobar.2.11 rdi)
          (set! foo.6.10 rsi)
          (set! foobar.7.9 rdx)
          (set! ball.5.8 rcx)
          (set! bar.1.7 r8)
          (set! bat.9.6 r9)
          (set! r9 foo.6.10)
          (set! r8 bar.1.7)
          (set! rcx foobar.2.11)
          (set! rdx bar.1.7)
          (set! rsi 1666412948)
          (set! rdi 273235985)
          (set! r15 tmp-ra.14)
          (jump L.tmp.2.3 rbp r15 rdi rsi rdx rcx r8 r9)))
      (begin
        (set! tmp-ra.15 r15)
        (if (begin
              (set! tmp.16 -9223372036854775808)
              (= tmp.16 9223372036854775807))
            (begin
              (set! rax 9223372036854775807)
              (jump tmp-ra.15 rbp rax))
            (begin
              (set! rax 1)
              (jump tmp-ra.15 rbp rax))))))
  (check-by-interp
   '(module ((locals (tmp-ra.7)) (conflicts ((tmp-ra.7 (rax rbp)) (rbp (rax tmp-ra.7))
                                                                  (rax (rbp tmp-ra.7))))
                                 (assignment ()))
            (define L.fn.0.1
              ((locals (foo.8.1 foo.1.2 ball.0.3 ball.4.4 ball.2.5 tmp-ra.6))
               (conflicts
                ((tmp-ra.6 (foo.8.1 foo.1.2 ball.0.3 ball.4.4 ball.2.5 rbp r8 rcx rdx rsi rdi))
                 (ball.2.5 (foo.8.1 foo.1.2 ball.0.3 ball.4.4 rbp tmp-ra.6 r8 rcx rdx rsi))
                 (ball.4.4 (foo.8.1 foo.1.2 ball.0.3 rbp tmp-ra.6 ball.2.5 r8 rcx rdx))
                 (ball.0.3 (rbp tmp-ra.6 ball.2.5 ball.4.4 r8 rcx))
                 (foo.1.2 (foo.8.1 rbp tmp-ra.6 ball.2.5 ball.4.4 r8))
                 (foo.8.1 (rsi rdx rcx r8 rbp tmp-ra.6 ball.2.5 ball.4.4 foo.1.2))
                 (rdi (r15 rbp rsi rdx rcx r8 tmp-ra.6))
                 (rsi (r15 rdi rbp rdx rcx r8 foo.8.1 ball.2.5 tmp-ra.6))
                 (rdx (r15 rdi rsi rbp rcx r8 foo.8.1 ball.4.4 ball.2.5 tmp-ra.6))
                 (rcx (r15 rdi rsi rdx rbp r8 foo.8.1 ball.0.3 ball.4.4 ball.2.5 tmp-ra.6))
                 (r8 (r15 rdi rsi rdx rcx rbp foo.8.1 foo.1.2 ball.0.3 ball.4.4 ball.2.5 tmp-ra.6))
                 (rbp (r15 rdi rsi rdx rcx r8 foo.8.1 foo.1.2 ball.0.3 ball.4.4 ball.2.5 tmp-ra.6))
                 (r15 (rbp rdi rsi rdx rcx r8))))
               (assignment ()))
              (begin
                (set! tmp-ra.6 r15)
                (set! ball.2.5 rdi)
                (set! ball.4.4 rsi)
                (set! ball.0.3 rdx)
                (set! foo.1.2 rcx)
                (set! foo.8.1 r8)
                (set! r8 ball.2.5)
                (set! rcx foo.1.2)
                (set! rdx ball.4.4)
                (set! rsi ball.2.5)
                (set! rdi foo.8.1)
                (set! r15 tmp-ra.6)
                (jump L.fn.0.1 rbp r15 rdi rsi rdx rcx r8)))
      (begin
        (set! tmp-ra.7 r15)
        (set! rax -167685894)
        (jump tmp-ra.7 rbp rax))))
  (check-by-interp
   '(module ((locals (tmp.25 tmp-ra.23))
             (conflicts ((tmp-ra.23 (rax tmp.25 rbp)) (tmp.25 (rbp tmp-ra.23))
                                                      (rbp (rax tmp.25 tmp-ra.23))
                                                      (rax (rbp tmp-ra.23))))
             (assignment ()))
            (define L.func.0.1
              ((locals (foobar.8.1 bar.0.2 tmp-ra.20))
               (conflicts ((tmp-ra.20 (rdx rcx r8 r9 foobar.8.1 bar.0.2 rbp rsi rdi))
                           (bar.0.2 (rdx r8 r9 foobar.8.1 rbp tmp-ra.20 rsi))
                           (foobar.8.1 (rsi rcx rbp tmp-ra.20 bar.0.2))
                           (rdi (r15 rbp rsi rdx rcx r8 r9 tmp-ra.20))
                           (rsi (r15 rdi rbp rdx rcx r8 r9 foobar.8.1 bar.0.2 tmp-ra.20))
                           (rbp (r15 rdi rsi rdx rcx r8 r9 foobar.8.1 bar.0.2 tmp-ra.20))
                           (r9 (r15 rdi rsi rdx rcx r8 rbp tmp-ra.20 bar.0.2))
                           (r8 (r15 rdi rsi rdx rcx rbp r9 tmp-ra.20 bar.0.2))
                           (rcx (r15 rdi rsi rdx rbp r8 r9 tmp-ra.20 foobar.8.1))
                           (rdx (r15 rdi rsi rbp rcx r8 r9 tmp-ra.20 bar.0.2))
                           (r15 (rbp rdi rsi rdx rcx r8 r9))))
               (assignment ()))
              (begin
                (set! tmp-ra.20 r15)
                (set! bar.0.2 rdi)
                (set! foobar.8.1 rsi)
                (set! r9 foobar.8.1)
                (set! r8 foobar.8.1)
                (set! rcx bar.0.2)
                (set! rdx foobar.8.1)
                (set! rsi bar.0.2)
                (set! rdi foobar.8.1)
                (set! r15 tmp-ra.20)
                (jump L.fn.2.3 rbp r15 rdi rsi rdx rcx r8 r9)))
      (define L.fn.1.2
        ((locals (bar.0.8 foobar.1.11
                          bar.9.12
                          bar.0.13
                          foobar.2.9
                          tmp.24
                          foobar.7.10
                          foobar.5.3
                          bat.3.4
                          foobar.1.5
                          foobar.2.6
                          foo.6.7
                          tmp-ra.21))
         (conflicts
          ((tmp-ra.21 (bar.0.8 foobar.1.11
                               bar.9.12
                               bar.0.13
                               foobar.2.9
                               tmp.24
                               foobar.7.10
                               foobar.5.3
                               bat.3.4
                               foobar.1.5
                               foobar.2.6
                               foo.6.7
                               rbp
                               r8
                               rcx
                               rdx
                               rsi
                               rdi))
           (foo.6.7 (rbp tmp-ra.21 r8 rcx rdx rsi))
           (foobar.2.6 (tmp.24 foobar.7.10 foobar.5.3 bat.3.4 foobar.1.5 rbp tmp-ra.21 r8 rcx rdx))
           (foobar.1.5 (bar.9.12 bar.0.13
                                 foobar.2.9
                                 tmp.24
                                 foobar.7.10
                                 foobar.5.3
                                 bat.3.4
                                 rbp
                                 tmp-ra.21
                                 foobar.2.6
                                 r8
                                 rcx))
           (bat.3.4 (rsi rdx
                         foobar.1.11
                         bar.9.12
                         bar.0.13
                         foobar.2.9
                         tmp.24
                         foobar.7.10
                         foobar.5.3
                         rbp
                         tmp-ra.21
                         foobar.1.5
                         foobar.2.6
                         r8))
           (foobar.5.3 (rcx bar.0.8
                            foobar.1.11
                            bar.9.12
                            bar.0.13
                            foobar.2.9
                            tmp.24
                            rbp
                            tmp-ra.21
                            bat.3.4
                            foobar.1.5
                            foobar.2.6))
           (foobar.7.10 (foobar.2.9 tmp.24 rbp tmp-ra.21 bat.3.4 foobar.1.5 foobar.2.6))
           (tmp.24 (foobar.1.5 rbp tmp-ra.21 bat.3.4 foobar.5.3 foobar.7.10 foobar.2.6))
           (foobar.2.9 (bar.0.13 rbp tmp-ra.21 bat.3.4 foobar.5.3 foobar.1.5 foobar.7.10))
           (bar.0.13 (rbp tmp-ra.21 bat.3.4 foobar.5.3 foobar.1.5 foobar.2.9))
           (bar.9.12 (rbp tmp-ra.21 bat.3.4 foobar.5.3 foobar.1.5))
           (foobar.1.11 (rbp tmp-ra.21 bat.3.4 foobar.5.3))
           (bar.0.8 (rbp tmp-ra.21 foobar.5.3))
           (rdi (r15 rbp rsi rdx rcx r8 tmp-ra.21))
           (rsi (r15 rdi rbp rdx rcx r8 bat.3.4 foo.6.7 tmp-ra.21))
           (rdx (r15 rdi rsi rbp rcx r8 bat.3.4 foobar.2.6 foo.6.7 tmp-ra.21))
           (rcx (r15 rdi rsi rdx rbp r8 foobar.5.3 foobar.1.5 foobar.2.6 foo.6.7 tmp-ra.21))
           (r8 (r15 rdi rsi rdx rcx rbp bat.3.4 foobar.1.5 foobar.2.6 foo.6.7 tmp-ra.21))
           (rbp (r15 rdi
                     rsi
                     rdx
                     rcx
                     r8
                     bar.0.8
                     foobar.1.11
                     bar.9.12
                     bar.0.13
                     foobar.2.9
                     tmp.24
                     foobar.7.10
                     foobar.5.3
                     bat.3.4
                     foobar.1.5
                     foobar.2.6
                     foo.6.7
                     tmp-ra.21))
           (r15 (rbp rdi rsi rdx rcx r8))))
         (assignment ()))
        (begin
          (set! tmp-ra.21 r15)
          (set! foo.6.7 rdi)
          (set! foobar.2.6 rsi)
          (set! foobar.1.5 rdx)
          (set! bat.3.4 rcx)
          (set! foobar.5.3 r8)
          (set! foobar.7.10 foobar.5.3)
          (set! tmp.24 foobar.1.5)
          (set! tmp.24 (- tmp.24 foobar.2.6))
          (set! foobar.2.9 tmp.24)
          (set! bar.0.13 foobar.7.10)
          (set! bar.9.12 foobar.2.9)
          (set! foobar.1.11 foobar.1.5)
          (set! bar.0.8 bat.3.4)
          (set! r8 foobar.5.3)
          (set! rcx bat.3.4)
          (set! rdx foobar.5.3)
          (set! rsi -9223372036854775808)
          (set! rdi bat.3.4)
          (set! r15 tmp-ra.21)
          (jump L.fn.1.2 rbp r15 rdi rsi rdx rcx r8)))
      (define L.fn.2.3
        ((locals (foobar.7.14 foobar.8.15 ball.4.16 foobar.2.17 foobar.5.18 foobar.1.19 tmp-ra.22))
         (conflicts ((tmp-ra.22 (foobar.7.14 foobar.8.15
                                             ball.4.16
                                             foobar.2.17
                                             foobar.5.18
                                             foobar.1.19
                                             rbp
                                             r9
                                             r8
                                             rcx
                                             rdx
                                             rsi
                                             rdi))
                     (foobar.1.19 (foobar.7.14 foobar.8.15
                                               ball.4.16
                                               foobar.2.17
                                               foobar.5.18
                                               rbp
                                               tmp-ra.22
                                               r9
                                               r8
                                               rcx
                                               rdx
                                               rsi))
                     (foobar.5.18 (rbp tmp-ra.22 foobar.1.19 r9 r8 rcx rdx))
                     (foobar.2.17 (rbp tmp-ra.22 foobar.1.19 r9 r8 rcx))
                     (ball.4.16 (foobar.7.14 foobar.8.15 rbp tmp-ra.22 foobar.1.19 r9 r8))
                     (foobar.8.15 (rbp tmp-ra.22 foobar.1.19 ball.4.16 r9))
                     (foobar.7.14 (rbp tmp-ra.22 foobar.1.19 ball.4.16))
                     (rdi (r15 rbp rsi tmp-ra.22))
                     (rsi (r15 rdi rbp foobar.1.19 tmp-ra.22))
                     (rdx (foobar.5.18 foobar.1.19 tmp-ra.22))
                     (rcx (foobar.2.17 foobar.5.18 foobar.1.19 tmp-ra.22))
                     (r8 (ball.4.16 foobar.2.17 foobar.5.18 foobar.1.19 tmp-ra.22))
                     (r9 (foobar.8.15 ball.4.16 foobar.2.17 foobar.5.18 foobar.1.19 tmp-ra.22))
                     (rbp (r15 rdi
                               rsi
                               foobar.7.14
                               foobar.8.15
                               ball.4.16
                               foobar.2.17
                               foobar.5.18
                               foobar.1.19
                               tmp-ra.22))
                     (r15 (rbp rdi rsi))))
         (assignment ()))
        (begin
          (set! tmp-ra.22 r15)
          (set! foobar.1.19 rdi)
          (set! foobar.5.18 rsi)
          (set! foobar.2.17 rdx)
          (set! ball.4.16 rcx)
          (set! foobar.8.15 r8)
          (set! foobar.7.14 r9)
          (set! rsi ball.4.16)
          (set! rdi foobar.1.19)
          (set! r15 tmp-ra.22)
          (jump L.func.0.1 rbp r15 rdi rsi)))
      (begin
        (set! tmp-ra.23 r15)
        (set! tmp.25 1962527269)
        (set! tmp.25 (+ tmp.25 9223372036854775807))
        (set! rax tmp.25)
        (jump tmp-ra.23 rbp rax))))
  (check-by-interp
   '(module ((locals (tmp-ra.3)) (conflicts ((tmp-ra.3 (rdi rbp)) (rbp (r15 rdi tmp-ra.3))
                                                                  (rdi (r15 rbp tmp-ra.3))
                                                                  (r15 (rbp rdi))))
                                 (assignment ()))
            (define L.func.0.1
              ((locals (tmp-ra.2 tmp.4 bat.0.1))
               (conflicts ((bat.0.1 (rbp tmp-ra.2 tmp.4)) (tmp.4 (rbp tmp-ra.2 bat.0.1))
                                                          (tmp-ra.2 (bat.0.1 rbp tmp.4 rax rdi))
                                                          (rdi (r15 rbp tmp-ra.2))
                                                          (rbp (bat.0.1 tmp-ra.2 tmp.4 rax r15 rdi))
                                                          (r15 (rbp rdi))
                                                          (rax (rbp tmp-ra.2))))
               (assignment ()))
              (begin
                (set! tmp-ra.2 r15)
                (set! bat.0.1 rdi)
                (if (if (true)
                        (not (> bat.0.1 bat.0.1))
                        (begin
                          (set! tmp.4 2020417677)
                          (>= tmp.4 -9223372036854775808)))
                    (if (true)
                        (if (= bat.0.1 bat.0.1)
                            (begin
                              (set! rax bat.0.1)
                              (jump tmp-ra.2 rbp rax))
                            (begin
                              (set! rax bat.0.1)
                              (jump tmp-ra.2 rbp rax)))
                        (begin
                          (set! rdi bat.0.1)
                          (set! r15 tmp-ra.2)
                          (jump L.func.0.1 rbp r15 rdi)))
                    (begin
                      (set! rdi 9223372036854775807)
                      (set! r15 tmp-ra.2)
                      (jump L.func.0.1 rbp r15 rdi)))))
      (begin
        (set! tmp-ra.3 r15)
        (set! rdi 733499244)
        (set! r15 tmp-ra.3)
        (jump L.func.0.1 rbp r15 rdi))))
  (check-by-interp
   '(module ((locals (foobar.7.19 foo.8.20 ball.3.21 tmp-ra.25))
             (conflicts ((tmp-ra.25 (rax foobar.7.19 foo.8.20 ball.3.21 rbp))
                         (ball.3.21 (foobar.7.19 foo.8.20 rbp tmp-ra.25))
                         (foo.8.20 (rbp tmp-ra.25 ball.3.21))
                         (foobar.7.19 (rbp tmp-ra.25 ball.3.21))
                         (rbp (rax foobar.7.19 foo.8.20 ball.3.21 tmp-ra.25))
                         (rax (rbp tmp-ra.25))))
             (assignment ()))
            (define L.proc.0.1
              ((locals (foobar.1.1 foobar.4.2 foo.8.3 ball.3.4 tmp-ra.22))
               (conflicts
                ((tmp-ra.22 (r8 foobar.1.1 foobar.4.2 foo.8.3 ball.3.4 rbp rcx rdx rsi rdi))
                 (ball.3.4 (rbp tmp-ra.22 rcx rdx rsi))
                 (foo.8.3 (foobar.1.1 foobar.4.2 rbp tmp-ra.22 rcx rdx))
                 (foobar.4.2 (rbp tmp-ra.22 foo.8.3 rcx))
                 (foobar.1.1 (rbp tmp-ra.22 foo.8.3))
                 (rdi (r15 rbp rsi rdx rcx r8 tmp-ra.22))
                 (rsi (r15 rdi rbp rdx rcx r8 ball.3.4 tmp-ra.22))
                 (rdx (r15 rdi rsi rbp rcx r8 foo.8.3 ball.3.4 tmp-ra.22))
                 (rcx (r15 rdi rsi rdx rbp r8 foobar.4.2 foo.8.3 ball.3.4 tmp-ra.22))
                 (rbp (r15 rdi rsi rdx rcx r8 foobar.1.1 foobar.4.2 foo.8.3 ball.3.4 tmp-ra.22))
                 (r8 (r15 rdi rsi rdx rcx rbp tmp-ra.22))
                 (r15 (rbp rdi rsi rdx rcx r8))))
               (assignment ()))
              (begin
                (set! tmp-ra.22 r15)
                (set! ball.3.4 rdi)
                (set! foo.8.3 rsi)
                (set! foobar.4.2 rdx)
                (set! foobar.1.1 rcx)
                (set! r8 foo.8.3)
                (set! rcx 1)
                (set! rdx 0)
                (set! rsi -9223372036854775808)
                (set! rdi 835392363)
                (set! r15 tmp-ra.22)
                (jump L.fn.1.2 rbp r15 rdi rsi rdx rcx r8)))
      (define L.fn.1.2
        ((locals (foobar.4.5 bat.6.6 bar.2.7 foobar.7.8 bat.0.9 tmp-ra.23))
         (conflicts
          ((tmp-ra.23 (foobar.4.5 bat.6.6 bar.2.7 foobar.7.8 bat.0.9 rbp r8 rcx rdx rsi rdi))
           (bat.0.9 (rbp tmp-ra.23 r8 rcx rdx rsi))
           (foobar.7.8 (foobar.4.5 bat.6.6 bar.2.7 rbp tmp-ra.23 r8 rcx rdx))
           (bar.2.7 (rbp tmp-ra.23 foobar.7.8 r8 rcx))
           (bat.6.6 (rbp tmp-ra.23 foobar.7.8 r8))
           (foobar.4.5 (rbp tmp-ra.23 foobar.7.8))
           (rdi (r15 rbp tmp-ra.23))
           (rsi (bat.0.9 tmp-ra.23))
           (rdx (foobar.7.8 bat.0.9 tmp-ra.23))
           (rcx (bar.2.7 foobar.7.8 bat.0.9 tmp-ra.23))
           (r8 (bat.6.6 bar.2.7 foobar.7.8 bat.0.9 tmp-ra.23))
           (rbp (r15 rdi foobar.4.5 bat.6.6 bar.2.7 foobar.7.8 bat.0.9 tmp-ra.23))
           (r15 (rbp rdi))))
         (assignment ()))
        (begin
          (set! tmp-ra.23 r15)
          (set! bat.0.9 rdi)
          (set! foobar.7.8 rsi)
          (set! bar.2.7 rdx)
          (set! bat.6.6 rcx)
          (set! foobar.4.5 r8)
          (set! rdi foobar.7.8)
          (set! r15 tmp-ra.23)
          (jump L.x.2.3 rbp r15 rdi)))
      (define L.x.2.3
        ((locals
          (ball.3.13 foobar.7.14 foobar.1.16 foobar.7.17 bat.0.18 foo.9.15 foo.9.11 tmp.26 bat.0.12))
         (conflicts
          ((tmp-ra.24 (ball.3.13 foobar.7.14
                                 foobar.1.16
                                 foobar.7.17
                                 bat.0.18
                                 foo.9.15
                                 foo.9.11
                                 tmp.26
                                 bat.0.12
                                 rax
                                 foobar.7.10
                                 rbp
                                 rdi))
           (foobar.7.10
            (foobar.7.14 foobar.1.16 bat.0.18 foo.9.15 foo.9.11 tmp.26 bat.0.12 rax rbp tmp-ra.24))
           (bat.0.12 (rbp tmp-ra.24 foobar.7.10))
           (tmp.26 (rbp tmp-ra.24 foobar.7.10))
           (foo.9.11 (foobar.7.17 foo.9.15 rbp tmp-ra.24 foobar.7.10))
           (foo.9.15 (foobar.7.10 rbp tmp-ra.24 foo.9.11))
           (bat.0.18 (foobar.1.16 foobar.7.17 rbp tmp-ra.24 foobar.7.10))
           (foobar.7.17 (rbp tmp-ra.24 bat.0.18 foo.9.11))
           (foobar.1.16 (rbp tmp-ra.24 foobar.7.10 bat.0.18))
           (foobar.7.14 (rbp tmp-ra.24 foobar.7.10))
           (ball.3.13 (rbp tmp-ra.24))
           (rdi (r15 rbp rsi rdx rcx tmp-ra.24))
           (rbp (ball.3.13 foobar.7.14
                           foobar.1.16
                           foobar.7.17
                           bat.0.18
                           foo.9.15
                           foo.9.11
                           tmp.26
                           bat.0.12
                           r15
                           rdi
                           rsi
                           rdx
                           rcx
                           rax
                           foobar.7.10
                           tmp-ra.24))
           (rax (rbp tmp-ra.24 foobar.7.10))
           (rcx (r15 rdi rsi rdx rbp))
           (rdx (r15 rdi rsi rbp rcx))
           (rsi (r15 rdi rbp rdx rcx))
           (r15 (rbp rdi rsi rdx rcx))))
         (assignment ((tmp-ra.24 fv0) (foobar.7.10 fv1))))
        (begin
          (set! tmp-ra.24 r15)
          (set! foobar.7.10 rdi)
          (begin
            (set! rbp (- rbp 16))
            (return-point L.rp.4
                          (begin
                            (set! rcx foobar.7.10)
                            (set! rdx foobar.7.10)
                            (set! rsi foobar.7.10)
                            (set! rdi foobar.7.10)
                            (set! r15 L.rp.4)
                            (jump L.proc.0.1 rbp r15 rdi rsi rdx rcx)))
            (set! rbp (+ rbp 16)))
          (set! bat.0.12 rax)
          (set! tmp.26 bat.0.12)
          (set! tmp.26 (- tmp.26 bat.0.12))
          (set! foo.9.11 tmp.26)
          (if (<= foo.9.11 foobar.7.10)
              (set! foo.9.15 foo.9.11)
              (set! foo.9.15 foobar.7.10))
          (set! bat.0.18 foo.9.11)
          (set! foobar.7.17 foobar.7.10)
          (set! foobar.1.16 foo.9.11)
          (set! foobar.7.14 bat.0.18)
          (set! ball.3.13 foobar.7.10)
          (set! rdi ball.3.13)
          (set! r15 tmp-ra.24)
          (jump L.x.2.3 rbp r15 rdi)))
      (begin
        (set! tmp-ra.25 r15)
        (set! ball.3.21 1830309714)
        (set! foo.8.20 -9223372036854775808)
        (set! foobar.7.19 -9223372036854775808)
        (set! rax ball.3.21)
        (jump tmp-ra.25 rbp rax))))
  (check-by-interp
   '(module ((locals (tmp-ra.13)) (conflicts ((tmp-ra.13 (rax rbp)) (rbp (rax tmp-ra.13))
                                                                    (rax (rbp tmp-ra.13))))
                                  (assignment ()))
            (define L.func.0.1
              ((locals (bar.7.1 bat.3.2 bat.6.3 foo.5.4 foobar.0.5 tmp-ra.10))
               (conflicts
                ((tmp-ra.10 (rax bar.7.1 bat.3.2 bat.6.3 foo.5.4 foobar.0.5 rbp r8 rcx rdx rsi rdi))
                 (foobar.0.5 (rbp tmp-ra.10 r8 rcx rdx rsi))
                 (foo.5.4 (rbp tmp-ra.10 r8 rcx rdx))
                 (bat.6.3 (rbp tmp-ra.10 r8 rcx))
                 (bat.3.2 (bar.7.1 rbp tmp-ra.10 r8))
                 (bar.7.1 (rbp tmp-ra.10 bat.3.2))
                 (rdi (tmp-ra.10))
                 (rsi (foobar.0.5 tmp-ra.10))
                 (rdx (foo.5.4 foobar.0.5 tmp-ra.10))
                 (rcx (bat.6.3 foo.5.4 foobar.0.5 tmp-ra.10))
                 (r8 (bat.3.2 bat.6.3 foo.5.4 foobar.0.5 tmp-ra.10))
                 (rbp (rax bar.7.1 bat.3.2 bat.6.3 foo.5.4 foobar.0.5 tmp-ra.10))
                 (rax (rbp tmp-ra.10))))
               (assignment ()))
              (begin
                (set! tmp-ra.10 r15)
                (set! foobar.0.5 rdi)
                (set! foo.5.4 rsi)
                (set! bat.6.3 rdx)
                (set! bat.3.2 rcx)
                (set! bar.7.1 r8)
                (set! rax bat.3.2)
                (jump tmp-ra.10 rbp rax)))
      (define L.func.1.2
        ((locals (foobar.4.6 bat.2.8 tmp.14))
         (conflicts ((tmp-ra.11 (foobar.4.6 rax bat.3.7 bat.2.8 tmp.14 rbp))
                     (tmp.14 (rbp tmp-ra.11))
                     (bat.2.8 (rbp tmp-ra.11))
                     (bat.3.7 (foobar.4.6 rax rbp tmp-ra.11))
                     (foobar.4.6 (rbp tmp-ra.11 bat.3.7))
                     (rbp (foobar.4.6 r15 rax bat.3.7 bat.2.8 tmp.14 tmp-ra.11))
                     (rax (rbp tmp-ra.11 bat.3.7))
                     (r15 (rbp))))
         (assignment ((tmp-ra.11 fv0) (bat.3.7 fv1))))
        (begin
          (set! tmp-ra.11 r15)
          (set! tmp.14 -620373304)
          (set! tmp.14 (- tmp.14 -68719063))
          (set! bat.2.8 tmp.14)
          (set! bat.3.7 0)
          (begin
            (set! rbp (- rbp 16))
            (return-point L.rp.4
                          (begin
                            (set! r15 L.rp.4)
                            (jump L.func.1.2 rbp r15)))
            (set! rbp (+ rbp 16)))
          (set! foobar.4.6 rax)
          (set! rax bat.3.7)
          (jump tmp-ra.11 rbp rax)))
      (define L.x.2.3
        ((locals (bar.8.9 tmp-ra.12))
         (conflicts ((tmp-ra.12 (bar.8.9 rbp rdi)) (bar.8.9 (rbp tmp-ra.12))
                                                   (rdi (tmp-ra.12))
                                                   (rbp (r15 bar.8.9 tmp-ra.12))
                                                   (r15 (rbp))))
         (assignment ()))
        (begin
          (set! tmp-ra.12 r15)
          (set! bar.8.9 rdi)
          (set! r15 tmp-ra.12)
          (jump L.func.1.2 rbp r15)))
      (begin
        (set! tmp-ra.13 r15)
        (set! rax -575594324)
        (jump tmp-ra.13 rbp rax))))
  (check-by-interp
   '(module ((locals (tmp.16 tmp-ra.14 foo.3.11 bat.6.10 foobar.4.9 tmp.15))
             (conflicts ((tmp.15 (rbp tmp-ra.14))
                         (foobar.4.9 (rbp tmp-ra.14 foo.3.11))
                         (bat.6.10 (rbp tmp-ra.14 foo.3.11))
                         (foo.3.11 (foobar.4.9 bat.6.10 rbp tmp-ra.14))
                         (tmp-ra.14 (rbp tmp.15 foobar.4.9 bat.6.10 foo.3.11 tmp.16 rax))
                         (tmp.16 (rbp tmp-ra.14))
                         (rax (rbp tmp-ra.14))
                         (rbp (tmp-ra.14 tmp.15 foobar.4.9 bat.6.10 foo.3.11 tmp.16 rax))))
             (assignment ()))
            (define L.x.0.1
              ((locals (bat.6.1 bar.5.2 bar.7.3 bat.2.4 foobar.0.5 foo.3.6 tmp-ra.12))
               (conflicts
                ((tmp-ra.12
                  (bat.6.1 bar.5.2 bar.7.3 bat.2.4 foobar.0.5 foo.3.6 rbp r9 r8 rcx rdx rsi rdi))
                 (foo.3.6 (rbp tmp-ra.12 r9 r8 rcx rdx rsi))
                 (foobar.0.5 (rbp tmp-ra.12 r9 r8 rcx rdx))
                 (bat.2.4 (rbp tmp-ra.12 r9 r8 rcx))
                 (bar.7.3 (rsi bat.6.1 bar.5.2 rbp tmp-ra.12 r9 r8))
                 (bar.5.2 (rbp tmp-ra.12 bar.7.3 r9))
                 (bat.6.1 (rbp tmp-ra.12 bar.7.3))
                 (rdi (r15 rbp rsi tmp-ra.12))
                 (rsi (r15 rdi rbp bar.7.3 foo.3.6 tmp-ra.12))
                 (rdx (foobar.0.5 foo.3.6 tmp-ra.12))
                 (rcx (bat.2.4 foobar.0.5 foo.3.6 tmp-ra.12))
                 (r8 (bar.7.3 bat.2.4 foobar.0.5 foo.3.6 tmp-ra.12))
                 (r9 (bar.5.2 bar.7.3 bat.2.4 foobar.0.5 foo.3.6 tmp-ra.12))
                 (rbp (r15 rdi rsi bat.6.1 bar.5.2 bar.7.3 bat.2.4 foobar.0.5 foo.3.6 tmp-ra.12))
                 (r15 (rbp rdi rsi))))
               (assignment ()))
              (begin
                (set! tmp-ra.12 r15)
                (set! foo.3.6 rdi)
                (set! foobar.0.5 rsi)
                (set! bat.2.4 rdx)
                (set! bar.7.3 rcx)
                (set! bar.5.2 r8)
                (set! bat.6.1 r9)
                (set! rsi 1)
                (set! rdi bar.7.3)
                (set! r15 tmp-ra.12)
                (jump L.x.1.2 rbp r15 rdi rsi)))
      (define L.x.1.2
        ((locals (foobar.4.8 tmp-ra.13 foobar.0.7))
         (conflicts ((foobar.0.7 (rbp tmp-ra.13 foobar.4.8 r9))
                     (tmp-ra.13 (foobar.0.7 foobar.4.8 rbp rdi rsi rdx rcx r8 r9 rax))
                     (foobar.4.8 (foobar.0.7 rbp tmp-ra.13 rsi rdx rcx r8))
                     (rax (rbp tmp-ra.13))
                     (rbp (foobar.0.7 foobar.4.8 tmp-ra.13 r15 rdi rsi rdx rcx r8 r9 rax))
                     (r9 (r15 rdi rsi rdx rcx r8 rbp tmp-ra.13 foobar.0.7))
                     (r8 (r15 rdi rsi rdx rcx rbp r9 tmp-ra.13 foobar.4.8))
                     (rcx (r15 rdi rsi rdx rbp r8 r9 tmp-ra.13 foobar.4.8))
                     (rdx (r15 rdi rsi rbp rcx r8 r9 tmp-ra.13 foobar.4.8))
                     (rsi (foobar.4.8 r15 rdi rbp rdx rcx r8 r9 tmp-ra.13))
                     (rdi (r15 rbp rsi rdx rcx r8 r9 tmp-ra.13))
                     (r15 (rbp rdi rsi rdx rcx r8 r9))))
         (assignment ()))
        (begin
          (set! tmp-ra.13 r15)
          (set! foobar.4.8 rdi)
          (set! foobar.0.7 rsi)
          (if (<= foobar.0.7 -9223372036854775808)
              (begin
                (set! r9 foobar.4.8)
                (set! r8 foobar.0.7)
                (set! rcx foobar.0.7)
                (set! rdx foobar.0.7)
                (set! rsi foobar.4.8)
                (set! rdi foobar.4.8)
                (set! r15 tmp-ra.13)
                (jump L.x.0.1 rbp r15 rdi rsi rdx rcx r8 r9))
              (begin
                (set! rax foobar.0.7)
                (jump tmp-ra.13 rbp rax)))))
      (begin
        (set! tmp-ra.14 r15)
        (if (not (begin
                   (set! tmp.15 0)
                   (= tmp.15 -844906965)))
            (begin
              (set! foo.3.11 996590913)
              (set! bat.6.10 299367411)
              (set! foobar.4.9 -9223372036854775808)
              (set! rax foo.3.11)
              (jump tmp-ra.14 rbp rax))
            (if (begin
                  (set! tmp.16 894536270)
                  (> tmp.16 1910216157))
                (begin
                  (set! rax 1)
                  (jump tmp-ra.14 rbp rax))
                (begin
                  (set! rax 1)
                  (jump tmp-ra.14 rbp rax)))))))
  (check-by-interp
   '(module ((locals (tmp-ra.21 tmp.24))
             (conflicts ((tmp.24 (rbp tmp-ra.21))
                         (tmp-ra.21 (rbp tmp.24 rax rdi rsi rdx rcx r8 r9 fv0))
                         (fv0 (r15 rdi rsi rdx rcx r8 r9 rbp tmp-ra.21))
                         (rbp (tmp-ra.21 tmp.24 rax r15 rdi rsi rdx rcx r8 r9 fv0))
                         (r9 (r15 rdi rsi rdx rcx r8 rbp fv0 tmp-ra.21))
                         (r8 (r15 rdi rsi rdx rcx rbp r9 fv0 tmp-ra.21))
                         (rcx (r15 rdi rsi rdx rbp r8 r9 fv0 tmp-ra.21))
                         (rdx (r15 rdi rsi rbp rcx r8 r9 fv0 tmp-ra.21))
                         (rsi (r15 rdi rbp rdx rcx r8 r9 fv0 tmp-ra.21))
                         (rdi (r15 rbp rsi rdx rcx r8 r9 fv0 tmp-ra.21))
                         (r15 (rbp rdi rsi rdx rcx r8 r9 fv0))
                         (rax (rbp tmp-ra.21))))
             (assignment ()))
            (define L.tmp.0.1
              ((locals (bar.3.7 bar.4.6 bat.2.8 tmp-ra.19 bat.6.5 foobar.8.3 bar.3.2 foo.1.1 bat.2.4))
               (conflicts
                ((bat.2.4 (foo.1.1 bar.3.2 foobar.8.3 rbp tmp-ra.19 bat.6.5 rdx rsi rcx r8 r9 fv0))
                 (foo.1.1 (rbp tmp-ra.19 bar.3.2 foobar.8.3 bat.6.5 bat.2.4 fv0))
                 (bar.3.2 (foo.1.1 rbp tmp-ra.19 foobar.8.3 bat.6.5 bat.2.4 rsi rdx rcx r8 r9 fv0))
                 (foobar.8.3
                  (foo.1.1 bar.3.2 rbp tmp-ra.19 bat.6.5 bat.2.4 rdx rcx r8 r9 fv0 bar.4.6 bar.3.7))
                 (bat.6.5
                  (foo.1.1 bar.3.2 foobar.8.3 bat.2.4 rbp tmp-ra.19 rdx rsi rcx r8 r9 fv0 bar.3.7))
                 (tmp-ra.19 (foo.1.1 bar.3.2
                                     foobar.8.3
                                     bat.2.4
                                     bat.6.5
                                     rbp
                                     rdi
                                     rsi
                                     rdx
                                     rcx
                                     r8
                                     r9
                                     fv0
                                     rax
                                     bat.2.8
                                     bar.4.6
                                     bar.3.7))
                 (bat.2.8 (rbp tmp-ra.19))
                 (bar.4.6 (rbp tmp-ra.19 foobar.8.3))
                 (bar.3.7 (rbp tmp-ra.19 foobar.8.3 bat.6.5))
                 (rbp (foo.1.1 bar.3.2
                               foobar.8.3
                               bat.2.4
                               bat.6.5
                               tmp-ra.19
                               r15
                               rdi
                               rsi
                               rdx
                               rcx
                               r8
                               r9
                               fv0
                               rax
                               bat.2.8
                               bar.4.6
                               bar.3.7))
                 (rax (rbp tmp-ra.19))
                 (fv0 (bat.6.5 r15
                               rdi
                               rsi
                               rdx
                               rcx
                               r8
                               r9
                               rbp
                               tmp-ra.19
                               bat.2.4
                               foobar.8.3
                               bar.3.2
                               foo.1.1))
                 (r9 (bat.6.5 r15 rdi rsi rdx rcx r8 rbp fv0 tmp-ra.19 bat.2.4 foobar.8.3 bar.3.2))
                 (r8 (bar.3.2 bat.6.5 r15 rdi rsi rdx rcx rbp r9 fv0 tmp-ra.19 bat.2.4 foobar.8.3))
                 (rcx (bar.3.2 bat.6.5 r15 rdi rsi rdx rbp r8 r9 fv0 tmp-ra.19 bat.2.4 foobar.8.3))
                 (rdx (bat.2.4 bat.6.5 bar.3.2 r15 rdi rsi rbp rcx r8 r9 fv0 tmp-ra.19 foobar.8.3))
                 (rsi (bat.6.5 bar.3.2 r15 rdi rbp rdx rcx r8 r9 fv0 tmp-ra.19 bat.2.4))
                 (rdi (r15 rbp rsi rdx rcx r8 r9 fv0 tmp-ra.19))
                 (r15 (rbp rdi rsi rdx rcx r8 r9 fv0))))
               (assignment ()))
              (begin
                (set! tmp-ra.19 r15)
                (set! bat.6.5 rdi)
                (set! bat.2.4 rsi)
                (set! foobar.8.3 rdx)
                (set! bar.3.2 rcx)
                (set! foo.1.1 r8)
                (if (<= bat.2.4 9223372036854775807)
                    (if (true)
                        (begin
                          (set! fv0 bar.3.2)
                          (set! r9 -9223372036854775808)
                          (set! r8 1)
                          (set! rcx foobar.8.3)
                          (set! rdx bat.6.5)
                          (set! rsi foobar.8.3)
                          (set! rdi bar.3.2)
                          (set! r15 tmp-ra.19)
                          (jump L.tmp.1.2 rbp r15 rdi rsi rdx rcx r8 r9 fv0))
                        (begin
                          (set! fv0 bat.6.5)
                          (set! r9 foo.1.1)
                          (set! r8 bar.3.2)
                          (set! rcx bar.3.2)
                          (set! rdx bat.2.4)
                          (set! rsi foobar.8.3)
                          (set! rdi bat.2.4)
                          (set! r15 tmp-ra.19)
                          (jump L.tmp.1.2 rbp r15 rdi rsi rdx rcx r8 r9 fv0)))
                    (begin
                      (set! bar.3.7 foo.1.1)
                      (set! bar.4.6 bat.6.5)
                      (set! bat.2.8 foobar.8.3)
                      (set! rax bat.2.8)
                      (jump tmp-ra.19 rbp rax)))))
      (define L.tmp.1.2
        ((locals (bar.3.16 bat.0.17 tmp.23 tmp.22 bat.0.12 foobar.8.13 bar.3.15))
         (conflicts
          ((tmp-ra.20 (bar.3.16 bat.0.17
                                tmp.23
                                tmp.22
                                rax
                                foobar.8.18
                                bat.6.9
                                foobar.7.10
                                bat.2.11
                                bat.0.12
                                foobar.8.13
                                foo.1.14
                                bar.3.15
                                rbp
                                fv0
                                r9
                                r8
                                rcx
                                rdx
                                rsi
                                rdi))
           (bar.3.15 (rbp tmp-ra.20 fv0 r9 r8 rcx rdx rsi))
           (foo.1.14 (bar.3.16 bat.0.17
                               tmp.23
                               tmp.22
                               rax
                               foobar.8.18
                               bat.6.9
                               foobar.7.10
                               bat.2.11
                               bat.0.12
                               foobar.8.13
                               rbp
                               tmp-ra.20
                               fv0
                               r9
                               r8
                               rcx
                               rdx))
           (foobar.8.13
            (tmp.22 rdx bat.6.9 foobar.7.10 bat.2.11 bat.0.12 rbp tmp-ra.20 foo.1.14 fv0 r9 r8 rcx))
           (bat.0.12
            (tmp.22 rcx bat.6.9 foobar.7.10 bat.2.11 rbp tmp-ra.20 foo.1.14 foobar.8.13 fv0 r9 r8))
           (bat.2.11 (bat.0.17 tmp.23
                               tmp.22
                               rsi
                               rdx
                               rcx
                               r8
                               rax
                               foobar.8.18
                               bat.6.9
                               foobar.7.10
                               rbp
                               tmp-ra.20
                               foo.1.14
                               bat.0.12
                               foobar.8.13
                               fv0
                               r9))
           (foobar.7.10 (rsi r8
                             r9
                             bar.3.16
                             bat.0.17
                             tmp.23
                             tmp.22
                             rdx
                             rcx
                             rax
                             foobar.8.18
                             bat.6.9
                             rbp
                             tmp-ra.20
                             foo.1.14
                             bat.2.11
                             bat.0.12
                             foobar.8.13
                             fv0))
           (bat.6.9 (r9 fv0
                        bar.3.16
                        bat.0.17
                        tmp.23
                        tmp.22
                        rax
                        foobar.8.18
                        rbp
                        tmp-ra.20
                        foobar.7.10
                        foo.1.14
                        bat.2.11
                        bat.0.12
                        foobar.8.13))
           (foobar.8.18
            (fv0 bar.3.16 rax bat.0.17 tmp.23 rbp tmp-ra.20 foobar.7.10 foo.1.14 bat.6.9 bat.2.11))
           (tmp.22 (rbp tmp-ra.20 foobar.7.10 foo.1.14 bat.6.9 bat.2.11 bat.0.12 foobar.8.13))
           (tmp.23 (bat.6.9 rbp tmp-ra.20 foobar.7.10 foo.1.14 foobar.8.18 bat.2.11))
           (bat.0.17 (rbp tmp-ra.20 foobar.7.10 foo.1.14 bat.6.9 foobar.8.18 bat.2.11))
           (bar.3.16 (r8 r9 fv0 rbp tmp-ra.20 foobar.7.10 foo.1.14 bat.6.9 foobar.8.18))
           (rdi (r9 fv0 r15 rbp rsi rdx rcx r8 tmp-ra.20))
           (rsi (r9 fv0 foobar.7.10 bat.2.11 r15 rdi rbp rdx rcx r8 bar.3.15 tmp-ra.20))
           (rdx (r9 fv0
                    bat.2.11
                    foobar.7.10
                    r15
                    rdi
                    rsi
                    rbp
                    rcx
                    r8
                    foobar.8.13
                    foo.1.14
                    bar.3.15
                    tmp-ra.20))
           (rcx (r9 fv0
                    bat.2.11
                    foobar.7.10
                    bat.0.12
                    r15
                    rdi
                    rsi
                    rdx
                    rbp
                    r8
                    foobar.8.13
                    foo.1.14
                    bar.3.15
                    tmp-ra.20))
           (r8 (r9 fv0
                   foobar.7.10
                   bar.3.16
                   bat.2.11
                   r15
                   rdi
                   rsi
                   rdx
                   rcx
                   rbp
                   bat.0.12
                   foobar.8.13
                   foo.1.14
                   bar.3.15
                   tmp-ra.20))
           (r9 (r15 rdi
                    rsi
                    rdx
                    rcx
                    r8
                    rbp
                    fv0
                    foobar.7.10
                    bar.3.16
                    bat.6.9
                    bat.2.11
                    bat.0.12
                    foobar.8.13
                    foo.1.14
                    bar.3.15
                    tmp-ra.20))
           (fv0 (r15 rdi
                     rsi
                     rdx
                     rcx
                     r8
                     r9
                     rbp
                     bar.3.16
                     bat.6.9
                     foobar.8.18
                     foobar.7.10
                     bat.2.11
                     bat.0.12
                     foobar.8.13
                     foo.1.14
                     bar.3.15
                     tmp-ra.20))
           (rbp (r9 fv0
                    bar.3.16
                    bat.0.17
                    tmp.23
                    tmp.22
                    r15
                    rdi
                    rsi
                    rdx
                    rcx
                    r8
                    rax
                    foobar.8.18
                    bat.6.9
                    foobar.7.10
                    bat.2.11
                    bat.0.12
                    foobar.8.13
                    foo.1.14
                    bar.3.15
                    tmp-ra.20))
           (rax (foobar.8.18 rbp tmp-ra.20 foobar.7.10 foo.1.14 bat.6.9 bat.2.11))
           (r15 (r9 fv0 rbp rdi rsi rdx rcx r8))))
         (assignment ((tmp-ra.20 fv1) (foobar.7.10 fv2)
                                      (foo.1.14 fv3)
                                      (bat.6.9 fv4)
                                      (bat.2.11 fv5)
                                      (foobar.8.18 fv6))))
        (begin
          (set! tmp-ra.20 r15)
          (set! bar.3.15 rdi)
          (set! foo.1.14 rsi)
          (set! foobar.8.13 rdx)
          (set! bat.0.12 rcx)
          (set! bat.2.11 r8)
          (set! foobar.7.10 r9)
          (set! bat.6.9 fv0)
          (if (not (begin
                     (set! tmp.22 1242010444)
                     (> tmp.22 foobar.8.13)))
              (begin
                (begin
                  (set! rbp (- rbp 56))
                  (return-point L.rp.3
                                (begin
                                  (set! r8 foobar.7.10)
                                  (set! rcx 1)
                                  (set! rdx bat.0.12)
                                  (set! rsi foobar.7.10)
                                  (set! rdi bat.2.11)
                                  (set! r15 L.rp.3)
                                  (jump L.tmp.0.1 rbp r15 rdi rsi rdx rcx r8)))
                  (set! rbp (+ rbp 56)))
                (set! foobar.8.18 rax))
              (begin
                (begin
                  (set! rbp (- rbp 56))
                  (return-point L.rp.4
                                (begin
                                  (set! r8 bat.0.12)
                                  (set! rcx bat.0.12)
                                  (set! rdx foo.1.14)
                                  (set! rsi foobar.8.13)
                                  (set! rdi foobar.8.13)
                                  (set! r15 L.rp.4)
                                  (jump L.tmp.0.1 rbp r15 rdi rsi rdx rcx r8)))
                  (set! rbp (+ rbp 56)))
                (set! foobar.8.18 rax)))
          (set! tmp.23 bat.6.9)
          (set! tmp.23 (* tmp.23 foo.1.14))
          (set! bat.0.17 tmp.23)
          (begin
            (set! rbp (- rbp 56))
            (return-point L.rp.5
                          (begin
                            (set! r8 bat.2.11)
                            (set! rcx bat.2.11)
                            (set! rdx 0)
                            (set! rsi foo.1.14)
                            (set! rdi foo.1.14)
                            (set! r15 L.rp.5)
                            (jump L.tmp.0.1 rbp r15 rdi rsi rdx rcx r8)))
            (set! rbp (+ rbp 56)))
          (set! bar.3.16 rax)
          (set! fv0 foobar.7.10)
          (set! r9 foobar.8.18)
          (set! r8 bat.6.9)
          (set! rcx bar.3.16)
          (set! rdx 1)
          (set! rsi foo.1.14)
          (set! rdi foobar.7.10)
          (set! r15 tmp-ra.20)
          (jump L.tmp.1.2 rbp r15 rdi rsi rdx rcx r8 r9 fv0)))
      (begin
        (set! tmp-ra.21 r15)
        (if (not (begin
                   (set! tmp.24 1973720366)
                   (< tmp.24 1864083813)))
            (begin
              (set! rax 9223372036854775807)
              (jump tmp-ra.21 rbp rax))
            (begin
              (set! fv0 379193781)
              (set! r9 726597669)
              (set! r8 -264137160)
              (set! rcx -1022801227)
              (set! rdx 501537014)
              (set! rsi 9223372036854775807)
              (set! rdi 9223372036854775807)
              (set! r15 tmp-ra.21)
              (jump L.tmp.1.2 rbp r15 rdi rsi rdx rcx r8 r9 fv0))))))
  (check-by-interp '(module ((locals (ball.8.3 bat.6.2 foo.5.1 tmp-ra.4))
                             (conflicts ((tmp-ra.4 (foo.5.1 bat.6.2 ball.8.3 rbp rax))
                                         (foo.5.1 (rbp tmp-ra.4 bat.6.2 ball.8.3))
                                         (bat.6.2 (foo.5.1 rbp tmp-ra.4 ball.8.3))
                                         (ball.8.3 (foo.5.1 bat.6.2 rbp tmp-ra.4))
                                         (rax (rbp tmp-ra.4))
                                         (rbp (foo.5.1 bat.6.2 ball.8.3 tmp-ra.4 rax))))
                             (assignment ()))
                            (begin
                              (set! tmp-ra.4 r15)
                              (set! ball.8.3 1521957632)
                              (set! bat.6.2 -9223372036854775808)
                              (set! foo.5.1 -9223372036854775808)
                              (if (false)
                                  (if (!= bat.6.2 bat.6.2)
                                      (begin
                                        (set! rax foo.5.1)
                                        (jump tmp-ra.4 rbp rax))
                                      (begin
                                        (set! rax bat.6.2)
                                        (jump tmp-ra.4 rbp rax)))
                                  (if (> ball.8.3 -755834168)
                                      (begin
                                        (set! rax 0)
                                        (jump tmp-ra.4 rbp rax))
                                      (begin
                                        (set! rax bat.6.2)
                                        (jump tmp-ra.4 rbp rax)))))
                      ))
  (check-by-interp
   '(module ((locals (ball.9.8 foo.4.2 foo.3.3 bar.0.4 ball.9.5 bar.7.6 foobar.8.7 ball.1.1 tmp-ra.9))
             (conflicts
              ((tmp-ra.9
                (rax ball.9.8 foo.4.2 foo.3.3 bar.0.4 ball.9.5 bar.7.6 foobar.8.7 ball.1.1 rbp))
               (ball.1.1 (ball.9.8 bar.0.4 foobar.8.7 rbp tmp-ra.9))
               (foobar.8.7 (rbp tmp-ra.9 ball.1.1))
               (bar.7.6 (rbp tmp-ra.9))
               (ball.9.5 (rbp tmp-ra.9))
               (bar.0.4 (foo.4.2 foo.3.3 rbp tmp-ra.9 ball.1.1))
               (foo.3.3 (rbp tmp-ra.9 bar.0.4))
               (foo.4.2 (rbp tmp-ra.9 bar.0.4))
               (ball.9.8 (rbp tmp-ra.9 ball.1.1))
               (rbp
                (rax ball.9.8 foo.4.2 foo.3.3 bar.0.4 ball.9.5 bar.7.6 foobar.8.7 ball.1.1 tmp-ra.9))
               (rax (rbp tmp-ra.9))))
             (assignment ()))
            (begin
              (set! tmp-ra.9 r15)
              (set! ball.1.1 -9223372036854775808)
              (set! foobar.8.7 0)
              (set! bar.7.6 ball.1.1)
              (set! ball.9.5 ball.1.1)
              (set! bar.0.4 ball.9.5)
              (set! foo.3.3 ball.1.1)
              (if (> ball.1.1 ball.1.1)
                  (set! foo.4.2 ball.1.1)
                  (set! foo.4.2 ball.1.1))
              (set! ball.9.8 bar.0.4)
              (set! rax ball.1.1)
              (jump tmp-ra.9 rbp rax))
      ))
  (check-by-interp
   '(module ((locals (foobar.1.10 foobar.3.11
                                  foobar.1.2
                                  tmp.13
                                  foo.8.3
                                  foobar.3.4
                                  foo.4.5
                                  foobar.5.6
                                  foo.8.7
                                  foobar.1.8
                                  foo.4.9
                                  foo.7.1
                                  tmp-ra.12))
             (conflicts ((tmp-ra.12 (rax foobar.1.10
                                         foobar.3.11
                                         foobar.1.2
                                         tmp.13
                                         foo.8.3
                                         foo.4.5
                                         foobar.5.6
                                         foo.8.7
                                         foobar.1.8
                                         foo.4.9
                                         foobar.3.4
                                         foo.7.1
                                         rbp))
                         (foo.7.1 (foobar.1.10 foobar.3.11 foobar.1.2 tmp.13 rbp tmp-ra.12))
                         (foo.4.9 (rbp tmp-ra.12))
                         (foobar.1.8 (rbp tmp-ra.12))
                         (foo.8.7 (rbp tmp-ra.12))
                         (foobar.5.6 (rbp tmp-ra.12))
                         (foo.4.5 (rbp tmp-ra.12))
                         (foobar.3.4 (foobar.1.2 tmp.13 foo.8.3 rbp tmp-ra.12))
                         (foo.8.3 (rbp tmp-ra.12 foobar.3.4))
                         (tmp.13 (foo.7.1 rbp tmp-ra.12 foobar.3.4))
                         (foobar.1.2 (rbp tmp-ra.12 foo.7.1 foobar.3.4))
                         (foobar.3.11 (rbp tmp-ra.12 foo.7.1))
                         (foobar.1.10 (rbp tmp-ra.12 foo.7.1))
                         (rbp (rax foobar.1.10
                                   foobar.3.11
                                   foobar.1.2
                                   tmp.13
                                   foo.8.3
                                   foo.4.5
                                   foobar.5.6
                                   foo.8.7
                                   foobar.1.8
                                   foo.4.9
                                   foobar.3.4
                                   foo.7.1
                                   tmp-ra.12))
                         (rax (rbp tmp-ra.12))))
             (assignment ()))
            (begin
              (set! tmp-ra.12 r15)
              (set! foo.7.1 1)
              (if (= foo.7.1 foo.7.1)
                  (begin
                    (set! foo.8.7 foo.7.1)
                    (set! foobar.5.6 foo.7.1)
                    (set! foo.4.5 foo.7.1)
                    (set! foobar.3.4 foo.7.1))
                  (begin
                    (set! foo.4.9 foo.7.1)
                    (set! foobar.1.8 foo.7.1)
                    (set! foobar.3.4 foo.7.1)))
              (set! foo.8.3 foo.7.1)
              (set! tmp.13 foo.7.1)
              (set! tmp.13 (+ tmp.13 foo.7.1))
              (set! foobar.1.2 tmp.13)
              (set! foobar.3.11 foobar.3.4)
              (set! foobar.1.10 1648274049)
              (set! rax foo.7.1)
              (jump tmp-ra.12 rbp rax))
      ))
  (check-by-interp
   '(module ((locals (tmp-ra.4)) (conflicts ((tmp-ra.4 (rax rbp)) (rbp (rax tmp-ra.4))
                                                                  (rax (rbp tmp-ra.4))))
                                 (assignment ()))
            (define L.func.0.1
              ((locals (bat.8.1 bat.7.2 tmp-ra.3))
               (conflicts ((tmp-ra.3 (bat.8.1 bat.7.2 rbp rsi rdi))
                           (bat.7.2 (rbp tmp-ra.3 rsi))
                           (bat.8.1 (rbp tmp-ra.3))
                           (rdi (r15 rbp rsi tmp-ra.3))
                           (rsi (r15 rdi rbp bat.7.2 tmp-ra.3))
                           (rbp (r15 rdi rsi bat.8.1 bat.7.2 tmp-ra.3))
                           (r15 (rbp rdi rsi))))
               (assignment ()))
              (begin
                (set! tmp-ra.3 r15)
                (set! bat.7.2 rdi)
                (set! bat.8.1 rsi)
                (set! rsi bat.8.1)
                (set! rdi 1)
                (set! r15 tmp-ra.3)
                (jump L.func.0.1 rbp r15 rdi rsi)))
      (begin
        (set! tmp-ra.4 r15)
        (set! rax 0)
        (jump tmp-ra.4 rbp rax))))
  (check-by-interp
   '(module ((locals (tmp-ra.1 tmp.2)) (conflicts ((tmp.2 (rbp tmp-ra.1)) (tmp-ra.1 (rbp tmp.2 rax))
                                                                          (rax (rbp tmp-ra.1))
                                                                          (rbp (tmp-ra.1 tmp.2 rax))))
                                       (assignment ()))
            (begin
              (set! tmp-ra.1 r15)
              (if (begin
                    (set! tmp.2 -9223372036854775808)
                    (> tmp.2 526950868))
                  (begin
                    (set! rax -9223372036854775808)
                    (jump tmp-ra.1 rbp rax))
                  (begin
                    (set! rax 9223372036854775807)
                    (jump tmp-ra.1 rbp rax))))
      ))
  (check-by-interp
   '(module ((locals (tmp-ra.18)) (conflicts ((tmp-ra.18 (rdi rsi rdx rcx r8 r9 rbp))
                                              (rbp (r15 rdi rsi rdx rcx r8 r9 tmp-ra.18))
                                              (r9 (r15 rdi rsi rdx rcx r8 rbp tmp-ra.18))
                                              (r8 (r15 rdi rsi rdx rcx rbp r9 tmp-ra.18))
                                              (rcx (r15 rdi rsi rdx rbp r8 r9 tmp-ra.18))
                                              (rdx (r15 rdi rsi rbp rcx r8 r9 tmp-ra.18))
                                              (rsi (r15 rdi rbp rdx rcx r8 r9 tmp-ra.18))
                                              (rdi (r15 rbp rsi rdx rcx r8 r9 tmp-ra.18))
                                              (r15 (rbp rdi rsi rdx rcx r8 r9))))
                                  (assignment ()))
            (define L.fn.0.1
              ((locals (bat.4.1 bar.7.2 ball.9.3 ball.3.4 foobar.6.5 tmp-ra.16))
               (conflicts
                ((tmp-ra.16 (r9 bat.4.1 bar.7.2 ball.9.3 ball.3.4 foobar.6.5 rbp r8 rcx rdx rsi rdi))
                 (foobar.6.5 (rbp tmp-ra.16 r8 rcx rdx rsi))
                 (ball.3.4 (bat.4.1 bar.7.2 ball.9.3 rbp tmp-ra.16 r8 rcx rdx))
                 (ball.9.3 (rbp tmp-ra.16 ball.3.4 r8 rcx))
                 (bar.7.2 (r9 bat.4.1 rbp tmp-ra.16 ball.3.4 r8))
                 (bat.4.1 (rsi rdx r8 r9 rbp tmp-ra.16 ball.3.4 bar.7.2))
                 (rdi (r15 rbp rsi rdx rcx r8 r9 tmp-ra.16))
                 (rsi (r15 rdi rbp rdx rcx r8 r9 bat.4.1 foobar.6.5 tmp-ra.16))
                 (rdx (r15 rdi rsi rbp rcx r8 r9 bat.4.1 ball.3.4 foobar.6.5 tmp-ra.16))
                 (rcx (r15 rdi rsi rdx rbp r8 r9 ball.9.3 ball.3.4 foobar.6.5 tmp-ra.16))
                 (r8
                  (r15 rdi rsi rdx rcx rbp r9 bat.4.1 bar.7.2 ball.9.3 ball.3.4 foobar.6.5 tmp-ra.16))
                 (rbp
                  (r15 rdi rsi rdx rcx r8 r9 bat.4.1 bar.7.2 ball.9.3 ball.3.4 foobar.6.5 tmp-ra.16))
                 (r9 (r15 rdi rsi rdx rcx r8 rbp tmp-ra.16 bat.4.1 bar.7.2))
                 (r15 (rbp rdi rsi rdx rcx r8 r9))))
               (assignment ()))
              (begin
                (set! tmp-ra.16 r15)
                (set! foobar.6.5 rdi)
                (set! ball.3.4 rsi)
                (set! ball.9.3 rdx)
                (set! bar.7.2 rcx)
                (set! bat.4.1 r8)
                (set! r9 ball.3.4)
                (set! r8 bar.7.2)
                (set! rcx bat.4.1)
                (set! rdx 1064830001)
                (set! rsi ball.3.4)
                (set! rdi bat.4.1)
                (set! r15 tmp-ra.16)
                (jump L.func.1.2 rbp r15 rdi rsi rdx rcx r8 r9)))
      (define L.func.1.2
        ((locals (ball.3.15 ball.1.14
                            bat.4.12
                            foo.5.9
                            foo.8.13
                            tmp-ra.17
                            tmp.19
                            ball.9.8
                            tmp.20
                            tmp.21
                            ball.3.6
                            bat.4.10
                            ball.1.11
                            foo.8.7))
         (conflicts
          ((foo.8.7 (ball.3.6 rbp tmp-ra.17 bat.4.10 ball.1.11 foo.5.9 ball.9.8 r9 tmp.19 tmp.21))
           (ball.1.11 (ball.3.6 foo.8.7
                                ball.9.8
                                foo.5.9
                                bat.4.10
                                rbp
                                tmp-ra.17
                                rsi
                                tmp.19
                                tmp.20
                                tmp.21
                                bat.4.12
                                rdx
                                rcx
                                r8
                                r9))
           (bat.4.10 (ball.3.6 foo.8.7
                               ball.9.8
                               foo.5.9
                               rbp
                               tmp-ra.17
                               ball.1.11
                               rcx
                               rdx
                               tmp.19
                               tmp.20
                               tmp.21
                               bat.4.12
                               r8
                               r9))
           (ball.3.6 (rbp tmp-ra.17
                          bat.4.10
                          ball.1.11
                          foo.5.9
                          ball.9.8
                          foo.8.7
                          tmp.19
                          tmp.20
                          tmp.21
                          bat.4.12
                          rcx
                          r8
                          r9
                          ball.1.14
                          ball.3.15))
           (tmp.21 (rbp tmp-ra.17 ball.3.6 bat.4.10 ball.1.11 foo.5.9 ball.9.8 foo.8.7))
           (tmp.20 (rbp tmp-ra.17 ball.3.6 bat.4.10 ball.1.11 foo.5.9 ball.9.8))
           (ball.9.8 (ball.3.6 foo.8.7
                               rbp
                               tmp-ra.17
                               bat.4.10
                               ball.1.11
                               foo.5.9
                               r9
                               r8
                               tmp.19
                               tmp.20
                               tmp.21
                               bat.4.12))
           (tmp.19 (rbp tmp-ra.17 ball.3.6 bat.4.10 ball.1.11 foo.5.9 ball.9.8 foo.8.7))
           (tmp-ra.17 (ball.3.6 foo.8.7
                                ball.9.8
                                foo.5.9
                                bat.4.10
                                ball.1.11
                                rbp
                                tmp.19
                                tmp.20
                                tmp.21
                                bat.4.12
                                rax
                                foo.8.13
                                rdi
                                rsi
                                rdx
                                rcx
                                r8
                                r9
                                ball.1.14
                                ball.3.15))
           (foo.8.13 (rbp tmp-ra.17))
           (foo.5.9 (ball.3.6 foo.8.7
                              ball.9.8
                              rbp
                              tmp-ra.17
                              bat.4.10
                              ball.1.11
                              tmp.19
                              tmp.20
                              tmp.21
                              rsi
                              rdx
                              rcx
                              r9
                              r8
                              ball.1.14))
           (bat.4.12 (rbp tmp-ra.17 ball.3.6 bat.4.10 ball.1.11 ball.9.8))
           (ball.1.14 (rsi rdx rcx r9 rbp tmp-ra.17 ball.3.6 foo.5.9))
           (ball.3.15 (rbp tmp-ra.17 ball.3.6))
           (rbp (ball.3.6 foo.8.7
                          ball.9.8
                          foo.5.9
                          bat.4.10
                          ball.1.11
                          tmp-ra.17
                          tmp.19
                          tmp.20
                          tmp.21
                          bat.4.12
                          rax
                          foo.8.13
                          r15
                          rdi
                          rsi
                          rdx
                          rcx
                          r8
                          r9
                          ball.1.14
                          ball.3.15))
           (r9 (foo.8.7 ball.9.8
                        foo.5.9
                        ball.1.11
                        bat.4.10
                        r15
                        rdi
                        rsi
                        rdx
                        rcx
                        r8
                        rbp
                        tmp-ra.17
                        ball.1.14
                        ball.3.6))
           (r8 (ball.9.8 ball.1.11 bat.4.10 r15 rdi rsi rdx rcx rbp r9 tmp-ra.17 ball.3.6 foo.5.9))
           (rcx (bat.4.10 foo.5.9 ball.1.11 r15 rdi rsi rdx rbp r8 r9 tmp-ra.17 ball.1.14 ball.3.6))
           (rdx (bat.4.10 foo.5.9 ball.1.11 r15 rdi rsi rbp rcx r8 r9 tmp-ra.17 ball.1.14))
           (rsi (ball.1.11 foo.5.9 r15 rdi rbp rdx rcx r8 r9 tmp-ra.17 ball.1.14))
           (rdi (r15 rbp rsi rdx rcx r8 r9 tmp-ra.17))
           (r15 (rbp rdi rsi rdx rcx r8 r9))
           (rax (rbp tmp-ra.17))))
         (assignment ()))
        (begin
          (set! tmp-ra.17 r15)
          (set! ball.1.11 rdi)
          (set! bat.4.10 rsi)
          (set! foo.5.9 rdx)
          (set! ball.9.8 rcx)
          (set! foo.8.7 r8)
          (set! ball.3.6 r9)
          (if (if (if (< foo.8.7 foo.8.7)
                      (= ball.1.11 ball.1.11)
                      (!= bat.4.10 foo.8.7))
                  (= ball.3.6 0)
                  (if (begin
                        (set! tmp.19 0)
                        (> tmp.19 ball.3.6))
                      (begin
                        (set! tmp.20 1)
                        (<= tmp.20 ball.9.8))
                      (begin
                        (set! tmp.21 529266316)
                        (>= tmp.21 foo.8.7))))
              (if (begin
                    (set! bat.4.12 foo.5.9)
                    (<= ball.9.8 bat.4.12))
                  (begin
                    (set! foo.8.13 ball.3.6)
                    (set! rax ball.3.6)
                    (jump tmp-ra.17 rbp rax))
                  (begin
                    (set! r9 ball.3.6)
                    (set! r8 foo.5.9)
                    (set! rcx bat.4.10)
                    (set! rdx bat.4.10)
                    (set! rsi ball.1.11)
                    (set! rdi foo.5.9)
                    (set! r15 tmp-ra.17)
                    (jump L.func.1.2 rbp r15 rdi rsi rdx rcx r8 r9)))
              (begin
                (set! ball.3.15 foo.5.9)
                (set! ball.1.14 ball.3.15)
                (set! r9 foo.5.9)
                (set! r8 ball.1.14)
                (set! rcx foo.5.9)
                (set! rdx ball.3.6)
                (set! rsi ball.3.6)
                (set! rdi ball.1.14)
                (set! r15 tmp-ra.17)
                (jump L.func.1.2 rbp r15 rdi rsi rdx rcx r8 r9)))))
      (begin
        (set! tmp-ra.18 r15)
        (set! r9 0)
        (set! r8 0)
        (set! rcx 1)
        (set! rdx 1)
        (set! rsi -1337458253)
        (set! rdi 9223372036854775807)
        (set! r15 tmp-ra.18)
        (jump L.func.1.2 rbp r15 rdi rsi rdx rcx r8 r9))))
  (check-by-interp
   '(module ((locals (bar.9.4 tmp.9 tmp-ra.5 bat.2.3 bat.2.2 tmp.8 bar.8.1 tmp.7 tmp.6))
             (conflicts
              ((tmp.6 (rbp tmp-ra.5))
               (tmp.7 (rbp tmp-ra.5))
               (bar.8.1 (rbp tmp-ra.5 bat.2.2))
               (tmp.8 (rbp tmp-ra.5 bat.2.2))
               (bat.2.2 (bar.8.1 tmp.8 rbp tmp-ra.5))
               (bat.2.3 (rbp tmp-ra.5))
               (tmp-ra.5 (rbp tmp.6 tmp.7 bar.8.1 tmp.8 bat.2.2 bat.2.3 bar.9.4 tmp.9 rax))
               (tmp.9 (rbp tmp-ra.5))
               (bar.9.4 (rbp tmp-ra.5))
               (rax (rbp tmp-ra.5))
               (rbp (tmp-ra.5 tmp.6 tmp.7 bar.8.1 tmp.8 bat.2.2 bat.2.3 bar.9.4 tmp.9 rax))))
             (assignment ()))
            (begin
              (set! tmp-ra.5 r15)
              (if (if (begin
                        (set! tmp.6 9223372036854775807)
                        (!= tmp.6 2124101395))
                      (true)
                      (not (begin
                             (set! tmp.7 9223372036854775807)
                             (<= tmp.7 0))))
                  (begin
                    (set! bat.2.3 -9223372036854775808)
                    (set! bat.2.2 -9223372036854775808)
                    (set! tmp.8 9223372036854775807)
                    (set! tmp.8 (* tmp.8 -9223372036854775808))
                    (set! bar.8.1 tmp.8)
                    (set! rax bat.2.2)
                    (jump tmp-ra.5 rbp rax))
                  (begin
                    (set! tmp.9 1865158198)
                    (set! tmp.9 (+ tmp.9 1))
                    (set! bar.9.4 tmp.9)
                    (if (> bar.9.4 bar.9.4)
                        (begin
                          (set! rax bar.9.4)
                          (jump tmp-ra.5 rbp rax))
                        (begin
                          (set! rax bar.9.4)
                          (jump tmp-ra.5 rbp rax))))))
      ))
  (check-by-interp
   '(module ((locals (tmp-ra.1 tmp.2)) (conflicts ((tmp.2 (rbp tmp-ra.1)) (tmp-ra.1 (rbp tmp.2 rax))
                                                                          (rax (rbp tmp-ra.1))
                                                                          (rbp (tmp-ra.1 tmp.2 rax))))
                                       (assignment ()))
            (begin
              (set! tmp-ra.1 r15)
              (if (begin
                    (set! tmp.2 1069510162)
                    (>= tmp.2 -9223372036854775808))
                  (begin
                    (set! rax 1)
                    (jump tmp-ra.1 rbp rax))
                  (begin
                    (set! rax 323863587)
                    (jump tmp-ra.1 rbp rax))))
      ))
  (check-by-interp '(module ((locals (tmp.2 tmp-ra.1))
                             (conflicts ((tmp-ra.1 (rax tmp.2 rbp)) (tmp.2 (rbp tmp-ra.1))
                                                                    (rbp (rax tmp.2 tmp-ra.1))
                                                                    (rax (rbp tmp-ra.1))))
                             (assignment ()))
                            (begin
                              (set! tmp-ra.1 r15)
                              (set! tmp.2 379335310)
                              (set! tmp.2 (* tmp.2 0))
                              (set! rax tmp.2)
                              (jump tmp-ra.1 rbp rax))
                      ))
  (check-by-interp
   '(module ((locals (tmp-ra.1)) (conflicts ((tmp-ra.1 (rax rbp)) (rbp (rax tmp-ra.1))
                                                                  (rax (rbp tmp-ra.1))))
                                 (assignment ()))
            (begin
              (set! tmp-ra.1 r15)
              (set! rax 0)
              (jump tmp-ra.1 rbp rax))
      ))
  (check-by-interp
   '(module ((locals (bat.0.3 foo.5.4 ball.3.5 bat.0.1 bat.2.2 tmp.7 tmp-ra.6))
             (conflicts ((tmp-ra.6 (rax bat.0.3 foo.5.4 ball.3.5 bat.0.1 bat.2.2 tmp.7 rbp))
                         (tmp.7 (rbp tmp-ra.6))
                         (bat.2.2 (ball.3.5 bat.0.1 rbp tmp-ra.6))
                         (bat.0.1 (foo.5.4 ball.3.5 rbp tmp-ra.6 bat.2.2))
                         (ball.3.5 (rbp tmp-ra.6 bat.0.1 bat.2.2))
                         (foo.5.4 (bat.0.3 rbp tmp-ra.6 bat.0.1))
                         (bat.0.3 (rbp tmp-ra.6 foo.5.4))
                         (rbp (rax bat.0.3 foo.5.4 ball.3.5 bat.0.1 bat.2.2 tmp.7 tmp-ra.6))
                         (rax (rbp tmp-ra.6))))
             (assignment ()))
            (begin
              (set! tmp-ra.6 r15)
              (set! tmp.7 -9223372036854775808)
              (set! tmp.7 (- tmp.7 0))
              (set! bat.2.2 tmp.7)
              (set! bat.0.1 -9223372036854775808)
              (set! ball.3.5 1969620648)
              (set! foo.5.4 bat.2.2)
              (set! bat.0.3 bat.0.1)
              (set! rax foo.5.4)
              (jump tmp-ra.6 rbp rax))
      ))

  ;;
  )
