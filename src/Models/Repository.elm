module Models.Repository where

import Array exposing (Array)
import Dict exposing (Dict)

import Models.Syntax exposing (Syntax)
import Models.Semantics exposing (Semantics)
import Models.Theory exposing (Theory)
import Models.GlobalConfig exposing (GlobalConfig)

type alias ModuleName = String

type alias ModulePath = List ModuleName

-- constrain:
--   - each `ModulePath` represented here must
--       - exist in `root_package` of `Repository`
--       - have the same type corresponded to its name
--           eg. each element in dependent_syntaxes must be `ModuleSyntax`
--  - for dependent_{syntaxes, semanticses, theories}
--      it must not duplicate elements.
--      e.g. syntax can't import another syntax twice.
type Module
  = ModuleSyntax { syntax : Syntax
                 , dependent_syntaxes : Array ModulePath
                 }
  | ModuleSemantics { semantics : Semantics
                    , dependent_syntax : ModulePath
                    , dependent_semanticses : Array ModulePath
                    }
  | ModuleTheory { theory : Theory
                 , dependent_semantics : ModulePath
                 , dependent_theories : Array ModulePath
                 }
  | ModulePackage (Dict ModuleName Module)

type alias Repository
  = { root_package : Module
    , global_config : GlobalConfig
      -- we might add more thing here, if it need to be save
    , version : Int
    }
