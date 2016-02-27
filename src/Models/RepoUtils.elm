module Models.RepoUtils where

import Dict exposing (Dict)

import Tools.OrderedDict exposing (ordered_dict_from_list)
import Tools.SanityCheck exposing (CheckResult, valid)
import Tools.StripedList exposing (striped_list_introduce)
import Models.RepoModel exposing (..)
import Models.Model exposing (Model)

init_package : Package
init_package =
  { dict = Dict.fromList [("Standard Library", PackageElemPkg standard_library)]
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

standard_library : Package
standard_library =
  { dict = Dict.fromList [
      ("First Order Logic", PackageElemMod {
        comment = Nothing,
        nodes = ordered_dict_from_list [
          ("Prop", NodeGrammar {
            comment = Nothing,
            is_folded = False,
            var_regex = Just "[A-Z]([1-9][0-9]*|'*)",
            choices = [
              striped_list_introduce [" ⊤ "] [],
              striped_list_introduce [" ⊥ "] [],
              striped_list_introduce ["", ""] ["Atom"],
              striped_list_introduce ["", " ∧ ", ""] ["Prop", "Prop"],
              striped_list_introduce ["", " ∨ ", ""] ["Prop", "Prop"],
              striped_list_introduce [" ¬ ", ""] ["Prop"],
              striped_list_introduce ["", " → ", ""] ["Prop", "Prop"],
              striped_list_introduce ["", " ↔ ", ""] ["Prop", "Prop"]
            ]
          }),
          ("Atom", NodeGrammar {
            comment = Nothing,
            is_folded = False,
            var_regex = Just "[a-z]([1-9][0-9]*|'*)",
            choices = []
          }),
          ("Context", NodeGrammar {
            comment = Nothing,
            is_folded = False,
            var_regex = Just "[ΓΔ]([1-9][0-9]*|'*)",
            choices = [
              striped_list_introduce ["", ""] ["Prop"],
              striped_list_introduce ["", " , ", ""] ["Context", "Prop"]
            ]
          }),
          -- TODO: remove this from stdlib
          ("theorem-1", NodeTheorem {
            comment = Nothing,
            is_folded = False,
            goal = {
              context = init_root_term,
              goal = init_root_term
            },
            proof = ProofTodo
          }),
          -- TODO: remove this from stdlib
          ("theorem-2", NodeTheorem {
            comment = Nothing,
            is_folded = False,
            goal = {
              context = init_root_term,
              goal = init_root_term
            },
            proof = ProofTodo
          })
        ],
        is_folded = False
      })
    ]
  , is_folded = False }
