module View.Pane where

import Signal exposing (Address)

import Flex exposing (row, column, flexN, flexDiv)
import Html exposing (Html)

import Model.InputAction exposing (InputAction)
import Model.Model exposing (Model)
import Model.Pane exposing (Pane(..))
import View.Welcome exposing (show_welcome)
import View.MiniBuffer exposing (show_mini_buffer)

show_pane : Address InputAction -> Model -> Pane -> Html
show_pane address model pane =
  let html =
        case pane of
          PaneContainer r ->
            -- no need to implement when either of ratio is 0
            -- as it is handled correctly in flex-html by default
            (if r.is_vertical then column else row)
              [ flexN (fst r.size_ratio)
                  <| show_pane address model
                  <| fst r.subpanes
              , flexN (snd r.size_ratio)
                  <| show_pane address model
                  <| snd r.subpanes
              ]
          PaneWelcome -> show_welcome address model
          PaneMiniBuffer -> show_mini_buffer address model
      style =
        let pane_style = model.repository.global_config.style.pane
         in [ ("border", pane_style.border)
            , ("padding", pane_style.padding)
            , ("background-color", pane_style.background_color)
            , ("overflow", "hidden")
            --, ("min-height", "0")
            --, ("min-width", "0")
            --, ("max-height", "100%")
            --, ("max-width", "100%")
            --, ("flex-basis", "0px")
            --, ("flex", "1")
            ]
   in flexDiv style [] [html]

----import Html.Events exposing (onClick)
--  fullbleed <| column
--    [ row
--        [ flexDiv [("background-color", "yellow"),("width", "30%")] [] [ text "nw" ]
--        , flexDiv [("background-color", "red"),("width", "70%")] [] [ text "ne" ]
--        ]
--    , row
--        [ flexDiv [("background-color", "blue")] [] [ text "sw" ]
--        , flexDiv [("background-color", "green")] [] [ text "se" ]
--        ]
--    ]
--  --div []
--  --  [ button [ onClick address Decrement ] [ text "-" ]
--  --  , div [] [ text (toString model) ]
--  --  , button [ onClick address Increment ] [ text "+" ]
--  --  ]
