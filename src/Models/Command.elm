module Models.Command where

import Models.ComponentPath exposing (ComponentPath)

type Command
 = CommandNothing
 | CommandMoveCursorTo ComponentPath
 | CommandMoveCursorToParent
 | CommandMoveCursorToPrevSibling
 | CommandMoveCursorToNextSibling
 | CommandMoveCursorToFirstChild
 | CommandMouseHoverTo ComponentPath
 -- TODO: finish this
