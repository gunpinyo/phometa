module Updates.Keymap where

import Dict

import Models.Mode exposing (MajorMode(..))
import Models.Model exposing (Command, KeyBinding(..), Keymap)
import Updates.KeymapUtils exposing (merge_keymaps, build_keymap)

cmd_assign_root_keymap : Command
cmd_assign_root_keymap model =
  { model | root_keymap = merge_keymaps global_keymap
                            (major_mode_keymap model.major_mode)}

cmd_press_prefix_key : Keymap -> Command
cmd_press_prefix_key keymap model =
  { model | root_keymap = merge_keymaps model.root_keymap keymap }

global_keymap : Keymap
global_keymap =
  build_keymap [
    ("ctrl space", "menu", KeyBindingPrefix <| build_keymap [
      ("w", "window related", KeyBindingPrefix <| build_keymap [
        -- ("p", "toggle package pane", KeyBindingCommand cmd_toggle_package_pane),
        -- ("k", "toggle keymap pane", KeyBindingCommand cmd_toggle_keymap_pane)
      ])
    ])
  ]

major_mode_keymap : MajorMode -> Keymap
major_mode_keymap major_mode =
  case major_mode of
    MajorModeDefault -> build_keymap [] -- TODO: finish this
    _                -> build_keymap [] -- TODO: finish this
