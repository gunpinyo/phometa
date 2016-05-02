module Updates.ModeRule where

import Dict
import Focus exposing (Focus, (=>))

import Tools.Utils exposing (list_remove_duplication, list_remove, list_swap,
                             list_focus_elem)
import Models.Focus exposing (mode_, micro_mode_, reversed_ref_path_,
                              node_name_, sub_cursor_path_, allow_reduction_,
                              parameters_, conclusion_,
                              premises_, pattern_, arguments_)
import Models.Cursor exposing (IntCursorPath, CursorInfo,
                               cursor_info_is_here,
                               get_cursor_info_from_cursor_tree,
                               cursor_info_go_to_sub_elem,
                               cursor_tree_go_to_sub_elem)
import Models.RepoModel exposing (NodePath, Term(..), RootTerm, RuleName, Rule,
                                  Premise(..), PremiseCascadeRecord)
import Models.RepoUtils exposing (has_root_term_completed,
                                  get_usable_rule_names, focus_rule, apply_rule,
                                  has_root_term_completed,
                                  get_root_term_variables,
                                  init_root_term, root_term_undefined_grammar,
                                  get_term_todo_cursor_paths, init_rule,
                                  get_rule_variables)
import Models.Message exposing (Message(..))
import Models.Model exposing (Model, Command, KeyBinding(..), Keymap, Command,
                              AutoComplete, Mode(..),
                              EditabilityRootTerm(..), MicroModeRootTerm(..),
                              RecordModeRule, MicroModeRule(..))
import Models.ModelUtils exposing (focus_record_mode_theorem,
                                   init_auto_complete, focus_record_mode_rule)
import Updates.CommonCmd exposing (cmd_nothing)
import Updates.Message exposing (cmd_send_message)
import Updates.KeymapUtils exposing (empty_keymap,
                                     merge_keymaps, merge_keymaps_list,
                                     build_keymap, build_keymap_cond,
                                     keymap_auto_complete)
import Updates.Cursor exposing (cmd_click_block)
import Updates.ModeRootTerm exposing (embed_css_root_term,
                                      cmd_enter_mode_root_term)

cmd_enter_mode_rule : RecordModeRule -> Command
cmd_enter_mode_rule record =
  let cursor_info = get_cursor_info_from_cursor_tree record
   in (Focus.set mode_ (ModeRule record)) >> (cmd_click_block cursor_info)

cmd_enter_micro_mode_navigate : RecordModeRule -> Command
cmd_enter_micro_mode_navigate record =
  let record' = record
        |> Focus.set micro_mode_ MicroModeRuleNavigate
        |> Focus.set sub_cursor_path_ []
   in cmd_enter_mode_rule record'
        >> cmd_enter_mode_rule record'

cmd_update_rule_params_and_cascades : RecordModeRule -> Command
cmd_update_rule_params_and_cascades record model =
  let module_path = record.node_path.module_path
      cur_rule_name = record.node_path.node_name
      cur_rule_focus = focus_rule record.node_path
      cur_rule = Focus.get cur_rule_focus model
      conclusion_vars = get_root_term_variables cur_rule.conclusion
      existing_vars = get_rule_variables record.node_path model
      unbounded_vars = Dict.diff existing_vars conclusion_vars
      parameters = unbounded_vars
        |> Dict.toList
        |> List.map (\ (var_name, grammar_name) -> { var_name = var_name
                                                   , grammar = grammar_name })
        |> (\new_params -> cur_rule.parameters ++ new_params)
        |> List.reverse            -- reverse list before and after
        |> list_remove_duplication -- to preserve the first occurrence
        |> List.reverse            -- instead of the last occurrence
   in if cur_rule.parameters == parameters then model else
  let model' = Focus.set (cur_rule_focus => parameters_) parameters model
      rules_names = get_usable_rule_names Nothing module_path model True
      map_func cas_record =
        if cas_record.rule_name /= cur_rule_name then cas_record else
        let old_argument_dict = Dict.fromList <|
              List.map2 (\param arg -> (param.var_name, arg))
                cur_rule.parameters cas_record.arguments
            new_arguments = List.map (\param ->
              case Dict.get param.var_name old_argument_dict of
                Nothing -> { grammar = param.grammar
                           , term = TermTodo }
                Just root_term -> root_term) parameters
         in cas_record
              |> (if cas_record.pattern.grammar == cur_rule.conclusion.grammar
                   then identity else
                     Focus.set pattern_ { grammar = cur_rule.conclusion.grammar
                                         , term = TermTodo })
              |> Focus.set arguments_ new_arguments
      fold_func rule_name acc_model =
        let rule_focus = focus_rule { module_path = module_path
                                    , node_name = rule_name
                                    }
            rule = Focus.get rule_focus acc_model
         in if rule.has_locked then acc_model else
        let premises = List.map (\premise -> case premise of
              PremiseDirect pattern -> PremiseDirect pattern
              PremiseCascade cascase_records -> PremiseCascade <|
                List.map map_func cascase_records) rule.premises
         in Focus.set (rule_focus => premises_) premises acc_model
   in List.foldl fold_func model' rules_names

cmd_toggle_allow_reduction : RecordModeRule -> Command
cmd_toggle_allow_reduction record =
  Focus.update (focus_rule record.node_path => allow_reduction_) not
    >> cmd_enter_micro_mode_navigate record

cmd_add_premise_direct : RecordModeRule -> Command
cmd_add_premise_direct record =
  Focus.update (focus_rule record.node_path => premises_)
      (\premises -> premises ++ [PremiseDirect init_root_term])
    >> cmd_enter_micro_mode_navigate record -- TODO: jump to new premise

cmd_add_premise_cascade : RecordModeRule -> Command
cmd_add_premise_cascade record =
  Focus.update (focus_rule record.node_path => premises_)
      (\premises -> premises ++ [PremiseCascade []])
    >> cmd_enter_micro_mode_navigate record -- TODO: jump to new premise

cmd_reset_rule : Command
cmd_reset_rule model =
  let record = Focus.get focus_record_mode_rule model
   in model
        |> Focus.set (focus_rule record.node_path) init_rule
        |> cmd_enter_micro_mode_navigate record

cmd_lock_rule : Command
cmd_lock_rule model =
  let record = Focus.get focus_record_mode_rule model
   in model -- TODO:
        |> cmd_enter_micro_mode_navigate record

cmd_swap_premise : Int -> Command
cmd_swap_premise index model =
  let record = Focus.get focus_record_mode_rule model
   in model
        |> Focus.update (focus_rule record.node_path => premises_)
             (list_swap index)
        |> cmd_enter_micro_mode_navigate record

cmd_delete_premise : Int -> Command
cmd_delete_premise index model =
  let record = Focus.get focus_record_mode_rule model
   in model
        |> Focus.update (focus_rule record.node_path => premises_)
             (list_remove index)
        |> cmd_enter_micro_mode_navigate record

focus_premise_direct_pattern : Int -> Focus Rule RootTerm
focus_premise_direct_pattern index =
  let err_msg = "from Updates.ModeRule.focus_premise_direct_pattern"
      getter premise = case premise of
        PremiseDirect pattern  -> pattern
        PremiseCascade records -> Debug.crash err_msg
      updater update_func premise = case premise of
        PremiseDirect pattern  -> PremiseDirect (update_func pattern)
        PremiseCascade records -> PremiseCascade records
   in (premises_ => list_focus_elem index
                 => Focus.create getter updater)

focus_premise_cascade_records : Int -> Focus Rule (List PremiseCascadeRecord)
focus_premise_cascade_records index =
  let err_msg = "from Updates.ModeRule.focus_premise_cascade_records"
      getter premise = case premise of
        PremiseDirect pattern  -> Debug.crash err_msg
        PremiseCascade records -> records
      updater update_func premise = case premise of
        PremiseDirect pattern  -> PremiseDirect pattern
        PremiseCascade records -> PremiseCascade (update_func records)
   in (premises_ => list_focus_elem index
                 => Focus.create getter updater)
