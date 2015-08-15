module Updates.InputAction where

import Models.InputAction exposing (InputAction(..))
import Models.Command exposing (Command(..))
import Models.ProcessCommand exposing (ProcessCommand)
import ModelUtils.ProcessCommand exposing (from_composite_command)

input_action_pcmd : InputAction -> ProcessCommand
input_action_pcmd input_action =
  from_composite_command <|
    case input_action of
      InputActionNothing -> []
      InputActionClick component_path ->
        [ CommandSetCursorPath component_path
        , CommandUnsetHoveredPath
        , CommandLogToConsole "Click" (toString component_path)
        ]
      InputActionHover component_path ->
        [ CommandSetHoveredPath component_path
        , CommandLogToConsole "Hover" (toString component_path)
        ]
      InputActionCurserLeavesWindow ->
        [ CommandUnsetHoveredPath
        , CommandLogToConsole "Hover" "leaves window!!!!!"
        ]
      InputActionKeysDown keycode_set ->
        [ CommandLogToConsole "KeysDown" (toString keycode_set)
        ]
      -- TODO: write about dragging
