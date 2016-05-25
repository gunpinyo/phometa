module Views.Keymap where

import Dict
import String

import Html exposing (Html, text, hr , table, tr, th, td)
import Html.Attributes exposing (class, style, align)

import Tools.Flex exposing (flex_div)
import Tools.HtmlExtra exposing (on_click)
import Tools.CssExtra exposing (css_inline_str_compile)
import Tools.Utils exposing (list_skeleton)
import Models.Model exposing (Model, KeyBinding(..))
import Models.Action exposing (Action(..), address)
import Models.ViewState exposing (View)

show_keymap_pane : View
show_keymap_pane model =
  let header = tr [] <| List.map (th [class "text-center"] << list_skeleton
                                                           <<  text)
                                 ["Key", "Description"]
      (info_items, keymap_items) = Dict.toList model.root_keymap
                                     |> List.partition (fst >> List.isEmpty)
      detail = keymap_items
                 |> List.map (\ (keys, ((raw_key, description), key_binding)) ->
                      tr [ on_click address (ActionKeystroke keys)
                         , style [("cursor", "pointer")]] [
                        td [align "center", class "keymap-keystroke-td"]
                           [text raw_key],
                        td [align "center",
                            case key_binding of
                              KbCmd _ -> class "keymap-command-description-td"
                              KbPrefix _ -> class "keymap-prefix-description-td"
                           ]
                           (css_inline_str_compile description)])
      info_item_func key desc = tr []
        [td [align "center", class "keymap-inactive-keystroke-td"] [text key],
         td [align "center"] (css_inline_str_compile desc)]
      info_table_func (_, ((keys, descs) , _)) =
        List.map2 info_item_func (String.split "\n" keys)
                                 (String.split "\n" descs)
          |> table [style [("width", "100%")]]
      table' = header :: detail
        |> table [style [("width", "100%")], class "keymap-table"]
   in flex_div [("flex-direction", "column")] [class "pane"] <|
        case info_items of
          []             -> [table']
          info_item :: _ ->
            [ info_table_func info_item
            , Html.div [style [("width", "100%")]] [hr [] []]
            , table']
