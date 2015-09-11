module Tests.ModelUtils.Model where

import ElmTest.Assertion exposing (assertEqual)
import ElmTest.Test exposing (Test, test, suite)

import ModelUtils.Model exposing (..)

tests : Test
tests = suite "ModelUtils.Model"

  [ suite "is_at_cursor_path"

    [ test "when no cursor" <|

        let component_path = [1, 1]
            model = { initial_model |
                      cursor_path_maybe <- Nothing
                    }
            actual = is_at_cursor_path model component_path
         in assertEqual actual False

    , test "have cursor but not that position" <|

        let fst_component_path = [1, 1]
            snd_component_path = [1]
            model = { initial_model |
                      cursor_path_maybe <- Just fst_component_path
                    }
            actual = is_at_cursor_path model snd_component_path
         in assertEqual actual False

    , test "have cursor and at that position" <|

        let component_path = [1, 1]
            model = { initial_model |
                      cursor_path_maybe <- Just component_path
                    }
            actual = is_at_cursor_path model component_path
         in assertEqual actual True
    ]

  , suite "is_at_hovered_path"

    [ test "when no hovered path" <|

        let component_path = [1, 1]
            model = { initial_model |
                      hovered_path_maybe <- Nothing
                    }
            actual = is_at_hovered_path model component_path
         in assertEqual actual False

    , test "have hovered path but not that position" <|

        let fst_component_path = [1, 1]
            snd_component_path = [1]
            model = { initial_model |
                      hovered_path_maybe <- Just fst_component_path
                    }
            actual = is_at_hovered_path model snd_component_path
         in assertEqual actual False

    , test "have hovered path and at that position" <|

        let component_path = [1, 1]
            model = { initial_model |
                      hovered_path_maybe <- Just component_path
                    }
            actual = is_at_hovered_path model component_path
         in assertEqual actual True
    ]
  ]
