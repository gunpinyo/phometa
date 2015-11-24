-- conventionally this should be `module Tests.Test where`
-- but it clashes elm-test, so need to declare it as `Main` module
module Main where

import Task

import Console
import ElmTest exposing (Test, suite)

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
    Console.run (ElmTest.consoleRunner tests)
