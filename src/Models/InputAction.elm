module Models.InputAction where

import Keyboard exposing (KeyCode)
import Set exposing (Set)

type alias ComponentPath = List Int

type InputAction
  = InputActionNothing
  | InputActionClick ComponentPath
  | InputActionHover ComponentPath
  | InputActionCurserLeavesWindow
  | InputActionDrag ComponentPath
  | InputActionDrop (Maybe ComponentPath)
  | InputActionKeysDown (Set KeyCode)
