#lang racket
(require cpsc411/compiler-lib
         cpsc411/langs/v9
         "common.rkt")

(provide implement-closures)

;; (Hoisted-lang-v9 p) -> (Proc-exposed-lang-v9 p)
;; Implements closures in terms of the procedure data structure.
(define (implement-closures p)

  (define (closure->proc closure)
    (match closure
      [`(make-closure ,label ,arity ,env ...) `(make-procedure ,label ,arity ,(length env))]))

  (define (make-env aloc closure acc)
    (match closure
      [`(make-closure ,label ,arity ,env ...)
       (append
        acc
        (let-values ([(count inits)
                      (for/fold ([count 0]
                                 [inits empty])
                                ([e env])
                        (values (add1 count)
                                (cons `(unsafe-procedure-set! ,aloc ,count ,(implement-value e))
                                      inits)))])
          (reverse inits)))]))

  (define (implement-value value)
    (match value
      [`(closure-ref ,val1 ,val2)
       `(unsafe-procedure-ref ,(implement-value val1) ,(implement-value val2))]
      [`(closure-call ,val1 ,values ...)
       `(call (unsafe-procedure-label ,(implement-value val1)) ,@(map implement-value values))]
      [`(call ,val1 ,values ...) `(call ,(implement-value val1) ,@(map implement-value values))]
      [`(cletrec ([,alocs ,closures] ...) ,body-value)
       `(let ,(for/list ([aloc alocs]
                         [closure closures])
                `(,aloc ,(closure->proc closure)))
          ,(let ([inits (for/fold ([acc empty])
                                  ([aloc alocs]
                                   [closure closures])
                          (make-env aloc closure acc))])
             (if (empty? inits)
                 (implement-value body-value)
                 `(begin
                    ,@inits
                    ,(implement-value body-value)))))]
      [`(let ([,alocs ,vs] ...) ,body-value)
       `(let ,(for/list ([aloc alocs]
                         [val vs])
                `(,aloc ,(implement-value val)))
          ,(implement-value body-value))]
      [`(if ,val1 ,val2 ,val3)
       `(if ,(implement-value val1)
            ,(implement-value val2)
            ,(implement-value val3))]
      [`(begin
          ,effects ...
          ,val)
       `(begin
          ,@(map implement-effect effects)
          ,(implement-value val))]
      [`(,primop ,values ...)
       #:when (primop? primop)
       `(,primop ,@(map implement-value values))]
      [_ value]))

  (define (implement-effect effect)
    (match effect
      [`(begin
          ,effects ...
          ,effect)
       `(begin
          ,@(map implement-effect effects)
          ,(implement-effect effect))]
      [`(,primop ,values ...) `(,primop ,@(map implement-value values))]))

  (define (implement-def def)
    (match def
      [`(define ,label (lambda (,alocs ...) ,value))
       `(define ,label (lambda ,alocs ,(implement-value value)))]))

  (define (implement-p p)
    (match p
      [`(module ,defs ...
          ,value)
       `(module ,@(map implement-def defs) ,(implement-value value)
          )]))

  (implement-p p))
