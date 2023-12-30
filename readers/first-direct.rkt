;; -*- fill-column: 102; -*-
#lang racket/base

#|

Read first direct, downloaded csv statements

As of 29 July 2023 the first line of the csv file is the
string "Date,Description,Amount,Balance".

Each subsequent line is of the form:

DD/MM/YYYY,SS..SSTT..TT,99.99,99.99

If the field SS..SSTT..TT is not more than 18 characters, then it
should be read as a single description. If it is longer than 18
characters, then the first 18 characters are a description
(which may be truncated or may be right-padded with spaces) and the
remaining characters are a reference.

The third field is the transaction amount (positive for a deposit;
negative for a payment or withdrawal). The final field is the balance
following this transaction.

|#

(require racket/list
         racket/match
         racket/string
         gregor
         "../statements.rkt")


(provide first-direct)

;; read-entry : string? -> (date? integer? integer? string? [or/c string? #f])
(define (read-entry ln)
  (match-let ([(list dt desc amt bal) (string-split ln "," #:trim? #f)])
    (let ([dt   (parse-date dt "dd/MM/yyyy")] 
          [amt  (* 100 (string->number amt 10 'number-or-false 'decimal-as-exact))]
          [desc (string-trim (substring desc 0 (min 18 (string-length desc))))]     
          [ref  (and (> (string-length desc) 18) (substring desc 18))])
      (list dt amt bal desc ref))))

;; parse-entry :  -> raw-entry? 
(define (parse-entry entry)
  (match-let ([(list dt amt _ desc ref) entry])
    (raw-entry dt
               (abs amt)
               (negative? amt) ; A negative amount is a withdrawal
               (if ref
                   (list desc ref)
                   (list desc)))))


;; first-direct : path? date? date? -> raw-statement? 
(define (first-direct path)
  
  ;; Read all entries
  (define entries 
    (with-input-from-file
      path
      (λ ()
        (unless (string=? (read-line) "Date,Description,Amount,Balance")
          (raise-user-error "Did not recognise the header as a first direct statement"
                            (path->string path)))
        ;; Sort descending by date
        (sort 
         (for/list ([line (in-lines)])
           (read-entry line))
         date>?
         #:key car))))

  ;; ;; The list of entries is now sorted in descending order of date

  ;; (when (date>? (car (first entries)) end-date)
  ;;   (raise-user-error "Latest entry in statement occurs after claimed end date" path))
  ;; (when (date<? (car (last entries)) start-date)
  ;;   (raise-user-error "Earliest entry in statement occurs before claimed end date" path))

  (raw-statement (map parse-entry entries)
                 (car (last entries))    ; start date
                 (car (first entries))   ; end date 
                 )

  )

