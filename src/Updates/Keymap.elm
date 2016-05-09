module Updates.Keymap where

import Focus

import Models.Focus exposing (root_keymap_)
import Models.Model exposing (Model, Command, KeyBinding(..), Keymap, Mode(..))
import Updates.KeymapUtils exposing (empty_keymap, merge_keymaps,
                                     build_keymap, build_keymap_cond)
import Updates.ModeMenu exposing (keymap_mode_menu, cmd_enter_mode_menu)
import Updates.ModeRepo exposing (keymap_mode_repo)
import Updates.ModeModule exposing (keymap_mode_module)
import Updates.ModeGrammar exposing (keymap_mode_grammar)
import Updates.ModeRootTerm exposing (keymap_mode_root_term)
import Updates.ModeRule exposing (keymap_mode_rule)
import Updates.ModeTheorem exposing (keymap_mode_theorem)

cmd_assign_root_keymap : Command
cmd_assign_root_keymap model =
  let keymap = merge_keymaps
        (build_keymap_cond (model.mode /= ModeMenu)
          [(model.config.spacial_key_prefix ++ "x",
            "jump to menu", KbCmd cmd_enter_mode_menu)])
        (keymap_mode model)
   in Focus.set root_keymap_ keymap model

cmd_press_prefix_key : Keymap -> Command
cmd_press_prefix_key keymap model =
  let new_keymap = merge_keymaps keymap <| build_keymap [
        ("Escape", "quit prefix key", KbCmd cmd_assign_root_keymap)]
   in Focus.set root_keymap_ new_keymap model

keymap_mode : Model -> Keymap
keymap_mode model =
  case model.mode of
    ModeNothing -> empty_keymap
    ModeMenu -> keymap_mode_menu model
    ModeRepo record -> keymap_mode_repo record model
    ModeModule record -> keymap_mode_module record model
    ModeComment record -> empty_keymap
    ModeGrammar record -> keymap_mode_grammar record model
    ModeRootTerm record -> keymap_mode_root_term record model
    ModeRule record -> keymap_mode_rule record model
    ModeTheorem record -> keymap_mode_theorem record model
