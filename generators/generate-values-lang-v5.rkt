#lang racket

(require cpsc411/compiler-lib
         cpsc411/2c-run-time
         cpsc411/langs/v5
         cpsc411/test-suite/utils
         cpsc411/test-suite/public/v5)

(define (generate-values-lang-v5)

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

  ;; () -> int64
  ;; pseudorandomly generates an int64, with additional weight towards edge cases (0, 1, minint, maxint)
  (define (generate-int64)
    (case (random 6)
      [(0) 0]
      [(1) 1]
      [(2) (min-int 64)]
      [(3) (max-int 64)]
      [(4) (random (max-int 32))]
      [(5) (- 0 (random (sub1 (max-int 32))))]))

  ;; () -> (values-lang relop)
  ;; randomly selects a relop
  (define (generate-relop)
    (choose-from-list '(< <= = >= > !=)))

  ;; () -> (values-lang binop)
  ;; randomly selects a binop
  (define (generate-binop)
    (choose-from-list '(+ *)))

  ;; (listof symbol) -> symbol | int64
  (define (generate-triv env)
    (if (and (not (null? env)) (zero? (random 2)))
        (choose-from-list env)
        (generate-int64)))

  ;; (natural (listof symbol)) -> (listof (symbol | int64))
  (define (generate-trivs n env)
    (for/list ([_ (in-range n)])
      (generate-triv env)))

  (define (generate-pred depth env)
    (if (zero? depth)
        `(,(generate-relop) ,(generate-triv env) ,(generate-triv env))
        (case (random 6)
          [(0) `(,(generate-relop) ,(generate-triv env) ,(generate-triv env))]
          [(1) '(true)]
          [(2) '(false)]
          [(3) `(not ,(generate-pred (sub1 depth) env))]
          [(4) (generate-let depth env generate-pred)]
          [(5)
           `(if ,(generate-pred (sub1 depth) env)
                ,(generate-pred (sub1 depth) env)
                ,(generate-pred (sub1 depth) env))])))

  (define (generate-value depth env)
    (if (zero? depth)
        (generate-triv env)
        (case (random 4)
          [(0) (generate-triv env)]
          [(1) `(,(generate-binop) ,(generate-triv env) ,(generate-triv env))]
          [(2) (generate-let depth env generate-value)]
          [(3)
           `(if ,(generate-pred (sub1 depth) env)
                ,(generate-value (sub1 depth) env)
                ,(generate-value (sub1 depth) env))])))

  (define (generate-tail depth env)
    (if (zero? depth)
        (generate-value 0 env)
        (case (random 4)
          [(0) (generate-value depth env)] ;; can't sub1 or might get nothing in tail position
          [(1) (generate-let depth env generate-tail)]
          [(2)
           `(if ,(generate-pred (sub1 depth) env)
                ,(generate-tail (sub1 depth) env)
                ,(generate-tail (sub1 depth) env))]
          [(3)
           ;; check if any procedure is defined, return value if there is no procedure
           (if (null? proc-names)
               (generate-tail depth env)
               (let* ([fname (get-random-proc-name)]
                      [arity (hash-ref proc-arities fname)])
                 `(call ,fname ,@(generate-trivs arity env))))])))

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

    `(module ,@defs ,(generate-tail (random 1 3) '())
       ))

  (generate-program))

(for ([i (in-range 10)])
  (pretty-display (format "(check-by-interp '~a)" (generate-values-lang-v5)))
  (newline))
