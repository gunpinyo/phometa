module Model.Action where

import Keyboard exposing (KeyCode)
import Maybe exposing (Maybe)
import Set exposing (Set)

import Model.Pane exposing (ComponentPath)

type Action
  = ActionNoAction
  | ActionClick ComponentPath
  | ActionDrag ComponentPath
  | ActionDrop (Maybe ComponentPath)
  | ActionKeysDown (Set KeyCode)
