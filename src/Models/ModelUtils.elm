module Models.ModelUtils where

import Dict exposing (Dict)

import Focus exposing (Focus, (=>))

import Tools.KeyboardExtra exposing (RawKeystroke, Keystroke)
import Tools.SanityCheck exposing (CheckResult, sequentially_check)
import Models.Focus exposing (mode_, unicode_state_)
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

init_auto_complete : AutoComplete
init_auto_complete =
  { filters       = ""
  , counter       = 0
  , unicode_state = Nothing
  }

focus_auto_complete_unicode : Focus AutoComplete { filters : String
                                                 , counter : Counter}
focus_auto_complete_unicode =
  let getter maybe_record = case maybe_record of
        Nothing -> { filters = ""
                   , counter = 0}
        Just record -> record
      updater = Maybe.map
   in unicode_state_ => Focus.create getter updater


init_mode : Mode
init_mode = ModeNothing

focus_record_mode_root_term : Focus Model RecordModeRootTerm
focus_record_mode_root_term =
  (mode_ => (Focus.create
     (\mode -> case mode of
        ModeRootTerm record -> record
        _                   ->
          Debug.crash "from Models.ModelUtils.focus_record_mode_root_term")
     (\update_func mode -> case mode of
        ModeRootTerm record -> ModeRootTerm <| update_func record
        other               -> other)))

focus_record_mode_theorem : Focus Model RecordModeTheorem
focus_record_mode_theorem =
  (mode_ => (Focus.create
     (\mode -> case mode of
        ModeTheorem record -> record
        _                  ->
          Debug.crash "from Models.ModelUtils.focus_record_mode_theorem")
     (\update_func mode -> case mode of
        ModeTheorem record -> ModeTheorem <| update_func record
        other               -> other)))
