module Views.Keymap where

import Dict

import Html exposing (Html, text, table, tr, th, td)
import Html.Attributes exposing (class)

import Tools.Flex exposing (flex_div)
import Tools.Utils exposing (list_skeleton)
import Models.Model exposing (Model, KeyBinding(..))

show_keymap_pane : Model -> Html
show_keymap_pane model =
  let header = List.map (th [] << list_skeleton <<  text)
                 ["Keystroke", "", "Name"]
      detail = Dict.values model.root_keymap
                 |> List.map (\ ((raw_keystroke, name), key_binding) ->
                      let sign = case key_binding of
                                   KeyBindingCommand _ -> ""
                                   KeyBindingPrefix _  -> "+"
                       in List.map (td [] << list_skeleton << text) <|
                            [raw_keystroke, sign, name])
      table' = table [] <| List.map (tr []) <| header :: detail
   in flex_div [] [class "pane"] [table']  -- TODO: do this
