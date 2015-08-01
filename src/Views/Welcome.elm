module Views.Welcome where

import Signal exposing (Address)

import Html exposing (Html, text)

import Models.InputAction exposing (InputAction)
import Models.Model exposing (Model)

show_welcome : Address InputAction -> Model -> Html
show_welcome address model =
  text <| "Welcomee to phometa!!!"
  -- TODO: finish this