;; -*- fill-column: 102 -*-
#lang racket/base

(require gregor
         "readers/first-direct.rkt")

(module+ main

  (define the-statement
    (dynamic-require "data/statements/first-direct-geddesdealmeida.rkt" 'statement))

  (printf "\n\n~a transactions parsed" (length (statement-entries the-statement)))
  
  )
