module Updates.ProcessCommand where

import Models.Command exposing (Command(..))
import Models.ProcessCommand exposing (ProcessCommand)
import Updates.InputAction exposing (input_action_pcmd)
import Updates.PreProcess exposing (pre_process_pcmd)
import Updates.PostProcess exposing (post_process_pcmd)
import Updates.LogToConsole exposing (log_to_console_pcmd)
import Updates.SetCursorPath exposing (set_cursor_path_pcmd)
import Updates.SetHoveredPath exposing (set_hovered_path_pcmd)
import Updates.UnsetHoveredPath exposing (unset_hovered_path_pcmd)

-- exception to project's naming convention:
--   this function is to map from `Command` to `ProcessCommand` only
--   we do not care meaning of parameters here that much
--   so it is acceptable to use p, p', p'', ...  to refer parameters
command_to_process_command : Command -> ProcessCommand
command_to_process_command command =
  case command of
    CommandNothing -> (\model -> ([], model))
    CommandInputAction p -> input_action_pcmd p
    CommandPreProcess -> pre_process_pcmd
    CommandPostProcess -> post_process_pcmd
    CommandLogToConsole p p' -> log_to_console_pcmd p p'
    CommandSetCursorPath p -> set_cursor_path_pcmd p
    CommandSetHoveredPath p -> set_hovered_path_pcmd p
    CommandUnsetHoveredPath -> unset_hovered_path_pcmd
