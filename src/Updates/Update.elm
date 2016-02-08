module Updates.Update where

import Maybe
import Dict

import Models.Popup exposing (Popup(..))
import Models.Model exposing (Command, KeyBinding(..), check_model)
import Models.Action exposing (Action(..))
import Updates.KeyBinding exposing (cmd_press_prefix_key,
                                    cmd_assign_root_keymap)
import Updates.CommonCmd exposing (cmd_nothing)

update : Action -> Command
update action =
  case action of
    ActionNothing          -> cmd_nothing
    ActionCommand command  -> add_pre_post_cmd command
    ActionPreTask pre_task -> cmd_nothing -- handled by `task_signal` in `Main`
    ActionKeystroke keystroke ->
      (\model -> model |>
         case Dict.get keystroke model.root_keymap of
           Just (KeyBindingCommand _ command) -> add_pre_post_cmd command
           Just (KeyBindingPrefix _ keymap)   -> cmd_press_prefix_key keymap
           _                                  -> cmd_nothing)

add_pre_post_cmd : Command -> Command
add_pre_post_cmd command =
  let cmd_pre  = cmd_nothing -- currently, there is no pre-command
      cmd_post = cmd_assign_root_keymap >> cmd_sanity_check
   in cmd_pre >> command >> cmd_post

cmd_sanity_check : Command
cmd_sanity_check model =
  case check_model model of
    Nothing     -> model
    Just reason -> { model |
                     popup_list = (PopupProgError reason) :: model.popup_list }
