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
import Models.Model exposing (EditabilityRootTerm(..))
import Models.Action exposing (Action(..), address)
import Models.ViewState exposing (View)
import Updates.Cursor exposing (cmd_click_block)
import Views.Utils exposing (show_indented_clickable_block)
import Views.Term exposing (show_root_term)

show_theorem : CursorInfo -> NodePath -> Theorem -> View
show_theorem cursor_info node_path theorem model =
  let err_msg = "from Views.Theorem.show_theorem"
      theorem_focus = focus_theorem node_path
   in show_indented_clickable_block
        "block" cursor_info (cmd_click_block cursor_info)
        [ div [] [ div [class "keyword-block"] [text " Theorem "]
                 , div [class "newly-defined-block"] [text node_path.node_name]]
        , hr [] []
        , div [] [ div [class "keyword-block"] [text " goal "]
                 , show_root_term
                     (cursor_info_go_to_sub_elem cursor_info 0)
                     node_path.module_path EditabilityRootTermUpToTerm
                     (theorem_focus => goal_) theorem.goal model]
        , div [] [ div [class "keyword-block"] [text " to_prove "]
                 , text "TODO: implement proving system "]]
