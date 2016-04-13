module Views.Utils where

import Html exposing (Html, div, text)
import Html.Attributes exposing (class, classList)

import Tools.CssExtra exposing (CssClass)
import Tools.HtmlExtra exposing (on_click)
import Models.Cursor exposing (CursorInfo, cursor_info_is_here)
import Models.Model exposing (Command)
import Models.Action exposing (Action(..), address)

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
        on_click address (ActionCommand <| command)]
      htmls
