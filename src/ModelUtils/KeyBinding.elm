module ModelUtils.KeyBinding where

import Models.KeyBinding exposing (KeyBinding)

initial_key_binding : KeyBinding
initial_key_binding =
  { command_dict = []
  , is_in_typing_mode = True
  }
