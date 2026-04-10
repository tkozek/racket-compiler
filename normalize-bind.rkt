#lang racket

(require cpsc411/compiler-lib)

(provide normalize-bind)
; imp-mf-lang-v6
;  p	 	::=	 	(module (define label (lambda (aloc ...) tail)) ... tail)
 	 	 	 	 
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
;  	 	|	 	(call triv opand ...)
;  	 	|	 	(binop opand opand)
;  	 	|	 	(begin effect ... value)
;  	 	|	 	(if pred value value)
 	 	 	 	 
;   effect	 	::=	 	(set! aloc value)
;  	 	|	 	(begin effect ... effect)
;  	 	|	 	(if pred effect effect)
 	 	 	 	 
;   opand	 	::=	 	int64
;  	 	|	 	aloc
 	 	 	 	 
;   triv	 	::=	 	opand
;  	 	|	 	label
 	 	 	 	 
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
 	 	 	 	 
;   int64	 	::=	 	int64?
; --------------------
; proc-imp-cmf-lang-v6
; p	 	::=	 	
; (module (define label (lambda (aloc ...) entry)) ...
;   entry)
 	 	 	 	 
;   entry	 	::=	 	tail
 	 	 	 	 
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
;  	 	|	 	(call triv opand ...)
 	 	 	 	 
;   effect	 	::=	 	(set! aloc value)
;  	 	|	 	(begin effect ... effect)
;  	 	|	 	(if pred effect effect)
 	 	 	 	 
;   opand	 	::=	 	int64
;  	 	|	 	aloc
 	 	 	 	 
;   triv	 	::=	 	opand
;  	 	|	 	label
 	 	 	 	 
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
 	 	 	 	 
;   int64	 	::=	 	int64?

; imp-mf-lang-v6 -> proc-imp-cmf-lang-v6
;; Compiles imp-mf-lang-v6 to proc-imp-cmf-lang-v6, pushing set! under begin so that the 
;; right hand side of each set! is a base value-producing operation
(define (normalize-bind mf)
  (define (join-begin fx* tail)  
    (match tail 
      [`(begin ,fx2* ... ,tail) (make-begin (append fx2* fx*) tail)]
      [_ (make-begin fx* tail)]))
  (define (normalize-definitions definition)
    (match definition
      [`(define ,label (lambda ,alocs ,tail))
       `(define ,label (lambda ,alocs ,(normalize-tail tail)))]))

  (define (normalize-triv triv)
    triv)
  ;; value (nvalue -> nvalue) -> nvalue
  (define (normalize-value value [k identity])
    (match value
      [`(begin
          ,effects ...
          ,value2)
       (normalize-value value2
                        (λ (nvalue)
                          (join-begin
                             (map normalize-effect effects)
                              (k nvalue))))]
      [`(,binop ,triv1 ,triv2) (k `(,binop ,(normalize-triv triv1) ,(normalize-triv triv2)))]
      [`(if ,pred ,value1 ,value2)
       (normalize-value value1
                        (λ (nvalue1)
                          (normalize-value value2
                                           (λ (nvalue2)
                                             `(if ,(normalize-pred pred)
                                                  ,(k nvalue1)
                                                  ,(k nvalue2))))))]
      [triv (k (normalize-triv triv))]))
  (define (normalize-pred pred)
    (match pred
      [`(not ,pred) `(not ,(normalize-pred pred))]
      [`(begin
          ,fxs ...
          ,pred)
       `(begin
          ,@(map normalize-effect fxs)
          ,(normalize-pred pred))]
      [`(if ,pred1 ,pred2 ,pred3)
       `(if ,(normalize-pred pred1)
            ,(normalize-pred pred2)
            ,(normalize-pred pred3))]
      [_ pred]))
  (define (normalize-effect effect)
    (match effect
      ; need to convert value to triv or (binop triv triv) with begin isolated out
      [`(set! ,aloc ,value) (normalize-value value (λ (nvalue) `(set! ,aloc ,nvalue)))]
      [`(begin
          ,effects ...
          ,effect2)
       `(begin
          ,@(map normalize-effect effects)
          ,(normalize-effect effect2))]
      [`(if ,pred ,effect1 ,effect2)
       `(if ,(normalize-pred pred)
            ,(normalize-effect effect1)
            ,(normalize-effect effect2))]))

  (define (normalize-tail tail)
    (match tail
      [`(begin
          ,effects ...
          ,tail)
       `(begin
          ,@(map normalize-effect effects)
          ,(normalize-tail tail))]
      [`(,binop ,triv1 ,triv2) `(,binop ,(normalize-triv triv1) ,(normalize-triv triv2))]
      [`(if ,pred ,tail1 ,tail2)
       `(if ,(normalize-pred pred)
            ,(normalize-tail tail1)
            ,(normalize-tail tail2))]
      ;; nothing special happens
      [`(call ,_ ,_ ...) tail]
      [triv (normalize-triv triv)]))
  (define (normalize-p p)
    (match p
      [`(module ,definitions ...
          ,tail)
       `(module ,@(map normalize-definitions definitions) ,(normalize-tail tail)
       )]))

  (normalize-p mf))