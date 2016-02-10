module Updates.Message where

import Models.Message exposing (Message)
import Models.Model exposing (Command)

cmd_send_message : Message -> Command
cmd_send_message message model =
  { model | message_list = message :: model.message_list}
