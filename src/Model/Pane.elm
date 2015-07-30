module Model.Pane where

type alias ComponentPath
  = List Int

type Pane
  = PaneContainer { subpanes : (Pane, Pane)
                  -- True if this is vertical, subpanes are upper/lower panes
                  -- False if this is horizontal, subpanes are left/right panes
                  , is_vertical : Bool
                  -- correspond to flexN of flex-html package
                  -- constrain:
                  --   - both of element in a pair can't be negative
                  --   - if any of element in a pair is zero
                  --       means its size depend on another subpane
                  --   - both element in a pair can't be zero at the same time
                  , size_ratio : (Int, Int)  -- correspond to flexN
                  , is_resizable : Bool
                  , are_minimizable : (Bool, Bool)
                  }
  | PaneWelcome                -- For new Pane, will be convert later
  | PaneRepository             -- TODO: give arguements and explaination
  | PaneSyntax                 -- TODO: give arguements and explaination
  | PaneSemantics              -- TODO: give arguements and explaination
  | PaneTheory                 -- TODO: give arguements and explaination
  | PaneGlobalConfig           -- TODO: give arguements and explaination
  | PaneCommand                -- TODO: give arguements and explaination
  | PaneHistoryTree            -- TODO: give arguements and explaination
  | PaneMiniBuffer             -- TODO: give arguements and explaination
