module View.View where

import Signal exposing (Address)

import Flex exposing (fullbleed, flexDiv)
import Html exposing (Html)

import Model.InputAction exposing (InputAction)
import Model.Model exposing (Model)
import View.Pane exposing (show_pane)

view : Address InputAction -> Model -> Html
view address model =
  let html = show_pane address model model.main_pane
      style =
        let view_style = model.repository.global_config.style.view
         in [ ("font-family", view_style.font_family)
            , ("font-size", view_style.font_size)
            , ("color", view_style.foreground_color)
            ]
   in fullbleed <| flexDiv style [] [html]
