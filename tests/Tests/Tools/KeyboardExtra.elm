module Tests.Tools.KeyboardExtra where

import Set

import ElmTest exposing (Test, test, suite, assertEqual)

import Tools.KeyboardExtra exposing (..)

tests : Test
tests = suite "Tools.KeyboardExtra" [
  suite "string_to_keycodes" [
    test "normal" <|
      assertEqual [16, 17, 67]
        (List.sort <| Set.toList <| string_to_keycodes "ctrl shift c"),
    test "when empty" <|
      assertEqual (Set.fromList []) (string_to_keycodes "")],
  suite "string_to_keycode" [
    test "modifier character" <|
      assertEqual (Just 17) (string_to_keycode "ctrl"),
    test "normal" <|
      assertEqual (Just 67) (string_to_keycode "C"),
    test "lower case character auto convert" <|
      assertEqual (Just 67) (string_to_keycode "c"),
    test "when empty" <|
      assertEqual Nothing (string_to_keycode ""),
    test "garbage" <|
      assertEqual Nothing (string_to_keycode "garbage")]]
