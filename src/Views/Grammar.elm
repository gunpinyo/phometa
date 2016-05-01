module Views.Grammar where

import Focus exposing ((=>))
import Html exposing (Html, text, div, hr)

import Tools.RegexExtra exposing (regex_to_string)
import Models.Focus exposing (metavar_regex_, literal_regex_, micro_mode_)
import Models.Cursor exposing (CursorInfo, cursor_info_go_to_sub_elem)
import Models.RepoModel exposing (NodePath, Grammar)
import Models.Model exposing (Mode(..), RecordModeGrammar, MicroModeGrammar(..))
import Models.ModelUtils exposing (focus_record_mode_grammar)
import Models.ViewState exposing (View)
import Updates.CommonCmd exposing (cmd_nothing)
import Updates.ModeGrammar exposing (cmd_enter_mode_grammar,
                                     cmd_enter_micro_mode_metavar,
                                     cmd_disable_metavar,
                                     cmd_enter_micro_mode_literal,
                                     cmd_disable_literal,
                                     focus_auto_complete)
import Views.Utils exposing (show_indented_clickable_block,
                             show_clickable_block, show_text_block,
                             show_keyword_block, show_todo_keyword_block,
                             show_close_button, show_auto_complete_filter,
                             show_button)

show_grammar : CursorInfo -> NodePath -> Grammar -> View
show_grammar cursor_info node_path grammar model =
  let record = { node_path        = node_path
               , top_cursor_info  = cursor_info
               , sub_cursor_path  = []
               , micro_mode       = MicroModeGrammarNavigate
               }
      header_html = div []
        [ show_keyword_block <|
            if grammar.has_locked then "Grammar" else "Draft Grammar"
        , show_text_block "grammar-block" node_path.node_name ]
      metavar_regex_header =  [ show_keyword_block "metavar_regex", text " "]
      metavar_unlocked_inactive = metavar_regex_header ++
        case grammar.metavar_regex of
          Nothing -> [show_button (cmd_enter_micro_mode_metavar record)
                       [text "Disabled"]]
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
        else case model.mode of
          ModeGrammar record' ->
            if node_path /= record'.node_path then
              metavar_unlocked_inactive
            else
              case record'.micro_mode of
                MicroModeGrammarSetMetaVarRegex _ ->
                  metavar_regex_header ++
                  [ show_auto_complete_filter "regex-block"
                      (cursor_info_go_to_sub_elem 0 cursor_info)
                      "metavar regex" cmd_nothing focus_auto_complete model
                  , text " "
                  , show_close_button <| cmd_disable_metavar record]
                _ -> metavar_unlocked_inactive
          _                   -> metavar_unlocked_inactive)
      literal_regex_header =  [ show_keyword_block "literal_regex", text " "]
      literal_unlocked_inactive = literal_regex_header ++
        case grammar.literal_regex of
          Nothing -> [show_button (cmd_enter_micro_mode_literal record)
                       [text "Disabled"]]
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
        else case model.mode of
          ModeGrammar record' ->
            if node_path /= record'.node_path then
              literal_unlocked_inactive
            else
              case record'.micro_mode of
                MicroModeGrammarSetLiteralRegex _ ->
                  literal_regex_header ++
                  [ show_auto_complete_filter "regex-block"
                      (cursor_info_go_to_sub_elem 1 cursor_info)
                      "literal regex" cmd_nothing focus_auto_complete model
                  , text " "
                  , show_close_button <| cmd_disable_literal record]
                _ -> literal_unlocked_inactive
          _                   -> literal_unlocked_inactive)
      choices_html = Html.text "TODO" -- TODO: finish this
   in show_indented_clickable_block cursor_info (cmd_enter_mode_grammar record)
        [ header_html
        , hr [] []
        , metavar_regex_html
        , literal_regex_html
        , choices_html ]
