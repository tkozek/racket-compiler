#lang racket
(require rackunit
         cpsc411/compiler-lib
         cpsc411/ptr-run-time
         cpsc411/langs/v8
         cpsc411/langs/v9
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

(check-by-interp
 '(module
    (define cons.56 (lambda (tmp.51 tmp.52) (cons tmp.51 tmp.52)))
    (unsafe-procedure-call cons.56 6 501)))
(check-by-interp
 '(module
    (define cons.56 (lambda (tmp.51 tmp.52) (cons tmp.51 tmp.52)))
    (unsafe-procedure-call cons.56 42 510)))
(check-by-interp
 '(module
    (define fun/error8439.4 (lambda () (error 148)))
    (unsafe-procedure-call fun/error8439.4)))
(check-by-interp
 '(module
    (define fun/error8442.4 (lambda () (error 247)))
    (unsafe-procedure-call fun/error8442.4)))
(check-by-interp
 '(module
    (define fun/error8445.4 (lambda () (error 141)))
    (unsafe-procedure-call fun/error8445.4)))
(check-by-interp
 '(module
    (define cons.57 (lambda (tmp.52 tmp.53) (cons tmp.52 tmp.53)))
    (define fun/pair8448.4 (lambda () (unsafe-procedure-call cons.57 183 277)))
    (unsafe-procedure-call fun/pair8448.4)))
(check-by-interp '(module (let ((ascii-char0.5 #\N) (void1.4 (void))) #t)))
(check-by-interp
 '(module
    (define vector-init-loop.8
      (lambda (len.9 i.11 vec.10)
        (if (eq? len.9 i.11)
          vec.10
          (begin
            (unsafe-vector-set! vec.10 i.11 0)
            (unsafe-procedure-call
             vector-init-loop.8
             len.9
             (unsafe-fx+ i.11 1)
             vec.10)))))
    (define make-init-vector.1
      (lambda (tmp.6)
        (let ((tmp.7 (unsafe-make-vector tmp.6)))
          (unsafe-procedure-call vector-init-loop.8 tmp.6 0 tmp.7))))
    (define make-vector.58
      (lambda (tmp.34)
        (if (fixnum? tmp.34)
          (unsafe-procedure-call make-init-vector.1 tmp.34)
          (error 8))))
    (let ((vector0.5 (unsafe-procedure-call make-vector.58 8))
          (procedure1.4 (lambda () 72)))
      empty)))
(check-by-interp
 '(module
    (define cons.59 (lambda (tmp.54 tmp.55) (cons tmp.54 tmp.55)))
    (define fun/empty8458.4 (lambda () empty))
    (define fun/empty8457.5
      (lambda (oprand0.6) (unsafe-procedure-call fun/empty8458.4)))
    (unsafe-procedure-call
     fun/empty8457.5
     (if #f
       (unsafe-procedure-call cons.59 197 480)
       (unsafe-procedure-call cons.59 47 421)))))
(check-by-interp '(module (if #f (void) (void))))
(check-by-interp
 '(module
    (define vector-init-loop.6
      (lambda (len.7 i.9 vec.8)
        (if (eq? len.7 i.9)
          vec.8
          (begin
            (unsafe-vector-set! vec.8 i.9 0)
            (unsafe-procedure-call
             vector-init-loop.6
             len.7
             (unsafe-fx+ i.9 1)
             vec.8)))))
    (define make-init-vector.1
      (lambda (tmp.4)
        (let ((tmp.5 (unsafe-make-vector tmp.4)))
          (unsafe-procedure-call vector-init-loop.6 tmp.4 0 tmp.5))))
    (define make-vector.56
      (lambda (tmp.32)
        (if (fixnum? tmp.32)
          (unsafe-procedure-call make-init-vector.1 tmp.32)
          (error 8))))
    (if #f
      (unsafe-procedure-call make-vector.56 8)
      (unsafe-procedure-call make-vector.56 8))))
(check-by-interp
 '(module
    (define cons.61 (lambda (tmp.56 tmp.57) (cons tmp.56 tmp.57)))
    (define fun/error8467.4 (lambda (oprand0.7) (error 175)))
    (define fun/empty8465.5
      (lambda (oprand0.8) (unsafe-procedure-call fun/empty8466.6)))
    (define fun/empty8466.6 (lambda () empty))
    (unsafe-procedure-call
     fun/empty8465.5
     (unsafe-procedure-call
      fun/error8467.4
      (unsafe-procedure-call cons.61 79 502)))))
(check-by-interp
 '(module
    (define |-.63|
      (lambda (tmp.29 tmp.30)
        (if (fixnum? tmp.30)
          (if (fixnum? tmp.29) (unsafe-fx- tmp.29 tmp.30) (error 3))
          (error 3))))
    (define fun/void8484.4 (lambda () (void)))
    (define fun/ascii-char8485.5 (lambda (oprand0.8 oprand1.7) #\B))
    (define fun/void8483.6
      (lambda (oprand0.10 oprand1.9) (unsafe-procedure-call fun/void8484.4)))
    (unsafe-procedure-call
     fun/void8483.6
     (unsafe-procedure-call
      fun/ascii-char8485.5
      (unsafe-procedure-call |-.63| 28 88)
      (unsafe-procedure-call fun/ascii-char8485.5 88 #\C))
     (if #t 120 66))))
(check-by-interp
 '(module
    (if (if #t #t #f)
      (if #t (error 18) (error 103))
      (let ((ascii-char0.6 #\p) (fixnum1.5 201) (empty2.4 empty))
        (error 21)))))
(check-by-interp
 '(module
    (define vector?.63 (lambda (tmp.54) (vector? tmp.54)))
    (define vector-init-loop.12
      (lambda (len.13 i.15 vec.14)
        (if (eq? len.13 i.15)
          vec.14
          (begin
            (unsafe-vector-set! vec.14 i.15 0)
            (unsafe-procedure-call
             vector-init-loop.12
             len.13
             (unsafe-fx+ i.15 1)
             vec.14)))))
    (define make-init-vector.1
      (lambda (tmp.10)
        (let ((tmp.11 (unsafe-make-vector tmp.10)))
          (unsafe-procedure-call vector-init-loop.12 tmp.10 0 tmp.11))))
    (define make-vector.62
      (lambda (tmp.38)
        (if (fixnum? tmp.38)
          (unsafe-procedure-call make-init-vector.1 tmp.38)
          (error 8))))
    (define fun/error8492.4 (lambda () (error 77)))
    (define fun/void8490.5 (lambda () (void)))
    (define fun/void8491.6 (lambda () (void)))
    (let ((void0.9 (unsafe-procedure-call fun/void8490.5))
          (void1.8 (unsafe-procedure-call fun/void8491.6))
          (boolean2.7
           (unsafe-procedure-call
            vector?.63
            (unsafe-procedure-call make-vector.62 8))))
      (unsafe-procedure-call fun/error8492.4))))
(check-by-interp
 '(module
    (define vector-init-loop.9
      (lambda (len.10 i.12 vec.11)
        (if (eq? len.10 i.12)
          vec.11
          (begin
            (unsafe-vector-set! vec.11 i.12 0)
            (unsafe-procedure-call
             vector-init-loop.9
             len.10
             (unsafe-fx+ i.12 1)
             vec.11)))))
    (define make-init-vector.1
      (lambda (tmp.7)
        (let ((tmp.8 (unsafe-make-vector tmp.7)))
          (unsafe-procedure-call vector-init-loop.9 tmp.7 0 tmp.8))))
    (define make-vector.59
      (lambda (tmp.35)
        (if (fixnum? tmp.35)
          (unsafe-procedure-call make-init-vector.1 tmp.35)
          (error 8))))
    (define fun/error8495.4 (lambda (oprand0.6 oprand1.5) (error 68)))
    (if (if #t #t #f)
      (if #t (error 231) (error 156))
      (unsafe-procedure-call
       fun/error8495.4
       #\c
       (unsafe-procedure-call make-vector.59 8)))))
