module Model.Pane where

type Pane
  = PaneVertical Int Pane Pane   -- Int is height (in pixel)
  | PaneHorizontal Int Pane Pane -- Int is width (in pixel)
  | PaneNew                      -- For new Pane, will be convert later
  | PaneSyntax                 -- TODO: give arguements and explaination
  | PaneSemantics              -- TODO: give arguements and explaination
  | PaneTheory                 -- TODO: give arguements and explaination
  | PaneRepository             -- TODO: give arguements and explaination
  | PaneKeyBinding             -- TODO: give arguements and explaination
  | PaneInteractive            -- TODO: give arguements and explaination
