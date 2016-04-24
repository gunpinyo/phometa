module Views.Message where

import Html exposing (Html, div, text, table, tr, th, td)
import Html.Attributes exposing (class, classList, style, align)

import Tools.Flex exposing (flex_div)
import Tools.CssExtra exposing (css_inline_str_compile)
import Tools.HtmlExtra exposing (on_click)
import Models.Message exposing (Message(..))
import Models.Action exposing (Action(..), address)
import Models.ViewState exposing (View)
import Updates.Message exposing (cmd_remove_message)
import Views.Utils exposing (show_todo_keyword_block)

show_messages_pane : View
show_messages_pane model =
  let msg_tr_func index message =
        let (keyword, msg_css_inline) = case message of
               MessageSuccess css_inline    -> ("SUCCESS", css_inline)
               MessageInfo css_inline       -> ("INFO", css_inline)
               MessageWarning css_inline    -> ("WARNING", css_inline)
               MessageException css_inline  -> ("EXCEPTION", css_inline)
               MessageFatalError css_inline -> ("FATAL ERROR", css_inline)
               MessageDebug css_inline      -> ("DEBUG", css_inline)
         in tr [] [ td [] [show_todo_keyword_block keyword]
                  , td [] (css_inline_str_compile msg_css_inline)
                  , td [] [div [classList [("button-block", True)
                                          ,("block-clickable", True)],
                                on_click address
                                 (ActionCommand <| cmd_remove_message index)]
                           [text "✖"]]]
      table' = table [style [("width", "100%")]]
        <| List.indexedMap msg_tr_func model.message_list
   in flex_div [] [class "pane"] [table']
