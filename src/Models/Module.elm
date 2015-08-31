module Models.Module where

import Array exposing (Array)
import Dict exposing (Dict)

import Models.ModuleHeader exposing (ModuleName, ModulePath)
import Models.Syntax exposing (Syntax)
import Models.Semantics exposing (Semantics)
import Models.Theory exposing (Theory)


type Module
  = ModuleSyntax Syntax
  | ModuleSemantics Semantics
  | ModuleTheory Theory
  | ModulePackage (Dict ModuleName Module)
