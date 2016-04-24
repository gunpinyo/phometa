module Views.Home where

import Html exposing (Html, div, text, h1, h3, hr,a)
import Html.Attributes exposing (href)

import Tools.Flex exposing (flex_div, flex_split)
import Models.Cursor exposing (CursorInfo)
import Models.ViewState exposing (View)

show_home : CursorInfo -> View
show_home cursor_info model =
  flex_div [("flex-direction" , "column"),
            ("align-items", "center"),
            ("justify-content", "center")] []
    [ div [] [h1 [] [ hr [] []
                    , text "!! Welcome to phometa !!"
                    , hr [] []]]
    , div [] [h3 [] [ text "Please select any item in package pane to start."]]
    , div [] [h3 [] [ text "For further information, please visit "
                    , a [href "https://github.com/gunpinyo/phometa"]
                        [text "phometa repository"]
                    , text "."]]]
