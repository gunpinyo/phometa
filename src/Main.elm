-- TODO: Note: this file currently is just a gateway to test other component
--             need to write this properly

module Main where

import Model.Model exposing (Model)

import Html exposing (button, text)
import Html.Events exposing (onClick)
import Flex exposing (row, column, flexDiv, fullbleed)
import StartApp

main =
  StartApp.start { model = model, view = view, update = update }

model = 0

view address model =
  fullbleed <| column
    [ row
        [ flexDiv [("background-color", "yellow"),("width", "30%")] [] [ text "nw" ]
        , flexDiv [("background-color", "red"),("width", "70%")] [] [ text "ne" ]
        ]
    , row
        [ flexDiv [("background-color", "blue")] [] [ text "sw" ]
        , flexDiv [("background-color", "green")] [] [ text "se" ]
        ]
    ]
  --div []
  --  [ button [ onClick address Decrement ] [ text "-" ]
  --  , div [] [ text (toString model) ]
  --  , button [ onClick address Increment ] [ text "+" ]
  --  ]

type Action = Increment | Decrement

update action model =
  case action of
    Increment -> model + 1
    Decrement -> model - 1
