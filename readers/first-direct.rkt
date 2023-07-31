#lang racket/base

(require gregor)

;; Readers for first direct statments
;; A reader is one or two regular expressions, followed by a list of transaction templates


(provide readers)

(define readers
  (list
   (list #rx"")))
