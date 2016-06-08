module Updates.ModeRepo where

import Dict
import Focus exposing (Focus, (=>))

import Tools.CssExtra exposing (css_inline_str_embed)
import Models.Focus exposing (pane_cursor_, grids_, is_folded_, nodes_, order_,
                              mode_, micro_mode_, nodes_, dict_)
import Models.Cursor exposing (PaneCursor(..))
import Models.RepoModel exposing (ContainerName, PackageElem(..),
                                  PackagePath, ModulePath, NodeName, NodePath,
                                  Node(..), NodeType(..))
import Models.RepoUtils exposing (focus_package, init_package,
                                  focus_module, init_module,
                                  get_usable_grammar_names, init_grammar,
                                  get_usable_rule_names, init_rule,
                                  get_usable_theorem_names, init_theorem)
import Models.Message exposing (Message(..))
import Models.Model exposing (Model, Keymap, AutoComplete, Mode(..),
                              RecordModeRepo, MicroModeRepo(..), KeyBinding(..))
import Models.ModelUtils exposing (init_auto_complete, focus_record_mode_repo)
import Models.Grid exposing (Grid(..), focus_grid)
import Models.Model exposing (Command)
import Updates.CommonCmd exposing (cmd_nothing, cmd_reset_mode)
import Updates.Cursor exposing (cmd_change_pane_cursor)
import Updates.Message exposing (cmd_send_message)
import Updates.KeymapUtils exposing (empty_keymap, build_keymap, merge_keymaps,
                                     keymap_auto_complete)

keymap_mode_repo : RecordModeRepo -> Model -> Keymap
keymap_mode_repo record model =
  case record.micro_mode of
    MicroModeRepoNavigate -> empty_keymap
    MicroModeRepoAddPkgMod auto_complete package_path is_adding_module ->
      let hit_return_msg = if is_adding_module then "add module"
                                               else "add package"
          command = cmd_add_pkgmod package_path is_adding_module
       in merge_keymaps (build_keymap [("Escape", "quit " ++ hit_return_msg
                                       , KbCmd cmd_enter_micro_mode_navigate)])
                        (keymap_auto_complete [] True
                           (Just (command, hit_return_msg))
                           focus_auto_complete model)

cmd_enter_mode_repo : MicroModeRepo -> Command
cmd_enter_mode_repo micro_mode =
  Focus.set pane_cursor_ PaneCursorPackage
    >> Focus.set mode_ (ModeRepo {micro_mode = micro_mode})

cmd_enter_micro_mode_navigate : Command
cmd_enter_micro_mode_navigate =
  cmd_enter_mode_repo MicroModeRepoNavigate

cmd_enter_micro_mode_add_pkgmod : PackagePath -> Bool -> Command
cmd_enter_micro_mode_add_pkgmod package_path is_adding_module =
  let micro_mode =
        MicroModeRepoAddPkgMod init_auto_complete package_path is_adding_module
   in cmd_enter_mode_repo micro_mode

cmd_select_module : ModulePath -> Command
cmd_select_module module_path model =
  let pane_cursor = if model.pane_cursor == PaneCursorPackage
                      then PaneCursorGrid1 else model.pane_cursor
      grid = GridModule module_path []
   in model
        |> Focus.set pane_cursor_ pane_cursor
        |> Focus.set (grids_ => focus_grid pane_cursor) grid
        |> cmd_reset_mode
        |> cmd_change_pane_cursor pane_cursor

cmd_select_node : NodePath -> Command
cmd_select_node node_path model =
  let pane_cursor = if model.pane_cursor == PaneCursorPackage
                      then PaneCursorGrid1 else model.pane_cursor
      grid = GridNode node_path []
   in model
        |> Focus.set pane_cursor_ pane_cursor
        |> Focus.set (grids_ => focus_grid pane_cursor) grid
        |> cmd_reset_mode
        |> cmd_change_pane_cursor pane_cursor

cmd_package_fold_unfold : PackagePath -> Command
cmd_package_fold_unfold package_path =
  Focus.update (focus_package package_path => is_folded_) not
    >> cmd_enter_micro_mode_navigate

cmd_module_fold_unfold : ModulePath -> Command
cmd_module_fold_unfold module_path =
  Focus.update (focus_module module_path => is_folded_) not
    >> cmd_enter_micro_mode_navigate

cmd_add_pkgmod : PackagePath -> Bool -> ContainerName-> Command
cmd_add_pkgmod package_path is_adding_module pkgmod_name model =
  let err_msg = "from Updates.ModeRepo.cmd_add_pkgmod"
      new_pkgmod = if is_adding_module then PackageElemMod init_module
                                       else PackageElemPkg init_package
      parent_package = Focus.get (focus_package package_path) model
   in if Dict.member pkgmod_name parent_package.dict then
        let css_class = case Dict.get pkgmod_name parent_package.dict of
                          Nothing -> Debug.crash err_msg
                          Just (PackageElemPkg _) -> "package-block"
                          Just (PackageElemMod _) -> "module-block"
         in model |> cmd_send_message (MessageException <|
                       (css_inline_str_embed css_class pkgmod_name) ++
                       " already exists here, hence, cannot create a new one")
                  |> cmd_enter_micro_mode_navigate
      else
        model |> Focus.update (focus_package package_path => dict_)
                   (Dict.insert pkgmod_name new_pkgmod)
              |> cmd_enter_micro_mode_navigate

focus_auto_complete : Focus Model AutoComplete
focus_auto_complete =
  let err_msg = "from Updates.ModeRepo.focus_auto_complete"
      getter record = case record.micro_mode of
        MicroModeRepoNavigate                     -> Debug.crash err_msg
        MicroModeRepoAddPkgMod auto_complete _ _  -> auto_complete
      updater update_func record = case record.micro_mode of
        MicroModeRepoNavigate                   -> record
        MicroModeRepoAddPkgMod auto_complete package_path is_adding_module ->
          Focus.set micro_mode_ (MicroModeRepoAddPkgMod
            (update_func auto_complete) package_path is_adding_module) record
   in (focus_record_mode_repo => Focus.create getter updater)
