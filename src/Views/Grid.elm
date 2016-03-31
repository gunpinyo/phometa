module Views.Grid where

import Html exposing (Html, div)
import Html.Attributes exposing (classList)
import Graphics.Element exposing (show)

import Tools.Flex exposing (flex_div, flex_split)
import Tools.HtmlExtra exposing (debug_to_html)
import Models.Cursor exposing (PaneCursor(..), init_cursor_info)
import Models.Grid exposing (Grids(..), Grid(..))
import Models.RepoModel exposing (Node(..))
import Models.RepoUtils exposing (get_node)
import Models.Model exposing (Model)
import Models.ViewState exposing (View)
import Views.Theorem exposing (show_theorem)

show_grids_pane : View
show_grids_pane model =
  case model.grids of
    Grids1x1 grid1 ->
      show_grid_pane PaneCursorGrid1 grid1 model
    Grids1x2 grid1 grid2 ->
      flex_split "row" [] [] [
        (1, show_grid_pane PaneCursorGrid1 grid1 model),
        (1, show_grid_pane PaneCursorGrid2 grid2 model)]
    Grids1x3 grid1 grid2 grid3 ->
      flex_split "row" [] [] [
        (1, show_grid_pane PaneCursorGrid1 grid1 model),
        (1, show_grid_pane PaneCursorGrid2 grid2 model),
        (1, show_grid_pane PaneCursorGrid3 grid3 model)]
    Grids2x1 grid1 grid2 ->
      flex_split "column" [] [] [
        (1, show_grid_pane PaneCursorGrid1 grid1 model),
        (1, show_grid_pane PaneCursorGrid2 grid2 model)]
    Grids3x1 grid1 grid2 grid3 ->
      flex_split "column" [] [] [
        (1, show_grid_pane PaneCursorGrid1 grid1 model),
        (1, show_grid_pane PaneCursorGrid2 grid2 model),
        (1, show_grid_pane PaneCursorGrid3 grid3 model)]
    Grids2x2 grid1 grid2 grid3 grid4 ->
      flex_split "row" [] [] [
        (1, flex_split "column" [] [] [
          (1, show_grid_pane PaneCursorGrid1 grid1 model),
          (1, show_grid_pane PaneCursorGrid3 grid3 model)]),
        (1, flex_split "column" [] [] [
          (1, show_grid_pane PaneCursorGrid2 grid2 model),
          (1, show_grid_pane PaneCursorGrid4 grid4 model)])]

show_grid_pane : PaneCursor -> Grid -> View
show_grid_pane pane_cursor grid model =
  let has_cursor = model.pane_cursor == pane_cursor
      content = case grid of
        GridHome int_cursor_path -> -- TODO: finish this
          Html.text "Welcome to phometa" -- TODO: finish this
        GridModule module_path int_cursor_path ->
          debug_to_html (module_path, int_cursor_path) -- TODO: finish this
        GridNode node_path int_cursor_path ->
          let cursor_info = init_cursor_info has_cursor
                              int_cursor_path pane_cursor
           in case get_node node_path model of
                Just (NodeTheorem theorem) ->
                  show_theorem cursor_info node_path theorem model
                _  -> debug_to_html node_path -- TODO: finish this
      attrs  = [classList [("pane", True), ("pane-on-cursor", has_cursor)]]
   in -- use div inside flex_div to detach flex
      -- since its elements doesn't depend on monitor size anymore
      flex_div [] attrs [div [] [content]]
