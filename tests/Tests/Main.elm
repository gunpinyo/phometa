-- The test suite entry has to have name "Main"
-- since during testing, it is just another elm execution
-- which require entry point to have name "Main".
module Main where

import Task

import Console exposing (run)
import ElmTest exposing (Test, suite, consoleRunner)

-- order alphabetically (exceptional to our convention on README.md)
import Tests.Tools.KeyboardExtra
import Tests.Tools.Utils

tests : Test
tests =
  suite "Tests" [
    Tests.Tools.KeyboardExtra.tests,
    Tests.Tools.Utils.tests]
    -- TODO: write more tests

port runner : Signal (Task.Task x ())
port runner =
    run (consoleRunner tests)
