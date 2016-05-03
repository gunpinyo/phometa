module Updates.ModeGrammar where

import Regex exposing (Regex)
import String

import Focus exposing (Focus, (=>))

import Tools.Utils exposing (list_safe_get_elem, list_focus_elem, list_swap,
                             list_remove, list_remove_duplication)
import Tools.RegexExtra exposing (safe_regex, regex_to_string)
import Tools.CssExtra exposing (css_inline_str_embed)
import Tools.StripedList exposing (striped_list_get_even_element,
                                   striped_list_get_odd_element,
                                   striped_list_introduce)
import Models.Focus exposing (mode_, micro_mode_, sub_cursor_path_, choices_,
                              metavar_regex_, literal_regex_, filters_,
                              has_locked_)
import Models.Cursor exposing (IntCursorPath, CursorInfo,
                               get_cursor_info_from_cursor_tree,
                               cursor_info_go_to_sub_elem)
import Models.RepoModel exposing (Grammar)
import Models.RepoUtils exposing (focus_grammar, init_grammar,
                                  init_grammar_choice,
                                  get_usable_grammar_names,
                                  root_term_undefined_grammar)
import Models.Message exposing (Message(..))
import Models.Model exposing (Model, Command, KeyBinding(..), Keymap, Command,
                              AutoComplete, Mode(..),
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
   in case record.micro_mode of
        MicroModeGrammarNavigate -> empty_keymap
        MicroModeGrammarSetMetaVarRegex auto_complete ->
          keymap_auto_complete [] True
            (Just (cmd_set_maybe_regex metavar_regex_ record
                  , "set regex for metavar")) focus_auto_complete model
        MicroModeGrammarSetLiteralRegex auto_complete ->
          keymap_auto_complete [] True
            (Just (cmd_set_maybe_regex literal_regex_ record
                  , "set regex for literal")) focus_auto_complete model
        MicroModeGrammarAddChoice auto_complete ->
          keymap_auto_complete [] True
            (Just (cmd_add_choice record, "add grammar choice"))
            focus_auto_complete model
        MicroModeGrammarSetChoiceFormat auto_complete choice_index sub_index ->
          keymap_auto_complete [] True
            (Just (cmd_set_choice_format choice_index sub_index record
                  , "add format"))
            focus_auto_complete model
        MicroModeGrammarSetChoiceGrammar auto_complete choice_index sub_index ->
          let choices = List.map (\grammar_name ->
                ( css_inline_str_embed "grammar-block" grammar_name
                , cmd_set_choice_grammar choice_index
                    sub_index record grammar_name))
                (get_usable_grammar_names
                   record.node_path.module_path model True)
           in keymap_auto_complete choices True Nothing
                focus_auto_complete model

cmd_enter_mode_grammar : RecordModeGrammar -> Command
cmd_enter_mode_grammar record =
  let cursor_info = get_cursor_info_from_cursor_tree record
   in (Focus.set mode_ (ModeGrammar record)) >> (cmd_click_block cursor_info)

cmd_enter_micro_mode_navigate : RecordModeGrammar -> Command
cmd_enter_micro_mode_navigate record =
  let record' = record
        |> Focus.set micro_mode_ MicroModeGrammarNavigate
        |> Focus.set sub_cursor_path_ []
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
cmd_disable_metavar record =
  Focus.set (focus_grammar record.node_path => metavar_regex_) Nothing
    >> cmd_enter_micro_mode_navigate record

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
cmd_disable_literal record =
  Focus.set (focus_grammar record.node_path => literal_regex_) Nothing
    >> cmd_enter_micro_mode_navigate record

cmd_set_maybe_regex : Focus Grammar (Maybe Regex) ->
                          RecordModeGrammar -> String -> Command
cmd_set_maybe_regex focus record regex_pattern =
  case safe_regex regex_pattern of
    Nothing -> (cmd_send_message <| MessageException
                  <| css_inline_str_embed "regex-block" regex_pattern
                  ++ " is not a valid regex pattern")
                 >> cmd_enter_micro_mode_navigate record
    Just regex -> Focus.set
                    (focus_grammar record.node_path => focus) (Just regex)
                   >> cmd_enter_micro_mode_navigate record

cmd_enter_micro_mode_add_choice : RecordModeGrammar -> Command
cmd_enter_micro_mode_add_choice record model =
  let record' = record
        |> Focus.set micro_mode_ (MicroModeGrammarAddChoice init_auto_complete)
        |> Focus.set sub_cursor_path_ [2]
   in cmd_enter_mode_grammar record' model

cmd_add_choice : RecordModeGrammar -> String -> Command
cmd_add_choice record raw_int =
  case String.toInt raw_int of
    Ok int -> if int < 0 then (cmd_send_message <| MessageException
                                 "number of sub-terms cannot be negative")
              else
                Focus.update (focus_grammar record.node_path => choices_)
                    (\choices -> choices ++ [init_grammar_choice int])
                  >> cmd_enter_micro_mode_navigate record -- TODO
    Err msg_str -> cmd_send_message <| MessageException msg_str

cmd_enter_micro_mode_format : Int -> Int -> RecordModeGrammar -> Command
cmd_enter_micro_mode_format choice_index sub_index record model =
  let old_grammar = Focus.get (focus_grammar record.node_path) model
      maybe_format = case list_safe_get_elem choice_index old_grammar.choices of
        Nothing -> Nothing
        Just grammar_choice -> list_safe_get_elem sub_index
                                 (striped_list_get_even_element grammar_choice)
      auto_complete = case maybe_format of
        Nothing -> init_auto_complete
        Just format -> Focus.set filters_ format init_auto_complete
      record' = record
        |> Focus.set micro_mode_ (MicroModeGrammarSetChoiceFormat
                                    auto_complete choice_index sub_index)
        |> Focus.set sub_cursor_path_ [3, choice_index, 2 * sub_index]
   in cmd_enter_mode_grammar record' model

cmd_set_choice_format : Int -> Int -> RecordModeGrammar -> String -> Command
cmd_set_choice_format choice_index sub_index record string model =
  let update_func grammar_choice =
        let fmt = striped_list_get_even_element grammar_choice
            gmr = striped_list_get_odd_element grammar_choice
            fmt' = Focus.set (list_focus_elem sub_index) string fmt
         in striped_list_introduce fmt' gmr
      focus = focus_grammar record.node_path
                => choices_
                => list_focus_elem choice_index
   in model
       |> Focus.update focus update_func
       |> cmd_enter_micro_mode_navigate record

cmd_set_choice_grammar : Int -> Int -> RecordModeGrammar -> String -> Command
cmd_set_choice_grammar choice_index sub_index record string model =
  let update_func grammar_choice =
        let fmt = striped_list_get_even_element grammar_choice
            gmr = striped_list_get_odd_element grammar_choice
            gmr' = Focus.set (list_focus_elem sub_index) string gmr
         in striped_list_introduce fmt gmr'
      focus = focus_grammar record.node_path
                => choices_
                => list_focus_elem choice_index
   in model
       |> Focus.update focus update_func
       |> cmd_enter_micro_mode_navigate record

cmd_enter_micro_mode_grammar : Int -> Int -> RecordModeGrammar -> Command
cmd_enter_micro_mode_grammar choice_index sub_index record model =
  let old_grammar = Focus.get (focus_grammar record.node_path) model
      maybe_grammar_name = case list_safe_get_elem choice_index
                                  old_grammar.choices of
        Nothing -> Nothing
        Just grammar_choice -> list_safe_get_elem sub_index
                                 (striped_list_get_odd_element grammar_choice)
      auto_complete = case maybe_grammar_name of
        Nothing -> init_auto_complete
        Just grammar_name -> Focus.set filters_ grammar_name init_auto_complete
      record' = record
        |> Focus.set micro_mode_ (MicroModeGrammarSetChoiceGrammar
                                    auto_complete choice_index sub_index)
        |> Focus.set sub_cursor_path_ [3, choice_index, 2 * sub_index + 1]
   in cmd_enter_mode_grammar record' model

cmd_reset_grammar : Command
cmd_reset_grammar model =
  let record = Focus.get focus_record_mode_grammar model
   in model
        |> Focus.set (focus_grammar record.node_path) init_grammar
        |> cmd_enter_micro_mode_navigate record

cmd_lock_grammar : Command
cmd_lock_grammar model =
  let record = Focus.get focus_record_mode_grammar model
      module_path = record.node_path.module_path
      cur_grammar_name = record.node_path.node_name
      -- work only on current module path
      -- but unlocked grammars cannot be imported anyway, so it should be fine
      get_dependencies_func grammar_name = model
        |> Focus.get (focus_grammar { module_path = module_path
                                    , node_name = grammar_name
                                    } => choices_)
        |> List.concatMap striped_list_get_odd_element
        |> list_remove_duplication
      valid_grammars = get_usable_grammar_names module_path model False
      verify_func stack required_grammars = case stack of
        [] -> Ok required_grammars
        head_stack :: tail_stack ->
          let dependencies = get_dependencies_func head_stack
           in if List.member head_stack required_grammars ||
                 List.member head_stack valid_grammars then
                verify_func tail_stack required_grammars
              else if List.any ((==) root_term_undefined_grammar)
                     dependencies then
                Err head_stack
              else
                verify_func (dependencies ++ tail_stack)
                   (head_stack :: required_grammars)
   in case verify_func [cur_grammar_name] [] of
        Ok required_grammars ->
          let fold_func grammar_name acc_model =
                Focus.set (focus_grammar { module_path = module_path
                                         , node_name = grammar_name
                                         } => has_locked_) True acc_model
              grammars_css = List.map (\grammar_name ->
                (css_inline_str_embed "grammar-block" grammar_name) ++ " ")
                required_grammars
              suc_msg = (String.concat grammars_css) ++
                (if List.length required_grammars == 1 then "has" else "have")++
                " been successfully locked "
           in List.foldl fold_func model required_grammars
                |> cmd_send_message (MessageSuccess suc_msg)
                |> cmd_enter_micro_mode_navigate record
        Err invalid_grammar ->
          let err_msg = "some sub-grammars of " ++
                (css_inline_str_embed "grammar-block" invalid_grammar) ++
                " hasn't been initialised, hence, cannot lock " ++
                (css_inline_str_embed "grammar-block" cur_grammar_name)
           in cmd_send_message (MessageException err_msg) model
                |> cmd_enter_micro_mode_navigate record

cmd_swap_choice : Int -> Command
cmd_swap_choice choice_index model =
  let record = Focus.get focus_record_mode_grammar model
   in model
        |> Focus.update (focus_grammar record.node_path => choices_)
             (list_swap choice_index)
        |> cmd_enter_micro_mode_navigate record

cmd_delete_choice : Int -> Command
cmd_delete_choice choice_index model =
  let record = Focus.get focus_record_mode_grammar model
   in model
        |> Focus.update (focus_grammar record.node_path => choices_)
             (list_remove choice_index)
        |> cmd_enter_micro_mode_navigate record

focus_auto_complete : Focus Model AutoComplete
focus_auto_complete =
  let err_msg = "from Updates.ModeGrammar.focus_auto_complete"
      getter record = case record.micro_mode of
        MicroModeGrammarNavigate                          -> Debug.crash err_msg
        MicroModeGrammarSetMetaVarRegex auto_complete     -> auto_complete
        MicroModeGrammarSetLiteralRegex auto_complete     -> auto_complete
        MicroModeGrammarAddChoice auto_complete           -> auto_complete
        MicroModeGrammarSetChoiceFormat auto_complete _ _ -> auto_complete
        MicroModeGrammarSetChoiceGrammar auto_complete _ _ -> auto_complete
      updater update_func record = case record.micro_mode of
        MicroModeGrammarNavigate                       -> record
        MicroModeGrammarSetMetaVarRegex auto_complete  ->
          Focus.set micro_mode_ (MicroModeGrammarSetMetaVarRegex <|
            update_func auto_complete) record
        MicroModeGrammarSetLiteralRegex auto_complete  ->
          Focus.set micro_mode_ (MicroModeGrammarSetLiteralRegex <|
            update_func auto_complete) record
        MicroModeGrammarAddChoice auto_complete        ->
          Focus.set micro_mode_ (MicroModeGrammarAddChoice <|
            update_func auto_complete) record
        MicroModeGrammarSetChoiceFormat auto_complete choice_index sub_index ->
          Focus.set micro_mode_ (MicroModeGrammarSetChoiceFormat
            (update_func auto_complete) choice_index sub_index) record
        MicroModeGrammarSetChoiceGrammar auto_complete choice_index sub_index ->
          Focus.set micro_mode_ (MicroModeGrammarSetChoiceGrammar
            (update_func auto_complete) choice_index sub_index) record
   in (focus_record_mode_grammar => Focus.create getter updater)
