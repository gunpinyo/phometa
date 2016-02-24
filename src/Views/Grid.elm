module Views.Grid where

import Html exposing (Html)
import Html.Attributes exposing (classList)
import Graphics.Element exposing (show)

import Tools.Flex exposing (flex_div, flex_split)
import Tools.HtmlExtra exposing (debug_to_html)
import Models.Cursor exposing (HasCursor, PaneCursor(..))
import Models.Grid exposing (Grids(..), Grid(..))
import Models.RepoModel exposing (Node(..))
import Models.RepoUtils exposing (get_node)
import Models.Model exposing (Model)
import Models.ViewState exposing (View)
import Views.Definition exposing (show_definition)

show_grids_pane : View
show_grids_pane model =
  case model.grids of
    Grids1x1 grid1 ->
      show_grid_pane (model.pane_cursor == PaneCursorGrid1) grid1 model
    Grids1x2 grid1 grid2 ->
      flex_split "row" [] [] [
        (1, show_grid_pane (model.pane_cursor == PaneCursorGrid1) grid1 model),
        (1, show_grid_pane (model.pane_cursor == PaneCursorGrid2) grid2 model)]
    Grids1x3 grid1 grid2 grid3 ->
      flex_split "row" [] [] [
        (1, show_grid_pane (model.pane_cursor == PaneCursorGrid1) grid1 model),
        (1, show_grid_pane (model.pane_cursor == PaneCursorGrid2) grid2 model),
        (1, show_grid_pane (model.pane_cursor == PaneCursorGrid3) grid3 model)]
    Grids2x1 grid1 grid2 ->
      flex_split "column" [] [] [
        (1, show_grid_pane (model.pane_cursor == PaneCursorGrid1) grid1 model),
        (1, show_grid_pane (model.pane_cursor == PaneCursorGrid2) grid2 model)]
    Grids3x1 grid1 grid2 grid3 ->
      flex_split "column" [] [] [
        (1, show_grid_pane (model.pane_cursor == PaneCursorGrid1) grid1 model),
        (1, show_grid_pane (model.pane_cursor == PaneCursorGrid2) grid2 model),
        (1, show_grid_pane (model.pane_cursor == PaneCursorGrid3) grid3 model)]
    Grids2x2 grid1 grid2 grid3 grid4 ->
      flex_split "row" [] [] [
        (1, flex_split "column" [] [] [
          (1, show_grid_pane
                (model.pane_cursor == PaneCursorGrid1) grid1 model),
          (1, show_grid_pane
                (model.pane_cursor == PaneCursorGrid3) grid3 model)]),
        (1, flex_split "column" [] [] [
          (1, show_grid_pane
                (model.pane_cursor == PaneCursorGrid2) grid2 model),
          (1, show_grid_pane
                (model.pane_cursor == PaneCursorGrid4) grid4 model)])]

show_grid_pane : HasCursor -> Grid -> View
show_grid_pane has_cursor grid model =
  let content = case grid of
                  GridHome -> -- TODO: finish this
                    Html.text "Welcome to phometa" -- TODO: finish this
                  GridModule module_path cursor ->
                    debug_to_html (module_path, cursor) -- TODO: finish this
                  GridNode node_path ->
                    case get_node node_path model of
                      Just (NodeDefinition definition) ->
                        show_definition
                            has_cursor node_path.node_name definition model
                      _  -> debug_to_html node_path -- TODO: finish this
      attrs  = [classList [("pane", True), ("pane-on-cursor", has_cursor)]]
   in flex_div [] attrs [content]
