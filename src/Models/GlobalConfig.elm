module Models.GlobalConfig where

import Tools.Css exposing
  ( CssColor
  , CssSize
  , CssValue
  )

type alias GlobalConfig
  = { style :
        { view :
            { font_family : CssValue
            , font_size : CssSize
            , foreground_color : CssColor
            }
        , input :
            { cursor_border_color : CssColor
            , hover_border_color : CssColor
            , clickable_border_color : CssColor
            , dragable_border_color : CssColor
            , dropable_border_color : CssColor
            }
        , pane :
            { border : CssValue
            , padding : CssSize
            , background_color : CssColor
            }
        , module' :
            { comment_background_color : CssColor
            , dependency_background_color : CssColor
            , show_header_description : Bool
            }
        , repository :
            { syntax_background_color : CssColor
            , semantics_background_color : CssColor
            , theory_background_color : CssColor
            , package_background_color_pair : (CssColor, CssColor)
            }
        , term :
            { background_color_pair : (CssColor, CssColor)
            , variable_background_color : CssColor
            , show_grammar_reference : Bool
            }
        , theory :
            { proof_background_color_pair : (CssColor, CssColor)
            }
        }
    }
