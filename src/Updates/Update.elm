module Updates.Update where

import Maybe
import Dict

import Focus

import Models.Focus exposing (environment_)
import Models.Environment exposing (Environment)
import Models.Message exposing (Message(..))
import Models.Model exposing (Model, Command, KeyBinding(..), check_model)
import Models.Action exposing (Action(..))
import Updates.CommonCmd exposing (cmd_nothing)
import Updates.KeymapUtils exposing (get_key_binding)
import Updates.Keymap exposing (cmd_press_prefix_key, cmd_assign_root_keymap)
import Updates.Message exposing (cmd_send_message)

update : (Environment, Action) -> Model -> Model
update (environment, action) old_model =
  let model  = Focus.set environment_ environment old_model
   in (cmd_assign_root_keymap >> cmd_sanity_check) model

get_root_cmd : Action -> Command
get_root_cmd action =
  case action of
    ActionNothing          -> cmd_nothing
    ActionCommand command  -> command
    ActionKeystroke keystroke -> (\model ->
      case get_key_binding keystroke model.root_keymap of
        Just (KeyBindingCommand command)  -> command model
        Just (KeyBindingPrefix keymap) -> cmd_press_prefix_key keymap model
        _                              -> model)

cmd_sanity_check : Command
cmd_sanity_check model =
  case check_model model of
    Nothing     -> model
    Just reason -> cmd_send_message (MessageProgError reason) model
