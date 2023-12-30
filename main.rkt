;; -*- fill-column: 102 -*-
#lang racket/base

(require gregor
         "statements.rkt"
         "readers/first-direct.rkt")

(module+ main

  ;; Load and parse a single statement
  (define *dir* "data/statements/joint")
  (define *statement* "6976_2023-04-01_2023-06-30.csv")

  (first-direct (build-path *dir* *statement*))
  
  )
