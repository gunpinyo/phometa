module Views.Utils where

import Html exposing (Html, div)
import Html.Attributes exposing (class, classList)

import Tools.CssExtra exposing (CssClass)
import Tools.HtmlExtra exposing (on_click)
import Models.Cursor exposing (CursorInfo, cursor_info_is_here)
import Models.Model exposing (Command)
import Models.Action exposing (Action(..), address)

show_indented_clickable_block : CssClass -> CursorInfo ->
                                  Command -> List Html -> Html
show_indented_clickable_block class_name cursor_info command htmls =
  div [class "indented-block"]
      [show_clickable_block class_name cursor_info command htmls]

show_underlined_clickable_block : CursorInfo -> Command -> List Html -> Html
show_underlined_clickable_block cursor_info command htmls =
  div [class "underlined-block"]
      [show_clickable_block "underlined-child-block" cursor_info command htmls]

show_clickable_block : CssClass -> CursorInfo -> Command -> List Html -> Html
show_clickable_block class_name cursor_info command htmls =
  div [ classList [
        (class_name, True),
        ("block-clickable", True),
        ("block-on-cursor", cursor_info_is_here cursor_info)],
        on_click address (ActionCommand <| command)]
      htmls
