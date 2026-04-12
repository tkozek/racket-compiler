#lang racket

(require cpsc411/compiler-lib
         cpsc411/langs/v4
         "../common.rkt")

(provide optimize-predicates
         nested-asm-lang-progs)

;; (nested-asm-lang-fvars-v6 p) -> (nested-asm-lang-fvars-v6 p)
;; Optimizes Nested-asm-lang-v4 programs by analyzing and simplifying predicates
(define (optimize-predicates p)

  ;; (nested-asm-lang-fvars-v6?) -> boolean
  ;; wrapper for int64?, may change implementation if optimize-predicates implementation changes
  ;; to statically evaluate a wider array of expressions.
  (define (concrete? val)
    (int64? val))

  ;; ((nested-asm-lang-fvars-v6 opand) (list (loc . (triv | 'unknown)))) ->
  ;;                                                              (nested-asm-lang-fvars-v6 triv) | 'unknown
  ;; Tries to make opand concrete using env, returns 'unknown if this is not possible
  (define (abstract-opand opand env)
    (if (int64? opand)
        opand
        (hash-ref env opand 'unknown)))

  ;; ((nested-asm-lang-fvars-v6 binop opand opand) (list (loc . (triv | 'unknown))))
  ;;      -> 'unknown | int64
  (define (abstract-binop op v1 v2 env)
    (define v1 (abstract-opand v1 env))
    (define v2 (abstract-opand v2 env))
    (match* (v1 v2)
      [((? int64?) (? int64?)) (op v1 v2)]
      [(_ _) 'unknown]))

  ;; ('relop) -> (nested-asm-lang-fvars-v6 relop)
  ;; Returns the function which op symbolizes.
  (define (patch-relop op)
    (match op
      ['> >]
      ['< <]
      ['= =]
      ['>= >=]
      ['<= <=]
      ['!= (λ (x y) (not (= x y)))]))

  ;; (nested-asm-lang-fvars-v6 relop loc opand (list (loc . (triv | 'unknown)))
  ;;                                          -> '(true) | '(false) | 'unknown
  ;; Attempts to resolve (relop v1 v2), using static information stored in env. Returns 'unknown
  ;; if there is not enough static information available.
  (define (abstract-relop relop loc opand env)
    (define v1 (abstract-opand loc env))
    (define v2 (abstract-opand opand env))
    (match* (v1 v2)
      [((? concrete?) (? concrete?))
       (if ((patch-relop relop) v1 v2)
           '(true)
           '(false))]
      [(_ _) `(,relop ,loc ,opand)]))

  ;; ((nested-asm-lang-fvars-v6 effect) ((and/c hash? (not/c immutable?)))) -> ('unknown | triv)
  (define (update-env effect env)
    (match effect
      [`(set! ,loc ,triv)
       (if (int64? triv)
           (hash-set! env loc triv)
           (hash-set! env loc (hash-ref env triv 'unknown)))]
      [`(set! ,loc1 (,op ,loc1 ,opand))
       (define cur-val (hash-ref env loc1 'unknown))
       (if (int64? cur-val)
           (hash-set! env loc1 (abstract-binop op cur-val opand env))
           (hash-set! env loc1 'unknown))]))

  (define (optimize-pred pred env)
    (match pred
      [`(if (not ,pred) ,pred2 ,pred3) (optimize-pred `(if ,pred ,pred3 ,pred2) env)]
      [`(if ,cond ,then ,else)
       (define optimized-cond (optimize-pred cond env))
       (define env-then (hash-copy env))
       (define env-else (hash-copy env))
       (cond
         [(equal? optimized-cond '(true)) (optimize-pred then env-then)]
         [(equal? optimized-cond '(false)) (optimize-pred else env-else)]
         [else
          `(if ,optimized-cond
               ,(optimize-pred then env-then)
               ,(optimize-pred else env-else))])]
      [`(begin
          ,effects ...
          ,pred)
       `(begin
          ,@(for/list ([e effects])
              (optimize-effect e env))
          ,(optimize-pred pred env))]
      [`(,relop ,loc ,opand) (abstract-relop relop loc opand env)]
      [_ pred]))

  (define (optimize-effect effect env)
    (match effect
      [`(set! ,loc ,rest)
       (begin
         (update-env effect env)
         effect)]
      [`(begin
          ,effects ...)
       `(begin
          ,@(for/list ([effect effects])
              (optimize-effect effect env)))]
      [`(if (not ,cond) ,then ,else) (optimize-effect `(if ,cond ,else ,then) env)]
      [`(if ,cond ,then ,else)
       (define optimized-cond (optimize-pred cond env))
       (define env-then (hash-copy env))
       (define env-else (hash-copy env))
       (cond
         [(equal? optimized-cond '(true)) (optimize-effect then env-then)]
         [(equal? optimized-cond '(false)) (optimize-effect else env-else)]
         [else
          `(if ,optimized-cond
               ,(optimize-effect then env-then)
               ,(optimize-effect else env-else))])]
      ;; not really extending m8
      [_ effect]))

  (define (optimize-tail tail env)
    (match tail
      [`(begin
          ,effects ...
          tail)
       `(begin
          ,@(for/list ([effect effects])
              (optimize-effect effect env))
          ,(optimize-tail tail env))]
      [`(if (not ,pred) ,t1 ,t2) (optimize-tail `(if ,pred ,t2 ,t1) env)]
      [`(if ,pred ,t1 ,t2)
       (define optimized-cond (optimize-pred pred env))
       (define env-then (hash-copy env))
       (define env-else (hash-copy env))
       (cond
         [(equal? optimized-cond '(true)) (optimize-tail t1 env-then)]
         [(equal? optimized-cond '(false)) (optimize-tail t2 env-else)]
         [else
          `(if ,optimized-cond
               ,(optimize-tail t1 env-then)
               ,(optimize-tail t2 env-else))])]
      [_ tail]))

  ;; (nested-asm-lang-fvars-v6) -> (nested-asm-lang-fvars-v6)
  ;; Optimizes an individual nested-asm-lang-fvars-v6 procedure definition
  (define (optimize-def def)
    (match def
      [`(define ,label ,tail) `(define ,label ,(optimize-tail tail (make-hash)))]))

  ;; (nested-asm-lang-fvars-v6 p) -> (nested-asm-lang-fvars-v6 p)
  (define (optimize-p p)
    (match p
      [`(module ,defs ...
          ,tail)
       `(module ,@(map optimize-def defs) ,(optimize-tail tail (make-hash))
          )]))

  (optimize-p p))

(define nested-asm-lang-progs
  '((module (true)) (module (false))
                    (module (not (true)))
                    (module (not (false)))
                    (module (if (true)))))

(module+ test
  (require rackunit
           cpsc411/langs/v6)

  (define-syntax-rule (check-by-interp p)
    (check-equal? (interp-nested-asm-lang-fvars-v6 p)
                  (interp-nested-asm-lang-fvars-v6 (optimize-predicates p))))

  ;; M6 tests; Added by Trevor on March 6th 2026, multiple bindings allowed per let
  (check-by-interp '(module (define L.proc.0.1
                              (begin
                                (set! r15 r15)
                                (set! r14 rdi)
                                (set! r14 rsi)
                                (set! r14 rdx)
                                (set! r14 rcx)
                                (set! r14 r8)
                                (set! r14 r9)
                                (set! r14 fv0)
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
                          (set! fv0 1635273112)
                          (set! r9 r13)
                          (set! r8 r14)
                          (set! rcx r13)
                          (set! rdx 445965252)
                          (set! rsi r13)
                          (set! rdi r14)
                          (set! r15 r15)
                          (jump L.proc.0.1)))
                      (begin
                        (set! r15 r15)
                        (if (if (begin
                                  (set! r14 9223372036854775807)
                                  (<= r14 -9223372036854775808))
                                (begin
                                  (set! r14 692968731)
                                  (< r14 0))
                                (begin
                                  (set! r14 -1490931083)
                                  (<= r14 -14809197)))
                            (begin
                              (set! rax 1275113131)
                              (jump r15))
                            (if (begin
                                  (set! r14 -1702177019)
                                  (<= r14 -9223372036854775808))
                                (begin
                                  (set! rax 0)
                                  (jump r15))
                                (begin
                                  (set! rax 1843455920)
                                  (jump r15)))))))
  (check-by-interp '(module (define L.fn.0.1
                              (begin
                                (set! r15 r15)
                                (set! r14 rdi)
                                (set! r13 rsi)
                                (set! r13 rdx)
                                (set! rdi rcx)
                                (set! r13 r8)
                                (set! r13 r9)
                                (set! r9 fv0)
                                (set! fv0 r13)
                                (set! r9 rdi)
                                (set! r8 rdi)
                                (set! rcx 9223372036854775807)
                                (set! rdx r14)
                                (set! rsi -9223372036854775808)
                                (set! rdi r13)
                                (set! r15 r15)
                                (jump L.fn.0.1)))
                            (begin
                              (set! r15 r15)
                              (set! r14 9223372036854775807)
                              (set! r14 9223372036854775807)
                              (set! r13 9223372036854775807)
                              (set! rax r14)
                              (jump r15))
                      ))
  (check-by-interp '(module (define L.func.0.1
                              (begin
                                (set! fv0 r15)
                                (set! r14 rdi)
                                (set! r15 rsi)
                                (set! r15 rdx)
                                (set! r13 rcx)
                                (set! fv1 r8)
                                (if (true)
                                    (begin
                                      (set! r14 r14)
                                      (begin
                                        (set! rbp (- rbp 16))
                                        (return-point L.rp.3
                                                      (begin
                                                        (set! rdx -1140169546)
                                                        (set! rsi r13)
                                                        (set! rdi r15)
                                                        (set! r15 L.rp.3)
                                                        (jump L.func.1.2)))
                                        (set! rbp (+ rbp 16)))
                                      (set! r15 rax)
                                      (set! r14 fv1)
                                      (set! r14 (+ r14 r15))
                                      (set! rax r14)
                                      (jump fv0))
                                    (begin
                                      (set! rdx 9223372036854775807)
                                      (set! rsi r13)
                                      (set! rdi fv1)
                                      (set! r15 fv0)
                                      (jump L.func.1.2)))))
                            (define L.func.1.2
                              (begin
                                (set! r15 r15)
                                (set! r14 rdi)
                                (set! r13 rsi)
                                (set! r8 rdx)
                                (if (begin
                                      (set! r9 9223372036854775807)
                                      (!= r9 -47909185))
                                    (if (false)
                                        (if (< r8 r8)
                                            (begin
                                              (set! rax r14)
                                              (jump r15))
                                            (begin
                                              (set! rax -9223372036854775808)
                                              (jump r15)))
                                        (begin
                                          (set! rdx r8)
                                          (set! rsi r8)
                                          (set! rdi r14)
                                          (set! r15 r15)
                                          (jump L.func.1.2)))
                                    (begin
                                      (set! r14 -9223372036854775808)
                                      (set! r14 (+ r14 r13))
                                      (set! rax r14)
                                      (jump r15)))))
                      (begin
                        (set! r15 r15)
                        (if (begin
                              (set! r14 9223372036854775807)
                              (> r14 9223372036854775807))
                            (begin
                              (set! rax -877748660)
                              (jump r15))
                            (begin
                              (set! rax -9223372036854775808)
                              (jump r15))))))
  (check-by-interp '(module (begin
                              (set! r15 r15)
                              (set! r14 -1640821439)
                              (set! r14 (+ r14 -406700566))
                              (set! rax r14)
                              (jump r15))))
  (check-by-interp '(module (define L.fn.0.1
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
                                (jump L.x.1.2)))
                      (begin
                        (set! r15 r15)
                        (set! r14 -477286222)
                        (set! r14 0)
                        (set! rax 643069821)
                        (jump r15))))
  (check-by-interp '(module (define L.func.0.1
                              (begin
                                (set! r15 r15)
                                (set! r14 rdi)
                                (if (!= r14 r14)
                                    (begin
                                      (set! rdi 2058053814)
                                      (set! r15 r15)
                                      (jump L.func.0.1))
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
                                      (jump L.x.2.3)))))
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
                          (set! fv0 r15)
                          (set! r15 rdi)
                          (begin
                            (set! rbp (- rbp 8))
                            (return-point L.rp.4
                                          (begin
                                            (set! rdx -1942673900)
                                            (set! rsi r15)
                                            (set! rdi r15)
                                            (set! r15 L.rp.4)
                                            (jump L.tmp.1.2)))
                            (set! rbp (+ rbp 8)))
                          (set! r15 rax)
                          (if (begin
                                (set! r15 r15)
                                (set! r15 r15)
                                (set! r15 r15)
                                (= r15 r15))
                              (begin
                                (set! rdx -1386061378)
                                (set! rsi r15)
                                (set! rdi r15)
                                (set! r15 fv0)
                                (jump L.tmp.1.2))
                              (begin
                                (set! rdi r15)
                                (set! r15 fv0)
                                (jump L.func.0.1)))))
                      (begin
                        (set! r15 r15)
                        (if (true)
                            (begin
                              (set! r14 9223372036854775807)
                              (set! r14 (+ r14 -9223372036854775808))
                              (set! rax r14)
                              (jump r15))
                            (begin
                              (set! rdi -2107846344)
                              (set! r15 r15)
                              (jump L.func.0.1))))))
  (check-by-interp '(module (begin
                              (set! r15 r15)
                              (if (begin
                                    (set! r14 1)
                                    (<= r14 -9223372036854775808))
                                  (if (false)
                                      (begin
                                        (set! rax -9223372036854775808)
                                        (jump r15))
                                      (begin
                                        (set! rax 2012039291)
                                        (jump r15)))
                                  (begin
                                    (set! rax 9223372036854775807)
                                    (jump r15))))))
  (check-by-interp '(module (define L.func.0.1
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
                                (set! fv0 r15)
                                (set! r15 9223372036854775807)
                                (set! r15 (+ r15 1))
                                (set! fv1 r15)
                                (begin
                                  (set! rbp (- rbp 16))
                                  (return-point L.rp.4
                                                (begin
                                                  (set! r9 fv1)
                                                  (set! r8 fv1)
                                                  (set! rcx fv1)
                                                  (set! rdx fv1)
                                                  (set! rsi fv1)
                                                  (set! rdi 0)
                                                  (set! r15 L.rp.4)
                                                  (jump L.func.0.1)))
                                  (set! rbp (+ rbp 16)))
                                (set! r15 rax)
                                (set! r14 fv1)
                                (if (>= fv1 fv1)
                                    (set! r14 fv1)
                                    (set! r14 fv1))
                                (set! r15 r15)
                                (set! r15 r15)
                                (set! r15 -9223372036854775808)
                                (set! rax 9223372036854775807)
                                (jump fv0)))
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
                              (begin
                                (set! rax r13)
                                (jump r15))
                              (begin
                                (set! rax r14)
                                (jump r15)))))
                      (begin
                        (set! r15 r15)
                        (set! rcx 9223372036854775807)
                        (set! rdx -1735352110)
                        (set! rsi 9223372036854775807)
                        (set! rdi 0)
                        (set! r15 r15)
                        (jump L.func.2.3))))
  (check-by-interp '(module (define L.x.0.1
                              (begin
                                (set! fv1 r15)
                                (set! r15 rdi)
                                (set! fv3 rsi)
                                (set! r14 rdx)
                                (set! fv4 rcx)
                                (set! fv2 r8)
                                (set! r13 r9)
                                (set! r14 fv0)
                                (begin
                                  (set! rbp (- rbp 40))
                                  (return-point L.rp.3
                                                (begin
                                                  (set! fv5 r13)
                                                  (set! r9 r15)
                                                  (set! r8 r13)
                                                  (set! rcx 0)
                                                  (set! rdx r14)
                                                  (set! rsi fv4)
                                                  (set! rdi fv4)
                                                  (set! r15 L.rp.3)
                                                  (jump L.fn.1.2)))
                                  (set! rbp (+ rbp 40)))
                                (set! r15 rax)
                                (if (not (begin
                                           (set! r14 0)
                                           (< r14 -9223372036854775808)))
                                    (begin
                                      (set! r14 fv2)
                                      (set! r14 (+ r14 r15))
                                      (set! rax r14)
                                      (jump fv1))
                                    (if (<= fv4 0)
                                        (begin
                                          (set! rax fv4)
                                          (jump fv1))
                                        (begin
                                          (set! rax fv3)
                                          (jump fv1))))))
                            (define L.fn.1.2
                              (begin
                                (set! r15 r15)
                                (set! r14 rdi)
                                (set! r14 rsi)
                                (set! r13 rdx)
                                (set! r13 rcx)
                                (set! r8 r8)
                                (set! r8 r9)
                                (set! r9 fv0)
                                (set! fv0 0)
                                (set! r9 r14)
                                (set! r8 r8)
                                (set! rcx -9223372036854775808)
                                (set! rdx r14)
                                (set! rsi r8)
                                (set! rdi r13)
                                (set! r15 r15)
                                (jump L.fn.1.2)))
                      (begin
                        (set! r15 r15)
                        (if (begin
                              (set! r14 -9223372036854775808)
                              (>= r14 -637253177))
                            (begin
                              (set! rax -9223372036854775808)
                              (jump r15))
                            (begin
                              (set! rax 0)
                              (jump r15))))))
  (check-by-interp '(module (begin
                              (set! r15 r15)
                              (set! rax 9223372036854775807)
                              (jump r15))))
  (check-by-interp '(module (define L.proc.0.1
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
                                (set! fv1 r15)
                                (set! fv3 rdi)
                                (set! fv0 rsi)
                                (set! fv4 rdx)
                                (set! fv5 rcx)
                                (set! fv2 r8)
                                (begin
                                  (set! rbp (- rbp 56))
                                  (return-point L.rp.4
                                                (begin
                                                  (set! r8 fv2)
                                                  (set! rcx fv5)
                                                  (set! rdx fv3)
                                                  (set! rsi fv2)
                                                  (set! rdi fv5)
                                                  (set! r15 L.rp.4)
                                                  (jump L.tmp.1.2)))
                                  (set! rbp (+ rbp 56)))
                                (set! fv6 rax)
                                (begin
                                  (set! rbp (- rbp 56))
                                  (return-point L.rp.5
                                                (begin
                                                  (set! fv7 fv2)
                                                  (set! r9 fv4)
                                                  (set! r8 fv5)
                                                  (set! rcx -501684781)
                                                  (set! rdx fv2)
                                                  (set! rsi 9223372036854775807)
                                                  (set! rdi fv0)
                                                  (set! r15 L.rp.5)
                                                  (jump L.func.2.3)))
                                  (set! rbp (+ rbp 56)))
                                (set! r15 rax)
                                (set! r15 fv0)
                                (begin
                                  (set! rbp (- rbp 56))
                                  (return-point L.rp.6
                                                (begin
                                                  (set! fv7 fv3)
                                                  (set! r9 fv0)
                                                  (set! r8 fv4)
                                                  (set! rcx -9223372036854775808)
                                                  (set! rdx fv2)
                                                  (set! rsi 1644735104)
                                                  (set! rdi fv3)
                                                  (set! r15 L.rp.6)
                                                  (jump L.func.2.3)))
                                  (set! rbp (+ rbp 56)))
                                (set! r15 rax)
                                (set! r14 fv6)
                                (set! r14 (- r14 fv6))
                                (set! r14 r14)
                                (if (= fv6 r15)
                                    (set! r14 r15)
                                    (set! r14 fv6))
                                (set! fv0 r15)
                                (set! r9 -9223372036854775808)
                                (set! r8 fv3)
                                (set! rcx r14)
                                (set! rdx fv2)
                                (set! rsi fv2)
                                (set! rdi r15)
                                (set! r15 fv1)
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
                          (set! r8 fv0)
                          (set! fv0 9223372036854775807)
                          (set! r9 r13)
                          (set! r8 r8)
                          (set! rcx r8)
                          (set! rdx r13)
                          (set! rsi -9223372036854775808)
                          (set! rdi r14)
                          (set! r15 r15)
                          (jump L.func.2.3)))
                      (begin
                        (set! r15 r15)
                        (set! r14 -9223372036854775808)
                        (set! r13 9223372036854775807)
                        (set! r13 9223372036854775807)
                        (set! rax r14)
                        (jump r15))))
  (check-by-interp '(module (define L.func.0.1
                              (begin
                                (set! fv0 r15)
                                (set! r15 rdi)
                                (set! fv2 rsi)
                                (set! fv3 rdx)
                                (set! fv4 rcx)
                                (set! fv1 r8)
                                (if (begin
                                      (set! r14 fv3)
                                      (if (<= fv4 fv1)
                                          (set! r14 fv4)
                                          (set! r14 fv1))
                                      (begin
                                        (begin
                                          (set! rbp (- rbp 40))
                                          (return-point L.rp.3
                                                        (begin
                                                          (set! r8 fv1)
                                                          (set! rcx r15)
                                                          (set! rdx r15)
                                                          (set! rsi fv3)
                                                          (set! rdi 1)
                                                          (set! r15 L.rp.3)
                                                          (jump L.func.0.1)))
                                          (set! rbp (+ rbp 40)))
                                        (set! r15 rax))
                                      (false))
                                    (begin
                                      (set! r8 0)
                                      (set! rcx fv3)
                                      (set! rdx 1603961181)
                                      (set! rsi fv2)
                                      (set! rdi fv1)
                                      (set! r15 fv0)
                                      (jump L.func.0.1))
                                    (begin
                                      (set! r9 fv4)
                                      (set! r8 fv1)
                                      (set! rcx fv2)
                                      (set! rdx fv1)
                                      (set! rsi -9223372036854775808)
                                      (set! rdi fv2)
                                      (set! r15 fv0)
                                      (jump L.fn.1.2)))))
                            (define L.fn.1.2
                              (begin
                                (set! r15 r15)
                                (set! r14 rdi)
                                (set! rdi rsi)
                                (set! rsi rdx)
                                (set! rdx rcx)
                                (set! r13 r8)
                                (set! r9 r9)
                                (if (if (>= r13 r14)
                                        (> rdi -9223372036854775808)
                                        (>= rsi r13))
                                    (begin
                                      (set! r9 rdx)
                                      (set! r9 9223372036854775807)
                                      (set! r14 r14)
                                      (set! rax r13)
                                      (jump r15))
                                    (if (< r13 r14)
                                        (begin
                                          (set! rax rdx)
                                          (jump r15))
                                        (begin
                                          (set! rax rdi)
                                          (jump r15))))))
                      (begin
                        (set! r15 r15)
                        (set! r14 405359082)
                        (if (not (begin
                                   (set! r13 -915730633)
                                   (>= r13 0)))
                            (begin
                              (set! r13 -532660031)
                              (set! r13 -248685178))
                            (set! r13 0))
                        (set! r9 1254220652)
                        (set! r9 r14)
                        (set! r8 r13)
                        (set! rcx 9223372036854775807)
                        (set! rdx r13)
                        (set! rsi r13)
                        (set! rdi -9223372036854775808)
                        (set! r15 r15)
                        (jump L.fn.1.2))))
  (check-by-interp '(module (define L.proc.0.1
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
                          (set! fv1 r15)
                          (set! fv4 rdi)
                          (set! r14 rsi)
                          (set! r15 rdx)
                          (set! fv3 rcx)
                          (set! r13 r8)
                          (set! r9 r9)
                          (set! fv2 fv0)
                          (if (>= fv3 fv2)
                              (set! r15 r14)
                              (begin
                                (begin
                                  (set! rbp (- rbp 40))
                                  (return-point L.rp.4
                                                (begin
                                                  (set! fv5 1783645727)
                                                  (set! r9 r9)
                                                  (set! r8 fv3)
                                                  (set! rcx r13)
                                                  (set! rdx 0)
                                                  (set! rsi r15)
                                                  (set! rdi 1)
                                                  (set! r15 L.rp.4)
                                                  (jump L.x.2.3)))
                                  (set! rbp (+ rbp 40)))
                                (set! r15 rax)))
                          (set! r15 fv3)
                          (set! r15 (* r15 fv3))
                          (set! r15 r15)
                          (set! fv0 fv3)
                          (set! r9 fv4)
                          (set! r8 -922337918)
                          (set! rcx fv2)
                          (set! rdx fv2)
                          (set! rsi fv3)
                          (set! rdi fv2)
                          (set! r15 fv1)
                          (jump L.x.2.3)))
                      (begin
                        (set! r15 r15)
                        (set! r14 0)
                        (set! r13 1029279872)
                        (set! rax r14)
                        (jump r15))))
  (check-by-interp '(module (begin
                              (set! r15 r15)
                              (if (if (begin
                                        (set! r14 1)
                                        (set! r13 -1606724555)
                                        (= r14 r14))
                                      (begin
                                        (set! r14 1)
                                        (set! r13 1)
                                        (set! r13 -9223372036854775808)
                                        (<= r14 r14))
                                      (begin
                                        (begin
                                          (set! r14 -1879829070)
                                          (!= r14 1981475003))))
                                  (begin
                                    (set! r14 -634246165)
                                    (set! r14 (- r14 -684848771))
                                    (set! rax r14)
                                    (jump r15))
                                  (begin
                                    (set! rax 0)
                                    (jump r15))))))
  (check-by-interp '(module (define L.func.0.1
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
                                (jump L.proc.1.2)))
                      (begin
                        (set! r15 r15)
                        (set! r14 0)
                        (set! rax r14)
                        (jump r15))))
  (check-by-interp '(module (begin
                              (set! r15 r15)
                              (set! r14 1550347185)
                              (set! r14 9223372036854775807)
                              (set! r13 -9223372036854775808)
                              (set! r14 r14)
                              (set! r14 r14)
                              (set! r13 9223372036854775807)
                              (set! r13 (- r13 r14))
                              (set! rax r13)
                              (jump r15))))
  (check-by-interp '(module (define L.proc.0.1
                              (begin
                                (set! fv0 r15)
                                (set! fv3 rdi)
                                (set! fv2 rsi)
                                (set! fv1 rdx)
                                (begin
                                  (set! rbp (- rbp 56))
                                  (return-point L.rp.2
                                                (begin
                                                  (set! rdx fv1)
                                                  (set! rsi fv1)
                                                  (set! rdi 9223372036854775807)
                                                  (set! r15 L.rp.2)
                                                  (jump L.proc.0.1)))
                                  (set! rbp (+ rbp 56)))
                                (set! fv5 rax)
                                (begin
                                  (set! rbp (- rbp 56))
                                  (return-point L.rp.3
                                                (begin
                                                  (set! rdx fv3)
                                                  (set! rsi fv1)
                                                  (set! rdi fv3)
                                                  (set! r15 L.rp.3)
                                                  (jump L.proc.0.1)))
                                  (set! rbp (+ rbp 56)))
                                (set! fv4 rax)
                                (begin
                                  (set! rbp (- rbp 56))
                                  (return-point L.rp.4
                                                (begin
                                                  (set! rdx fv3)
                                                  (set! rsi fv1)
                                                  (set! rdi fv1)
                                                  (set! r15 L.rp.4)
                                                  (jump L.proc.0.1)))
                                  (set! rbp (+ rbp 56)))
                                (set! fv3 rax)
                                (set! r15 fv2)
                                (begin
                                  (set! rbp (- rbp 56))
                                  (return-point L.rp.5
                                                (begin
                                                  (set! rdx fv2)
                                                  (set! rsi fv1)
                                                  (set! rdi fv1)
                                                  (set! r15 L.rp.5)
                                                  (jump L.proc.0.1)))
                                  (set! rbp (+ rbp 56)))
                                (set! r15 rax)
                                (begin
                                  (set! rbp (- rbp 56))
                                  (return-point L.rp.6
                                                (begin
                                                  (set! rdx fv3)
                                                  (set! rsi r15)
                                                  (set! rdi r15)
                                                  (set! r15 L.rp.6)
                                                  (jump L.proc.0.1)))
                                  (set! rbp (+ rbp 56)))
                                (set! r15 rax)
                                (if (> r15 fv1)
                                    (if (>= fv5 fv5)
                                        (begin
                                          (set! rax fv1)
                                          (jump fv0))
                                        (begin
                                          (set! rax r15)
                                          (jump fv0)))
                                    (begin
                                      (set! r15 -2087609688)
                                      (set! r15 fv5)
                                      (set! rax fv4)
                                      (jump fv0)))))
                            (begin
                              (set! r15 r15)
                              (set! r14 1)
                              (set! r14 -9223372036854775808)
                              (set! rax r14)
                              (jump r15))
                      ))
  (check-by-interp '(module (define L.fn.0.1
                              (begin
                                (set! r15 r15)
                                (set! r14 rdi)
                                (if (true)
                                    (begin
                                      (set! rcx 2099518136)
                                      (set! rdx r14)
                                      (set! rsi r14)
                                      (set! rdi r14)
                                      (set! r15 r15)
                                      (jump L.func.2.3))
                                    (begin
                                      (set! rcx r14)
                                      (set! rdx r14)
                                      (set! rsi r14)
                                      (set! rdi r14)
                                      (set! r15 r15)
                                      (jump L.func.2.3)))))
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
                          (jump L.tmp.1.2)))
                      (begin
                        (set! r15 r15)
                        (set! r14 1)
                        (set! r14 (+ r14 9223372036854775807))
                        (set! r14 r14)
                        (set! rax r14)
                        (jump r15))))
  (check-by-interp '(module (begin
                              (set! r15 r15)
                              (set! r14 0)
                              (set! r14 1)
                              (set! rax r14)
                              (jump r15))))
  (check-by-interp '(module (define L.func.0.1
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
                                (if (true)
                                    (if (if (>= rsi rsi)
                                            (< r14 rdi)
                                            (< r8 812242710))
                                        (begin
                                          (set! r14 rsi)
                                          (set! r14 (- r14 rdi))
                                          (set! rax r14)
                                          (jump r15))
                                        (begin
                                          (set! r15 r15)
                                          (jump L.func.0.1)))
                                    (begin
                                      (set! r9 rdi)
                                      (set! r8 r8)
                                      (set! rcx r8)
                                      (set! rdx rdi)
                                      (set! rsi rsi)
                                      (set! rdi r13)
                                      (set! r15 r15)
                                      (jump L.x.1.2)))))
                      (begin
                        (set! r15 r15)
                        (set! r9 -9223372036854775808)
                        (set! r8 0)
                        (set! rcx -9223372036854775808)
                        (set! rdx -9223372036854775808)
                        (set! rsi -2062025435)
                        (set! rdi 0)
                        (set! r15 r15)
                        (jump L.x.1.2))))
  (check-by-interp '(module (define L.func.0.1
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
                                (jump r15)))
                      (begin
                        (set! r15 r15)
                        (set! rax 1)
                        (jump r15))))
  (check-by-interp '(module (begin
                              (set! r15 r15)
                              (set! r14 -550916464)
                              (set! r14 9223372036854775807)
                              (set! rax r14)
                              (jump r15))))
  (check-by-interp '(module (begin
                              (set! r15 r15)
                              (if (false)
                                  (if (if (begin
                                            (set! r14 9223372036854775807)
                                            (< r14 1646335033))
                                          (begin
                                            (set! r14 9223372036854775807)
                                            (>= r14 1))
                                          (begin
                                            (set! r14 9223372036854775807)
                                            (!= r14 1)))
                                      (if (begin
                                            (set! r14 -9223372036854775808)
                                            (!= r14 -9223372036854775808))
                                          (begin
                                            (set! rax -9223372036854775808)
                                            (jump r15))
                                          (begin
                                            (set! rax 1282320164)
                                            (jump r15)))
                                      (begin
                                        (set! r14 -9223372036854775808)
                                        (set! rax r14)
                                        (jump r15)))
                                  (begin
                                    (set! r14 9223372036854775807)
                                    (set! r14 (- r14 1))
                                    (set! rax r14)
                                    (jump r15))))))
  (check-by-interp '(module (define L.tmp.0.1
                              (begin
                                (set! fv0 r15)
                                (set! fv2 rdi)
                                (set! fv1 rsi)
                                (set! r15 rdx)
                                (set! fv3 rcx)
                                (begin
                                  (set! rbp (- rbp 32))
                                  (return-point L.rp.3
                                                (begin
                                                  (set! rcx fv2)
                                                  (set! rdx fv3)
                                                  (set! rsi fv1)
                                                  (set! rdi fv1)
                                                  (set! r15 L.rp.3)
                                                  (jump L.tmp.0.1)))
                                  (set! rbp (+ rbp 32)))
                                (set! r15 rax)
                                (set! r15 fv1)
                                (set! r15 (- r15 fv3))
                                (set! r15 r15)
                                (set! r15 fv1)
                                (set! r15 1)
                                (set! r15 fv3)
                                (set! r15 fv2)
                                (begin
                                  (set! rbp (- rbp 32))
                                  (return-point L.rp.4
                                                (begin
                                                  (set! rdx fv2)
                                                  (set! rsi 9223372036854775807)
                                                  (set! rdi fv3)
                                                  (set! r15 L.rp.4)
                                                  (jump L.x.1.2)))
                                  (set! rbp (+ rbp 32)))
                                (set! r15 rax)
                                (set! rdx fv1)
                                (set! rsi fv1)
                                (set! rdi -9223372036854775808)
                                (set! r15 fv0)
                                (jump L.x.1.2)))
                            (define L.x.1.2
                              (begin
                                (set! r15 r15)
                                (set! r9 rdi)
                                (set! r14 rsi)
                                (set! r13 rdx)
                                (if (false)
                                    (begin
                                      (set! rdx r14)
                                      (set! rsi r13)
                                      (set! rdi 9223372036854775807)
                                      (set! r15 r15)
                                      (jump L.x.1.2))
                                    (if (false)
                                        (begin
                                          (set! rcx r9)
                                          (set! rdx r14)
                                          (set! rsi r9)
                                          (set! rdi r14)
                                          (set! r15 r15)
                                          (jump L.tmp.0.1))
                                        (begin
                                          (set! rdx r13)
                                          (set! rsi 580696126)
                                          (set! rdi r13)
                                          (set! r15 r15)
                                          (jump L.x.1.2))))))
                      (begin
                        (set! r15 r15)
                        (if (begin
                              (set! r14 9223372036854775807)
                              (<= r14 9223372036854775807))
                            (begin
                              (set! rax -1677147892)
                              (jump r15))
                            (begin
                              (set! rax 874915829)
                              (jump r15))))))
  (check-by-interp '(module (define L.proc.0.1
                              (begin
                                (set! fv1 r15)
                                (set! fv5 rdi)
                                (set! fv3 rsi)
                                (set! fv6 rdx)
                                (set! r15 rcx)
                                (set! fv4 r8)
                                (set! fv2 r9)
                                (set! fv0 fv0)
                                (if (not (> fv0 -727829088))
                                    (begin
                                      (set! r14 fv5)
                                      (begin
                                        (set! rbp (- rbp 56))
                                        (return-point L.rp.4
                                                      (begin
                                                        (set! fv7 fv5)
                                                        (set! r9 fv5)
                                                        (set! r8 r15)
                                                        (set! rcx fv3)
                                                        (set! rdx fv6)
                                                        (set! rsi fv4)
                                                        (set! rdi fv3)
                                                        (set! r15 L.rp.4)
                                                        (jump L.proc.0.1)))
                                        (set! rbp (+ rbp 56)))
                                      (set! r15 rax)
                                      (begin
                                        (set! rbp (- rbp 56))
                                        (return-point L.rp.5
                                                      (begin
                                                        (set! r9 fv0)
                                                        (set! r8 -9223372036854775808)
                                                        (set! rcx fv4)
                                                        (set! rdx 1)
                                                        (set! rsi fv5)
                                                        (set! rdi fv6)
                                                        (set! r15 L.rp.5)
                                                        (jump L.fn.1.2)))
                                        (set! rbp (+ rbp 56)))
                                      (set! r15 rax)
                                      (set! r15 fv3)
                                      (set! rax fv2)
                                      (jump fv1))
                                    (begin
                                      (set! rax -774243080)
                                      (jump fv1)))))
                            (define L.fn.1.2
                              (begin
                                (set! r15 r15)
                                (set! rdi rdi)
                                (set! r14 rsi)
                                (set! rsi rdx)
                                (set! rbx rcx)
                                (set! r13 r8)
                                (set! r8 r9)
                                (if (if (if (< r13 rdi)
                                            (>= rdi rbx)
                                            (!= r14 r14))
                                        (if (>= r8 rbx)
                                            (< rdi rdi)
                                            (>= rsi r13))
                                        (not (> rbx r8)))
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
                                      (jump L.fn.1.2))
                                    (begin
                                      (set! r9 rdi)
                                      (set! r8 r8)
                                      (set! rcx r8)
                                      (set! rdx r14)
                                      (set! rsi r13)
                                      (set! rdi rbx)
                                      (set! r15 r15)
                                      (jump L.fn.2.3)))))
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
                      (begin
                        (set! r15 r15)
                        (if (begin
                              (set! r14 -534391580)
                              (< r14 9223372036854775807))
                            (begin
                              (set! rax 0)
                              (jump r15))
                            (begin
                              (set! rax 0)
                              (jump r15))))))
  (check-by-interp '(module (begin
                              (set! r15 r15)
                              (set! r14 -1762920629)
                              (set! r14 1)
                              (set! r14 9223372036854775807)
                              (set! rax 0)
                              (jump r15))))
  (check-by-interp '(module (define L.proc.0.1
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
                            (begin
                              (set! r15 r15)
                              (if (begin
                                    (set! r14 1038395452)
                                    (!= r14 1))
                                  (begin
                                    (set! rax -9223372036854775808)
                                    (jump r15))
                                  (begin
                                    (set! rax 717010255)
                                    (jump r15))))
                      ))
  (check-by-interp '(module (begin
                              (set! r15 r15)
                              (if (true)
                                  (if (not (begin
                                             (set! r14 0)
                                             (= r14 1)))
                                      (if (begin
                                            (set! r14 -9223372036854775808)
                                            (>= r14 -1744096882))
                                          (begin
                                            (set! rax 0)
                                            (jump r15))
                                          (begin
                                            (set! rax 9223372036854775807)
                                            (jump r15)))
                                      (if (begin
                                            (set! r14 -9223372036854775808)
                                            (< r14 0))
                                          (begin
                                            (set! rax 1)
                                            (jump r15))
                                          (begin
                                            (set! rax 9223372036854775807)
                                            (jump r15))))
                                  (if (false)
                                      (begin
                                        (set! r14 1032709229)
                                        (set! r13 1)
                                        (set! rax r14)
                                        (jump r15))
                                      (begin
                                        (set! r14 9223372036854775807)
                                        (set! rax r14)
                                        (jump r15)))))))
  (check-by-interp '(module (begin
                              (set! r15 r15)
                              (if (begin
                                    (set! r14 0)
                                    (< r14 9223372036854775807))
                                  (begin
                                    (set! rax 1620518798)
                                    (jump r15))
                                  (if (begin
                                        (set! r14 0)
                                        (!= r14 9223372036854775807))
                                      (begin
                                        (set! rax 0)
                                        (jump r15))
                                      (begin
                                        (set! rax -9223372036854775808)
                                        (jump r15)))))))
  (check-by-interp '(module (define L.func.0.1
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
                                (if (false)
                                    (begin
                                      (set! r9 r9)
                                      (set! r8 r13)
                                      (set! rcx 0)
                                      (set! rdx r14)
                                      (set! rsi r14)
                                      (set! rdi r13)
                                      (set! r15 r15)
                                      (jump L.tmp.2.3))
                                    (begin
                                      (set! rdx r13)
                                      (set! rsi 9223372036854775807)
                                      (set! rdi r14)
                                      (set! r15 r15)
                                      (jump L.tmp.1.2)))))
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
                      (begin
                        (set! r15 r15)
                        (if (begin
                              (set! r14 -9223372036854775808)
                              (= r14 9223372036854775807))
                            (begin
                              (set! rax 9223372036854775807)
                              (jump r15))
                            (begin
                              (set! rax 1)
                              (jump r15))))))
  (check-by-interp '(module (define L.fn.0.1
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
                            (begin
                              (set! r15 r15)
                              (set! rax -167685894)
                              (jump r15))
                      ))
  (check-by-interp '(module (define L.func.0.1
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
                          (jump L.func.0.1)))
                      (begin
                        (set! r15 r15)
                        (set! r14 1962527269)
                        (set! r14 (+ r14 9223372036854775807))
                        (set! rax r14)
                        (jump r15))))
  (check-by-interp '(module (define L.func.0.1
                              (begin
                                (set! r15 r15)
                                (set! r14 rdi)
                                (if (if (true)
                                        (not (> r14 r14))
                                        (begin
                                          (set! r13 2020417677)
                                          (>= r13 -9223372036854775808)))
                                    (if (true)
                                        (if (= r14 r14)
                                            (begin
                                              (set! rax r14)
                                              (jump r15))
                                            (begin
                                              (set! rax r14)
                                              (jump r15)))
                                        (begin
                                          (set! rdi r14)
                                          (set! r15 r15)
                                          (jump L.func.0.1)))
                                    (begin
                                      (set! rdi 9223372036854775807)
                                      (set! r15 r15)
                                      (jump L.func.0.1)))))
                            (begin
                              (set! r15 r15)
                              (set! rdi 733499244)
                              (set! r15 r15)
                              (jump L.func.0.1))
                      ))
  (check-by-interp '(module (define L.proc.0.1
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
                          (set! fv0 r15)
                          (set! fv1 rdi)
                          (begin
                            (set! rbp (- rbp 16))
                            (return-point L.rp.4
                                          (begin
                                            (set! rcx fv1)
                                            (set! rdx fv1)
                                            (set! rsi fv1)
                                            (set! rdi fv1)
                                            (set! r15 L.rp.4)
                                            (jump L.proc.0.1)))
                            (set! rbp (+ rbp 16)))
                          (set! r15 rax)
                          (set! r15 r15)
                          (set! r15 (- r15 r15))
                          (set! r15 r15)
                          (if (<= r15 fv1)
                              (set! r14 r15)
                              (set! r14 fv1))
                          (set! r15 r15)
                          (set! r14 fv1)
                          (set! r14 r15)
                          (set! r15 r15)
                          (set! r15 fv1)
                          (set! rdi r15)
                          (set! r15 fv0)
                          (jump L.x.2.3)))
                      (begin
                        (set! r15 r15)
                        (set! r14 1830309714)
                        (set! r13 -9223372036854775808)
                        (set! r13 -9223372036854775808)
                        (set! rax r14)
                        (jump r15))))
  (check-by-interp '(module (define L.func.0.1
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
                                (set! fv0 r15)
                                (set! r15 -620373304)
                                (set! r15 (- r15 -68719063))
                                (set! r15 r15)
                                (set! fv1 0)
                                (begin
                                  (set! rbp (- rbp 16))
                                  (return-point L.rp.4
                                                (begin
                                                  (set! r15 L.rp.4)
                                                  (jump L.func.1.2)))
                                  (set! rbp (+ rbp 16)))
                                (set! r15 rax)
                                (set! rax fv1)
                                (jump fv0)))
                      (define L.x.2.3
                        (begin
                          (set! r15 r15)
                          (set! r14 rdi)
                          (set! r15 r15)
                          (jump L.func.1.2)))
                      (begin
                        (set! r15 r15)
                        (set! rax -575594324)
                        (jump r15))))
  (check-by-interp '(module (define L.x.0.1
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
                                    (begin
                                      (set! r9 r14)
                                      (set! r8 r13)
                                      (set! rcx r13)
                                      (set! rdx r13)
                                      (set! rsi r14)
                                      (set! rdi r14)
                                      (set! r15 r15)
                                      (jump L.x.0.1))
                                    (begin
                                      (set! rax r13)
                                      (jump r15)))))
                      (begin
                        (set! r15 r15)
                        (if (not (begin
                                   (set! r14 0)
                                   (= r14 -844906965)))
                            (begin
                              (set! r14 996590913)
                              (set! r13 299367411)
                              (set! r13 -9223372036854775808)
                              (set! rax r14)
                              (jump r15))
                            (if (begin
                                  (set! r14 894536270)
                                  (> r14 1910216157))
                                (begin
                                  (set! rax 1)
                                  (jump r15))
                                (begin
                                  (set! rax 1)
                                  (jump r15)))))))
  (check-by-interp '(module (define L.tmp.0.1
                              (begin
                                (set! r15 r15)
                                (set! r13 rdi)
                                (set! rdi rsi)
                                (set! r14 rdx)
                                (set! rbx rcx)
                                (set! r9 r8)
                                (if (<= rdi 9223372036854775807)
                                    (if (true)
                                        (begin
                                          (set! fv0 rbx)
                                          (set! r9 -9223372036854775808)
                                          (set! r8 1)
                                          (set! rcx r14)
                                          (set! rdx r13)
                                          (set! rsi r14)
                                          (set! rdi rbx)
                                          (set! r15 r15)
                                          (jump L.tmp.1.2))
                                        (begin
                                          (set! fv0 r13)
                                          (set! r9 r9)
                                          (set! r8 rbx)
                                          (set! rcx rbx)
                                          (set! rdx rdi)
                                          (set! rsi r14)
                                          (set! rdi rdi)
                                          (set! r15 r15)
                                          (jump L.tmp.1.2)))
                                    (begin
                                      (set! r9 r9)
                                      (set! r13 r13)
                                      (set! r14 r14)
                                      (set! rax r14)
                                      (jump r15)))))
                            (define L.tmp.1.2
                              (begin
                                (set! fv1 r15)
                                (set! r15 rdi)
                                (set! fv3 rsi)
                                (set! r15 rdx)
                                (set! r14 rcx)
                                (set! fv5 r8)
                                (set! fv2 r9)
                                (set! fv4 fv0)
                                (if (not (begin
                                           (set! r13 1242010444)
                                           (> r13 r15)))
                                    (begin
                                      (begin
                                        (set! rbp (- rbp 56))
                                        (return-point L.rp.3
                                                      (begin
                                                        (set! r8 fv2)
                                                        (set! rcx 1)
                                                        (set! rdx r14)
                                                        (set! rsi fv2)
                                                        (set! rdi fv5)
                                                        (set! r15 L.rp.3)
                                                        (jump L.tmp.0.1)))
                                        (set! rbp (+ rbp 56)))
                                      (set! fv6 rax))
                                    (begin
                                      (begin
                                        (set! rbp (- rbp 56))
                                        (return-point L.rp.4
                                                      (begin
                                                        (set! r8 r14)
                                                        (set! rcx r14)
                                                        (set! rdx fv3)
                                                        (set! rsi r15)
                                                        (set! rdi r15)
                                                        (set! r15 L.rp.4)
                                                        (jump L.tmp.0.1)))
                                        (set! rbp (+ rbp 56)))
                                      (set! fv6 rax)))
                                (set! r15 fv4)
                                (set! r15 (* r15 fv3))
                                (set! r15 r15)
                                (begin
                                  (set! rbp (- rbp 56))
                                  (return-point L.rp.5
                                                (begin
                                                  (set! r8 fv5)
                                                  (set! rcx fv5)
                                                  (set! rdx 0)
                                                  (set! rsi fv3)
                                                  (set! rdi fv3)
                                                  (set! r15 L.rp.5)
                                                  (jump L.tmp.0.1)))
                                  (set! rbp (+ rbp 56)))
                                (set! r15 rax)
                                (set! fv0 fv2)
                                (set! r9 fv6)
                                (set! r8 fv4)
                                (set! rcx r15)
                                (set! rdx 1)
                                (set! rsi fv3)
                                (set! rdi fv2)
                                (set! r15 fv1)
                                (jump L.tmp.1.2)))
                      (begin
                        (set! r15 r15)
                        (if (not (begin
                                   (set! r14 1973720366)
                                   (< r14 1864083813)))
                            (begin
                              (set! rax 9223372036854775807)
                              (jump r15))
                            (begin
                              (set! fv0 379193781)
                              (set! r9 726597669)
                              (set! r8 -264137160)
                              (set! rcx -1022801227)
                              (set! rdx 501537014)
                              (set! rsi 9223372036854775807)
                              (set! rdi 9223372036854775807)
                              (set! r15 r15)
                              (jump L.tmp.1.2))))))
  (check-by-interp '(module (begin
                              (set! r15 r15)
                              (set! r9 1521957632)
                              (set! r13 -9223372036854775808)
                              (set! r14 -9223372036854775808)
                              (if (false)
                                  (if (!= r13 r13)
                                      (begin
                                        (set! rax r14)
                                        (jump r15))
                                      (begin
                                        (set! rax r13)
                                        (jump r15)))
                                  (if (> r9 -755834168)
                                      (begin
                                        (set! rax 0)
                                        (jump r15))
                                      (begin
                                        (set! rax r13)
                                        (jump r15)))))))
  (check-by-interp '(module (begin
                              (set! r15 r15)
                              (set! r14 -9223372036854775808)
                              (set! r13 0)
                              (set! r14 r14)
                              (set! r14 r14)
                              (set! r13 r14)
                              (set! r14 r14)
                              (if (> r14 r14)
                                  (set! r14 r14)
                                  (set! r14 r14))
                              (set! r13 r13)
                              (set! rax r14)
                              (jump r15))))
  (check-by-interp '(module (begin
                              (set! r15 r15)
                              (set! r14 1)
                              (if (= r14 r14)
                                  (begin
                                    (set! r14 r14)
                                    (set! r14 r14)
                                    (set! r14 r14)
                                    (set! r14 r14))
                                  (begin
                                    (set! r14 r14)
                                    (set! r14 r14)
                                    (set! r14 r14)))
                              (set! r13 r14)
                              (set! r13 r14)
                              (set! r13 (+ r13 r14))
                              (set! r13 r13)
                              (set! r13 r14)
                              (set! r13 1648274049)
                              (set! rax r14)
                              (jump r15))))
  (check-by-interp '(module (define L.func.0.1
                              (begin
                                (set! r15 r15)
                                (set! r14 rdi)
                                (set! r14 rsi)
                                (set! rsi r14)
                                (set! rdi 1)
                                (set! r15 r15)
                                (jump L.func.0.1)))
                            (begin
                              (set! r15 r15)
                              (set! rax 0)
                              (jump r15))
                      ))
  (check-by-interp '(module (begin
                              (set! r15 r15)
                              (if (begin
                                    (set! r14 -9223372036854775808)
                                    (> r14 526950868))
                                  (begin
                                    (set! rax -9223372036854775808)
                                    (jump r15))
                                  (begin
                                    (set! rax 9223372036854775807)
                                    (jump r15))))))
  (check-by-interp '(module (define L.fn.0.1
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
                                (if (if (if (< r8 r8)
                                            (= r14 r14)
                                            (!= rsi r8))
                                        (= r13 0)
                                        (if (begin
                                              (set! r9 0)
                                              (> r9 r13))
                                            (begin
                                              (set! r9 1)
                                              (<= r9 rdx))
                                            (begin
                                              (set! r9 529266316)
                                              (>= r9 r8))))
                                    (if (begin
                                          (set! r9 rdi)
                                          (<= rdx r9))
                                        (begin
                                          (set! r14 r13)
                                          (set! rax r13)
                                          (jump r15))
                                        (begin
                                          (set! r9 r13)
                                          (set! r8 rdi)
                                          (set! rcx rsi)
                                          (set! rdx rsi)
                                          (set! rsi r14)
                                          (set! rdi rdi)
                                          (set! r15 r15)
                                          (jump L.func.1.2)))
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
                      (begin
                        (set! r15 r15)
                        (set! r9 0)
                        (set! r8 0)
                        (set! rcx 1)
                        (set! rdx 1)
                        (set! rsi -1337458253)
                        (set! rdi 9223372036854775807)
                        (set! r15 r15)
                        (jump L.func.1.2))))
  (check-by-interp '(module (begin
                              (set! r15 r15)
                              (if (if (begin
                                        (set! r14 9223372036854775807)
                                        (!= r14 2124101395))
                                      (true)
                                      (not (begin
                                             (set! r14 9223372036854775807)
                                             (<= r14 0))))
                                  (begin
                                    (set! r14 -9223372036854775808)
                                    (set! r14 -9223372036854775808)
                                    (set! r13 9223372036854775807)
                                    (set! r13 (* r13 -9223372036854775808))
                                    (set! r13 r13)
                                    (set! rax r14)
                                    (jump r15))
                                  (begin
                                    (set! r14 1865158198)
                                    (set! r14 (+ r14 1))
                                    (set! r14 r14)
                                    (if (> r14 r14)
                                        (begin
                                          (set! rax r14)
                                          (jump r15))
                                        (begin
                                          (set! rax r14)
                                          (jump r15))))))))
  (check-by-interp '(module (begin
                              (set! r15 r15)
                              (if (begin
                                    (set! r14 1069510162)
                                    (>= r14 -9223372036854775808))
                                  (begin
                                    (set! rax 1)
                                    (jump r15))
                                  (begin
                                    (set! rax 323863587)
                                    (jump r15))))))
  (check-by-interp '(module (begin
                              (set! r15 r15)
                              (set! r14 379335310)
                              (set! r14 (* r14 0))
                              (set! rax r14)
                              (jump r15))))
  (check-by-interp '(module (begin
                              (set! r15 r15)
                              (set! rax 0)
                              (jump r15))))
  (check-by-interp '(module (begin
                              (set! r15 r15)
                              (set! r14 -9223372036854775808)
                              (set! r14 (- r14 0))
                              (set! r13 r14)
                              (set! r14 -9223372036854775808)
                              (set! r9 1969620648)
                              (set! r13 r13)
                              (set! r14 r14)
                              (set! rax r13)
                              (jump r15))))
  ;; end multi-let bindings

  (check-equal? (optimize-predicates `(module (begin
                                                (true))))
                `(module (begin
                           (true))))
  (check-equal? (optimize-predicates `(module (begin
                                                (false))))
                `(module (begin
                           (false))))
  (check-equal? (optimize-predicates `(module (begin
                                                (false))))
                `(module (begin
                           (false))))

  (check-equal? (optimize-predicates `(module (if (true)
                                                  (true)
                                                  (false))))
                `(module (true)))
  (check-equal? (optimize-predicates `(module (if (true)
                                                  (false)
                                                  (true))))
                `(module (false)))
  (check-equal? (optimize-predicates `(module (if (false)
                                                  (false)
                                                  (true))))
                `(module (true)))
  (check-equal? (optimize-predicates `(module (if (false)
                                                  (begin
                                                    (set! rax 1)
                                                    (false))
                                                  (begin
                                                    (set! rax -1)
                                                    (true)))))
                `(module (begin
                           (set! rax -1)
                           (true))))
  (check-equal? (optimize-predicates `(module (if (true)
                                                  (begin
                                                    (set! rax 1)
                                                    (false))
                                                  (begin
                                                    (set! rax -1)
                                                    (true)))))
                `(module (begin
                           (set! rax 1)
                           (false))))
  (check-equal? (optimize-predicates `(module (if (> 1 0)
                                                  (begin
                                                    (set! rax 1)
                                                    (false))
                                                  (begin
                                                    (set! rax -1)
                                                    (true)))))
                `(module (begin
                           (set! rax 1)
                           (false))))
  (check-equal? (optimize-predicates `(module (if (not (> 1 0))
                                                  (begin
                                                    (set! rax 1)
                                                    (false))
                                                  (begin
                                                    (set! rax -1)
                                                    (true)))))
                `(module (begin
                           (set! rax -1)
                           (true))))
  (check-equal? (optimize-predicates `(module (if (!= 2 42)
                                                  (begin
                                                    (set! rax 1)
                                                    (false))
                                                  (begin
                                                    (set! rax -1)
                                                    (true)))))
                `(module (begin
                           (set! rax 1)
                           (false)))))
