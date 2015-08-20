module ModelUtils.Module where

import Dict exposing (Dict)

import Models.Module exposing (Module(..))

initial_package : Module
initial_package = ModulePackage (Dict.empty)
