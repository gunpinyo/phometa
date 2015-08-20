module Models.Module where

import Array exposing (Array)
import Dict exposing (Dict)

import Models.ModuleHeader exposing (ModuleName, ModulePath)
import Models.Syntax exposing (Syntax)
import Models.Semantics exposing (Semantics)
import Models.Theory exposing (Theory)

-- constrain:
--   - each `ModulePath` represented inside {syntax, semantics, theory} must
--       - exist in `root_package` of `Repository`
--       - have the same type corresponded to its name
--           eg. each element in dependent_syntaxes must be `ModuleSyntax`
--  - for dependent_{syntaxes, semanticses, theories}
--      it must not duplicate elements.
--      e.g. syntax can't import another syntax twice.
type Module
  = ModuleSyntax Syntax
  | ModuleSemantics Semantics
  | ModuleTheory Theory
  | ModulePackage (Dict ModuleName Module)
