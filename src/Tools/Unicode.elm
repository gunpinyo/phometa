module Tools.Unicode where

import Char
import String

import Tools.UnicodeLatex exposing (latex_to_unicode)

-- TODO: add more Unicode alternative
name_to_unicode : List (String, String)
name_to_unicode =
  List.map (\ (key, val) ->
              (key, val |> Char.fromCode |> String.fromChar)) latex_to_unicode
