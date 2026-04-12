#lang racket

(require cpsc411/compiler-lib
         "common.rkt")
(provide sequentialize-let)

(define triv? (or/c aloc? label?))
(define opand? (or/c aloc? int64?))

;; aloc value -> `(set! ,aloc ,value)
(define (make-fx aloc value)
  `(set! ,aloc ,value))

;; (Values-bits-lang v8 p) -> (Imp-mf-lang v8 p)
;; Compiles Values-unique-lang v8 to Imp-mf-lang v8 by picking a particular
;; order to implement let expressions using set!.
(define (sequentialize-let p)
  (define (make-fx+ aloc value)
    (make-fx aloc (seq-let-value value)))
  (define (seq-let-effect fx)
    (match fx
      [`(let ([,aloc* ,val*] ...) ,fx) (make-begin (map make-fx+ aloc* val*) (seq-let-effect fx))]
      [`(begin
          ,fx* ...
          ,fx)
       (make-begin-effect (map seq-let-effect `(,@fx* ,fx)))]
      [_ fx]))
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
      [`(begin
          ,fx* ...
          ,pred)
       (make-begin (map seq-let-effect fx*) (seq-let-pred pred))]
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
      [`(begin
          ,fx* ...
          ,value)
       (make-begin (map seq-let-effect fx*) (seq-let-value value))]
      [_ val]))
  (define (seq-let-tail tail)
    (match tail
      [`(let ([,aloc* ,val*] ...) ,tail0) (make-begin (map make-fx+ aloc* val*) (seq-let-tail tail0))]
      [`(if ,pred ,tail1 ,tail2)
       `(if ,(seq-let-pred pred)
            ,(seq-let-tail tail1)
            ,(seq-let-tail tail2))]
      [`(begin
          ,fx* ...
          ,tail)
       (make-begin (map seq-let-effect fx*) (seq-let-tail tail))]
      ;; (call triv opand ...) exists for both langs despite showing on the diff
      [_ tail]))
  (define (seq-let-p p)
    (match p
      [`(module ,def* ...
          ,tail)
       `(module ,@(map seq-let-def def*) ,(seq-let-tail tail)
          )]))
  (seq-let-p p))

(module+ test
  (require rackunit)
  (define (peek v [comment ""])
    ; (displayln comment)
    ; (pretty-display v)
    v)

  (define (peek/pretty v [comment ""])
    (peek (pretty-format v) comment)))
