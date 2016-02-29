module Views.View where

import Html exposing (Html)
import Html.Attributes exposing (class)
import Html.Lazy exposing (lazy)

import Tools.Flex exposing (flex_div, flex_split, fullbleed)
import Tools.HtmlExtra exposing (import_css, import_javascript)
import Models.Model exposing (Model)
import Models.ViewState exposing (View)
import Views.Package exposing (show_package_pane)
import Views.Keymap exposing (show_keymap_pane)
import Views.Grid exposing (show_grids_pane)

view : View
view = lazy show_view

show_view : View
show_view model =
  fullbleed
    <| flex_div [] [class "window"]
    <| [ import_css "style.css"
       , show_window model]

show_window : View
show_window model =
  let side_pane  = show_side_pane model
      grids_pane = show_grids_pane model
      cfg        = model.config
   in if not cfg.show_package_pane && not cfg.show_keymap_pane then
         grids_pane
      else
         flex_split "row" [] [] [
            (fst cfg.side_grids_panes_ratio, side_pane),
            (snd cfg.side_grids_panes_ratio, grids_pane)]

show_side_pane : View
show_side_pane model =
  let package_pane = show_package_pane model
      keymap_pane  = show_keymap_pane model
      cfg          = model.config
      css_style = [("flex-direction"  , "column"),
                   ("justify-content" , "center"),
                   ("align-items"     , "stretch")]
   in if cfg.show_package_pane && not cfg.show_keymap_pane then
        package_pane
      else if not cfg.show_package_pane && cfg.show_keymap_pane then
        keymap_pane
      else
        flex_div css_style [] [
            package_pane,
            flex_div [("flex", "0 auto")] [] [keymap_pane]]
