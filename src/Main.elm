-- TODO: Note: this file currently is just a gateway to test other component
--             need to write this properly

module Main where

import Graphics.Element exposing (Element, show)
--import Model.Term exposing (..)
--import View.Term exposing (..)
import Model.Repository
--exampleTerm : Term
--exampleTerm = TermApp (TermVar "4") (TermAbs "r" (TermVar "e"))

main : Element
main =
  show <| "hey"
