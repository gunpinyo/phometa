module Views.Package where

import Dict

import Html exposing (Html, div, text, table, tr, td)
import Html.Attributes exposing (class, classList, style)

import Tools.Flex exposing (flex_div)
import Tools.OrderedDict exposing (ordered_dict_to_list)
import Models.Cursor exposing (PaneCursor(..))
import Models.RepoModel exposing (PackageName, Package, PackageElem(..),
                                  ModuleName, Module)
import Models.ViewState exposing (View)

show_package_pane : View
show_package_pane model =
  flex_div []
    [classList [("pane", True),
                ("pane-on-cursor", model.pane_cursor == PaneCursorPackage)]]
    [show_package "Root Package" model.root_package model]

show_package : PackageName -> Package -> View
show_package package_name package model =
  let header = tr [] [ td [] [text <| if package.is_folded then "▶" else "▼" ]
                     , td [class "package-package-td"] [text package_name]]
      func (name, package_elem) =
        case package_elem of
          PackageElemPkg package' -> show_package name package' model
          PackageElemMod module'  -> show_module name module' model
      detail = if package.is_folded || Dict.isEmpty package.dict then [] else
                 [td [] [], td [] <| List.map func <| Dict.toList package.dict]
   in table [class "package-package-table"] (header :: detail)

show_module : ModuleName -> Module -> View
show_module module_name module' model =
  let header = tr [] [ td [] [text <| if module'.is_folded then "▶" else "▼" ]
                     , td [class "package-module-td"] [text module_name]]
      func (node_name, node) =
        tr [] [td [] [ text "⇁"],
               td [] [ div [class "package-node-text"]
                           [text node_name]]]
      detail = if module'.is_folded || Dict.isEmpty module'.nodes.dict then []
                 else ordered_dict_to_list module'.nodes
                        |> List.map func
                        |> (\list -> [tr [] [ td [] [],
                                              td [] [ table [] list ]]])
   in table [class "package-module-table"] (header :: detail)
