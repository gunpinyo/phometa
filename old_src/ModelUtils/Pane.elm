module ModelUtils.Pane where

import Models.Pane exposing (Pane(..))

initial_pane : Pane
-- TODO: set this to the correct config one
initial_pane =
  PaneContainer
    { subpanes =
        ( PaneContainer
            { subpanes =
                ( PaneContainer
                    { subpanes =
                        ( PaneWelcome
                        , PaneMiniBuffer
                        )
                    , is_vertical = True
                    , size_ratio = (1, 1)
                    , is_resizable = True
                    }
                , PaneWelcome
                )
            , is_vertical = False
            , size_ratio = (3, 7)
            , is_resizable = True
            }
        , PaneMiniBuffer
        )
    , is_vertical = True
    , size_ratio = (1, -1)
    , is_resizable = True
    }
