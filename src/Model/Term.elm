module Model.Term where

import Model.Syntax exposing (GrammarName)

{- example (continue from example in `Model.Grammar`):

  ((¬ ⊤) ∨ ((var 1) = (suc zero))) : BExp

can be represented as

  { grammar = "BExp"
  , term = TermInd 1
      [ TermInd 2
          [ TermInd 0 [] ]
      , TermInd 3
          [ TermRegex "0"
          , TermInd 1
              [ TermInd 0 [] ]
          ]
      ]
  }

please note that, corresponded syntax is strongly needed to interpret any term

-}

type Term
  = TermInd Int (List Term)        -- consists of index, subterms
  | TermRegex String               -- consists of term name
  | TermVar String                 -- consists of variable name
  | TermDef String                 -- consists of (global) definition name
  | TermHole                       -- for term that need to be complete

-- root term need to know its grammar in advance
-- but subterms will we be able to figure out by themselves
-- using root term knowledge
type alias RootTerm
  = { grammar : GrammarName
    , term : Term
    }
