module Views.Grammar where

import Focus exposing ((=>))
import Html exposing (Html, text, div, hr)
import String

import Tools.RegexExtra exposing (regex_to_string)
import Tools.CssExtra exposing (css_inline_str_compile, css_inline_str_embed)
import Tools.StripedList exposing (striped_list_eliminate,
                                   striped_list_get_odd_element,
                                   striped_list_get_even_element,
                                   stripe_two_list_together)
import Models.Focus exposing (metavar_regex_, literal_regex_, micro_mode_)
import Models.Cursor exposing (CursorInfo, cursor_info_go_to_sub_elem)
import Models.RepoModel exposing (NodePath, Grammar)
import Models.RepoUtils exposing (root_term_undefined_grammar)
import Models.Model exposing (Mode(..), RecordModeGrammar, MicroModeGrammar(..))
import Models.ModelUtils exposing (focus_record_mode_grammar,
                                   get_record_mode_grammar)
import Models.ViewState exposing (View)
import Updates.CommonCmd exposing (cmd_nothing)
import Updates.ModeRootTerm exposing (embed_css_grammar_choice)
import Updates.ModeGrammar exposing (cmd_enter_mode_grammar,
                                     cmd_enter_micro_mode_navigate,
                                     cmd_enter_micro_mode_metavar,
                                     cmd_enter_micro_mode_add_choice,
                                     cmd_enter_micro_mode_format,
                                     cmd_enter_micro_mode_grammar,
                                     cmd_disable_metavar,
                                     cmd_enter_micro_mode_literal,
                                     cmd_disable_literal,
                                     cmd_lock_grammar,
                                     cmd_swap_choice, cmd_delete_choice,
                                     focus_auto_complete)
import Views.Utils exposing (show_indented_clickable_block,
                             show_clickable_block, show_text_block,
                             show_keyword_block, show_todo_keyword_block,
                             show_close_button, show_auto_complete_filter,
                             show_button, show_lock_button, show_swap_button)

show_grammar : CursorInfo -> NodePath -> Grammar -> View
show_grammar cursor_info node_path grammar model =
  let record = { node_path        = node_path
               , top_cursor_info  = cursor_info
               , sub_cursor_path  = []
               , micro_mode       = MicroModeGrammarNavigate
               }
      header_htmls =
        [ show_keyword_block <|
            if grammar.has_locked then "Grammar" else "Draft Grammar"
        , show_text_block "grammar-block" node_path.node_name ]
      lock_button =  if grammar.has_locked then [] else
             [show_lock_button <| cmd_enter_micro_mode_navigate record
                                    >> cmd_lock_grammar]
      metavar_regex_header =  [ show_keyword_block "metavar_regex", text " "]
      metavar_unlocked_inactive = metavar_regex_header ++
        case grammar.metavar_regex of
          Nothing -> [show_button "Disabled"
                        (cmd_enter_micro_mode_metavar record)]
          Just regex ->
            [ show_clickable_block
                "regex-block"
                (cursor_info_go_to_sub_elem 0 cursor_info)
                (cmd_enter_micro_mode_metavar record)
                [text <| regex_to_string regex]
            , show_close_button <| cmd_disable_metavar record]
      metavar_regex_html = div [] (
        if grammar.has_locked then
          case grammar.metavar_regex of
            Nothing -> []
            Just regex -> metavar_regex_header ++
              [show_text_block "regex-block" (regex_to_string regex)]
        else case get_record_mode_grammar node_path model of
          Nothing      -> metavar_unlocked_inactive
          Just record' ->
            case record'.micro_mode of
              MicroModeGrammarSetMetaVarRegex _ ->
                metavar_regex_header ++
                [ show_auto_complete_filter "regex-block"
                    (cursor_info_go_to_sub_elem 0 cursor_info)
                    "metavar regex" cmd_nothing
                    focus_auto_complete model
                , text " "
                , show_close_button <| cmd_disable_metavar record]
              _ -> metavar_unlocked_inactive)
      literal_regex_header =  [ show_keyword_block "literal_regex", text " "]
      literal_unlocked_inactive = literal_regex_header ++
        case grammar.literal_regex of
          Nothing -> [show_button "Disabled"
                        (cmd_enter_micro_mode_literal record)]
          Just regex ->
            [ show_clickable_block
                "regex-block"
                (cursor_info_go_to_sub_elem 0 cursor_info)
                (cmd_enter_micro_mode_literal record)
                [text <| regex_to_string regex]
            , show_close_button <| cmd_disable_literal record]
      literal_regex_html = div [] (
        if grammar.has_locked then
          case grammar.literal_regex of
            Nothing -> []
            Just regex -> literal_regex_header ++
              [show_text_block "regex-block" (regex_to_string regex)]
        else case get_record_mode_grammar node_path model of
          Nothing      -> literal_unlocked_inactive
          Just record' ->
            case record'.micro_mode of
              MicroModeGrammarSetLiteralRegex _ ->
                literal_regex_header ++
                [ show_auto_complete_filter "regex-block"
                    (cursor_info_go_to_sub_elem 0 cursor_info)
                    "literal regex" cmd_nothing
                    focus_auto_complete model
                , text " "
                , show_close_button <| cmd_disable_literal record]
              _ -> literal_unlocked_inactive)
      add_choice_inactive = [show_button "Add Choice"
                              (cmd_enter_micro_mode_add_choice record)]
      choices_header_htmls = (text " ") ::
        if grammar.has_locked then [] else
          case get_record_mode_grammar node_path model of
            Nothing      -> add_choice_inactive
            Just record' ->
              case record'.micro_mode of
                MicroModeGrammarAddChoice _ ->
                  [show_auto_complete_filter "button-block"
                    (cursor_info_go_to_sub_elem 2 cursor_info)
                    "number of sub-terms" cmd_nothing
                    focus_auto_complete model]
                _ -> add_choice_inactive
      choices_aux = case get_record_mode_grammar node_path model of
        Nothing -> Nothing
        Just record' -> case record'.micro_mode of
          MicroModeGrammarSetChoiceFormat _ choice_index sub_index ->
            Just (True, choice_index, sub_index)
          MicroModeGrammarSetChoiceGrammar _ choice_index sub_index ->
            Just (False, choice_index, sub_index)
          _ -> Nothing
      choices_html = div [] <|
         if grammar.has_locked then
           List.map (\choice ->  choice
             |> embed_css_grammar_choice
             |> css_inline_str_compile
             |> ((::) <| show_keyword_block "choice ")
             |> div []) grammar.choices
         else
           List.indexedMap (\choice_index choice ->
             let cursor_info_func sub_index = cursor_info
                   |> cursor_info_go_to_sub_elem 3
                   |> cursor_info_go_to_sub_elem choice_index
                   |> cursor_info_go_to_sub_elem sub_index
                 format_htmls = choice
                   |> striped_list_get_even_element
                   |> List.indexedMap (\fmt_index fmt_string ->
                        if choices_aux == Just (True, choice_index, fmt_index)
                        then show_auto_complete_filter "ind-format-block"
                          (cursor_info_func (2 * fmt_index)) "format"
                          cmd_nothing focus_auto_complete model
                        else if fmt_string == "" then
                          show_button "Format" (cmd_enter_micro_mode_format
                            choice_index fmt_index record)
                        else show_clickable_block "ind-format-block"
                          (cursor_info_func (2 * fmt_index))
                          (cmd_enter_micro_mode_format choice_index
                             fmt_index record) [text fmt_string])
                 grammar_name_htmls = choice
                   |> striped_list_get_odd_element
                   |> List.indexedMap (\gmr_index gmr_string ->
                        if choices_aux == Just (False, choice_index, gmr_index)
                        then show_auto_complete_filter "grammar-block"
                          (cursor_info_func (2 * gmr_index + 1)) "sub-grammar"
                          cmd_nothing focus_auto_complete model
                        else if gmr_string == root_term_undefined_grammar then
                          show_button "Grammar" (cmd_enter_micro_mode_grammar
                            choice_index gmr_index record)
                        else show_clickable_block "grammar-block"
                            (cursor_info_func (2 * gmr_index + 1))
                            (cmd_enter_micro_mode_grammar choice_index
                               gmr_index record) [text gmr_string])
              in div [] <|
                   [show_keyword_block "choice "] ++
                   stripe_two_list_together format_htmls grammar_name_htmls ++
                   [show_close_button <| cmd_enter_micro_mode_navigate record
                                           >> cmd_delete_choice choice_index] ++
                   (if List.length grammar.choices == 1 then [] else
                      [show_swap_button <| cmd_enter_micro_mode_navigate record
                                             >> cmd_swap_choice choice_index])
            ) grammar.choices
   in show_indented_clickable_block cursor_info (cmd_enter_mode_grammar record)
        [ div [] (header_htmls ++ choices_header_htmls ++ lock_button)
        , hr [] []
        , metavar_regex_html
        , literal_regex_html
        , choices_html ]
