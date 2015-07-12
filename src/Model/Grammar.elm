module Model.Grammar where

{- example:

Grammar

NExp ::= zero
       | suc NExp

Var  ::= [a-z]+

BExp ::= ⊤
       | BoolExpr ∨ BoolExpr
       | ¬ BoolExpr
       | NExp = NExp

will be encode like

[ { name = "NExp"
  , type_ = Type_IndType [ { types = [], format = ["zero"] }
                         , { types = ["NExp"], format = ["suc ", ""] }
                         ]
  }
, { name = "Var"
  , type_ = Type_RegexType "[a-z]+"
  }
, { name = "BExp"
  , type_ = Type_IndType [ { types = [], format = ["⊤"] }
                         , { types = ["BExp", "BExp"], format = ["", " ∨ ", ""] }
                         , { types = ["BExp"], format = ["¬ ", ""] }
                         , { types = ["NExp", "NExp"], format = ["", " = ", ""] }
                         ]
  }
]

-}

type Type
  -- constrain:
  --   for Type_Ind length of `types` much be more that `format` by one
  = Type_IndType (List { types : List String, format : List String })
  -- the following string is regex pattern which follow javascript regex
  | Type_RegexType String

-- constrain:
--   each of `IndType.name` much be unique with in `Grammar`
type alias Grammar
  = List { name : String, type_ : Type }
