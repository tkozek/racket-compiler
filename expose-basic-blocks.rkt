#lang racket

(require cpsc411/compiler-lib)

(provide expose-basic-blocks)

;; (Nested-asm-lang-v9 p) -> (Block-pred-lang-v8 p)
;; Compile the Nested-asm-lang v8 to Block-pred-lang v8,
;; eliminating all nested expressions by generating fresh basic blocks and jumps.
(define (expose-basic-blocks p)
  (define blocks '())
  (define (create-block! label tail)
    (set! blocks (cons `(define ,label ,tail) blocks))
    label)
  ;; nested-pred label label -> label
  ;; effect: creates a block with pred
  (define (expose-pred! pred truelab falselab)
    (define label (fresh-label 'pred))
    (match pred
      [`(not ,pred) (expose-pred! pred falselab truelab)]
      [`(begin
          ,fx* ...
          ,pred)
       (foldr expose-effect! (expose-pred! pred truelab falselab) fx*)]
      [`(if ,pred ,pred1 ,pred2)
       (expose-pred! pred
                     (expose-pred! pred1 truelab falselab)
                     (expose-pred! pred2 truelab falselab))]
      [`(,relop ,loc ,triv)
       (create-block! label
                      `(if ,pred
                           (jump ,truelab)
                           (jump ,falselab)))]
      [`(true)
       (create-block! label
                      `(if ,pred
                           (jump ,truelab)
                           (jump ,falselab)))]
      [`(false)
       (create-block! label
                      `(if ,pred
                           (jump ,truelab)
                           (jump ,falselab)))]))
  ;; nested-effect label -> label
  ;; effect: creates a block with the effect
  (define (expose-effect! fx next)
    (define label (fresh-label 'fx))
    (match fx
      [`(set! ,loc ,triv)
       (create-block! label
                      `(begin
                         ,fx
                         (jump ,next)))]
      [`(set! ,loc (,binop ,loc ,triv))
       (create-block! label
                      `(begin
                         ,fx
                         (jump ,next)))]
      [`(mset! ,_ ,_ ,_)
       (create-block! label
                      `(begin
                         ,fx
                         (jump ,next)))]
      [`(begin
          ,fx* ...
          ,fx)
       (foldr expose-effect! (expose-effect! fx next) fx*)]
      [`(if ,pred ,fx1 ,fx2) (expose-pred! pred (expose-effect! fx1 next) (expose-effect! fx2 next))]
      [`(return-point ,ret-label ,tail)
       (define ret-lab (create-block! ret-label `(jump ,next)))
       (define tail-lab (expose-tail! tail))
       tail-lab]))
  ;; nested-tail (block-tail -> X) -> X
  (define (nested-tail->block-tail& tail [k identity])
    (match tail
      ; [`(halt ,_) (k tail)] ;; removed in v6
      [`(jump ,_) (k tail)]
      [`(begin
          ,fx* ...
          ,tail)
       (k `(jump ,(foldr expose-effect! (expose-tail! tail) fx*)))]
      [`(if ,pred ,tail1 ,tail2)
       (k `(jump ,(expose-pred! pred (expose-tail! tail1) (expose-tail! tail2))))]))

  ;; nested-tail -> label
  ;; effect: creates a block
  (define (expose-tail! tail)
    ;;block-tail -> label
    (define (expose-block-label! tail)
      (define label (fresh-label 'tail))
      (match tail
        [`(jump ,trg) trg]
        [_ (create-block! label tail)]))
    (nested-tail->block-tail& tail expose-block-label!))
  (match p
    [`(module (define ,label* ,tail*) ...
        ,tail)
     (begin
       (for-each create-block! label* (map (λ (tail) `(jump ,(expose-tail! tail))) tail*))
       (nested-tail->block-tail& tail (λ (bt) (create-block! (fresh-label 'start) bt)))
       `(module ,@blocks))]))

(module+ test
  (require rackunit
           cpsc411/langs/v6)
  (define-syntax-rule (check-by-interp p)
    (check-equal? (interp-nested-asm-lang-v6 p) (interp-block-pred-lang-v6 (expose-basic-blocks p))))

  ; see generated_tests folder to see the generated tests.
  )
