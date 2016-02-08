module ModelUtils.Package where

import Maybe exposing (andThen)
import Dict exposing (Dict)
import Debug exposing (crash)

import Tools.Verification exposing (VerificationResult, sequentially_verify)
import Models.Module exposing (ModuleName, ModulePath, ModuleBase)
import Models.Syntax exposing (Syntax)
import Models.Semantics exposing (Semantics)
import Models.Theory exposing (Theory)
import Models.Package exposing (Package, PackageDatatype(..))
import Models.Model exposing (Model)
import Models.EtcAlias exposing(VerifyModel)
import ModelUtils.Syntax exposing (verify_syntax)

initial_package : Package
initial_package =
  { syntaxes = Dict.empty
  , semanticses = Dict.empty
  , theories = Dict.empty
  , packages = Dict.empty
  , is_folded = False
  }

verify_package : Package -> VerifyModel
verify_package package model =
  sequentially_verify
    <| List.map
         (\subpackage_datatype ->
            let subpackage = get_package_from_datatype subpackage_datatype
             in \() -> verify_package subpackage model
         )
         (Dict.values package.packages)
    ++ List.map
         (\syntax -> (\() -> verify_syntax syntax model))
         (Dict.values package.syntaxes)
    -- TODO: enable this when finish implement semantics and theory
    --++ List.map
    --     (\semantics -> (\() -> verify_semantics model semantics))
    --     (Dict.values package.semanticses)
    --++ List.map
    --     (\theory -> (\() -> verify_theory model theory))

-- return package (if any) that address on the given path on given `package`
get_package : ModulePath -> Package -> Maybe Package
get_package package_path package =
  case package_path of
    [] -> Just package
    package_name :: package_path' ->
      get_subpackage package_name package `andThen` (get_package package_path')

-- return the given `package` with the addressed-by-path package replaced
-- by `value` (or added if this package doesn't exist before)
set_package : Package -> ModulePath -> Package -> Package
set_package value_package package_path package =
  case package_path of
    [] -> value_package
    package_name :: package_path' ->
      let subpackage = Maybe.withDefault initial_package
                         <| get_subpackage package_name package
          subpackage' = set_package value_package package_path' subpackage
          subpackage_datatype' = PackageConstruct subpackage'
       in { package |
            packages =
              Dict.insert package_name subpackage_datatype' package.packages
          }

get_syntax : ModulePath -> Package -> Maybe Syntax
get_syntax =
  get_module .syntaxes

set_syntax : Syntax -> Package -> Package
set_syntax =
  set_module .syntaxes
    <| (\module_dict package -> { package | syntaxes = module_dict })

get_semantics : ModulePath -> Package -> Maybe Semantics
get_semantics =
  get_module .semanticses

set_semantics : Semantics -> Package -> Package
set_semantics =
  set_module .semanticses
    <| (\module_dict package -> { package | semanticses = module_dict })

get_theory : ModulePath -> Package -> Maybe Theory
get_theory =
  get_module .theories

set_theory : Theory -> Package -> Package
set_theory =
  set_module .theories
    <| (\module_dict package -> { package | theories = module_dict })

-----------------------
-- private functions --
-----------------------

get_package_from_datatype : PackageDatatype -> Package
get_package_from_datatype package_datatype =
  case package_datatype of
    PackageConstruct package -> package

get_subpackage : ModuleName -> Package -> Maybe Package
get_subpackage module_name package =
  let package_datatype_maybe = Dict.get module_name package.packages
   in Maybe.map get_package_from_datatype package_datatype_maybe

get_module : (Package -> Dict ModuleName (ModuleBase a))
               -> ModulePath -> Package -> Maybe (ModuleBase a)
get_module accessor_func module_path package =
  case module_path of
    [] -> Nothing
    module_name :: package_path ->
      (get_package package_path package)
        `andThen` (\module_parent_package ->
          Dict.get module_name <| accessor_func module_parent_package)

-- no need to know `module_path` as it is one of fields in `ModuleBase`
set_module : (Package -> Dict ModuleName (ModuleBase a))
               -> (Dict ModuleName (ModuleBase a) -> Package -> Package)
               -> ModuleBase a -> Package -> Package
set_module getter_func setter_func value_module package =
  case value_module.module_path of
    -- we are safe not to implement empty list case
    -- since ModuleBase.module_path has constrain to exist in `root_package`
    -- and in order to exist it must not be empty path because that is for
    -- root_package itself which is not module
    module_name :: package_path ->
      let module_parent_package = Maybe.withDefault initial_package
                                    <| get_package package_path package
          module_dict = getter_func module_parent_package
          module_dict' = Dict.insert module_name value_module module_dict
          module_parent_package' =
            setter_func module_dict' module_parent_package
       in set_package module_parent_package' package_path package
    _ -> crash "Impossible to come here"
