module Models.Model where

import Maybe exposing (Maybe)

import Models.ComponentPath exposing (ComponentPath)
import Models.Repository exposing (Repository)
import Models.Pane exposing (Pane)
import Models.KeyBinding exposing (KeyBinding)
import Models.MiniBuffer exposing (MiniBuffer)

type alias Model
  = { repository : Repository
    , main_pane : Pane
    , cursor_path_maybe : Maybe ComponentPath
    , hovered_path_maybe : Maybe ComponentPath
    , dragged_path_maybe : Maybe ComponentPath        -- for drag and drop
    , key_binding : KeyBinding
    , mini_buffer : MiniBuffer
    }
