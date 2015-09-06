module Views.Pane where

import Html exposing (div)
import Html.Attributes exposing (classList)

import Tools.Flex exposing (flex_div, flex_grow)
import Tools.HtmlExtra exposing (on_click, on_mouse_enter)
import Models.InputAction exposing (InputAction(..))
import Models.InputAction exposing (ComponentPath)
import Models.Pane exposing (Pane(..))
import Models.EtcAlias exposing (View)
import ModelUtils.Model exposing (is_at_cursor_path, is_at_hovered_path)
import Views.Welcome exposing (show_welcome)
import Views.MiniBuffer exposing (show_mini_buffer)

show_pane : Pane -> ComponentPath -> View
show_pane pane component_path address model =
  let html =
        case pane of
          PaneContainer record ->
            let fst_subpane =
                  show_pane
                    (fst record.subpanes) (0 :: component_path) address model
                snd_subpane =
                  show_pane
                    (snd record.subpanes) (1 :: component_path) address model
                direction_str = if record.is_vertical then "column" else "row"
                (fst_item, snd_item, justify_str) =
                  let fst_valid_size = fst record.size_ratio >= 0
                      snd_valid_size = snd record.size_ratio >= 0
                   in if fst_valid_size && snd_valid_size then
                        ( flex_grow (fst record.size_ratio) fst_subpane
                        , flex_grow (snd record.size_ratio) snd_subpane
                        , "center"
                        )
                      else if fst_valid_size then
                        ( fst_subpane
                        , flex_div [("flex", "0 auto")] [] [snd_subpane]
                        , "flex_end"
                        )
                      else if snd_valid_size then
                        ( flex_div [("flex", "0 auto")] [] [fst_subpane]
                        , snd_subpane
                        , "flex_start"
                        )
                      else
                        ( fst_subpane
                        , snd_subpane
                        , "center"
                        )
                css_style =
                  [ ("flex-direction", direction_str)
                  , ("justify-content", justify_str)
                  , ("align-items", "stretch")
                  ]
             in flex_div css_style [] [fst_item, snd_item]
          PaneWelcome -> show_welcome address model -- TODO: component_path
          PaneMiniBuffer -> show_mini_buffer address model -- TODO: component_path
      attributes =
        [ classList
            [ ("pane", True)
            , ("pane-cursor", is_at_cursor_path model component_path)
            , ("pane-hovered", is_at_hovered_path model component_path)
            ]
        , on_click address <| InputActionClick component_path
        , on_mouse_enter address <| InputActionHover component_path
        ]
   in flex_div [] attributes [html]
