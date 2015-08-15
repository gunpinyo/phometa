module Updates.Update where

import Models.Command exposing (Command(..))
import Models.Model exposing (Model)
import Models.InputAction exposing (InputAction)
import Updates.ProcessCommand exposing (command_to_process_command)

update : InputAction -> Model -> Model
update input_action model =
  let command_list =
        [ CommandPreProcess
        , CommandInputAction input_action
        , CommandPostProcess
        ]
      ([], model') = process_command_sequence (command_list, model)
   in model'

process_command_sequence : (List Command, Model) -> (List Command, Model)
process_command_sequence (command_list, model) =
  case command_list of
    [] -> ([], model)
    command :: command_tail ->
      let process_command = command_to_process_command command
          (command_list', model') = process_command model
       in process_command_sequence (command_list' ++ command_tail, model')
