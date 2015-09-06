module ModelUtils.Repository where

import Tools.Verification exposing (VerificationResult)
import Models.Repository exposing (Repository)
import Models.Model exposing (Model)
import Models.EtcAlias exposing(VerifyModel)
import ModelUtils.GlobalConfig exposing (initial_global_config)
import ModelUtils.Package exposing (initial_package, verify_package)

initial_repository : Repository
initial_repository =
  { root_package = initial_package
  , global_config = initial_global_config
  , version = 1
  }

verify_repository : Repository -> VerifyModel
verify_repository repository =
  verify_package repository.root_package
