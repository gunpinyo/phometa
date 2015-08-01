module Tools.Flex where

import Maybe exposing (Maybe(..))

import Html exposing (Html, Attribute, div)
import Html.Attributes exposing (style)

import Tools.Css exposing (CssKey, CssValue)

flex_div : List (CssKey, CssValue) -> List Attribute -> List Html -> Html
flex_div css_block attribute_list =
  let css_block' =
        [ ("flex", "1 1 auto")
        , ("display", "flex")
        ] ++ css_block
   in div (style css_block' :: attribute_list)

flex_css : List (CssKey, CssValue) -> Html -> Html
flex_css css_block html =
  flex_div css_block [] [html]

flex_grow : Int -> Html -> Html
flex_grow factor html =
  let css_block =
        [ ("flex-grow", toString factor)
        , ("display", "flex")
        , ("flex-basis", "0px")
        ]
   in flex_div css_block [] [html]

fullbleed : Html -> Html
fullbleed html =
  let css_block =
        [ ("width", "100vw")
        , ("height", "100vh")
        , ("display", "flex")
        ]
   in flex_div css_block [] [html]
