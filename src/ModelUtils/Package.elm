module ModelUtils.Package where

import Dict exposing (Dict)

import Tools.Verification exposing
  (VerificationResult, valid, to_invalid, sequentially_verify)
import Models.Package exposing (Package(..))

initial_package : Package
initial_package =
  PackageConstruct
    { packages = Dict.empty
    , syntaxes = Dict.empty
    , semanticses = Dict.empty
    , theories = Dict.empty
    , is_folded = False
    }

verify_package : Package -> VerificationResult
verify_package package =
  case package of
    PackageConstruct record ->
      valid
  -- TODO:
  --sequentially_verify
  --  [(\() -> -- verify that `root_package` is actually a package
  --      case root_package of
  --        ModulePackage _ -> valid
  --        _ -> to_invalid "root_package: `root_package` should be a package."

  --   )
  --  -- TODO: finish this
  --  ]
