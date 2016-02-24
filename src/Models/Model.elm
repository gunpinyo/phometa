module Models.Model where

import Dict exposing (Dict)
import Task exposing (Task)

import Tools.KeyboardExtra exposing (RawKeystroke, Keystroke)
import Tools.SanityCheck exposing (CheckResult, sequentially_check)
import Models.Config exposing (Config)
import Models.Cursor exposing (PaneCursor)
import Models.RepoModel exposing (Package,
                                  GrammarName, Grammar, RootTerm, TermPath)
import Models.Grid exposing (Grids)
import Models.Message exposing (MessageList)
import Models.Environment exposing (Environment)

-- the entire state of program will be store here
-- has constrain, see `check_model`
type alias Model =
  { config       : Config
  , root_package : Package
  , root_keymap  : Keymap
  , grids        : Grids
  , pane_cursor  : PaneCursor
  , mode         : Mode
  , message_list : MessageList
  , environment  : Environment
  }

-- Keymap ----------------------------------------------------------------------

-- there is a circular dependency here
-- `Model` --> `Keymap` --> `KeyBinding` ---> `Command` ---> `Model`
-- so need to define the rest of circular stuff here
type alias Command =  Model -> Model

type KeyBinding
  = KbCmd Command
  | KbPrefix Keymap    -- similar to prefix key bindings in emacs

type alias KeyDescription = String

type alias Keymap = Dict Keystroke ((RawKeystroke, KeyDescription), KeyBinding)

-- Mode ------------------------------------------------------------------------

type Mode
  = ModeNothing
  | ModePackagePane
  | ModeRootTerm RecordModeRootTerm
  | ModeStrChoices RecordModeStrChoice
  -- TODO: add more  mode

type alias RecordModeRootTerm =
  { get_root_term : (Model -> RootTerm)
   , set_root_term : (RootTerm -> Model -> Model)
   , get_grammar   : (Model -> Dict GrammarName Grammar)
   , term_path     : TermPath
   , previous_mode : Mode
   }

type alias RecordModeStrChoice =
  { choices       : List String
  , prefix_info   : String
  , suffix_info   : String
  , callback      : (String -> Model -> Model)
  , counter       : Int
  , previous_mode : Mode
  }
