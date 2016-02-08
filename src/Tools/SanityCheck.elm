module Tools.SanityCheck where

import Maybe exposing (withDefault)

type alias InvalidReason = String

type alias CheckResult = Maybe InvalidReason

-- this useful to combine with sequentially_check
type alias CheckFunction = () -> CheckResult

valid : CheckResult
valid = Nothing

invalid : InvalidReason -> CheckResult
invalid = Just

to_string : CheckResult -> String
to_string result = withDefault "" result

-- execute `CheckFunction` sequentially
-- if found invalid `CheckResult`
--   stop immediately (i.e. do not execute later functions)
-- this is useful for function that might make assumption upon previous one
sequentially_check : List CheckFunction -> CheckResult
sequentially_check funcs =
  List.foldl (\func acc -> if acc == valid then func () else acc) valid funcs
