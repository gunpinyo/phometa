module Updates.ModeGrammar where

import Regex exposing (Regex)
import Focus exposing (Focus, (=>))

import Tools.RegexExtra exposing (safe_regex, regex_to_string)
import Tools.CssExtra exposing (css_inline_str_embed)
import Models.Focus exposing (mode_, micro_mode_, reversed_ref_path_,
                              node_name_, sub_cursor_path_,
                              metavar_regex_, literal_regex_, filters_)
import Models.Cursor exposing (IntCursorPath, CursorInfo,
                               cursor_info_is_here,
                               get_cursor_info_from_cursor_tree,
                               cursor_info_go_to_sub_elem,
                               cursor_tree_go_to_sub_elem)
import Models.RepoModel exposing (Grammar, Term(..), RuleName)
import Models.RepoUtils exposing (focus_grammar,
                                  has_root_term_completed,
                                  get_usable_rule_names, focus_rule, apply_rule,
                                  has_root_term_completed,
                                  root_term_undefined_grammar,
                                  get_term_todo_cursor_paths)
import Models.Message exposing (Message(..))
import Models.Model exposing (Model, Command, KeyBinding(..), Keymap, Command,
                              AutoComplete, Mode(..),
                              EditabilityRootTerm(..), MicroModeRootTerm(..),
                              RecordModeGrammar, MicroModeGrammar(..))
import Models.ModelUtils exposing (focus_record_mode_grammar,
                                   init_auto_complete)
import Updates.CommonCmd exposing (cmd_nothing)
import Updates.Message exposing (cmd_send_message)
import Updates.KeymapUtils exposing (empty_keymap,
                                     merge_keymaps, merge_keymaps_list,
                                     build_keymap, build_keymap_cond,
                                     keymap_auto_complete)
import Updates.Cursor exposing (cmd_click_block)

keymap_mode_grammar : RecordModeGrammar -> Model -> Keymap
keymap_mode_grammar record model =
  let grammar = Focus.get (focus_grammar record.node_path) model
      micro_mode_keymap = case record.micro_mode of
        MicroModeGrammarNavigate -> empty_keymap
        MicroModeGrammarSetMetaVarRegex auto_complete ->
          keymap_auto_complete [] True
            (Just (cmd_set_maybe_regex metavar_regex_ record
                  , "set regex for metavar")) focus_auto_complete model
        MicroModeGrammarSetLiteralRegex auto_complete ->
          keymap_auto_complete [] True
            (Just (cmd_set_maybe_regex literal_regex_ record
                  , "set regex for literal")) focus_auto_complete model
        _ -> empty_keymap -- TODO:
   in micro_mode_keymap

cmd_enter_mode_grammar : RecordModeGrammar -> Command
cmd_enter_mode_grammar record =
  let cursor_info = get_cursor_info_from_cursor_tree record
   in (Focus.set mode_ (ModeGrammar record)) >> (cmd_click_block cursor_info)

cmd_enter_micro_mode_navigate : RecordModeGrammar -> Command
cmd_enter_micro_mode_navigate record =
  let record' = record
        |> Focus.set sub_cursor_path_ []
        |> Focus.set micro_mode_ MicroModeGrammarNavigate
   in cmd_enter_mode_grammar record'

cmd_enter_micro_mode_metavar : RecordModeGrammar -> Command
cmd_enter_micro_mode_metavar record model =
  let old_grammar = Focus.get (focus_grammar record.node_path) model
      auto_complete = case old_grammar.metavar_regex of
        Nothing -> init_auto_complete
        Just regex -> Focus.set filters_ (regex_to_string regex)
                        init_auto_complete
      record' = record
        |> Focus.set micro_mode_
             (MicroModeGrammarSetMetaVarRegex auto_complete)
        |> Focus.set sub_cursor_path_ [0]
   in cmd_enter_mode_grammar record' model

cmd_disable_metavar : RecordModeGrammar -> Command
cmd_disable_metavar record model =
  let grammar_focus = focus_grammar record.node_path
      record' = record
        |> Focus.set micro_mode_ MicroModeGrammarNavigate
        |> Focus.set sub_cursor_path_ [0]
   in model
        |> cmd_enter_mode_grammar record'
        |> Focus.set (grammar_focus => metavar_regex_) Nothing

cmd_enter_micro_mode_literal : RecordModeGrammar -> Command
cmd_enter_micro_mode_literal record model =
  let old_grammar = Focus.get (focus_grammar record.node_path) model
      auto_complete = case old_grammar.literal_regex of
        Nothing -> init_auto_complete
        Just regex -> Focus.set filters_ (regex_to_string regex)
                        init_auto_complete
      record' = record
        |> Focus.set micro_mode_
             (MicroModeGrammarSetLiteralRegex auto_complete)
        |> Focus.set sub_cursor_path_ [1]
   in cmd_enter_mode_grammar record' model

cmd_disable_literal : RecordModeGrammar -> Command
cmd_disable_literal record model =
  let grammar_focus = focus_grammar record.node_path
      record' = record
        |> Focus.set micro_mode_ MicroModeGrammarNavigate
        |> Focus.set sub_cursor_path_ [1]
   in model
        |> cmd_enter_mode_grammar record'
        |> Focus.set (grammar_focus => literal_regex_) Nothing

cmd_set_maybe_regex : Focus Grammar (Maybe Regex) ->
                          RecordModeGrammar -> String -> Command
cmd_set_maybe_regex focus record regex_pattern =
  case safe_regex regex_pattern of
    Nothing -> (cmd_send_message <| MessageException
                  <| css_inline_str_embed "regex-block" regex_pattern
                  ++ "is not a valid regex pattern")
    Just regex -> Focus.set
                    (focus_grammar record.node_path => focus) (Just regex)
                   >> cmd_enter_micro_mode_navigate record

focus_auto_complete : Focus Model AutoComplete
focus_auto_complete =
  let err_msg = "from Updates.ModeGrammar.focus_auto_complete"
      getter record = case record.micro_mode of
        MicroModeGrammarNavigate                       -> Debug.crash err_msg
        MicroModeGrammarSetMetaVarRegex auto_complete  -> auto_complete
        MicroModeGrammarSetLiteralRegex auto_complete  -> auto_complete
        MicroModeGrammarNavigateChoice                 -> Debug.crash err_msg
        MicroModeGrammarSetChoiceFormat auto_complete  -> auto_complete
        MicroModeGrammarSetChoiceGrammar auto_complete -> auto_complete
      updater update_func record = case record.micro_mode of
        MicroModeGrammarNavigate                       -> record
        MicroModeGrammarSetMetaVarRegex auto_complete  ->
          Focus.set micro_mode_ (MicroModeGrammarSetMetaVarRegex <|
            update_func auto_complete) record

        MicroModeGrammarSetLiteralRegex auto_complete  ->
          Focus.set micro_mode_ (MicroModeGrammarSetLiteralRegex <|
            update_func auto_complete) record
        MicroModeGrammarNavigateChoice                 -> record
        MicroModeGrammarSetChoiceFormat auto_complete  ->
          Focus.set micro_mode_ (MicroModeGrammarSetChoiceFormat <|
            update_func auto_complete) record
        MicroModeGrammarSetChoiceGrammar auto_complete ->
          Focus.set micro_mode_ (MicroModeGrammarSetChoiceGrammar <|
            update_func auto_complete) record
   in (focus_record_mode_grammar => Focus.create getter updater)
