module Models.Package where

import Dict exposing (Dict)

import Models.Module exposing (ModuleName)
import Models.Syntax exposing (Syntax)
import Models.Semantics exposing (Semantics)
import Models.Theory exposing (Theory)


type Package
  = PackageConstruct
      { packages : Dict ModuleName Package
      , syntaxes : Dict ModuleName Syntax
      , semanticses : Dict ModuleName Semantics
      , theories : Dict ModuleName Theory
      }
