module Views.Home where

import Html exposing (Html)

import Models.Cursor exposing (CursorInfo)
import Models.ViewState exposing (View)

show_home : CursorInfo -> View
show_home cursor_info model = Html.text "Welcome to phometa !!!" -- TODO: finish this
