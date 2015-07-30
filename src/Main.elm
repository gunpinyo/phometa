module Main where

import Html exposing (Html)
import StartApp exposing (App, start)

import Model.InputAction exposing (InputAction)
import Model.Model exposing (Model)
import ModelUtil.Model exposing (initial_model)
import Update.Update exposing (update)
import View.View exposing (view)

app : App Model InputAction
app = { model = initial_model
      , view = view
      , update = update
      }

main : Signal Html
main = start app
