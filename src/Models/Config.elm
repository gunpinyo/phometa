-- All things that users can configure goes here
module Models.Config where

type alias Config =
  { package_panes_ratio             : Int
  , grids_panes_ratio               : Int
  , keymap_panes_ratio              : Int
  , show_package_pane               : Bool
  , show_keymap_pane                : Bool
  , spacial_key_prefix              : String
  }

init_config : Config
init_config =
  { package_panes_ratio             = 2
  , grids_panes_ratio               = 6
  , keymap_panes_ratio              = 2
  , show_package_pane               = True
  , show_keymap_pane                = True
  , spacial_key_prefix              = "Alt-"
  }
