module Updates.KeymapGlobal where

import Focus exposing ((=>))

import Models.Cursor exposing (PaneCursor(..))
import Models.Grid exposing (Grids(..), Grid(..), get_number_of_grids)
import Models.Model exposing (Model, KeyBinding(..), Command, Keymap)
import Updates.Cursor exposing (cmd_change_pane_cursor, cmd_toggle_keymap_pane,
                                cmd_toggle_package_pane, cmd_reform_grids)
import Updates.KeymapUtils exposing (build_keymap, merge_keymaps)

keymap_global : Model -> Keymap
keymap_global model =
  build_keymap [
    ("Escape", "global keymap", KbPrefix <| merge_keymaps (build_keymap [
      ("p", "toggle package pane", KbCmd cmd_toggle_package_pane),
      ("k", "toggle keymap pane", KbCmd cmd_toggle_keymap_pane),
      ("1", "reform grids to 1x1", KbCmd <| cmd_reform_grids 1 1),
      ("2", "reform grids to 1x2", KbCmd <| cmd_reform_grids 1 2),
      ("3", "reform grids to 1x3", KbCmd <| cmd_reform_grids 1 3),
      ("4", "reform grids to 2x2", KbCmd <| cmd_reform_grids 2 2),
      ("8", "reform grids to 2x1", KbCmd <| cmd_reform_grids 2 1),
      ("9", "reform grids to 3x1", KbCmd <| cmd_reform_grids 3 1)
    ]) (keymap_pane_cursor model))
  ]

keymap_pane_cursor : Model -> Keymap
keymap_pane_cursor model =
  [("Shift-0", "jump to package pane", PaneCursorPackage),
   ("Shift-1", "jump to first grid pane", PaneCursorGrid1),
   ("Shift-2", "jump to second grid pane", PaneCursorGrid2),
   ("Shift-3", "jump to third grid pane", PaneCursorGrid3),
   ("Shift-4", "jump to fourth grid pane", PaneCursorGrid4)]
  |> List.map (\ (key, descr, pane_cursor) ->
         (key, descr, KbCmd <| cmd_change_pane_cursor pane_cursor))
  |> List.take ((get_number_of_grids model.grids) + 1)
  |> build_keymap
