module Model.Pane where

type alias ComponentPath
  = List Int

type Pane
  = PaneHorizontal { left_pane : Pane
                   , right_pane : Pane
                   , width_percentage : Int
                   , is_lock : Bool
                   }
  | PaneVertical { upper_pane : Pane
                 , lower_pane : Pane
                 , height_percentage : Int
                 , is_lock : Bool
                 }
  -- similar to `PaneVertical` but height will depend on `lower_pane` height
  | PaneLowerDynamic { upper_pane : Pane
                     , lower_pane : Pane
                     }
  | PaneNew                    -- For new Pane, will be convert later
  | PaneRepository             -- TODO: give arguements and explaination
  | PaneSyntax                 -- TODO: give arguements and explaination
  | PaneSemantics              -- TODO: give arguements and explaination
  | PaneTheory                 -- TODO: give arguements and explaination
  | PaneGlobalConfig           -- TODO: give arguements and explaination
  | PaneKeyBinding             -- TODO: give arguements and explaination
  | PaneHistoryTree            -- TODO: give arguements and explaination
  | PaneRespond                -- TODO: give arguements and explaination
