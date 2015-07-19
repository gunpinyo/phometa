module Model.Pane where

type alias ComponentPath
  = List Int

type Pane
  = PaneVertical Int Pane Pane   -- Int is width (in percentage)
  | PaneHorizontal Int Pane Pane -- Int is height (in percentage)
  | PaneNew                      -- For new Pane, will be convert later
  | PaneSyntax                 -- TODO: give arguements and explaination
  | PaneSemantics              -- TODO: give arguements and explaination
  | PaneTheory                 -- TODO: give arguements and explaination
  | PaneRepository             -- TODO: give arguements and explaination
  | PaneKeyBinding             -- TODO: give arguements and explaination
  | PaneInteractive            -- TODO: give arguements and explaination
