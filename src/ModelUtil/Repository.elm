module ModelUtil.Repository where

import Dict exposing (Dict)

import Model.Repository exposing (Module(..), Repository)
import ModelUtil.GlobalConfig exposing (initial_global_config)

initial_package : Module
initial_package = ModulePackage (Dict.empty)

initial_repository : Repository
initial_repository
  = { root_package = initial_package
    , global_config = initial_global_config
    , version = 1
    }
