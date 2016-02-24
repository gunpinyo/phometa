module Models.RepoUtils where

import Dict exposing (Dict)

import Tools.OrderedDict exposing (ordered_dict_from_list)
import Tools.SanityCheck exposing (CheckResult, valid)
import Models.RepoModel exposing (..)
import Models.Model exposing (Model)

-- TODO: reset to real initial
init_package : Package
init_package = {
  dict = Dict.fromList [
    ("module-A", PackageElemMod {
      comment = Nothing,
      nodes = ordered_dict_from_list [],
      is_folded = False
    }),
    ("sub-package", PackageElemPkg {
      dict = Dict.fromList [
        ("module-B", PackageElemMod {
          comment = Nothing,
          nodes = ordered_dict_from_list [
            ("Bool", NodeGrammar {
              comment = Nothing,
              is_folded = False,
              var_regex = Nothing,
              choices = ordered_dict_from_list [
                ("⊤", []),
                ("⊥", [])
              ]
            }),
            ("BinTree", NodeGrammar {
              comment = Nothing,
              is_folded = False,
              var_regex = Nothing,
              choices = ordered_dict_from_list [
                ("leaf", []),
                ((mixfix_hole ++ " ⚻ " ++ mixfix_hole), ["Bintree", "Bintree"])
              ]
            }),
            ("my-tree", NodeDefinition {
              comment = Nothing,
              is_folded = False,
              arguments = [],
              root_term = init_root_term
            })
          ],
          is_folded = False
        })],
      is_folded = False
    }),
    ("sub-package'", PackageElemPkg {
      dict = Dict.fromList [
        ("module-C", PackageElemMod {
          comment = Nothing,
          nodes = ordered_dict_from_list [],
          is_folded = False
        }),
        ("another-sub-package", PackageElemPkg {
          dict = Dict.fromList [
            ("module-D", PackageElemMod {
              comment = Nothing,
              nodes = ordered_dict_from_list [],
              is_folded = False
            })],
          is_folded = False
        })],
      is_folded = False
    })]
  , is_folded = False
  }

check_package : Package -> CheckResult
check_package package = valid -- TODO: implment this

get_package : PackagePath -> Model -> Maybe Package
get_package package_path model =
  get_package' package_path model.root_package

get_package' : PackagePath -> Package -> Maybe Package
get_package' package_path top_package =
  case package_path of
    [] -> Just top_package
    package_name :: package_path' ->
      case Dict.get package_name top_package.dict of
        Just (PackageElemPkg package) -> get_package' package_path' package
        _                             -> Nothing

get_module : ModulePath -> Model -> Maybe Module
get_module module_path model =
  get_package module_path.package_path model
     |> (flip Maybe.andThen) (\package ->
          case Dict.get module_path.module_name package.dict of
            Just (PackageElemMod module') -> Just module'
            _                             -> Nothing)

get_node : NodePath -> Model -> Maybe Node
get_node node_path model =
  get_module node_path.module_path model
     |> (flip Maybe.andThen)
          (\module' -> Dict.get node_path.node_name module'.nodes.dict)

-- when root_term is newly created, its grammar hasn't been defined
root_term_undefined_grammar : GrammarName
root_term_undefined_grammar = ""

init_root_term : RootTerm
init_root_term =
  { grammar = root_term_undefined_grammar
  , term = TermTodo
  }
