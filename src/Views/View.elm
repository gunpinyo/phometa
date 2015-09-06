module Views.View where

import Html.Attributes exposing (class)
import Html.Lazy exposing (lazy2)

import Tools.Flex exposing (flex_div, fullbleed)
import Tools.HtmlExtra exposing (import_css, import_javascript, on_mouse_leave)
import Models.InputAction exposing (InputAction(..))
import ModelUtils.InputAction exposing (initial_component_path)
import Models.EtcAlias exposing (View)
import Views.Pane exposing (show_pane)

show_window : View
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
        , show_pane model.root_pane initial_component_path address model
        ]
   in fullbleed <| flex_div [] attributes sub_html_list

view : View
view = lazy2 show_window
