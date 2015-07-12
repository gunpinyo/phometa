module Model.Term where

import Model.Grammar exposing (TypeName)

{- example (continue from example in `Model.Grammar`):

  ((¬ ⊤) ∨ (zero = (suc zero))) : BExp

can be represented as

  Term_FromIndType "BExp" 1
    [ Term_FromIndType "BExp" 2
        [ Term_FromIndType "BExp" 0 [] ]
    , Term_FromIndType "BExp" 3
        [ Term_FromIndType "NExp" 0 []
        , Term_FromIndType "NExp" 1
            [ Term_FromIndType "NExp" 0 [] ]
        ]
    ]

and

  somevar : Var

can be represented as

  Term_FromRegexType "Var" "somevar"

-}

type Term
  = Term_FromIndType TypeName Int (List Term) -- type_name index subterms
  | Term_FromRegexType TypeName String        -- type_name name
  | Term_Hole                              -- state term needed to be complete
