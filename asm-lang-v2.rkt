#lang racket

(require cpsc411/compiler-lib
        compiler.rkt)


(provide uncover-locals
         assign-fvars
         replace-locations
         assign-homes)

(define (uncover-triv triv)
    ())



;; (asm-lang-v2) -> (asm-lang-v2/locals)
;; Analyzes which alocs are used in p and decorates program with set of variables in info field
(define (uncover-locals p)
    (define locals '())

    (define (uncover-aloc aloc)
        (when (and (aloc? aloc) 
            (not (memq aloc locals)))
            (set! locals (cons aloc locals))))
    
    ; (define (uncover-triv triv)
    ;         (uncover-aloc triv))

    (define (uncover-effect effect)
        (match effect
            [`(set! ,aloc1 (,binop ,aloc1 ,triv))
                (uncover-aloc aloc1)
                (uncover-aloc triv)]
            [`(set! ,aloc ,triv)
                (uncover-aloc aloc)
                (uncover-aloc triv)] 
            [`(begin ,first ,rest ...)
                (uncover-effect first)
                (for-each uncover-effect rest)]
            [_ (error "Expected an effect, got: ~a" effect)]))

    (define (uncover-tails tail)
        (match tail
            [`(halt triv)
                (uncover-aloc triv)]
            [`(begin ,effect ... ,tail)
                (for-each uncover-effect effect)
                (uncover-tails tail)]
            [_ (error "Expected a tail, got: ~a" tail)]))


    (define (uncover-p p)
        (match p
            [`(module ,info ,tail)
                (uncover-tails tail)
                (info-set info 'locals locals)
                `(module info ,tail)]
            [_ (error "Expected asm-lang-v2 p, got: ~a" p)]))
    (uncover-p p)
)

    

  
;; (asm-lang-v2/assignments) -> (nested-asm-lang-v2)
;; Replaces each aloc with its assigned physical location from the assignment info field
(define (replace-locations p)
    (define assignments (make-hash))

;; for every assignment pair in info, add an entry to assignments that maps
;; the aloc to the fvar
    (define (init-assignments info) 
        (for-each (lambda (pair)
                    (let ([aloc (first pair)]
                          [fvar (second pair)])
                          (hash-set! assignments aloc fvar)))
                (info-ref info 'assignment)))

    ; (define (replace-aloc aloc)
    ;     (when (and (aloc? aloc)
    ;                 (hash-ref assignments aloc #f))
    ;             (hash-ref assignments aloc)))
    (define (replace-aloc aloc)
        (match aloc
            [(? int64?)
                aloc]
            [(? aloc?)
                (when (and (aloc? aloc)
                            (hash-ref assignments aloc #f))
                (hash-ref assignments aloc))]
            [_ (error "Expected aloc, got: " aloc)]))

    (define (replace-effect effect)
        (match effect
            [`(set! ,aloc1 (,binop ,aloc1 ,triv))
                `(set! ,(replace-aloc aloc1) (,binop ,(replace-aloc aloc1) ,(replace-aloc triv)))]
            [`(set! ,aloc ,triv)
                `(set! ,(replace-aloc aloc) ,(replace-aloc triv))]
            [`(begin ,first ,rest ...)
                `(begin 
                    ,(replace-effect first)
                    ,@(map replace-effect rest))]
            [_ (error "Expected an effect, got: ~a" effect)]))

    (define (replace-tail tail)
        (match tail
            [`(halt ,triv)
                `(halt ,(replace-aloc triv))]
            [`(begin ,effects ... ,tail)
                `(begin ,@(map replace-effect effects) ,(replace-tail tail))]
            [_ (error "Expected a tail, got: ~a" tail)]))

    (define (replace-p p)
        (match p
            [`(module ,info ,tail)
            ;; do I need begin here? I don't think I do
            (init-assignments info)
            (replace-tail tail)]))

    (replace-p p))


;; want to get the pairs from assignments in info.
;; then when we see an aloc we replace it and return it replaced
;; 


;; (asm-lang-v2/locals) -> (asm-lang-v2/assignments)
;; Assigns each aloc from the locals info field to a fresh frame variable
(define (assign-fvars p)
    (define fvar-counter 0)
    (define assignments (make-hash))
    (define (assign-aloc aloc)
        (when (and (aloc? aloc)
                (not (hash-has-key? assignments aloc)))
                (hash-set! assignments aloc (make-fvar fvar-counter))
                (set! fvar-counter (add1 fvar-counter))))

    (define (assign-effect effect)
        (match effect
            [`(set! ,aloc1 (,binop ,aloc1 ,triv))]
            [`(set! ,aloc ,triv)
                (assign-aloc aloc)
                (assign-aloc triv)]
            [`(begin ,first ,rest)
                (assign-effect first)
                (for-each assign-effect rest)]
            [_ (error "Expected an effect, got: ~a" effect)]))

    (define (assign-tail tail)
        (match tail
            [`(halt ,triv)
                #when (triv? triv)
                (assign-aloc triv)]
            [`(begin ,effects ... ,tail)
                (for-each assign-effect effects)
                (assign-tail tail)]
            [_ (error "Expected a tail, got: ~a" tail)]))
    
    (define (assign-p p)
        (match p
            [`(module ,info ,tail)
                (assign-tail tail) ; (list (k v)) for k, v in assignments
                (info-set info 'assignment (hash->list assignments)) 
                `(module info tail)]
            [_ (error "Expected asm-lang-v2, got: ~a" p)]))
    (assign-p p))

;; (asm-lang-v2) -> (nested-asm-lang-v2)
;; Replaces each aloc its with assigned physical location from assignment info field
(define (assign-homes p)
    (replace-locations (assign-fvars (uncover-locals p))))