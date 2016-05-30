module Views.Package where

import Dict

import Html exposing (Html, div, text, table, tr, td)
import Html.Attributes exposing (class, classList, style)

import Tools.Flex exposing (flex_div)
import Tools.OrderedDict exposing (ordered_dict_to_list)
import Tools.HtmlExtra exposing (on_click)
import Models.Cursor exposing (PaneCursor(..), init_cursor_info)
import Models.RepoModel exposing (PackageName, PackagePath, Package,
                                  PackageElem(..), ModuleName, Module,
                                  ModulePath, Node(..), NodeType(..))
import Models.Model exposing (Mode(..), MicroModeRepo(..))
import Models.ViewState exposing (View)
import Models.Action exposing (Action(..), address)
import Updates.CommonCmd exposing (cmd_nothing,
                                   cmd_delete_package, cmd_delete_module)
import Updates.ModeRepo exposing (cmd_enter_micro_mode_navigate,
                                  cmd_enter_micro_mode_add_pkgmod,
                                  cmd_select_node, cmd_select_module,
                                  cmd_package_fold_unfold,
                                  cmd_module_fold_unfold,
                                  focus_auto_complete)
import Views.Utils exposing (show_clickable_block,
                             show_button, show_non_float_close_button,
                             show_auto_complete_filter, show_keyword_block)

show_package_pane : View
show_package_pane model =
  flex_div []
    [ classList [("pane", True),
                 ("pane-on-cursor", model.pane_cursor == PaneCursorPackage)]
    , on_click address <| ActionCommand <| cmd_enter_micro_mode_navigate]
    [show_package "Repository" [] model.root_package model]

show_package : PackageName -> PackagePath -> Package -> View
show_package package_name package_path package model =
  let header = tr [] [ td [ on_click address <| ActionCommand <|
                             cmd_package_fold_unfold package_path
                          , style [("cursor", "pointer")]]
                         [text <| if package.is_folded then "▶" else "▼" ]
                     , td [] [ div [class "package-block"] [text package_name]
                             , show_non_float_close_button <|
                              cmd_delete_package package_path]]
      dummy_cursor_info = init_cursor_info False [] PaneCursorPackage
      func (name, package_elem) =
        case package_elem of
          PackageElemPkg package' ->
            show_package name (package_path ++ [name]) package' model
          PackageElemMod module'  ->
            show_module name { package_path = package_path
                             , module_name = name
                             } module' model
      detail = if package.is_folded || Dict.isEmpty package.dict then [] else
                 [td [] [], td [] <| List.map func <| Dict.toList package.dict]
      input_panel_inactive =
          (List.map2 (\is_adding_module placeholder -> show_button placeholder
               <| cmd_enter_micro_mode_add_pkgmod package_path is_adding_module)
             [False, True] ["Add Package", "Add Module"])
      input_panel = if package.is_folded then [] else
        (\list -> [tr [] [ td [] [], td [] list]]) <|
        case model.mode of
          ModeRepo record -> case record.micro_mode of
            MicroModeRepoAddPkgMod auto_complete package_path'
                                     is_adding_module ->
              if package_path /= package_path' then input_panel_inactive else
              [ show_auto_complete_filter "button-block" dummy_cursor_info
                  (if is_adding_module then "Add Module" else "Add Package")
                  focus_auto_complete model]
            _ -> input_panel_inactive
          _ -> input_panel_inactive
   in table [class "package-module-table"] (header :: input_panel ++ detail)

show_module : ModuleName -> ModulePath -> Module -> View
show_module module_name module_path module' model =
  let header = tr [] [ td [ on_click address <| ActionCommand <|
                             cmd_module_fold_unfold module_path
                          , style [("cursor", "pointer")]]
                          [text <| if module'.is_folded then "▶" else "▼" ]
                     , td [] [ div [ class "module-block"
                                   , on_click address <| ActionCommand <|
                                       cmd_select_module module_path
                                   , style [("cursor", "pointer")]]
                                   [text module_name]
                             , show_non_float_close_button <|
                                cmd_delete_module module_path]]
      dummy_cursor_info = init_cursor_info False [] PaneCursorPackage
      func index (node_name, node) =
        let css_class = case node of
                          NodeComment _ -> "comment-block"
                          NodeGrammar _ -> "grammar-block"
                          NodeRule _ -> "rule-block"
                          NodeTheorem _ _ -> "theorem-block"
            node_path = { module_path = module_path
                        , node_name = node_name
                        }
            html = show_clickable_block     -- `cursor_info` is not important
              css_class dummy_cursor_info   -- since cursor will be changed
              (cmd_select_node node_path)   -- immediately by `cmd_select_node`
              [text node_name]
         in [html]
      detail = if module'.is_folded || Dict.isEmpty module'.nodes.dict then []
                 else ordered_dict_to_list module'.nodes
                        |> List.indexedMap func
                        |> List.map (\list -> tr [] [ td [] [], td [] list])
   in table [class "package-module-table"] (header :: detail)
