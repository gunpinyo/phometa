module ModelUtils.Module where

import Dict exposing (Dict)

import Tools.Verification exposing
  (VerificationResult, valid, to_invalid, sequentially_verify)
import Models.Module exposing (Module(..))

initial_package : Module
initial_package = ModulePackage (Dict.empty)

verify_root_package : Module -> VerificationResult
verify_root_package root_package =
  sequentially_verify
    [(\() -> -- verify that `root_package` is actually a package
        case root_package of
          ModulePackage _ -> valid
          _ -> to_invalid "root_package: `root_package` should be a package."

     )
    -- TODO: finish this
    ]
