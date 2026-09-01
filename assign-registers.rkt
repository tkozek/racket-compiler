#lang racket

(require cpsc411/compiler-lib
         cpsc411/graph-lib
         cpsc411/info-lib)
(provide assign-registers)

;; (list X (listof Y)) -> Number
;; returns the number of Y in the given pair
(define (num-values pair)
  (length (cadr pair)))

;; (list X (listof Y)) Y -> (list X (listof Y))
;; remove one occurence the given Y from the list of Y
;;     if given Y does not exists in the list of Y, do nothing
(define (remove-from-loy pair val)
  (list (car pair) (remove val (cadr pair))))

;; (Asm-pred-lang-v8/framed p) -> (Asm-pred-lang-v8/spilled p)
;; Performs graph-colouring register allocation, compiling Asm-pred-lang v8/framed
;; to Asm-pred-lang v8/spilled by decorating programs with their register assignments.
(define (assign-registers p)
  (define spilled '())

  (define (assign-register alocs conflicts)
    (if (empty? alocs)
        '()
        (let* ([cur-aloc (car alocs)]
               [assigned-rest (assign-register (cdr alocs) (remove-vertex conflicts cur-aloc))]
               [incompatible-registers (get-incompatible-registers cur-aloc assigned-rest conflicts)]
               [available (filter (lambda (rloc) (not (set-member? incompatible-registers rloc)))
                                  (current-assignable-registers))])
          (if (empty? available)
              ;; spill if nothing is available
              (begin
                (set! spilled (cons cur-aloc spilled))
                assigned-rest)
              (cons (list cur-aloc (car available)) assigned-rest)))))

  (define (get-incompatible-registers cur-var assignments conflicts)
    (let* ([directly-conflicting (get-neighbors conflicts cur-var)]
           [incompatible-registers (mutable-set (filter register? directly-conflicting))])
      (for ([assignment assignments]
            ;; when the assigned aloc is conflicting with the unassigned aloc, we add
            ;; the assigned aloc's register to the list of incompatible registers
            #:when (memq (first assignment) directly-conflicting))
        (set-add! incompatible-registers (second assignment)))
      incompatible-registers))

  ;; ((listof aloc) (listof (loc (listof loc)))) -> (listof aloc)
  ;; Sorts alocs in non-decreasing order, where comparisons are based on conflict graph size
  (define (sort-by-degree alocs conflicts)
    (sort alocs
          (lambda (u v)
            (< (length (get-neighbors conflicts u)) (length (get-neighbors conflicts v))))))

  (define (update-info info)
    ;; Each info needs its own spilled list
    (set! spilled '())
    (let* ([locals (info-ref info 'locals)]
           [conflicts (info-ref info 'conflicts)]
           [existing-assignments (info-ref info 'assignment)]
           [already-assigned-alocs (map car existing-assignments)]
           [unassigned-alocs (filter (lambda (aloc) (not (memq aloc already-assigned-alocs))) locals)]
           [sorted (sort-by-degree unassigned-alocs conflicts)]
           [new-assignments (assign-register sorted conflicts)]
           [all-assignments (append existing-assignments new-assignments)])
      (info-set (info-set info 'locals spilled) 'assignment all-assignments)))

  (define (assign-definition def)
    (match def
      [`(define ,label
          ,info
          ,tail)
       `(define ,label
          ,(update-info info)
          ,tail)]))
  (match p
    [`(module ,info ,defs
        ...
        ,tail)
     ; Replaces the locals set with just the alocs that spilled
     `(module ,(update-info info) ,@(map assign-definition defs)
        ,tail)]))
