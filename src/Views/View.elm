module Views.View where

import Signal exposing (Address)

import Html exposing (Html, div)
import Html.Lazy exposing (lazy2)

import Tools.Flex exposing (flex_css_style, fullbleed)
import Models.InputAction exposing (InputAction)
import Models.Model exposing (Model)
import ModelUtils.Model exposing (initial_component_path)
import Views.Pane exposing (show_pane)

view' : Address InputAction -> Model -> Html
view' address model =
  let html = show_pane address model model.main_pane initial_component_path
      css_style = model.repository.global_config.style.view.css_style
   in fullbleed <| flex_css_style css_style html

view : Address InputAction -> Model -> Html
view = lazy2 view'
