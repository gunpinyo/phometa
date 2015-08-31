module Views.MiniBuffer where

import Signal exposing (Address)

import Html exposing (Html, text)

import Models.InputAction exposing (InputAction)
import Models.Model exposing (Model)
import Models.MiniBuffer exposing (MiniBuffer(..))

show_mini_buffer : Address InputAction -> Model -> Html
show_mini_buffer address model =
  case model.mini_buffer of
    MiniBufferDebug message -> text ("DEBUG: " ++ message)
    MiniBufferError message -> text ("ERROR: " ++ message)
    -- TODO: write more
