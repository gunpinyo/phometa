-- All things that users can configure goes here
module Models.Config where

type alias Config =
  { side_grids_panes_ratio          : (Int, Int)
  -- , keymap_pane_max_ratio        : (Int, Int)
  , show_package_pane               : Bool
  , show_keymap_pane                : Bool
  , globally_show_terms_description : Bool
  }

init_config : Config
init_config =
  { side_grids_panes_ratio          = (1, 3)
  -- , keymap_pane_max_ratio        : (1, 1)
  , show_package_pane               = True
  , show_keymap_pane                = True
  , globally_show_terms_description = True
  }
