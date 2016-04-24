module Updates.ModeTheorem where

import String

import Focus exposing (Focus, (=>))

import Tools.Utils exposing (list_get_elem, list_update_elem)
import Tools.CssExtra exposing (css_inline_str_embed)
import Models.Focus exposing (mode_, micro_mode_, reversed_ref_path_,
                              node_name_, goal_, proof_, has_locked_,
                              sub_cursor_path_)
import Models.Cursor exposing (IntCursorPath,
                               get_cursor_info_from_cursor_tree,
                               cursor_tree_go_to_sub_elem)
import Models.RepoModel exposing (Term(..), RuleName, TheoremName, Theorem,
                                  Proof(..), SubstitutionList)
import Models.RepoUtils exposing (has_root_term_completed,
                                  get_usable_rule_names, focus_rule, apply_rule,
                                  init_theorem, get_usable_theorem_names,
                                  focus_theorem, has_theorem_completed,
                                  multiple_root_substitute,
                                  pattern_matchable, pattern_match)
import Models.Message exposing (Message(..))
import Models.Model exposing (Model, Command, KeyBinding(..), Keymap, Command,
                              AutoComplete,
                              Mode(..), RecordModeTheorem, MicroModeTheorem(..))
import Models.ModelUtils exposing (focus_record_mode_theorem,
                                   init_auto_complete)
import Updates.CommonCmd exposing (cmd_nothing)
import Updates.Message exposing (cmd_send_message)
import Updates.KeymapUtils exposing (empty_keymap,
                                     merge_keymaps, merge_keymaps_list,
                                     build_keymap, build_keymap_cond,
                                     keymap_auto_complete)
import Updates.Cursor exposing (cmd_click_block)
import Updates.ModeRootTerm exposing (embed_css_root_term)

cmd_enter_mode_theorem : RecordModeTheorem -> Command
cmd_enter_mode_theorem record =
  let cursor_info = get_cursor_info_from_cursor_tree record
   in (Focus.set mode_ (ModeTheorem record)) >> (cmd_click_block cursor_info)

cmd_resume_to_navigate_micro_mode : Command
cmd_resume_to_navigate_micro_mode model =
  model
    |> cmd_enter_mode_theorem (Focus.get focus_record_mode_theorem model)
    |> cmd_set_micro_mode (MicroModeTheoremNavigate)

cmd_select_rule : Int -> RecordModeTheorem -> Command
cmd_select_rule index record model =
  model
    |> cmd_click_block (get_cursor_info_from_cursor_tree
                          <| cursor_tree_go_to_sub_elem index record)
    |> Focus.set mode_ (ModeTheorem record)
    |> cmd_set_micro_mode (MicroModeTheoremSelectRule init_auto_complete)

cmd_select_lemma : Int -> RecordModeTheorem -> Command
cmd_select_lemma index record model =
  model
    |> cmd_click_block (get_cursor_info_from_cursor_tree
                          <| cursor_tree_go_to_sub_elem index record)
    |> Focus.set mode_ (ModeTheorem record)
    |> cmd_set_micro_mode (MicroModeTheoremSelectTheorem init_auto_complete)

keymap_mode_theorem : RecordModeTheorem -> Model -> Keymap
keymap_mode_theorem record model =
  merge_keymaps
    (build_keymap
      [(model.config.spacial_key_prefix ++ "r",
        "reset whole theorem", KbCmd cmd_reset_top_theorem)
      ,(model.config.spacial_key_prefix ++ "t",
        "reset current proof", KbCmd cmd_reset_current_proof)])
    (case record.micro_mode of
      MicroModeTheoremNavigate -> empty_keymap
      MicroModeTheoremSelectRule auto_complete ->
        let cur_sub_theorem = Focus.get (focus_current_sub_theorem model) model
            choices = get_usable_rule_names cur_sub_theorem.goal.grammar
                        record.node_path.module_path model
              |> List.map (\rule_name ->
                   (css_inline_str_embed "rule-block" rule_name,
                    cmd_set_rule rule_name))
         in keymap_auto_complete choices Nothing focus_auto_complete model
      MicroModeTheoremSelectTheorem auto_complete ->
        let cur_sub_theorem = Focus.get (focus_current_sub_theorem model) model
            choices = get_usable_theorem_names cur_sub_theorem.goal
                        record.node_path.node_name
                        record.node_path.module_path model
              |> List.map (\theorem_name ->
                   (css_inline_str_embed "theorem-block" theorem_name,
                    cmd_set_theorem theorem_name))
         in keymap_auto_complete choices Nothing focus_auto_complete model)

cmd_set_rule : RuleName -> Command
cmd_set_rule rule_name model =
  let err_msg = "from Updates.ModeTheorem.cmd_set_rule"
      record = Focus.get focus_record_mode_theorem model
      module_path = record.node_path.module_path
      rule = Focus.get (focus_rule { module_path = module_path
                                   , node_name = rule_name
                                   }) model
      new_proof = ProofTodoWithRule rule_name <|
                    List.map (\parameter -> { grammar = parameter.grammar
                                            , term = TermTodo
                                            }) rule.parameters
      top_theorem_focus = focus_theorem record.node_path
      top_sub_focus = focus_sub_theorem record.sub_cursor_path
   in model
       |> Focus.set (top_theorem_focus => top_sub_focus => proof_) new_proof
       |> if List.isEmpty rule.parameters then
            cmd_execute_current_rule
          else
            cmd_resume_to_navigate_micro_mode

cmd_execute_current_rule : Command
cmd_execute_current_rule model =
  let err_msg = "from Updates.ModeTheorem.cmd_execute_current_rule"
      record = Focus.get focus_record_mode_theorem model
      module_path = record.node_path.module_path
      top_theorem_focus = focus_theorem record.node_path
      top_sub_focus = focus_sub_theorem record.sub_cursor_path
      top_theorem = Focus.get top_theorem_focus model
      sub_theorem = Focus.get top_sub_focus top_theorem
      on_success rule_name arguments premises pm_info =
        let sub_sub_theorems = List.map
              (\premise -> Focus.set goal_ premise init_theorem) premises
            new_proof = ProofByRule rule_name arguments pm_info sub_sub_theorems
            new_sub_theorem = Focus.set proof_ new_proof sub_theorem
            new_top_theorem = theorem_tree_substitute pm_info.substitution_list
              (Focus.set top_sub_focus new_sub_theorem top_theorem)
         in Focus.set top_theorem_focus new_top_theorem
      on_failure rule_name arguments =
        let parameters_inline = if List.isEmpty arguments then " " else
              " with parameter" ++ (if List.length arguments == 1
                                      then " " else "s ") ++
              (String.concat <| List.map (\argument ->
                embed_css_root_term module_path model argument ++ " ")arguments)
            exception_msg = "cannot apply "
              ++ css_inline_str_embed "rule-block" rule_name ++parameters_inline
              ++ "on " ++ embed_css_root_term module_path model sub_theorem.goal
            proof_focus = (top_theorem_focus => top_sub_focus => proof_)
         in (Focus.set proof_focus ProofTodo) >>
            (cmd_send_message <| MessageException exception_msg)
      main_command =
        case sub_theorem.proof of
          ProofTodoWithRule rule_name arguments ->
            if not <| List.all has_root_term_completed arguments then
              cmd_nothing
            else
              case apply_rule rule_name sub_theorem.goal
                     arguments record.node_path.module_path model of
                Nothing -> on_failure rule_name arguments
                Just (premises, pm_info) ->
                  on_success rule_name arguments premises pm_info
          _ -> cmd_nothing
   in model
        |> main_command
        |> cmd_resume_to_navigate_micro_mode

cmd_set_theorem : TheoremName -> Command
cmd_set_theorem theorem_name model =
  let err_msg = "from Updates.ModeTheorem.cmd_set_theorem"
      record = Focus.get focus_record_mode_theorem model
      pattern_theorem_path = Focus.set node_name_ theorem_name record.node_path
      pattern_theorem = Focus.get (focus_theorem pattern_theorem_path) model
      top_theorem_focus = focus_theorem record.node_path
      target_theorem = Focus.get top_theorem_focus model
      sub_theorem_update_func current_sub_theorem =
        case pattern_match record.node_path.module_path model
               pattern_theorem.goal current_sub_theorem.goal of
          Nothing -> current_sub_theorem
          Just pattern_match_info ->
            Focus.set proof_
              (ProofByLemma theorem_name pattern_match_info)
              current_sub_theorem
      top_theorem_update_func top_theorem =
        let top_sub_focus = focus_sub_theorem record.sub_cursor_path
            top_theorem' = Focus.update top_sub_focus
                             sub_theorem_update_func top_theorem
            sub_theorem = Focus.get top_sub_focus top_theorem
            sub_theorem' = Focus.get top_sub_focus top_theorem'
            subst_list = if sub_theorem == sub_theorem' then [] else
                           case sub_theorem'.proof of
                             ProofByLemma _ pattern_match_info ->
                               pattern_match_info.substitution_list
                             _ -> Debug.crash err_msg
         in theorem_tree_substitute subst_list top_theorem'
   in model
       |> Focus.update top_theorem_focus top_theorem_update_func
       |> cmd_resume_to_navigate_micro_mode

cmd_set_micro_mode : MicroModeTheorem -> Command
cmd_set_micro_mode micro_mode model =
  Focus.set (focus_record_mode_theorem => micro_mode_) micro_mode model

cmd_reset_current_proof : Command
cmd_reset_current_proof model =
  let record = Focus.get focus_record_mode_theorem model
      top_theorem_focus = focus_theorem record.node_path
      top_sub_focus = focus_sub_theorem record.sub_cursor_path
      proof_focus = top_theorem_focus => top_sub_focus => proof_
   in model
        |> Focus.set proof_focus ProofTodo
        |> Focus.set (focus_record_mode_theorem => has_locked_) False
        |> cmd_resume_to_navigate_micro_mode

cmd_reset_top_theorem : Command
cmd_reset_top_theorem model =
  let record = Focus.get focus_record_mode_theorem model
   in model
        |> Focus.set (focus_theorem record.node_path) init_theorem
        |> Focus.set (focus_record_mode_theorem => sub_cursor_path_) []
        |> Focus.set (focus_record_mode_theorem => has_locked_) False
        |> cmd_resume_to_navigate_micro_mode

theorem_tree_substitute : SubstitutionList -> Theorem -> Theorem
theorem_tree_substitute subst_list theorem = theorem
  |> Focus.set goal_ (multiple_root_substitute subst_list theorem.goal)
  |> Focus.set proof_ (case theorem.proof of
       ProofTodo -> ProofTodo
       ProofTodoWithRule rule_name arguments ->
         ProofTodoWithRule rule_name <|
           List.map (multiple_root_substitute subst_list) arguments
       ProofByRule rule_name arguments pattern_match_info sub_theorems ->
         let arguments' =
               List.map (multiple_root_substitute subst_list) arguments
             sub_theorems' =
               List.map (theorem_tree_substitute subst_list) sub_theorems
          in ProofByRule rule_name arguments' pattern_match_info sub_theorems'
       ProofByLemma theorem_name pattern_match_info ->
         ProofByLemma theorem_name pattern_match_info)

focus_auto_complete : Focus Model AutoComplete
focus_auto_complete =
  let err_msg = "from Updates.ModeTheorem.focus_auto_complete"
      getter record =
        case record.micro_mode of
          MicroModeTheoremNavigate -> Debug.crash err_msg
          MicroModeTheoremSelectRule auto_complete -> auto_complete
          MicroModeTheoremSelectTheorem auto_complete -> auto_complete
      updater update_func record =
        case record.micro_mode of
          MicroModeTheoremNavigate -> record
          MicroModeTheoremSelectRule auto_complete ->
            Focus.set micro_mode_
              (MicroModeTheoremSelectRule <| update_func auto_complete)
              record
          MicroModeTheoremSelectTheorem auto_complete ->
            Focus.set micro_mode_
              (MicroModeTheoremSelectTheorem <| update_func auto_complete)
              record
   in (focus_record_mode_theorem => Focus.create getter updater)

focus_current_sub_theorem : Model -> Focus Model Theorem
focus_current_sub_theorem model =
  let record = Focus.get focus_record_mode_theorem model
   in (focus_theorem record.node_path) =>
        (focus_sub_theorem record.sub_cursor_path)

-- please note that cursor_path is not only for sub_theorem
-- but also for goal (index = 0) and arguments (index = 1 + i)
-- also i_th sub_theorem will be at 1 + (List.length arguments) + i
focus_sub_theorem : IntCursorPath -> Focus Theorem Theorem
focus_sub_theorem top_cursor_path =
  let err_msg = "from Updates.ModeTheorem.focus_sub_theorem"
      getter theorem = getter_aux top_cursor_path theorem
      getter_aux cursor_path theorem =
        case cursor_path of
          []                    -> theorem
          index :: cursor_path' ->
            case theorem.proof of
              ProofByRule rule_name arguments pattern_match_info sub_theorems ->
                let index' = index - (1 + List.length arguments)
                 in getter_aux cursor_path' (list_get_elem index' sub_theorems)
              _ -> Debug.crash err_msg
      updater update_func theorem =
        updater_aux top_cursor_path update_func theorem
      updater_aux cursor_path update_func theorem =
        case cursor_path of
          []                    -> update_func theorem
          index :: cursor_path' -> Focus.update proof_ (\proof ->
            case proof of
              ProofByRule rule_name arguments pattern_match_info sub_theorems ->
                let index' = index - (1 + List.length arguments)
                 in ProofByRule rule_name arguments pattern_match_info <|
                      list_update_elem index' (\sub_theorem ->
                          updater_aux cursor_path' update_func sub_theorem)
                        sub_theorems
              _ -> Debug.crash err_msg) theorem
   in Focus.create getter updater
