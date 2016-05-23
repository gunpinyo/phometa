module Updates.Environment where

import Dict
import Char exposing (KeyCode)
import Set exposing (Set)
import Task exposing (Task)
import Time exposing (timestamp)

import Focus exposing ((=>))
import Http

import Tools.KeyboardExtra exposing (Keystroke)
import Models.Focus exposing (environment_, maybe_task_)
import Models.Environment exposing (Environment)
import Models.Message exposing (Message(..))
import Models.Model exposing (Model, Command, KeyBinding(..))
import Models.Action exposing (Action(..), address)
import Updates.Message exposing (cmd_send_message)
import Updates.CommonCmd exposing (cmd_parse_and_load_repository)

inject_env_to_action : Signal Action -> Signal (Environment, Action)
inject_env_to_action action_signal =
  let time_to_env time = { time       = time
                         , maybe_task = Nothing
                         }
   in Signal.map (\ (time, action) -> (time_to_env time, action))
        <| timestamp action_signal

extract_task : Model -> Maybe (Task () ())
extract_task model = model.environment.maybe_task

cmd_add_task : (Model -> Task () ()) -> Command
cmd_add_task func model =
  let new_task = case model.environment.maybe_task of
                   Nothing       -> func model
                   Just old_task -> Task.andThen old_task (\ () -> func model)
   in Focus.set (environment_ => maybe_task_) (Just new_task) model

task_load_repository : Task () ()
task_load_repository =
  Http.getString "./repository.json"
    |> (flip Task.andThen) (\repo_string -> Signal.send address
          (ActionCommand <| cmd_parse_and_load_repository repo_string))
    |> (flip Task.onError) (\http_error ->  Signal.send address
          (ActionCommand <| cmd_send_message (MessageException
            <| "cannot load repository because " ++ (toString http_error))))
