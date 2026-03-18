#lang racket

(require cpsc411/compiler-lib
         cpsc411/graph-lib)

;; Asm-lang v2/undead
; p	 	    ::=	 	(module info tail)

; info	 	::=	 	(#:from-contract (info/c (locals (aloc ...)) (undead-out undead-set-tree?)))

; tail	 	::=	 	(halt triv)
;	 	    |	 	(begin effect ... tail)
;
; effect	 ::=	(set! aloc triv)
;	 	    |	 	(set! aloc_1 (binop aloc_1 triv))
;	 	    |	 	(begin effect ... effect)
;
; triv	 	::=	 	int64
;	 	    |	 	aloc
;
; binop	 	::=	 	*
;	 	    |	 	+
;
; aloc	 	::=	 	aloc?
;
; int64	 	::=	 	int64?

;; Asm-lang v2/conflicts
; p	 	    ::=	 	(module info tail)
;
; info	 	::=	 	(#:from-contract (info/c (locals (aloc ...)) (conflicts ((aloc (aloc ...)) ...))))
;
; tail	 	::=	 	(halt triv)
;	 	    |	 	(begin effect ... tail)
;
; effect	::=	 	(set! aloc triv)
;	 	    |	 	(set! aloc_1 (binop aloc_1 triv))
;	 	    |	 	(begin effect ... effect)
;
; triv	 	::=	 	int64
;	 	    |	 	aloc
;
; binop	 	::=	 	*
;	 	    |	 	+
;
; aloc	 	::=	 	aloc?
;
; int64	 	::=	 	int64?

(provide conflict-analysis)

;; (Asm-lang-v4/undead p) -> (Asm-lang-v4/conflicts p)
;; Decorates a program with its conflict graph, replacing the undead-out set in the info
;; field
(define (conflict-analysis p)

  (define (update-graph graph-init new-vertex vertices)
    (add-edges graph-init new-vertex (set-remove vertices new-vertex)))

  (define (set-remove-triv ust triv)
    (if (aloc? triv)
        (set-remove ust triv)
        ust))

  ;; Undead-search-tree (Asm-lang-v2/undead tail) -> graph
  (define (analyze-tree-effect ust effect graph-init)
    (match* (effect ust)
      [(`(begin
           ,effects ...)
        _)
       (for/fold ([graph graph-init])
                 ([effect effects]
                  [ust ust])
         (analyze-tree-effect ust effect graph))]
      [(`(set! ,aloc (,binop ,aloc ,triv)) _) (update-graph graph-init aloc ust)]
      [(`(set! ,aloc ,triv) _) (update-graph graph-init aloc (set-remove-triv ust triv))]
      [(`(if ,pred ,effect1 ,effect2) `(,ust1 ,ust2 ,ust3))
       (analyze-tree-effect ust3 effect2 (analyze-tree-effect ust2 effect1 graph-init))]))

  ;; Undead-search-tree (Asm-lang-v2/undead tail) -> graph
  (define (analyze-tree-tail ust tail graph-init)
    (match* (tail ust)
      [(`(begin
           ,effects ...
           ,tail)
        `(,usts ... ,ust))
       (analyze-tree-tail ust
                          tail
                          (for/fold ([graph graph-init])
                                    ([effect effects]
                                     [ust usts])
                            (analyze-tree-effect ust effect graph)))]
      [(`(halt ,triv) ust) graph-init]
      [(`(if ,pred ,tail1 ,tail2) `(,ust1 ,ust2 ,ust3))
       (analyze-tree-tail ust3 tail2 
        (analyze-tree-tail ust2 tail1 
         (analyze-tree-pred ust1 pred graph-init)))]))

  ;; Thanks Rui
  (define (analyze-tree-pred ust pred graph-init)
    (match* (pred ust)
      [(`(begin ,fx* ... ,pred0) `(,ust* ... ,ust-pred)) 
       (analyze-tree-pred ust-pred pred0 (for/fold ([graph graph-init])
                                                    ([effect fx*]
                                                    [ust ust*])
                                                    (analyze-tree-effect ust effect graph)))]
      [(`(not ,pred0) `(,ust-pred0)) (analyze-tree-pred ust-pred0 pred0)]
      [(`(,relop ,loc ,opand) _) (update-graph graph-init loc (set-remove-triv ust opand))]
      [(pred ust) graph-init]))

  (match p
    [`(module ,info ,tail
        )
     `(module ((locals ,(info-ref info 'locals))
               (conflicts ,(analyze-tree-tail (info-ref info 'undead-out)
                                              tail
                                              (new-graph (info-ref info 'locals)))))
              ,tail
        )]))

;; NOTES
#;((p.1 (z.5 t.6 y.4 x.3 w.2)) (t.6 (p.1 z.5))
                               (z.5 (p.1 t.6 w.2 y.4))
                               (y.4 (z.5 x.3 p.1 w.2))
                               (x.3 (y.4 p.1 w.2))
                               (w.2 (z.5 y.4 p.1 x.3 v.1))
                               (v.1 (w.2)))

#;((p.1 (z.5 t.6 y.4 x.3 w.2)) (t.6 (p.1 z.5))
                               (z.5 (p.1 t.6 w.2 y.4))
                               (y.4 (z.5 x.3 p.1 w.2))
                               (x.3 (y.4 p.1 w.2))
                               (w.2 (z.5 y.4 p.1 x.3 v.1))
                               (v.1 (w.2)))

(module+ test
  (require rackunit)

  (check-equal? (conflict-analysis '(module ((locals (x.1)) (undead-out ((x.1) ())))
                                            (begin
                                              (set! x.1 42)
                                              (halt x.1))
                                      ))
                '(module ((locals (x.1)) (conflicts ((x.1 ()))))
                         (begin
                           (set! x.1 42)
                           (halt x.1))
                   ))

  ; works
  ; (check-equal?
  ;     (conflict-analysis
  ;             '(module
  ;                 ((locals (y.1))
  ;                 (undead-out ((y.1) (y.1) ())))
  ;                     (begin
  ;                         (set! y.1 42)
  ;                         (set! x.1 1)
  ;                         (halt y.1))))
  ;     `(module
  ;     ((locals (y.1)) (conflicts ((y.1 (x.1)) (x.1 (y.1)))))
  ;     (begin (set! y.1 42) (set! x.1 1) (halt y.1))))

  (check-equal? (conflict-analysis '(module ((locals (y.1)) (undead-out ((y.1) (y.1) ())))
                                            (begin
                                              (set! y.1 42)
                                              (set! y.1 y.1)
                                              (halt y.1))
                                      ))
                '(module ((locals (y.1)) (conflicts ((y.1 ()))))
                         (begin
                           (set! y.1 42)
                           (set! y.1 y.1)
                           (halt y.1))
                   ))
  (check-equal? (conflict-analysis '(module ((locals (y.1)) (undead-out ((y.1) (y.1) (y.1))))
                                            (begin
                                              (set! y.1 42)
                                              (set! y.1 y.1)
                                              (set! y.1 y.1)
                                              (halt y.1))
                                      ))
                '(module ((locals (y.1)) (conflicts ((y.1 ()))))
                         (begin
                           (set! y.1 42)
                           (set! y.1 y.1)
                           (set! y.1 y.1)
                           (halt y.1))
                   ))
  ; works
  ; (check-equal?
  ;     (conflict-analysis
  ;         '(module ((locals (v.1 w.2 x.3 y.4 z.5 t.6 p.1))
  ;                     (undead-out
  ;                         ((v.1)
  ;                     (v.1 w.2)
  ;                     (w.2 x.3)
  ;                     (p.1 w.2 x.3)
  ;                     (w.2 x.3)
  ;                     (y.4 w.2 x.3)
  ;                     (p.1 y.4 w.2 x.3)
  ;                     (y.4 w.2 x.3)
  ;                     (z.5 y.4 w.2)
  ;                     (z.5 y.4)
  ;                     (t.6 z.5)
  ;                     (t.6 z.5 p.1)
  ;                     (t.6 z.5)
  ;                     (z.5)
  ;                     ())))
  ;         (begin
  ;             (set! v.1 1)
  ;             (set! w.2 46)
  ;             (set! x.3 v.1)
  ;             (set! p.1 7)
  ;             (set! x.3 (+ x.3 p.1))
  ;             (set! y.4 x.3)
  ;             (set! p.1 4)
  ;             (set! y.4 (+ y.4 p.1))
  ;             (set! z.5 x.3)
  ;             (set! z.5 (+ z.5 w.2))
  ;             (set! t.6 y.4)
  ;             (set! p.1 -1)
  ;             (set! t.6 (* t.6 p.1))
  ;             (set! z.5 (+ z.5 t.6))
  ;             (halt z.5))))
  ;     '(module ((locals (v.1 w.2 x.3 y.4 z.5 t.6 p.1))
  ;         (conflicts
  ;         ((p.1 (z.5 t.6 y.4 x.3 w.2))
  ;         (t.6 (p.1 z.5))
  ;         (z.5 (p.1 t.6 w.2 y.4))
  ;         (y.4 (z.5 x.3 p.1 w.2))
  ;         (x.3 (y.4 p.1 w.2))
  ;         (w.2 (z.5 y.4 p.1 x.3 v.1))
  ;         (v.1 (w.2)))))
  ;         (begin
  ;             (set! v.1 1)
  ;             (set! w.2 46)
  ;             (set! x.3 v.1)
  ;             (set! p.1 7)
  ;             (set! x.3 (+ x.3 p.1))
  ;             (set! y.4 x.3)
  ;             (set! p.1 4)
  ;             (set! y.4 (+ y.4 p.1))
  ;             (set! z.5 x.3)
  ;             (set! z.5 (+ z.5 w.2))
  ;             (set! t.6 y.4)
  ;             (set! p.1 -1)
  ;             (set! t.6 (* t.6 p.1))
  ;             (set! z.5 (+ z.5 t.6))
  ;             (halt z.5))))

  #;(begin
      (set! x.6 2)
      (set! x.6 (+ x.6 3))
      (set! x.7 x.6)
      (set! x.7 (+ x.7 x.6))
      (set! y.2 5)
      (halt x.6))

  #;((x.6) (x.6) (x.7 x.6) (x.6) (x.6) ())

  ;; Actual

  #;((y.2 (x.6)) (x.7 ()) (x.6 (y.2)))

  ;; Expected

  #;((y.2 (x.6)) (x.7 (x.6)) (x.6 (y.2 x.7)))

  #;
  ;;works
  (check-equal? (conflict-analysis
                 '(module ((locals (a.1 b.2 c.3 d.4))
                           (undead-out ((a.1) (a.1 c.3) (b.2 a.1 c.3) (a.1 c.3) (c.3 d.4) (d.4) ())))
                          (begin
                            (set! a.1 1)
                            (set! c.3 2)
                            (set! b.2 a.1)
                            (set! b.2 (+ b.2 c.3))
                            (set! d.4 a.1)
                            (set! d.4 (* d.4 c.3))
                            (halt d.4))
                    ))
                `(module ((locals (a.1 b.2 c.3 d.4)) (conflicts ((d.4 (c.3)) (c.3 (d.4 b.2 a.1))
                                                                             (b.2 (a.1 c.3))
                                                                             (a.1 (b.2 c.3)))))
                         (begin
                           (set! a.1 1)
                           (set! c.3 2)
                           (set! b.2 a.1)
                           (set! b.2 (+ b.2 c.3))
                           (set! d.4 a.1)
                           (set! d.4 (* d.4 c.3))
                           (halt d.4))
                   ))

  (check-equal? (conflict-analysis
                 '(module ((locals (x.6 x.7 y.2)) (undead-out ((x.6) (x.6) (x.7 x.6) (x.6) (x.6) ())))
                          (begin
                            (set! x.6 2)
                            (set! x.6 (+ x.6 3))
                            (set! x.7 x.6)
                            (set! x.7 (+ x.7 x.6))
                            (set! y.2 5)
                            (halt x.6))
                    ))
                `(module ((locals (x.6 x.7 y.2)) (conflicts ((y.2 (x.6)) (x.7 (x.6))
                                                                         (x.6 (y.2 x.7)))))
                         (begin
                           (set! x.6 2)
                           (set! x.6 (+ x.6 3))
                           (set! x.7 x.6)
                           (set! x.7 (+ x.7 x.6))
                           (set! y.2 5)
                           (halt x.6))
                   ))

  #;
  ;;works
  (check-equal?
   (conflict-analysis
    `(module ((locals (y.2 x.1 B.3)) (undead-out (((y.2) (x.1 y.2) (x.1 y.2)) ((x.1 y.2) (y.2)) ())))
             (begin
               (begin
                 (set! y.2 1)
                 (set! x.1 1)
                 (set! B.3 x.1))
               (begin
                 (set! x.1 (+ x.1 1))
                 (set! y.2 (+ y.2 x.1)))
               (halt y.2))
       ))
   `(module ((locals (y.2 x.1 B.3)) (conflicts ((B.3 (y.2)) (x.1 (y.2)) (y.2 (x.1 B.3)))))
            (begin
              (begin
                (set! y.2 1)
                (set! x.1 1)
                (set! B.3 x.1))
              (begin
                (set! x.1 (+ x.1 1))
                (set! y.2 (+ y.2 x.1)))
              (halt y.2))
      ))

  ;; milestone 4

  (check-equal?
   (conflict-analysis
    `(module ((locals (x.1 y.2 b.3 c.4))
              (undead-out ((x.1) (x.1 y.2) ((y.2 b.3) (b.3) (b.3 c.4) ((c.4) () ((c.4) ()))))))
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
   `(module ((locals (x.1 y.2 b.3 c.4)) (conflicts ((c.4 ()) (b.3 (y.2)) (y.2 (b.3)) (x.1 ()))))
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
      )))
