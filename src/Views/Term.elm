module Views.Term where

import Debug

import Focus exposing (Focus, (=>))
import Html exposing (Html, div, text, hr)
import Html.Attributes exposing (class, classList)

import Tools.HtmlExtra exposing (debug_to_html, inline_div, on_click)
import Models.Focus exposing (context_, root_term_)
import Models.Cursor exposing (CursorInfo,
                               cursor_info_is_here,
                               cursor_info_go_to_sub_elem)
import Models.RepoModel exposing (RootTerm, Judgement)
import Models.Model exposing (Model)
import Models.Action exposing (Action(..), address)
import Models.ViewState exposing (View)
import Updates.Cursor exposing (cmd_click_block)

show_judgement : CursorInfo -> Focus Model Judgement -> Judgement -> View
show_judgement cursor_info judgement_focus judgemet model =
  inline_div [
    classList [
      ("inline-block", True),
      ("inline-block-clickable", True),
      ("inline-block-on-cursor", cursor_info_is_here cursor_info)],
      on_click address (ActionCommand <| cmd_click_block cursor_info)][
    show_root_term (cursor_info_go_to_sub_elem cursor_info 0)
      (judgement_focus => context_) judgemet.context model,
    div [class "pkw"] [Html.text "⊢"],
    show_root_term (cursor_info_go_to_sub_elem cursor_info 1)
      (judgement_focus => root_term_) judgemet.root_term model]

show_root_term : CursorInfo -> Focus Model RootTerm -> RootTerm -> View
show_root_term cursor_info root_term_focus root_term model =
  Html.text "sdfd"
