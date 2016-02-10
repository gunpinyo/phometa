module Models.Message where

type Message
  = MessageSuccess String
  | MessageInfo String
  | MessageWarning String
  | MessageUserError String -- error from user than can happend
  | MessageProgError String -- fatal error, if happened, contract Gun Pinyo
  | MessageDebug String

type alias MessageList = List Message

init_message_list : MessageList
init_message_list = []
