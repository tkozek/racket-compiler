#lang racket

(require cpsc411/compiler-lib)
(provide sequentialize-let
         interp-values-unique-lang)

(define (binop? op)
  (or (equal? op '+) (equal? op '*)))

(define (binop->fun op)
  (match op
    ['+ x64-add]
    ['* x64-mul]))
(define triv? (or/c aloc? int64?))
; values-unique lang-v3
; p	 	::=	 	(module (define label (lambda (aloc ...) tail)) ... tail)
;   pred	 	::=	 	(relop opand opand)
;  	 	|	 	(true) | (false) | (not pred)
;  	 	|	 	(let ([aloc value] ...) pred)
;  	 	|	 	(if pred pred pred)
;   tail	 	::=	 	value
;  	 	|	 	(let ([aloc value] ...) tail)
;  	 	|	 	(if pred tail tail)
;  	 	|	 	(call triv opand ...)
;   value	 	::=	 	triv | (binop opand opand) | (let ([aloc value] ...) value)
;  	 	|	 	(if pred value value)
;   opand	 	::=	 	int64 |	aloc
;   triv	 	::=	 	opand |	 label
;   binop	 	::=	 	* |	 +
;   relop	 	::=	 	< | <= | = | >= | > | !=
;   aloc	 	::=	 	aloc?
;   label	 	::=	 	label?
;   int64	 	::=	 	int64?

(define (interp-values-unique-lang vlu)
  (define (interp-triv triv env)
    (match triv
      [(? aloc?) (dict-ref env triv)]
      [(? int64?) triv]))
  (define (interp-tail tail env)
    (match tail
      [`(let ([,alocs ,vals] ...) ,tail2)
       (interp-tail tail2
                    (foldl (λ (aloc val env) (dict-set env aloc val))
                           env
                           alocs
                           (map (λ (val) (interp-tail val env)) vals)))]
      [`(,(? binop? binop) ,(? triv? triv) ,(? triv? triv2))
       ((binop->fun binop) (interp-triv triv env) (interp-triv triv2 env))]
      [(? triv?) (interp-triv tail env)]))
  (let _ ([p vlu]
          [env '()])
    (match p
      [`(module ,tail) (interp-tail tail env)])))
;-----------------------------
; imp-mf-lang-v5
; p	 	::=
; (module (define label (lambda (aloc ...) tail)) ...
;         tail)
;   pred	 	::=	 	(relop opand opand) | (true) | (false) | (not pred) | (begin effect ... pred)
;  	 	|	 	(if pred pred pred)
;   tail	 	::=	 	value  | (call triv opand ...) | (begin effect ... tail) | (if pred tail tail)
;   value	 	::=	 	triv | (binop opand opand) | (begin effect ... value) |	(if pred value value)
;   effect	 	::=	 	(set! aloc value) | (begin effect ... effect) | (if pred effect effect)
;   opand	 	::=	 	int64 | aloc
;   triv	 	::=	 	opand | label
;   binop	 	::=	 	* | +
;   relop	 	::=	 	< | <= | = | >= | > | !=
;   aloc	 	::=	 	aloc?
;   label	 	::=	 	label?
;   int64	 	::=	 	int64?

; values-unique-lang-v5 -> imp-mf-lang-v5
(define (sequentialize-let vulv5)

  (define (wrap-begin tail*)
    (if (= 1 (length tail*))
        (first tail*)
        `(begin
           ,@tail*)))

  ;; I dont know how to use the info-ref lmao
  (define (seq-let-definitions definition)
    (match definition
      [`(define ,label (lambda ,alocs ,tail))
       (seq-let-tail tail
                     (λ (tail*)
                       `(define ,label
                          (lambda ,alocs
                            ,@(if (= 1 (length tail*))
                                  tail*
                                  (list `(begin
                                           ,@tail*)))))))]))

  ;; let assignment be (list values-unique-lang-v4-aloc values-unique-lang-v4-value)
  ;; let k be continuation (imp-mf-lang-v4-effect ... imp-mf-lang-v4-tail) -> imp-mf-lang-v4-tail)
  (define (seq-let-assignment* a* k)
    (if (empty? a*)
        (k '())
        (seq-let-assignment
         (first a*)
         (λ (tail*) (seq-let-assignment* (rest a*) (λ (tail*2) (k (append tail* tail*2))))))))

  (define (seq-let-assignment a k)
    (match a
      [`(,aloc ,val)
       (seq-let-tail val
                     (λ (tail*)
                       (k (append (remove (last tail*) tail*) `((set! ,aloc ,(last tail*)))))))]))
  (define (seq-let-pred pred k)
    (match pred
      [`(not ,p)
       (seq-let-pred p (λ (p*) (k (append (remove (last p*) p*) (list `(not ,(last p*)))))))]
      [`(if ,p1 ,p2 ,p3)
       (seq-let-pred
        p1
        (λ (p1-effects)
          (seq-let-pred p2
                        (λ (p2-effects)
                          (seq-let-pred p3
                                        (λ (p3-effects)
                                          (k (list `(if ,(wrap-begin p1-effects)
                                                        ,(wrap-begin p2-effects)
                                                        ,(wrap-begin p3-effects))))))))))]
      [`(let (,as ...) ,p)
       (seq-let-assignment* as (λ (a*) (seq-let-pred p (λ (p*) (k (append a* p*))))))]
      [_ (k (list pred))]))

  (define (seq-let-tail tail k)
    (match tail
      [`(let (,assignments ...) ,tail2)
       (seq-let-assignment* assignments
                            (λ (tail*) (seq-let-tail tail2 (λ (tail*2) (k (append tail* tail*2))))))]
      [`(if ,p ,t1 ,t2)
       (seq-let-pred
        p
        (λ (pred-effects)
          (seq-let-tail t1
                        (λ (t1-effects)
                          (seq-let-tail t2
                                        (λ (t2-effects)
                                          (k (list `(if ,(wrap-begin pred-effects)
                                                        ,(wrap-begin t1-effects)
                                                        ,(wrap-begin t2-effects))))))))))]
      [_ (k (list tail))]))

  (define (seq-let-p p)
    (match p
      [`(module ,definitions ...
          ,tail)
       (seq-let-tail tail
                     (λ (tail*)
                       (append `(module)
                               (map seq-let-definitions definitions)
                               (list (if (= 1 (length tail*))
                                         (first tail*)
                                         `(begin
                                            ,@tail*))))))]))
  (seq-let-p vulv5))
