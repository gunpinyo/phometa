module Views.Definition where

import Html exposing (Html)
import Html.Attributes exposing (classList)

import Tools.HtmlExtra exposing (debug_to_html)
import Models.Cursor exposing (CursorInfo)
import Models.RepoModel exposing (NodePath, Definition)
import Models.ViewState exposing (View)

show_definition : CursorInfo -> NodePath -> Definition -> View
show_definition cursor_info node_path definition model =
  debug_to_html (cursor_info, definition)
