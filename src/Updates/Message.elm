module Updates.Message where

import Focus

import Tools.Utils exposing (list_remove)
import Models.Focus exposing (message_list_)
import Models.Message exposing (Message(..))
import Models.Model exposing (Command)

cmd_send_message : Message -> Command
cmd_send_message message model =
  Focus.update message_list_
    ((::) message >> List.take model.config.maximum_messages) model

cmd_remove_message : Int -> Command
cmd_remove_message index model =
  Focus.update message_list_ (list_remove index) model
