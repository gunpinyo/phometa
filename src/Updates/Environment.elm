module Updates.Environment where

import Dict
import Char exposing (KeyCode)
import Set exposing (Set)
import Task exposing (Task)
import Time exposing (timestamp)

import Tools.KeyboardExtra exposing (Keystroke)
import Models.Environment exposing (Environment)
import Models.Model exposing (Model, Command, KeyBinding(..))
import Models.Action exposing (Action(..))

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
      old_env  = model.environment
      new_env  = { old_env | maybe_task = Just new_task }
   in { model | environment = new_env}
