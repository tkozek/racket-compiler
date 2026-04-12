#lang racket
(require cpsc411/compiler-lib
         cpsc411/graph-lib
         "common.rkt")

(provide assign-call-undead-variables)

;; (Asm-pred-lang-v8/conflicts p) -> (Asm-pred-lang-v8/pre-framed p)
;; Compiles Asm-pred-lang-v8/conflicts to Asm-pred-lang-v8/pre-framed by pre-assigning
;; all variables in the call-undead sets to frame variables.
(define (assign-call-undead-variables p)

  (define (update-info info)
    (match-let* ([assignment (assign-call-undead-variables/info info)]
                 [`((,alocs ,fvars) ...) assignment]
                 [locals-updated (set-subtract (info-ref info 'locals) alocs)])
      (info-set (info-set info 'locals locals-updated) 'assignment assignment)))

  (define (assign-call-undead-variables/def def)
    (match def
      [`(define ,label
          ,info
          ,tail)
       `(define ,label
          ,(update-info info)
          ,tail)]))

  (define (assign-call-undead-variables/info info)
    (let ([default-assignment '()]
          [conflicts (info-ref info 'conflicts)]
          [call-undead (info-ref info 'call-undead)])
      (if (empty? info)
          default-assignment
          (assign-call-undead-fvar call-undead conflicts))))

  (define (assign-call-undead-fvar call-undead conflicts)
    (if (empty? call-undead)
        '()
        (let* ([current-variable (car call-undead)]
               [assignments (assign-call-undead-fvar (cdr call-undead)
                                                     (remove-vertex conflicts current-variable))]
               [incompatiable-fvars-set (get-incompatible current-variable assignments conflicts)])
          (cons `(,current-variable ,(let/cc return
                                       (let loop ([i 0])
                                         (let ([current (string->symbol (format "fv~a" i))])
                                           (if (memq current (set->list incompatiable-fvars-set))
                                               (loop (+ 1 i))
                                               (return current))))))
                assignments))))

  (define (get-incompatible current-variable assignments conflicts)
    (let* ([directly-conflicting (get-neighbors conflicts current-variable)]
           [incompatiable-fvars-set (mutable-set (filter fvar? directly-conflicting))])
      (for ([assignment assignments]
            #:when (memq (first assignment) directly-conflicting))
        (set-add! incompatiable-fvars-set (second assignment)))
      incompatiable-fvars-set))

  (match p
    [`(module ,info ,defs
        ...
        ,tail)
     `(module ,(update-info info) ,@(map assign-call-undead-variables/def defs)
        ,tail)]))

;; works

#;
(module+ test
  (require rackunit
           cpsc411/langs/v6)
  (define-syntax-rule (check-by-interp p)
    (check-equal? (interp-asm-pred-lang-v6/conflicts p)
                  (interp-asm-pred-lang-v6/pre-framed (assign-call-undead-variables p)))))
