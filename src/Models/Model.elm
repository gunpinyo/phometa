module Models.Model where

import Models.GlobalConfig exposing (GlobalConfig)
import Models.Package exposing (Package)
import Models.InputAction exposing (ComponentPath)
import Models.Pane exposing (Pane)
import Models.KeyBinding exposing (KeyBinding)
import Models.MiniBuffer exposing (MiniBuffer)

type alias Model
  = { global_config : GlobalConfig
    , root_package : Package
    , root_pane : Pane
    , cursor_path_maybe : Maybe ComponentPath
    , hovered_path_maybe : Maybe ComponentPath
    , dragged_path_maybe : Maybe ComponentPath        -- for drag and drop
    , key_binding : KeyBinding
    , mini_buffer : MiniBuffer
    }
