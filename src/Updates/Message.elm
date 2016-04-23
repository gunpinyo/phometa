module Updates.Message where

import Focus

import Models.Focus exposing (message_list_)
import Models.Message exposing (Message(..))
import Models.Model exposing (Command)

cmd_send_message : Message -> Command
cmd_send_message message model =
  Focus.update message_list_ ((::) message) model
