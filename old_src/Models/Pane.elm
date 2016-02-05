module Models.Pane where

import Models.Module exposing (ModulePath)

type Pane
  = PaneContainer { subpanes : (Pane, Pane)
                  -- True if this is vertical, subpanes are upper/lower panes
                  -- False if this is horizontal, subpanes are left/right panes
                  , is_vertical : Bool
                  -- correspond to flexN of flex-html package
                  -- negative ratio means the subpane size vary on another one
                  --   e.g. (-1, 0) means the first subpane will use remaining
                  --        height/width after the second use all it need.
                  -- if both values are negative
                  --   default html behavior will be used.
                  , size_ratio : (Int, Int)
                  -- True if user can drag handle to resize subpanes
                  , is_resizable : Bool
                  }
  | PaneWelcome                -- For new Pane, will be convert later
  | PaneRootPackage            -- TODO: give explaination
  -- constrain:
  --   `ModulePath` must exist in `RootPackage` with type `Syntax`
  | PaneSyntax ModulePath      -- TODO: give explaination
  -- constrain:
  --   `ModulePath` must exist in `RootPackage` with type `Semantics`
  | PaneSemantics ModulePath   -- TODO: give explaination
  -- constrain:
  --   `ModulePath` must exist in `RootPackage` with type `Theory`
  | PaneTheory ModulePath      -- TODO: give arguements and explaination
  | PaneGlobalConfig           -- TODO: give arguements and explaination
  | PaneCommand                -- TODO: give arguements and explaination
  | PaneHistoryTree            -- TODO: give arguements and explaination
  | PaneMiniBuffer             -- TODO: give arguements and explaination
