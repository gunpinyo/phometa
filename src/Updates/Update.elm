module Updates.Update where

import Maybe
import Dict

import Focus exposing ((=>))

import Models.Focus exposing (environment_, model_is_modified_)
import Models.Environment exposing (Environment)
import Models.Message exposing (Message(..))
import Models.Model exposing (Model, Command, KeyBinding(..))
import Models.ModelUtils exposing (check_model)
import Models.Action exposing (Action(..))
import Updates.CommonCmd exposing (cmd_nothing)
import Updates.KeymapUtils exposing (get_key_binding)
import Updates.Keymap exposing (cmd_press_prefix_key, cmd_assign_root_keymap)
import Updates.Message exposing (cmd_send_message)

update : (Environment, Action) -> Model -> Model
update (environment, action) old_model =
  let model  = Focus.set environment_ environment old_model
   in case action of
        ActionNothing             -> (add_pre_post_cmd cmd_nothing) model
        ActionCommand command     -> (add_pre_post_cmd command) model
        ActionKeystroke keystroke ->
          case get_key_binding keystroke model.root_keymap of
            Just (KbCmd command)   -> (add_pre_post_cmd command) model
            Just (KbPrefix keymap) -> cmd_press_prefix_key keymap model
            Nothing                -> model

add_pre_post_cmd : Command -> Command
add_pre_post_cmd command =
  let cmd_pre  = cmd_nothing -- currently, there is no pre-command
      cmd_post = cmd_assign_root_keymap
                   >> Focus.set (environment_ => model_is_modified_) True
                   >> cmd_sanity_check
   in cmd_pre >> command >> cmd_post

cmd_sanity_check : Command
cmd_sanity_check model =
  case check_model model of
    Nothing     -> model
    Just reason -> cmd_send_message (MessageFatalError reason) model
