module Model.GlobalConfig where

import Array exposing (Array)

import Tool.Style exposing
  ( ColorString
  , FontFamilyString
  , FontSizeString
  , PixelInt
  )

type alias GlobalConfig
  = { global :
        { font_family : FontFamilyString
        , font_size : FontSizeString
        , foreground_color : ColorString
        , cursor_border_color : ColorString
        , hover_border_color : ColorString
        , clickable_border_color : ColorString
        , dragable_border_color : ColorString
        , dropable_border_color : ColorString
        }
    , pane :
        { edge_color : ColorString
        , edge_size : PixelInt
        , background_color : ColorString
        }
    , module' :
        { comment_background_color : ColorString
        , dependency_background_color : ColorString
        , show_header_description : Bool
        }
    , repository :
        { syntax_background_color : ColorString
        , semantics_background_color : ColorString
        , theory_background_color : ColorString
        , package_background_color_pair : (ColorString, ColorString)
        }
    , term :
        { background_color_pair : (ColorString, ColorString)
        , variable_background_color : ColorString
        , show_grammar_reference : Bool
        }
    , theory :
        { proof_background_color_pair : (ColorString, ColorString)
        }
    }
