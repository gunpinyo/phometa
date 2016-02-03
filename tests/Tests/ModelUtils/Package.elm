module Tests.ModelUtils.Package where

import ElmTest exposing (Test, test, suite, assertEqual)

import ModelUtils.Package exposing (..)

tests : Test
tests = suite "ModelUtils.Package"

  [ suite "get_package"

    [ test "when root package empty" <|

      let package_path = ["package", "path"]
          root_package = initial_package
          actual = get_package package_path root_package
       in assertEqual Nothing actual

    , test "when package in package path does not exist in root_package" <|

      let package_path = ["package", "path"]
          another_package_path = ["another", "package", "path"]
          another_package = initial_package
          root_package =
            set_package another_package another_package_path initial_package
          actual = get_package package_path root_package
       in assertEqual Nothing actual

    , test "when package in package path exists in root_package" <|

      let package_path = ["path", "package"]
          package = initial_package
          root_package = set_package package package_path initial_package
          actual = get_package package_path root_package
       in assertEqual (Just package) actual

    , test "when package in package path does not exist but parent exist" <|

      let parent_package_path = ["package"]
          package_path = "path" :: parent_package_path
          parent_package = initial_package
          root_package =
            set_package parent_package parent_package_path initial_package
          actual = get_package package_path root_package
       in assertEqual Nothing actual
    ]

  --, suite "set_package"
  --  [ test "package in package path "
  --  ]
  ]
