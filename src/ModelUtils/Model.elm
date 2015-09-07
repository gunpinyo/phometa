module ModelUtils.Model where

import Models.InputAction exposing (ComponentPath)
import Models.Model exposing (Model)
import Models.EtcAlias exposing(VerifyModel)
import ModelUtils.GlobalConfig exposing (initial_global_config)
import ModelUtils.Package exposing (initial_package, verify_package)
import ModelUtils.Pane exposing (initial_pane)
import ModelUtils.KeyBinding exposing (initial_key_binding)
import ModelUtils.MiniBuffer exposing (initial_mini_buffer)

initial_model : Model
initial_model =
  { global_config = initial_global_config
  , root_package = initial_package
  , root_pane = initial_pane
  , cursor_path_maybe = Just [1, 1]
  , hovered_path_maybe = Just [1, 1]
  , dragged_path_maybe = Nothing
  , key_binding = initial_key_binding
  , mini_buffer = initial_mini_buffer
  }

verify_model : VerifyModel
verify_model model =
  verify_package model.root_package model

is_at_cursor_path : Model -> ComponentPath -> Bool
is_at_cursor_path model component_path =
  case model.cursor_path_maybe of
    Just cursor_path -> cursor_path == component_path
    Nothing -> False

is_at_hovered_path : Model -> ComponentPath -> Bool
is_at_hovered_path model component_path =
  case model.hovered_path_maybe of
    Just hovered_path -> hovered_path == component_path
    Nothing -> False
