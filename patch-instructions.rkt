#lang racket
(require cpsc411/compiler-lib
         "common.rkt")

(provide patch-instructions)

;; (Para-asm-lang-v8 p)-> (Paren-x64-mops-v8 p)
;; Compiles para-asm-lang-v8 to paren-x64-mops-v8 by patching each instruction that has no x64
;; analogue into a sequence of instructions using auxiliary
;; registers from current-patch-instruction-registers
(define (patch-instructions p)
  (define aux-reg current-patch-instructions-registers)
  (define first-reg (first (aux-reg)))
  (define second-reg (second (aux-reg)))

  ;; (para-asm-lang-v8 s)-> (paren-x64-mops-v8 s)
  ;; patches set! instructions where the id is a register
  (define (patch-set-reg s)
    (match s
      [`(set! ,reg1 (,binop ,reg1 ,triv))
       #:when (and (integer? triv) (not (int32? triv)))
       `((set! ,first-reg ,triv) (set! ,reg1 (,binop ,reg1 ,first-reg)))]
      [_ `(,s)]))

  ;; (para-asm-lang-v8 s)-> (paren-x64-mops-v8 s)
  ;; patches set! instructions where the id is a register
  (define (patch-set-addr s)
    (match s
      [`(set! ,addr1 (,binop ,addr1 ,triv))
       `((set! ,first-reg ,triv) (set! ,first-reg (,binop ,first-reg ,addr1))
                                 (set! ,addr1 ,first-reg))]
      [`(set! ,addr1 ,triv)
       #:when (or (addr? triv) (and (integer? triv) (not (int32? triv))))
       `((set! ,first-reg ,triv) (set! ,addr1 ,first-reg))]
      [_ `(,s)]))

  ;; let src-X be X non-terminal in the source language
  ;; let trg-X be X non-terminal in the target language
  ;; by observation: src-triv === trg-triv
  ;; however: src-triv != (trg-trg or int32) 
  (define (patch-s s)
    (match s
      [`(mset! ,loc1 ,index ,triv) 
      ; could optimize this if index is not int64 or triv is not int64, but this reduces cases
        `((set! ,first-reg ,loc1)
          (set! ,second-reg ,index)
          (set! ,first-reg (+ ,first-reg ,second-reg))
          (set! ,second-reg ,triv)
          (mset! ,first-reg 0 ,second-reg))]
      [`(set! ,loc1 (mref ,loc2 ,index))
       `((set! ,second-reg ,loc2) (set! ,second-reg (mref ,second-reg ,index))
                                  (set! ,loc1 ,second-reg))]
      [`(set! ,loc ,rest)
       #:when (register? loc)
       (patch-set-reg s)]
      [`(set! ,loc ,rest) (patch-set-addr s)]
      [`(with-label ,label ,s)
       (define patched (patch-s s))
       `((with-label ,label ,(first patched)) ,@(rest patched))]
      [`(compare ,loc ,opand)
       `((set! ,first-reg ,loc) (set! ,second-reg ,opand) (compare ,first-reg ,second-reg))]
      [`(jump-if ,relop ,trg)
       #:when (or (addr? trg) (register? trg))
       `((set! ,first-reg ,trg) (jump-if ,relop ,first-reg))]
      [`(jump ,trg)
       #:when (addr? trg)
       `((set! ,first-reg ,trg) (jump ,first-reg))]
      [_ `(,s)]))

  (define (patch-p p)
    (match p
      [`(begin
          ,ss ...)
       `(begin
          ,@(apply append (map patch-s ss)))]))

  (patch-p p))
