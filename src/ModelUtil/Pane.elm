module ModelUtil.Pane where

import Model.Pane exposing (Pane(..))

initial_pane : Pane
-- TODO: set this to the correct config one
initial_pane =
  PaneContainer
    { subpanes =
        ( PaneContainer
            { subpanes =
                ( PaneWelcome
                , PaneMiniBuffer
                )
            , is_vertical = True
            , size_ratio = (-1, 2)
            , is_resizable = True
            }
        , PaneContainer
            { subpanes =
                ( PaneMiniBuffer
                , PaneWelcome
                )
            , is_vertical = True
            , size_ratio = (2, 5)
            , is_resizable = True
            }
        )
    , is_vertical = False
    , size_ratio = (1, -1)
    , is_resizable = True
    }
