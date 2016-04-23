module Tools.CssExtra where

import String
import Debug

import Html exposing (Html, text, div)
import Html.Attributes exposing (class)

type alias CssKey = String
type alias CssValue = String
type alias CssStyle = List (CssKey, CssValue)
type alias CssClass = String

type alias CssColor = String
type alias CssSize = String

type alias CssInlineStr = String
type CssInlineToken
  = CssInlineTokenText String
  | CssInlineTokenOpen CssClass
  | CssInlineTokenClose

css_inline_str_delimiter : String
css_inline_str_delimiter = "⁑"

css_inline_str_embed : CssClass -> CssInlineStr -> CssInlineStr
css_inline_str_embed css_class string =
  css_inline_str_delimiter ++ css_class ++ css_inline_str_delimiter
    ++ string
    ++ css_inline_str_delimiter ++ css_inline_str_delimiter

css_inline_str_tokenise : CssInlineStr -> List CssInlineToken
css_inline_str_tokenise css_inline_str =
  String.split css_inline_str_delimiter css_inline_str
    |> List.indexedMap (\index raw_token ->
         if index % 2 == 0 then
           CssInlineTokenText raw_token
         else if raw_token /= "" then
           CssInlineTokenOpen raw_token
         else
           CssInlineTokenClose)

css_inline_str_compile : CssInlineStr -> List Html
css_inline_str_compile css_inline_str =
  let err_msg = "bug in function Tools.CssExtra.css_inline_str_complie"
      tokens = css_inline_str_tokenise css_inline_str
      -- this function operate with reverse order
      -- this play well with list representation
      func token stack = case (token, stack) of
        (CssInlineTokenText string, htmls :: stack') ->
          ((Html.text string) :: htmls) :: stack'
        (CssInlineTokenOpen css_class, htmls' :: htmls :: stack') ->
          ((div [class css_class] htmls') :: htmls) :: stack'
        (CssInlineTokenClose, _) ->
          [] :: stack
        _ -> Debug.crash err_msg
   in List.foldr func [[]] tokens
        |> List.concat -- we know that that this stage
                       -- stack will have one element which is result
                       -- we want to lift this result to top level
                       -- we can do this by List.concat
