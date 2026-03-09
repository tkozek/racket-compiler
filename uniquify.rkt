#lang racket

(require cpsc411/compiler-lib
         cpsc411/langs/v5)

(provide uniquify
         interp-values-lang)

(define (binop? op)
  (or (equal? op '+) (equal? op '*)))

(define (binop->fun op)
  (match op
    ['+ x64-add]
    ['* x64-mul]))
(define triv? (or/c name? int64?))

; values-lang-v5
;   p	 	::=	 	(module (define x (lambda (x ...) tail)) ... tail)

;   pred	 	::=	 	(relop triv triv)
;  	 	|	 	(true)
;  	 	|	 	(false)
;  	 	|	 	(not pred)
;  	 	|	 	(let ([x value] ...) pred)
;  	 	|	 	(if pred pred pred)

;   tail	 	::=	 	value
;  	 	|	 	(let ([x value] ...) tail)
;  	 	|	 	(if pred tail tail)
;  	 	|	 	(call x triv ...)

;   value	 	::=	 	triv
;  	 	|	 	(binop triv triv)
;  	 	|	 	(let ([x value] ...) value)
;  	 	|	 	(if pred value value)

;   triv	 	::=	 	int64
;  	 	|	 	x

;   x	 	::=	 	name?

;   binop	 	::=	 	*
;  	 	|	 	+

;   relop	 	::=	 	<
;  	 	|	 	<=
;  	 	|	 	=
;  	 	|	 	>=
;  	 	|	 	>
;  	 	|	 	!=

;   int64	 	::=	 	int64?

(define (interp-values-lang vl3)
  (define (interp-triv triv env)
    (match triv
      [(? name?) (dict-ref env triv (λ () (error "not defined: ~a" triv)))]
      [(? int64?) triv]))
  (define (interp-tail tail env)
    (match tail
      [`(let ([,x* ,value*] ...) ,tail)
       (define val+ (map (λ (val) (interp-tail val env)) value*))
       (define env+ (foldl (λ (x val env) (dict-set env x val)) env x* val+))
       (interp-tail tail env+)]
      [`(,(? binop? binop) ,(? triv? triv) ,(? triv? triv2))
       ((binop->fun binop) (interp-triv triv env) (interp-triv triv2 env))]
      [(? triv?) (interp-triv tail env)]))
  (let _ ([p vl3]
          [env '()])
    (match p
      [`(module ,tail) (interp-tail tail env)])))

;---------------------
; values-unique-lang-v5
;  p	 	::=	 	(module (define label (lambda (aloc ...) tail)) ... tail)
;   pred	 	::=	 	(relop opand opand)
;  	 	|	 	(true)
;  	 	|	 	(false)
;  	 	|	 	(not pred)
;  	 	|	 	(let ([aloc value] ...) pred)
;  	 	|	 	(if pred pred pred)
;   tail	 	::=	 	value
;  	 	|	 	(let ([aloc value] ...) tail)
;  	 	|	 	(if pred tail tail)
;  	 	|	 	(call triv opand ...)
;   value	 	::=	 	triv
;  	 	|	 	(binop opand opand)
;  	 	|	 	(let ([aloc value] ...) value)
;  	 	|	 	(if pred value value)
;   opand	 	::=	 	int64
;  	 	|	 	aloc
;   triv	 	::=	 	opand
;  	 	|	 	label
;   binop	 	::=	 	* | +
;   relop	 	::=	 	< | <= | = >= | > | !=
;   aloc	 	::=	 	aloc?
;   label	 	::=	 	label?
;   int64	 	::=	 	int64?

; values-lang-v5 -> values-unique-lang-v5
(define (uniquify vlv5)
  (define proc-env (make-hash))

  ; let env be a dict which maps (procedure-name : label)
  ;; name -> label
  (define (proc-name->label proc-name)
    (dict-ref! proc-env proc-name (fresh-label proc-name)))

  ; let env be a dict which maps name to aloc
  ; name env -> aloc
  (define (name->aloc x arg-env)
    (hash-ref arg-env x (λ () (error (format "undefined: ~a" x)))))

  ;; Takes triv in argument position and assigns aloc if triv is a name, otherwise returns
  ;; triv if triv is int64.
  ;; (values-lang-v5 triv?) -> (values-lang-v5 triv | int64)
  (define (triv->arg arg arg-env)
    (if (int64? arg)
        arg
        (name->aloc arg arg-env)))

  ; values-lang-v5-triv env -> values-unique-lang-v5-triv
  (define (uniquify-triv triv env)
    (match triv
      [(? int64?) triv]
      [(? name?) (hash-ref env triv (λ () (error (format "undefined: ~a" triv))))]))

  ; (listof values-lang-v5-name) (listof value-lang-v5-value) env ->
  ;     (list (listof (list values-unique-lang-v5-name values-unique-lang-v5-value)) env)
  (define (uniquify-pairs xs vals arg-env)
    (when (not (equal? (set-count (list->set xs)) (length xs)))
      (error (format "duplicate declaration in the same let: ~a" xs)))
    (define alocs (map fresh xs))
    (define bindings (map (λ (aloc val) (list aloc (uniquify-value val arg-env))) alocs vals))
    (define new-env
      (for/fold ([env arg-env])
                ([x xs]
                 [aloc alocs])
        (hash-set env x aloc)))
    (values bindings new-env))

  (define (uniquify-pred pred env)
    (match pred
      [`(,relop ,triv1 ,triv2)
       #:when (memq relop '(< <= = >= > !=))
       `(,relop ,(uniquify-triv triv1 env) ,(uniquify-triv triv2 env))]
      [`(not ,pred) `(not ,(uniquify-pred pred env))]
      [`(let ([,xs ,vals] ...) ,pred)
       ;    #:when ((listof name?) xs) ;; isn't it guaranteed to be (listof name) ?
       (let-values ([(bindings new-env) (uniquify-pairs xs vals env)])
         `(let ,bindings ,(uniquify-pred pred new-env)))]
      [`(if ,pred1 ,pred2 ,pred3)
       `(if ,(uniquify-pred pred1 env)
            ,(uniquify-pred pred2 env)
            ,(uniquify-pred pred3 env))]
      [_ pred]))

  ; values-lang-v5-value env -> values-unique-lang-v5-value
  (define (uniquify-value value env)
    (match value
      [`(let ([,xs ,vals] ...) ,value)
       (let-values ([(bindings new-env) (uniquify-pairs xs vals env)])
         `(let ,bindings ,(uniquify-value value new-env)))]
      [`(if ,pred1 ,pred2 ,pred3)
       `(if ,(uniquify-pred pred1 env)
            ,(uniquify-value pred2 env)
            ,(uniquify-value pred3 env))]
      ;; reordered to disambiguate with (if) instead

      [`(,binop ,triv1 ,triv2)
       #:when (and (binop? binop) (triv? triv1) (triv? triv2))
       `(,binop ,(uniquify-triv triv1 env) ,(uniquify-triv triv2 env))]
      [(? triv?) (uniquify-triv value env)])) ;;

  (define (uniquify-tail tail arg-env)
    (match tail
      [`(let ([,xs ,vals] ...) ,tail)
       ;#:when ((listof name?) xs) ;; is this necessary?
       (let-values ([(bindings new-env) (uniquify-pairs xs vals arg-env)])
         `(let ,bindings ,(uniquify-tail tail new-env)))]
      [`(if ,pred ,t1 ,t2)
       `(if ,(uniquify-pred pred arg-env)
            ,(uniquify-tail t1 arg-env)
            ,(uniquify-tail t2 arg-env))]
      ;; call to function x, with trivs as args
      [`(call ,x ,trivs ...)
       `(call ,(proc-name->label x) ,@(map (λ (arg) (triv->arg arg arg-env)) trivs))]
      [_ (uniquify-value tail arg-env)]))

  (define (uniquify-definitions def)
    (match def
      [`(define ,proc-name (lambda (,args ...) ,tail))
       (define alocs (map fresh args))
       (define arg-env
         (for/fold ([env (hash)])
                   ([arg args]
                    [aloc alocs])
           (hash-set env arg aloc)))
       `(define ,(proc-name->label proc-name)
          (lambda ,alocs ,(uniquify-tail tail arg-env)))]))

  ; (values-lang-v5-p env) -> (values-unique-lang-v5 p)
  (define (uniquify-p p)
    (match p
      [`(module ,defs ...
          ,tail)
       `(module ,@(map (λ (def) (uniquify-definitions def)) defs) ,(uniquify-tail tail (hash))
          )]))

  (uniquify-p vlv5))

(module+ test
  (require rackunit
           cpsc411/langs/v5)
  (define-syntax-rule (check-by-interp vlv5)
    (check-equal? (interp-values-lang-v5 vlv5) (interp-values-unique-lang-v5 (uniquify vlv5))))

  ;; M5 tests; Added by Trevor on March 8th 2026, multiple bindings allowed per let
  (check-by-interp '(module (define fn.0
                              (lambda (bat.1 foobar.5 foobar.8 foo.0 foo.3 foo.4)
                                (if (true)
                                    (if (= -502092639 foobar.5)
                                        (if (>= foobar.8 1) 1852032564 -106704231)
                                        (+ foo.4 1))
                                    (if (true)
                                        (+ -9223372036854775808 0)
                                        (let ([foo.4 foobar.5]
                                              [foo.3 0])
                                          foo.0)))))
                            (if (let ([foo.4 -9223372036854775808]
                                      [ball.7 0])
                                  (> foo.4 ball.7))
                                -9223372036854775808
                                (let ([bat.1 -9223372036854775808]
                                      [foo.4 1]
                                      [foobar.8 1])
                                  foobar.8))
                      ))
  (check-by-interp '(module (define tmp.0
                              (lambda (bat.2 bat.0 foobar.5 foobar.6 bat.8 foo.9)
                                (let ([foobar.6 (if (true)
                                                    (* bat.0 -1194246923)
                                                    foobar.5)]
                                      [foobar.5 (if (let ([bat.2 foobar.5]
                                                          [bat.4 foo.9])
                                                      (= bat.2 422731415))
                                                    (if (<= 9223372036854775807 9223372036854775807)
                                                        9223372036854775807
                                                        9223372036854775807)
                                                    (+ foo.9 52582991))])
                                  (call tmp.0 foobar.6 -191435828 -1002513727 0 bat.8 foo.9))))
                            (let ([bat.0 (+ -9223372036854775808 937267391)]
                                  [bat.2 (+ -9223372036854775808 -9223372036854775808)])
                              (if (!= bat.2 1) -335809824 bat.0))
                      ))
  (check-by-interp '(module (define proc.0
                              (lambda (ball.1 bat.9 foobar.2)
                                (if (false)
                                    (call tmp.1 bat.9 9223372036854775807 bat.9 ball.1 1)
                                    (let ([bat.7 (let ([bar.5 1554173211]
                                                       [foobar.2 616342412])
                                                   foobar.2)]
                                          [ball.1 (if (= foobar.2 ball.1) foobar.2 bat.9)]
                                          [ball.3 (if (= 1 0) bat.9 0)])
                                      (if (< 1320805275 9223372036854775807) 0 0)))))
                            (define tmp.1
                              (lambda (bat.7 ball.1 foobar.2 ball.3 ball.8)
                                (call proc.0 ball.3 9223372036854775807 ball.8)))
                      (let ([foo.6 (let ([foobar.0 2142022224]
                                         [foo.6 0]
                                         [bat.7 1])
                                     foo.6)]
                            [foobar.2 (+ 1 121573080)]
                            [bat.9 (* 9223372036854775807 -1355489058)])
                        0)))
  (check-by-interp
   '(module (let ([ball.5 (+ 0 9223372036854775807)]
                  [ball.7 -678062995]
                  [ball.8 (if (!= 0 9223372036854775807) -2004574473 9223372036854775807)])
              (* 1 ball.5))))
  (check-by-interp '(module (define fn.0 (lambda (foo.3 foo.1 bat.4) (call fn.0 foo.1 bat.4 foo.1)))
                            (define tmp.1
                              (lambda ()
                                (if (true)
                                    (let ([ball.0 (let ([foo.1 -918704320]
                                                        [foo.6 -1822595193])
                                                    foo.6)]
                                          [bat.4 0]
                                          [foo.7 (* 9223372036854775807 810114007)])
                                      (let ([foo.9 1]
                                            [foo.7 foo.7]
                                            [bat.8 1])
                                        1271317139))
                                    (if (let ([ball.0 9223372036854775807]
                                              [foobar.5 -9223372036854775808])
                                          (< 1474008962 ball.0))
                                        (if (!= -566856990 -9223372036854775808) 1 1056302987)
                                        (call tmp.1)))))
                      (let ([foo.1 (let ([bat.4 -9223372036854775808]
                                         [foo.7 9223372036854775807])
                                     bat.4)]
                            [foo.6 (if (>= -1846550218 1836975164) -186139937 1)])
                        (let ([foo.7 1884722986]
                              [foo.6 9223372036854775807])
                          0))))
  (check-by-interp '(module (define func.0 (lambda (bat.0 bat.7 bar.6 foo.2 foobar.5 foo.9) bat.0))
                            (define func.1
                              (lambda (foobar.1 bat.0)
                                (let ([foobar.1 (let ([bat.8 0]
                                                      [bar.3 (let ([foo.2 foobar.1]
                                                                   [bat.8 1492712685]
                                                                   [foo.4 foobar.1])
                                                               9223372036854775807)])
                                                  bar.3)]
                                      [bar.3 (let ([foobar.5 (let ([bat.8 bat.0]
                                                                   [foo.2 foobar.1]
                                                                   [foo.4 -383652955])
                                                               -9223372036854775808)]
                                                   [foobar.1 (+ bat.0 566306668)])
                                               (if (!= bat.0 0) -9223372036854775808 bat.0))]
                                      [bat.0 (if (false)
                                                 (* 1 0)
                                                 foobar.1)])
                                  bar.3)))
                      (call func.1 -9223372036854775808 0)))
  (check-by-interp
   '(module (define tmp.0
              (lambda (foobar.0 bar.7 foo.5 bat.2 bar.3 bar.8)
                (let ([bar.8 bat.2]
                      [bar.7 1])
                  (if (if (!= bar.7 foobar.0)
                          (<= -494940107 bar.3)
                          (< 0 1869530139))
                      (if (<= bar.7 0) 0 -777687734)
                      (if (> -9223372036854775808 foo.5) 9223372036854775807 -9223372036854775808)))))
            9223372036854775807
      ))
  (check-by-interp '(module (if (true)
                                (let ([foo.0 1]
                                      [foo.8 0])
                                  356048754)
                                (if (<= -1287356538 1126106862) 4712028 349517812))))
  (check-by-interp
   '(module (define fn.0
              (lambda ()
                (let ([bar.8 (* -9223372036854775808 0)]
                      [foobar.1 (let ([ball.3 (let ([foobar.7 0]
                                                    [bar.2 9223372036854775807])
                                                foobar.7)]
                                      [foobar.0 (let ([bar.8 1]
                                                      [ball.3 -9223372036854775808]
                                                      [bat.4 0])
                                                  0)]
                                      [bar.8 (+ 2146083242 1877941467)])
                                  (if (>= 1 0) foobar.0 bar.8))])
                  (let ([foobar.0 (let ([ball.6 9223372036854775807]
                                        [ball.3 1]
                                        [bat.4 bar.8])
                                    ball.3)]
                        [bar.2 (let ([foobar.1 foobar.1]
                                     [bar.8 -80057626]
                                     [bar.5 451403960])
                                 0)]
                        [ball.6 -9223372036854775808])
                    (if (= 0 foobar.1) 1 -9223372036854775808)))))
            (define func.1
              (lambda (ball.3 foobar.1 foobar.7 ball.6 foobar.0 bar.2 bat.4)
                (if (>= -68053908 1924767324)
                    (call func.2 0 2020389049 2037093174 foobar.7)
                    (call fn.0))))
      (define func.2
        (lambda (foobar.0 bat.4 ball.3 bar.8)
          (let ([bar.5 (let ([bar.2 (let ([bat.4 1683456577]
                                          [ball.3 0])
                                      572391381)]
                             [bar.8 (if (>= 9223372036854775807 foobar.0) -2023903597 -15104029)]
                             [foobar.7 1])
                         ball.3)]
                [ball.3 0]
                [bar.8 (+ bat.4 bat.4)])
            (+ 1 bat.4))))
      (if (not (> 512244517 -294049298))
          (let ([bar.5 1283186732]
                [bar.2 99039009]
                [bat.4 1811100583])
            bar.5)
          (let ([bat.4 1]
                [foobar.7 -9223372036854775808]
                [ball.6 1])
            ball.6))))
  (check-by-interp
   '(module (define proc.0
              (lambda (foobar.8 bat.1 bar.7 foobar.4 foobar.0)
                (call proc.2 foobar.0 bat.1 1 -9223372036854775808 foobar.8 9223372036854775807)))
            (define x.1
              (lambda (foobar.4 bar.2)
                (if (true)
                    (let ([foobar.0 (if (< foobar.4 foobar.4) foobar.4 foobar.4)]
                          [foo.5 (* foobar.4 -1298566605)]
                          [bar.2 0])
                      (* foobar.0 foobar.0))
                    (let ([foobar.4 (+ -1679672366 bar.2)]
                          [foobar.8 (+ 0 foobar.4)])
                      (let ([foobar.8 0]
                            [foobar.3 -511883263]
                            [bat.1 bar.2])
                        foobar.3)))))
      (define proc.2
        (lambda (foo.5 bat.1 foobar.4 foobar.3 bar.7 foo.9) (+ bar.7 -9223372036854775808)))
      (if (> 1 -735340476) -9223372036854775808 -1627211406)))
  (check-by-interp '(module (define x.0
                              (lambda (foobar.3)
                                (if (not (false))
                                    (let ([bat.7 (let ([bat.7 -508084756]
                                                       [foobar.3 foobar.3]
                                                       [bar.5 1])
                                                   bat.7)]
                                          [bat.4 (let ([bat.7 foobar.3]
                                                       [bar.5 1120136428]
                                                       [foobar.1 606194936])
                                                   -908142049)]
                                          [ball.0 (+ 600266106 foobar.3)])
                                      (let ([foobar.3 foobar.3]
                                            [ball.0 0])
                                        1))
                                    (call x.0 -2072909432))))
                            (let ([foobar.3 (let ([bat.7 -1755065230]
                                                  [bar.5 9223372036854775807]
                                                  [ball.0 0])
                                              bar.5)]
                                  [bar.8 -9223372036854775808]
                                  [bar.5 -9223372036854775808])
                              (if (< 1 bar.8) bar.8 -9223372036854775808))
                      ))
  (check-by-interp '(module (let ([bar.4 (* 993422572 1)]
                                  [bar.6 (if (<= 92310708 1290581674) 1 0)]
                                  [bar.1 (+ 9223372036854775807 -1759699484)])
                              (let ([bar.4 bar.4]
                                    [foobar.5 -9223372036854775808])
                                bar.4))))
  (check-by-interp '(module (define func.0
                              (lambda (bar.6)
                                (let ([bat.2 (let ([foo.0 (+ -9223372036854775808
                                                             -9223372036854775808)]
                                                   [bar.6 (+ bar.6 1312056768)])
                                               (if (<= 1 bar.6) -9223372036854775808 -50606571))]
                                      [foo.7 bar.6]
                                      [foobar.4 bar.6])
                                  (if (if (>= foo.7 bar.6)
                                          (< 0 foo.7)
                                          (!= 1880363761 9223372036854775807))
                                      (let ([bat.3 1]
                                            [bar.6 foobar.4])
                                        foo.7)
                                      (+ bat.2 bar.6)))))
                            (define x.1
                              (lambda ()
                                (if (true)
                                    -9223372036854775808
                                    (+ 0 9223372036854775807))))
                      (call x.1)))
  (check-by-interp '(module (define x.0
                              (lambda (ball.8 ball.6 foobar.1) (call x.0 foobar.1 ball.8 0)))
                            (if (> 9223372036854775807 1757631774)
                                (let ([foo.4 0]
                                      [foobar.2 213435043])
                                  -9223372036854775808)
                                0)
                      ))
  (check-by-interp '(module (if (not (< 1946235623 -9223372036854775808))
                                (let ([bat.0 -135046761]
                                      [bat.2 1453915451]
                                      [ball.5 257292075])
                                  bat.2)
                                -9223372036854775808)))
  (check-by-interp '(module (define proc.0 (lambda (foobar.9 foobar.3 bar.8) foobar.3))
                            (* 1 9223372036854775807)
                      ))
  (check-by-interp
   '(module (define proc.0
              (lambda (foobar.3 bar.5 bat.1 foobar.2 foobar.7 ball.0)
                (if (true)
                    (call func.1 1843221563 foobar.3 0 1407333795 foobar.3 foobar.2 1165846535)
                    (+ -1543779281 1))))
            (define func.1
              (lambda (bar.5 bat.6 bar.9 bar.4 foobar.7 ball.0 foobar.2)
                (let ([foobar.3 (* -9223372036854775808 ball.0)]
                      [foobar.2 ball.0]
                      [bat.6 bar.4])
                  (call func.1 -9223372036854775808 0 ball.0 foobar.2 ball.0 -811936434 foobar.2))))
      (if (true)
          -1263415267
          (if (<= 9223372036854775807 -514434406) 9223372036854775807 9223372036854775807))))
  (check-by-interp '(module (define proc.0 (lambda (bat.6 bar.8) (call tmp.1 -9223372036854775808)))
                            (define tmp.1
                              (lambda (bat.6)
                                (if (!= 9223372036854775807 bat.6)
                                    (if (true)
                                        (let ([bar.2 2026709313]
                                              [bat.9 bat.6]
                                              [bat.6 bat.6])
                                          bat.6)
                                        (if (>= 1890937388 bat.6) bat.6 1616264974))
                                    9223372036854775807)))
                      (let ([ball.7 (* 0 1192307430)]
                            [bat.3 (if (< -9223372036854775808 1) -9223372036854775808 2088471563)]
                            [bar.8 (let ([ball.7 1]
                                         [bat.9 9223372036854775807])
                                     1861500702)])
                        (if (!= 9223372036854775807 -9223372036854775808) ball.7 0))))
  (check-by-interp '(module (define proc.0
                              (lambda (foo.9)
                                (if (false)
                                    (call fn.2 foo.9 foo.9 -9223372036854775808 foo.9 foo.9 foo.9)
                                    (if (false)
                                        (let ([foobar.8 9223372036854775807]
                                              [foo.2 foo.9]
                                              [foobar.1 foo.9])
                                          foo.9)
                                        (if (> 1 foo.9) 822960898 foo.9)))))
                            (define fn.1
                              (lambda (foobar.1 foo.6 foobar.3)
                                (if (false)
                                    (let ([foobar.1 foobar.1]
                                          [foobar.5 (+ -2065189484 foobar.3)]
                                          [foobar.7 (if (< foobar.1 -300039187) 2115350249 foobar.1)])
                                      (let ([foobar.1 -195312042]
                                            [foobar.5 foo.6]
                                            [foo.6 foobar.3])
                                        foobar.7))
                                    (let ([foo.6 (let ([foobar.3 -1983872386]
                                                       [foobar.7 foobar.1])
                                                   foobar.7)]
                                          [foobar.3 (let ([foo.6 9223372036854775807]
                                                          [foo.0 -9223372036854775808]
                                                          [foo.9 1])
                                                      0)])
                                      (if (>= foo.6 foo.6) -9223372036854775808 foobar.3)))))
                      (define fn.2
                        (lambda (foo.6 foo.4 foobar.1 foo.9 foobar.5 foo.0)
                          (call fn.2 foo.6 foo.4 foo.4 968969801 foobar.1 foo.4)))
                      9223372036854775807))
  (check-by-interp '(module (if (not (>= 1622421353 94202816))
                                (let ([foobar.7 -2027378735]
                                      [bar.5 9223372036854775807])
                                  9223372036854775807)
                                (let ([foobar.4 -9223372036854775808]
                                      [bat.8 1])
                                  9223372036854775807))))
  (check-by-interp '(module (let ([bar.4 (* -1915251883 1)]
                                  [foo.7 (let ([ball.9 -9223372036854775808]
                                               [bar.0 356482613]
                                               [foo.7 9223372036854775807])
                                           foo.7)])
                              (let ([ball.5 foo.7]
                                    [ball.9 bar.4]
                                    [bat.3 -1601764542])
                                -9223372036854775808))))
  (check-by-interp '(module (define func.0
                              (lambda (ball.7 bar.4 foo.9 foo.2 foo.1 ball.8)
                                (if (if (> bar.4 ball.7)
                                        (if (= -1032056006 foo.1)
                                            (>= foo.2 ball.8)
                                            (< foo.9 1))
                                        (>= 1 foo.9))
                                    (call func.0 0 -675302553 bar.4 1807204646 ball.8 foo.9)
                                    (call func.0
                                          ball.8
                                          -41674885
                                          ball.8
                                          foo.1
                                          -9223372036854775808
                                          9223372036854775807))))
                            (if (!= -9223372036854775808 -719419034)
                                (let ([foo.1 9223372036854775807]
                                      [bar.4 0]
                                      [foobar.5 9223372036854775807])
                                  foobar.5)
                                (if (> -235413122 1) 0 9223372036854775807))
                      ))
  (check-by-interp '(module (define fn.0 (lambda (ball.9) (call x.1 ball.9 ball.9)))
                            (define x.1
                              (lambda (ball.6 ball.9)
                                (if (not (false))
                                    (let ([foobar.4 ball.9]
                                          [foo.1 (let ([foo.1 9223372036854775807]
                                                       [bar.5 ball.6])
                                                   9223372036854775807)]
                                          [ball.9 -2115998024])
                                      -1101891150)
                                    (let ([bat.7 (* -1594085017 ball.9)]
                                          [ball.9 (let ([bat.7 -999943825]
                                                        [foobar.0 ball.6])
                                                    593362223)]
                                          [foobar.0 0])
                                      (if (= bat.7 1) foobar.0 0)))))
                      (if (if (= 1 -1319463227)
                              (>= -9223372036854775808 1)
                              (!= -1520052689 1))
                          (let ([foo.8 -9223372036854775808]
                                [foobar.0 9223372036854775807]
                                [ball.2 744570222])
                            foo.8)
                          (let ([bar.5 -133225634]
                                [foo.8 -9223372036854775808]
                                [ball.6 -9223372036854775808])
                            bar.5))))
  (check-by-interp '(module (let ([bat.2 9223372036854775807]
                                  [foobar.3 (let ([ball.6 1]
                                                  [bar.4 -9223372036854775808]
                                                  [ball.1 9223372036854775807])
                                              1)]
                                  [bar.4 (let ([foobar.7 -1722042928]
                                               [foobar.9 0])
                                           1)])
                              (if (!= -1508403451 bat.2) 447579047 bat.2))))
  (check-by-interp '(module (define tmp.0
                              (lambda (foo.4 ball.9 foobar.6 foo.8)
                                (call tmp.0 9223372036854775807 foobar.6 foobar.6 foo.4)))
                            (+ 9223372036854775807 -1932027129)
                      ))
  (check-by-interp '(module (define func.0
                              (lambda (bat.4 ball.7) (call fn.1 bat.4 ball.7 -436836322 bat.4)))
                            (define fn.1
                              (lambda (ball.7 bar.8 bat.1 ball.2)
                                (if (true)
                                    (if (if (> 182929845 bar.8)
                                            (>= bat.1 1)
                                            (< -767224240 9223372036854775807))
                                        (+ bat.1 -9223372036854775808)
                                        bat.1)
                                    (let ([bar.5 (+ -9223372036854775808 -9223372036854775808)]
                                          [ball.0 (let ([bat.1 -1747554427]
                                                        [ball.2 ball.7]
                                                        [ball.0 9223372036854775807])
                                                    bat.1)])
                                      ball.0))))
                      (define x.2
                        (lambda ()
                          (if (< 0 9223372036854775807)
                              1083014636
                              (let ([bat.4 (if (<= 1 9223372036854775807) 9223372036854775807 1)]
                                    [bar.5 (* 0 0)]
                                    [bat.1 (* 1942355770 9223372036854775807)])
                                (if (>= bat.4 9223372036854775807) -9223372036854775808 1)))))
                      (call func.0 -1129269775 9223372036854775807)))
  (check-by-interp
   '(module (define proc.0
              (lambda ()
                (if (let ([bat.2 (* 1 0)]
                          [ball.8 -9223372036854775808])
                      (if (> ball.8 bat.2)
                          (>= 9223372036854775807 ball.8)
                          (= bat.2 0)))
                    -9223372036854775808
                    (call proc.2 0 1 0))))
            (define fn.1
              (lambda (bat.2 foo.4 foobar.0 foobar.1 bat.3 ball.9 bar.6)
                (if (if (true)
                        (if (!= -1156972119 bat.3)
                            (> 9223372036854775807 bat.2)
                            (!= 1703616983 foo.4))
                        (if (>= ball.9 bar.6)
                            (> bat.3 bat.3)
                            (< bat.2 bat.2)))
                    (let ([foo.4 (let ([bat.2 bar.6]
                                       [ball.9 -144518674]
                                       [bar.6 foobar.1])
                                   bat.3)]
                          [bat.3 (if (< bat.2 9223372036854775807) 0 -9223372036854775808)])
                      (if (>= bat.2 -2080421634) 9223372036854775807 0))
                    -274219017)))
      (define proc.2 (lambda (ball.5 bat.2 ball.9) (+ bat.2 9223372036854775807)))
      (let ([foobar.1 (+ 1 -1806804688)]
            [ball.7 (+ 1880531761 1)])
        (if (<= 0 foobar.1) 0 9223372036854775807))))
  (check-by-interp '(module (if (!= -107521481 -1873066368)
                                (* 1275956981 1)
                                (let ([bat.4 1318401057]
                                      [foobar.7 -542033033])
                                  -288327503))))
  (check-by-interp '(module (define fn.0
                              (lambda ()
                                (let ([bat.3 (let ([foobar.4 9223372036854775807]
                                                   [bat.0 684249837]
                                                   [bar.7 1])
                                               (if (= 2084897481 bar.7) foobar.4 bar.7))]
                                      [ball.9 (if (let ([ball.1 0]
                                                        [bat.5 1774106288])
                                                    (> 0 bat.5))
                                                  (let ([bat.0 9223372036854775807]
                                                        [foo.6 811516044])
                                                    bat.0)
                                                  (if (< -1327371506 9223372036854775807)
                                                      -9223372036854775808
                                                      9223372036854775807))])
                                  (call fn.0))))
                            (let ([bat.5 (if (= 1517267005 605514120) -1228391641 -1926002282)]
                                  [ball.9 (if (> 0 1) 9223372036854775807 0)])
                              (* 25767341 0))
                      ))
  (check-by-interp
   '(module (define func.0
              (lambda ()
                (if (false)
                    (if (not (!= -1086072832 9223372036854775807))
                        (let ([bar.4 793954259]
                              [bat.0 0]
                              [bat.6 -9223372036854775808])
                          9223372036854775807)
                        (+ 620579510 1))
                    (if (true)
                        9223372036854775807
                        (let ([ball.8 716210269]
                              [bat.0 -524345693])
                          -9223372036854775808)))))
            (define fn.1
              (lambda (bat.0 bat.6)
                (if (if (true)
                        (if (> 0 9223372036854775807)
                            (<= 1 -330770905)
                            (> 0 bat.0))
                        (if (>= bat.0 bat.0)
                            (<= -1763336001 1)
                            (>= 9223372036854775807 -1870920433)))
                    (if (not (= -9223372036854775808 1676706544))
                        (if (<= 0 bat.0) -9223372036854775808 bat.0)
                        (if (<= -9223372036854775808 1745852904) 592053094 -1824096668))
                    (let ([ball.5 (let ([foo.3 bat.0]
                                        [ball.5 bat.6])
                                    foo.3)]
                          [foo.3 (+ 1995506902 -677333479)]
                          [bar.4 (let ([bar.9 bat.0]
                                       [bat.0 -1273465885]
                                       [bat.6 148631858])
                                   bat.0)])
                      bat.6))))
      (let ([bar.7 -1536502942]
            [bat.0 -1557455680]
            [bat.6 (let ([bat.6 -1112875927]
                         [ball.5 9223372036854775807]
                         [foo.3 9223372036854775807])
                     ball.5)])
        (if (<= bar.7 bat.0) 1132619346 0))))
  (check-by-interp '(module (if (true)
                                (let ([foobar.3 -9223372036854775808]
                                      [foo.8 9223372036854775807])
                                  foobar.3)
                                (let ([foo.5 -9223372036854775808]
                                      [foo.8 1929590320]
                                      [foobar.2 0])
                                  0))))
  (check-by-interp '(module (let ([bar.1 (if (> 9223372036854775807 1398326902)
                                             9223372036854775807
                                             9223372036854775807)]
                                  [bat.3 0]
                                  [foo.0 (let ([bat.3 -9223372036854775808]
                                               [ball.9 -1747244286])
                                           ball.9)])
                              (let ([foo.0 -1923830755]
                                    [bat.5 bar.1])
                                bat.5))))
  (check-by-interp '(module (define proc.0
                              (lambda ()
                                (let ([bat.6 (if (true)
                                                 0
                                                 (* 1 1))]
                                      [foo.9 -9223372036854775808]
                                      [bar.0 (* 672116958 1)])
                                  (if (< bar.0 980303276)
                                      (+ 9223372036854775807 bar.0)
                                      (let ([bar.2 -667597146]
                                            [foo.9 1438122241])
                                        1900048603)))))
                            (define proc.1
                              (lambda ()
                                (if (true)
                                    (if (if (< 0 -9223372036854775808)
                                            (<= 0 -9223372036854775808)
                                            (> 9223372036854775807 -1813633866))
                                        -935154891
                                        (let ([ball.3 -1449852093]
                                              [bat.6 -9223372036854775808])
                                          1))
                                    (+ -1450359427 -701676518))))
                      (if (false)
                          (call proc.1)
                          (if (!= 1 9223372036854775807) 313960847 0))))
  (check-by-interp '(module (if (if (< -500842013 -2010375969)
                                    (< -1785958547 9223372036854775807)
                                    (<= 904902616 1))
                                (if (= -1568723397 0) 1 -9223372036854775808)
                                1)))
  (check-by-interp '(module (if (false)
                                0
                                (if (>= 1 0) 281602960 9223372036854775807))))
  (check-by-interp '(module (if (true)
                                (+ -1267155910 -9223372036854775808)
                                (if (>= 901304193 1) 0 -154349390))))
  (check-by-interp '(module 9223372036854775807))
  (check-by-interp '(module (if (true)
                                (+ -9223372036854775808 1965973068)
                                (let ([bar.2 -644439618]
                                      [foo.7 1])
                                  foo.7))))

  ;;
  (check-by-interp '(module (define proc.0 (lambda (ball.3) (call proc.0 9223372036854775807)))
                            (define x.1
                              (lambda (ball.3 ball.6)
                                (if (if (if (!= ball.6 ball.6)
                                            (>= ball.3 ball.3)
                                            (<= -763864902 9223372036854775807))
                                        (< 1 1)
                                        (false))
                                    (let ([ball.1 (+ ball.3 -9223372036854775808)]) 598366993)
                                    (* 9223372036854775807 ball.3))))
                      (define tmp.2
                        (lambda (ball.6 foo.9)
                          (if (true)
                              (let ([ball.1 (+ 1 -9223372036854775808)]) 1)
                              (* foo.9 foo.9))))
                      (if (let ([ball.4 2083024360]) (<= 1 ball.4))
                          (+ 0 1)
                          (call x.1 -390453851 1))))

  (check-by-interp '(module (define fn.0 (lambda (foo.3 bat.7) (call tmp.1 0 bat.7)))
                            (define tmp.1
                              (lambda (ball.2 foo.1) (call func.2 9223372036854775807 foo.1)))
                      (define func.2
                        (lambda (foo.6 bat.7)
                          (let ([foobar.9 foo.6])
                            (let ([foobar.8 (if (< 0 9223372036854775807) 0 -1879014922)])
                              (if (= 1 1) foobar.9 foobar.9)))))
                      (if (<= 9223372036854775807 9223372036854775807) 0 0)))

  (check-by-interp '(module (define proc.0
                              (lambda (ball.0 ball.3)
                                (if (if (not (>= 1676206373 ball.0))
                                        (not (>= -9223372036854775808 ball.0))
                                        (false))
                                    (call fn.2)
                                    (+ -679407720 -1670539202))))
                            (define proc.1 (lambda (bat.6 bar.5) (call proc.0 -2030614437 1)))
                      (define fn.2
                        (lambda ()
                          (let ([bat.6 (* -9223372036854775808 -1564619175)])
                            (if (not (<= bat.6 9223372036854775807))
                                (call fn.2)
                                (call proc.1 -9223372036854775808 9223372036854775807)))))
                      (let ([bat.7 760052997]) (+ 9223372036854775807 9223372036854775807))))

  (check-by-interp '(module (define x.0
                              (lambda (ball.3 foobar.2)
                                (let ([foobar.4 -9223372036854775808])
                                  (call x.0 -939287079 foobar.2))))
                            1542811121
                      ))

  (check-by-interp '(module (define x.0
                              (lambda (ball.4 ball.5)
                                (if (>= -663003513 946817357)
                                    (if (if (> -9223372036854775808 0)
                                            (= 9223372036854775807 ball.4)
                                            (< ball.5 -9223372036854775808))
                                        (if (>= ball.5 9223372036854775807) 0 ball.4)
                                        (let ([ball.4 -467213902]) ball.4))
                                    (if (false)
                                        (if (= ball.4 0) -9223372036854775808 -9223372036854775808)
                                        (if (> ball.5 0) 271081552 9223372036854775807)))))
                            (define tmp.1
                              (lambda (ball.5)
                                (let ([ball.9 ball.5])
                                  (let ([bat.6 9223372036854775807]) (call tmp.1 ball.9)))))
                      (define proc.2
                        (lambda ()
                          (let ([foo.1 (if (if (> 1458486403 645932820)
                                               (!= 1 1594860681)
                                               (< -9223372036854775808 -70861590))
                                           (+ 2099071943 -9223372036854775808)
                                           (if (< -9223372036854775808 881673257) 1 -568199062))])
                            1)))
                      (let ([ball.9 -9223372036854775808]) 9223372036854775807)))

  (check-by-interp '(module (define proc.0 (lambda (ball.3) (call proc.0 9223372036854775807)))
                            (define x.1
                              (lambda (ball.3 ball.6)
                                (if (if (if (!= ball.6 ball.6)
                                            (>= ball.3 ball.3)
                                            (<= -763864902 9223372036854775807))
                                        (< 1 1)
                                        (false))
                                    (let ([ball.1 (+ ball.3 -9223372036854775808)]) 598366993)
                                    (* 9223372036854775807 ball.3))))
                      (define tmp.2
                        (lambda (ball.6 foo.9)
                          (if (true)
                              (let ([ball.1 (+ 1 -9223372036854775808)]) 1)
                              (* foo.9 foo.9))))
                      (if (let ([ball.4 2083024360]) (<= 1 ball.4))
                          (+ 0 1)
                          (call x.1 -390453851 1))))
  (check-by-interp '(module (define func.0 (lambda (foobar.1 foo.6) (call x.1 foo.6 foo.6)))
                            (define x.1 (lambda (foobar.1 bar.9) bar.9))
                      (call x.1 9223372036854775807 0)))
  (check-by-interp '(module (define tmp.0
                              (lambda (bat.8 foo.1)
                                (if (if (if (>= bat.8 foo.1)
                                            (< bat.8 0)
                                            (>= bat.8 foo.1))
                                        (not (>= -9223372036854775808 bat.8))
                                        (< 9223372036854775807 9223372036854775807))
                                    (call proc.1 9223372036854775807)
                                    (call tmp.2 bat.8 bat.8))))
                            (define proc.1
                              (lambda (foobar.3)
                                (if (false)
                                    foobar.3
                                    (* foobar.3 foobar.3))))
                      (define tmp.2 (lambda (foo.1 ball.0) (call proc.1 -915763316)))
                      (let ([foo.1 (* -864893154 9223372036854775807)])
                        (if (> 1679313251 -9223372036854775808) foo.1 -9223372036854775808))))

  (check-by-interp
   '(module (define fn.0
              (lambda (bat.1 foo.0)
                (let ([bat.5 (let ([foobar.8
                                    (if (>= 9223372036854775807 -9223372036854775808) bat.1 foo.0)])
                               (let ([ball.4 -9223372036854775808]) foo.0))])
                  (let ([ball.4 (if (<= -1657890681 9223372036854775807) bat.1 bat.1)])
                    (call fn.0 bat.1 bat.1)))))
            (if (<= 1 1) 0 -9223372036854775808)
      ))

  (check-by-interp '(module (define x.0
                              (lambda (bat.1)
                                (let ([ball.5 (let ([bat.6 (+ -1473118393 -9223372036854775808)])
                                                (let ([foo.4 9223372036854775807]) 218975616))])
                                  (* bat.1 bat.1))))
                            (define tmp.1
                              (lambda ()
                                (let ([bat.1 (if (not (<= 1 1))
                                                 (* -753830259 -9223372036854775808)
                                                 0)])
                                  (if (if (>= bat.1 1170112415)
                                          (!= 172014518 bat.1)
                                          (<= bat.1 540373982))
                                      bat.1
                                      (+ bat.1 bat.1)))))
                      (define proc.2 (lambda (ball.9) (+ -499436274 9223372036854775807)))
                      1))

  (check-by-interp '(module (if (> -9223372036854775808 9223372036854775807) 0 -171588084)))

  (check-by-interp '(module (if (< -9223372036854775808 1)
                                (let ([ball.0 -1183539798]) ball.0)
                                (let ([foobar.6 -1081284475]) foobar.6))))
  (check-by-interp '(module (define func.0
                              (lambda (bar.6)
                                (if (false)
                                    bar.6
                                    (call func.0 bar.6))))
                            (if (< 1694312373 9223372036854775807)
                                (if (= 1766930141 9223372036854775807) 1 9223372036854775807)
                                (if (<= 1 530802046) 0 -9223372036854775808))
                      ))
  ;;   added March 2nd 2026
  (check-by-interp
   '(module (define x.0 (lambda (bat.2 bar.0) (call x.0 1 203659231)))
            (define tmp.1
              (lambda ()
                (let ([foo.3 (let ([bat.2 (if (= -9223372036854775808 1) 9223372036854775807 0)])
                               (if (>= -9223372036854775808 784027956) 9223372036854775807 0))])
                  (if (false)
                      (if (= -9223372036854775808 foo.3) foo.3 foo.3)
                      (call x.0 1 foo.3)))))
      (let ([foo.6 (if (<= -1418225656 0) -750331240 1598097510)])
        (let ([foo.3 1]) 9223372036854775807))))

  (check-by-interp '(module (define tmp.0
                              (lambda (bat.7 ball.5) (let ([bat.8 -1468616918]) (* bat.8 bat.8))))
                            (define func.1 (lambda (ball.9 bar.1) 0))
                      (if (<= 1 -9223372036854775808) 0 -1806756174)))

  (check-by-interp '(module (let ([ball.3 0]) ball.3)))

  (check-by-interp '(module (define tmp.0
                              (lambda (foo.5 foobar.8)
                                (let ([ball.3 (+ foo.5 1)])
                                  (if (= 1760100976 9223372036854775807)
                                      (if (< foo.5 0) foo.5 -2034842933)
                                      (+ ball.3 1)))))
                            (define fn.1 (lambda (foo.2 bat.7) bat.7))
                      (define func.2 (lambda (foobar.8) (call fn.1 -9223372036854775808 foobar.8)))
                      (let ([foo.2 (* 9223372036854775807 -1278565935)])
                        (if (<= 9223372036854775807 0) 9223372036854775807 1))))

  (check-by-interp '(module (define func.0 (lambda () 0))
                            (define tmp.1 (lambda (foo.2) (call func.0)))
                      (define func.2
                        (lambda ()
                          (let ([bar.4 (if (true)
                                           (let ([foo.2 1]) foo.2)
                                           (* -9223372036854775808 1806293504))])
                            (let ([foobar.6 (if (> 1 0) 156890122 bar.4)]) 0))))
                      (call tmp.1 -1860620182)))

  (check-by-interp
   '(module (define tmp.0
              (lambda ()
                (if (>= 9223372036854775807 -1020514810)
                    (call x.2)
                    (* 1 0))))
            (define func.1
              (lambda ()
                (let ([bar.1 -9223372036854775808])
                  (if (not (> 9223372036854775807 0)) 1309557052 bar.1))))
      (define x.2
        (lambda ()
          (if (if (true)
                  (not (> 0 1))
                  (true))
              (if (> 0 0)
                  (if (< 9223372036854775807 9223372036854775807) 9223372036854775807 -260353756)
                  (let ([ball.0 0]) ball.0))
              (let ([bar.3 (if (!= -302047143 0) 9223372036854775807 102036653)])
                (if (= 0 bar.3) bar.3 -362331747)))))
      (let ([ball.0 (* -9223372036854775808 -9223372036854775808)]) (+ ball.0 0))))

  (check-by-interp '(module (define proc.0 (lambda (ball.6) (call func.1)))
                            (define func.1 (lambda () (* 1 0)))
                      (define fn.2
                        (lambda (ball.3)
                          (if (true)
                              (let ([bat.0 (if (<= -2033705372 965540822) -1853172774 1133506028)])
                                (let ([foo.4 1]) 1236904416))
                              (call func.1))))
                      (call proc.0 1)))

  (check-by-interp '(module (define fn.0
                              (lambda ()
                                (let ([bat.9 (if (false)
                                                 1
                                                 (let ([foo.5 1]) 1))])
                                  (if (if (>= 9223372036854775807 -9223372036854775808)
                                          (= -248968641 9223372036854775807)
                                          (!= bat.9 -9223372036854775808))
                                      (let ([ball.4 bat.9]) 1622965009)
                                      (let ([foo.5 bat.9]) bat.9)))))
                            (if (false)
                                (if (>= 995853130 1) 1 -9223372036854775808)
                                (call fn.0))
                      ))

  (check-by-interp '(module (+ -9223372036854775808 -1465538260)))

  (check-by-interp '(module (define fn.0
                              (lambda ()
                                (let ([bar.2 (+ 1 9223372036854775807)])
                                  (let ([foo.8 (let ([foo.1 bar.2]) foo.1)]) bar.2))))
                            (define func.1
                              (lambda ()
                                (let ([ball.3 (if (let ([foo.8 1]) (< 1 foo.8))
                                                  (let ([foo.1 406779451]) 1200977699)
                                                  (let ([foo.8 0]) foo.8))])
                                  (* ball.3 ball.3))))
                      (let ([bat.5 1]) (let ([ball.9 0]) bat.5))))

  (check-by-interp
   '(module (define x.0 (lambda (ball.1 foo.0) (call tmp.1)))
            (define tmp.1
              (lambda ()
                (if (if (if (<= -765445006 0)
                            (!= 0 -7399083)
                            (<= 9223372036854775807 1))
                        (false)
                        (true))
                    (let ([ball.4 (let ([bar.5 -9223372036854775808]) bar.5)])
                      (if (> ball.4 ball.4) -9223372036854775808 ball.4))
                    (let ([foobar.9 (if (>= 1 0) -9223372036854775808 -9223372036854775808)])
                      (if (= 0 foobar.9) 0 9223372036854775807)))))
      (define func.2 (lambda (ball.4 ball.6) (call tmp.1)))
      (if (<= 0 1) -1271132888 2101306416)))

  (check-by-interp '(module (define proc.0
                              (lambda (bar.8)
                                (let ([bat.7 (if (false)
                                                 (let ([bat.4 bar.8]) 1733388107)
                                                 (let ([foobar.2 -818241658]) foobar.2))])
                                  (let ([bat.3 (* -1769976594 bat.7)])
                                    (if (!= bar.8 bar.8) 1 bar.8)))))
                            (if (<= 0 0) 1764584349 -9223372036854775808)
                      ))

  (check-by-interp '(module (define proc.0
                              (lambda (ball.3)
                                (if (not (false))
                                    (call x.1)
                                    (let ([foobar.4 (let ([bat.9 ball.3]) 9223372036854775807)])
                                      (+ -9223372036854775808 ball.3)))))
                            (define x.1 (lambda () 1))
                      (let ([foobar.4 (let ([ball.1 453798193]) ball.1)])
                        (if (>= 9223372036854775807 foobar.4) 0 -1617493587))))

  (check-by-interp '(module (define func.0
                              (lambda (bat.8)
                                (if (let ([bat.2 (* 9223372036854775807 bat.8)]) (true))
                                    (if (true)
                                        (if (< bat.8 -9223372036854775808) bat.8 bat.8)
                                        (if (= -9223372036854775808 bat.8) bat.8 bat.8))
                                    (call proc.1))))
                            (define proc.1 (lambda () (call func.0 954069433)))
                      (if (false)
                          (* 1337690701 9223372036854775807)
                          (call proc.1))))

  (check-by-interp '(module (if (not (> 1 9223372036854775807))
                                (if (>= 1 1197468889) 9223372036854775807 1)
                                1)))

  (check-by-interp '(module (define func.0 (lambda (foo.9 foo.2 bar.1 bat.7 foobar.4) -1458025903))
                            (call func.0 -9223372036854775808 1 -808937821 -9223372036854775808 0)
                      ))

  (check-by-interp '(module (define tmp.0
                              (lambda (ball.6 bat.5 bar.8 foobar.0)
                                (let ([bat.2 ball.6])
                                  (if (if (<= -9223372036854775808 bat.5)
                                          (>= -9223372036854775808 ball.6)
                                          (>= bat.5 2025307007))
                                      (+ bat.2 9223372036854775807)
                                      (if (<= bat.5 -9223372036854775808) 9223372036854775807 0)))))
                            (let ([ball.6 0]) ball.6)
                      ))

  (check-by-interp
   '(module (define func.0
              (lambda (ball.6 foobar.3)
                (if (= 0 foobar.3)
                    (+ -9223372036854775808 -9223372036854775808)
                    (if (if (< ball.6 ball.6)
                            (<= foobar.3 foobar.3)
                            (= foobar.3 ball.6))
                        (+ foobar.3 foobar.3)
                        (if (= 1 foobar.3) ball.6 foobar.3)))))
            (define x.1
              (lambda (bar.0)
                (let ([ball.1 (let ([bat.9 (let ([bat.2 1757280127]) bat.2)])
                                (let ([ball.5 1]) -1128483887))])
                  (if (let ([foo.7 bar.0]) (> foo.7 foo.7))
                      ball.1
                      (+ ball.1 bar.0)))))
      (define fn.2
        (lambda ()
          (if (let ([foobar.8 (+ -9223372036854775808 -1421853645)]) (not (>= 0 -1400373009)))
              (+ -167927521 1)
              (let ([ball.1 (* 1041085683 9223372036854775807)]) (let ([foo.4 ball.1]) 770292232)))))
      (call x.1 1840464414)))

  (check-by-interp
   '(module (define proc.0
              (lambda (ball.4 foo.7 ball.2) (call proc.0 9223372036854775807 ball.2 foo.7)))
            (define func.1
              (lambda (ball.1 bat.0 foo.7 ball.4 foobar.6 bar.3)
                (let ([bar.3 (let ([ball.4 foo.7]) (let ([foobar.5 ball.1]) -9223372036854775808))])
                  (call proc.0 bar.3 -780648786 bar.3))))
      (let ([bat.0 -579691794]) 953357957)))

  (check-by-interp '(module (+ 609364271 -9223372036854775808)))

  (check-by-interp '(module (let ([bar.5 (let ([ball.2 9223372036854775807]) -546026276)])
                              (if (!= bar.5 1) 9223372036854775807 2063023986))))

  (check-by-interp '(module (define func.0
                              (lambda (foo.8 bar.2)
                                (if (not (let ([foo.8 foo.8]) (= foo.8 0)))
                                    (let ([foobar.6 (+ foo.8 0)]) (* 0 9223372036854775807))
                                    (let ([bat.7 (* 0 bar.2)])
                                      (if (!= bat.7 -9223372036854775808) bar.2 0)))))
                            (if (= 9223372036854775807 -315897602) 1 -9223372036854775808)
                      ))

  (check-by-interp
   '(module (define fn.0
              (lambda (foobar.3 ball.7)
                (let ([bar.9 (let ([bat.4 (* 1 9223372036854775807)])
                               (+ -9223372036854775808 bat.4))])
                  (let ([bat.4 9223372036854775807]) (if (!= 1 bar.9) 9223372036854775807 ball.7)))))
            (define x.1
              (lambda (bat.2)
                (let ([foobar.3 (let ([bat.4 (+ -1410706204 bat.2)])
                                  (let ([bat.2 1]) -9223372036854775808))])
                  (* -152436426 0))))
      (define proc.2 (lambda (foo.5 ball.7 foo.0 ball.8) (let ([foobar.1 foo.5]) (+ 956544411 1))))
      (+ 979460199 -1697959716)))

  (check-by-interp
   '(module (define proc.0
              (lambda (foobar.1 bar.0 foobar.2 ball.8 bat.3 bar.5)
                (let ([bar.9 (if (let ([bar.7 -669410514]) (< bat.3 bat.3))
                                 (+ bar.5 ball.8)
                                 foobar.2)])
                  (let ([ball.6 (let ([foo.4 ball.8]) 1)])
                    (if (<= foobar.2 1) 9223372036854775807 bat.3)))))
            (call proc.0 0 9223372036854775807 0 -1371550930 -1891086346 9223372036854775807)
      ))

  (check-by-interp '(module (define x.0
                              (lambda (bat.7 ball.9 foobar.3 ball.5 ball.4 bar.0 ball.2)
                                (if (not (if (>= 388494724 ball.9)
                                             (> ball.5 -9223372036854775808)
                                             (< foobar.3 ball.5)))
                                    (if (<= ball.4 bar.0)
                                        0
                                        (let ([ball.4 ball.5]) 1887946265))
                                    foobar.3)))
                            (define tmp.1
                              (lambda (bat.7 ball.9 ball.5 foo.6 bar.0 ball.2)
                                (if (true)
                                    (* foo.6 9223372036854775807)
                                    (if (let ([foobar.3 1]) (<= bar.0 ball.5))
                                        (let ([ball.9 -9223372036854775808]) ball.9)
                                        (let ([bat.7 1]) 1)))))
                      (define tmp.2
                        (lambda (bat.7 ball.2 foo.6 foobar.3 bar.8 bar.0)
                          (let ([foobar.3 (if (let ([ball.2 258314756]) (!= bar.8 0))
                                              bar.8
                                              (let ([foo.6 -1809848824]) 9223372036854775807))])
                            (if (< 1525021420 1)
                                (call tmp.1 foobar.3 1 -1256996529 foo.6 -768559462 1067478227)
                                (if (> 389818959 882297114) bar.8 ball.2)))))
                      (let ([bar.0 1]) 1)))

  (check-by-interp
   '(module (define tmp.0 (lambda (foo.1 ball.6 bar.9 bat.3 ball.8 bat.0 ball.7) (* bat.3 bat.0)))
            (define func.1
              (lambda (foo.1 bar.2 foo.5 bat.3 bar.9) (let ([bat.3 1]) 9223372036854775807)))
      (define fn.2
        (lambda (ball.7 ball.8)
          (let ([bat.3 (if (>= ball.7 1)
                           (if (= ball.7 ball.7) ball.8 214741259)
                           (+ 1683358713 ball.8))])
            (call tmp.0 bat.3 ball.8 0 ball.7 9223372036854775807 ball.7 -2043460455))))
      (call tmp.0
            -9223372036854775808
            -9223372036854775808
            -9223372036854775808
            9223372036854775807
            -9223372036854775808
            1
            -9223372036854775808)))

  (check-by-interp '(module (if (true)
                                (+ 1 -9223372036854775808)
                                (if (> 1383245321 0) 0 1))))

  (check-by-interp
   '(module (define func.0
              (lambda (ball.1 foobar.0 ball.7 bat.9)
                (let ([foo.6 (* 0 ball.7)])
                  (if (let ([foo.2 0]) (!= 0 1))
                      (call func.0 foobar.0 1 0 ball.1)
                      (call func.0 foobar.0 9223372036854775807 -1987151411 1)))))
            (if (>= -935340714 -9223372036854775808) -9223372036854775808 9223372036854775807)
      ))

  (check-by-interp
   '(module (define fn.0
              (lambda (bar.2 bat.3)
                (if (not (let ([foo.7 bar.2]) (<= 0 989218265)))
                    (call fn.0 bat.3 bar.2)
                    (let ([bar.9 (let ([bat.0 -9223372036854775808]) bat.3)]) 2108201156))))
            (define func.1
              (lambda ()
                (if (<= 106243304 0)
                    -9223372036854775808
                    (let ([foobar.5 (let ([foobar.5 9223372036854775807]) 9223372036854775807)])
                      (+ foobar.5 -211580633)))))
      (define x.2
        (lambda (bat.1 bat.3 ball.8 foobar.6 bar.2)
          (if (false)
              (let ([ball.8 foobar.6]) (if (<= 1 9223372036854775807) 1924763751 ball.8))
              bat.1)))
      (let ([bar.9 (+ 1471174001 779392821)]) (if (<= bar.9 1) bar.9 -9223372036854775808))))
  ;; Extra large tests

  (check-by-interp
   '(module (define tmp.0 (lambda (bat.1 bar.2 bat.4 foo.7) bar.2))
            (define tmp.1 (lambda (foo.7 bat.5 bat.4 foobar.0) (* foo.7 -520057153)))
      (define proc.2
        (lambda (bar.2 bat.5 bat.4 bat.1 ball.6)
          (let ([foobar.3 (* -1313115038 -9223372036854775808)]) ball.6)))
      (define fn.3
        (lambda ()
          (let ([bat.1 -9223372036854775808])
            (let ([ball.6 (* 1512642431 bat.1)]) (if (> bat.1 9223372036854775807) ball.6 ball.6)))))
      (define func.4
        (lambda (bat.8 bar.2 bat.5 ball.9 bat.1 foobar.0)
          (let ([bat.4 (* 9223372036854775807 ball.9)]) -1238090268)))
      (define x.5 (lambda (bat.1 bat.8 bat.4 ball.6 ball.9 foo.7) (+ 1 1)))
      (define tmp.6 (lambda (foobar.3) (let ([foobar.3 (+ foobar.3 foobar.3)]) foobar.3)))
      (define x.7
        (lambda (foobar.3 ball.6 bat.1 foo.7 bat.8 bar.2)
          (if (> bar.2 ball.6)
              bat.1
              (* bar.2 bat.8))))
      (call fn.3)))

  (check-by-interp
   '(module (define x.0 (lambda (ball.0 foobar.1 foo.3 foobar.2 foo.6 foobar.5 ball.8) (call x.4 1)))
            (define func.1
              (lambda ()
                (let ([bar.9 9223372036854775807])
                  (let ([foobar.1 bar.9]) (if (>= -577997854 foobar.1) -9223372036854775808 bar.9)))))
      (define fn.2
        (lambda ()
          (let ([ball.7 (+ 1 1)])
            (if (false)
                ball.7
                (let ([foobar.1 ball.7]) 1969054361)))))
      (define x.3
        (lambda (foobar.4 foobar.5 bar.9 foobar.2 ball.8 foo.3 ball.7)
          (call func.6
                0
                -9223372036854775808
                9223372036854775807
                25911444
                9223372036854775807
                foobar.4
                -9223372036854775808)))
      (define x.4 (lambda (foobar.4) (call x.3 0 foobar.4 foobar.4 1 foobar.4 foobar.4 foobar.4)))
      (define x.5
        (lambda (foo.6 foo.3 foobar.4 bar.9 foobar.1 foobar.5)
          (let ([foobar.5 (let ([foobar.1 bar.9]) (let ([foo.6 foo.3]) foobar.1))])
            (if (let ([ball.8 bar.9]) (> foo.3 foo.6))
                (call x.0
                      -1863740769
                      9223372036854775807
                      foobar.4
                      foobar.5
                      foo.3
                      foobar.5
                      -1819248150)
                1))))
      (define func.6
        (lambda (foobar.2 foo.6 ball.0 ball.8 foo.3 foobar.1 foobar.5)
          (if (if (true)
                  (let ([ball.0 foobar.2]) (> -1497437069 -9223372036854775808))
                  (not (!= -1101838227 -1416967818)))
              (let ([ball.8 (+ foobar.2 foobar.2)]) (let ([foobar.1 0]) foobar.1))
              1)))
      (define fn.7
        (lambda ()
          (if (true)
              (if (not (> 0 100011461))
                  (call x.5 -9223372036854775808 16140507 0 -1248542300 0 -1579752260)
                  (if (= -9223372036854775808 471889533) 1 0))
              (if (if (>= 1 0)
                      (>= 0 -9223372036854775808)
                      (> 9223372036854775807 0))
                  (call fn.7)
                  (if (> 1 1) -444155079 9223372036854775807)))))
      (if (let ([foo.6
                 (if (let ([foobar.2 -9223372036854775808]) (true))
                     (let ([foobar.2 (if (> 9223372036854775807 0) -1444900091 -9223372036854775808)])
                       foobar.2)
                     (if (true)
                         (let ([foobar.5 9223372036854775807]) foobar.5)
                         (if (= -9223372036854775808 1173781558) 0 1)))])
            (if (true)
                (let ([bar.9 0]) (true))
                (< 858519747 foo.6)))
          1
          (if (< 1 -1323259230)
              (call fn.2)
              (call fn.2)))))

  (check-by-interp
   '(module (define fn.0
              (lambda (foobar.5 foo.4 bat.9 bar.1 foobar.6)
                (if (>= -9223372036854775808 bar.1)
                    1
                    (if (true)
                        (let ([ball.0 bat.9]) 272878342)
                        (let ([bat.9 foo.4]) 1621698237)))))
            (define x.1
              (lambda ()
                (let ([bar.1 (if (if (< -9223372036854775808 -9223372036854775808)
                                     (!= 1373678353 9223372036854775807)
                                     (= -9223372036854775808 9223372036854775807))
                                 9223372036854775807
                                 1)])
                  (let ([bar.8 bar.1]) (if (<= bar.8 1832962769) -1179877563 bar.8)))))
      (define tmp.2 (lambda (foobar.7 foobar.6 bat.9 foobar.5 ball.2 bar.1) (+ 1614414513 0)))
      (define tmp.3
        (lambda (bar.8 foobar.3 ball.2 foobar.7 foobar.5)
          (let ([ball.2 (if (let ([bar.8 0]) (<= ball.2 foobar.5))
                            foobar.5
                            (* -9223372036854775808 2143760394))])
            (let ([ball.2 (let ([foobar.3 1560147081]) ball.2)])
              (let ([foo.4 0]) -9223372036854775808)))))
      (define func.4
        (lambda (foobar.5 ball.0 bar.8 bat.9 foobar.3 foobar.6)
          (let ([bar.1 (let ([foobar.6 (* 0 0)]) (* ball.0 672300375))]) (+ 599851097 ball.0))))
      (define fn.5
        (lambda (foo.4)
          (if (>= 9223372036854775807 532145951)
              (if (let ([bar.1 9223372036854775807]) (< foo.4 -9223372036854775808))
                  (let ([ball.0 0]) ball.0)
                  (if (!= foo.4 0) 0 940835989))
              (call tmp.3 foo.4 0 1817052000 -9223372036854775808 872683016))))
      (let ([bat.9 (let ([ball.2 (* -9223372036854775808 -1620764170)])
                     (+ 1515105242 9223372036854775807))])
        (let ([ball.0 bat.9])
          (if (false)
              (if (!= ball.0 -98359895) ball.0 -1192498197)
              (let ([bar.8 bat.9]) ball.0))))))
  (check-by-interp
   '(module (define fn.0
              (lambda (ball.4 foobar.1 foobar.6 bar.7 ball.5 foo.8 ball.9)
                (let ([ball.5 (if (= -99505426 ball.4)
                                  (let ([ball.4 1]) (+ bar.7 foobar.6))
                                  (* 1 foobar.6))])
                  (if (if (if (not (let ([bat.3 foo.8]) (<= 0 1)))
                              (let ([foo.8 (* 0 foo.8)])
                                (let ([foobar.0 429372017]) (>= -2010637217 bar.7)))
                              (false))
                          (true)
                          (not (false)))
                      1
                      foobar.6))))
            (define tmp.1 (lambda (foobar.6) (call tmp.1 foobar.6)))
      (define tmp.2
        (lambda (foobar.1 foobar.0 foobar.6)
          (call func.3 foobar.0 foobar.0 foobar.1 foobar.6 foobar.1 foobar.1 0)))
      (define func.3
        (lambda (foobar.1 foobar.0 ball.5 foo.2 foo.8 ball.4 bat.3)
          (if (let ([foobar.0 (let ([foo.8 (if (if (>= 0 foobar.0)
                                                   (true)
                                                   (if (<= 1 1856622568)
                                                       (>= bat.3 bat.3)
                                                       (= ball.5 -9223372036854775808)))
                                               1037087964
                                               (if (let ([bat.3 -1794855172]) (< -355327964 ball.5))
                                                   foo.2
                                                   (let ([foo.8 695562651]) 0)))])
                                (if (false)
                                    (+ ball.4 9223372036854775807)
                                    (if (true)
                                        (+ -9223372036854775808 foobar.0)
                                        foobar.1)))])
                (false))
              (+ bat.3 foobar.1)
              (let ([bat.3 foo.2])
                (if (false)
                    (+ 218056169 ball.5)
                    (let ([bat.3 (* 939433463 9223372036854775807)])
                      (let ([bat.3 (+ ball.5 bat.3)]) -9223372036854775808)))))))
      (define fn.4
        (lambda ()
          (if (not (true))
              (let ([bat.3 (if (not (false))
                               -9223372036854775808
                               (if (true)
                                   -582767426
                                   (if (false)
                                       (* 0 -9223372036854775808)
                                       0)))])
                bat.3)
              (+ -924459426 0))))
      (define tmp.5 (lambda (ball.4 foo.8 bar.7 foobar.0 foobar.6 ball.5 bat.3) 9223372036854775807))
      (if (true)
          (+ 1 95298529)
          0)))

  (check-by-interp
   '(module (define x.0
              (lambda ()
                (let ([ball.0 (let ([ball.0 (let ([foobar.6 -1510419750])
                                              (let ([ball.0 (if (false)
                                                                1880825961
                                                                (let ([foo.2 41183491]) foo.2))])
                                                (+ 1 ball.0)))])
                                (let ([ball.9 (if (false)
                                                  (if (not (>= 1 1964968205))
                                                      (if (>= ball.0 ball.0) -1473992388 0)
                                                      (* 1 ball.0))
                                                  (if (true)
                                                      (let ([foo.2 0]) 9223372036854775807)
                                                      (let ([foo.3 9223372036854775807])
                                                        -9223372036854775808)))])
                                  (let ([foo.2 (let ([foobar.6 (if (!= ball.9 ball.9) -1054245420 1)])
                                                 (let ([ball.0 ball.9]) ball.0))])
                                    -399220545)))])
                  (+ ball.0 ball.0))))
            (define fn.1 (lambda (foo.1) (+ foo.1 1)))
      (define proc.2 (lambda (foo.2 ball.0 ball.7) (call fn.5 ball.0 foo.2 foo.2 0)))
      (define x.3
        (lambda (foo.2 ball.7 ball.9)
          (if (> ball.7 ball.9)
              (let ([foo.3 (let ([foo.3 ball.9]) (let ([foo.8 ball.7]) (* 1 ball.9)))])
                (* foo.3 foo.2))
              (if (if (false)
                      (let ([ball.0 -9223372036854775808])
                        (if (if (< foo.2 9223372036854775807)
                                (< ball.7 ball.7)
                                (<= foo.2 884043998))
                            (false)
                            (not (<= ball.7 1))))
                      (true))
                  foo.2
                  (+ ball.9 foo.2)))))
      (define x.4 (lambda (foo.2 foo.1) (call proc.2 -672138667 foo.1 foo.1)))
      (define fn.5 (lambda (ball.4 foobar.6 ball.0 foo.1) (+ foobar.6 0)))
      (let ([foo.1 -9223372036854775808]) (call x.4 foo.1 foo.1))))

  (check-by-interp
   '(module (define x.0
              (lambda (ball.5 foobar.2 foo.3 ball.4 bat.1)
                (call fn.1 -9223372036854775808 9223372036854775807 1 ball.5 ball.4 ball.4)))
            (define fn.1 (lambda (ball.9 bat.1 foo.7 foo.3 ball.5 foo.0) foo.0))
      (define tmp.2
        (lambda (ball.4 foo.3 bar.6)
          (let ([foobar.2 (* ball.4 9223372036854775807)]) (+ foo.3 767883438))))
      (define func.3
        (lambda (ball.9 bar.8 foo.3 bat.1) (call tmp.2 164105141 foo.3 -9223372036854775808)))
      (define fn.4 (lambda (foo.7 ball.9 foo.3 bar.6) (+ 518721108 0)))
      (define tmp.5
        (lambda (ball.9 foo.3 ball.5 bar.8 ball.4 foo.0)
          (let ([foo.3 (let ([ball.4 (if (let ([ball.9 (if (not (<= ball.9 71239012))
                                                           1
                                                           (if (<= 0 9223372036854775807)
                                                               foo.3
                                                               -1037460705))])
                                           (false))
                                         (if (not (if (<= ball.5 885580486)
                                                      (< bar.8 ball.9)
                                                      (> 0 ball.4)))
                                             (if (if (!= 0 ball.5)
                                                     (< ball.9 ball.5)
                                                     (!= bar.8 foo.3))
                                                 bar.8
                                                 bar.8)
                                             (+ 1 0))
                                         0)])
                         (let ([bar.8 (let ([ball.9 (if (<= 1 ball.4)
                                                        (if (= bar.8 foo.0) ball.4 0)
                                                        (if (<= foo.0 foo.3) ball.9 1))])
                                        9223372036854775807)])
                           (+ 1 9223372036854775807)))])
            (let ([foo.3 1917454727])
              (if (not (< 1229284432 9223372036854775807))
                  foo.3
                  (+ 1274698633 foo.0))))))
      (define fn.6
        (lambda (foobar.2 bar.6 foo.7) (let ([foobar.2 (* -9223372036854775808 bar.6)]) 690826547)))
      (let ([bar.6 (if (if (true)
                           (not (true))
                           (true))
                       (* 1791882774 0)
                       0)])
        (if (false)
            (if (true)
                (let ([ball.4 (* bar.6 1)])
                  (let ([bat.1 (let ([foo.3 (* bar.6 -9223372036854775808)])
                                 (+ bar.6 -9223372036854775808))])
                    (call x.0 0 1 -9223372036854775808 1 44798641)))
                (if (let ([bar.8 (if (= bar.6 bar.6)
                                     (+ 1 bar.6)
                                     0)])
                      (if (let ([foo.0 -335382762]) (>= foo.0 198878680))
                          (< 9223372036854775807 bar.8)
                          (false)))
                    (let ([foobar.2 (if (let ([ball.5 1]) (= 0 9223372036854775807))
                                        (if (= 1 355925562) 1 9223372036854775807)
                                        (let ([bar.8 0]) 1))])
                      (call x.0 foobar.2 bar.6 foobar.2 9223372036854775807 bar.6))
                    (if (false)
                        (if (not (= bar.6 1505519823))
                            (call fn.6 bar.6 bar.6 -1389936468)
                            0)
                        (call fn.6 -1026710181 bar.6 0))))
            (let ([ball.9 (if (false)
                              (if (let ([bar.6 (let ([foobar.2 1572624047]) foobar.2)])
                                    (not (<= -728694911 -403064853)))
                                  (if (if (>= bar.6 bar.6)
                                          (>= bar.6 bar.6)
                                          (>= bar.6 1))
                                      (* bar.6 -1072326562)
                                      (+ bar.6 -9223372036854775808))
                                  bar.6)
                              (if (true)
                                  (let ([bar.8 (if (>= 9223372036854775807 bar.6) bar.6 bar.6)])
                                    (let ([foo.7 bar.8]) -9223372036854775808))
                                  (if (if (< -9223372036854775808 bar.6)
                                          (<= bar.6 bar.6)
                                          (< 107040658 bar.6))
                                      (* bar.6 1)
                                      0)))])
              (let ([foo.0 (let ([foo.3 (if (!= 0 1)
                                            (let ([ball.5 ball.9]) -9223372036854775808)
                                            (let ([foo.7 bar.6]) bar.6))])
                             foo.3)])
                (call fn.6 -704490852 ball.9 9223372036854775807)))))))

  (check-by-interp
   '(module (define L.tmp.0.1
              (lambda ()
                (if (>= 9223372036854775807 -1020514810)
                    (call L.x.2.3)
                    (* 1 0))))
            (define L.func.1.2
              (lambda ()
                (let ([bar.1.1 -9223372036854775808])
                  (if (not (> 9223372036854775807 0)) 1309557052 bar.1.1))))
      (define L.x.2.3
        (lambda ()
          (if (if (true)
                  (not (> 0 1))
                  (true))
              (if (> 0 0)
                  (if (< 9223372036854775807 9223372036854775807) 9223372036854775807 -260353756)
                  (let ([ball.0.2 0]) ball.0.2))
              (let ([bar.3.3 (if (!= -302047143 0) 9223372036854775807 102036653)])
                (if (= 0 bar.3.3) bar.3.3 -362331747)))))
      (let ([ball.0.4 (* -9223372036854775808 -9223372036854775808)]) (+ ball.0.4 0))))

  (check-by-interp '(module (define L.proc.0.1 (lambda (ball.6.1) (call L.func.1.2)))
                            (define L.func.1.2 (lambda () (* 1 0)))
                      (define L.fn.2.3
                        (lambda (ball.3.2)
                          (if (true)
                              (let ([bat.0.3 (if (<= -2033705372 965540822) -1853172774 1133506028)])
                                (let ([foo.4.4 1]) 1236904416))
                              (call L.func.1.2))))
                      (call L.proc.0.1 1)))
  (check-by-interp '(module (define fn.0
                              (lambda ()
                                (let ([bat.9 (if (false)
                                                 1
                                                 (let ([foo.5 1]) 1))])
                                  (if (if (>= 9223372036854775807 -9223372036854775808)
                                          (= -248968641 9223372036854775807)
                                          (!= bat.9 -9223372036854775808))
                                      (let ([ball.4 bat.9]) 1622965009)
                                      (let ([foo.5 bat.9]) bat.9)))))
                            (if (false)
                                (if (>= 995853130 1) 1 -9223372036854775808)
                                (call fn.0))
                      ))
  (check-by-interp '(module (+ -9223372036854775808 -1465538260)))
  (check-by-interp '(module (define fn.0
                              (lambda ()
                                (let ([bar.2 (+ 1 9223372036854775807)])
                                  (let ([foo.8 (let ([foo.1 bar.2]) foo.1)]) bar.2))))
                            (define func.1
                              (lambda ()
                                (let ([ball.3 (if (let ([foo.8 1]) (< 1 foo.8))
                                                  (let ([foo.1 406779451]) 1200977699)
                                                  (let ([foo.8 0]) foo.8))])
                                  (* ball.3 ball.3))))
                      (let ([bat.5 1]) (let ([ball.9 0]) bat.5))))
  (check-by-interp
   '(module (define x.0 (lambda (ball.1 foo.0) (call tmp.1)))
            (define tmp.1
              (lambda ()
                (if (if (if (<= -765445006 0)
                            (!= 0 -7399083)
                            (<= 9223372036854775807 1))
                        (false)
                        (true))
                    (let ([ball.4 (let ([bar.5 -9223372036854775808]) bar.5)])
                      (if (> ball.4 ball.4) -9223372036854775808 ball.4))
                    (let ([foobar.9 (if (>= 1 0) -9223372036854775808 -9223372036854775808)])
                      (if (= 0 foobar.9) 0 9223372036854775807)))))
      (define func.2 (lambda (ball.4 ball.6) (call tmp.1)))
      (if (<= 0 1) -1271132888 2101306416)))
  (check-by-interp '(module (define proc.0
                              (lambda (bar.8)
                                (let ([bat.7 (if (false)
                                                 (let ([bat.4 bar.8]) 1733388107)
                                                 (let ([foobar.2 -818241658]) foobar.2))])
                                  (let ([bat.3 (* -1769976594 bat.7)])
                                    (if (!= bar.8 bar.8) 1 bar.8)))))
                            (if (<= 0 0) 1764584349 -9223372036854775808)
                      ))
  (check-by-interp '(module (define proc.0
                              (lambda (ball.3)
                                (if (not (false))
                                    (call x.1)
                                    (let ([foobar.4 (let ([bat.9 ball.3]) 9223372036854775807)])
                                      (+ -9223372036854775808 ball.3)))))
                            (define x.1 (lambda () 1))
                      (let ([foobar.4 (let ([ball.1 453798193]) ball.1)])
                        (if (>= 9223372036854775807 foobar.4) 0 -1617493587))))
  (check-by-interp '(module (define func.0
                              (lambda (bat.8)
                                (if (let ([bat.2 (* 9223372036854775807 bat.8)]) (true))
                                    (if (true)
                                        (if (< bat.8 -9223372036854775808) bat.8 bat.8)
                                        (if (= -9223372036854775808 bat.8) bat.8 bat.8))
                                    (call proc.1))))
                            (define proc.1 (lambda () (call func.0 954069433)))
                      (if (false)
                          (* 1337690701 9223372036854775807)
                          (call proc.1))))
  (check-by-interp '(module (if (not (> 1 9223372036854775807))
                                (if (>= 1 1197468889) 9223372036854775807 1)
                                1)))
  (check-by-interp '(module (define func.0 (lambda (foo.9 foo.2 bar.1 bat.7 foobar.4) -1458025903))
                            (call func.0 -9223372036854775808 1 -808937821 -9223372036854775808 0)
                      ))
  (check-by-interp '(module (define tmp.0
                              (lambda (ball.6 bat.5 bar.8 foobar.0)
                                (let ([bat.2 ball.6])
                                  (if (if (<= -9223372036854775808 bat.5)
                                          (>= -9223372036854775808 ball.6)
                                          (>= bat.5 2025307007))
                                      (+ bat.2 9223372036854775807)
                                      (if (<= bat.5 -9223372036854775808) 9223372036854775807 0)))))
                            (let ([ball.6 0]) ball.6)
                      ))
  (check-by-interp
   '(module (define func.0
              (lambda (ball.6 foobar.3)
                (if (= 0 foobar.3)
                    (+ -9223372036854775808 -9223372036854775808)
                    (if (if (< ball.6 ball.6)
                            (<= foobar.3 foobar.3)
                            (= foobar.3 ball.6))
                        (+ foobar.3 foobar.3)
                        (if (= 1 foobar.3) ball.6 foobar.3)))))
            (define x.1
              (lambda (bar.0)
                (let ([ball.1 (let ([bat.9 (let ([bat.2 1757280127]) bat.2)])
                                (let ([ball.5 1]) -1128483887))])
                  (if (let ([foo.7 bar.0]) (> foo.7 foo.7))
                      ball.1
                      (+ ball.1 bar.0)))))
      (define fn.2
        (lambda ()
          (if (let ([foobar.8 (+ -9223372036854775808 -1421853645)]) (not (>= 0 -1400373009)))
              (+ -167927521 1)
              (let ([ball.1 (* 1041085683 9223372036854775807)]) (let ([foo.4 ball.1]) 770292232)))))
      (call x.1 1840464414)))
  (check-by-interp
   '(module (define proc.0
              (lambda (ball.4 foo.7 ball.2) (call proc.0 9223372036854775807 ball.2 foo.7)))
            (define func.1
              (lambda (ball.1 bat.0 foo.7 ball.4 foobar.6 bar.3)
                (let ([bar.3 (let ([ball.4 foo.7]) (let ([foobar.5 ball.1]) -9223372036854775808))])
                  (call proc.0 bar.3 -780648786 bar.3))))
      (let ([bat.0 -579691794]) 953357957)))
  (check-by-interp '(module (let ([bar.5 (let ([ball.2 9223372036854775807]) -546026276)])
                              (if (!= bar.5 1) 9223372036854775807 2063023986))))
  (check-by-interp '(module (define func.0
                              (lambda (foo.8 bar.2)
                                (if (not (let ([foo.8 foo.8]) (= foo.8 0)))
                                    (let ([foobar.6 (+ foo.8 0)]) (* 0 9223372036854775807))
                                    (let ([bat.7 (* 0 bar.2)])
                                      (if (!= bat.7 -9223372036854775808) bar.2 0)))))
                            (if (= 9223372036854775807 -315897602) 1 -9223372036854775808)
                      ))
  (check-by-interp
   '(module (define fn.0
              (lambda (foobar.3 ball.7)
                (let ([bar.9 (let ([bat.4 (* 1 9223372036854775807)])
                               (+ -9223372036854775808 bat.4))])
                  (let ([bat.4 9223372036854775807]) (if (!= 1 bar.9) 9223372036854775807 ball.7)))))
            (define x.1
              (lambda (bat.2)
                (let ([foobar.3 (let ([bat.4 (+ -1410706204 bat.2)])
                                  (let ([bat.2 1]) -9223372036854775808))])
                  (* -152436426 0))))
      (define proc.2 (lambda (foo.5 ball.7 foo.0 ball.8) (let ([foobar.1 foo.5]) (+ 956544411 1))))
      (+ 979460199 -1697959716)))
  (check-by-interp
   '(module (define proc.0
              (lambda (foobar.1 bar.0 foobar.2 ball.8 bat.3 bar.5)
                (let ([bar.9 (if (let ([bar.7 -669410514]) (< bat.3 bat.3))
                                 (+ bar.5 ball.8)
                                 foobar.2)])
                  (let ([ball.6 (let ([foo.4 ball.8]) 1)])
                    (if (<= foobar.2 1) 9223372036854775807 bat.3)))))
            (call proc.0 0 9223372036854775807 0 -1371550930 -1891086346 9223372036854775807)
      ))
  (check-by-interp '(module (define x.0
                              (lambda (bat.7 ball.9 foobar.3 ball.5 ball.4 bar.0 ball.2)
                                (if (not (if (>= 388494724 ball.9)
                                             (> ball.5 -9223372036854775808)
                                             (< foobar.3 ball.5)))
                                    (if (<= ball.4 bar.0)
                                        0
                                        (let ([ball.4 ball.5]) 1887946265))
                                    foobar.3)))
                            (define tmp.1
                              (lambda (bat.7 ball.9 ball.5 foo.6 bar.0 ball.2)
                                (if (true)
                                    (* foo.6 9223372036854775807)
                                    (if (let ([foobar.3 1]) (<= bar.0 ball.5))
                                        (let ([ball.9 -9223372036854775808]) ball.9)
                                        (let ([bat.7 1]) 1)))))
                      (define tmp.2
                        (lambda (bat.7 ball.2 foo.6 foobar.3 bar.8 bar.0)
                          (let ([foobar.3 (if (let ([ball.2 258314756]) (!= bar.8 0))
                                              bar.8
                                              (let ([foo.6 -1809848824]) 9223372036854775807))])
                            (if (< 1525021420 1)
                                (call tmp.1 foobar.3 1 -1256996529 foo.6 -768559462 1067478227)
                                (if (> 389818959 882297114) bar.8 ball.2)))))
                      (let ([bar.0 1]) 1)))
  (check-by-interp
   '(module (define tmp.0 (lambda (foo.1 ball.6 bar.9 bat.3 ball.8 bat.0 ball.7) (* bat.3 bat.0)))
            (define func.1
              (lambda (foo.1 bar.2 foo.5 bat.3 bar.9) (let ([bat.3 1]) 9223372036854775807)))
      (define fn.2
        (lambda (ball.7 ball.8)
          (let ([bat.3 (if (>= ball.7 1)
                           (if (= ball.7 ball.7) ball.8 214741259)
                           (+ 1683358713 ball.8))])
            (call tmp.0 bat.3 ball.8 0 ball.7 9223372036854775807 ball.7 -2043460455))))
      (call tmp.0
            -9223372036854775808
            -9223372036854775808
            -9223372036854775808
            9223372036854775807
            -9223372036854775808
            1
            -9223372036854775808)))
  (check-by-interp '(module (if (true)
                                (+ 1 -9223372036854775808)
                                (if (> 1383245321 0) 0 1))))
  (check-by-interp
   '(module (define x.0 (lambda (ball.0 foobar.1 foo.3 foobar.2 foo.6 foobar.5 ball.8) (call x.4 1)))
            (define func.1
              (lambda ()
                (let ([bar.9 9223372036854775807])
                  (let ([foobar.1 bar.9]) (if (>= -577997854 foobar.1) -9223372036854775808 bar.9)))))
      (define fn.2
        (lambda ()
          (let ([ball.7 (+ 1 1)])
            (if (false)
                ball.7
                (let ([foobar.1 ball.7]) 1969054361)))))
      (define x.3
        (lambda (foobar.4 foobar.5 bar.9 foobar.2 ball.8 foo.3 ball.7)
          (call func.6
                0
                -9223372036854775808
                9223372036854775807
                25911444
                9223372036854775807
                foobar.4
                -9223372036854775808)))
      (define x.4 (lambda (foobar.4) (call x.3 0 foobar.4 foobar.4 1 foobar.4 foobar.4 foobar.4)))
      (define x.5
        (lambda (foo.6 foo.3 foobar.4 bar.9 foobar.1 foobar.5)
          (let ([foobar.5 (let ([foobar.1 bar.9]) (let ([foo.6 foo.3]) foobar.1))])
            (if (let ([ball.8 bar.9]) (> foo.3 foo.6))
                (call x.0
                      -1863740769
                      9223372036854775807
                      foobar.4
                      foobar.5
                      foo.3
                      foobar.5
                      -1819248150)
                1))))
      (define func.6
        (lambda (foobar.2 foo.6 ball.0 ball.8 foo.3 foobar.1 foobar.5)
          (if (if (true)
                  (let ([ball.0 foobar.2]) (> -1497437069 -9223372036854775808))
                  (not (!= -1101838227 -1416967818)))
              (let ([ball.8 (+ foobar.2 foobar.2)]) (let ([foobar.1 0]) foobar.1))
              1)))
      (define fn.7
        (lambda ()
          (if (true)
              (if (not (> 0 100011461))
                  (call x.5 -9223372036854775808 16140507 0 -1248542300 0 -1579752260)
                  (if (= -9223372036854775808 471889533) 1 0))
              (if (if (>= 1 0)
                      (>= 0 -9223372036854775808)
                      (> 9223372036854775807 0))
                  (call fn.7)
                  (if (> 1 1) -444155079 9223372036854775807)))))
      (if (let ([foo.6
                 (if (let ([foobar.2 -9223372036854775808]) (true))
                     (let ([foobar.2 (if (> 9223372036854775807 0) -1444900091 -9223372036854775808)])
                       foobar.2)
                     (if (true)
                         (let ([foobar.5 9223372036854775807]) foobar.5)
                         (if (= -9223372036854775808 1173781558) 0 1)))])
            (if (true)
                (let ([bar.9 0]) (true))
                (< 858519747 foo.6)))
          1
          (if (< 1 -1323259230)
              (call fn.2)
              (call fn.2))))))
; (module+ test
;   (require rackunit)
;   ; example outputs for uniquify
;   (check-equal? (uniquify '(module (+ 2 2))) '(module (+ 2 2)))
;   (check-match (uniquify '(module (let ([x 5]) x))) `(module (let ([,x 5]) ,x)) (aloc? x))
;   (check-match (uniquify '(module (let ([x (+ 2 2)]) x))) `(module (let ([,x (+ 2 2)]) ,x)) (aloc? x))
;   (check-match (uniquify '(module (let ([x 2]) (let ([y 2]) (+ x y)))))
;                `(module (let ([,x.5 2]) (let ([,y.6 2]) (+ ,x.5 ,y.6))))
;                (andmap aloc? `(,x.5 ,y.6)))
;   (check-match (uniquify '(module (let ([x 2]) (let ([x 2]) (+ x x)))))
;                `(module (let ([,x.7 2]) (let ([,x.8 2]) (+ ,x.8 ,x.8))))
;                (andmap aloc? `(,x.7 ,x.8)))
;   (check-equal? (uniquify '(module 1)) `(module 1))
;   (check-exn exn:fail? (λ () (uniquify '(module x))))
;   (check-match (uniquify '(module (let ([x 5]) 1))) `(module (let ([,x 5]) 1)) (aloc? x))
;   (check-match (uniquify '(module (let ([y 2]
;                                         [x 3])
;                                     (+ x x))))
;                `(module (let ([,x.7 2]
;                               [,x.8 3])
;                           (+ ,x.8 ,x.8)))
;                (andmap aloc? `(,x.7 ,x.8)))
;   (check-match (uniquify '(module (let ([x 2]
;                                         [y 3])
;                                     (let ([y (+ y y)]
;                                           [x 3])
;                                       (+ x x)))))
;                `(module (let ([,x.7 2]
;                               [,x.8 3])
;                           (let ([,x.9 (+ ,x.8 ,x.8)]
;                                 [,x.10 3])
;                             (+ ,x.10 ,x.10))))
;                (andmap aloc? `(,x.7 ,x.8 ,x.9 ,x.10)))
;   (check-match (uniquify '(module (let ([y (let ([x 1]) x)]
;                                         [x 3])
;                                     (let ([y (+ x x)]
;                                           [x 3])
;                                       (+ x x)))))
;                `(module (let ([,x.7 (let ([,x.1 1]) ,x.1)]
;                               [,x.8 3])
;                           (let ([,x.9 (+ ,x.8 ,x.8)]
;                                 [,x.10 3])
;                             (+ ,x.10 ,x.10))))
;                (andmap aloc? `(,x.1 ,x.7 ,x.8 ,x.9 ,x.10)))
;   (check-exn exn:fail?
;              (λ ()
;                (uniquify '(module (let ([t (let ([x 1]) x)]
;                                         [x x])
;                                     (let ([x (+ x x)]
;                                           [x 3])
;                                       (+ x x)))))))
;   (check-match (uniquify '(module (let ([y 2]
;                                         [x 3])
;                                     (if (true)
;                                         (let ([z 3]) z)
;                                         (let ([z 3]) z)))))
;                `(module (let ([,y.2 2]
;                               [,x.1 3])
;                           (if (true)
;                               (let ([,z.3 3]) ,z.3)
;                               (let ([,z.4 3]) ,z.4))))
;                (andmap aloc? `(,x.1 ,y.2 ,z.3 ,z.4))))
