module Models.Term where

import Array exposing (Array)

import Models.Syntax exposing (GrammarChoiceIndex, GrammarRef)


type alias VariableName = String

type Term
  -- constrain:
  --   - `index` must be in range of number of choice of corresponding grammar
  --   - `subterms` must have the same length as `subgrammars`
  --       of index-th choice of corresponding grammar
  --   -  constrains above must be enforce for subterms recursively
  = TermGrammar { index : GrammarChoiceIndex
                , subterms : Array Term
                }
  -- constrain:
  --   - `VariableName` must match with `variable_regex`
  --       of corresponding grammar (if `variable_regex` == `Just _`)
  | TermVariable VariableName
  | TermHole

-- root term need to know its grammar in advance
-- but subterms will we be able to figure out themselves
-- by using root term knowledge
type alias RootTerm a
  = { a |
      grammar : GrammarRef
    , term : Term
    }
