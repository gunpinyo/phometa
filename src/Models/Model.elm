module Models.Model where

import Dict exposing (Dict)
import Task exposing (Task)

import Focus exposing (Focus)

import Tools.KeyboardExtra exposing (RawKeystroke, Keystroke)
import Tools.SanityCheck exposing (CheckResult, sequentially_check)
import Models.Config exposing (Config)
import Models.Cursor exposing (IntCursorPath, PaneCursor, CursorInfo)
import Models.RepoModel exposing (Package, ModulePath,
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

type alias RingChoiceCounter = Int

-- Mode ------------------------------------------------------------------------

type Mode
  = ModeNothing
  | ModePackagePane
  | ModeRootTerm RecordModeRootTerm
  -- | ModeStrChoices RecordModeStrChoice
  -- TODO: add more  mode

type alias RecordModeRootTerm =
  { module_path           : ModulePath
  , root_term_focus       : Focus Model RootTerm
  , root_term_cursor_info : CursorInfo    -- path from model to root_term
  , sub_term_cursor_path  : IntCursorPath -- path from root_term to current term
  , micro_mode            : MicroModeRootTerm
  , is_editable           : Bool
  }

type MicroModeRootTerm
  = MicroModeRootTermSetGrammar RingChoiceCounter
  | MicroModeRootTermSetGrammarWithString
  | MicroModeRootTermTodo RingChoiceCounter
  | MicroModeRootTermTodoWithString
  | MicroModeRootTermNavigate

-- type alias RecordModeStrChoice =
--   { choices        : List String
--   , to_description : (String -> String)
--   , callback       : (String -> Model -> Model)
--   , counter        : Int
--   , previous_mode  : Mode
--   }
