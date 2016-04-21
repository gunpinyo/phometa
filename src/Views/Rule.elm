module Views.Rule where

import Html exposing (Html, div, hr)

import Models.Cursor exposing (CursorInfo)
import Models.RepoModel exposing (NodePath, Rule)
import Models.ViewState exposing (View)
import Views.Utils exposing (show_indented_clickable_block,
                             show_clickable_block, show_text_block,
                             show_keyword_block, show_todo_keyword_block)

show_rule : CursorInfo -> NodePath -> Rule -> View
show_rule cursor_info node_path rule model =
  let header = [ div []
                   [ show_keyword_block "Rule "
                   , show_text_block "rule-block" node_path.node_name ]
               , hr [] []]
      body = [Html.text "TODO"] -- TODO: finish this
   in show_indented_clickable_block
        "block" cursor_info identity -- (cmd_enter_mode_rule record) TODO:
        ( header ++ body )
