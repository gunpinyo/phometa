module Views.Keymap where

import Dict

import Html exposing (Html, text, table, tr, th, td)
import Html.Attributes exposing (class, style)

import Tools.Flex exposing (flex_div)
import Tools.Utils exposing (list_skeleton)
import Models.Model exposing (Model, KeyBinding(..))

show_keymap_pane : Model -> Html
show_keymap_pane model =
  let header = List.map (th [] << list_skeleton <<  text)
                 ["Key", "Name"]
      detail = Dict.values model.root_keymap
                 |> List.map (\ ((raw_keystroke, name), key_binding) -> [
                       td [class "key-binding-keystroke-td"]
                          [text raw_keystroke],
                       td [case key_binding of
                            KeyBindingCommand _ ->
                              class "key-binding-command-name-td"
                            KeyBindingPrefix _  ->
                              class "key-binding-prefix-name-td"]
                          [text name]])
      table' = table [style [("width", "100%")]]
                 <| List.map (tr [])
                 <| header :: detail
   in flex_div [] [class "pane"] [table']
