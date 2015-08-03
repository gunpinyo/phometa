module Tools.HtmlExtra where

import Json.Decode as Json
import Signal exposing (Address)

import Html exposing (Html, Attribute, node)
import Html.Attributes exposing (rel, href)
import Html.Events exposing (onWithOptions)

get_css_link_node : String -> Html
get_css_link_node css_location =
  node "link" [rel "stylesheet", href css_location] []

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

on_mouse_enter : Address a -> a -> Attribute
on_mouse_enter = on_mouse_event "mouseover"

on_mouse_leave : Address a -> a -> Attribute
on_mouse_leave = on_mouse_event "mouseleave"
