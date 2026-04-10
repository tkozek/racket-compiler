#lang racket
(require cpsc411/compiler-lib)
(provide implement-fvars)

;paren-x64-fvars-v4 -> paren-x64-v4
(define (implement-fvars pxf2)
  (define triv? (or/c int64? register?))
  (define loc? (or/c fvar? register?))
  ; p	 	::=	 	(begin s ...)
  (define (implement-p p)
    (match p
      [`(begin
          ,s* ...)
       (append '(begin) (map implement-s s*))]))
  ; s	 	::=	 	(set! fvar int32)
  ; |	 	(set! fvar reg)
  ; |	 	(set! reg loc)
  ; |	 	(set! reg triv)
  ; |	 	(set! reg_1 (binop reg_1 int32))
  ; |	 	(set! reg_1 (binop reg_1 loc))
  ; |	  (with-label label s)
  ; |	 	(jump trg)
  ;	|	 	(compare reg opand)
  ; |	 	(jump-if relop label)
  (define (implement-s s)
    (match s
      [`(set! ,fvar ,i32)
       #:when (and (fvar? fvar) (int32? i32))
       `(set! ,(implement-fvar fvar) ,i32)]
      [`(set! ,fvar ,reg)
       #:when (and (fvar? fvar) (register? reg))
       `(set! ,(implement-fvar fvar) ,reg)]
      [`(set! ,reg (,binop ,reg ,i32))
       #:when (and (register? reg) (int32? i32))
       `(set! ,reg (,binop ,reg ,i32))]
      [`(set! ,reg (,binop ,reg ,loc))
       #:when (and (register? reg) (loc? loc))
       `(set! ,reg (,binop ,reg ,(implement-loc loc)))]
      [`(set! ,reg ,triv)
       #:when (and (register? reg) (triv? triv))
       `(set! ,reg ,triv)]
      [`(set! ,reg ,loc)
       #:when (and (register? reg) (loc? loc))
       `(set! ,reg ,(implement-loc loc))]
      [`(with-label ,label ,s) `(with-label ,label ,(implement-s s))]
      [`(jump ,trg) `(jump ,trg)]
      [`(compare ,reg ,opand) `(compare ,reg ,opand)]
      [`(jump-if ,relop ,label) `(jump-if ,relop ,label)]
      [_ s]))

  (define (implement-loc loc)
    (match loc
      [(? register?) loc]
      [(? fvar?) (implement-fvar loc)]))
  ; addr	 	::=	 	(fbp - dispoffset)
  ; fbp	 	::=	 	frame-base-pointer-register?
  (define (implement-fvar fvar)
    `(,(current-frame-base-pointer-register) - ,(* 8 (fvar->index fvar))))
  (implement-p pxf2))

