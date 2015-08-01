module Tools.Flex where

import Maybe exposing (Maybe(..))

import Html exposing (Html, Attribute, div)
import Html.Attributes exposing (style)

import Tools.Css exposing (Css)

flex_div : Css -> List Attribute -> List Html -> Html
flex_div css attribute_list =
  let css' =
        [ ("flex", "1 1 auto")
        , ("display", "flex")
        ] ++ css
   in div (style css' :: attribute_list)

flex_css : Css -> Html -> Html
flex_css css html =
  flex_div css [] [html]

flex_grow : Int -> Html -> Html
flex_grow factor html =
  let css =
        [ ("flex-grow", toString factor)
        , ("display", "flex")
        , ("flex-basis", "0px")
        ]
   in flex_div css [] [html]

fullbleed : Html -> Html
fullbleed html =
  let css =
        [ ("width", "100vw")
        , ("height", "100vh")
        , ("display", "flex")
        ]
   in flex_div css [] [html]
