module Models.Module where

type alias ModuleName = String

type alias ModulePath = List ModuleName

-- constrain:
--   - `name` can't be empty string
--   - this will be put inside array
--       `name` must be unique for each `ModuleElement` inside array
type alias ModuleElement a =
  { a |
    name : String
  , comment : String
  }

-- constrain:
--   - everything that has type `ModulePath` must exists in root package
--       (including extended fields that have this type as well)
type alias Module a
  = { a |
      module_path : ModulePath
    , has_locked : Bool
    , comment : String
    }
