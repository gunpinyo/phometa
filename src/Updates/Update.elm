module Updates.Update where

import String

import Tools.Verification as Verification exposing (VerificationResult, valid)
import Models.Command exposing (Command(..))
import Models.Model exposing (Model)
import Models.InputAction exposing (InputAction)
import Models.MiniBuffer exposing (MiniBuffer(..))
import ModelUtils.Model exposing (verify_model)
import Updates.ProcessCommand exposing (command_to_process_command)

type alias ProgramState
  = { command_list : List Command
    , model : Model
    , verification_result : VerificationResult
    }

update : InputAction -> Model -> Model
update input_action model =
  let initial_program_state =
        { command_list =
            [ CommandPreProcess
            , CommandInputAction input_action
            , CommandPostProcess
            ]
        , model = model
        , verification_result = verify_model model
        }
      final_program_state = process_program initial_program_state
   in if final_program_state.verification_result == valid then
        final_program_state.model
      else
        { model |
          mini_buffer <- MiniBufferError
            <| "Internal verification fail:\n"
            ++ "  "
            ++ Verification.to_string
                 final_program_state.verification_result
            ++ "\n"
            ++ "Please contract developer to fix this (gunpinyo@gmail.com)."
        }

process_program : ProgramState -> ProgramState
process_program record =
  if record.verification_result /= valid then
    record -- if the program become invalid stop program immediately.
  else
    case record.command_list of
      [] -> record
      command :: command_tail ->
        let process_command = command_to_process_command command
            (command_list', model') = process_command record.model
            record' =
              { command_list = command_list' ++ command_tail
              , model = model'
              , verification_result = verify_model model'
              }
         in process_program record'
