module Models.Term where

import Array exposing (Array)

import Models.Syntax exposing (GrammarChoiceIndex, GrammarReference)


type alias Variable = String

type Term
  = TermGrammar { index : GrammarChoiceIndex
                , subterms : Array Term
                }
  | TermVariable Variable
  | TermHole

-- root term need to know its grammar in advance
-- but subterms will we be able to figure out themselves
-- by using root term knowledge
type alias RootTerm
  = { grammar : GrammarReference
    , term : Term
    }
