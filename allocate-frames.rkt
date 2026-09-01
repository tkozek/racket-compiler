#lang racket

(require cpsc411/compiler-lib
         cpsc411/langs/v7
         cpsc411/info-lib)

(provide allocate-frames)

;; (Asm-pred-lang-v8/pre-framed p)-> (Asm-pred-lang-v8/framed p)
;; Compiles Asm-pred-lang-v8/pre-framed to Asm-pred-lang-v8/framed by allocating frames for each
;;  non-tail call, and assigning all new-frame variables to frame variables in the new frame.
(define (allocate-frames p)

  (define-syntax-rule (mymap proc lst n)
    (map (lambda (x) (proc x n)) lst))

  (define (get-size-of-frame info)
    (match-let* ([call-undead-set (info-ref info 'call-undead)]
                 [`((,_ ,call-undead-assigned-fvars) ...) (info-ref info 'assignment)]
                 [max-fvar (foldr (lambda (curr-fvar curr-max) (max (fvar->index curr-fvar) curr-max))
                                  0
                                  call-undead-assigned-fvars)])
      (max (length call-undead-set) (+ 1 max-fvar))))

  (define (get-allocation-bytes n)
    (* n (current-word-size-bytes)))

  (define (get-new-assignments new-frames assignments n)
    (append (append-map (lambda (curr) (iterate-new-frame-variables curr n)) new-frames) assignments))

  (define (iterate-new-frame-variables new-frames-list n)
    (for/list ([curr-fvar new-frames-list]
               [i (in-naturals n)])
      `(,curr-fvar ,(make-fvar i))))

  (define (remove-redundant-info info)
    (info-remove (info-remove info 'call-undead) 'new-frames))

  (define (update-info info n)
    (match-let* ([new-frame-vars (info-ref info 'new-frames)]
                 [assignments (info-ref info 'assignment)]
                 [updated-assignments (get-new-assignments new-frame-vars assignments n)]
                 [`((,alocs ,_) ...) updated-assignments]
                 [locals-updated (set-subtract (info-ref info 'locals) alocs)]
                 [pruned-info (remove-redundant-info info)])
      (info-set (info-set pruned-info 'locals locals-updated) 'assignment updated-assignments)))

  (define (allocate-frames-def def)
    (match def
      [`(define ,label
          ,info
          ,tail)
       (let ([n (get-size-of-frame info)])
         `(define ,label
            ,(update-info info n)
            ,(allocate-frames-tail tail n)))]))

  (define (allocate-frames-pred pred n)
    (match pred
      [`(begin
          ,effects ...
          ,pred)
       `(begin
          ,@(mymap allocate-frames-effect effects n)
          ,(allocate-frames-pred pred n))]
      [`(if ,preds ...) `(if ,@(mymap allocate-frames-pred preds n))]
      [`(not ,pred) `(not ,(allocate-frames-pred pred n))]
      [_ pred]))

  (define (allocate-frames-tail tail n)
    (match tail
      [`(begin
          ,effects ...
          ,tail)
       `(begin
          ,@(mymap allocate-frames-effect effects n)
          ,(allocate-frames-tail tail n))]
      [`(if ,pred ,tails ...)
       `(if ,(allocate-frames-pred pred n)
            ,@(mymap allocate-frames-tail tails n))]
      [_ tail]))

  (define (allocate-frames-effect effect n)
    (match effect
      [`(begin
          ,effects ...)
       `(begin
          ,@(mymap allocate-frames-effect effects n))]
      [`(if ,pred ,effects ...)
       `(if ,(allocate-frames-pred pred n)
            ,@(mymap allocate-frames-effect effects n))]
      [`(return-point ,label ,tail)
       (let ([nb (get-allocation-bytes n)]
             [fbp (current-frame-base-pointer-register)])
         `(begin
            (set! ,fbp (- ,fbp ,nb))
            (return-point ,label ,(allocate-frames-tail tail n))
            (set! ,fbp (+ ,fbp ,nb))))]
      [_ effect]))

  (match p
    [`(module ,info ,defs
        ...
        ,tail)
     (let ([n (get-size-of-frame info)])
       `(module ,(update-info info n) ,@(map allocate-frames-def defs)
          ,(allocate-frames-tail tail n)))]))

(module+ test
  (require rackunit
           cpsc411/langs/v6)
  (define-syntax-rule (check-by-interp p)
    (check-equal? (interp-asm-pred-lang-v6/pre-framed p)
                  (interp-asm-pred-lang-v6/framed (allocate-frames p)))))
