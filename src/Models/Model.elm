module Models.Model where

import Maybe exposing (Maybe)

import Models.Repository exposing (Repository)
import Models.Pane exposing (Pane, ComponentPath)
import Models.MiniBuffer exposing (MiniBuffer)

type alias Model
  = { repository : Repository
    , main_pane : Pane
    , cursor_path : Maybe ComponentPath
    , holding_path : Maybe ComponentPath        -- for drag and drop
    , mini_buffer : MiniBuffer
    }
