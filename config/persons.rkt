;; -*- fill-column: 102 -*-
#lang racket/base

(require racket/list)

(provide global-person-set      ; List of persons
         global-person-kinds    ; List of person kinds
         person-kind            
         person-short-name
         )

;; A person is a list (person-id kind short-name)
;; person-id  : symbol?
;; kind       : symbol?
;; short-name : string?
;; The short name may be a good description only in the context of the kind.

(define person-kind car)
(define person-short-name cadr)

(define persons
  '(
    ;; --- Persons I typically do favours for
    (employer . ((turing "Turing")))
    (client   . ((bcg "BCG")))
    (lessor   . ((tenant "Tenant")))

    ;; --- Natural persons
    (person   . ((jamie             "Jamie")
                 (irene             "Irene")
                 (tomaz             "Tomaz")
                 (geddes-de-almeida "Family Geddes de Almeida")))

    ;; --- Intermediaries
    (asset    . ((nocell "Nocell shares")))

    (financial . ((first-direct-jamie             "Personal account (Jamie)")
                  (first-direct-geddes-de-almeida "Joint account")
                  (first-direct-jamie-credit-card "Credit card (Jamie)")
                  (first-direct-isa               "ISA")
                  (irene-personal                 "Personal account (Irene)")
                  (santander-mortgage             "Mortgage")))

    ;; --- Persons I typically get favours from
    (utility  . ((bulb         "Bulb")
                 (octopus      "Octopus")
                 (thames-water "Thames Water")
                 (sky          "Sky")))
    
    (subscription . ((grauniad  "The Guardian")
                     (labour    "The Labour Party")
                     (applesubs "Apple")
                     (bbc       "TV Licensing")))
    
    (retailer . ((sainsburys "Sainsburys")
                 (aldi       "Aldi")
                 (lidl       "Lidl")
                 (tesco      "Tesco")
                 (waitrose   "Waitrose")
                 (tkmaxx     "TK Maxx")
                 (primark    "Primark")
                 (boots      "Boots")))
    
    (service . ((therapy "Therapist")))))


(define (of-kind kind prsns)
  (map (λ (p) (list (car p) kind (cadr p)))
       prsns))

;; The global-person-set is a list of persons. It can be used as an
;; association list with person-id as the key

(define global-person-set
  (append-map (λ (ks)
                (of-kind (car ks) (cdr ks)))
              persons))

;; Kinds of persons (for layout and grouping)

(define global-person-kinds
  (map car persons))
