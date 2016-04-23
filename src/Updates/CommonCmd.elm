module Updates.CommonCmd where

import Focus

import Models.Focus exposing (mode_, pane_cursor_)
import Models.Cursor exposing (PaneCursor(..))
import Models.Model exposing (Command, Mode(..))

cmd_nothing : Command
cmd_nothing = identity

cmd_reset_mode : Command
cmd_reset_mode model =
  model
    |> Focus.set pane_cursor_ PaneCursorPackage
    |> Focus.set mode_ ModeNothing
