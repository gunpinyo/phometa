module Models.InputAction where

import Keyboard exposing (KeyCode)
import Maybe exposing (Maybe)
import Set exposing (Set)

import Models.Pane exposing (ComponentPath)

type InputAction
  = InputActionNothing
  | InputActionClick ComponentPath
  | InputActionDrag ComponentPath
  | InputActionDrop (Maybe ComponentPath)
  | InputActionKeysDown (Set KeyCode)
