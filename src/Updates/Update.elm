module Updates.Update where

import Maybe exposing (Maybe(..))

import Models.Model exposing (Model)
import Models.InputAction exposing (InputAction(..))
import Models.MiniBuffer exposing (MiniBuffer(..))

update : InputAction -> Model -> Model
update input_action model =
  case input_action of
    InputActionNothing -> model
    InputActionClick component_path ->
      { model |
        cursor_path_maybe <- Just component_path
      , hovered_path_maybe <- Nothing
      , mini_buffer <- MiniBufferDebug ("Click!!!" ++ toString component_path)
      }
    InputActionHover component_path ->
      { model |
        hovered_path_maybe <- Just component_path
      , mini_buffer <- MiniBufferDebug ("Hover!!!" ++ toString component_path)
      }
    InputActionCurserLeavesWindow ->
      { model |
        hovered_path_maybe <- Nothing
      , mini_buffer <- MiniBufferDebug "Curser leaves window!!!!!"
      }
    InputActionKeysDown keycode_set ->
      { model |
        mini_buffer <- MiniBufferDebug ("keys down!!" ++ toString keycode_set)
      }
  -- TODO: finish this
