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

  (define (analyze-defintiions def)
    (match def
      [`(define ,label
          ,info
          ,tail)
       `(define ,label
          ((locals ,(info-ref info 'locals))
           (conflicts ,(analyze-tree-tail (info-ref info 'undead-out)
                                          tail
                                          (new-graph (info-ref info 'locals)))))
          ,tail)]))

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
      [(`(jump ,trg ,loc ...) ust) graph-init]
      ;; pred doesn't need to be checked for conflicts,
      ;; as it is impossible to define new variables in pred.
      [(`(if ,pred ,tail1 ,tail2) `(,ust1 ,ust2 ,ust3))
       (analyze-tree-tail ust3
                          tail2
                          (analyze-tree-tail ust2 tail1 (analyze-tree-pred ust1 pred graph-init)))]))

  ;; Undead-search-tree (Asm-lang-v4/undead pred) -> graph
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
  (match p
    [`(module ,info ,definitions
        ...
        ,tail)
     `(module ((locals ,(info-ref info 'locals))
               (conflicts ,(analyze-tree-tail (info-ref info 'undead-out)
                                              tail
                                              (new-graph (info-ref info 'locals)))))
              ,@(map analyze-defintiions definitions)
        ,tail)]))