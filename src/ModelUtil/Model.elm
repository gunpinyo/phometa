module ModelUtil.Model where

import Maybe exposing (Maybe(..))

import Model.Model exposing (Model)
import ModelUtil.Repository exposing (initial_repository)
import ModelUtil.Pane exposing (initial_pane)
import ModelUtil.MiniBuffer exposing (initial_mini_buffer)

initial_model : Model
initial_model =
  { repository = initial_repository
  , main_pane = initial_pane
  , cursor_path = Nothing
  , holding_path = Nothing
  , mini_buffer = initial_mini_buffer
  }
