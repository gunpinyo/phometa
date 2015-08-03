module ModelUtils.Model where

import Maybe exposing (Maybe(..))

import Models.Model exposing (ComponentPath, Model)
import ModelUtils.Repository exposing (initial_repository)
import ModelUtils.Pane exposing (initial_pane)
import ModelUtils.MiniBuffer exposing (initial_mini_buffer)

initial_component_path : ComponentPath
initial_component_path = []

initial_model : Model
initial_model =
  { repository = initial_repository
  , main_pane = initial_pane
  , cursor_path_maybe = Just [1, 1]
  , hovered_path_maybe = Just [1, 1]
  , dragged_path_maybe = Nothing
  , mini_buffer = initial_mini_buffer
  }

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
