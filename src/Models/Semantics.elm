module Models.Semantics where

import Array exposing (Array)
import Dict exposing (Dict)

import Models.ModuleHeader exposing (ModulePath)
import Models.Term exposing (RootTerm)


-- constrain:
--   - `SemanticsIndex` must be in range of `dependent_semanticses`
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

-- each existence of `ModulePath` will be handle at module level
type alias Semantics
  = { rules : Array Rule
    , dependent_syntax : ModulePath
    , dependent_semanticses : Array { module_path : ModulePath, alias : String}
    , has_locked : Bool
    , comment : String
    }
