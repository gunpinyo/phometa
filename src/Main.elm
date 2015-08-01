module Main where

import Html exposing (Html)
import StartApp exposing (App, start)

import Models.InputAction exposing (InputAction)
import Models.Model exposing (Model)
import ModelUtils.Model exposing (initial_model)
import Updates.Update exposing (update)
import Views.View exposing (view)

app : App Model InputAction
app = { model = initial_model
      , view = view
      , update = update
      }

main : Signal Html
main = start app
