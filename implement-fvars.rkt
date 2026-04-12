#lang racket
(require cpsc411/compiler-lib
         "common.rkt")
(provide implement-fvars)

;; (Nested-asm-lang-fvars-v8 p) -> (Nested-asm-lang-v8 p)
;; Reifies fvars into displacement mode operands
(define (implement-fvars p)
  (define loc? (or/c register? fvar?))
  (define opand? (or/c int64? loc?))
  (define triv? (or/c opand? label?))

  (define curr-offset-nbytes 0)
  ; p	 	::=	 	(module (define label tail) ... tail)
  ;; EFFECT: changes curr-offset-nword
  (define (implement-p! p)
    (match p
      [`(module ,def* ...
          ,tail)
       `(module ,@(map implement-def! def*)
                ,(begin
                   (set! curr-offset-nbytes 0)
                   (implement-tail! tail))
          )]))
  ;; EFFECT: changes curr-offset-nword
  (define (implement-def! def)
    (set! curr-offset-nbytes 0)
    (match def
      [`(define ,label ,tail) `(define ,label ,(implement-tail! tail))]))
  ; tail	 	::=	 	(jump trg)
  ;  	|	 	(begin effect ... tail)
  ;  	|	 	(if pred tail tail)
  ;; EFFECT: may change curr-offset-nword
  (define (implement-tail! tail)
    (match tail
      [`(if ,pred ,tail1 ,tail2)
       `(if ,(implement-pred! pred)
            ,(implement-tail! tail1)
            ,(implement-tail! tail2))]
      [`(begin
          ,fx* ...
          ,tail)
       (make-begin (map implement-effect! fx*) (implement-tail! tail))]
      [`(jump ,trg) `(jump ,(implement-trg trg))]))
  ; pred	 	::=	 	(relop loc opand)
  ;  	|	 	(true)
  ;  	|	 	(false)
  ;  	|	 	(not pred)
  ;  	|	 	(begin effect ... pred)
  ;  	|	 	(if pred pred pred)
  ;; EFFECT: may change curr-offset-nword
  (define (implement-pred! pred)
    (match pred
      [`(if ,pred0 ,pred1 ,pred2)
       `(if ,(implement-pred! pred0)
            ,(implement-pred! pred1)
            ,(implement-pred! pred2))]
      [`(begin
          ,fx* ...
          ,pred0)
       `(begin
          ,@(map implement-effect! fx*)
          ,(implement-pred! pred0))]
      [`(not ,pred0) `(not ,(implement-pred! pred0))]
      [`(,relop ,loc ,opand) `(,relop ,(implement-loc loc) ,(implement-opand opand))]
      ; (true) and (false)
      [_ pred]))
  ; effect	 	::=	 	(set! loc triv)
  ;  	|	 	(set! loc_1 (binop loc_1 opand))
  ;  	|	 	(begin effect ... effect)
  ;  	|	 	(if pred effect effect)
  ;  	|	 	(return-point label tail)
  ;; EFFECT: may change curr-offset-nword
  (define (implement-effect! fx)
    (match fx
      ;; opand and index are same
      [`(mset! ,loc ,index ,triv)
       `(set! ,(implement-loc loc) ,(implement-opand index) ,(implement-triv triv))]
      [`(set! ,loc1 (mref ,loc2 ,index))
       `(set! ,(implement-loc loc1) (mref ,(implement-loc loc2) ,(implement-opand index)))]
      [`(set! ,loc ,(? triv? triv)) `(set! ,(implement-loc loc) ,(implement-triv triv))]
      [`(set! ,loc (,binop ,loc ,opand))
       (define trg-loc (implement-loc loc))
       (define trg-opand (implement-opand opand))
       (when (eq? trg-loc (current-frame-base-pointer-register))
         (if (not (int64? trg-opand))
             (error (format "Unsupported offset ~a, we support int64 offset only as of v6" trg-opand))
             (set! curr-offset-nbytes ((binop->fun binop) curr-offset-nbytes trg-opand))))
       `(set! ,trg-loc (,binop ,trg-loc ,(implement-opand opand)))]
      ; hacky but should work
      [`(begin
          ,fx+ ...)
       #:when (not (empty? fx+))
       (make-begin-effect (map implement-effect! fx+))]
      [`(if ,pred ,fx1 ,fx2)
       `(if ,(implement-pred! pred)
            ,(implement-effect! fx1)
            ,(implement-effect! fx2))]
      [`(return-point ,label ,tail) `(return-point ,label ,(implement-tail! tail))]))
  ; trg	 	::=	 	label
  ;  	|	 	loc
  (define (implement-trg trg)
    (match trg
      [(? label?) trg]
      [(? loc?) (implement-loc trg)]))
  ; opand	 	::=	 	int64
  ;  	|	 	loc
  (define (implement-opand opand)
    (match opand
      [(? int64?) opand]
      [(? loc?) (implement-loc opand)]))
  ; triv	 	::=	 	opand
  ;  	|	 	label
  (define (implement-triv triv)
    (match triv
      [(? opand?) (implement-opand triv)]
      [(? label?) triv]))
  (define (implement-loc loc)
    (match loc
      [(? register?) loc]
      [(? fvar?) (implement-fvar loc)]))
  ; fvar -> addr
  (define (implement-fvar fvar)
    `(,(current-frame-base-pointer-register) -
                                             ,(+ (* (current-word-size-bytes) (fvar->index fvar))
                                                 curr-offset-nbytes)))
  (implement-p! p))

(module+ test
  (require rackunit
           cpsc411/langs/v6)
  (define (peek x)
    ; (pretty-display x)
    x)
  (define-syntax-rule (check-by-interp p)
    (check-equal? (interp-nested-asm-lang-fvars-v6 p)
                  (interp-nested-asm-lang-v6 (implement-fvars p)))))
