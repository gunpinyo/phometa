-- The test suite entry has to have name "Main"
-- since during testing, it is just another elm execution
-- which require entry point to name "Main".
module Main where

import Task

import Console exposing (run)
import ElmTest exposing (Test, suite, consoleRunner)

-- order alphabetically (not the same as our convention)
import Tests.ModelUtils.Model
import Tests.ModelUtils.Package

tests : Test
tests =
  suite "Tests"
    [ Tests.ModelUtils.Model.tests
    , Tests.ModelUtils.Package.tests
    ]

port runner : Signal (Task.Task x ())
port runner =
    run (consoleRunner tests)
