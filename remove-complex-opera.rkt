#lang racket

(require cpsc411/compiler-lib
         "common.rkt")

(provide remove-complex-opera*)



;; exprs-bits-lang-v7 p -> values-bits-lang-v7 p
;; Performs the monadic form transformation, 
;; unnesting all non-trivial operators and operands to binops, 
;; calls, and relopss, making data flow explicit and simple to implement imperatively.

(define (remove-complex-opera* p)

  (define (rco-def def)
    (match def
      [`(define ,label (lambda ,alocs ... ,tail))
       `(define ,label (lambda ,@alocs
                     ,(rco-tail tail)))]))

  (define (rco-pred pred)
    (match pred
      [`(true) pred]
      [`(false) pred]

      [`(not ,pred)
       `(not ,(rco-pred pred))]
      [`(let ([,alocs ,values] ...) ,pred)
       `(let ,(for/list ([aloc alocs] [value values])
                `(,aloc ,(rco-value value)))
          ,(rco-pred pred))]
      [`(if ,pred1 ,pred2 ,pred3)
       `(if ,(rco-pred pred1)
            ,(rco-pred pred2)
            ,(rco-pred pred3))]
      [`(,relop ,value1 ,value2)
       (rco-triv value1
         (λ (opand1)
           (rco-triv value2
             (λ (opand2)
               `(,relop ,opand1 ,opand2)))))]))

  (define (rco-tail tail)
    (match tail
      [`(call ,label ,opands ...)
       (rco-triv label
         (λ (label^)
           (rco-trivs opands
             (λ (opands^)
               `(call ,label^ ,@opands^)))))]
      [`(let ([,alocs ,values] ...) ,tail)
       `(let ,(for/list ([aloc alocs] [value values])
                `(,aloc ,(rco-value value)))
          ,(rco-tail tail))]
      [`(if ,pred ,tail1 ,tail2)
       `(if ,(rco-pred pred)
            ,(rco-tail tail1)
            ,(rco-tail tail2))]
      [value (rco-value value)]))

  (define (rco-value value)
    (match value
      [`(,binop ,value1 ,value2)
       (rco-triv value1
         (λ (value1^)
           (rco-triv value2
             (λ (value2^)
               `(,binop ,value1^ ,value2^)))))]
      [`(call ,label ,opands ...)
       (rco-triv label
         (λ (label^)
           (rco-trivs opands
             (λ (opands^)
               `(call ,label^ ,@opands^)))))]
      [`(let ([,alocs ,values] ...) ,value-body)
       `(let ,(for/list ([aloc alocs] [value values])
                `(,aloc ,(rco-value value)))
          ,(rco-value value-body))]
      [`(if ,pred ,value1 ,value2)
       `(if ,(rco-pred pred)
            ,(rco-value value1)
            ,(rco-value value2))]
      [triv (rco-triv triv)]))

  ;; for/list but with continuations
  (define (rco-trivs trivs k)
    (if (null? trivs)
        (k '())
        (rco-triv (car trivs)
          (λ (triv^)
            (rco-trivs (cdr trivs)
              (λ (rest)
                (k (cons triv^ rest))))))))
  
  (define (rco-triv triv [k identity])
    (match triv
      [(? int64?) (k triv)]
      [(? aloc?) (k triv)]
      [(? label?) (k triv)]
      [_ 
       (let ([fresh-aloc (fresh)])
         `(let ([,fresh-aloc ,(rco-value triv)])
            ,(k fresh-aloc)))]))

  (match p
    [`(module ,defs ... ,tail)
     `(module ,@(map rco-def defs)
        ,(rco-tail tail))]))

#;
(module+ test
  (require rackunit
           cpsc411/langs/v7)
  (check-match (remove-complex-opera* '(module (define L.<=.2
                            (lambda (tmp.10 tmp.11)
                              (if (!= (if (= (bitwise-and tmp.11 7) 0) 14 6) 6)
                                  (if (!= (if (= (bitwise-and tmp.10 7) 0) 14 6) 6)
                                      (if (<= tmp.10 tmp.11) 14 6)
                                      1342)
                                  1342)))
                          (define L.tmp.0.1 (lambda (foo.9.1) 14))
                    (call L.<=.2 0 0)))
`(module
  (define L.<=.2
    (lambda (tmp.10 tmp.11)
      (if (let ((tmp.1
                 (if (let ((tmp.2 (bitwise-and tmp.11 7))) (= tmp.2 0)) 14 6)))
            (!= tmp.1 6))
        (if (let ((tmp.3
                   (if (let ((tmp.4 (bitwise-and tmp.10 7))) (= tmp.4 0))
                     14
                     6)))
              (!= tmp.3 6))
          (if (<= tmp.10 tmp.11) 14 6)
          1342)
        1342)))
  (define L.tmp.0.1 (lambda (foo.9.1) 14))
  (call L.<=.2 0 0)))

  (check-match (remove-complex-opera* '(module (define L.error?.1
                            (lambda (tmp.22) (if (= (bitwise-and tmp.22 255) 62) 14 6)))
                          (call L.error?.1 30)
                    ))
            `(module
  (define L.error?.1
    (lambda (tmp.22)
      (if (let ((tmp.1 (bitwise-and tmp.22 255))) (= tmp.1 62)) 14 6)))
  (call L.error?.1 30)) )


 (check-match (remove-complex-opera* `(module (* x.1 (arithmetic-shift-right opand2.6 3))))
  `(module (let ((tmp.1 (arithmetic-shift-right opand2.6 3))) (* x.1 tmp.1)))
 
 )

 (check-match (remove-complex-opera* `(module (let ([x.2 (* x.1 (arithmetic-shift-right opand2.6 3))]) x.2)))
 `(module
  (let ((x.2
         (let ((tmp.1 (arithmetic-shift-right opand2.6 3))) (* x.1 tmp.1))))
    x.2)))
)