module Views.Theorem where

import Debug

import Focus exposing (Focus, (=>))
import Html exposing (Html, div, text, hr)
import Html.Attributes exposing (class, classList)

import Tools.HtmlExtra exposing (debug_to_html, on_click)
import Models.Focus exposing (goal_)
import Models.Cursor exposing (CursorInfo, cursor_info_go_to_sub_elem,
                               cursor_tree_go_to_sub_elem, cursor_info_is_here)
import Models.RepoModel exposing (NodePath, Node(..), Theorem, Proof(..))
import Models.RepoUtils exposing (focus_rule, get_usable_rule_names,
                                  focus_theorem, get_usable_theorem_names,
                                  has_root_term_completed,
                                  focus_theorem_rule_argument,
                                  get_theorem_variables_from_model)
import Models.Model exposing (Model,
                              EditabilityRootTerm(..), MicroModeRootTerm(..),
                              RecordModeTheorem, MicroModeTheorem(..))
import Models.Action exposing (Action(..), address)
import Models.ViewState exposing (View)
import Updates.CommonCmd exposing (cmd_nothing)
import Updates.Cursor exposing (cmd_click_block)
import Updates.ModeTheorem exposing (cmd_enter_mode_theorem,
                                     cmd_select_rule,
                                     cmd_select_lemma,
                                     cmd_execute_current_rule,
                                     focus_auto_complete,
                                     focus_sub_theorem)
import Views.Utils exposing (show_indented_clickable_block,
                             show_clickable_block, show_text_block,
                             show_keyword_block, show_todo_keyword_block,
                             show_auto_complete_filter)
import Views.Term exposing (show_root_term, get_variable_css)

show_theorem : CursorInfo -> NodePath -> Theorem -> View
show_theorem cursor_info node_path theorem model =
  let err_msg = "from Views.Theorem.show_theorem"
      theorem_focus = focus_theorem node_path
      record = { node_path        = node_path
               , top_cursor_info  = cursor_info
               , sub_cursor_path  = []
               , micro_mode       = MicroModeTheoremNavigate
               , has_locked       = False
               , on_quit_callback = cmd_nothing
               }
      header = [ div []
                   [ show_keyword_block "Theorem "
                   , show_text_block "theorem-block" node_path.node_name ]
               , hr [] []]
      body = show_sub_theorem cursor_info record theorem theorem_focus model
   in show_indented_clickable_block
        "block" cursor_info (cmd_enter_mode_theorem record)
        ( header ++ body )

show_sub_theorem : CursorInfo -> RecordModeTheorem -> Theorem ->
                     Focus Model Theorem -> Model -> List Html
show_sub_theorem cursor_info record theorem theorem_focus model =
  let module_path = record.node_path.module_path
      is_setting_main_goal =
        theorem.proof == ProofTodo && List.isEmpty record.sub_cursor_path
      goal_record =
        { module_path = module_path
        , root_term_focus = (theorem_focus => goal_)
        , top_cursor_info = (cursor_info_go_to_sub_elem 0 cursor_info)
        , sub_cursor_path = [] -- meaningless here but need to make type checked
                               -- will be replaced in `show_root_term` function
        , micro_mode = MicroModeRootTermNavigate            -- the same as above
        , editability = (if is_setting_main_goal
                           then EditabilityRootTermUpToGrammar
                           else EditabilityRootTermReadOnly)
        , can_create_fresh_vars = True
        , get_existing_variables = get_theorem_variables_from_model
                                     record.node_path
        , on_quit_callback = cmd_enter_mode_theorem record
        }
      goal_html = show_root_term goal_record theorem.goal model
      show_rule_name_and_arguments is_editable rule_name arguments =
        let rule = Focus.get (focus_rule { module_path = module_path
                                         , node_name = rule_name
                                         }) model
            indexed_map_func index (parameter, argument) =
              [ show_keyword_block <| if index == 0 then "with" else ","
              , let var_css = get_variable_css parameter.var_name
                                argument.grammar module_path model
                 in show_text_block var_css parameter.var_name
              , show_keyword_block "="
              , show_root_term
                  { module_path = module_path
                  , root_term_focus =
                      theorem_focus => focus_theorem_rule_argument index
                  , top_cursor_info =
                      cursor_info_go_to_sub_elem (index + 1) cursor_info
                  , sub_cursor_path = [] -- meaningless the same as above
                  , micro_mode = MicroModeRootTermNavigate -- the same
                  , editability = if is_editable
                                    then EditabilityRootTermUpToTerm
                                    else EditabilityRootTermReadOnly
                  , can_create_fresh_vars = False
                  , get_existing_variables = get_theorem_variables_from_model
                                               record.node_path
                  , on_quit_callback =
                      cmd_enter_mode_theorem record >> cmd_execute_current_rule
                  } argument model
              ]
         in List.map2 (,) rule.parameters arguments
              |> List.indexedMap indexed_map_func
              |> List.concat
              |> List.append [ show_keyword_block "proof_by_rule"
                             , show_text_block "rule-block" rule_name ]
      goal_proof_div_html proof_htmls =
        div [] (goal_html :: text " " :: proof_htmls)
   in case theorem.proof of
        ProofTodo ->
          if not <| has_root_term_completed theorem.goal then
            [ goal_proof_div_html
                [ show_todo_keyword_block "to_prove"
                , text " "
                , show_todo_keyword_block
                    "Please fill all holes in the goal before continue."]]
          else
            let rule_html =
                  let sub_cursor_info = cursor_info_go_to_sub_elem 1 cursor_info
                      on_click_cmd = cmd_select_rule 1 record
                   in if cursor_info_is_here sub_cursor_info then
                        show_auto_complete_filter "button-block" sub_cursor_info
                          "Proof By Rule" cmd_nothing focus_auto_complete model
                      else
                        show_clickable_block "button-block" sub_cursor_info
                          on_click_cmd [text "Proof By Rule"]
                lemma_html =
                  let sub_cursor_info = cursor_info_go_to_sub_elem 2 cursor_info
                      on_click_cmd = cmd_select_lemma 2 record
                   in if cursor_info_is_here sub_cursor_info then
                        show_auto_complete_filter "button-block" sub_cursor_info
                          "Proof By Lemma" cmd_nothing focus_auto_complete model
                      else
                        show_clickable_block "button-block" sub_cursor_info
                          on_click_cmd [text "Proof By Lemma"]
                rule_exists = not <| List.isEmpty <|
                  get_usable_rule_names theorem.goal.grammar module_path model
                lemma_exists = not <| List.isEmpty <|
                  get_usable_theorem_names theorem.goal
                    record.node_path.node_name module_path model
                possibly_rule_lemma_htmls =
                  if rule_exists && lemma_exists then
                    [ rule_html
                    , text " "
                    , show_todo_keyword_block "or"
                    , text " "
                    , lemma_html ]
                  else if rule_exists then
                    [ rule_html ]
                  else if lemma_exists then
                    [ lemma_html ]
                  else
                    [ show_todo_keyword_block
                        "but there are nothing possible to prove it."]
             in [ goal_proof_div_html <|
                    [ show_todo_keyword_block "to_prove"
                    , text " "] ++ possibly_rule_lemma_htmls
                ]
        ProofTodoWithRule rule_name arguments ->
          [ show_todo_keyword_block <| "to_prove "
                                    ++ "please enter arguments before continue."
          , goal_proof_div_html
              (show_rule_name_and_arguments True rule_name arguments) ]
        ProofByRule rule_name arguments pattern_matching_info sub_theorems ->
          let indexed_map_func index sub_theorem =
                let cursor_index = 1 + List.length arguments + index
                    cursor_info' = cursor_info_go_to_sub_elem
                                     cursor_index cursor_info
                    record' = cursor_tree_go_to_sub_elem cursor_index record
                    sub_theorem_focus = theorem_focus =>
                                          (focus_sub_theorem [cursor_index])
                    sub_theorem_htmls = show_sub_theorem cursor_info' record'
                                          sub_theorem sub_theorem_focus model
                 in show_indented_clickable_block "block" cursor_info'
                      (cmd_enter_mode_theorem record')
                      (sub_theorem_htmls)
           in (List.indexedMap indexed_map_func sub_theorems) ++
                [ goal_proof_div_html
                   (show_rule_name_and_arguments False rule_name arguments) ]
        ProofByLemma theorem_name pattern_matching_info ->
          [ goal_proof_div_html
              [ show_keyword_block "proof_by_lemma"
              , show_text_block "theorem-block" theorem_name
              ]
          ]
