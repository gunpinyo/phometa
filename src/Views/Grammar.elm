module Views.Grammar where

import Html exposing (Html, div, hr)

import Models.Cursor exposing (CursorInfo)
import Models.RepoModel exposing (NodePath, Grammar)
import Models.ViewState exposing (View)
import Views.Utils exposing (show_indented_clickable_block,
                             show_clickable_block, show_text_block,
                             show_keyword_block, show_todo_keyword_block)

show_grammar : CursorInfo -> NodePath -> Grammar -> View
show_grammar cursor_info node_path grammar model =
  let header = [ div []
                   [ show_keyword_block "Grammar "
                   , show_text_block "grammar-block" node_path.node_name ]
               , hr [] []]
      body = [Html.text "TODO"] -- TODO: finish this
   in show_indented_clickable_block
        "block" cursor_info identity -- (cmd_enter_mode_grammar record) TODO:
        ( header ++ body )
