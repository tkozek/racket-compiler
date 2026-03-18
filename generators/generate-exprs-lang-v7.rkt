#lang racket

(require cpsc411/compiler-lib
         cpsc411/2c-run-time
         cpsc411/langs/v7
         cpsc411/test-suite/utils
         cpsc411/test-suite/public/v7)

(define (generate-values-lang-v7)
  (define unassigned-proc-names '())
  (define proc-names '())
  (define triv-names '())
  ;; maps procedure name to how many arguments it takes
  (define proc-arities (make-hash))

  ;; (listof x) -> x
  ;; chooses a random x from xs
  (define (choose . xs)
    (list-ref xs (random (length xs))))

  ;; (listof x) -> x
  ;; chooses a random x from xs
  (define (choose-from-list xs)
    (list-ref xs (random (length xs))))

  ;; () -> symbol
  ;; gets a random name for a triv
  (define (get-random-triv-name)
    (choose-from-list triv-names))

  ;; (natural) -> ()
  ;; ahead of time generator for names to be used in triv context throughout the program
  (define (generate-triv-names num-names)
    (define bases '("bar" "foo" "bat" "foobar" "ball"))
    (define names
      (for/list ([i (in-range num-names)])
        (string->symbol (format "~a.~a"
                                (list-ref bases (random (length bases)))
                                i)))) ;; random base, then i makes it unique.
    (set! triv-names names)
    names)

  ;; () -> symbol
  ;; gets a random procedure name, such as to be used in call context
  ;; this procedure name may be reused in such context multiple times
  (define (get-random-proc-name)
    (choose-from-list (hash-keys proc-arities)))

  ;; () -> symbol
  ;; assigns a procedure name to follow a 'define', removes it from procedure names that are available
  ;; to be assigned (values-lang doesn't allow repeated declarations of procedures)
  (define (assign-proc-name)
    (define assigned-proc-name (first unassigned-proc-names))
    (set! unassigned-proc-names (rest unassigned-proc-names))
    assigned-proc-name)

  ;; (natural) -> ()
  ;; ahead of time generator for proc names to be used throughout the program
  (define (generate-proc-names num-names)
    (define bases '("tmp" "proc" "x" "fn" "func"))
    (define names

      (for/list ([i (in-range num-names)])
        (string->symbol (format "~a.~a"
                                (list-ref bases (random (length bases)))
                                i)))) ;; random base, then i makes it unique.
    (set! unassigned-proc-names names)
    (set! proc-names names)
    ;; set the number of arguments ahead of time, to enable calls to procedures that are defined
    ;; after the calling procedure
    (for ([name names])
      (hash-set! proc-arities name (random 8)))
    names)

  (define (generate-let depth env body-func)
    (define xs
      (take (shuffle (append triv-names env))
            (if (zero? (random 2))
                (random 1 4)
                (random 4))))
    (define bindings
      (for/list ([x xs])
        `[,x ,(generate-value (sub1 depth) env)]))
    `(let ,bindings ,(body-func (sub1 depth) (remove-duplicates (append xs env)))))

  ;; () -> uint8
  (define (generate-uint8)
    (case (random 4)
      [(0) 0]
      [(1) 1]
      [(2) (max-int 8)]
      [(3) (random (max-int 8))]))

  ;; () -> int61
  ;; pseudorandomly generates an int61, with additional weight towards edge cases (0, 1, minint, maxint)
  (define (generate-int61)
    (case (random 6)
      [(0) 0]
      [(1) 1]
      [(2) (min-int 61)]
      [(3) (max-int 61)]
      [(4) (random (max-int 32))]
      [(5) (- 0 (random (sub1 (max-int 32))))]))

  ;; () -> (values-lang-v7 binop)
  ;; randomly selects a binop
  (define (generate-binop)
    (choose-from-list '(+ * - eq? < <= > >=)))

  ;; (natural (listof symbol)) -> (listof (symbol | int61))
  (define (generate-trivs n env)
    (for/list ([_ (in-range n)])
      (generate-triv env)))

  (define (generate-value depth env)
    (if (zero? depth)
        (generate-triv env)
        (case (random 6)
          [(0) (generate-triv env)]
          [(1) `(,(generate-binop) ,(generate-triv env) ,(generate-triv env))]
          [(2) (generate-let depth env generate-value)]
          [(3)
           `(if ,(generate-pred (sub1 depth) env)
                ,(generate-value (sub1 depth) env)
                ,(generate-value (sub1 depth) env))]
          [(4 5)
           ;; check if any procedure is defined, retry if no procedure is defined
           (if (null? proc-names)
               (generate-value depth env)
               (let* ([fname (get-random-proc-name)]
                      [arity (hash-ref proc-arities fname)])
                 `(call ,fname ,@(generate-trivs arity env))))])))

  (define (generate-ascii-char-literal)
    (integer->char (random 256)))

  (define (generate-unop)
    (choose-from-list '(fixnum? boolean? empty? eq? void? ascii-char? error? not)))

  (define (generate-prim-f)
    (case (random 1)
      [(0) (generate-binop)]
      [(1) (generate-unop)]))

  (define (generate-x env)
    (if (empty? env)
        (generate-prim-f)
        (case (random 1)
          [(0) (generate-name)]
          [(1) (generate-prim-f)])))

  (define (generate-triv env)
    (case (random 8)
      [(0) (generate-x)]
      [(1) (generate-int61)]
      [(2) #t]
      [(3) #f]
      [(4) empty]
      [(5) (void)]
      [(6) `(error ,(generate-uint8))]
      [(7) (generate-ascii-char-literal)]))

  (define (generate-define depth)
    (let* ([proc (assign-proc-name)]
           [num-params (hash-ref proc-arities proc)]
           ;; take first num-params from shuffled copy of triv-names
           [params (take (shuffle triv-names) num-params)])
      `(define ,proc (lambda ,params ,(generate-tail depth params)))))

  (define (generate-program)
    (define num-defs (random 4))
    (generate-proc-names num-defs)
    (generate-triv-names 10)
    (define defs
      (for/list ([_ (in-range num-defs)])
        (let ([def (generate-define 3)]) def)))

    `(module ,@defs ,(generate-value (random 1 5) '())
       ))

  (generate-program))

(define (runs-within-time? p)
  (define ch (make-channel))

  (define thr
    (thread (lambda ()
              (channel-put ch
                           (with-handlers ([exn:fail? (lambda (e) 'error)])
                             (interp-values-lang-7 p))))))

  (define result (sync/timeout 3 ch))

  (cond
    [(not result) ; timeout
     (kill-thread thr)
     #f]
    [(eq? result 'error) #f]
    [else #t]))

; (define success 0)
(for ([i (in-range 100)])

  (define p (generate-values-lang-v7))
  ; (pretty-display (format "Iteration number: ~a" (add1 i)))
  (when (runs-within-time? p)
    (pretty-display (format "'~a" p))
    (pretty-display "#%")
    ; (set! success (add1 success))
    ; (newline)
    ; (pretty-display (format "Sucesss number: ~a" success))
    ))
