;; -*- fill-column: 102; -*-
#lang racket/base

#|

Statements

A statement is a set of partial transactions containing favours from the perspective of a particular
person. A raw statement is one where the other side(s) of the transactions or the reason may be
uncertain. (This is the case with most bank statements, for example.)

Statements typically guarantee to be a complete record of transactions involving that person within a
a particular range of dates.

|#

(provide raw-entry
         raw-statement)

;; Raw statement entries are a generic structure that read the minimal data we expect in any
;; downloaded file and retain person-specific entries as a list of strings.

;; date : date?
;; cr?  : boolean? Is this person the creditor in this transaction?
;; amt  : integer? In pence!
;; desc : [List-of string?]

(struct raw-entry (date amt cr? desc) #:transparent)

;; Raw statements are
;; - a list of raw entries
;; - the earliest and latest dates 

(struct raw-statement (entries start end) #:transparent)







