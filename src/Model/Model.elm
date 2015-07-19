module Model.Model where

import Model.Repository exposing (Repository)
import Model.Pane exposing (Pane, ComponentPath)

type alias Model
  = { repository : Repository,
      main_pane : Pane,
      cursor_path : ComponentPath
    }
