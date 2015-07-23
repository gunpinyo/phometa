module View.Pane where

import Signal exposing (Signal, Address)

import Model.Model exposing (Model)
import Model.Pane exposing (Pane(..))
import Update.Action exposing (Action)


show_pane : Address Action -> Model -> Pane -> Html
show_pane address model pane
  = case pane of
      PaneHorizontal record ->
