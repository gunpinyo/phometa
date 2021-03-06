module Views.Utils where

import Focus exposing (Focus)
import Html exposing (Html, div, text, span, i, button)
import Html.Attributes exposing (class, classList, style)

import Tools.CssExtra exposing (CssClass)
import Tools.HtmlExtra exposing (on_click, on_blur, on_typing_to_input_field)
import Models.Cursor exposing (CursorInfo, cursor_info_is_here)
import Models.Model exposing (Model, Command, AutoComplete)
import Models.Action exposing (Action(..), address)
import Updates.KeymapUtils exposing (update_auto_complete)
import Models.ViewState exposing (View)

show_indented_clickable_block : CursorInfo -> Command -> List Html -> Html
show_indented_clickable_block cursor_info command htmls =
  div [ classList [
          ("indented-block", True),
          ("indented-block-on-cursor", cursor_info_is_here cursor_info)],
        on_click address (ActionCommand command)]
      htmls

show_underlined_clickable_block : CursorInfo -> Command -> List Html -> Html
show_underlined_clickable_block cursor_info command htmls =
  div [class "underlined-block"]
      [show_clickable_block "underlined-child-block" cursor_info command htmls]

show_text_block : CssClass -> String -> Html
show_text_block class_name string =
  div [class class_name] [text string]

show_keyword_block : String -> Html
show_keyword_block = show_text_block "keyword-block"

show_todo_keyword_block : String -> Html
show_todo_keyword_block = show_text_block "todo-keyword-block"

show_clickable_block : CssClass -> CursorInfo -> Command -> List Html -> Html
show_clickable_block class_name cursor_info command htmls =
  div [ classList [
          (class_name, True),
          ("block-clickable", True),
          ("block-on-cursor", cursor_info_is_here cursor_info)],
      on_click address (ActionCommand command)]
      htmls

show_html_button : CssClass -> CursorInfo -> Command -> List Html -> Html
show_html_button class_name cursor_info command htmls =
  div [class "modifiable-block"]
    [show_clickable_block class_name cursor_info command htmls]

show_button : String -> Command -> Html
show_button string command =
  button
    [ Html.Attributes.type' "button"
    , on_click address (ActionCommand command) ]
    [ text string ]

show_float_right_button : String -> Command -> Html
show_float_right_button string command =
  div [ class "button-panel" ]
      [ text " "
      , show_button string command ]

show_plain_icon_button : Bool -> String -> Command -> Html
show_plain_icon_button is_float string command =
  div [class <| if is_float then "button-panel" else "button-non-float"]
      [ text " "
      , button [ Html.Attributes.type' "button"
               , on_click address (ActionCommand command) ]
          [ i [ classList [ ("fa", True)
                          , ("fa-lg", is_float)
                          , (string, True)]] [] ]
      ]

show_icon_button : String -> Command -> Html
show_icon_button = show_plain_icon_button True

show_ok_button : Command -> Html
show_ok_button = show_icon_button "fa-check"

show_close_button : Command -> Html
show_close_button = show_icon_button "fa-times"

show_non_float_close_button : Command -> Html
show_non_float_close_button = show_plain_icon_button False "fa-times"

show_reset_button : Command -> Html
show_reset_button = show_icon_button "fa-undo"

show_lock_button : Command -> Html
show_lock_button = show_icon_button "fa-lock"

show_swap_button : Command -> Html
show_swap_button = show_icon_button "fa-arrows-v"

show_focus_button : Command -> Html
show_focus_button = show_icon_button "fa-thumb-tack"

show_unfocus_button : Command -> Html
show_unfocus_button = show_icon_button "fa-sign-out"

show_auto_complete_filter : CssClass -> CursorInfo -> String ->
                              Focus Model AutoComplete -> View
show_auto_complete_filter class_name cursor_info placeholder
                            auto_complete_focus model =
  let auto_complete = Focus.get auto_complete_focus model
      css_style = classList [
        (class_name, True),
        ("block-clickable", True),
        ("block-on-cursor", cursor_info_is_here cursor_info)]
   in case auto_complete.unicode_state of
        Nothing ->
          Html.input ([
              css_style,
              on_typing_to_input_field address (\string -> ActionCommand <|
                update_auto_complete string auto_complete_focus),
              Html.Attributes.type' "text",
              Html.Attributes.placeholder placeholder,
              Html.Attributes.attribute "data-autofocus" ""] ++
              if not auto_complete.need_to_fetch then [] else
                [Html.Attributes.value auto_complete.filters])
            [text auto_complete.filters]
        Just record ->
          div [css_style] [
            text auto_complete.filters,
            Html.input [
                class "auto-complete-unicode-block",
                on_typing_to_input_field address (\string -> ActionCommand <|
                  update_auto_complete string auto_complete_focus),
                Html.Attributes.type' "text",
                Html.Attributes.placeholder "unicode",
                Html.Attributes.attribute "data-autofocus" ""]
              [text record.filters]]
