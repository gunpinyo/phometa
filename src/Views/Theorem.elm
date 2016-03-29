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
import Models.RepoUtils exposing (focus_theorem, has_root_term_completed)
import Models.Model exposing (Model, EditabilityRootTerm(..),
                              RecordModeTheorem, MicroModeTheorem(..))
import Models.Action exposing (Action(..), address)
import Models.ViewState exposing (View)
import Updates.CommonCmd exposing (cmd_nothing)
import Updates.Cursor exposing (cmd_click_block)
import Updates.ModeTheorem exposing (cmd_enter_mode_theorem,
                                     cmd_from_todo_to_proof_by_rule,
                                     cmd_from_todo_to_proof_by_lemma)
import Views.Utils exposing (show_indented_clickable_block,
                             show_clickable_block,
                             show_text_block, show_keyword_block)
import Views.Term exposing (show_root_term)

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
                   , show_text_block "newly-defined-block" node_path.node_name ]
               , hr [] []]
      body = show_sub_theorem cursor_info record theorem theorem_focus model
   in show_indented_clickable_block
        "block" cursor_info (cmd_enter_mode_theorem record)
        ( header ++ body )

show_sub_theorem : CursorInfo -> RecordModeTheorem -> Theorem ->
                     Focus Model Theorem -> Model -> List Html
show_sub_theorem cursor_info record theorem theorem_focus model =
  let goal_html = div [] [ show_keyword_block "goal "
                         , show_root_term
                             (cursor_info_go_to_sub_elem cursor_info 0)
                             record.node_path.module_path
                             (if theorem.proof == ProofTodo
                                && List.isEmpty record.sub_cursor_path
                               then EditabilityRootTermUpToGrammar
                               else EditabilityRootTermReadOnly)
                             (cmd_enter_mode_theorem record)
                             (theorem_focus => goal_) theorem.goal model]
   in case theorem.proof of
        ProofTodo ->
          if not <| has_root_term_completed theorem.goal then
            [ goal_html
            , show_keyword_block
                "to_prove, please fill all holes in the goal before continue."]
          else
            [ goal_html
            , show_keyword_block "to_prove"
            , show_clickable_block
                "button-block" (cursor_info_go_to_sub_elem cursor_info 1)
                (cmd_from_todo_to_proof_by_rule 1 record)
                [text "Proof By Rule"]
            , show_keyword_block "or"
            , show_clickable_block
                "button-block" (cursor_info_go_to_sub_elem cursor_info 2)
                (cmd_from_todo_to_proof_by_lemma 2 record)
                [text "Proof By Lemma"]]
        ProofByRule rule_name sub_theorems -> [text "TODO:"]
        ProofByLemma theorem_name -> [text "TODO:"]
