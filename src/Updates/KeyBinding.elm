module Updates.KeyBinding where

import Dict

import Tools.KeyboardExtra exposing (to_keystroke)
import Models.Mode exposing (MajorMode(..))
import Models.Model exposing (Command, Keymap)

cmd_assign_root_keymap : Command
cmd_assign_root_keymap model =
  { model | root_keymap = merge_keymaps global_keymap
                            (major_mode_keymap model.major_mode)}

cmd_press_prefix_key : Keymap -> Command
cmd_press_prefix_key keymap model =
  { model | root_keymap = merge_keymaps model.root_keymap keymap }

-- if there a collision
merge_keymaps : Keymap -> Keymap -> Keymap
merge_keymaps = flip Dict.union

global_keymap : Keymap
global_keymap =
  Dict.fromList [] -- TODO: finish this
    -- (to_keystroke "", KeyBindingCommand "cmd desc"),
    -- (to_keystroke "", KeyBindingPrefix "prefix description" <| Dict.fromList [
    --    to_keystroke "", KeyBindingCommand "cmd desc",
    --    to_keystroke "", KeyBindingCommand "cmd desc",
    --    to_keystroke "", KeyBindingCommand "cmd desc"])]

major_mode_keymap : MajorMode -> Keymap
major_mode_keymap major_mode =
  case major_mode of
    MajorModeDefault -> Dict.fromList [] -- TODO: finish this
    _                -> Dict.empty       -- TODO: finish this
