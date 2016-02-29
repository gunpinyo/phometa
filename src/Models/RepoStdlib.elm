module Models.RepoStdlib where

import Dict exposing (Dict)

import Focus

import Tools.OrderedDict exposing (ordered_dict_from_list)
import Tools.StripedList exposing (striped_list_introduce)
import Models.Focus exposing (dict_)
import Models.RepoModel exposing (..)
import Models.RepoUtils exposing (..)


init_package_with_stdlib : Package
init_package_with_stdlib =
  Focus.update
    dict_
    (Dict.insert "Standard Library" (PackageElemPkg stdlib_package))
    init_package

stdlib_package : Package
stdlib_package =
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
          ("theorem-1", NodeTheorem init_theorem),
          -- TODO: remove this from stdlib
          ("theorem-2", NodeTheorem init_theorem)
        ],
        is_folded = False
      })
    ]
  , is_folded = False }
