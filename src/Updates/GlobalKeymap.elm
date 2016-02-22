module Updates.GlobalKeymap where

import Focus exposing ((=>))

import Models.Focus exposing (
  config_, grids_, show_package_pane_, show_keymap_pane_)
import Models.Grid exposing (Grids(..), Grid(..))
import Models.Model exposing (Command, KeyBinding(..), Keymap)
import Updates.KeymapUtils exposing (build_keymap)

global_keymap : Keymap
global_keymap =
  build_keymap [
    ("C-SPC", "menu", KeyBindingPrefix <| build_keymap [
      ("w", "window related", KeyBindingPrefix <| build_keymap [
        ("p", "toggle package pane", KeyBindingCommand cmd_toggle_package_pane),
        ("k", "toggle keymap pane", KeyBindingCommand cmd_toggle_keymap_pane),
        ("1", "reform grids to 1x1", KeyBindingCommand <| cmd_reform_grids 1 1),
        ("2", "reform grids to 1x1", KeyBindingCommand <| cmd_reform_grids 1 2),
        ("3", "reform grids to 1x1", KeyBindingCommand <| cmd_reform_grids 1 3),
        ("4", "reform grids to 1x1", KeyBindingCommand <| cmd_reform_grids 2 2),
        ("8", "reform grids to 1x1", KeyBindingCommand <| cmd_reform_grids 2 1),
        ("9", "reform grids to 1x1", KeyBindingCommand <| cmd_reform_grids 3 1)
      ])
    ])
  ]

cmd_toggle_package_pane : Command
cmd_toggle_package_pane model =
  Focus.update (config_ => show_package_pane_) not model

cmd_toggle_keymap_pane : Command
cmd_toggle_keymap_pane model =
  Focus.update (config_ => show_keymap_pane_) not model

cmd_reform_grids : Int -> Int -> Command
cmd_reform_grids row col model =
  let gh = GridHome
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
