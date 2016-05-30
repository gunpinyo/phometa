module Updates.ModeRule where

import Dict
import Focus exposing (Focus, (=>))
import String

import Tools.Utils exposing (list_remove_duplication, list_remove, list_swap,
                             list_focus_elem)
import Tools.CssExtra exposing (css_inline_str_embed)
import Models.Focus exposing (mode_, micro_mode_, reversed_ref_path_,
                              node_name_, sub_cursor_path_,
                              allow_reduction_, allow_unification_,
                              parameters_, conclusion_,
                              premises_, pattern_, arguments_, has_locked_)
import Models.Cursor exposing (IntCursorPath, CursorInfo,
                               cursor_info_is_here,
                               get_cursor_info_from_cursor_tree,
                               cursor_info_go_to_sub_elem,
                               cursor_tree_go_to_sub_elem)
import Models.RepoModel exposing (NodePath, Term(..), RootTerm, VarType(..),
                                  RuleName, Rule,
                                  Premise(..), PremiseCascadeRecord)
import Models.RepoUtils exposing (has_root_term_completed,
                                  get_usable_rule_names, focus_rule, apply_rule,
                                  has_root_term_completed,
                                  get_root_term_variables,
                                  get_variable_type,
                                  init_root_term, init_root_term_alt,
                                  root_term_undefined_grammar,
                                  get_term_todo_cursor_paths, init_rule,
                                  get_rule_variables)
import Models.Message exposing (Message(..))
import Models.Model exposing (Model, Command, KeyBinding(..), Keymap, Command,
                              AutoComplete, Mode(..),
                              EditabilityRootTerm(..), MicroModeRootTerm(..),
                              RecordModeRule, MicroModeRule(..))
import Models.ModelUtils exposing (focus_record_mode_theorem,
                                   init_auto_complete, focus_record_mode_rule)
import Updates.Message exposing (cmd_send_message)
import Updates.KeymapUtils exposing (empty_keymap,
                                     merge_keymaps, merge_keymaps_list,
                                     build_keymap, build_keymap_cond,
                                     keymap_auto_complete)
import Updates.Cursor exposing (cmd_click_block)

keymap_mode_rule : RecordModeRule -> Model -> Keymap
keymap_mode_rule record model =
  let rule = Focus.get (focus_rule record.node_path) model
      module_path = record.node_path.module_path
   in case record.micro_mode of
        MicroModeRuleNavigate -> empty_keymap
        MicroModeRuleSelectCascadeRule auto_complete index ->
         let choices = get_usable_rule_names Nothing module_path model True
               |> List.map (\rule_name ->
                    (css_inline_str_embed "rule-block" rule_name,
                     cmd_add_cascade_rule rule_name index))
          in keymap_auto_complete choices True Nothing focus_auto_complete model

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

cmd_enter_micro_mode_cascade : RecordModeRule -> Int ->  Command
cmd_enter_micro_mode_cascade record index =
  let record' = record
        |> Focus.set micro_mode_
             (MicroModeRuleSelectCascadeRule init_auto_complete index)
        |> Focus.set sub_cursor_path_ [index + 1, 0]
   in cmd_enter_mode_rule record'


cmd_update_rule_params_and_cascades : RecordModeRule -> Command
cmd_update_rule_params_and_cascades record model =
  let module_path = record.node_path.module_path
      cur_rule_name = record.node_path.node_name
      cur_rule_focus = focus_rule record.node_path
      cur_rule = Focus.get cur_rule_focus model
      conclusion_vars = get_root_term_variables cur_rule.conclusion
      existing_vars = get_rule_variables record.node_path model
      unbounded_vars = Dict.diff existing_vars conclusion_vars
      filtered_old_parameters = List.filter (\param ->
        Dict.member param.var_name unbounded_vars) cur_rule.parameters
      parameters = unbounded_vars
        |> Dict.toList
        |> List.map (\ (var_name, grammar_name) -> { var_name = var_name
                                                   , grammar = grammar_name })
        |> (\new_params -> filtered_old_parameters ++ new_params)
        |> List.reverse            -- reverse list before and after
        |> list_remove_duplication -- to preserve the first occurrence
        |> List.reverse            -- instead of the last occurrence
        |> List.filter (\param -> Just VarTypeMetaVar ==
             get_variable_type module_path model param.var_name param.grammar)
      model' = Focus.set (cur_rule_focus => parameters_) parameters model
      rules_names = get_usable_rule_names Nothing module_path model True
      map_func cas_record =
        if cas_record.rule_name /= cur_rule_name then cas_record else
        let old_argument_dict = Dict.fromList <|
              List.map2 (\param arg -> (param.var_name, arg))
                cur_rule.parameters cas_record.arguments
            new_arguments = List.map (\param ->
              case Dict.get param.var_name old_argument_dict of
                Nothing -> init_root_term_alt module_path model param.grammar
                Just root_term -> root_term) parameters
         in cas_record
              |> (if cas_record.pattern.grammar == cur_rule.conclusion.grammar
                   then identity
                   else Focus.set pattern_ (init_root_term_alt module_path model
                                              cur_rule.conclusion.grammar))
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

cmd_toggle_allow_unification : Int -> Int ->  RecordModeRule -> Command
cmd_toggle_allow_unification premise_index cascase_index record =
  Focus.update (focus_rule record.node_path
                  => focus_premise_cascade_records premise_index
                  => list_focus_elem cascase_index
                  => allow_unification_) not
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
      module_path = record.node_path.module_path
      cur_rule_name = record.node_path.node_name
      -- work only on current module path
      -- but unlocked rules cannot be imported anyway, so it should be fine
      get_dependencies_func rule_name = model
        |> Focus.get (focus_rule { module_path = module_path
                                 , node_name = rule_name
                                 } => premises_)
        |> List.concatMap (\premise -> case premise of
             PremiseDirect _ -> []
             PremiseCascade cas_records -> List.map .rule_name cas_records)
        |> list_remove_duplication
      valid_rules = get_usable_rule_names Nothing module_path model False
      find_err_func premise acc = case (premise, acc) of
        (_, Just _) -> acc -- need just the first exception
        (PremiseDirect pattern, Nothing) -> if has_root_term_completed pattern
          then Nothing else Just ("some premise in ", " is not complete")
        (PremiseCascade cas_records, Nothing) ->
          if List.isEmpty cas_records then
            Just ("some cascade in ", " has no sub-rule")
          else List.foldl (\cas_record sub_acc -> case sub_acc of
            Just _ -> sub_acc
            Nothing -> if not <| has_root_term_completed cas_record.pattern then
                         Just ( "some pattern in some cascade in "
                              , " is not complete")
                       else List.foldl (\arg sub_sub_acc -> case sub_sub_acc of
                              Just _ -> sub_sub_acc
                              Nothing -> if has_root_term_completed arg
                                           then Nothing
                                           else Just ( "some argument in " ++
                                                       "some cascade in "
                                                     , " is not complete"))
                                       Nothing cas_record.arguments)
                          Nothing cas_records
      verify_one_step rule_name = Maybe.map
        (\ (fst_msg, snd_msg) ->
          fst_msg ++ css_inline_str_embed "rule-block" rule_name ++ snd_msg)
        (let rule = Focus.get (focus_rule { module_path = module_path
                                         , node_name = rule_name
                                         }) model

         in if not <| has_root_term_completed rule.conclusion then
              Just <| ("conclusion in ", " is not complete")
            else
              List.foldl find_err_func Nothing rule.premises)
      verify_func stack required_rules = case stack of
        [] -> Ok required_rules
        head_stack :: tail_stack ->
          let dependencies = get_dependencies_func head_stack
           in if List.member head_stack required_rules ||
                 List.member head_stack valid_rules then
                verify_func tail_stack required_rules
              else case verify_one_step head_stack of
                     Nothing -> verify_func (dependencies ++ tail_stack)
                                 (head_stack :: required_rules)
                     Just err_msg -> Err err_msg
   in case verify_func [cur_rule_name] [] of
        Ok required_rules ->
          let fold_func rule_name acc_model =
                Focus.set (focus_rule { module_path = module_path
                                      , node_name = rule_name
                                      } => has_locked_) True acc_model
              rules_css = List.map (\rule_name ->
                (css_inline_str_embed "rule-block" rule_name) ++ " ")
                required_rules
              suc_msg = (String.concat rules_css) ++
                (if List.length required_rules == 1 then "has" else "have") ++
                " been successfully locked "
           in List.foldl fold_func model required_rules
                |> cmd_send_message (MessageSuccess suc_msg)
                |> cmd_enter_micro_mode_navigate record
        Err err_msg ->
          let err_msg' = err_msg ++  ", hence, cannot lock " ++
                (css_inline_str_embed "rule-block" cur_rule_name)
           in cmd_send_message (MessageException err_msg) model
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

cmd_swap_cascade_rule : Int -> Int -> Command
cmd_swap_cascade_rule premise_index cascade_index model =
  let record = Focus.get focus_record_mode_rule model
   in model
        |> Focus.update (focus_rule record.node_path
                           => focus_premise_cascade_records premise_index)
             (list_swap cascade_index)
        |> cmd_enter_micro_mode_navigate record

cmd_delete_cascade_rule : Int -> Int -> Command
cmd_delete_cascade_rule premise_index cascade_index model =
  let record = Focus.get focus_record_mode_rule model
   in model
        |> Focus.update (focus_rule record.node_path
                           => focus_premise_cascade_records premise_index)
             (list_remove cascade_index)
        |> cmd_enter_micro_mode_navigate record

cmd_add_cascade_rule : RuleName -> Int -> Command
cmd_add_cascade_rule sub_rule_name index model =
  let record = Focus.get focus_record_mode_rule model
      module_path = record.node_path.module_path
      sub_rule_focus = focus_rule { module_path = module_path
                                  , node_name = sub_rule_name }
      sub_rule = Focus.get sub_rule_focus model
      focus = (focus_rule record.node_path
                 => focus_premise_cascade_records index)
      new_cas_record =
        { rule_name = sub_rule_name
        , pattern = init_root_term_alt module_path model
                      sub_rule.conclusion.grammar
        , arguments = List.map (\param -> init_root_term_alt module_path model
                                  param.grammar) sub_rule.parameters
        , allow_unification = True
        }
   in model
        |> Focus.update focus (\cas_records -> cas_records ++ [new_cas_record])
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

focus_auto_complete : Focus Model AutoComplete
focus_auto_complete =
  let err_msg = "from Updates.ModeRule.focus_auto_complete"
      getter record = case record.micro_mode of
        MicroModeRuleNavigate                          -> Debug.crash err_msg
        MicroModeRuleSelectCascadeRule auto_complete _ -> auto_complete
      updater update_func record = case record.micro_mode of
        MicroModeRuleNavigate                           -> record
        MicroModeRuleSelectCascadeRule auto_complete index ->
          Focus.set micro_mode_ (MicroModeRuleSelectCascadeRule
            (update_func auto_complete) index) record
   in (focus_record_mode_rule => Focus.create getter updater)
