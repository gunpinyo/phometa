module Models.GlobalConfig where

import Tools.Css exposing
  ( Css
  , CssColor
  , CssSize
  , CssValue
  )

type alias GlobalConfig
  = { style :
        { view :
            { css : Css
            }
        , interactive :
            { cursor_css : Css
            , hover_css : Css
            , editable_css : Css
            , dragable_css : Css
            , dropable_css : Css
            }
        , pane :
            { css : Css
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
