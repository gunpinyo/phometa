module ModelUtils.Model where

import Maybe exposing (Maybe(..))

import Models.Model exposing (Model)
import ModelUtils.Repository exposing (initial_repository)
import ModelUtils.Pane exposing (initial_pane)
import ModelUtils.MiniBuffer exposing (initial_mini_buffer)

initial_model : Model
initial_model =
  { repository = initial_repository
  , main_pane = initial_pane
  , cursor_path = Nothing
  , holding_path = Nothing
  , mini_buffer = initial_mini_buffer
  }
