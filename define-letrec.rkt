#lang racket
(provide define->letrec)

(define (define->letrec p)
  (define (make-entry fun/aloc param/aloc* val)
    `[,fun/aloc (lambda ,param/aloc* ,val)])
  ;   p	 	::=	 	(module (define aloc (lambda (aloc ...) value)) ... value)
  (match p
    [`(module
          (define ,fun/aloc* (lambda ,aloc** ,val*)) ...
        ,value)
     `(module
          (letrec ,(map make-entry fun/aloc* aloc** val*)
            ,value))]))