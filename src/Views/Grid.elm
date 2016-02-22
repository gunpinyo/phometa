module Views.Grid where

import Html exposing (Html)
import Html.Attributes exposing (class)
import Graphics.Element exposing (show)

import Tools.Flex exposing (flex_div, flex_split)
import Tools.HtmlExtra exposing (debug_to_html)
import Models.Grid exposing (Grid(..), GridElem(..))
import Models.Model exposing (Model)

show_grid_pane : Model -> Html
show_grid_pane model =
  case model.grid of
    Grid1x1 elem1 ->
      show_grid_elem_pane elem1 model
    Grid1x2 elem1 elem2 ->
      flex_split "row" [] [] [
        (1, show_grid_elem_pane elem1 model),
        (1, show_grid_elem_pane elem2 model)]
    Grid1x3 elem1 elem2 elem3 ->
      flex_split "row" [] [] [
        (1, show_grid_elem_pane elem1 model),
        (1, show_grid_elem_pane elem2 model),
        (1, show_grid_elem_pane elem3 model)]
    Grid2x1 elem1 elem2 ->
      flex_split "column" [] [] [
        (1, show_grid_elem_pane elem1 model),
        (1, show_grid_elem_pane elem2 model)]
    Grid3x1 elem1 elem2 elem3 ->
      flex_split "column" [] [] [
        (1, show_grid_elem_pane elem1 model),
        (1, show_grid_elem_pane elem2 model),
        (1, show_grid_elem_pane elem3 model)]
    Grid2x2 elem1 elem2 elem3 elem4 ->
      flex_split "row" [] [] [
        (1, flex_split "column" [] [] [
              (1, show_grid_elem_pane elem1 model),
              (1, show_grid_elem_pane elem2 model)]),
        (1, flex_split "column" [] [] [
              (1, show_grid_elem_pane elem3 model),
              (1, show_grid_elem_pane elem4 model)])]

show_grid_elem_pane : GridElem -> Model -> Html
show_grid_elem_pane elem model =
  case elem of
    GridElemHome -> -- TODO: finish this
      flex_div [] [class "pane"] [Html.text "Welcome to phometa"]
    GridElemModule module_path ->
      debug_to_html module_path -- TODO: finish this
    GridElemNode module_path node_name ->
      debug_to_html (module_path, node_name) -- TODO: finish this
