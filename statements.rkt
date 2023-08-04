;; -*- fill-column: 102; -*-
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
;;
;; A line? is a list whose first element is the date, the second is the amount in pence, and then
;; either one or two strings.
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
    (unless (string=? (car lines) "Date,Description,Amount,Balance")
        (raise-user-error "Did not recognise the header as a first direct statement" path))
    (map parse-line (cdr lines))))

(define (favour . xs)
  #f)

(define (simple-expense-reader creditor debtor reason)
  (λ (dt amt text1 text2)
    (list
     (list
      (favour dt amt creditor debtor reason)
      (favour dt amt 'first-direct-geddesdealmeida creditor 'favour)
      (favour dt amt debtor 'first-direct-geddesdealmeida 'favour)))))


;; Patterns and readers for different kinds of line
(define readers
  (list
   ;; Sainsbury's supermarket. The reference is the branch, which we ignore
   `((#rx"SAINSBURYS" #f) . ,(simple-expense-reader 'Sainsburys 'GeddesDeAlmeida 'groceries)) )
  )




;; read-tentative-first-direct-statement : [List-of line?] - > [List-of [List-of tentative-favour?]]
;; Attempt to determine the reason and the (other) person for each line in the statement.
;; For each line, return a list of possible interpretations.

;; 1. Check exact exceptions as given in the exceptions list
;; 2. Check pattern matches as given in the pattern-match list
;;    - Emit warnings if pattern over-ridden by exception
;; 3. Emit unmatched lines

(define (read-tentative-first-direct-statement lines)
  #f
  )

