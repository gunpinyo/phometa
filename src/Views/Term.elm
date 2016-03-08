module Views.Term where

import Debug

import Focus exposing (Focus, (=>))
import Html exposing (Html, div, text, hr)
import Html.Attributes exposing (class, classList,
                                 type', placeholder, attribute)

import Tools.HtmlExtra exposing (debug_to_html, on_blur, on_click,
                                 on_typing_to_input_field)
import Tools.StripedList exposing (striped_list_get_even_element,
                                   striped_list_get_odd_element,
                                   stripe_two_list_together)
import Models.Focus exposing (context_, root_term_,
                              micro_mode_, sub_term_cursor_path_)
import Models.Cursor exposing (IntCursorPath, CursorInfo,
                               cursor_info_is_here,
                               cursor_info_go_to_sub_elem,
                               cursor_info_get_ref_path)
import Models.RepoModel exposing (ModulePath, GrammarName,
                                  Term(..), RootTerm)
import Models.RepoUtils exposing (root_term_undefined_grammar, get_grammar)
import Models.Model exposing (Model, RecordModeRootTerm, MicroModeRootTerm(..),
                              EditabilityRootTerm)
import Models.Action exposing (Action(..), address)
import Models.ViewState exposing (View)
import Updates.Cursor exposing (cmd_click_block)
import Updates.ModeRootTerm exposing (cmd_enter_mode_root_term,
                                      cmd_get_var_from_term_todo,
                                      cmd_from_todo_for_var_to_var)
import Views.Utils exposing (show_underlined_clickable_block,
                             show_clickable_block)

show_root_term : CursorInfo -> ModulePath -> EditabilityRootTerm ->
                   Focus Model RootTerm -> RootTerm -> View
show_root_term
    cursor_info module_path editability root_term_focus root_term model =
  let record = { module_path = module_path
               , root_term_focus = root_term_focus
               , root_term_cursor_info = cursor_info
               , sub_term_cursor_path = [] -- might be modified by `show_term`
               , micro_mode = MicroModeRootTermSetGrammar 0 -- the same as above
               , editability = editability
               }
   in if root_term.grammar == root_term_undefined_grammar then
        show_clickable_block "grammar-todo-block" cursor_info
          (cmd_enter_mode_root_term record)
          [Html.text "Choose Grammar"]
      else
        show_term cursor_info record root_term.grammar root_term.term model

show_term : CursorInfo -> RecordModeRootTerm -> GrammarName -> Term -> View
show_term cursor_info record grammar_name term model =
  case term of
    TermTodo ->
      let record' = Focus.set micro_mode_ (MicroModeRootTermTodo 0) record
          has_var_regex = case get_grammar { module_path = record.module_path
                                           , node_name = grammar_name
                                           } model of
                            Nothing -> False
                            Just grammar ->
                              grammar.var_regex /= Nothing

       in if cursor_info_is_here cursor_info && has_var_regex then
            Html.input [
              classList [
                ("term-todo-block", True),
                ("block-clickable", True),
                ("block-on-cursor", cursor_info_is_here cursor_info)],
              on_click address
                (ActionCommand <| cmd_enter_mode_root_term record'),
              on_typing_to_input_field address
                (\string -> ActionCommand <| cmd_get_var_from_term_todo string),
              on_blur address (ActionCommand <| cmd_from_todo_for_var_to_var),
              type' "text",
              placeholder grammar_name,
              attribute "data-autofocus" ""] []
          else
            show_clickable_block "term-todo-block" cursor_info
              (cmd_enter_mode_root_term record')
              [Html.text grammar_name]
    TermVar var_name ->
      let record' = Focus.set micro_mode_ MicroModeRootTermNavigate record
       in show_clickable_block "variable-block" cursor_info
            (cmd_enter_mode_root_term record')
            [Html.text var_name]
    TermInd grammar_choice sub_terms ->
      let record' = Focus.set micro_mode_ MicroModeRootTermNavigate record
          sub_grammars = striped_list_get_odd_element grammar_choice
          sub_blocks = List.map2 (,) sub_grammars sub_terms
            |> List.indexedMap (\index (sub_grammar, sub_term) ->
                 show_term (cursor_info_go_to_sub_elem cursor_info index)
                   (Focus.update sub_term_cursor_path_
                      (\cursor_path -> cursor_path ++ [index]) record)
                   sub_grammar sub_term model)
          format_htmls = striped_list_get_even_element grammar_choice
            |> List.map (\format ->
                 if format == "" then (Html.text "")
                   else div [class "ind-format-block"] [Html.text format])
          htmls = stripe_two_list_together format_htmls sub_blocks
       in show_underlined_clickable_block cursor_info
            (cmd_enter_mode_root_term record') htmls
