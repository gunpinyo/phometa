module Tools.KeyboardExtra where

import Char exposing (KeyCode)
import Debug exposing (crash)
import Set exposing (Set)
import String

type alias RawKeystroke = String
type alias Keystroke = List KeyCode

-- post: the return list is sorted
to_keystroke : RawKeystroke -> Keystroke
to_keystroke string =
  string
    |> String.split "-"
    |> List.filterMap to_maybe_keycode
    |> List.sort

to_maybe_keycode : String -> Maybe KeyCode
to_maybe_keycode string =
  case string of
    "RET"    -> Just 13  -- enter / return
    "S"      -> Just 16  -- shift
    "C"      -> Just 17  -- ctrl
    "A"      -> Just 18  -- alt
    "SPC"    -> Just 32  -- space
    "ESC"    -> Just 27  -- escape
    _        -> case String.toList string of
                  char :: [] -> Just <| Char.toCode <| Char.toUpper char
                  _          -> Nothing
