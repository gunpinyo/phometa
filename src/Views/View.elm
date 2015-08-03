module Views.View where

import Signal exposing (Address)

import Html exposing (Html)
import Html.Attributes exposing (class)
import Html.Lazy exposing (lazy2)

import Tools.Flex exposing (flex_div, fullbleed)
import Tools.HtmlExtra exposing (get_css_link_node)
import Models.InputAction exposing (InputAction)
import Models.Model exposing (Model)
import ModelUtils.Model exposing (initial_component_path)
import Views.Pane exposing (show_pane)

view' : Address InputAction -> Model -> Html
view' address model =
  let html = show_pane address model model.main_pane initial_component_path
      css_link_node = get_css_link_node "style.css"
   in fullbleed <| flex_div [] [class "view"] [css_link_node, html]

view : Address InputAction -> Model -> Html
view = lazy2 view'
