#lang racket
(require rackunit
         cpsc411/compiler-lib
         cpsc411/ptr-run-time
         cpsc411/langs/v8
         "../expose-allocation-pointer.rkt")
(define (fail-if-invalid p)
  (when (not (asm-pred-lang-v8? p))
    (error
     (~a
      (pretty-format p)
      "\n is not a semantically valid "
      "asm-pred-lang-v8"
      " program")))
  p)
(define-syntax-rule
 (check-by-interp p)
 (check-equal?
  (interp-asm-alloc-lang-v8 p)
  (interp-asm-pred-lang-v8 (fail-if-invalid (expose-allocation-pointer p)))))

(check-by-interp
 '(module
    ((new-frames ()))
    (begin (set! tmp-ra.50 r15) (set! rax 30) (jump tmp-ra.50 rbp rax))))
(check-by-interp
 '(module
    ((new-frames ()))
    (begin
      (set! tmp-ra.51 r15)
      (set! ascii-char0.1 27438)
      (set! rax 22)
      (jump tmp-ra.51 rbp rax))))
(check-by-interp
 '(module
    ((new-frames ()))
    (begin
      (set! tmp-ra.51 r15)
      (set! void0.1 30)
      (set! rax 31790)
      (jump tmp-ra.51 rbp rax))))

(check-by-interp
 '(module
    ((new-frames ()))
    (define L.fun/fixnum8389.4
      ((new-frames ()))
      (begin (set! tmp-ra.50 r15) (set! rax 1672) (jump tmp-ra.50 rbp rax)))
    (begin
      (set! tmp-ra.51 r15)
      (set! r15 tmp-ra.51)
      (jump L.fun/fixnum8389.4 rbp r15))))
(check-by-interp
 '(module
    ((new-frames ()))
    (begin
      (set! tmp-ra.52 r15)
      (set! boolean0.2 6)
      (set! void1.1 30)
      (set! rax 30)
      (jump tmp-ra.52 rbp rax))))
(check-by-interp
 '(module
    ((new-frames ()))
    (define L.fun/fixnum8394.4
      ((new-frames ()))
      (begin
        (set! tmp-ra.52 r15)
        (set! oprand0.1 rdi)
        (set! rax 312)
        (jump tmp-ra.52 rbp rax)))
    (begin
      (set! tmp-ra.53 r15)
      (if (begin (set! tmp.54 14) (!= tmp.54 6))
        (set! tmp.51 15934)
        (set! tmp.51 45118))
      (set! rdi tmp.51)
      (set! r15 tmp-ra.53)
      (jump L.fun/fixnum8394.4 rbp r15 rdi))))
(check-by-interp
 '(module
    ((new-frames (())))
    (define L.fun/error8401.4
      ((new-frames ()))
      (begin
        (set! tmp-ra.53 r15)
        (set! oprand0.1 rdi)
        (set! rax 1854)
        (jump tmp-ra.53 rbp rax)))
    (define L.fun/void8402.5
      ((new-frames ()))
      (begin
        (set! tmp-ra.54 r15)
        (set! oprand0.2 rdi)
        (set! rax 30)
        (jump tmp-ra.54 rbp rax)))
    (begin
      (set! tmp-ra.55 r15)
      (return-point L.rp.7
        (begin
          (set! rdi 22)
          (set! r15 L.rp.7)
          (jump L.fun/void8402.5 rbp r15 rdi)))
      (set! tmp.52 rax)
      (set! rdi tmp.52)
      (set! r15 tmp-ra.55)
      (jump L.fun/error8401.4 rbp r15 rdi))))
(check-by-interp
 '(module
    ((new-frames (())))
    (define L.cons.5
      ((new-frames ()))
      (begin
        (set! tmp-ra.54 r15)
        (set! tmp.48 rdi)
        (set! tmp.49 rsi)
        (set! tmp.53 (alloc 16))
        (set! tmp.56 tmp.53)
        (set! tmp.56 (+ tmp.56 1))
        (set! tmp.52 tmp.56)
        (mset! tmp.52 -1 tmp.48)
        (mset! tmp.52 7 tmp.49)
        (set! rax tmp.52)
        (jump tmp-ra.54 rbp rax)))
    (begin
      (set! tmp-ra.55 r15)
      (set! ascii-char0.2 18222)
      (return-point L.rp.6
        (begin
          (set! rsi 2272)
          (set! rdi 832)
          (set! r15 L.rp.6)
          (jump L.cons.5 rbp r15 rdi rsi)))
      (set! pair1.1 rax)
      (set! rax ascii-char0.2)
      (jump tmp-ra.55 rbp rax))))
(check-by-interp
 '(module
    ((new-frames ()))
    (begin
      (set! tmp-ra.52 r15)
      (set! fixnum0.2 1712)
      (set! boolean1.1 14)
      (set! rax 1864)
      (jump tmp-ra.52 rbp rax))))
(check-by-interp
 '(module
    ((new-frames (() ())))
    (define L.cons.8
      ((new-frames ()))
      (begin
        (set! tmp-ra.60 r15)
        (set! tmp.52 rdi)
        (set! tmp.53 rsi)
        (set! tmp.57 (alloc 16))
        (set! tmp.65 tmp.57)
        (set! tmp.65 (+ tmp.65 1))
        (set! tmp.56 tmp.65)
        (mset! tmp.56 -1 tmp.52)
        (mset! tmp.56 7 tmp.53)
        (set! rax tmp.56)
        (jump tmp-ra.60 rbp rax)))
    (define L.fun/error8419.4
      ((new-frames ()))
      (begin
        (set! tmp-ra.61 r15)
        (set! oprand0.2 rdi)
        (set! oprand1.1 rsi)
        (set! rax 47678)
        (jump tmp-ra.61 rbp rax)))
    (define L.fun/boolean8418.5
      ((new-frames ()))
      (begin
        (set! tmp-ra.62 r15)
        (set! oprand0.4 rdi)
        (set! oprand1.3 rsi)
        (set! rax 6)
        (jump tmp-ra.62 rbp rax)))
    (define L.fun/error8420.6
      ((new-frames ()))
      (begin
        (set! tmp-ra.63 r15)
        (set! oprand0.6 rdi)
        (set! oprand1.5 rsi)
        (set! rax 39998)
        (jump tmp-ra.63 rbp rax)))
    (begin
      (set! tmp-ra.64 r15)
      (if (begin
            (begin
              (return-point L.rp.9
                (begin
                  (set! rsi 456)
                  (set! rdi 14)
                  (set! r15 L.rp.9)
                  (jump L.fun/boolean8418.5 rbp r15 rdi rsi)))
              (set! tmp.58 rax))
            (!= tmp.58 6))
        (begin
          (set! rsi 22)
          (set! rdi 14)
          (set! r15 tmp-ra.64)
          (jump L.fun/error8419.4 rbp r15 rdi rsi))
        (begin
          (return-point L.rp.10
            (begin
              (set! rsi 3240)
              (set! rdi 208)
              (set! r15 L.rp.10)
              (jump L.cons.8 rbp r15 rdi rsi)))
          (set! tmp.59 rax)
          (set! rsi tmp.59)
          (set! rdi 22)
          (set! r15 tmp-ra.64)
          (jump L.fun/error8420.6 rbp r15 rdi rsi))))))
(check-by-interp
 '(module
    ((new-frames (() () ())))
    (define L.+.9
      ((new-frames ()))
      (begin
        (set! tmp-ra.59 r15)
        (set! tmp.19 rdi)
        (set! tmp.20 rsi)
        (if (begin
              (if (begin
                    (begin
                      (set! tmp.65 tmp.20)
                      (set! tmp.65 (bitwise-and tmp.65 7))
                      (set! tmp.55 tmp.65))
                    (= tmp.55 0))
                (set! tmp.54 14)
                (set! tmp.54 6))
              (!= tmp.54 6))
          (if (begin
                (if (begin
                      (begin
                        (set! tmp.66 tmp.19)
                        (set! tmp.66 (bitwise-and tmp.66 7))
                        (set! tmp.57 tmp.66))
                      (= tmp.57 0))
                  (set! tmp.56 14)
                  (set! tmp.56 6))
                (!= tmp.56 6))
            (begin
              (set! tmp.67 tmp.19)
              (set! tmp.67 (+ tmp.67 tmp.20))
              (set! rax tmp.67)
              (jump tmp-ra.59 rbp rax))
            (begin (set! rax 574) (jump tmp-ra.59 rbp rax)))
          (begin (set! rax 574) (jump tmp-ra.59 rbp rax)))))
    (define L.cons.8
      ((new-frames ()))
      (begin
        (set! tmp-ra.60 r15)
        (set! tmp.49 rdi)
        (set! tmp.50 rsi)
        (set! tmp.58 (alloc 16))
        (set! tmp.68 tmp.58)
        (set! tmp.68 (+ tmp.68 1))
        (set! tmp.53 tmp.68)
        (mset! tmp.53 -1 tmp.49)
        (mset! tmp.53 7 tmp.50)
        (set! rax tmp.53)
        (jump tmp-ra.60 rbp rax)))
    (define L.fun/ascii-char8439.4
      ((new-frames ()))
      (begin (set! tmp-ra.61 r15) (set! rax 22318) (jump tmp-ra.61 rbp rax)))
    (define L.fun/error8440.5
      ((new-frames ()))
      (begin (set! tmp-ra.62 r15) (set! rax 4670) (jump tmp-ra.62 rbp rax)))
    (define L.fun/pair8441.6
      ((new-frames ()))
      (begin
        (set! tmp-ra.63 r15)
        (set! rsi 2392)
        (set! rdi 704)
        (set! r15 tmp-ra.63)
        (jump L.cons.8 rbp r15 rdi rsi)))
    (begin
      (set! tmp-ra.64 r15)
      (return-point L.rp.10
        (begin (set! r15 L.rp.10) (jump L.fun/ascii-char8439.4 rbp r15)))
      (set! ascii-char0.3 rax)
      (return-point L.rp.11
        (begin (set! r15 L.rp.11) (jump L.fun/error8440.5 rbp r15)))
      (set! error1.2 rax)
      (return-point L.rp.12
        (begin (set! r15 L.rp.12) (jump L.fun/pair8441.6 rbp r15)))
      (set! pair2.1 rax)
      (set! rsi 1064)
      (set! rdi 2024)
      (set! r15 tmp-ra.64)
      (jump L.+.9 rbp r15 rdi rsi))))
(check-by-interp
 '(module
    ((new-frames (() () ())))
    (define L.pair?.8
      ((new-frames ()))
      (begin
        (set! tmp-ra.54 r15)
        (set! tmp.46 rdi)
        (if (begin
              (begin
                (set! tmp.59 tmp.46)
                (set! tmp.59 (bitwise-and tmp.59 7))
                (set! tmp.53 tmp.59))
              (= tmp.53 1))
          (begin (set! rax 14) (jump tmp-ra.54 rbp rax))
          (begin (set! rax 6) (jump tmp-ra.54 rbp rax)))))
    (define L.fun/ascii-char8463.4
      ((new-frames ()))
      (begin (set! tmp-ra.55 r15) (set! rax 22574) (jump tmp-ra.55 rbp rax)))
    (define L.fun/ascii-char8462.5
      ((new-frames ()))
      (begin (set! tmp-ra.56 r15) (set! rax 10286) (jump tmp-ra.56 rbp rax)))
    (define L.fun/error8464.6
      ((new-frames ()))
      (begin (set! tmp-ra.57 r15) (set! rax 5694) (jump tmp-ra.57 rbp rax)))
    (begin
      (set! tmp-ra.58 r15)
      (return-point L.rp.9
        (begin (set! r15 L.rp.9) (jump L.fun/ascii-char8462.5 rbp r15)))
      (set! ascii-char0.3 rax)
      (return-point L.rp.10
        (begin (set! r15 L.rp.10) (jump L.fun/ascii-char8463.4 rbp r15)))
      (set! ascii-char1.2 rax)
      (return-point L.rp.11
        (begin (set! rdi 14) (set! r15 L.rp.11) (jump L.pair?.8 rbp r15 rdi)))
      (set! boolean2.1 rax)
      (set! r15 tmp-ra.58)
      (jump L.fun/error8464.6 rbp r15))))
(check-by-interp
 '(module
    ((new-frames ()))
    (begin
      (set! tmp-ra.56 r15)
      (if (begin
            (set! boolean0.3 6)
            (set! fixnum1.2 1448)
            (set! boolean2.1 6)
            (!= boolean0.3 6))
        (begin
          (set! fixnum0.6 1104)
          (set! boolean1.5 14)
          (set! error2.4 64318)
          (set! rax fixnum0.6)
          (jump tmp-ra.56 rbp rax))
        (if (begin (set! tmp.57 14) (!= tmp.57 6))
          (begin (set! rax 416) (jump tmp-ra.56 rbp rax))
          (begin (set! rax 664) (jump tmp-ra.56 rbp rax)))))))
(check-by-interp
 '(module
    ((new-frames (() () () () () ())))
    (define L.+.12
      ((new-frames ()))
      (begin
        (set! tmp-ra.71 r15)
        (set! tmp.20 rdi)
        (set! tmp.21 rsi)
        (if (begin
              (if (begin
                    (begin
                      (set! tmp.80 tmp.21)
                      (set! tmp.80 (bitwise-and tmp.80 7))
                      (set! tmp.56 tmp.80))
                    (= tmp.56 0))
                (set! tmp.55 14)
                (set! tmp.55 6))
              (!= tmp.55 6))
          (if (begin
                (if (begin
                      (begin
                        (set! tmp.81 tmp.20)
                        (set! tmp.81 (bitwise-and tmp.81 7))
                        (set! tmp.58 tmp.81))
                      (= tmp.58 0))
                  (set! tmp.57 14)
                  (set! tmp.57 6))
                (!= tmp.57 6))
            (begin
              (set! tmp.82 tmp.20)
              (set! tmp.82 (+ tmp.82 tmp.21))
              (set! rax tmp.82)
              (jump tmp-ra.71 rbp rax))
            (begin (set! rax 574) (jump tmp-ra.71 rbp rax)))
          (begin (set! rax 574) (jump tmp-ra.71 rbp rax)))))
    (define L.-.11
      ((new-frames ()))
      (begin
        (set! tmp-ra.72 r15)
        (set! tmp.22 rdi)
        (set! tmp.23 rsi)
        (if (begin
              (if (begin
                    (begin
                      (set! tmp.83 tmp.23)
                      (set! tmp.83 (bitwise-and tmp.83 7))
                      (set! tmp.60 tmp.83))
                    (= tmp.60 0))
                (set! tmp.59 14)
                (set! tmp.59 6))
              (!= tmp.59 6))
          (if (begin
                (if (begin
                      (begin
                        (set! tmp.84 tmp.22)
                        (set! tmp.84 (bitwise-and tmp.84 7))
                        (set! tmp.62 tmp.84))
                      (= tmp.62 0))
                  (set! tmp.61 14)
                  (set! tmp.61 6))
                (!= tmp.61 6))
            (begin
              (set! tmp.85 tmp.22)
              (set! tmp.85 (- tmp.85 tmp.23))
              (set! rax tmp.85)
              (jump tmp-ra.72 rbp rax))
            (begin (set! rax 830) (jump tmp-ra.72 rbp rax)))
          (begin (set! rax 830) (jump tmp-ra.72 rbp rax)))))
    (define L.*.10
      ((new-frames ()))
      (begin
        (set! tmp-ra.73 r15)
        (set! tmp.18 rdi)
        (set! tmp.19 rsi)
        (if (begin
              (if (begin
                    (begin
                      (set! tmp.86 tmp.19)
                      (set! tmp.86 (bitwise-and tmp.86 7))
                      (set! tmp.64 tmp.86))
                    (= tmp.64 0))
                (set! tmp.63 14)
                (set! tmp.63 6))
              (!= tmp.63 6))
          (if (begin
                (if (begin
                      (begin
                        (set! tmp.87 tmp.18)
                        (set! tmp.87 (bitwise-and tmp.87 7))
                        (set! tmp.66 tmp.87))
                      (= tmp.66 0))
                  (set! tmp.65 14)
                  (set! tmp.65 6))
                (!= tmp.65 6))
            (begin
              (set! tmp.88 tmp.19)
              (set! tmp.88 (arithmetic-shift-right tmp.88 3))
              (set! tmp.67 tmp.88)
              (set! tmp.89 tmp.18)
              (set! tmp.89 (* tmp.89 tmp.67))
              (set! rax tmp.89)
              (jump tmp-ra.73 rbp rax))
            (begin (set! rax 318) (jump tmp-ra.73 rbp rax)))
          (begin (set! rax 318) (jump tmp-ra.73 rbp rax)))))
    (define L.cons.9
      ((new-frames ()))
      (begin
        (set! tmp-ra.74 r15)
        (set! tmp.50 rdi)
        (set! tmp.51 rsi)
        (set! tmp.68 (alloc 16))
        (set! tmp.90 tmp.68)
        (set! tmp.90 (+ tmp.90 1))
        (set! tmp.54 tmp.90)
        (mset! tmp.54 -1 tmp.50)
        (mset! tmp.54 7 tmp.51)
        (set! rax tmp.54)
        (jump tmp-ra.74 rbp rax)))
    (define L.fun/error8501.4
      ((new-frames ()))
      (begin (set! tmp-ra.75 r15) (set! rax 1342) (jump tmp-ra.75 rbp rax)))
    (define L.fun/pair8499.5
      ((new-frames ()))
      (begin
        (set! tmp-ra.76 r15)
        (set! rsi 2072)
        (set! rdi 592)
        (set! r15 tmp-ra.76)
        (jump L.cons.9 rbp r15 rdi rsi)))
    (define L.fun/void8500.6
      ((new-frames ()))
      (begin (set! tmp-ra.77 r15) (set! rax 30) (jump tmp-ra.77 rbp rax)))
    (define L.fun/void8498.7
      ((new-frames ()))
      (begin (set! tmp-ra.78 r15) (set! rax 30) (jump tmp-ra.78 rbp rax)))
    (begin
      (set! tmp-ra.79 r15)
      (return-point L.rp.13
        (begin
          (set! rsi 1784)
          (set! rdi 1400)
          (set! r15 L.rp.13)
          (jump L.*.10 rbp r15 rdi rsi)))
      (set! tmp.69 rax)
      (return-point L.rp.14
        (begin
          (set! rsi 2024)
          (set! rdi 1776)
          (set! r15 L.rp.14)
          (jump L.-.11 rbp r15 rdi rsi)))
      (set! tmp.70 rax)
      (return-point L.rp.15
        (begin
          (set! rsi tmp.70)
          (set! rdi tmp.69)
          (set! r15 L.rp.15)
          (jump L.+.12 rbp r15 rdi rsi)))
      (set! fixnum0.4 rax)
      (return-point L.rp.16
        (begin (set! r15 L.rp.16) (jump L.fun/void8498.7 rbp r15)))
      (set! void1.3 rax)
      (return-point L.rp.17
        (begin (set! r15 L.rp.17) (jump L.fun/pair8499.5 rbp r15)))
      (set! pair2.2 rax)
      (return-point L.rp.18
        (begin (set! r15 L.rp.18) (jump L.fun/void8500.6 rbp r15)))
      (set! void3.1 rax)
      (set! r15 tmp-ra.79)
      (jump L.fun/error8501.4 rbp r15))))
(check-by-interp
 '(module
    ((new-frames (() () () () ())))
    (define L.pair?.10
      ((new-frames ()))
      (begin
        (set! tmp-ra.75 r15)
        (set! tmp.59 rdi)
        (if (begin
              (begin
                (set! tmp.82 tmp.59)
                (set! tmp.82 (bitwise-and tmp.82 7))
                (set! tmp.67 tmp.82))
              (= tmp.67 1))
          (begin (set! rax 14) (jump tmp-ra.75 rbp rax))
          (begin (set! rax 6) (jump tmp-ra.75 rbp rax)))))
    (define L.cons.9
      ((new-frames ()))
      (begin
        (set! tmp-ra.76 r15)
        (set! tmp.62 rdi)
        (set! tmp.63 rsi)
        (set! tmp.68 (alloc 16))
        (set! tmp.83 tmp.68)
        (set! tmp.83 (+ tmp.83 1))
        (set! tmp.66 tmp.83)
        (mset! tmp.66 -1 tmp.62)
        (mset! tmp.66 7 tmp.63)
        (set! rax tmp.66)
        (jump tmp-ra.76 rbp rax)))
    (define L.fun/ascii-char8512.4
      ((new-frames ()))
      (begin
        (set! tmp-ra.77 r15)
        (set! oprand0.3 rdi)
        (set! oprand1.2 rsi)
        (set! oprand2.1 rdx)
        (set! rax 18734)
        (jump tmp-ra.77 rbp rax)))
    (define L.fun/ascii-char8510.5
      ((new-frames ()))
      (begin
        (set! tmp-ra.78 r15)
        (set! oprand0.6 rdi)
        (set! oprand1.5 rsi)
        (set! oprand2.4 rdx)
        (set! rax oprand0.6)
        (jump tmp-ra.78 rbp rax)))
    (define L.fun/ascii-char8511.6
      ((new-frames ()))
      (begin
        (set! tmp-ra.79 r15)
        (set! oprand0.9 rdi)
        (set! oprand1.8 rsi)
        (set! oprand2.7 rdx)
        (set! rax 12334)
        (jump tmp-ra.79 rbp rax)))
    (define L.fun/boolean8513.7
      ((new-frames ()))
      (begin
        (set! tmp-ra.80 r15)
        (set! oprand0.12 rdi)
        (set! oprand1.11 rsi)
        (set! oprand2.10 rdx)
        (set! rax 6)
        (jump tmp-ra.80 rbp rax)))
    (begin
      (set! tmp-ra.81 r15)
      (if (begin
            (set! ascii-char0.16 30510)
            (set! void1.15 30)
            (set! empty2.14 22)
            (set! error3.13 28222)
            (begin (set! tmp.84 14) (!= tmp.84 6)))
        (begin
          (return-point L.rp.11
            (begin
              (set! rdx 12078)
              (set! rsi 23870)
              (set! rdi 28974)
              (set! r15 L.rp.11)
              (jump L.fun/ascii-char8511.6 rbp r15 rdi rsi rdx)))
          (set! tmp.69 rax))
        (begin
          (return-point L.rp.12
            (begin
              (set! rdx 11838)
              (set! rsi 13102)
              (set! rdi 25134)
              (set! r15 L.rp.12)
              (jump L.fun/ascii-char8512.4 rbp r15 rdi rsi rdx)))
          (set! tmp.69 rax)))
      (if (begin
            (begin
              (return-point L.rp.13
                (begin
                  (set! rsi 3600)
                  (set! rdi 688)
                  (set! r15 L.rp.13)
                  (jump L.cons.9 rbp r15 rdi rsi)))
              (set! tmp.72 rax)
              (return-point L.rp.14
                (begin
                  (set! rdi tmp.72)
                  (set! r15 L.rp.14)
                  (jump L.pair?.10 rbp r15 rdi)))
              (set! tmp.71 rax))
            (!= tmp.71 6))
        (if (begin (set! tmp.85 14) (!= tmp.85 6))
          (set! tmp.70 58942)
          (set! tmp.70 23102))
        (if (begin (set! tmp.86 6) (!= tmp.86 6))
          (set! tmp.70 54078)
          (set! tmp.70 19774)))
      (if (begin
            (begin
              (return-point L.rp.15
                (begin
                  (set! rdx 320)
                  (set! rsi 1968)
                  (set! rdi 416)
                  (set! r15 L.rp.15)
                  (jump L.fun/boolean8513.7 rbp r15 rdi rsi rdx)))
              (set! tmp.74 rax))
            (!= tmp.74 6))
        (if (begin (set! tmp.87 6) (!= tmp.87 6))
          (set! tmp.73 18478)
          (set! tmp.73 19246))
        (if (begin (set! tmp.88 14) (!= tmp.88 6))
          (set! tmp.73 26414)
          (set! tmp.73 18990)))
      (set! rdx tmp.73)
      (set! rsi tmp.70)
      (set! rdi tmp.69)
      (set! r15 tmp-ra.81)
      (jump L.fun/ascii-char8510.5 rbp r15 rdi rsi rdx))))
(check-by-interp
 '(module
    ((new-frames (() () () ())))
    (define L.fun/ascii-char8546.4
      ((new-frames ()))
      (begin (set! tmp-ra.54 r15) (set! rax 29486) (jump tmp-ra.54 rbp rax)))
    (define L.fun/empty8547.5
      ((new-frames ()))
      (begin (set! tmp-ra.55 r15) (set! rax 22) (jump tmp-ra.55 rbp rax)))
    (define L.fun/error8544.6
      ((new-frames ()))
      (begin (set! tmp-ra.56 r15) (set! rax 17982) (jump tmp-ra.56 rbp rax)))
    (define L.fun/ascii-char8545.7
      ((new-frames ()))
      (begin (set! tmp-ra.57 r15) (set! rax 12334) (jump tmp-ra.57 rbp rax)))
    (begin
      (set! tmp-ra.58 r15)
      (return-point L.rp.9
        (begin (set! r15 L.rp.9) (jump L.fun/error8544.6 rbp r15)))
      (set! error0.4 rax)
      (return-point L.rp.10
        (begin (set! r15 L.rp.10) (jump L.fun/ascii-char8545.7 rbp r15)))
      (set! ascii-char1.3 rax)
      (return-point L.rp.11
        (begin (set! r15 L.rp.11) (jump L.fun/ascii-char8546.4 rbp r15)))
      (set! ascii-char2.2 rax)
      (return-point L.rp.12
        (begin (set! r15 L.rp.12) (jump L.fun/empty8547.5 rbp r15)))
      (set! empty3.1 rax)
      (set! rax ascii-char1.3)
      (jump tmp-ra.58 rbp rax))))
(check-by-interp
 '(module
    ((new-frames (() () () () ())))
    (define L.void?.11
      ((new-frames ()))
      (begin
        (set! tmp-ra.58 r15)
        (set! tmp.44 rdi)
        (if (begin
              (begin
                (set! tmp.66 tmp.44)
                (set! tmp.66 (bitwise-and tmp.66 255))
                (set! tmp.55 tmp.66))
              (= tmp.55 30))
          (begin (set! rax 14) (jump tmp-ra.58 rbp rax))
          (begin (set! rax 6) (jump tmp-ra.58 rbp rax)))))
    (define L.cons.10
      ((new-frames ()))
      (begin
        (set! tmp-ra.59 r15)
        (set! tmp.50 rdi)
        (set! tmp.51 rsi)
        (set! tmp.56 (alloc 16))
        (set! tmp.67 tmp.56)
        (set! tmp.67 (+ tmp.67 1))
        (set! tmp.54 tmp.67)
        (mset! tmp.54 -1 tmp.50)
        (mset! tmp.54 7 tmp.51)
        (set! rax tmp.54)
        (jump tmp-ra.59 rbp rax)))
    (define L.fun/any8685.4
      ((new-frames ()))
      (begin (set! tmp-ra.60 r15) (set! rax 30) (jump tmp-ra.60 rbp rax)))
    (define L.fun/pair8681.5
      ((new-frames ()))
      (begin
        (set! tmp-ra.61 r15)
        (set! rsi 3104)
        (set! rdi 856)
        (set! r15 tmp-ra.61)
        (jump L.cons.10 rbp r15 rdi rsi)))
    (define L.fun/error8683.6
      ((new-frames ()))
      (begin (set! tmp-ra.62 r15) (set! rax 21310) (jump tmp-ra.62 rbp rax)))
    (define L.fun/pair8684.7
      ((new-frames ()))
      (begin
        (set! tmp-ra.63 r15)
        (set! rsi 2576)
        (set! rdi 936)
        (set! r15 tmp-ra.63)
        (jump L.cons.10 rbp r15 rdi rsi)))
    (define L.fun/error8682.8
      ((new-frames ()))
      (begin (set! tmp-ra.64 r15) (set! rax 51774) (jump tmp-ra.64 rbp rax)))
    (begin
      (set! tmp-ra.65 r15)
      (return-point L.rp.12
        (begin (set! r15 L.rp.12) (jump L.fun/pair8681.5 rbp r15)))
      (set! pair0.4 rax)
      (return-point L.rp.13
        (begin (set! r15 L.rp.13) (jump L.fun/error8682.8 rbp r15)))
      (set! error1.3 rax)
      (return-point L.rp.14
        (begin (set! r15 L.rp.14) (jump L.fun/error8683.6 rbp r15)))
      (set! error2.2 rax)
      (return-point L.rp.15
        (begin (set! r15 L.rp.15) (jump L.fun/pair8684.7 rbp r15)))
      (set! pair3.1 rax)
      (return-point L.rp.16
        (begin (set! r15 L.rp.16) (jump L.fun/any8685.4 rbp r15)))
      (set! tmp.57 rax)
      (set! rdi tmp.57)
      (set! r15 tmp-ra.65)
      (jump L.void?.11 rbp r15 rdi))))
(check-by-interp
 '(module
    ((new-frames (() () () () () () () () () () () () () () () () ())))
    (define L.*.12
      ((new-frames ()))
      (begin
        (set! tmp-ra.82 r15)
        (set! tmp.19 rdi)
        (set! tmp.20 rsi)
        (if (begin
              (if (begin
                    (begin
                      (set! tmp.91 tmp.20)
                      (set! tmp.91 (bitwise-and tmp.91 7))
                      (set! tmp.57 tmp.91))
                    (= tmp.57 0))
                (set! tmp.56 14)
                (set! tmp.56 6))
              (!= tmp.56 6))
          (if (begin
                (if (begin
                      (begin
                        (set! tmp.92 tmp.19)
                        (set! tmp.92 (bitwise-and tmp.92 7))
                        (set! tmp.59 tmp.92))
                      (= tmp.59 0))
                  (set! tmp.58 14)
                  (set! tmp.58 6))
                (!= tmp.58 6))
            (begin
              (set! tmp.93 tmp.20)
              (set! tmp.93 (arithmetic-shift-right tmp.93 3))
              (set! tmp.60 tmp.93)
              (set! tmp.94 tmp.19)
              (set! tmp.94 (* tmp.94 tmp.60))
              (set! rax tmp.94)
              (jump tmp-ra.82 rbp rax))
            (begin (set! rax 318) (jump tmp-ra.82 rbp rax)))
          (begin (set! rax 318) (jump tmp-ra.82 rbp rax)))))
    (define L.-.11
      ((new-frames ()))
      (begin
        (set! tmp-ra.83 r15)
        (set! tmp.23 rdi)
        (set! tmp.24 rsi)
        (if (begin
              (if (begin
                    (begin
                      (set! tmp.95 tmp.24)
                      (set! tmp.95 (bitwise-and tmp.95 7))
                      (set! tmp.62 tmp.95))
                    (= tmp.62 0))
                (set! tmp.61 14)
                (set! tmp.61 6))
              (!= tmp.61 6))
          (if (begin
                (if (begin
                      (begin
                        (set! tmp.96 tmp.23)
                        (set! tmp.96 (bitwise-and tmp.96 7))
                        (set! tmp.64 tmp.96))
                      (= tmp.64 0))
                  (set! tmp.63 14)
                  (set! tmp.63 6))
                (!= tmp.63 6))
            (begin
              (set! tmp.97 tmp.23)
              (set! tmp.97 (- tmp.97 tmp.24))
              (set! rax tmp.97)
              (jump tmp-ra.83 rbp rax))
            (begin (set! rax 830) (jump tmp-ra.83 rbp rax)))
          (begin (set! rax 830) (jump tmp-ra.83 rbp rax)))))
    (define L.+.10
      ((new-frames ()))
      (begin
        (set! tmp-ra.84 r15)
        (set! tmp.21 rdi)
        (set! tmp.22 rsi)
        (if (begin
              (if (begin
                    (begin
                      (set! tmp.98 tmp.22)
                      (set! tmp.98 (bitwise-and tmp.98 7))
                      (set! tmp.66 tmp.98))
                    (= tmp.66 0))
                (set! tmp.65 14)
                (set! tmp.65 6))
              (!= tmp.65 6))
          (if (begin
                (if (begin
                      (begin
                        (set! tmp.99 tmp.21)
                        (set! tmp.99 (bitwise-and tmp.99 7))
                        (set! tmp.68 tmp.99))
                      (= tmp.68 0))
                  (set! tmp.67 14)
                  (set! tmp.67 6))
                (!= tmp.67 6))
            (begin
              (set! tmp.100 tmp.21)
              (set! tmp.100 (+ tmp.100 tmp.22))
              (set! rax tmp.100)
              (jump tmp-ra.84 rbp rax))
            (begin (set! rax 574) (jump tmp-ra.84 rbp rax)))
          (begin (set! rax 574) (jump tmp-ra.84 rbp rax)))))
    (define L.cons.9
      ((new-frames ()))
      (begin
        (set! tmp-ra.85 r15)
        (set! tmp.51 rdi)
        (set! tmp.52 rsi)
        (set! tmp.69 (alloc 16))
        (set! tmp.101 tmp.69)
        (set! tmp.101 (+ tmp.101 1))
        (set! tmp.55 tmp.101)
        (mset! tmp.55 -1 tmp.51)
        (mset! tmp.55 7 tmp.52)
        (set! rax tmp.55)
        (jump tmp-ra.85 rbp rax)))
    (define L.fun/empty8907.4
      ((new-frames ()))
      (begin (set! tmp-ra.86 r15) (set! rax 22) (jump tmp-ra.86 rbp rax)))
    (define L.fun/error8906.5
      ((new-frames ()))
      (begin (set! tmp-ra.87 r15) (set! rax 18238) (jump tmp-ra.87 rbp rax)))
    (define L.fun/pair8908.6
      ((new-frames ()))
      (begin
        (set! tmp-ra.88 r15)
        (set! rsi 3040)
        (set! rdi 1360)
        (set! r15 tmp-ra.88)
        (jump L.cons.9 rbp r15 rdi rsi)))
    (define L.fun/void8909.7
      ((new-frames ()))
      (begin (set! tmp-ra.89 r15) (set! rax 30) (jump tmp-ra.89 rbp rax)))
    (begin
      (set! tmp-ra.90 r15)
      (return-point L.rp.13
        (begin
          (set! rsi 1560)
          (set! rdi 864)
          (set! r15 L.rp.13)
          (jump L.+.10 rbp r15 rdi rsi)))
      (set! tmp.71 rax)
      (return-point L.rp.14
        (begin
          (set! rsi 1832)
          (set! rdi 1632)
          (set! r15 L.rp.14)
          (jump L.-.11 rbp r15 rdi rsi)))
      (set! tmp.72 rax)
      (return-point L.rp.15
        (begin
          (set! rsi tmp.72)
          (set! rdi tmp.71)
          (set! r15 L.rp.15)
          (jump L.*.12 rbp r15 rdi rsi)))
      (set! tmp.70 rax)
      (return-point L.rp.16
        (begin
          (set! rsi 408)
          (set! rdi 408)
          (set! r15 L.rp.16)
          (jump L.+.10 rbp r15 rdi rsi)))
      (set! tmp.74 rax)
      (return-point L.rp.17
        (begin
          (set! rsi 88)
          (set! rdi 1168)
          (set! r15 L.rp.17)
          (jump L.+.10 rbp r15 rdi rsi)))
      (set! tmp.75 rax)
      (return-point L.rp.18
        (begin
          (set! rsi tmp.75)
          (set! rdi tmp.74)
          (set! r15 L.rp.18)
          (jump L.*.12 rbp r15 rdi rsi)))
      (set! tmp.73 rax)
      (return-point L.rp.19
        (begin
          (set! rsi tmp.73)
          (set! rdi tmp.70)
          (set! r15 L.rp.19)
          (jump L.-.11 rbp r15 rdi rsi)))
      (set! fixnum0.5 rax)
      (return-point L.rp.20
        (begin (set! r15 L.rp.20) (jump L.fun/error8906.5 rbp r15)))
      (set! error1.4 rax)
      (return-point L.rp.21
        (begin
          (set! rsi 512)
          (set! rdi 1752)
          (set! r15 L.rp.21)
          (jump L.+.10 rbp r15 rdi rsi)))
      (set! tmp.77 rax)
      (return-point L.rp.22
        (begin
          (set! rsi 1392)
          (set! rdi 1728)
          (set! r15 L.rp.22)
          (jump L.-.11 rbp r15 rdi rsi)))
      (set! tmp.78 rax)
      (return-point L.rp.23
        (begin
          (set! rsi tmp.78)
          (set! rdi tmp.77)
          (set! r15 L.rp.23)
          (jump L.*.12 rbp r15 rdi rsi)))
      (set! tmp.76 rax)
      (return-point L.rp.24
        (begin
          (set! rsi 560)
          (set! rdi 136)
          (set! r15 L.rp.24)
          (jump L.*.12 rbp r15 rdi rsi)))
      (set! tmp.80 rax)
      (return-point L.rp.25
        (begin
          (set! rsi 984)
          (set! rdi 176)
          (set! r15 L.rp.25)
          (jump L.-.11 rbp r15 rdi rsi)))
      (set! tmp.81 rax)
      (return-point L.rp.26
        (begin
          (set! rsi tmp.81)
          (set! rdi tmp.80)
          (set! r15 L.rp.26)
          (jump L.-.11 rbp r15 rdi rsi)))
      (set! tmp.79 rax)
      (return-point L.rp.27
        (begin
          (set! rsi tmp.79)
          (set! rdi tmp.76)
          (set! r15 L.rp.27)
          (jump L.+.10 rbp r15 rdi rsi)))
      (set! fixnum2.3 rax)
      (return-point L.rp.28
        (begin (set! r15 L.rp.28) (jump L.fun/empty8907.4 rbp r15)))
      (set! empty3.2 rax)
      (return-point L.rp.29
        (begin (set! r15 L.rp.29) (jump L.fun/pair8908.6 rbp r15)))
      (set! pair4.1 rax)
      (set! r15 tmp-ra.90)
      (jump L.fun/void8909.7 rbp r15))))
(check-by-interp
 '(module
    ((new-frames (() () () () () () () () () () ())))
    (define L.*.12
      ((new-frames ()))
      (begin
        (set! tmp-ra.76 r15)
        (set! tmp.19 rdi)
        (set! tmp.20 rsi)
        (if (begin
              (if (begin
                    (begin
                      (set! tmp.85 tmp.20)
                      (set! tmp.85 (bitwise-and tmp.85 7))
                      (set! tmp.57 tmp.85))
                    (= tmp.57 0))
                (set! tmp.56 14)
                (set! tmp.56 6))
              (!= tmp.56 6))
          (if (begin
                (if (begin
                      (begin
                        (set! tmp.86 tmp.19)
                        (set! tmp.86 (bitwise-and tmp.86 7))
                        (set! tmp.59 tmp.86))
                      (= tmp.59 0))
                  (set! tmp.58 14)
                  (set! tmp.58 6))
                (!= tmp.58 6))
            (begin
              (set! tmp.87 tmp.20)
              (set! tmp.87 (arithmetic-shift-right tmp.87 3))
              (set! tmp.60 tmp.87)
              (set! tmp.88 tmp.19)
              (set! tmp.88 (* tmp.88 tmp.60))
              (set! rax tmp.88)
              (jump tmp-ra.76 rbp rax))
            (begin (set! rax 318) (jump tmp-ra.76 rbp rax)))
          (begin (set! rax 318) (jump tmp-ra.76 rbp rax)))))
    (define L.-.11
      ((new-frames ()))
      (begin
        (set! tmp-ra.77 r15)
        (set! tmp.23 rdi)
        (set! tmp.24 rsi)
        (if (begin
              (if (begin
                    (begin
                      (set! tmp.89 tmp.24)
                      (set! tmp.89 (bitwise-and tmp.89 7))
                      (set! tmp.62 tmp.89))
                    (= tmp.62 0))
                (set! tmp.61 14)
                (set! tmp.61 6))
              (!= tmp.61 6))
          (if (begin
                (if (begin
                      (begin
                        (set! tmp.90 tmp.23)
                        (set! tmp.90 (bitwise-and tmp.90 7))
                        (set! tmp.64 tmp.90))
                      (= tmp.64 0))
                  (set! tmp.63 14)
                  (set! tmp.63 6))
                (!= tmp.63 6))
            (begin
              (set! tmp.91 tmp.23)
              (set! tmp.91 (- tmp.91 tmp.24))
              (set! rax tmp.91)
              (jump tmp-ra.77 rbp rax))
            (begin (set! rax 830) (jump tmp-ra.77 rbp rax)))
          (begin (set! rax 830) (jump tmp-ra.77 rbp rax)))))
    (define L.+.10
      ((new-frames ()))
      (begin
        (set! tmp-ra.78 r15)
        (set! tmp.21 rdi)
        (set! tmp.22 rsi)
        (if (begin
              (if (begin
                    (begin
                      (set! tmp.92 tmp.22)
                      (set! tmp.92 (bitwise-and tmp.92 7))
                      (set! tmp.66 tmp.92))
                    (= tmp.66 0))
                (set! tmp.65 14)
                (set! tmp.65 6))
              (!= tmp.65 6))
          (if (begin
                (if (begin
                      (begin
                        (set! tmp.93 tmp.21)
                        (set! tmp.93 (bitwise-and tmp.93 7))
                        (set! tmp.68 tmp.93))
                      (= tmp.68 0))
                  (set! tmp.67 14)
                  (set! tmp.67 6))
                (!= tmp.67 6))
            (begin
              (set! tmp.94 tmp.21)
              (set! tmp.94 (+ tmp.94 tmp.22))
              (set! rax tmp.94)
              (jump tmp-ra.78 rbp rax))
            (begin (set! rax 574) (jump tmp-ra.78 rbp rax)))
          (begin (set! rax 574) (jump tmp-ra.78 rbp rax)))))
    (define L.cons.9
      ((new-frames ()))
      (begin
        (set! tmp-ra.79 r15)
        (set! tmp.51 rdi)
        (set! tmp.52 rsi)
        (set! tmp.69 (alloc 16))
        (set! tmp.95 tmp.69)
        (set! tmp.95 (+ tmp.95 1))
        (set! tmp.55 tmp.95)
        (mset! tmp.55 -1 tmp.51)
        (mset! tmp.55 7 tmp.52)
        (set! rax tmp.55)
        (jump tmp-ra.79 rbp rax)))
    (define L.fun/pair9174.4
      ((new-frames ()))
      (begin
        (set! tmp-ra.80 r15)
        (set! rsi 3672)
        (set! rdi 1016)
        (set! r15 tmp-ra.80)
        (jump L.cons.9 rbp r15 rdi rsi)))
    (define L.fun/ascii-char9175.5
      ((new-frames ()))
      (begin (set! tmp-ra.81 r15) (set! rax 23598) (jump tmp-ra.81 rbp rax)))
    (define L.fun/empty9176.6
      ((new-frames ()))
      (begin (set! tmp-ra.82 r15) (set! rax 22) (jump tmp-ra.82 rbp rax)))
    (define L.fun/error9177.7
      ((new-frames ()))
      (begin (set! tmp-ra.83 r15) (set! rax 17470) (jump tmp-ra.83 rbp rax)))
    (begin
      (set! tmp-ra.84 r15)
      (return-point L.rp.13
        (begin (set! r15 L.rp.13) (jump L.fun/pair9174.4 rbp r15)))
      (set! pair0.5 rax)
      (return-point L.rp.14
        (begin (set! r15 L.rp.14) (jump L.fun/ascii-char9175.5 rbp r15)))
      (set! ascii-char1.4 rax)
      (return-point L.rp.15
        (begin (set! r15 L.rp.15) (jump L.fun/empty9176.6 rbp r15)))
      (set! empty2.3 rax)
      (return-point L.rp.16
        (begin (set! r15 L.rp.16) (jump L.fun/error9177.7 rbp r15)))
      (set! error3.2 rax)
      (return-point L.rp.17
        (begin
          (set! rsi 256)
          (set! rdi 1312)
          (set! r15 L.rp.17)
          (jump L.+.10 rbp r15 rdi rsi)))
      (set! tmp.71 rax)
      (return-point L.rp.18
        (begin
          (set! rsi 320)
          (set! rdi 1592)
          (set! r15 L.rp.18)
          (jump L.-.11 rbp r15 rdi rsi)))
      (set! tmp.72 rax)
      (return-point L.rp.19
        (begin
          (set! rsi tmp.72)
          (set! rdi tmp.71)
          (set! r15 L.rp.19)
          (jump L.+.10 rbp r15 rdi rsi)))
      (set! tmp.70 rax)
      (return-point L.rp.20
        (begin
          (set! rsi 456)
          (set! rdi 1512)
          (set! r15 L.rp.20)
          (jump L.*.12 rbp r15 rdi rsi)))
      (set! tmp.74 rax)
      (return-point L.rp.21
        (begin
          (set! rsi 1776)
          (set! rdi 280)
          (set! r15 L.rp.21)
          (jump L.+.10 rbp r15 rdi rsi)))
      (set! tmp.75 rax)
      (return-point L.rp.22
        (begin
          (set! rsi tmp.75)
          (set! rdi tmp.74)
          (set! r15 L.rp.22)
          (jump L.-.11 rbp r15 rdi rsi)))
      (set! tmp.73 rax)
      (return-point L.rp.23
        (begin
          (set! rsi tmp.73)
          (set! rdi tmp.70)
          (set! r15 L.rp.23)
          (jump L.*.12 rbp r15 rdi rsi)))
      (set! fixnum4.1 rax)
      (set! rax error3.2)
      (jump tmp-ra.84 rbp rax))))
(check-by-interp
 '(module
    ((new-frames (() () () () () () () () () () ())))
    (define L.*.11
      ((new-frames ()))
      (begin
        (set! tmp-ra.74 r15)
        (set! tmp.19 rdi)
        (set! tmp.20 rsi)
        (if (begin
              (if (begin
                    (begin
                      (set! tmp.82 tmp.20)
                      (set! tmp.82 (bitwise-and tmp.82 7))
                      (set! tmp.56 tmp.82))
                    (= tmp.56 0))
                (set! tmp.55 14)
                (set! tmp.55 6))
              (!= tmp.55 6))
          (if (begin
                (if (begin
                      (begin
                        (set! tmp.83 tmp.19)
                        (set! tmp.83 (bitwise-and tmp.83 7))
                        (set! tmp.58 tmp.83))
                      (= tmp.58 0))
                  (set! tmp.57 14)
                  (set! tmp.57 6))
                (!= tmp.57 6))
            (begin
              (set! tmp.84 tmp.20)
              (set! tmp.84 (arithmetic-shift-right tmp.84 3))
              (set! tmp.59 tmp.84)
              (set! tmp.85 tmp.19)
              (set! tmp.85 (* tmp.85 tmp.59))
              (set! rax tmp.85)
              (jump tmp-ra.74 rbp rax))
            (begin (set! rax 318) (jump tmp-ra.74 rbp rax)))
          (begin (set! rax 318) (jump tmp-ra.74 rbp rax)))))
    (define L.-.10
      ((new-frames ()))
      (begin
        (set! tmp-ra.75 r15)
        (set! tmp.23 rdi)
        (set! tmp.24 rsi)
        (if (begin
              (if (begin
                    (begin
                      (set! tmp.86 tmp.24)
                      (set! tmp.86 (bitwise-and tmp.86 7))
                      (set! tmp.61 tmp.86))
                    (= tmp.61 0))
                (set! tmp.60 14)
                (set! tmp.60 6))
              (!= tmp.60 6))
          (if (begin
                (if (begin
                      (begin
                        (set! tmp.87 tmp.23)
                        (set! tmp.87 (bitwise-and tmp.87 7))
                        (set! tmp.63 tmp.87))
                      (= tmp.63 0))
                  (set! tmp.62 14)
                  (set! tmp.62 6))
                (!= tmp.62 6))
            (begin
              (set! tmp.88 tmp.23)
              (set! tmp.88 (- tmp.88 tmp.24))
              (set! rax tmp.88)
              (jump tmp-ra.75 rbp rax))
            (begin (set! rax 830) (jump tmp-ra.75 rbp rax)))
          (begin (set! rax 830) (jump tmp-ra.75 rbp rax)))))
    (define L.+.9
      ((new-frames ()))
      (begin
        (set! tmp-ra.76 r15)
        (set! tmp.21 rdi)
        (set! tmp.22 rsi)
        (if (begin
              (if (begin
                    (begin
                      (set! tmp.89 tmp.22)
                      (set! tmp.89 (bitwise-and tmp.89 7))
                      (set! tmp.65 tmp.89))
                    (= tmp.65 0))
                (set! tmp.64 14)
                (set! tmp.64 6))
              (!= tmp.64 6))
          (if (begin
                (if (begin
                      (begin
                        (set! tmp.90 tmp.21)
                        (set! tmp.90 (bitwise-and tmp.90 7))
                        (set! tmp.67 tmp.90))
                      (= tmp.67 0))
                  (set! tmp.66 14)
                  (set! tmp.66 6))
                (!= tmp.66 6))
            (begin
              (set! tmp.91 tmp.21)
              (set! tmp.91 (+ tmp.91 tmp.22))
              (set! rax tmp.91)
              (jump tmp-ra.76 rbp rax))
            (begin (set! rax 574) (jump tmp-ra.76 rbp rax)))
          (begin (set! rax 574) (jump tmp-ra.76 rbp rax)))))
    (define L.fun/error9704.4
      ((new-frames ()))
      (begin (set! tmp-ra.77 r15) (set! rax 56382) (jump tmp-ra.77 rbp rax)))
    (define L.fun/void9703.5
      ((new-frames ()))
      (begin (set! tmp-ra.78 r15) (set! rax 30) (jump tmp-ra.78 rbp rax)))
    (define L.fun/void9702.6
      ((new-frames ()))
      (begin (set! tmp-ra.79 r15) (set! rax 30) (jump tmp-ra.79 rbp rax)))
    (define L.fun/empty9705.7
      ((new-frames ()))
      (begin (set! tmp-ra.80 r15) (set! rax 22) (jump tmp-ra.80 rbp rax)))
    (begin
      (set! tmp-ra.81 r15)
      (return-point L.rp.12
        (begin
          (set! rsi 992)
          (set! rdi 904)
          (set! r15 L.rp.12)
          (jump L.+.9 rbp r15 rdi rsi)))
      (set! tmp.69 rax)
      (return-point L.rp.13
        (begin
          (set! rsi 1512)
          (set! rdi 1656)
          (set! r15 L.rp.13)
          (jump L.-.10 rbp r15 rdi rsi)))
      (set! tmp.70 rax)
      (return-point L.rp.14
        (begin
          (set! rsi tmp.70)
          (set! rdi tmp.69)
          (set! r15 L.rp.14)
          (jump L.-.10 rbp r15 rdi rsi)))
      (set! tmp.68 rax)
      (return-point L.rp.15
        (begin
          (set! rsi 1624)
          (set! rdi 1080)
          (set! r15 L.rp.15)
          (jump L.+.9 rbp r15 rdi rsi)))
      (set! tmp.72 rax)
      (return-point L.rp.16
        (begin
          (set! rsi 240)
          (set! rdi 296)
          (set! r15 L.rp.16)
          (jump L.*.11 rbp r15 rdi rsi)))
      (set! tmp.73 rax)
      (return-point L.rp.17
        (begin
          (set! rsi tmp.73)
          (set! rdi tmp.72)
          (set! r15 L.rp.17)
          (jump L.+.9 rbp r15 rdi rsi)))
      (set! tmp.71 rax)
      (return-point L.rp.18
        (begin
          (set! rsi tmp.71)
          (set! rdi tmp.68)
          (set! r15 L.rp.18)
          (jump L.-.10 rbp r15 rdi rsi)))
      (set! fixnum0.5 rax)
      (return-point L.rp.19
        (begin (set! r15 L.rp.19) (jump L.fun/void9702.6 rbp r15)))
      (set! void1.4 rax)
      (return-point L.rp.20
        (begin (set! r15 L.rp.20) (jump L.fun/void9703.5 rbp r15)))
      (set! void2.3 rax)
      (return-point L.rp.21
        (begin (set! r15 L.rp.21) (jump L.fun/error9704.4 rbp r15)))
      (set! error3.2 rax)
      (return-point L.rp.22
        (begin (set! r15 L.rp.22) (jump L.fun/empty9705.7 rbp r15)))
      (set! empty4.1 rax)
      (set! rax error3.2)
      (jump tmp-ra.81 rbp rax))))
(check-by-interp
 '(module
    ((new-frames (() () () () () () () () () () () () () () () () ())))
    (define L.*.11
      ((new-frames ()))
      (begin
        (set! tmp-ra.82 r15)
        (set! tmp.19 rdi)
        (set! tmp.20 rsi)
        (if (begin
              (if (begin
                    (begin
                      (set! tmp.90 tmp.20)
                      (set! tmp.90 (bitwise-and tmp.90 7))
                      (set! tmp.57 tmp.90))
                    (= tmp.57 0))
                (set! tmp.56 14)
                (set! tmp.56 6))
              (!= tmp.56 6))
          (if (begin
                (if (begin
                      (begin
                        (set! tmp.91 tmp.19)
                        (set! tmp.91 (bitwise-and tmp.91 7))
                        (set! tmp.59 tmp.91))
                      (= tmp.59 0))
                  (set! tmp.58 14)
                  (set! tmp.58 6))
                (!= tmp.58 6))
            (begin
              (set! tmp.92 tmp.20)
              (set! tmp.92 (arithmetic-shift-right tmp.92 3))
              (set! tmp.60 tmp.92)
              (set! tmp.93 tmp.19)
              (set! tmp.93 (* tmp.93 tmp.60))
              (set! rax tmp.93)
              (jump tmp-ra.82 rbp rax))
            (begin (set! rax 318) (jump tmp-ra.82 rbp rax)))
          (begin (set! rax 318) (jump tmp-ra.82 rbp rax)))))
    (define L.+.10
      ((new-frames ()))
      (begin
        (set! tmp-ra.83 r15)
        (set! tmp.21 rdi)
        (set! tmp.22 rsi)
        (if (begin
              (if (begin
                    (begin
                      (set! tmp.94 tmp.22)
                      (set! tmp.94 (bitwise-and tmp.94 7))
                      (set! tmp.62 tmp.94))
                    (= tmp.62 0))
                (set! tmp.61 14)
                (set! tmp.61 6))
              (!= tmp.61 6))
          (if (begin
                (if (begin
                      (begin
                        (set! tmp.95 tmp.21)
                        (set! tmp.95 (bitwise-and tmp.95 7))
                        (set! tmp.64 tmp.95))
                      (= tmp.64 0))
                  (set! tmp.63 14)
                  (set! tmp.63 6))
                (!= tmp.63 6))
            (begin
              (set! tmp.96 tmp.21)
              (set! tmp.96 (+ tmp.96 tmp.22))
              (set! rax tmp.96)
              (jump tmp-ra.83 rbp rax))
            (begin (set! rax 574) (jump tmp-ra.83 rbp rax)))
          (begin (set! rax 574) (jump tmp-ra.83 rbp rax)))))
    (define L.-.9
      ((new-frames ()))
      (begin
        (set! tmp-ra.84 r15)
        (set! tmp.23 rdi)
        (set! tmp.24 rsi)
        (if (begin
              (if (begin
                    (begin
                      (set! tmp.97 tmp.24)
                      (set! tmp.97 (bitwise-and tmp.97 7))
                      (set! tmp.66 tmp.97))
                    (= tmp.66 0))
                (set! tmp.65 14)
                (set! tmp.65 6))
              (!= tmp.65 6))
          (if (begin
                (if (begin
                      (begin
                        (set! tmp.98 tmp.23)
                        (set! tmp.98 (bitwise-and tmp.98 7))
                        (set! tmp.68 tmp.98))
                      (= tmp.68 0))
                  (set! tmp.67 14)
                  (set! tmp.67 6))
                (!= tmp.67 6))
            (begin
              (set! tmp.99 tmp.23)
              (set! tmp.99 (- tmp.99 tmp.24))
              (set! rax tmp.99)
              (jump tmp-ra.84 rbp rax))
            (begin (set! rax 830) (jump tmp-ra.84 rbp rax)))
          (begin (set! rax 830) (jump tmp-ra.84 rbp rax)))))
    (define L.cons.8
      ((new-frames ()))
      (begin
        (set! tmp-ra.85 r15)
        (set! tmp.51 rdi)
        (set! tmp.52 rsi)
        (set! tmp.69 (alloc 16))
        (set! tmp.100 tmp.69)
        (set! tmp.100 (+ tmp.100 1))
        (set! tmp.55 tmp.100)
        (mset! tmp.55 -1 tmp.51)
        (mset! tmp.55 7 tmp.52)
        (set! rax tmp.55)
        (jump tmp-ra.85 rbp rax)))
    (define L.fun/pair9710.4
      ((new-frames ()))
      (begin
        (set! tmp-ra.86 r15)
        (set! rsi 2640)
        (set! rdi 792)
        (set! r15 tmp-ra.86)
        (jump L.cons.8 rbp r15 rdi rsi)))
    (define L.fun/error9708.5
      ((new-frames ()))
      (begin (set! tmp-ra.87 r15) (set! rax 54846) (jump tmp-ra.87 rbp rax)))
    (define L.fun/void9709.6
      ((new-frames ()))
      (begin (set! tmp-ra.88 r15) (set! rax 30) (jump tmp-ra.88 rbp rax)))
    (begin
      (set! tmp-ra.89 r15)
      (return-point L.rp.12
        (begin (set! r15 L.rp.12) (jump L.fun/error9708.5 rbp r15)))
      (set! error0.5 rax)
      (return-point L.rp.13
        (begin (set! r15 L.rp.13) (jump L.fun/void9709.6 rbp r15)))
      (set! void1.4 rax)
      (return-point L.rp.14
        (begin
          (set! rsi 152)
          (set! rdi 2000)
          (set! r15 L.rp.14)
          (jump L.-.9 rbp r15 rdi rsi)))
      (set! tmp.71 rax)
      (return-point L.rp.15
        (begin
          (set! rsi 416)
          (set! rdi 784)
          (set! r15 L.rp.15)
          (jump L.-.9 rbp r15 rdi rsi)))
      (set! tmp.72 rax)
      (return-point L.rp.16
        (begin
          (set! rsi tmp.72)
          (set! rdi tmp.71)
          (set! r15 L.rp.16)
          (jump L.-.9 rbp r15 rdi rsi)))
      (set! tmp.70 rax)
      (return-point L.rp.17
        (begin
          (set! rsi 240)
          (set! rdi 1824)
          (set! r15 L.rp.17)
          (jump L.-.9 rbp r15 rdi rsi)))
      (set! tmp.74 rax)
      (return-point L.rp.18
        (begin
          (set! rsi 312)
          (set! rdi 320)
          (set! r15 L.rp.18)
          (jump L.+.10 rbp r15 rdi rsi)))
      (set! tmp.75 rax)
      (return-point L.rp.19
        (begin
          (set! rsi tmp.75)
          (set! rdi tmp.74)
          (set! r15 L.rp.19)
          (jump L.+.10 rbp r15 rdi rsi)))
      (set! tmp.73 rax)
      (return-point L.rp.20
        (begin
          (set! rsi tmp.73)
          (set! rdi tmp.70)
          (set! r15 L.rp.20)
          (jump L.+.10 rbp r15 rdi rsi)))
      (set! fixnum2.3 rax)
      (return-point L.rp.21
        (begin
          (set! rsi 992)
          (set! rdi 216)
          (set! r15 L.rp.21)
          (jump L.*.11 rbp r15 rdi rsi)))
      (set! tmp.77 rax)
      (return-point L.rp.22
        (begin
          (set! rsi 568)
          (set! rdi 168)
          (set! r15 L.rp.22)
          (jump L.*.11 rbp r15 rdi rsi)))
      (set! tmp.78 rax)
      (return-point L.rp.23
        (begin
          (set! rsi tmp.78)
          (set! rdi tmp.77)
          (set! r15 L.rp.23)
          (jump L.+.10 rbp r15 rdi rsi)))
      (set! tmp.76 rax)
      (return-point L.rp.24
        (begin
          (set! rsi 1352)
          (set! rdi 1248)
          (set! r15 L.rp.24)
          (jump L.+.10 rbp r15 rdi rsi)))
      (set! tmp.80 rax)
      (return-point L.rp.25
        (begin
          (set! rsi 1632)
          (set! rdi 168)
          (set! r15 L.rp.25)
          (jump L.-.9 rbp r15 rdi rsi)))
      (set! tmp.81 rax)
      (return-point L.rp.26
        (begin
          (set! rsi tmp.81)
          (set! rdi tmp.80)
          (set! r15 L.rp.26)
          (jump L.+.10 rbp r15 rdi rsi)))
      (set! tmp.79 rax)
      (return-point L.rp.27
        (begin
          (set! rsi tmp.79)
          (set! rdi tmp.76)
          (set! r15 L.rp.27)
          (jump L.*.11 rbp r15 rdi rsi)))
      (set! fixnum3.2 rax)
      (return-point L.rp.28
        (begin (set! r15 L.rp.28) (jump L.fun/pair9710.4 rbp r15)))
      (set! pair4.1 rax)
      (set! rax void1.4)
      (jump tmp-ra.89 rbp rax))))
(check-by-interp
 '(module
    ((new-frames (() () () () () () () () () () ())))
    (define L.*.13
      ((new-frames ()))
      (begin
        (set! tmp-ra.76 r15)
        (set! tmp.19 rdi)
        (set! tmp.20 rsi)
        (if (begin
              (if (begin
                    (begin
                      (set! tmp.86 tmp.20)
                      (set! tmp.86 (bitwise-and tmp.86 7))
                      (set! tmp.57 tmp.86))
                    (= tmp.57 0))
                (set! tmp.56 14)
                (set! tmp.56 6))
              (!= tmp.56 6))
          (if (begin
                (if (begin
                      (begin
                        (set! tmp.87 tmp.19)
                        (set! tmp.87 (bitwise-and tmp.87 7))
                        (set! tmp.59 tmp.87))
                      (= tmp.59 0))
                  (set! tmp.58 14)
                  (set! tmp.58 6))
                (!= tmp.58 6))
            (begin
              (set! tmp.88 tmp.20)
              (set! tmp.88 (arithmetic-shift-right tmp.88 3))
              (set! tmp.60 tmp.88)
              (set! tmp.89 tmp.19)
              (set! tmp.89 (* tmp.89 tmp.60))
              (set! rax tmp.89)
              (jump tmp-ra.76 rbp rax))
            (begin (set! rax 318) (jump tmp-ra.76 rbp rax)))
          (begin (set! rax 318) (jump tmp-ra.76 rbp rax)))))
    (define L.-.12
      ((new-frames ()))
      (begin
        (set! tmp-ra.77 r15)
        (set! tmp.23 rdi)
        (set! tmp.24 rsi)
        (if (begin
              (if (begin
                    (begin
                      (set! tmp.90 tmp.24)
                      (set! tmp.90 (bitwise-and tmp.90 7))
                      (set! tmp.62 tmp.90))
                    (= tmp.62 0))
                (set! tmp.61 14)
                (set! tmp.61 6))
              (!= tmp.61 6))
          (if (begin
                (if (begin
                      (begin
                        (set! tmp.91 tmp.23)
                        (set! tmp.91 (bitwise-and tmp.91 7))
                        (set! tmp.64 tmp.91))
                      (= tmp.64 0))
                  (set! tmp.63 14)
                  (set! tmp.63 6))
                (!= tmp.63 6))
            (begin
              (set! tmp.92 tmp.23)
              (set! tmp.92 (- tmp.92 tmp.24))
              (set! rax tmp.92)
              (jump tmp-ra.77 rbp rax))
            (begin (set! rax 830) (jump tmp-ra.77 rbp rax)))
          (begin (set! rax 830) (jump tmp-ra.77 rbp rax)))))
    (define L.+.11
      ((new-frames ()))
      (begin
        (set! tmp-ra.78 r15)
        (set! tmp.21 rdi)
        (set! tmp.22 rsi)
        (if (begin
              (if (begin
                    (begin
                      (set! tmp.93 tmp.22)
                      (set! tmp.93 (bitwise-and tmp.93 7))
                      (set! tmp.66 tmp.93))
                    (= tmp.66 0))
                (set! tmp.65 14)
                (set! tmp.65 6))
              (!= tmp.65 6))
          (if (begin
                (if (begin
                      (begin
                        (set! tmp.94 tmp.21)
                        (set! tmp.94 (bitwise-and tmp.94 7))
                        (set! tmp.68 tmp.94))
                      (= tmp.68 0))
                  (set! tmp.67 14)
                  (set! tmp.67 6))
                (!= tmp.67 6))
            (begin
              (set! tmp.95 tmp.21)
              (set! tmp.95 (+ tmp.95 tmp.22))
              (set! rax tmp.95)
              (jump tmp-ra.78 rbp rax))
            (begin (set! rax 574) (jump tmp-ra.78 rbp rax)))
          (begin (set! rax 574) (jump tmp-ra.78 rbp rax)))))
    (define L.cons.10
      ((new-frames ()))
      (begin
        (set! tmp-ra.79 r15)
        (set! tmp.51 rdi)
        (set! tmp.52 rsi)
        (set! tmp.69 (alloc 16))
        (set! tmp.96 tmp.69)
        (set! tmp.96 (+ tmp.96 1))
        (set! tmp.55 tmp.96)
        (mset! tmp.55 -1 tmp.51)
        (mset! tmp.55 7 tmp.52)
        (set! rax tmp.55)
        (jump tmp-ra.79 rbp rax)))
    (define L.fun/void9976.4
      ((new-frames ()))
      (begin (set! tmp-ra.80 r15) (set! rax 30) (jump tmp-ra.80 rbp rax)))
    (define L.fun/pair9973.5
      ((new-frames ()))
      (begin
        (set! tmp-ra.81 r15)
        (set! rsi 3448)
        (set! rdi 1352)
        (set! r15 tmp-ra.81)
        (jump L.cons.10 rbp r15 rdi rsi)))
    (define L.fun/empty9975.6
      ((new-frames ()))
      (begin (set! tmp-ra.82 r15) (set! rax 22) (jump tmp-ra.82 rbp rax)))
    (define L.fun/void9974.7
      ((new-frames ()))
      (begin (set! tmp-ra.83 r15) (set! rax 30) (jump tmp-ra.83 rbp rax)))
    (define L.fun/ascii-char9977.8
      ((new-frames ()))
      (begin (set! tmp-ra.84 r15) (set! rax 20782) (jump tmp-ra.84 rbp rax)))
    (begin
      (set! tmp-ra.85 r15)
      (return-point L.rp.14
        (begin (set! r15 L.rp.14) (jump L.fun/pair9973.5 rbp r15)))
      (set! pair0.5 rax)
      (return-point L.rp.15
        (begin (set! r15 L.rp.15) (jump L.fun/void9974.7 rbp r15)))
      (set! void1.4 rax)
      (return-point L.rp.16
        (begin (set! r15 L.rp.16) (jump L.fun/empty9975.6 rbp r15)))
      (set! empty2.3 rax)
      (return-point L.rp.17
        (begin (set! r15 L.rp.17) (jump L.fun/void9976.4 rbp r15)))
      (set! void3.2 rax)
      (return-point L.rp.18
        (begin
          (set! rsi 1288)
          (set! rdi 1608)
          (set! r15 L.rp.18)
          (jump L.+.11 rbp r15 rdi rsi)))
      (set! tmp.71 rax)
      (return-point L.rp.19
        (begin
          (set! rsi 1528)
          (set! rdi 1992)
          (set! r15 L.rp.19)
          (jump L.-.12 rbp r15 rdi rsi)))
      (set! tmp.72 rax)
      (return-point L.rp.20
        (begin
          (set! rsi tmp.72)
          (set! rdi tmp.71)
          (set! r15 L.rp.20)
          (jump L.+.11 rbp r15 rdi rsi)))
      (set! tmp.70 rax)
      (return-point L.rp.21
        (begin
          (set! rsi 1152)
          (set! rdi 688)
          (set! r15 L.rp.21)
          (jump L.-.12 rbp r15 rdi rsi)))
      (set! tmp.74 rax)
      (return-point L.rp.22
        (begin
          (set! rsi 1848)
          (set! rdi 1048)
          (set! r15 L.rp.22)
          (jump L.*.13 rbp r15 rdi rsi)))
      (set! tmp.75 rax)
      (return-point L.rp.23
        (begin
          (set! rsi tmp.75)
          (set! rdi tmp.74)
          (set! r15 L.rp.23)
          (jump L.+.11 rbp r15 rdi rsi)))
      (set! tmp.73 rax)
      (return-point L.rp.24
        (begin
          (set! rsi tmp.73)
          (set! rdi tmp.70)
          (set! r15 L.rp.24)
          (jump L.-.12 rbp r15 rdi rsi)))
      (set! fixnum4.1 rax)
      (set! r15 tmp-ra.85)
      (jump L.fun/ascii-char9977.8 rbp r15))))
(check-by-interp
 '(module
    ((new-frames (() () () () () ())))
    (define L.fun/void15785.4
      ((new-frames ()))
      (begin
        (set! tmp-ra.56 r15)
        (set! r15 tmp-ra.56)
        (jump L.fun/void15786.9 rbp r15)))
    (define L.fun/empty15784.5
      ((new-frames ()))
      (begin (set! tmp-ra.57 r15) (set! rax 22) (jump tmp-ra.57 rbp rax)))
    (define L.fun/error15778.6
      ((new-frames ()))
      (begin (set! tmp-ra.58 r15) (set! rax 4670) (jump tmp-ra.58 rbp rax)))
    (define L.fun/ascii-char15782.7
      ((new-frames ()))
      (begin (set! tmp-ra.59 r15) (set! rax 29742) (jump tmp-ra.59 rbp rax)))
    (define L.fun/error15777.8
      ((new-frames ()))
      (begin
        (set! tmp-ra.60 r15)
        (set! r15 tmp-ra.60)
        (jump L.fun/error15778.6 rbp r15)))
    (define L.fun/void15786.9
      ((new-frames ()))
      (begin (set! tmp-ra.61 r15) (set! rax 30) (jump tmp-ra.61 rbp rax)))
    (define L.fun/ascii-char15781.10
      ((new-frames ()))
      (begin
        (set! tmp-ra.62 r15)
        (set! r15 tmp-ra.62)
        (jump L.fun/ascii-char15782.7 rbp r15)))
    (define L.fun/ascii-char15779.11
      ((new-frames ()))
      (begin
        (set! tmp-ra.63 r15)
        (set! r15 tmp-ra.63)
        (jump L.fun/ascii-char15780.14 rbp r15)))
    (define L.fun/empty15775.12
      ((new-frames ()))
      (begin
        (set! tmp-ra.64 r15)
        (set! r15 tmp-ra.64)
        (jump L.fun/empty15776.15 rbp r15)))
    (define L.fun/empty15783.13
      ((new-frames ()))
      (begin
        (set! tmp-ra.65 r15)
        (set! r15 tmp-ra.65)
        (jump L.fun/empty15784.5 rbp r15)))
    (define L.fun/ascii-char15780.14
      ((new-frames ()))
      (begin (set! tmp-ra.66 r15) (set! rax 21038) (jump tmp-ra.66 rbp rax)))
    (define L.fun/empty15776.15
      ((new-frames ()))
      (begin (set! tmp-ra.67 r15) (set! rax 22) (jump tmp-ra.67 rbp rax)))
    (begin
      (set! tmp-ra.68 r15)
      (return-point L.rp.17
        (begin (set! r15 L.rp.17) (jump L.fun/empty15775.12 rbp r15)))
      (set! empty0.6 rax)
      (return-point L.rp.18
        (begin (set! r15 L.rp.18) (jump L.fun/error15777.8 rbp r15)))
      (set! error1.5 rax)
      (return-point L.rp.19
        (begin (set! r15 L.rp.19) (jump L.fun/ascii-char15779.11 rbp r15)))
      (set! ascii-char2.4 rax)
      (return-point L.rp.20
        (begin (set! r15 L.rp.20) (jump L.fun/ascii-char15781.10 rbp r15)))
      (set! ascii-char3.3 rax)
      (return-point L.rp.21
        (begin (set! r15 L.rp.21) (jump L.fun/empty15783.13 rbp r15)))
      (set! empty4.2 rax)
      (return-point L.rp.22
        (begin (set! r15 L.rp.22) (jump L.fun/void15785.4 rbp r15)))
      (set! void5.1 rax)
      (set! rax void5.1)
      (jump tmp-ra.68 rbp rax))))
(check-by-interp
 '(module
    ((new-frames (() () () () () () () ())))
    (define L.void?.16
      ((new-frames ()))
      (begin
        (set! tmp-ra.60 r15)
        (set! tmp.46 rdi)
        (if (begin
              (begin
                (set! tmp.73 tmp.46)
                (set! tmp.73 (bitwise-and tmp.73 255))
                (set! tmp.56 tmp.73))
              (= tmp.56 30))
          (begin (set! rax 14) (jump tmp-ra.60 rbp rax))
          (begin (set! rax 6) (jump tmp-ra.60 rbp rax)))))
    (define L.boolean?.15
      ((new-frames ()))
      (begin
        (set! tmp-ra.61 r15)
        (set! tmp.44 rdi)
        (if (begin
              (begin
                (set! tmp.74 tmp.44)
                (set! tmp.74 (bitwise-and tmp.74 247))
                (set! tmp.57 tmp.74))
              (= tmp.57 6))
          (begin (set! rax 14) (jump tmp-ra.61 rbp rax))
          (begin (set! rax 6) (jump tmp-ra.61 rbp rax)))))
    (define L.fun/any18974.4
      ((new-frames ()))
      (begin (set! tmp-ra.62 r15) (set! rax 30) (jump tmp-ra.62 rbp rax)))
    (define L.fun/void18977.5
      ((new-frames ()))
      (begin
        (set! tmp-ra.63 r15)
        (set! r15 tmp-ra.63)
        (jump L.fun/void18978.12 rbp r15)))
    (define L.fun/ascii-char18970.6
      ((new-frames ()))
      (begin (set! tmp-ra.64 r15) (set! rax 23854) (jump tmp-ra.64 rbp rax)))
    (define L.fun/ascii-char18969.7
      ((new-frames ()))
      (begin
        (set! tmp-ra.65 r15)
        (set! r15 tmp-ra.65)
        (jump L.fun/ascii-char18970.6 rbp r15)))
    (define L.fun/error18976.8
      ((new-frames ()))
      (begin (set! tmp-ra.66 r15) (set! rax 39742) (jump tmp-ra.66 rbp rax)))
    (define L.fun/void18971.9
      ((new-frames ()))
      (begin
        (set! tmp-ra.67 r15)
        (set! r15 tmp-ra.67)
        (jump L.fun/void18972.10 rbp r15)))
    (define L.fun/void18972.10
      ((new-frames ()))
      (begin (set! tmp-ra.68 r15) (set! rax 30) (jump tmp-ra.68 rbp rax)))
    (define L.fun/error18975.11
      ((new-frames ()))
      (begin
        (set! tmp-ra.69 r15)
        (set! r15 tmp-ra.69)
        (jump L.fun/error18976.8 rbp r15)))
    (define L.fun/void18978.12
      ((new-frames ()))
      (begin (set! tmp-ra.70 r15) (set! rax 30) (jump tmp-ra.70 rbp rax)))
    (define L.fun/any18973.13
      ((new-frames ()))
      (begin (set! tmp-ra.71 r15) (set! rax 60990) (jump tmp-ra.71 rbp rax)))
    (begin
      (set! tmp-ra.72 r15)
      (return-point L.rp.17
        (begin (set! r15 L.rp.17) (jump L.fun/ascii-char18969.7 rbp r15)))
      (set! ascii-char0.6 rax)
      (return-point L.rp.18
        (begin (set! r15 L.rp.18) (jump L.fun/void18971.9 rbp r15)))
      (set! void1.5 rax)
      (return-point L.rp.19
        (begin (set! r15 L.rp.19) (jump L.fun/any18973.13 rbp r15)))
      (set! tmp.58 rax)
      (return-point L.rp.20
        (begin
          (set! rdi tmp.58)
          (set! r15 L.rp.20)
          (jump L.boolean?.15 rbp r15 rdi)))
      (set! boolean2.4 rax)
      (return-point L.rp.21
        (begin (set! r15 L.rp.21) (jump L.fun/any18974.4 rbp r15)))
      (set! tmp.59 rax)
      (return-point L.rp.22
        (begin
          (set! rdi tmp.59)
          (set! r15 L.rp.22)
          (jump L.void?.16 rbp r15 rdi)))
      (set! boolean3.3 rax)
      (return-point L.rp.23
        (begin (set! r15 L.rp.23) (jump L.fun/error18975.11 rbp r15)))
      (set! error4.2 rax)
      (return-point L.rp.24
        (begin (set! r15 L.rp.24) (jump L.fun/void18977.5 rbp r15)))
      (set! void5.1 rax)
      (set! rax ascii-char0.6)
      (jump tmp-ra.72 rbp rax))))
(check-by-interp
 '(module
    ((new-frames
      (()
       ()
       ()
       ()
       ()
       ()
       ()
       ()
       ()
       ()
       ()
       ()
       ()
       ()
       ()
       ()
       ()
       ()
       ()
       ()
       ()
       ()
       ()
       ()
       ()
       ()
       ()
       ()
       ()
       ()
       ()
       ()
       ()
       ()
       ()
       ()
       ()
       ()
       ()
       ()
       ()
       ()
       ()
       ()
       ()
       ()
       ()
       ()
       ())))
    (define L.boolean?.15
      ((new-frames ()))
      (begin
        (set! tmp-ra.113 r15)
        (set! tmp.44 rdi)
        (if (begin
              (begin
                (set! tmp.125 tmp.44)
                (set! tmp.125 (bitwise-and tmp.125 247))
                (set! tmp.56 tmp.125))
              (= tmp.56 6))
          (begin (set! rax 14) (jump tmp-ra.113 rbp rax))
          (begin (set! rax 6) (jump tmp-ra.113 rbp rax)))))
    (define L.-.14
      ((new-frames ()))
      (begin
        (set! tmp-ra.114 r15)
        (set! tmp.24 rdi)
        (set! tmp.25 rsi)
        (if (begin
              (if (begin
                    (begin
                      (set! tmp.126 tmp.25)
                      (set! tmp.126 (bitwise-and tmp.126 7))
                      (set! tmp.58 tmp.126))
                    (= tmp.58 0))
                (set! tmp.57 14)
                (set! tmp.57 6))
              (!= tmp.57 6))
          (if (begin
                (if (begin
                      (begin
                        (set! tmp.127 tmp.24)
                        (set! tmp.127 (bitwise-and tmp.127 7))
                        (set! tmp.60 tmp.127))
                      (= tmp.60 0))
                  (set! tmp.59 14)
                  (set! tmp.59 6))
                (!= tmp.59 6))
            (begin
              (set! tmp.128 tmp.24)
              (set! tmp.128 (- tmp.128 tmp.25))
              (set! rax tmp.128)
              (jump tmp-ra.114 rbp rax))
            (begin (set! rax 830) (jump tmp-ra.114 rbp rax)))
          (begin (set! rax 830) (jump tmp-ra.114 rbp rax)))))
    (define L.*.13
      ((new-frames ()))
      (begin
        (set! tmp-ra.115 r15)
        (set! tmp.20 rdi)
        (set! tmp.21 rsi)
        (if (begin
              (if (begin
                    (begin
                      (set! tmp.129 tmp.21)
                      (set! tmp.129 (bitwise-and tmp.129 7))
                      (set! tmp.62 tmp.129))
                    (= tmp.62 0))
                (set! tmp.61 14)
                (set! tmp.61 6))
              (!= tmp.61 6))
          (if (begin
                (if (begin
                      (begin
                        (set! tmp.130 tmp.20)
                        (set! tmp.130 (bitwise-and tmp.130 7))
                        (set! tmp.64 tmp.130))
                      (= tmp.64 0))
                  (set! tmp.63 14)
                  (set! tmp.63 6))
                (!= tmp.63 6))
            (begin
              (set! tmp.131 tmp.21)
              (set! tmp.131 (arithmetic-shift-right tmp.131 3))
              (set! tmp.65 tmp.131)
              (set! tmp.132 tmp.20)
              (set! tmp.132 (* tmp.132 tmp.65))
              (set! rax tmp.132)
              (jump tmp-ra.115 rbp rax))
            (begin (set! rax 318) (jump tmp-ra.115 rbp rax)))
          (begin (set! rax 318) (jump tmp-ra.115 rbp rax)))))
    (define L.+.12
      ((new-frames ()))
      (begin
        (set! tmp-ra.116 r15)
        (set! tmp.22 rdi)
        (set! tmp.23 rsi)
        (if (begin
              (if (begin
                    (begin
                      (set! tmp.133 tmp.23)
                      (set! tmp.133 (bitwise-and tmp.133 7))
                      (set! tmp.67 tmp.133))
                    (= tmp.67 0))
                (set! tmp.66 14)
                (set! tmp.66 6))
              (!= tmp.66 6))
          (if (begin
                (if (begin
                      (begin
                        (set! tmp.134 tmp.22)
                        (set! tmp.134 (bitwise-and tmp.134 7))
                        (set! tmp.69 tmp.134))
                      (= tmp.69 0))
                  (set! tmp.68 14)
                  (set! tmp.68 6))
                (!= tmp.68 6))
            (begin
              (set! tmp.135 tmp.22)
              (set! tmp.135 (+ tmp.135 tmp.23))
              (set! rax tmp.135)
              (jump tmp-ra.116 rbp rax))
            (begin (set! rax 574) (jump tmp-ra.116 rbp rax)))
          (begin (set! rax 574) (jump tmp-ra.116 rbp rax)))))
    (define L.fun/void20855.4
      ((new-frames ()))
      (begin (set! tmp-ra.117 r15) (set! rax 30) (jump tmp-ra.117 rbp rax)))
    (define L.fun/ascii-char20850.5
      ((new-frames ()))
      (begin
        (set! tmp-ra.118 r15)
        (set! r15 tmp-ra.118)
        (jump L.fun/ascii-char20851.8 rbp r15)))
    (define L.fun/void20854.6
      ((new-frames ()))
      (begin
        (set! tmp-ra.119 r15)
        (set! r15 tmp-ra.119)
        (jump L.fun/void20855.4 rbp r15)))
    (define L.fun/any20856.7
      ((new-frames ()))
      (begin (set! tmp-ra.120 r15) (set! rax 14) (jump tmp-ra.120 rbp rax)))
    (define L.fun/ascii-char20851.8
      ((new-frames ()))
      (begin (set! tmp-ra.121 r15) (set! rax 29742) (jump tmp-ra.121 rbp rax)))
    (define L.fun/ascii-char20853.9
      ((new-frames ()))
      (begin (set! tmp-ra.122 r15) (set! rax 24366) (jump tmp-ra.122 rbp rax)))
    (define L.fun/ascii-char20852.10
      ((new-frames ()))
      (begin
        (set! tmp-ra.123 r15)
        (set! r15 tmp-ra.123)
        (jump L.fun/ascii-char20853.9 rbp r15)))
    (begin
      (set! tmp-ra.124 r15)
      (return-point L.rp.16
        (begin (set! r15 L.rp.16) (jump L.fun/ascii-char20850.5 rbp r15)))
      (set! ascii-char0.6 rax)
      (return-point L.rp.17
        (begin
          (set! rsi 456)
          (set! rdi 1200)
          (set! r15 L.rp.17)
          (jump L.+.12 rbp r15 rdi rsi)))
      (set! tmp.72 rax)
      (return-point L.rp.18
        (begin
          (set! rsi 616)
          (set! rdi 336)
          (set! r15 L.rp.18)
          (jump L.+.12 rbp r15 rdi rsi)))
      (set! tmp.73 rax)
      (return-point L.rp.19
        (begin
          (set! rsi tmp.73)
          (set! rdi tmp.72)
          (set! r15 L.rp.19)
          (jump L.+.12 rbp r15 rdi rsi)))
      (set! tmp.71 rax)
      (return-point L.rp.20
        (begin
          (set! rsi 480)
          (set! rdi 352)
          (set! r15 L.rp.20)
          (jump L.*.13 rbp r15 rdi rsi)))
      (set! tmp.75 rax)
      (return-point L.rp.21
        (begin
          (set! rsi 1240)
          (set! rdi 456)
          (set! r15 L.rp.21)
          (jump L.-.14 rbp r15 rdi rsi)))
      (set! tmp.76 rax)
      (return-point L.rp.22
        (begin
          (set! rsi tmp.76)
          (set! rdi tmp.75)
          (set! r15 L.rp.22)
          (jump L.-.14 rbp r15 rdi rsi)))
      (set! tmp.74 rax)
      (return-point L.rp.23
        (begin
          (set! rsi tmp.74)
          (set! rdi tmp.71)
          (set! r15 L.rp.23)
          (jump L.-.14 rbp r15 rdi rsi)))
      (set! tmp.70 rax)
      (return-point L.rp.24
        (begin
          (set! rsi 640)
          (set! rdi 1264)
          (set! r15 L.rp.24)
          (jump L.+.12 rbp r15 rdi rsi)))
      (set! tmp.79 rax)
      (return-point L.rp.25
        (begin
          (set! rsi 400)
          (set! rdi 504)
          (set! r15 L.rp.25)
          (jump L.-.14 rbp r15 rdi rsi)))
      (set! tmp.80 rax)
      (return-point L.rp.26
        (begin
          (set! rsi tmp.80)
          (set! rdi tmp.79)
          (set! r15 L.rp.26)
          (jump L.*.13 rbp r15 rdi rsi)))
      (set! tmp.78 rax)
      (return-point L.rp.27
        (begin
          (set! rsi 664)
          (set! rdi 1024)
          (set! r15 L.rp.27)
          (jump L.+.12 rbp r15 rdi rsi)))
      (set! tmp.82 rax)
      (return-point L.rp.28
        (begin
          (set! rsi 936)
          (set! rdi 112)
          (set! r15 L.rp.28)
          (jump L.-.14 rbp r15 rdi rsi)))
      (set! tmp.83 rax)
      (return-point L.rp.29
        (begin
          (set! rsi tmp.83)
          (set! rdi tmp.82)
          (set! r15 L.rp.29)
          (jump L.-.14 rbp r15 rdi rsi)))
      (set! tmp.81 rax)
      (return-point L.rp.30
        (begin
          (set! rsi tmp.81)
          (set! rdi tmp.78)
          (set! r15 L.rp.30)
          (jump L.-.14 rbp r15 rdi rsi)))
      (set! tmp.77 rax)
      (return-point L.rp.31
        (begin
          (set! rsi tmp.77)
          (set! rdi tmp.70)
          (set! r15 L.rp.31)
          (jump L.+.12 rbp r15 rdi rsi)))
      (set! fixnum1.5 rax)
      (return-point L.rp.32
        (begin (set! r15 L.rp.32) (jump L.fun/ascii-char20852.10 rbp r15)))
      (set! ascii-char2.4 rax)
      (return-point L.rp.33
        (begin
          (set! rsi 672)
          (set! rdi 376)
          (set! r15 L.rp.33)
          (jump L.*.13 rbp r15 rdi rsi)))
      (set! tmp.86 rax)
      (return-point L.rp.34
        (begin
          (set! rsi 352)
          (set! rdi 1128)
          (set! r15 L.rp.34)
          (jump L.*.13 rbp r15 rdi rsi)))
      (set! tmp.87 rax)
      (return-point L.rp.35
        (begin
          (set! rsi tmp.87)
          (set! rdi tmp.86)
          (set! r15 L.rp.35)
          (jump L.-.14 rbp r15 rdi rsi)))
      (set! tmp.85 rax)
      (return-point L.rp.36
        (begin
          (set! rsi 1896)
          (set! rdi 1360)
          (set! r15 L.rp.36)
          (jump L.-.14 rbp r15 rdi rsi)))
      (set! tmp.89 rax)
      (return-point L.rp.37
        (begin
          (set! rsi 1680)
          (set! rdi 1848)
          (set! r15 L.rp.37)
          (jump L.+.12 rbp r15 rdi rsi)))
      (set! tmp.90 rax)
      (return-point L.rp.38
        (begin
          (set! rsi tmp.90)
          (set! rdi tmp.89)
          (set! r15 L.rp.38)
          (jump L.+.12 rbp r15 rdi rsi)))
      (set! tmp.88 rax)
      (return-point L.rp.39
        (begin
          (set! rsi tmp.88)
          (set! rdi tmp.85)
          (set! r15 L.rp.39)
          (jump L.+.12 rbp r15 rdi rsi)))
      (set! tmp.84 rax)
      (return-point L.rp.40
        (begin
          (set! rsi 440)
          (set! rdi 248)
          (set! r15 L.rp.40)
          (jump L.+.12 rbp r15 rdi rsi)))
      (set! tmp.93 rax)
      (return-point L.rp.41
        (begin
          (set! rsi 1952)
          (set! rdi 960)
          (set! r15 L.rp.41)
          (jump L.-.14 rbp r15 rdi rsi)))
      (set! tmp.94 rax)
      (return-point L.rp.42
        (begin
          (set! rsi tmp.94)
          (set! rdi tmp.93)
          (set! r15 L.rp.42)
          (jump L.-.14 rbp r15 rdi rsi)))
      (set! tmp.92 rax)
      (return-point L.rp.43
        (begin
          (set! rsi 248)
          (set! rdi 504)
          (set! r15 L.rp.43)
          (jump L.+.12 rbp r15 rdi rsi)))
      (set! tmp.96 rax)
      (return-point L.rp.44
        (begin
          (set! rsi 1768)
          (set! rdi 696)
          (set! r15 L.rp.44)
          (jump L.-.14 rbp r15 rdi rsi)))
      (set! tmp.97 rax)
      (return-point L.rp.45
        (begin
          (set! rsi tmp.97)
          (set! rdi tmp.96)
          (set! r15 L.rp.45)
          (jump L.+.12 rbp r15 rdi rsi)))
      (set! tmp.95 rax)
      (return-point L.rp.46
        (begin
          (set! rsi tmp.95)
          (set! rdi tmp.92)
          (set! r15 L.rp.46)
          (jump L.*.13 rbp r15 rdi rsi)))
      (set! tmp.91 rax)
      (return-point L.rp.47
        (begin
          (set! rsi tmp.91)
          (set! rdi tmp.84)
          (set! r15 L.rp.47)
          (jump L.-.14 rbp r15 rdi rsi)))
      (set! fixnum3.3 rax)
      (return-point L.rp.48
        (begin (set! r15 L.rp.48) (jump L.fun/void20854.6 rbp r15)))
      (set! void4.2 rax)
      (return-point L.rp.49
        (begin
          (set! rsi 1552)
          (set! rdi 424)
          (set! r15 L.rp.49)
          (jump L.-.14 rbp r15 rdi rsi)))
      (set! tmp.100 rax)
      (return-point L.rp.50
        (begin
          (set! rsi 144)
          (set! rdi 1264)
          (set! r15 L.rp.50)
          (jump L.-.14 rbp r15 rdi rsi)))
      (set! tmp.101 rax)
      (return-point L.rp.51
        (begin
          (set! rsi tmp.101)
          (set! rdi tmp.100)
          (set! r15 L.rp.51)
          (jump L.-.14 rbp r15 rdi rsi)))
      (set! tmp.99 rax)
      (return-point L.rp.52
        (begin
          (set! rsi 1256)
          (set! rdi 640)
          (set! r15 L.rp.52)
          (jump L.-.14 rbp r15 rdi rsi)))
      (set! tmp.103 rax)
      (return-point L.rp.53
        (begin
          (set! rsi 1904)
          (set! rdi 712)
          (set! r15 L.rp.53)
          (jump L.+.12 rbp r15 rdi rsi)))
      (set! tmp.104 rax)
      (return-point L.rp.54
        (begin
          (set! rsi tmp.104)
          (set! rdi tmp.103)
          (set! r15 L.rp.54)
          (jump L.*.13 rbp r15 rdi rsi)))
      (set! tmp.102 rax)
      (return-point L.rp.55
        (begin
          (set! rsi tmp.102)
          (set! rdi tmp.99)
          (set! r15 L.rp.55)
          (jump L.-.14 rbp r15 rdi rsi)))
      (set! tmp.98 rax)
      (return-point L.rp.56
        (begin
          (set! rsi 1304)
          (set! rdi 1080)
          (set! r15 L.rp.56)
          (jump L.+.12 rbp r15 rdi rsi)))
      (set! tmp.107 rax)
      (return-point L.rp.57
        (begin
          (set! rsi 1928)
          (set! rdi 1000)
          (set! r15 L.rp.57)
          (jump L.*.13 rbp r15 rdi rsi)))
      (set! tmp.108 rax)
      (return-point L.rp.58
        (begin
          (set! rsi tmp.108)
          (set! rdi tmp.107)
          (set! r15 L.rp.58)
          (jump L.+.12 rbp r15 rdi rsi)))
      (set! tmp.106 rax)
      (return-point L.rp.59
        (begin
          (set! rsi 416)
          (set! rdi 1720)
          (set! r15 L.rp.59)
          (jump L.*.13 rbp r15 rdi rsi)))
      (set! tmp.110 rax)
      (return-point L.rp.60
        (begin
          (set! rsi 1112)
          (set! rdi 1344)
          (set! r15 L.rp.60)
          (jump L.-.14 rbp r15 rdi rsi)))
      (set! tmp.111 rax)
      (return-point L.rp.61
        (begin
          (set! rsi tmp.111)
          (set! rdi tmp.110)
          (set! r15 L.rp.61)
          (jump L.-.14 rbp r15 rdi rsi)))
      (set! tmp.109 rax)
      (return-point L.rp.62
        (begin
          (set! rsi tmp.109)
          (set! rdi tmp.106)
          (set! r15 L.rp.62)
          (jump L.+.12 rbp r15 rdi rsi)))
      (set! tmp.105 rax)
      (return-point L.rp.63
        (begin
          (set! rsi tmp.105)
          (set! rdi tmp.98)
          (set! r15 L.rp.63)
          (jump L.*.13 rbp r15 rdi rsi)))
      (set! fixnum5.1 rax)
      (return-point L.rp.64
        (begin (set! r15 L.rp.64) (jump L.fun/any20856.7 rbp r15)))
      (set! tmp.112 rax)
      (set! rdi tmp.112)
      (set! r15 tmp-ra.124)
      (jump L.boolean?.15 rbp r15 rdi))))
(check-by-interp
 '(module
    ((new-frames
      (() () () () () () () () () () () () () () () () () () () ())))
    (define L.-.18
      ((new-frames ()))
      (begin
        (set! tmp-ra.85 r15)
        (set! tmp.24 rdi)
        (set! tmp.25 rsi)
        (if (begin
              (if (begin
                    (begin
                      (set! tmp.100 tmp.25)
                      (set! tmp.100 (bitwise-and tmp.100 7))
                      (set! tmp.58 tmp.100))
                    (= tmp.58 0))
                (set! tmp.57 14)
                (set! tmp.57 6))
              (!= tmp.57 6))
          (if (begin
                (if (begin
                      (begin
                        (set! tmp.101 tmp.24)
                        (set! tmp.101 (bitwise-and tmp.101 7))
                        (set! tmp.60 tmp.101))
                      (= tmp.60 0))
                  (set! tmp.59 14)
                  (set! tmp.59 6))
                (!= tmp.59 6))
            (begin
              (set! tmp.102 tmp.24)
              (set! tmp.102 (- tmp.102 tmp.25))
              (set! rax tmp.102)
              (jump tmp-ra.85 rbp rax))
            (begin (set! rax 830) (jump tmp-ra.85 rbp rax)))
          (begin (set! rax 830) (jump tmp-ra.85 rbp rax)))))
    (define L.*.17
      ((new-frames ()))
      (begin
        (set! tmp-ra.86 r15)
        (set! tmp.20 rdi)
        (set! tmp.21 rsi)
        (if (begin
              (if (begin
                    (begin
                      (set! tmp.103 tmp.21)
                      (set! tmp.103 (bitwise-and tmp.103 7))
                      (set! tmp.62 tmp.103))
                    (= tmp.62 0))
                (set! tmp.61 14)
                (set! tmp.61 6))
              (!= tmp.61 6))
          (if (begin
                (if (begin
                      (begin
                        (set! tmp.104 tmp.20)
                        (set! tmp.104 (bitwise-and tmp.104 7))
                        (set! tmp.64 tmp.104))
                      (= tmp.64 0))
                  (set! tmp.63 14)
                  (set! tmp.63 6))
                (!= tmp.63 6))
            (begin
              (set! tmp.105 tmp.21)
              (set! tmp.105 (arithmetic-shift-right tmp.105 3))
              (set! tmp.65 tmp.105)
              (set! tmp.106 tmp.20)
              (set! tmp.106 (* tmp.106 tmp.65))
              (set! rax tmp.106)
              (jump tmp-ra.86 rbp rax))
            (begin (set! rax 318) (jump tmp-ra.86 rbp rax)))
          (begin (set! rax 318) (jump tmp-ra.86 rbp rax)))))
    (define L.+.16
      ((new-frames ()))
      (begin
        (set! tmp-ra.87 r15)
        (set! tmp.22 rdi)
        (set! tmp.23 rsi)
        (if (begin
              (if (begin
                    (begin
                      (set! tmp.107 tmp.23)
                      (set! tmp.107 (bitwise-and tmp.107 7))
                      (set! tmp.67 tmp.107))
                    (= tmp.67 0))
                (set! tmp.66 14)
                (set! tmp.66 6))
              (!= tmp.66 6))
          (if (begin
                (if (begin
                      (begin
                        (set! tmp.108 tmp.22)
                        (set! tmp.108 (bitwise-and tmp.108 7))
                        (set! tmp.69 tmp.108))
                      (= tmp.69 0))
                  (set! tmp.68 14)
                  (set! tmp.68 6))
                (!= tmp.68 6))
            (begin
              (set! tmp.109 tmp.22)
              (set! tmp.109 (+ tmp.109 tmp.23))
              (set! rax tmp.109)
              (jump tmp-ra.87 rbp rax))
            (begin (set! rax 574) (jump tmp-ra.87 rbp rax)))
          (begin (set! rax 574) (jump tmp-ra.87 rbp rax)))))
    (define L.cons.15
      ((new-frames ()))
      (begin
        (set! tmp-ra.88 r15)
        (set! tmp.52 rdi)
        (set! tmp.53 rsi)
        (set! tmp.70 (alloc 16))
        (set! tmp.110 tmp.70)
        (set! tmp.110 (+ tmp.110 1))
        (set! tmp.56 tmp.110)
        (mset! tmp.56 -1 tmp.52)
        (mset! tmp.56 7 tmp.53)
        (set! rax tmp.56)
        (jump tmp-ra.88 rbp rax)))
    (define L.fun/ascii-char22195.4
      ((new-frames ()))
      (begin (set! tmp-ra.89 r15) (set! rax 31278) (jump tmp-ra.89 rbp rax)))
    (define L.fun/empty22197.5
      ((new-frames ()))
      (begin (set! tmp-ra.90 r15) (set! rax 22) (jump tmp-ra.90 rbp rax)))
    (define L.fun/pair22193.6
      ((new-frames ()))
      (begin
        (set! tmp-ra.91 r15)
        (set! rsi 2320)
        (set! rdi 640)
        (set! r15 tmp-ra.91)
        (jump L.cons.15 rbp r15 rdi rsi)))
    (define L.fun/pair22192.7
      ((new-frames ()))
      (begin
        (set! tmp-ra.92 r15)
        (set! r15 tmp-ra.92)
        (jump L.fun/pair22193.6 rbp r15)))
    (define L.fun/empty22199.8
      ((new-frames ()))
      (begin (set! tmp-ra.93 r15) (set! rax 22) (jump tmp-ra.93 rbp rax)))
    (define L.fun/empty22198.9
      ((new-frames ()))
      (begin
        (set! tmp-ra.94 r15)
        (set! r15 tmp-ra.94)
        (jump L.fun/empty22199.8 rbp r15)))
    (define L.fun/empty22196.10
      ((new-frames ()))
      (begin
        (set! tmp-ra.95 r15)
        (set! r15 tmp-ra.95)
        (jump L.fun/empty22197.5 rbp r15)))
    (define L.fun/error22191.11
      ((new-frames ()))
      (begin (set! tmp-ra.96 r15) (set! rax 19262) (jump tmp-ra.96 rbp rax)))
    (define L.fun/error22190.12
      ((new-frames ()))
      (begin
        (set! tmp-ra.97 r15)
        (set! r15 tmp-ra.97)
        (jump L.fun/error22191.11 rbp r15)))
    (define L.fun/ascii-char22194.13
      ((new-frames ()))
      (begin
        (set! tmp-ra.98 r15)
        (set! r15 tmp-ra.98)
        (jump L.fun/ascii-char22195.4 rbp r15)))
    (begin
      (set! tmp-ra.99 r15)
      (return-point L.rp.19
        (begin (set! r15 L.rp.19) (jump L.fun/error22190.12 rbp r15)))
      (set! error0.6 rax)
      (return-point L.rp.20
        (begin (set! r15 L.rp.20) (jump L.fun/pair22192.7 rbp r15)))
      (set! pair1.5 rax)
      (return-point L.rp.21
        (begin (set! r15 L.rp.21) (jump L.fun/ascii-char22194.13 rbp r15)))
      (set! ascii-char2.4 rax)
      (return-point L.rp.22
        (begin (set! r15 L.rp.22) (jump L.fun/empty22196.10 rbp r15)))
      (set! empty3.3 rax)
      (return-point L.rp.23
        (begin (set! r15 L.rp.23) (jump L.fun/empty22198.9 rbp r15)))
      (set! empty4.2 rax)
      (return-point L.rp.24
        (begin
          (set! rsi 1408)
          (set! rdi 1072)
          (set! r15 L.rp.24)
          (jump L.+.16 rbp r15 rdi rsi)))
      (set! tmp.73 rax)
      (return-point L.rp.25
        (begin
          (set! rsi 784)
          (set! rdi 1232)
          (set! r15 L.rp.25)
          (jump L.*.17 rbp r15 rdi rsi)))
      (set! tmp.74 rax)
      (return-point L.rp.26
        (begin
          (set! rsi tmp.74)
          (set! rdi tmp.73)
          (set! r15 L.rp.26)
          (jump L.-.18 rbp r15 rdi rsi)))
      (set! tmp.72 rax)
      (return-point L.rp.27
        (begin
          (set! rsi 1688)
          (set! rdi 1496)
          (set! r15 L.rp.27)
          (jump L.*.17 rbp r15 rdi rsi)))
      (set! tmp.76 rax)
      (return-point L.rp.28
        (begin
          (set! rsi 824)
          (set! rdi 832)
          (set! r15 L.rp.28)
          (jump L.+.16 rbp r15 rdi rsi)))
      (set! tmp.77 rax)
      (return-point L.rp.29
        (begin
          (set! rsi tmp.77)
          (set! rdi tmp.76)
          (set! r15 L.rp.29)
          (jump L.-.18 rbp r15 rdi rsi)))
      (set! tmp.75 rax)
      (return-point L.rp.30
        (begin
          (set! rsi tmp.75)
          (set! rdi tmp.72)
          (set! r15 L.rp.30)
          (jump L.*.17 rbp r15 rdi rsi)))
      (set! tmp.71 rax)
      (return-point L.rp.31
        (begin
          (set! rsi 880)
          (set! rdi 392)
          (set! r15 L.rp.31)
          (jump L.*.17 rbp r15 rdi rsi)))
      (set! tmp.80 rax)
      (return-point L.rp.32
        (begin
          (set! rsi 192)
          (set! rdi 312)
          (set! r15 L.rp.32)
          (jump L.*.17 rbp r15 rdi rsi)))
      (set! tmp.81 rax)
      (return-point L.rp.33
        (begin
          (set! rsi tmp.81)
          (set! rdi tmp.80)
          (set! r15 L.rp.33)
          (jump L.+.16 rbp r15 rdi rsi)))
      (set! tmp.79 rax)
      (return-point L.rp.34
        (begin
          (set! rsi 576)
          (set! rdi 1728)
          (set! r15 L.rp.34)
          (jump L.*.17 rbp r15 rdi rsi)))
      (set! tmp.83 rax)
      (return-point L.rp.35
        (begin
          (set! rsi 848)
          (set! rdi 160)
          (set! r15 L.rp.35)
          (jump L.-.18 rbp r15 rdi rsi)))
      (set! tmp.84 rax)
      (return-point L.rp.36
        (begin
          (set! rsi tmp.84)
          (set! rdi tmp.83)
          (set! r15 L.rp.36)
          (jump L.*.17 rbp r15 rdi rsi)))
      (set! tmp.82 rax)
      (return-point L.rp.37
        (begin
          (set! rsi tmp.82)
          (set! rdi tmp.79)
          (set! r15 L.rp.37)
          (jump L.-.18 rbp r15 rdi rsi)))
      (set! tmp.78 rax)
      (return-point L.rp.38
        (begin
          (set! rsi tmp.78)
          (set! rdi tmp.71)
          (set! r15 L.rp.38)
          (jump L.+.16 rbp r15 rdi rsi)))
      (set! fixnum5.1 rax)
      (set! rax error0.6)
      (jump tmp-ra.99 rbp rax))))
(check-by-interp
 '(module
    ((new-frames (() () () () () ())))
    (define L.fun/error24539.4
      ((new-frames ()))
      (begin (set! tmp-ra.56 r15) (set! rax 15934) (jump tmp-ra.56 rbp rax)))
    (define L.fun/ascii-char24535.5
      ((new-frames ()))
      (begin (set! tmp-ra.57 r15) (set! rax 18734) (jump tmp-ra.57 rbp rax)))
    (define L.fun/ascii-char24529.6
      ((new-frames ()))
      (begin (set! tmp-ra.58 r15) (set! rax 24622) (jump tmp-ra.58 rbp rax)))
    (define L.fun/empty24537.7
      ((new-frames ()))
      (begin (set! tmp-ra.59 r15) (set! rax 22) (jump tmp-ra.59 rbp rax)))
    (define L.fun/ascii-char24534.8
      ((new-frames ()))
      (begin
        (set! tmp-ra.60 r15)
        (set! r15 tmp-ra.60)
        (jump L.fun/ascii-char24535.5 rbp r15)))
    (define L.fun/error24531.9
      ((new-frames ()))
      (begin (set! tmp-ra.61 r15) (set! rax 2622) (jump tmp-ra.61 rbp rax)))
    (define L.fun/error24538.10
      ((new-frames ()))
      (begin
        (set! tmp-ra.62 r15)
        (set! r15 tmp-ra.62)
        (jump L.fun/error24539.4 rbp r15)))
    (define L.fun/empty24536.11
      ((new-frames ()))
      (begin
        (set! tmp-ra.63 r15)
        (set! r15 tmp-ra.63)
        (jump L.fun/empty24537.7 rbp r15)))
    (define L.fun/void24532.12
      ((new-frames ()))
      (begin
        (set! tmp-ra.64 r15)
        (set! r15 tmp-ra.64)
        (jump L.fun/void24533.14 rbp r15)))
    (define L.fun/error24530.13
      ((new-frames ()))
      (begin
        (set! tmp-ra.65 r15)
        (set! r15 tmp-ra.65)
        (jump L.fun/error24531.9 rbp r15)))
    (define L.fun/void24533.14
      ((new-frames ()))
      (begin (set! tmp-ra.66 r15) (set! rax 30) (jump tmp-ra.66 rbp rax)))
    (define L.fun/ascii-char24528.15
      ((new-frames ()))
      (begin
        (set! tmp-ra.67 r15)
        (set! r15 tmp-ra.67)
        (jump L.fun/ascii-char24529.6 rbp r15)))
    (begin
      (set! tmp-ra.68 r15)
      (return-point L.rp.17
        (begin (set! r15 L.rp.17) (jump L.fun/ascii-char24528.15 rbp r15)))
      (set! ascii-char0.6 rax)
      (return-point L.rp.18
        (begin (set! r15 L.rp.18) (jump L.fun/error24530.13 rbp r15)))
      (set! error1.5 rax)
      (return-point L.rp.19
        (begin (set! r15 L.rp.19) (jump L.fun/void24532.12 rbp r15)))
      (set! void2.4 rax)
      (return-point L.rp.20
        (begin (set! r15 L.rp.20) (jump L.fun/ascii-char24534.8 rbp r15)))
      (set! ascii-char3.3 rax)
      (return-point L.rp.21
        (begin (set! r15 L.rp.21) (jump L.fun/empty24536.11 rbp r15)))
      (set! empty4.2 rax)
      (return-point L.rp.22
        (begin (set! r15 L.rp.22) (jump L.fun/error24538.10 rbp r15)))
      (set! error5.1 rax)
      (set! rax empty4.2)
      (jump tmp-ra.68 rbp rax))))
(check-by-interp
 '(module
    ((new-frames
      (()
       ()
       ()
       ()
       ()
       ()
       ()
       ()
       ()
       ()
       ()
       ()
       ()
       ()
       ()
       ()
       ()
       ()
       ()
       ()
       ()
       ()
       ()
       ()
       ()
       ()
       ()
       ()
       ()
       ()
       ()
       ()
       ()
       ()
       ()
       ()
       ()
       ()
       ()
       ())))
    (define L.-.15
      ((new-frames ()))
      (begin
        (set! tmp-ra.103 r15)
        (set! tmp.24 rdi)
        (set! tmp.25 rsi)
        (if (begin
              (if (begin
                    (begin
                      (set! tmp.115 tmp.25)
                      (set! tmp.115 (bitwise-and tmp.115 7))
                      (set! tmp.57 tmp.115))
                    (= tmp.57 0))
                (set! tmp.56 14)
                (set! tmp.56 6))
              (!= tmp.56 6))
          (if (begin
                (if (begin
                      (begin
                        (set! tmp.116 tmp.24)
                        (set! tmp.116 (bitwise-and tmp.116 7))
                        (set! tmp.59 tmp.116))
                      (= tmp.59 0))
                  (set! tmp.58 14)
                  (set! tmp.58 6))
                (!= tmp.58 6))
            (begin
              (set! tmp.117 tmp.24)
              (set! tmp.117 (- tmp.117 tmp.25))
              (set! rax tmp.117)
              (jump tmp-ra.103 rbp rax))
            (begin (set! rax 830) (jump tmp-ra.103 rbp rax)))
          (begin (set! rax 830) (jump tmp-ra.103 rbp rax)))))
    (define L.*.14
      ((new-frames ()))
      (begin
        (set! tmp-ra.104 r15)
        (set! tmp.20 rdi)
        (set! tmp.21 rsi)
        (if (begin
              (if (begin
                    (begin
                      (set! tmp.118 tmp.21)
                      (set! tmp.118 (bitwise-and tmp.118 7))
                      (set! tmp.61 tmp.118))
                    (= tmp.61 0))
                (set! tmp.60 14)
                (set! tmp.60 6))
              (!= tmp.60 6))
          (if (begin
                (if (begin
                      (begin
                        (set! tmp.119 tmp.20)
                        (set! tmp.119 (bitwise-and tmp.119 7))
                        (set! tmp.63 tmp.119))
                      (= tmp.63 0))
                  (set! tmp.62 14)
                  (set! tmp.62 6))
                (!= tmp.62 6))
            (begin
              (set! tmp.120 tmp.21)
              (set! tmp.120 (arithmetic-shift-right tmp.120 3))
              (set! tmp.64 tmp.120)
              (set! tmp.121 tmp.20)
              (set! tmp.121 (* tmp.121 tmp.64))
              (set! rax tmp.121)
              (jump tmp-ra.104 rbp rax))
            (begin (set! rax 318) (jump tmp-ra.104 rbp rax)))
          (begin (set! rax 318) (jump tmp-ra.104 rbp rax)))))
    (define L.+.13
      ((new-frames ()))
      (begin
        (set! tmp-ra.105 r15)
        (set! tmp.22 rdi)
        (set! tmp.23 rsi)
        (if (begin
              (if (begin
                    (begin
                      (set! tmp.122 tmp.23)
                      (set! tmp.122 (bitwise-and tmp.122 7))
                      (set! tmp.66 tmp.122))
                    (= tmp.66 0))
                (set! tmp.65 14)
                (set! tmp.65 6))
              (!= tmp.65 6))
          (if (begin
                (if (begin
                      (begin
                        (set! tmp.123 tmp.22)
                        (set! tmp.123 (bitwise-and tmp.123 7))
                        (set! tmp.68 tmp.123))
                      (= tmp.68 0))
                  (set! tmp.67 14)
                  (set! tmp.67 6))
                (!= tmp.67 6))
            (begin
              (set! tmp.124 tmp.22)
              (set! tmp.124 (+ tmp.124 tmp.23))
              (set! rax tmp.124)
              (jump tmp-ra.105 rbp rax))
            (begin (set! rax 574) (jump tmp-ra.105 rbp rax)))
          (begin (set! rax 574) (jump tmp-ra.105 rbp rax)))))
    (define L.fun/empty24788.4
      ((new-frames ()))
      (begin (set! tmp-ra.106 r15) (set! rax 22) (jump tmp-ra.106 rbp rax)))
    (define L.fun/error24789.5
      ((new-frames ()))
      (begin
        (set! tmp-ra.107 r15)
        (set! r15 tmp-ra.107)
        (jump L.fun/error24790.10 rbp r15)))
    (define L.fun/error24786.6
      ((new-frames ()))
      (begin (set! tmp-ra.108 r15) (set! rax 34622) (jump tmp-ra.108 rbp rax)))
    (define L.fun/error24785.7
      ((new-frames ()))
      (begin
        (set! tmp-ra.109 r15)
        (set! r15 tmp-ra.109)
        (jump L.fun/error24786.6 rbp r15)))
    (define L.fun/empty24792.8
      ((new-frames ()))
      (begin (set! tmp-ra.110 r15) (set! rax 22) (jump tmp-ra.110 rbp rax)))
    (define L.fun/empty24787.9
      ((new-frames ()))
      (begin
        (set! tmp-ra.111 r15)
        (set! r15 tmp-ra.111)
        (jump L.fun/empty24788.4 rbp r15)))
    (define L.fun/error24790.10
      ((new-frames ()))
      (begin (set! tmp-ra.112 r15) (set! rax 11070) (jump tmp-ra.112 rbp rax)))
    (define L.fun/empty24791.11
      ((new-frames ()))
      (begin
        (set! tmp-ra.113 r15)
        (set! r15 tmp-ra.113)
        (jump L.fun/empty24792.8 rbp r15)))
    (begin
      (set! tmp-ra.114 r15)
      (return-point L.rp.16
        (begin (set! r15 L.rp.16) (jump L.fun/error24785.7 rbp r15)))
      (set! error0.6 rax)
      (return-point L.rp.17
        (begin
          (set! rsi 1112)
          (set! rdi 1392)
          (set! r15 L.rp.17)
          (jump L.+.13 rbp r15 rdi rsi)))
      (set! tmp.71 rax)
      (return-point L.rp.18
        (begin
          (set! rsi 1584)
          (set! rdi 1104)
          (set! r15 L.rp.18)
          (jump L.*.14 rbp r15 rdi rsi)))
      (set! tmp.72 rax)
      (return-point L.rp.19
        (begin
          (set! rsi tmp.72)
          (set! rdi tmp.71)
          (set! r15 L.rp.19)
          (jump L.+.13 rbp r15 rdi rsi)))
      (set! tmp.70 rax)
      (return-point L.rp.20
        (begin
          (set! rsi 1024)
          (set! rdi 88)
          (set! r15 L.rp.20)
          (jump L.*.14 rbp r15 rdi rsi)))
      (set! tmp.74 rax)
      (return-point L.rp.21
        (begin
          (set! rsi 32)
          (set! rdi 680)
          (set! r15 L.rp.21)
          (jump L.+.13 rbp r15 rdi rsi)))
      (set! tmp.75 rax)
      (return-point L.rp.22
        (begin
          (set! rsi tmp.75)
          (set! rdi tmp.74)
          (set! r15 L.rp.22)
          (jump L.-.15 rbp r15 rdi rsi)))
      (set! tmp.73 rax)
      (return-point L.rp.23
        (begin
          (set! rsi tmp.73)
          (set! rdi tmp.70)
          (set! r15 L.rp.23)
          (jump L.-.15 rbp r15 rdi rsi)))
      (set! tmp.69 rax)
      (return-point L.rp.24
        (begin
          (set! rsi 1672)
          (set! rdi 1648)
          (set! r15 L.rp.24)
          (jump L.-.15 rbp r15 rdi rsi)))
      (set! tmp.78 rax)
      (return-point L.rp.25
        (begin
          (set! rsi 1616)
          (set! rdi 2016)
          (set! r15 L.rp.25)
          (jump L.*.14 rbp r15 rdi rsi)))
      (set! tmp.79 rax)
      (return-point L.rp.26
        (begin
          (set! rsi tmp.79)
          (set! rdi tmp.78)
          (set! r15 L.rp.26)
          (jump L.+.13 rbp r15 rdi rsi)))
      (set! tmp.77 rax)
      (return-point L.rp.27
        (begin
          (set! rsi 1512)
          (set! rdi 1040)
          (set! r15 L.rp.27)
          (jump L.-.15 rbp r15 rdi rsi)))
      (set! tmp.81 rax)
      (return-point L.rp.28
        (begin
          (set! rsi 1256)
          (set! rdi 2024)
          (set! r15 L.rp.28)
          (jump L.+.13 rbp r15 rdi rsi)))
      (set! tmp.82 rax)
      (return-point L.rp.29
        (begin
          (set! rsi tmp.82)
          (set! rdi tmp.81)
          (set! r15 L.rp.29)
          (jump L.*.14 rbp r15 rdi rsi)))
      (set! tmp.80 rax)
      (return-point L.rp.30
        (begin
          (set! rsi tmp.80)
          (set! rdi tmp.77)
          (set! r15 L.rp.30)
          (jump L.+.13 rbp r15 rdi rsi)))
      (set! tmp.76 rax)
      (return-point L.rp.31
        (begin
          (set! rsi tmp.76)
          (set! rdi tmp.69)
          (set! r15 L.rp.31)
          (jump L.-.15 rbp r15 rdi rsi)))
      (set! fixnum1.5 rax)
      (return-point L.rp.32
        (begin (set! r15 L.rp.32) (jump L.fun/empty24787.9 rbp r15)))
      (set! empty2.4 rax)
      (return-point L.rp.33
        (begin (set! r15 L.rp.33) (jump L.fun/error24789.5 rbp r15)))
      (set! error3.3 rax)
      (return-point L.rp.34
        (begin
          (set! rsi 608)
          (set! rdi 640)
          (set! r15 L.rp.34)
          (jump L.*.14 rbp r15 rdi rsi)))
      (set! tmp.85 rax)
      (return-point L.rp.35
        (begin
          (set! rsi 1840)
          (set! rdi 88)
          (set! r15 L.rp.35)
          (jump L.*.14 rbp r15 rdi rsi)))
      (set! tmp.86 rax)
      (return-point L.rp.36
        (begin
          (set! rsi tmp.86)
          (set! rdi tmp.85)
          (set! r15 L.rp.36)
          (jump L.-.15 rbp r15 rdi rsi)))
      (set! tmp.84 rax)
      (return-point L.rp.37
        (begin
          (set! rsi 2008)
          (set! rdi 1992)
          (set! r15 L.rp.37)
          (jump L.+.13 rbp r15 rdi rsi)))
      (set! tmp.88 rax)
      (return-point L.rp.38
        (begin
          (set! rsi 1960)
          (set! rdi 632)
          (set! r15 L.rp.38)
          (jump L.*.14 rbp r15 rdi rsi)))
      (set! tmp.89 rax)
      (return-point L.rp.39
        (begin
          (set! rsi tmp.89)
          (set! rdi tmp.88)
          (set! r15 L.rp.39)
          (jump L.+.13 rbp r15 rdi rsi)))
      (set! tmp.87 rax)
      (return-point L.rp.40
        (begin
          (set! rsi tmp.87)
          (set! rdi tmp.84)
          (set! r15 L.rp.40)
          (jump L.-.15 rbp r15 rdi rsi)))
      (set! tmp.83 rax)
      (return-point L.rp.41
        (begin
          (set! rsi 1392)
          (set! rdi 744)
          (set! r15 L.rp.41)
          (jump L.*.14 rbp r15 rdi rsi)))
      (set! tmp.92 rax)
      (return-point L.rp.42
        (begin
          (set! rsi 440)
          (set! rdi 808)
          (set! r15 L.rp.42)
          (jump L.*.14 rbp r15 rdi rsi)))
      (set! tmp.93 rax)
      (return-point L.rp.43
        (begin
          (set! rsi tmp.93)
          (set! rdi tmp.92)
          (set! r15 L.rp.43)
          (jump L.+.13 rbp r15 rdi rsi)))
      (set! tmp.91 rax)
      (return-point L.rp.44
        (begin
          (set! rsi 920)
          (set! rdi 1368)
          (set! r15 L.rp.44)
          (jump L.-.15 rbp r15 rdi rsi)))
      (set! tmp.95 rax)
      (return-point L.rp.45
        (begin
          (set! rsi 920)
          (set! rdi 912)
          (set! r15 L.rp.45)
          (jump L.-.15 rbp r15 rdi rsi)))
      (set! tmp.96 rax)
      (return-point L.rp.46
        (begin
          (set! rsi tmp.96)
          (set! rdi tmp.95)
          (set! r15 L.rp.46)
          (jump L.*.14 rbp r15 rdi rsi)))
      (set! tmp.94 rax)
      (return-point L.rp.47
        (begin
          (set! rsi tmp.94)
          (set! rdi tmp.91)
          (set! r15 L.rp.47)
          (jump L.*.14 rbp r15 rdi rsi)))
      (set! tmp.90 rax)
      (return-point L.rp.48
        (begin
          (set! rsi tmp.90)
          (set! rdi tmp.83)
          (set! r15 L.rp.48)
          (jump L.*.14 rbp r15 rdi rsi)))
      (set! fixnum4.2 rax)
      (return-point L.rp.49
        (begin (set! r15 L.rp.49) (jump L.fun/empty24791.11 rbp r15)))
      (set! empty5.1 rax)
      (return-point L.rp.50
        (begin
          (set! rsi fixnum4.2)
          (set! rdi 56)
          (set! r15 L.rp.50)
          (jump L.-.15 rbp r15 rdi rsi)))
      (set! tmp.99 rax)
      (return-point L.rp.51
        (begin
          (set! rsi fixnum4.2)
          (set! rdi tmp.99)
          (set! r15 L.rp.51)
          (jump L.-.15 rbp r15 rdi rsi)))
      (set! tmp.98 rax)
      (return-point L.rp.52
        (begin
          (set! rsi fixnum1.5)
          (set! rdi 144)
          (set! r15 L.rp.52)
          (jump L.*.14 rbp r15 rdi rsi)))
      (set! tmp.101 rax)
      (return-point L.rp.53
        (begin
          (set! rsi tmp.101)
          (set! rdi fixnum1.5)
          (set! r15 L.rp.53)
          (jump L.*.14 rbp r15 rdi rsi)))
      (set! tmp.100 rax)
      (return-point L.rp.54
        (begin
          (set! rsi tmp.100)
          (set! rdi tmp.98)
          (set! r15 L.rp.54)
          (jump L.+.13 rbp r15 rdi rsi)))
      (set! tmp.97 rax)
      (return-point L.rp.55
        (begin
          (set! rsi fixnum1.5)
          (set! rdi fixnum4.2)
          (set! r15 L.rp.55)
          (jump L.-.15 rbp r15 rdi rsi)))
      (set! tmp.102 rax)
      (set! rsi tmp.102)
      (set! rdi tmp.97)
      (set! r15 tmp-ra.114)
      (jump L.+.13 rbp r15 rdi rsi))))
(check-by-interp
 '(module
    ((new-frames (() () () () () () ())))
    (define L.error?.19
      ((new-frames ()))
      (begin
        (set! tmp-ra.60 r15)
        (set! tmp.48 rdi)
        (if (begin
              (begin
                (set! tmp.76 tmp.48)
                (set! tmp.76 (bitwise-and tmp.76 255))
                (set! tmp.57 tmp.76))
              (= tmp.57 62))
          (begin (set! rax 14) (jump tmp-ra.60 rbp rax))
          (begin (set! rax 6) (jump tmp-ra.60 rbp rax)))))
    (define L.cons.18
      ((new-frames ()))
      (begin
        (set! tmp-ra.61 r15)
        (set! tmp.52 rdi)
        (set! tmp.53 rsi)
        (set! tmp.58 (alloc 16))
        (set! tmp.77 tmp.58)
        (set! tmp.77 (+ tmp.77 1))
        (set! tmp.56 tmp.77)
        (mset! tmp.56 -1 tmp.52)
        (mset! tmp.56 7 tmp.53)
        (set! rax tmp.56)
        (jump tmp-ra.61 rbp rax)))
    (define L.fun/pair24832.4
      ((new-frames ()))
      (begin
        (set! tmp-ra.62 r15)
        (set! r15 tmp-ra.62)
        (jump L.fun/pair24833.15 rbp r15)))
    (define L.fun/error24829.5
      ((new-frames ()))
      (begin (set! tmp-ra.63 r15) (set! rax 2110) (jump tmp-ra.63 rbp rax)))
    (define L.fun/pair24835.6
      ((new-frames ()))
      (begin
        (set! tmp-ra.64 r15)
        (set! r15 tmp-ra.64)
        (jump L.fun/pair24836.7 rbp r15)))
    (define L.fun/pair24836.7
      ((new-frames ()))
      (begin
        (set! tmp-ra.65 r15)
        (set! rsi 4056)
        (set! rdi 1040)
        (set! r15 tmp-ra.65)
        (jump L.cons.18 rbp r15 rdi rsi)))
    (define L.fun/any24834.8
      ((new-frames ()))
      (begin (set! tmp-ra.66 r15) (set! rax 40766) (jump tmp-ra.66 rbp rax)))
    (define L.fun/ascii-char24839.9
      ((new-frames ()))
      (begin
        (set! tmp-ra.67 r15)
        (set! r15 tmp-ra.67)
        (jump L.fun/ascii-char24840.12 rbp r15)))
    (define L.fun/void24831.10
      ((new-frames ()))
      (begin (set! tmp-ra.68 r15) (set! rax 30) (jump tmp-ra.68 rbp rax)))
    (define L.fun/void24830.11
      ((new-frames ()))
      (begin
        (set! tmp-ra.69 r15)
        (set! r15 tmp-ra.69)
        (jump L.fun/void24831.10 rbp r15)))
    (define L.fun/ascii-char24840.12
      ((new-frames ()))
      (begin (set! tmp-ra.70 r15) (set! rax 26414) (jump tmp-ra.70 rbp rax)))
    (define L.fun/empty24838.13
      ((new-frames ()))
      (begin (set! tmp-ra.71 r15) (set! rax 22) (jump tmp-ra.71 rbp rax)))
    (define L.fun/empty24837.14
      ((new-frames ()))
      (begin
        (set! tmp-ra.72 r15)
        (set! r15 tmp-ra.72)
        (jump L.fun/empty24838.13 rbp r15)))
    (define L.fun/pair24833.15
      ((new-frames ()))
      (begin
        (set! tmp-ra.73 r15)
        (set! rsi 3544)
        (set! rdi 1856)
        (set! r15 tmp-ra.73)
        (jump L.cons.18 rbp r15 rdi rsi)))
    (define L.fun/error24828.16
      ((new-frames ()))
      (begin
        (set! tmp-ra.74 r15)
        (set! r15 tmp-ra.74)
        (jump L.fun/error24829.5 rbp r15)))
    (begin
      (set! tmp-ra.75 r15)
      (return-point L.rp.20
        (begin (set! r15 L.rp.20) (jump L.fun/error24828.16 rbp r15)))
      (set! error0.6 rax)
      (return-point L.rp.21
        (begin (set! r15 L.rp.21) (jump L.fun/void24830.11 rbp r15)))
      (set! void1.5 rax)
      (return-point L.rp.22
        (begin (set! r15 L.rp.22) (jump L.fun/pair24832.4 rbp r15)))
      (set! pair2.4 rax)
      (return-point L.rp.23
        (begin (set! r15 L.rp.23) (jump L.fun/any24834.8 rbp r15)))
      (set! tmp.59 rax)
      (return-point L.rp.24
        (begin
          (set! rdi tmp.59)
          (set! r15 L.rp.24)
          (jump L.error?.19 rbp r15 rdi)))
      (set! boolean3.3 rax)
      (return-point L.rp.25
        (begin (set! r15 L.rp.25) (jump L.fun/pair24835.6 rbp r15)))
      (set! pair4.2 rax)
      (return-point L.rp.26
        (begin (set! r15 L.rp.26) (jump L.fun/empty24837.14 rbp r15)))
      (set! empty5.1 rax)
      (set! r15 tmp-ra.75)
      (jump L.fun/ascii-char24839.9 rbp r15))))
(check-by-interp
 '(module
    ((new-frames
      (()
       ()
       ()
       ()
       ()
       ()
       ()
       ()
       ()
       ()
       ()
       ()
       ()
       ()
       ()
       ()
       ()
       ()
       ()
       ()
       ()
       ()
       ()
       ()
       ()
       ()
       ()
       ()
       ()
       ())))
    (define L.*.17
      ((new-frames ()))
      (begin
        (set! tmp-ra.93 r15)
        (set! tmp.20 rdi)
        (set! tmp.21 rsi)
        (if (begin
              (if (begin
                    (begin
                      (set! tmp.107 tmp.21)
                      (set! tmp.107 (bitwise-and tmp.107 7))
                      (set! tmp.57 tmp.107))
                    (= tmp.57 0))
                (set! tmp.56 14)
                (set! tmp.56 6))
              (!= tmp.56 6))
          (if (begin
                (if (begin
                      (begin
                        (set! tmp.108 tmp.20)
                        (set! tmp.108 (bitwise-and tmp.108 7))
                        (set! tmp.59 tmp.108))
                      (= tmp.59 0))
                  (set! tmp.58 14)
                  (set! tmp.58 6))
                (!= tmp.58 6))
            (begin
              (set! tmp.109 tmp.21)
              (set! tmp.109 (arithmetic-shift-right tmp.109 3))
              (set! tmp.60 tmp.109)
              (set! tmp.110 tmp.20)
              (set! tmp.110 (* tmp.110 tmp.60))
              (set! rax tmp.110)
              (jump tmp-ra.93 rbp rax))
            (begin (set! rax 318) (jump tmp-ra.93 rbp rax)))
          (begin (set! rax 318) (jump tmp-ra.93 rbp rax)))))
    (define L.+.16
      ((new-frames ()))
      (begin
        (set! tmp-ra.94 r15)
        (set! tmp.22 rdi)
        (set! tmp.23 rsi)
        (if (begin
              (if (begin
                    (begin
                      (set! tmp.111 tmp.23)
                      (set! tmp.111 (bitwise-and tmp.111 7))
                      (set! tmp.62 tmp.111))
                    (= tmp.62 0))
                (set! tmp.61 14)
                (set! tmp.61 6))
              (!= tmp.61 6))
          (if (begin
                (if (begin
                      (begin
                        (set! tmp.112 tmp.22)
                        (set! tmp.112 (bitwise-and tmp.112 7))
                        (set! tmp.64 tmp.112))
                      (= tmp.64 0))
                  (set! tmp.63 14)
                  (set! tmp.63 6))
                (!= tmp.63 6))
            (begin
              (set! tmp.113 tmp.22)
              (set! tmp.113 (+ tmp.113 tmp.23))
              (set! rax tmp.113)
              (jump tmp-ra.94 rbp rax))
            (begin (set! rax 574) (jump tmp-ra.94 rbp rax)))
          (begin (set! rax 574) (jump tmp-ra.94 rbp rax)))))
    (define L.-.15
      ((new-frames ()))
      (begin
        (set! tmp-ra.95 r15)
        (set! tmp.24 rdi)
        (set! tmp.25 rsi)
        (if (begin
              (if (begin
                    (begin
                      (set! tmp.114 tmp.25)
                      (set! tmp.114 (bitwise-and tmp.114 7))
                      (set! tmp.66 tmp.114))
                    (= tmp.66 0))
                (set! tmp.65 14)
                (set! tmp.65 6))
              (!= tmp.65 6))
          (if (begin
                (if (begin
                      (begin
                        (set! tmp.115 tmp.24)
                        (set! tmp.115 (bitwise-and tmp.115 7))
                        (set! tmp.68 tmp.115))
                      (= tmp.68 0))
                  (set! tmp.67 14)
                  (set! tmp.67 6))
                (!= tmp.67 6))
            (begin
              (set! tmp.116 tmp.24)
              (set! tmp.116 (- tmp.116 tmp.25))
              (set! rax tmp.116)
              (jump tmp-ra.95 rbp rax))
            (begin (set! rax 830) (jump tmp-ra.95 rbp rax)))
          (begin (set! rax 830) (jump tmp-ra.95 rbp rax)))))
    (define L.fun/ascii-char27114.4
      ((new-frames ()))
      (begin
        (set! tmp-ra.96 r15)
        (set! r15 tmp-ra.96)
        (jump L.fun/ascii-char27115.8 rbp r15)))
    (define L.fun/empty27120.5
      ((new-frames ()))
      (begin
        (set! tmp-ra.97 r15)
        (set! r15 tmp-ra.97)
        (jump L.fun/empty27121.11 rbp r15)))
    (define L.fun/error27116.6
      ((new-frames ()))
      (begin
        (set! tmp-ra.98 r15)
        (set! r15 tmp-ra.98)
        (jump L.fun/error27117.7 rbp r15)))
    (define L.fun/error27117.7
      ((new-frames ()))
      (begin (set! tmp-ra.99 r15) (set! rax 34622) (jump tmp-ra.99 rbp rax)))
    (define L.fun/ascii-char27115.8
      ((new-frames ()))
      (begin (set! tmp-ra.100 r15) (set! rax 23342) (jump tmp-ra.100 rbp rax)))
    (define L.fun/ascii-char27123.9
      ((new-frames ()))
      (begin (set! tmp-ra.101 r15) (set! rax 27694) (jump tmp-ra.101 rbp rax)))
    (define L.fun/ascii-char27122.10
      ((new-frames ()))
      (begin
        (set! tmp-ra.102 r15)
        (set! r15 tmp-ra.102)
        (jump L.fun/ascii-char27123.9 rbp r15)))
    (define L.fun/empty27121.11
      ((new-frames ()))
      (begin (set! tmp-ra.103 r15) (set! rax 22) (jump tmp-ra.103 rbp rax)))
    (define L.fun/empty27118.12
      ((new-frames ()))
      (begin
        (set! tmp-ra.104 r15)
        (set! r15 tmp-ra.104)
        (jump L.fun/empty27119.13 rbp r15)))
    (define L.fun/empty27119.13
      ((new-frames ()))
      (begin (set! tmp-ra.105 r15) (set! rax 22) (jump tmp-ra.105 rbp rax)))
    (begin
      (set! tmp-ra.106 r15)
      (return-point L.rp.18
        (begin (set! r15 L.rp.18) (jump L.fun/ascii-char27114.4 rbp r15)))
      (set! ascii-char0.6 rax)
      (return-point L.rp.19
        (begin (set! r15 L.rp.19) (jump L.fun/error27116.6 rbp r15)))
      (set! error1.5 rax)
      (return-point L.rp.20
        (begin (set! r15 L.rp.20) (jump L.fun/empty27118.12 rbp r15)))
      (set! empty2.4 rax)
      (return-point L.rp.21
        (begin (set! r15 L.rp.21) (jump L.fun/empty27120.5 rbp r15)))
      (set! empty3.3 rax)
      (return-point L.rp.22
        (begin
          (set! rsi 584)
          (set! rdi 608)
          (set! r15 L.rp.22)
          (jump L.-.15 rbp r15 rdi rsi)))
      (set! tmp.71 rax)
      (return-point L.rp.23
        (begin
          (set! rsi 1304)
          (set! rdi 1776)
          (set! r15 L.rp.23)
          (jump L.-.15 rbp r15 rdi rsi)))
      (set! tmp.72 rax)
      (return-point L.rp.24
        (begin
          (set! rsi tmp.72)
          (set! rdi tmp.71)
          (set! r15 L.rp.24)
          (jump L.-.15 rbp r15 rdi rsi)))
      (set! tmp.70 rax)
      (return-point L.rp.25
        (begin
          (set! rsi 1824)
          (set! rdi 1456)
          (set! r15 L.rp.25)
          (jump L.+.16 rbp r15 rdi rsi)))
      (set! tmp.74 rax)
      (return-point L.rp.26
        (begin
          (set! rsi 312)
          (set! rdi 1832)
          (set! r15 L.rp.26)
          (jump L.+.16 rbp r15 rdi rsi)))
      (set! tmp.75 rax)
      (return-point L.rp.27
        (begin
          (set! rsi tmp.75)
          (set! rdi tmp.74)
          (set! r15 L.rp.27)
          (jump L.+.16 rbp r15 rdi rsi)))
      (set! tmp.73 rax)
      (return-point L.rp.28
        (begin
          (set! rsi tmp.73)
          (set! rdi tmp.70)
          (set! r15 L.rp.28)
          (jump L.+.16 rbp r15 rdi rsi)))
      (set! tmp.69 rax)
      (return-point L.rp.29
        (begin
          (set! rsi 8)
          (set! rdi 1536)
          (set! r15 L.rp.29)
          (jump L.-.15 rbp r15 rdi rsi)))
      (set! tmp.78 rax)
      (return-point L.rp.30
        (begin
          (set! rsi 912)
          (set! rdi 648)
          (set! r15 L.rp.30)
          (jump L.-.15 rbp r15 rdi rsi)))
      (set! tmp.79 rax)
      (return-point L.rp.31
        (begin
          (set! rsi tmp.79)
          (set! rdi tmp.78)
          (set! r15 L.rp.31)
          (jump L.*.17 rbp r15 rdi rsi)))
      (set! tmp.77 rax)
      (return-point L.rp.32
        (begin
          (set! rsi 1304)
          (set! rdi 688)
          (set! r15 L.rp.32)
          (jump L.+.16 rbp r15 rdi rsi)))
      (set! tmp.81 rax)
      (return-point L.rp.33
        (begin
          (set! rsi 1096)
          (set! rdi 1544)
          (set! r15 L.rp.33)
          (jump L.-.15 rbp r15 rdi rsi)))
      (set! tmp.82 rax)
      (return-point L.rp.34
        (begin
          (set! rsi tmp.82)
          (set! rdi tmp.81)
          (set! r15 L.rp.34)
          (jump L.+.16 rbp r15 rdi rsi)))
      (set! tmp.80 rax)
      (return-point L.rp.35
        (begin
          (set! rsi tmp.80)
          (set! rdi tmp.77)
          (set! r15 L.rp.35)
          (jump L.*.17 rbp r15 rdi rsi)))
      (set! tmp.76 rax)
      (return-point L.rp.36
        (begin
          (set! rsi tmp.76)
          (set! rdi tmp.69)
          (set! r15 L.rp.36)
          (jump L.+.16 rbp r15 rdi rsi)))
      (set! fixnum4.2 rax)
      (return-point L.rp.37
        (begin (set! r15 L.rp.37) (jump L.fun/ascii-char27122.10 rbp r15)))
      (set! ascii-char5.1 rax)
      (return-point L.rp.38
        (begin
          (set! rsi 1928)
          (set! rdi fixnum4.2)
          (set! r15 L.rp.38)
          (jump L.*.17 rbp r15 rdi rsi)))
      (set! tmp.85 rax)
      (return-point L.rp.39
        (begin
          (set! rsi tmp.85)
          (set! rdi fixnum4.2)
          (set! r15 L.rp.39)
          (jump L.-.15 rbp r15 rdi rsi)))
      (set! tmp.84 rax)
      (return-point L.rp.40
        (begin
          (set! rsi fixnum4.2)
          (set! rdi 184)
          (set! r15 L.rp.40)
          (jump L.+.16 rbp r15 rdi rsi)))
      (set! tmp.87 rax)
      (return-point L.rp.41
        (begin
          (set! rsi tmp.87)
          (set! rdi fixnum4.2)
          (set! r15 L.rp.41)
          (jump L.+.16 rbp r15 rdi rsi)))
      (set! tmp.86 rax)
      (return-point L.rp.42
        (begin
          (set! rsi tmp.86)
          (set! rdi tmp.84)
          (set! r15 L.rp.42)
          (jump L.*.17 rbp r15 rdi rsi)))
      (set! tmp.83 rax)
      (return-point L.rp.43
        (begin
          (set! rsi 912)
          (set! rdi 920)
          (set! r15 L.rp.43)
          (jump L.-.15 rbp r15 rdi rsi)))
      (set! tmp.90 rax)
      (return-point L.rp.44
        (begin
          (set! rsi fixnum4.2)
          (set! rdi tmp.90)
          (set! r15 L.rp.44)
          (jump L.+.16 rbp r15 rdi rsi)))
      (set! tmp.89 rax)
      (return-point L.rp.45
        (begin
          (set! rsi 1752)
          (set! rdi 792)
          (set! r15 L.rp.45)
          (jump L.-.15 rbp r15 rdi rsi)))
      (set! tmp.92 rax)
      (return-point L.rp.46
        (begin
          (set! rsi fixnum4.2)
          (set! rdi tmp.92)
          (set! r15 L.rp.46)
          (jump L.-.15 rbp r15 rdi rsi)))
      (set! tmp.91 rax)
      (return-point L.rp.47
        (begin
          (set! rsi tmp.91)
          (set! rdi tmp.89)
          (set! r15 L.rp.47)
          (jump L.-.15 rbp r15 rdi rsi)))
      (set! tmp.88 rax)
      (set! rsi tmp.88)
      (set! rdi tmp.83)
      (set! r15 tmp-ra.106)
      (jump L.-.15 rbp r15 rdi rsi))))