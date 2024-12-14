;; -*- fill-column: 102; -*-
#lang racket/base

#|

Read all downloaded csv statements in a given directory and produce a list of raw transactions

|#

(require racket/list
         racket/match
         racket/string
         racket/format
         racket/path
         gregor
         )

(provide read-first-direct        ; read all statements in a directory
         (struct-out entry)       ; a structure representing a single line in a statement 
         entry<?                  ; the original order of entries
         (struct-out statement))  ; a structure to hold a complete list of entries


(define-logger tally)

;; An entry is a single line from a statement
;;
;; line is a line number -- an integer which orders entries having the same date (smaller numbers
;; indicate later transactions, because the source files are in reverse chronological order)

(struct entry (line date amount balance description reference) #:transparent)

(define (entry<? e1 e2)
  (let ([d1 (entry-date e1)]
        [d2 (entry-date e2)])
    (or (date<? d1 d2)
        (and (date=? d1 d2)
             (> (entry-line e1) (entry-line e2))))))

;; A statement is a list of entries

(struct statement (source first-date last-date opening entries) #:transparent)

#|

Parse an entry

Each line is of the form: DD/MM/YYYY,DD..DRR..R,99.99,99.99

If the field DD..DRR..R is not more than 18 characters, then it should be read as a single
description, DD..D. If it is longer than 18 characters, then the first 18 characters are a
description (which may be truncated or may be right-padded with spaces) and the remaining characters
are a reference, RR..R.

The third field is the transaction amount (positive for a deposit; negative for a payment or
withdrawal). The final field is the balance following this transaction.

|#

;; parse-entry : string? -> entry?
(define (parse-entry ln ln-number)
  (match-let ([(list dt desc amt bal) (string-split ln "," #:trim? #f)])
    (entry ln-number                                                          ; line
           (parse-date dt "dd/MM/yyyy")                                       ; date
           (* 100 (string->number amt 10 'number-or-false 'decimal-as-exact)) ; amount
           (* 100 (string->number bal 10 'number-or-false 'decimal-as-exact)) ; balance
           (string-trim (substring desc 0 (min 18 (string-length desc))))     ; description
           (and (> (string-length desc) 18) (substring desc 18))              ; reference
           )))


;; Read a single statement. Fail if we don't think this is a first direct statement
;; As of 29 July 2023 the first line of the csv file is the string "Date,Description,Amount,Balance".

;; read-statement : path? -> statement? 
(define (read-statement path)
  (with-input-from-file
    path
    (λ ()
      (unless (string=? (read-line) "Date,Description,Amount,Balance")
        (raise-user-error "Did not recognise the header as a first direct statement"
                          (path->string path)))

      (let* ([entries
              (for/list ([(line line-number) (in-indexed (in-lines))])
                (parse-entry line (+ line-number 1)))]
             [sorted-entries (sort entries entry<?)]
             [first-entry (first sorted-entries)])
        (statement path                                                       ; source
                   (entry-date first-entry)                                   ; first-date
                   (entry-date (last sorted-entries))                         ; last-date
                   (- (entry-balance first-entry) (entry-amount first-entry)) ; opening
                   sorted-entries                                             ; entries
                   )))))


;; Read all statements in a given directory
;; A file is a statement if its filename ends in .csv

(define (read-first-direct path)
  (log-tally-info (format "Entering ~a and reading ..." path))

  (define statements 
    (for/list ([csv-file (filter (λ (p) (path-has-extension? p #".csv")) (directory-list path))])
      (let ([stmnt (read-statement (build-path path csv-file))])
        (log-tally-info (format "* ~a [~a entries ~a to ~a]"
                                (path-element->string csv-file)
                                (length (statement-entries stmnt))
                                (date->iso8601 (statement-first-date stmnt))
                                (date->iso8601 (statement-last-date stmnt))))
        stmnt)))
  
  statements)

;; show-raw-favour : raw-favour? -> string?
;; Produce a single-line representation of the raw favour

#|
(define (show-raw-favour rf)
  (let ([cr?  (raw-favour-cr? rf)]
        [desc (raw-favour-desc rf)])
    (string-append
     (date->iso8601 (raw-favour-date rf))
     (if cr? " " "  ")     ; leave space for "-"
     (~r (* (if cr? -1 1)
            (/ (raw-favour-amt rf) 100))
         #:precision '(= 2)
         #:group-sep ","
         #:min-width 10)
     " "
     (~a (car desc) #:min-width 18)
     (~a (if (null? (cdr desc)) "" (cadr desc))))))


|#
