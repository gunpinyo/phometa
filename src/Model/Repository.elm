module Model.Repository where

import Array exposing (Array)

import Tool.OrderedDict exposing (OrderedDict)
import Model.Syntax exposing (Syntax)
import Model.Semantics exposing (Semantics)
import Model.Theory exposing (Theory)


type alias ModuleName = String

type alias ModulePath = List ModuleName

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
  | ModulePackage (OrderedDict ModuleName Module)

type alias Repository
  = { root_package : Module,
      -- we might add more thing here, if it need to be save
      version : List Int
    }
