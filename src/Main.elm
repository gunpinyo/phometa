module Main where

import Html exposing (Html)
import Keyboard exposing (KeyCode, keysDown)
import Signal exposing (Mailbox, Address)

import Models.InputAction exposing (InputAction(..))
import Models.Model exposing (Model)
import ModelUtils.Model exposing (initial_model)
import Updates.Update exposing (update)
import Views.View exposing (view)

mouse_mailbox : Mailbox InputAction
mouse_mailbox =
  Signal.mailbox InputActionNothing

keyboard_signal : Signal InputAction
keyboard_signal =
  Signal.map (\keycode_set -> InputActionKeysDown keycode_set) keysDown

input_signal : Signal InputAction
input_signal =
  Signal.merge mouse_mailbox.signal keyboard_signal

model_signal : Signal Model
model_signal =
  Signal.foldp update initial_model input_signal

main : Signal Html
main =
  Signal.map (\model -> view mouse_mailbox.address model) model_signal
