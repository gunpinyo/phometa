module Models.Command where

import Models.InputAction exposing (ComponentPath, InputAction)

type Command
 = CommandNothing

 | CommandInputAction InputAction
 | CommandPreProcess
 | CommandPostProcess

 | CommandLogToConsole String String -- arguments are header and message

 | CommandSetCursorPath ComponentPath
 | CommandMoveCursorToParent -- TODO: implement this
 | CommandMoveCursorToPrevSibling -- TODO: implement this
 | CommandMoveCursorToNextSibling -- TODO: implement this
 | CommandMoveCursorToFirstChild -- TODO: implement this
 | CommandSetHoveredPath ComponentPath
 | CommandUnsetHoveredPath
 | CommandSetDraggedPath ComponentPath -- TODO: implement this

 -- TODO: finish this
