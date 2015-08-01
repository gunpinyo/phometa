module View.MiniBuffer where

import Signal exposing (Address)

import Html exposing (Html, text)

import Model.InputAction exposing (InputAction)
import Model.Model exposing (Model)
import Model.MiniBuffer exposing (MiniBuffer(..))

show_mini_buffer : Address InputAction -> Model -> Html
show_mini_buffer address model =
  case model.mini_buffer of
    MiniBufferDebug message -> text message
    -- TODO: write more
