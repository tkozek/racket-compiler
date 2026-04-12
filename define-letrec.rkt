#lang racket
(provide define->letrec)

;; (Exprs-unsafe-lang v9 p) -> (Just-exprs-lang v9 p)
;; Transform all top-level bindings into local bindings.
(define (define->letrec p)
  (define (make-entry fun/aloc param/aloc* val)
    `[,fun/aloc (lambda ,param/aloc* ,val)])
  ;   p	 	::=	 	(module (define aloc (lambda (aloc ...) value)) ... value)
  (match p
    [`(module (define ,fun/aloc* (lambda ,aloc** ,val*)) ...
        ,value)
     `(module (letrec ,(map make-entry fun/aloc* aloc** val*)
                ,value))]))
