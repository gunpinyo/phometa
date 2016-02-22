module Views.View where

import Html exposing (Html)
import Html.Attributes exposing (class)
import Html.Lazy exposing (lazy)

import Tools.Flex exposing (flex_div, flex_split, fullbleed)
import Tools.HtmlExtra exposing (import_css, import_javascript)
import Models.Model exposing (Model)
import Views.Keymap exposing (show_keymap_pane)
import Views.Grid exposing (show_grid_pane)

view : Model -> Html
view = lazy show_view

show_view : Model -> Html
show_view model =
  fullbleed
    <| flex_div [] [class "window"]
    <| [import_css "style.css", show_window model]

show_window : Model -> Html
show_window model =
  let side_pane = show_side_pane model
      grid_pane = show_grid_pane model
      cfg       = model.config
   in if cfg.is_package_pane_hided && cfg.is_keymap_pane_hided then
         grid_pane
      else
         flex_split "row" [] [] [
            (fst cfg.side_grid_panes_ratio, side_pane),
            (snd cfg.side_grid_panes_ratio, grid_pane)]

show_side_pane : Model -> Html
show_side_pane model =
  let package_pane = show_package_pane model
      keymap_pane  = show_keymap_pane model
      cfg          = model.config
      css_style = [("flex-direction"  , "column"),
                   ("justify-content" , "center"),
                   ("align-items"     , "stretch")]
   in if not cfg.is_package_pane_hided && cfg.is_keymap_pane_hided then
        package_pane
      else if cfg.is_package_pane_hided && not cfg.is_keymap_pane_hided then
        keymap_pane
      else
        flex_div css_style [] [
            package_pane,
            flex_div [("flex", "0 auto")] [] [keymap_pane]]

show_package_pane : Model -> Html
show_package_pane model =
  flex_div [] [class "pane"] [
    Html.text "this is package pane" ]  -- TODO: do this
