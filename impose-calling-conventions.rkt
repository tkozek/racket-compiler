#lang racket

(require cpsc411/compiler-lib
         "common.rkt")
(provide impose-calling-conventions)

(define (make-nfv i)
  (fresh (string->symbol (string-join (list "nfv" (number->string i)) "_"))))

;; (Proc-imp-cmf-lang-v8 p) -> (Imp-cmf-lang-v8 p)
;; Compiles Proc-imp-cmf-lang v8 to Imp-cmf-lang v8
;; by imposing calling conventions on all calls and procedure definitions.
;; The parameter registers are defined by the list current-parameter-registers.
(define (impose-calling-conventions picl5)
  (define rbp (current-frame-base-pointer-register))
  (define ra (current-return-address-register))
  (define rv (current-return-value-register))
  ;; ...sorry to whoever has to maintain this sh*t in the next milestone
  (define new-frames '())

  ;; loc -> (void)
  ;; EFFECT: appends the newframe variables of the passed list of locations to new-frames
  (define (register-newframe! nfv*)
    (set! new-frames (append new-frames (list (filter aloc? nfv*)))))
  ;; -> (void)
  ;; EFFECT; resets new-frames to an empty list
  (define (reset-newframes!)
    (set! new-frames '()))
  ;; let trg-value be an value in imp-cmf-lang-v8
  (define tmp-ra (void))
  ; (listof opand) -> (listof rloc)
  ;  generates 1 rloc for each aloc, following the calling convention
  (define (generate-param-list aloc*)
    (define num-param-reg (length (current-parameter-registers)))
    (define (get-reg-or-fvar idx)
      (if (< idx num-param-reg)
          (list-ref (current-parameter-registers) idx)
          (make-fvar (- idx num-param-reg))))
    (map get-reg-or-fvar (range (length aloc*))))

  ; (listof opand) -> (listof (register or aloc))
  ;  generates 1 register or nfvar(new fvar) for each aloc, following the calling convention
  (define (generate-param-list/nfvar aloc*)
    (define num-param-reg (length (current-parameter-registers)))
    (define (get-reg-or-nfvar idx)
      (if (< idx num-param-reg)
          (list-ref (current-parameter-registers) idx)
          (fresh (make-nfv (- idx num-param-reg)))))
    (map get-reg-or-nfvar (range (length aloc*))))

  ; (listof X) (listof Y) -> (listof `(set ,X ,Y))
  ;  generates a list of set! expressions given X and Y
  (define (generate-sets X* Y*)
    (map (λ (x y) `(set! ,x ,y)) X* Y*))

  ;; value -> trg-value
  (define impose-non-calling-value identity)

  ;; EFFECT: may register new frame variables to new-frames
  (define (impose-pred! pred)
    (match pred
      [`(begin
          ,fx* ...
          ,pred)
       `(begin
          ,@(map impose-effect! fx*)
          ,(impose-pred! pred))]
      [`(not ,pred1) `(not ,(impose-pred! pred1))]
      [`(if ,pred0 ,pred1 ,pred2)
       `(if ,(impose-pred! pred0)
            ,(impose-pred! pred1)
            ,(impose-pred! pred2))]
      [_ pred]))

  ;; EFFECT: may register new frame variables to new-frames
  (define (impose-effect! fx)
    (match fx
      [`(begin
          ,fx* ...
          ,fx2)
       `(begin
          ,@(map impose-effect! fx*)
          ,(impose-effect! fx2))]
      [`(set! ,aloc ,value) (value->fx^! value (λ (trg-val) `(set! ,aloc ,trg-val)))]
      [`(mset! ,_ ,_ ,_) fx]
      [`(if ,pred ,fx1 ,fx2)
       `(if ,(impose-pred! pred)
            ,(impose-effect! fx1)
            ,(impose-effect! fx2))]))
  ;; value (trg-value -> effect) -> effect
  ;; EFFECT: may register new frame variables to new-frames
  (define (value->fx^! value [k identity])
    (match value
      ;; non-tail call here
      [`(call ,triv ,opand* ...)
       (define loc* (generate-param-list/nfvar opand*))
       ;  create localized-tail
       (register-newframe! loc*)
       (define rp (fresh-label 'return-point))
       (make-begin-effect
        `((return-point ,rp
                        ,(make-begin (generate-sets loc* opand*)
                                     (make-begin-effect
                                      `((set! ,ra ,rp) (jump ,triv ,rbp ,ra ,@loc*)))))
          ,(k rv)))]
      ; other value are a valid tails in source language
      [_ (k value)]))

  ;; EFFECT: may register new frame variables to new-frames
  (define (impose-tail! tail [return-point tmp-ra])
    (match tail
      [`(call ,triv ,opand* ...)
       ;; tail call, no stack frame incurred
       (define loc* (generate-param-list opand*))
       (make-begin (generate-sets loc* opand*)
                   (make-begin `((set! ,ra ,return-point)) `(jump ,triv ,rbp ,ra ,@loc*)))]
      [`(begin
          ,fx* ...
          ,tail)
       (make-begin (map impose-effect! fx*) (impose-tail! tail))]
      [`(if ,pred ,tail1 ,tail2)
       `(if ,(impose-pred! pred)
            ,(impose-tail! tail1)
            ,(impose-tail! tail2))]
      [value
       (make-begin `((set! ,rv ,(impose-non-calling-value value))) `(jump ,return-point ,rbp ,rv))]))

  ;; EFFECT: may register new frame variables to new-frames
  ;;         also sets tmp-ra
  (define (impose-entry! tail)
    (set! tmp-ra (fresh 'tmp-ra))
    (make-begin `((set! ,tmp-ra ,ra)) (impose-tail! tail)))

  (define (impose-define label aloc* entry)
    (define entry+ (impose-entry! entry))
    (define nfs new-frames)
    (reset-newframes!)
    `(define ,label
       ,(info-set '() 'new-frames nfs)
       ,(make-begin (generate-sets aloc* (generate-param-list aloc*)) entry+)))

  (define (impose-p p)
    (match p
      [`(module (define ,(? label? label*)
                  (lambda (,(? aloc? aloc**) ...) ,entry*))
                ...
          ,entry)
       (define entry+ (impose-entry! entry))
       (define nfs new-frames)
       (reset-newframes!)
       `(module ,(info-set '() 'new-frames nfs) ,@(map impose-define label* aloc** entry*)
          ,entry+)]))

  (impose-p picl5))

(module+ test
  (require rackunit
           cpsc411/langs/v8)
  (define (peek x)
    ; (pretty-display x)
    x)
  (define-syntax-rule (check-by-interp-v6 p)
    (check-equal? (interp-proc-imp-cmf-lang-v8 (peek p))
                  (interp-imp-cmf-lang-v8 (peek (impose-calling-conventions p))))))
