-- TODO: Note: this file currently is just a gateway to test other component
--             need to write this properly

module Main where

import Html exposing (Html)
import StartApp exposing (App, start)

import Model.Action exposing (Action)
import Model.Model exposing (Model)
import ModelUtil.Model exposing (initial_model)
import Update.Update exposing (update)
import View.View exposing (view)

app : App Model Action
app
  = { model = initial_model
    , view = view
    , update = update
    }

main : Signal Html
main
  = start app
