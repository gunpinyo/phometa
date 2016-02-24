module Updates.ModeStrChoices where

import Models.Model exposing (Model, Command)

cmd_push_mode_str_choices : List String -> String -> String
                              -> (String -> Model -> Model) -> Command
cmd_push_mode_str_choices choices prefix suffix callback =
  (\m -> m) -- TODO:
