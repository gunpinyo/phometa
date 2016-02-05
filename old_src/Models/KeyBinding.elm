module Models.KeyBinding where

import Set exposing (Set)

import Tools.KeyboardExtra exposing (KeyCode)
import Models.Command exposing (Command)

type alias KeyBinding
  = { -- warning:
      --   if there is duplication on (Set KeyCode) the latest append wins.
      command_dict : List ((Set KeyCode), Command)
      -- if True, most of keys (except some like ctrl-*, alt-*)
      -- will be temporary excluded from key-binding
      -- it is useful when cursor is on input box
      -- where typing should reflex actual text
    , is_in_typing_mode : Bool
    }
