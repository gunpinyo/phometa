module Updates.ModeTheorem where

import Focus exposing ((=>))

import Tools.Utils exposing (list_get_elem)
import Tools.CssExtra exposing (css_inline_str_embed)
import Models.Focus exposing (mode_, micro_mode_, reversed_ref_path_,
                              node_name_)
import Models.Cursor exposing (IntCursorPath, get_cursor_info_from_cursor_tree,
                               cursor_tree_go_to_sub_elem)
import Models.RepoModel exposing (RuleName, Theorem, Proof(..))
import Models.RepoUtils exposing (get_rule_names, focus_rule,
                                  focus_theorem, unify)
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
      let cur_sub_theorem = get_sub_theorem model
          choices = get_rule_names record.node_path.module_path model
            |> List.filter (\rule_name ->
                 let rule = Focus.get (focus_rule (Focus.set node_name_
                              rule_name record.node_path)) model
                     unification_result = unify rule.conclusion
                                                cur_sub_theorem.goal
                  in unification_result /= Nothing) -- TODO:
            |> List.map (\rule_name ->
                 (css_inline_str_embed "rule-block" rule_name, rule_name))
          choice_handler (_, rule_name) =
            cmd_set_rule rule_name
          counter_handler counter =
            cmd_set_micro_mode (MicroModeTheoremSelectRule counter)
       in merge_keymaps
            (keymap_ring_choices
              choices ring_choices_counter choice_handler counter_handler)
            (build_keymap
              [("⭡", "quit root term", KbCmd record.on_quit_callback)])
    MicroModeTheoremSelectTheorem ring_choices_counter ->
      build_keymap [("t", "TODO:", KbCmd identity)]

cmd_set_rule : RuleName -> Command
cmd_set_rule rule_name model =
  model -- TODO:

cmd_set_micro_mode : MicroModeTheorem -> Command
cmd_set_micro_mode micro_mode model =
  Focus.set (focus_record_mode_theorem => micro_mode_) micro_mode model

get_sub_theorem : Model -> Theorem
get_sub_theorem model =
  let record = Focus.get focus_record_mode_theorem model
      top_theorem = Focus.get (focus_theorem record.node_path) model
   in get_sub_theorem' record.sub_cursor_path top_theorem

get_sub_theorem' : IntCursorPath -> Theorem -> Theorem
get_sub_theorem' cursor_path theorem =
  case cursor_path of
    []                    -> theorem
    index :: cursor_path' ->
      case theorem.proof of
        ProofByRule rule_name sub_theorems ->
          get_sub_theorem' cursor_path' (list_get_elem index sub_theorems)
        _ -> Debug.crash "from Updates.ModeTheorem.get_sub_theorem'"
