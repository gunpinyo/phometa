module Updates.ModeComment where

import Focus

import Models.Focus exposing (mode_)
import Models.Cursor exposing (get_cursor_info_from_cursor_tree)
import Models.RepoModel exposing (Node(..))
import Models.RepoUtils exposing (focus_node)
import Models.Model exposing (Command, Mode(..), RecordModeComment)
import Updates.Cursor exposing (cmd_click_block)

cmd_enter_mode_comment : RecordModeComment -> Command
cmd_enter_mode_comment record =
  let cursor_info = get_cursor_info_from_cursor_tree record
   in (Focus.set mode_ (ModeComment record)) >> (cmd_click_block cursor_info)

cmd_set_comment : RecordModeComment -> String -> Command
cmd_set_comment record comment =
  Focus.update (focus_node record.node_path)
    (\node -> case node of
       NodeComment _ -> NodeComment comment
       _             -> node)