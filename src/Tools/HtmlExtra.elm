module Tools.HtmlExtra where

import Json.Decode as Json
import Signal exposing (Address)

import Html exposing (Attribute)
import Html.Events exposing (onWithOptions)

on_mouse_event : String -> Address a -> a -> Attribute
on_mouse_event event_str address action =
  onWithOptions
    event_str
    { stopPropagation = True
    , preventDefault = True
    }
    Json.value
    (\_ -> Signal.message address action)

on_click : Address a -> a -> Attribute
on_click = on_mouse_event "click"
