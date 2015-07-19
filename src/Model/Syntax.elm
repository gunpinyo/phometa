module Model.Syntax where

import Array exposing (Array)
import Maybe exposing (Maybe(..))


-- constrain:
--   - `DependentSyntaxIndex` must be in range of
--       `dependent_syntaxes` of `ModuleSyntax` in `Model.Repository`
type alias DependentSyntaxIndex = Int

-- constrain:
--   - `GrammarIndex` must be in range of `grammars` in `Syntax`
type alias GrammarIndex = Int

-- constrain:
--   - `GrammarChoiceIndex` must be in range of
--       `choices` of corresponding `Grammar`
type alias GrammarChoiceIndex = Int

-- constrain:
--   - sub-`GrammarRef` in `GrammarRefImport` must correspond to
--       `DependentSyntaxIndex`-th dependent syntax of this syntax
type GrammarRef
  = GrammarRefCurrent GrammarIndex
  | GrammarRefImport DependentSyntaxIndex GrammarRef

-- constrain:
--   - `subgrammars` must have length less than `format` by 1.
--   - each element in subgrammars must exists in corresponding syntax
type alias GrammarChoice
  = { subgrammars : Array GrammarRef
    , format : Array String
    }

-- constrain:
--   - `name` can't be empty string nor the same with in another `grammar`
type alias Grammar
  = { choices : Array GrammarChoice
    , name : String
    , use_distinction : Bool          -- if True, additional build-in style
                                      --   will be apply to distinct between
                                      --   parent and child term
    }

-- constrain:
--   - `dependent_syntax_aliases` must correspond
--       `dependent_syntaxes` of `ModelSyntax` in `Model.Repository`
type alias Syntax
  = { grammars : Array Grammar
    , dependent_syntax_aliases : Array String
    , has_locked : Bool
    }
