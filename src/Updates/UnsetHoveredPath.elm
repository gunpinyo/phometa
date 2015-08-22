module Updates.UnsetHoveredPath where

import Models.ProcessCommand exposing (ProcessCommand)

unset_hovered_path_pcmd : ProcessCommand
unset_hovered_path_pcmd model =
  let model' = { model |
                 hovered_path_maybe <- Nothing
               }
   in ([], model')
