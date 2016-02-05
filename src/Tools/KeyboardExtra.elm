module Tools.KeyboardExtra where

import Char exposing (KeyCode)
import Debug exposing (crash)
import Set exposing (Set)
import String

-- this is actually define in core library named `Keyboard`
--   but we can't use it directly since it makes `elm-test` clash
--   (perhaps weird bug)
-- type alias KeyCode = Int

string_to_keycodes : String -> Set KeyCode
string_to_keycodes string =
  string
    |> String.split " "
    |> List.filterMap string_to_keycode
    |> Set.fromList

string_to_keycode : String -> Maybe KeyCode
string_to_keycode string =
  case string of
    "enter"  -> Just 13
    "shift"  -> Just 16
    "ctrl"   -> Just 17
    "alt"    -> Just 18
    "space"  -> Just 32
    _        -> case String.toList string of
                  char :: [] -> Just <| Char.toCode <| Char.toUpper char
                  _          -> Nothing
