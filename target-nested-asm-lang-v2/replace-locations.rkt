#lang racket

(require cpsc411/compiler-lib
         "../common.rkt")
(provide replace-locations)

;; (Asm-pred-lang-v8/assignments p) -> (Nested-asm-lang-fvars-v8 p)
;; Replaces all abstract locations with physical locations, and removes register-allocation metadata
;; Precondition: all abstract locations have a corresponding physical location in the info metadata
(define (replace-locations al2a)

  ;; (asm-pred-lang-v6/assignments loc) -> (asm-pred-lang-v6/assignments rloc)
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
      [`(mset! ,loc ,index ,triv)
       (let* ([loc^ (replace-loc loc assignments)]
              [index^ (replace-triv index assignments)]
              [triv^ (replace-triv triv assignments)])
         `(mset! ,loc^ ,index^ ,triv^))]
      [`(set! ,loc1 (mref ,loc2 ,index))
       (let* ([loc1^ (replace-loc loc1 assignments)]
              [index^ (replace-triv index assignments)]
              [loc2^ (replace-loc loc2 assignments)])
         `(set! ,loc1^ (mref ,loc2^ ,index^)))]
      [`(set! ,loc (,binop ,loc ,triv))
       (define rloc (replace-loc loc assignments))
       `(set! ,rloc (,binop ,rloc ,(replace-triv triv assignments)))]
      [`(set! ,loc ,triv) `(set! ,(replace-loc loc assignments) ,(replace-triv triv assignments))]
      [`(begin
          ,fxs ...)
       `(begin
          ,@(map (λ (fx) (replace-effect fx assignments)) fxs))]
      [`(if ,pred ,effect1 ,effect2)
       `(if ,(replace-pred pred assignments)
            ,(replace-effect effect1 assignments)
            ,(replace-effect effect2 assignments))]
      [`(return-point ,label ,tail) `(return-point ,label ,(replace-tail tail assignments))]))

  (define (replace-tail tail assignments)
    (match tail
      [`(jump ,trg ,locs ...) `(jump ,(replace-loc trg assignments))]
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

  ;; (asm-pred-lang-v6/assignments definition) -> (nested-asm-lang-fvars-v6 definition)
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

(module+ test
  (require rackunit)
  (check-match (replace-locations `(module ((assignment ((x.1 rax) (x.2 rbx) (x.3 rcx))))
                                           (begin
                                             (set! x.1 10)
                                             (set! x.2 20)
                                             (mset! x.1 4 x.2)
                                             (set! x.3 (mref x.1 4))
                                             (jump L.done.1 x.3))
                                     ))
               `(module (begin
                          (set! rax 10)
                          (set! rbx 20)
                          (mset! rax 4 rbx)
                          (set! rcx (mref rax 4))
                          (jump L.done.1)))))
