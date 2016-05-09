module Tests.Tools.KeyboardExtra where

import ElmTest exposing (Test, test, suite, assertEqual, assertNotEqual)

import Tools.KeyboardExtra exposing (..)

tests : Test
tests = suite "Tools.KeyboardExtra" [
  suite "to_keystroke" [
    test "normal with correct order" <|
      assertEqual [16, 17, 67] (to_keystroke "Ctrl-Shift-c"),
    test "when empty" <|
      assertEqual [] (to_keystroke "")],
  suite "to_maybe_keycode" [
    test "modifier character" <|
      assertEqual (Just 17) (to_maybe_keycode "Ctrl"),
    test "lower case character auto convert" <|
      assertEqual (Just 67) (to_maybe_keycode "c"),
    test "when empty" <|
      assertEqual Nothing (to_maybe_keycode ""),
    test "garbage" <|
      assertEqual Nothing (to_maybe_keycode "garbage")]]
