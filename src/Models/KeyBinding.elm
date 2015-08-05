module Models.KeyBinding where

import List
import Keyboard exposing (KeyCode)
import Set exposing (Set)

import Models.Command exposing (Command)

type alias KeyBinding
  = { -- warning:
      --   if there is duplication on (Set KeyCode) the lastest append wins.
      command_dict : List ((Set KeyCode), Command)
    , is_in_typing_mode : Bool
    }
