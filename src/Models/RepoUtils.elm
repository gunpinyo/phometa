module Models.RepoUtils where

import Dict exposing (Dict)

import Tools.SanityCheck exposing (CheckResult, valid)
import Models.RepoModel exposing (..)

init_package : Package
init_package =
  { dict      = Dict.empty
  , is_folded = False
  , pointer   = Nothing
  }

check_package : Package -> CheckResult
check_package package = valid -- TODO: implment this
