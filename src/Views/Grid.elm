module Views.Grid where

import Html exposing (Html, div)
import Html.Attributes exposing (classList, style)

import Tools.Flex exposing (flex_div, flex_split)
import Tools.HtmlExtra exposing (debug_to_html, on_click)
import Models.Cursor exposing (PaneCursor(..), init_cursor_info)
import Models.Grid exposing (Grids(..), Grid(..))
import Models.RepoModel exposing (Node(..))
import Models.RepoUtils exposing (get_node)
import Models.Model exposing (MicroModeModule(..),
                              MicroModeComment(..),
                              MicroModeGrammar(..),
                              MicroModeRule(..),
                              MicroModeTheorem(..))
import Models.Action exposing (Action(..), address)
import Models.ViewState exposing (View)
import Updates.Cursor exposing (cmd_change_pane_cursor)
import Updates.CommonCmd exposing (cmd_nothing)
import Updates.ModeModule exposing (cmd_enter_mode_module)
import Updates.ModeComment exposing (cmd_enter_mode_comment)
import Updates.ModeGrammar exposing (cmd_enter_mode_grammar)
import Updates.ModeRule exposing (cmd_enter_mode_rule)
import Updates.ModeTheorem exposing (cmd_enter_mode_theorem)
import Views.Home exposing (show_home)
import Views.Module exposing (show_module)
import Views.Comment exposing (show_comment)
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
      (content, on_click_cmd) = case grid of
        GridHome int_cursor_path ->
          (show_home (cursor_func int_cursor_path) model, cmd_nothing)
        GridModule module_path int_cursor_path ->
          let cursor_info = cursor_func int_cursor_path
              module_content = show_module cursor_info module_path model
              on_click_cmd' = cmd_enter_mode_module
                                { module_path      = module_path
                                , top_cursor_info  = cursor_info
                                , sub_cursor_path  = []
                                , micro_mode       = MicroModeModuleNavigate }
           in (div [style [("width", "100%")]] [module_content], on_click_cmd')
        GridNode node_path int_cursor_path ->
          let cursor_info = cursor_func int_cursor_path
              (node_content, on_click_cmd') =
                case get_node node_path model of
                  Nothing -> ( show_home cursor_info model, cmd_nothing )
                  Just (NodeComment comment) ->
                    (show_comment cursor_info node_path comment model
                    , cmd_enter_mode_comment
                        { node_path        = node_path
                        , top_cursor_info  = cursor_info
                        , sub_cursor_path  = []
                        , micro_mode       = MicroModeCommentNavigate })
                  Just (NodeGrammar grammar) ->
                    (show_grammar cursor_info node_path grammar model
                    , cmd_enter_mode_grammar
                        { node_path        = node_path
                        , top_cursor_info  = cursor_info
                        , sub_cursor_path  = []
                        , micro_mode       = MicroModeGrammarNavigate })
                  Just (NodeRule rule) ->
                    (show_rule cursor_info node_path rule model
                    , cmd_enter_mode_rule
                        { node_path        = node_path
                        , top_cursor_info  = cursor_info
                        , sub_cursor_path  = []
                        , micro_mode       = MicroModeRuleNavigate })
                  Just (NodeTheorem theorem has_locked) ->
                    (show_theorem cursor_info node_path theorem has_locked model
                    , cmd_enter_mode_theorem
                        { node_path        = node_path
                        , top_cursor_info  = cursor_info
                        , sub_cursor_path  = []
                        , micro_mode       = MicroModeTheoremNavigate })
           in -- if it is not `GridHome` use div inside flex_div to detach flex
              -- since its elements doesn't depend on monitor height anymore
              (div [style [("width", "100%")]] [node_content], on_click_cmd')
      attrs  = [ classList [("pane", True), ("pane-on-cursor", has_cursor)]
               , on_click address
                   (ActionCommand <| cmd_change_pane_cursor pane_cursor
                                       >> on_click_cmd) ]
   in flex_div [] attrs [content]
