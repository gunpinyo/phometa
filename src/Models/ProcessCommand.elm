module Models.ProcessCommand where

import Models.Command exposing (Command)
import Models.Model exposing (Model)

type alias ProcessCommand
  = Model -> (List Command, Model)
