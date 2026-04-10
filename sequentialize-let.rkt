#lang racket

(require cpsc411/compiler-lib)
(provide sequentialize-let)

(define binop? (or/c '+ '- '*))
(define (binop->fun op)
  (match op
    ['+ x64-add]
    ['* x64-mul]
    ['- x64-sub]))
(define triv? (or/c aloc? label?))
(define opand? (or/c aloc? int64?))

;; values-unique-lang-v6
; p	 	::=	 	(module (define label (lambda (aloc ...) tail)) ... tail)
; pred	 	::=	 	(relop opand opand)
;  	|	 	(true)
;  	|	 	(false)
;  	|	 	(not pred)
;  	|	 	(let ([aloc value] ...) pred)
;  	|	 	(if pred pred pred)
; tail	 	::=	 	value
;  	|	 	(let ([aloc value] ...) tail)
;  	|	 	(if pred tail tail)
;  	|	 	(call triv opand ...)
; value	 	::=	 	triv
;  	|	 	(binop opand opand)
;  	|	 	(let ([aloc value] ...) value)
;  	|	 	(if pred value value)
;  	|	 	(call triv opand ...)
; opand	 	::=	 	int64
;  	|	 	aloc
; triv	 	::=	 	opand
;  	|	 	label
; binop	 	::=	 	*
;  	|	 	+
;  	|	 	-
; relop	 	::=	 	<
;  	|	 	<=
;  	|	 	=
;  	|	 	>=
;  	|	 	>
;  	|	 	!=

; ------------------
;; diff:
; pred	 	::=	 	(relop opand opand)
;  	 	|	 	(true)
;  	 	|	 	(false)
;  	 	|	 	(not pred)
;  	 	|	 	(begin effect ... pred)+
;  	 	|	 	(let ([aloc value] ...) pred)-
;  	 	|	 	(if pred pred pred)
; tail	 	::=	 	value
; |	 	(call triv opand ...)+
; |	 	(begin effect ... tail)+
; |	 	(let ([aloc value] ...) tail)-
; |	 	(if pred tail tail)
; |	 	(call triv opand ...)-
;value	 	::=	 	triv
; |	 	(call triv opand ...)+
; |	 	(binop opand opand)
; |	 	(begin effect ... value)+
; |	 	(let ([aloc value] ...) value)-
; |	 	(if pred value value)
; |	 	(call triv opand ...)-
;effect+	 	::=	 	(set! aloc value)
; |	 	(begin effect ... effect)
; |	 	(if pred effect effect)

;; aloc value -> `(set! ,aloc ,value)
(define (make-fx aloc value)
  `(set! ,aloc ,value))

; values-unique-lang-v6 -> imp-mf-lang-v6
(define (sequentialize-let vulv6)
  (define (make-fx+ aloc value)
    (make-fx aloc (seq-let-value value)))
  (define (seq-let-def def)
    (match def
      [`(define ,label (lambda (,aloc* ...) ,tail))
       `(define ,label (lambda ,aloc* ,(seq-let-tail tail)))]))
  (define (seq-let-pred pred)
    (match pred
      [`(if ,pred0 ,pred1 ,pred2)
       `(if ,(seq-let-pred pred0)
            ,(seq-let-pred pred1)
            ,(seq-let-pred pred2))]
      [`(let ([,aloc* ,val*] ...) ,pred) (make-begin (map make-fx+ aloc* val*) (seq-let-pred pred))]
      [`(not ,pred) `(not ,(seq-let-pred pred))]
      [_ pred]))
  (define (seq-let-value val)
    (match val
      [`(let ([,aloc* ,val*] ...) ,value)
       (make-begin (map make-fx+ aloc* val*) (seq-let-value value))]
      ;; (call triv opand ...) exists for both langs despite showing on the diff
      [`(if ,pred ,value1 ,value2)
       `(if ,(seq-let-pred pred)
            ,(seq-let-value value1)
            ,(seq-let-value value2))]
      [_ val]))
  (define (seq-let-tail tail)
    (match tail
      [`(let ([,aloc* ,val*] ...) ,tail0) (make-begin (map make-fx+ aloc* val*) (seq-let-tail tail0))]
      [`(if ,pred ,tail1 ,tail2)
       `(if ,(seq-let-pred pred)
            ,(seq-let-tail tail1)
            ,(seq-let-tail tail2))]
      ;; (call triv opand ...) exists for both langs despite showing on the diff
      [_ tail]))
  (define (seq-let-p p)
    (match p
      [`(module ,def* ...
          ,tail)
       `(module ,@(map seq-let-def def*) ,(seq-let-tail tail)
          )]))
  (seq-let-p vulv6))
