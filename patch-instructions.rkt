#lang racket
(require cpsc411/compiler-lib
         cpsc411/langs/v8
         "common.rkt")

(provide patch-instructions)

;; (Para-asm-lang-v8 p)-> (Paren-x64-mops-v8 p)
;; Compiles para-asm-lang-v8 to paren-x64-mops-v8 by patching each instruction that has no x64
;; analogue into a sequence of instructions using auxiliary
;; registers from current-patch-instruction-registers
(define (patch-instructions p)
  (define aux-reg current-patch-instructions-registers)
  (define first-reg (first (aux-reg)))
  (define second-reg (second (aux-reg)))

  ;; (para-asm-lang-v8 s)-> (paren-x64-mops-v8 s)
  ;; patches set! instructions where the id is a register
  (define (patch-set-reg s)
    (match s
      [`(set! ,reg1 (,binop ,reg1 ,triv))
       #:when (and (integer? triv) (not (int32? triv)))
       `((set! ,first-reg ,triv) (set! ,reg1 (,binop ,reg1 ,first-reg)))]
      [_ `(,s)]))

  ;; (para-asm-lang-v8 s)-> (paren-x64-mops-v8 s)
  ;; patches set! instructions where the id is a register
  (define (patch-set-addr s)
    (match s
      [`(set! ,addr1 (,binop ,addr1 ,triv))
       `((set! ,first-reg ,triv) (set! ,first-reg (,binop ,first-reg ,addr1))
                                 (set! ,addr1 ,first-reg))]
      [`(set! ,addr1 ,triv)
       #:when (or (addr? triv) (and (integer? triv) (not (int32? triv))))
       `((set! ,first-reg ,triv) (set! ,addr1 ,first-reg))]
      [_ `(,s)]))

  ;; (set! loc1 (mref loc2 index))
  ;; if loc1 is an addr, we need to patch that to a register
  ;; if loc1 is an addr and loc2 is an addr, we need to patch both to registers
  ;; if

  ; (define (patch-mref s)
  ;   (match s
  ;     []))

  ;; mset! loc1 index triv
  ;; loc1 must be a register, else it needs to be patched
  ;; if index is an addr, or an int64 and not an int32, then it must be patched
  ;; triv can be int32, reg, label. cannot be int64 and not int32, cannot be addr
  ; (define (patch-mset s)
  ;   (match s
  ;     ;; may add one more instruction than necessary, but collapses cases
  ;     [`(mset! ,loc ,index ,triv)
  ;      #:when (register? loc)
  ;      `((set! ,first-reg ,index) (set! ,second-reg ,triv) (mset! ,loc ,first-reg ,second-reg))]
  ;     [`(mset! ,addr ,index ,triv)
  ;      (match addr
  ;        [`((,? ?frame-base-pointer-register? fbp) - ,offset) ((set! ,first-reg))])
  ;      `((set! ,second-reg ,addr) (set! ,first-reg ,index) (mset!))]))
  ; s	 	::=	 	(set! loc triv)
  ;  	 	|	 	(set! loc_1 (binop loc_1 opand))
  ;  	 	|	 	(set! loc_1 (mref loc_2 index))
  ;  	 	|	 	(mset! loc_1 index triv)
  ;  	 	|	 	(with-label label s)
  ;  	 	|	 	(jump trg)
  ;  	 	|	 	(compare loc opand)
  ;  	 	|	 	(jump-if relop trg)
  ;   loc	 	::=	 	reg
  ; |	 	addr
  ; triv	 	::=	 	opand
  ;  	|	 	label
  ; opand	 	::=	 	int64
  ;  	|	 	reg
  ; -----------------------------
  ; s	 	::=	 	(set! addr int32)
  ;  	|	 	(set! addr trg)
  ;  	|	 	(set! reg loc)
  ;  	|	 	(set! reg triv)
  ;  	|	 	(set! reg_1 (binop reg_1 int32))
  ;  	|	 	(set! reg_1 (binop reg_1 loc))
  ;  	|	 	(set! reg_1 (mref reg_2 index))
  ;  	|	 	(mset! reg_1 index int32)
  ;  	|	 	(mset! reg_1 index trg)
  ;  	|	 	(with-label label s)
  ;  	|	 	(jump trg)
  ;  	|	 	(compare reg opand)
  ;  	|	 	(jump-if relop label)
  ;  triv	 	::=	 	trg
  ;  	|	 	int64
  ; trg	 	::=	 	reg
  ; |	 	label
  ;; by observation: src-triv === trg-triv
  (define (patch-s s)
    (match s
      [`(mset! ,loc1 ,index ,triv) `((set! ,first-reg ,loc1) (mset! ,first-reg ,index ,triv))]
      [`(set! ,loc1 (mref ,loc2 ,index))
       `((set! ,second-reg ,loc2) (set! ,second-reg (mref ,second-reg ,index))
                                  (set! ,loc1 ,second-reg))]
      [`(set! ,loc ,rest)
       #:when (register? loc)
       (patch-set-reg s)]
      [`(set! ,loc ,rest) (patch-set-addr s)]
      [`(with-label ,label ,s)
       (define patched (patch-s s))
       `((with-label ,label ,(first patched)) ,@(rest patched))]
      [`(compare ,loc ,opand)
       `((set! ,first-reg ,loc) (set! ,second-reg ,opand) (compare ,first-reg ,second-reg))]
      [`(jump-if ,relop ,trg)
       #:when (or (addr? trg) (register? trg))
       `((set! ,first-reg ,trg) (jump-if ,relop ,first-reg))]
      [`(jump ,trg)
       #:when (addr? trg)
       `((set! ,first-reg ,trg) (jump ,first-reg))]
      [_ `(,s)]))

  (define (patch-p p)
    (match p
      [`(begin
          ,ss ...)
       `(begin
          ,@(apply append (map patch-s ss)))]))

  (patch-p p))
