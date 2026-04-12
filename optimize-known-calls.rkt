#lang racket
(require cpsc411/compiler-lib
         cpsc411/langs/v9
         "common.rkt")

(provide optimize-known-calls)

; (Closure-lang-v9 p) -> (Closure-lang-v9 p)
; Optimizes calls to known closures.
(define (optimize-known-calls p)

  (define (optimize-effect effect bindings)
    (match effect
      [`(begin
          ,effects ...)
       `(begin
          ,@(map (lambda (effect) (optimize-effect effect bindings)) effects))]
      [`(,primop ,values ...)
       `(,primop ,@(map (lambda (val) (optimize-value val bindings)) values))]))

  (define (optimize-value value bindings)
    (match value
      [`(closure-ref ,val1 ,val2)
       `(closure-ref ,(optimize-value val1 bindings) ,(optimize-value val2 bindings))]
      [`(closure-call ,val1 ,values ...)
       ;; if val1 is in bindings, then it is an aloc that maps to a label in bindings
       ;; hence we can directly call that label, skipping a memory lookup at runtime
       (if (dict-has-key? bindings val1)
           `(call ,(dict-ref bindings val1)
                  ,@(map (lambda (val) (optimize-value val bindings)) values))
           `(closure-call ,(optimize-value val1 bindings)
                          ,@(map (lambda (val) (optimize-value val bindings)) values)))]
      [`(call ,val1 ,values ...)
       `(call ,(optimize-value val1 bindings)
              ,@(map (lambda (val) (optimize-value val bindings)) values))]
      [`(letrec ([,labels ,fns] ...)
          (cletrec ([,alocs ,closures] ...) ,body-val))
       (let ([new-bindings (for/fold ([new-bindings bindings])
                                     ([aloc alocs]
                                      [closure closures])
                             (match closure
                               [`(make-closure ,label ,values ...)
                                (dict-set new-bindings aloc label)]))])
         `(letrec ,(for/list ([label labels]
                              [fn fns])
                     (match fn
                       [`(lambda (,alocs ...) ,body)
                        `(,label (lambda ,alocs ,(optimize-value body new-bindings)))]))
            (cletrec ,(for/list ([aloc alocs]
                                 [closure closures])
                        (match closure
                          [`(make-closure ,label ,values ...)
                           `(,aloc (make-closure ,label
                                                 ,@(map (lambda (val) (optimize-value val bindings))
                                                        values)))]))
                     ,(optimize-value body-val new-bindings))))]
      [`(letrec ([,labels ,fns] ...)
          ,body-val)
       `(letrec ,(for/list ([label labels]
                            [fn fns])
                   (match fn
                     [`(lambda (,alocs ...) ,body)
                      `(,label (lambda ,alocs ,(optimize-value body bindings)))]))
          ,(optimize-value body-val bindings))]
      [`(cletrec ([,alocs ,closures] ...) ,body-val)
       (let ([new-bindings (for/fold ([new-bindings bindings])
                                     ([aloc alocs]
                                      [closure closures])
                             (match closure
                               [`(make-closure ,label ,values ...)
                                (dict-set new-bindings aloc label)]))])
         `(cletrec ,(for/list ([aloc alocs]
                               [closure closures])
                      (match closure
                        [`(make-closure ,label ,values ...)
                         `(,aloc (make-closure ,label
                                               ,@(map (lambda (val) (optimize-value val bindings))
                                                      values)))]))
                   ,(optimize-value body-val new-bindings)))]
      [`(let ([,alocs ,vals] ...) ,body-value)
       `(let ,(for/list ([aloc alocs]
                         [val vals])
                `(,aloc ,(optimize-value val bindings)))
          ,(optimize-value body-value bindings))]
      [`(if ,val1 ,val2 ,val3)
       `(if ,(optimize-value val1 bindings)
            ,(optimize-value val2 bindings)
            ,(optimize-value val3 bindings))]
      [`(begin
          ,effects ...
          ,val)
       `(begin
          ,@(map (lambda (e) (optimize-effect e bindings)) effects)
          ,(optimize-value val bindings))]
      [`(,primop ,values ...)
       #:when (primop? primop)
       `(,primop ,@(map (lambda (val) (optimize-value val bindings)) values))]
      [_ value]))

  (define (optimize-p p)
    (match p
      [`(module ,value) `(module ,(optimize-value value '()))]))

  (optimize-p p))
