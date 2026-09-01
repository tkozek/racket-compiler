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
(check-by-interp
 '(module
    (define |-.62|
      (lambda (tmp.27 tmp.28)
        (if (fixnum? tmp.28)
          (if (fixnum? tmp.27) (unsafe-fx- tmp.27 tmp.28) (error 3))
          (error 3))))
    (define empty?.61 (lambda (tmp.48) (empty? tmp.48)))
    (define fun/error8528.4 (lambda () (error 215)))
    (define fun/ascii-char8529.5 (lambda () #\W))
    (let ((error0.8 (unsafe-procedure-call fun/error8528.4))
          (ascii-char1.7 (unsafe-procedure-call fun/ascii-char8529.5))
          (boolean2.6 (unsafe-procedure-call empty?.61 #\I)))
      (unsafe-procedure-call |-.62| 186 245))))
(check-by-interp
 '(module
    (define cons.62 (lambda (tmp.57 tmp.58) (cons tmp.57 tmp.58)))
    (define fun/pair8539.4 (lambda (oprand0.7 oprand1.6) oprand1.6))
    (define fun/pair8538.5
      (lambda (oprand0.9 oprand1.8) (unsafe-procedure-call cons.62 5 510)))
    (if (if #t #f #f)
      (unsafe-procedure-call fun/pair8538.5 247 #f)
      (unsafe-procedure-call
       fun/pair8539.4
       #f
       (unsafe-procedure-call cons.62 28 345)))))
(check-by-interp
 '(module
    (define cons.63 (lambda (tmp.57 tmp.58) (cons tmp.57 tmp.58)))
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
    (define fun/ascii-char8543.4 (lambda (oprand0.7 oprand1.6) #\x))
    (define fun/boolean8542.5 (lambda (oprand0.9 oprand1.8) #t))
    (if (unsafe-procedure-call
         fun/boolean8542.5
         #\]
         (unsafe-procedure-call make-vector.62 8))
      (unsafe-procedure-call
       fun/ascii-char8543.4
       (unsafe-procedure-call cons.63 180 382)
       229)
      (if #f #\^ #\i))))
(check-by-interp
 '(module
    (define *.66
      (lambda (tmp.25 tmp.26)
        (if (fixnum? tmp.26)
          (if (fixnum? tmp.25) (unsafe-fx* tmp.25 tmp.26) (error 1))
          (error 1))))
    (define |+.65|
      (lambda (tmp.27 tmp.28)
        (if (fixnum? tmp.28)
          (if (fixnum? tmp.27) (unsafe-fx+ tmp.27 tmp.28) (error 2))
          (error 2))))
    (define |-.64|
      (lambda (tmp.29 tmp.30)
        (if (fixnum? tmp.30)
          (if (fixnum? tmp.29) (unsafe-fx- tmp.29 tmp.30) (error 3))
          (error 3))))
    (define vector-init-loop.13
      (lambda (len.14 i.16 vec.15)
        (if (eq? len.14 i.16)
          vec.15
          (begin
            (unsafe-vector-set! vec.15 i.16 0)
            (unsafe-procedure-call
             vector-init-loop.13
             len.14
             (unsafe-fx+ i.16 1)
             vec.15)))))
    (define make-init-vector.1
      (lambda (tmp.11)
        (let ((tmp.12 (unsafe-make-vector tmp.11)))
          (unsafe-procedure-call vector-init-loop.13 tmp.11 0 tmp.12))))
    (define make-vector.63
      (lambda (tmp.39)
        (if (fixnum? tmp.39)
          (unsafe-procedure-call make-init-vector.1 tmp.39)
          (error 8))))
    (define fun/empty8591.4 (lambda () empty))
    (define fun/vector8589.5
      (lambda () (unsafe-procedure-call make-vector.63 8)))
    (define fun/ascii-char8590.6 (lambda () #\D))
    (let ((fixnum0.10
           (unsafe-procedure-call
            |-.64|
            (unsafe-procedure-call |-.64| 215 72)
            (unsafe-procedure-call |-.64| 219 173)))
          (vector1.9 (unsafe-procedure-call fun/vector8589.5))
          (fixnum2.8
           (unsafe-procedure-call
            |+.65|
            (unsafe-procedure-call |+.65| 93 220)
            (unsafe-procedure-call *.66 170 131)))
          (ascii-char3.7 (unsafe-procedure-call fun/ascii-char8590.6)))
      (unsafe-procedure-call fun/empty8591.4))))
(check-by-interp
 '(module
    (define cons.56 (lambda (tmp.51 tmp.52) (cons tmp.51 tmp.52)))
    (if (if #t #t #f)
      (if #t
        (unsafe-procedure-call cons.56 51 420)
        (unsafe-procedure-call cons.56 40 364))
      (if #t
        (unsafe-procedure-call cons.56 241 350)
        (unsafe-procedure-call cons.56 112 345)))))
(check-by-interp
 '(module
    (define fun/ascii-char8689.4 (lambda () #\I))
    (define fun/error8691.5 (lambda () (error 124)))
    (define fun/empty8692.6 (lambda () empty))
    (define fun/ascii-char8688.7 (lambda () #\j))
    (define fun/void8690.8 (lambda () (void)))
    (let ((ascii-char0.12 (unsafe-procedure-call fun/ascii-char8688.7))
          (ascii-char1.11 (unsafe-procedure-call fun/ascii-char8689.4))
          (void2.10 (unsafe-procedure-call fun/void8690.8))
          (procedure3.9 (lambda () (unsafe-procedure-call fun/error8691.5))))
      (unsafe-procedure-call fun/empty8692.6))))
(check-by-interp
 '(module
    (define boolean?.67 (lambda (tmp.51) (boolean? tmp.51)))
    (define vector?.66 (lambda (tmp.57) (vector? tmp.57)))
    (define vector-init-loop.15
      (lambda (len.16 i.18 vec.17)
        (if (eq? len.16 i.18)
          vec.17
          (begin
            (unsafe-vector-set! vec.17 i.18 0)
            (unsafe-procedure-call
             vector-init-loop.15
             len.16
             (unsafe-fx+ i.18 1)
             vec.17)))))
    (define make-init-vector.1
      (lambda (tmp.13)
        (let ((tmp.14 (unsafe-make-vector tmp.13)))
          (unsafe-procedure-call vector-init-loop.15 tmp.13 0 tmp.14))))
    (define make-vector.65
      (lambda (tmp.41)
        (if (fixnum? tmp.41)
          (unsafe-procedure-call make-init-vector.1 tmp.41)
          (error 8))))
    (define fun/vector8765.4
      (lambda () (unsafe-procedure-call make-vector.65 8)))
    (define fun/ascii-char8761.5 (lambda () #\k))
    (define fun/any8762.6 (lambda () (void)))
    (define fun/void8763.7 (lambda () (void)))
    (define fun/any8764.8 (lambda () (error 55)))
    (let ((ascii-char0.12 (unsafe-procedure-call fun/ascii-char8761.5))
          (boolean1.11
           (unsafe-procedure-call
            vector?.66
            (unsafe-procedure-call fun/any8762.6)))
          (void2.10 (unsafe-procedure-call fun/void8763.7))
          (boolean3.9
           (unsafe-procedure-call
            boolean?.67
            (unsafe-procedure-call fun/any8764.8))))
      (unsafe-procedure-call fun/vector8765.4))))
(check-by-interp
 '(module
    (define *.109
      (lambda (tmp.67 tmp.68)
        (if (fixnum? tmp.68)
          (if (fixnum? tmp.67) (unsafe-fx* tmp.67 tmp.68) (error 1))
          (error 1))))
    (define >.108
      (lambda (tmp.77 tmp.78)
        (if (fixnum? tmp.78)
          (if (fixnum? tmp.77) (unsafe-fx> tmp.77 tmp.78) (error 6))
          (error 6))))
    (define ascii-char?.107 (lambda (tmp.94) (ascii-char? tmp.94)))
    (define vector-init-loop.55
      (lambda (len.56 i.58 vec.57)
        (if (eq? len.56 i.58)
          vec.57
          (begin
            (unsafe-vector-set! vec.57 i.58 0)
            (unsafe-procedure-call
             vector-init-loop.55
             len.56
             (unsafe-fx+ i.58 1)
             vec.57)))))
    (define make-init-vector.1
      (lambda (tmp.53)
        (let ((tmp.54 (unsafe-make-vector tmp.53)))
          (unsafe-procedure-call vector-init-loop.55 tmp.53 0 tmp.54))))
    (define make-vector.106
      (lambda (tmp.81)
        (if (fixnum? tmp.81)
          (unsafe-procedure-call make-init-vector.1 tmp.81)
          (error 8))))
    (define cons.105 (lambda (tmp.100 tmp.101) (cons tmp.100 tmp.101)))
    (define fun/fixnum8791.4
      (lambda (oprand0.19 oprand1.18 oprand2.17)
        (unsafe-procedure-call fun/fixnum8792.13)))
    (define fun/pair8797.5
      (lambda (oprand0.22 oprand1.21 oprand2.20)
        (unsafe-procedure-call fun/pair8798.16)))
    (define fun/error8799.6
      (lambda (oprand0.25 oprand1.24 oprand2.23) (error 158)))
    (define fun/pair8789.7 (lambda () (unsafe-procedure-call fun/pair8790.10)))
    (define fun/pair8788.8
      (lambda (oprand0.28 oprand1.27 oprand2.26)
        (unsafe-procedure-call fun/pair8789.7)))
    (define fun/empty8793.9 (lambda (oprand0.31 oprand1.30 oprand2.29) empty))
    (define fun/pair8790.10
      (lambda () (unsafe-procedure-call cons.105 25 485)))
    (define fun/fixnum8796.11 (lambda (oprand0.34 oprand1.33 oprand2.32) 254))
    (define fun/ascii-char8795.12 (lambda () #\K))
    (define fun/fixnum8792.13 (lambda () 185))
    (define fun/error8800.14
      (lambda (oprand0.37 oprand1.36 oprand2.35) oprand2.35))
    (define fun/ascii-char8794.15
      (lambda (oprand0.40 oprand1.39 oprand2.38)
        (unsafe-procedure-call fun/ascii-char8795.12)))
    (define fun/pair8798.16
      (lambda () (unsafe-procedure-call cons.105 24 277)))
    (unsafe-procedure-call
     fun/pair8788.8
     (unsafe-procedure-call
      >.108
      (unsafe-procedure-call
       fun/fixnum8791.4
       (unsafe-procedure-call fun/empty8793.9 250 #t (error 11))
       (if #f empty empty)
       (unsafe-procedure-call
        ascii-char?.107
        (unsafe-procedure-call make-vector.106 8)))
      (if #t 182 209))
     (unsafe-procedure-call
      fun/ascii-char8794.15
      (unsafe-procedure-call
       *.109
       (let ((error0.44 (error 211))
             (fixnum1.43 224)
             (vector2.42 (unsafe-procedure-call make-vector.106 8))
             (procedure3.41 (lambda () #\X)))
         226)
       (unsafe-procedure-call fun/fixnum8796.11 174 (error 224) (void)))
      (unsafe-procedure-call
       fun/pair8797.5
       (unsafe-procedure-call fun/error8799.6 empty 6 (void))
       (if #t (void) (void))
       (unsafe-procedure-call
        fun/ascii-char8794.15
        79
        (unsafe-procedure-call cons.105 43 357)
        (unsafe-procedure-call make-vector.106 8)))
      (if #f
        (unsafe-procedure-call make-vector.106 8)
        (unsafe-procedure-call make-vector.106 8)))
     (unsafe-procedure-call
      fun/error8800.14
      (if #t
        (unsafe-procedure-call make-vector.106 8)
        (unsafe-procedure-call make-vector.106 8))
      (let ((vector0.48 (unsafe-procedure-call make-vector.106 8))
            (vector1.47 (unsafe-procedure-call make-vector.106 8))
            (ascii-char2.46 #\])
            (vector3.45 (unsafe-procedure-call make-vector.106 8)))
        (void))
      (let ((boolean0.52 #t)
            (void1.51 (void))
            (boolean2.50 #f)
            (boolean3.49 #f))
        (error 220))))))
(check-by-interp
 '(module
    (define fun/error8923.4
      (lambda () (unsafe-procedure-call fun/error8924.14)))
    (define fun/ascii-char8926.5 (lambda () #\x))
    (define fun/empty8929.6
      (lambda () (unsafe-procedure-call fun/empty8930.11)))
    (define fun/void8927.7 (lambda () (unsafe-procedure-call fun/void8928.15)))
    (define fun/ascii-char8921.8
      (lambda () (unsafe-procedure-call fun/ascii-char8922.10)))
    (define fun/error8919.9
      (lambda () (unsafe-procedure-call fun/error8920.12)))
    (define fun/ascii-char8922.10 (lambda () #\k))
    (define fun/empty8930.11 (lambda () empty))
    (define fun/error8920.12 (lambda () (error 185)))
    (define fun/ascii-char8925.13
      (lambda () (unsafe-procedure-call fun/ascii-char8926.5)))
    (define fun/error8924.14 (lambda () (error 130)))
    (define fun/void8928.15 (lambda () (void)))
    (let ((error0.20 (unsafe-procedure-call fun/error8919.9))
          (ascii-char1.19 (unsafe-procedure-call fun/ascii-char8921.8))
          (error2.18 (unsafe-procedure-call fun/error8923.4))
          (ascii-char3.17 (unsafe-procedure-call fun/ascii-char8925.13))
          (void4.16 (unsafe-procedure-call fun/void8927.7)))
      (unsafe-procedure-call fun/empty8929.6))))
(check-by-interp
 '(module
    (define >=.71
      (lambda (tmp.41 tmp.42)
        (if (fixnum? tmp.42)
          (if (fixnum? tmp.41) (unsafe-fx>= tmp.41 tmp.42) (error 7))
          (error 7))))
    (define <=.70
      (lambda (tmp.37 tmp.38)
        (if (fixnum? tmp.38)
          (if (fixnum? tmp.37) (unsafe-fx<= tmp.37 tmp.38) (error 5))
          (error 5))))
    (define |+.69|
      (lambda (tmp.31 tmp.32)
        (if (fixnum? tmp.32)
          (if (fixnum? tmp.31) (unsafe-fx+ tmp.31 tmp.32) (error 2))
          (error 2))))
    (define *.68
      (lambda (tmp.29 tmp.30)
        (if (fixnum? tmp.30)
          (if (fixnum? tmp.29) (unsafe-fx* tmp.29 tmp.30) (error 1))
          (error 1))))
    (define |-.67|
      (lambda (tmp.33 tmp.34)
        (if (fixnum? tmp.34)
          (if (fixnum? tmp.33) (unsafe-fx- tmp.33 tmp.34) (error 3))
          (error 3))))
    (define fun/empty9121.4 (lambda () empty))
    (define fun/ascii-char9123.5 (lambda () #\s))
    (define fun/empty9120.6
      (lambda () (unsafe-procedure-call fun/empty9121.4)))
    (define fun/void9119.7 (lambda () (void)))
    (define fun/ascii-char9122.8
      (lambda () (unsafe-procedure-call fun/ascii-char9123.5)))
    (define fun/void9118.9 (lambda () (unsafe-procedure-call fun/void9119.7)))
    (let ((void0.14 (unsafe-procedure-call fun/void9118.9))
          (fixnum1.13
           (unsafe-procedure-call
            *.68
            (unsafe-procedure-call
             *.68
             (unsafe-procedure-call |-.67| 25 226)
             (unsafe-procedure-call |-.67| 159 56))
            (unsafe-procedure-call
             |-.67|
             (unsafe-procedure-call *.68 192 122)
             (unsafe-procedure-call |-.67| 47 86))))
          (empty2.12 (unsafe-procedure-call fun/empty9120.6))
          (procedure3.11
           (lambda ()
             (unsafe-procedure-call
              <=.70
              (unsafe-procedure-call
               |+.69|
               (unsafe-procedure-call |+.69| 101 114)
               (unsafe-procedure-call |+.69| 88 54))
              (unsafe-procedure-call
               |+.69|
               (unsafe-procedure-call |+.69| 59 2)
               (unsafe-procedure-call |-.67| 47 76)))))
          (ascii-char4.10 (unsafe-procedure-call fun/ascii-char9122.8)))
      (unsafe-procedure-call
       >=.71
       (unsafe-procedure-call
        |-.67|
        (unsafe-procedure-call |+.69| 68 167)
        (unsafe-procedure-call |+.69| 167 157))
       (unsafe-procedure-call
        |-.67|
        (unsafe-procedure-call |-.67| 30 155)
        (unsafe-procedure-call |+.69| 28 101))))))
(check-by-interp
 '(module
    (define <=.78
      (lambda (tmp.46 tmp.47)
        (if (fixnum? tmp.47)
          (if (fixnum? tmp.46) (unsafe-fx<= tmp.46 tmp.47) (error 5))
          (error 5))))
    (define vector?.77 (lambda (tmp.68) (vector? tmp.68)))
    (define vector-init-loop.26
      (lambda (len.27 i.29 vec.28)
        (if (eq? len.27 i.29)
          vec.28
          (begin
            (unsafe-vector-set! vec.28 i.29 0)
            (unsafe-procedure-call
             vector-init-loop.26
             len.27
             (unsafe-fx+ i.29 1)
             vec.28)))))
    (define make-init-vector.1
      (lambda (tmp.24)
        (let ((tmp.25 (unsafe-make-vector tmp.24)))
          (unsafe-procedure-call vector-init-loop.26 tmp.24 0 tmp.25))))
    (define make-vector.76
      (lambda (tmp.52)
        (if (fixnum? tmp.52)
          (unsafe-procedure-call make-init-vector.1 tmp.52)
          (error 8))))
    (define fun/error9127.4 (lambda () (error 167)))
    (define fun/ascii-char9131.5 (lambda () #\o))
    (define fun/empty9128.6 (lambda () empty))
    (define fun/ascii-char9132.7 (lambda () #\p))
    (define fun/ascii-char9130.8 (lambda () #\p))
    (define fun/vector9133.9
      (lambda () (unsafe-procedure-call make-vector.76 8)))
    (define fun/ascii-char9129.10 (lambda () #\P))
    (define fun/vector9134.11
      (lambda () (unsafe-procedure-call make-vector.76 8)))
    (define fun/void9126.12 (lambda () (void)))
    (define fun/ascii-char9135.13 (lambda () #\u))
    (if (unsafe-procedure-call vector?.77 (if #f empty (void)))
      (let ((procedure0.18 (lambda () (unsafe-procedure-call fun/void9126.12)))
            (error1.17 (unsafe-procedure-call fun/error9127.4))
            (empty2.16 (unsafe-procedure-call fun/empty9128.6))
            (ascii-char3.15 (unsafe-procedure-call fun/ascii-char9129.10))
            (ascii-char4.14 (unsafe-procedure-call fun/ascii-char9130.8)))
        (unsafe-procedure-call fun/ascii-char9131.5))
      (let ((procedure0.23
             (lambda () (unsafe-procedure-call fun/ascii-char9132.7)))
            (vector1.22 (unsafe-procedure-call fun/vector9133.9))
            (vector2.21 (unsafe-procedure-call fun/vector9134.11))
            (ascii-char3.20 (unsafe-procedure-call fun/ascii-char9135.13))
            (boolean4.19 (unsafe-procedure-call <=.78 42 157)))
        (if (procedure? procedure0.23)
          (if (eq? (unsafe-procedure-arity procedure0.23) 0)
            (unsafe-procedure-call procedure0.23)
            (error 42))
          (error 43))))))
(check-by-interp
 '(module
    (define fun/ascii-char9194.4 (lambda () #\f))
    (define fun/void9197.5 (lambda () (unsafe-procedure-call fun/void9198.8)))
    (define fun/error9195.6
      (lambda () (unsafe-procedure-call fun/error9196.13)))
    (define fun/empty9199.7
      (lambda () (unsafe-procedure-call fun/empty9200.10)))
    (define fun/void9198.8 (lambda () (void)))
    (define fun/ascii-char9193.9
      (lambda () (unsafe-procedure-call fun/ascii-char9194.4)))
    (define fun/empty9200.10 (lambda () empty))
    (define fun/void9202.11 (lambda () (void)))
    (define fun/error9191.12
      (lambda () (unsafe-procedure-call fun/error9192.14)))
    (define fun/error9196.13 (lambda () (error 198)))
    (define fun/error9192.14 (lambda () (error 213)))
    (define fun/void9201.15
      (lambda () (unsafe-procedure-call fun/void9202.11)))
    (let ((procedure0.20 (lambda () (unsafe-procedure-call fun/error9191.12)))
          (ascii-char1.19 (unsafe-procedure-call fun/ascii-char9193.9))
          (error2.18 (unsafe-procedure-call fun/error9195.6))
          (void3.17 (unsafe-procedure-call fun/void9197.5))
          (empty4.16 (unsafe-procedure-call fun/empty9199.7)))
      (unsafe-procedure-call fun/void9201.15))))
(check-by-interp
 '(module
    (define |-.74|
      (lambda (tmp.37 tmp.38)
        (if (fixnum? tmp.38)
          (if (fixnum? tmp.37) (unsafe-fx- tmp.37 tmp.38) (error 3))
          (error 3))))
    (define *.73
      (lambda (tmp.33 tmp.34)
        (if (fixnum? tmp.34)
          (if (fixnum? tmp.33) (unsafe-fx* tmp.33 tmp.34) (error 1))
          (error 1))))
    (define |+.72|
      (lambda (tmp.35 tmp.36)
        (if (fixnum? tmp.36)
          (if (fixnum? tmp.35) (unsafe-fx+ tmp.35 tmp.36) (error 2))
          (error 2))))
    (define vector-init-loop.21
      (lambda (len.22 i.24 vec.23)
        (if (eq? len.22 i.24)
          vec.23
          (begin
            (unsafe-vector-set! vec.23 i.24 0)
            (unsafe-procedure-call
             vector-init-loop.21
             len.22
             (unsafe-fx+ i.24 1)
             vec.23)))))
    (define make-init-vector.1
      (lambda (tmp.19)
        (let ((tmp.20 (unsafe-make-vector tmp.19)))
          (unsafe-procedure-call vector-init-loop.21 tmp.19 0 tmp.20))))
    (define make-vector.71
      (lambda (tmp.47)
        (if (fixnum? tmp.47)
          (unsafe-procedure-call make-init-vector.1 tmp.47)
          (error 8))))
    (define fun/ascii-char9893.4 (lambda () #\Q))
    (define fun/void9890.5 (lambda () (unsafe-procedure-call fun/void9891.9)))
    (define fun/ascii-char9887.6 (lambda () #\]))
    (define fun/ascii-char9892.7
      (lambda () (unsafe-procedure-call fun/ascii-char9893.4)))
    (define fun/void9884.8 (lambda () (unsafe-procedure-call fun/void9885.12)))
    (define fun/void9891.9 (lambda () (void)))
    (define fun/vector9888.10
      (lambda () (unsafe-procedure-call fun/vector9889.13)))
    (define fun/ascii-char9886.11
      (lambda () (unsafe-procedure-call fun/ascii-char9887.6)))
    (define fun/void9885.12 (lambda () (void)))
    (define fun/vector9889.13
      (lambda () (unsafe-procedure-call make-vector.71 8)))
    (let ((void0.18 (unsafe-procedure-call fun/void9884.8))
          (ascii-char1.17 (unsafe-procedure-call fun/ascii-char9886.11))
          (procedure2.16 (lambda () (unsafe-procedure-call fun/vector9888.10)))
          (void3.15 (unsafe-procedure-call fun/void9890.5))
          (fixnum4.14
           (unsafe-procedure-call
            *.73
            (unsafe-procedure-call
             *.73
             (unsafe-procedure-call |+.72| 168 24)
             (unsafe-procedure-call *.73 207 124))
            (unsafe-procedure-call
             *.73
             (unsafe-procedure-call *.73 127 249)
             (unsafe-procedure-call |-.74| 196 211)))))
      (unsafe-procedure-call fun/ascii-char9892.7))))
(check-by-interp
 '(module
    (define <=.73
      (lambda (tmp.38 tmp.39)
        (if (fixnum? tmp.39)
          (if (fixnum? tmp.38) (unsafe-fx<= tmp.38 tmp.39) (error 5))
          (error 5))))
    (define *.72
      (lambda (tmp.30 tmp.31)
        (if (fixnum? tmp.31)
          (if (fixnum? tmp.30) (unsafe-fx* tmp.30 tmp.31) (error 1))
          (error 1))))
    (define |-.71|
      (lambda (tmp.34 tmp.35)
        (if (fixnum? tmp.35)
          (if (fixnum? tmp.34) (unsafe-fx- tmp.34 tmp.35) (error 3))
          (error 3))))
    (define |+.70|
      (lambda (tmp.32 tmp.33)
        (if (fixnum? tmp.33)
          (if (fixnum? tmp.32) (unsafe-fx+ tmp.32 tmp.33) (error 2))
          (error 2))))
    (define void?.69 (lambda (tmp.56) (void? tmp.56)))
    (define vector-init-loop.18
      (lambda (len.19 i.21 vec.20)
        (if (eq? len.19 i.21)
          vec.20
          (begin
            (unsafe-vector-set! vec.20 i.21 0)
            (unsafe-procedure-call
             vector-init-loop.18
             len.19
             (unsafe-fx+ i.21 1)
             vec.20)))))
    (define make-init-vector.1
      (lambda (tmp.16)
        (let ((tmp.17 (unsafe-make-vector tmp.16)))
          (unsafe-procedure-call vector-init-loop.18 tmp.16 0 tmp.17))))
    (define make-vector.68
      (lambda (tmp.44)
        (if (fixnum? tmp.44)
          (unsafe-procedure-call make-init-vector.1 tmp.44)
          (error 8))))
    (define fun/void10282.4 (lambda () (void)))
    (define fun/empty10284.5 (lambda () empty))
    (define fun/vector10278.6
      (lambda () (unsafe-procedure-call fun/vector10279.8)))
    (define fun/empty10283.7
      (lambda () (unsafe-procedure-call fun/empty10284.5)))
    (define fun/vector10279.8
      (lambda () (unsafe-procedure-call make-vector.68 8)))
    (define fun/any10280.9 (lambda () #f))
    (define fun/void10281.10
      (lambda () (unsafe-procedure-call fun/void10282.4)))
    (let ((vector0.15 (unsafe-procedure-call fun/vector10278.6))
          (boolean1.14
           (unsafe-procedure-call
            void?.69
            (unsafe-procedure-call fun/any10280.9)))
          (fixnum2.13
           (unsafe-procedure-call
            |+.70|
            (unsafe-procedure-call
             |-.71|
             (unsafe-procedure-call |+.70| 119 181)
             (unsafe-procedure-call |+.70| 72 105))
            (unsafe-procedure-call
             |-.71|
             (unsafe-procedure-call |+.70| 81 154)
             (unsafe-procedure-call *.72 141 81))))
          (procedure3.12 (lambda () (unsafe-procedure-call fun/void10281.10)))
          (boolean4.11
           (unsafe-procedure-call
            <=.73
            (unsafe-procedure-call
             *.72
             (unsafe-procedure-call |-.71| 176 127)
             (unsafe-procedure-call |+.70| 186 126))
            (unsafe-procedure-call
             |-.71|
             (unsafe-procedure-call *.72 75 253)
             (unsafe-procedure-call |-.71| 185 207)))))
      (unsafe-procedure-call fun/empty10283.7))))
(check-by-interp
 '(module
    (define *.69
      (lambda (tmp.29 tmp.30)
        (if (fixnum? tmp.30)
          (if (fixnum? tmp.29) (unsafe-fx* tmp.29 tmp.30) (error 1))
          (error 1))))
    (define |-.68|
      (lambda (tmp.33 tmp.34)
        (if (fixnum? tmp.34)
          (if (fixnum? tmp.33) (unsafe-fx- tmp.33 tmp.34) (error 3))
          (error 3))))
    (define |+.67|
      (lambda (tmp.31 tmp.32)
        (if (fixnum? tmp.32)
          (if (fixnum? tmp.31) (unsafe-fx+ tmp.31 tmp.32) (error 2))
          (error 2))))
    (define fun/error10623.4
      (lambda () (unsafe-procedure-call fun/error10624.5)))
    (define fun/error10624.5 (lambda () (error 75)))
    (define fun/void10626.6 (lambda () (void)))
    (define fun/void10627.7
      (lambda () (unsafe-procedure-call fun/void10628.8)))
    (define fun/void10628.8 (lambda () (void)))
    (define fun/void10625.9
      (lambda () (unsafe-procedure-call fun/void10626.6)))
    (let ((error0.14 (unsafe-procedure-call fun/error10623.4))
          (void1.13 (unsafe-procedure-call fun/void10625.9))
          (fixnum2.12
           (unsafe-procedure-call
            |+.67|
            (unsafe-procedure-call
             |+.67|
             (unsafe-procedure-call |+.67| 177 96)
             (unsafe-procedure-call |-.68| 65 207))
            (unsafe-procedure-call
             *.69
             (unsafe-procedure-call |-.68| 170 11)
             (unsafe-procedure-call *.69 52 179))))
          (fixnum3.11
           (unsafe-procedure-call
            *.69
            (unsafe-procedure-call
             |+.67|
             (unsafe-procedure-call |-.68| 72 203)
             (unsafe-procedure-call |+.67| 144 243))
            (unsafe-procedure-call
             |-.68|
             (unsafe-procedure-call |-.68| 179 253)
             (unsafe-procedure-call *.69 42 49))))
          (fixnum4.10
           (unsafe-procedure-call
            |-.68|
            (unsafe-procedure-call
             |+.67|
             (unsafe-procedure-call *.69 47 226)
             (unsafe-procedure-call |-.68| 208 124))
            (unsafe-procedure-call
             |-.68|
             (unsafe-procedure-call |+.67| 230 152)
             (unsafe-procedure-call |+.67| 214 219)))))
      (unsafe-procedure-call fun/void10627.7))))
(check-by-interp
 '(module
    (define fixnum?.73 (lambda (tmp.57) (fixnum? tmp.57)))
    (define vector-init-loop.22
      (lambda (len.23 i.25 vec.24)
        (if (eq? len.23 i.25)
          vec.24
          (begin
            (unsafe-vector-set! vec.24 i.25 0)
            (unsafe-procedure-call
             vector-init-loop.22
             len.23
             (unsafe-fx+ i.25 1)
             vec.24)))))
    (define make-init-vector.1
      (lambda (tmp.20)
        (let ((tmp.21 (unsafe-make-vector tmp.20)))
          (unsafe-procedure-call vector-init-loop.22 tmp.20 0 tmp.21))))
    (define make-vector.72
      (lambda (tmp.48)
        (if (fixnum? tmp.48)
          (unsafe-procedure-call make-init-vector.1 tmp.48)
          (error 8))))
    (define fun/error10718.4 (lambda () (error 183)))
    (define fun/any10714.5
      (lambda () (unsafe-procedure-call make-vector.72 8)))
    (define fun/void10715.6
      (lambda () (unsafe-procedure-call fun/void10716.14)))
    (define fun/vector10712.7
      (lambda () (unsafe-procedure-call fun/vector10713.11)))
    (define fun/ascii-char10710.8
      (lambda () (unsafe-procedure-call fun/ascii-char10711.12)))
    (define fun/empty10708.9
      (lambda () (unsafe-procedure-call fun/empty10709.13)))
    (define fun/error10717.10
      (lambda () (unsafe-procedure-call fun/error10718.4)))
    (define fun/vector10713.11
      (lambda () (unsafe-procedure-call make-vector.72 8)))
    (define fun/ascii-char10711.12 (lambda () #\[))
    (define fun/empty10709.13 (lambda () empty))
    (define fun/void10716.14 (lambda () (void)))
    (let ((empty0.19 (unsafe-procedure-call fun/empty10708.9))
          (procedure1.18
           (lambda () (unsafe-procedure-call fun/ascii-char10710.8)))
          (vector2.17 (unsafe-procedure-call fun/vector10712.7))
          (boolean3.16
           (unsafe-procedure-call
            fixnum?.73
            (unsafe-procedure-call fun/any10714.5)))
          (void4.15 (unsafe-procedure-call fun/void10715.6)))
      (unsafe-procedure-call fun/error10717.10))))
(check-by-interp
 '(module
    (define unsafe-vector-ref.3
      (lambda (tmp.28 tmp.29)
        (if (unsafe-fx< tmp.29 (unsafe-vector-length tmp.28))
          (if (unsafe-fx>= tmp.29 0)
            (unsafe-vector-ref tmp.28 tmp.29)
            (error 11))
          (error 11))))
    (define vector-ref.72
      (lambda (tmp.50 tmp.51)
        (if (fixnum? tmp.51)
          (if (vector? tmp.50)
            (unsafe-procedure-call unsafe-vector-ref.3 tmp.50 tmp.51)
            (error 11))
          (error 11))))
    (define |+.71|
      (lambda (tmp.33 tmp.34)
        (if (fixnum? tmp.34)
          (if (fixnum? tmp.33) (unsafe-fx+ tmp.33 tmp.34) (error 2))
          (error 2))))
    (define |-.70|
      (lambda (tmp.35 tmp.36)
        (if (fixnum? tmp.36)
          (if (fixnum? tmp.35) (unsafe-fx- tmp.35 tmp.36) (error 3))
          (error 3))))
    (define vector-init-loop.19
      (lambda (len.20 i.22 vec.21)
        (if (eq? len.20 i.22)
          vec.21
          (begin
            (unsafe-vector-set! vec.21 i.22 0)
            (unsafe-procedure-call
             vector-init-loop.19
             len.20
             (unsafe-fx+ i.22 1)
             vec.21)))))
    (define make-init-vector.1
      (lambda (tmp.17)
        (let ((tmp.18 (unsafe-make-vector tmp.17)))
          (unsafe-procedure-call vector-init-loop.19 tmp.17 0 tmp.18))))
    (define make-vector.69
      (lambda (tmp.45)
        (if (fixnum? tmp.45)
          (unsafe-procedure-call make-init-vector.1 tmp.45)
          (error 8))))
    (define fun/void10791.4
      (lambda () (unsafe-procedure-call fun/void10792.10)))
    (define fun/ascii-char10794.5 (lambda () #\F))
    (define fun/ascii-char10796.6 (lambda () #\j))
    (define fun/ascii-char10795.7
      (lambda () (unsafe-procedure-call fun/ascii-char10796.6)))
    (define fun/vector10789.8
      (lambda () (unsafe-procedure-call fun/vector10790.9)))
    (define fun/vector10790.9
      (lambda () (unsafe-procedure-call make-vector.69 8)))
    (define fun/void10792.10 (lambda () (void)))
    (define fun/ascii-char10793.11
      (lambda () (unsafe-procedure-call fun/ascii-char10794.5)))
    (let ((vector0.16 (unsafe-procedure-call fun/vector10789.8))
          (procedure1.15 (lambda () (unsafe-procedure-call fun/void10791.4)))
          (ascii-char2.14 (unsafe-procedure-call fun/ascii-char10793.11))
          (procedure3.13
           (lambda () (unsafe-procedure-call fun/ascii-char10795.7)))
          (procedure4.12
           (lambda ()
             (unsafe-procedure-call
              |+.71|
              (unsafe-procedure-call
               |-.70|
               (unsafe-procedure-call |-.70| 90 126)
               (unsafe-procedure-call |-.70| 96 108))
              (unsafe-procedure-call
               |+.71|
               (unsafe-procedure-call |+.71| 101 105)
               (unsafe-procedure-call |-.70| 163 189))))))
      (unsafe-procedure-call vector-ref.72 vector0.16 1))))
(check-by-interp
 '(module
    (define cons.75 (lambda (tmp.69 tmp.70) (cons tmp.69 tmp.70)))
    (define vector-init-loop.24
      (lambda (len.25 i.27 vec.26)
        (if (eq? len.25 i.27)
          vec.26
          (begin
            (unsafe-vector-set! vec.26 i.27 0)
            (unsafe-procedure-call
             vector-init-loop.24
             len.25
             (unsafe-fx+ i.27 1)
             vec.26)))))
    (define make-init-vector.1
      (lambda (tmp.22)
        (let ((tmp.23 (unsafe-make-vector tmp.22)))
          (unsafe-procedure-call vector-init-loop.24 tmp.22 0 tmp.23))))
    (define make-vector.74
      (lambda (tmp.50)
        (if (fixnum? tmp.50)
          (unsafe-procedure-call make-init-vector.1 tmp.50)
          (error 8))))
    (define fun/vector11667.4
      (lambda () (unsafe-procedure-call fun/vector11668.9)))
    (define fun/pair11669.5
      (lambda () (unsafe-procedure-call fun/pair11670.11)))
    (define fun/void11665.6
      (lambda () (unsafe-procedure-call fun/void11666.14)))
    (define fun/empty11663.7
      (lambda () (unsafe-procedure-call fun/empty11664.15)))
    (define fun/error11662.8 (lambda () (error 142)))
    (define fun/vector11668.9
      (lambda () (unsafe-procedure-call make-vector.74 8)))
    (define fun/empty11660.10 (lambda () empty))
    (define fun/pair11670.11
      (lambda () (unsafe-procedure-call cons.75 150 417)))
    (define fun/error11661.12
      (lambda () (unsafe-procedure-call fun/error11662.8)))
    (define fun/empty11659.13
      (lambda () (unsafe-procedure-call fun/empty11660.10)))
    (define fun/void11666.14 (lambda () (void)))
    (define fun/empty11664.15 (lambda () empty))
    (let ((procedure0.21 (lambda () (unsafe-procedure-call fun/empty11659.13)))
          (error1.20 (unsafe-procedure-call fun/error11661.12))
          (empty2.19 (unsafe-procedure-call fun/empty11663.7))
          (void3.18 (unsafe-procedure-call fun/void11665.6))
          (vector4.17 (unsafe-procedure-call fun/vector11667.4))
          (procedure5.16 (lambda () (unsafe-procedure-call fun/pair11669.5))))
      (if (procedure? procedure0.21)
        (if (eq? (unsafe-procedure-arity procedure0.21) 0)
          (unsafe-procedure-call procedure0.21)
          (error 42))
        (error 43)))))
(check-by-interp
 '(module
    (define |+.76|
      (lambda (tmp.38 tmp.39)
        (if (fixnum? tmp.39)
          (if (fixnum? tmp.38) (unsafe-fx+ tmp.38 tmp.39) (error 2))
          (error 2))))
    (define *.75
      (lambda (tmp.36 tmp.37)
        (if (fixnum? tmp.37)
          (if (fixnum? tmp.36) (unsafe-fx* tmp.36 tmp.37) (error 1))
          (error 1))))
    (define |-.74|
      (lambda (tmp.40 tmp.41)
        (if (fixnum? tmp.41)
          (if (fixnum? tmp.40) (unsafe-fx- tmp.40 tmp.41) (error 3))
          (error 3))))
    (define fun/empty12026.4
      (lambda () (unsafe-procedure-call fun/empty12027.12)))
    (define fun/error12024.5
      (lambda () (unsafe-procedure-call fun/error12025.9)))
    (define fun/ascii-char12030.6
      (lambda () (unsafe-procedure-call fun/ascii-char12031.14)))
    (define fun/error12034.7
      (lambda () (unsafe-procedure-call fun/error12035.15)))
    (define fun/error12028.8
      (lambda () (unsafe-procedure-call fun/error12029.13)))
    (define fun/error12025.9 (lambda () (error 190)))
    (define fun/ascii-char12033.10 (lambda () #\k))
    (define fun/ascii-char12032.11
      (lambda () (unsafe-procedure-call fun/ascii-char12033.10)))
    (define fun/empty12027.12 (lambda () empty))
    (define fun/error12029.13 (lambda () (error 244)))
    (define fun/ascii-char12031.14 (lambda () #\]))
    (define fun/error12035.15 (lambda () (error 38)))
    (let ((fixnum0.21
           (unsafe-procedure-call
            |+.76|
            (unsafe-procedure-call
             |-.74|
             (unsafe-procedure-call
              |+.76|
              (unsafe-procedure-call |-.74| 20 248)
              (unsafe-procedure-call *.75 206 242))
             (unsafe-procedure-call
              |-.74|
              (unsafe-procedure-call |+.76| 165 249)
              (unsafe-procedure-call *.75 245 99)))
            (unsafe-procedure-call
             *.75
             (unsafe-procedure-call
              |-.74|
              (unsafe-procedure-call *.75 200 34)
              (unsafe-procedure-call |+.76| 43 207))
             (unsafe-procedure-call
              *.75
              (unsafe-procedure-call |-.74| 204 93)
              (unsafe-procedure-call *.75 55 91)))))
          (error1.20 (unsafe-procedure-call fun/error12024.5))
          (empty2.19 (unsafe-procedure-call fun/empty12026.4))
          (error3.18 (unsafe-procedure-call fun/error12028.8))
          (ascii-char4.17 (unsafe-procedure-call fun/ascii-char12030.6))
          (ascii-char5.16 (unsafe-procedure-call fun/ascii-char12032.11)))
      (unsafe-procedure-call fun/error12034.7))))
(check-by-interp
 '(module
    (define cons.74 (lambda (tmp.69 tmp.70) (cons tmp.69 tmp.70)))
    (define fun/error13992.4 (lambda () (error 29)))
    (define fun/ascii-char13987.5
      (lambda () (unsafe-procedure-call fun/ascii-char13988.11)))
    (define fun/void13994.6 (lambda () (void)))
    (define fun/void13996.7 (lambda () (void)))
    (define fun/void13990.8 (lambda () (void)))
    (define fun/pair13985.9
      (lambda () (unsafe-procedure-call fun/pair13986.12)))
    (define fun/void13993.10
      (lambda () (unsafe-procedure-call fun/void13994.6)))
    (define fun/ascii-char13988.11 (lambda () #\j))
    (define fun/pair13986.12
      (lambda () (unsafe-procedure-call cons.74 112 427)))
    (define fun/error13991.13
      (lambda () (unsafe-procedure-call fun/error13992.4)))
    (define fun/void13995.14
      (lambda () (unsafe-procedure-call fun/void13996.7)))
    (define fun/void13989.15
      (lambda () (unsafe-procedure-call fun/void13990.8)))
    (let ((procedure0.21 (lambda () (unsafe-procedure-call fun/pair13985.9)))
          (ascii-char1.20 (unsafe-procedure-call fun/ascii-char13987.5))
          (void2.19 (unsafe-procedure-call fun/void13989.15))
          (error3.18 (unsafe-procedure-call fun/error13991.13))
          (void4.17 (unsafe-procedure-call fun/void13993.10))
          (void5.16 (unsafe-procedure-call fun/void13995.14)))
      (if (procedure? procedure0.21)
        (if (eq? (unsafe-procedure-arity procedure0.21) 0)
          (unsafe-procedure-call procedure0.21)
          (error 42))
        (error 43)))))
(check-by-interp
 '(module
    (define ascii-char?.79 (lambda (tmp.63) (ascii-char? tmp.63)))
    (define fixnum?.78 (lambda (tmp.59) (fixnum? tmp.59)))
    (define |+.77|
      (lambda (tmp.38 tmp.39)
        (if (fixnum? tmp.39)
          (if (fixnum? tmp.38) (unsafe-fx+ tmp.38 tmp.39) (error 2))
          (error 2))))
    (define *.76
      (lambda (tmp.36 tmp.37)
        (if (fixnum? tmp.37)
          (if (fixnum? tmp.36) (unsafe-fx* tmp.36 tmp.37) (error 1))
          (error 1))))
    (define |-.75|
      (lambda (tmp.40 tmp.41)
        (if (fixnum? tmp.41)
          (if (fixnum? tmp.40) (unsafe-fx- tmp.40 tmp.41) (error 3))
          (error 3))))
    (define vector-init-loop.24
      (lambda (len.25 i.27 vec.26)
        (if (eq? len.25 i.27)
          vec.26
          (begin
            (unsafe-vector-set! vec.26 i.27 0)
            (unsafe-procedure-call
             vector-init-loop.24
             len.25
             (unsafe-fx+ i.27 1)
             vec.26)))))
    (define make-init-vector.1
      (lambda (tmp.22)
        (let ((tmp.23 (unsafe-make-vector tmp.22)))
          (unsafe-procedure-call vector-init-loop.24 tmp.22 0 tmp.23))))
    (define make-vector.74
      (lambda (tmp.50)
        (if (fixnum? tmp.50)
          (unsafe-procedure-call make-init-vector.1 tmp.50)
          (error 8))))
    (define fun/vector14738.4
      (lambda () (unsafe-procedure-call fun/vector14739.15)))
    (define fun/vector14745.5
      (lambda () (unsafe-procedure-call make-vector.74 8)))
    (define fun/vector14744.6
      (lambda () (unsafe-procedure-call fun/vector14745.5)))
    (define fun/any14740.7 (lambda () (unsafe-procedure-call fun/any14741.12)))
    (define fun/ascii-char14748.8
      (lambda () (unsafe-procedure-call fun/ascii-char14749.14)))
    (define fun/ascii-char14742.9
      (lambda () (unsafe-procedure-call fun/ascii-char14743.13)))
    (define fun/any14746.10
      (lambda () (unsafe-procedure-call fun/any14747.11)))
    (define fun/any14747.11 (lambda () empty))
    (define fun/any14741.12
      (lambda () (unsafe-procedure-call make-vector.74 8)))
    (define fun/ascii-char14743.13 (lambda () #\f))
    (define fun/ascii-char14749.14 (lambda () #\z))
    (define fun/vector14739.15
      (lambda () (unsafe-procedure-call make-vector.74 8)))
    (let ((vector0.21 (unsafe-procedure-call fun/vector14738.4))
          (fixnum1.20
           (unsafe-procedure-call
            |+.77|
            (unsafe-procedure-call
             *.76
             (unsafe-procedure-call
              *.76
              (unsafe-procedure-call |-.75| 45 247)
              (unsafe-procedure-call |-.75| 119 239))
             (unsafe-procedure-call
              |+.77|
              (unsafe-procedure-call |-.75| 100 45)
              (unsafe-procedure-call *.76 251 105)))
            (unsafe-procedure-call
             *.76
             (unsafe-procedure-call
              |-.75|
              (unsafe-procedure-call *.76 114 238)
              (unsafe-procedure-call *.76 230 88))
             (unsafe-procedure-call
              |-.75|
              (unsafe-procedure-call |+.77| 250 216)
              (unsafe-procedure-call |+.77| 89 76)))))
          (boolean2.19
           (unsafe-procedure-call
            fixnum?.78
            (unsafe-procedure-call fun/any14740.7)))
          (ascii-char3.18 (unsafe-procedure-call fun/ascii-char14742.9))
          (vector4.17 (unsafe-procedure-call fun/vector14744.6))
          (procedure5.16
           (lambda ()
             (unsafe-procedure-call
              ascii-char?.79
              (unsafe-procedure-call fun/any14746.10)))))
      (unsafe-procedure-call fun/ascii-char14748.8))))
(check-by-interp
 '(module
    (define procedure?.76 (lambda (tmp.66) (procedure? tmp.66)))
    (define *.75
      (lambda (tmp.34 tmp.35)
        (if (fixnum? tmp.35)
          (if (fixnum? tmp.34) (unsafe-fx* tmp.34 tmp.35) (error 1))
          (error 1))))
    (define |-.74|
      (lambda (tmp.38 tmp.39)
        (if (fixnum? tmp.39)
          (if (fixnum? tmp.38) (unsafe-fx- tmp.38 tmp.39) (error 3))
          (error 3))))
    (define |+.73|
      (lambda (tmp.36 tmp.37)
        (if (fixnum? tmp.37)
          (if (fixnum? tmp.36) (unsafe-fx+ tmp.36 tmp.37) (error 2))
          (error 2))))
    (define vector-init-loop.22
      (lambda (len.23 i.25 vec.24)
        (if (eq? len.23 i.25)
          vec.24
          (begin
            (unsafe-vector-set! vec.24 i.25 0)
            (unsafe-procedure-call
             vector-init-loop.22
             len.23
             (unsafe-fx+ i.25 1)
             vec.24)))))
    (define make-init-vector.1
      (lambda (tmp.20)
        (let ((tmp.21 (unsafe-make-vector tmp.20)))
          (unsafe-procedure-call vector-init-loop.22 tmp.20 0 tmp.21))))
    (define make-vector.72
      (lambda (tmp.48)
        (if (fixnum? tmp.48)
          (unsafe-procedure-call make-init-vector.1 tmp.48)
          (error 8))))
    (define fun/ascii-char14780.4
      (lambda () (unsafe-procedure-call fun/ascii-char14781.11)))
    (define fun/vector14772.5
      (lambda () (unsafe-procedure-call fun/vector14773.8)))
    (define fun/empty14779.6 (lambda () empty))
    (define fun/any14775.7 (lambda () 147))
    (define fun/vector14773.8
      (lambda () (unsafe-procedure-call make-vector.72 8)))
    (define fun/vector14777.9
      (lambda () (unsafe-procedure-call make-vector.72 8)))
    (define fun/empty14778.10
      (lambda () (unsafe-procedure-call fun/empty14779.6)))
    (define fun/ascii-char14781.11 (lambda () #\Z))
    (define fun/vector14776.12
      (lambda () (unsafe-procedure-call fun/vector14777.9)))
    (define fun/any14774.13 (lambda () (unsafe-procedure-call fun/any14775.7)))
    (let ((fixnum0.19
           (unsafe-procedure-call
            *.75
            (unsafe-procedure-call
             |-.74|
             (unsafe-procedure-call
              |+.73|
              (unsafe-procedure-call |+.73| 228 49)
              (unsafe-procedure-call |+.73| 11 111))
             (unsafe-procedure-call
              |+.73|
              (unsafe-procedure-call |-.74| 17 94)
              (unsafe-procedure-call *.75 83 228)))
            (unsafe-procedure-call
             |-.74|
             (unsafe-procedure-call
              *.75
              (unsafe-procedure-call |-.74| 76 30)
              (unsafe-procedure-call |+.73| 20 59))
             (unsafe-procedure-call
              |-.74|
              (unsafe-procedure-call |-.74| 248 63)
              (unsafe-procedure-call *.75 59 35)))))
          (vector1.18 (unsafe-procedure-call fun/vector14772.5))
          (boolean2.17
           (unsafe-procedure-call
            procedure?.76
            (unsafe-procedure-call fun/any14774.13)))
          (vector3.16 (unsafe-procedure-call fun/vector14776.12))
          (fixnum4.15
           (unsafe-procedure-call
            |-.74|
            (unsafe-procedure-call
             |-.74|
             (unsafe-procedure-call
              |-.74|
              (unsafe-procedure-call *.75 35 53)
              (unsafe-procedure-call |+.73| 152 36))
             (unsafe-procedure-call
              |-.74|
              (unsafe-procedure-call |+.73| 147 111)
              (unsafe-procedure-call |-.74| 250 208)))
            (unsafe-procedure-call
             |+.73|
             (unsafe-procedure-call
              |+.73|
              (unsafe-procedure-call |+.73| 245 114)
              (unsafe-procedure-call *.75 118 89))
             (unsafe-procedure-call
              |-.74|
              (unsafe-procedure-call *.75 148 242)
              (unsafe-procedure-call |-.74| 212 75)))))
          (empty5.14 (unsafe-procedure-call fun/empty14778.10)))
      (unsafe-procedure-call fun/ascii-char14780.4))))
(check-by-interp
 '(module
    (define ascii-char?.77 (lambda (tmp.65) (ascii-char? tmp.65)))
    (define cons.76 (lambda (tmp.71 tmp.72) (cons tmp.71 tmp.72)))
    (define fun/error15417.4 (lambda () (error 26)))
    (define fun/any15415.5 (lambda () #f))
    (define fun/pair15426.6
      (lambda () (unsafe-procedure-call fun/pair15427.15)))
    (define fun/error15423.7 (lambda () (error 88)))
    (define fun/void15424.8
      (lambda () (unsafe-procedure-call fun/void15425.13)))
    (define fun/error15421.9 (lambda () (error 37)))
    (define fun/error15418.10
      (lambda () (unsafe-procedure-call fun/error15419.11)))
    (define fun/error15419.11 (lambda () (error 229)))
    (define fun/error15422.12
      (lambda () (unsafe-procedure-call fun/error15423.7)))
    (define fun/void15425.13 (lambda () (void)))
    (define fun/any15414.14 (lambda () (unsafe-procedure-call fun/any15415.5)))
    (define fun/pair15427.15
      (lambda () (unsafe-procedure-call cons.76 247 511)))
    (define fun/error15416.16
      (lambda () (unsafe-procedure-call fun/error15417.4)))
    (define fun/error15420.17
      (lambda () (unsafe-procedure-call fun/error15421.9)))
    (let ((boolean0.23
           (unsafe-procedure-call
            ascii-char?.77
            (unsafe-procedure-call fun/any15414.14)))
          (error1.22 (unsafe-procedure-call fun/error15416.16))
          (error2.21 (unsafe-procedure-call fun/error15418.10))
          (error3.20 (unsafe-procedure-call fun/error15420.17))
          (error4.19 (unsafe-procedure-call fun/error15422.12))
          (void5.18 (unsafe-procedure-call fun/void15424.8)))
      (unsafe-procedure-call fun/pair15426.6))))
(check-by-interp
 '(module
    (define |+.76|
      (lambda (tmp.38 tmp.39)
        (if (fixnum? tmp.39)
          (if (fixnum? tmp.38) (unsafe-fx+ tmp.38 tmp.39) (error 2))
          (error 2))))
    (define |-.75|
      (lambda (tmp.40 tmp.41)
        (if (fixnum? tmp.41)
          (if (fixnum? tmp.40) (unsafe-fx- tmp.40 tmp.41) (error 3))
          (error 3))))
    (define *.74
      (lambda (tmp.36 tmp.37)
        (if (fixnum? tmp.37)
          (if (fixnum? tmp.36) (unsafe-fx* tmp.36 tmp.37) (error 1))
          (error 1))))
    (define fun/ascii-char16435.4
      (lambda () (unsafe-procedure-call fun/ascii-char16436.10)))
    (define fun/ascii-char16444.5 (lambda () #\e))
    (define fun/void16439.6
      (lambda () (unsafe-procedure-call fun/void16440.14)))
    (define fun/ascii-char16437.7
      (lambda () (unsafe-procedure-call fun/ascii-char16438.9)))
    (define fun/error16433.8
      (lambda () (unsafe-procedure-call fun/error16434.13)))
    (define fun/ascii-char16438.9 (lambda () #\H))
    (define fun/ascii-char16436.10 (lambda () #\[))
    (define fun/ascii-char16442.11 (lambda () #\`))
    (define fun/ascii-char16441.12
      (lambda () (unsafe-procedure-call fun/ascii-char16442.11)))
    (define fun/error16434.13 (lambda () (error 239)))
    (define fun/void16440.14 (lambda () (void)))
    (define fun/ascii-char16443.15
      (lambda () (unsafe-procedure-call fun/ascii-char16444.5)))
    (let ((error0.21 (unsafe-procedure-call fun/error16433.8))
          (ascii-char1.20 (unsafe-procedure-call fun/ascii-char16435.4))
          (fixnum2.19
           (unsafe-procedure-call
            |+.76|
            (unsafe-procedure-call
             *.74
             (unsafe-procedure-call
              |-.75|
              (unsafe-procedure-call *.74 240 46)
              (unsafe-procedure-call |-.75| 188 112))
             (unsafe-procedure-call
              |-.75|
              (unsafe-procedure-call *.74 35 210)
              (unsafe-procedure-call |+.76| 107 254)))
            (unsafe-procedure-call
             |-.75|
             (unsafe-procedure-call
              *.74
              (unsafe-procedure-call |-.75| 80 233)
              (unsafe-procedure-call *.74 108 186))
             (unsafe-procedure-call
              |-.75|
              (unsafe-procedure-call |-.75| 234 172)
              (unsafe-procedure-call |+.76| 179 80)))))
          (ascii-char3.18 (unsafe-procedure-call fun/ascii-char16437.7))
          (void4.17 (unsafe-procedure-call fun/void16439.6))
          (ascii-char5.16 (unsafe-procedure-call fun/ascii-char16441.12)))
      (unsafe-procedure-call fun/ascii-char16443.15))))
(check-by-interp
 '(module
    (define >.89
      (lambda (tmp.55 tmp.56)
        (if (fixnum? tmp.56)
          (if (fixnum? tmp.55) (unsafe-fx> tmp.55 tmp.56) (error 6))
          (error 6))))
    (define *.88
      (lambda (tmp.45 tmp.46)
        (if (fixnum? tmp.46)
          (if (fixnum? tmp.45) (unsafe-fx* tmp.45 tmp.46) (error 1))
          (error 1))))
    (define boolean?.87 (lambda (tmp.69) (boolean? tmp.69)))
    (define <=.86
      (lambda (tmp.53 tmp.54)
        (if (fixnum? tmp.54)
          (if (fixnum? tmp.53) (unsafe-fx<= tmp.53 tmp.54) (error 5))
          (error 5))))
    (define |+.85|
      (lambda (tmp.47 tmp.48)
        (if (fixnum? tmp.48)
          (if (fixnum? tmp.47) (unsafe-fx+ tmp.47 tmp.48) (error 2))
          (error 2))))
    (define |-.84|
      (lambda (tmp.49 tmp.50)
        (if (fixnum? tmp.50)
          (if (fixnum? tmp.49) (unsafe-fx- tmp.49 tmp.50) (error 3))
          (error 3))))
    (define vector-init-loop.33
      (lambda (len.34 i.36 vec.35)
        (if (eq? len.34 i.36)
          vec.35
          (begin
            (unsafe-vector-set! vec.35 i.36 0)
            (unsafe-procedure-call
             vector-init-loop.33
             len.34
             (unsafe-fx+ i.36 1)
             vec.35)))))
    (define make-init-vector.1
      (lambda (tmp.31)
        (let ((tmp.32 (unsafe-make-vector tmp.31)))
          (unsafe-procedure-call vector-init-loop.33 tmp.31 0 tmp.32))))
    (define make-vector.83
      (lambda (tmp.59)
        (if (fixnum? tmp.59)
          (unsafe-procedure-call make-init-vector.1 tmp.59)
          (error 8))))
    (define fun/ascii-char16492.4 (lambda () #\h))
    (define fun/empty16491.5 (lambda () empty))
    (define fun/vector16484.6
      (lambda () (unsafe-procedure-call make-vector.83 8)))
    (define fun/empty16487.7 (lambda () empty))
    (define fun/any16488.8 (lambda () 68))
    (define fun/empty16489.9 (lambda () empty))
    (define fun/error16485.10 (lambda () (error 237)))
    (define fun/empty16490.11 (lambda () empty))
    (define fun/error16486.12 (lambda () (error 225)))
    (if (let ((fixnum0.18
               (unsafe-procedure-call
                |-.84|
                (unsafe-procedure-call |-.84| 89 200)
                (unsafe-procedure-call |+.85| 38 241)))
              (vector1.17 (unsafe-procedure-call fun/vector16484.6))
              (error2.16 (unsafe-procedure-call fun/error16485.10))
              (error3.15 (unsafe-procedure-call fun/error16486.12))
              (empty4.14 (unsafe-procedure-call fun/empty16487.7))
              (boolean5.13
               (unsafe-procedure-call
                <=.86
                (unsafe-procedure-call |-.84| 185 172)
                (unsafe-procedure-call |+.85| 136 173))))
          (unsafe-procedure-call
           boolean?.87
           (unsafe-procedure-call fun/any16488.8)))
      (if (if #t #f #f)
        (let ((ascii-char0.24 #\_)
              (ascii-char1.23 #\A)
              (boolean2.22 #f)
              (void3.21 (void))
              (boolean4.20 #f)
              (empty5.19 empty))
          #\U)
        (if #t #\v #\U))
      (let ((empty0.30 (unsafe-procedure-call fun/empty16489.9))
            (fixnum1.29
             (unsafe-procedure-call
              |-.84|
              (unsafe-procedure-call *.88 53 209)
              (unsafe-procedure-call *.88 2 115)))
            (boolean2.28
             (unsafe-procedure-call
              >.89
              (unsafe-procedure-call *.88 94 22)
              (unsafe-procedure-call |+.85| 89 85)))
            (empty3.27 (unsafe-procedure-call fun/empty16490.11))
            (fixnum4.26
             (unsafe-procedure-call
              |-.84|
              (unsafe-procedure-call |-.84| 17 63)
              (unsafe-procedure-call *.88 147 5)))
            (empty5.25 (unsafe-procedure-call fun/empty16491.5)))
        (unsafe-procedure-call fun/ascii-char16492.4)))))
(check-by-interp
 '(module
    (define procedure?.78 (lambda (tmp.70) (procedure? tmp.70)))
    (define cons.77 (lambda (tmp.71 tmp.72) (cons tmp.71 tmp.72)))
    (define vector-init-loop.26
      (lambda (len.27 i.29 vec.28)
        (if (eq? len.27 i.29)
          vec.28
          (begin
            (unsafe-vector-set! vec.28 i.29 0)
            (unsafe-procedure-call
             vector-init-loop.26
             len.27
             (unsafe-fx+ i.29 1)
             vec.28)))))
    (define make-init-vector.1
      (lambda (tmp.24)
        (let ((tmp.25 (unsafe-make-vector tmp.24)))
          (unsafe-procedure-call vector-init-loop.26 tmp.24 0 tmp.25))))
    (define make-vector.76
      (lambda (tmp.52)
        (if (fixnum? tmp.52)
          (unsafe-procedure-call make-init-vector.1 tmp.52)
          (error 8))))
    (define fun/any16598.4 (lambda () (unsafe-procedure-call fun/any16599.12)))
    (define fun/ascii-char16603.5 (lambda () #\]))
    (define fun/vector16592.6
      (lambda () (unsafe-procedure-call fun/vector16593.13)))
    (define fun/vector16605.7
      (lambda () (unsafe-procedure-call make-vector.76 8)))
    (define fun/vector16595.8
      (lambda () (unsafe-procedure-call make-vector.76 8)))
    (define fun/void16601.9 (lambda () (void)))
    (define fun/ascii-char16597.10 (lambda () #\c))
    (define fun/vector16604.11
      (lambda () (unsafe-procedure-call fun/vector16605.7)))
    (define fun/any16599.12
      (lambda () (unsafe-procedure-call cons.77 178 511)))
    (define fun/vector16593.13
      (lambda () (unsafe-procedure-call make-vector.76 8)))
    (define fun/ascii-char16596.14
      (lambda () (unsafe-procedure-call fun/ascii-char16597.10)))
    (define fun/ascii-char16602.15
      (lambda () (unsafe-procedure-call fun/ascii-char16603.5)))
    (define fun/void16600.16
      (lambda () (unsafe-procedure-call fun/void16601.9)))
    (define fun/vector16594.17
      (lambda () (unsafe-procedure-call fun/vector16595.8)))
    (let ((vector0.23 (unsafe-procedure-call fun/vector16592.6))
          (vector1.22 (unsafe-procedure-call fun/vector16594.17))
          (ascii-char2.21 (unsafe-procedure-call fun/ascii-char16596.14))
          (boolean3.20
           (unsafe-procedure-call
            procedure?.78
            (unsafe-procedure-call fun/any16598.4)))
          (void4.19 (unsafe-procedure-call fun/void16600.16))
          (ascii-char5.18 (unsafe-procedure-call fun/ascii-char16602.15)))
      (unsafe-procedure-call fun/vector16604.11))))
(check-by-interp
 '(module
    (define void?.79 (lambda (tmp.64) (void? tmp.64)))
    (define vector?.78 (lambda (tmp.68) (vector? tmp.68)))
    (define cons.77 (lambda (tmp.71 tmp.72) (cons tmp.71 tmp.72)))
    (define vector-init-loop.26
      (lambda (len.27 i.29 vec.28)
        (if (eq? len.27 i.29)
          vec.28
          (begin
            (unsafe-vector-set! vec.28 i.29 0)
            (unsafe-procedure-call
             vector-init-loop.26
             len.27
             (unsafe-fx+ i.29 1)
             vec.28)))))
    (define make-init-vector.1
      (lambda (tmp.24)
        (let ((tmp.25 (unsafe-make-vector tmp.24)))
          (unsafe-procedure-call vector-init-loop.26 tmp.24 0 tmp.25))))
    (define make-vector.76
      (lambda (tmp.52)
        (if (fixnum? tmp.52)
          (unsafe-procedure-call make-init-vector.1 tmp.52)
          (error 8))))
    (define fun/vector18001.4
      (lambda () (unsafe-procedure-call make-vector.76 8)))
    (define fun/vector17999.5
      (lambda () (unsafe-procedure-call make-vector.76 8)))
    (define fun/vector17998.6
      (lambda () (unsafe-procedure-call fun/vector17999.5)))
    (define fun/ascii-char18008.7
      (lambda () (unsafe-procedure-call fun/ascii-char18009.17)))
    (define fun/void18006.8
      (lambda () (unsafe-procedure-call fun/void18007.12)))
    (define fun/any18002.9 (lambda () (unsafe-procedure-call fun/any18003.14)))
    (define fun/empty17997.10 (lambda () empty))
    (define fun/any18005.11 (lambda () (error 158)))
    (define fun/void18007.12 (lambda () (void)))
    (define fun/any18004.13
      (lambda () (unsafe-procedure-call fun/any18005.11)))
    (define fun/any18003.14 (lambda () (unsafe-procedure-call cons.77 98 287)))
    (define fun/vector18000.15
      (lambda () (unsafe-procedure-call fun/vector18001.4)))
    (define fun/empty17996.16
      (lambda () (unsafe-procedure-call fun/empty17997.10)))
    (define fun/ascii-char18009.17 (lambda () #\G))
    (let ((procedure0.23 (lambda () (unsafe-procedure-call fun/empty17996.16)))
          (vector1.22 (unsafe-procedure-call fun/vector17998.6))
          (vector2.21 (unsafe-procedure-call fun/vector18000.15))
          (boolean3.20
           (unsafe-procedure-call
            vector?.78
            (unsafe-procedure-call fun/any18002.9)))
          (boolean4.19
           (unsafe-procedure-call
            void?.79
            (unsafe-procedure-call fun/any18004.13)))
          (void5.18 (unsafe-procedure-call fun/void18006.8)))
      (unsafe-procedure-call fun/ascii-char18008.7))))
(check-by-interp
 '(module
    (define |+.76|
      (lambda (tmp.38 tmp.39)
        (if (fixnum? tmp.39)
          (if (fixnum? tmp.38) (unsafe-fx+ tmp.38 tmp.39) (error 2))
          (error 2))))
    (define |-.75|
      (lambda (tmp.40 tmp.41)
        (if (fixnum? tmp.41)
          (if (fixnum? tmp.40) (unsafe-fx- tmp.40 tmp.41) (error 3))
          (error 3))))
    (define *.74
      (lambda (tmp.36 tmp.37)
        (if (fixnum? tmp.37)
          (if (fixnum? tmp.36) (unsafe-fx* tmp.36 tmp.37) (error 1))
          (error 1))))
    (define fun/error18490.4
      (lambda () (unsafe-procedure-call fun/error18491.8)))
    (define fun/empty18499.5 (lambda () empty))
    (define fun/error18497.6 (lambda () (error 98)))
    (define fun/ascii-char18492.7
      (lambda () (unsafe-procedure-call fun/ascii-char18493.13)))
    (define fun/error18491.8 (lambda () (error 186)))
    (define fun/void18494.9
      (lambda () (unsafe-procedure-call fun/void18495.15)))
    (define fun/void18489.10 (lambda () (void)))
    (define fun/empty18498.11
      (lambda () (unsafe-procedure-call fun/empty18499.5)))
    (define fun/error18496.12
      (lambda () (unsafe-procedure-call fun/error18497.6)))
    (define fun/ascii-char18493.13 (lambda () #\Q))
    (define fun/void18488.14
      (lambda () (unsafe-procedure-call fun/void18489.10)))
    (define fun/void18495.15 (lambda () (void)))
    (let ((void0.21 (unsafe-procedure-call fun/void18488.14))
          (error1.20 (unsafe-procedure-call fun/error18490.4))
          (fixnum2.19
           (unsafe-procedure-call
            *.74
            (unsafe-procedure-call
             |-.75|
             (unsafe-procedure-call
              *.74
              (unsafe-procedure-call *.74 88 125)
              (unsafe-procedure-call |-.75| 220 155))
             (unsafe-procedure-call
              |-.75|
              (unsafe-procedure-call |-.75| 144 224)
              (unsafe-procedure-call *.74 186 124)))
            (unsafe-procedure-call
             |-.75|
             (unsafe-procedure-call
              |-.75|
              (unsafe-procedure-call |-.75| 97 190)
              (unsafe-procedure-call *.74 211 147))
             (unsafe-procedure-call
              |+.76|
              (unsafe-procedure-call *.74 175 153)
              (unsafe-procedure-call *.74 126 159)))))
          (ascii-char3.18 (unsafe-procedure-call fun/ascii-char18492.7))
          (void4.17 (unsafe-procedure-call fun/void18494.9))
          (error5.16 (unsafe-procedure-call fun/error18496.12)))
      (unsafe-procedure-call fun/empty18498.11))))
(check-by-interp
 '(module
    (define cons.76 (lambda (tmp.71 tmp.72) (cons tmp.71 tmp.72)))
    (define fun/empty22590.4
      (lambda () (unsafe-procedure-call fun/empty22591.9)))
    (define fun/ascii-char22595.5 (lambda () #\b))
    (define fun/pair22601.6
      (lambda () (unsafe-procedure-call cons.76 100 463)))
    (define fun/ascii-char22589.7 (lambda () #\[))
    (define fun/empty22599.8 (lambda () empty))
    (define fun/empty22591.9 (lambda () empty))
    (define fun/empty22597.10 (lambda () empty))
    (define fun/ascii-char22588.11
      (lambda () (unsafe-procedure-call fun/ascii-char22589.7)))
    (define fun/error22593.12 (lambda () (error 22)))
    (define fun/pair22600.13
      (lambda () (unsafe-procedure-call fun/pair22601.6)))
    (define fun/error22592.14
      (lambda () (unsafe-procedure-call fun/error22593.12)))
    (define fun/empty22598.15
      (lambda () (unsafe-procedure-call fun/empty22599.8)))
    (define fun/empty22596.16
      (lambda () (unsafe-procedure-call fun/empty22597.10)))
    (define fun/ascii-char22594.17
      (lambda () (unsafe-procedure-call fun/ascii-char22595.5)))
    (let ((ascii-char0.23 (unsafe-procedure-call fun/ascii-char22588.11))
          (empty1.22 (unsafe-procedure-call fun/empty22590.4))
          (error2.21 (unsafe-procedure-call fun/error22592.14))
          (ascii-char3.20 (unsafe-procedure-call fun/ascii-char22594.17))
          (empty4.19 (unsafe-procedure-call fun/empty22596.16))
          (empty5.18 (unsafe-procedure-call fun/empty22598.15)))
      (unsafe-procedure-call fun/pair22600.13))))
(check-by-interp
 '(module
    (define *.74
      (lambda (tmp.32 tmp.33)
        (if (fixnum? tmp.33)
          (if (fixnum? tmp.32) (unsafe-fx* tmp.32 tmp.33) (error 1))
          (error 1))))
    (define |+.73|
      (lambda (tmp.34 tmp.35)
        (if (fixnum? tmp.35)
          (if (fixnum? tmp.34) (unsafe-fx+ tmp.34 tmp.35) (error 2))
          (error 2))))
    (define |-.72|
      (lambda (tmp.36 tmp.37)
        (if (fixnum? tmp.37)
          (if (fixnum? tmp.36) (unsafe-fx- tmp.36 tmp.37) (error 3))
          (error 3))))
    (define boolean?.71 (lambda (tmp.56) (boolean? tmp.56)))
    (define cons.70 (lambda (tmp.65 tmp.66) (cons tmp.65 tmp.66)))
    (define fun/void23349.4 (lambda () (void)))
    (define fun/any23351.5 (lambda () (unsafe-procedure-call cons.70 159 398)))
    (define fun/void23348.6
      (lambda () (unsafe-procedure-call fun/void23349.4)))
    (define fun/any23350.7 (lambda () (unsafe-procedure-call fun/any23351.5)))
    (define fun/ascii-char23347.8 (lambda () #\\))
    (define fun/ascii-char23346.9
      (lambda () (unsafe-procedure-call fun/ascii-char23347.8)))
    (define fun/void23353.10 (lambda () (void)))
    (define fun/void23352.11
      (lambda () (unsafe-procedure-call fun/void23353.10)))
    (let ((ascii-char0.17 (unsafe-procedure-call fun/ascii-char23346.9))
          (void1.16 (unsafe-procedure-call fun/void23348.6))
          (boolean2.15
           (unsafe-procedure-call
            boolean?.71
            (unsafe-procedure-call fun/any23350.7)))
          (procedure3.14
           (lambda ()
             (unsafe-procedure-call
              |+.73|
              (unsafe-procedure-call
               |+.73|
               (unsafe-procedure-call
                |+.73|
                (unsafe-procedure-call |-.72| 239 118)
                (unsafe-procedure-call |-.72| 38 153))
               (unsafe-procedure-call
                |+.73|
                (unsafe-procedure-call *.74 128 179)
                (unsafe-procedure-call |-.72| 208 217)))
              (unsafe-procedure-call
               |-.72|
               (unsafe-procedure-call
                |+.73|
                (unsafe-procedure-call |-.72| 121 152)
                (unsafe-procedure-call *.74 212 8))
               (unsafe-procedure-call
                *.74
                (unsafe-procedure-call *.74 175 82)
                (unsafe-procedure-call |-.72| 52 179))))))
          (fixnum4.13
           (unsafe-procedure-call
            *.74
            (unsafe-procedure-call
             |-.72|
             (unsafe-procedure-call
              *.74
              (unsafe-procedure-call |-.72| 100 80)
              (unsafe-procedure-call |+.73| 40 93))
             (unsafe-procedure-call
              |+.73|
              (unsafe-procedure-call |-.72| 163 92)
              (unsafe-procedure-call |-.72| 230 103)))
            (unsafe-procedure-call
             |-.72|
             (unsafe-procedure-call
              |-.72|
              (unsafe-procedure-call |-.72| 47 61)
              (unsafe-procedure-call |-.72| 139 24))
             (unsafe-procedure-call
              |+.73|
              (unsafe-procedure-call *.74 103 132)
              (unsafe-procedure-call |+.73| 140 95)))))
          (procedure5.12 (lambda () (unsafe-procedure-call fun/void23352.11))))
      (unsafe-procedure-call
       |-.72|
       (unsafe-procedure-call
        *.74
        (if (procedure? procedure3.14)
          (if (eq? (unsafe-procedure-arity procedure3.14) 0)
            (unsafe-procedure-call procedure3.14)
            (error 42))
          (error 43))
        (if (procedure? procedure3.14)
          (if (eq? (unsafe-procedure-arity procedure3.14) 0)
            (unsafe-procedure-call procedure3.14)
            (error 42))
          (error 43)))
       (unsafe-procedure-call
        |+.73|
        (unsafe-procedure-call
         *.74
         (unsafe-procedure-call *.74 105 226)
         (unsafe-procedure-call |+.73| 43 81))
        (unsafe-procedure-call
         |+.73|
         (unsafe-procedure-call *.74 245 145)
         (unsafe-procedure-call *.74 109 196)))))))
(check-by-interp
 '(module
    (define empty?.78 (lambda (tmp.61) (empty? tmp.61)))
    (define |-.77|
      (lambda (tmp.40 tmp.41)
        (if (fixnum? tmp.41)
          (if (fixnum? tmp.40) (unsafe-fx- tmp.40 tmp.41) (error 3))
          (error 3))))
    (define |+.76|
      (lambda (tmp.38 tmp.39)
        (if (fixnum? tmp.39)
          (if (fixnum? tmp.38) (unsafe-fx+ tmp.38 tmp.39) (error 2))
          (error 2))))
    (define *.75
      (lambda (tmp.36 tmp.37)
        (if (fixnum? tmp.37)
          (if (fixnum? tmp.36) (unsafe-fx* tmp.36 tmp.37) (error 1))
          (error 1))))
    (define vector-init-loop.24
      (lambda (len.25 i.27 vec.26)
        (if (eq? len.25 i.27)
          vec.26
          (begin
            (unsafe-vector-set! vec.26 i.27 0)
            (unsafe-procedure-call
             vector-init-loop.24
             len.25
             (unsafe-fx+ i.27 1)
             vec.26)))))
    (define make-init-vector.1
      (lambda (tmp.22)
        (let ((tmp.23 (unsafe-make-vector tmp.22)))
          (unsafe-procedure-call vector-init-loop.24 tmp.22 0 tmp.23))))
    (define make-vector.74
      (lambda (tmp.50)
        (if (fixnum? tmp.50)
          (unsafe-procedure-call make-init-vector.1 tmp.50)
          (error 8))))
    (define fun/vector24625.4
      (lambda () (unsafe-procedure-call fun/vector24626.15)))
    (define fun/any24628.5 (lambda () empty))
    (define fun/error24633.6
      (lambda () (unsafe-procedure-call fun/error24634.12)))
    (define fun/empty24629.7
      (lambda () (unsafe-procedure-call fun/empty24630.11)))
    (define fun/error24636.8 (lambda () (error 205)))
    (define fun/void24632.9 (lambda () (void)))
    (define fun/void24631.10
      (lambda () (unsafe-procedure-call fun/void24632.9)))
    (define fun/empty24630.11 (lambda () empty))
    (define fun/error24634.12 (lambda () (error 74)))
    (define fun/error24635.13
      (lambda () (unsafe-procedure-call fun/error24636.8)))
    (define fun/any24627.14 (lambda () (unsafe-procedure-call fun/any24628.5)))
    (define fun/vector24626.15
      (lambda () (unsafe-procedure-call make-vector.74 8)))
    (let ((fixnum0.21
           (unsafe-procedure-call
            |-.77|
            (unsafe-procedure-call
             *.75
             (unsafe-procedure-call
              |+.76|
              (unsafe-procedure-call *.75 148 145)
              (unsafe-procedure-call *.75 226 44))
             (unsafe-procedure-call
              *.75
              (unsafe-procedure-call |+.76| 65 170)
              (unsafe-procedure-call |-.77| 129 146)))
            (unsafe-procedure-call
             |+.76|
             (unsafe-procedure-call
              |+.76|
              (unsafe-procedure-call |+.76| 24 189)
              (unsafe-procedure-call |-.77| 110 80))
             (unsafe-procedure-call
              |+.76|
              (unsafe-procedure-call |-.77| 191 251)
              (unsafe-procedure-call |-.77| 78 207)))))
          (vector1.20 (unsafe-procedure-call fun/vector24625.4))
          (boolean2.19
           (unsafe-procedure-call
            empty?.78
            (unsafe-procedure-call fun/any24627.14)))
          (procedure3.18 (lambda () (unsafe-procedure-call fun/empty24629.7)))
          (procedure4.17 (lambda () (unsafe-procedure-call fun/void24631.10)))
          (error5.16 (unsafe-procedure-call fun/error24633.6)))
      (unsafe-procedure-call fun/error24635.13))))
