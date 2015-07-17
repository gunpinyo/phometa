module Model.Semantics where

import Array exposing (Array)
import Dict exposing (Dict)

import Model.Term exposing (RootTerm)

-- TODO: write example and import declaration

type alias RuleName = String

type Rule
  = Array { promises : (Array RootTerm)
          , conclusion : RootTerm
          }

type alias RuleDict
  = Dict RuleName Rule

type alias Semantics
  = { rule_dict : RuleDict
    , rule_order : List RuleName
    , has_locked : Bool
    }
