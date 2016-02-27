module Tools.Flex where

import Html exposing (Html, Attribute, div)
import Html.Attributes exposing (style)

import Tools.CssExtra exposing (CssStyle)

flex_div : CssStyle -> List Attribute -> List Html -> Html
flex_div css_style attributes =
  let css_style' =
        [ ("flex", "1 1 auto")
        , ("display", "flex")
        ] ++ css_style
   in div (style css_style' :: attributes)

flex_grow : Int -> Html -> Html
flex_grow factor sub_html =
  let css_style =
        [ ("flex-grow", toString factor)
        , ("display", "flex")
        , ("flex-basis", "0px")
        ]
   in flex_div css_style [] [sub_html]

flex_split : String -> CssStyle -> List Attribute -> List (Int, Html) -> Html
flex_split direction css_style attributes grow_html_list =
  let css_style' = [("flex-direction"  , direction),
                    ("justify-content" , "center"),
                    ("align-items"     , "stretch")] ++ css_style
      grow_html_list' = List.map (uncurry flex_grow) grow_html_list
   in flex_div css_style' attributes grow_html_list'

fullbleed : Html -> Html
fullbleed sub_html =
  let css_style =
        [ ("width", "100vw")
        , ("height", "100vh")
        , ("display", "flex")
        ]
   in flex_div css_style [] [sub_html]
