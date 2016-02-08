module Models.Model where

import Dict exposing (Dict)
import Task exposing (Task)

import Tools.KeyboardExtra exposing (Keystroke)
import Tools.SanityCheck exposing (CheckResult, sequentially_check)
import Models.Config exposing (GlobalConfig, init_global_config)
import Models.PkgMod exposing (Package, init_package, check_package)
import Models.Mode exposing (MajorMode, init_major_mode)
import Models.Popup exposing (PopupList, init_popup_list)

-- the entire state of program will be store here
-- has constrain, see `check_model`
type alias Model =
  { global_config : GlobalConfig
  , root_package  : Package
  , root_keymap   : Keymap
  , major_mode    : MajorMode
  , popup_list    : PopupList
  }

-- there is a circular dependency here
-- `Model` --> `Keymap` --> `KeyBinding` ---> `Command` ---> `Model`
--                                       '--> `PreTask` --'
-- so need to define the rest of circular stuff here
type alias Command =  Model -> Model

-- it is a task that need to know current state of model prior to its execution
-- The type of error on a task is forced to be `()`
-- so if we put task that doesn't have error type as `()` it will not compile
-- and we will know that we forget to inject error handler
type alias PreTask = Model -> Task () ()

type KeyBinding
  = KeyBindingCommand String Command
  | KeyBindingPreTask String PreTask
  | KeyBindingPrefix String Keymap    -- similar to prefix key bindings in emacs

type alias Keymap = Dict Keystroke KeyBinding

init_model : Model
init_model =
  { global_config = init_global_config
  , root_package  = init_package
  , root_keymap   = init_keymap
  , major_mode    = init_major_mode
  , popup_list    = init_popup_list
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
