module Tools.RegexExtra where

import Native.Phometa

import Regex exposing (Regex)
import String

-- in Phometa, we only use regex for exact match
-- so these functions put `^` and `$` automatically

safe_regex : String -> Maybe Regex
safe_regex raw_regex_pattern =
  let regex_pattern = "^" ++ raw_regex_pattern ++ "$"
   in if Native.Phometa.isValidRegexPattern regex_pattern
        then Just (Regex.regex regex_pattern)
        else Nothing

unsafe_regex : String -> Regex
unsafe_regex raw_regex_pattern = Regex.regex ("^" ++ raw_regex_pattern ++ "$")

regex_to_string : Regex -> String
regex_to_string = Native.Phometa.regexToString >> String.slice 2 -3
