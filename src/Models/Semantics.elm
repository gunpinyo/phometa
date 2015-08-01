module Models.Semantics where

import Array exposing (Array)
import Dict exposing (Dict)

import Models.Term exposing (RootTerm)


-- constrain:
--   - `SemanticsIndex` must be in range of
--       `dependent_semanticses` of `ModuleSemantics` in `Model.Repository`
type alias SemanticsIndex = Int

-- constrain:
--   - `RuleIndex` must be in range of `rules` in `Semantics`
type alias RuleIndex = Int

-- constrain:
--   - `RuleChoiceIndex` must be in range of
--       `choices` of corresponding `Rule`
type alias RuleChoiceIndex = Int

-- if `semantics_index` == `Nothing`, then it refer to current semantics
type alias RuleReference
  = { semantics_index : Maybe SemanticsIndex
    , rule_index : RuleIndex
    }

type alias RuleChoice
  = { promises : (Array RootTerm)
    , conclusion : RootTerm
    }

-- constrain:
--   - `name` can't be empty string
--       nor the same name with in another `rule` in `Semantics`
type alias Rule
  = { choices : Array RuleChoice
    , name : String
    , comment : String
    }

-- constrain:
--   - `dependent_semantics_aliases` must correspond
--       `dependent_semanticses` of `ModelSemantics` in `Model.Repository`
type alias Semantics
  = { rules : Array Rule
    , dependent_semantics_aliases : Array String
    , has_locked : Bool
    , comment : String
    }
