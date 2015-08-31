module Models.Semantics where

import Array exposing (Array)
import Dict exposing (Dict)

import Models.ModuleHeader exposing (ModulePath)
import Models.Term exposing (RootTerm)
import Models.Syntax exposing (GrammarChoiceIndex, GrammarRef)


type alias SemanticsAlias = String

type alias RuleName = String

-- if `semantics_alise` == `Nothing`, then it refers to current syntax
-- constrain:
--   - if `semantics_alise` == `Just _`
--       it must correspond to one of alias in `Semantics.dependent_semanticses`
--   - `rule_name` must correspond to one of rule
--       of corresponding `Semantics`
type alias RuleRef
  = { semantics_alias : Maybe SemanticsAlias
    , rule_name : RuleName
    }

-- constrain:
--   - `name` can't be empty string
--       nor the same name with in another `rule` in `Semantics`
--   - `name` and `comment` are compulsory fields for each of Rule
--       if new alternative has been added, make sure these fields are included
--       (this constrain is not for verification but for reminder only)
type Rule
  = RuleBasic
      { name : String
      , promises : (Array RootTerm)
      , conclusion : RootTerm
      , comment : String
      }
  -- constrain:
  --   - each of grammar in `subrules` must match main `grammar`
  --       (`conclusion.grammar` for `RuleBasic`)
  | RuleDerived
      { name : String
      , grammar : GrammarRef
      , subrules : Array RuleRef
      , comment : String
      }

-- constrain:
--   - everything that has type `ModulePath` must exists in `RootPackage`
--       and must has correct format
--       e.g. module_path has format `ModuleSemantics _`
--   - in `dependent_semanticses`, both of `module_path` and `alias`
--       must not duplicate to other elements
type alias Semantics
  = { module_path : ModulePath
    , dependent_syntax : ModulePath
    , dependent_semanticses :
        Array { module_path : ModulePath, alias : SemanticsAlias }
    , rules : Array Rule
    , has_locked : Bool
    , comment : String
    }
