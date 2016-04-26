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
                                  ModulePath, Node(..))
import Models.ViewState exposing (View)
import Models.Action exposing (Action(..), address)
import Updates.Repository exposing (cmd_select_node, cmd_package_fold_unfold,
                                    cmd_module_fold_unfold)
import Views.Utils exposing (show_clickable_block)

show_package_pane : View
show_package_pane model =
  flex_div []
    [classList [("pane", True),
                ("pane-on-cursor", model.pane_cursor == PaneCursorPackage)]]
    [show_package "Root Package" [] model.root_package model]

show_package : PackageName -> PackagePath -> Package -> View
show_package package_name package_path package model =
  let header = tr [] [ td [on_click address <| ActionCommand <|
                             cmd_package_fold_unfold package_path]
                         [text <| if package.is_folded then "▶" else "▼" ]
                     , td [class "package-package-td"] [text package_name]]
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
   in table [class "package-package-table"] (header :: detail)

show_module : ModuleName -> ModulePath -> Module -> View
show_module module_name module_path module' model =
  let header = tr [] [ td [on_click address <| ActionCommand <|
                             cmd_module_fold_unfold module_path]
                         [text <| if module'.is_folded then "▶" else "▼" ]
                     , td [class "package-module-td"] [text module_name]]
      func (node_name, node) =
        let css_class = case node of
                          NodeGrammar _ -> "grammar-block"
                          NodeRule _ -> "rule-block"
                          NodeTheorem _ _ -> "theorem-block"
            node_path = { module_path = module_path
                        , node_name = node_name
                        }
            dummy_cursor_info = init_cursor_info False [] PaneCursorPackage
            html = show_clickable_block     -- `cursor_info` is not important
              css_class dummy_cursor_info   -- since cursor will be changed
              (cmd_select_node node_path)   -- immediately by `cmd_select_node`
              [text node_name]
         in tr [] [td [] [html]]
      detail = if module'.is_folded || Dict.isEmpty module'.nodes.dict then []
                 else ordered_dict_to_list module'.nodes
                        |> List.map func
                        |> (\list -> [tr [] [ td [] [],
                                              td [] [ table [] list ]]])
   in table [class "package-module-table"] (header :: detail)
