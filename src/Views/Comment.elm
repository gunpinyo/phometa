module Views.Comment where

import Html exposing (div, hr, br, text)
import Html.Attributes exposing (class, classList, style, rows, attribute)
import Focus

import Tools.OrderedDict exposing (ordered_dict_to_list)
import Tools.HtmlExtra exposing (on_typing_to_input_field)
import Models.Focus exposing (micro_mode_)
import Models.Cursor exposing (CursorInfo, cursor_info_go_to_sub_elem)
import Models.RepoModel exposing (ModulePath, NodePath, Node(..))
import Models.RepoUtils exposing (focus_module)
import Models.Model exposing (Command, Mode(..), MicroModeComment(..))
import Models.Action exposing (Action(..), address)
import Models.ViewState exposing (View)
import Updates.CommonCmd exposing (cmd_delete_node)
import Updates.ModeComment exposing (cmd_enter_mode_comment, cmd_set_comment)
import Views.Utils exposing (show_keyword_block, show_text_block, show_button,
                             show_indented_clickable_block, show_close_button)

show_comment : CursorInfo -> NodePath -> String -> View
show_comment cursor_info node_path comment model =
  let record = { node_path        = node_path
               , top_cursor_info  = cursor_info
               , sub_cursor_path  = []
               , micro_mode       = if is_editing then MicroModeCommentEditing
                                                  else MicroModeCommentNavigate
               }
      is_editing = case model.mode of
        ModeComment record' -> node_path == record'.node_path
          && record'.micro_mode == MicroModeCommentEditing
        _                   -> False
      toggle_record = Focus.set micro_mode_ (if is_editing
        then MicroModeCommentNavigate else MicroModeCommentEditing) record
      header_html = div []
        [ show_close_button <| cmd_delete_node node_path
        , div [class "button-panel"] [
            show_button (if is_editing then "Quit Editing" else "Edit Comment")
                        (cmd_enter_mode_comment toggle_record)]
        , show_keyword_block "Comment"
        , show_text_block "comment-block" node_path.node_name]
      body_htmls = if is_editing then
                     [ hr [] []
                     , Html.textarea
                        [ style [("width", "98%")]
                        , rows 10
                        , attribute "data-autofocus" ""
                        , on_typing_to_input_field address (\string ->
                            ActionCommand <| cmd_set_comment record string) ]
                        [text comment]]
                  else if comment == "" then
                    []
                  else
                    [ hr [] []
                    , div [classList [ ("inline-block", True)
                                     , ("mathjax", True)
                                     , ("wordwrap", True)]]
                          [text comment]]
   in show_indented_clickable_block cursor_info (cmd_enter_mode_comment record)
        <| header_html :: body_htmls
