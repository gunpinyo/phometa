module Views.View where

import Html.Attributes exposing (class)
import Html.Lazy exposing (lazy)

import Tools.Flex exposing (flex_div, flex_split, fullbleed)
import Tools.HtmlExtra exposing (import_css, import_javascript)
import Models.ViewState exposing (View)
import Views.Package exposing (show_package_pane)
import Views.Keymap exposing (show_keymap_pane)
import Views.Grid exposing (show_grids_pane)
-- import Views.Message exposing (show_messages_pane)

view : View
view = lazy show_view

show_view : View
show_view model =
  fullbleed
    <| flex_div [] [class "window"]
    <| [ import_css "style.css"
       , show_window model
       , import_javascript "naive.js"]

-- TODO: include messages_pane
show_window : View
show_window model =
  let package_pane = show_package_pane model
      keymap_pane  = show_keymap_pane model
      grids_pane = show_grids_pane model
      cfg        = model.config
   in if cfg.show_package_pane && cfg.show_keymap_pane then
        flex_split "row" [] [] [
          (cfg.package_panes_ratio, package_pane),
          (cfg.grids_panes_ratio,   grids_pane),
          (cfg.keymap_panes_ratio,  keymap_pane)]
      else if cfg.show_package_pane then
        flex_split "row" [] [] [
          (cfg.package_panes_ratio, package_pane),
          (cfg.grids_panes_ratio + cfg.keymap_panes_ratio, grids_pane)]
      else if cfg.show_keymap_pane then
        flex_split "row" [] [] [
          (cfg.package_panes_ratio + cfg.grids_panes_ratio, grids_pane),
          (cfg.keymap_panes_ratio,  keymap_pane)]
      else
        grids_pane
