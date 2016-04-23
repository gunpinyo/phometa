module Tools.KeyboardExtra where

import Char exposing (KeyCode)
import Dict
import Regex exposing (Regex, regex, replace)
import String

import Tools.UnicodeMath exposing (latex_to_unicode)

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
    "Return" -> Just 13  -- enter / return
    "Shift"  -> Just 16  -- shift
    "Ctrl"   -> Just 17  -- ctrl
    "Alt"    -> Just 18  -- alt
    "Space"  -> Just 32  -- space
    "Escape" -> Just 27  -- escape
    "["      -> Just 219
    "]"      -> Just 221
    "⭠"     -> Just 37
    "⭡"      -> Just 38
    "⭢"     -> Just 39
    "⭣"      -> Just 40
    _        -> case String.toList string of
                  char :: [] -> Just <| Char.toCode <| Char.toUpper char
                  _          -> Nothing

transfrom_to_unicode_string : String -> String
transfrom_to_unicode_string =
  replace Regex.All (regex "\\\\.*?\\\\")
    (.match >> String.slice 1 -1 >> transfrom_to_unicode_symbol)

transfrom_to_unicode_symbol : String -> String
transfrom_to_unicode_symbol raw_symbol =
  case Dict.get raw_symbol latex_to_unicode of
    Nothing -> raw_symbol
    Just code_point -> code_point |> Char.fromCode |> String.fromChar
