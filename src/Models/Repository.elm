module Models.Repository where

import Models.GlobalConfig exposing (GlobalConfig)
import Models.Package exposing (Package)

type alias Repository
  = { root_package : Package
    , global_config : GlobalConfig
      -- TODO: we might add more thing here, if it need to be save
    , version : Int
    }
