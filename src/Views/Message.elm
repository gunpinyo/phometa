module Views.Message where

import Html exposing (Html, div)
import Html.Attributes exposing (class, style, align)

import Tools.Flex exposing (flex_div)
import Tools.CssExtra exposing (css_inline_str_compile)
import Models.Message exposing (Message(..))
import Models.Action exposing (Action(..), address)
import Models.ViewState exposing (View)

show_messages_pane : View
show_messages_pane model =
  let msg_html_func index message =
        let (css_class, msg_css_inline) = case message of
               MessageSuccess css_inline    -> ("msg-success", css_inline)
               MessageInfo css_inline       -> ("msg-info", css_inline)
               MessageWarning css_inline    -> ("msg-warning", css_inline)
               MessageException css_inline  -> ("msg-exception", css_inline)
               MessageFatalError css_inline -> ("msg-fatal-error", css_inline)
               MessageDebug css_inline      -> ("msg-debug", css_inline)
         in div [class css_class]
                (css_inline_str_compile msg_css_inline)
      messages_htmls = List.indexedMap msg_html_func model.message_list
   in flex_div [] [class "pane"] messages_htmls
