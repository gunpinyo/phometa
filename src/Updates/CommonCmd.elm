module Updates.CommonCmd where

import Focus

import Models.Focus exposing (mode_, pane_cursor_, root_package_, grids_)
import Models.Cursor exposing (PaneCursor(..))
import Models.RepoModel exposing (NodePath)
import Models.RepoEnDeJson exposing (decode_repository, de_package)
import Models.Grid exposing (Grid(..), init_grids, update_all_grid)
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

cmd_parse_and_load_repository : String -> Command
cmd_parse_and_load_repository repo_string =
  case decode_repository repo_string of
    Ok root_package -> Focus.set root_package_ root_package
                    >> cmd_send_message (MessageSuccess
                         "repository has been loaded successfully")
                    >> Focus.set grids_ init_grids
                    >> cmd_reset_mode
    Err err_msg     -> cmd_send_message (MessageException
                         <| "cannot parse repository because " ++ err_msg)

cmd_remove_node_from_grids : NodePath -> Command
cmd_remove_node_from_grids node_path =
  Focus.update (grids_) (update_all_grid (\grid -> case grid of
    GridHome _ -> grid
    GridModule module_path _ -> if module_path == node_path.module_path
      then GridModule module_path [] else grid
    GridNode node_path' _ -> if node_path' == node_path
      then GridModule node_path.module_path [] else grid))
