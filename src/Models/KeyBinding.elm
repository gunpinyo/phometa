module Models.KeyBinding where

import List
import Keyboard exposing (KeyCode)
import Set exposing (Set)

import Models.Command exposing (Command)

type alias KeyBinding
  = { -- warning:
      --   if there is duplication on (Set KeyCode) the latest append wins.
      command_dict : List ((Set KeyCode), Command)
      -- if True, most of keys (except some like ctrl-*, alt-*)
      -- will not be temporary excluded from key-binding
      -- it is useful when cursor is on input box
      -- where typing should reflex actual text
    , is_in_typing_mode : Bool
    }
