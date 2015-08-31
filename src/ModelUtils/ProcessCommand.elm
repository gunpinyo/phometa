module ModelUtils.ProcessCommand where

import Models.Command exposing (Command)
import Models.ProcessCommand exposing (ProcessCommand)

from_composite_command : List Command -> ProcessCommand
from_composite_command command_list model =
  (command_list, model)
