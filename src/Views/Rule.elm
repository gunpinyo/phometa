module Views.Rule where

import Focus exposing ((=>))
import Html exposing (Html, div, text, hr, br, table, tr, td)
import Html.Attributes exposing (class)

import Tools.Utils exposing (list_focus_elem)
import Tools.HtmlExtra exposing (on_click)
import Models.Focus exposing (conclusion_, sub_cursor_path_,
                              pattern_, arguments_)
import Models.Cursor exposing (CursorInfo, cursor_info_go_to_sub_elem)
import Models.RepoModel exposing (NodePath, Rule, Premise(..))
import Models.RepoUtils exposing (focus_rule, get_rule_variables,
                                  get_variable_css)
import Models.Model exposing (Mode(..), EditabilityRootTerm(..),
                              MicroModeRootTerm(..),
                              RecordModeRule, MicroModeRule(..))
import Models.ModelUtils exposing (init_auto_complete)
import Models.ViewState exposing (View)
import Updates.CommonCmd exposing (cmd_nothing, cmd_delete_node)
import Updates.ModeRule exposing (cmd_enter_mode_rule,
                                  cmd_enter_micro_mode_navigate,
                                  cmd_enter_micro_mode_cascade,
                                  cmd_update_rule_params_and_cascades,
                                  cmd_reset_rule, cmd_lock_rule,
                                  cmd_add_premise_direct,
                                  cmd_add_premise_cascade,
                                  cmd_swap_premise, cmd_delete_premise,
                                  cmd_swap_cascade_rule,cmd_delete_cascade_rule,
                                  cmd_toggle_allow_reduction,
                                  cmd_toggle_allow_unification,
                                  focus_premise_direct_pattern,
                                  focus_premise_cascade_records,
                                  focus_auto_complete)
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
      root_term_record_func sub_focus cursor_path has_complete_control =
        { module_path = node_path.module_path
        , root_term_focus = (rule_focus => sub_focus)
        , top_cursor_info = List.foldl cursor_info_go_to_sub_elem
                              cursor_info cursor_path
        , sub_cursor_path = []                              -- meaningless here
        , micro_mode = MicroModeRootTermNavigate init_auto_complete -- the same
        , is_reducible = False              -- reduction has no effect in rules
        , editability = (if rule.has_locked then
                           EditabilityRootTermReadOnly
                         else if has_complete_control then
                           EditabilityRootTermUpToGrammar
                         else
                           EditabilityRootTermUpToTerm)
        , can_create_fresh_vars = not rule.has_locked && has_complete_control
        , get_existing_variables = get_rule_variables record.node_path
        , on_modify_callback = cmd_update_rule_params_and_cascades record
        , on_quit_callback = cmd_enter_micro_mode_navigate record
        }
      header_htmls =
        [ show_keyword_block <| if rule.has_locked then "Rule" else "Draft Rule"
        , show_text_block "rule-block" node_path.node_name
        , text " "]
      header_buttons = (show_close_button <| cmd_delete_node node_path) ::
        if rule.has_locked then [] else
        [ show_lock_button <| cmd_enter_micro_mode_navigate record
                                >> cmd_lock_rule
        , show_reset_button <| cmd_enter_micro_mode_navigate record
                                 >> cmd_reset_rule
        , show_float_right_button "Add Cascade" <|cmd_add_premise_cascade record
        , show_float_right_button "Add Premise" <|cmd_add_premise_direct record]
      cascade_elem_func cas_records index sub_index cas_record = div [] (
        let sub_focus = focus_premise_cascade_records index
                          => list_focus_elem sub_index
         in [ if rule.has_locked then [] else
              [show_close_button <| cmd_enter_micro_mode_navigate record
                   >> cmd_delete_cascade_rule index sub_index] ++
                 (if List.length cas_records == 1 then [] else
                    [show_swap_button <| cmd_enter_micro_mode_navigate record
                       >> cmd_swap_cascade_rule index sub_index])
            , [show_text_block "rule-block" cas_record.rule_name]
            , if rule.has_locked then
                 if cas_record.allow_unification
                   then [] else [show_keyword_block "exact_match"]
               else
                 [show_button (if cas_record.allow_unification
                                 then "Unifiable"
                                 else "Exact Match")
                  (cmd_toggle_allow_unification index sub_index record)]
            , [show_root_term (root_term_record_func (sub_focus => pattern_)
                                [index + 1, sub_index + 1, 0] False)
                              cas_record.pattern model] ++
              let sub_rule = Focus.get (focus_rule
                               { module_path = node_path.module_path
                               , node_name = cas_record.rule_name }) model
               in List.map2 (,) sub_rule.parameters cas_record.arguments |>
                    List.indexedMap (\arg_index (parameter, argument) ->
                      [ show_keyword_block <|
                          if arg_index == 0 then "with" else ","
                      , let var_css = get_variable_css node_path.module_path
                                       model parameter.var_name argument.grammar
                         in show_text_block var_css parameter.var_name
                      , show_keyword_block "="
                      , show_root_term (root_term_record_func
                          (sub_focus => arguments_ => list_focus_elem arg_index)
                          [index + 1, sub_index + 1, arg_index + 1] False)
                          argument model]) |> List.concat
            ] |> List.concatMap (\htmls -> htmls ++ [text " "]))
      premise_func index premise =
        ((div [] <|
         (if rule.has_locked then [] else
              [show_close_button <| cmd_enter_micro_mode_navigate record
                                         >> cmd_delete_premise index] ++
                 (if List.length rule.premises == 1 then [] else
                    [show_swap_button <| cmd_enter_micro_mode_navigate record
                                           >> cmd_swap_premise index]))
         ++ (case premise of
          PremiseDirect pattern ->
            [ show_keyword_block "premise "
            , show_root_term
                (root_term_record_func (focus_premise_direct_pattern index)
                   [index + 1] True)
                pattern model ]
          PremiseCascade cas_records ->
            [ show_keyword_block "cascade "] ++
            (let inactive_add_cascade_html = [show_button "Add Sub-Rule" <|
                   cmd_enter_micro_mode_cascade record index]
              in if rule.has_locked then [] else
                 case model.mode of
                   ModeRule record' -> if node_path /= record'.node_path
                                         then inactive_add_cascade_html else
                     case record'.micro_mode of
                       MicroModeRuleSelectCascadeRule _ index' ->
                         if index /= index' then inactive_add_cascade_html
                         else [show_auto_complete_filter "button-block"
                                (List.foldl cursor_info_go_to_sub_elem
                                 cursor_info [index + 1, 0]) "sub-rule name"
                                 focus_auto_complete model]
                       _ -> inactive_add_cascade_html
                   _ -> inactive_add_cascade_html)))
        :: (case premise of
             PremiseDirect _ -> []
             PremiseCascade cas_records ->
               if List.isEmpty cas_records then [] else
               [div [class "inactive-indented-block"]
                  (List.indexedMap (cascade_elem_func cas_records index)
                     cas_records)])
        )
      premises_htmls = rule.premises
        |> List.indexedMap premise_func
        |> List.concat
      conclusion_html = div []
        [ show_keyword_block "conclusion "
        , show_root_term (root_term_record_func conclusion_ [0] True)
            rule.conclusion model ]
      parameters_html = div []
        (if List.isEmpty rule.parameters then [] else
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
        [ div [] (header_buttons ++ header_htmls)
        , hr [] []] ++
        premises_htmls ++
        (if List.isEmpty rule.premises then [] else [hr [] []]) ++
        [ conclusion_html
        , parameters_html
        , allow_reduction_html ]
