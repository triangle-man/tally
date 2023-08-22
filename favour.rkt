;; -*- fill-column: 102 -*-
#lang racket/base

(require gregor)

(provide (struct-out period)
         pdate
         (struct-out person)
         reason?
         )

;; ---------------------------------------------------------------------------------------------------
;; Persons

;; A person is individuated by a string
;; 
(struct person (name kind minimum-balance) #:transparent)


;; ---------------------------------------------------------------------------------------------------
;; Reasons

;; A reason is a list of symbols
(define (reason? v)
  (and (list? v)
       (andmap symbol? v)))

;; A period is a pair of dates
;; date2 may be 'anyday or 'someday
;; Otherwise, date1 <= date2 must hold
(struct period (date1 date2) #:transparent)

(define (pdate dt)
  (period dt dt))

