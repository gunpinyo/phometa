module Updates.Keymap where

import Dict

import Focus

import Models.Focus exposing (root_keymap_)
import Models.Mode exposing (MajorMode(..))
import Models.Model exposing (Command, KeyBinding(..), Keymap)
import Updates.KeymapUtils exposing (merge_keymaps, build_keymap)

cmd_assign_root_keymap : Command
cmd_assign_root_keymap model =
  let keymap = merge_keymaps global_keymap (major_mode_keymap model.major_mode)
   in Focus.set root_keymap_ keymap model

cmd_press_prefix_key : Keymap -> Command
cmd_press_prefix_key keymap model =
  let new_keymap = merge_keymaps keymap <| build_keymap [
                     ("ESC", "quit prefix keystrokes",
                      KeyBindingCommand cmd_assign_root_keymap)]
   in Focus.set root_keymap_ new_keymap model

global_keymap : Keymap
global_keymap =
  build_keymap [
    ("C-SPC", "menu", KeyBindingPrefix <| build_keymap [
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
