module Updates.CommonCmd where

import Models.Model exposing (Command)

cmd_nothing : Command
cmd_nothing = identity
