module Models.ModelUtils where

import Dict exposing (Dict)

import Tools.KeyboardExtra exposing (RawKeystroke, Keystroke)
import Tools.SanityCheck exposing (CheckResult, sequentially_check)
import Models.Config exposing (init_config)
import Models.Cursor exposing (init_pane_cursor)
import Models.RepoUtils exposing (check_package)
import Models.RepoStdlib exposing (init_package_with_stdlib)
import Models.Grid exposing (init_grids)
import Models.Message exposing (init_message_list)
import Models.Environment exposing (init_environment)
import Models.Model exposing (..)


init_model : Model
init_model =
  { config        = init_config
  , root_package  = init_package_with_stdlib
  , root_keymap   = init_keymap
  , grids         = init_grids
  , pane_cursor   = init_pane_cursor
  , mode          = init_mode
  , message_list  = init_message_list
  , environment   = init_environment
  }

-- we can set initial keymap to be empty since immediately after
-- the first action triggered, the actual default keymap will be used instead
init_keymap : Keymap
init_keymap = Dict.empty

check_model : Model -> CheckResult
check_model model =
  sequentially_check [
    \ () -> check_package model.root_package ]
    -- TODO: finish this

init_mode : Mode
init_mode = ModeNothing