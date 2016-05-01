module Views.Grid where

import Html exposing (Html, div)
import Html.Attributes exposing (classList, style)

import Tools.Flex exposing (flex_div, flex_split)
import Tools.HtmlExtra exposing (debug_to_html, on_click)
import Models.Cursor exposing (PaneCursor(..), init_cursor_info)
import Models.Grid exposing (Grids(..), Grid(..))
import Models.RepoModel exposing (Node(..))
import Models.RepoUtils exposing (get_node)
import Models.Action exposing (Action(..), address)
import Models.ViewState exposing (View)
import Updates.Cursor exposing (cmd_change_pane_cursor)
import Views.Home exposing (show_home)
import Views.Grammar exposing (show_grammar)
import Views.Rule exposing (show_rule)
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
      cursor_func int_cursor_path = init_cursor_info has_cursor
                                      int_cursor_path pane_cursor
      content = case grid of
        GridHome int_cursor_path ->
          show_home (cursor_func int_cursor_path) model
        GridModule module_path int_cursor_path ->
          -- TODO: finish this
          div [] [debug_to_html (module_path, int_cursor_path)]
        GridNode node_path int_cursor_path ->
          let node_content =
                case get_node node_path model of
                  Nothing -> show_home (cursor_func int_cursor_path) model
                  Just (NodeGrammar grammar) ->
                    show_grammar (cursor_func int_cursor_path)
                      node_path grammar model
                  Just (NodeRule rule) ->
                    show_rule (cursor_func int_cursor_path)
                      node_path rule model
                  Just (NodeTheorem theorem has_locked) ->
                    show_theorem (cursor_func int_cursor_path)
                      node_path theorem has_locked model
           in -- if it is not `GridHome` use div inside flex_div to detach flex
              -- since its elements doesn't depend on monitor size anymore
              div [style [("width", "100%")]] [node_content]
      attrs  = [ classList [("pane", True), ("pane-on-cursor", has_cursor)]
               , on_click address
                   (ActionCommand <| cmd_change_pane_cursor pane_cursor) ]
   in flex_div [] attrs [content]
