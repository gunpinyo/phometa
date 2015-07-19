module Model.Theory where

import Array exposing (Array)
import Dict exposing (Dict)

import Model.Term exposing (RootTerm)
import Model.Semantics exposing (RuleRef)


-- constrain:
--   - `DependentTheoryIndex` must be in range of
--       `dependent_theories` of `ModuleTheory` in `Model.Repository`
type alias DependentTheoryIndex = Int

-- constrain:
--   - `TheoremIndex` must be in range of `theorems` in `Theory`
type alias TheoremIndex = Int

-- constrain:
--   - sub-`TheoremRef` in `TheoremRefImport` must correspond to
--       `DependentTheoryIndex`-th dependent theory of this theory
type TheoremRef
  = TheoremRefCurrent TheoremIndex
  | TheoremRefImport DependentTheoryIndex TheoremRef

-- constrain:
--   `TheoremRef` in `ProofByLemma` must be a theorem BEFORE this `Theorem`
--     ie. theorem that is in dependent theory or theorem above this
type Proof
  = ProofByRule { rule : RuleRef
                , subproofs : (Array Proof)
                }
  | ProofByLemma TheoremRef

-- constrain:
--   - `name` can't be empty string nor the same name with in another `theorem`
type alias Theorem
  = { term : RootTerm
    , proof : Proof
    , name : String
    }

-- constrain:
--   - `dependent_theories_aliases` must correspond
--       `dependent_theories` of `ModuleTheory` in `Model.Repository`
type alias Theory
  = { theorems : Array Theorem
    , dependent_theories_aliases : Array String
    , has_locked : Bool
    }
