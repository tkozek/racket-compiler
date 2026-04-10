#lang racket

(require cpsc411/compiler-lib)
; Asm-lang-v2/conflicts
; p	 	::=	 	(module info tail)
;   info	 	::=	 	(#:from-contract (info/c (locals (aloc ...)) (conflicts ((aloc (aloc ...)) ...))))
;----------------
; Asm-lang-v2/assignments
; p	 	::=	 	(module info tail)
;  info	 	::=	 	(#:from-contract (info/c (locals (aloc ...)) (assignment ((aloc loc) ...))))

;; same as v4
(provide (all-defined-out))

;; (Listof X) (X -> Number) (X -> Y) -> Y
;; returns the (k x) with x as the least value item of the list given the evaluation function
; did I really need the continuation? no. But is it funny? sure.
(define (minimum& x* valueof [k identity])
  (let ([valueof (λ (x)
                   (if (void? x)
                       +inf.f
                       (valueof x)))])
    (define (min-of x y)
      (if (> (valueof x) (valueof y)) y x))
    (let loop ([x* x*]
               [cur-min (void)])
      (if (empty? x*)
          (k cur-min)
          (loop (rest x*) (min-of (first x*) cur-min))))))

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
;; asm-lang-v4/conflicts -> asm-lang-v4/assignments
;; Performs graph-colouring register allocation. The pass attempts to fit each of
;;     the abstract location declared in the locals set into a register,
;;     and if one cannot be found, assigns it a frame variable instead.
(define (assign-registers p)
  (define assignables (current-assignable-registers))
  (define num-fvars 0)

  (define (assign-definition def)
    (match def
      [`(define ,label
          ,info
          ,tail)
       `(define ,label
          ,(assign-registers/info info)
          ,tail)]))

  ;let cinfo represent asm-lang-v4/conflicts-info
  ;let clocals represent asm-lang-v4/conflicts-info-locals
  ;let conflicts represent asm-lang-v4/conflicts-info-conflicts
  ;let ainfo represent asm-lang-v4/assignments-info
  ;let alocals represent asm-lang-v4/assignments-info-locals
  ;let assignments represent asm-lang-v4/assignment-info-assignments

  ;; (listof loc) assignments -> (register or fvar)
  ;; produce a register that is not assigned by any aloc in the 'self-conflicts' list
  ;;     if no registers are available, produce a fvar instead.
  ;; EFFECT: increments the number of fvar allocated for the runtime of the 'assign-registers'
  ;;     function
  (define (get-assignment! self-conflicts assignments)
    (define assigned (map (λ (aloc) (info-ref assignments aloc)) (filter aloc? self-conflicts)))
    (define registers (filter (λ (reg) (not (memq reg assigned))) assignables))
    (if (empty? registers)
        (let ([fvar (make-fvar num-fvars)])
          (set! num-fvars (+ 1 num-fvars))
          fvar)
        ;; effects on assignment needs to be processed elsewhere
        (first registers)))

  ;; cinfo (assignments -> ainfo) -> ainfo
  (define (assign-registers/info info)
    (define conflicts (info-ref info 'conflicts))
    (let loop ([conflicts conflicts]
               [k (λ (assignments) (info-set info 'assignment assignments))])
      (if (empty? conflicts)
          (k '())
          (match-let ([`(,reg ,reg-conflicts) (minimum& conflicts num-values)])
            (loop
             (map (λ (conflict) (remove-from-loy conflict reg)) (info-remove conflicts reg))
             (λ (assignments)
               (k (if (register? reg)
                      assignments ; (info-set assignments reg reg)
                      (info-set assignments reg (get-assignment! reg-conflicts assignments))))))))))

  (match p
    [`(module ,info ,definitions
        ...
        ,tail)
     `(module ,(assign-registers/info info) ,@(map assign-definition definitions)
        ,tail)]))
