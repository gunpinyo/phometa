module View.View where

import Signal exposing (Address)

import Flex exposing (row, column, flexDiv, fullbleed)
import Html exposing (Html, button, text)
--import Html.Events exposing (onClick)

import Model.Action exposing (Action)
import Model.Model exposing (Model)

view : Address Action -> Model -> Html
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
