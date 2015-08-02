module ModelUtils.GlobalConfig where

import Models.GlobalConfig exposing (GlobalConfig)

initial_global_config : GlobalConfig
initial_global_config =
  { style =
      { view =
          { css_style =
              [ ("font-family", "monospace")
              , ("font-size", "100%")
              , ("color", "DarkBlue")
              , ("background-color", "#E9C062")
              ]
          }
      , interactive =
          { cursor_css_style =
              [ ("border-color", "DarkGreen")
              , ("border-width", "5px")
              ]
          , hover_css_style =
              [ ("border-color", "Lime")
              , ("border-width", "5px")
              ]
          , editable_css_style = [("border-color", "#8800FF")]
          , dragable_css_style = [("border-color", "#FFFF00")]
          , dropable_css_style = [("border-color", "#FFFF00")]
          }
      , pane =
          { css_style =
              [ ("border-style", "solid")
              , ("border-color", "brown")
              , ("border-width", "2px")
              , ("padding", "2px")
              , ("margin", "2px")
              , ("background-color", "#E9C062")
              , ("overflow", "auto")
              ]
          }
      , module' =
          { comment_bg_color = "#FFDDDD"
          , dependency_bg_color = "#DDFFDD"
          , show_header_description = True
          }
      , repository =
          { syntax_bg_color = "#FF0000"
          , semantics_bg_color = "#00FF00"
          , theory_bg_color = "#0000FF"
          , package_bg_color_pair = ("#CCFFFF", "#FFCCFF")
          }
      , term =
          { bg_color_pair = ("#DDDDDD", "#AAAAAA")
          , variable_bg_color = "#FF2222"
          , show_grammar_reference = True
          }
      , theory =
          { proof_bg_color_pair = ("#DDDDDD", "#AAAAAA")
          }
      }
  }
