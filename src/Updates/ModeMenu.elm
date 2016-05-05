module Updates.ModeMenu where

import Focus exposing ((=>))

import Models.Focus exposing (mode_)
import Models.Model exposing (Model, KeyBinding(..), Command, Keymap, Mode(..))
import Updates.CommonCmd exposing (cmd_nothing, cmd_reset_mode)
import Updates.Cursor exposing (cmd_change_pane_cursor, cmd_toggle_keymap_pane,
                                cmd_toggle_package_pane, cmd_reform_grids)
import Updates.KeymapUtils exposing (build_keymap, merge_keymaps)

cmd_enter_mode_menu : Command
cmd_enter_mode_menu model =
  model |> cmd_reset_mode
        |> Focus.set mode_ ModeMenu

keymap_mode_menu : Model -> Keymap
keymap_mode_menu model =
  build_keymap
    <| List.map (\ (key_prefix, key_desc, cmd) ->
         ( key_prefix, key_desc, KbCmd <| cmd_reset_mode >> cmd ))
    <| [ ("p", "toggle package pane", cmd_toggle_package_pane)
       , ("k", "toggle keymap pane", cmd_toggle_keymap_pane)
       , ("q", "quit menu", cmd_nothing)
       , ("1", "reform grids to 1x1", cmd_reform_grids 1 1)
       , ("2", "reform grids to 1x2", cmd_reform_grids 1 2)
       , ("3", "reform grids to 1x3", cmd_reform_grids 1 3)
       , ("4", "reform grids to 2x2", cmd_reform_grids 2 2)
       , ("8", "reform grids to 2x1", cmd_reform_grids 2 1)
       , ("9", "reform grids to 3x1", cmd_reform_grids 3 1)
       ]
