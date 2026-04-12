#lang racket
(require cpsc411/compiler-lib
         cpsc411/langs/v9
         "common.rkt")

(provide hoist-lambdas)

; (Closure-lang-v9 p) -> (Hoisted-lang-v9 p)
; Hoists code to the top-level definitions.
(define (hoist-lambdas p)

  ;; shared state to accumulate definitions
  (define defs '())

  (define (hoist-effect effect)
    (match effect
      [`(begin
          ,effects ...)
       `(begin
          ,@(map hoist-effect effects))]
      [`(,primop ,values ...) `(,primop ,@(map hoist-value values))]))

  (define (hoist-value value)
    (match value
      [`(closure-ref ,val1 ,val2) `(closure-ref ,(hoist-value val1) ,(hoist-value val2))]
      [`(closure-call ,values ...) `(closure-call ,@(map hoist-value values))]
      [`(call ,values ...) `(call ,@(map hoist-value values))]
      [`(letrec ([,labels ,fns] ...)
          ,body-value)
       ;; move ,labels and ,fns to top level global state
       ;; we use for-each since this pass removes letrec, so we only care about the effects
       (for-each (lambda (label fn)
                   (match fn
                     [`(lambda (,alocs ...) ,body)
                      (set! defs
                            (append defs `((define ,label (lambda ,alocs ,(hoist-value body))))))]))
                 labels
                 fns)
       (hoist-value body-value)]
      [`(cletrec ([,alocs ,closures] ...) ,body-value)
       `(cletrec ,(for/list ([aloc alocs]
                             [closure closures])
                    (match closure
                      [`(make-closure ,label ,values ...)
                       `(,aloc (make-closure ,label ,@(map hoist-value values)))]))
                 ,(hoist-value body-value))]
      [`(let ([,alocs ,vals] ...) ,body-value)
       `(let ,(for/list ([aloc alocs]
                         [val vals])
                `(,aloc ,(hoist-value val)))
          ,(hoist-value body-value))]
      [`(if ,val1 ,val2 ,val3)
       `(if ,(hoist-value val1)
            ,(hoist-value val2)
            ,(hoist-value val3))]
      [`(begin
          ,effects ...
          ,value)
       `(begin
          ,@(map hoist-effect effects)
          ,(hoist-value value))]
      [`(,primop ,values ...)
       #:when (primop? primop)
       `(,primop ,@(map hoist-value values))]
      [_ value]))

  (define (hoist-p p)
    (match p
      [`(module ,value)
       ;; call first to accumulate defines in mutable shared state,
       ;; then add those defines to the output
       (define hoisted-program (hoist-value value))
       `(module ,@defs ,hoisted-program
          )]))

  (hoist-p p))
