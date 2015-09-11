module Models.InputAction where

import Set exposing (Set)

import Tools.KeyboardExtra exposing (KeyCode)

type alias ComponentPath = List Int

type InputAction
  = InputActionNothing
  | InputActionClick ComponentPath
  | InputActionHover ComponentPath
  | InputActionCurserLeavesWindow
  | InputActionDrag ComponentPath
  | InputActionDrop (Maybe ComponentPath)
  | InputActionKeysDown (Set KeyCode)
