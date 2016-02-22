module Updates.Keymap where

import Dict

import Focus

import Models.Focus exposing (root_keymap_)
import Models.Mode exposing (MajorMode(..))
import Models.Model exposing (Command, KeyBinding(..), Keymap)
import Updates.KeymapUtils exposing (merge_keymaps, build_keymap)
import Updates.GlobalKeymap exposing (global_keymap)

cmd_assign_root_keymap : Command
cmd_assign_root_keymap model =
  let keymap = merge_keymaps global_keymap (major_mode_keymap model.major_mode)
   in Focus.set root_keymap_ keymap model

cmd_press_prefix_key : Keymap -> Command
cmd_press_prefix_key keymap model =
  let new_keymap = merge_keymaps keymap <| build_keymap [
                     ("ESC", "quit prefix key",
                      KeyBindingCommand cmd_assign_root_keymap)]
   in Focus.set root_keymap_ new_keymap model

major_mode_keymap : MajorMode -> Keymap
major_mode_keymap major_mode =
  case major_mode of
    MajorModeDefault -> build_keymap [] -- TODO: finish this
    _                -> build_keymap [] -- TODO: finish this
