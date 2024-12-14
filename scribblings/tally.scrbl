#lang scribble/manual
@require[@for-label[racket/base]]

@title{tally}
@author["James Geddes"]

@defmodule[tally/favour]{

Contains the core definitions of this model of accounting.}


@defmodule[tally/statement]{

 A @deftech{statement} represents the complete set of all
 favours [NB: transactions?] between two dates for which a
 specific person is either a creditor or debitor.}


