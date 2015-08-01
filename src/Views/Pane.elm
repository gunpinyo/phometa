module Views.Pane where

import Signal exposing (Address)
import List

import Html exposing (Html, div)

import Tools.Utils exposing (parity_pair_extract)
import Tools.Flex exposing (flex_div, flex_css, flex_grow)
import Tools.HtmlExtra exposing (on_click)
import Models.InputAction exposing (InputAction(..))
import Models.Model exposing (ComponentPath, Model)
import Models.Pane exposing (Pane(..))
import ModelUtils.Model exposing (is_at_cursor_path)
import Views.Welcome exposing (show_welcome)
import Views.MiniBuffer exposing (show_mini_buffer)

show_pane : Address InputAction -> Model -> Pane -> ComponentPath -> Html
show_pane address model pane component_path =
  let html =
        case pane of
          PaneContainer r ->
            let fst_subpane =
                  show_pane address model
                    (fst r.subpanes) (0 :: component_path)
                snd_subpane =
                  show_pane address model
                    (snd r.subpanes) (1 :: component_path)
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
                css =
                  [ ("flex-direction", direction_str)
                  , ("justify-content", justify_str)
                  , ("align-items", "stretch")
                  ]
             in flex_div css [] [fst_item, snd_item]
          PaneWelcome -> show_welcome address model -- TODO: component_path
          PaneMiniBuffer -> show_mini_buffer address model -- TODO: component_path
      css =
        let global_style = model.repository.global_config.style
            maybe_cursor_css =
              if is_at_cursor_path model component_path
                then global_style.interactive.cursor_css else []
         in global_style.pane.css ++ maybe_cursor_css
      attributes =
        [ on_click address <| InputActionClick component_path
        ]
   in flex_div css attributes [html]
