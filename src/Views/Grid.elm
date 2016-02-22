module Views.Grid where

import Html exposing (Html)
import Html.Attributes exposing (class)
import Graphics.Element exposing (show)

import Tools.Flex exposing (flex_div, flex_split)
import Tools.HtmlExtra exposing (debug_to_html)
import Models.Grid exposing (Grids(..), Grid(..))
import Models.Model exposing (Model)
import Models.ViewState exposing (View)

show_grids_pane : View
show_grids_pane model =
  case model.grids of
    Grids1x1 grid1 ->
      show_grid_pane grid1 model
    Grids1x2 grid1 grid2 ->
      flex_split "row" [] [] [
        (1, show_grid_pane grid1 model),
        (1, show_grid_pane grid2 model)]
    Grids1x3 grid1 grid2 grid3 ->
      flex_split "row" [] [] [
        (1, show_grid_pane grid1 model),
        (1, show_grid_pane grid2 model),
        (1, show_grid_pane grid3 model)]
    Grids2x1 grid1 grid2 ->
      flex_split "column" [] [] [
        (1, show_grid_pane grid1 model),
        (1, show_grid_pane grid2 model)]
    Grids3x1 grid1 grid2 grid3 ->
      flex_split "column" [] [] [
        (1, show_grid_pane grid1 model),
        (1, show_grid_pane grid2 model),
        (1, show_grid_pane grid3 model)]
    Grids2x2 grid1 grid2 grid3 grid4 ->
      flex_split "row" [] [] [
        (1, flex_split "column" [] [] [
              (1, show_grid_pane grid1 model),
              (1, show_grid_pane grid2 model)]),
        (1, flex_split "column" [] [] [
              (1, show_grid_pane grid3 model),
              (1, show_grid_pane grid4 model)])]

show_grid_pane : Grid -> View
show_grid_pane grid model =
  case grid of
    GridHome -> -- TODO: finish this
      flex_div [] [class "pane"] [Html.text "Welcome to phometa"]
    GridModule module_path pointer ->
      debug_to_html (module_path, pointer) -- TODO: finish this
    GridNode node_path ->
      debug_to_html node_path -- TODO: finish this
