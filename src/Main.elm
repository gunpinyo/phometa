module Main where

import Html exposing (Html)
import Keyboard exposing (keysDown)
import Set exposing (Set)
import Task exposing (Task)

import Models.Model exposing (Model, PreTask, init_model)
import Models.Action exposing (Action(..), mailbox)
import Updates.Task exposing (extract_maybe_task)
import Updates.Update exposing (update)
import Views.View exposing (view)

keyboard_signal : Signal Action
keyboard_signal =
  Signal.map (Set.toList >> List.sort >> ActionKeystroke) keysDown

action_signal : Signal Action
action_signal = Signal.merge mailbox.signal keyboard_signal

model_signal : Signal Model
model_signal = Signal.foldp update init_model action_signal

main : Signal Html
main = Signal.map view model_signal

port task_signal : Signal (Task () ())
port task_signal =
  Signal.filterMap identity (Task.succeed ())
    <| Signal.map2 extract_maybe_task action_signal model_signal
