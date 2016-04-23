module Models.Message where

import Tools.CssExtra exposing (CssInlineStr)

type Message
  = MessageSuccess CssInlineStr
  | MessageInfo CssInlineStr
  | MessageWarning CssInlineStr
  | MessageException CssInlineStr -- error from user than can happend
  | MessageFatalError CssInlineStr -- fatal error, if happened, contact Gun Pinyo
  | MessageDebug CssInlineStr

type alias MessageList = List Message

init_message_list : MessageList
init_message_list = []
