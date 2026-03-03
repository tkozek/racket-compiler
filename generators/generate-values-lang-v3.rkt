#lang racket

(require cpsc411/compiler-lib
         cpsc411/2c-run-time
         cpsc411/langs/v3
         cpsc411/test-suite/utils
         cpsc411/test-suite/public/v3)

(define (generate-values-lang-v3)

  (define triv-names '())

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

  (define (generate-value depth env)
    (if (zero? depth)
        (generate-triv env)
        (case (random 3)
          [(0) (generate-triv env)]
          [(1) `(,(generate-binop) ,(generate-triv env) ,(generate-triv env))]
          [(2)
           (let ([x (get-random-triv-name)])
             `(let ([,x ,(generate-value (sub1 depth) env)])
                ,(generate-value (sub1 depth) (cons x env))))])))

  (define (generate-tail depth env)
    (if (zero? depth)
        (generate-value 0 env)
        (case (random 2)
          [(0) (generate-value depth env)] ;; can't sub1 or might get nothing in tail position
          [(1)
           (let ([x (get-random-triv-name)])
             `(let ([,x ,(generate-value (sub1 depth) env)])
                ,(generate-tail (sub1 depth) (cons x env))))])))

  (define (generate-program)
    (generate-triv-names 10)
    `(module ,(generate-tail (random 1 3) '())))

  (generate-program))

; (for ([i (in-range 10)])
;   (pretty-display (format "(check-by-interp '~a)" (generate-values-lang-v4)))
;   (newline))

(for ([i (in-range 1000)])
  (pretty-display (format "(check-by-interp '~a)" (generate-values-lang-v3)))
  (newline))
