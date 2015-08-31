module Models.Theory where

import Array exposing (Array)
import Dict exposing (Dict)

import Models.ModuleHeader exposing (ModulePath)
import Models.Term exposing (RootTerm)
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
--   - `name` can't be empty string
--       nor the same name with in another `lamma` in `Theory`
type alias Lamma
  = { name : String
    , term : RootTerm
    , proof : Proof
    , comment : String
    }

-- constrain:
--   - `dependent_syntax` must match `dependent_semantics.dependent_syntax`
--   - everything that has type `ModulePath` must exists in `RootPackage`
--       and must has correct format
--       e.g. module_path has format `ModuleTheory _`
--   - in `dependent_theories`, both of `module_path` and `alias`
--       must not duplicate to other elements
type alias Theory
  = { module_path : ModulePath
    , dependent_syntax : ModulePath
    , dependent_semantics : ModulePath
    , dependent_theories :
        Array { module_path : ModulePath, alias : TheoryAlias }
    , lammas : Array Lamma
    , has_locked : Bool
    , comment : String
    }
