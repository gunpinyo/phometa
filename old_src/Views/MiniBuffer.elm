module Views.MiniBuffer where

import Html exposing (text)

import Models.MiniBuffer exposing (MiniBuffer(..))
import Models.EtcAlias exposing (View)

show_mini_buffer : View
show_mini_buffer address model =
  case model.mini_buffer of
    MiniBufferDebug message -> text ("DEBUG: " ++ message)
    MiniBufferError message -> text ("ERROR: " ++ message)
    _ -> text ("TODO: write more")
    -- TODO: write more
