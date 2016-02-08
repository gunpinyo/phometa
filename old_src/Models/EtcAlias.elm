module Models.EtcAlias where

import Signal exposing (Address)

import Html exposing (Html)

import Tools.Verification exposing (VerificationResult)
import Models.Command exposing (Command)
import Models.InputAction exposing (InputAction)
import Models.Model exposing (Model)

type alias VerifyModel
  = Model -> VerificationResult

type alias ProcessCommand
  = Model -> (List Command, Model)

type alias View
  = Address InputAction -> Model -> Html
