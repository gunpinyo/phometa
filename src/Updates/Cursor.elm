module Updates.Cursor where

import Focus exposing ((=>))

import Models.Focus exposing (..)
import Models.Cursor exposing (PaneCursor, CursorInfo, cursor_info_get_ref_path)
import Models.Grid exposing (Grids(..), Grid(..), focus_grid)
import Models.Model exposing (Command)

-- TODO: finish this
-- cmd_set_mode_from_cursor : Command
-- cmd_set_mode_from_cursor model =
--   case model.pane_cursor of
--     PaneCursorPackage -> ModePackagePane
--     PaneCursorGrid1

cmd_click_block : CursorInfo -> Command
cmd_click_block cursor_info model =
  let new_cursor_path = cursor_info_get_ref_path cursor_info
      model' = Focus.set pane_cursor_ cursor_info.pane_cursor model
   in Focus.update (grids_ => focus_grid cursor_info.pane_cursor)
        (\grid -> case grid of
          GridHome _ -> GridHome new_cursor_path
          GridModule module_path _ -> GridModule module_path new_cursor_path
          GridNode node_path _ -> GridNode node_path new_cursor_path)
        model'

cmd_change_pane_cursor : PaneCursor -> Command
cmd_change_pane_cursor pane_cursor model =
  Focus.set pane_cursor_ pane_cursor model

cmd_toggle_package_pane : Command
cmd_toggle_package_pane model =
  Focus.update (config_ => show_package_pane_) not model

cmd_toggle_keymap_pane : Command
cmd_toggle_keymap_pane model =
  Focus.update (config_ => show_keymap_pane_) not model

cmd_reform_grids : Int -> Int -> Command
cmd_reform_grids row col model =
  let gh = GridHome []
      (g1, g2, g3, g4) = case model.grids of
                           Grids1x1 g1          -> (g1, gh, gh, gh)
                           Grids1x2 g1 g2       -> (g1, g2, gh, gh)
                           Grids1x3 g1 g2 g3    -> (g1, g2, g3, gh)
                           Grids2x1 g1 g2       -> (g1, g2, gh, gh)
                           Grids3x1 g1 g2 g3    -> (g1, g2, g3, gh)
                           Grids2x2 g1 g2 g3 g4 -> (g1, g2, g3, g4)
      grids = case (row, col) of
                (1, 1) -> Grids1x1 g1
                (1, 2) -> Grids1x2 g1 g2
                (1, 3) -> Grids1x3 g1 g2 g3
                (2, 1) -> Grids2x1 g1 g2
                (3, 1) -> Grids3x1 g1 g2 g3
                (2, 2) -> Grids2x2 g1 g2 g3 g4
                _      -> Grids1x1 g1          -- if error, fail safe to Grids1x1
   in Focus.set grids_ grids model
