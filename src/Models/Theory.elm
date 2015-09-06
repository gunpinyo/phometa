module Models.Theory where

import Array exposing (Array)
import Dict exposing (Dict)

import Models.Module exposing (ModulePath, ModuleBase, ModuleElementBase)
import Models.Term exposing (RootTermBase)
import Models.Semantics exposing (RuleRef)


type alias TheoryAlias = String

type alias LammaName = String

-- if `theory_alias` == `Nothing`, then it refer to current theory
type alias LammaRef
  = { theory_alias : Maybe TheoryAlias
    , lamma_name : LammaName
    }


-- constrain:
--   `LammaRef` in `ProofByLemma` must be a lamma than come BEFORE this lamma
type Proof
  = ProofByRule { rule : RuleRef
                , subproofs : (Array Proof)
                }
  | ProofByLemma LammaRef

-- constrain:
--   - inherit from `ModuleElement` constrain
type alias Lamma
  = ModuleElementBase (RootTermBase { proof : Proof })

-- constrain:
--   - inherit from `Module` constrain
--   - `dependent_syntax` must match `dependent_semantics`'s `dependent_syntax`
--   - in `dependent_theories`, both of `module_path` and `alias`
--       must not duplicate to other elements
--   - theory dependency hierarchy must be acyclic graph
--       i.e. theory cannot import itself
--              nor import theory that depend on this theory
type alias Theory
  = ModuleBase
      { dependent_syntax : ModulePath
      , dependent_semantics : ModulePath
      , dependent_theories :
          Array { module_path : ModulePath, alias : TheoryAlias }
      , lammas : Array Lamma
      }
