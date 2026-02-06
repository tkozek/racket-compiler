#lang racket

(require cpsc411/compiler-lib
        compiler.rkt)
    
(provide interp-paren-x64)

(define (interp-paren-x64 p)
  ; Environment (List-of (paren-x64-v2 Statements)) -> Integer
  (define (eval-instruction-sequence env sls)
    (if (empty? sls)
        (dict-ref env 'rax)
        (TODO "Implement the fold over a sequence of Paren-x64-v2 /s/.")))

  ; Environment Statement -> Environment
  (define (eval-statement env s)
    (TODO "Implement the transition function evaluating a Paren-x64-v2 /s/."))

  ; (Paren-x64-v2 binop) -> procedure?
  (define (eval-binop b)
    (TODO "Implement the interpreter for Paren-x64-v2 /binop/."))

  ; Environment (Paren-x64-v2 triv) -> Integer
  (define (eval-triv regfile t)
    (TODO "Implement the interpreter for Paren-x64-v2 /triv/."))

  (TODO "Implement the interpreter for Paren-x64-v2 /p/."))