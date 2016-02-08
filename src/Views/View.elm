module Views.View where

import Html exposing (Html)
import Html.Attributes exposing (class)
import Html.Lazy exposing (lazy2)

import Tools.Flex exposing (flex_div, fullbleed)
import Tools.HtmlExtra exposing (import_css, import_javascript)
import Models.Model exposing (Model)

show_window : Model -> Html
show_window model =
  let attributes = [
        class "window"]
      elements = [
        -- bootstrap css cdn
        import_css <| "http://maxcdn.bootstrapcdn.com/"
                   ++ "bootstrap/3.3.5/css/bootstrap.min.css",
        -- our own css style
        import_css "style.css"]
        -- main pane
        --show_pane model.root_pane initial_component_path address model
   in fullbleed <| flex_div [] attributes elements

view : Model -> Html
view = lazy2 show_window
