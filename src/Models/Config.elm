-- All things that users can configure goes here
module Models.Config where

type alias Config =
  { side_grid_panes_ratio     : (Int, Int)
  -- , keymap_pane_max_ratio     : (Int, Int)
  , is_package_pane_hided     : Bool
  , is_keymap_pane_hided      : Bool
  }

init_config : Config
init_config =
  { side_grid_panes_ratio     = (1, 3)
  -- , keymap_pane_max_ratio     : (1, 1)
  , is_package_pane_hided     = False
  , is_keymap_pane_hided      = False
  }
