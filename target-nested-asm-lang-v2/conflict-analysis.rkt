#lang racket

(require cpsc411/compiler-lib
         cpsc411/graph-lib
         "../common.rkt")

;; Asm-pred-lang-v6/undead
; p	 	::=	 	(module info (define label info tail) ... tail)

;   info	 	::=	 	(#:from-contract (info/c (new-frames (frame ...)) (locals (aloc ...)) (call-undead (loc ...)) (undead-out undead-set-tree/rloc?)))

;   frame	 	::=	 	(aloc ...)

;   pred	 	::=	 	(relop loc opand)
;  	 	|	 	(true)
;  	 	|	 	(false)
;  	 	|	 	(not pred)
;  	 	|	 	(begin effect ... pred)
;  	 	|	 	(if pred pred pred)

;   tail	 	::=	 	(jump trg loc ...)
;  	 	|	 	(begin effect ... tail)
;  	 	|	 	(if pred tail tail)

;   effect	 	::=	 	(set! loc triv)
;  	 	|	 	(set! loc_1 (binop loc_1 opand))
;  	 	|	 	(begin effect ... effect)
;  	 	|	 	(if pred effect effect)
;  	 	|	 	(return-point label tail)

;   opand	 	::=	 	int64
;  	 	|	 	loc

;   triv	 	::=	 	opand
;  	 	|	 	label

;   loc	 	::=	 	rloc
;  	 	|	 	aloc

;   trg	 	::=	 	label
;  	 	|	 	loc

;   binop	 	::=	 	*
;  	 	|	 	+
;  	 	|	 	-

;   relop	 	::=	 	<
;  	 	|	 	<=
;  	 	|	 	=
;  	 	|	 	>=
;  	 	|	 	>
;  	 	|	 	!=

;   aloc	 	::=	 	aloc?

;   label	 	::=	 	label?

;   rloc	 	::=	 	register?
;  	 	|	 	fvar?

;   int64	 	::=	 	int64?

;; Asm-pred-lang-v6/conflicts
;  p	 	::=	 	(module info (define label info tail) ... tail)

;   info	 	::=	 	(#:from-contract (info/c (new-frames (frame ...)) (locals (aloc ...)) (call-undead (loc ...)) (conflicts ((loc (loc ...)) ...))))

;   frame	 	::=	 	(aloc ...)

;   pred	 	::=	 	(relop loc opand)
;  	 	|	 	(true)
;  	 	|	 	(false)
;  	 	|	 	(not pred)
;  	 	|	 	(begin effect ... pred)
;  	 	|	 	(if pred pred pred)

;   tail	 	::=	 	(jump trg loc ...)
;  	 	|	 	(begin effect ... tail)
;  	 	|	 	(if pred tail tail)

;   effect	 	::=	 	(set! loc triv)
;  	 	|	 	(set! loc_1 (binop loc_1 opand))
;  	 	|	 	(begin effect ... effect)
;  	 	|	 	(if pred effect effect)
;  	 	|	 	(return-point label tail)

;   opand	 	::=	 	int64
;  	 	|	 	loc

;   triv	 	::=	 	opand
;  	 	|	 	label

;   loc	 	::=	 	rloc
;  	 	|	 	aloc

;   trg	 	::=	 	label
;  	 	|	 	loc

;   binop	 	::=	 	*
;  	 	|	 	+
;  	 	|	 	-

;   relop	 	::=	 	<
;  	 	|	 	<=
;  	 	|	 	=
;  	 	|	 	>=
;  	 	|	 	>
;  	 	|	 	!=

;   aloc	 	::=	 	aloc?

;   label	 	::=	 	label?

;   rloc	 	::=	 	register?
;  	 	|	 	fvar?

;   int64	 	::=	 	int64?

(provide conflict-analysis)

;; (asm-pred-lang-v8/undead p) -> (asm-pred-lang-v8/conflicts p)
;; Decorates a program with its conflict graph, replacing the undead-out set in the info
;; field
(define (conflict-analysis p)

  (define (analyze-defintiions def)
    (match def
      [`(define ,label
          ,info
          ,tail)
       `(define ,label
          ,(info-set
            (info-remove info 'undead-out)
            'conflicts
            (analyze-tree-tail (info-ref info 'undead-out) tail (new-graph (info-ref info 'locals))))
          ,tail)]))

  (define (update-graph graph-init new-vertex vertices)
    (add-edges graph-init new-vertex (set-remove vertices new-vertex)))

  (define (set-remove-triv ust triv)
    (if (or (register? triv) (aloc? triv))
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
      [(`(set! ,loc1 (mref ,loc2 ,index)) _)
       (let ([ust^ (set-remove-triv ust index)])
         (update-graph graph-init loc1 (set-remove ust^ loc1)))]
      ;; not actually assigning variable loc
      [(`(mset! ,loc ,index ,triv) _) graph-init]
      [(`(set! ,aloc (,binop ,aloc ,triv)) _) (update-graph graph-init aloc ust)]
      [(`(set! ,aloc ,triv) _) (update-graph graph-init aloc (set-remove-triv ust triv))]
      [(`(if ,pred ,effect1 ,effect2) `(,ust1 ,ust2 ,ust3))
       (analyze-tree-effect ust3 effect2 (analyze-tree-effect ust2 effect1 graph-init))]
      [(`(return-point ,label ,tail) _) (analyze-tree-tail ust tail graph-init)]))

  (define (analyze-tree-pred ust pred graph-init)
    (match* (pred ust)
      [(`(begin
           ,fx* ...
           ,pred0)
        `(,ust* ... ,ust-pred))
       (analyze-tree-pred ust-pred
                          pred0
                          (for/fold ([graph graph-init])
                                    ([effect fx*]
                                     [ust ust*])
                            (analyze-tree-effect ust effect graph)))]
      [(`(not ,pred0) `(,ust-pred0)) (analyze-tree-pred ust-pred0 pred0)]
      [(`(,relop ,loc ,opand) _) (update-graph graph-init loc (set-remove-triv ust opand))]
      [(pred ust) graph-init]))

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
      [(`(jump ,trg ,loc ...) ust)
       ;(update-graph graph-init trg ust)
       (if (not (label? trg))
           (update-graph graph-init trg ust)
           graph-init)]
      [(`(if ,pred ,tail1 ,tail2) `(,ust1 ,ust2 ,ust3))
       (analyze-tree-tail ust3
                          tail2
                          (analyze-tree-tail ust2 tail1 (analyze-tree-pred ust1 pred graph-init)))]))

  (match p
    [`(module ,info ,definitions
        ...
        ,tail)
     `(module ,(info-set (info-remove info 'undead-out)
                         'conflicts
                         (analyze-tree-tail (info-ref info 'undead-out)
                                            tail
                                            (new-graph (info-ref info 'locals))))
              ,@(map analyze-defintiions definitions)
        ,tail)]))

(module+ test
  (require rackunit)
  (check-match (conflict-analysis `(module ((new-frames ()) (locals (x.1 x.2 x.3))
                                                            (call-undead ())
                                                            (undead-out ((r15 x.1) (x.1) (x.1))))
                                           (begin
                                             (set! x.1 (mref x.2 x.3))
                                             (mset! x.1 3 r15)
                                             (jump L.test.1 x.1))
                                     ))
               `(module ((new-frames ()) (locals (x.1 x.2 x.3))
                                         (call-undead ())
                                         (conflicts ((x.3 ()) (x.2 ()) (x.1 (r15)) (r15 (x.1)))))
                        (begin
                          (set! x.1 (mref x.2 x.3))
                          (mset! x.1 3 r15)
                          (jump L.test.1 x.1))
                  ))

  (check-match
   (conflict-analysis
    `(module ((new-frames ()) (locals (x.1 x.2 x.3 y.7))
                              (call-undead ())
                              (undead-out ((x.3 x.2 r15 y.7) (r15 y.7 x.1) (x.1) (x.1))))
             (begin
               (set! x.1 5)
               (set! x.1 (mref x.2 x.3))
               (mset! x.1 y.7 r15)
               (jump L.test.1 x.1))
       ))
   `(module ((new-frames ())
             (locals (x.1 x.2 x.3 y.7))
             (call-undead ())
             (conflicts ((y.7 (x.1)) (x.3 (x.1)) (x.2 (x.1)) (x.1 (y.7 r15 x.2 x.3)) (r15 (x.1)))))
            (begin
              (set! x.1 5)
              (set! x.1 (mref x.2 x.3))
              (mset! x.1 y.7 r15)
              (jump L.test.1 x.1))
      )))
