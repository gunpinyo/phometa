module ModelUtils.KeyBinding where

import Models.Command exposing (Command(..))
import Models.KeyBinding exposing (KeyBinding)

initial_key_binding : KeyBinding
initial_key_binding =
  { command_dict = []
  , is_in_typing_mode = False
  }

-- if return `Nothing`
-- then the correspond command is not suitable for key binding
get_command_description : Command -> Maybe String
get_command_description command =
  case command of
    CommandMoveCursorToParent -> Just "move cursor to parent"
    CommandMoveCursorToPrevSibling -> Just "move cursor to prev sibling"
    CommandMoveCursorToNextSibling -> Just "move cursor to next sibling"
    CommandMoveCursorToFirstChild -> Just "move cursor to first child"
    _ -> Nothing
    -- TODO: finish this
