module Models.Repository where

import Models.GlobalConfig exposing (GlobalConfig)
import Models.Module exposing (Module)

type alias Repository
  = { root_package : Module
    , global_config : GlobalConfig
      -- TODO: we might add more thing here, if it need to be save
    , version : Int
    }
