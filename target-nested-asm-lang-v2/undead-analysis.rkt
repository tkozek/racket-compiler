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

(provide 
 undead-analysis)


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
        [`(begin ,effects ... ,effect)
          (let-values ([(undead-out updated-ust) (analyze-program-effect undead-out effect)])
            (let-values ([(pre-wrap-undead-out pre-wrap-updated-ust) 
              (for/foldr ([undead-out undead-out]
                          [ust `(,updated-ust)])
                         ([effect effects])
                (let-values ([(undead-in new-ust)
                                (analyze-program-effect undead-out effect)])
                    (values 
                    undead-in
                    (cons new-ust ust))))])
                    
              (values pre-wrap-undead-out pre-wrap-updated-ust)))]
        [`(set! ,aloc_1 (,binop ,aloc_1 ,triv))
          (let ([undead-in (set-add (set-add-triv undead-out triv) aloc_1)])
            (values undead-in undead-out))]
        [`(set! ,aloc ,triv)
          (let ([undead-in (set-add-triv (set-remove undead-out aloc) triv)])
            (values undead-in undead-out))]
    )
  )

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
        [`(begin ,effects ... ,tail)
          (let-values ([(undead-out updated-ust) (analyze-program-tail undead-out tail)])
            (for/foldr ([undead-out undead-out]
                        [ust updated-ust])
                        ([effect effects])
            (let-values ([(undead-in new-ust)
                          (analyze-program-effect undead-out effect)])
                (values 
                undead-in
                (cons new-ust ust)))))]
        [`(halt ,triv)
          (let ([undead-in (set-add-triv undead-out triv)])
            (values undead-in 
                    (cons undead-out '())))]
        )
  )


  (define (get-ust tail)
    (let-values ([(_ ust) (analyze-program-tail `() tail)]) 
      ust))
  
  (define (insert-undead-analysis ust info)
    (match info
      [`(,locals)
        `(,locals (undead-out ,ust))]))

  (match p
    [`(module ,info ,tail)
      `(module ,(insert-undead-analysis (get-ust tail) info) ,tail)]))




(module+ test
  (require rackunit)

    (define (set-list=? a b)
    (set=? (list->set a)
           (list->set b)))


    (check-match 
    (undead-analysis
    '(module ((locals (x.1)))
        (begin
          (set! x.1 42)
          (halt x.1))))
    `(module ((locals (x.1)) 
              (undead-out (
                           ,(? (lambda (x) (set-list=? x '(x.1)))) 
                           ())))
        (begin 
          (set! x.1 42) 
          (halt x.1)))
        )

  (check-equal? (undead-analysis '(module ((locals (x.1))) (begin (begin (set! x.1 1)) (halt x.1))))
  `(module
  ((locals (x.1)) (undead-out (((x.1)) ())))
  (begin (begin (set! x.1 1)) (halt x.1)))
  )

  (check-equal? (undead-analysis 
    '(module ((locals (x.1))) (begin (begin (begin (set! x.1 1))) (halt x.1))))
  `(module
  ((locals (x.1)) (undead-out ((((x.1))) ())))
  (begin (begin (begin (set! x.1 1))) (halt x.1))))
  
  (check-match
    (undead-analysis
   '(module ((locals (v.1 w.2 x.3 y.4 z.5 t.6 p.1)))
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
        (halt z.5))))
    `(module ((locals (v.1 w.2 x.3 y.4 z.5 t.6 p.1))
              (undead-out
                (
                ,(? (lambda (x) (set-list=? x '(v.1))))
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
     (halt z.5))))
)