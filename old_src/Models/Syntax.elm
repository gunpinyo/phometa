module Models.Syntax where

import Array exposing (Array)

import Tools.Css exposing (CssColor)
import Models.Module exposing (ModulePath, ModuleBase, ModuleElementBase)

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
--   - inherit from `ModuleElement` constrain
--   - variable_regex must contain string which has well-form regex pattern
type alias Grammar
  = ModuleElementBase
      { -- if `base_grammar` == `Nothing`, then it extends nothing
        base_grammar : Maybe GrammarRef
        -- if `variable_regex` == `Nothing`, then any string as variable name
        -- we don't store compiled regex but rather store string instead
        --   this is because we need to show regex to user
      , variable_regex : Maybe String
      , choices : Array GrammarChoice
        -- if True, additional build-in style will be apply
        --   to distinct between parent and child term
      , use_distinction : Bool
      , fg_color : CssColor
      }

-- constrain:
--   - inherit from `Module` constrain
--   - in `dependent_syntaxes`, both of `module_path` and `alias`
--       must not duplicate to other elements
--   - syntax dependency hierarchy must be acyclic graph
--       i.e. syntax cannot import itself
--              nor import syntax that depend on this syntax
type alias Syntax
  = ModuleBase
      { dependent_syntaxes :
          Array { module_path : ModulePath, alias : SyntaxAlias }
      , grammars : Array Grammar
      }
