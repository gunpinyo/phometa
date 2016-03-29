module Updates.Keymap where

import Dict

import Focus

import Models.Focus exposing (root_keymap_)
import Models.Model exposing (Model, Command, KeyBinding(..), Keymap, Mode(..))
import Updates.KeymapUtils exposing (merge_keymaps, build_keymap)
import Updates.KeymapGlobal exposing (keymap_global)
import Updates.ModeRootTerm exposing (keymap_mode_root_term)
import Updates.ModeTheorem exposing (keymap_mode_theorem)

cmd_assign_root_keymap : Command
cmd_assign_root_keymap model =
  let keymap = merge_keymaps (keymap_global model) (keymap_mode model)
   in Focus.set root_keymap_ keymap model

cmd_press_prefix_key : Keymap -> Command
cmd_press_prefix_key keymap model =
  let new_keymap = merge_keymaps keymap <| build_keymap [
        ("Escape", "quit prefix key", KbCmd cmd_assign_root_keymap)]
   in Focus.set root_keymap_ new_keymap model

keymap_mode : Model -> Keymap
keymap_mode model =
  case model.mode of
    ModeNothing -> build_keymap [] -- TODO: finish this
    ModeRootTerm record -> keymap_mode_root_term record model
    ModeTheorem record -> keymap_mode_theorem record model
    _           -> build_keymap [] -- TODO: finish this
