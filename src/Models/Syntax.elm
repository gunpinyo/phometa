module Models.Syntax where

import Array exposing (Array)

import Tools.Css exposing (CssColor)
import Models.ModuleHeader exposing (ModulePath)

-- constrain:
--   - `SyntaxIndex` must be in range of `dependent_syntaxes`
type alias SyntaxIndex = Int

-- constrain:
--   - `GrammarIndex` must be in range of `grammars` in `Syntax`
type alias GrammarIndex = Int

-- constrain:
--   - `GrammarChoiceIndex` must be in range of
--       `choices` of corresponding `Grammar`
type alias GrammarChoiceIndex = Int

-- if `syntax_index` == `Nothing`, then it refer to current syntax
type alias GrammarReference
  = { syntax_index : Maybe SyntaxIndex
    , grammar_index : GrammarIndex
    }

-- constrain:
--   - `subgrammars` must have length less than `format` by 1.
--   - each element in subgrammars must exists in corresponding syntax
type alias GrammarChoice
  = { subgrammars : Array GrammarReference
    , format : Array String
    }

-- constrain:
--   - `name` can't be empty string
--       nor the same with in another `grammar` in `Syntax`
type alias Grammar
  = { choices : Array GrammarChoice
    , name : String
    , use_distinction : Bool          -- if True, additional build-in style
                                      --   will be apply to distinct between
                                      --   parent and child term
    , fg_color : CssColor
    , comment : String
    }

-- each existence of `ModulePath` will be handle at module level
type alias Syntax
  = { grammars : Array Grammar
    , dependent_syntaxes : Array { module_path : ModulePath, alias : String}
    , has_locked : Bool
    , comment : String
    }
