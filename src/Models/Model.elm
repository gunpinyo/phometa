module Models.Model where

import Dict exposing (Dict)
import Task exposing (Task)

import Tools.KeyboardExtra exposing (RawKeystroke, Keystroke)
import Tools.SanityCheck exposing (CheckResult, sequentially_check)
import Models.Config exposing (Config, init_config)
import Models.PkgMod exposing (Package, init_package, check_package)
import Models.Grid exposing (Grid, init_grid)
import Models.Mode exposing (MajorMode, init_major_mode)
import Models.Message exposing (MessageList, init_message_list)
import Models.Environment exposing (Environment, init_environment)

-- the entire state of program will be store here
-- has constrain, see `check_model`
type alias Model =
  { config       : Config
  , root_package : Package
  , root_keymap  : Keymap
  , grid         : Grid
  , major_mode   : MajorMode
  , message_list : MessageList
  , environment  : Environment
  }

-- there is a circular dependency here
-- `Model` --> `Keymap` --> `KeyBinding` ---> `Command` ---> `Model`
-- so need to define the rest of circular stuff here
type alias Command =  Model -> Model

type KeyBinding
  = KeyBindingCommand Command
  | KeyBindingPrefix Keymap    -- similar to prefix key bindings in emacs

type alias KeyBindingName = String

type alias Keymap = Dict Keystroke ((RawKeystroke, KeyBindingName), KeyBinding)

init_model : Model
init_model =
  { config        = init_config
  , root_package  = init_package
  , root_keymap   = init_keymap
  , grid          = init_grid
  , major_mode    = init_major_mode
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
