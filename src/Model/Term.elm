module Model.Term where

import Model.Variable exposing (Variable)

type Term
  = TermVar Variable
  | TermAbs Variable Term
  | TermApp Term Term
