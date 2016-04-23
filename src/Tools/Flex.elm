module Tools.Flex where

import Html exposing (Html, Attribute, div)
import Html.Attributes exposing (style)

import Tools.CssExtra exposing (CssStyle)

flex_div : CssStyle -> List Attribute -> List Html -> Html
flex_div css_style attributes htmls =
  let css_style' =
        [ ("-webkit-box-flex", "1")        -- OLD - iOS 6-, Safari 3.1-6
        , ("-moz-box-flex", "1")           -- OLD - Firefox 19-
        , ("-webkit-flex", "1")            -- Chrome
        , ("-ms-flex", "1")                -- IE 10
        , ("flex", "1")                    -- NEW Spec - Opera 12.1, Firefox 20+
        , ("display", "-webkit-box")       -- OLD - iOS 6-, Safari 3.1-6
        , ("display", "-moz-box")          -- OLD - Firefox 19-
        , ("display", "-ms-flexbox")       -- TWEENER - IE 10
        , ("display", "-webkit-flex")      -- NEW - Chrome
        , ("display", "flex")              -- NEW Spec - Opera 12.1, Firefox 20+
        , ("overflow", "auto")
        ] ++ css_style
   in div (style css_style' :: attributes) htmls

flex_grow : Int -> Html -> Html
flex_grow factor htmls =
  let css_style =
        [ ("flex-grow", toString factor)
        , ("flex-basis", "0px")
        ]
   in flex_div css_style [] [htmls]

flex_inline : CssStyle -> List Attribute -> List Html -> Html
flex_inline css_style attributes htmls =
  flex_div (("flex-direction", "row") :: css_style) attributes htmls

flex_split : String -> CssStyle -> List Attribute -> List (Int, Html) -> Html
flex_split direction css_style attributes grow_html_list =
  let css_style' = [("flex-direction"  , direction),
                    ("justify-content" , "center"),
                    ("align-items"     , "stretch")] ++ css_style
      grow_html_list' = List.map (uncurry flex_grow) grow_html_list
   in flex_div css_style' attributes grow_html_list'

fullbleed : Html -> Html
fullbleed html =
  let css_style =
        [ ("width", "100vw")
        , ("height", "100vh")
        ]
   in flex_div css_style [] [html]
