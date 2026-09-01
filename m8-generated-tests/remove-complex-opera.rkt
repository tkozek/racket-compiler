#lang racket
(require rackunit
         cpsc411/compiler-lib
         cpsc411/ptr-run-time
         cpsc411/langs/v8
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

(check-by-interp '(module 30))
(check-by-interp
 '(module
    (define L.cons.5
      (lambda (tmp.46 tmp.47)
        (let ((tmp.50 (+ (alloc 16) 1)))
          (begin (mset! tmp.50 -1 tmp.46) (mset! tmp.50 7 tmp.47) tmp.50))))
    (call L.cons.5 1808 3816)))
(check-by-interp '(module (let ((ascii-char0.1 27438)) 22)))
(check-by-interp '(module (let ((void0.1 30)) 31790)))
(check-by-interp
 '(module
    (define L.cons.5
      (lambda (tmp.47 tmp.48)
        (let ((tmp.51 (+ (alloc 16) 1)))
          (begin (mset! tmp.51 -1 tmp.47) (mset! tmp.51 7 tmp.48) tmp.51))))
    (let ((void0.1 30)) (call L.cons.5 1624 3704))))
(check-by-interp
 '(module
    (define L.fun/fixnum8389.4 (lambda () 1672))
    (call L.fun/fixnum8389.4)))
(check-by-interp '(module (let ((boolean0.2 6) (void1.1 30)) 30)))
(check-by-interp
 '(module
    (define L.fun/fixnum8394.4 (lambda (oprand0.1) 312))
    (call L.fun/fixnum8394.4 (if (!= 14 6) 15934 45118))))
(check-by-interp
 '(module
    (define L.fun/error8401.4 (lambda (oprand0.1) 1854))
    (define L.fun/void8402.5 (lambda (oprand0.2) 30))
    (call L.fun/error8401.4 (call L.fun/void8402.5 22))))
(check-by-interp
 '(module
    (define L.cons.5
      (lambda (tmp.48 tmp.49)
        (let ((tmp.52 (+ (alloc 16) 1)))
          (begin (mset! tmp.52 -1 tmp.48) (mset! tmp.52 7 tmp.49) tmp.52))))
    (let ((ascii-char0.2 18222) (pair1.1 (call L.cons.5 832 2272)))
      ascii-char0.2)))
(check-by-interp
 '(module
    (define L.cons.6
      (lambda (tmp.47 tmp.48)
        (let ((tmp.51 (+ (alloc 16) 1)))
          (begin (mset! tmp.51 -1 tmp.47) (mset! tmp.51 7 tmp.48) tmp.51))))
    (define L.fun/pair8407.4 (lambda (oprand0.1) (call L.cons.6 400 3872)))
    (call L.fun/pair8407.4 (if (!= 14 6) 17454 17966))))
(check-by-interp '(module (let ((fixnum0.2 1712) (boolean1.1 14)) 1864)))
(check-by-interp '(module (let ((error0.2 13118) (boolean1.1 14)) boolean1.1)))
(check-by-interp
 '(module
    (define L.cons.8
      (lambda (tmp.52 tmp.53)
        (let ((tmp.56 (+ (alloc 16) 1)))
          (begin (mset! tmp.56 -1 tmp.52) (mset! tmp.56 7 tmp.53) tmp.56))))
    (define L.fun/error8419.4 (lambda (oprand0.2 oprand1.1) 47678))
    (define L.fun/boolean8418.5 (lambda (oprand0.4 oprand1.3) 6))
    (define L.fun/error8420.6 (lambda (oprand0.6 oprand1.5) 39998))
    (if (!= (call L.fun/boolean8418.5 14 456) 6)
      (call L.fun/error8419.4 14 22)
      (call L.fun/error8420.6 22 (call L.cons.8 208 3240)))))
(check-by-interp
 '(module
    (define L.+.9
      (lambda (tmp.19 tmp.20)
        (if (!= (if (= (bitwise-and tmp.20 7) 0) 14 6) 6)
          (if (!= (if (= (bitwise-and tmp.19 7) 0) 14 6) 6)
            (+ tmp.19 tmp.20)
            574)
          574)))
    (define L.cons.8
      (lambda (tmp.49 tmp.50)
        (let ((tmp.53 (+ (alloc 16) 1)))
          (begin (mset! tmp.53 -1 tmp.49) (mset! tmp.53 7 tmp.50) tmp.53))))
    (define L.fun/ascii-char8439.4 (lambda () 22318))
    (define L.fun/error8440.5 (lambda () 4670))
    (define L.fun/pair8441.6 (lambda () (call L.cons.8 704 2392)))
    (let ((ascii-char0.3 (call L.fun/ascii-char8439.4))
          (error1.2 (call L.fun/error8440.5))
          (pair2.1 (call L.fun/pair8441.6)))
      (call L.+.9 2024 1064))))
(check-by-interp
 '(module
    (define L.empty?.8
      (lambda (tmp.41) (if (= (bitwise-and tmp.41 255) 22) 14 6)))
    (define L.cons.7
      (lambda (tmp.48 tmp.49)
        (let ((tmp.52 (+ (alloc 16) 1)))
          (begin (mset! tmp.52 -1 tmp.48) (mset! tmp.52 7 tmp.49) tmp.52))))
    (define L.fun/pair8459.4 (lambda () (call L.cons.7 704 2824)))
    (define L.fun/pair8458.5
      (lambda (oprand0.2 oprand1.1) (call L.fun/pair8459.4)))
    (call
     L.fun/pair8458.5
     (call L.empty?.8 (if (!= 6 6) 54078 38718))
     (if (!= 6 6) 30 30))))
(check-by-interp
 '(module
    (define L.pair?.8 (lambda (tmp.46) (if (= (bitwise-and tmp.46 7) 1) 14 6)))
    (define L.fun/ascii-char8463.4 (lambda () 22574))
    (define L.fun/ascii-char8462.5 (lambda () 10286))
    (define L.fun/error8464.6 (lambda () 5694))
    (let ((ascii-char0.3 (call L.fun/ascii-char8462.5))
          (ascii-char1.2 (call L.fun/ascii-char8463.4))
          (boolean2.1 (call L.pair?.8 14)))
      (call L.fun/error8464.6))))
(check-by-interp
 '(module
    (if (let ((boolean0.3 6) (fixnum1.2 1448) (boolean2.1 6))
          (!= boolean0.3 6))
      (let ((fixnum0.6 1104) (boolean1.5 14) (error2.4 64318)) fixnum0.6)
      (if (!= 14 6) 416 664))))
(check-by-interp
 '(module
    (define L.cons.9
      (lambda (tmp.50 tmp.51)
        (let ((tmp.54 (+ (alloc 16) 1)))
          (begin (mset! tmp.54 -1 tmp.50) (mset! tmp.54 7 tmp.51) tmp.54))))
    (define L.fun/void8484.4 (lambda () 30))
    (define L.fun/empty8485.5 (lambda () 22))
    (define L.fun/pair8483.6 (lambda () (call L.cons.9 712 2640)))
    (define L.fun/empty8482.7 (lambda () 22))
    (let ((empty0.4 (call L.fun/empty8482.7))
          (pair1.3 (call L.fun/pair8483.6))
          (void2.2 (call L.fun/void8484.4))
          (empty3.1 (call L.fun/empty8485.5)))
      pair1.3)))
(check-by-interp
 '(module
    (define L.+.12
      (lambda (tmp.20 tmp.21)
        (if (!= (if (= (bitwise-and tmp.21 7) 0) 14 6) 6)
          (if (!= (if (= (bitwise-and tmp.20 7) 0) 14 6) 6)
            (+ tmp.20 tmp.21)
            574)
          574)))
    (define L.-.11
      (lambda (tmp.22 tmp.23)
        (if (!= (if (= (bitwise-and tmp.23 7) 0) 14 6) 6)
          (if (!= (if (= (bitwise-and tmp.22 7) 0) 14 6) 6)
            (- tmp.22 tmp.23)
            830)
          830)))
    (define L.*.10
      (lambda (tmp.18 tmp.19)
        (if (!= (if (= (bitwise-and tmp.19 7) 0) 14 6) 6)
          (if (!= (if (= (bitwise-and tmp.18 7) 0) 14 6) 6)
            (* tmp.18 (arithmetic-shift-right tmp.19 3))
            318)
          318)))
    (define L.cons.9
      (lambda (tmp.50 tmp.51)
        (let ((tmp.54 (+ (alloc 16) 1)))
          (begin (mset! tmp.54 -1 tmp.50) (mset! tmp.54 7 tmp.51) tmp.54))))
    (define L.fun/error8501.4 (lambda () 1342))
    (define L.fun/pair8499.5 (lambda () (call L.cons.9 592 2072)))
    (define L.fun/void8500.6 (lambda () 30))
    (define L.fun/void8498.7 (lambda () 30))
    (let ((fixnum0.4
           (call L.+.12 (call L.*.10 1400 1784) (call L.-.11 1776 2024)))
          (void1.3 (call L.fun/void8498.7))
          (pair2.2 (call L.fun/pair8499.5))
          (void3.1 (call L.fun/void8500.6)))
      (call L.fun/error8501.4))))
(check-by-interp
 '(module
    (define L.pair?.10
      (lambda (tmp.59) (if (= (bitwise-and tmp.59 7) 1) 14 6)))
    (define L.cons.9
      (lambda (tmp.62 tmp.63)
        (let ((tmp.66 (+ (alloc 16) 1)))
          (begin (mset! tmp.66 -1 tmp.62) (mset! tmp.66 7 tmp.63) tmp.66))))
    (define L.fun/ascii-char8512.4
      (lambda (oprand0.3 oprand1.2 oprand2.1) 18734))
    (define L.fun/ascii-char8510.5
      (lambda (oprand0.6 oprand1.5 oprand2.4) oprand0.6))
    (define L.fun/ascii-char8511.6
      (lambda (oprand0.9 oprand1.8 oprand2.7) 12334))
    (define L.fun/boolean8513.7 (lambda (oprand0.12 oprand1.11 oprand2.10) 6))
    (call
     L.fun/ascii-char8510.5
     (if (let ((ascii-char0.16 30510)
               (void1.15 30)
               (empty2.14 22)
               (error3.13 28222))
           (!= 14 6))
       (call L.fun/ascii-char8511.6 28974 23870 12078)
       (call L.fun/ascii-char8512.4 25134 13102 11838))
     (if (!= (call L.pair?.10 (call L.cons.9 688 3600)) 6)
       (if (!= 14 6) 58942 23102)
       (if (!= 6 6) 54078 19774))
     (if (!= (call L.fun/boolean8513.7 416 1968 320) 6)
       (if (!= 6 6) 18478 19246)
       (if (!= 14 6) 26414 18990)))))
(check-by-interp
 '(module
    (define L.fun/ascii-char8546.4 (lambda () 29486))
    (define L.fun/empty8547.5 (lambda () 22))
    (define L.fun/error8544.6 (lambda () 17982))
    (define L.fun/ascii-char8545.7 (lambda () 12334))
    (let ((error0.4 (call L.fun/error8544.6))
          (ascii-char1.3 (call L.fun/ascii-char8545.7))
          (ascii-char2.2 (call L.fun/ascii-char8546.4))
          (empty3.1 (call L.fun/empty8547.5)))
      ascii-char1.3)))
(check-by-interp
 '(module
    (define L.void?.11
      (lambda (tmp.44) (if (= (bitwise-and tmp.44 255) 30) 14 6)))
    (define L.cons.10
      (lambda (tmp.50 tmp.51)
        (let ((tmp.54 (+ (alloc 16) 1)))
          (begin (mset! tmp.54 -1 tmp.50) (mset! tmp.54 7 tmp.51) tmp.54))))
    (define L.fun/any8685.4 (lambda () 30))
    (define L.fun/pair8681.5 (lambda () (call L.cons.10 856 3104)))
    (define L.fun/error8683.6 (lambda () 21310))
    (define L.fun/pair8684.7 (lambda () (call L.cons.10 936 2576)))
    (define L.fun/error8682.8 (lambda () 51774))
    (call
     L.void?.11
     (let ((pair0.4 (call L.fun/pair8681.5))
           (error1.3 (call L.fun/error8682.8))
           (error2.2 (call L.fun/error8683.6))
           (pair3.1 (call L.fun/pair8684.7)))
       (call L.fun/any8685.4)))))
(check-by-interp
 '(module
    (define L.+.12
      (lambda (tmp.21 tmp.22)
        (if (!= (if (= (bitwise-and tmp.22 7) 0) 14 6) 6)
          (if (!= (if (= (bitwise-and tmp.21 7) 0) 14 6) 6)
            (+ tmp.21 tmp.22)
            574)
          574)))
    (define L.-.11
      (lambda (tmp.23 tmp.24)
        (if (!= (if (= (bitwise-and tmp.24 7) 0) 14 6) 6)
          (if (!= (if (= (bitwise-and tmp.23 7) 0) 14 6) 6)
            (- tmp.23 tmp.24)
            830)
          830)))
    (define L.*.10
      (lambda (tmp.19 tmp.20)
        (if (!= (if (= (bitwise-and tmp.20 7) 0) 14 6) 6)
          (if (!= (if (= (bitwise-and tmp.19 7) 0) 14 6) 6)
            (* tmp.19 (arithmetic-shift-right tmp.20 3))
            318)
          318)))
    (define L.cons.9
      (lambda (tmp.51 tmp.52)
        (let ((tmp.55 (+ (alloc 16) 1)))
          (begin (mset! tmp.55 -1 tmp.51) (mset! tmp.55 7 tmp.52) tmp.55))))
    (define L.fun/empty8893.4 (lambda () 22))
    (define L.fun/empty8894.5 (lambda () 22))
    (define L.fun/pair8895.6 (lambda () (call L.cons.9 1160 2344)))
    (define L.fun/void8896.7 (lambda () 30))
    (let ((empty0.5 (call L.fun/empty8893.4))
          (empty1.4 (call L.fun/empty8894.5))
          (fixnum2.3
           (call
            L.-.11
            (call L.*.10 (call L.*.10 1632 200) (call L.*.10 320 904))
            (call L.-.11 (call L.-.11 712 320) (call L.+.12 896 928))))
          (pair3.2 (call L.fun/pair8895.6))
          (void4.1 (call L.fun/void8896.7)))
      pair3.2)))
(check-by-interp
 '(module
    (define L.*.12
      (lambda (tmp.19 tmp.20)
        (if (!= (if (= (bitwise-and tmp.20 7) 0) 14 6) 6)
          (if (!= (if (= (bitwise-and tmp.19 7) 0) 14 6) 6)
            (* tmp.19 (arithmetic-shift-right tmp.20 3))
            318)
          318)))
    (define L.-.11
      (lambda (tmp.23 tmp.24)
        (if (!= (if (= (bitwise-and tmp.24 7) 0) 14 6) 6)
          (if (!= (if (= (bitwise-and tmp.23 7) 0) 14 6) 6)
            (- tmp.23 tmp.24)
            830)
          830)))
    (define L.+.10
      (lambda (tmp.21 tmp.22)
        (if (!= (if (= (bitwise-and tmp.22 7) 0) 14 6) 6)
          (if (!= (if (= (bitwise-and tmp.21 7) 0) 14 6) 6)
            (+ tmp.21 tmp.22)
            574)
          574)))
    (define L.cons.9
      (lambda (tmp.51 tmp.52)
        (let ((tmp.55 (+ (alloc 16) 1)))
          (begin (mset! tmp.55 -1 tmp.51) (mset! tmp.55 7 tmp.52) tmp.55))))
    (define L.fun/empty8907.4 (lambda () 22))
    (define L.fun/error8906.5 (lambda () 18238))
    (define L.fun/pair8908.6 (lambda () (call L.cons.9 1360 3040)))
    (define L.fun/void8909.7 (lambda () 30))
    (let ((fixnum0.5
           (call
            L.-.11
            (call L.*.12 (call L.+.10 864 1560) (call L.-.11 1632 1832))
            (call L.*.12 (call L.+.10 408 408) (call L.+.10 1168 88))))
          (error1.4 (call L.fun/error8906.5))
          (fixnum2.3
           (call
            L.+.10
            (call L.*.12 (call L.+.10 1752 512) (call L.-.11 1728 1392))
            (call L.-.11 (call L.*.12 136 560) (call L.-.11 176 984))))
          (empty3.2 (call L.fun/empty8907.4))
          (pair4.1 (call L.fun/pair8908.6)))
      (call L.fun/void8909.7))))
(check-by-interp
 '(module
    (define L.*.12
      (lambda (tmp.19 tmp.20)
        (if (!= (if (= (bitwise-and tmp.20 7) 0) 14 6) 6)
          (if (!= (if (= (bitwise-and tmp.19 7) 0) 14 6) 6)
            (* tmp.19 (arithmetic-shift-right tmp.20 3))
            318)
          318)))
    (define L.-.11
      (lambda (tmp.23 tmp.24)
        (if (!= (if (= (bitwise-and tmp.24 7) 0) 14 6) 6)
          (if (!= (if (= (bitwise-and tmp.23 7) 0) 14 6) 6)
            (- tmp.23 tmp.24)
            830)
          830)))
    (define L.+.10
      (lambda (tmp.21 tmp.22)
        (if (!= (if (= (bitwise-and tmp.22 7) 0) 14 6) 6)
          (if (!= (if (= (bitwise-and tmp.21 7) 0) 14 6) 6)
            (+ tmp.21 tmp.22)
            574)
          574)))
    (define L.cons.9
      (lambda (tmp.51 tmp.52)
        (let ((tmp.55 (+ (alloc 16) 1)))
          (begin (mset! tmp.55 -1 tmp.51) (mset! tmp.55 7 tmp.52) tmp.55))))
    (define L.fun/pair9174.4 (lambda () (call L.cons.9 1016 3672)))
    (define L.fun/ascii-char9175.5 (lambda () 23598))
    (define L.fun/empty9176.6 (lambda () 22))
    (define L.fun/error9177.7 (lambda () 17470))
    (let ((pair0.5 (call L.fun/pair9174.4))
          (ascii-char1.4 (call L.fun/ascii-char9175.5))
          (empty2.3 (call L.fun/empty9176.6))
          (error3.2 (call L.fun/error9177.7))
          (fixnum4.1
           (call
            L.*.12
            (call L.+.10 (call L.+.10 1312 256) (call L.-.11 1592 320))
            (call L.-.11 (call L.*.12 1512 456) (call L.+.10 280 1776)))))
      error3.2)))
(check-by-interp
 '(module
    (define L.*.11
      (lambda (tmp.19 tmp.20)
        (if (!= (if (= (bitwise-and tmp.20 7) 0) 14 6) 6)
          (if (!= (if (= (bitwise-and tmp.19 7) 0) 14 6) 6)
            (* tmp.19 (arithmetic-shift-right tmp.20 3))
            318)
          318)))
    (define L.-.10
      (lambda (tmp.23 tmp.24)
        (if (!= (if (= (bitwise-and tmp.24 7) 0) 14 6) 6)
          (if (!= (if (= (bitwise-and tmp.23 7) 0) 14 6) 6)
            (- tmp.23 tmp.24)
            830)
          830)))
    (define L.+.9
      (lambda (tmp.21 tmp.22)
        (if (!= (if (= (bitwise-and tmp.22 7) 0) 14 6) 6)
          (if (!= (if (= (bitwise-and tmp.21 7) 0) 14 6) 6)
            (+ tmp.21 tmp.22)
            574)
          574)))
    (define L.fun/error9704.4 (lambda () 56382))
    (define L.fun/void9703.5 (lambda () 30))
    (define L.fun/void9702.6 (lambda () 30))
    (define L.fun/empty9705.7 (lambda () 22))
    (let ((fixnum0.5
           (call
            L.-.10
            (call L.-.10 (call L.+.9 904 992) (call L.-.10 1656 1512))
            (call L.+.9 (call L.+.9 1080 1624) (call L.*.11 296 240))))
          (void1.4 (call L.fun/void9702.6))
          (void2.3 (call L.fun/void9703.5))
          (error3.2 (call L.fun/error9704.4))
          (empty4.1 (call L.fun/empty9705.7)))
      error3.2)))
(check-by-interp
 '(module
    (define L.*.11
      (lambda (tmp.19 tmp.20)
        (if (!= (if (= (bitwise-and tmp.20 7) 0) 14 6) 6)
          (if (!= (if (= (bitwise-and tmp.19 7) 0) 14 6) 6)
            (* tmp.19 (arithmetic-shift-right tmp.20 3))
            318)
          318)))
    (define L.+.10
      (lambda (tmp.21 tmp.22)
        (if (!= (if (= (bitwise-and tmp.22 7) 0) 14 6) 6)
          (if (!= (if (= (bitwise-and tmp.21 7) 0) 14 6) 6)
            (+ tmp.21 tmp.22)
            574)
          574)))
    (define L.-.9
      (lambda (tmp.23 tmp.24)
        (if (!= (if (= (bitwise-and tmp.24 7) 0) 14 6) 6)
          (if (!= (if (= (bitwise-and tmp.23 7) 0) 14 6) 6)
            (- tmp.23 tmp.24)
            830)
          830)))
    (define L.cons.8
      (lambda (tmp.51 tmp.52)
        (let ((tmp.55 (+ (alloc 16) 1)))
          (begin (mset! tmp.55 -1 tmp.51) (mset! tmp.55 7 tmp.52) tmp.55))))
    (define L.fun/pair9710.4 (lambda () (call L.cons.8 792 2640)))
    (define L.fun/error9708.5 (lambda () 54846))
    (define L.fun/void9709.6 (lambda () 30))
    (let ((error0.5 (call L.fun/error9708.5))
          (void1.4 (call L.fun/void9709.6))
          (fixnum2.3
           (call
            L.+.10
            (call L.-.9 (call L.-.9 2000 152) (call L.-.9 784 416))
            (call L.+.10 (call L.-.9 1824 240) (call L.+.10 320 312))))
          (fixnum3.2
           (call
            L.*.11
            (call L.+.10 (call L.*.11 216 992) (call L.*.11 168 568))
            (call L.+.10 (call L.+.10 1248 1352) (call L.-.9 168 1632))))
          (pair4.1 (call L.fun/pair9710.4)))
      void1.4)))
(check-by-interp
 '(module
    (define L.*.13
      (lambda (tmp.19 tmp.20)
        (if (!= (if (= (bitwise-and tmp.20 7) 0) 14 6) 6)
          (if (!= (if (= (bitwise-and tmp.19 7) 0) 14 6) 6)
            (* tmp.19 (arithmetic-shift-right tmp.20 3))
            318)
          318)))
    (define L.-.12
      (lambda (tmp.23 tmp.24)
        (if (!= (if (= (bitwise-and tmp.24 7) 0) 14 6) 6)
          (if (!= (if (= (bitwise-and tmp.23 7) 0) 14 6) 6)
            (- tmp.23 tmp.24)
            830)
          830)))
    (define L.+.11
      (lambda (tmp.21 tmp.22)
        (if (!= (if (= (bitwise-and tmp.22 7) 0) 14 6) 6)
          (if (!= (if (= (bitwise-and tmp.21 7) 0) 14 6) 6)
            (+ tmp.21 tmp.22)
            574)
          574)))
    (define L.cons.10
      (lambda (tmp.51 tmp.52)
        (let ((tmp.55 (+ (alloc 16) 1)))
          (begin (mset! tmp.55 -1 tmp.51) (mset! tmp.55 7 tmp.52) tmp.55))))
    (define L.fun/void9976.4 (lambda () 30))
    (define L.fun/pair9973.5 (lambda () (call L.cons.10 1352 3448)))
    (define L.fun/empty9975.6 (lambda () 22))
    (define L.fun/void9974.7 (lambda () 30))
    (define L.fun/ascii-char9977.8 (lambda () 20782))
    (let ((pair0.5 (call L.fun/pair9973.5))
          (void1.4 (call L.fun/void9974.7))
          (empty2.3 (call L.fun/empty9975.6))
          (void3.2 (call L.fun/void9976.4))
          (fixnum4.1
           (call
            L.-.12
            (call L.+.11 (call L.+.11 1608 1288) (call L.-.12 1992 1528))
            (call L.+.11 (call L.-.12 688 1152) (call L.*.13 1048 1848)))))
      (call L.fun/ascii-char9977.8))))
(check-by-interp
 '(module
    (define L.fun/void15785.4 (lambda () (call L.fun/void15786.9)))
    (define L.fun/empty15784.5 (lambda () 22))
    (define L.fun/error15778.6 (lambda () 4670))
    (define L.fun/ascii-char15782.7 (lambda () 29742))
    (define L.fun/error15777.8 (lambda () (call L.fun/error15778.6)))
    (define L.fun/void15786.9 (lambda () 30))
    (define L.fun/ascii-char15781.10
      (lambda () (call L.fun/ascii-char15782.7)))
    (define L.fun/ascii-char15779.11
      (lambda () (call L.fun/ascii-char15780.14)))
    (define L.fun/empty15775.12 (lambda () (call L.fun/empty15776.15)))
    (define L.fun/empty15783.13 (lambda () (call L.fun/empty15784.5)))
    (define L.fun/ascii-char15780.14 (lambda () 21038))
    (define L.fun/empty15776.15 (lambda () 22))
    (let ((empty0.6 (call L.fun/empty15775.12))
          (error1.5 (call L.fun/error15777.8))
          (ascii-char2.4 (call L.fun/ascii-char15779.11))
          (ascii-char3.3 (call L.fun/ascii-char15781.10))
          (empty4.2 (call L.fun/empty15783.13))
          (void5.1 (call L.fun/void15785.4)))
      void5.1)))
(check-by-interp
 '(module
    (define L.void?.16
      (lambda (tmp.46) (if (= (bitwise-and tmp.46 255) 30) 14 6)))
    (define L.boolean?.15
      (lambda (tmp.44) (if (= (bitwise-and tmp.44 247) 6) 14 6)))
    (define L.fun/any18974.4 (lambda () 30))
    (define L.fun/void18977.5 (lambda () (call L.fun/void18978.12)))
    (define L.fun/ascii-char18970.6 (lambda () 23854))
    (define L.fun/ascii-char18969.7 (lambda () (call L.fun/ascii-char18970.6)))
    (define L.fun/error18976.8 (lambda () 39742))
    (define L.fun/void18971.9 (lambda () (call L.fun/void18972.10)))
    (define L.fun/void18972.10 (lambda () 30))
    (define L.fun/error18975.11 (lambda () (call L.fun/error18976.8)))
    (define L.fun/void18978.12 (lambda () 30))
    (define L.fun/any18973.13 (lambda () 60990))
    (let ((ascii-char0.6 (call L.fun/ascii-char18969.7))
          (void1.5 (call L.fun/void18971.9))
          (boolean2.4 (call L.boolean?.15 (call L.fun/any18973.13)))
          (boolean3.3 (call L.void?.16 (call L.fun/any18974.4)))
          (error4.2 (call L.fun/error18975.11))
          (void5.1 (call L.fun/void18977.5)))
      ascii-char0.6)))
(check-by-interp
 '(module
    (define L.cons.17
      (lambda (tmp.52 tmp.53)
        (let ((tmp.56 (+ (alloc 16) 1)))
          (begin (mset! tmp.56 -1 tmp.52) (mset! tmp.56 7 tmp.53) tmp.56))))
    (define L.fun/error19375.4 (lambda () 5438))
    (define L.fun/empty19379.5 (lambda () 22))
    (define L.fun/error19373.6 (lambda () 1086))
    (define L.fun/pair19383.7 (lambda () (call L.cons.17 1696 3048)))
    (define L.fun/ascii-char19377.8 (lambda () 28718))
    (define L.fun/pair19382.9 (lambda () (call L.fun/pair19383.7)))
    (define L.fun/ascii-char19376.10
      (lambda () (call L.fun/ascii-char19377.8)))
    (define L.fun/empty19378.11 (lambda () (call L.fun/empty19379.5)))
    (define L.fun/empty19381.12 (lambda () 22))
    (define L.fun/empty19380.13 (lambda () (call L.fun/empty19381.12)))
    (define L.fun/error19372.14 (lambda () (call L.fun/error19373.6)))
    (define L.fun/error19374.15 (lambda () (call L.fun/error19375.4)))
    (let ((error0.6 (call L.fun/error19372.14))
          (error1.5 (call L.fun/error19374.15))
          (ascii-char2.4 (call L.fun/ascii-char19376.10))
          (empty3.3 (call L.fun/empty19378.11))
          (empty4.2 (call L.fun/empty19380.13))
          (pair5.1 (call L.fun/pair19382.9)))
      pair5.1)))
(check-by-interp
 '(module
    (define L.boolean?.15
      (lambda (tmp.44) (if (= (bitwise-and tmp.44 247) 6) 14 6)))
    (define L.-.14
      (lambda (tmp.24 tmp.25)
        (if (!= (if (= (bitwise-and tmp.25 7) 0) 14 6) 6)
          (if (!= (if (= (bitwise-and tmp.24 7) 0) 14 6) 6)
            (- tmp.24 tmp.25)
            830)
          830)))
    (define L.*.13
      (lambda (tmp.20 tmp.21)
        (if (!= (if (= (bitwise-and tmp.21 7) 0) 14 6) 6)
          (if (!= (if (= (bitwise-and tmp.20 7) 0) 14 6) 6)
            (* tmp.20 (arithmetic-shift-right tmp.21 3))
            318)
          318)))
    (define L.+.12
      (lambda (tmp.22 tmp.23)
        (if (!= (if (= (bitwise-and tmp.23 7) 0) 14 6) 6)
          (if (!= (if (= (bitwise-and tmp.22 7) 0) 14 6) 6)
            (+ tmp.22 tmp.23)
            574)
          574)))
    (define L.fun/void20855.4 (lambda () 30))
    (define L.fun/ascii-char20850.5 (lambda () (call L.fun/ascii-char20851.8)))
    (define L.fun/void20854.6 (lambda () (call L.fun/void20855.4)))
    (define L.fun/any20856.7 (lambda () 14))
    (define L.fun/ascii-char20851.8 (lambda () 29742))
    (define L.fun/ascii-char20853.9 (lambda () 24366))
    (define L.fun/ascii-char20852.10
      (lambda () (call L.fun/ascii-char20853.9)))
    (let ((ascii-char0.6 (call L.fun/ascii-char20850.5))
          (fixnum1.5
           (call
            L.+.12
            (call
             L.-.14
             (call L.+.12 (call L.+.12 1200 456) (call L.+.12 336 616))
             (call L.-.14 (call L.*.13 352 480) (call L.-.14 456 1240)))
            (call
             L.-.14
             (call L.*.13 (call L.+.12 1264 640) (call L.-.14 504 400))
             (call L.-.14 (call L.+.12 1024 664) (call L.-.14 112 936)))))
          (ascii-char2.4 (call L.fun/ascii-char20852.10))
          (fixnum3.3
           (call
            L.-.14
            (call
             L.+.12
             (call L.-.14 (call L.*.13 376 672) (call L.*.13 1128 352))
             (call L.+.12 (call L.-.14 1360 1896) (call L.+.12 1848 1680)))
            (call
             L.*.13
             (call L.-.14 (call L.+.12 248 440) (call L.-.14 960 1952))
             (call L.+.12 (call L.+.12 504 248) (call L.-.14 696 1768)))))
          (void4.2 (call L.fun/void20854.6))
          (fixnum5.1
           (call
            L.*.13
            (call
             L.-.14
             (call L.-.14 (call L.-.14 424 1552) (call L.-.14 1264 144))
             (call L.*.13 (call L.-.14 640 1256) (call L.+.12 712 1904)))
            (call
             L.+.12
             (call L.+.12 (call L.+.12 1080 1304) (call L.*.13 1000 1928))
             (call L.-.14 (call L.*.13 1720 416) (call L.-.14 1344 1112))))))
      (call L.boolean?.15 (call L.fun/any20856.7)))))
(check-by-interp
 '(module
    (define L.-.18
      (lambda (tmp.24 tmp.25)
        (if (!= (if (= (bitwise-and tmp.25 7) 0) 14 6) 6)
          (if (!= (if (= (bitwise-and tmp.24 7) 0) 14 6) 6)
            (- tmp.24 tmp.25)
            830)
          830)))
    (define L.*.17
      (lambda (tmp.20 tmp.21)
        (if (!= (if (= (bitwise-and tmp.21 7) 0) 14 6) 6)
          (if (!= (if (= (bitwise-and tmp.20 7) 0) 14 6) 6)
            (* tmp.20 (arithmetic-shift-right tmp.21 3))
            318)
          318)))
    (define L.+.16
      (lambda (tmp.22 tmp.23)
        (if (!= (if (= (bitwise-and tmp.23 7) 0) 14 6) 6)
          (if (!= (if (= (bitwise-and tmp.22 7) 0) 14 6) 6)
            (+ tmp.22 tmp.23)
            574)
          574)))
    (define L.cons.15
      (lambda (tmp.52 tmp.53)
        (let ((tmp.56 (+ (alloc 16) 1)))
          (begin (mset! tmp.56 -1 tmp.52) (mset! tmp.56 7 tmp.53) tmp.56))))
    (define L.fun/ascii-char22195.4 (lambda () 31278))
    (define L.fun/empty22197.5 (lambda () 22))
    (define L.fun/pair22193.6 (lambda () (call L.cons.15 640 2320)))
    (define L.fun/pair22192.7 (lambda () (call L.fun/pair22193.6)))
    (define L.fun/empty22199.8 (lambda () 22))
    (define L.fun/empty22198.9 (lambda () (call L.fun/empty22199.8)))
    (define L.fun/empty22196.10 (lambda () (call L.fun/empty22197.5)))
    (define L.fun/error22191.11 (lambda () 19262))
    (define L.fun/error22190.12 (lambda () (call L.fun/error22191.11)))
    (define L.fun/ascii-char22194.13
      (lambda () (call L.fun/ascii-char22195.4)))
    (let ((error0.6 (call L.fun/error22190.12))
          (pair1.5 (call L.fun/pair22192.7))
          (ascii-char2.4 (call L.fun/ascii-char22194.13))
          (empty3.3 (call L.fun/empty22196.10))
          (empty4.2 (call L.fun/empty22198.9))
          (fixnum5.1
           (call
            L.+.16
            (call
             L.*.17
             (call L.-.18 (call L.+.16 1072 1408) (call L.*.17 1232 784))
             (call L.-.18 (call L.*.17 1496 1688) (call L.+.16 832 824)))
            (call
             L.-.18
             (call L.+.16 (call L.*.17 392 880) (call L.*.17 312 192))
             (call L.*.17 (call L.*.17 1728 576) (call L.-.18 160 848))))))
      error0.6)))
(check-by-interp
 '(module
    (define L.*.20
      (lambda (tmp.20 tmp.21)
        (if (!= (if (= (bitwise-and tmp.21 7) 0) 14 6) 6)
          (if (!= (if (= (bitwise-and tmp.20 7) 0) 14 6) 6)
            (* tmp.20 (arithmetic-shift-right tmp.21 3))
            318)
          318)))
    (define L.+.19
      (lambda (tmp.22 tmp.23)
        (if (!= (if (= (bitwise-and tmp.23 7) 0) 14 6) 6)
          (if (!= (if (= (bitwise-and tmp.22 7) 0) 14 6) 6)
            (+ tmp.22 tmp.23)
            574)
          574)))
    (define L.-.18
      (lambda (tmp.24 tmp.25)
        (if (!= (if (= (bitwise-and tmp.25 7) 0) 14 6) 6)
          (if (!= (if (= (bitwise-and tmp.24 7) 0) 14 6) 6)
            (- tmp.24 tmp.25)
            830)
          830)))
    (define L.vector?.17
      (lambda (tmp.50) (if (= (bitwise-and tmp.50 7) 3) 14 6)))
    (define L.cons.16
      (lambda (tmp.52 tmp.53)
        (let ((tmp.56 (+ (alloc 16) 1)))
          (begin (mset! tmp.56 -1 tmp.52) (mset! tmp.56 7 tmp.53) tmp.56))))
    (define L.fun/pair23550.4 (lambda () (call L.fun/pair23551.8)))
    (define L.fun/void23549.5 (lambda () 30))
    (define L.fun/void23541.6 (lambda () (call L.fun/void23542.14)))
    (define L.fun/void23548.7 (lambda () (call L.fun/void23549.5)))
    (define L.fun/pair23551.8 (lambda () (call L.cons.16 664 3872)))
    (define L.fun/error23546.9 (lambda () (call L.fun/error23547.11)))
    (define L.fun/empty23544.10 (lambda () 22))
    (define L.fun/error23547.11 (lambda () 53822))
    (define L.fun/any23545.12 (lambda () 6))
    (define L.fun/empty23543.13 (lambda () (call L.fun/empty23544.10)))
    (define L.fun/void23542.14 (lambda () 30))
    (let ((void0.6 (call L.fun/void23541.6))
          (empty1.5 (call L.fun/empty23543.13))
          (boolean2.4 (call L.vector?.17 (call L.fun/any23545.12)))
          (fixnum3.3
           (call
            L.+.19
            (call
             L.-.18
             (call L.+.19 (call L.-.18 1448 368) (call L.-.18 672 1528))
             (call L.*.20 (call L.+.19 1808 464) (call L.-.18 104 520)))
            (call
             L.*.20
             (call L.+.19 (call L.*.20 1264 104) (call L.-.18 448 448))
             (call L.+.19 (call L.+.19 1664 320) (call L.*.20 1296 112)))))
          (error4.2 (call L.fun/error23546.9))
          (void5.1 (call L.fun/void23548.7)))
      (call L.fun/pair23550.4))))
(check-by-interp
 '(module
    (define L.fun/error24539.4 (lambda () 15934))
    (define L.fun/ascii-char24535.5 (lambda () 18734))
    (define L.fun/ascii-char24529.6 (lambda () 24622))
    (define L.fun/empty24537.7 (lambda () 22))
    (define L.fun/ascii-char24534.8 (lambda () (call L.fun/ascii-char24535.5)))
    (define L.fun/error24531.9 (lambda () 2622))
    (define L.fun/error24538.10 (lambda () (call L.fun/error24539.4)))
    (define L.fun/empty24536.11 (lambda () (call L.fun/empty24537.7)))
    (define L.fun/void24532.12 (lambda () (call L.fun/void24533.14)))
    (define L.fun/error24530.13 (lambda () (call L.fun/error24531.9)))
    (define L.fun/void24533.14 (lambda () 30))
    (define L.fun/ascii-char24528.15
      (lambda () (call L.fun/ascii-char24529.6)))
    (let ((ascii-char0.6 (call L.fun/ascii-char24528.15))
          (error1.5 (call L.fun/error24530.13))
          (void2.4 (call L.fun/void24532.12))
          (ascii-char3.3 (call L.fun/ascii-char24534.8))
          (empty4.2 (call L.fun/empty24536.11))
          (error5.1 (call L.fun/error24538.10)))
      empty4.2)))
(check-by-interp
 '(module
    (define L.-.15
      (lambda (tmp.24 tmp.25)
        (if (!= (if (= (bitwise-and tmp.25 7) 0) 14 6) 6)
          (if (!= (if (= (bitwise-and tmp.24 7) 0) 14 6) 6)
            (- tmp.24 tmp.25)
            830)
          830)))
    (define L.*.14
      (lambda (tmp.20 tmp.21)
        (if (!= (if (= (bitwise-and tmp.21 7) 0) 14 6) 6)
          (if (!= (if (= (bitwise-and tmp.20 7) 0) 14 6) 6)
            (* tmp.20 (arithmetic-shift-right tmp.21 3))
            318)
          318)))
    (define L.+.13
      (lambda (tmp.22 tmp.23)
        (if (!= (if (= (bitwise-and tmp.23 7) 0) 14 6) 6)
          (if (!= (if (= (bitwise-and tmp.22 7) 0) 14 6) 6)
            (+ tmp.22 tmp.23)
            574)
          574)))
    (define L.fun/empty24788.4 (lambda () 22))
    (define L.fun/error24789.5 (lambda () (call L.fun/error24790.10)))
    (define L.fun/error24786.6 (lambda () 34622))
    (define L.fun/error24785.7 (lambda () (call L.fun/error24786.6)))
    (define L.fun/empty24792.8 (lambda () 22))
    (define L.fun/empty24787.9 (lambda () (call L.fun/empty24788.4)))
    (define L.fun/error24790.10 (lambda () 11070))
    (define L.fun/empty24791.11 (lambda () (call L.fun/empty24792.8)))
    (let ((error0.6 (call L.fun/error24785.7))
          (fixnum1.5
           (call
            L.-.15
            (call
             L.-.15
             (call L.+.13 (call L.+.13 1392 1112) (call L.*.14 1104 1584))
             (call L.-.15 (call L.*.14 88 1024) (call L.+.13 680 32)))
            (call
             L.+.13
             (call L.+.13 (call L.-.15 1648 1672) (call L.*.14 2016 1616))
             (call L.*.14 (call L.-.15 1040 1512) (call L.+.13 2024 1256)))))
          (empty2.4 (call L.fun/empty24787.9))
          (error3.3 (call L.fun/error24789.5))
          (fixnum4.2
           (call
            L.*.14
            (call
             L.-.15
             (call L.-.15 (call L.*.14 640 608) (call L.*.14 88 1840))
             (call L.+.13 (call L.+.13 1992 2008) (call L.*.14 632 1960)))
            (call
             L.*.14
             (call L.+.13 (call L.*.14 744 1392) (call L.*.14 808 440))
             (call L.*.14 (call L.-.15 1368 920) (call L.-.15 912 920)))))
          (empty5.1 (call L.fun/empty24791.11)))
      (call
       L.+.13
       (call
        L.+.13
        (call L.-.15 (call L.-.15 56 fixnum4.2) fixnum4.2)
        (call L.*.14 fixnum1.5 (call L.*.14 144 fixnum1.5)))
       (call L.-.15 fixnum4.2 fixnum1.5)))))
(check-by-interp
 '(module
    (define L.error?.19
      (lambda (tmp.48) (if (= (bitwise-and tmp.48 255) 62) 14 6)))
    (define L.cons.18
      (lambda (tmp.52 tmp.53)
        (let ((tmp.56 (+ (alloc 16) 1)))
          (begin (mset! tmp.56 -1 tmp.52) (mset! tmp.56 7 tmp.53) tmp.56))))
    (define L.fun/pair24832.4 (lambda () (call L.fun/pair24833.15)))
    (define L.fun/error24829.5 (lambda () 2110))
    (define L.fun/pair24835.6 (lambda () (call L.fun/pair24836.7)))
    (define L.fun/pair24836.7 (lambda () (call L.cons.18 1040 4056)))
    (define L.fun/any24834.8 (lambda () 40766))
    (define L.fun/ascii-char24839.9
      (lambda () (call L.fun/ascii-char24840.12)))
    (define L.fun/void24831.10 (lambda () 30))
    (define L.fun/void24830.11 (lambda () (call L.fun/void24831.10)))
    (define L.fun/ascii-char24840.12 (lambda () 26414))
    (define L.fun/empty24838.13 (lambda () 22))
    (define L.fun/empty24837.14 (lambda () (call L.fun/empty24838.13)))
    (define L.fun/pair24833.15 (lambda () (call L.cons.18 1856 3544)))
    (define L.fun/error24828.16 (lambda () (call L.fun/error24829.5)))
    (let ((error0.6 (call L.fun/error24828.16))
          (void1.5 (call L.fun/void24830.11))
          (pair2.4 (call L.fun/pair24832.4))
          (boolean3.3 (call L.error?.19 (call L.fun/any24834.8)))
          (pair4.2 (call L.fun/pair24835.6))
          (empty5.1 (call L.fun/empty24837.14)))
      (call L.fun/ascii-char24839.9))))
(check-by-interp
 '(module
    (define L.+.16
      (lambda (tmp.22 tmp.23)
        (if (!= (if (= (bitwise-and tmp.23 7) 0) 14 6) 6)
          (if (!= (if (= (bitwise-and tmp.22 7) 0) 14 6) 6)
            (+ tmp.22 tmp.23)
            574)
          574)))
    (define L.-.15
      (lambda (tmp.24 tmp.25)
        (if (!= (if (= (bitwise-and tmp.25 7) 0) 14 6) 6)
          (if (!= (if (= (bitwise-and tmp.24 7) 0) 14 6) 6)
            (- tmp.24 tmp.25)
            830)
          830)))
    (define L.*.14
      (lambda (tmp.20 tmp.21)
        (if (!= (if (= (bitwise-and tmp.21 7) 0) 14 6) 6)
          (if (!= (if (= (bitwise-and tmp.20 7) 0) 14 6) 6)
            (* tmp.20 (arithmetic-shift-right tmp.21 3))
            318)
          318)))
    (define L.cons.13
      (lambda (tmp.52 tmp.53)
        (let ((tmp.56 (+ (alloc 16) 1)))
          (begin (mset! tmp.56 -1 tmp.52) (mset! tmp.56 7 tmp.53) tmp.56))))
    (define L.fun/empty27006.4 (lambda () (call L.fun/empty27007.9)))
    (define L.fun/pair27009.5 (lambda () (call L.cons.13 1768 2952)))
    (define L.fun/void27004.6 (lambda () (call L.fun/void27005.11)))
    (define L.fun/ascii-char27003.7 (lambda () 29998))
    (define L.fun/pair27008.8 (lambda () (call L.fun/pair27009.5)))
    (define L.fun/empty27007.9 (lambda () 22))
    (define L.fun/ascii-char27002.10
      (lambda () (call L.fun/ascii-char27003.7)))
    (define L.fun/void27005.11 (lambda () 30))
    (let ((fixnum0.6
           (call
            L.-.15
            (call
             L.+.16
             (call L.-.15 (call L.*.14 264 1480) (call L.-.15 1256 408))
             (call L.+.16 (call L.-.15 384 1408) (call L.-.15 2016 1384)))
            (call
             L.-.15
             (call L.*.14 (call L.-.15 168 1384) (call L.*.14 872 808))
             (call L.-.15 (call L.+.16 560 608) (call L.-.15 520 872)))))
          (fixnum1.5
           (call
            L.*.14
            (call
             L.*.14
             (call L.+.16 (call L.+.16 776 488) (call L.*.14 704 1368))
             (call L.+.16 (call L.-.15 1880 1592) (call L.*.14 1080 1824)))
            (call
             L.-.15
             (call L.-.15 (call L.-.15 1312 1800) (call L.*.14 792 1856))
             (call L.-.15 (call L.*.14 608 408) (call L.-.15 16 904)))))
          (ascii-char2.4 (call L.fun/ascii-char27002.10))
          (void3.3 (call L.fun/void27004.6))
          (empty4.2 (call L.fun/empty27006.4))
          (fixnum5.1
           (call
            L.+.16
            (call
             L.*.14
             (call L.*.14 (call L.*.14 704 48) (call L.-.15 1448 1168))
             (call L.-.15 (call L.-.15 1016 784) (call L.*.14 240 2016)))
            (call
             L.*.14
             (call L.-.15 (call L.-.15 496 1968) (call L.+.16 1672 1688))
             (call L.-.15 (call L.*.14 880 992) (call L.-.15 1176 1000))))))
      (call L.fun/pair27008.8))))
(check-by-interp
 '(module
    (define L.*.17
      (lambda (tmp.20 tmp.21)
        (if (!= (if (= (bitwise-and tmp.21 7) 0) 14 6) 6)
          (if (!= (if (= (bitwise-and tmp.20 7) 0) 14 6) 6)
            (* tmp.20 (arithmetic-shift-right tmp.21 3))
            318)
          318)))
    (define L.+.16
      (lambda (tmp.22 tmp.23)
        (if (!= (if (= (bitwise-and tmp.23 7) 0) 14 6) 6)
          (if (!= (if (= (bitwise-and tmp.22 7) 0) 14 6) 6)
            (+ tmp.22 tmp.23)
            574)
          574)))
    (define L.-.15
      (lambda (tmp.24 tmp.25)
        (if (!= (if (= (bitwise-and tmp.25 7) 0) 14 6) 6)
          (if (!= (if (= (bitwise-and tmp.24 7) 0) 14 6) 6)
            (- tmp.24 tmp.25)
            830)
          830)))
    (define L.fun/ascii-char27114.4 (lambda () (call L.fun/ascii-char27115.8)))
    (define L.fun/empty27120.5 (lambda () (call L.fun/empty27121.11)))
    (define L.fun/error27116.6 (lambda () (call L.fun/error27117.7)))
    (define L.fun/error27117.7 (lambda () 34622))
    (define L.fun/ascii-char27115.8 (lambda () 23342))
    (define L.fun/ascii-char27123.9 (lambda () 27694))
    (define L.fun/ascii-char27122.10
      (lambda () (call L.fun/ascii-char27123.9)))
    (define L.fun/empty27121.11 (lambda () 22))
    (define L.fun/empty27118.12 (lambda () (call L.fun/empty27119.13)))
    (define L.fun/empty27119.13 (lambda () 22))
    (let ((ascii-char0.6 (call L.fun/ascii-char27114.4))
          (error1.5 (call L.fun/error27116.6))
          (empty2.4 (call L.fun/empty27118.12))
          (empty3.3 (call L.fun/empty27120.5))
          (fixnum4.2
           (call
            L.+.16
            (call
             L.+.16
             (call L.-.15 (call L.-.15 608 584) (call L.-.15 1776 1304))
             (call L.+.16 (call L.+.16 1456 1824) (call L.+.16 1832 312)))
            (call
             L.*.17
             (call L.*.17 (call L.-.15 1536 8) (call L.-.15 648 912))
             (call L.+.16 (call L.+.16 688 1304) (call L.-.15 1544 1096)))))
          (ascii-char5.1 (call L.fun/ascii-char27122.10)))
      (call
       L.-.15
       (call
        L.*.17
        (call L.-.15 fixnum4.2 (call L.*.17 fixnum4.2 1928))
        (call L.+.16 fixnum4.2 (call L.+.16 184 fixnum4.2)))
       (call
        L.-.15
        (call L.+.16 (call L.-.15 920 912) fixnum4.2)
        (call L.-.15 (call L.-.15 792 1752) fixnum4.2))))))
(check-by-interp
 '(module
    (define L.pair?.19
      (lambda (tmp.49) (if (= (bitwise-and tmp.49 7) 1) 14 6)))
    (define L.cons.18
      (lambda (tmp.52 tmp.53)
        (let ((tmp.56 (+ (alloc 16) 1)))
          (begin (mset! tmp.56 -1 tmp.52) (mset! tmp.56 7 tmp.53) tmp.56))))
    (define L.fun/pair27447.4 (lambda () (call L.fun/pair27448.11)))
    (define L.fun/ascii-char27445.5
      (lambda () (call L.fun/ascii-char27446.13)))
    (define L.fun/ascii-char27438.6 (lambda () 18222))
    (define L.fun/error27440.7 (lambda () 33342))
    (define L.fun/ascii-char27443.8
      (lambda () (call L.fun/ascii-char27444.14)))
    (define L.fun/void27441.9 (lambda () (call L.fun/void27442.12)))
    (define L.fun/error27439.10 (lambda () (call L.fun/error27440.7)))
    (define L.fun/pair27448.11 (lambda () (call L.cons.18 1488 3512)))
    (define L.fun/void27442.12 (lambda () 30))
    (define L.fun/ascii-char27446.13 (lambda () 29230))
    (define L.fun/ascii-char27444.14 (lambda () 25134))
    (define L.fun/ascii-char27437.15
      (lambda () (call L.fun/ascii-char27438.6)))
    (define L.fun/any27436.16 (lambda () (call L.cons.18 1488 3104)))
    (let ((boolean0.6 (call L.pair?.19 (call L.fun/any27436.16)))
          (ascii-char1.5 (call L.fun/ascii-char27437.15))
          (error2.4 (call L.fun/error27439.10))
          (void3.3 (call L.fun/void27441.9))
          (ascii-char4.2 (call L.fun/ascii-char27443.8))
          (ascii-char5.1 (call L.fun/ascii-char27445.5)))
      (call L.fun/pair27447.4))))
