module Tools.HtmlExtra where

import Json.Decode as Json
import Regex exposing (HowMany(..), replace, regex)
import Signal exposing (Address)
import Graphics.Element exposing (show)

import Html exposing (Html, Attribute, node, div, text)
import Html.Attributes exposing (attribute, style, rel, href)
import Html.Events exposing (onWithOptions)

import_css : String -> Html
import_css css_location =
  node "link" [rel "stylesheet", href css_location] []

-- we shouldn't import javascript since it might effect elm internal
-- use this function only when we need to
-- e.g. some feature that elm doesn't have
import_javascript : String -> Html
import_javascript javascript_location =
  node "script" [attribute "src" javascript_location] []

debug_to_html : a -> Html
debug_to_html x = Html.div [] [Html.fromElement <| show x]

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
