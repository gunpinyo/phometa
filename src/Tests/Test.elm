-- conventionally this should be `module Tests.Test where`
-- but it clashes elm-test, so need to declare it as `Main` module
module Main where

import IO.IO exposing (..)
import IO.Runner exposing (Request, Response, run)
import ElmTest.Runner.Console exposing (runDisplay)
import ElmTest.Test exposing (Test, suite)

import Tests.ModelUtils.Model

tests : Test
tests =
  suite "Tests"
    [ Tests.ModelUtils.Model.tests
    ]

port requests : Signal Request
port requests = run responses (runDisplay tests)

port responses : Signal Response
