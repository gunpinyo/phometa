module Views.Rule where

import Focus exposing ((=>))
import Html exposing (Html, div, text, hr, br)

import Tools.HtmlExtra exposing (on_click)
import Models.Focus exposing (conclusion_, sub_cursor_path_)
import Models.Cursor exposing (CursorInfo, cursor_info_go_to_sub_elem)
import Models.RepoModel exposing (NodePath, Rule, Premise(..))
import Models.RepoUtils exposing (focus_rule, get_rule_variables,
                                  get_variable_css)
import Models.Model exposing (EditabilityRootTerm(..), MicroModeRootTerm(..),
                              RecordModeRule, MicroModeRule(..))
import Models.ModelUtils exposing (init_auto_complete)
import Models.ViewState exposing (View)
import Updates.CommonCmd exposing (cmd_nothing)
import Updates.ModeRule exposing (cmd_enter_mode_rule,
                                  cmd_enter_micro_mode_navigate,
                                  cmd_reset_rule, cmd_lock_rule,
                                  cmd_add_premise_direct,
                                  cmd_add_premise_cascade,
                                  cmd_swap_premise, cmd_delete_premise,
                                  cmd_toggle_allow_reduction,
                                  focus_premise_direct_pattern)
import Views.Utils exposing (show_indented_clickable_block,
                             show_clickable_block, show_text_block,
                             show_keyword_block, show_todo_keyword_block,
                             show_close_button, show_auto_complete_filter,
                             show_button, show_lock_button, show_swap_button,
                             show_reset_button, show_float_right_button)
import Views.Term exposing (show_root_term)

show_rule : CursorInfo -> NodePath -> Rule -> View
show_rule cursor_info node_path rule model =
  let record = { node_path        = node_path
               , top_cursor_info  = cursor_info
               , sub_cursor_path  = []
               , micro_mode       = MicroModeRuleNavigate
               }
      rule_focus = focus_rule node_path
      root_term_record_func sub_focus cursor_path can_set_grammar =
        { module_path = node_path.module_path
        , root_term_focus = (rule_focus => sub_focus)
        , top_cursor_info = List.foldl
            (\index -> cursor_info_go_to_sub_elem index) cursor_info cursor_path
        , sub_cursor_path = []                              -- meaningless here
        , micro_mode = MicroModeRootTermNavigate init_auto_complete -- the same
        , is_reducible = False              -- reduction has no effect in rules
        , editability = (if rule.has_locked then
                           EditabilityRootTermReadOnly
                         else if can_set_grammar then
                           EditabilityRootTermUpToGrammar
                         else
                           EditabilityRootTermUpToTerm)
        , can_create_fresh_vars = not rule.has_locked
        , get_existing_variables = get_rule_variables record.node_path
        , on_quit_callback = cmd_enter_mode_rule record
        }
      header_htmls =
        [ show_keyword_block <| if rule.has_locked then "Rule" else "Draft Rule"
        , show_text_block "rule-block" node_path.node_name
        , text " "]
      header_buttons = if rule.has_locked then [] else
        [ show_lock_button <| cmd_enter_micro_mode_navigate record
                                >> cmd_lock_rule
        , show_reset_button <| cmd_enter_micro_mode_navigate record
                                 >> cmd_reset_rule
        , show_float_right_button "Add Cascade" <|cmd_add_premise_cascade record
        , show_float_right_button "Add Premise" <|cmd_add_premise_direct record]
      premises_htmls = rule.premises |> List.indexedMap (\index premise ->
          div [] <| (case premise of
            PremiseDirect pattern ->
              [ show_keyword_block "premise "
              , show_root_term
                  (root_term_record_func (focus_premise_direct_pattern index)
                     [index + 1] True)
                  pattern model ]
            PremiseCascade cas_records ->
              [ show_keyword_block "cascade "
              , text "TODO" ])
          ++ (if rule.has_locked then [] else
                [show_close_button <| cmd_enter_micro_mode_navigate record
                                           >> cmd_delete_premise index] ++
                   (if List.length rule.premises == 1 then [] else
                      [show_swap_button <| cmd_enter_micro_mode_navigate record
                                             >> cmd_swap_premise index])))
      conclusion_html = div []
        [ show_keyword_block "conclusion "
        , show_root_term (root_term_record_func conclusion_ [0] True)
            rule.conclusion model ]
      parameters_html = div []
        (if not rule.has_locked || List.isEmpty rule.parameters then [] else
          rule.parameters
            |> List.indexedMap (\ index param_record ->
                [ show_keyword_block <| if index /= 0 then ","
                    else "parameter" ++ (if List.length rule.parameters == 1
                                          then " " else "s ")
                , show_text_block
                    (get_variable_css node_path.module_path model
                      param_record.var_name param_record.grammar)
                    param_record.var_name
                , show_keyword_block ":"
                , show_text_block "grammar-block" param_record.grammar])
            |> List.concat)
      allow_reduction_html = div [] <|
        if rule.has_locked then
          if rule.allow_reduction then [show_keyword_block "allow_reduction"]
                                  else []
        else
          [ show_keyword_block "reduction "
          , show_button (if rule.allow_reduction then "Enabled" else "Disabled")
              (cmd_toggle_allow_reduction record)
          ]
   in show_indented_clickable_block cursor_info (cmd_enter_mode_rule record) <|
        [ div [] (header_htmls ++ header_buttons)
        , hr [] []] ++
        premises_htmls ++
        [ conclusion_html
        , parameters_html
        , allow_reduction_html ]
