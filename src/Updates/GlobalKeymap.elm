module Updates.GlobalKeymap where

import Focus exposing ((=>))

import Models.Focus exposing (
  config_, grid_, is_package_pane_hided_, is_keymap_pane_hided_)
import Models.Grid exposing (Grid(..), GridElem(..))
import Models.Model exposing (Command, KeyBinding(..), Keymap)
import Updates.KeymapUtils exposing (build_keymap)

global_keymap : Keymap
global_keymap =
  build_keymap [
    ("C-SPC", "menu", KeyBindingPrefix <| build_keymap [
      ("w", "window related", KeyBindingPrefix <| build_keymap [
        ("p", "toggle package pane", KeyBindingCommand cmd_toggle_package_pane),
        ("k", "toggle keymap pane", KeyBindingCommand cmd_toggle_keymap_pane),
        ("1", "switch grid to 1x1", KeyBindingCommand <| cmd_switch_grid 1 1),
        ("2", "switch grid to 1x1", KeyBindingCommand <| cmd_switch_grid 1 2),
        ("3", "switch grid to 1x1", KeyBindingCommand <| cmd_switch_grid 1 3),
        ("4", "switch grid to 1x1", KeyBindingCommand <| cmd_switch_grid 2 2),
        ("8", "switch grid to 1x1", KeyBindingCommand <| cmd_switch_grid 2 1),
        ("9", "switch grid to 1x1", KeyBindingCommand <| cmd_switch_grid 3 1)
      ])
    ])
  ]

cmd_toggle_package_pane : Command
cmd_toggle_package_pane model =
  Focus.update (config_ => is_package_pane_hided_) not model

cmd_toggle_keymap_pane : Command
cmd_toggle_keymap_pane model =
  Focus.update (config_ => is_keymap_pane_hided_) not model

cmd_switch_grid : Int -> Int -> Command
cmd_switch_grid row col model =
  let eh = GridElemHome
      (e1, e2, e3, e4) = case model.grid of
                           Grid1x1 e1          -> (e1, eh, eh, eh)
                           Grid1x2 e1 e2       -> (e1, e2, eh, eh)
                           Grid1x3 e1 e2 e3    -> (e1, e2, e3, eh)
                           Grid2x1 e1 e2       -> (e1, e2, eh, eh)
                           Grid3x1 e1 e2 e3    -> (e1, e2, e3, eh)
                           Grid2x2 e1 e2 e3 e4 -> (e1, e2, e3, e4)
      grid = case (row, col) of
               (1, 1) -> Grid1x1 e1
               (1, 2) -> Grid1x2 e1 e2
               (1, 3) -> Grid1x3 e1 e2 e3
               (2, 1) -> Grid2x1 e1 e2
               (3, 1) -> Grid3x1 e1 e2 e3
               (2, 2) -> Grid2x2 e1 e2 e3 e4
               _      -> Grid1x1 e1           -- if error, fail safe to Grid1x1
   in Focus.set grid_ grid model
