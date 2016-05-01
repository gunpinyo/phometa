module Updates.ModeRule where

import Focus exposing (Focus, (=>))

import Models.Focus exposing (mode_, micro_mode_, reversed_ref_path_,
                              node_name_, sub_cursor_path_, allow_reduction_)
import Models.Cursor exposing (IntCursorPath, CursorInfo,
                               cursor_info_is_here,
                               get_cursor_info_from_cursor_tree,
                               cursor_info_go_to_sub_elem,
                               cursor_tree_go_to_sub_elem)
import Models.RepoModel exposing (Term(..), RuleName)
import Models.RepoUtils exposing (has_root_term_completed,
                                  get_usable_rule_names, focus_rule, apply_rule,
                                  has_root_term_completed,
                                  root_term_undefined_grammar,
                                  get_term_todo_cursor_paths)
import Models.Message exposing (Message(..))
import Models.Model exposing (Model, Command, KeyBinding(..), Keymap, Command,
                              AutoComplete, Mode(..),
                              EditabilityRootTerm(..), MicroModeRootTerm(..),
                              RecordModeRule, MicroModeRule(..))
import Models.ModelUtils exposing (focus_record_mode_theorem,
                                   init_auto_complete)
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

cmd_toggle_allow_reduction : RecordModeRule -> Command
cmd_toggle_allow_reduction record model =
  let record' = record
        |> Focus.set micro_mode_ MicroModeRuleNavigate
        |> Focus.set sub_cursor_path_ [0]
      rule_focus = focus_rule record.node_path
   in model
        |> cmd_enter_mode_rule record'
        |> Focus.update (rule_focus => allow_reduction_) not
