#lang racket

(require cpsc411/compiler-lib)
(provide replace-locations)

; asm-pred-lang-v5/assignments -> nested-asm-lang-v5
;; Replaces all abstract locations with physical locations, and removes register-allocation metadata
;; Precondition: all abstract locations have a corresponding physical location in the info metadata
(define (replace-locations al2a)

  ;; (asm-pred-lang-v5/assignments loc) -> (asm-pred-lang-v5/assignments rloc)
  ;; Iff loc is abstract, replaces it with its corresponding physical location
  (define (replace-loc loc assignments)
    (if (aloc? loc)
        (info-ref assignments loc)
        loc))

  (define (replace-triv triv assignments)
    (match triv
      [(? aloc?) (info-ref assignments triv)]
      [_ triv]))

  (define (replace-pred pred assignments)
    (match pred
      [`(,relop ,loc ,triv)
       #:when (memq relop '(< <= = >= > !=))
       `(,relop ,(replace-loc loc assignments) ,(replace-triv triv assignments))]
      [`(not ,pred) `(not ,(replace-pred pred assignments))]
      [`(begin
          ,fxs ...
          ,pred)
       `(begin
          ,@(map (λ (fx) (replace-effect fx assignments)) fxs)
          ,(replace-pred pred assignments))]
      [`(if ,pred1 ,pred2 ,pred3)
       `(if ,(replace-pred pred1 assignments)
            ,(replace-pred pred2 assignments)
            ,(replace-pred pred3 assignments))]
      [_ pred]))

  (define (replace-effect fx assignments)
    (match fx
      [`(set! ,loc (,binop ,loc ,triv))
       (define rloc (replace-loc loc assignments))
       `(set! ,rloc (,binop ,rloc ,(replace-triv triv assignments)))]
      [`(set! ,loc ,triv) `(set! ,(replace-loc loc assignments) ,(replace-triv triv assignments))]
      [`(begin
          ,fxs ...
          ,fx)
       `(begin
          ,@(map (λ (fx) (replace-effect fx assignments)) fxs)
          ,(replace-effect fx assignments))]
      [`(if ,pred ,effect1 ,effect2)
       `(if ,(replace-pred pred assignments)
            ,(replace-effect effect1 assignments)
            ,(replace-effect effect2 assignments))]))

  (define (replace-tail tail assignments)
    (match tail
      [`(halt ,triv) `(halt ,(replace-triv triv assignments))]
      [`(jump ,trg ,locs ...) `(jump ,trg)]
      [`(begin
          ,fxs ...
          ,tail)
       `(begin
          ,@(map (λ (fx) (replace-effect fx assignments)) fxs)
          ,(replace-tail tail assignments))]
      [`(if ,pred ,tail1 ,tail2)
       `(if ,(replace-pred pred assignments)
            ,(replace-tail tail1 assignments)
            ,(replace-tail tail2 assignments))]))

  ;; (nested-asm-lang-v5/assignments definition) -> (nested-asm-lang-v5/assignments definition)
  ;; replaces abstract locations with physical locations within an top level procedure definition
  (define (replace-def def)
    (match def
      [`(define ,label
          ,info
          ,tail)
       (define assignments (info-ref info 'assignment))
       `(define ,label ,(replace-tail tail assignments))]))

  (define (replace-p p)
    (match p
      [`(module ,info ,defs
          ...
          ,tail)
       (define assignments (info-ref info 'assignment))
       `(module ,@(map replace-def defs) ,(replace-tail tail assignments)
          )]))

  (replace-p al2a))
