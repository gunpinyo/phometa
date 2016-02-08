module Models.Semantics where

import Array exposing (Array)
import Dict exposing (Dict)

import Models.Module exposing (ModulePath, ModuleBase, ModuleElementBase)
import Models.Term exposing (RootTermBase)
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
--   - inherit from `ModuleElement` constrain
type Rule
  = RuleBasic (ModuleElementBase
      { -- `hint` is a rule that will be apply to promise
        --   when a proof is build in automatic mode
        --   if `hint` == Nothing or hint fail during unification
        --   then user need to construct that part manually
        promises : Array (RootTermBase { hint : Maybe RuleRef })
      , conclusion : RootTermBase {}
      })
  -- constrain:
  --   - each of grammar in `subrules` must match main `grammar`
  --       (`conclusion.grammar` for `RuleBasic`)
  | RuleDerived (ModuleElementBase
      { grammar : GrammarRef
      , subrules : Array RuleRef
      })

-- constrain:
--   - inherit from `Module` constrain
--   - everything that has type `ModulePath` must exists in `RootPackage`,
--       and must has correct format
--       e.g. module_path has format `ModuleSemantics _`
--   - in `dependent_semanticses`, both of `module_path` and `alias`
--       must not duplicate to other one in the array
--   - semantics dependency hierarchy must be acyclic graph
--       i.e. semantics cannot import itself
--              nor import semantics that depend on this semantics
type alias Semantics
  = ModuleBase
      { dependent_syntax : ModulePath
      , dependent_semanticses :
          Array { module_path : ModulePath, alias : SemanticsAlias }
      , rules : Array Rule
      }
