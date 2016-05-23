module Models.Message where

import Tools.CssExtra exposing (CssInlineStr)
import Models.RepoModel exposing (PackagePath, ModulePath, NodeName, NodeType)

type Message
  = MessageSuccess CssInlineStr
  | MessageInfo CssInlineStr
  | MessageWarning CssInlineStr
  | MessageException CssInlineStr -- error from user than can happend
  | MessageFatalError CssInlineStr -- fatal error, if this happen,
                                   --              contact Gun Pinyo
  | MessageDebug CssInlineStr
  | MessageDeleteNodeConfirmation ModulePath (List (NodeType, NodeName))
  | MessageDeleteModuleConfirmation ModulePath
  | MessageDeletePackageConfirmation PackagePath


type alias MessageList = List Message

init_message_list : MessageList
init_message_list = []
