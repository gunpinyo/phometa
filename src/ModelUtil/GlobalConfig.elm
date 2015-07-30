module ModelUtil.GlobalConfig where

import Model.GlobalConfig exposing (GlobalConfig)

initial_global_config : GlobalConfig
initial_global_config =
  { style =
      { view =
          { font_family = "monospace"
          , font_size = "100%"
          , foreground_color = "blue"
          }
      , input =
          { cursor_border_color = "#FF8800"
          , hover_border_color = "#0088FF"
          , clickable_border_color = "#8800FF"
          , dragable_border_color = "#FFFF00"
          , dropable_border_color = "#FFFF00"
          }
      , pane =
          { border = "1px solid brown"
          , padding = "1px"
          , background_color = "#E9C062"
          }
      , module' =
          { comment_background_color = "#FFDDDD"
          , dependency_background_color = "#DDFFDD"
          , show_header_description = True
          }
      , repository =
          { syntax_background_color = "#FF0000"
          , semantics_background_color = "#00FF00"
          , theory_background_color = "#0000FF"
          , package_background_color_pair = ("#CCFFFF", "#FFCCFF")
          }
      , term =
          { background_color_pair = ("#DDDDDD", "#AAAAAA")
          , variable_background_color = "#FF2222"
          , show_grammar_reference = True
          }
      , theory =
          { proof_background_color_pair = ("#DDDDDD", "#AAAAAA")
          }
      }
  }
