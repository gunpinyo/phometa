module Models.Theory where

import Array exposing (Array)
import Dict exposing (Dict)

import Models.Term exposing (RootTerm)
import Models.Semantics exposing (RuleReference)


-- constrain:
--   - `TheoryIndex` must be in range of
--       `dependent_theories` of `ModuleTheory` in `Model.Repository`
type alias TheoryIndex = Int

-- constrain:
--   - `TheoremIndex` must be in range of `theorems` in `Theory`
type alias TheoremIndex = Int

-- if `theory_index` == `Nothing`, then it refer to current theory
type alias TheoremReference
  = { theory_index : Maybe TheoryIndex
    , theorem_index : TheoremIndex
    }


-- constrain:
--   `TheoremRef` in `ProofByLemma` must be a theorem BEFORE this `Theorem`
--     ie. theorem that is in dependent theory or theorem above this
type Proof
  = ProofByRule { rule : RuleReference
                , subproofs : (Array Proof)
                }
  | ProofByLemma TheoremReference

-- constrain:
--   - `name` can't be empty string
--       nor the same name with in another `theorem` in `Theory`
type alias Theorem
  = { term : RootTerm
    , proof : Proof
    , name : String
    , comment : String
    }

-- constrain:
--   - `dependent_theories_aliases` must correspond
--       `dependent_theories` of `ModuleTheory` in `Model.Repository`
type alias Theory
  = { theorems : Array Theorem
    , dependent_theories_aliases : Array String
    , has_locked : Bool
    , comment : String
    }
