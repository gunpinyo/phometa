module Views.Definition where

import Html exposing (Html)
import Html.Attributes exposing (classList)
import Graphics.Element exposing (show)

import Tools.HtmlExtra exposing (debug_to_html)
import Models.Cursor exposing (HasCursor)
import Models.RepoModel exposing (NodeName, Definition)
import Models.ViewState exposing (View)

show_definition : HasCursor -> NodeName -> Definition -> View
show_definition has_cursor node_name definition model =
  debug_to_html (has_cursor, definition)
