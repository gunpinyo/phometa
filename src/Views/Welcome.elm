module Views.Welcome where

import Html exposing (text)

import Tools.Flex exposing (flex_div)
import Models.EtcAlias exposing (View)

show_welcome : View
show_welcome address model =
  text "Welcome to phometa!!!"
  -- TODO: finish this
