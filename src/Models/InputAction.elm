module Models.C where

import Char exposing (KeyCode)
import Set exposing (Set)

-- address that can identify a component from the entire view
type alias ComponentPath = List Int


type InputAction
  = InputActionNothing
  | InputActionMouse
  | InputActionKeysDown (Set KeyCode)
