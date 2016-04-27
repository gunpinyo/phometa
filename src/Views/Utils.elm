module Views.Utils where

import Focus exposing (Focus)
import Html exposing (Html, div, text)
import Html.Attributes exposing (class, classList)

import Tools.CssExtra exposing (CssClass)
import Tools.HtmlExtra exposing (on_click, on_blur, on_typing_to_input_field)
import Models.Cursor exposing (CursorInfo, cursor_info_is_here)
import Models.Model exposing (Model, Command, AutoComplete)
import Models.Action exposing (Action(..), address)
import Updates.KeymapUtils exposing (update_auto_complete)
import Models.ViewState exposing (View)

show_indented_clickable_block : CssClass -> CursorInfo ->
                                  Command -> List Html -> Html
show_indented_clickable_block class_name cursor_info command htmls =
  div [ classList [
          ("indented-block", True),
          ("indented-block-on-cursor", cursor_info_is_here cursor_info)]]
      [show_clickable_block class_name cursor_info command htmls]

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

show_auto_complete_filter : CssClass -> CursorInfo -> String -> Command ->
                              Focus Model AutoComplete -> View
show_auto_complete_filter class_name cursor_info placeholder
                            blur_cmd auto_complete_focus model =
  let auto_complete = Focus.get auto_complete_focus model
      css_style = classList [
        (class_name, True),
        ("block-clickable", True),
        ("block-on-cursor", cursor_info_is_here cursor_info)]
   in case auto_complete.unicode_state of
        Nothing ->
          Html.input [
            css_style,
            on_blur address (ActionCommand blur_cmd),
            on_typing_to_input_field address (\string -> ActionCommand <|
              update_auto_complete string auto_complete_focus),
            Html.Attributes.type' "text",
            Html.Attributes.placeholder placeholder,
            Html.Attributes.value auto_complete.filters,
            Html.Attributes.attribute "data-autofocus" ""] []
        Just record ->
          div [css_style] [
            text auto_complete.filters,
            Html.input [
              class "auto-complete-unicode-block",
              on_typing_to_input_field address (\string -> ActionCommand <|
                update_auto_complete string auto_complete_focus),
              Html.Attributes.type' "text",
              Html.Attributes.placeholder "unicode",
              Html.Attributes.value record.filters,
              Html.Attributes.attribute "data-autofocus" ""] []]
