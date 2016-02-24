module Updates.KeymapUtils where

import Dict

import Tools.KeyboardExtra exposing (RawKeystroke, Keystroke, to_keystroke)
import Models.Model exposing (KeyBinding(..), KeyDescription, Keymap)

-- if there a collision, second one wins
merge_keymaps : Keymap -> Keymap -> Keymap
merge_keymaps = flip Dict.union

get_key_binding : Keystroke -> Keymap -> Maybe KeyBinding
get_key_binding keystroke keymap =
  Maybe.map snd <| Dict.get keystroke keymap

build_keymap : List (RawKeystroke, KeyDescription, KeyBinding) -> Keymap
build_keymap list =
  let tuple_to_dict_elem (raw_keystroke, key_binding_name, key_binding) =
        (to_keystroke raw_keystroke,
           ((raw_keystroke, key_binding_name), key_binding))
   in Dict.fromList <| List.map tuple_to_dict_elem list

empty_keymap : Keymap
empty_keymap = build_keymap []
