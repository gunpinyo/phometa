module ModelUtils.Package where

import Dict exposing (Dict)

import Tools.Verification exposing (VerificationResult, sequentially_verify)
import Models.Package exposing (Package(..))
import Models.Model exposing (Model)
import Models.EtcAlias exposing(VerifyModel)
import ModelUtils.Syntax exposing (verify_syntax)

initial_package : Package
initial_package =
  PackageConstruct
    { packages = Dict.empty
    , syntaxes = Dict.empty
    , semanticses = Dict.empty
    , theories = Dict.empty
    , is_folded = False
    }

verify_package : Package -> VerifyModel
verify_package package model =
  case package of
    PackageConstruct record ->
      sequentially_verify
        <| List.map
             (\package -> (\() -> verify_package package model))
             (Dict.values record.packages)
        ++ List.map
             (\syntax -> (\() -> verify_syntax syntax model))
             (Dict.values record.syntaxes)
        -- TODO: enable this when finish implement semantics and theory
        --++ List.map
        --     (\semantics -> (\() -> verify_semantics model semantics))
        --     (Dict.values record.semanticses)
        --++ List.map
        --     (\theory -> (\() -> verify_theory model theory))
        --     (Dict.values record.theories)

--exist_in_package : Package -> M
-- TODO:
