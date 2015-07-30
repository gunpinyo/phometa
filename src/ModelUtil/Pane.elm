module ModelUtil.Pane where

import Model.Pane exposing (Pane(..))

initial_pane : Pane
initial_pane =
  PaneContainer
    { subpanes =
        ( PaneContainer
            { subpanes =
                ( PaneWelcome
                , PaneMiniBuffer
                )
            , is_vertical = True
            , size_ratio = (1, 1)
            , is_resizable = True
            , are_minimizable = (True, True)
            }
        , PaneMiniBuffer
        )
    , is_vertical = False
    , size_ratio = (1, 1)
    , is_resizable = True
    , are_minimizable = (True, True)
    }
