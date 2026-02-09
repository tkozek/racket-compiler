#lang racket 
(require cpsc411/compiler-lib 
        cpsc411/2c-run-time)
 (require cpsc411/test-suite/public/v2)

(provide
 check-values-lang
 uniquify
 sequentialize-let
 normalize-bind
 select-instructions
 uncover-locals
 assign-fvars
 replace-locations
 assign-homes
 flatten-begins
 patch-instructions
 implement-fvars
 check-paren-x64
 generate-x64
 interp-values-lang
 interp-paren-x64)

(require "values-lang-v3.rkt"
            "values-unique-lang-v3.rkt"
            "imp-mf-lang-v3.rkt"
            "imp-cmf-lang-v3.rkt"
            "asm-lang-v2.rkt"
            "nested-asm-v3.rkt"
            "para-asm-v2.rkt"
            "paren-x64-fvars-v2.rkt"
            "paren-x64-v2.rkt"
            "util.rkt"
                )

;; You might want to reuse check-paren-x64 and generate-x64 from milestone-1



(define (generate-x64 p)
  (define (program->x64 p)
    (match p
      [`(begin ,s ...)
       (TODO "generate-x64")]))

  (define (statement->x64 s)
    (TODO "generate-x64"))

  (define (loc->x64 loc)
    (TODO "generate-x64"))

  (define (binop->ins b)
    (TODO "generate-x64"))

  (program->x64 p))


;; Optional
(define (check-paren-x64 p)
    p)

;; Optional
(define (interp-values-lang p)
    0)

(current-pass-list
 (list
  check-values-lang
  uniquify
  sequentialize-let
  normalize-bind
  select-instructions
  assign-homes
  flatten-begins
  patch-instructions
  implement-fvars
  generate-x64
  wrap-x64-run-time
  wrap-x64-boilerplate))

(module+ test
  (require
   rackunit
   rackunit/text-ui
   cpsc411/test-suite/public/v3
   ;; NB: Workaround typo in shipped version of cpsc411-lib
   (except-in cpsc411/langs/v3 values-lang-v3)
   cpsc411/langs/v2)
;    (require
;   (submod "values-lang-v3.rkt" test)
;   (submod "values-unique-lang-v3.rkt" test)
;   (submod "imp-mf-lang-v3.rkt" test)
;   (submod "imp-cmf-lang-v3.rkt" test)
;   (submod "asm-lang-v2.rkt" test)
;   (submod "nested-asm-v3.rkt" test)
;   (submod "para-asm-v2.rkt" test)
;   (submod "paren-x64-fvars-v2.rkt" test)
;   (submod "paren-x64-v2.rkt" test))

  (run-tests
   (v3-public-test-sutie
    (current-pass-list)
    (list
     interp-values-lang-v3
     interp-values-lang-v3
     interp-values-unique-lang-v3
     interp-imp-mf-lang-v3
     interp-imp-cmf-lang-v3
     interp-asm-lang-v2
     interp-nested-asm-lang-v2
     interp-para-asm-lang-v2
     interp-paren-x64-fvars-v2
     interp-paren-x64-v2
     #f #f))))

(module+ test
;; First five tests taken from book
    (check-equal? (uniquify '(module (+ 2 2)))     
                        '(module (+ 2 2)))
    (check-equal? (uniquify '(module (* 2 2)))     
                        '(module (* 2 2)))
    (check-equal? (uniquify '(module (let ([x 5]) x))) 
                '(module (let ([x.1 5]) x.1)))
    (check-equal? (uniquify '(module (let ([x (+ 2 2)]) x))) 
                        '(module (let ([x.2 (+ 2 2)]) x.2)))
    (check-equal? (uniquify '(module (let ([x 2]) (let ([y 2]) (+ x y)))))
                    '(module (let ((x.3 2)) (let ((y.4 2)) (+ x.3 y.4)))))
    (check-equal? (uniquify '(module (let ([x 2]) (let ([x 2]) (+ x x))))) 
                    '(module (let ((x.5 2)) (let ((x.6 2)) (+ x.6 x.6)))))  
    (check-equal? (uniquify '(module (let '() 0))) '(module (let '() 0)))
    (check-equal? (uniquify '(module (let '() (+ 2 2)))) '(module (let '() (+ 2 2))))
    (check-equal? (uniquify '(module (let '() (let '() 42)))) 
                            '(module (let '() (let '() 42))))
    (check-equal? (uniquify '(module (let '() (let ([x 0]) (+ (max-int 64) x))))) 
                        '(module (let '() (let ([x.7 0]) (+ (max-int 64) x.7))))) 
    (check-equal? (uniquify '(module (let '() (let '() (let '() -1)))))
                        '(module (let '() (let '() (let '() -1)))))
    (check-equal? (uniquify '(module 0)) '(module 0))
    (check-equal? (uniquify '(module 9223372036854775807)) '(module 9223372036854775807))
    (check-equal? (uniquify '(module 9223372036854775806)) '(module 9223372036854775806))
    (check-equal? (uniquify '(module -9223372036854775808)) '(module -9223372036854775808))
    (check-equal? (uniquify '(module -9223372036854775807)) '(module -9223372036854775807))
    (check-exn exn:fail?
        (lambda () (uniquify '(module 9223372036854775808))))
    (check-exn exn:fail?
        (lambda () (uniquify '(module -9223372036854775809))))
    (check-exn exn:fail? 
        (lambda () (uniquify '(module x))))
    (check-exn exn:fail? 
        (lambda () (uniquify '(module (+ x y)))))
    (check-exn exn:fail? 
        (lambda () (uniquify '(module (* x y)))))
    (check-exn exn:fail? 
        (lambda () (uniquify '(module ))))
    (check-exn exn:fail? 
        (lambda () (uniquify '(module (add1 2 2)))))
    ;; Nested binop
    (check-exn exn:fail? 
        (lambda () (uniquify '(module (+ 1 (+ 1 1))))))
    ;; Binop with one triv OOB for int64
    (check-exn exn:fail? 
        (lambda () (uniquify '(module (* 2 9223372036854775808)))))
    ;; Binop with both triv OOB for int64
    (check-exn exn:fail? 
        (lambda () (uniquify '(module (* 9223372036854775808 9223372036854775808)))))
    (check-exn exn:fail? 
        (lambda () (uniquify '(module (* -9223372036854775809 -9223372036854775808)))))
    (check-exn exn:fail? 
        (lambda () (uniquify '(module (* -9223372036854775809 9223372036854775808)))))
    )
    
(module+ test
    (check-equal? (sequentialize-let '(module 0)) '(module 0))
    (check-equal? (sequentialize-let '(module 9223372036854775807)) '(module 9223372036854775807))
    (check-equal? (sequentialize-let '(module -9223372036854775808)) '(module -9223372036854775808))
    (check-eq? (sequentialize-let '(module (let '() 0))) '(module (begin 0)))
    (check-eq? (sequentialize-let '(module (let '() 9223372036854775807))) 
                                    '(module (begin 9223372036854775807)))
    (check-eq? (sequentialize-let '(module (let '() -9223372036854775808))) 
                                    '(module (begin -9223372036854775808)))
    (check-eq? (sequentialize-let '(module (let ([x.1 0]) 1)))
                '(module (begin (set! x.1 0) 1)))
    (check-eq? (sequentialize-let '(module (let ([x.2 1]) x.2)))
                '(module (begin (set! x.2 1) x.2)))    
    (check-eq? (sequentialize-let '(module (+ 0 1)))
                '(module (+ 0 1)))     
    (check-eq? (sequentialize-let '(module (* -1 2)))
                '(module (* -1 2)))  
    (check-eq? (sequentialize-let '(module x.2))
                '(module x.2))  
    (check-eq? (sequentialize-let '(module (let ([x.1 1] [x.2 -1] [x.3 4]) (* x.3 x.2))))
                '(module (begin (set! x.1 1) (set! x.2 -1) (set! x.3 4) (* x.3 x.2))))
    (check-eq? (sequentialize-let '(module (let ([x.1 (let ([x.2 5]) x.2)]) x.1)))
                '(module (begin (set! x.1 (begin (set! x.2 5) x.2)) x.1)))
    (check-eq? (sequentialize-let '(module (let ([x.1 
                                            (let ([x.2 
                                            (let ([x.3 3]) (* x.3 x.3))]) x.2)]) (* 2 x.1))))
                '(module (begin (set! x.1 
                            (begin (set! x.2 
                                (begin (set! x.3 3) (* x.3 x.3))) x.2)) (* 2 x.1))))
    (check-eq? (sequentialize-let '(module 
                                    (let ([x.1 (+ 1 2)]) 
                                    (let ([x.2 (+ x.1 3)]) 0))))
            '(module (begin (set! x.1 (+ 1 2)) (begin (set! x.2 (+ x.1 3)) 0))))
    (check-eq? (sequentialize-let '(module (let ([x.1 (+ 1 2)]) (let ([x.2 (+ x.1 3)]) (* 2 x.1)))))
            '(module (begin (set! x.1 (+ 1 2)) (begin (set! x.2 (+ x.1 3)) (* 2 x.1)))))
    (check-eq? (sequentialize-let '(module (let ([x.1 (+ 1 2)]) (let ([x.2 (+ x.1 3)]) (+ x.2 x.1)))))
            '(module (begin (set! x.1 (+ 1 2)) (begin (set! x.2 (+ x.1 3)) (+ x.2 x.1)))))
    (check-eq? (sequentialize-let '(module (let ([x.1 (+ 1 2)]) (let ([x.2 (+ x.1 3)]) (* x.2 x.1)))))
            '(module (begin (set! x.1 (+ 1 2)) (begin (set! x.2 (+ x.1 3)) (* x.2 x.1)))))
)

(module+ test
    (check-equal? (normalize-bind '(module 0)) '(module 0))
    (check-equal? (normalize-bind '(module 9223372036854775807)) '(module 9223372036854775807))
    (check-equal? (normalize-bind '(module -9223372036854775808)) '(module -9223372036854775808))
    (check-equal? (normalize-bind '(module (+ 1 2))) '(module (+ 1 2)))
    (check-equal? (normalize-bind '(module (* -2 1))) '(module (* -2 1)))
    (check-equal? (normalize-bind '(module (* 1 9223372036854775807))) 
                                '(module (* 1 9223372036854775807)))
    (check-equal? (normalize-bind '(module (+ 10 -9223372036854775808))) 
                                '(module (+ 10 -9223372036854775808)))
    (check-equal? (normalize-bind '(module (begin (set! x.1 1) x.1))) 
                                '(module (begin (set! x.1 1) x.1)))
    (check-equal? (normalize-bind '(module (begin (set! x.1 2) (set! x.1 5) (+ 42 x.1)))) 
                                '(module (begin (set! x.1 2) (set! x.1 5) (+ 42 x.1))))
    (check-equal? (normalize-bind '(module (begin (set! x.1 (+ 2 4)) (set! x.1 (* 3 3)) (+ 42 x.1)))) 
                                '(module (begin (set! x.1 (+ 2 4)) (set! x.1 (* 3 3)) (+ 42 x.1))))
    (check-equal? (normalize-bind '(module (begin (set! x.1 (+ 2 4)) (set! x.2 (* 3 3)) (+ x.2 x.1)))) 
                                '(module (begin (set! x.1 (+ 2 4)) (set! x.2 (* 3 3)) (+ x.2 x.1))))
    (check-equal? (normalize-bind '(module (begin (set! x.1 1) (set! x.2 0) (* x.2 x.1)))) 
                                '(module (begin (set! x.1 1) (set! x.2 0) (* x.2 x.1))))
    (check-equal? (normalize-bind '(module (begin (set! x.1 2) (set! x.1 5) (+ x.1 x.1)))) 
                                '(module (begin (set! x.1 2) (set! x.1 5) (+ x.1 x.1))))
    (check-equal? (normalize-bind '(module (begin (set! x.1 (begin () 5)) 0)))
                                '(module (begin (begin (set! x.1 5)) 0)))
    (check-equal? (normalize-bind '(module (begin (set! x.1 (begin () 5)) x.1)))
                                '(module (begin (begin (set! x.1 5)) x.1)))
    (check-equal? (normalize-bind '(module (begin (set! x.1 
                                            (begin (set! x.2 5) (set! x.1 3) 1)) 2))) 
                                '(module (begin (begin 
                                                    (set! x.2 5) (set! x.1 3) (set! x.1 1) 2))))
    (check-equal? (normalize-bind '(module (begin (set! x.1 
                                            (begin (set! x.2 5) 
                                                (set! x.1 3) 1)) (+ x.1 x.2))))
                                '(module (begin 
                                            (begin (set! x.2 5) (set! x.1 3) 
                                                    (set! x.1 1) (+ x.1 x.2)))))
    (check-equal? (normalize-bind '(module (begin (set! x.1 
                                            (begin (set! x.2 5) 
                                                (set! x.1 3) (+ x.2 x.1))) (+ x.1 x.2))))
                                '(module (begin 
                                            (begin (set! x.2 5) (set! x.1 3) 
                                                    (set! x.1 (+ x.2 x.1)) (+ x.1 x.2)))))
    (check-equal? (normalize-bind '(module (begin (set! x.1 
                                            (begin (set! x.2 5) 
                                                (set! x.1 3) (* x.2 x.1))) (+ x.1 x.2))))
                                '(module (begin 
                                            (begin (set! x.2 5) (set! x.1 3) 
                                                    (set! x.1 (* x.2 x.1)) (+ x.1 x.2)))))
    (check-equal? (normalize-bind '(module (begin (set! x.1 
                                            (begin (set! x.2 5) 
                                                (set! x.1 3) (* x.2 x.1))) (* 5 x.2))))
                                '(module (begin 
                                            (begin (set! x.2 5) (set! x.1 3) 
                                                    (set! x.1 (* x.2 x.1)) (* 5 x.2)))))
    (check-equal? (normalize-bind '(module (begin (set! x.1 
                                            (begin (set! x.2 5) 
                                                (set! x.1 3) (+ x.2 x.1))) (* 5 x.2))))
                                '(module (begin 
                                            (begin (set! x.2 5) (set! x.1 3) 
                                                    (set! x.1 (+ x.2 x.1)) (* 5 x.2)))))
    (check-equal? (normalize-bind '(module (begin (set! x.1 2) (set! x.2 3) 
                                        (begin (set! x.1 3) (set! x.2 1) 1))))
                            '(module (begin (set! x.1 2) (set! x.2 3) 
                                        (begin (set! x.1 3) (set! x.2 1) 1))))
    (check-equal? (normalize-bind '(module (begin (set! x.1 2) (set! x.2 3) 
                                        (begin (set! x.1 3) (set! x.2 1) (+ x.1 x.2)))))
                            '(module (begin (set! x.1 2) (set! x.2 3) 
                                        (begin (set! x.1 3) (set! x.2 1) (+ x.1 x.2)))))
    (check-equal? (normalize-bind '(module (begin (set! x.1 2) (set! x.2 3) 
                                        (begin (set! x.1 3) (set! x.2 (begin 4)) (+ x.1 x.2)))))
                                '(module (begin (set! x.1 2) (set! x.2 3) 
                                        (begin (set! x.1 3) (begin (set! x.2 4)) (+ x.1 x.2)))))

    (check-equal? (normalize-bind '(module (begin (set! x.1 2) (set! x.2 3) 
                                        (begin (set! x.1 3) (set! x.2 
                                        (begin (set! x.1 4) (set! x.1 0) (+ x.1 x.1)))) (+ x.1 x.2))))
                                '(module (begin (set! x.1 2) (set! x.2 3) 
                                        (begin (set! x.1 3) 
                                        (begin (set! x.1 4) (set! x.1 0) (set! x.2 (+ x.1 x.1))) 
                                                (+ x.1 x.2)))))                            
)

(module+ test
    (check-equal? (select-instructions '(module 0))
                    '(module () (halt 0)))
    (check-equal? (select-instructions '(module 9223372036854775807))
                    '(module () (halt 9223372036854775807)))
    (check-equal? (select-instructions '(module -9223372036854775808))
                    '(module () (halt -9223372036854775808)))
    (check-match (select-instructions '(module (+ 2 2))) 
            '(module () (begin (set! ,t 2) (set! ,t (+ ,t 2)) (halt ,t))))
    (check-match (select-instructions '(module (* -3 2))) 
            '(module () (begin (set! ,t -3) (set! ,t (* ,t 2)) (halt ,t))))
    (check-match (select-instructions '(module (+ 9223372036854775807 9223372036854775807))) 
            '(module () (begin (set! ,t 9223372036854775807) (set! ,t (+ ,t 9223372036854775807))
             (halt ,t))))
    (check-match (select-instructions '(module (* -9223372036854775808 9223372036854775807))) 
            '(module () (begin (set! ,t -9223372036854775808) (set! ,t (* ,t 9223372036854775807)) 
                                                (halt ,t))))
    (check-match (select-instructions '(module (begin (set! ,t 5) ,t)))
                '(module () (begin (set! ,t 5) (halt ,t))))
    (check-equal? (select-instructions '(module (begin (set! x.1 (+ 2 2)) x.1)))
        '(module () (begin (set! x.1 2) (set! x.1 (+ x.1 2)) (halt x.1))))
    (check-match (select-instructions '(module (begin (set! x.1 2) (set! x.2 2) (+ x.1 x.2)))) 
        '(module () (begin (set! x.1 2) (set! x.2 2) (set! ,t x.1) 
                (set! ,t (+ ,t x.2)) (halt ,t))))
    (check-match (select-instructions '(module (begin (begin (set! ,t 3)) ,t)))
                '(module () (begin (begin (set! ,t 3)) (halt ,t))))    
)

(module+ test
    (check-equal? (uncover-locals '(module () (halt 0)))
                '(module ((locals ())) (halt 0)))
    (check-equal? (uncover-locals '(module () (halt 9223372036854775807)))
                '(module ((locals ())) (halt 9223372036854775807)))
    (check-equal? (uncover-locals '(module () (halt -9223372036854775808)))
                '(module ((locals ())) (halt -9223372036854775808)))
    (check-exn exn:fail? (lambda () (uncover-locals '(module () (halt x.1)))))

    (check-match? (uncover-locals '(module () (begin (set! ,x.1 0) (halt ,x.1))))
                '(module ((locals (,x.1))) (begin (set! ,x.1 0) (halt ,x.1))))
    (check-match? (uncover-locals '(module () (begin (set! ,x.1 0) (set! ,y.1 ,x.1)
                                            (set! ,y.1 (+ ,y.1 ,x.1)) (halt ,y.1))))
                '(module ((locals (,x.1 ,y.1))) (begin (set! ,x.1 0) (set! ,y.1 ,x.1) 
                                                (set! y.1 (+ ,y.1 ,x.1)) (halt ,y.1))))
)

(module+ test
    (check-match?  (assign-fvars '(module ((locals (,x.1))) (begin (set! ,x.1 0) (halt ,x.1))))
            '(module ((locals (,x.1)) (assignment ((,x.1 ,fv0)))) (begin (set! ,x.1 0) (halt ,x.1))))
    (check-match? (assign-fvars '(module ((locals (,x.1 ,y.1 ,w.1))) (begin (set! ,x.1 0) (set! ,y.1 ,x.1)
                    (set! ,w.1 1) (set! ,w.1 (+ ,w.1 ,y.1)) (halt ,w.1)))) 
        '(module ((locals (,x.1 ,y.1 ,w.1)) (assignment ((,x.1 fv0) (,y.1 ,fv1) (,w.1 ,fv2))))
           (begin (set! ,x.1 0) (set! ,y.1 ,x.1) (set! ,w.1 1) (set! ,w.1 (+ ,w.1 ,y.1)) (halt ,w.1))))
)

(module+ test
    (check-match? (replace-locations '(module ((locals (x.1)) (assignment ((x.1 rax))))
                    (begin (set! x.1 0) (halt x.1))))
                    '(begin (set! rax 0) (halt rax)))
    (check-match? (replace-locations '(module ((locals (x.1 y.1 w.1)) 
                    (assignment ((x.1 rax) (y.1 rbx) (w.1 r9)))) 
            (begin (set! x.1 0) (set! y.1 x.1) (set! w.1 1) (set! w.1 (+ w.1 y.1)) (halt w.1))))
            '(begin (set! rax 0) (set! rbx rax) (set! r9 1) (set! r9 (+ r9 rbx)) (halt r9)))
)

(module+ test
    (check-eq? (flatten-begins '(halt 0)) '(begin (halt 0)))

)

(module+ test
    (check-eq? (patch-instructions '(begin (set! rbx 42) (halt rbx)))
                '(begin (set! rbx 42) (set! rax rbx)))
    (check-eq? (patch-instructions '(begin (set! fv0 0) (set! fv1 42) (set! fv0 fv1) (halt fv0)))
                '(begin (set! fv0 0) (set! fv1 42) (set! r10 fv1) (set! fv0 r10) (set! rax fv0)))
    (check-eq? (patch-instructions '(begin (set! rbx 0) (set! rcx 0) (set! r9 42) (set! rbx rcx)
                        (set! rbx (+ rbx r9)) (halt rbx))) 
                        '(begin (set! rbx 0) (set! rcx 0) (set! r9 42) (set! rbx rcx)
                         (set! rbx (+ rbx r9)) (set! rax rbx)))
)

(module+ test
    (check-eq? (implement-fvars '(begin)) '(begin))
)
