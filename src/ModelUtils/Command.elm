module ModleUtils.Command where

import Models.Command exposing (Command)

get_command_description : Command -> Maybe String
get_command_description command =
  case command of
    CommandMoveCursorTo -> Nothing
    CommandMoveCursorToParent -> "move cursor to parent"
    CommandMoveCursorToPrevSibling -> "move cursor to prev sibling"
    CommandMoveCursorToNextSibling -> "move cursor to next sibling"
    CommandMoveCursorToFirstChild -> "move cursor to first child"
    -- TODO: finish this
