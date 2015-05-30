module View.Term where

import Model.Term exposing (..)
import View.Variable exposing (printVariable)

printTerm : Term -> String
printTerm term
  = case term of
      TermVar x
        -> printVariable x
      TermAbs x m
        -> "λ" ++ (printVariable x) ++ "." ++ (printTerm m)
      TermApp m n
        -> "(" ++ (printTerm m) ++ ") (" ++ (printTerm n) ++ ")"
