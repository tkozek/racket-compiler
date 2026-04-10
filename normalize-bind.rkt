#lang racket

(require cpsc411/compiler-lib)

(provide normalize-bind
         interp-imp-mf-lang)

(define (binop? op)
  (or (equal? op '+) (equal? op '*)))

(define (binop->fun op)
  (match op
    ['+ x64-add]
    ['* x64-mul]))
(define triv? (or/c aloc? int64?))

; imp-mf-lang-v3
; p	 	::=	 	(module tail)

; tail	 	::=	 	value
;  	|	 	(begin effect ... tail)

; value	 	::=	 	triv
;  	|	 	(binop triv triv)
;  	|	 	(begin effect ... value)

; effect	 	::=	 	(set! aloc value)
;  	|	 	(begin effect ... effect)

; triv	 	::=	 	int64
;  	|	 	aloc

; binop	 	::=	 	*
;  	|	 	+

; aloc	 	::=	 	aloc?

; int64	 	::=	 	int64?
(define (interp-imp-mf-lang iml)
  (define env (make-hash))
  (define (interp-triv triv)
    (match triv
      [(? int64?) triv]
      [(? aloc?) (hash-ref env triv)]))
  (define (interp-effect fx)
    (match fx
      [`(set! ,a ,val)
       #:when (aloc? a)
       (hash-set! env a (interp-value val))]
      [`(begin
          ,fxs ...
          ,fx)
       (for-each interp-effect fxs)
       (interp-effect fx)]))
  (define (interp-value val)
    (match val
      [`(begin
          ,fxs ...
          ,val)
       (for-each interp-effect fxs)
       (interp-value val)]
      [`(,(? binop? binop) ,(? triv? triv) ,(? triv? triv2))
       ((binop->fun binop) (interp-triv triv) (interp-triv triv2))]
      [(? triv?) (interp-triv val)]))
  (define (interp-tail tail)
    (match tail
      [`(begin
          ,fxs ...
          ,tail)
       (for-each interp-effect fxs)
       (interp-tail tail)]
      [_ (interp-value tail)]))
  (match iml
    [`(module ,tail) (interp-tail tail)]))
; --------------------
; Imp-cmf-lang-v3
; p	 	::=	 	(module tail)

; tail	 	::=	 	value
;  	|	 	(begin effect ... tail)

; value	 	::=	 	triv
;  	|	 	(binop triv triv)

; effect	 	::=	 	(set! aloc value)
;  	|	 	(begin effect ... effect)

; triv	 	::=	 	int64
;  	|	 	aloc

; binop	 	::=	 	*
;  	|	 	+

; aloc	 	::=	 	aloc?

; int64	 	::=	 	int64?

; imp-mf-lang-v4 -> imp-cmf-lang-v4
;; converts all `(set! aloc (begin ... val)) to `(begin ... (set! aloc val))
(define (normalize-bind mf)

  (define (normalize-definitions definition)
    (match definition
      [`(define ,label (lambda ,alocs ,tail))
       `(define ,label (lambda ,alocs ,(normalize-tail tail)))]))

  (define (normalize-triv triv)
    triv)

  (define (normalize-value value [k identity])
    (match value
      [`(begin
          ,effects ...
          ,value2)
       (normalize-value value2
                        (λ (nvalue)
                          `(begin
                             ,@(map normalize-effect effects)
                             ,(k nvalue))))]
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
  ;; NOTE: tail = value in imp-mf-lang-v3
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
      [`(call ,triv ,opand ...) tail]
      [triv (normalize-triv triv)]))
  (define (normalize-p p)
    (match p
      [`(module ,definitions ...
          ,tail)
       (append `(module) (map normalize-definitions definitions) (list (normalize-tail tail)))]))

  (normalize-p mf))
