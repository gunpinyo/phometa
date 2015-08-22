module Updates.SetCursorPath where

import Models.ComponentPath exposing (ComponentPath)
import Models.ProcessCommand exposing (ProcessCommand)

set_cursor_path_pcmd : ComponentPath -> ProcessCommand
set_cursor_path_pcmd component_path model =
  let model' = { model |
                 cursor_path_maybe <- Just component_path
               }
   in ([], model')
