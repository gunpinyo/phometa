module Updates.Task where

import Dict
import Char exposing (KeyCode)
import Set exposing (Set)
import Task exposing (Task)

import Tools.KeyboardExtra exposing (Keystroke)
import Models.Model exposing (Model, PreTask, KeyBinding(..))
import Models.Action exposing (Action(..))

extract_maybe_task : Action -> Model -> Maybe (Task () ())
extract_maybe_task action model =
  let maybe_pre_task =
        case action of
          ActionPreTask pre_task    -> Just pre_task
          ActionKeystroke keystroke ->
            case Dict.get keystroke model.root_keymap of
              Just (KeyBindingPreTask _ pre_task) -> Just pre_task
              _                                -> Nothing
          _                         -> Nothing
   in Maybe.map (\pre_task -> pre_task model) maybe_pre_task
