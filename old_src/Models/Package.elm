module Models.Package where

import Dict exposing (Dict)

import Models.Module exposing (ModuleName)
import Models.Syntax exposing (Syntax)
import Models.Semantics exposing (Semantics)
import Models.Theory exposing (Theory)

type alias Package
  = { syntaxes : Dict ModuleName Syntax
    , semanticses : Dict ModuleName Semantics
    , theories : Dict ModuleName Theory
    , packages : Dict ModuleName PackageDatatype
    , is_folded : Bool                        -- for ui fold/unfold
    }

type PackageDatatype
  = PackageConstruct Package
