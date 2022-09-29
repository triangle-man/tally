#lang info
(define collection "budget")
(define deps '("base"))
(define build-deps '("scribble-lib" "racket-doc" "rackunit-lib"))
(define scribblings '(("scribblings/budget.scrbl" ())))
(define pkg-desc "Sort out my finances")
(define version "0.0")
(define pkg-authors '(jgeddes))
(define license 'MIT)
