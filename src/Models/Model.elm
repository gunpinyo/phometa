module Models.Model where

import Maybe exposing (Maybe)

import Models.Repository exposing (Repository)
import Models.Pane exposing (Pane)
import Models.MiniBuffer exposing (MiniBuffer)

type alias ComponentPath
  = List Int

type alias Model
  = { repository : Repository
    , main_pane : Pane
    , cursor_path_maybe : Maybe ComponentPath
    , holding_path_maybe : Maybe ComponentPath        -- for drag and drop
    , mini_buffer : MiniBuffer
    }
