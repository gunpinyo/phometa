module Update.Action where

import Pane exposing (CursorPath)

type Action
  = ActionNoAction
  | ActionChangeCursorPath CursorPath
