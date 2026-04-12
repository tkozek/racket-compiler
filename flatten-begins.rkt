#lang racket

(require cpsc411/compiler-lib)

(provide flatten-begins)
;nested-asm-lang-v2 -> para-asm-lang-v2
(define (flatten-begins nal2)
  ;  p	 	::=	 	tail
  ;   tail	 	::=	 	(halt triv)
  ;  	 	|	 	(begin effect ... tail)
  (define (flatten-tail tail)
    (match tail
      [`(halt ,_) (list tail)]
      [`(begin
          ,fxs ...
          ,tail)
       (append (foldr append '() (map flatten/fx->fxs fxs)) (flatten-tail tail))]))

  ;   effect	 	::=	 	(set! loc triv)
  ;  	 	|	 	(set! loc_1 (binop loc_1 triv))
  ;  	 	|	 	(begin effect ... effect)
  (define (flatten/fx->fxs fx)
    (match fx
      [`(set! ,_ ,_) (list fx)]
      [`(begin
          ,fxs ...
          ,fx2)
       (append (foldr append '() (map flatten/fx->fxs fxs)) (flatten/fx->fxs fx2))]))
  (match nal2
    [`(module ,nal2) (append `(begin) (flatten-tail nal2))]))

#;
(module+ test
  (require rackunit)
  ; example outputs for uniquify

  (check-equal? (flatten-begins '(module (begin
                                           (set! x.1 1)
                                           (set! x.2 1)
                                           (set! x.3 1)
                                           (halt x.1))))
                '(begin
                   (set! x.1 1)
                   (set! x.2 1)
                   (set! x.3 1)
                   (halt x.1)))
  (check-equal? (flatten-begins '(module (begin
                                           (begin
                                             (set! x.1 1)
                                             (set! x.2 1))
                                           (halt x.1))))
                '(begin
                   (set! x.1 1)
                   (set! x.2 1)
                   (halt x.1)))
  (check-equal? (flatten-begins '(module (begin
                                           (begin
                                             (set! x.1 1)
                                             (set! x.2 1)
                                             (set! x.3 1))
                                           (halt x.1))))
                '(begin
                   (set! x.1 1)
                   (set! x.2 1)
                   (set! x.3 1)
                   (halt x.1)))

  (check-equal? (flatten-begins '(module (begin
                                           (begin
                                             (set! x.1 1)
                                             (begin
                                               (set! x.2 1)
                                               (set! x.3 1)))
                                           (halt x.1))))
                '(begin
                   (set! x.1 1)
                   (set! x.2 1)
                   (set! x.3 1)
                   (halt x.1))))
