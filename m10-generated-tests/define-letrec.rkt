#lang racket
(require rackunit
         cpsc411/compiler-lib
         cpsc411/ptr-run-time
         cpsc411/langs/v8
         cpsc411/langs/v9
         cpsc411/langs/v11
         (file "../define-letrec.rkt"))
(define (fail-if-invalid p)
  (when (not (just-exprs-lang-v9? p))
    (error
     (~a
      (pretty-format p)
      "\n is not a semantically valid "
      "just-exprs-lang-v9"
      " program")))
  p)
(define-syntax-rule
 (check-by-interp p)
 (check-equal?
  (interp-exprs-unsafe-lang-v9 p)
  (interp-just-exprs-lang-v9 (fail-if-invalid (define-letrec p)))))

(check-by-interp '(module empty))
(check-by-interp '(module (error 240)))
(check-by-interp '(module empty))
(check-by-interp '(module #\x))
(check-by-interp '(module (if empty empty #f)))
(check-by-interp '(module (let () 212)))
(check-by-interp
 '(module
    (define fun/fixnum8485.7 (lambda () 60))
    (unsafe-procedure-call fun/fixnum8485.7)))
(check-by-interp
 '(module
    (define fun/ascii-char8488.7 (lambda () #\A))
    (unsafe-procedure-call fun/ascii-char8488.7)))
(check-by-interp
 '(module
    (define fun/ascii-char8491.7 (lambda () #\Z))
    (unsafe-procedure-call fun/ascii-char8491.7)))
(check-by-interp
 '(module
    (let ((tmp.7.12 #\h))
      (if tmp.7.12
        tmp.7.12
        (let ((tmp.8.13 #\l))
          (if tmp.8.13
            tmp.8.13
            (let ((tmp.9.14 #\K))
              (if tmp.9.14
                tmp.9.14
                (let ((tmp.10.15 #\i))
                  (if tmp.10.15
                    tmp.10.15
                    (let ((tmp.11.16 #\m))
                      (if tmp.11.16 tmp.11.16 #\y))))))))))))
(check-by-interp '(module (if #t 219 101)))
(check-by-interp
 '(module
    (define fun/empty8500.7 (lambda () empty))
    (unsafe-procedure-call fun/empty8500.7)))
(check-by-interp
 '(module
    (if (let () empty)
      (if (if empty
            (if empty (if empty (if empty (if empty empty #f) #f) #f) #f)
            #f)
        (if #t empty empty)
        #f)
      #f)))
(check-by-interp
 '(module
    (define unsafe-vector-set!.5
      (lambda (tmp.35 tmp.36 tmp.37)
        (if (unsafe-fx< tmp.36 (unsafe-vector-length tmp.35))
          (if (unsafe-fx>= tmp.36 0)
            (begin (unsafe-vector-set! tmp.35 tmp.36 tmp.37) (void))
            (error 10))
          (error 10))))
    (define vector-set!.83
      (lambda (tmp.59 tmp.60 tmp.61)
        (if (fixnum? tmp.60)
          (if (vector? tmp.59)
            (unsafe-procedure-call unsafe-vector-set!.5 tmp.59 tmp.60 tmp.61)
            (error 10))
          (error 10))))
    (define vector-init-loop.31
      (lambda (len.32 i.34 vec.33)
        (if (eq? len.32 i.34)
          vec.33
          (begin
            (unsafe-vector-set! vec.33 i.34 0)
            (unsafe-procedure-call
             vector-init-loop.31
             len.32
             (unsafe-fx+ i.34 1)
             vec.33)))))
    (define make-init-vector.4
      (lambda (tmp.29)
        (let ((tmp.30 (unsafe-make-vector tmp.29)))
          (unsafe-procedure-call vector-init-loop.31 tmp.29 0 tmp.30))))
    (define make-vector.82
      (lambda (tmp.57)
        (if (fixnum? tmp.57)
          (unsafe-procedure-call make-init-vector.4 tmp.57)
          (error 8))))
    (define error?.81 (lambda (tmp.71) (error? tmp.71)))
    (define fun/void8514.8 (lambda () (void)))
    (define fun/void8513.9 (lambda () (void)))
    (let ((g42771912.10 (if #f (void) (void))))
      (if (unsafe-procedure-call error?.81 g42771912.10)
        g42771912.10
        (let ((g42771913.11 (unsafe-procedure-call fun/void8513.9)))
          (if (unsafe-procedure-call error?.81 g42771913.11)
            g42771913.11
            (let ((g42771914.12
                   (let ((vector0.13
                          (let ((tmp.7.14
                                 (unsafe-procedure-call make-vector.82 8)))
                            (let ((g42771915.15
                                   (unsafe-procedure-call
                                    vector-set!.83
                                    tmp.7.14
                                    0
                                    0)))
                              (if (unsafe-procedure-call
                                   error?.81
                                   g42771915.15)
                                g42771915.15
                                (let ((g42771916.16
                                       (unsafe-procedure-call
                                        vector-set!.83
                                        tmp.7.14
                                        1
                                        1)))
                                  (if (unsafe-procedure-call
                                       error?.81
                                       g42771916.16)
                                    g42771916.16
                                    (let ((g42771917.17
                                           (unsafe-procedure-call
                                            vector-set!.83
                                            tmp.7.14
                                            2
                                            2)))
                                      (if (unsafe-procedure-call
                                           error?.81
                                           g42771917.17)
                                        g42771917.17
                                        (let ((g42771918.18
                                               (unsafe-procedure-call
                                                vector-set!.83
                                                tmp.7.14
                                                3
                                                3)))
                                          (if (unsafe-procedure-call
                                               error?.81
                                               g42771918.18)
                                            g42771918.18
                                            (let ((g42771919.19
                                                   (unsafe-procedure-call
                                                    vector-set!.83
                                                    tmp.7.14
                                                    4
                                                    4)))
                                              (if (unsafe-procedure-call
                                                   error?.81
                                                   g42771919.19)
                                                g42771919.19
                                                (let ((g42771920.20
                                                       (unsafe-procedure-call
                                                        vector-set!.83
                                                        tmp.7.14
                                                        5
                                                        5)))
                                                  (if (unsafe-procedure-call
                                                       error?.81
                                                       g42771920.20)
                                                    g42771920.20
                                                    (let ((g42771921.21
                                                           (unsafe-procedure-call
                                                            vector-set!.83
                                                            tmp.7.14
                                                            6
                                                            6)))
                                                      (if (unsafe-procedure-call
                                                           error?.81
                                                           g42771921.21)
                                                        g42771921.21
                                                        (let ((g42771922.22
                                                               (unsafe-procedure-call
                                                                vector-set!.83
                                                                tmp.7.14
                                                                7
                                                                7)))
                                                          (if (unsafe-procedure-call
                                                               error?.81
                                                               g42771922.22)
                                                            g42771922.22
