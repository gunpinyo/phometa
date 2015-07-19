module Model.Semantics where

import Array exposing (Array)
import Dict exposing (Dict)

import Model.Term exposing (RootTerm)


-- constrain:
--   - `DependentSemanticsIndex` must be in range of
--       `dependent_semanticses` of `ModuleSemantics` in `Model.Repository`
type alias DependentSemanticsIndex = Int

-- constrain:
--   - `RuleIndex` must be in range of `rules` in `Semantics`
type alias RuleIndex = Int

-- constrain:
--   - `RuleChoiceIndex` must be in range of
--       `choices` of corresponding `Rule`
type alias RuleChoiceIndex = Int

-- constrain:
--   - sub-`RuleRef` in `RuleRefImport` must correspond to
--       `DependentSemanticsIndex`-th dependent semantics of this semantics
type RuleRef
  = RuleRefCurrent RuleIndex
  | RuleRefImport DependentSemanticsIndex RuleRef

type alias RuleChoice
  = { promises : (Array RootTerm)
    , conclusion : RootTerm
    }

-- constrain:
--   - `name` can't be empty string nor the same name with in another `rule`
type alias Rule
  = { choices : Array RuleChoice
    , name : String
    }

-- constrain:
--   - `dependent_semantics_aliases` must correspond
--       `dependent_semanticses` of `ModelSemantics` in `Model.Repository`
type alias Semantics
  = { rules : Array Rule
    , dependent_semantics_aliases : Array String
    , has_locked : Bool
    }
