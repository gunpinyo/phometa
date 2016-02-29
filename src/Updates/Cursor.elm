module Updates.Cursor where

import Focus exposing ((=>))

import Models.Focus exposing (grids_, pane_cursor_)
import Models.Cursor exposing (CursorInfo, cursor_info_get_ref_path)
import Models.Grid exposing (Grid(..), focus_grid)
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
