module Updates.ModeTheorem where

import Focus exposing (Focus, (=>))

import Tools.Utils exposing (list_get_elem, list_update_elem)
import Tools.CssExtra exposing (css_inline_str_embed)
import Models.Focus exposing (mode_, micro_mode_, reversed_ref_path_,
                              node_name_, goal_, proof_)
import Models.Cursor exposing (IntCursorPath,
                               get_cursor_info_from_cursor_tree,
                               cursor_tree_go_to_sub_elem)
import Models.RepoModel exposing (RuleName, TheoremName, Theorem, Proof(..),
                                  SubstitutionList)
import Models.RepoUtils exposing (get_rule_names, focus_rule,
                                  get_theorem_names, focus_theorem,
                                  has_theorem_completed,
                                  multiple_root_substitute,
                                  pattern_matchable, pattern_match)
import Models.Model exposing (Model, Command, KeyBinding(..), Keymap, Command,
                              Mode(..), RecordModeTheorem, MicroModeTheorem(..))
import Models.ModelUtils exposing (focus_record_mode_theorem)
import Updates.KeymapUtils exposing (empty_keymap,
                                     merge_keymaps, merge_keymaps_list,
                                     build_keymap, build_keymap_cond,
                                     keymap_ring_choices)
import Updates.Cursor exposing (cmd_click_block)

cmd_enter_mode_theorem : RecordModeTheorem -> Command
cmd_enter_mode_theorem record =
  let cursor_info = get_cursor_info_from_cursor_tree record
   in (Focus.set mode_ (ModeTheorem record)) >> (cmd_click_block cursor_info)

cmd_from_todo_to_proof_by_rule : Int -> RecordModeTheorem -> Command
cmd_from_todo_to_proof_by_rule index record model =
  model
    |> cmd_click_block (get_cursor_info_from_cursor_tree
                          <| cursor_tree_go_to_sub_elem index record)
    |> Focus.set mode_ (ModeTheorem record)
    |> cmd_set_micro_mode (MicroModeTheoremSelectRule 0)

cmd_from_todo_to_proof_by_lemma : Int -> RecordModeTheorem -> Command
cmd_from_todo_to_proof_by_lemma index record model =
  model
    |> cmd_click_block (get_cursor_info_from_cursor_tree
                          <| cursor_tree_go_to_sub_elem index record)
    |> Focus.set mode_ (ModeTheorem record)
    |> cmd_set_micro_mode (MicroModeTheoremSelectTheorem 0)

keymap_mode_theorem : RecordModeTheorem -> Model -> Keymap
keymap_mode_theorem record model =
  case record.micro_mode of
    MicroModeTheoremNavigate -> build_keymap [("n", "TODO:", KbCmd identity)]
    MicroModeTheoremSelectRule ring_choices_counter ->
      let cur_sub_theorem = Focus.get (focus_current_sub_theorem model) model
          choices = get_rule_names record.node_path.module_path model
            |> List.filter (\rule_name ->
                 let rule = Focus.get (focus_rule (Focus.set node_name_
                              rule_name record.node_path)) model
                  in pattern_matchable rule.conclusion cur_sub_theorem.goal)
            |> List.map (\rule_name ->
                 (css_inline_str_embed "rule-block" rule_name, rule_name))
          choice_handler (_, rule_name) =
            cmd_set_rule rule_name
          counter_handler counter =
            cmd_set_micro_mode (MicroModeTheoremSelectRule counter)
       in (keymap_ring_choices
            choices ring_choices_counter choice_handler counter_handler)
    MicroModeTheoremSelectTheorem ring_choices_counter ->
      let cur_sub_theorem = Focus.get (focus_current_sub_theorem model) model
          choices = get_theorem_names record.node_path.module_path model
            |> List.filter (\theorem_name ->
                 let theorem = Focus.get (focus_theorem (Focus.set node_name_
                                 theorem_name record.node_path)) model
                  in pattern_matchable theorem.goal cur_sub_theorem.goal
                       {- TODO: uncomment this, && has_theorem_completed theorem-})
            |> List.map (\theorem_name ->
                 (css_inline_str_embed "theorem-block" theorem_name,
                  theorem_name))
          choice_handler (_, theorem_name) =
            cmd_set_theorem theorem_name
          counter_handler counter =
            cmd_set_micro_mode (MicroModeTheoremSelectTheorem counter)
       in (keymap_ring_choices
            choices ring_choices_counter choice_handler counter_handler)

cmd_set_rule : RuleName -> Command
cmd_set_rule rule_name model =
  model -- TODO:

cmd_set_theorem : TheoremName -> Command
cmd_set_theorem theorem_name model =
  let err_msg = "from Updates.ModeTheorem.cmd_set_theorem"
      record = Focus.get focus_record_mode_theorem model
      pattern_theorem_path = Focus.set node_name_ theorem_name record.node_path
      pattern_theorem = Focus.get (focus_theorem pattern_theorem_path) model
      top_theorem_focus = focus_theorem record.node_path
      target_theorem = Focus.get top_theorem_focus model
      update_func current_sub_theorem =
        case pattern_match pattern_theorem.goal current_sub_theorem.goal of
          Nothing -> current_sub_theorem
          Just pattern_match_info ->
            Focus.set
              proof_
              (ProofByLemma theorem_name pattern_match_info)
              current_sub_theorem
   in if pattern_matchable pattern_theorem.goal target_theorem.goal then
        Focus.update top_theorem_focus
          (\top_theorem ->
            let top_sub_focus = focus_sub_theorem record.sub_cursor_path
                top_theorem' =
                  Focus.update top_sub_focus update_func top_theorem
                sub_theorem' =
                  Focus.get top_sub_focus top_theorem'
                subst_list = case sub_theorem'.proof of
                               ProofByLemma _ pattern_match_info ->
                                 pattern_match_info.substitution_list
                               _ -> Debug.crash err_msg
             in theorem_tree_substitute subst_list top_theorem')
          model
      else
        model -- if pattern matching fail, do nothing

cmd_set_micro_mode : MicroModeTheorem -> Command
cmd_set_micro_mode micro_mode model =
  Focus.set (focus_record_mode_theorem => micro_mode_) micro_mode model

theorem_tree_substitute : SubstitutionList -> Theorem -> Theorem
theorem_tree_substitute subst_list theorem =
  theorem
    |> Focus.set goal_ (multiple_root_substitute subst_list theorem.goal)
    |> Focus.set proof_
         (case theorem.proof of
            ProofTodo -> ProofTodo
            ProofByRule rule_name pattern_match_info sub_theorems ->
              ProofByRule rule_name pattern_match_info <|
                List.map (theorem_tree_substitute subst_list) sub_theorems
            ProofByReduction theorem' ->
              ProofByReduction <| theorem_tree_substitute subst_list theorem'
            ProofByLemma theorem_name pattern_match_info ->
              ProofByLemma theorem_name pattern_match_info)

focus_current_sub_theorem : Model -> Focus Model Theorem
focus_current_sub_theorem model =
  let record = Focus.get focus_record_mode_theorem model
   in (focus_theorem record.node_path) =>
        (focus_sub_theorem record.sub_cursor_path)

focus_sub_theorem : IntCursorPath -> Focus Theorem Theorem
focus_sub_theorem top_cursor_path =
  let err_msg = "from Updates.ModeTheorem.focus_sub_theorem"
      getter theorem = getter_aux top_cursor_path theorem
      getter_aux cursor_path theorem =
        case cursor_path of
          []                    -> theorem
          index :: cursor_path' ->
            case theorem.proof of
              ProofByRule rule_name pattern_match_info sub_theorems ->
                getter_aux cursor_path' (list_get_elem index sub_theorems)
              _ -> Debug.crash err_msg
      updater update_func theorem =
        updater_aux top_cursor_path update_func theorem
      updater_aux cursor_path update_func theorem =
        case cursor_path of
          []                    -> update_func theorem
          index :: cursor_path' ->
            Focus.update
              proof_
              (\proof ->
                case proof of
                  ProofByRule rule_name pattern_match_info sub_theorems ->
                    ProofByRule rule_name pattern_match_info <|
                      list_update_elem
                        index
                        (\sub_theorem ->
                          updater_aux cursor_path' update_func sub_theorem)
                        sub_theorems
                  _ -> Debug.crash err_msg)
              theorem
   in Focus.create getter updater
