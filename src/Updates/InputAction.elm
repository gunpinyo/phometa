module Updates.InputAction where

import Models.InputAction exposing (InputAction(..))
import Models.Command exposing (Command(..))
import Models.EtcAlias exposing (ProcessCommand)

input_action_pcmd : InputAction -> ProcessCommand
input_action_pcmd input_action =
  (,) <|
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
