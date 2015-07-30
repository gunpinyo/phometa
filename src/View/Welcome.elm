module View.Welcome where

import Signal exposing (Address)

import Flex exposing (row, column, flexN, flexDiv)
import Html exposing (Html, node, button, text)

import Model.InputAction exposing (InputAction)
import Model.Model exposing (Model)

show_welcome : Address InputAction -> Model -> Html
show_welcome address model =
  flexDiv [("overflow", "auto"), ("width", "50%"), ("min-width", "0")] []
    [ text
        <| "Welcomeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee" ++
           "eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee" ++
           "eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee" ++
           "eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee to phometa!!!"
    ]
