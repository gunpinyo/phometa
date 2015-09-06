module Models.Module where

type alias ModuleName = String

type alias ModulePath = List ModuleName

-- constrain:
--   - `name` can't be empty string
--   - this will be put inside array
--       `name` must be unique for each `ModuleElement` inside array
type alias ModuleElementBase a =
  { a |
    name : String
  , comment : String
  }

-- constrain:
--   - everything that has type `ModulePath` must exists in root package
--       (including extended fields that have this type as well)
type alias ModuleBase a
  = { a |
      module_path : ModulePath
    , has_locked : Bool
    , comment : String
    }

type ModuleType
  = ModuleTypeSyntax
  | ModuleTypeSemantics
  | ModuleTypeTheory
  -- Although, theoretically package is not a module
  -- But most of time, package share common functionality with other package
  -- e.g. adding a package procedure is similar to adding other module
  -- so it worth to add it here
  | ModuleTypePackage
