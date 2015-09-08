import IO.IO exposing (..)
import IO.Runner exposing (Request, Response, run)
import ElmTest.Assertion exposing (assert, assertEqual)
import ElmTest.Runner.Console exposing (runDisplay)
import ElmTest.Test exposing (Test, test, suite)

-- TODO: this is example test, the real tests will be written later
tests : Test
tests =
  suite "Root"
    [ test "Addition" (assertEqual (3 + 7) 10)
    , test "This test should pass" (assert True)
    ]

port requests : Signal Request
port requests = run responses (runDisplay tests)

port responses : Signal Response
