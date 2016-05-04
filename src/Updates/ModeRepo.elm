module Updates.ModeRepo where

import Focus exposing ((=>))

import Models.Focus exposing (pane_cursor_, grids_, is_folded_)
import Models.Cursor exposing (PaneCursor(..))
import Models.RepoModel exposing (PackagePath, ModulePath, NodePath)
import Models.RepoUtils exposing (focus_package, focus_module)
import Models.Model exposing (Model, Keymap, RecordModeRepo)
import Models.Grid exposing (Grid(..), focus_grid)
import Models.Model exposing (Command)
import Updates.CommonCmd exposing (cmd_reset_mode)
import Updates.KeymapUtils exposing (empty_keymap)

keymap_mode_repo : RecordModeRepo -> Model -> Keymap
keymap_mode_repo record model = empty_keymap -- TODO:

cmd_select_node : NodePath -> Command
cmd_select_node node_path model =
  let pane_cursor = if model.pane_cursor == PaneCursorPackage
                      then PaneCursorGrid1 else model.pane_cursor
      grid = GridNode node_path []
   in model
        |> Focus.set pane_cursor_ pane_cursor
        |> Focus.set (grids_ => focus_grid pane_cursor) grid
        |> cmd_reset_mode

cmd_package_fold_unfold : PackagePath -> Command
cmd_package_fold_unfold package_path model =
  Focus.update (focus_package package_path => is_folded_) not model

cmd_module_fold_unfold : ModulePath -> Command
cmd_module_fold_unfold module_path model =
  Focus.update (focus_module module_path => is_folded_) not model
