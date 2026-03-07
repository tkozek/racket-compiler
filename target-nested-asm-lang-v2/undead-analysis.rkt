#lang racket

(require cpsc411/compiler-lib)

;; Asm-lang v2/locals
; p	 	    ::=	 	(module info tail)
;
; info	 	::=	 	(#:from-contract (info/c (locals (aloc ...))))
;
; tail	 	::=	 	(halt triv)
;	 	       |	 	(begin effect ... tail)
;
; effect	 ::=	(set! aloc triv)
;	 	         |	 	(set! aloc_1 (binop aloc_1 triv))
;	 	         |	 	(begin effect ... effect)
;
; triv	 	::=	 	int64
;	 	       |	 	aloc
;
; binop	 	::=	 	*
;	 	       |	 	+
;
; aloc	 	::=	 	aloc?
;
; int64	 	::=	 	int64?

;; Asm-lang v2/undead
; p	 	    ::=	 	(module info tail)

; info	 	::=	 	(#:from-contract (info/c (locals (aloc ...)) (undead-out undead-set-tree?)))

; tail	 	::=	 	(halt triv)
;	 	       |	 	(begin effect ... tail)
;
; effect	 ::=	  (set! aloc triv)
;	 	         |	 	(set! aloc_1 (binop aloc_1 triv))
;	 	         |	 	(begin effect ... effect)
;
; triv	 	::=	 	int64
;	 	       |	 	aloc
;
; binop	 	::=	 	*
;	 	        |	 	+
;
; aloc	 	::=	 	aloc?
;
; int64	 	::=	 	int64?

(provide undead-analysis)

;; (asm-lang-v2/locals p) -> (asm-lang-v2/undead p)
;; Performs undeadness analysis, decorating the program with undead-set tree.
;; Only the info field of the program is modified.
(define (undead-analysis p)

  ;; undead-set (asm-lang-v2/locals effect) -> (values undead-set ust)
  ;; SLIGHTLY MODIFIED CODE FROM LECTURE
  ;; takes in the undead-out set for the current instruction
  ;; and computes the undead-in set for the current instruction,
  ;; and the undead-set-tree for the effect
  (define (analyze-program-effect undead-out effect)
    (match effect
      [`(begin
          ,effects ...
          ,effect)
       (let-values ([(undead-out updated-ust) (analyze-program-effect undead-out effect)])
         (let-values ([(pre-wrap-undead-out pre-wrap-updated-ust)
                       (for/foldr ([undead-out undead-out] [ust updated-ust])
                                  ([effect effects])
                                  (let-values ([(undead-in new-ust) (analyze-program-effect undead-out
                                                                                            effect)])
                                    (values undead-in (cons new-ust ust))))])

           (values pre-wrap-undead-out `(,pre-wrap-updated-ust))))]
      [`(set! ,aloc_1 (,binop ,aloc_1 ,triv))
       (let ([undead-in (set-add (set-add-triv undead-out triv) aloc_1)])
         (values undead-in undead-out))]
      [`(set! ,aloc ,triv)
       (let ([undead-in (set-add-triv (set-remove undead-out aloc) triv)])
         (values undead-in undead-out))]
      [`(if ,pred ,effect1 ,effect2)
       (let*-values ([(undead-out-effect2 ust-effect2) (analyze-program-effect undead-out effect2)]
                     [(undead-out-effect1 ust-effect1) (analyze-program-effect undead-out effect1)]
                     [(undead-out-pred ust-pred)
                      (analyze-program-pred (set-union undead-out-effect1 undead-out-effect2) pred)])
         (values undead-out-pred `(,ust-pred ,ust-effect1 ,ust-effect2)))]))

  (define (analyze-program-pred undead-out pred)
    (match pred
      [`(,relop ,aloc ,triv)
       #:when (memq relop '(< <= = >= > !=))
       (let ([undead-in (set-add-triv (set-add undead-out aloc) triv)])
         (values undead-in undead-out))]
      [`(true) (values undead-out undead-out)]
      [`(false) (values undead-out undead-out)]
      [`(not ,pred)
       (let-values ([(undead-out-pred updated-ust) (analyze-program-pred undead-out pred)])
         (values undead-out-pred updated-ust))]
      [`(begin
          ,effects ...
          ,pred)
       (let-values ([(undead-out updated-ust) (analyze-program-pred undead-out pred)])
         (let-values ([(pre-wrap-undead-out pre-wrap-updated-ust)
                       (for/foldr ([undead-out undead-out] [ust updated-ust])
                                  ([effect effects])
                                  (let-values ([(undead-in new-ust) (analyze-program-effect undead-out
                                                                                            effect)])
                                    (values undead-in (cons new-ust ust))))])

           (values pre-wrap-undead-out `(,pre-wrap-updated-ust))))]
      [`(if ,pred1 ,pred2 ,pred3)
       (let*-values ([(undead-out-pred3 ust-pred3) (analyze-program-pred undead-out pred3)]
                     [(undead-out-pred2 ust-pred2) (analyze-program-pred undead-out pred2)]
                     [(undead-out-pred1 ust-pred1)
                      (analyze-program-pred (set-union undead-out-pred3 undead-out-pred2) pred1)])
         (values undead-out-pred1 `(,ust-pred1 ,ust-pred2 ,ust-pred3)))]))

  ; undead-set (asm-lang-v2/locals triv) -> undead-set
  ; TAKEN FROM LECTURE
  ; adds triv to the undead-set if the triv is an aloc.
  (define (set-add-triv undead-set triv)
    (if (aloc? triv)
        (set-add undead-set triv)
        undead-set))

  ;; undead-set (asm-lang-v2/locals tail) -> (values undead-set ust)
  ;; takes in the undead-out set for the current instruction
  ;; and computes the undead-in set for the current instruction,
  ;; and the undead-set-tree for the effect
  (define (analyze-program-tail undead-out tail)
    (match tail
      [`(begin
          ,effects ...
          ,tail)
       (let-values ([(undead-out updated-ust) (analyze-program-tail undead-out tail)])
         (let-values ([(pre-wrap-undead-out pre-wrap-updated-ust)
                       (for/foldr ([undead-out undead-out] [ust updated-ust])
                                  ([effect effects])
                                  (let-values ([(undead-in new-ust) (analyze-program-effect undead-out
                                                                                            effect)])
                                    (values undead-in (cons new-ust ust))))])

           (values pre-wrap-undead-out `(,pre-wrap-updated-ust))))]
      [`(halt ,triv)
       (let ([undead-in (set-add-triv undead-out triv)]) (values undead-in (cons undead-out '())))]
      [`(if ,pred ,tail1 ,tail2)
       (let*-values ([(undead-out-tail2 ust-tail2) (analyze-program-tail undead-out tail2)]
                     [(undead-out-tail1 ust-tail1) (analyze-program-tail undead-out tail1)]
                     [(undead-out-pred ust-pred)
                      (analyze-program-pred (set-union undead-out-tail1 undead-out-tail2) pred)])
         (values undead-out-pred `((,ust-pred ,(first ust-tail1) ,(first ust-tail2)))))]))

  (define (get-ust tail)
    (let-values ([(_ ust) (analyze-program-tail `() tail)])
      (first ust)))

  (define (insert-undead-analysis ust info)
    (match info
      [`(,locals) `(,locals (undead-out ,ust))]))

  (match p
    [`(module ,info ,tail
        )
     `(module ,(insert-undead-analysis (get-ust tail) info) ,tail
        )]))

(module+ test
  (require rackunit)
  (require cpsc411/langs/v4)
  (define (set-list=? a b)
    (set=? (list->set a) (list->set b)))

  (check-match (undead-analysis '(module ((locals (x.1)))
                                         (begin
                                           (set! x.1 42)
                                           (halt x.1))
                                   ))
               `(module ((locals (x.1)) (undead-out (,(? (lambda (x) (set-list=? x '(x.1)))) ())))
                        (begin
                          (set! x.1 42)
                          (halt x.1))
                  ))

  (check-equal? (undead-analysis '(module ((locals (x.1)))
                                          (begin
                                            (begin
                                              (set! x.1 1))
                                            (halt x.1))
                                    ))
                `(module ((locals (x.1)) (undead-out (((x.1)) ())))
                         (begin
                           (begin
                             (set! x.1 1))
                           (halt x.1))
                   ))

  (check-equal? (undead-analysis '(module ((locals (x.1)))
                                          (begin
                                            (begin
                                              (begin
                                                (set! x.1 1)))
                                            (halt x.1))
                                    ))
                `(module ((locals (x.1)) (undead-out ((((x.1))) ())))
                         (begin
                           (begin
                             (begin
                               (set! x.1 1)))
                           (halt x.1))
                   ))

  (check-match (undead-analysis '(module ((locals (v.1 w.2 x.3 y.4 z.5 t.6 p.1)))
                                         (begin
                                           (set! v.1 1)
                                           (set! w.2 46)
                                           (set! x.3 v.1)
                                           (set! p.1 7)
                                           (set! x.3 (+ x.3 p.1))
                                           (set! y.4 x.3)
                                           (set! p.1 4)
                                           (set! y.4 (+ y.4 p.1))
                                           (set! z.5 x.3)
                                           (set! z.5 (+ z.5 w.2))
                                           (set! t.6 y.4)
                                           (set! p.1 -1)
                                           (set! t.6 (* t.6 p.1))
                                           (set! z.5 (+ z.5 t.6))
                                           (halt z.5))
                                   ))
               `(module ((locals (v.1 w.2 x.3 y.4 z.5 t.6 p.1))
                         (undead-out (,(? (lambda (x) (set-list=? x '(v.1))))
                                      ,(? (lambda (x) (set-list=? x '(v.1 w.2))))
                                      ,(? (lambda (x) (set-list=? x '(x.3 w.2))))
                                      ,(? (lambda (x) (set-list=? x '(p.1 x.3 w.2))))
                                      ,(? (lambda (x) (set-list=? x '(x.3 w.2))))
                                      ,(? (lambda (x) (set-list=? x '(y.4 x.3 w.2))))
                                      ,(? (lambda (x) (set-list=? x '(p.1 y.4 x.3 w.2))))
                                      ,(? (lambda (x) (set-list=? x '(x.3 w.2 y.4))))
                                      ,(? (lambda (x) (set-list=? x '(w.2 z.5 y.4))))
                                      ,(? (lambda (x) (set-list=? x '(y.4 z.5))))
                                      ,(? (lambda (x) (set-list=? x '(t.6 z.5))))
                                      ,(? (lambda (x) (set-list=? x '(p.1 t.6 z.5))))
                                      ,(? (lambda (x) (set-list=? x '(t.6 z.5))))
                                      ,(? (lambda (x) (set-list=? x '(z.5))))
                                      ())))
                        (begin
                          (set! v.1 1)
                          (set! w.2 46)
                          (set! x.3 v.1)
                          (set! p.1 7)
                          (set! x.3 (+ x.3 p.1))
                          (set! y.4 x.3)
                          (set! p.1 4)
                          (set! y.4 (+ y.4 p.1))
                          (set! z.5 x.3)
                          (set! z.5 (+ z.5 w.2))
                          (set! t.6 y.4)
                          (set! p.1 -1)
                          (set! t.6 (* t.6 p.1))
                          (set! z.5 (+ z.5 t.6))
                          (halt z.5))
                  ))

  (check-equal? (undead-analysis `(module ((locals (x.1 y.2 b.3 c.4)))
                                          (begin
                                            (set! x.1 5)
                                            (set! y.2 x.1)
                                            (begin
                                              (set! b.3 x.1)
                                              (set! b.3 (+ b.3 y.2))
                                              (set! c.4 b.3)
                                              (if (= c.4 b.3)
                                                  (halt c.4)
                                                  (begin
                                                    (set! x.1 c.4)
                                                    (halt c.4)))))
                                    ))
                `(module ((locals (x.1 y.2 b.3 c.4))
                          (undead-out ((x.1) (x.1 y.2)
                                             ((y.2 b.3) (b.3) (b.3 c.4) ((c.4) () ((c.4) ()))))))
                         (begin
                           (set! x.1 5)
                           (set! y.2 x.1)
                           (begin
                             (set! b.3 x.1)
                             (set! b.3 (+ b.3 y.2))
                             (set! c.4 b.3)
                             (if (= c.4 b.3)
                                 (halt c.4)
                                 (begin
                                   (set! x.1 c.4)
                                   (halt c.4)))))
                   ))

  (check-equal? (undead-analysis `(module ((locals (x.1 y.2 b.3 c.4)))
                                          (begin
                                            (set! x.1 5)
                                            (set! y.2 x.1)
                                            (begin
                                              (set! b.3 x.1)
                                              (set! b.3 (+ b.3 y.2))
                                              (set! c.4 b.3)
                                              (if (= c.4 b.3)
                                                  (halt c.4)
                                                  (begin
                                                    (set! x.1 c.4)
                                                    (set! x.1 y.2)
                                                    (halt c.4)))))
                                    ))
                `(module ((locals (x.1 y.2 b.3 c.4))
                          (undead-out ((x.1) (x.1 y.2)
                                             ((b.3 y.2) (b.3 y.2)
                                                        (b.3 y.2 c.4)
                                                        ((y.2 c.4) () ((y.2 c.4) (c.4) ()))))))
                         (begin
                           (set! x.1 5)
                           (set! y.2 x.1)
                           (begin
                             (set! b.3 x.1)
                             (set! b.3 (+ b.3 y.2))
                             (set! c.4 b.3)
                             (if (= c.4 b.3)
                                 (halt c.4)
                                 (begin
                                   (set! x.1 c.4)
                                   (set! x.1 y.2)
                                   (halt c.4)))))
                   ))

  (check-equal?
   (undead-analysis `(module ((locals (x.1 y.2 b.3 c.4)))
                             (begin
                               (set! x.1 5)
                               (set! y.2 x.1)
                               (begin
                                 (set! b.3 x.1)
                                 (set! b.3 (+ b.3 y.2))
                                 (set! c.4 b.3)
                                 (if (if (true)
                                         (false)
                                         (not (false)))
                                     (halt c.4)
                                     (begin
                                       (set! x.1 c.4)
                                       (set! x.1 y.2)
                                       (halt c.4)))))
                       ))
   `(module ((locals (x.1 y.2 b.3 c.4)) (undead-out ((x.1) (x.1 y.2)
                                                           ((b.3 y.2) (b.3 y.2)
                                                                      (y.2 c.4)
                                                                      (((y.2 c.4) (y.2 c.4) (y.2 c.4))
                                                                       ()
                                                                       ((y.2 c.4) (c.4) ()))))))
            (begin
              (set! x.1 5)
              (set! y.2 x.1)
              (begin
                (set! b.3 x.1)
                (set! b.3 (+ b.3 y.2))
                (set! c.4 b.3)
                (if (if (true)
                        (false)
                        (not (false)))
                    (halt c.4)
                    (begin
                      (set! x.1 c.4)
                      (set! x.1 y.2)
                      (halt c.4)))))))
)
