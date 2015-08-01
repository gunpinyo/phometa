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
      , mini_buffer <- MiniBufferDebug "Click!!!"
      }
  -- TODO: finish this
