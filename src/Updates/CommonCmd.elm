module Updates.CommonCmd where

import Focus

import Models.Focus exposing (mode_, pane_cursor_, root_package_, grids_)
import Models.Cursor exposing (PaneCursor(..))
import Models.RepoEnDeJson exposing (decode_repository)
import Models.Grid exposing (init_grids)
import Models.Message exposing (Message(..))
import Models.Model exposing (Command, Mode(..))
import Updates.Message exposing (cmd_send_message)

cmd_nothing : Command
cmd_nothing = identity

cmd_reset_mode : Command
cmd_reset_mode model =
  model
    |> Focus.set pane_cursor_ PaneCursorPackage
    |> Focus.set mode_ ModeNothing

cmd_load_repository : String -> Command
cmd_load_repository repo_string =
  case decode_repository repo_string of
    Ok root_package -> Focus.set root_package_ root_package
                    >> cmd_send_message (MessageSuccess
                         "repository has been loaded successfully")
                    >> Focus.set grids_ init_grids
                    >> cmd_reset_mode
    Err err_msg     -> cmd_send_message (MessageException
                         <| "cannot load repository because " ++ err_msg)
