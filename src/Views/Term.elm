module Views.Term where

import Debug

import Focus exposing (Focus, (=>))
import Html exposing (Html, div, text, hr)
import Html.Attributes exposing (class, classList)

import Tools.HtmlExtra exposing (debug_to_html, on_click)
import Tools.StripedList exposing (striped_list_get_even_element,
                                   striped_list_get_odd_element,
                                   stripe_two_list_together)
import Models.Focus exposing (context_, root_term_)
import Models.Cursor exposing (IntCursorPath, CursorInfo,
                               cursor_info_is_here,
                               cursor_info_go_to_sub_elem,
                               cursor_info_get_ref_path)
import Models.RepoModel exposing (ModulePath, GrammarName,
                                  Term(..), RootTerm, Judgement)
import Models.RepoUtils exposing (root_term_undefined_grammar)
import Models.Model exposing (Model)
import Models.Action exposing (Action(..), address)
import Models.ViewState exposing (View)
import Updates.Cursor exposing (cmd_click_block)
import Views.Utils exposing (show_underlined_clickable_block,
                             show_clickable_block)

type alias ViewsTermCarrier =
  { module_path : ModulePath
  , root_term_focus : Focus Model RootTerm
  , root_term_cursor_ref : IntCursorPath
  , is_editable : Bool
  }

show_judgement : CursorInfo -> ModulePath -> Bool ->
                   Focus Model Judgement -> Judgement -> View
show_judgement
    cursor_info module_path is_editable judgement_focus judgemet model =
  show_clickable_block
    "inline-block" cursor_info (cmd_click_block cursor_info)
    [ show_root_term (cursor_info_go_to_sub_elem cursor_info 0) module_path
        is_editable (judgement_focus => context_) judgemet.context model,
      div [class "keyword-block"] [Html.text " ⊢ "],
      show_root_term (cursor_info_go_to_sub_elem cursor_info 1) module_path
        is_editable (judgement_focus => root_term_) judgemet.root_term model]

show_root_term : CursorInfo -> ModulePath -> Bool ->
                   Focus Model RootTerm -> RootTerm -> View
show_root_term
    cursor_info module_path is_editable root_term_focus root_term model =
  if root_term.grammar == root_term_undefined_grammar then
    show_clickable_block "grammar-todo-block" cursor_info
      (cmd_click_block cursor_info) [Html.text "Choose Grammar"]
  else
    let carrier = { module_path = module_path
                  , root_term_focus = root_term_focus
                  , root_term_cursor_ref = cursor_info_get_ref_path cursor_info
                  , is_editable = is_editable
                  }
     in show_term cursor_info carrier root_term.grammar root_term.term model

show_term : CursorInfo -> ViewsTermCarrier -> GrammarName -> Term -> View
show_term cursor_info carrier grammar_name term model =
  case term of
    TermTodo ->
      show_clickable_block "term-todo-block" cursor_info
        (cmd_click_block cursor_info) [Html.text grammar_name]
    TermVar var_name ->
      show_clickable_block "variable-block" cursor_info
        (cmd_click_block cursor_info) [Html.text var_name]
    TermInd grammar_choice sub_terms ->
      let sub_grammars = striped_list_get_odd_element grammar_choice
          sub_blocks = List.map2 (,) sub_grammars sub_terms
            |> List.indexedMap (\index (sub_grammar, sub_term) ->
                 show_term (cursor_info_go_to_sub_elem cursor_info index)
                   carrier sub_grammar sub_term model)
          format_htmls = striped_list_get_even_element grammar_choice
            |> List.map (\format ->
                 if format == "" then (Html.text "")
                   else div [class "ind-format-block"] [Html.text format])
          htmls = stripe_two_list_together format_htmls sub_blocks
       in show_underlined_clickable_block cursor_info
            (cmd_click_block cursor_info) htmls
