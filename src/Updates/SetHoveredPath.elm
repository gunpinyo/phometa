module Updates.SetHoveredPath where

import Maybe exposing (Maybe(..))

import Models.ComponentPath exposing (ComponentPath)
import Models.ProcessCommand exposing (ProcessCommand)

set_hovered_path_pcmd : ComponentPath -> ProcessCommand
set_hovered_path_pcmd component_path model =
  let model' = { model |
                 hovered_path_maybe <- Just component_path
               }
   in ([], model')
