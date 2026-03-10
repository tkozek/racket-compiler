#lang racket

(require cpsc411/compiler-lib
         cpsc411/langs/v4
         "assign-homes.rkt"
         "../generate-x64.rkt")

(provide optimize-predicates
         nested-asm-lang-progs)

;; nested-asm-lang-v5
;   p	 	::=	 	(module (define label tail) ... tail)
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

;; returns x64 function corresponding to this binop
(define (op->x64-function op)
  (match op

    ['+ x64-add]
    ['* x64-mul]))

;; (nested-asm-lang-v5 p) -> (nested-asm-lang-v5 p)
;; Optimizes Nested-asm-lang-v4 programs by analyzing and simplifying predicates
(define (optimize-predicates p)

  ;; (nested-asm-lang-v5?) -> boolean
  ;; wrapper for int64?, may change implementation if optimize-predicates implementation changes
  ;; to statically evaluate a wider array of expressions.
  (define (concrete? val)
    (int64? val))

  ;; ((nested-asm-lang-v5 opand) (list (loc . (triv | 'unknown)))) ->
  ;;                                                              (nested-asm-lang-v5 triv) | 'unknown
  ;; Tries to make opand concrete using env, returns 'unknown if this is not possible
  (define (abstract-opand opand env)
    (if (int64? opand)
        opand
        (hash-ref env opand 'unknown)))

  ;; ((nested-asm-lang-v5 binop opand opand) (list (loc . (triv | 'unknown))))
  ;;      -> 'unknown | int64
  (define (abstract-binop op v1 v2 env)
    (let ([v1 (abstract-opand v1 env)]
          [v2 (abstract-opand v2 env)])
      (match* (v1 v2)
        [((? int64?) (? int64?)) ((op->x64-function op) v1 v2)]
        [(_ _) 'unknown])))

  ;; ('relop) -> (nested-asm-lang-v5 relop)
  ;; Returns the function which op symbolizes.
  (define (patch-relop op)
    (match op
      ['> >]
      ['< <]
      ['= =]
      ['>= >=]
      ['<= <=]
      ['!= (λ (x y) (not (= x y)))]
      [_ (error "ffddf")]))

  ;; (nested-asm-lang-v5 relop loc opand (list (loc . (triv | 'unknown)))
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

  ;; ((nested-asm-lang-v5 effect) ((and/c hash? (not/c immutable?)))) -> ('unknown | triv)
  (define (update-env effect env)
    (match effect
      [`(set! ,loc ,triv)
       (if (int64? triv)
           (hash-set! env loc triv)
           (hash-set! env loc (hash-ref env triv 'unknown)))]
      [`(set! ,loc1 (,op ,loc1 ,opand))
       (define cur-val (hash-ref env loc1 'unknown))
       (hash-set! env
                  loc1
                  (if (int64? cur-val)
                      (abstract-binop op cur-val opand env)
                      'unknown))]))

  (define (optimize-pred pred env)
    (match pred
      [`(if (not ,pred) ,pred2 ,pred3) (optimize-pred `(if ,pred ,pred3 ,pred2) env)]
      [`(if ,conditional ,then ,otherwise)
       (define optimized-cond (optimize-pred conditional env))
       (define env-then (hash-copy env))
       (define env-else (hash-copy env))
       (cond
         [(equal? optimized-cond '(true)) (optimize-pred then env-then)]
         [(equal? optimized-cond '(false)) (optimize-pred otherwise env-else)]
         [else
          `(if ,optimized-cond
               ,(optimize-pred then env-then)
               ,(optimize-pred otherwise env-else))])]
      [`(begin
          ,effects ...
          ,pred)
       `(begin
          ,@(for/list ([e effects])
              (optimize-effect e env))
          ,(optimize-pred pred env))]
      [`(,relop ,loc ,opand)
       #:when (relop? relop)
       (abstract-relop relop loc opand env)]
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
      [`(if (not ,conditional) ,then ,otherwise)
       (optimize-effect `(if ,conditional ,otherwise ,then) env)]
      [`(if ,conditional ,then ,otherwise)
       (define optimized-cond (optimize-pred conditional env))
       (define env-then (hash-copy env))
       (define env-else (hash-copy env))
       (cond
         [(equal? optimized-cond '(true)) (optimize-effect then env-then)]
         [(equal? optimized-cond '(false)) (optimize-effect otherwise env-else)]
         [else
          `(if ,optimized-cond
               ,(optimize-effect then env-then)
               ,(optimize-effect otherwise env-else))])]))

  (define (optimize-tail tail env)
    (match tail
      [`(begin
          ,effects ...
          ,tail)
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

  ;; (nested-asm-lang-v5) -> (nested-asm-lang-v5)
  ;; Optimizes an individual nested-asm-lang-v5 procedure definition
  (define (optimize-def def)
    (match def
      [`(define ,label ,tail) `(define ,label ,(optimize-tail tail (make-hash)))]))

  ;; (nested-asm-lang-v5 p) -> (nested-asm-lang-v5 p)
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

(define asm-lang-progs
  '((module () (halt 1)
      )
    (module ()
            (begin
              (halt 1))
      )
    (module ()
            (begin
              (begin
                (set! x.1 1))
              (halt x.1))
      )
    (module ()
            (begin
              (begin
                (set! x.1 1)
                (set! x.1 (+ x.1 1)))
              (halt x.1))
      )
    (module ()
            (begin
              (begin
                (set! x.1 1)
                (set! x.1 (+ x.1 1)))
              (set! x.1 1)
              (halt x.1))
      )
    (module ()
            (begin
              (set! x.1 1)
              (set! x.2 2)
              (set! x.3 3)
              (halt x.3))
      )))

(module+ test
  (require rackunit
           cpsc411/langs/v5)

  (define-syntax-rule (check-by-interp p)
    (check-equal? (interp-nested-asm-lang-v5 p) (interp-nested-asm-lang-v5 (optimize-predicates p))))

  ;; M5 tests; Added by Trevor on March 8th 2026, multiple bindings allowed per let
  (check-by-interp '(module (define L.fn.0.1
                              (begin
                                (set! r15 rdi)
                                (set! r15 rsi)
                                (set! r14 rdx)
                                (set! r13 rcx)
                                (set! r8 r8)
                                (set! r9 r9)
                                (if (true)
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
                                          (halt r15)))
                                    (if (true)
                                        (begin
                                          (set! r15 -9223372036854775808)
                                          (set! r15 (+ r15 0))
                                          (set! r15 r15)
                                          (halt r15))
                                        (begin
                                          (set! r15 r15)
                                          (set! r15 0)
                                          (halt r13))))))
                            (if (begin
                                  (set! r15 -9223372036854775808)
                                  (set! r14 0)
                                  (> r15 r14))
                                (halt -9223372036854775808)
                                (begin
                                  (set! r15 -9223372036854775808)
                                  (set! r15 1)
                                  (set! r15 1)
                                  (halt r15)))
                      ))
  (check-by-interp '(module (define L.tmp.0.1
                              (begin
                                (set! r15 rdi)
                                (set! r15 rsi)
                                (set! r13 rdx)
                                (set! r14 rcx)
                                (set! r14 r8)
                                (set! r9 r9)
                                (if (true)
                                    (begin
                                      (set! r15 r15)
                                      (set! r15 (* r15 -1194246923))
                                      (set! r15 r15))
                                    (set! r15 r13))
                                (if (begin
                                      (set! r13 r13)
                                      (set! r9 r9)
                                      (= r13 422731415))
                                    (if (begin
                                          (set! r13 9223372036854775807)
                                          (<= r13 9223372036854775807))
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
                              (if (!= r14 1)
                                  (halt -335809824)
                                  (halt r15)))
                      ))
  (check-by-interp '(module (define L.proc.0.1
                              (begin
                                (set! r14 rdi)
                                (set! r15 rsi)
                                (set! r13 rdx)
                                (if (false)
                                    (begin
                                      (set! r8 1)
                                      (set! rcx r14)
                                      (set! rdx r15)
                                      (set! rsi 9223372036854775807)
                                      (set! rdi r15)
                                      (jump L.tmp.1.2))
                                    (begin
                                      (set! r9 1554173211)
                                      (set! r9 616342412)
                                      (set! r9 r9)
                                      (if (= r13 r14)
                                          (set! r14 r13)
                                          (set! r14 r15))
                                      (if (begin
                                            (set! r14 1)
                                            (= r14 0))
                                          (set! r15 r15)
                                          (set! r15 0))
                                      (if (begin
                                            (set! r15 1320805275)
                                            (< r15 9223372036854775807))
                                          (halt 0)
                                          (halt 0))))))
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
                                    (!= r14 9223372036854775807))
                                  (set! r14 -2004574473)
                                  (set! r14 9223372036854775807))
                              (set! r14 1)
                              (set! r14 (* r14 r15))
                              (set! r15 r14)
                              (halt r15))))
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
                              (if (true)
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
                                    (halt 1271317139))
                                  (if (begin
                                        (set! r15 9223372036854775807)
                                        (set! r14 -9223372036854775808)
                                        (begin
                                          (set! r14 1474008962)
                                          (< r14 r15)))
                                      (if (begin
                                            (set! r15 -566856990)
                                            (!= r15 -9223372036854775808))
                                          (halt 1)
                                          (halt 1056302987))
                                      (jump L.tmp.1.2))))
                      (begin
                        (set! r15 -9223372036854775808)
                        (set! r14 9223372036854775807)
                        (set! r15 r15)
                        (if (begin
                              (set! r15 -1846550218)
                              (>= r15 1836975164))
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
                                (if (false)
                                    (begin
                                      (set! r15 1)
                                      (set! r15 (* r15 0))
                                      (set! r15 r15))
                                    (set! r15 r15))
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
                                          (< r15 1869530139)))
                                    (if (<= r9 0)
                                        (halt 0)
                                        (halt -777687734))
                                    (if (begin
                                          (set! r15 -9223372036854775808)
                                          (> r15 r14))
                                        (halt 9223372036854775807)
                                        (halt -9223372036854775808)))))
                            (halt 9223372036854775807)
                      ))
  (check-by-interp '(module (if (true)
                                (begin
                                  (set! r15 1)
                                  (set! r15 0)
                                  (halt 356048754))
                                (if (begin
                                      (set! r15 -1287356538)
                                      (<= r15 1126106862))
                                    (halt 4712028)
                                    (halt 349517812)))))
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
                                      (>= r9 0))
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
                                      (>= r14 1924767324))
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
                                 (> r15 -294049298)))
                          (begin
                            (set! r15 1283186732)
                            (set! r14 99039009)
                            (set! r14 1811100583)
                            (halt r15))
                          (begin
                            (set! r15 1)
                            (set! r15 -9223372036854775808)
                            (set! r15 1)
                            (halt r15)))))
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
                                (if (true)
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
                                      (halt r15))
                                    (begin
                                      (set! r13 -1679672366)
                                      (set! r13 (+ r13 r15))
                                      (set! r13 r13)
                                      (set! r13 0)
                                      (set! r13 (+ r13 r14))
                                      (set! r14 r13)
                                      (set! r14 0)
                                      (set! r14 -511883263)
                                      (set! r15 r15)
                                      (halt r14)))))
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
                            (> r15 -735340476))
                          (halt -9223372036854775808)
                          (halt -1627211406))))
  (check-by-interp '(module (define L.x.0.1
                              (begin
                                (set! r15 rdi)
                                (if (not (false))
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
                                      (halt 1))
                                    (begin
                                      (set! rdi -2072909432)
                                      (jump L.x.0.1)))))
                            (begin
                              (set! r15 -1755065230)
                              (set! r15 9223372036854775807)
                              (set! r14 0)
                              (set! r15 r15)
                              (set! r15 -9223372036854775808)
                              (set! r14 -9223372036854775808)
                              (if (begin
                                    (set! r14 1)
                                    (< r14 r15))
                                  (halt r15)
                                  (halt -9223372036854775808)))
                      ))
  (check-by-interp '(module (begin
                              (set! r15 993422572)
                              (set! r15 (* r15 1))
                              (set! r15 r15)
                              (if (begin
                                    (set! r14 92310708)
                                    (<= r14 1290581674))
                                  (set! r14 1)
                                  (set! r14 0))
                              (set! r14 9223372036854775807)
                              (set! r14 (+ r14 -1759699484))
                              (set! r14 r14)
                              (set! r15 r15)
                              (set! r14 -9223372036854775808)
                              (halt r15))))
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
                                          (!= r9 9223372036854775807)))
                                    (begin
                                      (set! r13 1)
                                      (set! r14 r14)
                                      (halt r15))
                                    (begin
                                      (set! r14 r13)
                                      (set! r14 (+ r14 r15))
                                      (set! r15 r14)
                                      (halt r15)))))
                            (define L.x.1.2
                              (if (true)
                                  (halt -9223372036854775808)
                                  (begin
                                    (set! r15 0)
                                    (set! r15 (+ r15 9223372036854775807))
                                    (set! r15 r15)
                                    (halt r15))))
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
                                  (> r15 1757631774))
                                (begin
                                  (set! r15 0)
                                  (set! r15 213435043)
                                  (halt -9223372036854775808))
                                (halt 0))
                      ))
  (check-by-interp '(module (if (not (begin
                                       (set! r15 1946235623)
                                       (< r15 -9223372036854775808)))
                                (begin
                                  (set! r15 -135046761)
                                  (set! r14 1453915451)
                                  (set! r15 257292075)
                                  (halt r14))
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
                              (halt r15))
                      ))
  (check-by-interp '(module (define L.proc.0.1
                              (begin
                                (set! r15 rdi)
                                (set! r14 rsi)
                                (set! r14 rdx)
                                (set! r14 rcx)
                                (set! r13 r8)
                                (set! r13 r9)
                                (if (true)
                                    (begin
                                      (set! fv0 1165846535)
                                      (set! r9 r14)
                                      (set! r8 r15)
                                      (set! rcx 1407333795)
                                      (set! rdx 0)
                                      (set! rsi r15)
                                      (set! rdi 1843221563)
                                      (jump L.func.1.2))
                                    (begin
                                      (set! r15 -1543779281)
                                      (set! r15 (+ r15 1))
                                      (set! r15 r15)
                                      (halt r15)))))
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
                      (if (true)
                          (halt -1263415267)
                          (if (begin
                                (set! r15 9223372036854775807)
                                (<= r15 -514434406))
                              (halt 9223372036854775807)
                              (halt 9223372036854775807)))))
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
                                    (if (true)
                                        (begin
                                          (set! r14 2026709313)
                                          (set! r15 r15)
                                          (set! r15 r15)
                                          (halt r15))
                                        (if (begin
                                              (set! r14 1890937388)
                                              (>= r14 r15))
                                            (halt r15)
                                            (halt 1616264974)))
                                    (halt 9223372036854775807))))
                      (begin
                        (set! r15 0)
                        (set! r15 (* r15 1192307430))
                        (set! r15 r15)
                        (if (begin
                              (set! r14 -9223372036854775808)
                              (< r14 1))
                            (set! r14 -9223372036854775808)
                            (set! r14 2088471563))
                        (set! r14 1)
                        (set! r14 9223372036854775807)
                        (set! r14 1861500702)
                        (if (begin
                              (set! r14 9223372036854775807)
                              (!= r14 -9223372036854775808))
                            (halt r15)
                            (halt 0)))))
  (check-by-interp '(module (define L.proc.0.1
                              (begin
                                (set! r15 rdi)
                                (if (false)
                                    (begin
                                      (set! r9 r15)
                                      (set! r8 r15)
                                      (set! rcx r15)
                                      (set! rdx -9223372036854775808)
                                      (set! rsi r15)
                                      (set! rdi r15)
                                      (jump L.fn.2.3))
                                    (if (false)
                                        (begin
                                          (set! r14 9223372036854775807)
                                          (set! r15 r15)
                                          (set! r15 r15)
                                          (halt r15))
                                        (if (begin
                                              (set! r14 1)
                                              (> r14 r15))
                                            (halt 822960898)
                                            (halt r15))))))
                            (define L.fn.1.2
                              (begin
                                (set! r13 rdi)
                                (set! r15 rsi)
                                (set! r14 rdx)
                                (if (false)
                                    (begin
                                      (set! r13 r13)
                                      (set! r9 -2065189484)
                                      (set! r9 (+ r9 r14))
                                      (set! r9 r9)
                                      (if (< r13 -300039187)
                                          (set! r13 2115350249)
                                          (set! r13 r13))
                                      (set! r9 -195312042)
                                      (set! r15 r15)
                                      (set! r15 r14)
                                      (halt r13))
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
                                          (halt r14))))))
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
                                       (>= r15 94202816)))
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
                                  (!= r15 -719419034))
                                (begin
                                  (set! r15 9223372036854775807)
                                  (set! r15 0)
                                  (set! r15 9223372036854775807)
                                  (halt r15))
                                (if (begin
                                      (set! r15 -235413122)
                                      (> r15 1))
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
                                (if (not (false))
                                    (begin
                                      (set! r14 r14)
                                      (set! r14 9223372036854775807)
                                      (set! r15 r15)
                                      (set! r15 9223372036854775807)
                                      (set! r15 -2115998024)
                                      (halt -1101891150))
                                    (begin
                                      (set! r13 -1594085017)
                                      (set! r13 (* r13 r14))
                                      (set! r14 r13)
                                      (set! r13 -999943825)
                                      (set! r15 r15)
                                      (set! r15 593362223)
                                      (set! r15 0)
                                      (if (= r14 1)
                                          (halt r15)
                                          (halt 0))))))
                      (if (if (begin
                                (set! r15 1)
                                (= r15 -1319463227))
                              (begin
                                (set! r15 -9223372036854775808)
                                (>= r15 1))
                              (begin
                                (set! r15 -1520052689)
                                (!= r15 1)))
                          (begin
                            (set! r15 -9223372036854775808)
                            (set! r14 9223372036854775807)
                            (set! r14 744570222)
                            (halt r15))
                          (begin
                            (set! r15 -133225634)
                            (set! r14 -9223372036854775808)
                            (set! r14 -9223372036854775808)
                            (halt r15)))))
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
                                    (!= r14 r15))
                                  (halt 447579047)
                                  (halt r15)))))
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
                              (halt r15))
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
                                (if (true)
                                    (if (if (begin
                                              (set! r15 182929845)
                                              (> r15 r13))
                                            (>= r14 1)
                                            (begin
                                              (set! r15 -767224240)
                                              (< r15 9223372036854775807)))
                                        (begin
                                          (set! r15 r14)
                                          (set! r15 (+ r15 -9223372036854775808))
                                          (set! r15 r15)
                                          (halt r15))
                                        (halt r14))
                                    (begin
                                      (set! r14 -9223372036854775808)
                                      (set! r14 (+ r14 -9223372036854775808))
                                      (set! r14 r14)
                                      (set! r14 -1747554427)
                                      (set! r15 r15)
                                      (set! r15 9223372036854775807)
                                      (set! r15 r14)
                                      (halt r15)))))
                      (define L.x.2.3
                        (if (begin
                              (set! r15 0)
                              (< r15 9223372036854775807))
                            (halt 1083014636)
                            (begin
                              (if (begin
                                    (set! r15 1)
                                    (<= r15 9223372036854775807))
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
                                    (if (> r15 r14)
                                        (begin
                                          (set! r14 9223372036854775807)
                                          (>= r14 r15))
                                        (= r14 0)))
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
                                (if (if (true)
                                        (if (begin
                                              (set! r8 -1156972119)
                                              (!= r8 r13))
                                            (begin
                                              (set! r14 9223372036854775807)
                                              (> r14 r15))
                                            (begin
                                              (set! r8 1703616983)
                                              (!= r8 r14)))
                                        (if (>= r8 r9)
                                            (> r13 r13)
                                            (< r15 r15)))
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
                              (<= r14 r15))
                            (halt 0)
                            (halt 9223372036854775807)))))
  (check-by-interp '(module (if (begin
                                  (set! r15 -107521481)
                                  (!= r15 -1873066368))
                                (begin
                                  (set! r15 1275956981)
                                  (set! r15 (* r15 1))
                                  (set! r15 r15)
                                  (halt r15))
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
                                      (= r13 r14))
                                    (set! r15 r15)
                                    (set! r15 r14))
                                (if (begin
                                      (set! r15 0)
                                      (set! r15 1774106288)
                                      (begin
                                        (set! r14 0)
                                        (> r14 r15)))
                                    (begin
                                      (set! r15 9223372036854775807)
                                      (set! r14 811516044)
                                      (set! r15 r15))
                                    (if (begin
                                          (set! r15 -1327371506)
                                          (< r15 9223372036854775807))
                                        (set! r15 -9223372036854775808)
                                        (set! r15 9223372036854775807)))
                                (jump L.fn.0.1)))
                            (begin
                              (if (begin
                                    (set! r15 1517267005)
                                    (= r15 605514120))
                                  (set! r15 -1228391641)
                                  (set! r15 -1926002282))
                              (if (begin
                                    (set! r15 0)
                                    (> r15 1))
                                  (set! r15 9223372036854775807)
                                  (set! r15 0))
                              (set! r15 25767341)
                              (set! r15 (* r15 0))
                              (set! r15 r15)
                              (halt r15))
                      ))
  (check-by-interp '(module (define L.func.0.1
                              (if (false)
                                  (if (not (begin
                                             (set! r15 -1086072832)
                                             (!= r15 9223372036854775807)))
                                      (begin
                                        (set! r15 793954259)
                                        (set! r15 0)
                                        (set! r15 -9223372036854775808)
                                        (halt 9223372036854775807))
                                      (begin
                                        (set! r15 620579510)
                                        (set! r15 (+ r15 1))
                                        (set! r15 r15)
                                        (halt r15)))
                                  (if (true)
                                      (halt 9223372036854775807)
                                      (begin
                                        (set! r15 716210269)
                                        (set! r15 -524345693)
                                        (halt -9223372036854775808)))))
                            (define L.fn.1.2
                              (begin
                                (set! r14 rdi)
                                (set! r15 rsi)
                                (if (if (true)
                                        (if (begin
                                              (set! r13 0)
                                              (> r13 9223372036854775807))
                                            (begin
                                              (set! r13 1)
                                              (<= r13 -330770905))
                                            (begin
                                              (set! r13 0)
                                              (> r13 r14)))
                                        (if (>= r14 r14)
                                            (begin
                                              (set! r13 -1763336001)
                                              (<= r13 1))
                                            (begin
                                              (set! r13 9223372036854775807)
                                              (>= r13 -1870920433))))
                                    (if (not (begin
                                               (set! r15 -9223372036854775808)
                                               (= r15 1676706544)))
                                        (if (begin
                                              (set! r15 0)
                                              (<= r15 r14))
                                            (halt -9223372036854775808)
                                            (halt r14))
                                        (if (begin
                                              (set! r15 -9223372036854775808)
                                              (<= r15 1745852904))
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
                        (if (<= r15 r14)
                            (halt 1132619346)
                            (halt 0)))))
  (check-by-interp '(module (if (true)
                                (begin
                                  (set! r14 -9223372036854775808)
                                  (set! r15 9223372036854775807)
                                  (halt r14))
                                (begin
                                  (set! r15 -9223372036854775808)
                                  (set! r15 1929590320)
                                  (set! r15 0)
                                  (halt 0)))))
  (check-by-interp '(module (begin
                              (if (begin
                                    (set! r15 9223372036854775807)
                                    (> r15 1398326902))
                                  (set! r15 9223372036854775807)
                                  (set! r15 9223372036854775807))
                              (set! r14 0)
                              (set! r14 -9223372036854775808)
                              (set! r14 -1747244286)
                              (set! r14 r14)
                              (set! r14 -1923830755)
                              (set! r15 r15)
                              (halt r15))))
  (check-by-interp '(module (define L.proc.0.1
                              (begin
                                (if (true)
                                    (set! r15 0)
                                    (begin
                                      (set! r15 1)
                                      (set! r15 (* r15 1))
                                      (set! r15 r15)))
                                (set! r15 -9223372036854775808)
                                (set! r15 672116958)
                                (set! r15 (* r15 1))
                                (set! r15 r15)
                                (if (< r15 980303276)
                                    (begin
                                      (set! r14 9223372036854775807)
                                      (set! r14 (+ r14 r15))
                                      (set! r15 r14)
                                      (halt r15))
                                    (begin
                                      (set! r15 -667597146)
                                      (set! r15 1438122241)
                                      (halt 1900048603)))))
                            (define L.proc.1.2
                              (if (true)
                                  (if (if (begin
                                            (set! r15 0)
                                            (< r15 -9223372036854775808))
                                          (begin
                                            (set! r15 0)
                                            (<= r15 -9223372036854775808))
                                          (begin
                                            (set! r15 9223372036854775807)
                                            (> r15 -1813633866)))
                                      (halt -935154891)
                                      (begin
                                        (set! r15 -1449852093)
                                        (set! r15 -9223372036854775808)
                                        (halt 1)))
                                  (begin
                                    (set! r15 -1450359427)
                                    (set! r15 (+ r15 -701676518))
                                    (set! r15 r15)
                                    (halt r15))))
                      (if (false)
                          (jump L.proc.1.2)
                          (if (begin
                                (set! r15 1)
                                (!= r15 9223372036854775807))
                              (halt 313960847)
                              (halt 0)))))
  (check-by-interp '(module (if (if (begin
                                      (set! r15 -500842013)
                                      (< r15 -2010375969))
                                    (begin
                                      (set! r15 -1785958547)
                                      (< r15 9223372036854775807))
                                    (begin
                                      (set! r15 904902616)
                                      (<= r15 1)))
                                (if (begin
                                      (set! r15 -1568723397)
                                      (= r15 0))
                                    (halt 1)
                                    (halt -9223372036854775808))
                                (halt 1))))
  (check-by-interp '(module (if (false)
                                (halt 0)
                                (if (begin
                                      (set! r15 1)
                                      (>= r15 0))
                                    (halt 281602960)
                                    (halt 9223372036854775807)))))
  (check-by-interp '(module (if (true)
                                (begin
                                  (set! r15 -1267155910)
                                  (set! r15 (+ r15 -9223372036854775808))
                                  (set! r15 r15)
                                  (halt r15))
                                (if (begin
                                      (set! r15 901304193)
                                      (>= r15 1))
                                    (halt 0)
                                    (halt -154349390)))))
  (check-by-interp '(module (halt 9223372036854775807)))
  (check-by-interp '(module (if (true)
                                (begin
                                  (set! r15 -9223372036854775808)
                                  (set! r15 (+ r15 1965973068))
                                  (set! r15 r15)
                                  (halt r15))
                                (begin
                                  (set! r15 -644439618)
                                  (set! r15 1)
                                  (halt r15)))))

  ;;

  ;; !!! Added by Trevor on March 2nd 2026

  (check-by-interp '(module (define L.L.func.0.1.4 (halt 0))
                            (define L.L.tmp.1.2.5
                              (begin
                                (set! r15 rdi)
                                (jump L.L.func.0.1.4)))
                      (define L.L.func.2.3.6
                        (begin
                          (if (true)
                              (begin
                                (set! r15 1)
                                (set! r15 r15))
                              (begin
                                (set! r15 -9223372036854775808)
                                (set! r15 (* r15 1806293504))
                                (set! r15 r15)))
                          (if (begin
                                (set! r14 1)
                                (> r14 0))
                              (set! r15 156890122)
                              (set! r15 r15))
                          (halt 0)))
                      (begin
                        (set! rdi -1860620182)
                        (jump L.L.tmp.1.2.5))))
  (check-by-interp '(module (define L.L.tmp.0.1.4
                              (if (begin
                                    (set! r15 9223372036854775807)
                                    (>= r15 -1020514810))
                                  (jump L.L.x.2.3.6)
                                  (begin
                                    (set! r15 1)
                                    (set! r15 (* r15 0))
                                    (set! r15 r15)
                                    (halt r15))))
                            (define L.L.func.1.2.5
                              (begin
                                (set! r14 -9223372036854775808)
                                (if (not (begin
                                           (set! r15 9223372036854775807)
                                           (> r15 0)))
                                    (halt 1309557052)
                                    (halt r14))))
                      (define L.L.x.2.3.6
                        (if (if (true)
                                (not (begin
                                       (set! r15 0)
                                       (> r15 1)))
                                (true))
                            (if (begin
                                  (set! r15 0)
                                  (> r15 0))
                                (if (begin
                                      (set! r15 9223372036854775807)
                                      (< r15 9223372036854775807))
                                    (halt 9223372036854775807)
                                    (halt -260353756))
                                (begin
                                  (set! r15 0)
                                  (halt r15)))
                            (begin
                              (if (begin
                                    (set! r15 -302047143)
                                    (!= r15 0))
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
                        (halt r15))))
  (check-by-interp '(module (define L.L.proc.0.1.4
                              (begin
                                (set! r15 rdi)
                                (jump L.L.func.1.2.5)))
                            (define L.L.func.1.2.5
                              (begin
                                (set! r15 1)
                                (set! r15 (* r15 0))
                                (set! r15 r15)
                                (halt r15)))
                      (define L.L.fn.2.3.6
                        (begin
                          (set! r15 rdi)
                          (if (true)
                              (begin
                                (if (begin
                                      (set! r15 -2033705372)
                                      (<= r15 965540822))
                                    (set! r15 -1853172774)
                                    (set! r15 1133506028))
                                (set! r15 1)
                                (halt 1236904416))
                              (jump L.L.func.1.2.5))))
                      (begin
                        (set! rdi 1)
                        (jump L.L.proc.0.1.4))))
  (check-by-interp '(module (define L.fn.0.1
                              (begin
                                (if (false)
                                    (set! r15 1)
                                    (begin
                                      (set! r15 1)
                                      (set! r15 1)))
                                (if (if (begin
                                          (set! r14 9223372036854775807)
                                          (>= r14 -9223372036854775808))
                                        (begin
                                          (set! r14 -248968641)
                                          (= r14 9223372036854775807))
                                        (!= r15 -9223372036854775808))
                                    (begin
                                      (set! r15 r15)
                                      (halt 1622965009))
                                    (begin
                                      (set! r15 r15)
                                      (halt r15)))))
                            (if (false)
                                (if (begin
                                      (set! r15 995853130)
                                      (>= r15 1))
                                    (halt 1)
                                    (halt -9223372036854775808))
                                (jump L.fn.0.1))
                      ))
  (check-by-interp '(module (begin
                              (set! r15 -9223372036854775808)
                              (set! r15 (+ r15 -1465538260))
                              (set! r15 r15)
                              (halt r15))))
  (check-by-interp '(module (define L.fn.0.1
                              (begin
                                (set! r15 1)
                                (set! r15 (+ r15 9223372036854775807))
                                (set! r15 r15)
                                (set! r15 r15)
                                (set! r14 r15)
                                (halt r15)))
                            (define L.func.1.2
                              (begin
                                (if (begin
                                      (set! r15 1)
                                      (begin
                                        (set! r14 1)
                                        (< r14 r15)))
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
                        (halt r15))))
  (check-by-interp '(module (define L.x.0.1
                              (begin
                                (set! r15 rdi)
                                (set! r15 rsi)
                                (jump L.tmp.1.2)))
                            (define L.tmp.1.2
                              (if (if (if (begin
                                            (set! r15 -765445006)
                                            (<= r15 0))
                                          (begin
                                            (set! r15 0)
                                            (!= r15 -7399083))
                                          (begin
                                            (set! r15 9223372036854775807)
                                            (<= r15 1)))
                                      (false)
                                      (true))
                                  (begin
                                    (set! r15 -9223372036854775808)
                                    (set! r15 r15)
                                    (if (> r15 r15)
                                        (halt -9223372036854775808)
                                        (halt r15)))
                                  (begin
                                    (if (begin
                                          (set! r15 1)
                                          (>= r15 0))
                                        (set! r15 -9223372036854775808)
                                        (set! r15 -9223372036854775808))
                                    (if (begin
                                          (set! r14 0)
                                          (= r14 r15))
                                        (halt 0)
                                        (halt 9223372036854775807)))))
                      (define L.func.2.3
                        (begin
                          (set! r15 rdi)
                          (set! r15 rsi)
                          (jump L.tmp.1.2)))
                      (if (begin
                            (set! r15 0)
                            (<= r15 1))
                          (halt -1271132888)
                          (halt 2101306416))))
  (check-by-interp '(module (define L.proc.0.1
                              (begin
                                (set! r15 rdi)
                                (if (false)
                                    (begin
                                      (set! r15 r15)
                                      (set! r14 1733388107))
                                    (begin
                                      (set! r14 -818241658)
                                      (set! r14 r14)))
                                (set! r13 -1769976594)
                                (set! r13 (* r13 r14))
                                (set! r14 r13)
                                (if (!= r15 r15)
                                    (halt 1)
                                    (halt r15))))
                            (if (begin
                                  (set! r15 0)
                                  (<= r15 0))
                                (halt 1764584349)
                                (halt -9223372036854775808))
                      ))
  (check-by-interp '(module (define L.proc.0.1
                              (begin
                                (set! r15 rdi)
                                (if (not (false))
                                    (jump L.x.1.2)
                                    (begin
                                      (set! r15 r15)
                                      (set! r14 9223372036854775807)
                                      (set! r14 -9223372036854775808)
                                      (set! r14 (+ r14 r15))
                                      (set! r15 r14)
                                      (halt r15)))))
                            (define L.x.1.2 (halt 1))
                      (begin
                        (set! r15 453798193)
                        (set! r14 r15)
                        (if (begin
                              (set! r15 9223372036854775807)
                              (>= r15 r14))
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
                                    (if (true)
                                        (if (< r15 -9223372036854775808)
                                            (halt r15)
                                            (halt r15))
                                        (if (begin
                                              (set! r14 -9223372036854775808)
                                              (= r14 r15))
                                            (halt r15)
                                            (halt r15)))
                                    (jump L.proc.1.2))))
                            (define L.proc.1.2
                              (begin
                                (set! rdi 954069433)
                                (jump L.func.0.1)))
                      (if (false)
                          (begin
                            (set! r15 1337690701)
                            (set! r15 (* r15 9223372036854775807))
                            (set! r15 r15)
                            (halt r15))
                          (jump L.proc.1.2))))
  (check-by-interp '(module (if (not (begin
                                       (set! r15 1)
                                       (> r15 9223372036854775807)))
                                (if (begin
                                      (set! r15 1)
                                      (>= r15 1197468889))
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
                              (halt r15))
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
                                      (halt r15))
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
                                    (halt r14)
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
                                     (>= r15 -1400373009))))
                            (begin
                              (set! r15 -167927521)
                              (set! r15 (+ r15 1))
                              (set! r15 r15)
                              (halt r15))
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
                              (if (!= r15 1)
                                  (halt 9223372036854775807)
                                  (halt 2063023986)))))
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
                                      (halt r15))
                                    (begin
                                      (set! r14 0)
                                      (set! r14 (* r14 r15))
                                      (set! r14 r14)
                                      (if (!= r14 -9223372036854775808)
                                          (halt r15)
                                          (halt 0))))))
                            (if (begin
                                  (set! r15 9223372036854775807)
                                  (= r15 -315897602))
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
                                      (!= r13 r14))
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
                                (halt r15)))
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
                          (halt r15)))
                      (begin
                        (set! r15 979460199)
                        (set! r15 (+ r15 -1697959716))
                        (set! r15 r15)
                        (halt r15))))
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
                                (if (true)
                                    (begin
                                      (set! r15 r14)
                                      (set! r15 (* r15 9223372036854775807))
                                      (set! r15 r15)
                                      (halt r15))
                                    (if (begin
                                          (set! r14 1)
                                          (<= r13 r15))
                                        (begin
                                          (set! r15 -9223372036854775808)
                                          (halt r15))
                                        (begin
                                          (set! r15 1)
                                          (halt 1))))))
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
                                (< r9 1))
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
                                    (> r14 882297114))
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
  (check-by-interp '(module (if (true)
                                (begin
                                  (set! r15 1)
                                  (set! r15 (+ r15 -9223372036854775808))
                                  (set! r15 r15)
                                  (halt r15))
                                (if (begin
                                      (set! r15 1383245321)
                                      (> r15 0))
                                    (halt 0)
                                    (halt 1)))))
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
                                      (>= r15 r14))
                                    (halt -9223372036854775808)
                                    (halt r14))))
                      (define L.fn.2.3
                        (begin
                          (set! r15 1)
                          (set! r15 (+ r15 1))
                          (set! r15 r15)
                          (if (false)
                              (halt r15)
                              (begin
                                (set! r15 r15)
                                (halt 1969054361)))))
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
                          (if (if (true)
                                  (begin
                                    (set! r15 r15)
                                    (begin
                                      (set! r14 -1497437069)
                                      (> r14 -9223372036854775808)))
                                  (not (begin
                                         (set! r14 -1101838227)
                                         (!= r14 -1416967818))))
                              (begin
                                (set! r15 r15)
                                (set! r15 (+ r15 r15))
                                (set! r15 r15)
                                (set! r15 0)
                                (halt r15))
                              (halt 1))))
                      (define L.fn.7.8
                        (if (true)
                            (if (not (begin
                                       (set! r15 0)
                                       (> r15 100011461)))
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
                                      (= r15 471889533))
                                    (halt 1)
                                    (halt 0)))
                            (if (if (begin
                                      (set! r15 1)
                                      (>= r15 0))
                                    (begin
                                      (set! r15 0)
                                      (>= r15 -9223372036854775808))
                                    (begin
                                      (set! r15 9223372036854775807)
                                      (> r15 0)))
                                (jump L.fn.7.8)
                                (if (begin
                                      (set! r15 1)
                                      (> r15 1))
                                    (halt -444155079)
                                    (halt 9223372036854775807)))))
                      (if (begin
                            (if (begin
                                  (set! r15 -9223372036854775808)
                                  (true))
                                (begin
                                  (if (begin
                                        (set! r15 9223372036854775807)
                                        (> r15 0))
                                      (set! r15 -1444900091)
                                      (set! r15 -9223372036854775808))
                                  (set! r15 r15))
                                (if (true)
                                    (begin
                                      (set! r15 9223372036854775807)
                                      (set! r15 r15))
                                    (if (begin
                                          (set! r15 -9223372036854775808)
                                          (= r15 1173781558))
                                        (set! r15 0)
                                        (set! r15 1))))
                            (if (true)
                                (begin
                                  (set! r15 0)
                                  (true))
                                (begin
                                  (set! r14 858519747)
                                  (< r14 r15))))
                          (halt 1)
                          (if (begin
                                (set! r15 1)
                                (< r15 -1323259230))
                              (jump L.fn.2.3)
                              (jump L.fn.2.3)))))
  ;; !!!

  ;   (check-by-interp (assign-homes-opt '(module ()
  ;                                               (begin
  ;                                                 (set! x.1 2)
  ;                                                 (set! x.2 2)
  ;                                                 (set! tmp.2 x.1)
  ;                                                 (set! tmp.2 (+ tmp.2 x.2))
  ;                                                 (halt tmp.2))
  ;                                         )))
  ;     (define inputs (map assign-homes-opt asm-lang-progs))

  ;   (for-each check-equal?
  ;             (map (compose interp-nested-asm-lang-v4 assign-homes-opt) asm-lang-progs)
  ;             (map (compose interp-nested-asm-lang-v4 optimize-predicates assign-homes-opt)
  ;                  asm-lang-progs))
  ; (for-each
  ;  (λ (prog)
  ;    (define input (assign-homes-opt prog))
  ;    (check-equal? (interp-nested-asm-lang-v4 input)
  ;                  (interp-nested-asm-lang-v4 (optimize-predicates input))))
  ;  asm-lang-progs)

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
                           (false))))
  (check-equal? (optimize-predicates `(module (begin
                                                (set! rax ,(max-int 64))
                                                (set! rbx ,(min-int 64))
                                                (set! rax (+ rax rbx))
                                                (set! rdi rax) ;; r[rdi] = -1
                                                (if (< rdi 0)
                                                    (halt 1)
                                                    (halt 0)))))
                `(module (begin
                           (set! rax ,(max-int 64))
                           (set! rbx ,(min-int 64))
                           (set! rax (+ rax rbx))
                           (set! rdi rax) ;; r[rdi] = -1
                           (if (< rdi 0)
                               (halt 1)
                               (halt 0))))))
