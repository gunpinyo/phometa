module Views.Term where

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
                              micro_mode_, sub_cursor_path_)
import Models.Cursor exposing (IntCursorPath, CursorInfo,
                               cursor_info_is_here,
                               cursor_info_go_to_sub_elem,
                               cursor_tree_go_to_sub_elem)
import Models.RepoModel exposing (ModulePath, GrammarName, VarName, VarType(..),
                                  Term(..), RootTerm)
import Models.RepoUtils exposing (root_term_undefined_grammar, get_grammar,
                                  grammar_allow_variable, get_variable_css)
import Models.Model exposing (Model, Command,
                              RecordModeRootTerm, MicroModeRootTerm(..),
                              EditabilityRootTerm(..))
import Models.ModelUtils exposing (init_auto_complete)
import Models.ViewState exposing (View)
import Updates.CommonCmd exposing (cmd_nothing)
import Updates.ModeRootTerm exposing (cmd_enter_mode_root_term,
                                      focus_auto_complete)
import Views.Utils exposing (show_todo_keyword_block,
                             show_underlined_clickable_block,
                             show_clickable_block,
                             show_auto_complete_filter,
                             show_button)

show_root_term : RecordModeRootTerm -> RootTerm -> View
show_root_term raw_record root_term model =
  let cursor_info = raw_record.top_cursor_info
      record = raw_record
        |> Focus.set sub_cursor_path_ [] -- might be modified by `show_term`
        |> Focus.set micro_mode_
             (MicroModeRootTermSetGrammar init_auto_complete)
      on_click_cmd = cmd_enter_mode_root_term record
   in if root_term.grammar == root_term_undefined_grammar then
        if record.editability /= EditabilityRootTermUpToGrammar then
          show_todo_keyword_block "GRAMMAR UNDEFINED"
        else if cursor_info_is_here cursor_info then
          show_auto_complete_filter "button-block" cursor_info "Choose Grammar"
            cmd_nothing focus_auto_complete model
        else
          show_button "Choose Grammar" (cmd_enter_mode_root_term record)
      else
        let body = [show_term cursor_info record
                     root_term.grammar root_term.term model]
            css_class = if record.editability == EditabilityRootTermReadOnly
                        then "root-term-block" else "modifiable-root-term-block"
         in div [class css_class] body


show_term : CursorInfo -> RecordModeRootTerm -> GrammarName -> Term -> View
show_term cursor_info record grammar_name term model =
  case term of
    TermTodo ->
      let record' = Focus.set micro_mode_
                      (MicroModeRootTermTodo init_auto_complete) record
       in if record.editability == EditabilityRootTermReadOnly then
            show_todo_keyword_block "UNFINISHED TERM"
          else if cursor_info_is_here cursor_info then
            show_auto_complete_filter "term-todo-block" cursor_info grammar_name
              cmd_nothing focus_auto_complete model
          else
            show_clickable_block "term-todo-block" cursor_info
              (cmd_enter_mode_root_term record')
              [Html.text grammar_name]
    TermVar var_name ->
      let record' = Focus.set micro_mode_
                      (MicroModeRootTermNavigate init_auto_complete) record
          var_css = get_variable_css record.module_path model
                      var_name grammar_name
       in show_clickable_block var_css cursor_info
            (cmd_enter_mode_root_term record')
            [Html.text var_name]
    TermInd grammar_choice sub_terms ->
      let record' = Focus.set micro_mode_
                      (MicroModeRootTermNavigate init_auto_complete) record
          sub_grammars = striped_list_get_odd_element grammar_choice
          sub_blocks = List.map2 (,) sub_grammars sub_terms
            |> List.indexedMap (\index (sub_grammar, sub_term) ->
                 show_term
                   (cursor_info_go_to_sub_elem index cursor_info)
                   (cursor_tree_go_to_sub_elem index record)
                   sub_grammar sub_term model)
          format_htmls = striped_list_get_even_element grammar_choice
            |> List.map (\format ->
                 if format == "" then (Html.text "")
                   else div [class "ind-format-block"] [Html.text format])
          htmls = stripe_two_list_together format_htmls sub_blocks
       in show_underlined_clickable_block cursor_info
            (cmd_enter_mode_root_term record') htmls
