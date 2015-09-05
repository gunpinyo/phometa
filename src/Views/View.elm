module Views.View where

import Signal exposing (Address)

import Html exposing (Html)
import Html.Attributes exposing (class)
import Html.Lazy exposing (lazy2)

import Tools.Flex exposing (flex_div, fullbleed)
import Tools.HtmlExtra exposing (import_css, import_javascript, on_mouse_leave)
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
        [ -- bootstrap css cdn
          import_css
            <| "http://maxcdn.bootstrapcdn.com/"
            ++ "bootstrap/3.3.5/css/bootstrap.min.css"
          -- our own css style
        , import_css "style.css"
          -- main pane
        , show_pane address model model.root_pane initial_component_path
        ]
   in fullbleed <| flex_div [] attributes sub_html_list

view : Address InputAction -> Model -> Html
view = lazy2 show_window
