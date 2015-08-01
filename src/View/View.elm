module View.View where

import Signal exposing (Address)

import Html exposing (Html, div)

import Model.InputAction exposing (InputAction)
import Model.Model exposing (Model)
import View.Pane exposing (show_pane)
import Tool.Flex exposing (flex_css, fullbleed)

view : Address InputAction -> Model -> Html
view address model =
  let html = show_pane address model model.main_pane
      view_style = model.repository.global_config.style.view
      css_block =
        [ ("font-family", view_style.font_family)
        , ("font-size", view_style.font_size)
        , ("color", view_style.foreground_color)
        ]
   in fullbleed <| flex_css css_block html
