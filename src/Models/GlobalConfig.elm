module Models.GlobalConfig where

import Tools.Css exposing
  ( CssColor
  , CssSize
  , CssValue
  , CssStyle
  )

type alias GlobalConfig
  = { style :
        { interactive :
            { hover_css_style : CssStyle
            , editable_css_style : CssStyle
            , dragable_css_style : CssStyle
            , dropable_css_style : CssStyle
            }
        , module' :
            { comment_bg_color : CssColor
            , dependency_bg_color : CssColor
            , show_header_description : Bool
            }
        , repository :
            { syntax_bg_color : CssColor
            , semantics_bg_color : CssColor
            , theory_bg_color : CssColor
            , package_bg_color_pair : (CssColor, CssColor)
            }
        , term :
            { bg_color_pair : (CssColor, CssColor)
            , variable_bg_color : CssColor
            , show_grammar_reference : Bool
            }
        , theory :
            { proof_bg_color_pair : (CssColor, CssColor)
            }
        }
    }
