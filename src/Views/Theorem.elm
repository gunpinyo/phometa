module Views.Theorem where

import Debug

import Focus exposing ((=>))
import Html exposing (Html, div, text, hr)
import Html.Attributes exposing (class, classList)

import Tools.HtmlExtra exposing (debug_to_html, on_click)
import Models.Focus exposing (goal_)
import Models.Cursor exposing (CursorInfo, cursor_info_go_to_sub_elem,
                               cursor_info_is_here)
import Models.RepoModel exposing (NodePath, Node(..), Theorem)
import Models.RepoUtils exposing (focus_theorem)
import Models.Action exposing (Action(..), address)
import Models.ViewState exposing (View)
import Updates.Cursor exposing (cmd_click_block)
import Views.Term exposing (show_judgement)

show_theorem : CursorInfo -> NodePath -> Theorem -> View
show_theorem cursor_info node_path theorem model =
  let err_msg = "from Views.Theorem.show_theorem"
      theorem_focus = focus_theorem node_path
   in div [classList [("indented-block", True),
                      ("indented-block-clickable", True),
                      ("indented-block-on-cursor", cursor_info_is_here cursor_info)],
           on_click address (ActionCommand <| cmd_click_block cursor_info)] [
        div [] [ div [class "pkw"] [text "Theorem"]
               , div [class "pstr"] [text node_path.node_name]],
        hr [] [],
        div [] [ div [class "pkw"] [text "goal"]
               , show_judgement (cursor_info_go_to_sub_elem cursor_info 0)
                       (theorem_focus => goal_) theorem.goal model],
        div [] [ div [class "pkw"] [text "to_prove"]
               , text "TODO: implement proving system"]]
