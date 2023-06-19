#lang racket/base

;; Facilities for reading bank statements from CSVs
;; Currently assumes statements are in the format provided by first direct

(require racket/contract
         racket/path
         racket/port
         racket/string
         racket/match
         gregor)

(provide
 (contract-out
  (struct line
    [(date        date?)
     (description string?)
     (reference   string?)
     (amount      number?)
     (balance     number?)])
  (path->account-number (-> path? string?))
  (parse-line (-> string? line?)))) 


;; ----------------------------------------------------------------------

(struct line (date description reference amount balance) #:transparent)
  
;; read-csv-statement : path? -> string? [List-of line?]
(define (read-csv-statement path)
  ;; Read last four digits of the account number from the filename
  (define account (path->account-number path))
  account
  )

(define (parse-line ln)
  (match-let ([(list dt desc amt bal) (string-split ln "," #:trim? #f)])
    (line (parse-date dt "dd/MM/yyyy")
          (string-trim (substring desc 0 (min 18 (string-length desc))))
          (if (> (string-length desc) 18)
              (substring desc 18)
              "")
          (string->number amt)
          (string->number bal))))



;; In first direct CSVs, the filename is of the form DDMMYYYY_nnnn.csv where
;; DDMMYYYY is the download data and nnnn is the last four digits of the account
;; number.
;; path->account-number : path? -> string?
(define (path->account-number path)
  (define filename
    (path->string
     (or (file-name-from-path path)
         (raise-argument-error
          'path->account-number
          "a filename, not a directory"
          path))))
  (define maybe-account-number
    (or (regexp-match #px"^\\d{8}_(\\d{4})\\.csv$" filename)
        (raise-argument-error
         'path->-account-number
         "a first direct format filename, of the form DDMMYYYY_nnnn.csv"
         filename)))
  (cadr maybe-account-number))

;; ----------------------------------------------------------------------

(module+ main
  (with-input-from-file "data/25092022_6976.csv"
    (λ ()
      (read-line)
      (sort (map parse-line (port->lines))
            (λ (l1 l2)
              (string<? (line-description l1) (line-description l2)))))))
