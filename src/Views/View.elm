module Views.View where

import Signal exposing (Address)

import Html exposing (Html)
import Html.Attributes exposing (class)
import Html.Lazy exposing (lazy2)

import Tools.Flex exposing (flex_div, fullbleed)
import Tools.HtmlExtra exposing (get_css_link_node, on_mouse_leave)
import Models.InputAction exposing (InputAction(..))
import Models.Model exposing (Model)
import ModelUtils.ComponentPath exposing (initial_component_path)
import Views.Pane exposing (show_pane)

show_window : Address InputAction -> Model -> Html
show_window address model =
  let attributes =
        [ class "window"
        , on_mouse_leave address InputActionCurserLeavesWindow
        ]
      sub_html_list =
        [ get_css_link_node "style.css"
        , show_pane address model model.main_pane initial_component_path
        ]
   in fullbleed <| flex_div [] attributes sub_html_list

view : Address InputAction -> Model -> Html
view = lazy2 show_window
