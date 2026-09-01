#lang racket
(require rackunit
         cpsc411/compiler-lib
         cpsc411/ptr-run-time
         cpsc411/langs/v8
         cpsc411/langs/v9
         cpsc411/langs/v11
         "../expand-macros.rkt")
(define (fail-if-invalid p)
  (when (not (exprs-lang-v9? p))
    (error
     (~a
      (pretty-format p)
      "\n is not a semantically valid "
      "exprs-lang-v9"
      " program")))
  p)
(define-syntax-rule
 (check-by-interp p)
 (check-equal?
  (interp-racketish-surface p)
  (interp-exprs-lang-v9 (fail-if-invalid (expand-macros p)))))

(check-by-interp '(module empty))
(check-by-interp '(module (error 240)))
(check-by-interp '(module empty))
(check-by-interp '(module #\x))
(check-by-interp '(module (and empty empty)))
(check-by-interp '(module (let () 212)))
(check-by-interp
 '(module (define fun/fixnum8485 (lambda () 60)) (call fun/fixnum8485)))
(check-by-interp
 '(module
    (define fun/ascii-char8488 (lambda () #\A))
    (call fun/ascii-char8488)))
(check-by-interp
 '(module
    (define fun/ascii-char8491 (lambda () #\Z))
    (call fun/ascii-char8491)))
(check-by-interp '(module (or #\h #\l #\K #\i #\m #\y)))
(check-by-interp '(module (if #t 219 101)))
(check-by-interp
 '(module (define fun/empty8500 (lambda () empty)) (call fun/empty8500)))
(check-by-interp
 '(module
    (and (let () empty)
         (and empty empty empty empty empty empty)
         (if #t empty empty))))
(check-by-interp
 '(module
    (define fun/void8514 (lambda () (void)))
    (define fun/void8513 (lambda () (void)))
    (begin
      (if #f (void) (void))
      (call fun/void8513)
      (let ((vector0 #(0 1 2 3 4 5 6 7))) (void))
      (begin (void) (void) (void) (void))
      (let () (void))
      (let () (void))
      (call fun/void8514))))
(check-by-interp '(module (let () empty)))
(check-by-interp '(module (let () #\Y)))
(check-by-interp
 '(module
    (define fun/empty8524 (lambda () (if #f empty empty)))
    (call fun/empty8524)))
(check-by-interp '(module (if #t empty empty)))
(check-by-interp '(module (let ((fixnum0 33)) #t)))
(check-by-interp
 '(module
    (define fun/void8531 (lambda () (if #f (void) (void))))
    (call fun/void8531)))
(check-by-interp
 '(module
    (define fun/void8538 (lambda () (void)))
    (and (and (void) (void)) (call fun/void8538))))
(check-by-interp '(module (if #f #\_ #\i)))
(check-by-interp
 '(module
    (define fun/fixnum8543 (lambda () (call fun/fixnum8544)))
    (define fun/fixnum8544 (lambda () 117))
    (call fun/fixnum8543)))
(check-by-interp '(module (if #f (error 164) (error 184))))
(check-by-interp '(module (let () #\Z)))
(check-by-interp
 '(module
    (define fun/fixnum8551 (lambda () (if #t 67 129)))
    (call fun/fixnum8551)))
(check-by-interp
 '(module
    (define fun/error8558 (lambda () (call fun/error8559)))
    (define fun/error8559 (lambda () (error 186)))
    (call fun/error8558)))
(check-by-interp
 '(module
    (define fun/void8562 (lambda () (call fun/void8563)))
    (define fun/void8565 (lambda () (void)))
    (define fun/void8564 (lambda () (call fun/void8565)))
    (define fun/void8563 (lambda () (void)))
    (and (call fun/void8562)
         (let ((void0 (void)) (error1 (error 196))) (void))
         (call fun/void8564))))
(check-by-interp
 '(module
    (define fun/ascii-char8568 (lambda (oprand0) (call fun/ascii-char8569)))
    (define fun/ascii-char8569 (lambda () #\X))
    (call fun/ascii-char8568 (if #t 65 125))))
(check-by-interp
 '(module
    (let ((vector0
           #((make-vector 8)
             '(206 384)
             '(188 505)
             #\l
             '(154 282)
             (void)
             (lambda () 892)
             #f))
          (void1 (begin (void) (void) (void) (void) (void))))
      (let () 170))))
(check-by-interp
 '(module
    (define fun/boolean8574 (lambda (oprand0) #f))
    (if (call fun/boolean8574 (make-vector 8))
      (if #t #\C #\])
      (let ((void0 (void)) (pair1 '(184 385))) #\Y))))
(check-by-interp
 '(module
    (define fun/empty8578 (lambda () (call fun/empty8579)))
    (define fun/empty8579 (lambda () empty))
    (define fun/empty8577 (lambda (oprand0) (if #f empty empty)))
    (and (let ((ascii-char0 #\^)) empty)
         (call fun/empty8577 (and empty empty empty empty))
         (let () empty)
         (let ((procedure0 (lambda () #f)) (fixnum1 204)) empty)
         (call fun/empty8578))))
(check-by-interp
 '(module
    (define fun/vector8584 (lambda () (vector 1 2 3 4 5 6 7 8)))
    (define fun/fixnum8582 (lambda () 234))
    (define fun/fixnum8583 (lambda (oprand0) (if #f 70 77)))
    (call
     >=
     (call * (let () 78) (call fun/fixnum8582))
     (call fun/fixnum8583 (call fun/vector8584)))))
(check-by-interp
 '(module
    (define fun/empty8588 (lambda (oprand0) (let () empty)))
    (define fun/empty8587 (lambda () empty))
    (or (if #f empty empty)
        (if #f empty empty)
        (let () empty)
        (if #f empty empty)
        (and (if #t empty empty)
             (let ((fixnum0 114)) empty)
             (if #t empty empty)
             (or empty empty empty empty empty empty empty)
             (let () empty)
             (call fun/empty8587)
             (let ((fixnum0 110)) empty))
        (let () empty)
        (call fun/empty8588 (begin 203 29 74 228 185)))))
(check-by-interp
 '(module
    (define fun/empty8592 (lambda () (if #t empty empty)))
    (define fun/empty8594 (lambda (oprand0) (if #f empty empty)))
    (define fun/empty8593 (lambda (oprand0) (let () empty)))
    (define fun/empty8591 (lambda (oprand0) empty))
    (define fun/empty8595 (lambda () empty))
    (begin
      (let ((pair0 '(253 358)) (pair1 '(169 295))) empty)
      (or (if #f empty empty)
          (if #f empty empty)
          (begin empty empty empty empty empty empty)
          (let () empty)
          (call fun/empty8591 139))
      (call fun/empty8592)
      (call fun/empty8593 (let ((pair0 '(112 452))) (error 248)))
      (call fun/empty8594 (or (error 149)))
      (let () empty)
      (and (call fun/empty8595) (if #t empty empty)))))
(check-by-interp
 '(module
    (define fun/fixnum8598 (lambda () 203))
    (define fun/fixnum8599 (lambda () 64))
    (and (begin
           (call fun/fixnum8598)
           (let () 107)
           (call fun/fixnum8599)
           (if #t 192 15)))))
(check-by-interp
 '(module
    (define fun/fixnum8602 (lambda (oprand0) (call fun/fixnum8603)))
    (define fun/fixnum8604 (lambda () 49))
    (define fun/fixnum8603 (lambda () (call fun/fixnum8604)))
    (call fun/fixnum8602 (if #t '(141 350) '(232 266)))))
(check-by-interp
 '(module
    (define fun/error8609 (lambda () (error 43)))
    (define fun/error8608 (lambda () (error 155)))
    (define fun/error8607 (lambda (oprand0) oprand0))
    (or (or (call fun/error8607 (error 221))
            (call fun/error8608)
            (and (error 37)
                 (error 42)
                 (error 98)
                 (error 1)
                 (error 165)
                 (error 150))
            (if #f (error 91) (error 43))
            (begin (error 171) (error 153) (error 111) (error 206) (error 173))
            (call fun/error8609))
        (if #t (error 249) (error 66))
        (let () (error 165)))))
(check-by-interp
 '(module
    (define fun/fixnum8612 (lambda () (call fun/fixnum8613)))
    (define fun/fixnum8614 (lambda () 46))
    (define fun/fixnum8613 (lambda () (call fun/fixnum8614)))
    (call fun/fixnum8612)))
(check-by-interp '(module (and (if #f 144 165))))
(check-by-interp
 '(module (if (if #t #f #f) (if #t (void) (void)) (or (void) (void)))))
(check-by-interp '(module (if (if #f #t #t) (or #\[ #\F) (if #f #\H #\B))))
(check-by-interp '(module (let () (if #t empty empty))))
(check-by-interp
 '(module
    (define fun/boolean8626 (lambda (oprand0) #f))
    (define fun/boolean8625 (lambda (oprand0) (if #t #t #f)))
    (call
     fun/boolean8625
     (or (if #f #f #f)
         (if #f #f #t)
         (call fun/boolean8626 #(0 1 2 3 4 5 6 7))
         (let ((procedure0 (lambda () #(0 1 2 3 4 5 6 7)))
               (vector1 (make-vector 8)))
           #t)
         (let ((ascii-char0 #\B)
               (procedure1 (lambda () (vector 1 2 3 4 5 6 7 8))))
           #t)))))
(check-by-interp '(module (let () (let ((void0 (void))) (void)))))
(check-by-interp
 '(module
    (define fun/empty8631 (lambda (oprand0) (if #t empty empty)))
    (call fun/empty8631 (let ((error0 (error 175))) '(187 430)))))
(check-by-interp
 '(module
    (define fun/empty8634 (lambda () (if #t empty empty)))
    (call fun/empty8634)))
(check-by-interp
 '(module
    (define fun/vector8638 (lambda () #(0 1 2 3 4 5 6 7)))
    (define fun/void8637 (lambda () (void)))
    (define fun/fixnum8639 (lambda () 23))
    (let ((void0 (call fun/void8637))
          (procedure1 (lambda () (call fun/vector8638))))
      (call fun/fixnum8639))))
(check-by-interp
 '(module
    (define fun/fixnum8642 (lambda () 171))
    (if (let () #f) (if #f 157 104) (call fun/fixnum8642))))
(check-by-interp
 '(module
    (let ((vector0 #(112 (lambda () 928) empty #f (void) #\t empty empty)))
      (let ((ascii-char0 #\P)) (void)))))
(check-by-interp
 '(module
    (define fun/ascii-char8647
      (lambda () (let ((vector0 #(0 1 2 3 4 5 6 7))) #\])))
    (define fun/ascii-char8648 (lambda (oprand0) #\u))
    (or (call fun/ascii-char8647)
        (let ((procedure0 (lambda () (lambda () 813)))) #\r)
        (or (call fun/ascii-char8648 220)
            (let ((procedure0 (lambda () (error 180))) (error1 (error 170)))
              #\C)
            (begin #\\ #\^))
        (let ((error0 (error 253))) #\R)
        (if #f #\K #\m))))
(check-by-interp
 '(module
    (define fun/void8651 (lambda () (void)))
    (let ((vector0
           #(empty
             (vector 1 2 3 4 5 6 7 8)
             (void)
             (error 187)
             #t
             (error 0)
             #\A
             110)))
      (call fun/void8651))))
(check-by-interp
 '(module
    (define fun/void8654 (lambda (oprand0) (if #f (void) (void))))
    (call
     fun/void8654
     (let ((procedure0 (lambda (oprand0) #t))) (lambda () 908)))))
(check-by-interp
 '(module
    (define fun/ascii-char8657 (lambda (oprand0) #\^))
    (let () (call fun/ascii-char8657 (void)))))
(check-by-interp
 '(module
    (define fun/fixnum8661 (lambda () 122))
    (define fun/empty8660 (lambda () empty))
    (let ((empty0 (call fun/empty8660)) (boolean1 (or #f)))
      (call fun/fixnum8661))))
(check-by-interp
 '(module
    (define fun/fixnum8664 (lambda (oprand0) 40))
    (or (and (if #t 75 131)
             (begin 219 29 199 203 163)
             (call fun/fixnum8664 '(205 453))))))
(check-by-interp
 '(module
    (define fun/error8667 (lambda (oprand0) (if #t (error 243) (error 182))))
    (call fun/error8667 (if #f #\k #\l))))
(check-by-interp
 '(module
    (define fun/empty8670 (lambda () empty))
    (define fun/empty8671 (lambda () (if #f empty empty)))
    (begin
      (or (call fun/empty8670) (if #f empty empty) (and empty))
      (call fun/empty8671))))
(check-by-interp
 '(module
    (define fun/void8674 (lambda () (void)))
    (let () (call fun/void8674))))
(check-by-interp
 '(module
    (define fun/void8678 (lambda () (void)))
    (define fun/any8677 (lambda () 207))
    (let ((boolean0 (call fixnum? (call fun/any8677)))
          (pair1 '(#t (60 352) #\U #f #\h (183 445) #f #t))
          (vector2
           #((begin '(210 265))
             (let () (error 49))
             (let () (lambda () 607))
             (call fun/void8678)
             (if #f (void) (void))
             (let () 179)
             (if #t (lambda () 687) (lambda () 691))
             (and 216 101 8 78 234))))
      (let () (void)))))
(check-by-interp
 '(module
    (define fun/error8682 (lambda () (error 7)))
    (define fun/boolean8683 (lambda () #f))
    (define fun/error8681 (lambda () (call fun/error8682)))
    (define fun/boolean8684 (lambda () #t))
    (let ((pair0 '((218 271) #t (220 505) (246 281) #t empty (148 289) #\e))
          (error1 (call fun/error8681))
          (procedure2 (lambda () (let () #(0 1 2 3 4 5 6 7)))))
      (or (if #f #f #t)
          (procedure? (error 58))
          (call fun/boolean8683)
          (call fun/boolean8684)
          (begin #f #t #t)
          (or #f #f #t #f)))))
(check-by-interp
 '(module
    (define fun/error8688 (lambda () (error 156)))
    (define fun/error8687 (lambda (oprand0 oprand1) (call fun/error8688)))
    (begin
      (or (or (let ((error0 (error 234))) (error 178))
              (if #t (error 31) (error 214))
              (if #f (error 168) (error 132)))
          (let ((pair0 '(29 492))) (error 235))
          (if #f (error 222) (error 127))
          (let ((vector0 (vector 1 2 3 4 5 6 7 8))) (error 216))
          (let () (error 117))
          (call fun/error8687 (if #f (void) (void)) (if #f empty empty))))))
(check-by-interp
 '(module
    (define fun/void8692 (lambda (oprand0 oprand1) (void)))
    (define fun/void8693 (lambda (oprand0 oprand1) (let () (void))))
    (define fun/boolean8691 (lambda () #f))
    (define fun/void8694 (lambda () (void)))
    (if (or (let ((pair0 '(214 273)) (error1 (error 15))) #t)
            (boolean? #\^)
            (call fun/boolean8691)
            (error? #f)
            (if #t #f #f))
      (and (let ((procedure0 (lambda () (error 38)))
                 (error1 (error 99))
                 (empty2 empty))
             (void))
           (let () (void))
           (if #t (void) (void))
           (call fun/void8692 #\t (error 161))
           (and (void) (void) (void))
           (and (void) (void) (void) (void)))
      (call fun/void8693 (begin 26 21 162 104 106) (call fun/void8694)))))
(check-by-interp
 '(module
    (define fun/error8697 (lambda () (let () (error 156))))
    (let ((error0 (call fun/error8697)) (error1 (let () (error 2))))
      (if #t (error 191) (error 77)))))
(check-by-interp
 '(module
    (define fun/void8702 (lambda () (void)))
    (define fun/void8701 (lambda () (call fun/void8702)))
    (define fun/empty8700 (lambda () empty))
    (let ((empty0
           (or (let () empty)
               (if #t empty empty)
               (let () empty)
               (and empty empty empty)
               (let () empty)
               (call fun/empty8700)
               (if #t empty empty)))
          (ascii-char1 (if #f #\m #\F))
          (void2 (call fun/void8701)))
      (if #f #t #t))))
(check-by-interp
 '(module
    (define fun/void8706 (lambda (oprand0 oprand1) (let () oprand1)))
    (define fun/void8714 (lambda () (call fun/void8715)))
    (define fun/void8713 (lambda () (void)))
    (define fun/void8705 (lambda () (void)))
    (define fun/void8708 (lambda (oprand0) (void)))
    (define fun/void8709 (lambda () (void)))
    (define fun/void8710 (lambda (oprand0) (void)))
    (define fun/boolean8712 (lambda () #f))
    (define fun/void8715 (lambda () (void)))
    (define fun/void8711
      (lambda (oprand0 oprand1) (vector-set! oprand1 5 oprand0)))
    (define fun/void8707 (lambda (oprand0) oprand0))
    (and (let ((empty0 (if #f empty empty)))
           (and (void) (void) (void) (void) (void)))
         (and (if #f (void) (void))
              (or (and (void) (void))
                  (if #t (void) (void))
                  (call fun/void8705)
                  (if #f (void) (void))
                  (if #f (void) (void))
                  (let () (void))
                  (begin (void) (void)))
              (call fun/void8706 (if #t (void) (void)) (if #f (void) (void)))
              (let ((vector0 #(0 1 2 3 4 5 6 7))
                    (ascii-char1 #\n)
                    (vector2 #(0 1 2 3 4 5 6 7)))
                (void))
              (and (or (void) (void))
                   (call fun/void8707 (void))
                   (if #t (void) (void))
                   (if #t (void) (void))
                   (call fun/void8708 #\d)
                   (let ((error0 (error 213))) (void))))
         (if (let ((boolean0 #f)) #t)
           (call fun/void8709)
           (call fun/void8710 empty))
         (let () (call fun/void8711 (lambda () 1012) (vector 1 2 3 4 5 6 7 8)))
         (if (call fun/boolean8712)
           (let ((pair0 '(164 281))
                 (vector1 (vector 1 2 3 4 5 6 7 8))
                 (error2 (error 86)))
             (void))
           (call fun/void8713))
         (or (if #f (void) (void))
             (call fun/void8714)
             (let ((fixnum0 202) (error1 (error 86))) (void))))))
(check-by-interp
 '(module
    (define fun/boolean8722 (lambda () #t))
    (define fun/fixnum8721
      (lambda ()
        (if (call fun/boolean8722)
          (let ((empty0 empty)) 242)
          (let ((pair0 '(87 424)) (fixnum1 124)) 132))))
    (call fun/fixnum8721)))
(check-by-interp
 '(module
    (define fun/ascii-char8726 (lambda () (if #t #\H #\a)))
    (define fun/ascii-char8725 (lambda () #\s))
    (begin
      (begin (and (call fun/ascii-char8725)) (if #f #\k #\i) (if #t #\C #\E))
      (call fun/ascii-char8726)
      (let ((vector0
             #((make-vector 8)
               #\\
               (lambda () 1020)
               231
               (void)
               #\o
               212
               (error 79))))
        (call vector-ref vector0 5)))))
(check-by-interp
 '(module
    (define fun/empty8731 (lambda () empty))
    (define fun/pair8730 (lambda () (if #t '(220 397) '(228 458))))
    (define fun/empty8729 (lambda (oprand0 oprand1) (if #f empty empty)))
    (or (let () (begin empty empty))
        (call fun/empty8729 (call fun/pair8730) (let () (error 128)))
        (let ((vector0
               #((vector 1 2 3 4 5 6 7 8)
                 #t
                 (error 169)
                 (void)
                 31
                 (error 119)
                 (lambda () 773)
                 (void)))
              (procedure1 (lambda () (let () empty)))
              (empty2 (let () empty)))
          (call fun/empty8731))
        (if (let ((error0 (error 40))
                  (vector1 (vector 1 2 3 4 5 6 7 8))
                  (boolean2 #t))
              #t)
          (or empty empty empty empty empty empty empty)
          (begin empty empty empty))
        (if (pair? '(61 385)) (if #t empty empty) (and empty))
        (let () (if #f empty empty)))))
(check-by-interp
 '(module
    (define fun/error8736 (lambda () (call fun/error8737)))
    (define fun/boolean8735 (lambda () #f))
    (define fun/error8737 (lambda () (error 242)))
    (define fun/boolean8734 (lambda () (call fun/boolean8735)))
    (let ((procedure0 (lambda () (let () #t)))
          (boolean1 (call fun/boolean8734))
          (ascii-char2 (if #t #\z #\u)))
      (call fun/error8736))))
(check-by-interp
 '(module
    (define fun/void8741 (lambda () (void)))
    (define fun/void8740 (lambda (oprand0 oprand1) (void)))
    (let ()
      (begin
        (call fun/void8740 191 72)
        (begin (void) (void) (void) (void) (void) (void))
        (call fun/void8741)
        (let () (void))
        (or (void) (void) (void) (void) (void))
        (let ((fixnum0 189)) (void))))))
(check-by-interp
 '(module
    (define fun/empty8745 (lambda () (call fun/empty8746)))
    (define fun/empty8744 (lambda (oprand0) (call fun/empty8745)))
    (define fun/vector8748 (lambda () #(0 1 2 3 4 5 6 7)))
    (define fun/empty8746 (lambda () (call fun/empty8747)))
    (define fun/empty8747 (lambda () empty))
    (call
     fun/empty8744
     (let ((fixnum0 (+ 209 230)) (fixnum1 (let () 196)))
       (call fun/vector8748)))))
(check-by-interp '(module (let () (if #f (void) (void)))))
(check-by-interp
 '(module
    (define fun/boolean8753 (lambda (oprand0) #t))
    (if (let ((ascii-char0 #\q) (void1 (void)) (boolean2 #t)) #t)
      (let ((empty0 empty) (fixnum1 19) (boolean2 #f)) #t)
      (or (call ascii-char? (lambda () 526))
          (if #f #t #t)
          (call fun/boolean8753 195)
          (begin #f #f #t #t #t #t #f)))))
(check-by-interp
 '(module
    (define fun/boolean8757 (lambda () #f))
    (define fun/boolean8756 (lambda (oprand0 oprand1) (call fun/boolean8757)))
    (if (call
         fun/boolean8756
         (let ((void0 (void))) (vector 1 2 3 4 5 6 7 8))
         (call >= 111 213))
      (if #t #\Q #\p)
      (let ((empty0 empty) (fixnum1 94)) #\l))))
(check-by-interp
 '(module
    (define fun/empty8761 (lambda () empty))
    (define fun/empty8760 (lambda () empty))
    (let ((empty0
           (or (call fun/empty8760) (if #t empty empty) (call fun/empty8761)))
          (empty1 (let () empty)))
      (and (let ((pair0 '(164 328))) #\Z)
           (and #\r #\Z #\j #\j #\^)
           (if #t #\V #\R)
           (let ((fixnum0 98)) #\X)))))
(check-by-interp
 '(module
    (define fun/fixnum8766 (lambda (oprand0) 66))
    (define fun/fixnum8765 (lambda () (call fun/fixnum8766 empty)))
    (define fun/boolean8764 (lambda (oprand0 oprand1) (let () #f)))
    (if (call
         fun/boolean8764
         (or (lambda () 522) (lambda () 662))
         (let ((ascii-char0 #\z)) (void)))
      (let ((vector0 (vector 1 2 3 4 5 6 7 8)) (fixnum1 211)) 23)
      (call fun/fixnum8765))))
(check-by-interp
 '(module (let ((boolean0 (let ((fixnum0 179)) #t))) (if #f empty empty))))
(check-by-interp
 '(module
    (define fun/fixnum8773 (lambda (oprand0) (call fun/fixnum8774)))
    (define fun/fixnum8771 (lambda () (call fun/fixnum8772 #f)))
    (define fun/fixnum8775 (lambda (oprand0) 117))
    (define fun/fixnum8774 (lambda () 126))
    (define fun/fixnum8772 (lambda (oprand0) 87))
    (call
     +
     (and (let () 213)
          (call fun/fixnum8771)
          (if #t 219 12)
          (if #f 137 140)
          (call fun/fixnum8773 (* 130 63))
          (let () 156))
     (if (let ((fixnum0 100) (pair1 '(19 454)) (pair2 '(5 453))) #f)
       (+ 124 32)
       (call fun/fixnum8775 '(111 440))))))
(check-by-interp '(module (let () (or (if #t #t #t)))))
(check-by-interp
 '(module
    (define fun/empty8780 (lambda () empty))
    (if (error? (if #t #t #\e))
      (and (and empty empty empty empty empty)
           (if #t empty empty)
           (if #t empty empty)
           (call fun/empty8780)
           (let ((pair0 '(18 445))
                 (vector1 (vector 1 2 3 4 5 6 7 8))
                 (pair2 '(194 316)))
             empty)
           (if #t empty empty))
      (if #f empty empty))))
(check-by-interp
 '(module
    (define fun/boolean8789 (lambda (oprand0) #t))
    (define fun/boolean8790 (lambda (oprand0 oprand1) #t))
    (define fun/ascii-char8791 (lambda (oprand0) (if #t #\m #\`)))
    (define fun/void8788 (lambda () (void)))
    (define fun/void8786 (lambda () (void)))
    (define fun/ascii-char8785 (lambda () #\k))
    (define fun/ascii-char8783
      (lambda (oprand0 oprand1) (call fun/ascii-char8784)))
    (define fun/void8787 (lambda (oprand0) (vector-set! oprand0 1 '(56 441))))
    (define fun/ascii-char8784 (lambda () (call fun/ascii-char8785)))
    (or (call
         fun/ascii-char8783
         (begin
           (let () (void))
           (and (void) (void) (void) (void) (void) (void))
           (or (void))
           (begin (void) (void))
           (call fun/void8786)
           (call fun/void8787 (vector 1 2 3 4 5 6 7 8))
           (call fun/void8788))
         (let ((error0 (error 149))) (error 198)))
        (let ((vector0
               #(empty #\Y 211 '(19 491) #\U '(239 358) 70 (error 150))))
          (if #f #\^ #\W))
        (if (call fun/boolean8789 (lambda () 792))
          (or #\[ #\W #\R #\Y)
          (if #t #\a #\^))
        (if (call fun/boolean8790 empty 240)
          (if #t #\v #\d)
          (and #\j #\H #\a #\E #\h #\K))
        (call
         fun/ascii-char8791
         (or (if #t (make-vector 8) (vector 1 2 3 4 5 6 7 8))
             (and (vector 1 2 3 4 5 6 7 8)
                  (vector 1 2 3 4 5 6 7 8)
                  (vector 1 2 3 4 5 6 7 8)))))))
(check-by-interp
 '(module
    (define fun/empty8795 (lambda (oprand0 oprand1) (let () empty)))
    (define fun/boolean8796 (lambda (oprand0) #t))
    (define fun/empty8794 (lambda (oprand0) empty))
    (begin
      (or (let ((boolean0 #f) (boolean1 #f) (empty2 empty)) empty)
          (and (let ((empty0 empty)) empty)
               (call fun/empty8794 (lambda () 949))
               (let () empty))
          (call
           fun/empty8795
           (call fun/boolean8796 #(0 1 2 3 4 5 6 7))
           (if #t (lambda () 556) (lambda () 797)))
          (if #t empty empty)
          (if #f empty empty)
          (begin
            (let ((error0 (error 163)) (pair1 '(164 444)) (ascii-char2 #\d))
              empty)
            (if #t empty empty))))))
(check-by-interp
 '(module
    (define fun/void8801 (lambda () (void)))
    (define fun/void8800 (lambda () (call fun/void8801)))
    (define fun/void8799 (lambda () (call fun/void8800)))
    (call fun/void8799)))
(check-by-interp
 '(module
    (define fun/any8804 (lambda (oprand0 oprand1) (error 108)))
    (if (call fixnum? (call fun/any8804 empty (void)))
      (let ((boolean0 #f) (boolean1 #t)) #t)
      (<
       (and 154 56 94 97 119 21)
       (let ((void0 (void)) (vector1 (vector 1 2 3 4 5 6 7 8)) (void2 (void)))
         92)))))
(check-by-interp
 '(module
    (define fun/fixnum8807
      (lambda () (let ((pair0 (cons #\j (error 63)))) 37)))
    (let () (call fun/fixnum8807))))
(check-by-interp
 '(module
    (let ((void0 (if #t (void) (void))))
      (let ((void0 (void)) (empty1 empty)) (void)))))
(check-by-interp
 '(module
    (let ((empty0 (let ((fixnum0 108) (error1 (error 116))) empty)))
      (if #f empty empty))))
(check-by-interp
 '(module
    (let ((empty0 (or (or empty empty)))
          (ascii-char1
           (begin
             (begin #\_ #\Z #\u #\Q)
             (let () #\^)
             (let () #\l)
             (let () #\m)))
          (error2 (let () (error 52))))
      (let () 18))))
(check-by-interp
 '(module
    (call
     +
     (and (if #t 94 161))
     (let ((pair0 '(empty 205 #f (34 258) #\L empty #f 84))) (if #f 39 166)))))
(check-by-interp
 '(module
    (define fun/ascii-char8826 (lambda () #\k))
    (define fun/ascii-char8823
      (lambda ()
        (if (call fun/boolean8824 '(112 300))
          (call fun/ascii-char8825)
          (call fun/ascii-char8826))))
    (define fun/ascii-char8825 (lambda () #\r))
    (define fun/boolean8824 (lambda (oprand0) #f))
    (call fun/ascii-char8823)))
(check-by-interp
 '(module
    (define fun/boolean8831 (lambda () (call fun/boolean8832)))
    (define fun/boolean8829 (lambda (oprand0) (call fun/boolean8830)))
    (define fun/boolean8832 (lambda () #t))
    (define fun/boolean8830 (lambda () (call fun/boolean8831)))
    (call
     fun/boolean8829
     (if (let ((void0 (void))) #f)
       (if #f empty empty)
       (let ((void0 (void))) empty)))))
(check-by-interp
 '(module
    (if (begin
          (let () #t)
          (and #t #f #f #t #t #t #t)
          (if #t #f #f)
          (if #f #f #t)
          (let () #f))
      (let ((error0 (error 211)) (boolean1 #f) (boolean2 #t)) (void))
      (let ((ascii-char0 #\F)
            (vector1 (vector 1 2 3 4 5 6 7 8))
            (ascii-char2 #\L))
        (void)))))
(check-by-interp
 '(module
    (define fun/ascii-char8840 (lambda (oprand0 oprand1) #\M))
    (define fun/ascii-char8839 (lambda (oprand0 oprand1) #\q))
    (define fun/ascii-char8841 (lambda (oprand0 oprand1) #\p))
    (define fun/boolean8837 (lambda (oprand0 oprand1) (call fun/boolean8838)))
    (define fun/boolean8838 (lambda () #f))
    (if (call
         fun/boolean8837
         (begin (error 9) (error 98) (error 17) (error 22))
         (begin
           #(0 1 2 3 4 5 6 7)
           (vector 1 2 3 4 5 6 7 8)
           (vector 1 2 3 4 5 6 7 8)))
      (and (if #t #\D #\R)
           (begin #\X #\b #\B #\o #\t)
           (call fun/ascii-char8839 empty (make-vector 8))
           (if #f #\B #\R)
           (call fun/ascii-char8840 (void) #f)
           (let ((pair0 '(60 439)) (empty1 empty)) #\F))
      (begin
        (and #\N #\V #\y #\d)
        (if #f #\M #\T)
        (begin #\s #\t #\r #\W)
        (let ((procedure0 (lambda () (void)))
              (empty1 empty)
              (error2 (error 52)))
          #\T)
        (or #\d #\w #\l #\W)
        (begin #\L #\K #\S #\W #\W)
        (call fun/ascii-char8841 empty 118)))))
(check-by-interp
 '(module
    (let ((boolean0 (let ((ascii-char0 #\U) (error1 (error 199))) #f)))
      (let ((boolean0 #f)) #\K))))
(check-by-interp
 '(module
    (define fun/error8847 (lambda () (call fun/error8848)))
    (define fun/error8846 (lambda (oprand0 oprand1) (call fun/error8847)))
    (define fun/pair8849 (lambda (oprand0) '(200 421)))
    (define fun/fixnum8851 (lambda (oprand0) 236))
    (define fun/fixnum8850 (lambda (oprand0) 31))
    (define fun/error8852 (lambda () (call fun/error8853)))
    (define fun/error8848 (lambda () (error 200)))
    (define fun/error8853 (lambda () (error 51)))
    (define fun/error8854 (lambda () (if #f (error 82) (error 144))))
    (define fun/error8855 (lambda () (error 63)))
    (or (call
         fun/error8846
         (begin (begin '(116 426) '(249 432)) (call fun/pair8849 #f))
         (* (call fun/fixnum8850 '(106 289)) (call fun/fixnum8851 (void))))
        (or (if #f (error 28) (error 67))
            (call fun/error8852)
            (and (let ((boolean0 #f)
                       (vector1 #(0 1 2 3 4 5 6 7))
                       (pair2 '(223 355)))
                   (error 185))
                 (let ((ascii-char0 #\R)) (error 120))
                 (if #f (error 82) (error 203))
                 (if #t (error 72) (error 18))
                 (let ((fixnum0 211) (ascii-char1 #\O) (void2 (void)))
                   (error 201))
                 (if #t (error 204) (error 149))))
        (call fun/error8854)
        (let ((error0 (call fun/error8855))
              (vector1
               #(#\P
                 #t
                 #t
                 (lambda () 731)
                 (error 110)
                 (error 120)
                 (error 249)
                 (lambda () 807)))
              (void2 (let () (void))))
          (let () (error 11)))
        (let ((procedure0 (lambda (oprand0) (or #f #t))))
          (let () (error 252))))))
(check-by-interp
 '(module
    (define fun/fixnum8859 (lambda () 240))
    (define fun/fixnum8863 (lambda () 189))
    (define fun/fixnum8864 (lambda (oprand0) (let () 246)))
    (define fun/void8861
      (lambda (oprand0 oprand1)
        (vector-set! oprand1 5 (vector-set! oprand1 3 oprand0))))
    (define fun/error8865 (lambda (oprand0) (error 210)))
    (define fun/fixnum8858 (lambda () (if #f 223 114)))
    (define fun/fixnum8860 (lambda (oprand0 oprand1) (let () 190)))
    (define fun/empty8862 (lambda (oprand0) empty))
    (begin
      (or (if #t 73 215)
          (call fun/fixnum8858)
          (let ((procedure0 (lambda () #\V))
                (error1 (error 143))
                (void2 (void)))
            166))
      (let ((pair0 '(empty #\t 164 empty 177 #\o (44 451) #\H))
            (fixnum1 (call fun/fixnum8859)))
        (if #t 42 198))
      (begin
        (call
         fun/fixnum8860
         (call fun/void8861 #\J (vector 1 2 3 4 5 6 7 8))
         (call fun/empty8862 186))
        (- (if #f 32 170) (call fun/fixnum8863))
        (let ((fixnum0 208) (fixnum1 116)) 46)
        (let ((empty0 empty) (boolean1 #f)) 65)
        (if #f 71 196)
        (let ((void0 (void)) (error1 (error 115)) (pair2 '(253 276))) 7))
      (call
       fun/fixnum8864
       (or (and (error 62)) (call fun/error8865 (lambda () 976)))))))
(check-by-interp
 '(module
    (define fun/fixnum8869 (lambda () 144))
    (define fun/fixnum8868 (lambda (oprand0 oprand1) (call fun/fixnum8869)))
    (if (let ((empty0 empty)
              (vector1 (vector 1 2 3 4 5 6 7 8))
              (procedure2 (lambda () '(148 308))))
          #f)
      (if #f 51 196)
      (call
       fun/fixnum8868
       (or (void) (void) (void) (void) (void) (void) (void))
       (begin #f #t)))))
(check-by-interp
 '(module
    (define fun/fixnum8875 (lambda (oprand0) (call fun/fixnum8876)))
    (define fun/fixnum8873 (lambda () (let () 155)))
    (define fun/fixnum8874
      (lambda () (call fun/fixnum8875 (call fun/pair8877 #\N))))
    (define fun/fixnum8872 (lambda (oprand0) (call fun/fixnum8873)))
    (define fun/fixnum8876 (lambda () 203))
    (define fun/pair8877 (lambda (oprand0) '(28 385)))
    (call fun/fixnum8872 (call fun/fixnum8874))))
(check-by-interp
 '(module
    (if (let ((void0 (void))) #t)
      (let ((empty0 empty) (empty1 empty) (boolean2 #t)) #\w)
      (if #t #\F #\w))))
(check-by-interp
 '(module
    (define fun/empty8882 (lambda () (call fun/empty8883 (void))))
    (define fun/empty8885 (lambda (oprand0 oprand1) empty))
    (define fun/empty8883 (lambda (oprand0) empty))
    (define fun/empty8884 (lambda () empty))
    (if (if #t #t #t)
      (call fun/empty8882)
      (and (call fun/empty8884)
           (or empty)
           (call fun/empty8885 (error 63) '(99 348))
           (let ((pair0 '(87 285)) (procedure1 (lambda () #(0 1 2 3 4 5 6 7))))
             empty)
           (or empty empty empty empty empty empty empty)
           (let ((error0 (error 188))) empty)
           (begin empty empty empty empty empty)))))
(check-by-interp
 '(module
    (let ((pair0 '(#\j #t #\z (42 508) 140 (214 430) #\L (23 329))))
      (let ((error0 (error 125))) (error 135)))))
(check-by-interp
 '(module
    (define fun/ascii-char8895 (lambda () #\I))
    (define fun/boolean8892 (lambda (oprand0 oprand1) (call fun/boolean8893)))
    (define fun/boolean8893 (lambda () #f))
    (define fun/ascii-char8894 (lambda () (call fun/ascii-char8895)))
    (if (call fun/boolean8892 (and 186 17 70 72 191 38) (and (void) (void)))
      (call fun/ascii-char8894)
      (if #t #\u #\M))))
(check-by-interp
 '(module
    (define fun/empty8899 (lambda (oprand0) (call fun/empty8900)))
    (define fun/error8902 (lambda (oprand0) (let () (error 138))))
    (define fun/empty8900 (lambda () (call fun/empty8901)))
    (define fun/empty8898
      (lambda () (call fun/empty8899 (call fun/error8902 (if #t #\C #\I)))))
    (define fun/empty8901 (lambda () empty))
    (call fun/empty8898)))
(check-by-interp
 '(module
    (define fun/empty8905 (lambda (oprand0) (let () empty)))
    (let ()
      (call
       fun/empty8905
       (let ((void0 (void)) (procedure1 (lambda () #\W)) (fixnum2 220))
         '(141 422))))))
(check-by-interp
 '(module
    (define fun/fixnum8912 (lambda (oprand0 oprand1) oprand0))
    (define fun/error8911
      (lambda (oprand0 oprand1) (if #f (error 227) (error 92))))
    (define fun/empty8908
      (lambda (oprand0)
        (if (call fun/boolean8909) (let () empty) (call fun/empty8910))))
    (define fun/boolean8909 (lambda () #f))
    (define fun/empty8910 (lambda () empty))
    (call
     fun/empty8908
     (call
      fun/error8911
      (call fun/fixnum8912 (begin 193 248 139) (if #f #f #t))
      (if #f 172 187)))))
(check-by-interp
 '(module
    (define fun/empty8915
      (lambda () (call fun/empty8916 (call fun/ascii-char8917 (if #t #t #f)))))
    (define fun/empty8916 (lambda (oprand0) (if #t empty empty)))
    (define fun/ascii-char8917 (lambda (oprand0) #\t))
    (call fun/empty8915)))
(check-by-interp
 '(module
    (define fun/void8925 (lambda (oprand0 oprand1) oprand0))
    (define fun/fixnum8922 (lambda () 32))
    (define fun/void8928 (lambda (oprand0 oprand1) (let () (void))))
    (define fun/fixnum8921 (lambda () (call fun/fixnum8922)))
    (define fun/fixnum8920 (lambda (oprand0 oprand1) (call fun/fixnum8921)))
    (define fun/void8924 (lambda () (void)))
    (define fun/void8923
      (lambda (oprand0)
        (let () (vector-set! oprand0 3 (vector-set! oprand0 4 '(148 417))))))
    (define fun/void8926 (lambda () (void)))
    (define fun/void8927
      (lambda () (let ((vector0 (vector 1 2 3 4 5 6 7 8))) (void))))
    (call
     fun/fixnum8920
     (call fun/void8923 (if #t (vector 1 2 3 4 5 6 7 8) #(0 1 2 3 4 5 6 7)))
     (or (begin
           (call fun/void8924)
           (and (void) (void) (void) (void) (void) (void))
           (let ((pair0 '(23 408))
                 (vector1 (vector 1 2 3 4 5 6 7 8))
                 (procedure2 (lambda () (lambda () 738))))
             (void))
           (call fun/void8925 (void) empty)
           (let ((ascii-char0 #\p) (error1 (error 127))) (void))
           (call fun/void8926))
         (call fun/void8927)
         (call
          fun/void8928
          (let ((error0 (error 214)) (fixnum1 220) (fixnum2 214)) '(245 379))
          (if #t '(229 508) '(135 424)))
         (if #t (void) (void))))))
(check-by-interp
 '(module (and (if (begin #f #f #f #f #t) (or (void)) (if #t (void) (void))))))
(check-by-interp
 '(module
    (define fun/boolean8934 (lambda () #t))
    (define fun/fixnum8933
      (lambda () (if (call fun/boolean8934) (if #t 180 142) (let () 34))))
    (call fun/fixnum8933)))
(check-by-interp '(module (let () (let () (error 250)))))
(check-by-interp
 '(module
    (define fun/void8949 (lambda (oprand0 oprand1) (let () (void))))
    (define fun/void8950 (lambda () (void)))
    (define fun/void8951 (lambda () (void)))
    (if (call
         ascii-char?
         (let ((procedure0 (lambda (oprand0) (lambda () 1019)))
               (pair1 '(69 333)))
           (error 189)))
      (call fun/void8949 (if #t 226 18) (begin #\Y #\t #\l #\s #\g #\V #\A))
      (or (let ((pair0 '(202 321)) (pair1 '(143 414))) (void))
          (if #t (void) (void))
          (call fun/void8950)
          (if #t (void) (void))
          (or (void))
          (call fun/void8951)))))
(check-by-interp
 '(module (or (begin (let ((boolean0 #f) (empty1 empty)) (void))))))
(check-by-interp
 '(module
    (define fun/error8958 (lambda () (if #t (error 216) (error 110))))
    (define fun/error8956 (lambda () (call fun/error8957)))
    (define fun/error8957 (lambda () (call fun/error8958)))
    (call fun/error8956)))
(check-by-interp
 '(module
    (define fun/error8961 (lambda () (call fun/error8962)))
    (define fun/error8962 (lambda () (error 73)))
    (let ((pair0 '((104 475) 0 #f empty 169 #t empty empty))
          (boolean1 (let () #f)))
      (call fun/error8961))))
(check-by-interp
 '(module
    (define fun/ascii-char8966 (lambda (oprand0 oprand1) #\j))
    (define fun/ascii-char8965 (lambda (oprand0 oprand1) #\g))
    (if (if #t #t #f)
      (or (if #t #\r #\`)
          (or #\Q #\E #\E)
          (if #f #\k #\J)
          (if #f #\M #\v)
          (call fun/ascii-char8965 #f (make-vector 8))
          (call fun/ascii-char8966 #(0 1 2 3 4 5 6 7) 235))
      (let ((ascii-char0 #\n) (ascii-char1 #\B)) #\O))))
(check-by-interp
 '(module
    (define fun/void8969 (lambda () (void)))
    (let ((ascii-char0 (if #f #\a #\S))
          (procedure1
           (lambda ()
             (or (and (void))
                 (call fun/void8969)
                 (if #f (void) (void))
                 (let () (void))
                 (let () (void))
                 (if #f (void) (void))
                 (let () (void)))))
          (procedure2 (lambda () (let () #f))))
      (if #t (error 237) (error 2)))))
(check-by-interp
 '(module
    (define fun/boolean8974 (lambda () #t))
    (define fun/boolean8973 (lambda (oprand0) (call fun/boolean8974)))
    (define fun/boolean8972
      (lambda ()
        (call fun/boolean8973 (if #f (lambda () 569) (lambda () 967)))))
    (call fun/boolean8972)))
(check-by-interp
 '(module
    (define fun/boolean8978 (lambda (oprand0) #t))
    (define fun/procedure8982 (lambda () (let () (lambda () 845))))
    (define fun/void8979 (lambda (oprand0 oprand1) (call fun/void8980)))
    (define fun/void8977 (lambda () (void)))
    (define fun/void8980 (lambda () (call fun/void8981)))
    (define fun/void8981 (lambda () (void)))
    (and (let ((void0 (call fun/void8977))
               (boolean1 (call pair? '(70 501)))
               (empty2 (if #t empty empty)))
           (if #t (void) (void)))
         (if (call fun/boolean8978 #\P)
           (if #f (void) (void))
           (or (void) (void)))
         (call
          fun/void8979
          (let ((fixnum0 64) (empty1 empty)) (vector 1 2 3 4 5 6 7 8))
          (call fun/procedure8982)))))
(check-by-interp
 '(module
    (define fun/fixnum8985 (lambda (oprand0) 23))
    (if (call
         >
         (call fun/fixnum8985 '(175 398))
         (begin 21 243 246 134 143 161 37))
      (let ((pair0 '(131 509))) (void))
      (let ((procedure0 (lambda () #\v)) (fixnum1 181) (pair2 '(38 400)))
        (void)))))
(check-by-interp
 '(module
    (define fun/void8988
      (lambda ()
        (if (call fun/boolean8989 '(233 346))
          (call fun/void8990 74)
          (if #f (void) (void)))))
    (define fun/boolean8989 (lambda (oprand0) #f))
    (define fun/void8990 (lambda (oprand0) (void)))
    (call fun/void8988)))
(check-by-interp
 '(module
    (define fun/fixnum8993 (lambda (oprand0) (call fun/fixnum8994)))
    (define fun/fixnum8994 (lambda () (if #f 82 210)))
    (call fun/fixnum8993 (let () (let ((empty0 empty)) (lambda () 562))))))
(check-by-interp
 '(module
    (define fun/error8998 (lambda () (call fun/error8999)))
    (define fun/error8999 (lambda () (error 87)))
    (define fun/boolean9002 (lambda () #t))
    (define fun/error8997 (lambda (oprand0) (call fun/error8998)))
    (define fun/boolean9001 (lambda () (call fun/boolean9002)))
    (define fun/procedure9000
      (lambda (oprand0) (if oprand0 (lambda () 608) (lambda () 525))))
    (call fun/error8997 (call fun/procedure9000 (call fun/boolean9001)))))
