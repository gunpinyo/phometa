module Views.Theorem where

import Html exposing (Html, div, text)
import Html.Attributes exposing (class, classList)
import Graphics.Element exposing (show)

import Tools.HtmlExtra exposing (debug_to_html, inline_div)
import Models.Cursor exposing (HasCursor)
import Models.RepoModel exposing (NodeName, Theorem)
import Models.ViewState exposing (View)

show_theorem : HasCursor -> NodeName -> Theorem -> View
show_theorem has_cursor node_name theorem model =
  div [classList [("indented-block", True)]] [
     inline_div [ div [class "pkw"] [text "Theorem"]
                , div [class "pstr"] [text node_name]],
     debug_to_html (has_cursor, theorem)]
