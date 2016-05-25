module Tools.HtmlExtra where

import Json.Decode as Json
import Signal exposing (Address)
import Graphics.Element exposing (show)

import Html exposing (Html, Attribute, node, div, text)
import Html.Attributes exposing (attribute, style, rel, href, type')
import Html.Events exposing (onWithOptions, targetValue)

import_css : String -> Html
import_css css_location =
  node "link" [rel "stylesheet", href css_location] []

-- we shouldn't import javascript since it might effect elm internal
-- use this function only when we need to
-- e.g. some feature that elm doesn't have
import_javascript : String -> Html
import_javascript javascript_location =
  node "script" [attribute "src" javascript_location] []

import_icon : Html
import_icon =
  node "link" [rel "shortcut icon", type' "image/png", href "/logo.png"][]

custom_script : String -> String -> Html
custom_script script_type content =
  node "script" [ type' script_type ]
                [ text content ]

debug_to_html : a -> Html
debug_to_html x = Html.div [] [Html.fromElement <| show x]

on_custom_event : String -> Address a -> a -> Attribute
on_custom_event event_str address action =
  onWithOptions
    event_str
    { stopPropagation = True
    , preventDefault = True
    }
    Json.value
    (\_ -> Signal.message address action)

on_typing_to_input_field : Address a -> (String -> a) -> Attribute
on_typing_to_input_field address string_to_action =
  onWithOptions
    "input"
    { stopPropagation = True
    , preventDefault = True
    }
    targetValue
    (\string -> Signal.message address (string_to_action string))

on_blur : Address a -> a -> Attribute
on_blur = on_custom_event "blur"


on_click : Address a -> a -> Attribute
on_click = on_custom_event "click"

on_mouse_over : Address a -> a -> Attribute
on_mouse_over = on_custom_event "mouseover"

on_mouse_leave : Address a -> a -> Attribute
on_mouse_leave = on_custom_event "mouseleave"
