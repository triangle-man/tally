#lang racket/base

#|

Read and parse raw statements 

A statement is a file containing favours from the perspective of a particular person. A raw statement
is one where the other side(s) of the transactions or the reason may be uncertain. This is the case
with most bank statements, for example.

|#

(require racket/contract
         racket/path
         racket/port
         racket/string
         racket/match
         gregor)

(provide read-raw-first-direct-statement) 





;; Person-specific readers
;; ===================================================================================================


#|

------------------------------------------------------------------------------------------------------
Bank: first direct

Format: Downloaded csv statements
As of:  29 July 2023

The first line of this file is the string:
"Date,Description,Amount,Balance"

Each subsequent line is of the form:

DD/MM/YYYY,SS..SSTT..TT,99.99,99.99

If the field SS..SSTT..TT is not more than 18 characters, then it should be read as a single
description. If it is longer than 18 characters, then the first 18 characters are a description
(which may be truncated or may be right-padded with spaces) and the remaining characters are a
reference.

The first numeric field is the transaction amount (positive for a deposit; negative for a payment or
withdrawal). The final field is the balance following this transaction.

|#


;; read-raw-first-direct-statement : path? -> [List-of line?]
;; A line? is a list whose first element is the date, the second is the amount, and then either one
;; or two strings.
(define (read-raw-first-direct-statement path)
  
  (define (parse-line ln)
    (match-let ([(list dt desc amt _) (string-split ln "," #:trim? #f)])
      (list (parse-date dt "dd/MM/yyyy")                                       ; date
            (* 100 (string->number amt 10 'number-or-false 'decimal-as-exact)) ; amount in pence
            (string-trim (substring desc 0 (min 18 (string-length desc))))     ; description
            (if (> (string-length desc) 18)                                    ; reference (if given)
                (substring desc 18)
                ""))))

  (let ([lines (with-input-from-file path port->lines)])
    (if (not (string=? (car lines) "Date,Description,Amount,Balance"))
        (raise-user-error "Did not recognise the header as a first direct statement" path)
        (map parse-line (cdr lines)))))


  


  
