#lang racket
(require cpsc411/compiler-lib
         cpsc411/langs/v9
         "common.rkt")

(provide convert-closures)

;; (Lam-free-lang-v9 p) -> (Closure-lang-v9 p)
;; Make closures explicit using free variable info
(define (convert-closures p)

  ;; value -> value
  (define (convert-value value)
    (match value
      [`(,primop ,values ...)
       #:when (primop? primop)
       (let ([values^ (map convert-value values)]) `(,primop ,@values^))]
      [`(unsafe-procedure-call ,func ,args ...)
       (let ([func^ (convert-value func)]
             [args^ (map convert-value args)])
         `(closure-call ,func^ ,func^ ,@args^))]
      [`(let ([,alocs ,values] ...) ,value-body)
       (let ([values^ (map convert-value values)]
             [body^ (convert-value value-body)])
         (let ([expr-updated (for/list ([aloc alocs]
                                        [value values^])
                               `(,aloc ,value))])
           `(let ,expr-updated ,body^)))]
      [`(letrec ([,rec-alocs (lambda ,infos
                               (,params ...)
                               ,bodies)] ...)
          ,value-body)
       (let-values ([(value-body^) (convert-value value-body)]
                    [(labels^ clet-bindings)
                     (map2 (λ (info params body rec-aloc)
                             ;; completely forgot about info-ref...
                             ;; too lazy to replace
                             (match info
                               [`((free (,frees ...)))
                                (let* ([label (fresh-label rec-aloc)]
                                       [clos-param (fresh 'c)]
                                       [free-bindings (for/list ([free frees]
                                                                 [i (in-naturals)])
                                                        `(,free (closure-ref ,clos-param ,i)))]
                                       [body^ (convert-value body)]
                                       [arity (length params)])
                                  (values `(,label (lambda (,clos-param ,@params)
                                                     (let ,free-bindings ,body^)))
                                          `(,rec-aloc (make-closure ,label ,arity ,@frees))))]))
                           infos
                           params
                           bodies
                           rec-alocs)])
         `(letrec ,labels^
            (cletrec ,clet-bindings ,value-body^)))]
      [`(if ,value1 ,value2 ,value3)
       `(if ,(convert-value value1)
            ,(convert-value value2)
            ,(convert-value value3))]
      [`(begin
          ,effects ...
          ,value)
       (let ([effects^ (map convert-effect effects)]
             [value^ (convert-value value)])
         `(begin
            ,@effects^
            ,value^))]
      [triv (convert-triv triv)]))

  (define (convert-effect effect)
    (match effect
      [`(,primop ,values ...)
       #:when (primop? primop)
       (let ([values^ (map convert-value values)]) `(,primop ,@values^))]
      [`(begin
          ,effects ...)
       (let ([effects^ (map convert-effect effects)])
         `(begin
            ,@effects^))]))

  (define (convert-triv triv)
    (match triv
      [_ triv]))

  (match p
    [`(module ,v) `(module ,(convert-value v))]))

(module+ test
  (require rackunit)
  (check-match (convert-closures `(module (let ([x.1 5]) (unsafe-fx+ x.1 1))))
               `(module (let ([x.1 5]) (unsafe-fx+ x.1 1))))

  (check-match (convert-closures `(module (letrec ([f.1 (lambda ((free ()))
                                                          (x.1)
                                                          x.1)])
                                            (unsafe-procedure-call f.1 5))))
               `(module (letrec ([,L.f.1.7 (lambda (,c.4 x.1) (let () x.1))])
                          (cletrec ((f.1 (make-closure ,L.f.1.7 1))) (closure-call f.1 f.1 5)))))

  (check-match
   (convert-closures `(module (let ([y.1 10])
                                (letrec ([f.1 (lambda ((free (y.1)))
                                                (x.1)
                                                (unsafe-fx+ x.1 y.1))])
                                  (unsafe-procedure-call f.1 5)))))
   `(module (let ([y.1 10])
              (letrec ([,L.f.1.7 (lambda (,c.4 x.1)
                                   (let ([y.1 (closure-ref ,c.4 0)]) (unsafe-fx+ x.1 y.1)))])
                (cletrec ((f.1 (make-closure ,L.f.1.7 1 y.1))) (closure-call f.1 f.1 5))))))

  (check-match (convert-closures `(module (let ([a.1 1]
                                                [b.1 2])
                                            (letrec ([f.1 (lambda ((free (a.1 b.1)))
                                                            (x.1)
                                                            (unsafe-fx+ (unsafe-fx+ x.1 a.1) b.1))])
                                              (unsafe-procedure-call f.1 10)))))
               `(module (let ([a.1 1]
                              [b.1 2])
                          (letrec ([,L.f.1.7 (lambda (,c.4 x.1)
                                               (let ([a.1 (closure-ref ,c.4 0)]
                                                     [b.1 (closure-ref ,c.4 1)])
                                                 (unsafe-fx+ (unsafe-fx+ x.1 a.1) b.1)))])
                            (cletrec ((f.1 (make-closure ,L.f.1.7 1 a.1 b.1)))
                                     (closure-call f.1 f.1 10))))))

  (check-match
   (convert-closures `(module (letrec ([f.1 (lambda ((free (g.2)))
                                              (x.1)
                                              (unsafe-procedure-call g.2 x.1))]
                                       [g.2 (lambda ((free (f.1)))
                                              (y.1)
                                              (unsafe-procedure-call f.1 y.1))])
                                (unsafe-procedure-call f.1 5))))
   `(module (letrec ([,L.f.1.7 (lambda (,c.4 x.1)
                                 (let ([g.2 (closure-ref ,c.4 0)]) (closure-call g.2 g.2 x.1)))]
                     [,L.g.2.8 (lambda (,c.5 y.1)
                                 (let ([f.1 (closure-ref ,c.5 0)]) (closure-call f.1 f.1 y.1)))])
              (cletrec ((f.1 (make-closure ,L.f.1.7 1 g.2)) (g.2 (make-closure ,L.g.2.8 1 f.1)))
                       (closure-call f.1 f.1 5))))))
