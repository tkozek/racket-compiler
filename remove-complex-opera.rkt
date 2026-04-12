#lang racket

(require cpsc411/compiler-lib
         "common.rkt")

(provide remove-complex-opera*)

;; (Exprs-bits-lang-v8 p) -> (Values-bits-lang-v8 p)
;; Performs the monadic form transformation,
;; unnesting all non-trivial operators and operands to binops,
;; calls, and relopss, making data flow explicit and simple to implement imperatively.
(define (remove-complex-opera* p)

  (define (rco-def def)
    (match def
      [`(define ,label
          (lambda ,alocs
            ...
            ,tail))
       `(define ,label (lambda ,@alocs ,(rco-tail tail)))]))

  (define (rco-pred pred)
    (match pred
      [`(true) pred]
      [`(false) pred]
      [`(not ,pred) `(not ,(rco-pred pred))]
      [`(let ([,alocs ,values] ...) ,pred)
       `(let ,(for/list ([aloc alocs]
                         [value values])
                `(,aloc ,(rco-value value)))
          ,(rco-pred pred))]
      [`(if ,pred1 ,pred2 ,pred3)
       `(if ,(rco-pred pred1)
            ,(rco-pred pred2)
            ,(rco-pred pred3))]
      [`(,relop ,value1 ,value2)
       (rco-triv value1 (λ (opand1) (rco-triv value2 (λ (opand2) `(,relop ,opand1 ,opand2)))))]
      [`(begin
          ,effects ...
          ,pred)
       `(begin
          ,@(map rco-effect effects)
          ,(rco-pred pred))]))

  (define (rco-tail tail)
    (match tail
      [`(call ,label ,opands ...)
       (rco-triv label (λ (label^) (rco-trivs opands (λ (opands^) `(call ,label^ ,@opands^)))))]
      [`(begin
          ,effects ...
          ,tail)
       `(begin
          ,@(map rco-effect effects)
          ,(rco-tail tail))]
      [`(let ([,alocs ,values] ...) ,tail)
       `(let ,(for/list ([aloc alocs]
                         [value values])
                `(,aloc ,(rco-value value)))
          ,(rco-tail tail))]
      [`(if ,pred ,tail1 ,tail2)
       `(if ,(rco-pred pred)
            ,(rco-tail tail1)
            ,(rco-tail tail2))]
      [value (rco-value value)]))

  (define (rco-effect effect)
    (match effect
      [`(mset! ,value1 ,value2 ,value3)
       (rco-triv value1
                 (λ (value1^) (rco-triv value2 (λ (value2^) `(mset! ,value1^ ,value2^ ,value3)))))]
      [`(begin
          ,effects ...
          ,last)
       `(begin
          ,@(map rco-effect effects)
          ,(rco-effect last))]
      [`(let ([,alocs ,values] ...) ,effect)
       `(let ,(for/list ([aloc alocs]
                         [value values])
                `[,aloc ,(rco-value value)])
          ,(rco-effect effect))]))

  (define (rco-value value)
    (match value
      [`(call ,label ,opands ...)
       (rco-triv label (λ (label^) (rco-trivs opands (λ (opands^) `(call ,label^ ,@opands^)))))]
      [`(begin
          ,effects ...
          ,value)
       `(begin
          ,@(map rco-effect effects)
          ,(rco-value value))]
      [`(let ([,alocs ,values] ...) ,value-body)
       `(let ,(for/list ([aloc alocs]
                         [value values])
                `[,aloc ,(rco-value value)])
          ,(rco-value value-body))]
      [`(alloc ,value) (rco-triv value (λ (value^) `(alloc ,value^)))]
      [`(mref ,value1 ,value2)
       (rco-triv value1 (λ (value1^) (rco-triv value2 (λ (value2^) `(mref ,value1^ ,value2^)))))]
      [`(,binop ,value1 ,value2)
       (rco-triv value1 (λ (value1^) (rco-triv value2 (λ (value2^) `(,binop ,value1^ ,value2^)))))]
      [`(if ,pred ,value1 ,value2)
       `(if ,(rco-pred pred)
            ,(rco-value value1)
            ,(rco-value value2))]
      [triv (rco-triv triv)]))

  ;; for/list but with continuations
  (define (rco-trivs trivs k)
    (if (null? trivs)
        (k '())
        (rco-triv (car trivs) (λ (triv^) (rco-trivs (cdr trivs) (λ (rest) (k (cons triv^ rest))))))))

  (define (rco-triv triv [k identity])
    (match triv
      [(? int64?) (k triv)]
      [(? aloc?) (k triv)]
      [(? label?) (k triv)]
      [_ (let ([fresh-aloc (fresh)]) `(let ([,fresh-aloc ,(rco-value triv)]) ,(k fresh-aloc)))]))

  (match p
    [`(module ,defs ...
        ,tail)
     `(module ,@(map rco-def defs) ,(rco-tail tail)
        )]))

(module+ test
  (require rackunit
           cpsc411/langs/v8)
  (check-match (remove-complex-opera* '(module (mref (+ 1 2) (+ 3 4))))
               `(module (let ([,t1 (+ 1 2)]) (let ([,t2 (+ 3 4)]) (mref ,t1 ,t2)))))

  (check-match (remove-complex-opera* '(module (alloc (+ 1 2))))
               `(module (let ([,t1 (+ 1 2)]) (alloc ,t1))))

  (check-match (remove-complex-opera* '(module (begin
                                                 (mset! (+ 1 2) (+ 3 4) (+ 5 6))
                                                 0)))
               `(module (begin
                          (let ([,tmp.1 (+ 1 2)])
                            (let ([,tmp.2 (+ 3 4)]) (mset! ,tmp.1 ,tmp.2 (+ 5 6))))
                          0)))

  (check-match (remove-complex-opera* '(module (begin
                                                 (mset! 1 2 3)
                                                 (+ 4 5))))
               `(module (begin
                          (mset! 1 2 3)
                          (+ 4 5))))

  ;; interrogator the goat
  (check-match (remove-complex-opera* '(module (mref (alloc (+ 1 2)) (+ 3 4))))
               `(module (let ([,tmp.1 (let ([,tmp.2 (+ 1 2)]) (alloc ,tmp.2))])
                          (let ([,tmp.3 (+ 3 4)]) (mref ,tmp.1 ,tmp.3))))))
