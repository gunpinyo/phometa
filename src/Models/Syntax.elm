module Models.Syntax where

import Array exposing (Array)

import Tools.Css exposing (CssColor)
import Models.ModuleHeader exposing (ModulePath)


type alias SyntaxAlias = String

type alias GrammarName = String

-- constrain:
--   - `GrammarChoiceIndex` must be in range of
--       `choices` of corresponding `Grammar`
type alias GrammarChoiceIndex = Int

-- if `syntax_alise` == `Nothing`, then it refers to current syntax
-- constrain:
--   - if `syntax_alise` == `Just _`
--       it must correspond to one of alias in `Syntax.dependent_syntaxes`
--   - `grammar_name` must correspond to one of grammar
--       of corresponding `Syntax`
type alias GrammarRef
  = { syntax_alise : Maybe SyntaxAlias
    , grammar_name : GrammarName
    }

-- constrain:
--   - `subgrammars` must have length less than `format` by 1
type alias GrammarChoice
  = { subgrammars : Array GrammarRef
    , format : Array String
    }

-- constrain:
--   - `name` can't be empty string
--       nor the same with in another `grammar` in `Syntax`
--   - variable_regex must contain string which has well-form regex pattern
type alias Grammar
  = { name : String
    , base_grammar : Maybe GrammarRef -- if `base_grammar` == `Nothing`
                                      --   then it extends nothing
    , variable_regex : Maybe String   -- if `variable_regex` == `Nothing`
                                      --   then any string as variable name
                                      -- we don't store compiled regex
                                      --   but store string instead
                                      --   since we need to show regex to user
    , choices : Array GrammarChoice
    , use_distinction : Bool          -- if True, additional build-in style
                                      --   will be apply to distinct between
                                      --   parent and child term
    , fg_color : CssColor
    , comment : String
    }

-- constrain:
--   - everything that has type `ModulePath` must exists in `RootPackage`
--       and must has correct format
--       e.g. module_path has format `ModuleSyntax _`
--   - in `dependent_syntaxes`, both of `module_path` and `alias`
--       must not duplicate to other elements
type alias Syntax
  = { module_path : ModulePath
    , dependent_syntaxes :
        Array { module_path : ModulePath, alias : SyntaxAlias }
    , grammars : Array Grammar
    , has_locked : Bool
    , comment : String
    }
