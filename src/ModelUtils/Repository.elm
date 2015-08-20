module ModelUtils.Repository where

import Models.Repository exposing (Repository)
import ModelUtils.GlobalConfig exposing (initial_global_config)
import ModelUtils.Module exposing (initial_package)

initial_repository : Repository
initial_repository =
  { root_package = initial_package
  , global_config = initial_global_config
  , version = 1
  }
