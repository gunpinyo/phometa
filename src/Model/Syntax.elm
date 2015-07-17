module Model.Syntax where

import Array exposing (Array)
import Dict exposing (Dict)
import Maybe exposing (Maybe)

{- example:

Grammar

NExp ::= zero
       | suc NExp
       | dig Digits

Digits =~ [0-9]+

BExp ::= ⊤
       | BoolExpr ∨ BoolExpr
       | ¬ BoolExpr
       | NExp = NExp

will be encode like

Dict.formList
  [ ( "NExp", GrammarInd
                Array.fromList [ Array.fromList []
                               , Array.fromList [ "NExp" ]
                               , Array.fromList [ "Digits" ]
                               ]
                Array.fromList [ Array.fromList [ "zero" ]
                               , Array.fromList [ "suc ", "" ]
                               , Array.fromList [ "dig ", "" ]
                               ]
                ]
    )
  , ( "Digits", GrammarRegex "[0-9]+" )
  , ( "BExp", GrammarInd
                Array.fromList [ Array.fromList []
                               , Array.fromList [ "BExp", "BExp" ]
                               , Array.fromList [ "BExp" ]
                               , Array.fromList [ "NExp", "NExp" ]
                               ]
                Array.fromList [ Array.fromList ["⊤"]
                               , Array.fromList ["", " ∨ ", ""]
                               , Array.fromList ["¬ ", ""]
                               , Array.fromList ["", " = ", ""]
                               ]
    )
  ]

-}

type alias GrammarName = String

type Grammar
  -- First element correspond to array of array of (children) grammar
  -- Second element correspond to array of format
  -- constrain:
  --   - First and second element much have equal length
  --   - Row of first element much be less than
  --       correspond row of second element by 1
  = GrammarInd (Array (Array GrammarName)) (Array (Array String))
  -- consists of javascript regexp pattern
  | GrammarRegex String

type alias GrammarDict
  = Dict GrammarName Grammar

type alias GrammarConfig
  = { use_distinction : Bool          -- if True, additional build-in style
                                      --   will be apply to distinct between
                                      --   parent and child term
    , background_color : Maybe Int    -- hexcode color, eg. #FFFFFF
    , foreground_color : Maybe Int    -- hexcode color, eg. #FFFFFF
    , is_bold : Bool
    , is_italic : Bool
    }

type alias Syntax
  = { grammar_dict : GrammarDict
    , grammar_order : List GrammarName
    , grammar_config_dict : Dict GrammarName GrammarConfig
    , has_locked : Bool
    }
