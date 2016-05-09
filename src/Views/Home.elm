module Views.Home where

import Html exposing (Html, div, text, h1, h3, hr, a, textarea)
import Html.Attributes exposing (href, rows, cols, style)

import Tools.Flex exposing (flex_div, flex_split)
import Tools.HtmlExtra exposing (on_typing_to_input_field)
import Models.Cursor exposing (CursorInfo)
import Models.RepoEnDeJson exposing (encode_repository)
import Models.Action exposing (Action(..), address)
import Models.ViewState exposing (View)
import Updates.CommonCmd exposing (cmd_load_repository)

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
                    , text "."]]
    , div [] [ hr [] []
             , text "Load / Save repository by paste-to / copy-from this box"
             ]
    , div [] [ textarea [ style [("margin-top", "10px")], rows 10, cols 50
                        , on_typing_to_input_field address (\string ->
                            ActionCommand <| cmd_load_repository string)]
                        [ text (encode_repository model.root_package)]]]
