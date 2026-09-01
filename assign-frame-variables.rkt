#lang racket

(require cpsc411/compiler-lib
         cpsc411/graph-lib)

(provide assign-frame-variables)

;; (asm-pred-lang-v8/spilled p) → (asm-pred-lang-v8/assignments p)
;; Compiles Asm-pred-lang-v8/spilled to Asm-pred-lang-v8/assignments
;; by allocating all abstract locations in the locals set to free frame variables.
(define (assign-frame-variables p)
  (define (update-info info)
    (let ([assignment (assign-variables/info info)])
      (info-set (info-remove (info-remove info 'locals) 'conflicts)
                'assignment
                (append assignment (info-ref info 'assignment)))))

  (define (assign-fvar locals conflicts)
    (if (empty? locals)
        '()
        (let* ([current-variable (car locals)]
               [assignments (assign-fvar (cdr locals) (remove-vertex conflicts current-variable))]
               [incompatible-fvars-set (get-incompatible current-variable assignments conflicts)])
          (cons `(,current-variable ,(let loop ([i 0])
                                       (let ([current (make-fvar i)])
                                         (if (set-member? incompatible-fvars-set current)
                                             (loop (+ 1 i))
                                             current))))
                assignments))))

  (define (get-incompatible current-variable assignments conflicts)
    (let* ([directly-conflicting (get-neighbors conflicts current-variable)]
           [incompatible-fvars-set (mutable-set (filter fvar? directly-conflicting))])
      (for ([assignment assignments]
            #:when (memq (first assignment) directly-conflicting))
        (set-add! incompatible-fvars-set (second assignment)))
      incompatible-fvars-set))

  (define (assign-variables/def def)
    (match def
      [`(define ,label
          ,info
          ,tail)
       `(define ,label
          ,(update-info info)
          ,tail)]))

  (define (assign-variables/info info)
    (let ([conflicts (info-ref info 'conflicts)]
          [locals (info-ref info 'locals)])
      (assign-fvar locals conflicts)))

  (match p
    [`(module ,info ,defs
        ...
        ,tail)
     `(module ,(update-info info) ,@(map assign-variables/def defs)
        ,tail)]))

(module+ test
  (require rackunit
           cpsc411/langs/v6)
  (define-syntax-rule (check-by-interp p)
    (check-equal? (interp-asm-pred-lang-v6/spilled p)
                  (interp-asm-pred-lang-v6/assignments (assign-frame-variables p)))))
