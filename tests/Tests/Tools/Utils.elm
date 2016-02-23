module Tests.Tools.Utils where

import Set

import ElmTest exposing (Test, test, suite, assert, assertEqual, assertNotEqual)

import Tools.Utils exposing (..)

tests : Test
tests = suite "Tools.Utils" [
  suite "list_skeleton" [
    test "normal" <|
      assertEqual [5] (list_skeleton 5)],
  suite "list_insert" [
    test "n < 0" <|
      assertEqual [7, 6, 4, 9] (list_insert (-1) 7 [6, 4, 9]),
    test "n = 0" <|
      assertEqual [7, 6, 4, 9] (list_insert 0 7 [6, 4, 9]),
    test "n in range" <|
      assertEqual [6, 4, 7, 9] (list_insert 2 7 [6, 4, 9]),
    test "n >= length" <|
      assertEqual [6, 4, 9, 7] (list_insert 10 7 [6, 4, 9]),
    test "when empty, n < 0" <|
      assertEqual [7] (list_insert (-1) 7 []),
    test "when empty, n >= 0" <|
      assertEqual [7] (list_insert 0 7 [])],
  suite "parity_pair_extract" [
    test "when odd" <|
      assertEqual "odd" ((parity_pair_extract 5) ("even", "odd")),
    test "when even" <|
      assertEqual "even" ((parity_pair_extract 8) ("even", "odd"))],
  suite "remove_list_duplicate" [
    test "when empty" <|
      assertEqual [] (remove_list_duplicate []) ,
    test "when no duplicate" <|
      assertEqual [5, 1, 2] (remove_list_duplicate [5, 1, 2]),
    test "normal" <|
      assertEqual [5, 1, 2] (remove_list_duplicate [1, 5, 2, 1, 5, 2, 1, 1, 2]),
    test "not allow permute when no duplicate" <|
      assertNotEqual [5, 1, 2] (remove_list_duplicate [5, 2, 1]),
    test "not allow permute" <|
      assertNotEqual [5, 1, 2] (remove_list_duplicate [1, 2, 1, 5])],
  suite "are_list_unorderly_equal_to" [
    test "when both empty" <|
      assert (are_list_unorderly_equal_to [] []),
    test "when left empty" <|
      (assert << not) (are_list_unorderly_equal_to [] [7]),
    test "when right empty" <|
      (assert << not) (are_list_unorderly_equal_to [8] []),
    test "when identical" <|
      assert (are_list_unorderly_equal_to [7, 8, 6] [7, 8, 6]),
    test "when permute" <|
      assert (are_list_unorderly_equal_to [3, 8, 4, 2] [4, 3, 2, 8]),
    test "when duplicate" <|
      (assert << not) (are_list_unorderly_equal_to [3, 8, 8, 4] [4, 3, 8]),
    test "some gone" <|
      (assert << not) (are_list_unorderly_equal_to [6, 8] [7, 8, 6]),
    test "some gone both side" <|
      (assert << not) (are_list_unorderly_equal_to [6, 8] [7, 8])],
  suite "are_list_elements_unique" [
    test "when empty" <|
      assert (are_list_elements_unique []),
    test "when not unique" <|
      (assert << not) (are_list_elements_unique [7, 8, 7 ,9]),
    test "when unique" <|
      assert (are_list_elements_unique [7, 8 ,9])]]
