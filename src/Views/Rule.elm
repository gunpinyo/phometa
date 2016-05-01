module Views.Rule where

import Focus exposing ((=>))
import Html exposing (Html, div, text, hr, br)

import Tools.HtmlExtra exposing (on_click)
import Models.Focus exposing (conclusion_, sub_cursor_path_)
import Models.Cursor exposing (CursorInfo, cursor_info_go_to_sub_elem)
import Models.RepoModel exposing (NodePath, Rule)
import Models.RepoUtils exposing (focus_rule, get_rule_variables,
                                  get_variable_css)
import Models.Model exposing (EditabilityRootTerm(..), MicroModeRootTerm(..),
                              RecordModeRule, MicroModeRule(..))
import Models.ModelUtils exposing (init_auto_complete)
import Models.ViewState exposing (View)
import Updates.CommonCmd exposing (cmd_nothing)
import Updates.ModeRule exposing (cmd_enter_mode_rule,
                                  cmd_toggle_allow_reduction)
import Views.Utils exposing (show_indented_clickable_block,
                             show_clickable_block, show_text_block,
                             show_keyword_block, show_todo_keyword_block,
                             show_button)
import Views.Term exposing (show_root_term)

show_rule : CursorInfo -> NodePath -> Rule -> View
show_rule cursor_info node_path rule model =
  let record = { node_path        = node_path
               , top_cursor_info  = cursor_info
               , sub_cursor_path  = []
               , micro_mode       = MicroModeRuleNavigate
               }
      rule_focus = focus_rule node_path
      header_html = div []
        [ show_keyword_block <| if rule.has_locked then "Rule" else "Draft Rule"
        , show_text_block "rule-block" node_path.node_name ]
      premises_htmls = [Html.text "TODO"]
      conclusion_html = div []
        [ show_keyword_block "conclusion "
        , show_root_term
            { module_path = node_path.module_path
            , root_term_focus = (rule_focus => conclusion_)
            , top_cursor_info = (cursor_info_go_to_sub_elem 2 cursor_info)
            , sub_cursor_path = [] -- meaningless here
            , micro_mode = MicroModeRootTermNavigate -- meaningless
                             init_auto_complete
            , is_reducible = rule.has_locked
            , editability = (if rule.has_locked
                               then EditabilityRootTermReadOnly
                               else EditabilityRootTermUpToGrammar)
            , can_create_fresh_vars = not rule.has_locked
            , get_existing_variables = get_rule_variables record.node_path
            , on_quit_callback = cmd_enter_mode_rule record
            } rule.conclusion model ]
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
          , show_button (cmd_toggle_allow_reduction record)
              [text <| if rule.allow_reduction then "Enabled" else "Disabled"]
          ]
   in show_indented_clickable_block cursor_info (cmd_enter_mode_rule record) <|
        [ header_html, hr [] []] ++
        premises_htmls ++
        [ conclusion_html
        , parameters_html
        , allow_reduction_html ]
