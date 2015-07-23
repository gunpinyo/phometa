module Model.Model where

import Maybe exposing (Maybe)

import Model.Repository exposing (Repository)
import Model.Pane exposing (Pane, ComponentPath)

type alias Model
  = { repository : Repository
    , main_pane : Pane
    , cursor_path : Maybe ComponentPath
    , holding_path : Maybe ComponentPath        -- for drag and drop
    }
