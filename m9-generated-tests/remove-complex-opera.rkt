#lang racket
(require rackunit
         cpsc411/compiler-lib
         cpsc411/ptr-run-time
         cpsc411/langs/v8
         cpsc411/langs/v9
         "../remove-complex-opera.rkt")
(define (fail-if-invalid p)
  (when (not (values-bits-lang-v8? p))
    (error
     (~a
      (pretty-format p)
      "\n is not a semantically valid "
      "values-bits-lang-v8"
      " program")))
  p)
(define-syntax-rule
 (check-by-interp p)
 (check-equal?
  (interp-exprs-bits-lang-v8 p)
  (interp-values-bits-lang-v8 (fail-if-invalid (remove-complex-opera p)))))

(check-by-interp
 '(module
    (define L.cons.56.7
      (lambda (c.57 tmp.51 tmp.52)
        (let ()
          (let ((tmp.58 (+ (alloc 16) 1)))
            (begin (mset! tmp.58 -1 tmp.51) (mset! tmp.58 7 tmp.52) tmp.58)))))
    (let ((cons.56
           (let ((tmp.59 (+ (alloc 16) 2)))
             (begin
               (mset! tmp.59 -2 L.cons.56.7)
               (mset! tmp.59 6 16)
               tmp.59))))
      (call L.cons.56.7 cons.56 48 4008))))
(check-by-interp
 '(module
    (define L.cons.56.7
      (lambda (c.57 tmp.51 tmp.52)
        (let ()
          (let ((tmp.58 (+ (alloc 16) 1)))
            (begin (mset! tmp.58 -1 tmp.51) (mset! tmp.58 7 tmp.52) tmp.58)))))
    (let ((cons.56
           (let ((tmp.59 (+ (alloc 16) 2)))
             (begin
               (mset! tmp.59 -2 L.cons.56.7)
               (mset! tmp.59 6 16)
               tmp.59))))
      (call L.cons.56.7 cons.56 336 4080))))
(check-by-interp
 '(module
    (define L.fun/error8439.4.7 (lambda (c.57) (let () 37950)))
    (let ((fun/error8439.4
           (let ((tmp.58 (+ (alloc 16) 2)))
             (begin
               (mset! tmp.58 -2 L.fun/error8439.4.7)
               (mset! tmp.58 6 0)
               tmp.58))))
      (call L.fun/error8439.4.7 fun/error8439.4))))
(check-by-interp
 '(module
    (define L.fun/error8442.4.7 (lambda (c.57) (let () 63294)))
    (let ((fun/error8442.4
           (let ((tmp.58 (+ (alloc 16) 2)))
             (begin
               (mset! tmp.58 -2 L.fun/error8442.4.7)
               (mset! tmp.58 6 0)
               tmp.58))))
      (call L.fun/error8442.4.7 fun/error8442.4))))
(check-by-interp
 '(module
    (define L.fun/error8445.4.7 (lambda (c.57) (let () 36158)))
    (let ((fun/error8445.4
           (let ((tmp.58 (+ (alloc 16) 2)))
             (begin
               (mset! tmp.58 -2 L.fun/error8445.4.7)
               (mset! tmp.58 6 0)
               tmp.58))))
      (call L.fun/error8445.4.7 fun/error8445.4))))
(check-by-interp
 '(module
    (define L.fun/pair8448.4.8
      (lambda (c.59)
        (let ((cons.57 (mref c.59 14))) (call L.cons.57.7 cons.57 1464 2216))))
    (define L.cons.57.7
      (lambda (c.58 tmp.52 tmp.53)
        (let ()
          (let ((tmp.60 (+ (alloc 16) 1)))
            (begin (mset! tmp.60 -1 tmp.52) (mset! tmp.60 7 tmp.53) tmp.60)))))
    (let ((cons.57
           (let ((tmp.61 (+ (alloc 16) 2)))
             (begin (mset! tmp.61 -2 L.cons.57.7) (mset! tmp.61 6 16) tmp.61)))
          (fun/pair8448.4
           (let ((tmp.62 (+ (alloc 24) 2)))
             (begin
               (mset! tmp.62 -2 L.fun/pair8448.4.8)
               (mset! tmp.62 6 0)
               tmp.62))))
      (begin
        (mset! fun/pair8448.4 14 cons.57)
        (call L.fun/pair8448.4.8 fun/pair8448.4)))))
(check-by-interp '(module (let ((ascii-char0.5 20014) (void1.4 30)) 14)))
(check-by-interp
 '(module
    (define L.lam.59.10 (lambda (c.63) (let () 576)))
    (define L.make-vector.58.9
      (lambda (c.62 tmp.34)
        (let ((make-init-vector.1 (mref c.62 14)))
          (if (!= (if (= (bitwise-and tmp.34 7) 0) 14 6) 6)
            (call L.make-init-vector.1.8 make-init-vector.1 tmp.34)
            2110))))
    (define L.make-init-vector.1.8
      (lambda (c.61 tmp.6)
        (let ((vector-init-loop.8 (mref c.61 14)))
          (let ((tmp.7
                 (let ((tmp.64
                        (+
                         (alloc (* (+ 1 (arithmetic-shift-right tmp.6 3)) 8))
                         3)))
                   (begin (mset! tmp.64 -3 tmp.6) tmp.64))))
            (call L.vector-init-loop.8.7 vector-init-loop.8 tmp.6 0 tmp.7)))))
    (define L.vector-init-loop.8.7
      (lambda (c.60 len.9 i.11 vec.10)
        (let ((vector-init-loop.8 (mref c.60 14)))
          (if (!= (if (= len.9 i.11) 14 6) 6)
            vec.10
            (begin
              (mset! vec.10 (+ (* (arithmetic-shift-right i.11 3) 8) 5) 0)
              (call
               L.vector-init-loop.8.7
               vector-init-loop.8
               len.9
               (+ i.11 8)
               vec.10))))))
    (let ((vector-init-loop.8
           (let ((tmp.65 (+ (alloc 24) 2)))
             (begin
               (mset! tmp.65 -2 L.vector-init-loop.8.7)
               (mset! tmp.65 6 24)
               tmp.65)))
          (make-init-vector.1
           (let ((tmp.66 (+ (alloc 24) 2)))
             (begin
               (mset! tmp.66 -2 L.make-init-vector.1.8)
               (mset! tmp.66 6 8)
               tmp.66)))
          (make-vector.58
           (let ((tmp.67 (+ (alloc 24) 2)))
             (begin
               (mset! tmp.67 -2 L.make-vector.58.9)
               (mset! tmp.67 6 8)
               tmp.67))))
      (begin
        (mset! vector-init-loop.8 14 vector-init-loop.8)
        (mset! make-init-vector.1 14 vector-init-loop.8)
        (mset! make-vector.58 14 make-init-vector.1)
        (let ((vector0.5 (call L.make-vector.58.9 make-vector.58 64))
              (procedure1.4
               (let ((lam.59
                      (let ((tmp.68 (+ (alloc 16) 2)))
                        (begin
                          (mset! tmp.68 -2 L.lam.59.10)
                          (mset! tmp.68 6 0)
                          tmp.68))))
                 lam.59)))
          22)))))
(check-by-interp
 '(module
    (define L.fun/empty8457.5.9
      (lambda (c.62 oprand0.6)
        (let ((fun/empty8458.4 (mref c.62 14)))
          (call L.fun/empty8458.4.8 fun/empty8458.4))))
    (define L.fun/empty8458.4.8 (lambda (c.61) (let () 22)))
    (define L.cons.59.7
      (lambda (c.60 tmp.54 tmp.55)
        (let ()
          (let ((tmp.63 (+ (alloc 16) 1)))
            (begin (mset! tmp.63 -1 tmp.54) (mset! tmp.63 7 tmp.55) tmp.63)))))
    (let ((cons.59
           (let ((tmp.64 (+ (alloc 16) 2)))
             (begin (mset! tmp.64 -2 L.cons.59.7) (mset! tmp.64 6 16) tmp.64)))
          (fun/empty8458.4
           (let ((tmp.65 (+ (alloc 16) 2)))
             (begin
               (mset! tmp.65 -2 L.fun/empty8458.4.8)
               (mset! tmp.65 6 0)
               tmp.65)))
          (fun/empty8457.5
           (let ((tmp.66 (+ (alloc 24) 2)))
             (begin
               (mset! tmp.66 -2 L.fun/empty8457.5.9)
               (mset! tmp.66 6 8)
               tmp.66))))
      (begin
        (mset! fun/empty8457.5 14 fun/empty8458.4)
        (call
         L.fun/empty8457.5.9
         fun/empty8457.5
         (if (!= 6 6)
           (call L.cons.59.7 cons.59 1576 3840)
           (call L.cons.59.7 cons.59 376 3368)))))))
(check-by-interp '(module (if (!= 6 6) 30 30)))
(check-by-interp
 '(module
    (define L.make-vector.56.9
      (lambda (c.59 tmp.32)
        (let ((make-init-vector.1 (mref c.59 14)))
          (if (!= (if (= (bitwise-and tmp.32 7) 0) 14 6) 6)
            (call L.make-init-vector.1.8 make-init-vector.1 tmp.32)
            2110))))
    (define L.make-init-vector.1.8
      (lambda (c.58 tmp.4)
        (let ((vector-init-loop.6 (mref c.58 14)))
          (let ((tmp.5
                 (let ((tmp.60
                        (+
                         (alloc (* (+ 1 (arithmetic-shift-right tmp.4 3)) 8))
                         3)))
                   (begin (mset! tmp.60 -3 tmp.4) tmp.60))))
            (call L.vector-init-loop.6.7 vector-init-loop.6 tmp.4 0 tmp.5)))))
    (define L.vector-init-loop.6.7
      (lambda (c.57 len.7 i.9 vec.8)
        (let ((vector-init-loop.6 (mref c.57 14)))
          (if (!= (if (= len.7 i.9) 14 6) 6)
            vec.8
            (begin
              (mset! vec.8 (+ (* (arithmetic-shift-right i.9 3) 8) 5) 0)
              (call
               L.vector-init-loop.6.7
               vector-init-loop.6
               len.7
               (+ i.9 8)
               vec.8))))))
    (let ((vector-init-loop.6
           (let ((tmp.61 (+ (alloc 24) 2)))
             (begin
               (mset! tmp.61 -2 L.vector-init-loop.6.7)
               (mset! tmp.61 6 24)
               tmp.61)))
          (make-init-vector.1
           (let ((tmp.62 (+ (alloc 24) 2)))
             (begin
               (mset! tmp.62 -2 L.make-init-vector.1.8)
               (mset! tmp.62 6 8)
               tmp.62)))
          (make-vector.56
           (let ((tmp.63 (+ (alloc 24) 2)))
             (begin
               (mset! tmp.63 -2 L.make-vector.56.9)
               (mset! tmp.63 6 8)
               tmp.63))))
      (begin
        (mset! vector-init-loop.6 14 vector-init-loop.6)
        (mset! make-init-vector.1 14 vector-init-loop.6)
        (mset! make-vector.56 14 make-init-vector.1)
        (if (!= 6 6)
          (call L.make-vector.56.9 make-vector.56 64)
          (call L.make-vector.56.9 make-vector.56 64))))))
(check-by-interp
 '(module
    (define L.fun/empty8466.6.10 (lambda (c.65) (let () 22)))
    (define L.fun/empty8465.5.9
      (lambda (c.64 oprand0.8)
        (let ((fun/empty8466.6 (mref c.64 14)))
          (call L.fun/empty8466.6.10 fun/empty8466.6))))
    (define L.fun/error8467.4.8 (lambda (c.63 oprand0.7) (let () 44862)))
    (define L.cons.61.7
      (lambda (c.62 tmp.56 tmp.57)
        (let ()
          (let ((tmp.66 (+ (alloc 16) 1)))
            (begin (mset! tmp.66 -1 tmp.56) (mset! tmp.66 7 tmp.57) tmp.66)))))
    (let ((cons.61
           (let ((tmp.67 (+ (alloc 16) 2)))
             (begin (mset! tmp.67 -2 L.cons.61.7) (mset! tmp.67 6 16) tmp.67)))
          (fun/error8467.4
           (let ((tmp.68 (+ (alloc 16) 2)))
             (begin
               (mset! tmp.68 -2 L.fun/error8467.4.8)
               (mset! tmp.68 6 8)
               tmp.68)))
          (fun/empty8465.5
           (let ((tmp.69 (+ (alloc 24) 2)))
             (begin
               (mset! tmp.69 -2 L.fun/empty8465.5.9)
               (mset! tmp.69 6 8)
               tmp.69)))
          (fun/empty8466.6
           (let ((tmp.70 (+ (alloc 16) 2)))
             (begin
               (mset! tmp.70 -2 L.fun/empty8466.6.10)
               (mset! tmp.70 6 0)
               tmp.70))))
      (begin
        (mset! fun/empty8465.5 14 fun/empty8466.6)
        (call
         L.fun/empty8465.5.9
         fun/empty8465.5
         (call
          L.fun/error8467.4.8
          fun/error8467.4
          (call L.cons.61.7 cons.61 632 4016)))))))
(check-by-interp
 '(module
    (define L.fun/void8483.6.10
      (lambda (c.67 oprand0.10 oprand1.9)
        (let ((fun/void8484.4 (mref c.67 14)))
          (call L.fun/void8484.4.8 fun/void8484.4))))
    (define L.fun/ascii-char8485.5.9
      (lambda (c.66 oprand0.8 oprand1.7) (let () 16942)))
    (define L.fun/void8484.4.8 (lambda (c.65) (let () 30)))
    (define L.-.63.7
      (lambda (c.64 tmp.29 tmp.30)
        (let ()
          (if (!= (if (= (bitwise-and tmp.30 7) 0) 14 6) 6)
            (if (!= (if (= (bitwise-and tmp.29 7) 0) 14 6) 6)
              (- tmp.29 tmp.30)
              830)
            830))))
    (let ((|-.63|
           (let ((tmp.68 (+ (alloc 16) 2)))
             (begin (mset! tmp.68 -2 L.-.63.7) (mset! tmp.68 6 16) tmp.68)))
          (fun/void8484.4
           (let ((tmp.69 (+ (alloc 16) 2)))
             (begin
               (mset! tmp.69 -2 L.fun/void8484.4.8)
               (mset! tmp.69 6 0)
               tmp.69)))
          (fun/ascii-char8485.5
           (let ((tmp.70 (+ (alloc 16) 2)))
             (begin
               (mset! tmp.70 -2 L.fun/ascii-char8485.5.9)
               (mset! tmp.70 6 16)
               tmp.70)))
          (fun/void8483.6
           (let ((tmp.71 (+ (alloc 24) 2)))
             (begin
               (mset! tmp.71 -2 L.fun/void8483.6.10)
               (mset! tmp.71 6 16)
               tmp.71))))
      (begin
        (mset! fun/void8483.6 14 fun/void8484.4)
        (call
         L.fun/void8483.6.10
         fun/void8483.6
         (call
          L.fun/ascii-char8485.5.9
          fun/ascii-char8485.5
          (call L.-.63.7 |-.63| 224 704)
          (call L.fun/ascii-char8485.5.9 fun/ascii-char8485.5 704 17198))
         (if (!= 14 6) 960 528))))))
(check-by-interp
 '(module
    (if (if (!= 14 6) (!= 14 6) (!= 6 6))
      (if (!= 14 6) 4670 26430)
      (let ((ascii-char0.6 28718) (fixnum1.5 1608) (empty2.4 22)) 5438))))
(check-by-interp
 '(module
    (define L.fun/void8491.6.13 (lambda (c.70) (let () 30)))
    (define L.fun/void8490.5.12 (lambda (c.69) (let () 30)))
    (define L.fun/error8492.4.11 (lambda (c.68) (let () 19774)))
    (define L.make-vector.62.10
      (lambda (c.67 tmp.38)
        (let ((make-init-vector.1 (mref c.67 14)))
          (if (!= (if (= (bitwise-and tmp.38 7) 0) 14 6) 6)
            (call L.make-init-vector.1.9 make-init-vector.1 tmp.38)
            2110))))
    (define L.make-init-vector.1.9
      (lambda (c.66 tmp.10)
        (let ((vector-init-loop.12 (mref c.66 14)))
          (let ((tmp.11
                 (let ((tmp.71
                        (+
                         (alloc (* (+ 1 (arithmetic-shift-right tmp.10 3)) 8))
                         3)))
                   (begin (mset! tmp.71 -3 tmp.10) tmp.71))))
            (call
             L.vector-init-loop.12.8
             vector-init-loop.12
             tmp.10
             0
             tmp.11)))))
    (define L.vector-init-loop.12.8
      (lambda (c.65 len.13 i.15 vec.14)
        (let ((vector-init-loop.12 (mref c.65 14)))
          (if (!= (if (= len.13 i.15) 14 6) 6)
            vec.14
            (begin
              (mset! vec.14 (+ (* (arithmetic-shift-right i.15 3) 8) 5) 0)
              (call
               L.vector-init-loop.12.8
               vector-init-loop.12
               len.13
               (+ i.15 8)
               vec.14))))))
    (define L.vector?.63.7
      (lambda (c.64 tmp.54) (let () (if (= (bitwise-and tmp.54 7) 3) 14 6))))
    (let ((vector?.63
           (let ((tmp.72 (+ (alloc 16) 2)))
             (begin
               (mset! tmp.72 -2 L.vector?.63.7)
               (mset! tmp.72 6 8)
               tmp.72)))
          (vector-init-loop.12
           (let ((tmp.73 (+ (alloc 24) 2)))
             (begin
               (mset! tmp.73 -2 L.vector-init-loop.12.8)
               (mset! tmp.73 6 24)
               tmp.73)))
          (make-init-vector.1
           (let ((tmp.74 (+ (alloc 24) 2)))
             (begin
               (mset! tmp.74 -2 L.make-init-vector.1.9)
               (mset! tmp.74 6 8)
               tmp.74)))
          (make-vector.62
           (let ((tmp.75 (+ (alloc 24) 2)))
             (begin
               (mset! tmp.75 -2 L.make-vector.62.10)
               (mset! tmp.75 6 8)
               tmp.75)))
          (fun/error8492.4
           (let ((tmp.76 (+ (alloc 16) 2)))
             (begin
               (mset! tmp.76 -2 L.fun/error8492.4.11)
               (mset! tmp.76 6 0)
               tmp.76)))
          (fun/void8490.5
           (let ((tmp.77 (+ (alloc 16) 2)))
             (begin
               (mset! tmp.77 -2 L.fun/void8490.5.12)
               (mset! tmp.77 6 0)
               tmp.77)))
          (fun/void8491.6
           (let ((tmp.78 (+ (alloc 16) 2)))
             (begin
               (mset! tmp.78 -2 L.fun/void8491.6.13)
               (mset! tmp.78 6 0)
               tmp.78))))
      (begin
        (mset! vector-init-loop.12 14 vector-init-loop.12)
        (mset! make-init-vector.1 14 vector-init-loop.12)
        (mset! make-vector.62 14 make-init-vector.1)
        (let ((void0.9 (call L.fun/void8490.5.12 fun/void8490.5))
              (void1.8 (call L.fun/void8491.6.13 fun/void8491.6))
              (boolean2.7
               (call
                L.vector?.63.7
                vector?.63
                (call L.make-vector.62.10 make-vector.62 64))))
          (call L.fun/error8492.4.11 fun/error8492.4))))))
(check-by-interp
 '(module
    (define L.fun/error8495.4.10
      (lambda (c.63 oprand0.6 oprand1.5) (let () 17470)))
    (define L.make-vector.59.9
      (lambda (c.62 tmp.35)
        (let ((make-init-vector.1 (mref c.62 14)))
          (if (!= (if (= (bitwise-and tmp.35 7) 0) 14 6) 6)
            (call L.make-init-vector.1.8 make-init-vector.1 tmp.35)
            2110))))
    (define L.make-init-vector.1.8
      (lambda (c.61 tmp.7)
        (let ((vector-init-loop.9 (mref c.61 14)))
          (let ((tmp.8
                 (let ((tmp.64
                        (+
                         (alloc (* (+ 1 (arithmetic-shift-right tmp.7 3)) 8))
                         3)))
                   (begin (mset! tmp.64 -3 tmp.7) tmp.64))))
            (call L.vector-init-loop.9.7 vector-init-loop.9 tmp.7 0 tmp.8)))))
    (define L.vector-init-loop.9.7
      (lambda (c.60 len.10 i.12 vec.11)
        (let ((vector-init-loop.9 (mref c.60 14)))
          (if (!= (if (= len.10 i.12) 14 6) 6)
            vec.11
            (begin
              (mset! vec.11 (+ (* (arithmetic-shift-right i.12 3) 8) 5) 0)
              (call
               L.vector-init-loop.9.7
               vector-init-loop.9
               len.10
               (+ i.12 8)
               vec.11))))))
    (let ((vector-init-loop.9
           (let ((tmp.65 (+ (alloc 24) 2)))
             (begin
               (mset! tmp.65 -2 L.vector-init-loop.9.7)
               (mset! tmp.65 6 24)
               tmp.65)))
          (make-init-vector.1
           (let ((tmp.66 (+ (alloc 24) 2)))
             (begin
               (mset! tmp.66 -2 L.make-init-vector.1.8)
               (mset! tmp.66 6 8)
               tmp.66)))
          (make-vector.59
           (let ((tmp.67 (+ (alloc 24) 2)))
             (begin
               (mset! tmp.67 -2 L.make-vector.59.9)
               (mset! tmp.67 6 8)
               tmp.67)))
          (fun/error8495.4
           (let ((tmp.68 (+ (alloc 16) 2)))
             (begin
               (mset! tmp.68 -2 L.fun/error8495.4.10)
               (mset! tmp.68 6 16)
               tmp.68))))
      (begin
        (mset! vector-init-loop.9 14 vector-init-loop.9)
        (mset! make-init-vector.1 14 vector-init-loop.9)
        (mset! make-vector.59 14 make-init-vector.1)
        (if (if (!= 14 6) (!= 14 6) (!= 6 6))
          (if (!= 14 6) 59198 39998)
          (call
           L.fun/error8495.4.10
           fun/error8495.4
           25390
           (call L.make-vector.59.9 make-vector.59 64)))))))
(check-by-interp
 '(module
    (define L.fun/ascii-char8529.5.10 (lambda (c.66) (let () 22318)))
    (define L.fun/error8528.4.9 (lambda (c.65) (let () 55102)))
    (define L.empty?.61.8
      (lambda (c.64 tmp.48)
        (let () (if (= (bitwise-and tmp.48 255) 22) 14 6))))
    (define L.-.62.7
      (lambda (c.63 tmp.27 tmp.28)
        (let ()
          (if (!= (if (= (bitwise-and tmp.28 7) 0) 14 6) 6)
            (if (!= (if (= (bitwise-and tmp.27 7) 0) 14 6) 6)
              (- tmp.27 tmp.28)
              830)
            830))))
    (let ((|-.62|
           (let ((tmp.67 (+ (alloc 16) 2)))
             (begin (mset! tmp.67 -2 L.-.62.7) (mset! tmp.67 6 16) tmp.67)))
          (empty?.61
           (let ((tmp.68 (+ (alloc 16) 2)))
             (begin
               (mset! tmp.68 -2 L.empty?.61.8)
               (mset! tmp.68 6 8)
               tmp.68)))
          (fun/error8528.4
           (let ((tmp.69 (+ (alloc 16) 2)))
             (begin
               (mset! tmp.69 -2 L.fun/error8528.4.9)
               (mset! tmp.69 6 0)
               tmp.69)))
          (fun/ascii-char8529.5
           (let ((tmp.70 (+ (alloc 16) 2)))
             (begin
               (mset! tmp.70 -2 L.fun/ascii-char8529.5.10)
               (mset! tmp.70 6 0)
               tmp.70))))
      (let ((error0.8 (call L.fun/error8528.4.9 fun/error8528.4))
            (ascii-char1.7
             (call L.fun/ascii-char8529.5.10 fun/ascii-char8529.5))
            (boolean2.6 (call L.empty?.61.8 empty?.61 18734)))
        (call L.-.62.7 |-.62| 1488 1960)))))
(check-by-interp
 '(module
    (define L.fun/pair8538.5.9
      (lambda (c.65 oprand0.9 oprand1.8)
        (let ((cons.62 (mref c.65 14))) (call L.cons.62.7 cons.62 40 4080))))
    (define L.fun/pair8539.4.8
      (lambda (c.64 oprand0.7 oprand1.6) (let () oprand1.6)))
    (define L.cons.62.7
      (lambda (c.63 tmp.57 tmp.58)
        (let ()
          (let ((tmp.66 (+ (alloc 16) 1)))
            (begin (mset! tmp.66 -1 tmp.57) (mset! tmp.66 7 tmp.58) tmp.66)))))
    (let ((cons.62
           (let ((tmp.67 (+ (alloc 16) 2)))
             (begin (mset! tmp.67 -2 L.cons.62.7) (mset! tmp.67 6 16) tmp.67)))
          (fun/pair8539.4
           (let ((tmp.68 (+ (alloc 16) 2)))
             (begin
               (mset! tmp.68 -2 L.fun/pair8539.4.8)
               (mset! tmp.68 6 16)
               tmp.68)))
          (fun/pair8538.5
           (let ((tmp.69 (+ (alloc 24) 2)))
             (begin
               (mset! tmp.69 -2 L.fun/pair8538.5.9)
               (mset! tmp.69 6 16)
               tmp.69))))
      (begin
        (mset! fun/pair8538.5 14 cons.62)
        (if (if (!= 14 6) (!= 6 6) (!= 6 6))
          (call L.fun/pair8538.5.9 fun/pair8538.5 1976 6)
          (call
           L.fun/pair8539.4.8
           fun/pair8539.4
           6
           (call L.cons.62.7 cons.62 224 2760)))))))
(check-by-interp
 '(module
    (define L.fun/boolean8542.5.12
      (lambda (c.69 oprand0.9 oprand1.8) (let () 14)))
    (define L.fun/ascii-char8543.4.11
      (lambda (c.68 oprand0.7 oprand1.6) (let () 30766)))
    (define L.make-vector.62.10
      (lambda (c.67 tmp.38)
        (let ((make-init-vector.1 (mref c.67 14)))
          (if (!= (if (= (bitwise-and tmp.38 7) 0) 14 6) 6)
            (call L.make-init-vector.1.9 make-init-vector.1 tmp.38)
            2110))))
    (define L.make-init-vector.1.9
      (lambda (c.66 tmp.10)
        (let ((vector-init-loop.12 (mref c.66 14)))
          (let ((tmp.11
                 (let ((tmp.70
                        (+
                         (alloc (* (+ 1 (arithmetic-shift-right tmp.10 3)) 8))
                         3)))
                   (begin (mset! tmp.70 -3 tmp.10) tmp.70))))
            (call
             L.vector-init-loop.12.8
             vector-init-loop.12
             tmp.10
             0
             tmp.11)))))
    (define L.vector-init-loop.12.8
      (lambda (c.65 len.13 i.15 vec.14)
        (let ((vector-init-loop.12 (mref c.65 14)))
          (if (!= (if (= len.13 i.15) 14 6) 6)
            vec.14
            (begin
              (mset! vec.14 (+ (* (arithmetic-shift-right i.15 3) 8) 5) 0)
              (call
               L.vector-init-loop.12.8
               vector-init-loop.12
               len.13
               (+ i.15 8)
               vec.14))))))
    (define L.cons.63.7
      (lambda (c.64 tmp.57 tmp.58)
        (let ()
          (let ((tmp.71 (+ (alloc 16) 1)))
            (begin (mset! tmp.71 -1 tmp.57) (mset! tmp.71 7 tmp.58) tmp.71)))))
    (let ((cons.63
           (let ((tmp.72 (+ (alloc 16) 2)))
             (begin (mset! tmp.72 -2 L.cons.63.7) (mset! tmp.72 6 16) tmp.72)))
          (vector-init-loop.12
           (let ((tmp.73 (+ (alloc 24) 2)))
             (begin
               (mset! tmp.73 -2 L.vector-init-loop.12.8)
               (mset! tmp.73 6 24)
               tmp.73)))
          (make-init-vector.1
           (let ((tmp.74 (+ (alloc 24) 2)))
             (begin
               (mset! tmp.74 -2 L.make-init-vector.1.9)
               (mset! tmp.74 6 8)
               tmp.74)))
          (make-vector.62
           (let ((tmp.75 (+ (alloc 24) 2)))
             (begin
               (mset! tmp.75 -2 L.make-vector.62.10)
               (mset! tmp.75 6 8)
               tmp.75)))
          (fun/ascii-char8543.4
           (let ((tmp.76 (+ (alloc 16) 2)))
             (begin
               (mset! tmp.76 -2 L.fun/ascii-char8543.4.11)
               (mset! tmp.76 6 16)
               tmp.76)))
          (fun/boolean8542.5
           (let ((tmp.77 (+ (alloc 16) 2)))
             (begin
               (mset! tmp.77 -2 L.fun/boolean8542.5.12)
               (mset! tmp.77 6 16)
               tmp.77))))
      (begin
        (mset! vector-init-loop.12 14 vector-init-loop.12)
        (mset! make-init-vector.1 14 vector-init-loop.12)
        (mset! make-vector.62 14 make-init-vector.1)
        (if (!=
             (call
              L.fun/boolean8542.5.12
              fun/boolean8542.5
              23854
              (call L.make-vector.62.10 make-vector.62 64))
             6)
          (call
           L.fun/ascii-char8543.4.11
           fun/ascii-char8543.4
           (call L.cons.63.7 cons.63 1440 3056)
           1832)
          (if (!= 6 6) 24110 26926))))))
(check-by-interp
 '(module
    (define L.fun/ascii-char8590.6.15 (lambda (c.75) (let () 17454)))
    (define L.fun/vector8589.5.14
      (lambda (c.74)
        (let ((make-vector.63 (mref c.74 14)))
          (call L.make-vector.63.12 make-vector.63 64))))
    (define L.fun/empty8591.4.13 (lambda (c.73) (let () 22)))
    (define L.make-vector.63.12
      (lambda (c.72 tmp.39)
        (let ((make-init-vector.1 (mref c.72 14)))
          (if (!= (if (= (bitwise-and tmp.39 7) 0) 14 6) 6)
            (call L.make-init-vector.1.11 make-init-vector.1 tmp.39)
            2110))))
    (define L.make-init-vector.1.11
      (lambda (c.71 tmp.11)
        (let ((vector-init-loop.13 (mref c.71 14)))
          (let ((tmp.12
                 (let ((tmp.76
                        (+
                         (alloc (* (+ 1 (arithmetic-shift-right tmp.11 3)) 8))
                         3)))
                   (begin (mset! tmp.76 -3 tmp.11) tmp.76))))
            (call
             L.vector-init-loop.13.10
             vector-init-loop.13
             tmp.11
             0
             tmp.12)))))
    (define L.vector-init-loop.13.10
      (lambda (c.70 len.14 i.16 vec.15)
        (let ((vector-init-loop.13 (mref c.70 14)))
          (if (!= (if (= len.14 i.16) 14 6) 6)
            vec.15
            (begin
              (mset! vec.15 (+ (* (arithmetic-shift-right i.16 3) 8) 5) 0)
              (call
               L.vector-init-loop.13.10
               vector-init-loop.13
               len.14
               (+ i.16 8)
               vec.15))))))
    (define L.-.64.9
      (lambda (c.69 tmp.29 tmp.30)
        (let ()
          (if (!= (if (= (bitwise-and tmp.30 7) 0) 14 6) 6)
            (if (!= (if (= (bitwise-and tmp.29 7) 0) 14 6) 6)
              (- tmp.29 tmp.30)
              830)
            830))))
    (define L.+.65.8
      (lambda (c.68 tmp.27 tmp.28)
        (let ()
          (if (!= (if (= (bitwise-and tmp.28 7) 0) 14 6) 6)
            (if (!= (if (= (bitwise-and tmp.27 7) 0) 14 6) 6)
              (+ tmp.27 tmp.28)
              574)
            574))))
    (define L.*.66.7
      (lambda (c.67 tmp.25 tmp.26)
        (let ()
          (if (!= (if (= (bitwise-and tmp.26 7) 0) 14 6) 6)
            (if (!= (if (= (bitwise-and tmp.25 7) 0) 14 6) 6)
              (* tmp.25 (arithmetic-shift-right tmp.26 3))
              318)
            318))))
    (let ((*.66
           (let ((tmp.77 (+ (alloc 16) 2)))
             (begin (mset! tmp.77 -2 L.*.66.7) (mset! tmp.77 6 16) tmp.77)))
          (|+.65|
           (let ((tmp.78 (+ (alloc 16) 2)))
             (begin (mset! tmp.78 -2 L.+.65.8) (mset! tmp.78 6 16) tmp.78)))
          (|-.64|
           (let ((tmp.79 (+ (alloc 16) 2)))
             (begin (mset! tmp.79 -2 L.-.64.9) (mset! tmp.79 6 16) tmp.79)))
          (vector-init-loop.13
           (let ((tmp.80 (+ (alloc 24) 2)))
             (begin
               (mset! tmp.80 -2 L.vector-init-loop.13.10)
               (mset! tmp.80 6 24)
               tmp.80)))
          (make-init-vector.1
           (let ((tmp.81 (+ (alloc 24) 2)))
             (begin
               (mset! tmp.81 -2 L.make-init-vector.1.11)
               (mset! tmp.81 6 8)
               tmp.81)))
          (make-vector.63
           (let ((tmp.82 (+ (alloc 24) 2)))
             (begin
               (mset! tmp.82 -2 L.make-vector.63.12)
               (mset! tmp.82 6 8)
               tmp.82)))
          (fun/empty8591.4
           (let ((tmp.83 (+ (alloc 16) 2)))
             (begin
               (mset! tmp.83 -2 L.fun/empty8591.4.13)
               (mset! tmp.83 6 0)
               tmp.83)))
          (fun/vector8589.5
           (let ((tmp.84 (+ (alloc 24) 2)))
             (begin
               (mset! tmp.84 -2 L.fun/vector8589.5.14)
               (mset! tmp.84 6 0)
               tmp.84)))
          (fun/ascii-char8590.6
           (let ((tmp.85 (+ (alloc 16) 2)))
             (begin
               (mset! tmp.85 -2 L.fun/ascii-char8590.6.15)
               (mset! tmp.85 6 0)
               tmp.85))))
      (begin
        (mset! vector-init-loop.13 14 vector-init-loop.13)
        (mset! make-init-vector.1 14 vector-init-loop.13)
        (mset! make-vector.63 14 make-init-vector.1)
        (mset! fun/vector8589.5 14 make-vector.63)
        (let ((fixnum0.10
               (call
                L.-.64.9
                |-.64|
                (call L.-.64.9 |-.64| 1720 576)
                (call L.-.64.9 |-.64| 1752 1384)))
              (vector1.9 (call L.fun/vector8589.5.14 fun/vector8589.5))
              (fixnum2.8
               (call
                L.+.65.8
                |+.65|
                (call L.+.65.8 |+.65| 744 1760)
                (call L.*.66.7 *.66 1360 1048)))
              (ascii-char3.7
               (call L.fun/ascii-char8590.6.15 fun/ascii-char8590.6)))
          (call L.fun/empty8591.4.13 fun/empty8591.4))))))
(check-by-interp
 '(module
    (define L.cons.56.7
      (lambda (c.57 tmp.51 tmp.52)
        (let ()
          (let ((tmp.58 (+ (alloc 16) 1)))
            (begin (mset! tmp.58 -1 tmp.51) (mset! tmp.58 7 tmp.52) tmp.58)))))
    (let ((cons.56
           (let ((tmp.59 (+ (alloc 16) 2)))
             (begin
               (mset! tmp.59 -2 L.cons.56.7)
               (mset! tmp.59 6 16)
               tmp.59))))
      (if (if (!= 14 6) (!= 14 6) (!= 6 6))
        (if (!= 14 6)
          (call L.cons.56.7 cons.56 408 3360)
          (call L.cons.56.7 cons.56 320 2912))
        (if (!= 14 6)
          (call L.cons.56.7 cons.56 1928 2800)
          (call L.cons.56.7 cons.56 896 2760))))))
(check-by-interp
 '(module
    (define L.lam.65.12
      (lambda (c.71)
        (let ((fun/error8691.5 (mref c.71 14)))
          (call L.fun/error8691.5.8 fun/error8691.5))))
    (define L.fun/void8690.8.11 (lambda (c.70) (let () 30)))
    (define L.fun/ascii-char8688.7.10 (lambda (c.69) (let () 27182)))
    (define L.fun/empty8692.6.9 (lambda (c.68) (let () 22)))
    (define L.fun/error8691.5.8 (lambda (c.67) (let () 31806)))
    (define L.fun/ascii-char8689.4.7 (lambda (c.66) (let () 18734)))
    (let ((fun/ascii-char8689.4
           (let ((tmp.72 (+ (alloc 16) 2)))
             (begin
               (mset! tmp.72 -2 L.fun/ascii-char8689.4.7)
               (mset! tmp.72 6 0)
               tmp.72)))
          (fun/error8691.5
           (let ((tmp.73 (+ (alloc 16) 2)))
             (begin
               (mset! tmp.73 -2 L.fun/error8691.5.8)
               (mset! tmp.73 6 0)
               tmp.73)))
          (fun/empty8692.6
           (let ((tmp.74 (+ (alloc 16) 2)))
             (begin
               (mset! tmp.74 -2 L.fun/empty8692.6.9)
               (mset! tmp.74 6 0)
               tmp.74)))
          (fun/ascii-char8688.7
           (let ((tmp.75 (+ (alloc 16) 2)))
             (begin
               (mset! tmp.75 -2 L.fun/ascii-char8688.7.10)
               (mset! tmp.75 6 0)
               tmp.75)))
          (fun/void8690.8
           (let ((tmp.76 (+ (alloc 16) 2)))
             (begin
               (mset! tmp.76 -2 L.fun/void8690.8.11)
               (mset! tmp.76 6 0)
               tmp.76))))
      (let ((ascii-char0.12
             (call L.fun/ascii-char8688.7.10 fun/ascii-char8688.7))
            (ascii-char1.11
             (call L.fun/ascii-char8689.4.7 fun/ascii-char8689.4))
            (void2.10 (call L.fun/void8690.8.11 fun/void8690.8))
            (procedure3.9
             (let ((lam.65
                    (let ((tmp.77 (+ (alloc 24) 2)))
                      (begin
                        (mset! tmp.77 -2 L.lam.65.12)
                        (mset! tmp.77 6 0)
                        tmp.77))))
               (begin (mset! lam.65 14 fun/error8691.5) lam.65))))
        (call L.fun/empty8692.6.9 fun/empty8692.6)))))
(check-by-interp
 '(module
    (define L.fun/any8764.8.16 (lambda (c.77) (let () 14142)))
    (define L.fun/void8763.7.15 (lambda (c.76) (let () 30)))
    (define L.fun/any8762.6.14 (lambda (c.75) (let () 30)))
    (define L.fun/ascii-char8761.5.13 (lambda (c.74) (let () 27438)))
    (define L.fun/vector8765.4.12
      (lambda (c.73)
        (let ((make-vector.65 (mref c.73 14)))
          (call L.make-vector.65.11 make-vector.65 64))))
    (define L.make-vector.65.11
      (lambda (c.72 tmp.41)
        (let ((make-init-vector.1 (mref c.72 14)))
          (if (!= (if (= (bitwise-and tmp.41 7) 0) 14 6) 6)
            (call L.make-init-vector.1.10 make-init-vector.1 tmp.41)
            2110))))
    (define L.make-init-vector.1.10
      (lambda (c.71 tmp.13)
        (let ((vector-init-loop.15 (mref c.71 14)))
          (let ((tmp.14
                 (let ((tmp.78
                        (+
                         (alloc (* (+ 1 (arithmetic-shift-right tmp.13 3)) 8))
                         3)))
                   (begin (mset! tmp.78 -3 tmp.13) tmp.78))))
            (call
             L.vector-init-loop.15.9
             vector-init-loop.15
             tmp.13
             0
             tmp.14)))))
    (define L.vector-init-loop.15.9
      (lambda (c.70 len.16 i.18 vec.17)
        (let ((vector-init-loop.15 (mref c.70 14)))
          (if (!= (if (= len.16 i.18) 14 6) 6)
            vec.17
            (begin
              (mset! vec.17 (+ (* (arithmetic-shift-right i.18 3) 8) 5) 0)
              (call
               L.vector-init-loop.15.9
               vector-init-loop.15
               len.16
               (+ i.18 8)
               vec.17))))))
    (define L.vector?.66.8
      (lambda (c.69 tmp.57) (let () (if (= (bitwise-and tmp.57 7) 3) 14 6))))
    (define L.boolean?.67.7
      (lambda (c.68 tmp.51) (let () (if (= (bitwise-and tmp.51 247) 6) 14 6))))
    (let ((boolean?.67
           (let ((tmp.79 (+ (alloc 16) 2)))
             (begin
               (mset! tmp.79 -2 L.boolean?.67.7)
               (mset! tmp.79 6 8)
               tmp.79)))
          (vector?.66
           (let ((tmp.80 (+ (alloc 16) 2)))
             (begin
               (mset! tmp.80 -2 L.vector?.66.8)
               (mset! tmp.80 6 8)
               tmp.80)))
          (vector-init-loop.15
           (let ((tmp.81 (+ (alloc 24) 2)))
             (begin
               (mset! tmp.81 -2 L.vector-init-loop.15.9)
               (mset! tmp.81 6 24)
               tmp.81)))
          (make-init-vector.1
           (let ((tmp.82 (+ (alloc 24) 2)))
             (begin
               (mset! tmp.82 -2 L.make-init-vector.1.10)
               (mset! tmp.82 6 8)
               tmp.82)))
          (make-vector.65
           (let ((tmp.83 (+ (alloc 24) 2)))
             (begin
               (mset! tmp.83 -2 L.make-vector.65.11)
               (mset! tmp.83 6 8)
               tmp.83)))
          (fun/vector8765.4
           (let ((tmp.84 (+ (alloc 24) 2)))
             (begin
               (mset! tmp.84 -2 L.fun/vector8765.4.12)
               (mset! tmp.84 6 0)
               tmp.84)))
          (fun/ascii-char8761.5
           (let ((tmp.85 (+ (alloc 16) 2)))
             (begin
               (mset! tmp.85 -2 L.fun/ascii-char8761.5.13)
               (mset! tmp.85 6 0)
               tmp.85)))
          (fun/any8762.6
           (let ((tmp.86 (+ (alloc 16) 2)))
             (begin
               (mset! tmp.86 -2 L.fun/any8762.6.14)
               (mset! tmp.86 6 0)
               tmp.86)))
          (fun/void8763.7
           (let ((tmp.87 (+ (alloc 16) 2)))
             (begin
               (mset! tmp.87 -2 L.fun/void8763.7.15)
               (mset! tmp.87 6 0)
               tmp.87)))
          (fun/any8764.8
           (let ((tmp.88 (+ (alloc 16) 2)))
             (begin
               (mset! tmp.88 -2 L.fun/any8764.8.16)
               (mset! tmp.88 6 0)
               tmp.88))))
      (begin
        (mset! vector-init-loop.15 14 vector-init-loop.15)
        (mset! make-init-vector.1 14 vector-init-loop.15)
        (mset! make-vector.65 14 make-init-vector.1)
        (mset! fun/vector8765.4 14 make-vector.65)
        (let ((ascii-char0.12
               (call L.fun/ascii-char8761.5.13 fun/ascii-char8761.5))
              (boolean1.11
               (call
                L.vector?.66.8
                vector?.66
                (call L.fun/any8762.6.14 fun/any8762.6)))
              (void2.10 (call L.fun/void8763.7.15 fun/void8763.7))
              (boolean3.9
               (call
                L.boolean?.67.7
                boolean?.67
                (call L.fun/any8764.8.16 fun/any8764.8))))
          (call L.fun/vector8765.4.12 fun/vector8765.4))))))
(check-by-interp
 '(module
    (define L.lam.110.27 (lambda (c.131) (let () 22574)))
    (define L.fun/pair8798.16.26
      (lambda (c.130)
        (let ((cons.105 (mref c.130 14)))
          (call L.cons.105.13 cons.105 192 2216))))
    (define L.fun/ascii-char8794.15.25
      (lambda (c.129 oprand0.40 oprand1.39 oprand2.38)
        (let ((fun/ascii-char8795.12 (mref c.129 14)))
          (call L.fun/ascii-char8795.12.22 fun/ascii-char8795.12))))
    (define L.fun/error8800.14.24
      (lambda (c.128 oprand0.37 oprand1.36 oprand2.35) (let () oprand2.35)))
    (define L.fun/fixnum8792.13.23 (lambda (c.127) (let () 1480)))
    (define L.fun/ascii-char8795.12.22 (lambda (c.126) (let () 19246)))
    (define L.fun/fixnum8796.11.21
      (lambda (c.125 oprand0.34 oprand1.33 oprand2.32) (let () 2032)))
    (define L.fun/pair8790.10.20
      (lambda (c.124)
        (let ((cons.105 (mref c.124 14)))
          (call L.cons.105.13 cons.105 200 3880))))
    (define L.fun/empty8793.9.19
      (lambda (c.123 oprand0.31 oprand1.30 oprand2.29) (let () 22)))
    (define L.fun/pair8788.8.18
      (lambda (c.122 oprand0.28 oprand1.27 oprand2.26)
        (let ((fun/pair8789.7 (mref c.122 14)))
          (call L.fun/pair8789.7.17 fun/pair8789.7))))
    (define L.fun/pair8789.7.17
      (lambda (c.121)
        (let ((fun/pair8790.10 (mref c.121 14)))
          (call L.fun/pair8790.10.20 fun/pair8790.10))))
    (define L.fun/error8799.6.16
      (lambda (c.120 oprand0.25 oprand1.24 oprand2.23) (let () 40510)))
    (define L.fun/pair8797.5.15
      (lambda (c.119 oprand0.22 oprand1.21 oprand2.20)
        (let ((fun/pair8798.16 (mref c.119 14)))
          (call L.fun/pair8798.16.26 fun/pair8798.16))))
    (define L.fun/fixnum8791.4.14
      (lambda (c.118 oprand0.19 oprand1.18 oprand2.17)
        (let ((fun/fixnum8792.13 (mref c.118 14)))
          (call L.fun/fixnum8792.13.23 fun/fixnum8792.13))))
    (define L.cons.105.13
      (lambda (c.117 tmp.100 tmp.101)
        (let ()
          (let ((tmp.132 (+ (alloc 16) 1)))
            (begin
              (mset! tmp.132 -1 tmp.100)
              (mset! tmp.132 7 tmp.101)
              tmp.132)))))
    (define L.make-vector.106.12
      (lambda (c.116 tmp.81)
        (let ((make-init-vector.1 (mref c.116 14)))
          (if (!= (if (= (bitwise-and tmp.81 7) 0) 14 6) 6)
            (call L.make-init-vector.1.11 make-init-vector.1 tmp.81)
            2110))))
    (define L.make-init-vector.1.11
      (lambda (c.115 tmp.53)
        (let ((vector-init-loop.55 (mref c.115 14)))
          (let ((tmp.54
                 (let ((tmp.133
                        (+
                         (alloc (* (+ 1 (arithmetic-shift-right tmp.53 3)) 8))
                         3)))
                   (begin (mset! tmp.133 -3 tmp.53) tmp.133))))
            (call
             L.vector-init-loop.55.10
             vector-init-loop.55
             tmp.53
             0
             tmp.54)))))
    (define L.vector-init-loop.55.10
      (lambda (c.114 len.56 i.58 vec.57)
        (let ((vector-init-loop.55 (mref c.114 14)))
          (if (!= (if (= len.56 i.58) 14 6) 6)
            vec.57
            (begin
              (mset! vec.57 (+ (* (arithmetic-shift-right i.58 3) 8) 5) 0)
              (call
               L.vector-init-loop.55.10
               vector-init-loop.55
               len.56
               (+ i.58 8)
               vec.57))))))
    (define L.ascii-char?.107.9
      (lambda (c.113 tmp.94)
        (let () (if (= (bitwise-and tmp.94 255) 46) 14 6))))
    (define L.>.108.8
      (lambda (c.112 tmp.77 tmp.78)
        (let ()
          (if (!= (if (= (bitwise-and tmp.78 7) 0) 14 6) 6)
            (if (!= (if (= (bitwise-and tmp.77 7) 0) 14 6) 6)
              (if (> tmp.77 tmp.78) 14 6)
              1598)
            1598))))
    (define L.*.109.7
      (lambda (c.111 tmp.67 tmp.68)
        (let ()
          (if (!= (if (= (bitwise-and tmp.68 7) 0) 14 6) 6)
            (if (!= (if (= (bitwise-and tmp.67 7) 0) 14 6) 6)
              (* tmp.67 (arithmetic-shift-right tmp.68 3))
              318)
            318))))
    (let ((*.109
           (let ((tmp.134 (+ (alloc 16) 2)))
             (begin
               (mset! tmp.134 -2 L.*.109.7)
               (mset! tmp.134 6 16)
               tmp.134)))
          (>.108
           (let ((tmp.135 (+ (alloc 16) 2)))
             (begin
               (mset! tmp.135 -2 L.>.108.8)
               (mset! tmp.135 6 16)
               tmp.135)))
          (ascii-char?.107
           (let ((tmp.136 (+ (alloc 16) 2)))
             (begin
               (mset! tmp.136 -2 L.ascii-char?.107.9)
               (mset! tmp.136 6 8)
               tmp.136)))
          (vector-init-loop.55
           (let ((tmp.137 (+ (alloc 24) 2)))
             (begin
               (mset! tmp.137 -2 L.vector-init-loop.55.10)
               (mset! tmp.137 6 24)
               tmp.137)))
          (make-init-vector.1
           (let ((tmp.138 (+ (alloc 24) 2)))
             (begin
               (mset! tmp.138 -2 L.make-init-vector.1.11)
               (mset! tmp.138 6 8)
               tmp.138)))
          (make-vector.106
           (let ((tmp.139 (+ (alloc 24) 2)))
             (begin
               (mset! tmp.139 -2 L.make-vector.106.12)
               (mset! tmp.139 6 8)
               tmp.139)))
          (cons.105
           (let ((tmp.140 (+ (alloc 16) 2)))
             (begin
               (mset! tmp.140 -2 L.cons.105.13)
               (mset! tmp.140 6 16)
               tmp.140)))
          (fun/fixnum8791.4
           (let ((tmp.141 (+ (alloc 24) 2)))
             (begin
               (mset! tmp.141 -2 L.fun/fixnum8791.4.14)
               (mset! tmp.141 6 24)
               tmp.141)))
          (fun/pair8797.5
           (let ((tmp.142 (+ (alloc 24) 2)))
             (begin
               (mset! tmp.142 -2 L.fun/pair8797.5.15)
               (mset! tmp.142 6 24)
               tmp.142)))
          (fun/error8799.6
           (let ((tmp.143 (+ (alloc 16) 2)))
             (begin
               (mset! tmp.143 -2 L.fun/error8799.6.16)
               (mset! tmp.143 6 24)
               tmp.143)))
          (fun/pair8789.7
           (let ((tmp.144 (+ (alloc 24) 2)))
             (begin
               (mset! tmp.144 -2 L.fun/pair8789.7.17)
               (mset! tmp.144 6 0)
               tmp.144)))
          (fun/pair8788.8
           (let ((tmp.145 (+ (alloc 24) 2)))
             (begin
               (mset! tmp.145 -2 L.fun/pair8788.8.18)
               (mset! tmp.145 6 24)
               tmp.145)))
          (fun/empty8793.9
           (let ((tmp.146 (+ (alloc 16) 2)))
             (begin
               (mset! tmp.146 -2 L.fun/empty8793.9.19)
               (mset! tmp.146 6 24)
               tmp.146)))
          (fun/pair8790.10
           (let ((tmp.147 (+ (alloc 24) 2)))
             (begin
               (mset! tmp.147 -2 L.fun/pair8790.10.20)
               (mset! tmp.147 6 0)
               tmp.147)))
          (fun/fixnum8796.11
           (let ((tmp.148 (+ (alloc 16) 2)))
             (begin
               (mset! tmp.148 -2 L.fun/fixnum8796.11.21)
               (mset! tmp.148 6 24)
               tmp.148)))
          (fun/ascii-char8795.12
           (let ((tmp.149 (+ (alloc 16) 2)))
             (begin
               (mset! tmp.149 -2 L.fun/ascii-char8795.12.22)
               (mset! tmp.149 6 0)
               tmp.149)))
          (fun/fixnum8792.13
           (let ((tmp.150 (+ (alloc 16) 2)))
             (begin
               (mset! tmp.150 -2 L.fun/fixnum8792.13.23)
               (mset! tmp.150 6 0)
               tmp.150)))
          (fun/error8800.14
           (let ((tmp.151 (+ (alloc 16) 2)))
             (begin
               (mset! tmp.151 -2 L.fun/error8800.14.24)
               (mset! tmp.151 6 24)
               tmp.151)))
          (fun/ascii-char8794.15
           (let ((tmp.152 (+ (alloc 24) 2)))
             (begin
               (mset! tmp.152 -2 L.fun/ascii-char8794.15.25)
               (mset! tmp.152 6 24)
               tmp.152)))
          (fun/pair8798.16
           (let ((tmp.153 (+ (alloc 24) 2)))
             (begin
               (mset! tmp.153 -2 L.fun/pair8798.16.26)
               (mset! tmp.153 6 0)
               tmp.153))))
      (begin
        (mset! vector-init-loop.55 14 vector-init-loop.55)
        (mset! make-init-vector.1 14 vector-init-loop.55)
        (mset! make-vector.106 14 make-init-vector.1)
        (mset! fun/fixnum8791.4 14 fun/fixnum8792.13)
        (mset! fun/pair8797.5 14 fun/pair8798.16)
        (mset! fun/pair8789.7 14 fun/pair8790.10)
        (mset! fun/pair8788.8 14 fun/pair8789.7)
        (mset! fun/pair8790.10 14 cons.105)
        (mset! fun/ascii-char8794.15 14 fun/ascii-char8795.12)
        (mset! fun/pair8798.16 14 cons.105)
        (call
         L.fun/pair8788.8.18
         fun/pair8788.8
         (call
          L.>.108.8
          >.108
          (call
           L.fun/fixnum8791.4.14
           fun/fixnum8791.4
           (call L.fun/empty8793.9.19 fun/empty8793.9 2000 14 2878)
           (if (!= 6 6) 22 22)
           (call
            L.ascii-char?.107.9
            ascii-char?.107
            (call L.make-vector.106.12 make-vector.106 64)))
          (if (!= 14 6) 1456 1672))
         (call
          L.fun/ascii-char8794.15.25
          fun/ascii-char8794.15
          (call
           L.*.109.7
           *.109
           (let ((error0.44 54078)
                 (fixnum1.43 1792)
                 (vector2.42 (call L.make-vector.106.12 make-vector.106 64))
                 (procedure3.41
                  (let ((lam.110
                         (let ((tmp.154 (+ (alloc 16) 2)))
                           (begin
                             (mset! tmp.154 -2 L.lam.110.27)
                             (mset! tmp.154 6 0)
                             tmp.154))))
                    lam.110)))
             1808)
           (call L.fun/fixnum8796.11.21 fun/fixnum8796.11 1392 57406 30))
          (call
           L.fun/pair8797.5.15
           fun/pair8797.5
           (call L.fun/error8799.6.16 fun/error8799.6 22 48 30)
           (if (!= 14 6) 30 30)
           (call
            L.fun/ascii-char8794.15.25
            fun/ascii-char8794.15
            632
            (call L.cons.105.13 cons.105 344 2856)
            (call L.make-vector.106.12 make-vector.106 64)))
          (if (!= 6 6)
            (call L.make-vector.106.12 make-vector.106 64)
            (call L.make-vector.106.12 make-vector.106 64)))
         (call
          L.fun/error8800.14.24
          fun/error8800.14
          (if (!= 14 6)
            (call L.make-vector.106.12 make-vector.106 64)
            (call L.make-vector.106.12 make-vector.106 64))
          (let ((vector0.48 (call L.make-vector.106.12 make-vector.106 64))
                (vector1.47 (call L.make-vector.106.12 make-vector.106 64))
                (ascii-char2.46 23854)
                (vector3.45 (call L.make-vector.106.12 make-vector.106 64)))
            30)
          (let ((boolean0.52 14) (void1.51 30) (boolean2.50 6) (boolean3.49 6))
            56382)))))))
(check-by-interp
 '(module
    (define L.fun/void8928.15.18 (lambda (c.84) (let () 30)))
    (define L.fun/error8924.14.17 (lambda (c.83) (let () 33342)))
    (define L.fun/ascii-char8925.13.16
      (lambda (c.82)
        (let ((fun/ascii-char8926.5 (mref c.82 14)))
          (call L.fun/ascii-char8926.5.8 fun/ascii-char8926.5))))
    (define L.fun/error8920.12.15 (lambda (c.81) (let () 47422)))
    (define L.fun/empty8930.11.14 (lambda (c.80) (let () 22)))
    (define L.fun/ascii-char8922.10.13 (lambda (c.79) (let () 27438)))
    (define L.fun/error8919.9.12
      (lambda (c.78)
        (let ((fun/error8920.12 (mref c.78 14)))
          (call L.fun/error8920.12.15 fun/error8920.12))))
    (define L.fun/ascii-char8921.8.11
      (lambda (c.77)
        (let ((fun/ascii-char8922.10 (mref c.77 14)))
          (call L.fun/ascii-char8922.10.13 fun/ascii-char8922.10))))
    (define L.fun/void8927.7.10
      (lambda (c.76)
        (let ((fun/void8928.15 (mref c.76 14)))
          (call L.fun/void8928.15.18 fun/void8928.15))))
    (define L.fun/empty8929.6.9
      (lambda (c.75)
        (let ((fun/empty8930.11 (mref c.75 14)))
          (call L.fun/empty8930.11.14 fun/empty8930.11))))
    (define L.fun/ascii-char8926.5.8 (lambda (c.74) (let () 30766)))
    (define L.fun/error8923.4.7
      (lambda (c.73)
        (let ((fun/error8924.14 (mref c.73 14)))
          (call L.fun/error8924.14.17 fun/error8924.14))))
    (let ((fun/error8923.4
           (let ((tmp.85 (+ (alloc 24) 2)))
             (begin
               (mset! tmp.85 -2 L.fun/error8923.4.7)
               (mset! tmp.85 6 0)
               tmp.85)))
          (fun/ascii-char8926.5
           (let ((tmp.86 (+ (alloc 16) 2)))
             (begin
               (mset! tmp.86 -2 L.fun/ascii-char8926.5.8)
               (mset! tmp.86 6 0)
               tmp.86)))
          (fun/empty8929.6
           (let ((tmp.87 (+ (alloc 24) 2)))
             (begin
               (mset! tmp.87 -2 L.fun/empty8929.6.9)
               (mset! tmp.87 6 0)
               tmp.87)))
          (fun/void8927.7
           (let ((tmp.88 (+ (alloc 24) 2)))
             (begin
               (mset! tmp.88 -2 L.fun/void8927.7.10)
               (mset! tmp.88 6 0)
               tmp.88)))
          (fun/ascii-char8921.8
           (let ((tmp.89 (+ (alloc 24) 2)))
             (begin
               (mset! tmp.89 -2 L.fun/ascii-char8921.8.11)
               (mset! tmp.89 6 0)
               tmp.89)))
          (fun/error8919.9
           (let ((tmp.90 (+ (alloc 24) 2)))
             (begin
               (mset! tmp.90 -2 L.fun/error8919.9.12)
               (mset! tmp.90 6 0)
               tmp.90)))
          (fun/ascii-char8922.10
           (let ((tmp.91 (+ (alloc 16) 2)))
             (begin
               (mset! tmp.91 -2 L.fun/ascii-char8922.10.13)
               (mset! tmp.91 6 0)
               tmp.91)))
          (fun/empty8930.11
           (let ((tmp.92 (+ (alloc 16) 2)))
             (begin
               (mset! tmp.92 -2 L.fun/empty8930.11.14)
               (mset! tmp.92 6 0)
               tmp.92)))
          (fun/error8920.12
           (let ((tmp.93 (+ (alloc 16) 2)))
             (begin
               (mset! tmp.93 -2 L.fun/error8920.12.15)
               (mset! tmp.93 6 0)
               tmp.93)))
          (fun/ascii-char8925.13
           (let ((tmp.94 (+ (alloc 24) 2)))
             (begin
               (mset! tmp.94 -2 L.fun/ascii-char8925.13.16)
               (mset! tmp.94 6 0)
               tmp.94)))
          (fun/error8924.14
           (let ((tmp.95 (+ (alloc 16) 2)))
             (begin
               (mset! tmp.95 -2 L.fun/error8924.14.17)
               (mset! tmp.95 6 0)
               tmp.95)))
          (fun/void8928.15
           (let ((tmp.96 (+ (alloc 16) 2)))
             (begin
               (mset! tmp.96 -2 L.fun/void8928.15.18)
               (mset! tmp.96 6 0)
               tmp.96))))
      (begin
        (mset! fun/error8923.4 14 fun/error8924.14)
        (mset! fun/empty8929.6 14 fun/empty8930.11)
        (mset! fun/void8927.7 14 fun/void8928.15)
        (mset! fun/ascii-char8921.8 14 fun/ascii-char8922.10)
        (mset! fun/error8919.9 14 fun/error8920.12)
        (mset! fun/ascii-char8925.13 14 fun/ascii-char8926.5)
        (let ((error0.20 (call L.fun/error8919.9.12 fun/error8919.9))
              (ascii-char1.19
               (call L.fun/ascii-char8921.8.11 fun/ascii-char8921.8))
              (error2.18 (call L.fun/error8923.4.7 fun/error8923.4))
              (ascii-char3.17
               (call L.fun/ascii-char8925.13.16 fun/ascii-char8925.13))
              (void4.16 (call L.fun/void8927.7.10 fun/void8927.7)))
          (call L.fun/empty8929.6.9 fun/empty8929.6))))))
(check-by-interp
 '(module
    (define L.lam.72.18
      (lambda (c.84)
        (let ((|-.67| (mref c.84 14))
              (|+.69| (mref c.84 22))
              (<=.70 (mref c.84 30)))
          (call
           L.<=.70.8
           <=.70
           (call
            L.+.69.9
            |+.69|
            (call L.+.69.9 |+.69| 808 912)
            (call L.+.69.9 |+.69| 704 432))
           (call
            L.+.69.9
            |+.69|
            (call L.+.69.9 |+.69| 472 16)
            (call L.-.67.11 |-.67| 376 608))))))
    (define L.fun/void9118.9.17
      (lambda (c.83)
        (let ((fun/void9119.7 (mref c.83 14)))
          (call L.fun/void9119.7.15 fun/void9119.7))))
    (define L.fun/ascii-char9122.8.16
      (lambda (c.82)
        (let ((fun/ascii-char9123.5 (mref c.82 14)))
          (call L.fun/ascii-char9123.5.13 fun/ascii-char9123.5))))
    (define L.fun/void9119.7.15 (lambda (c.81) (let () 30)))
    (define L.fun/empty9120.6.14
      (lambda (c.80)
        (let ((fun/empty9121.4 (mref c.80 14)))
          (call L.fun/empty9121.4.12 fun/empty9121.4))))
    (define L.fun/ascii-char9123.5.13 (lambda (c.79) (let () 29486)))
    (define L.fun/empty9121.4.12 (lambda (c.78) (let () 22)))
    (define L.-.67.11
      (lambda (c.77 tmp.33 tmp.34)
        (let ()
          (if (!= (if (= (bitwise-and tmp.34 7) 0) 14 6) 6)
            (if (!= (if (= (bitwise-and tmp.33 7) 0) 14 6) 6)
              (- tmp.33 tmp.34)
              830)
            830))))
    (define L.*.68.10
      (lambda (c.76 tmp.29 tmp.30)
        (let ()
          (if (!= (if (= (bitwise-and tmp.30 7) 0) 14 6) 6)
            (if (!= (if (= (bitwise-and tmp.29 7) 0) 14 6) 6)
              (* tmp.29 (arithmetic-shift-right tmp.30 3))
              318)
            318))))
    (define L.+.69.9
      (lambda (c.75 tmp.31 tmp.32)
        (let ()
          (if (!= (if (= (bitwise-and tmp.32 7) 0) 14 6) 6)
            (if (!= (if (= (bitwise-and tmp.31 7) 0) 14 6) 6)
              (+ tmp.31 tmp.32)
              574)
            574))))
    (define L.<=.70.8
      (lambda (c.74 tmp.37 tmp.38)
        (let ()
          (if (!= (if (= (bitwise-and tmp.38 7) 0) 14 6) 6)
            (if (!= (if (= (bitwise-and tmp.37 7) 0) 14 6) 6)
              (if (<= tmp.37 tmp.38) 14 6)
              1342)
            1342))))
    (define L.>=.71.7
      (lambda (c.73 tmp.41 tmp.42)
        (let ()
          (if (!= (if (= (bitwise-and tmp.42 7) 0) 14 6) 6)
            (if (!= (if (= (bitwise-and tmp.41 7) 0) 14 6) 6)
              (if (>= tmp.41 tmp.42) 14 6)
              1854)
            1854))))
    (let ((>=.71
           (let ((tmp.85 (+ (alloc 16) 2)))
             (begin (mset! tmp.85 -2 L.>=.71.7) (mset! tmp.85 6 16) tmp.85)))
          (<=.70
           (let ((tmp.86 (+ (alloc 16) 2)))
             (begin (mset! tmp.86 -2 L.<=.70.8) (mset! tmp.86 6 16) tmp.86)))
          (|+.69|
           (let ((tmp.87 (+ (alloc 16) 2)))
             (begin (mset! tmp.87 -2 L.+.69.9) (mset! tmp.87 6 16) tmp.87)))
          (*.68
           (let ((tmp.88 (+ (alloc 16) 2)))
             (begin (mset! tmp.88 -2 L.*.68.10) (mset! tmp.88 6 16) tmp.88)))
          (|-.67|
           (let ((tmp.89 (+ (alloc 16) 2)))
             (begin (mset! tmp.89 -2 L.-.67.11) (mset! tmp.89 6 16) tmp.89)))
          (fun/empty9121.4
           (let ((tmp.90 (+ (alloc 16) 2)))
             (begin
               (mset! tmp.90 -2 L.fun/empty9121.4.12)
               (mset! tmp.90 6 0)
               tmp.90)))
          (fun/ascii-char9123.5
           (let ((tmp.91 (+ (alloc 16) 2)))
             (begin
               (mset! tmp.91 -2 L.fun/ascii-char9123.5.13)
               (mset! tmp.91 6 0)
               tmp.91)))
          (fun/empty9120.6
           (let ((tmp.92 (+ (alloc 24) 2)))
             (begin
               (mset! tmp.92 -2 L.fun/empty9120.6.14)
               (mset! tmp.92 6 0)
               tmp.92)))
          (fun/void9119.7
           (let ((tmp.93 (+ (alloc 16) 2)))
             (begin
               (mset! tmp.93 -2 L.fun/void9119.7.15)
               (mset! tmp.93 6 0)
               tmp.93)))
          (fun/ascii-char9122.8
           (let ((tmp.94 (+ (alloc 24) 2)))
             (begin
               (mset! tmp.94 -2 L.fun/ascii-char9122.8.16)
               (mset! tmp.94 6 0)
               tmp.94)))
          (fun/void9118.9
           (let ((tmp.95 (+ (alloc 24) 2)))
             (begin
               (mset! tmp.95 -2 L.fun/void9118.9.17)
               (mset! tmp.95 6 0)
               tmp.95))))
      (begin
        (mset! fun/empty9120.6 14 fun/empty9121.4)
        (mset! fun/ascii-char9122.8 14 fun/ascii-char9123.5)
        (mset! fun/void9118.9 14 fun/void9119.7)
        (let ((void0.14 (call L.fun/void9118.9.17 fun/void9118.9))
              (fixnum1.13
               (call
                L.*.68.10
                *.68
                (call
                 L.*.68.10
                 *.68
                 (call L.-.67.11 |-.67| 200 1808)
                 (call L.-.67.11 |-.67| 1272 448))
                (call
                 L.-.67.11
                 |-.67|
                 (call L.*.68.10 *.68 1536 976)
                 (call L.-.67.11 |-.67| 376 688))))
              (empty2.12 (call L.fun/empty9120.6.14 fun/empty9120.6))
              (procedure3.11
               (let ((lam.72
                      (let ((tmp.96 (+ (alloc 40) 2)))
                        (begin
                          (mset! tmp.96 -2 L.lam.72.18)
                          (mset! tmp.96 6 0)
                          tmp.96))))
                 (begin
                   (mset! lam.72 14 |-.67|)
                   (mset! lam.72 22 |+.69|)
                   (mset! lam.72 30 <=.70)
                   lam.72)))
              (ascii-char4.10
               (call L.fun/ascii-char9122.8.16 fun/ascii-char9122.8)))
          (call
           L.>=.71.7
           >=.71
           (call
            L.-.67.11
            |-.67|
            (call L.+.69.9 |+.69| 544 1336)
            (call L.+.69.9 |+.69| 1336 1256))
           (call
            L.-.67.11
            |-.67|
            (call L.-.67.11 |-.67| 240 1240)
            (call L.+.69.9 |+.69| 224 808))))))))
(check-by-interp
 '(module
    (define L.lam.80.23
      (lambda (c.97)
        (let ((fun/ascii-char9132.7 (mref c.97 14)))
          (call L.fun/ascii-char9132.7.15 fun/ascii-char9132.7))))
    (define L.lam.79.22
      (lambda (c.96)
        (let ((fun/void9126.12 (mref c.96 14)))
          (call L.fun/void9126.12.20 fun/void9126.12))))
    (define L.fun/ascii-char9135.13.21 (lambda (c.95) (let () 29998)))
    (define L.fun/void9126.12.20 (lambda (c.94) (let () 30)))
    (define L.fun/vector9134.11.19
      (lambda (c.93)
        (let ((make-vector.76 (mref c.93 14)))
          (call L.make-vector.76.11 make-vector.76 64))))
    (define L.fun/ascii-char9129.10.18 (lambda (c.92) (let () 20526)))
    (define L.fun/vector9133.9.17
      (lambda (c.91)
        (let ((make-vector.76 (mref c.91 14)))
          (call L.make-vector.76.11 make-vector.76 64))))
    (define L.fun/ascii-char9130.8.16 (lambda (c.90) (let () 28718)))
    (define L.fun/ascii-char9132.7.15 (lambda (c.89) (let () 28718)))
    (define L.fun/empty9128.6.14 (lambda (c.88) (let () 22)))
    (define L.fun/ascii-char9131.5.13 (lambda (c.87) (let () 28462)))
    (define L.fun/error9127.4.12 (lambda (c.86) (let () 42814)))
    (define L.make-vector.76.11
      (lambda (c.85 tmp.52)
        (let ((make-init-vector.1 (mref c.85 14)))
          (if (!= (if (= (bitwise-and tmp.52 7) 0) 14 6) 6)
            (call L.make-init-vector.1.10 make-init-vector.1 tmp.52)
            2110))))
    (define L.make-init-vector.1.10
      (lambda (c.84 tmp.24)
        (let ((vector-init-loop.26 (mref c.84 14)))
          (let ((tmp.25
                 (let ((tmp.98
                        (+
                         (alloc (* (+ 1 (arithmetic-shift-right tmp.24 3)) 8))
                         3)))
                   (begin (mset! tmp.98 -3 tmp.24) tmp.98))))
            (call
             L.vector-init-loop.26.9
             vector-init-loop.26
             tmp.24
             0
             tmp.25)))))
    (define L.vector-init-loop.26.9
      (lambda (c.83 len.27 i.29 vec.28)
        (let ((vector-init-loop.26 (mref c.83 14)))
          (if (!= (if (= len.27 i.29) 14 6) 6)
            vec.28
            (begin
              (mset! vec.28 (+ (* (arithmetic-shift-right i.29 3) 8) 5) 0)
              (call
               L.vector-init-loop.26.9
               vector-init-loop.26
               len.27
               (+ i.29 8)
               vec.28))))))
    (define L.vector?.77.8
      (lambda (c.82 tmp.68) (let () (if (= (bitwise-and tmp.68 7) 3) 14 6))))
    (define L.<=.78.7
      (lambda (c.81 tmp.46 tmp.47)
        (let ()
          (if (!= (if (= (bitwise-and tmp.47 7) 0) 14 6) 6)
            (if (!= (if (= (bitwise-and tmp.46 7) 0) 14 6) 6)
              (if (<= tmp.46 tmp.47) 14 6)
              1342)
            1342))))
    (let ((<=.78
           (let ((tmp.99 (+ (alloc 16) 2)))
             (begin (mset! tmp.99 -2 L.<=.78.7) (mset! tmp.99 6 16) tmp.99)))
          (vector?.77
           (let ((tmp.100 (+ (alloc 16) 2)))
             (begin
               (mset! tmp.100 -2 L.vector?.77.8)
               (mset! tmp.100 6 8)
               tmp.100)))
          (vector-init-loop.26
           (let ((tmp.101 (+ (alloc 24) 2)))
             (begin
               (mset! tmp.101 -2 L.vector-init-loop.26.9)
               (mset! tmp.101 6 24)
               tmp.101)))
          (make-init-vector.1
           (let ((tmp.102 (+ (alloc 24) 2)))
             (begin
               (mset! tmp.102 -2 L.make-init-vector.1.10)
               (mset! tmp.102 6 8)
               tmp.102)))
          (make-vector.76
           (let ((tmp.103 (+ (alloc 24) 2)))
             (begin
               (mset! tmp.103 -2 L.make-vector.76.11)
               (mset! tmp.103 6 8)
               tmp.103)))
          (fun/error9127.4
           (let ((tmp.104 (+ (alloc 16) 2)))
             (begin
               (mset! tmp.104 -2 L.fun/error9127.4.12)
               (mset! tmp.104 6 0)
               tmp.104)))
          (fun/ascii-char9131.5
           (let ((tmp.105 (+ (alloc 16) 2)))
             (begin
               (mset! tmp.105 -2 L.fun/ascii-char9131.5.13)
               (mset! tmp.105 6 0)
               tmp.105)))
          (fun/empty9128.6
           (let ((tmp.106 (+ (alloc 16) 2)))
             (begin
               (mset! tmp.106 -2 L.fun/empty9128.6.14)
               (mset! tmp.106 6 0)
               tmp.106)))
          (fun/ascii-char9132.7
           (let ((tmp.107 (+ (alloc 16) 2)))
             (begin
               (mset! tmp.107 -2 L.fun/ascii-char9132.7.15)
               (mset! tmp.107 6 0)
               tmp.107)))
          (fun/ascii-char9130.8
           (let ((tmp.108 (+ (alloc 16) 2)))
             (begin
               (mset! tmp.108 -2 L.fun/ascii-char9130.8.16)
               (mset! tmp.108 6 0)
               tmp.108)))
          (fun/vector9133.9
           (let ((tmp.109 (+ (alloc 24) 2)))
             (begin
               (mset! tmp.109 -2 L.fun/vector9133.9.17)
               (mset! tmp.109 6 0)
               tmp.109)))
          (fun/ascii-char9129.10
           (let ((tmp.110 (+ (alloc 16) 2)))
             (begin
               (mset! tmp.110 -2 L.fun/ascii-char9129.10.18)
               (mset! tmp.110 6 0)
               tmp.110)))
          (fun/vector9134.11
           (let ((tmp.111 (+ (alloc 24) 2)))
             (begin
               (mset! tmp.111 -2 L.fun/vector9134.11.19)
               (mset! tmp.111 6 0)
               tmp.111)))
          (fun/void9126.12
           (let ((tmp.112 (+ (alloc 16) 2)))
             (begin
               (mset! tmp.112 -2 L.fun/void9126.12.20)
               (mset! tmp.112 6 0)
               tmp.112)))
          (fun/ascii-char9135.13
           (let ((tmp.113 (+ (alloc 16) 2)))
             (begin
               (mset! tmp.113 -2 L.fun/ascii-char9135.13.21)
               (mset! tmp.113 6 0)
               tmp.113))))
      (begin
        (mset! vector-init-loop.26 14 vector-init-loop.26)
        (mset! make-init-vector.1 14 vector-init-loop.26)
        (mset! make-vector.76 14 make-init-vector.1)
        (mset! fun/vector9133.9 14 make-vector.76)
        (mset! fun/vector9134.11 14 make-vector.76)
        (if (!= (call L.vector?.77.8 vector?.77 (if (!= 6 6) 22 30)) 6)
          (let ((procedure0.18
                 (let ((lam.79
                        (let ((tmp.114 (+ (alloc 24) 2)))
                          (begin
                            (mset! tmp.114 -2 L.lam.79.22)
                            (mset! tmp.114 6 0)
                            tmp.114))))
                   (begin (mset! lam.79 14 fun/void9126.12) lam.79)))
                (error1.17 (call L.fun/error9127.4.12 fun/error9127.4))
                (empty2.16 (call L.fun/empty9128.6.14 fun/empty9128.6))
                (ascii-char3.15
                 (call L.fun/ascii-char9129.10.18 fun/ascii-char9129.10))
                (ascii-char4.14
                 (call L.fun/ascii-char9130.8.16 fun/ascii-char9130.8)))
            (call L.fun/ascii-char9131.5.13 fun/ascii-char9131.5))
          (let ((procedure0.23
                 (let ((lam.80
                        (let ((tmp.115 (+ (alloc 24) 2)))
                          (begin
                            (mset! tmp.115 -2 L.lam.80.23)
                            (mset! tmp.115 6 0)
                            tmp.115))))
                   (begin (mset! lam.80 14 fun/ascii-char9132.7) lam.80)))
                (vector1.22 (call L.fun/vector9133.9.17 fun/vector9133.9))
                (vector2.21 (call L.fun/vector9134.11.19 fun/vector9134.11))
                (ascii-char3.20
                 (call L.fun/ascii-char9135.13.21 fun/ascii-char9135.13))
                (boolean4.19 (call L.<=.78.7 <=.78 336 1256)))
            (if (!= (if (= (bitwise-and procedure0.23 7) 2) 14 6) 6)
              (if (!= (if (= (mref procedure0.23 6) 0) 14 6) 6)
                (call (mref procedure0.23 -2) procedure0.23)
                10814)
              11070)))))))
(check-by-interp
 '(module
    (define L.lam.73.19
      (lambda (c.86)
        (let ((fun/error9191.12 (mref c.86 14)))
          (call L.fun/error9191.12.15 fun/error9191.12))))
    (define L.fun/void9201.15.18
      (lambda (c.85)
        (let ((fun/void9202.11 (mref c.85 14)))
          (call L.fun/void9202.11.14 fun/void9202.11))))
    (define L.fun/error9192.14.17 (lambda (c.84) (let () 54590)))
    (define L.fun/error9196.13.16 (lambda (c.83) (let () 50750)))
    (define L.fun/error9191.12.15
      (lambda (c.82)
        (let ((fun/error9192.14 (mref c.82 14)))
          (call L.fun/error9192.14.17 fun/error9192.14))))
    (define L.fun/void9202.11.14 (lambda (c.81) (let () 30)))
    (define L.fun/empty9200.10.13 (lambda (c.80) (let () 22)))
    (define L.fun/ascii-char9193.9.12
      (lambda (c.79)
        (let ((fun/ascii-char9194.4 (mref c.79 14)))
          (call L.fun/ascii-char9194.4.7 fun/ascii-char9194.4))))
    (define L.fun/void9198.8.11 (lambda (c.78) (let () 30)))
    (define L.fun/empty9199.7.10
      (lambda (c.77)
        (let ((fun/empty9200.10 (mref c.77 14)))
          (call L.fun/empty9200.10.13 fun/empty9200.10))))
    (define L.fun/error9195.6.9
      (lambda (c.76)
        (let ((fun/error9196.13 (mref c.76 14)))
          (call L.fun/error9196.13.16 fun/error9196.13))))
    (define L.fun/void9197.5.8
      (lambda (c.75)
        (let ((fun/void9198.8 (mref c.75 14)))
          (call L.fun/void9198.8.11 fun/void9198.8))))
    (define L.fun/ascii-char9194.4.7 (lambda (c.74) (let () 26158)))
    (let ((fun/ascii-char9194.4
           (let ((tmp.87 (+ (alloc 16) 2)))
             (begin
               (mset! tmp.87 -2 L.fun/ascii-char9194.4.7)
               (mset! tmp.87 6 0)
               tmp.87)))
          (fun/void9197.5
           (let ((tmp.88 (+ (alloc 24) 2)))
             (begin
               (mset! tmp.88 -2 L.fun/void9197.5.8)
               (mset! tmp.88 6 0)
               tmp.88)))
          (fun/error9195.6
           (let ((tmp.89 (+ (alloc 24) 2)))
             (begin
               (mset! tmp.89 -2 L.fun/error9195.6.9)
               (mset! tmp.89 6 0)
               tmp.89)))
          (fun/empty9199.7
           (let ((tmp.90 (+ (alloc 24) 2)))
             (begin
               (mset! tmp.90 -2 L.fun/empty9199.7.10)
               (mset! tmp.90 6 0)
               tmp.90)))
          (fun/void9198.8
           (let ((tmp.91 (+ (alloc 16) 2)))
             (begin
               (mset! tmp.91 -2 L.fun/void9198.8.11)
               (mset! tmp.91 6 0)
               tmp.91)))
          (fun/ascii-char9193.9
           (let ((tmp.92 (+ (alloc 24) 2)))
             (begin
               (mset! tmp.92 -2 L.fun/ascii-char9193.9.12)
               (mset! tmp.92 6 0)
               tmp.92)))
          (fun/empty9200.10
           (let ((tmp.93 (+ (alloc 16) 2)))
             (begin
               (mset! tmp.93 -2 L.fun/empty9200.10.13)
               (mset! tmp.93 6 0)
               tmp.93)))
          (fun/void9202.11
           (let ((tmp.94 (+ (alloc 16) 2)))
             (begin
               (mset! tmp.94 -2 L.fun/void9202.11.14)
               (mset! tmp.94 6 0)
               tmp.94)))
          (fun/error9191.12
           (let ((tmp.95 (+ (alloc 24) 2)))
             (begin
               (mset! tmp.95 -2 L.fun/error9191.12.15)
               (mset! tmp.95 6 0)
               tmp.95)))
          (fun/error9196.13
           (let ((tmp.96 (+ (alloc 16) 2)))
             (begin
               (mset! tmp.96 -2 L.fun/error9196.13.16)
               (mset! tmp.96 6 0)
               tmp.96)))
          (fun/error9192.14
           (let ((tmp.97 (+ (alloc 16) 2)))
             (begin
               (mset! tmp.97 -2 L.fun/error9192.14.17)
               (mset! tmp.97 6 0)
               tmp.97)))
          (fun/void9201.15
           (let ((tmp.98 (+ (alloc 24) 2)))
             (begin
               (mset! tmp.98 -2 L.fun/void9201.15.18)
               (mset! tmp.98 6 0)
               tmp.98))))
      (begin
        (mset! fun/void9197.5 14 fun/void9198.8)
        (mset! fun/error9195.6 14 fun/error9196.13)
        (mset! fun/empty9199.7 14 fun/empty9200.10)
        (mset! fun/ascii-char9193.9 14 fun/ascii-char9194.4)
        (mset! fun/error9191.12 14 fun/error9192.14)
        (mset! fun/void9201.15 14 fun/void9202.11)
        (let ((procedure0.20
               (let ((lam.73
                      (let ((tmp.99 (+ (alloc 24) 2)))
                        (begin
                          (mset! tmp.99 -2 L.lam.73.19)
                          (mset! tmp.99 6 0)
                          tmp.99))))
                 (begin (mset! lam.73 14 fun/error9191.12) lam.73)))
              (ascii-char1.19
               (call L.fun/ascii-char9193.9.12 fun/ascii-char9193.9))
              (error2.18 (call L.fun/error9195.6.9 fun/error9195.6))
              (void3.17 (call L.fun/void9197.5.8 fun/void9197.5))
              (empty4.16 (call L.fun/empty9199.7.10 fun/empty9199.7)))
          (call L.fun/void9201.15.18 fun/void9201.15))))))
(check-by-interp
 '(module
    (define L.lam.75.23
      (lambda (c.92)
        (let ((fun/vector9888.10 (mref c.92 14)))
          (call L.fun/vector9888.10.19 fun/vector9888.10))))
    (define L.fun/vector9889.13.22
      (lambda (c.91)
        (let ((make-vector.71 (mref c.91 14)))
          (call L.make-vector.71.12 make-vector.71 64))))
    (define L.fun/void9885.12.21 (lambda (c.90) (let () 30)))
    (define L.fun/ascii-char9886.11.20
      (lambda (c.89)
        (let ((fun/ascii-char9887.6 (mref c.89 14)))
          (call L.fun/ascii-char9887.6.15 fun/ascii-char9887.6))))
    (define L.fun/vector9888.10.19
      (lambda (c.88)
        (let ((fun/vector9889.13 (mref c.88 14)))
          (call L.fun/vector9889.13.22 fun/vector9889.13))))
    (define L.fun/void9891.9.18 (lambda (c.87) (let () 30)))
    (define L.fun/void9884.8.17
      (lambda (c.86)
        (let ((fun/void9885.12 (mref c.86 14)))
          (call L.fun/void9885.12.21 fun/void9885.12))))
    (define L.fun/ascii-char9892.7.16
      (lambda (c.85)
        (let ((fun/ascii-char9893.4 (mref c.85 14)))
          (call L.fun/ascii-char9893.4.13 fun/ascii-char9893.4))))
    (define L.fun/ascii-char9887.6.15 (lambda (c.84) (let () 23854)))
    (define L.fun/void9890.5.14
      (lambda (c.83)
        (let ((fun/void9891.9 (mref c.83 14)))
          (call L.fun/void9891.9.18 fun/void9891.9))))
    (define L.fun/ascii-char9893.4.13 (lambda (c.82) (let () 20782)))
    (define L.make-vector.71.12
      (lambda (c.81 tmp.47)
        (let ((make-init-vector.1 (mref c.81 14)))
          (if (!= (if (= (bitwise-and tmp.47 7) 0) 14 6) 6)
            (call L.make-init-vector.1.11 make-init-vector.1 tmp.47)
            2110))))
    (define L.make-init-vector.1.11
      (lambda (c.80 tmp.19)
        (let ((vector-init-loop.21 (mref c.80 14)))
          (let ((tmp.20
                 (let ((tmp.93
                        (+
                         (alloc (* (+ 1 (arithmetic-shift-right tmp.19 3)) 8))
                         3)))
                   (begin (mset! tmp.93 -3 tmp.19) tmp.93))))
            (call
             L.vector-init-loop.21.10
             vector-init-loop.21
             tmp.19
             0
             tmp.20)))))
    (define L.vector-init-loop.21.10
      (lambda (c.79 len.22 i.24 vec.23)
        (let ((vector-init-loop.21 (mref c.79 14)))
          (if (!= (if (= len.22 i.24) 14 6) 6)
            vec.23
            (begin
              (mset! vec.23 (+ (* (arithmetic-shift-right i.24 3) 8) 5) 0)
              (call
               L.vector-init-loop.21.10
               vector-init-loop.21
               len.22
               (+ i.24 8)
               vec.23))))))
    (define L.+.72.9
      (lambda (c.78 tmp.35 tmp.36)
        (let ()
          (if (!= (if (= (bitwise-and tmp.36 7) 0) 14 6) 6)
            (if (!= (if (= (bitwise-and tmp.35 7) 0) 14 6) 6)
              (+ tmp.35 tmp.36)
              574)
            574))))
    (define L.*.73.8
      (lambda (c.77 tmp.33 tmp.34)
        (let ()
          (if (!= (if (= (bitwise-and tmp.34 7) 0) 14 6) 6)
            (if (!= (if (= (bitwise-and tmp.33 7) 0) 14 6) 6)
              (* tmp.33 (arithmetic-shift-right tmp.34 3))
              318)
            318))))
    (define L.-.74.7
      (lambda (c.76 tmp.37 tmp.38)
        (let ()
          (if (!= (if (= (bitwise-and tmp.38 7) 0) 14 6) 6)
            (if (!= (if (= (bitwise-and tmp.37 7) 0) 14 6) 6)
              (- tmp.37 tmp.38)
              830)
            830))))
    (let ((|-.74|
           (let ((tmp.94 (+ (alloc 16) 2)))
             (begin (mset! tmp.94 -2 L.-.74.7) (mset! tmp.94 6 16) tmp.94)))
          (*.73
           (let ((tmp.95 (+ (alloc 16) 2)))
             (begin (mset! tmp.95 -2 L.*.73.8) (mset! tmp.95 6 16) tmp.95)))
          (|+.72|
           (let ((tmp.96 (+ (alloc 16) 2)))
             (begin (mset! tmp.96 -2 L.+.72.9) (mset! tmp.96 6 16) tmp.96)))
          (vector-init-loop.21
           (let ((tmp.97 (+ (alloc 24) 2)))
             (begin
               (mset! tmp.97 -2 L.vector-init-loop.21.10)
               (mset! tmp.97 6 24)
               tmp.97)))
          (make-init-vector.1
           (let ((tmp.98 (+ (alloc 24) 2)))
             (begin
               (mset! tmp.98 -2 L.make-init-vector.1.11)
               (mset! tmp.98 6 8)
               tmp.98)))
          (make-vector.71
           (let ((tmp.99 (+ (alloc 24) 2)))
             (begin
               (mset! tmp.99 -2 L.make-vector.71.12)
               (mset! tmp.99 6 8)
               tmp.99)))
          (fun/ascii-char9893.4
           (let ((tmp.100 (+ (alloc 16) 2)))
             (begin
               (mset! tmp.100 -2 L.fun/ascii-char9893.4.13)
               (mset! tmp.100 6 0)
               tmp.100)))
          (fun/void9890.5
           (let ((tmp.101 (+ (alloc 24) 2)))
             (begin
               (mset! tmp.101 -2 L.fun/void9890.5.14)
               (mset! tmp.101 6 0)
               tmp.101)))
          (fun/ascii-char9887.6
           (let ((tmp.102 (+ (alloc 16) 2)))
             (begin
               (mset! tmp.102 -2 L.fun/ascii-char9887.6.15)
               (mset! tmp.102 6 0)
               tmp.102)))
          (fun/ascii-char9892.7
           (let ((tmp.103 (+ (alloc 24) 2)))
             (begin
               (mset! tmp.103 -2 L.fun/ascii-char9892.7.16)
               (mset! tmp.103 6 0)
               tmp.103)))
          (fun/void9884.8
           (let ((tmp.104 (+ (alloc 24) 2)))
             (begin
               (mset! tmp.104 -2 L.fun/void9884.8.17)
               (mset! tmp.104 6 0)
               tmp.104)))
          (fun/void9891.9
           (let ((tmp.105 (+ (alloc 16) 2)))
             (begin
               (mset! tmp.105 -2 L.fun/void9891.9.18)
               (mset! tmp.105 6 0)
               tmp.105)))
          (fun/vector9888.10
           (let ((tmp.106 (+ (alloc 24) 2)))
             (begin
               (mset! tmp.106 -2 L.fun/vector9888.10.19)
               (mset! tmp.106 6 0)
               tmp.106)))
          (fun/ascii-char9886.11
           (let ((tmp.107 (+ (alloc 24) 2)))
             (begin
               (mset! tmp.107 -2 L.fun/ascii-char9886.11.20)
               (mset! tmp.107 6 0)
               tmp.107)))
          (fun/void9885.12
           (let ((tmp.108 (+ (alloc 16) 2)))
             (begin
               (mset! tmp.108 -2 L.fun/void9885.12.21)
               (mset! tmp.108 6 0)
               tmp.108)))
          (fun/vector9889.13
           (let ((tmp.109 (+ (alloc 24) 2)))
             (begin
               (mset! tmp.109 -2 L.fun/vector9889.13.22)
               (mset! tmp.109 6 0)
               tmp.109))))
      (begin
        (mset! vector-init-loop.21 14 vector-init-loop.21)
        (mset! make-init-vector.1 14 vector-init-loop.21)
        (mset! make-vector.71 14 make-init-vector.1)
        (mset! fun/void9890.5 14 fun/void9891.9)
        (mset! fun/ascii-char9892.7 14 fun/ascii-char9893.4)
        (mset! fun/void9884.8 14 fun/void9885.12)
        (mset! fun/vector9888.10 14 fun/vector9889.13)
        (mset! fun/ascii-char9886.11 14 fun/ascii-char9887.6)
        (mset! fun/vector9889.13 14 make-vector.71)
        (let ((void0.18 (call L.fun/void9884.8.17 fun/void9884.8))
              (ascii-char1.17
               (call L.fun/ascii-char9886.11.20 fun/ascii-char9886.11))
              (procedure2.16
               (let ((lam.75
                      (let ((tmp.110 (+ (alloc 24) 2)))
                        (begin
                          (mset! tmp.110 -2 L.lam.75.23)
                          (mset! tmp.110 6 0)
                          tmp.110))))
                 (begin (mset! lam.75 14 fun/vector9888.10) lam.75)))
              (void3.15 (call L.fun/void9890.5.14 fun/void9890.5))
              (fixnum4.14
               (call
                L.*.73.8
                *.73
                (call
                 L.*.73.8
                 *.73
                 (call L.+.72.9 |+.72| 1344 192)
                 (call L.*.73.8 *.73 1656 992))
                (call
                 L.*.73.8
                 *.73
                 (call L.*.73.8 *.73 1016 1992)
                 (call L.-.74.7 |-.74| 1568 1688)))))
          (call L.fun/ascii-char9892.7.16 fun/ascii-char9892.7))))))
(check-by-interp
 '(module
    (define L.lam.74.22
      (lambda (c.90)
        (let ((fun/void10281.10 (mref c.90 14)))
          (call L.fun/void10281.10.21 fun/void10281.10))))
    (define L.fun/void10281.10.21
      (lambda (c.89)
        (let ((fun/void10282.4 (mref c.89 14)))
          (call L.fun/void10282.4.15 fun/void10282.4))))
    (define L.fun/any10280.9.20 (lambda (c.88) (let () 6)))
    (define L.fun/vector10279.8.19
      (lambda (c.87)
        (let ((make-vector.68 (mref c.87 14)))
          (call L.make-vector.68.14 make-vector.68 64))))
    (define L.fun/empty10283.7.18
      (lambda (c.86)
        (let ((fun/empty10284.5 (mref c.86 14)))
          (call L.fun/empty10284.5.16 fun/empty10284.5))))
    (define L.fun/vector10278.6.17
      (lambda (c.85)
        (let ((fun/vector10279.8 (mref c.85 14)))
          (call L.fun/vector10279.8.19 fun/vector10279.8))))
    (define L.fun/empty10284.5.16 (lambda (c.84) (let () 22)))
    (define L.fun/void10282.4.15 (lambda (c.83) (let () 30)))
    (define L.make-vector.68.14
      (lambda (c.82 tmp.44)
        (let ((make-init-vector.1 (mref c.82 14)))
          (if (!= (if (= (bitwise-and tmp.44 7) 0) 14 6) 6)
            (call L.make-init-vector.1.13 make-init-vector.1 tmp.44)
            2110))))
    (define L.make-init-vector.1.13
      (lambda (c.81 tmp.16)
        (let ((vector-init-loop.18 (mref c.81 14)))
          (let ((tmp.17
                 (let ((tmp.91
                        (+
                         (alloc (* (+ 1 (arithmetic-shift-right tmp.16 3)) 8))
                         3)))
                   (begin (mset! tmp.91 -3 tmp.16) tmp.91))))
            (call
             L.vector-init-loop.18.12
             vector-init-loop.18
             tmp.16
             0
             tmp.17)))))
    (define L.vector-init-loop.18.12
      (lambda (c.80 len.19 i.21 vec.20)
        (let ((vector-init-loop.18 (mref c.80 14)))
          (if (!= (if (= len.19 i.21) 14 6) 6)
            vec.20
            (begin
              (mset! vec.20 (+ (* (arithmetic-shift-right i.21 3) 8) 5) 0)
              (call
               L.vector-init-loop.18.12
               vector-init-loop.18
               len.19
               (+ i.21 8)
               vec.20))))))
    (define L.void?.69.11
      (lambda (c.79 tmp.56)
        (let () (if (= (bitwise-and tmp.56 255) 30) 14 6))))
    (define L.+.70.10
      (lambda (c.78 tmp.32 tmp.33)
        (let ()
          (if (!= (if (= (bitwise-and tmp.33 7) 0) 14 6) 6)
            (if (!= (if (= (bitwise-and tmp.32 7) 0) 14 6) 6)
              (+ tmp.32 tmp.33)
              574)
            574))))
    (define L.-.71.9
      (lambda (c.77 tmp.34 tmp.35)
        (let ()
          (if (!= (if (= (bitwise-and tmp.35 7) 0) 14 6) 6)
            (if (!= (if (= (bitwise-and tmp.34 7) 0) 14 6) 6)
              (- tmp.34 tmp.35)
              830)
            830))))
    (define L.*.72.8
      (lambda (c.76 tmp.30 tmp.31)
        (let ()
          (if (!= (if (= (bitwise-and tmp.31 7) 0) 14 6) 6)
            (if (!= (if (= (bitwise-and tmp.30 7) 0) 14 6) 6)
              (* tmp.30 (arithmetic-shift-right tmp.31 3))
              318)
            318))))
    (define L.<=.73.7
      (lambda (c.75 tmp.38 tmp.39)
        (let ()
          (if (!= (if (= (bitwise-and tmp.39 7) 0) 14 6) 6)
            (if (!= (if (= (bitwise-and tmp.38 7) 0) 14 6) 6)
              (if (<= tmp.38 tmp.39) 14 6)
              1342)
            1342))))
    (let ((<=.73
           (let ((tmp.92 (+ (alloc 16) 2)))
             (begin (mset! tmp.92 -2 L.<=.73.7) (mset! tmp.92 6 16) tmp.92)))
          (*.72
           (let ((tmp.93 (+ (alloc 16) 2)))
             (begin (mset! tmp.93 -2 L.*.72.8) (mset! tmp.93 6 16) tmp.93)))
          (|-.71|
           (let ((tmp.94 (+ (alloc 16) 2)))
             (begin (mset! tmp.94 -2 L.-.71.9) (mset! tmp.94 6 16) tmp.94)))
          (|+.70|
           (let ((tmp.95 (+ (alloc 16) 2)))
             (begin (mset! tmp.95 -2 L.+.70.10) (mset! tmp.95 6 16) tmp.95)))
          (void?.69
           (let ((tmp.96 (+ (alloc 16) 2)))
             (begin
               (mset! tmp.96 -2 L.void?.69.11)
               (mset! tmp.96 6 8)
               tmp.96)))
          (vector-init-loop.18
           (let ((tmp.97 (+ (alloc 24) 2)))
             (begin
               (mset! tmp.97 -2 L.vector-init-loop.18.12)
               (mset! tmp.97 6 24)
               tmp.97)))
          (make-init-vector.1
           (let ((tmp.98 (+ (alloc 24) 2)))
             (begin
               (mset! tmp.98 -2 L.make-init-vector.1.13)
               (mset! tmp.98 6 8)
               tmp.98)))
          (make-vector.68
           (let ((tmp.99 (+ (alloc 24) 2)))
             (begin
               (mset! tmp.99 -2 L.make-vector.68.14)
               (mset! tmp.99 6 8)
               tmp.99)))
          (fun/void10282.4
           (let ((tmp.100 (+ (alloc 16) 2)))
             (begin
               (mset! tmp.100 -2 L.fun/void10282.4.15)
               (mset! tmp.100 6 0)
               tmp.100)))
          (fun/empty10284.5
           (let ((tmp.101 (+ (alloc 16) 2)))
             (begin
               (mset! tmp.101 -2 L.fun/empty10284.5.16)
               (mset! tmp.101 6 0)
               tmp.101)))
          (fun/vector10278.6
           (let ((tmp.102 (+ (alloc 24) 2)))
             (begin
               (mset! tmp.102 -2 L.fun/vector10278.6.17)
               (mset! tmp.102 6 0)
               tmp.102)))
          (fun/empty10283.7
           (let ((tmp.103 (+ (alloc 24) 2)))
             (begin
               (mset! tmp.103 -2 L.fun/empty10283.7.18)
               (mset! tmp.103 6 0)
               tmp.103)))
          (fun/vector10279.8
           (let ((tmp.104 (+ (alloc 24) 2)))
             (begin
               (mset! tmp.104 -2 L.fun/vector10279.8.19)
               (mset! tmp.104 6 0)
               tmp.104)))
          (fun/any10280.9
           (let ((tmp.105 (+ (alloc 16) 2)))
             (begin
               (mset! tmp.105 -2 L.fun/any10280.9.20)
               (mset! tmp.105 6 0)
               tmp.105)))
          (fun/void10281.10
           (let ((tmp.106 (+ (alloc 24) 2)))
             (begin
               (mset! tmp.106 -2 L.fun/void10281.10.21)
               (mset! tmp.106 6 0)
               tmp.106))))
      (begin
        (mset! vector-init-loop.18 14 vector-init-loop.18)
        (mset! make-init-vector.1 14 vector-init-loop.18)
        (mset! make-vector.68 14 make-init-vector.1)
        (mset! fun/vector10278.6 14 fun/vector10279.8)
        (mset! fun/empty10283.7 14 fun/empty10284.5)
        (mset! fun/vector10279.8 14 make-vector.68)
        (mset! fun/void10281.10 14 fun/void10282.4)
        (let ((vector0.15 (call L.fun/vector10278.6.17 fun/vector10278.6))
              (boolean1.14
               (call
                L.void?.69.11
                void?.69
                (call L.fun/any10280.9.20 fun/any10280.9)))
              (fixnum2.13
               (call
                L.+.70.10
                |+.70|
                (call
                 L.-.71.9
                 |-.71|
                 (call L.+.70.10 |+.70| 952 1448)
                 (call L.+.70.10 |+.70| 576 840))
                (call
                 L.-.71.9
                 |-.71|
                 (call L.+.70.10 |+.70| 648 1232)
                 (call L.*.72.8 *.72 1128 648))))
              (procedure3.12
               (let ((lam.74
                      (let ((tmp.107 (+ (alloc 24) 2)))
                        (begin
                          (mset! tmp.107 -2 L.lam.74.22)
                          (mset! tmp.107 6 0)
                          tmp.107))))
                 (begin (mset! lam.74 14 fun/void10281.10) lam.74)))
              (boolean4.11
               (call
                L.<=.73.7
                <=.73
                (call
                 L.*.72.8
                 *.72
                 (call L.-.71.9 |-.71| 1408 1016)
                 (call L.+.70.10 |+.70| 1488 1008))
                (call
                 L.-.71.9
                 |-.71|
                 (call L.*.72.8 *.72 600 2024)
                 (call L.-.71.9 |-.71| 1480 1656)))))
          (call L.fun/empty10283.7.18 fun/empty10283.7))))))
(check-by-interp
 '(module
    (define L.fun/void10625.9.15
      (lambda (c.78)
        (let ((fun/void10626.6 (mref c.78 14)))
          (call L.fun/void10626.6.12 fun/void10626.6))))
    (define L.fun/void10628.8.14 (lambda (c.77) (let () 30)))
    (define L.fun/void10627.7.13
      (lambda (c.76)
        (let ((fun/void10628.8 (mref c.76 14)))
          (call L.fun/void10628.8.14 fun/void10628.8))))
    (define L.fun/void10626.6.12 (lambda (c.75) (let () 30)))
    (define L.fun/error10624.5.11 (lambda (c.74) (let () 19262)))
    (define L.fun/error10623.4.10
      (lambda (c.73)
        (let ((fun/error10624.5 (mref c.73 14)))
          (call L.fun/error10624.5.11 fun/error10624.5))))
    (define L.+.67.9
      (lambda (c.72 tmp.31 tmp.32)
        (let ()
          (if (!= (if (= (bitwise-and tmp.32 7) 0) 14 6) 6)
            (if (!= (if (= (bitwise-and tmp.31 7) 0) 14 6) 6)
              (+ tmp.31 tmp.32)
              574)
            574))))
    (define L.-.68.8
      (lambda (c.71 tmp.33 tmp.34)
        (let ()
          (if (!= (if (= (bitwise-and tmp.34 7) 0) 14 6) 6)
            (if (!= (if (= (bitwise-and tmp.33 7) 0) 14 6) 6)
              (- tmp.33 tmp.34)
              830)
            830))))
    (define L.*.69.7
      (lambda (c.70 tmp.29 tmp.30)
        (let ()
          (if (!= (if (= (bitwise-and tmp.30 7) 0) 14 6) 6)
            (if (!= (if (= (bitwise-and tmp.29 7) 0) 14 6) 6)
              (* tmp.29 (arithmetic-shift-right tmp.30 3))
              318)
            318))))
    (let ((*.69
           (let ((tmp.79 (+ (alloc 16) 2)))
             (begin (mset! tmp.79 -2 L.*.69.7) (mset! tmp.79 6 16) tmp.79)))
          (|-.68|
           (let ((tmp.80 (+ (alloc 16) 2)))
             (begin (mset! tmp.80 -2 L.-.68.8) (mset! tmp.80 6 16) tmp.80)))
          (|+.67|
           (let ((tmp.81 (+ (alloc 16) 2)))
             (begin (mset! tmp.81 -2 L.+.67.9) (mset! tmp.81 6 16) tmp.81)))
          (fun/error10623.4
           (let ((tmp.82 (+ (alloc 24) 2)))
             (begin
               (mset! tmp.82 -2 L.fun/error10623.4.10)
               (mset! tmp.82 6 0)
               tmp.82)))
          (fun/error10624.5
           (let ((tmp.83 (+ (alloc 16) 2)))
             (begin
               (mset! tmp.83 -2 L.fun/error10624.5.11)
               (mset! tmp.83 6 0)
               tmp.83)))
          (fun/void10626.6
           (let ((tmp.84 (+ (alloc 16) 2)))
             (begin
               (mset! tmp.84 -2 L.fun/void10626.6.12)
               (mset! tmp.84 6 0)
               tmp.84)))
          (fun/void10627.7
           (let ((tmp.85 (+ (alloc 24) 2)))
             (begin
               (mset! tmp.85 -2 L.fun/void10627.7.13)
               (mset! tmp.85 6 0)
               tmp.85)))
          (fun/void10628.8
           (let ((tmp.86 (+ (alloc 16) 2)))
             (begin
               (mset! tmp.86 -2 L.fun/void10628.8.14)
               (mset! tmp.86 6 0)
               tmp.86)))
          (fun/void10625.9
           (let ((tmp.87 (+ (alloc 24) 2)))
             (begin
               (mset! tmp.87 -2 L.fun/void10625.9.15)
               (mset! tmp.87 6 0)
               tmp.87))))
      (begin
        (mset! fun/error10623.4 14 fun/error10624.5)
        (mset! fun/void10627.7 14 fun/void10628.8)
        (mset! fun/void10625.9 14 fun/void10626.6)
        (let ((error0.14 (call L.fun/error10623.4.10 fun/error10623.4))
              (void1.13 (call L.fun/void10625.9.15 fun/void10625.9))
              (fixnum2.12
               (call
                L.+.67.9
                |+.67|
                (call
                 L.+.67.9
                 |+.67|
                 (call L.+.67.9 |+.67| 1416 768)
                 (call L.-.68.8 |-.68| 520 1656))
                (call
                 L.*.69.7
                 *.69
                 (call L.-.68.8 |-.68| 1360 88)
                 (call L.*.69.7 *.69 416 1432))))
              (fixnum3.11
               (call
                L.*.69.7
                *.69
                (call
                 L.+.67.9
                 |+.67|
                 (call L.-.68.8 |-.68| 576 1624)
                 (call L.+.67.9 |+.67| 1152 1944))
                (call
                 L.-.68.8
                 |-.68|
                 (call L.-.68.8 |-.68| 1432 2024)
                 (call L.*.69.7 *.69 336 392))))
              (fixnum4.10
               (call
                L.-.68.8
                |-.68|
                (call
                 L.+.67.9
                 |+.67|
                 (call L.*.69.7 *.69 376 1808)
                 (call L.-.68.8 |-.68| 1664 992))
                (call
                 L.-.68.8
                 |-.68|
                 (call L.+.67.9 |+.67| 1840 1216)
                 (call L.+.67.9 |+.67| 1712 1752)))))
          (call L.fun/void10627.7.13 fun/void10627.7))))))
(check-by-interp
 '(module
    (define L.lam.74.22
      (lambda (c.90)
        (let ((fun/ascii-char10710.8 (mref c.90 14)))
          (call L.fun/ascii-char10710.8.15 fun/ascii-char10710.8))))
    (define L.fun/void10716.14.21 (lambda (c.89) (let () 30)))
    (define L.fun/empty10709.13.20 (lambda (c.88) (let () 22)))
    (define L.fun/ascii-char10711.12.19 (lambda (c.87) (let () 23342)))
    (define L.fun/vector10713.11.18
      (lambda (c.86)
        (let ((make-vector.72 (mref c.86 14)))
          (call L.make-vector.72.10 make-vector.72 64))))
    (define L.fun/error10717.10.17
      (lambda (c.85)
        (let ((fun/error10718.4 (mref c.85 14)))
          (call L.fun/error10718.4.11 fun/error10718.4))))
    (define L.fun/empty10708.9.16
      (lambda (c.84)
        (let ((fun/empty10709.13 (mref c.84 14)))
          (call L.fun/empty10709.13.20 fun/empty10709.13))))
    (define L.fun/ascii-char10710.8.15
      (lambda (c.83)
        (let ((fun/ascii-char10711.12 (mref c.83 14)))
          (call L.fun/ascii-char10711.12.19 fun/ascii-char10711.12))))
    (define L.fun/vector10712.7.14
      (lambda (c.82)
        (let ((fun/vector10713.11 (mref c.82 14)))
          (call L.fun/vector10713.11.18 fun/vector10713.11))))
    (define L.fun/void10715.6.13
      (lambda (c.81)
        (let ((fun/void10716.14 (mref c.81 14)))
          (call L.fun/void10716.14.21 fun/void10716.14))))
    (define L.fun/any10714.5.12
      (lambda (c.80)
        (let ((make-vector.72 (mref c.80 14)))
          (call L.make-vector.72.10 make-vector.72 64))))
    (define L.fun/error10718.4.11 (lambda (c.79) (let () 46910)))
    (define L.make-vector.72.10
      (lambda (c.78 tmp.48)
        (let ((make-init-vector.1 (mref c.78 14)))
          (if (!= (if (= (bitwise-and tmp.48 7) 0) 14 6) 6)
            (call L.make-init-vector.1.9 make-init-vector.1 tmp.48)
            2110))))
    (define L.make-init-vector.1.9
      (lambda (c.77 tmp.20)
        (let ((vector-init-loop.22 (mref c.77 14)))
          (let ((tmp.21
                 (let ((tmp.91
                        (+
                         (alloc (* (+ 1 (arithmetic-shift-right tmp.20 3)) 8))
                         3)))
                   (begin (mset! tmp.91 -3 tmp.20) tmp.91))))
            (call
             L.vector-init-loop.22.8
             vector-init-loop.22
             tmp.20
             0
             tmp.21)))))
    (define L.vector-init-loop.22.8
      (lambda (c.76 len.23 i.25 vec.24)
        (let ((vector-init-loop.22 (mref c.76 14)))
          (if (!= (if (= len.23 i.25) 14 6) 6)
            vec.24
            (begin
              (mset! vec.24 (+ (* (arithmetic-shift-right i.25 3) 8) 5) 0)
              (call
               L.vector-init-loop.22.8
               vector-init-loop.22
               len.23
               (+ i.25 8)
               vec.24))))))
    (define L.fixnum?.73.7
      (lambda (c.75 tmp.57) (let () (if (= (bitwise-and tmp.57 7) 0) 14 6))))
    (let ((fixnum?.73
           (let ((tmp.92 (+ (alloc 16) 2)))
             (begin
               (mset! tmp.92 -2 L.fixnum?.73.7)
               (mset! tmp.92 6 8)
               tmp.92)))
          (vector-init-loop.22
           (let ((tmp.93 (+ (alloc 24) 2)))
             (begin
               (mset! tmp.93 -2 L.vector-init-loop.22.8)
               (mset! tmp.93 6 24)
               tmp.93)))
          (make-init-vector.1
           (let ((tmp.94 (+ (alloc 24) 2)))
             (begin
               (mset! tmp.94 -2 L.make-init-vector.1.9)
               (mset! tmp.94 6 8)
               tmp.94)))
          (make-vector.72
           (let ((tmp.95 (+ (alloc 24) 2)))
             (begin
               (mset! tmp.95 -2 L.make-vector.72.10)
               (mset! tmp.95 6 8)
               tmp.95)))
          (fun/error10718.4
           (let ((tmp.96 (+ (alloc 16) 2)))
             (begin
               (mset! tmp.96 -2 L.fun/error10718.4.11)
               (mset! tmp.96 6 0)
               tmp.96)))
          (fun/any10714.5
           (let ((tmp.97 (+ (alloc 24) 2)))
             (begin
               (mset! tmp.97 -2 L.fun/any10714.5.12)
               (mset! tmp.97 6 0)
               tmp.97)))
          (fun/void10715.6
           (let ((tmp.98 (+ (alloc 24) 2)))
             (begin
               (mset! tmp.98 -2 L.fun/void10715.6.13)
               (mset! tmp.98 6 0)
               tmp.98)))
          (fun/vector10712.7
           (let ((tmp.99 (+ (alloc 24) 2)))
             (begin
               (mset! tmp.99 -2 L.fun/vector10712.7.14)
               (mset! tmp.99 6 0)
               tmp.99)))
          (fun/ascii-char10710.8
           (let ((tmp.100 (+ (alloc 24) 2)))
             (begin
               (mset! tmp.100 -2 L.fun/ascii-char10710.8.15)
               (mset! tmp.100 6 0)
               tmp.100)))
          (fun/empty10708.9
           (let ((tmp.101 (+ (alloc 24) 2)))
             (begin
               (mset! tmp.101 -2 L.fun/empty10708.9.16)
               (mset! tmp.101 6 0)
               tmp.101)))
          (fun/error10717.10
           (let ((tmp.102 (+ (alloc 24) 2)))
             (begin
               (mset! tmp.102 -2 L.fun/error10717.10.17)
               (mset! tmp.102 6 0)
               tmp.102)))
          (fun/vector10713.11
           (let ((tmp.103 (+ (alloc 24) 2)))
             (begin
               (mset! tmp.103 -2 L.fun/vector10713.11.18)
               (mset! tmp.103 6 0)
               tmp.103)))
          (fun/ascii-char10711.12
           (let ((tmp.104 (+ (alloc 16) 2)))
             (begin
               (mset! tmp.104 -2 L.fun/ascii-char10711.12.19)
               (mset! tmp.104 6 0)
               tmp.104)))
          (fun/empty10709.13
           (let ((tmp.105 (+ (alloc 16) 2)))
             (begin
               (mset! tmp.105 -2 L.fun/empty10709.13.20)
               (mset! tmp.105 6 0)
               tmp.105)))
          (fun/void10716.14
           (let ((tmp.106 (+ (alloc 16) 2)))
             (begin
               (mset! tmp.106 -2 L.fun/void10716.14.21)
               (mset! tmp.106 6 0)
               tmp.106))))
      (begin
        (mset! vector-init-loop.22 14 vector-init-loop.22)
        (mset! make-init-vector.1 14 vector-init-loop.22)
        (mset! make-vector.72 14 make-init-vector.1)
        (mset! fun/any10714.5 14 make-vector.72)
        (mset! fun/void10715.6 14 fun/void10716.14)
        (mset! fun/vector10712.7 14 fun/vector10713.11)
        (mset! fun/ascii-char10710.8 14 fun/ascii-char10711.12)
        (mset! fun/empty10708.9 14 fun/empty10709.13)
        (mset! fun/error10717.10 14 fun/error10718.4)
        (mset! fun/vector10713.11 14 make-vector.72)
        (let ((empty0.19 (call L.fun/empty10708.9.16 fun/empty10708.9))
              (procedure1.18
               (let ((lam.74
                      (let ((tmp.107 (+ (alloc 24) 2)))
                        (begin
                          (mset! tmp.107 -2 L.lam.74.22)
                          (mset! tmp.107 6 0)
                          tmp.107))))
                 (begin (mset! lam.74 14 fun/ascii-char10710.8) lam.74)))
              (vector2.17 (call L.fun/vector10712.7.14 fun/vector10712.7))
              (boolean3.16
               (call
                L.fixnum?.73.7
                fixnum?.73
                (call L.fun/any10714.5.12 fun/any10714.5)))
              (void4.15 (call L.fun/void10715.6.13 fun/void10715.6)))
          (call L.fun/error10717.10.17 fun/error10717.10))))))
(check-by-interp
 '(module
    (define L.lam.75.24
      (lambda (c.93)
        (let ((|-.70| (mref c.93 14)) (|+.71| (mref c.93 22)))
          (call
           L.+.71.9
           |+.71|
           (call
            L.-.70.10
            |-.70|
            (call L.-.70.10 |-.70| 720 1008)
            (call L.-.70.10 |-.70| 768 864))
           (call
            L.+.71.9
            |+.71|
            (call L.+.71.9 |+.71| 808 840)
            (call L.-.70.10 |-.70| 1304 1512))))))
    (define L.lam.74.23
      (lambda (c.92)
        (let ((fun/ascii-char10795.7 (mref c.92 14)))
          (call L.fun/ascii-char10795.7.17 fun/ascii-char10795.7))))
    (define L.lam.73.22
      (lambda (c.91)
        (let ((fun/void10791.4 (mref c.91 14)))
          (call L.fun/void10791.4.14 fun/void10791.4))))
    (define L.fun/ascii-char10793.11.21
      (lambda (c.90)
        (let ((fun/ascii-char10794.5 (mref c.90 14)))
          (call L.fun/ascii-char10794.5.15 fun/ascii-char10794.5))))
    (define L.fun/void10792.10.20 (lambda (c.89) (let () 30)))
    (define L.fun/vector10790.9.19
      (lambda (c.88)
        (let ((make-vector.69 (mref c.88 14)))
          (call L.make-vector.69.13 make-vector.69 64))))
    (define L.fun/vector10789.8.18
      (lambda (c.87)
        (let ((fun/vector10790.9 (mref c.87 14)))
          (call L.fun/vector10790.9.19 fun/vector10790.9))))
    (define L.fun/ascii-char10795.7.17
      (lambda (c.86)
        (let ((fun/ascii-char10796.6 (mref c.86 14)))
          (call L.fun/ascii-char10796.6.16 fun/ascii-char10796.6))))
    (define L.fun/ascii-char10796.6.16 (lambda (c.85) (let () 27182)))
    (define L.fun/ascii-char10794.5.15 (lambda (c.84) (let () 17966)))
    (define L.fun/void10791.4.14
      (lambda (c.83)
        (let ((fun/void10792.10 (mref c.83 14)))
          (call L.fun/void10792.10.20 fun/void10792.10))))
    (define L.make-vector.69.13
      (lambda (c.82 tmp.45)
        (let ((make-init-vector.1 (mref c.82 14)))
          (if (!= (if (= (bitwise-and tmp.45 7) 0) 14 6) 6)
            (call L.make-init-vector.1.12 make-init-vector.1 tmp.45)
            2110))))
    (define L.make-init-vector.1.12
      (lambda (c.81 tmp.17)
        (let ((vector-init-loop.19 (mref c.81 14)))
          (let ((tmp.18
                 (let ((tmp.94
                        (+
                         (alloc (* (+ 1 (arithmetic-shift-right tmp.17 3)) 8))
                         3)))
                   (begin (mset! tmp.94 -3 tmp.17) tmp.94))))
            (call
             L.vector-init-loop.19.11
             vector-init-loop.19
             tmp.17
             0
             tmp.18)))))
    (define L.vector-init-loop.19.11
      (lambda (c.80 len.20 i.22 vec.21)
        (let ((vector-init-loop.19 (mref c.80 14)))
          (if (!= (if (= len.20 i.22) 14 6) 6)
            vec.21
            (begin
              (mset! vec.21 (+ (* (arithmetic-shift-right i.22 3) 8) 5) 0)
              (call
               L.vector-init-loop.19.11
               vector-init-loop.19
               len.20
               (+ i.22 8)
               vec.21))))))
    (define L.-.70.10
      (lambda (c.79 tmp.35 tmp.36)
        (let ()
          (if (!= (if (= (bitwise-and tmp.36 7) 0) 14 6) 6)
            (if (!= (if (= (bitwise-and tmp.35 7) 0) 14 6) 6)
              (- tmp.35 tmp.36)
              830)
            830))))
    (define L.+.71.9
      (lambda (c.78 tmp.33 tmp.34)
        (let ()
          (if (!= (if (= (bitwise-and tmp.34 7) 0) 14 6) 6)
            (if (!= (if (= (bitwise-and tmp.33 7) 0) 14 6) 6)
              (+ tmp.33 tmp.34)
              574)
            574))))
    (define L.vector-ref.72.8
      (lambda (c.77 tmp.50 tmp.51)
        (let ((unsafe-vector-ref.3 (mref c.77 14)))
          (if (!= (if (= (bitwise-and tmp.51 7) 0) 14 6) 6)
            (if (!= (if (= (bitwise-and tmp.50 7) 3) 14 6) 6)
              (call L.unsafe-vector-ref.3.7 unsafe-vector-ref.3 tmp.50 tmp.51)
              2878)
            2878))))
    (define L.unsafe-vector-ref.3.7
      (lambda (c.76 tmp.28 tmp.29)
        (let ()
          (if (!= (if (< tmp.29 (mref tmp.28 -3)) 14 6) 6)
            (if (!= (if (>= tmp.29 0) 14 6) 6)
              (mref tmp.28 (+ (* (arithmetic-shift-right tmp.29 3) 8) 5))
              2878)
            2878))))
    (let ((unsafe-vector-ref.3
           (let ((tmp.95 (+ (alloc 16) 2)))
             (begin
               (mset! tmp.95 -2 L.unsafe-vector-ref.3.7)
               (mset! tmp.95 6 16)
               tmp.95)))
          (vector-ref.72
           (let ((tmp.96 (+ (alloc 24) 2)))
             (begin
               (mset! tmp.96 -2 L.vector-ref.72.8)
               (mset! tmp.96 6 16)
               tmp.96)))
          (|+.71|
           (let ((tmp.97 (+ (alloc 16) 2)))
             (begin (mset! tmp.97 -2 L.+.71.9) (mset! tmp.97 6 16) tmp.97)))
          (|-.70|
           (let ((tmp.98 (+ (alloc 16) 2)))
             (begin (mset! tmp.98 -2 L.-.70.10) (mset! tmp.98 6 16) tmp.98)))
          (vector-init-loop.19
           (let ((tmp.99 (+ (alloc 24) 2)))
             (begin
               (mset! tmp.99 -2 L.vector-init-loop.19.11)
               (mset! tmp.99 6 24)
               tmp.99)))
          (make-init-vector.1
           (let ((tmp.100 (+ (alloc 24) 2)))
             (begin
               (mset! tmp.100 -2 L.make-init-vector.1.12)
               (mset! tmp.100 6 8)
               tmp.100)))
          (make-vector.69
           (let ((tmp.101 (+ (alloc 24) 2)))
             (begin
               (mset! tmp.101 -2 L.make-vector.69.13)
               (mset! tmp.101 6 8)
               tmp.101)))
          (fun/void10791.4
           (let ((tmp.102 (+ (alloc 24) 2)))
             (begin
               (mset! tmp.102 -2 L.fun/void10791.4.14)
               (mset! tmp.102 6 0)
               tmp.102)))
          (fun/ascii-char10794.5
           (let ((tmp.103 (+ (alloc 16) 2)))
             (begin
               (mset! tmp.103 -2 L.fun/ascii-char10794.5.15)
               (mset! tmp.103 6 0)
               tmp.103)))
          (fun/ascii-char10796.6
           (let ((tmp.104 (+ (alloc 16) 2)))
             (begin
               (mset! tmp.104 -2 L.fun/ascii-char10796.6.16)
               (mset! tmp.104 6 0)
               tmp.104)))
          (fun/ascii-char10795.7
           (let ((tmp.105 (+ (alloc 24) 2)))
             (begin
               (mset! tmp.105 -2 L.fun/ascii-char10795.7.17)
               (mset! tmp.105 6 0)
               tmp.105)))
          (fun/vector10789.8
           (let ((tmp.106 (+ (alloc 24) 2)))
             (begin
               (mset! tmp.106 -2 L.fun/vector10789.8.18)
               (mset! tmp.106 6 0)
               tmp.106)))
          (fun/vector10790.9
           (let ((tmp.107 (+ (alloc 24) 2)))
             (begin
               (mset! tmp.107 -2 L.fun/vector10790.9.19)
               (mset! tmp.107 6 0)
               tmp.107)))
          (fun/void10792.10
           (let ((tmp.108 (+ (alloc 16) 2)))
             (begin
               (mset! tmp.108 -2 L.fun/void10792.10.20)
               (mset! tmp.108 6 0)
               tmp.108)))
          (fun/ascii-char10793.11
           (let ((tmp.109 (+ (alloc 24) 2)))
             (begin
               (mset! tmp.109 -2 L.fun/ascii-char10793.11.21)
               (mset! tmp.109 6 0)
               tmp.109))))
      (begin
        (mset! vector-ref.72 14 unsafe-vector-ref.3)
        (mset! vector-init-loop.19 14 vector-init-loop.19)
        (mset! make-init-vector.1 14 vector-init-loop.19)
        (mset! make-vector.69 14 make-init-vector.1)
        (mset! fun/void10791.4 14 fun/void10792.10)
        (mset! fun/ascii-char10795.7 14 fun/ascii-char10796.6)
        (mset! fun/vector10789.8 14 fun/vector10790.9)
        (mset! fun/vector10790.9 14 make-vector.69)
        (mset! fun/ascii-char10793.11 14 fun/ascii-char10794.5)
        (let ((vector0.16 (call L.fun/vector10789.8.18 fun/vector10789.8))
              (procedure1.15
               (let ((lam.73
                      (let ((tmp.110 (+ (alloc 24) 2)))
                        (begin
                          (mset! tmp.110 -2 L.lam.73.22)
                          (mset! tmp.110 6 0)
                          tmp.110))))
                 (begin (mset! lam.73 14 fun/void10791.4) lam.73)))
              (ascii-char2.14
               (call L.fun/ascii-char10793.11.21 fun/ascii-char10793.11))
              (procedure3.13
               (let ((lam.74
                      (let ((tmp.111 (+ (alloc 24) 2)))
                        (begin
                          (mset! tmp.111 -2 L.lam.74.23)
                          (mset! tmp.111 6 0)
                          tmp.111))))
                 (begin (mset! lam.74 14 fun/ascii-char10795.7) lam.74)))
              (procedure4.12
               (let ((lam.75
                      (let ((tmp.112 (+ (alloc 32) 2)))
                        (begin
                          (mset! tmp.112 -2 L.lam.75.24)
                          (mset! tmp.112 6 0)
                          tmp.112))))
                 (begin
                   (mset! lam.75 14 |-.70|)
                   (mset! lam.75 22 |+.71|)
                   lam.75))))
          (call L.vector-ref.72.8 vector-ref.72 vector0.16 8))))))
(check-by-interp
 '(module
    (define L.lam.77.24
      (lambda (c.95)
        (let ((fun/pair11669.5 (mref c.95 14)))
          (call L.fun/pair11669.5.12 fun/pair11669.5))))
    (define L.lam.76.23
      (lambda (c.94)
        (let ((fun/empty11659.13 (mref c.94 14)))
          (call L.fun/empty11659.13.20 fun/empty11659.13))))
    (define L.fun/empty11664.15.22 (lambda (c.93) (let () 22)))
    (define L.fun/void11666.14.21 (lambda (c.92) (let () 30)))
    (define L.fun/empty11659.13.20
      (lambda (c.91)
        (let ((fun/empty11660.10 (mref c.91 14)))
          (call L.fun/empty11660.10.17 fun/empty11660.10))))
    (define L.fun/error11661.12.19
      (lambda (c.90)
        (let ((fun/error11662.8 (mref c.90 14)))
          (call L.fun/error11662.8.15 fun/error11662.8))))
    (define L.fun/pair11670.11.18
      (lambda (c.89)
        (let ((cons.75 (mref c.89 14))) (call L.cons.75.7 cons.75 1200 3336))))
    (define L.fun/empty11660.10.17 (lambda (c.88) (let () 22)))
    (define L.fun/vector11668.9.16
      (lambda (c.87)
        (let ((make-vector.74 (mref c.87 14)))
          (call L.make-vector.74.10 make-vector.74 64))))
    (define L.fun/error11662.8.15 (lambda (c.86) (let () 36414)))
    (define L.fun/empty11663.7.14
      (lambda (c.85)
        (let ((fun/empty11664.15 (mref c.85 14)))
          (call L.fun/empty11664.15.22 fun/empty11664.15))))
    (define L.fun/void11665.6.13
      (lambda (c.84)
        (let ((fun/void11666.14 (mref c.84 14)))
          (call L.fun/void11666.14.21 fun/void11666.14))))
    (define L.fun/pair11669.5.12
      (lambda (c.83)
        (let ((fun/pair11670.11 (mref c.83 14)))
          (call L.fun/pair11670.11.18 fun/pair11670.11))))
    (define L.fun/vector11667.4.11
      (lambda (c.82)
        (let ((fun/vector11668.9 (mref c.82 14)))
          (call L.fun/vector11668.9.16 fun/vector11668.9))))
    (define L.make-vector.74.10
      (lambda (c.81 tmp.50)
        (let ((make-init-vector.1 (mref c.81 14)))
          (if (!= (if (= (bitwise-and tmp.50 7) 0) 14 6) 6)
            (call L.make-init-vector.1.9 make-init-vector.1 tmp.50)
            2110))))
    (define L.make-init-vector.1.9
      (lambda (c.80 tmp.22)
        (let ((vector-init-loop.24 (mref c.80 14)))
          (let ((tmp.23
                 (let ((tmp.96
                        (+
                         (alloc (* (+ 1 (arithmetic-shift-right tmp.22 3)) 8))
                         3)))
                   (begin (mset! tmp.96 -3 tmp.22) tmp.96))))
            (call
             L.vector-init-loop.24.8
             vector-init-loop.24
             tmp.22
             0
             tmp.23)))))
    (define L.vector-init-loop.24.8
      (lambda (c.79 len.25 i.27 vec.26)
        (let ((vector-init-loop.24 (mref c.79 14)))
          (if (!= (if (= len.25 i.27) 14 6) 6)
            vec.26
            (begin
              (mset! vec.26 (+ (* (arithmetic-shift-right i.27 3) 8) 5) 0)
              (call
               L.vector-init-loop.24.8
               vector-init-loop.24
               len.25
               (+ i.27 8)
               vec.26))))))
    (define L.cons.75.7
      (lambda (c.78 tmp.69 tmp.70)
        (let ()
          (let ((tmp.97 (+ (alloc 16) 1)))
            (begin (mset! tmp.97 -1 tmp.69) (mset! tmp.97 7 tmp.70) tmp.97)))))
    (let ((cons.75
           (let ((tmp.98 (+ (alloc 16) 2)))
             (begin (mset! tmp.98 -2 L.cons.75.7) (mset! tmp.98 6 16) tmp.98)))
          (vector-init-loop.24
           (let ((tmp.99 (+ (alloc 24) 2)))
             (begin
               (mset! tmp.99 -2 L.vector-init-loop.24.8)
               (mset! tmp.99 6 24)
               tmp.99)))
          (make-init-vector.1
           (let ((tmp.100 (+ (alloc 24) 2)))
             (begin
               (mset! tmp.100 -2 L.make-init-vector.1.9)
               (mset! tmp.100 6 8)
               tmp.100)))
          (make-vector.74
           (let ((tmp.101 (+ (alloc 24) 2)))
             (begin
               (mset! tmp.101 -2 L.make-vector.74.10)
               (mset! tmp.101 6 8)
               tmp.101)))
          (fun/vector11667.4
           (let ((tmp.102 (+ (alloc 24) 2)))
             (begin
               (mset! tmp.102 -2 L.fun/vector11667.4.11)
               (mset! tmp.102 6 0)
               tmp.102)))
          (fun/pair11669.5
           (let ((tmp.103 (+ (alloc 24) 2)))
             (begin
               (mset! tmp.103 -2 L.fun/pair11669.5.12)
               (mset! tmp.103 6 0)
               tmp.103)))
          (fun/void11665.6
           (let ((tmp.104 (+ (alloc 24) 2)))
             (begin
               (mset! tmp.104 -2 L.fun/void11665.6.13)
               (mset! tmp.104 6 0)
               tmp.104)))
          (fun/empty11663.7
           (let ((tmp.105 (+ (alloc 24) 2)))
             (begin
               (mset! tmp.105 -2 L.fun/empty11663.7.14)
               (mset! tmp.105 6 0)
               tmp.105)))
          (fun/error11662.8
           (let ((tmp.106 (+ (alloc 16) 2)))
             (begin
               (mset! tmp.106 -2 L.fun/error11662.8.15)
               (mset! tmp.106 6 0)
               tmp.106)))
          (fun/vector11668.9
           (let ((tmp.107 (+ (alloc 24) 2)))
             (begin
               (mset! tmp.107 -2 L.fun/vector11668.9.16)
               (mset! tmp.107 6 0)
               tmp.107)))
          (fun/empty11660.10
           (let ((tmp.108 (+ (alloc 16) 2)))
             (begin
               (mset! tmp.108 -2 L.fun/empty11660.10.17)
               (mset! tmp.108 6 0)
               tmp.108)))
          (fun/pair11670.11
           (let ((tmp.109 (+ (alloc 24) 2)))
             (begin
               (mset! tmp.109 -2 L.fun/pair11670.11.18)
               (mset! tmp.109 6 0)
               tmp.109)))
          (fun/error11661.12
           (let ((tmp.110 (+ (alloc 24) 2)))
             (begin
               (mset! tmp.110 -2 L.fun/error11661.12.19)
               (mset! tmp.110 6 0)
               tmp.110)))
          (fun/empty11659.13
           (let ((tmp.111 (+ (alloc 24) 2)))
             (begin
               (mset! tmp.111 -2 L.fun/empty11659.13.20)
               (mset! tmp.111 6 0)
               tmp.111)))
          (fun/void11666.14
           (let ((tmp.112 (+ (alloc 16) 2)))
             (begin
               (mset! tmp.112 -2 L.fun/void11666.14.21)
               (mset! tmp.112 6 0)
               tmp.112)))
          (fun/empty11664.15
           (let ((tmp.113 (+ (alloc 16) 2)))
             (begin
               (mset! tmp.113 -2 L.fun/empty11664.15.22)
               (mset! tmp.113 6 0)
               tmp.113))))
      (begin
        (mset! vector-init-loop.24 14 vector-init-loop.24)
        (mset! make-init-vector.1 14 vector-init-loop.24)
        (mset! make-vector.74 14 make-init-vector.1)
        (mset! fun/vector11667.4 14 fun/vector11668.9)
        (mset! fun/pair11669.5 14 fun/pair11670.11)
        (mset! fun/void11665.6 14 fun/void11666.14)
        (mset! fun/empty11663.7 14 fun/empty11664.15)
        (mset! fun/vector11668.9 14 make-vector.74)
        (mset! fun/pair11670.11 14 cons.75)
        (mset! fun/error11661.12 14 fun/error11662.8)
        (mset! fun/empty11659.13 14 fun/empty11660.10)
        (let ((procedure0.21
               (let ((lam.76
                      (let ((tmp.114 (+ (alloc 24) 2)))
                        (begin
                          (mset! tmp.114 -2 L.lam.76.23)
                          (mset! tmp.114 6 0)
                          tmp.114))))
                 (begin (mset! lam.76 14 fun/empty11659.13) lam.76)))
              (error1.20 (call L.fun/error11661.12.19 fun/error11661.12))
              (empty2.19 (call L.fun/empty11663.7.14 fun/empty11663.7))
              (void3.18 (call L.fun/void11665.6.13 fun/void11665.6))
              (vector4.17 (call L.fun/vector11667.4.11 fun/vector11667.4))
              (procedure5.16
               (let ((lam.77
                      (let ((tmp.115 (+ (alloc 24) 2)))
                        (begin
                          (mset! tmp.115 -2 L.lam.77.24)
                          (mset! tmp.115 6 0)
                          tmp.115))))
                 (begin (mset! lam.77 14 fun/pair11669.5) lam.77))))
          (if (!= (if (= (bitwise-and procedure0.21 7) 2) 14 6) 6)
            (if (!= (if (= (mref procedure0.21 6) 0) 14 6) 6)
              (call (mref procedure0.21 -2) procedure0.21)
              10814)
            11070))))))
(check-by-interp
 '(module
    (define L.fun/error12035.15.21 (lambda (c.91) (let () 9790)))
    (define L.fun/ascii-char12031.14.20 (lambda (c.90) (let () 23854)))
    (define L.fun/error12029.13.19 (lambda (c.89) (let () 62526)))
    (define L.fun/empty12027.12.18 (lambda (c.88) (let () 22)))
    (define L.fun/ascii-char12032.11.17
      (lambda (c.87)
        (let ((fun/ascii-char12033.10 (mref c.87 14)))
          (call L.fun/ascii-char12033.10.16 fun/ascii-char12033.10))))
    (define L.fun/ascii-char12033.10.16 (lambda (c.86) (let () 27438)))
    (define L.fun/error12025.9.15 (lambda (c.85) (let () 48702)))
    (define L.fun/error12028.8.14
      (lambda (c.84)
        (let ((fun/error12029.13 (mref c.84 14)))
          (call L.fun/error12029.13.19 fun/error12029.13))))
    (define L.fun/error12034.7.13
      (lambda (c.83)
        (let ((fun/error12035.15 (mref c.83 14)))
          (call L.fun/error12035.15.21 fun/error12035.15))))
    (define L.fun/ascii-char12030.6.12
      (lambda (c.82)
        (let ((fun/ascii-char12031.14 (mref c.82 14)))
          (call L.fun/ascii-char12031.14.20 fun/ascii-char12031.14))))
    (define L.fun/error12024.5.11
      (lambda (c.81)
        (let ((fun/error12025.9 (mref c.81 14)))
          (call L.fun/error12025.9.15 fun/error12025.9))))
    (define L.fun/empty12026.4.10
      (lambda (c.80)
        (let ((fun/empty12027.12 (mref c.80 14)))
          (call L.fun/empty12027.12.18 fun/empty12027.12))))
    (define L.-.74.9
      (lambda (c.79 tmp.40 tmp.41)
        (let ()
          (if (!= (if (= (bitwise-and tmp.41 7) 0) 14 6) 6)
            (if (!= (if (= (bitwise-and tmp.40 7) 0) 14 6) 6)
              (- tmp.40 tmp.41)
              830)
            830))))
    (define L.*.75.8
      (lambda (c.78 tmp.36 tmp.37)
        (let ()
          (if (!= (if (= (bitwise-and tmp.37 7) 0) 14 6) 6)
            (if (!= (if (= (bitwise-and tmp.36 7) 0) 14 6) 6)
              (* tmp.36 (arithmetic-shift-right tmp.37 3))
              318)
            318))))
    (define L.+.76.7
      (lambda (c.77 tmp.38 tmp.39)
        (let ()
          (if (!= (if (= (bitwise-and tmp.39 7) 0) 14 6) 6)
            (if (!= (if (= (bitwise-and tmp.38 7) 0) 14 6) 6)
              (+ tmp.38 tmp.39)
              574)
            574))))
    (let ((|+.76|
           (let ((tmp.92 (+ (alloc 16) 2)))
             (begin (mset! tmp.92 -2 L.+.76.7) (mset! tmp.92 6 16) tmp.92)))
          (*.75
           (let ((tmp.93 (+ (alloc 16) 2)))
             (begin (mset! tmp.93 -2 L.*.75.8) (mset! tmp.93 6 16) tmp.93)))
          (|-.74|
           (let ((tmp.94 (+ (alloc 16) 2)))
             (begin (mset! tmp.94 -2 L.-.74.9) (mset! tmp.94 6 16) tmp.94)))
          (fun/empty12026.4
           (let ((tmp.95 (+ (alloc 24) 2)))
             (begin
               (mset! tmp.95 -2 L.fun/empty12026.4.10)
               (mset! tmp.95 6 0)
               tmp.95)))
          (fun/error12024.5
           (let ((tmp.96 (+ (alloc 24) 2)))
             (begin
               (mset! tmp.96 -2 L.fun/error12024.5.11)
               (mset! tmp.96 6 0)
               tmp.96)))
          (fun/ascii-char12030.6
           (let ((tmp.97 (+ (alloc 24) 2)))
             (begin
               (mset! tmp.97 -2 L.fun/ascii-char12030.6.12)
               (mset! tmp.97 6 0)
               tmp.97)))
          (fun/error12034.7
           (let ((tmp.98 (+ (alloc 24) 2)))
             (begin
               (mset! tmp.98 -2 L.fun/error12034.7.13)
               (mset! tmp.98 6 0)
               tmp.98)))
          (fun/error12028.8
           (let ((tmp.99 (+ (alloc 24) 2)))
             (begin
               (mset! tmp.99 -2 L.fun/error12028.8.14)
               (mset! tmp.99 6 0)
               tmp.99)))
          (fun/error12025.9
           (let ((tmp.100 (+ (alloc 16) 2)))
             (begin
               (mset! tmp.100 -2 L.fun/error12025.9.15)
               (mset! tmp.100 6 0)
               tmp.100)))
          (fun/ascii-char12033.10
           (let ((tmp.101 (+ (alloc 16) 2)))
             (begin
               (mset! tmp.101 -2 L.fun/ascii-char12033.10.16)
               (mset! tmp.101 6 0)
               tmp.101)))
          (fun/ascii-char12032.11
           (let ((tmp.102 (+ (alloc 24) 2)))
             (begin
               (mset! tmp.102 -2 L.fun/ascii-char12032.11.17)
               (mset! tmp.102 6 0)
               tmp.102)))
          (fun/empty12027.12
           (let ((tmp.103 (+ (alloc 16) 2)))
             (begin
               (mset! tmp.103 -2 L.fun/empty12027.12.18)
               (mset! tmp.103 6 0)
               tmp.103)))
          (fun/error12029.13
           (let ((tmp.104 (+ (alloc 16) 2)))
             (begin
               (mset! tmp.104 -2 L.fun/error12029.13.19)
               (mset! tmp.104 6 0)
               tmp.104)))
          (fun/ascii-char12031.14
           (let ((tmp.105 (+ (alloc 16) 2)))
             (begin
               (mset! tmp.105 -2 L.fun/ascii-char12031.14.20)
               (mset! tmp.105 6 0)
               tmp.105)))
          (fun/error12035.15
           (let ((tmp.106 (+ (alloc 16) 2)))
             (begin
               (mset! tmp.106 -2 L.fun/error12035.15.21)
               (mset! tmp.106 6 0)
               tmp.106))))
      (begin
        (mset! fun/empty12026.4 14 fun/empty12027.12)
        (mset! fun/error12024.5 14 fun/error12025.9)
        (mset! fun/ascii-char12030.6 14 fun/ascii-char12031.14)
        (mset! fun/error12034.7 14 fun/error12035.15)
        (mset! fun/error12028.8 14 fun/error12029.13)
        (mset! fun/ascii-char12032.11 14 fun/ascii-char12033.10)
        (let ((fixnum0.21
               (call
                L.+.76.7
                |+.76|
                (call
                 L.-.74.9
                 |-.74|
                 (call
                  L.+.76.7
                  |+.76|
                  (call L.-.74.9 |-.74| 160 1984)
                  (call L.*.75.8 *.75 1648 1936))
                 (call
                  L.-.74.9
                  |-.74|
                  (call L.+.76.7 |+.76| 1320 1992)
                  (call L.*.75.8 *.75 1960 792)))
                (call
                 L.*.75.8
                 *.75
                 (call
                  L.-.74.9
                  |-.74|
                  (call L.*.75.8 *.75 1600 272)
                  (call L.+.76.7 |+.76| 344 1656))
                 (call
                  L.*.75.8
                  *.75
                  (call L.-.74.9 |-.74| 1632 744)
                  (call L.*.75.8 *.75 440 728)))))
              (error1.20 (call L.fun/error12024.5.11 fun/error12024.5))
              (empty2.19 (call L.fun/empty12026.4.10 fun/empty12026.4))
              (error3.18 (call L.fun/error12028.8.14 fun/error12028.8))
              (ascii-char4.17
               (call L.fun/ascii-char12030.6.12 fun/ascii-char12030.6))
              (ascii-char5.16
               (call L.fun/ascii-char12032.11.17 fun/ascii-char12032.11)))
          (call L.fun/error12034.7.13 fun/error12034.7))))))
(check-by-interp
 '(module
    (define L.lam.75.20
      (lambda (c.89)
        (let ((fun/pair13985.9 (mref c.89 14)))
          (call L.fun/pair13985.9.13 fun/pair13985.9))))
    (define L.fun/void13989.15.19
      (lambda (c.88)
        (let ((fun/void13990.8 (mref c.88 14)))
          (call L.fun/void13990.8.12 fun/void13990.8))))
    (define L.fun/void13995.14.18
      (lambda (c.87)
        (let ((fun/void13996.7 (mref c.87 14)))
          (call L.fun/void13996.7.11 fun/void13996.7))))
    (define L.fun/error13991.13.17
      (lambda (c.86)
        (let ((fun/error13992.4 (mref c.86 14)))
          (call L.fun/error13992.4.8 fun/error13992.4))))
    (define L.fun/pair13986.12.16
      (lambda (c.85)
        (let ((cons.74 (mref c.85 14))) (call L.cons.74.7 cons.74 896 3416))))
    (define L.fun/ascii-char13988.11.15 (lambda (c.84) (let () 27182)))
    (define L.fun/void13993.10.14
      (lambda (c.83)
        (let ((fun/void13994.6 (mref c.83 14)))
          (call L.fun/void13994.6.10 fun/void13994.6))))
    (define L.fun/pair13985.9.13
      (lambda (c.82)
        (let ((fun/pair13986.12 (mref c.82 14)))
          (call L.fun/pair13986.12.16 fun/pair13986.12))))
    (define L.fun/void13990.8.12 (lambda (c.81) (let () 30)))
    (define L.fun/void13996.7.11 (lambda (c.80) (let () 30)))
    (define L.fun/void13994.6.10 (lambda (c.79) (let () 30)))
    (define L.fun/ascii-char13987.5.9
      (lambda (c.78)
        (let ((fun/ascii-char13988.11 (mref c.78 14)))
          (call L.fun/ascii-char13988.11.15 fun/ascii-char13988.11))))
    (define L.fun/error13992.4.8 (lambda (c.77) (let () 7486)))
    (define L.cons.74.7
      (lambda (c.76 tmp.69 tmp.70)
        (let ()
          (let ((tmp.90 (+ (alloc 16) 1)))
            (begin (mset! tmp.90 -1 tmp.69) (mset! tmp.90 7 tmp.70) tmp.90)))))
    (let ((cons.74
           (let ((tmp.91 (+ (alloc 16) 2)))
             (begin (mset! tmp.91 -2 L.cons.74.7) (mset! tmp.91 6 16) tmp.91)))
          (fun/error13992.4
           (let ((tmp.92 (+ (alloc 16) 2)))
             (begin
               (mset! tmp.92 -2 L.fun/error13992.4.8)
               (mset! tmp.92 6 0)
               tmp.92)))
          (fun/ascii-char13987.5
           (let ((tmp.93 (+ (alloc 24) 2)))
             (begin
               (mset! tmp.93 -2 L.fun/ascii-char13987.5.9)
               (mset! tmp.93 6 0)
               tmp.93)))
          (fun/void13994.6
           (let ((tmp.94 (+ (alloc 16) 2)))
             (begin
               (mset! tmp.94 -2 L.fun/void13994.6.10)
               (mset! tmp.94 6 0)
               tmp.94)))
          (fun/void13996.7
           (let ((tmp.95 (+ (alloc 16) 2)))
             (begin
               (mset! tmp.95 -2 L.fun/void13996.7.11)
               (mset! tmp.95 6 0)
               tmp.95)))
          (fun/void13990.8
           (let ((tmp.96 (+ (alloc 16) 2)))
             (begin
               (mset! tmp.96 -2 L.fun/void13990.8.12)
               (mset! tmp.96 6 0)
               tmp.96)))
          (fun/pair13985.9
           (let ((tmp.97 (+ (alloc 24) 2)))
             (begin
               (mset! tmp.97 -2 L.fun/pair13985.9.13)
               (mset! tmp.97 6 0)
               tmp.97)))
          (fun/void13993.10
           (let ((tmp.98 (+ (alloc 24) 2)))
             (begin
               (mset! tmp.98 -2 L.fun/void13993.10.14)
               (mset! tmp.98 6 0)
               tmp.98)))
          (fun/ascii-char13988.11
           (let ((tmp.99 (+ (alloc 16) 2)))
             (begin
               (mset! tmp.99 -2 L.fun/ascii-char13988.11.15)
               (mset! tmp.99 6 0)
               tmp.99)))
          (fun/pair13986.12
           (let ((tmp.100 (+ (alloc 24) 2)))
             (begin
               (mset! tmp.100 -2 L.fun/pair13986.12.16)
               (mset! tmp.100 6 0)
               tmp.100)))
          (fun/error13991.13
           (let ((tmp.101 (+ (alloc 24) 2)))
             (begin
               (mset! tmp.101 -2 L.fun/error13991.13.17)
               (mset! tmp.101 6 0)
               tmp.101)))
          (fun/void13995.14
           (let ((tmp.102 (+ (alloc 24) 2)))
             (begin
               (mset! tmp.102 -2 L.fun/void13995.14.18)
               (mset! tmp.102 6 0)
               tmp.102)))
          (fun/void13989.15
           (let ((tmp.103 (+ (alloc 24) 2)))
             (begin
               (mset! tmp.103 -2 L.fun/void13989.15.19)
               (mset! tmp.103 6 0)
               tmp.103))))
      (begin
        (mset! fun/ascii-char13987.5 14 fun/ascii-char13988.11)
        (mset! fun/pair13985.9 14 fun/pair13986.12)
        (mset! fun/void13993.10 14 fun/void13994.6)
        (mset! fun/pair13986.12 14 cons.74)
        (mset! fun/error13991.13 14 fun/error13992.4)
        (mset! fun/void13995.14 14 fun/void13996.7)
        (mset! fun/void13989.15 14 fun/void13990.8)
        (let ((procedure0.21
               (let ((lam.75
                      (let ((tmp.104 (+ (alloc 24) 2)))
                        (begin
                          (mset! tmp.104 -2 L.lam.75.20)
                          (mset! tmp.104 6 0)
                          tmp.104))))
                 (begin (mset! lam.75 14 fun/pair13985.9) lam.75)))
              (ascii-char1.20
               (call L.fun/ascii-char13987.5.9 fun/ascii-char13987.5))
              (void2.19 (call L.fun/void13989.15.19 fun/void13989.15))
              (error3.18 (call L.fun/error13991.13.17 fun/error13991.13))
              (void4.17 (call L.fun/void13993.10.14 fun/void13993.10))
              (void5.16 (call L.fun/void13995.14.18 fun/void13995.14)))
          (if (!= (if (= (bitwise-and procedure0.21 7) 2) 14 6) 6)
            (if (!= (if (= (mref procedure0.21 6) 0) 14 6) 6)
              (call (mref procedure0.21 -2) procedure0.21)
              10814)
            11070))))))
(check-by-interp
 '(module
    (define L.lam.80.27
      (lambda (c.101)
        (let ((fun/any14746.10 (mref c.101 14))
              (ascii-char?.79 (mref c.101 22)))
          (call
           L.ascii-char?.79.7
           ascii-char?.79
           (call L.fun/any14746.10.21 fun/any14746.10)))))
    (define L.fun/vector14739.15.26
      (lambda (c.100)
        (let ((make-vector.74 (mref c.100 14)))
          (call L.make-vector.74.14 make-vector.74 64))))
    (define L.fun/ascii-char14749.14.25 (lambda (c.99) (let () 31278)))
    (define L.fun/ascii-char14743.13.24 (lambda (c.98) (let () 26158)))
    (define L.fun/any14741.12.23
      (lambda (c.97)
        (let ((make-vector.74 (mref c.97 14)))
          (call L.make-vector.74.14 make-vector.74 64))))
    (define L.fun/any14747.11.22 (lambda (c.96) (let () 22)))
    (define L.fun/any14746.10.21
      (lambda (c.95)
        (let ((fun/any14747.11 (mref c.95 14)))
          (call L.fun/any14747.11.22 fun/any14747.11))))
    (define L.fun/ascii-char14742.9.20
      (lambda (c.94)
        (let ((fun/ascii-char14743.13 (mref c.94 14)))
          (call L.fun/ascii-char14743.13.24 fun/ascii-char14743.13))))
    (define L.fun/ascii-char14748.8.19
      (lambda (c.93)
        (let ((fun/ascii-char14749.14 (mref c.93 14)))
          (call L.fun/ascii-char14749.14.25 fun/ascii-char14749.14))))
    (define L.fun/any14740.7.18
      (lambda (c.92)
        (let ((fun/any14741.12 (mref c.92 14)))
          (call L.fun/any14741.12.23 fun/any14741.12))))
    (define L.fun/vector14744.6.17
      (lambda (c.91)
        (let ((fun/vector14745.5 (mref c.91 14)))
          (call L.fun/vector14745.5.16 fun/vector14745.5))))
    (define L.fun/vector14745.5.16
      (lambda (c.90)
        (let ((make-vector.74 (mref c.90 14)))
          (call L.make-vector.74.14 make-vector.74 64))))
    (define L.fun/vector14738.4.15
      (lambda (c.89)
        (let ((fun/vector14739.15 (mref c.89 14)))
          (call L.fun/vector14739.15.26 fun/vector14739.15))))
    (define L.make-vector.74.14
      (lambda (c.88 tmp.50)
        (let ((make-init-vector.1 (mref c.88 14)))
          (if (!= (if (= (bitwise-and tmp.50 7) 0) 14 6) 6)
            (call L.make-init-vector.1.13 make-init-vector.1 tmp.50)
            2110))))
    (define L.make-init-vector.1.13
      (lambda (c.87 tmp.22)
        (let ((vector-init-loop.24 (mref c.87 14)))
          (let ((tmp.23
                 (let ((tmp.102
                        (+
                         (alloc (* (+ 1 (arithmetic-shift-right tmp.22 3)) 8))
                         3)))
                   (begin (mset! tmp.102 -3 tmp.22) tmp.102))))
            (call
             L.vector-init-loop.24.12
             vector-init-loop.24
             tmp.22
             0
             tmp.23)))))
    (define L.vector-init-loop.24.12
      (lambda (c.86 len.25 i.27 vec.26)
        (let ((vector-init-loop.24 (mref c.86 14)))
          (if (!= (if (= len.25 i.27) 14 6) 6)
            vec.26
            (begin
              (mset! vec.26 (+ (* (arithmetic-shift-right i.27 3) 8) 5) 0)
              (call
               L.vector-init-loop.24.12
               vector-init-loop.24
               len.25
               (+ i.27 8)
               vec.26))))))
    (define L.-.75.11
      (lambda (c.85 tmp.40 tmp.41)
        (let ()
          (if (!= (if (= (bitwise-and tmp.41 7) 0) 14 6) 6)
            (if (!= (if (= (bitwise-and tmp.40 7) 0) 14 6) 6)
              (- tmp.40 tmp.41)
              830)
            830))))
    (define L.*.76.10
      (lambda (c.84 tmp.36 tmp.37)
        (let ()
          (if (!= (if (= (bitwise-and tmp.37 7) 0) 14 6) 6)
            (if (!= (if (= (bitwise-and tmp.36 7) 0) 14 6) 6)
              (* tmp.36 (arithmetic-shift-right tmp.37 3))
              318)
            318))))
    (define L.+.77.9
      (lambda (c.83 tmp.38 tmp.39)
        (let ()
          (if (!= (if (= (bitwise-and tmp.39 7) 0) 14 6) 6)
            (if (!= (if (= (bitwise-and tmp.38 7) 0) 14 6) 6)
              (+ tmp.38 tmp.39)
              574)
            574))))
    (define L.fixnum?.78.8
      (lambda (c.82 tmp.59) (let () (if (= (bitwise-and tmp.59 7) 0) 14 6))))
    (define L.ascii-char?.79.7
      (lambda (c.81 tmp.63)
        (let () (if (= (bitwise-and tmp.63 255) 46) 14 6))))
    (let ((ascii-char?.79
           (let ((tmp.103 (+ (alloc 16) 2)))
             (begin
               (mset! tmp.103 -2 L.ascii-char?.79.7)
               (mset! tmp.103 6 8)
               tmp.103)))
          (fixnum?.78
           (let ((tmp.104 (+ (alloc 16) 2)))
             (begin
               (mset! tmp.104 -2 L.fixnum?.78.8)
               (mset! tmp.104 6 8)
               tmp.104)))
          (|+.77|
           (let ((tmp.105 (+ (alloc 16) 2)))
             (begin (mset! tmp.105 -2 L.+.77.9) (mset! tmp.105 6 16) tmp.105)))
          (*.76
           (let ((tmp.106 (+ (alloc 16) 2)))
             (begin
               (mset! tmp.106 -2 L.*.76.10)
               (mset! tmp.106 6 16)
               tmp.106)))
          (|-.75|
           (let ((tmp.107 (+ (alloc 16) 2)))
             (begin
               (mset! tmp.107 -2 L.-.75.11)
               (mset! tmp.107 6 16)
               tmp.107)))
          (vector-init-loop.24
           (let ((tmp.108 (+ (alloc 24) 2)))
             (begin
               (mset! tmp.108 -2 L.vector-init-loop.24.12)
               (mset! tmp.108 6 24)
               tmp.108)))
          (make-init-vector.1
           (let ((tmp.109 (+ (alloc 24) 2)))
             (begin
               (mset! tmp.109 -2 L.make-init-vector.1.13)
               (mset! tmp.109 6 8)
               tmp.109)))
          (make-vector.74
           (let ((tmp.110 (+ (alloc 24) 2)))
             (begin
               (mset! tmp.110 -2 L.make-vector.74.14)
               (mset! tmp.110 6 8)
               tmp.110)))
          (fun/vector14738.4
           (let ((tmp.111 (+ (alloc 24) 2)))
             (begin
               (mset! tmp.111 -2 L.fun/vector14738.4.15)
               (mset! tmp.111 6 0)
               tmp.111)))
          (fun/vector14745.5
           (let ((tmp.112 (+ (alloc 24) 2)))
             (begin
               (mset! tmp.112 -2 L.fun/vector14745.5.16)
               (mset! tmp.112 6 0)
               tmp.112)))
          (fun/vector14744.6
           (let ((tmp.113 (+ (alloc 24) 2)))
             (begin
               (mset! tmp.113 -2 L.fun/vector14744.6.17)
               (mset! tmp.113 6 0)
               tmp.113)))
          (fun/any14740.7
           (let ((tmp.114 (+ (alloc 24) 2)))
             (begin
               (mset! tmp.114 -2 L.fun/any14740.7.18)
               (mset! tmp.114 6 0)
               tmp.114)))
          (fun/ascii-char14748.8
           (let ((tmp.115 (+ (alloc 24) 2)))
             (begin
               (mset! tmp.115 -2 L.fun/ascii-char14748.8.19)
               (mset! tmp.115 6 0)
               tmp.115)))
          (fun/ascii-char14742.9
           (let ((tmp.116 (+ (alloc 24) 2)))
             (begin
               (mset! tmp.116 -2 L.fun/ascii-char14742.9.20)
               (mset! tmp.116 6 0)
               tmp.116)))
          (fun/any14746.10
           (let ((tmp.117 (+ (alloc 24) 2)))
             (begin
               (mset! tmp.117 -2 L.fun/any14746.10.21)
               (mset! tmp.117 6 0)
               tmp.117)))
          (fun/any14747.11
           (let ((tmp.118 (+ (alloc 16) 2)))
             (begin
               (mset! tmp.118 -2 L.fun/any14747.11.22)
               (mset! tmp.118 6 0)
               tmp.118)))
          (fun/any14741.12
           (let ((tmp.119 (+ (alloc 24) 2)))
             (begin
               (mset! tmp.119 -2 L.fun/any14741.12.23)
               (mset! tmp.119 6 0)
               tmp.119)))
          (fun/ascii-char14743.13
           (let ((tmp.120 (+ (alloc 16) 2)))
             (begin
               (mset! tmp.120 -2 L.fun/ascii-char14743.13.24)
               (mset! tmp.120 6 0)
               tmp.120)))
          (fun/ascii-char14749.14
           (let ((tmp.121 (+ (alloc 16) 2)))
             (begin
               (mset! tmp.121 -2 L.fun/ascii-char14749.14.25)
               (mset! tmp.121 6 0)
               tmp.121)))
          (fun/vector14739.15
           (let ((tmp.122 (+ (alloc 24) 2)))
             (begin
               (mset! tmp.122 -2 L.fun/vector14739.15.26)
               (mset! tmp.122 6 0)
               tmp.122))))
      (begin
        (mset! vector-init-loop.24 14 vector-init-loop.24)
        (mset! make-init-vector.1 14 vector-init-loop.24)
        (mset! make-vector.74 14 make-init-vector.1)
        (mset! fun/vector14738.4 14 fun/vector14739.15)
        (mset! fun/vector14745.5 14 make-vector.74)
        (mset! fun/vector14744.6 14 fun/vector14745.5)
        (mset! fun/any14740.7 14 fun/any14741.12)
        (mset! fun/ascii-char14748.8 14 fun/ascii-char14749.14)
        (mset! fun/ascii-char14742.9 14 fun/ascii-char14743.13)
        (mset! fun/any14746.10 14 fun/any14747.11)
        (mset! fun/any14741.12 14 make-vector.74)
        (mset! fun/vector14739.15 14 make-vector.74)
        (let ((vector0.21 (call L.fun/vector14738.4.15 fun/vector14738.4))
              (fixnum1.20
               (call
                L.+.77.9
                |+.77|
                (call
                 L.*.76.10
                 *.76
                 (call
                  L.*.76.10
                  *.76
                  (call L.-.75.11 |-.75| 360 1976)
                  (call L.-.75.11 |-.75| 952 1912))
                 (call
                  L.+.77.9
                  |+.77|
                  (call L.-.75.11 |-.75| 800 360)
                  (call L.*.76.10 *.76 2008 840)))
                (call
                 L.*.76.10
                 *.76
                 (call
                  L.-.75.11
                  |-.75|
                  (call L.*.76.10 *.76 912 1904)
                  (call L.*.76.10 *.76 1840 704))
                 (call
                  L.-.75.11
                  |-.75|
                  (call L.+.77.9 |+.77| 2000 1728)
                  (call L.+.77.9 |+.77| 712 608)))))
              (boolean2.19
               (call
                L.fixnum?.78.8
                fixnum?.78
                (call L.fun/any14740.7.18 fun/any14740.7)))
              (ascii-char3.18
               (call L.fun/ascii-char14742.9.20 fun/ascii-char14742.9))
              (vector4.17 (call L.fun/vector14744.6.17 fun/vector14744.6))
              (procedure5.16
               (let ((lam.80
                      (let ((tmp.123 (+ (alloc 32) 2)))
                        (begin
                          (mset! tmp.123 -2 L.lam.80.27)
                          (mset! tmp.123 6 0)
                          tmp.123))))
                 (begin
                   (mset! lam.80 14 fun/any14746.10)
                   (mset! lam.80 22 ascii-char?.79)
                   lam.80))))
          (call L.fun/ascii-char14748.8.19 fun/ascii-char14748.8))))))
(check-by-interp
 '(module
    (define L.fun/any14774.13.23
      (lambda (c.93)
        (let ((fun/any14775.7 (mref c.93 14)))
          (call L.fun/any14775.7.17 fun/any14775.7))))
    (define L.fun/vector14776.12.22
      (lambda (c.92)
        (let ((fun/vector14777.9 (mref c.92 14)))
          (call L.fun/vector14777.9.19 fun/vector14777.9))))
    (define L.fun/ascii-char14781.11.21 (lambda (c.91) (let () 23086)))
    (define L.fun/empty14778.10.20
      (lambda (c.90)
        (let ((fun/empty14779.6 (mref c.90 14)))
          (call L.fun/empty14779.6.16 fun/empty14779.6))))
    (define L.fun/vector14777.9.19
      (lambda (c.89)
        (let ((make-vector.72 (mref c.89 14)))
          (call L.make-vector.72.13 make-vector.72 64))))
    (define L.fun/vector14773.8.18
      (lambda (c.88)
        (let ((make-vector.72 (mref c.88 14)))
          (call L.make-vector.72.13 make-vector.72 64))))
    (define L.fun/any14775.7.17 (lambda (c.87) (let () 1176)))
    (define L.fun/empty14779.6.16 (lambda (c.86) (let () 22)))
    (define L.fun/vector14772.5.15
      (lambda (c.85)
        (let ((fun/vector14773.8 (mref c.85 14)))
          (call L.fun/vector14773.8.18 fun/vector14773.8))))
    (define L.fun/ascii-char14780.4.14
      (lambda (c.84)
        (let ((fun/ascii-char14781.11 (mref c.84 14)))
          (call L.fun/ascii-char14781.11.21 fun/ascii-char14781.11))))
    (define L.make-vector.72.13
      (lambda (c.83 tmp.48)
        (let ((make-init-vector.1 (mref c.83 14)))
          (if (!= (if (= (bitwise-and tmp.48 7) 0) 14 6) 6)
            (call L.make-init-vector.1.12 make-init-vector.1 tmp.48)
            2110))))
    (define L.make-init-vector.1.12
      (lambda (c.82 tmp.20)
        (let ((vector-init-loop.22 (mref c.82 14)))
          (let ((tmp.21
                 (let ((tmp.94
                        (+
                         (alloc (* (+ 1 (arithmetic-shift-right tmp.20 3)) 8))
                         3)))
                   (begin (mset! tmp.94 -3 tmp.20) tmp.94))))
            (call
             L.vector-init-loop.22.11
             vector-init-loop.22
             tmp.20
             0
             tmp.21)))))
    (define L.vector-init-loop.22.11
      (lambda (c.81 len.23 i.25 vec.24)
        (let ((vector-init-loop.22 (mref c.81 14)))
          (if (!= (if (= len.23 i.25) 14 6) 6)
            vec.24
            (begin
              (mset! vec.24 (+ (* (arithmetic-shift-right i.25 3) 8) 5) 0)
              (call
               L.vector-init-loop.22.11
               vector-init-loop.22
               len.23
               (+ i.25 8)
               vec.24))))))
    (define L.+.73.10
      (lambda (c.80 tmp.36 tmp.37)
        (let ()
          (if (!= (if (= (bitwise-and tmp.37 7) 0) 14 6) 6)
            (if (!= (if (= (bitwise-and tmp.36 7) 0) 14 6) 6)
              (+ tmp.36 tmp.37)
              574)
            574))))
    (define L.-.74.9
      (lambda (c.79 tmp.38 tmp.39)
        (let ()
          (if (!= (if (= (bitwise-and tmp.39 7) 0) 14 6) 6)
            (if (!= (if (= (bitwise-and tmp.38 7) 0) 14 6) 6)
              (- tmp.38 tmp.39)
              830)
            830))))
    (define L.*.75.8
      (lambda (c.78 tmp.34 tmp.35)
        (let ()
          (if (!= (if (= (bitwise-and tmp.35 7) 0) 14 6) 6)
            (if (!= (if (= (bitwise-and tmp.34 7) 0) 14 6) 6)
              (* tmp.34 (arithmetic-shift-right tmp.35 3))
              318)
            318))))
    (define L.procedure?.76.7
      (lambda (c.77 tmp.66) (let () (if (= (bitwise-and tmp.66 7) 2) 14 6))))
    (let ((procedure?.76
           (let ((tmp.95 (+ (alloc 16) 2)))
             (begin
               (mset! tmp.95 -2 L.procedure?.76.7)
               (mset! tmp.95 6 8)
               tmp.95)))
          (*.75
           (let ((tmp.96 (+ (alloc 16) 2)))
             (begin (mset! tmp.96 -2 L.*.75.8) (mset! tmp.96 6 16) tmp.96)))
          (|-.74|
           (let ((tmp.97 (+ (alloc 16) 2)))
             (begin (mset! tmp.97 -2 L.-.74.9) (mset! tmp.97 6 16) tmp.97)))
          (|+.73|
           (let ((tmp.98 (+ (alloc 16) 2)))
             (begin (mset! tmp.98 -2 L.+.73.10) (mset! tmp.98 6 16) tmp.98)))
          (vector-init-loop.22
           (let ((tmp.99 (+ (alloc 24) 2)))
             (begin
               (mset! tmp.99 -2 L.vector-init-loop.22.11)
               (mset! tmp.99 6 24)
               tmp.99)))
          (make-init-vector.1
           (let ((tmp.100 (+ (alloc 24) 2)))
             (begin
               (mset! tmp.100 -2 L.make-init-vector.1.12)
               (mset! tmp.100 6 8)
               tmp.100)))
          (make-vector.72
           (let ((tmp.101 (+ (alloc 24) 2)))
             (begin
               (mset! tmp.101 -2 L.make-vector.72.13)
               (mset! tmp.101 6 8)
               tmp.101)))
          (fun/ascii-char14780.4
           (let ((tmp.102 (+ (alloc 24) 2)))
             (begin
               (mset! tmp.102 -2 L.fun/ascii-char14780.4.14)
               (mset! tmp.102 6 0)
               tmp.102)))
          (fun/vector14772.5
           (let ((tmp.103 (+ (alloc 24) 2)))
             (begin
               (mset! tmp.103 -2 L.fun/vector14772.5.15)
               (mset! tmp.103 6 0)
               tmp.103)))
          (fun/empty14779.6
           (let ((tmp.104 (+ (alloc 16) 2)))
             (begin
               (mset! tmp.104 -2 L.fun/empty14779.6.16)
               (mset! tmp.104 6 0)
               tmp.104)))
          (fun/any14775.7
           (let ((tmp.105 (+ (alloc 16) 2)))
             (begin
               (mset! tmp.105 -2 L.fun/any14775.7.17)
               (mset! tmp.105 6 0)
               tmp.105)))
          (fun/vector14773.8
           (let ((tmp.106 (+ (alloc 24) 2)))
             (begin
               (mset! tmp.106 -2 L.fun/vector14773.8.18)
               (mset! tmp.106 6 0)
               tmp.106)))
          (fun/vector14777.9
           (let ((tmp.107 (+ (alloc 24) 2)))
             (begin
               (mset! tmp.107 -2 L.fun/vector14777.9.19)
               (mset! tmp.107 6 0)
               tmp.107)))
          (fun/empty14778.10
           (let ((tmp.108 (+ (alloc 24) 2)))
             (begin
               (mset! tmp.108 -2 L.fun/empty14778.10.20)
               (mset! tmp.108 6 0)
               tmp.108)))
          (fun/ascii-char14781.11
           (let ((tmp.109 (+ (alloc 16) 2)))
             (begin
               (mset! tmp.109 -2 L.fun/ascii-char14781.11.21)
               (mset! tmp.109 6 0)
               tmp.109)))
          (fun/vector14776.12
           (let ((tmp.110 (+ (alloc 24) 2)))
             (begin
               (mset! tmp.110 -2 L.fun/vector14776.12.22)
               (mset! tmp.110 6 0)
               tmp.110)))
          (fun/any14774.13
           (let ((tmp.111 (+ (alloc 24) 2)))
             (begin
               (mset! tmp.111 -2 L.fun/any14774.13.23)
               (mset! tmp.111 6 0)
               tmp.111))))
      (begin
        (mset! vector-init-loop.22 14 vector-init-loop.22)
        (mset! make-init-vector.1 14 vector-init-loop.22)
        (mset! make-vector.72 14 make-init-vector.1)
        (mset! fun/ascii-char14780.4 14 fun/ascii-char14781.11)
        (mset! fun/vector14772.5 14 fun/vector14773.8)
        (mset! fun/vector14773.8 14 make-vector.72)
        (mset! fun/vector14777.9 14 make-vector.72)
        (mset! fun/empty14778.10 14 fun/empty14779.6)
        (mset! fun/vector14776.12 14 fun/vector14777.9)
        (mset! fun/any14774.13 14 fun/any14775.7)
        (let ((fixnum0.19
               (call
                L.*.75.8
                *.75
                (call
                 L.-.74.9
                 |-.74|
                 (call
                  L.+.73.10
                  |+.73|
                  (call L.+.73.10 |+.73| 1824 392)
                  (call L.+.73.10 |+.73| 88 888))
                 (call
                  L.+.73.10
                  |+.73|
                  (call L.-.74.9 |-.74| 136 752)
                  (call L.*.75.8 *.75 664 1824)))
                (call
                 L.-.74.9
                 |-.74|
                 (call
                  L.*.75.8
                  *.75
                  (call L.-.74.9 |-.74| 608 240)
                  (call L.+.73.10 |+.73| 160 472))
                 (call
                  L.-.74.9
                  |-.74|
                  (call L.-.74.9 |-.74| 1984 504)
                  (call L.*.75.8 *.75 472 280)))))
              (vector1.18 (call L.fun/vector14772.5.15 fun/vector14772.5))
              (boolean2.17
               (call
                L.procedure?.76.7
                procedure?.76
                (call L.fun/any14774.13.23 fun/any14774.13)))
              (vector3.16 (call L.fun/vector14776.12.22 fun/vector14776.12))
              (fixnum4.15
               (call
                L.-.74.9
                |-.74|
                (call
                 L.-.74.9
                 |-.74|
                 (call
                  L.-.74.9
                  |-.74|
                  (call L.*.75.8 *.75 280 424)
                  (call L.+.73.10 |+.73| 1216 288))
                 (call
                  L.-.74.9
                  |-.74|
                  (call L.+.73.10 |+.73| 1176 888)
                  (call L.-.74.9 |-.74| 2000 1664)))
                (call
                 L.+.73.10
                 |+.73|
                 (call
                  L.+.73.10
                  |+.73|
                  (call L.+.73.10 |+.73| 1960 912)
                  (call L.*.75.8 *.75 944 712))
                 (call
                  L.-.74.9
                  |-.74|
                  (call L.*.75.8 *.75 1184 1936)
                  (call L.-.74.9 |-.74| 1696 600)))))
              (empty5.14 (call L.fun/empty14778.10.20 fun/empty14778.10)))
          (call L.fun/ascii-char14780.4.14 fun/ascii-char14780.4))))))
(check-by-interp
 '(module
    (define L.fun/error15420.17.22
      (lambda (c.93)
        (let ((fun/error15421.9 (mref c.93 14)))
          (call L.fun/error15421.9.14 fun/error15421.9))))
    (define L.fun/error15416.16.21
      (lambda (c.92)
        (let ((fun/error15417.4 (mref c.92 14)))
          (call L.fun/error15417.4.9 fun/error15417.4))))
    (define L.fun/pair15427.15.20
      (lambda (c.91)
        (let ((cons.76 (mref c.91 14))) (call L.cons.76.8 cons.76 1976 4088))))
    (define L.fun/any15414.14.19
      (lambda (c.90)
        (let ((fun/any15415.5 (mref c.90 14)))
          (call L.fun/any15415.5.10 fun/any15415.5))))
    (define L.fun/void15425.13.18 (lambda (c.89) (let () 30)))
    (define L.fun/error15422.12.17
      (lambda (c.88)
        (let ((fun/error15423.7 (mref c.88 14)))
          (call L.fun/error15423.7.12 fun/error15423.7))))
    (define L.fun/error15419.11.16 (lambda (c.87) (let () 58686)))
    (define L.fun/error15418.10.15
      (lambda (c.86)
        (let ((fun/error15419.11 (mref c.86 14)))
          (call L.fun/error15419.11.16 fun/error15419.11))))
    (define L.fun/error15421.9.14 (lambda (c.85) (let () 9534)))
    (define L.fun/void15424.8.13
      (lambda (c.84)
        (let ((fun/void15425.13 (mref c.84 14)))
          (call L.fun/void15425.13.18 fun/void15425.13))))
    (define L.fun/error15423.7.12 (lambda (c.83) (let () 22590)))
    (define L.fun/pair15426.6.11
      (lambda (c.82)
        (let ((fun/pair15427.15 (mref c.82 14)))
          (call L.fun/pair15427.15.20 fun/pair15427.15))))
    (define L.fun/any15415.5.10 (lambda (c.81) (let () 6)))
    (define L.fun/error15417.4.9 (lambda (c.80) (let () 6718)))
    (define L.cons.76.8
      (lambda (c.79 tmp.71 tmp.72)
        (let ()
          (let ((tmp.94 (+ (alloc 16) 1)))
            (begin (mset! tmp.94 -1 tmp.71) (mset! tmp.94 7 tmp.72) tmp.94)))))
    (define L.ascii-char?.77.7
      (lambda (c.78 tmp.65)
        (let () (if (= (bitwise-and tmp.65 255) 46) 14 6))))
    (let ((ascii-char?.77
           (let ((tmp.95 (+ (alloc 16) 2)))
             (begin
               (mset! tmp.95 -2 L.ascii-char?.77.7)
               (mset! tmp.95 6 8)
               tmp.95)))
          (cons.76
           (let ((tmp.96 (+ (alloc 16) 2)))
             (begin (mset! tmp.96 -2 L.cons.76.8) (mset! tmp.96 6 16) tmp.96)))
          (fun/error15417.4
           (let ((tmp.97 (+ (alloc 16) 2)))
             (begin
               (mset! tmp.97 -2 L.fun/error15417.4.9)
               (mset! tmp.97 6 0)
               tmp.97)))
          (fun/any15415.5
           (let ((tmp.98 (+ (alloc 16) 2)))
             (begin
               (mset! tmp.98 -2 L.fun/any15415.5.10)
               (mset! tmp.98 6 0)
               tmp.98)))
          (fun/pair15426.6
           (let ((tmp.99 (+ (alloc 24) 2)))
             (begin
               (mset! tmp.99 -2 L.fun/pair15426.6.11)
               (mset! tmp.99 6 0)
               tmp.99)))
          (fun/error15423.7
           (let ((tmp.100 (+ (alloc 16) 2)))
             (begin
               (mset! tmp.100 -2 L.fun/error15423.7.12)
               (mset! tmp.100 6 0)
               tmp.100)))
          (fun/void15424.8
           (let ((tmp.101 (+ (alloc 24) 2)))
             (begin
               (mset! tmp.101 -2 L.fun/void15424.8.13)
               (mset! tmp.101 6 0)
               tmp.101)))
          (fun/error15421.9
           (let ((tmp.102 (+ (alloc 16) 2)))
             (begin
               (mset! tmp.102 -2 L.fun/error15421.9.14)
               (mset! tmp.102 6 0)
               tmp.102)))
          (fun/error15418.10
           (let ((tmp.103 (+ (alloc 24) 2)))
             (begin
               (mset! tmp.103 -2 L.fun/error15418.10.15)
               (mset! tmp.103 6 0)
               tmp.103)))
          (fun/error15419.11
           (let ((tmp.104 (+ (alloc 16) 2)))
             (begin
               (mset! tmp.104 -2 L.fun/error15419.11.16)
               (mset! tmp.104 6 0)
               tmp.104)))
          (fun/error15422.12
           (let ((tmp.105 (+ (alloc 24) 2)))
             (begin
               (mset! tmp.105 -2 L.fun/error15422.12.17)
               (mset! tmp.105 6 0)
               tmp.105)))
          (fun/void15425.13
           (let ((tmp.106 (+ (alloc 16) 2)))
             (begin
               (mset! tmp.106 -2 L.fun/void15425.13.18)
               (mset! tmp.106 6 0)
               tmp.106)))
          (fun/any15414.14
           (let ((tmp.107 (+ (alloc 24) 2)))
             (begin
               (mset! tmp.107 -2 L.fun/any15414.14.19)
               (mset! tmp.107 6 0)
               tmp.107)))
          (fun/pair15427.15
           (let ((tmp.108 (+ (alloc 24) 2)))
             (begin
               (mset! tmp.108 -2 L.fun/pair15427.15.20)
               (mset! tmp.108 6 0)
               tmp.108)))
          (fun/error15416.16
           (let ((tmp.109 (+ (alloc 24) 2)))
             (begin
               (mset! tmp.109 -2 L.fun/error15416.16.21)
               (mset! tmp.109 6 0)
               tmp.109)))
          (fun/error15420.17
           (let ((tmp.110 (+ (alloc 24) 2)))
             (begin
               (mset! tmp.110 -2 L.fun/error15420.17.22)
               (mset! tmp.110 6 0)
               tmp.110))))
      (begin
        (mset! fun/pair15426.6 14 fun/pair15427.15)
        (mset! fun/void15424.8 14 fun/void15425.13)
        (mset! fun/error15418.10 14 fun/error15419.11)
        (mset! fun/error15422.12 14 fun/error15423.7)
        (mset! fun/any15414.14 14 fun/any15415.5)
        (mset! fun/pair15427.15 14 cons.76)
        (mset! fun/error15416.16 14 fun/error15417.4)
        (mset! fun/error15420.17 14 fun/error15421.9)
        (let ((boolean0.23
               (call
                L.ascii-char?.77.7
                ascii-char?.77
                (call L.fun/any15414.14.19 fun/any15414.14)))
              (error1.22 (call L.fun/error15416.16.21 fun/error15416.16))
              (error2.21 (call L.fun/error15418.10.15 fun/error15418.10))
              (error3.20 (call L.fun/error15420.17.22 fun/error15420.17))
              (error4.19 (call L.fun/error15422.12.17 fun/error15422.12))
              (void5.18 (call L.fun/void15424.8.13 fun/void15424.8)))
          (call L.fun/pair15426.6.11 fun/pair15426.6))))))
(check-by-interp
 '(module
    (define L.fun/ascii-char16443.15.21
      (lambda (c.91)
        (let ((fun/ascii-char16444.5 (mref c.91 14)))
          (call L.fun/ascii-char16444.5.11 fun/ascii-char16444.5))))
    (define L.fun/void16440.14.20 (lambda (c.90) (let () 30)))
    (define L.fun/error16434.13.19 (lambda (c.89) (let () 61246)))
    (define L.fun/ascii-char16441.12.18
      (lambda (c.88)
        (let ((fun/ascii-char16442.11 (mref c.88 14)))
          (call L.fun/ascii-char16442.11.17 fun/ascii-char16442.11))))
    (define L.fun/ascii-char16442.11.17 (lambda (c.87) (let () 24622)))
    (define L.fun/ascii-char16436.10.16 (lambda (c.86) (let () 23342)))
    (define L.fun/ascii-char16438.9.15 (lambda (c.85) (let () 18478)))
    (define L.fun/error16433.8.14
      (lambda (c.84)
        (let ((fun/error16434.13 (mref c.84 14)))
          (call L.fun/error16434.13.19 fun/error16434.13))))
    (define L.fun/ascii-char16437.7.13
      (lambda (c.83)
        (let ((fun/ascii-char16438.9 (mref c.83 14)))
          (call L.fun/ascii-char16438.9.15 fun/ascii-char16438.9))))
    (define L.fun/void16439.6.12
      (lambda (c.82)
        (let ((fun/void16440.14 (mref c.82 14)))
          (call L.fun/void16440.14.20 fun/void16440.14))))
    (define L.fun/ascii-char16444.5.11 (lambda (c.81) (let () 25902)))
    (define L.fun/ascii-char16435.4.10
      (lambda (c.80)
        (let ((fun/ascii-char16436.10 (mref c.80 14)))
          (call L.fun/ascii-char16436.10.16 fun/ascii-char16436.10))))
    (define L.*.74.9
      (lambda (c.79 tmp.36 tmp.37)
        (let ()
          (if (!= (if (= (bitwise-and tmp.37 7) 0) 14 6) 6)
            (if (!= (if (= (bitwise-and tmp.36 7) 0) 14 6) 6)
              (* tmp.36 (arithmetic-shift-right tmp.37 3))
              318)
            318))))
    (define L.-.75.8
      (lambda (c.78 tmp.40 tmp.41)
        (let ()
          (if (!= (if (= (bitwise-and tmp.41 7) 0) 14 6) 6)
            (if (!= (if (= (bitwise-and tmp.40 7) 0) 14 6) 6)
              (- tmp.40 tmp.41)
              830)
            830))))
    (define L.+.76.7
      (lambda (c.77 tmp.38 tmp.39)
        (let ()
          (if (!= (if (= (bitwise-and tmp.39 7) 0) 14 6) 6)
            (if (!= (if (= (bitwise-and tmp.38 7) 0) 14 6) 6)
              (+ tmp.38 tmp.39)
              574)
            574))))
    (let ((|+.76|
           (let ((tmp.92 (+ (alloc 16) 2)))
             (begin (mset! tmp.92 -2 L.+.76.7) (mset! tmp.92 6 16) tmp.92)))
          (|-.75|
           (let ((tmp.93 (+ (alloc 16) 2)))
             (begin (mset! tmp.93 -2 L.-.75.8) (mset! tmp.93 6 16) tmp.93)))
          (*.74
           (let ((tmp.94 (+ (alloc 16) 2)))
             (begin (mset! tmp.94 -2 L.*.74.9) (mset! tmp.94 6 16) tmp.94)))
          (fun/ascii-char16435.4
           (let ((tmp.95 (+ (alloc 24) 2)))
             (begin
               (mset! tmp.95 -2 L.fun/ascii-char16435.4.10)
               (mset! tmp.95 6 0)
               tmp.95)))
          (fun/ascii-char16444.5
           (let ((tmp.96 (+ (alloc 16) 2)))
             (begin
               (mset! tmp.96 -2 L.fun/ascii-char16444.5.11)
               (mset! tmp.96 6 0)
               tmp.96)))
          (fun/void16439.6
           (let ((tmp.97 (+ (alloc 24) 2)))
             (begin
               (mset! tmp.97 -2 L.fun/void16439.6.12)
               (mset! tmp.97 6 0)
               tmp.97)))
          (fun/ascii-char16437.7
           (let ((tmp.98 (+ (alloc 24) 2)))
             (begin
               (mset! tmp.98 -2 L.fun/ascii-char16437.7.13)
               (mset! tmp.98 6 0)
               tmp.98)))
          (fun/error16433.8
           (let ((tmp.99 (+ (alloc 24) 2)))
             (begin
               (mset! tmp.99 -2 L.fun/error16433.8.14)
               (mset! tmp.99 6 0)
               tmp.99)))
          (fun/ascii-char16438.9
           (let ((tmp.100 (+ (alloc 16) 2)))
             (begin
               (mset! tmp.100 -2 L.fun/ascii-char16438.9.15)
               (mset! tmp.100 6 0)
               tmp.100)))
          (fun/ascii-char16436.10
           (let ((tmp.101 (+ (alloc 16) 2)))
             (begin
               (mset! tmp.101 -2 L.fun/ascii-char16436.10.16)
               (mset! tmp.101 6 0)
               tmp.101)))
          (fun/ascii-char16442.11
           (let ((tmp.102 (+ (alloc 16) 2)))
             (begin
               (mset! tmp.102 -2 L.fun/ascii-char16442.11.17)
               (mset! tmp.102 6 0)
               tmp.102)))
          (fun/ascii-char16441.12
           (let ((tmp.103 (+ (alloc 24) 2)))
             (begin
               (mset! tmp.103 -2 L.fun/ascii-char16441.12.18)
               (mset! tmp.103 6 0)
               tmp.103)))
          (fun/error16434.13
           (let ((tmp.104 (+ (alloc 16) 2)))
             (begin
               (mset! tmp.104 -2 L.fun/error16434.13.19)
               (mset! tmp.104 6 0)
               tmp.104)))
          (fun/void16440.14
           (let ((tmp.105 (+ (alloc 16) 2)))
             (begin
               (mset! tmp.105 -2 L.fun/void16440.14.20)
               (mset! tmp.105 6 0)
               tmp.105)))
          (fun/ascii-char16443.15
           (let ((tmp.106 (+ (alloc 24) 2)))
             (begin
               (mset! tmp.106 -2 L.fun/ascii-char16443.15.21)
               (mset! tmp.106 6 0)
               tmp.106))))
      (begin
        (mset! fun/ascii-char16435.4 14 fun/ascii-char16436.10)
        (mset! fun/void16439.6 14 fun/void16440.14)
        (mset! fun/ascii-char16437.7 14 fun/ascii-char16438.9)
        (mset! fun/error16433.8 14 fun/error16434.13)
        (mset! fun/ascii-char16441.12 14 fun/ascii-char16442.11)
        (mset! fun/ascii-char16443.15 14 fun/ascii-char16444.5)
        (let ((error0.21 (call L.fun/error16433.8.14 fun/error16433.8))
              (ascii-char1.20
               (call L.fun/ascii-char16435.4.10 fun/ascii-char16435.4))
              (fixnum2.19
               (call
                L.+.76.7
                |+.76|
                (call
                 L.*.74.9
                 *.74
                 (call
                  L.-.75.8
                  |-.75|
                  (call L.*.74.9 *.74 1920 368)
                  (call L.-.75.8 |-.75| 1504 896))
                 (call
                  L.-.75.8
                  |-.75|
                  (call L.*.74.9 *.74 280 1680)
                  (call L.+.76.7 |+.76| 856 2032)))
                (call
                 L.-.75.8
                 |-.75|
                 (call
                  L.*.74.9
                  *.74
                  (call L.-.75.8 |-.75| 640 1864)
                  (call L.*.74.9 *.74 864 1488))
                 (call
                  L.-.75.8
                  |-.75|
                  (call L.-.75.8 |-.75| 1872 1376)
                  (call L.+.76.7 |+.76| 1432 640)))))
              (ascii-char3.18
               (call L.fun/ascii-char16437.7.13 fun/ascii-char16437.7))
              (void4.17 (call L.fun/void16439.6.12 fun/void16439.6))
              (ascii-char5.16
               (call L.fun/ascii-char16441.12.18 fun/ascii-char16441.12)))
          (call L.fun/ascii-char16443.15.21 fun/ascii-char16443.15))))))
(check-by-interp
 '(module
    (define L.fun/error16486.12.24 (lambda (c.107) (let () 57662)))
    (define L.fun/empty16490.11.23 (lambda (c.106) (let () 22)))
    (define L.fun/error16485.10.22 (lambda (c.105) (let () 60734)))
    (define L.fun/empty16489.9.21 (lambda (c.104) (let () 22)))
    (define L.fun/any16488.8.20 (lambda (c.103) (let () 544)))
    (define L.fun/empty16487.7.19 (lambda (c.102) (let () 22)))
    (define L.fun/vector16484.6.18
      (lambda (c.101)
        (let ((make-vector.83 (mref c.101 14)))
          (call L.make-vector.83.15 make-vector.83 64))))
    (define L.fun/empty16491.5.17 (lambda (c.100) (let () 22)))
    (define L.fun/ascii-char16492.4.16 (lambda (c.99) (let () 26670)))
    (define L.make-vector.83.15
      (lambda (c.98 tmp.59)
        (let ((make-init-vector.1 (mref c.98 14)))
          (if (!= (if (= (bitwise-and tmp.59 7) 0) 14 6) 6)
            (call L.make-init-vector.1.14 make-init-vector.1 tmp.59)
            2110))))
    (define L.make-init-vector.1.14
      (lambda (c.97 tmp.31)
        (let ((vector-init-loop.33 (mref c.97 14)))
          (let ((tmp.32
                 (let ((tmp.108
                        (+
                         (alloc (* (+ 1 (arithmetic-shift-right tmp.31 3)) 8))
                         3)))
                   (begin (mset! tmp.108 -3 tmp.31) tmp.108))))
            (call
             L.vector-init-loop.33.13
             vector-init-loop.33
             tmp.31
             0
             tmp.32)))))
    (define L.vector-init-loop.33.13
      (lambda (c.96 len.34 i.36 vec.35)
        (let ((vector-init-loop.33 (mref c.96 14)))
          (if (!= (if (= len.34 i.36) 14 6) 6)
            vec.35
            (begin
              (mset! vec.35 (+ (* (arithmetic-shift-right i.36 3) 8) 5) 0)
              (call
               L.vector-init-loop.33.13
               vector-init-loop.33
               len.34
               (+ i.36 8)
               vec.35))))))
    (define L.-.84.12
      (lambda (c.95 tmp.49 tmp.50)
        (let ()
          (if (!= (if (= (bitwise-and tmp.50 7) 0) 14 6) 6)
            (if (!= (if (= (bitwise-and tmp.49 7) 0) 14 6) 6)
              (- tmp.49 tmp.50)
              830)
            830))))
    (define L.+.85.11
      (lambda (c.94 tmp.47 tmp.48)
        (let ()
          (if (!= (if (= (bitwise-and tmp.48 7) 0) 14 6) 6)
            (if (!= (if (= (bitwise-and tmp.47 7) 0) 14 6) 6)
              (+ tmp.47 tmp.48)
              574)
            574))))
    (define L.<=.86.10
      (lambda (c.93 tmp.53 tmp.54)
        (let ()
          (if (!= (if (= (bitwise-and tmp.54 7) 0) 14 6) 6)
            (if (!= (if (= (bitwise-and tmp.53 7) 0) 14 6) 6)
              (if (<= tmp.53 tmp.54) 14 6)
              1342)
            1342))))
    (define L.boolean?.87.9
      (lambda (c.92 tmp.69) (let () (if (= (bitwise-and tmp.69 247) 6) 14 6))))
    (define L.*.88.8
      (lambda (c.91 tmp.45 tmp.46)
        (let ()
          (if (!= (if (= (bitwise-and tmp.46 7) 0) 14 6) 6)
            (if (!= (if (= (bitwise-and tmp.45 7) 0) 14 6) 6)
              (* tmp.45 (arithmetic-shift-right tmp.46 3))
              318)
            318))))
    (define L.>.89.7
      (lambda (c.90 tmp.55 tmp.56)
        (let ()
          (if (!= (if (= (bitwise-and tmp.56 7) 0) 14 6) 6)
            (if (!= (if (= (bitwise-and tmp.55 7) 0) 14 6) 6)
              (if (> tmp.55 tmp.56) 14 6)
              1598)
            1598))))
    (let ((>.89
           (let ((tmp.109 (+ (alloc 16) 2)))
             (begin (mset! tmp.109 -2 L.>.89.7) (mset! tmp.109 6 16) tmp.109)))
          (*.88
           (let ((tmp.110 (+ (alloc 16) 2)))
             (begin (mset! tmp.110 -2 L.*.88.8) (mset! tmp.110 6 16) tmp.110)))
          (boolean?.87
           (let ((tmp.111 (+ (alloc 16) 2)))
             (begin
               (mset! tmp.111 -2 L.boolean?.87.9)
               (mset! tmp.111 6 8)
               tmp.111)))
          (<=.86
           (let ((tmp.112 (+ (alloc 16) 2)))
             (begin
               (mset! tmp.112 -2 L.<=.86.10)
               (mset! tmp.112 6 16)
               tmp.112)))
          (|+.85|
           (let ((tmp.113 (+ (alloc 16) 2)))
             (begin
               (mset! tmp.113 -2 L.+.85.11)
               (mset! tmp.113 6 16)
               tmp.113)))
          (|-.84|
           (let ((tmp.114 (+ (alloc 16) 2)))
             (begin
               (mset! tmp.114 -2 L.-.84.12)
               (mset! tmp.114 6 16)
               tmp.114)))
          (vector-init-loop.33
           (let ((tmp.115 (+ (alloc 24) 2)))
             (begin
               (mset! tmp.115 -2 L.vector-init-loop.33.13)
               (mset! tmp.115 6 24)
               tmp.115)))
          (make-init-vector.1
           (let ((tmp.116 (+ (alloc 24) 2)))
             (begin
               (mset! tmp.116 -2 L.make-init-vector.1.14)
               (mset! tmp.116 6 8)
               tmp.116)))
          (make-vector.83
           (let ((tmp.117 (+ (alloc 24) 2)))
             (begin
               (mset! tmp.117 -2 L.make-vector.83.15)
               (mset! tmp.117 6 8)
               tmp.117)))
          (fun/ascii-char16492.4
           (let ((tmp.118 (+ (alloc 16) 2)))
             (begin
               (mset! tmp.118 -2 L.fun/ascii-char16492.4.16)
               (mset! tmp.118 6 0)
               tmp.118)))
          (fun/empty16491.5
           (let ((tmp.119 (+ (alloc 16) 2)))
             (begin
               (mset! tmp.119 -2 L.fun/empty16491.5.17)
               (mset! tmp.119 6 0)
               tmp.119)))
          (fun/vector16484.6
           (let ((tmp.120 (+ (alloc 24) 2)))
             (begin
               (mset! tmp.120 -2 L.fun/vector16484.6.18)
               (mset! tmp.120 6 0)
               tmp.120)))
          (fun/empty16487.7
           (let ((tmp.121 (+ (alloc 16) 2)))
             (begin
               (mset! tmp.121 -2 L.fun/empty16487.7.19)
               (mset! tmp.121 6 0)
               tmp.121)))
          (fun/any16488.8
           (let ((tmp.122 (+ (alloc 16) 2)))
             (begin
               (mset! tmp.122 -2 L.fun/any16488.8.20)
               (mset! tmp.122 6 0)
               tmp.122)))
          (fun/empty16489.9
           (let ((tmp.123 (+ (alloc 16) 2)))
             (begin
               (mset! tmp.123 -2 L.fun/empty16489.9.21)
               (mset! tmp.123 6 0)
               tmp.123)))
          (fun/error16485.10
           (let ((tmp.124 (+ (alloc 16) 2)))
             (begin
               (mset! tmp.124 -2 L.fun/error16485.10.22)
               (mset! tmp.124 6 0)
               tmp.124)))
          (fun/empty16490.11
           (let ((tmp.125 (+ (alloc 16) 2)))
             (begin
               (mset! tmp.125 -2 L.fun/empty16490.11.23)
               (mset! tmp.125 6 0)
               tmp.125)))
          (fun/error16486.12
           (let ((tmp.126 (+ (alloc 16) 2)))
             (begin
               (mset! tmp.126 -2 L.fun/error16486.12.24)
               (mset! tmp.126 6 0)
               tmp.126))))
      (begin
        (mset! vector-init-loop.33 14 vector-init-loop.33)
        (mset! make-init-vector.1 14 vector-init-loop.33)
        (mset! make-vector.83 14 make-init-vector.1)
        (mset! fun/vector16484.6 14 make-vector.83)
        (if (let ((fixnum0.18
                   (call
                    L.-.84.12
                    |-.84|
                    (call L.-.84.12 |-.84| 712 1600)
                    (call L.+.85.11 |+.85| 304 1928)))
                  (vector1.17 (call L.fun/vector16484.6.18 fun/vector16484.6))
                  (error2.16 (call L.fun/error16485.10.22 fun/error16485.10))
                  (error3.15 (call L.fun/error16486.12.24 fun/error16486.12))
                  (empty4.14 (call L.fun/empty16487.7.19 fun/empty16487.7))
                  (boolean5.13
                   (call
                    L.<=.86.10
                    <=.86
                    (call L.-.84.12 |-.84| 1480 1376)
                    (call L.+.85.11 |+.85| 1088 1384))))
              (!=
               (call
                L.boolean?.87.9
                boolean?.87
                (call L.fun/any16488.8.20 fun/any16488.8))
               6))
          (if (if (!= 14 6) (!= 6 6) (!= 6 6))
            (let ((ascii-char0.24 24366)
                  (ascii-char1.23 16686)
                  (boolean2.22 6)
                  (void3.21 30)
                  (boolean4.20 6)
                  (empty5.19 22))
              21806)
            (if (!= 14 6) 30254 21806))
          (let ((empty0.30 (call L.fun/empty16489.9.21 fun/empty16489.9))
                (fixnum1.29
                 (call
                  L.-.84.12
                  |-.84|
                  (call L.*.88.8 *.88 424 1672)
                  (call L.*.88.8 *.88 16 920)))
                (boolean2.28
                 (call
                  L.>.89.7
                  >.89
                  (call L.*.88.8 *.88 752 176)
                  (call L.+.85.11 |+.85| 712 680)))
                (empty3.27 (call L.fun/empty16490.11.23 fun/empty16490.11))
                (fixnum4.26
                 (call
                  L.-.84.12
                  |-.84|
                  (call L.-.84.12 |-.84| 136 504)
                  (call L.*.88.8 *.88 1176 40)))
                (empty5.25 (call L.fun/empty16491.5.17 fun/empty16491.5)))
            (call L.fun/ascii-char16492.4.16 fun/ascii-char16492.4)))))))
(check-by-interp
 '(module
    (define L.fun/vector16594.17.25
      (lambda (c.97)
        (let ((fun/vector16595.8 (mref c.97 14)))
          (call L.fun/vector16595.8.16 fun/vector16595.8))))
    (define L.fun/void16600.16.24
      (lambda (c.96)
        (let ((fun/void16601.9 (mref c.96 14)))
          (call L.fun/void16601.9.17 fun/void16601.9))))
    (define L.fun/ascii-char16602.15.23
      (lambda (c.95)
        (let ((fun/ascii-char16603.5 (mref c.95 14)))
          (call L.fun/ascii-char16603.5.13 fun/ascii-char16603.5))))
    (define L.fun/ascii-char16596.14.22
      (lambda (c.94)
        (let ((fun/ascii-char16597.10 (mref c.94 14)))
          (call L.fun/ascii-char16597.10.18 fun/ascii-char16597.10))))
    (define L.fun/vector16593.13.21
      (lambda (c.93)
        (let ((make-vector.76 (mref c.93 14)))
          (call L.make-vector.76.11 make-vector.76 64))))
    (define L.fun/any16599.12.20
      (lambda (c.92)
        (let ((cons.77 (mref c.92 14))) (call L.cons.77.8 cons.77 1424 4088))))
    (define L.fun/vector16604.11.19
      (lambda (c.91)
        (let ((fun/vector16605.7 (mref c.91 14)))
          (call L.fun/vector16605.7.15 fun/vector16605.7))))
    (define L.fun/ascii-char16597.10.18 (lambda (c.90) (let () 25390)))
    (define L.fun/void16601.9.17 (lambda (c.89) (let () 30)))
    (define L.fun/vector16595.8.16
      (lambda (c.88)
        (let ((make-vector.76 (mref c.88 14)))
          (call L.make-vector.76.11 make-vector.76 64))))
    (define L.fun/vector16605.7.15
      (lambda (c.87)
        (let ((make-vector.76 (mref c.87 14)))
          (call L.make-vector.76.11 make-vector.76 64))))
    (define L.fun/vector16592.6.14
      (lambda (c.86)
        (let ((fun/vector16593.13 (mref c.86 14)))
          (call L.fun/vector16593.13.21 fun/vector16593.13))))
    (define L.fun/ascii-char16603.5.13 (lambda (c.85) (let () 23854)))
    (define L.fun/any16598.4.12
      (lambda (c.84)
        (let ((fun/any16599.12 (mref c.84 14)))
          (call L.fun/any16599.12.20 fun/any16599.12))))
    (define L.make-vector.76.11
      (lambda (c.83 tmp.52)
        (let ((make-init-vector.1 (mref c.83 14)))
          (if (!= (if (= (bitwise-and tmp.52 7) 0) 14 6) 6)
            (call L.make-init-vector.1.10 make-init-vector.1 tmp.52)
            2110))))
    (define L.make-init-vector.1.10
      (lambda (c.82 tmp.24)
        (let ((vector-init-loop.26 (mref c.82 14)))
          (let ((tmp.25
                 (let ((tmp.98
                        (+
                         (alloc (* (+ 1 (arithmetic-shift-right tmp.24 3)) 8))
                         3)))
                   (begin (mset! tmp.98 -3 tmp.24) tmp.98))))
            (call
             L.vector-init-loop.26.9
             vector-init-loop.26
             tmp.24
             0
             tmp.25)))))
    (define L.vector-init-loop.26.9
      (lambda (c.81 len.27 i.29 vec.28)
        (let ((vector-init-loop.26 (mref c.81 14)))
          (if (!= (if (= len.27 i.29) 14 6) 6)
            vec.28
            (begin
              (mset! vec.28 (+ (* (arithmetic-shift-right i.29 3) 8) 5) 0)
              (call
               L.vector-init-loop.26.9
               vector-init-loop.26
               len.27
               (+ i.29 8)
               vec.28))))))
    (define L.cons.77.8
      (lambda (c.80 tmp.71 tmp.72)
        (let ()
          (let ((tmp.99 (+ (alloc 16) 1)))
            (begin (mset! tmp.99 -1 tmp.71) (mset! tmp.99 7 tmp.72) tmp.99)))))
    (define L.procedure?.78.7
      (lambda (c.79 tmp.70) (let () (if (= (bitwise-and tmp.70 7) 2) 14 6))))
    (let ((procedure?.78
           (let ((tmp.100 (+ (alloc 16) 2)))
             (begin
               (mset! tmp.100 -2 L.procedure?.78.7)
               (mset! tmp.100 6 8)
               tmp.100)))
          (cons.77
           (let ((tmp.101 (+ (alloc 16) 2)))
             (begin
               (mset! tmp.101 -2 L.cons.77.8)
               (mset! tmp.101 6 16)
               tmp.101)))
          (vector-init-loop.26
           (let ((tmp.102 (+ (alloc 24) 2)))
             (begin
               (mset! tmp.102 -2 L.vector-init-loop.26.9)
               (mset! tmp.102 6 24)
               tmp.102)))
          (make-init-vector.1
           (let ((tmp.103 (+ (alloc 24) 2)))
             (begin
               (mset! tmp.103 -2 L.make-init-vector.1.10)
               (mset! tmp.103 6 8)
               tmp.103)))
          (make-vector.76
           (let ((tmp.104 (+ (alloc 24) 2)))
             (begin
               (mset! tmp.104 -2 L.make-vector.76.11)
               (mset! tmp.104 6 8)
               tmp.104)))
          (fun/any16598.4
           (let ((tmp.105 (+ (alloc 24) 2)))
             (begin
               (mset! tmp.105 -2 L.fun/any16598.4.12)
               (mset! tmp.105 6 0)
               tmp.105)))
          (fun/ascii-char16603.5
           (let ((tmp.106 (+ (alloc 16) 2)))
             (begin
               (mset! tmp.106 -2 L.fun/ascii-char16603.5.13)
               (mset! tmp.106 6 0)
               tmp.106)))
          (fun/vector16592.6
           (let ((tmp.107 (+ (alloc 24) 2)))
             (begin
               (mset! tmp.107 -2 L.fun/vector16592.6.14)
               (mset! tmp.107 6 0)
               tmp.107)))
          (fun/vector16605.7
           (let ((tmp.108 (+ (alloc 24) 2)))
             (begin
               (mset! tmp.108 -2 L.fun/vector16605.7.15)
               (mset! tmp.108 6 0)
               tmp.108)))
          (fun/vector16595.8
           (let ((tmp.109 (+ (alloc 24) 2)))
             (begin
               (mset! tmp.109 -2 L.fun/vector16595.8.16)
               (mset! tmp.109 6 0)
               tmp.109)))
          (fun/void16601.9
           (let ((tmp.110 (+ (alloc 16) 2)))
             (begin
               (mset! tmp.110 -2 L.fun/void16601.9.17)
               (mset! tmp.110 6 0)
               tmp.110)))
          (fun/ascii-char16597.10
           (let ((tmp.111 (+ (alloc 16) 2)))
             (begin
               (mset! tmp.111 -2 L.fun/ascii-char16597.10.18)
               (mset! tmp.111 6 0)
               tmp.111)))
          (fun/vector16604.11
           (let ((tmp.112 (+ (alloc 24) 2)))
             (begin
               (mset! tmp.112 -2 L.fun/vector16604.11.19)
               (mset! tmp.112 6 0)
               tmp.112)))
          (fun/any16599.12
           (let ((tmp.113 (+ (alloc 24) 2)))
             (begin
               (mset! tmp.113 -2 L.fun/any16599.12.20)
               (mset! tmp.113 6 0)
               tmp.113)))
          (fun/vector16593.13
           (let ((tmp.114 (+ (alloc 24) 2)))
             (begin
               (mset! tmp.114 -2 L.fun/vector16593.13.21)
               (mset! tmp.114 6 0)
               tmp.114)))
          (fun/ascii-char16596.14
           (let ((tmp.115 (+ (alloc 24) 2)))
             (begin
               (mset! tmp.115 -2 L.fun/ascii-char16596.14.22)
               (mset! tmp.115 6 0)
               tmp.115)))
          (fun/ascii-char16602.15
           (let ((tmp.116 (+ (alloc 24) 2)))
             (begin
               (mset! tmp.116 -2 L.fun/ascii-char16602.15.23)
               (mset! tmp.116 6 0)
               tmp.116)))
          (fun/void16600.16
           (let ((tmp.117 (+ (alloc 24) 2)))
             (begin
               (mset! tmp.117 -2 L.fun/void16600.16.24)
               (mset! tmp.117 6 0)
               tmp.117)))
          (fun/vector16594.17
           (let ((tmp.118 (+ (alloc 24) 2)))
             (begin
               (mset! tmp.118 -2 L.fun/vector16594.17.25)
               (mset! tmp.118 6 0)
               tmp.118))))
      (begin
        (mset! vector-init-loop.26 14 vector-init-loop.26)
        (mset! make-init-vector.1 14 vector-init-loop.26)
        (mset! make-vector.76 14 make-init-vector.1)
        (mset! fun/any16598.4 14 fun/any16599.12)
        (mset! fun/vector16592.6 14 fun/vector16593.13)
        (mset! fun/vector16605.7 14 make-vector.76)
        (mset! fun/vector16595.8 14 make-vector.76)
        (mset! fun/vector16604.11 14 fun/vector16605.7)
        (mset! fun/any16599.12 14 cons.77)
        (mset! fun/vector16593.13 14 make-vector.76)
        (mset! fun/ascii-char16596.14 14 fun/ascii-char16597.10)
        (mset! fun/ascii-char16602.15 14 fun/ascii-char16603.5)
        (mset! fun/void16600.16 14 fun/void16601.9)
        (mset! fun/vector16594.17 14 fun/vector16595.8)
        (let ((vector0.23 (call L.fun/vector16592.6.14 fun/vector16592.6))
              (vector1.22 (call L.fun/vector16594.17.25 fun/vector16594.17))
              (ascii-char2.21
               (call L.fun/ascii-char16596.14.22 fun/ascii-char16596.14))
              (boolean3.20
               (call
                L.procedure?.78.7
                procedure?.78
                (call L.fun/any16598.4.12 fun/any16598.4)))
              (void4.19 (call L.fun/void16600.16.24 fun/void16600.16))
              (ascii-char5.18
               (call L.fun/ascii-char16602.15.23 fun/ascii-char16602.15)))
          (call L.fun/vector16604.11.19 fun/vector16604.11))))))
(check-by-interp
 '(module
    (define L.lam.80.27
      (lambda (c.101)
        (let ((fun/empty17996.16 (mref c.101 14)))
          (call L.fun/empty17996.16.25 fun/empty17996.16))))
    (define L.fun/ascii-char18009.17.26 (lambda (c.100) (let () 18222)))
    (define L.fun/empty17996.16.25
      (lambda (c.99)
        (let ((fun/empty17997.10 (mref c.99 14)))
          (call L.fun/empty17997.10.19 fun/empty17997.10))))
    (define L.fun/vector18000.15.24
      (lambda (c.98)
        (let ((fun/vector18001.4 (mref c.98 14)))
          (call L.fun/vector18001.4.13 fun/vector18001.4))))
    (define L.fun/any18003.14.23
      (lambda (c.97)
        (let ((cons.77 (mref c.97 14))) (call L.cons.77.9 cons.77 784 2296))))
    (define L.fun/any18004.13.22
      (lambda (c.96)
        (let ((fun/any18005.11 (mref c.96 14)))
          (call L.fun/any18005.11.20 fun/any18005.11))))
    (define L.fun/void18007.12.21 (lambda (c.95) (let () 30)))
    (define L.fun/any18005.11.20 (lambda (c.94) (let () 40510)))
    (define L.fun/empty17997.10.19 (lambda (c.93) (let () 22)))
    (define L.fun/any18002.9.18
      (lambda (c.92)
        (let ((fun/any18003.14 (mref c.92 14)))
          (call L.fun/any18003.14.23 fun/any18003.14))))
    (define L.fun/void18006.8.17
      (lambda (c.91)
        (let ((fun/void18007.12 (mref c.91 14)))
          (call L.fun/void18007.12.21 fun/void18007.12))))
    (define L.fun/ascii-char18008.7.16
      (lambda (c.90)
        (let ((fun/ascii-char18009.17 (mref c.90 14)))
          (call L.fun/ascii-char18009.17.26 fun/ascii-char18009.17))))
    (define L.fun/vector17998.6.15
      (lambda (c.89)
        (let ((fun/vector17999.5 (mref c.89 14)))
          (call L.fun/vector17999.5.14 fun/vector17999.5))))
    (define L.fun/vector17999.5.14
      (lambda (c.88)
        (let ((make-vector.76 (mref c.88 14)))
          (call L.make-vector.76.12 make-vector.76 64))))
    (define L.fun/vector18001.4.13
      (lambda (c.87)
        (let ((make-vector.76 (mref c.87 14)))
          (call L.make-vector.76.12 make-vector.76 64))))
    (define L.make-vector.76.12
      (lambda (c.86 tmp.52)
        (let ((make-init-vector.1 (mref c.86 14)))
          (if (!= (if (= (bitwise-and tmp.52 7) 0) 14 6) 6)
            (call L.make-init-vector.1.11 make-init-vector.1 tmp.52)
            2110))))
    (define L.make-init-vector.1.11
      (lambda (c.85 tmp.24)
        (let ((vector-init-loop.26 (mref c.85 14)))
          (let ((tmp.25
                 (let ((tmp.102
                        (+
                         (alloc (* (+ 1 (arithmetic-shift-right tmp.24 3)) 8))
                         3)))
                   (begin (mset! tmp.102 -3 tmp.24) tmp.102))))
            (call
             L.vector-init-loop.26.10
             vector-init-loop.26
             tmp.24
             0
             tmp.25)))))
    (define L.vector-init-loop.26.10
      (lambda (c.84 len.27 i.29 vec.28)
        (let ((vector-init-loop.26 (mref c.84 14)))
          (if (!= (if (= len.27 i.29) 14 6) 6)
            vec.28
            (begin
              (mset! vec.28 (+ (* (arithmetic-shift-right i.29 3) 8) 5) 0)
              (call
               L.vector-init-loop.26.10
               vector-init-loop.26
               len.27
               (+ i.29 8)
               vec.28))))))
    (define L.cons.77.9
      (lambda (c.83 tmp.71 tmp.72)
        (let ()
          (let ((tmp.103 (+ (alloc 16) 1)))
            (begin
              (mset! tmp.103 -1 tmp.71)
              (mset! tmp.103 7 tmp.72)
              tmp.103)))))
    (define L.vector?.78.8
      (lambda (c.82 tmp.68) (let () (if (= (bitwise-and tmp.68 7) 3) 14 6))))
    (define L.void?.79.7
      (lambda (c.81 tmp.64)
        (let () (if (= (bitwise-and tmp.64 255) 30) 14 6))))
    (let ((void?.79
           (let ((tmp.104 (+ (alloc 16) 2)))
             (begin
               (mset! tmp.104 -2 L.void?.79.7)
               (mset! tmp.104 6 8)
               tmp.104)))
          (vector?.78
           (let ((tmp.105 (+ (alloc 16) 2)))
             (begin
               (mset! tmp.105 -2 L.vector?.78.8)
               (mset! tmp.105 6 8)
               tmp.105)))
          (cons.77
           (let ((tmp.106 (+ (alloc 16) 2)))
             (begin
               (mset! tmp.106 -2 L.cons.77.9)
               (mset! tmp.106 6 16)
               tmp.106)))
          (vector-init-loop.26
           (let ((tmp.107 (+ (alloc 24) 2)))
             (begin
               (mset! tmp.107 -2 L.vector-init-loop.26.10)
               (mset! tmp.107 6 24)
               tmp.107)))
          (make-init-vector.1
           (let ((tmp.108 (+ (alloc 24) 2)))
             (begin
               (mset! tmp.108 -2 L.make-init-vector.1.11)
               (mset! tmp.108 6 8)
               tmp.108)))
          (make-vector.76
           (let ((tmp.109 (+ (alloc 24) 2)))
             (begin
               (mset! tmp.109 -2 L.make-vector.76.12)
               (mset! tmp.109 6 8)
               tmp.109)))
          (fun/vector18001.4
           (let ((tmp.110 (+ (alloc 24) 2)))
             (begin
               (mset! tmp.110 -2 L.fun/vector18001.4.13)
               (mset! tmp.110 6 0)
               tmp.110)))
          (fun/vector17999.5
           (let ((tmp.111 (+ (alloc 24) 2)))
             (begin
               (mset! tmp.111 -2 L.fun/vector17999.5.14)
               (mset! tmp.111 6 0)
               tmp.111)))
          (fun/vector17998.6
           (let ((tmp.112 (+ (alloc 24) 2)))
             (begin
               (mset! tmp.112 -2 L.fun/vector17998.6.15)
               (mset! tmp.112 6 0)
               tmp.112)))
          (fun/ascii-char18008.7
           (let ((tmp.113 (+ (alloc 24) 2)))
             (begin
               (mset! tmp.113 -2 L.fun/ascii-char18008.7.16)
               (mset! tmp.113 6 0)
               tmp.113)))
          (fun/void18006.8
           (let ((tmp.114 (+ (alloc 24) 2)))
             (begin
               (mset! tmp.114 -2 L.fun/void18006.8.17)
               (mset! tmp.114 6 0)
               tmp.114)))
          (fun/any18002.9
           (let ((tmp.115 (+ (alloc 24) 2)))
             (begin
               (mset! tmp.115 -2 L.fun/any18002.9.18)
               (mset! tmp.115 6 0)
               tmp.115)))
          (fun/empty17997.10
           (let ((tmp.116 (+ (alloc 16) 2)))
             (begin
               (mset! tmp.116 -2 L.fun/empty17997.10.19)
               (mset! tmp.116 6 0)
               tmp.116)))
          (fun/any18005.11
           (let ((tmp.117 (+ (alloc 16) 2)))
             (begin
               (mset! tmp.117 -2 L.fun/any18005.11.20)
               (mset! tmp.117 6 0)
               tmp.117)))
          (fun/void18007.12
           (let ((tmp.118 (+ (alloc 16) 2)))
             (begin
               (mset! tmp.118 -2 L.fun/void18007.12.21)
               (mset! tmp.118 6 0)
               tmp.118)))
          (fun/any18004.13
           (let ((tmp.119 (+ (alloc 24) 2)))
             (begin
               (mset! tmp.119 -2 L.fun/any18004.13.22)
               (mset! tmp.119 6 0)
               tmp.119)))
          (fun/any18003.14
           (let ((tmp.120 (+ (alloc 24) 2)))
             (begin
               (mset! tmp.120 -2 L.fun/any18003.14.23)
               (mset! tmp.120 6 0)
               tmp.120)))
          (fun/vector18000.15
           (let ((tmp.121 (+ (alloc 24) 2)))
             (begin
               (mset! tmp.121 -2 L.fun/vector18000.15.24)
               (mset! tmp.121 6 0)
               tmp.121)))
          (fun/empty17996.16
           (let ((tmp.122 (+ (alloc 24) 2)))
             (begin
               (mset! tmp.122 -2 L.fun/empty17996.16.25)
               (mset! tmp.122 6 0)
               tmp.122)))
          (fun/ascii-char18009.17
           (let ((tmp.123 (+ (alloc 16) 2)))
             (begin
               (mset! tmp.123 -2 L.fun/ascii-char18009.17.26)
               (mset! tmp.123 6 0)
               tmp.123))))
      (begin
        (mset! vector-init-loop.26 14 vector-init-loop.26)
        (mset! make-init-vector.1 14 vector-init-loop.26)
        (mset! make-vector.76 14 make-init-vector.1)
        (mset! fun/vector18001.4 14 make-vector.76)
        (mset! fun/vector17999.5 14 make-vector.76)
        (mset! fun/vector17998.6 14 fun/vector17999.5)
        (mset! fun/ascii-char18008.7 14 fun/ascii-char18009.17)
        (mset! fun/void18006.8 14 fun/void18007.12)
        (mset! fun/any18002.9 14 fun/any18003.14)
        (mset! fun/any18004.13 14 fun/any18005.11)
        (mset! fun/any18003.14 14 cons.77)
        (mset! fun/vector18000.15 14 fun/vector18001.4)
        (mset! fun/empty17996.16 14 fun/empty17997.10)
        (let ((procedure0.23
               (let ((lam.80
                      (let ((tmp.124 (+ (alloc 24) 2)))
                        (begin
                          (mset! tmp.124 -2 L.lam.80.27)
                          (mset! tmp.124 6 0)
                          tmp.124))))
                 (begin (mset! lam.80 14 fun/empty17996.16) lam.80)))
              (vector1.22 (call L.fun/vector17998.6.15 fun/vector17998.6))
              (vector2.21 (call L.fun/vector18000.15.24 fun/vector18000.15))
              (boolean3.20
               (call
                L.vector?.78.8
                vector?.78
                (call L.fun/any18002.9.18 fun/any18002.9)))
              (boolean4.19
               (call
                L.void?.79.7
                void?.79
                (call L.fun/any18004.13.22 fun/any18004.13)))
              (void5.18 (call L.fun/void18006.8.17 fun/void18006.8)))
          (call L.fun/ascii-char18008.7.16 fun/ascii-char18008.7))))))
(check-by-interp
 '(module
    (define L.fun/void18495.15.21 (lambda (c.91) (let () 30)))
    (define L.fun/void18488.14.20
      (lambda (c.90)
        (let ((fun/void18489.10 (mref c.90 14)))
          (call L.fun/void18489.10.16 fun/void18489.10))))
    (define L.fun/ascii-char18493.13.19 (lambda (c.89) (let () 20782)))
    (define L.fun/error18496.12.18
      (lambda (c.88)
        (let ((fun/error18497.6 (mref c.88 14)))
          (call L.fun/error18497.6.12 fun/error18497.6))))
    (define L.fun/empty18498.11.17
      (lambda (c.87)
        (let ((fun/empty18499.5 (mref c.87 14)))
          (call L.fun/empty18499.5.11 fun/empty18499.5))))
    (define L.fun/void18489.10.16 (lambda (c.86) (let () 30)))
    (define L.fun/void18494.9.15
      (lambda (c.85)
        (let ((fun/void18495.15 (mref c.85 14)))
          (call L.fun/void18495.15.21 fun/void18495.15))))
    (define L.fun/error18491.8.14 (lambda (c.84) (let () 47678)))
    (define L.fun/ascii-char18492.7.13
      (lambda (c.83)
        (let ((fun/ascii-char18493.13 (mref c.83 14)))
          (call L.fun/ascii-char18493.13.19 fun/ascii-char18493.13))))
    (define L.fun/error18497.6.12 (lambda (c.82) (let () 25150)))
    (define L.fun/empty18499.5.11 (lambda (c.81) (let () 22)))
    (define L.fun/error18490.4.10
      (lambda (c.80)
        (let ((fun/error18491.8 (mref c.80 14)))
          (call L.fun/error18491.8.14 fun/error18491.8))))
    (define L.*.74.9
      (lambda (c.79 tmp.36 tmp.37)
        (let ()
          (if (!= (if (= (bitwise-and tmp.37 7) 0) 14 6) 6)
            (if (!= (if (= (bitwise-and tmp.36 7) 0) 14 6) 6)
              (* tmp.36 (arithmetic-shift-right tmp.37 3))
              318)
            318))))
    (define L.-.75.8
      (lambda (c.78 tmp.40 tmp.41)
        (let ()
          (if (!= (if (= (bitwise-and tmp.41 7) 0) 14 6) 6)
            (if (!= (if (= (bitwise-and tmp.40 7) 0) 14 6) 6)
              (- tmp.40 tmp.41)
              830)
            830))))
    (define L.+.76.7
      (lambda (c.77 tmp.38 tmp.39)
        (let ()
          (if (!= (if (= (bitwise-and tmp.39 7) 0) 14 6) 6)
            (if (!= (if (= (bitwise-and tmp.38 7) 0) 14 6) 6)
              (+ tmp.38 tmp.39)
              574)
            574))))
    (let ((|+.76|
           (let ((tmp.92 (+ (alloc 16) 2)))
             (begin (mset! tmp.92 -2 L.+.76.7) (mset! tmp.92 6 16) tmp.92)))
          (|-.75|
           (let ((tmp.93 (+ (alloc 16) 2)))
             (begin (mset! tmp.93 -2 L.-.75.8) (mset! tmp.93 6 16) tmp.93)))
          (*.74
           (let ((tmp.94 (+ (alloc 16) 2)))
             (begin (mset! tmp.94 -2 L.*.74.9) (mset! tmp.94 6 16) tmp.94)))
          (fun/error18490.4
           (let ((tmp.95 (+ (alloc 24) 2)))
             (begin
               (mset! tmp.95 -2 L.fun/error18490.4.10)
               (mset! tmp.95 6 0)
               tmp.95)))
          (fun/empty18499.5
           (let ((tmp.96 (+ (alloc 16) 2)))
             (begin
               (mset! tmp.96 -2 L.fun/empty18499.5.11)
               (mset! tmp.96 6 0)
               tmp.96)))
          (fun/error18497.6
           (let ((tmp.97 (+ (alloc 16) 2)))
             (begin
               (mset! tmp.97 -2 L.fun/error18497.6.12)
               (mset! tmp.97 6 0)
               tmp.97)))
          (fun/ascii-char18492.7
           (let ((tmp.98 (+ (alloc 24) 2)))
             (begin
               (mset! tmp.98 -2 L.fun/ascii-char18492.7.13)
               (mset! tmp.98 6 0)
               tmp.98)))
          (fun/error18491.8
           (let ((tmp.99 (+ (alloc 16) 2)))
             (begin
               (mset! tmp.99 -2 L.fun/error18491.8.14)
               (mset! tmp.99 6 0)
               tmp.99)))
          (fun/void18494.9
           (let ((tmp.100 (+ (alloc 24) 2)))
             (begin
               (mset! tmp.100 -2 L.fun/void18494.9.15)
               (mset! tmp.100 6 0)
               tmp.100)))
          (fun/void18489.10
           (let ((tmp.101 (+ (alloc 16) 2)))
             (begin
               (mset! tmp.101 -2 L.fun/void18489.10.16)
               (mset! tmp.101 6 0)
               tmp.101)))
          (fun/empty18498.11
           (let ((tmp.102 (+ (alloc 24) 2)))
             (begin
               (mset! tmp.102 -2 L.fun/empty18498.11.17)
               (mset! tmp.102 6 0)
               tmp.102)))
          (fun/error18496.12
           (let ((tmp.103 (+ (alloc 24) 2)))
             (begin
               (mset! tmp.103 -2 L.fun/error18496.12.18)
               (mset! tmp.103 6 0)
               tmp.103)))
          (fun/ascii-char18493.13
           (let ((tmp.104 (+ (alloc 16) 2)))
             (begin
               (mset! tmp.104 -2 L.fun/ascii-char18493.13.19)
               (mset! tmp.104 6 0)
               tmp.104)))
          (fun/void18488.14
           (let ((tmp.105 (+ (alloc 24) 2)))
             (begin
               (mset! tmp.105 -2 L.fun/void18488.14.20)
               (mset! tmp.105 6 0)
               tmp.105)))
          (fun/void18495.15
           (let ((tmp.106 (+ (alloc 16) 2)))
             (begin
               (mset! tmp.106 -2 L.fun/void18495.15.21)
               (mset! tmp.106 6 0)
               tmp.106))))
      (begin
        (mset! fun/error18490.4 14 fun/error18491.8)
        (mset! fun/ascii-char18492.7 14 fun/ascii-char18493.13)
        (mset! fun/void18494.9 14 fun/void18495.15)
        (mset! fun/empty18498.11 14 fun/empty18499.5)
        (mset! fun/error18496.12 14 fun/error18497.6)
        (mset! fun/void18488.14 14 fun/void18489.10)
        (let ((void0.21 (call L.fun/void18488.14.20 fun/void18488.14))
              (error1.20 (call L.fun/error18490.4.10 fun/error18490.4))
              (fixnum2.19
               (call
                L.*.74.9
                *.74
                (call
                 L.-.75.8
                 |-.75|
                 (call
                  L.*.74.9
                  *.74
                  (call L.*.74.9 *.74 704 1000)
                  (call L.-.75.8 |-.75| 1760 1240))
                 (call
                  L.-.75.8
                  |-.75|
                  (call L.-.75.8 |-.75| 1152 1792)
                  (call L.*.74.9 *.74 1488 992)))
                (call
                 L.-.75.8
                 |-.75|
                 (call
                  L.-.75.8
                  |-.75|
                  (call L.-.75.8 |-.75| 776 1520)
                  (call L.*.74.9 *.74 1688 1176))
                 (call
                  L.+.76.7
                  |+.76|
                  (call L.*.74.9 *.74 1400 1224)
                  (call L.*.74.9 *.74 1008 1272)))))
              (ascii-char3.18
               (call L.fun/ascii-char18492.7.13 fun/ascii-char18492.7))
              (void4.17 (call L.fun/void18494.9.15 fun/void18494.9))
              (error5.16 (call L.fun/error18496.12.18 fun/error18496.12)))
          (call L.fun/empty18498.11.17 fun/empty18498.11))))))
(check-by-interp
 '(module
    (define L.fun/ascii-char22594.17.21
      (lambda (c.91)
        (let ((fun/ascii-char22595.5 (mref c.91 14)))
          (call L.fun/ascii-char22595.5.9 fun/ascii-char22595.5))))
    (define L.fun/empty22596.16.20
      (lambda (c.90)
        (let ((fun/empty22597.10 (mref c.90 14)))
          (call L.fun/empty22597.10.14 fun/empty22597.10))))
    (define L.fun/empty22598.15.19
      (lambda (c.89)
        (let ((fun/empty22599.8 (mref c.89 14)))
          (call L.fun/empty22599.8.12 fun/empty22599.8))))
    (define L.fun/error22592.14.18
      (lambda (c.88)
        (let ((fun/error22593.12 (mref c.88 14)))
          (call L.fun/error22593.12.16 fun/error22593.12))))
    (define L.fun/pair22600.13.17
      (lambda (c.87)
        (let ((fun/pair22601.6 (mref c.87 14)))
          (call L.fun/pair22601.6.10 fun/pair22601.6))))
    (define L.fun/error22593.12.16 (lambda (c.86) (let () 5694)))
    (define L.fun/ascii-char22588.11.15
      (lambda (c.85)
        (let ((fun/ascii-char22589.7 (mref c.85 14)))
          (call L.fun/ascii-char22589.7.11 fun/ascii-char22589.7))))
    (define L.fun/empty22597.10.14 (lambda (c.84) (let () 22)))
    (define L.fun/empty22591.9.13 (lambda (c.83) (let () 22)))
    (define L.fun/empty22599.8.12 (lambda (c.82) (let () 22)))
    (define L.fun/ascii-char22589.7.11 (lambda (c.81) (let () 23342)))
    (define L.fun/pair22601.6.10
      (lambda (c.80)
        (let ((cons.76 (mref c.80 14))) (call L.cons.76.7 cons.76 800 3704))))
    (define L.fun/ascii-char22595.5.9 (lambda (c.79) (let () 25134)))
    (define L.fun/empty22590.4.8
      (lambda (c.78)
        (let ((fun/empty22591.9 (mref c.78 14)))
          (call L.fun/empty22591.9.13 fun/empty22591.9))))
    (define L.cons.76.7
      (lambda (c.77 tmp.71 tmp.72)
        (let ()
          (let ((tmp.92 (+ (alloc 16) 1)))
            (begin (mset! tmp.92 -1 tmp.71) (mset! tmp.92 7 tmp.72) tmp.92)))))
    (let ((cons.76
           (let ((tmp.93 (+ (alloc 16) 2)))
             (begin (mset! tmp.93 -2 L.cons.76.7) (mset! tmp.93 6 16) tmp.93)))
          (fun/empty22590.4
           (let ((tmp.94 (+ (alloc 24) 2)))
             (begin
               (mset! tmp.94 -2 L.fun/empty22590.4.8)
               (mset! tmp.94 6 0)
               tmp.94)))
          (fun/ascii-char22595.5
           (let ((tmp.95 (+ (alloc 16) 2)))
             (begin
               (mset! tmp.95 -2 L.fun/ascii-char22595.5.9)
               (mset! tmp.95 6 0)
               tmp.95)))
          (fun/pair22601.6
           (let ((tmp.96 (+ (alloc 24) 2)))
             (begin
               (mset! tmp.96 -2 L.fun/pair22601.6.10)
               (mset! tmp.96 6 0)
               tmp.96)))
          (fun/ascii-char22589.7
           (let ((tmp.97 (+ (alloc 16) 2)))
             (begin
               (mset! tmp.97 -2 L.fun/ascii-char22589.7.11)
               (mset! tmp.97 6 0)
               tmp.97)))
          (fun/empty22599.8
           (let ((tmp.98 (+ (alloc 16) 2)))
             (begin
               (mset! tmp.98 -2 L.fun/empty22599.8.12)
               (mset! tmp.98 6 0)
               tmp.98)))
          (fun/empty22591.9
           (let ((tmp.99 (+ (alloc 16) 2)))
             (begin
               (mset! tmp.99 -2 L.fun/empty22591.9.13)
               (mset! tmp.99 6 0)
               tmp.99)))
          (fun/empty22597.10
           (let ((tmp.100 (+ (alloc 16) 2)))
             (begin
               (mset! tmp.100 -2 L.fun/empty22597.10.14)
               (mset! tmp.100 6 0)
               tmp.100)))
          (fun/ascii-char22588.11
           (let ((tmp.101 (+ (alloc 24) 2)))
             (begin
               (mset! tmp.101 -2 L.fun/ascii-char22588.11.15)
               (mset! tmp.101 6 0)
               tmp.101)))
          (fun/error22593.12
           (let ((tmp.102 (+ (alloc 16) 2)))
             (begin
               (mset! tmp.102 -2 L.fun/error22593.12.16)
               (mset! tmp.102 6 0)
               tmp.102)))
          (fun/pair22600.13
           (let ((tmp.103 (+ (alloc 24) 2)))
             (begin
               (mset! tmp.103 -2 L.fun/pair22600.13.17)
               (mset! tmp.103 6 0)
               tmp.103)))
          (fun/error22592.14
           (let ((tmp.104 (+ (alloc 24) 2)))
             (begin
               (mset! tmp.104 -2 L.fun/error22592.14.18)
               (mset! tmp.104 6 0)
               tmp.104)))
          (fun/empty22598.15
           (let ((tmp.105 (+ (alloc 24) 2)))
             (begin
               (mset! tmp.105 -2 L.fun/empty22598.15.19)
               (mset! tmp.105 6 0)
               tmp.105)))
          (fun/empty22596.16
           (let ((tmp.106 (+ (alloc 24) 2)))
             (begin
               (mset! tmp.106 -2 L.fun/empty22596.16.20)
               (mset! tmp.106 6 0)
               tmp.106)))
          (fun/ascii-char22594.17
           (let ((tmp.107 (+ (alloc 24) 2)))
             (begin
               (mset! tmp.107 -2 L.fun/ascii-char22594.17.21)
               (mset! tmp.107 6 0)
               tmp.107))))
      (begin
        (mset! fun/empty22590.4 14 fun/empty22591.9)
        (mset! fun/pair22601.6 14 cons.76)
        (mset! fun/ascii-char22588.11 14 fun/ascii-char22589.7)
        (mset! fun/pair22600.13 14 fun/pair22601.6)
        (mset! fun/error22592.14 14 fun/error22593.12)
        (mset! fun/empty22598.15 14 fun/empty22599.8)
        (mset! fun/empty22596.16 14 fun/empty22597.10)
        (mset! fun/ascii-char22594.17 14 fun/ascii-char22595.5)
        (let ((ascii-char0.23
               (call L.fun/ascii-char22588.11.15 fun/ascii-char22588.11))
              (empty1.22 (call L.fun/empty22590.4.8 fun/empty22590.4))
              (error2.21 (call L.fun/error22592.14.18 fun/error22592.14))
              (ascii-char3.20
               (call L.fun/ascii-char22594.17.21 fun/ascii-char22594.17))
              (empty4.19 (call L.fun/empty22596.16.20 fun/empty22596.16))
              (empty5.18 (call L.fun/empty22598.15.19 fun/empty22598.15)))
          (call L.fun/pair22600.13.17 fun/pair22600.13))))))
(check-by-interp
 '(module
    (define L.lam.76.21
      (lambda (c.91)
        (let ((fun/void23352.11 (mref c.91 14)))
          (call L.fun/void23352.11.19 fun/void23352.11))))
    (define L.lam.75.20
      (lambda (c.90)
        (let ((*.74 (mref c.90 14))
              (|-.72| (mref c.90 22))
              (|+.73| (mref c.90 30)))
          (call
           L.+.73.8
           |+.73|
           (call
            L.+.73.8
            |+.73|
            (call
             L.+.73.8
             |+.73|
             (call L.-.72.9 |-.72| 1912 944)
             (call L.-.72.9 |-.72| 304 1224))
            (call
             L.+.73.8
             |+.73|
             (call L.*.74.7 *.74 1024 1432)
             (call L.-.72.9 |-.72| 1664 1736)))
           (call
            L.-.72.9
            |-.72|
            (call
             L.+.73.8
             |+.73|
             (call L.-.72.9 |-.72| 968 1216)
             (call L.*.74.7 *.74 1696 64))
            (call
             L.*.74.7
             *.74
             (call L.*.74.7 *.74 1400 656)
             (call L.-.72.9 |-.72| 416 1432)))))))
    (define L.fun/void23352.11.19
      (lambda (c.89)
        (let ((fun/void23353.10 (mref c.89 14)))
          (call L.fun/void23353.10.18 fun/void23353.10))))
    (define L.fun/void23353.10.18 (lambda (c.88) (let () 30)))
    (define L.fun/ascii-char23346.9.17
      (lambda (c.87)
        (let ((fun/ascii-char23347.8 (mref c.87 14)))
          (call L.fun/ascii-char23347.8.16 fun/ascii-char23347.8))))
    (define L.fun/ascii-char23347.8.16 (lambda (c.86) (let () 23598)))
    (define L.fun/any23350.7.15
      (lambda (c.85)
        (let ((fun/any23351.5 (mref c.85 14)))
          (call L.fun/any23351.5.13 fun/any23351.5))))
    (define L.fun/void23348.6.14
      (lambda (c.84)
        (let ((fun/void23349.4 (mref c.84 14)))
          (call L.fun/void23349.4.12 fun/void23349.4))))
    (define L.fun/any23351.5.13
      (lambda (c.83)
        (let ((cons.70 (mref c.83 14)))
          (call L.cons.70.11 cons.70 1272 3184))))
    (define L.fun/void23349.4.12 (lambda (c.82) (let () 30)))
    (define L.cons.70.11
      (lambda (c.81 tmp.65 tmp.66)
        (let ()
          (let ((tmp.92 (+ (alloc 16) 1)))
            (begin (mset! tmp.92 -1 tmp.65) (mset! tmp.92 7 tmp.66) tmp.92)))))
    (define L.boolean?.71.10
      (lambda (c.80 tmp.56) (let () (if (= (bitwise-and tmp.56 247) 6) 14 6))))
    (define L.-.72.9
      (lambda (c.79 tmp.36 tmp.37)
        (let ()
          (if (!= (if (= (bitwise-and tmp.37 7) 0) 14 6) 6)
            (if (!= (if (= (bitwise-and tmp.36 7) 0) 14 6) 6)
              (- tmp.36 tmp.37)
              830)
            830))))
    (define L.+.73.8
      (lambda (c.78 tmp.34 tmp.35)
        (let ()
          (if (!= (if (= (bitwise-and tmp.35 7) 0) 14 6) 6)
            (if (!= (if (= (bitwise-and tmp.34 7) 0) 14 6) 6)
              (+ tmp.34 tmp.35)
              574)
            574))))
    (define L.*.74.7
      (lambda (c.77 tmp.32 tmp.33)
        (let ()
          (if (!= (if (= (bitwise-and tmp.33 7) 0) 14 6) 6)
            (if (!= (if (= (bitwise-and tmp.32 7) 0) 14 6) 6)
              (* tmp.32 (arithmetic-shift-right tmp.33 3))
              318)
            318))))
    (let ((*.74
           (let ((tmp.93 (+ (alloc 16) 2)))
             (begin (mset! tmp.93 -2 L.*.74.7) (mset! tmp.93 6 16) tmp.93)))
          (|+.73|
           (let ((tmp.94 (+ (alloc 16) 2)))
             (begin (mset! tmp.94 -2 L.+.73.8) (mset! tmp.94 6 16) tmp.94)))
          (|-.72|
           (let ((tmp.95 (+ (alloc 16) 2)))
             (begin (mset! tmp.95 -2 L.-.72.9) (mset! tmp.95 6 16) tmp.95)))
          (boolean?.71
           (let ((tmp.96 (+ (alloc 16) 2)))
             (begin
               (mset! tmp.96 -2 L.boolean?.71.10)
               (mset! tmp.96 6 8)
               tmp.96)))
          (cons.70
           (let ((tmp.97 (+ (alloc 16) 2)))
             (begin
               (mset! tmp.97 -2 L.cons.70.11)
               (mset! tmp.97 6 16)
               tmp.97)))
          (fun/void23349.4
           (let ((tmp.98 (+ (alloc 16) 2)))
             (begin
               (mset! tmp.98 -2 L.fun/void23349.4.12)
               (mset! tmp.98 6 0)
               tmp.98)))
          (fun/any23351.5
           (let ((tmp.99 (+ (alloc 24) 2)))
             (begin
               (mset! tmp.99 -2 L.fun/any23351.5.13)
               (mset! tmp.99 6 0)
               tmp.99)))
          (fun/void23348.6
           (let ((tmp.100 (+ (alloc 24) 2)))
             (begin
               (mset! tmp.100 -2 L.fun/void23348.6.14)
               (mset! tmp.100 6 0)
               tmp.100)))
          (fun/any23350.7
           (let ((tmp.101 (+ (alloc 24) 2)))
             (begin
               (mset! tmp.101 -2 L.fun/any23350.7.15)
               (mset! tmp.101 6 0)
               tmp.101)))
          (fun/ascii-char23347.8
           (let ((tmp.102 (+ (alloc 16) 2)))
             (begin
               (mset! tmp.102 -2 L.fun/ascii-char23347.8.16)
               (mset! tmp.102 6 0)
               tmp.102)))
          (fun/ascii-char23346.9
           (let ((tmp.103 (+ (alloc 24) 2)))
             (begin
               (mset! tmp.103 -2 L.fun/ascii-char23346.9.17)
               (mset! tmp.103 6 0)
               tmp.103)))
          (fun/void23353.10
           (let ((tmp.104 (+ (alloc 16) 2)))
             (begin
               (mset! tmp.104 -2 L.fun/void23353.10.18)
               (mset! tmp.104 6 0)
               tmp.104)))
          (fun/void23352.11
           (let ((tmp.105 (+ (alloc 24) 2)))
             (begin
               (mset! tmp.105 -2 L.fun/void23352.11.19)
               (mset! tmp.105 6 0)
               tmp.105))))
      (begin
        (mset! fun/any23351.5 14 cons.70)
        (mset! fun/void23348.6 14 fun/void23349.4)
        (mset! fun/any23350.7 14 fun/any23351.5)
        (mset! fun/ascii-char23346.9 14 fun/ascii-char23347.8)
        (mset! fun/void23352.11 14 fun/void23353.10)
        (let ((ascii-char0.17
               (call L.fun/ascii-char23346.9.17 fun/ascii-char23346.9))
              (void1.16 (call L.fun/void23348.6.14 fun/void23348.6))
              (boolean2.15
               (call
                L.boolean?.71.10
                boolean?.71
                (call L.fun/any23350.7.15 fun/any23350.7)))
              (procedure3.14
               (let ((lam.75
                      (let ((tmp.106 (+ (alloc 40) 2)))
                        (begin
                          (mset! tmp.106 -2 L.lam.75.20)
                          (mset! tmp.106 6 0)
                          tmp.106))))
                 (begin
                   (mset! lam.75 14 *.74)
                   (mset! lam.75 22 |-.72|)
                   (mset! lam.75 30 |+.73|)
                   lam.75)))
              (fixnum4.13
               (call
                L.*.74.7
                *.74
                (call
                 L.-.72.9
                 |-.72|
                 (call
                  L.*.74.7
                  *.74
                  (call L.-.72.9 |-.72| 800 640)
                  (call L.+.73.8 |+.73| 320 744))
                 (call
                  L.+.73.8
                  |+.73|
                  (call L.-.72.9 |-.72| 1304 736)
                  (call L.-.72.9 |-.72| 1840 824)))
                (call
                 L.-.72.9
                 |-.72|
                 (call
                  L.-.72.9
                  |-.72|
                  (call L.-.72.9 |-.72| 376 488)
                  (call L.-.72.9 |-.72| 1112 192))
                 (call
                  L.+.73.8
                  |+.73|
                  (call L.*.74.7 *.74 824 1056)
                  (call L.+.73.8 |+.73| 1120 760)))))
              (procedure5.12
               (let ((lam.76
                      (let ((tmp.107 (+ (alloc 24) 2)))
                        (begin
                          (mset! tmp.107 -2 L.lam.76.21)
                          (mset! tmp.107 6 0)
                          tmp.107))))
                 (begin (mset! lam.76 14 fun/void23352.11) lam.76))))
          (call
           L.-.72.9
           |-.72|
           (call
            L.*.74.7
            *.74
            (if (!= (if (= (bitwise-and procedure3.14 7) 2) 14 6) 6)
              (if (!= (if (= (mref procedure3.14 6) 0) 14 6) 6)
                (call (mref procedure3.14 -2) procedure3.14)
                10814)
              11070)
            (if (!= (if (= (bitwise-and procedure3.14 7) 2) 14 6) 6)
              (if (!= (if (= (mref procedure3.14 6) 0) 14 6) 6)
                (call (mref procedure3.14 -2) procedure3.14)
                10814)
              11070))
           (call
            L.+.73.8
            |+.73|
            (call
             L.*.74.7
             *.74
             (call L.*.74.7 *.74 840 1808)
             (call L.+.73.8 |+.73| 344 648))
            (call
             L.+.73.8
             |+.73|
             (call L.*.74.7 *.74 1960 1160)
             (call L.*.74.7 *.74 872 1568)))))))))
(check-by-interp
 '(module
    (define L.lam.80.27
      (lambda (c.101)
        (let ((fun/void24631.10 (mref c.101 14)))
          (call L.fun/void24631.10.20 fun/void24631.10))))
    (define L.lam.79.26
      (lambda (c.100)
        (let ((fun/empty24629.7 (mref c.100 14)))
          (call L.fun/empty24629.7.17 fun/empty24629.7))))
    (define L.fun/vector24626.15.25
      (lambda (c.99)
        (let ((make-vector.74 (mref c.99 14)))
          (call L.make-vector.74.13 make-vector.74 64))))
    (define L.fun/any24627.14.24
      (lambda (c.98)
        (let ((fun/any24628.5 (mref c.98 14)))
          (call L.fun/any24628.5.15 fun/any24628.5))))
    (define L.fun/error24635.13.23
      (lambda (c.97)
        (let ((fun/error24636.8 (mref c.97 14)))
          (call L.fun/error24636.8.18 fun/error24636.8))))
    (define L.fun/error24634.12.22 (lambda (c.96) (let () 19006)))
    (define L.fun/empty24630.11.21 (lambda (c.95) (let () 22)))
    (define L.fun/void24631.10.20
      (lambda (c.94)
        (let ((fun/void24632.9 (mref c.94 14)))
          (call L.fun/void24632.9.19 fun/void24632.9))))
    (define L.fun/void24632.9.19 (lambda (c.93) (let () 30)))
    (define L.fun/error24636.8.18 (lambda (c.92) (let () 52542)))
    (define L.fun/empty24629.7.17
      (lambda (c.91)
        (let ((fun/empty24630.11 (mref c.91 14)))
          (call L.fun/empty24630.11.21 fun/empty24630.11))))
    (define L.fun/error24633.6.16
      (lambda (c.90)
        (let ((fun/error24634.12 (mref c.90 14)))
          (call L.fun/error24634.12.22 fun/error24634.12))))
    (define L.fun/any24628.5.15 (lambda (c.89) (let () 22)))
    (define L.fun/vector24625.4.14
      (lambda (c.88)
        (let ((fun/vector24626.15 (mref c.88 14)))
          (call L.fun/vector24626.15.25 fun/vector24626.15))))
    (define L.make-vector.74.13
      (lambda (c.87 tmp.50)
        (let ((make-init-vector.1 (mref c.87 14)))
          (if (!= (if (= (bitwise-and tmp.50 7) 0) 14 6) 6)
            (call L.make-init-vector.1.12 make-init-vector.1 tmp.50)
            2110))))
    (define L.make-init-vector.1.12
      (lambda (c.86 tmp.22)
        (let ((vector-init-loop.24 (mref c.86 14)))
          (let ((tmp.23
                 (let ((tmp.102
                        (+
                         (alloc (* (+ 1 (arithmetic-shift-right tmp.22 3)) 8))
                         3)))
                   (begin (mset! tmp.102 -3 tmp.22) tmp.102))))
            (call
             L.vector-init-loop.24.11
             vector-init-loop.24
             tmp.22
             0
             tmp.23)))))
    (define L.vector-init-loop.24.11
      (lambda (c.85 len.25 i.27 vec.26)
        (let ((vector-init-loop.24 (mref c.85 14)))
          (if (!= (if (= len.25 i.27) 14 6) 6)
            vec.26
            (begin
              (mset! vec.26 (+ (* (arithmetic-shift-right i.27 3) 8) 5) 0)
              (call
               L.vector-init-loop.24.11
               vector-init-loop.24
               len.25
               (+ i.27 8)
               vec.26))))))
    (define L.*.75.10
      (lambda (c.84 tmp.36 tmp.37)
        (let ()
          (if (!= (if (= (bitwise-and tmp.37 7) 0) 14 6) 6)
            (if (!= (if (= (bitwise-and tmp.36 7) 0) 14 6) 6)
              (* tmp.36 (arithmetic-shift-right tmp.37 3))
              318)
            318))))
    (define L.+.76.9
      (lambda (c.83 tmp.38 tmp.39)
        (let ()
          (if (!= (if (= (bitwise-and tmp.39 7) 0) 14 6) 6)
            (if (!= (if (= (bitwise-and tmp.38 7) 0) 14 6) 6)
              (+ tmp.38 tmp.39)
              574)
            574))))
    (define L.-.77.8
      (lambda (c.82 tmp.40 tmp.41)
        (let ()
          (if (!= (if (= (bitwise-and tmp.41 7) 0) 14 6) 6)
            (if (!= (if (= (bitwise-and tmp.40 7) 0) 14 6) 6)
              (- tmp.40 tmp.41)
              830)
            830))))
    (define L.empty?.78.7
      (lambda (c.81 tmp.61)
        (let () (if (= (bitwise-and tmp.61 255) 22) 14 6))))
    (let ((empty?.78
           (let ((tmp.103 (+ (alloc 16) 2)))
             (begin
               (mset! tmp.103 -2 L.empty?.78.7)
               (mset! tmp.103 6 8)
               tmp.103)))
          (|-.77|
           (let ((tmp.104 (+ (alloc 16) 2)))
             (begin (mset! tmp.104 -2 L.-.77.8) (mset! tmp.104 6 16) tmp.104)))
          (|+.76|
           (let ((tmp.105 (+ (alloc 16) 2)))
             (begin (mset! tmp.105 -2 L.+.76.9) (mset! tmp.105 6 16) tmp.105)))
          (*.75
           (let ((tmp.106 (+ (alloc 16) 2)))
             (begin
               (mset! tmp.106 -2 L.*.75.10)
               (mset! tmp.106 6 16)
               tmp.106)))
          (vector-init-loop.24
           (let ((tmp.107 (+ (alloc 24) 2)))
             (begin
               (mset! tmp.107 -2 L.vector-init-loop.24.11)
               (mset! tmp.107 6 24)
               tmp.107)))
          (make-init-vector.1
           (let ((tmp.108 (+ (alloc 24) 2)))
             (begin
               (mset! tmp.108 -2 L.make-init-vector.1.12)
               (mset! tmp.108 6 8)
               tmp.108)))
          (make-vector.74
           (let ((tmp.109 (+ (alloc 24) 2)))
             (begin
               (mset! tmp.109 -2 L.make-vector.74.13)
               (mset! tmp.109 6 8)
               tmp.109)))
          (fun/vector24625.4
           (let ((tmp.110 (+ (alloc 24) 2)))
             (begin
               (mset! tmp.110 -2 L.fun/vector24625.4.14)
               (mset! tmp.110 6 0)
               tmp.110)))
          (fun/any24628.5
           (let ((tmp.111 (+ (alloc 16) 2)))
             (begin
               (mset! tmp.111 -2 L.fun/any24628.5.15)
               (mset! tmp.111 6 0)
               tmp.111)))
          (fun/error24633.6
           (let ((tmp.112 (+ (alloc 24) 2)))
             (begin
               (mset! tmp.112 -2 L.fun/error24633.6.16)
               (mset! tmp.112 6 0)
               tmp.112)))
          (fun/empty24629.7
           (let ((tmp.113 (+ (alloc 24) 2)))
             (begin
               (mset! tmp.113 -2 L.fun/empty24629.7.17)
               (mset! tmp.113 6 0)
               tmp.113)))
          (fun/error24636.8
           (let ((tmp.114 (+ (alloc 16) 2)))
             (begin
               (mset! tmp.114 -2 L.fun/error24636.8.18)
               (mset! tmp.114 6 0)
               tmp.114)))
          (fun/void24632.9
           (let ((tmp.115 (+ (alloc 16) 2)))
             (begin
               (mset! tmp.115 -2 L.fun/void24632.9.19)
               (mset! tmp.115 6 0)
               tmp.115)))
          (fun/void24631.10
           (let ((tmp.116 (+ (alloc 24) 2)))
             (begin
               (mset! tmp.116 -2 L.fun/void24631.10.20)
               (mset! tmp.116 6 0)
               tmp.116)))
          (fun/empty24630.11
           (let ((tmp.117 (+ (alloc 16) 2)))
             (begin
               (mset! tmp.117 -2 L.fun/empty24630.11.21)
               (mset! tmp.117 6 0)
               tmp.117)))
          (fun/error24634.12
           (let ((tmp.118 (+ (alloc 16) 2)))
             (begin
               (mset! tmp.118 -2 L.fun/error24634.12.22)
               (mset! tmp.118 6 0)
               tmp.118)))
          (fun/error24635.13
           (let ((tmp.119 (+ (alloc 24) 2)))
             (begin
               (mset! tmp.119 -2 L.fun/error24635.13.23)
               (mset! tmp.119 6 0)
               tmp.119)))
          (fun/any24627.14
           (let ((tmp.120 (+ (alloc 24) 2)))
             (begin
               (mset! tmp.120 -2 L.fun/any24627.14.24)
               (mset! tmp.120 6 0)
               tmp.120)))
          (fun/vector24626.15
           (let ((tmp.121 (+ (alloc 24) 2)))
             (begin
               (mset! tmp.121 -2 L.fun/vector24626.15.25)
               (mset! tmp.121 6 0)
               tmp.121))))
      (begin
        (mset! vector-init-loop.24 14 vector-init-loop.24)
        (mset! make-init-vector.1 14 vector-init-loop.24)
        (mset! make-vector.74 14 make-init-vector.1)
        (mset! fun/vector24625.4 14 fun/vector24626.15)
        (mset! fun/error24633.6 14 fun/error24634.12)
        (mset! fun/empty24629.7 14 fun/empty24630.11)
        (mset! fun/void24631.10 14 fun/void24632.9)
        (mset! fun/error24635.13 14 fun/error24636.8)
        (mset! fun/any24627.14 14 fun/any24628.5)
        (mset! fun/vector24626.15 14 make-vector.74)
        (let ((fixnum0.21
               (call
                L.-.77.8
                |-.77|
                (call
                 L.*.75.10
                 *.75
                 (call
                  L.+.76.9
                  |+.76|
                  (call L.*.75.10 *.75 1184 1160)
                  (call L.*.75.10 *.75 1808 352))
                 (call
                  L.*.75.10
                  *.75
                  (call L.+.76.9 |+.76| 520 1360)
                  (call L.-.77.8 |-.77| 1032 1168)))
                (call
                 L.+.76.9
                 |+.76|
                 (call
                  L.+.76.9
                  |+.76|
                  (call L.+.76.9 |+.76| 192 1512)
                  (call L.-.77.8 |-.77| 880 640))
                 (call
                  L.+.76.9
                  |+.76|
                  (call L.-.77.8 |-.77| 1528 2008)
                  (call L.-.77.8 |-.77| 624 1656)))))
              (vector1.20 (call L.fun/vector24625.4.14 fun/vector24625.4))
              (boolean2.19
               (call
                L.empty?.78.7
                empty?.78
                (call L.fun/any24627.14.24 fun/any24627.14)))
              (procedure3.18
               (let ((lam.79
                      (let ((tmp.122 (+ (alloc 24) 2)))
                        (begin
                          (mset! tmp.122 -2 L.lam.79.26)
                          (mset! tmp.122 6 0)
                          tmp.122))))
                 (begin (mset! lam.79 14 fun/empty24629.7) lam.79)))
              (procedure4.17
               (let ((lam.80
                      (let ((tmp.123 (+ (alloc 24) 2)))
                        (begin
                          (mset! tmp.123 -2 L.lam.80.27)
                          (mset! tmp.123 6 0)
                          tmp.123))))
                 (begin (mset! lam.80 14 fun/void24631.10) lam.80)))
              (error5.16 (call L.fun/error24633.6.16 fun/error24633.6)))
          (call L.fun/error24635.13.23 fun/error24635.13))))))
