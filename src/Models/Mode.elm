module Models.Mode where

type MajorMode
  = MajorModeDefault
  | MajorModeBrowsePackage
    -- TODO: add more major mode

init_major_mode : MajorMode
init_major_mode = MajorModeDefault
