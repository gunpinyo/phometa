module Updates.LogToConsole where

import Debug exposing (log)

import Models.ProcessCommand exposing (ProcessCommand)

log_to_console_pcmd : String -> String -> ProcessCommand
log_to_console_pcmd header message model =
  let _ = log header message
   in ([], model)
