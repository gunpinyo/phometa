module ModelUtil.Model where

import Maybe exposing (Maybe(..))

import Model.Model exposing (Model)
import ModelUtil.Repository exposing (initial_repository)
import ModelUtil.Pane exposing (initial_pane)

initial_model : Model
initial_model
  = { repository = initial_repository
    , main_pane = initial_pane
    , cursor_path = Nothing
    , holding_path = Nothing
    }
