module Tools.Verification where

type alias InvalidReason = String

type alias VerificationResult = Maybe InvalidReason

type alias VerificationFunction = (() -> VerificationResult)

valid : VerificationResult
valid = Nothing

to_invalid : InvalidReason -> VerificationResult
to_invalid reason = Just reason

to_string : VerificationResult -> String
to_string result =
  case result of
    Nothing -> ""
    Just reason -> reason

-- execute `VerificationFunction` sequentially
-- if found invalid `VerificationResult`
--   stop immediately (i.e. do not execute later functions)
-- this is useful for function that might make assumption upon previous one
sequentially_verify : List VerificationFunction -> VerificationResult
sequentially_verify function_list =
  case function_list of
    [] -> valid
    function :: function_tail ->
      let result = function ()
       in if result == valid then
            sequentially_verify function_tail
          else
            result
