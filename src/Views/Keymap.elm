module Views.Keymap where

import Dict

import Html exposing (Html, text, table, tr, th, td)
import Html.Attributes exposing (class, style, align)

import Tools.Flex exposing (flex_div)
import Tools.HtmlExtra exposing (on_click)
import Tools.Utils exposing (list_skeleton)
import Models.Model exposing (Model, KeyBinding(..))
import Models.Action exposing (Action(..), address)
import Models.ViewState exposing (View)

show_keymap_pane : View
show_keymap_pane model =
  let header = tr [] <| List.map (th [] << list_skeleton <<  text)
                                 ["Key", "Description"]
      detail = Dict.toList model.root_keymap
                 |> List.map (\ (keys, ((raw_key, description), key_binding)) ->
                      tr [on_click address (ActionKeystroke keys)] [
                        td [align "center", class "keymap-keystroke-td"]
                           [text raw_key],
                        td [align "center",
                            case key_binding of
                              KbCmd _ -> class "keymap-command-description-td"
                              KbPrefix _ -> class "keymap-prefix-description-td"
                           ]
                           [text description]])
      table' = table [style [("width", "100%")], class "keymap-table"]
                 <| header :: detail
   in flex_div [] [class "pane"] [table']
