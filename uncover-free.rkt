#lang racket

(require cpsc411/compiler-lib
         "common.rkt")

(provide uncover-free)

;; (Lam-opticon-lang-v9 p) -> (Lam-free-lang-v9 p)
;; Explicitly annotate procedures with their free variable sets.
(define (uncover-free p)

  ;; value -> (values value (setof aloc))
  (define (uncover-value value bound)
    (match value
      [`(,primop ,myvalues ...)
       #:when (primop? primop)
       (let-values ([(values^ frees) (map2 (λ (value) (uncover-value value bound)) myvalues)])
         (values `(,primop ,@values^) (apply set-union frees)))]

      [`(unsafe-procedure-call ,myvalues ...)
       (let-values ([(values^ frees) (map2 (λ (value) (uncover-value value bound)) myvalues)])
         (values `(unsafe-procedure-call ,@values^) (apply set-union frees)))]

      [`(let ([,alocs ,myvalues] ...) ,value-body)
       (let-values
           ([(values^ values-free) (map2 (lambda (value) (uncover-value value bound)) myvalues)]
            [(value-body^ body-free) (uncover-value value-body (set-union (apply set alocs) bound))])
         ;; definitely an easier way to do this that I'm forgetting
         (let ([expr-updated (for/list ([aloc alocs]
                                        [value values^])
                               `(,aloc ,value))])
           (values `(let ,expr-updated ,value-body^)
                   (set-subtract (set-union (apply set-union values-free) body-free)
                                 (apply set alocs)))))]

      [`(letrec ([,rec-alocs (lambda (,params ...) ,bodies)] ...)
          ,value-body)
       (let-values ([(lams-updated^ lam-frees)
                     (map2 (λ (params body)
                             (let ([params-set (apply set params)])
                               (let-values ([(body^ body-free)
                                             (uncover-value body (set-union params-set bound))])
                                 (let ([body-free^ (set-subtract body-free params-set)])
                                   (values `(lambda ((free ,(set->list body-free^)))
                                              ,params
                                              ,body^)
                                           body-free^)))))
                           params
                           bodies)]
                    [(value-body^ body-free) (uncover-value value-body
                                                            (set-union (apply set rec-alocs) bound))])
         (let ([expr-updated (for/list ([rec-aloc rec-alocs]
                                        [lam-updated lams-updated^])
                               `(,rec-aloc ,lam-updated))])
           (values `(letrec ,expr-updated
                      ,value-body^)
                   (set-subtract (set-union (apply set-union lam-frees) body-free)
                                 (apply set rec-alocs)))))]
      [`(if ,value1 ,value2 ,value3)
       (let-values ([(value1^ free1) (uncover-value value1 bound)]
                    [(value2^ free2) (uncover-value value2 bound)]
                    [(value3^ free3) (uncover-value value3 bound)])
         (values `(if ,value1^ ,value2^ ,value3^) (set-union free1 free2 free3)))]
      [`(begin
          ,effects ...
          ,value)
       (let-values ([(effects^ frees1) (map2 (λ (effect) (uncover-effect effect bound)) effects)]
                    [(value^ frees2) (uncover-value value bound)])

         (values `(begin
                    ,@effects^
                    ,value^)
                 (set-union (apply set-union frees1) frees2)))]
      [triv (uf-triv triv bound)]))

  ;; effect -> (values effect (setof aloc))
  (define (uncover-effect effect bound)
    (match effect
      [`(,primop ,myvalues ...)
       #:when (primop? primop)
       (let-values ([(values^ frees) (map2 (λ (v) (uncover-value v bound)) myvalues)])
         (values `(,primop ,@values^) (apply set-union frees)))]
      [`(begin
          ,effects ...)
       (let-values ([(effects^ frees) (map2 (λ (effect) (uncover-effect effect bound)) effects)])
         (values `(begin
                    ,@effects^)
                 (apply set-union frees)))]))

  ;; triv -> (values triv (setof aloc))
  (define (uf-triv triv bound)
    (match triv
      [(? aloc?)
       (if (set-member? bound triv)
           (values triv bound)
           (values triv (set-add bound triv)))]
      [_ (values triv bound)]))

  (match p
    [`(module ,v)
     (let-values ([(v^ _) (uncover-value v (set))])
       `(module ,v^))]))

(module+ test
  (require rackunit)

  (check-match (uncover-free '(module (letrec ([f.1 (lambda () (unsafe-procedure-call x.1))])
                                        f.1)))
               `(module (letrec ([f.1 (lambda ((free (x.1)))
                                        ()
                                        (unsafe-procedure-call x.1))])
                          f.1)))

  (check-match (uncover-free '(module (letrec ([f.1 (lambda ()
                                                      (letrec ([g.1 (lambda ()
                                                                      (unsafe-procedure-call d.1))])
                                                        g.1))])
                                        f.1)))
               `(module (letrec ([f.1 (lambda ((free (d.1)))
                                        ()
                                        (letrec ([g.1 (lambda ((free (d.1)))
                                                        ()
                                                        (unsafe-procedure-call d.1))])
                                          g.1))])
                          f.1)))

  (check-match (uncover-free '(module (letrec ([f.1 (lambda ()
                                                      (letrec ([g.1 (lambda ()
                                                                      (unsafe-procedure-call d.1))])
                                                        (let ([t.1 5]) v.1)))])
                                        f.1)))
               `(module (letrec ([f.1 (lambda ((free (v.1 d.1)))
                                        ()
                                        (letrec ([g.1 (lambda ((free (d.1)))
                                                        ()
                                                        (unsafe-procedure-call d.1))])
                                          (let ([t.1 5]) v.1)))])
                          f.1)))

  (check-match
   (uncover-free '(module (letrec ([f.1 (lambda ()
                                          (letrec ([g.1 (lambda () (unsafe-procedure-call d.1 h.1))])
                                            (let ([t.1 5]) v.1)))])
                            f.1)))
   `(module (letrec ([f.1 (lambda ((free (d.1 h.1 v.1)))
                            ()
                            (letrec ([g.1 (lambda ((free (d.1 h.1)))
                                            ()
                                            (unsafe-procedure-call d.1 h.1))])
                              (let ([t.1 5]) v.1)))])
              f.1)))

  (check-match (uncover-free '(module (let ([x.1 1])
                                        (let ([y.1 x.1]) (let ([z.1 y.1]) (unsafe-fx+ x.1 z.1))))))
               `(module (let ([x.1 1]) (let ([y.1 x.1]) (let ([z.1 y.1]) (unsafe-fx+ x.1 z.1))))))

  (check-match (uncover-free `(module (letrec ([x.1 (lambda () (unsafe-procedure-call x.1))])
                                        x.1)))
               '(module (letrec ([x.1 (lambda ((free (x.1)))
                                        ()
                                        (unsafe-procedure-call x.1))])
                          x.1)))

  (check-match (uncover-free `(module (letrec ([f.1 (lambda ()
                                                      (letrec ([x.1 (lambda (d.1)
                                                                      (unsafe-procedure-call x.1))])
                                                        x.1))])
                                        f.1)))
               '(module (letrec ([f.1 (lambda ((free ()))
                                        ()
                                        (letrec ([x.1 (lambda ((free (x.1)))
                                                        (d.1)
                                                        (unsafe-procedure-call x.1))])
                                          x.1))])
                          f.1))))
