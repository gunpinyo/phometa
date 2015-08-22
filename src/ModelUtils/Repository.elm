module ModelUtils.Repository where

import Tools.Verification exposing (VerificationResult)
import Models.Repository exposing (Repository)
import ModelUtils.GlobalConfig exposing (initial_global_config)
import ModelUtils.Module exposing (initial_package, verify_root_package)

initial_repository : Repository
initial_repository =
  { root_package = initial_package
  , global_config = initial_global_config
  , version = 1
  }

verify_repository : Repository -> VerificationResult
verify_repository repository =
  verify_root_package repository.root_package
