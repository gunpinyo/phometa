module Models.PkgMod where

import Dict exposing (Dict)

import Tools.SanityCheck exposing (CheckResult, valid)
import Models.Node exposing (Node)

type alias ModuleName = PkgModName

type alias PackageName = PkgModName

type alias ModulePath =
  { module_name : ModuleName
  , package_path : PackagePath
  }

type PackagePath
  = PackagePathCur
  | PackagePathPkg PackageName PackagePath

type alias

type PkgMod =
  { is_folded : Bool }                       -- for view ui fold/unfold

type Module =
  PkgMod { nodes : OrderedDict NodeName Node }

type alias Package =
  PkgMod { dict : Dict PkgModName PackageElem }

type PackageElem
  = PackageElemPkg Package
  | PackageElemMod Module

init_package : Package
init_package =
  { is_folded  = True
  , dict       = Dict.empty
  }

check_package : Package -> CheckResult
check_package package = valid -- TODO: implment this
