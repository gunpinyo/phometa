module Model.Repository where

import Dict exposing (Dict)

import Model.Syntax exposing (Syntax)
import Model.Semantics exposing (Semantics)
import Model.Theory exposing (Theory)

type alias ModuleName = String

type alias ModulePath = List ModuleName

type Module
  -- consists of actual syntax and list of dependent syntax
  = ModuleSyntax Syntax (List ModulePath)
  -- consists of actual semantics, dependent syntax,
  --   and list of dependent semantics
  | ModuleSemantics Semantics ModulePath (List ModulePath)
  -- consists of actual theory, dependent semantics,
  --   and list of dependent theory
  | ModuleTheory Theory ModulePath (List ModulePath)
  -- consists of dict that map module name to actual module
  | ModulePackage (Dict ModuleName Module)

type alias Repository
  = { root_package : Module,
      -- we might add more thing here, if it need to be save
      version : List Int
    }
