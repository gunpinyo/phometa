module Updates.ModeRootTerm where

import Char
import Debug
import Dict
import String

import Focus exposing ((=>))

import Tools.Utils exposing (list_get_elem, sorted_list_get_index)
import Tools.CssExtra exposing (css_inline_str_embed)
import Tools.StripedList exposing (striped_list_get_odd_element,
                                   striped_list_eliminate)
import Models.Focus exposing (mode_, micro_mode_, grammar_, reversed_ref_path_,
                              sub_term_cursor_path_, root_term_focus_, term_)
import Models.RepoModel exposing (ModulePath,
                                  GrammarName, Grammar, GrammarChoice,
                                  RootTerm, Term(..))
import Models.RepoUtils exposing (init_root_term, root_term_undefined_grammar,
                                  get_grammar_names, get_grammar,
                                  focus_sub_term, get_all_todo_cursor_paths,
                                  init_term_ind)
import Models.Cursor exposing (IntCursorPath, CursorInfo)
import Models.Model exposing (Model, Command, KeyBinding(..), Keymap, Mode(..),
                              RecordModeRootTerm, MicroModeRootTerm(..),
                              EditabilityRootTerm(..))
import Models.ModelUtils exposing (focus_record_mode_root_term)
import Updates.KeymapUtils exposing (empty_keymap,
                                     merge_keymaps, merge_keymaps_list,
                                     build_keymap, build_keymap_cond,
                                     keymap_ring_choices)
import Updates.Cursor exposing (cmd_click_block)


cmd_enter_mode_root_term : RecordModeRootTerm -> Command
cmd_enter_mode_root_term record =
  let cursor_info = record.root_term_cursor_info
        |> Focus.update reversed_ref_path_
             (\path -> (List.reverse record.sub_term_cursor_path) ++ path)
   in (Focus.set mode_ (ModeRootTerm record)) >> (cmd_click_block cursor_info)

cmd_get_var_from_term_todo : String -> Command
cmd_get_var_from_term_todo input_string model =
  -- TODO: also use other way to verify input_string
  -- e.g. check against var_regex,
  --      check that there is no this name with different grammar
  if input_string == "" || String.all Char.isDigit input_string then
    cmd_set_micro_mode (MicroModeRootTermTodo 0) model
  else
    cmd_set_micro_mode (MicroModeRootTermTodoForVar input_string) model

keymap_mode_root_term : RecordModeRootTerm -> Model -> Keymap
keymap_mode_root_term record model =
  case record.micro_mode of
    MicroModeRootTermSetGrammar ring_choices_counter ->
      let choices = get_grammar_names record.module_path model |>
            List.map (\grammar_name ->
              (css_inline_str_embed "grammar-block" grammar_name,
                 grammar_name))
          choice_handler (_, grammar_name) =
            cmd_set_grammar grammar_name
          counter_handler counter =
            cmd_set_micro_mode (MicroModeRootTermSetGrammar counter)
       in keymap_ring_choices
            choices ring_choices_counter choice_handler counter_handler
    MicroModeRootTermTodo ring_choices_counter ->
      let grammar = get_grammar_at_sub_term model
          choices = grammar.choices |>
            List.map (\grammar_choice ->
              let description = String.concat <|
                    striped_list_eliminate
                      (css_inline_str_embed "ind-format-block")
                      (css_inline_str_embed "grammar-block")
                      grammar_choice
               in (description, grammar_choice))
          choice_handler (_, grammar_choice) =
            cmd_set_sub_term (init_term_ind grammar_choice)
              >> cmd_jump_to_next_todo 0
          counter_handler counter =
            cmd_set_micro_mode (MicroModeRootTermTodo counter)
       in merge_keymaps (keymap_after_set_grammar record model)
            (keymap_ring_choices
              choices ring_choices_counter choice_handler counter_handler)
    MicroModeRootTermTodoForVar input_string ->
      merge_keymaps
        (keymap_after_set_grammar record model)
        (build_keymap [
          ("Return", "make current term as variable",
             KbCmd cmd_from_todo_for_var_to_var)])
    MicroModeRootTermNavigate ->
      merge_keymaps
        (keymap_after_set_grammar record model)
        (build_keymap_cond (record.editability /= EditabilityRootTermReadOnly)
          [("Alt-t", "reset current term", KbCmd <| cmd_set_sub_term TermTodo)])


keymap_after_set_grammar : RecordModeRootTerm -> Model -> Keymap
keymap_after_set_grammar record model =
  merge_keymaps_list [
    build_keymap_cond (record.editability /= EditabilityRootTermReadOnly)
      [("Alt-r", "reset root term", KbCmd cmd_reset_root_term)],
    build_keymap_cond
      (not <| List.isEmpty
           <| get_all_todo_cursor_paths
           <| Focus.get (record.root_term_focus => term_) model)
      [("⭠", "jump to prev todo",
          KbCmd <| (cmd_jump_to_next_todo -1) << cmd_from_todo_for_var_to_var),
       ("⭢", "jump to next todo",
          KbCmd <| (cmd_jump_to_next_todo 1) << cmd_from_todo_for_var_to_var)],
    build_keymap_cond (not <| List.isEmpty record.sub_term_cursor_path)
      [("⭡", "jump to parent term",
          KbCmd <| cmd_jump_to_parent_term << cmd_from_todo_for_var_to_var)]]

cmd_set_grammar : GrammarName -> Command
cmd_set_grammar grammar_name model =
  let record = Focus.get focus_record_mode_root_term model
   in model
       |> Focus.set (record.root_term_focus => grammar_) grammar_name
       |> Focus.set (focus_record_mode_root_term => micro_mode_)
                    (MicroModeRootTermTodo 0)
       |> cmd_set_sub_term TermTodo -- for auto manipulation of TermTodo

cmd_set_sub_term : Term -> Command
cmd_set_sub_term term model =
  let record = Focus.get focus_record_mode_root_term model
   in model
        |> Focus.set (record.root_term_focus =>
             (focus_sub_term record.sub_term_cursor_path))
             (auto_manipulate_term
                (get_grammar_at_sub_term model) term record.module_path model)
        |> cmd_jump_to_next_todo 0

cmd_jump_to_parent_term : Command
cmd_jump_to_parent_term model =
  let record = Focus.get focus_record_mode_root_term model
                 |> Focus.update sub_term_cursor_path_
                      (\cursor_path ->
                         List.take ((List.length cursor_path) - 1) cursor_path)
                 |> Focus.set micro_mode_
                      MicroModeRootTermNavigate
   in cmd_enter_mode_root_term record model

cmd_jump_to_next_todo : Int -> Command
cmd_jump_to_next_todo displacement model =
  let record = Focus.get focus_record_mode_root_term model
      todo_cursor_paths = get_all_todo_cursor_paths <|
        Focus.get (record.root_term_focus => term_) model
      record' =
        if List.isEmpty todo_cursor_paths then
          record -- if no todos, go to root_term
            |> Focus.set sub_term_cursor_path_ []
            |> Focus.set micro_mode_ MicroModeRootTermNavigate
        else
          record
            |> Focus.update sub_term_cursor_path_ (\old_cursor_path ->
                 let old_index = sorted_list_get_index
                                   old_cursor_path todo_cursor_paths
                     pre_index = if displacement > 0 && not (List.member
                                  record.sub_term_cursor_path todo_cursor_paths)
                                   then old_index - 1 else old_index
                     index = (pre_index + displacement) %
                               List.length todo_cursor_paths
                  in list_get_elem index todo_cursor_paths)
            |> Focus.set micro_mode_ (MicroModeRootTermTodo 0)
   in cmd_enter_mode_root_term record' model

--  if micro_mode is not MicroModeRootTermTodoForVar, then do nothing
cmd_from_todo_for_var_to_var : Command
cmd_from_todo_for_var_to_var model =
  let record = Focus.get focus_record_mode_root_term model
   in case record.micro_mode of
        MicroModeRootTermTodoForVar input_string ->
          cmd_set_sub_term (TermVar input_string) model
          -- TODO: verify that this input_string are legitimate var_name
        _                                        -> model

cmd_set_micro_mode : MicroModeRootTerm -> Command
cmd_set_micro_mode micro_mode model =
  Focus.set (focus_record_mode_root_term => micro_mode_) micro_mode model

cmd_reset_root_term : Command
cmd_reset_root_term model =
  let record = Focus.get focus_record_mode_root_term model
   in case record.editability of
        EditabilityRootTermReadOnly -> model
        EditabilityRootTermUpToTerm ->
          let record' = record
                |> Focus.set sub_term_cursor_path_ []
                |> Focus.set micro_mode_ (MicroModeRootTermTodo 0)
           in model
                |> cmd_enter_mode_root_term record'
                |> cmd_set_sub_term TermTodo
        EditabilityRootTermUpToGrammar ->
          let model' = Focus.set record.root_term_focus init_root_term model
              record' = record
                |> Focus.set sub_term_cursor_path_ []
                |> Focus.set micro_mode_ (MicroModeRootTermSetGrammar 0)
           in cmd_enter_mode_root_term record' model'

get_grammar_at_sub_term : Model -> Grammar
get_grammar_at_sub_term model =
  let record = Focus.get focus_record_mode_root_term model
      root_term = Focus.get record.root_term_focus model
   in get_grammar_at_sub_term' record.module_path model
        root_term.grammar root_term.term record.sub_term_cursor_path

get_grammar_at_sub_term' : ModulePath -> Model -> GrammarName ->
                                 Term -> IntCursorPath -> Grammar
get_grammar_at_sub_term' module_path model grammar_name term cursor_path =
  let err_msg = "from Updates.ModeRootTerm.cmd_get_grammar_at_sub_term'"
   in case cursor_path of
        [] -> case get_grammar { module_path = module_path
                               , node_name = grammar_name
                               } model of
                Nothing      -> Debug.crash err_msg
                Just grammar -> grammar
        cursor_index :: cursor_path' ->
          case term of
            TermInd grammar_choice sub_terms ->
              get_grammar_at_sub_term' module_path model
                (list_get_elem cursor_index <|
                   striped_list_get_odd_element grammar_choice)
                (list_get_elem cursor_index sub_terms)
                cursor_path'
            _                                -> Debug.crash err_msg

-- if found something that can be done automatically for term, put it here
auto_manipulate_term : Grammar -> Term -> ModulePath -> Model -> Term
auto_manipulate_term grammar term module_path model =
  case term of
    TermTodo ->
      if grammar.var_regex == Nothing && List.length grammar.choices == 1
        then (init_term_ind <| list_get_elem 0 grammar.choices) else term
    TermVar _ -> term
    TermInd grammar_choice sub_terms ->
      List.map2 (,) (striped_list_get_odd_element grammar_choice) sub_terms
        |> List.map (\ (sub_grammar_name, sub_term) ->
             case get_grammar { module_path = module_path
                              , node_name = sub_grammar_name
                              } model of
               Nothing          -> sub_term
               Just sub_grammar ->
                 auto_manipulate_term sub_grammar sub_term module_path model)
        |> TermInd grammar_choice
