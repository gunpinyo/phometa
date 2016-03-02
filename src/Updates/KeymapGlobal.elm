module Updates.KeymapGlobal where

import Focus exposing ((=>))

import Models.Focus exposing (..)
import Models.Cursor exposing (PaneCursor(..))
import Models.Grid exposing (Grids(..), Grid(..), get_number_of_grids)
import Models.Model exposing (Model, KeyBinding(..), Command, Keymap)
import Updates.KeymapUtils exposing (build_keymap, merge_keymaps)

keymap_global : Model -> Keymap
keymap_global model =
  build_keymap [
    ("Ctrl-Space", "menu", KbPrefix <| merge_keymaps (build_keymap [
      ("w", "window related", KbPrefix <| build_keymap [
        ("p", "toggle package pane", KbCmd cmd_toggle_package_pane),
        ("k", "toggle keymap pane", KbCmd cmd_toggle_keymap_pane),
        ("1", "reform grids to 1x1", KbCmd <| cmd_reform_grids 1 1),
        ("2", "reform grids to 1x2", KbCmd <| cmd_reform_grids 1 2),
        ("3", "reform grids to 1x3", KbCmd <| cmd_reform_grids 1 3),
        ("4", "reform grids to 2x2", KbCmd <| cmd_reform_grids 2 2),
        ("8", "reform grids to 2x1", KbCmd <| cmd_reform_grids 2 1),
        ("9", "reform grids to 3x1", KbCmd <| cmd_reform_grids 3 1)
      ])
    ]) (keymap_pane_cursor model))
  ]

keymap_pane_cursor : Model -> Keymap
keymap_pane_cursor model =
  [("0", "jump to package pane", PaneCursorPackage),
   ("1", "jump to first grid pane", PaneCursorGrid1),
   ("2", "jump to second grid pane", PaneCursorGrid2),
   ("3", "jump to third grid pane", PaneCursorGrid3),
   ("4", "jump to fourth grid pane", PaneCursorGrid4)]
  |> List.map (\ (key, descr, pane_cursor) ->
         (key, descr, KbCmd <| cmd_change_pane_cursor pane_cursor))
  |> List.take ((get_number_of_grids model.grids) + 1)
  |> build_keymap

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
