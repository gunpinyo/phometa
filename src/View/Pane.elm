module View.Pane where

import Signal exposing (Address)

import Html exposing (Html, div)
import Html.Attributes exposing (style)

import Model.InputAction exposing (InputAction)
import Model.Model exposing (Model)
import Model.Pane exposing (Pane(..))
import View.Welcome exposing (show_welcome)
import View.MiniBuffer exposing (show_mini_buffer)
import Tool.Flex exposing (flex_div, flex_css, flex_grow)

show_pane : Address InputAction -> Model -> Pane -> Html
show_pane address model pane =
  let html =
        case pane of
          PaneContainer r ->
            let fst_subpane = show_pane address model <| fst r.subpanes
                snd_subpane = show_pane address model <| snd r.subpanes
                direction_str = if r.is_vertical then "column" else "row"
                (fst_item, snd_item, justify_str) =
                  if fst r.size_ratio >= 0 && snd r.size_ratio >= 0 then
                    ( flex_grow (fst r.size_ratio) fst_subpane
                    , flex_grow (snd r.size_ratio) snd_subpane
                    , "center"
                    )
                  else if fst r.size_ratio >= 0 then
                    ( fst_subpane
                    , flex_css [("flex", "0 auto")] snd_subpane
                    , "flex_end"
                    )
                  else if snd r.size_ratio >= 0 then
                    ( flex_css [("flex", "0 auto")] fst_subpane
                    , snd_subpane
                    , "flex_start"
                    )
                  else
                    ( fst_subpane
                    , snd_subpane
                    , "center"
                    )
                css_block =
                  [ ("flex-direction", direction_str)
                  , ("justify-content", justify_str)
                  , ("align-items", "stretch")
                  ]
             in flex_div css_block [] [fst_item, snd_item]
          PaneWelcome -> show_welcome address model
          PaneMiniBuffer -> show_mini_buffer address model
      css_block =
        let pane_style = model.repository.global_config.style.pane
         in [ ("border", pane_style.border)
            , ("padding", pane_style.padding)
            , ("background-color", pane_style.background_color)
            , ("overflow", "auto")
            ]
   in flex_css css_block html
