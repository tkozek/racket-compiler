#lang racket

(require cpsc411/compiler-lib)
(provide impose-calling-conventions)

; proc-imp-cmf-lang-v5 :
;   p	 	::=
; (module (define label (lambda (aloc ...) tail)) ...
;         tail)
;   pred	 	::=	 	(relop opand opand)
;  	 	|	 	(true)
;  	 	|	 	(false)
;  	 	|	 	(not pred)
;  	 	|	 	(begin effect ... pred)
;  	 	|	 	(if pred pred pred)
;   tail	 	::=	 	value
;  	 	|	 	(call triv opand ...)
;  	 	|	 	(begin effect ... tail)
;  	 	|	 	(if pred tail tail)
;   value	 	::=	 	triv
;  	 	|	 	(binop opand opand)
;   effect	 	::=	 	(set! aloc value)
;  	 	|	 	(begin effect ... effect)
;  	 	|	 	(if pred effect effect)
;   opand	 	::=	 	int64
;  	 	|	 	aloc
;   triv	 	::=	 	opand
;  	 	|	 	label
;   binop	 	::=	 	*
;  	 	|	 	+
;   relop	 	::=	 	<
;  	 	|	 	<=
;  	 	|	 	=
;  	 	|	 	>=
;  	 	|	 	>
;  	 	|	 	!=
;   aloc	 	::=	 	aloc?
;   label	 	::=	 	label?
;   int64	 	::=	 	int64?
;; ---------------------------------
;   imp-cmf-lang-v5 : grammar?
;   p	 	::=	 	(module (define label tail) ... tail)
;   pred	 	::=	 	(relop opand opand)
;  	 	|	 	(true)
;  	 	|	 	(false)
;  	 	|	 	(not pred)
;  	 	|	 	(begin effect ... pred)
;  	 	|	 	(if pred pred pred)
;   tail	 	::=	 	value
;  	 	|	 	(jump trg loc ...)
;  	 	|	 	(begin effect ... tail)
;  	 	|	 	(if pred tail tail)
;   value	 	::=	 	triv
;  	 	|	 	(binop opand opand)
;   effect	 	::=	 	(set! loc value)
;  	 	|	 	(begin effect ... effect)
;  	 	|	 	(if pred effect effect)
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

(define rloc? (or/c register? fvar?))
(define opand/proc-imp-cmf-lang-v5? (or/c int64? aloc?))
(define opand/imp-cmf-lang-v5? (or/c int64? aloc? rloc?))
(define triv/proc-imp-cmf-lang-v5? (or/c opand/proc-imp-cmf-lang-v5? label?))
(define triv/imp-cmf-lang-v5? (or/c opand/imp-cmf-lang-v5? label?))

;; proc-imp-cmf-lang-v5 -> imp-cmf-lang-v5
;; Compiles Proc-imp-cmf-lang v5 to Imp-cmf-lang v5
;;     by imposing calling conventions on all calls and procedure definitions.
;;     The parameter registers are defined by the list current-parameter-registers.
(define (impose-calling-conventions picl5)
  ; (listof opand) -> (listof rloc)
  ;  generates a list of rlocs to for each aloc, following the calling convention
  (define (generate-param-list aloc*)
    (define num-param-reg (length (current-parameter-registers)))
    (define (get-reg-or-fvar idx)
      (if (< idx num-param-reg)
          (list-ref (current-parameter-registers) idx)
          (make-fvar (- idx num-param-reg))))
    (map get-reg-or-fvar (range (length aloc*))))

  ; (listof X) (listof Y) -> (listof `(set ,X ,Y))
  ;  generates a list of set! expressions given X and Y
  (define (generate-sets X* Y*)
    (map (λ (x y) `(set! ,x ,y)) X* Y*))

  (define (impose-define label aloc* tail)
    `(define ,label
       (begin
         ,@(generate-sets aloc* (generate-param-list aloc*))
         ,(impose-tail tail))))

  (define (impose-tail tail)
    (match tail
      [`(call ,(? triv/proc-imp-cmf-lang-v5? triv) ,(? opand/proc-imp-cmf-lang-v5? opand*) ...)
       (define loc* (generate-param-list opand*))
       `(begin
          ,@(generate-sets loc* opand*)
          (jump ,triv rbp ,@loc*))]
      [`(begin
          ,fx* ...
          ,tail)
       `(begin
          ,@fx*
          ,(impose-tail tail))]
      [`(if ,pred ,tail1 ,tail2)
       `(if ,pred
            ,(impose-tail tail1)
            ,(impose-tail tail2))]
      [value value]))

  (define (impose-p p)
    (match p
      [`(module (define ,(? label? label*)
                  (lambda (,(? aloc? aloc**) ...) ,tail*))
                ...
          ,tail)
       `(module ,@(map impose-define label* aloc** tail*) ,(impose-tail tail)
          )]))

  (impose-p picl5))
