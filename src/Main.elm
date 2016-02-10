module Main where

import Html exposing (Html)
import Keyboard exposing (keysDown)
import Set exposing (Set)
import Task exposing (Task)

import Models.Environment exposing (Environment)
import Models.Model exposing (Model, init_model)
import Models.Action exposing (Action(..), mailbox, address)
import Updates.Environment exposing (inject_env_to_action, extract_task)
import Updates.Update exposing (update)
import Views.View exposing (view)

keyboard_signal : Signal Action
keyboard_signal =
  Signal.map (Set.toList >> List.sort >> ActionKeystroke) keysDown

action_signal : Signal Action
action_signal = Signal.merge mailbox.signal keyboard_signal

env_action_pair_signal : Signal (Environment, Action)
env_action_pair_signal = inject_env_to_action action_signal

model_signal : Signal Model
model_signal = Signal.foldp update init_model env_action_pair_signal

main : Signal Html
main = Signal.map view model_signal

port task_signal : Signal (Task () ())
port task_signal = Signal.filterMap extract_task activating_task model_signal

-- some sub-component of model e.g. root_keymap,
-- will behave correctly after model_signal got the first action
-- it is designed like this because setting a nice init_* would be an overkill
-- so, we need a task to click of the first action
activating_task : Task () ()
activating_task = Signal.send address ActionNothing
