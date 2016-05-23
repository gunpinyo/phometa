module Updates.CommonCmd where

import Dict

import Focus exposing ((=>))

import Tools.Utils exposing (list_get_elem)
import Tools.OrderedDict exposing (ordered_dict_remove)
import Models.Focus exposing (mode_, pane_cursor_, root_package_,
                              grids_, nodes_, dict_)
import Models.Cursor exposing (PaneCursor(..))
import Models.RepoModel exposing (PackagePath, ModulePath,
                                  NodeName, NodePath, NodeType(..))
import Models.RepoUtils exposing (focus_package, init_package,
                                  focus_module, get_nodes_types,
                                  get_nodes_inv_dependencies)
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

cmd_remove_module_from_grids : ModulePath -> Command
cmd_remove_module_from_grids module_path =
  Focus.update (grids_) (update_all_grid (\grid -> case grid of
    GridHome _ -> grid
    GridModule module_path' _ -> if module_path' == module_path
      then GridHome [] else grid
    GridNode node_path _ -> if node_path.module_path == module_path
      then GridHome [] else grid))

cmd_remove_package_from_grids : PackagePath -> Command
cmd_remove_package_from_grids package_path =
  let len = List.length package_path
      is_in_this_package package_path' =
        (List.length package_path' >= len) &&
        (List.take len package_path' == package_path)
   in Focus.update (grids_) (update_all_grid (\grid -> case grid of
        GridHome _ -> grid
        GridModule module_path _ ->
          if is_in_this_package module_path.package_path
            then GridHome [] else grid
        GridNode node_path _ ->
          if is_in_this_package node_path.module_path.package_path
            then GridHome [] else grid))

cmd_delete_node : NodePath -> Command
cmd_delete_node node_path model =
  let module_path = node_path.module_path
      inv_dep_graph = get_nodes_inv_dependencies module_path model
      func stack found_nodes = case stack of
        [] -> found_nodes
        head_stack :: tail_stack ->
          if List.member head_stack found_nodes then
            func tail_stack found_nodes
          else
            let new_nodes = Maybe.withDefault []
                              (Dict.get head_stack inv_dep_graph)
             in func (new_nodes ++ tail_stack) (head_stack :: found_nodes)
      to_delete_nodes = List.reverse <| func [node_path.node_name] []
      node_type_dict = get_nodes_types module_path model
      list = List.map (\node_name -> (Maybe.withDefault NodeTypeComment <|
               Dict.get node_name node_type_dict, node_name)) to_delete_nodes
   in model |> cmd_send_message
        (MessageDeleteNodeConfirmation module_path list)

cmd_confirmed_delete_nodes : List NodeName -> ModulePath -> Command
cmd_confirmed_delete_nodes nodes module_path model =
  let fold_func node_name acc_model = acc_model
        |> Focus.update (focus_module module_path => nodes_)
                        (ordered_dict_remove node_name)
        |> cmd_remove_node_from_grids { module_path = module_path
                                      , node_name = node_name }
   in cmd_reset_mode <| List.foldl fold_func model nodes

cmd_delete_module : ModulePath -> Command
cmd_delete_module module_path =
  cmd_send_message (MessageDeleteModuleConfirmation module_path)

cmd_confirmed_delete_module : ModulePath -> Command
cmd_confirmed_delete_module module_path model =
  model
    |> Focus.update (focus_package module_path.package_path => dict_)
                    (Dict.remove module_path.module_name)
    |> cmd_remove_module_from_grids module_path
    |> cmd_reset_mode

cmd_delete_package : PackagePath -> Command
cmd_delete_package package_path =
  cmd_send_message (MessageDeletePackageConfirmation package_path)

cmd_confirmed_delete_package : PackagePath -> Command
cmd_confirmed_delete_package package_path model =
  model
    |> (if List.length package_path == 0 then
          Focus.set root_package_ init_package
        else
          let len = List.length package_path
              parent_package_path = List.take (len - 1) package_path
              package_name = list_get_elem (len - 1) package_path
           in Focus.update (focus_package parent_package_path => dict_)
                           (Dict.remove package_name))
    |> cmd_remove_package_from_grids package_path
    |> cmd_reset_mode
