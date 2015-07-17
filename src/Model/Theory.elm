module Model.Theory where

import Array exposing (Array)
import Dict exposing (Dict)

import Model.Term exposing (RootTerm)
import Model.Semantics exposing (RuleName)

-- TODO: write example and import declaration

type Proof
  = ProofRecord { rule_name : RuleName
                , subproofs : (Array Proof)
                }

type alias TheoremName = String

type alias Theorem
  = { term : RootTerm
    , proof : Proof
    }

type alias TheoremDict
  = Dict TheoremName Theorem

type alias Theory
  = { theorem_dict : TheoremDict
    , theorem_order : List TheoremName
    , has_locked : Bool
    }
