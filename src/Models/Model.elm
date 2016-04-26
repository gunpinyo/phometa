module Models.Model where

import Dict exposing (Dict)
import Task exposing (Task)

import Focus exposing (Focus)

import Tools.KeyboardExtra exposing (RawKeystroke, Keystroke)
import Tools.SanityCheck exposing (CheckResult, sequentially_check)
import Models.Config exposing (Config)
import Models.Cursor exposing (IntCursorPath, PaneCursor,
                               CursorInfo, CursorTree)
import Models.RepoModel exposing (VarName, Package, ModulePath, NodePath,
                                  GrammarName, Grammar, RootTerm)
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

type alias Counter = Int

type alias AutoComplete =
  { raw_filters : String
  , counter : Counter
  , is_searching : Bool
  }


-- Mode ------------------------------------------------------------------------

type Mode
  = ModeNothing
  | ModeMenu
  | ModePackagePane
  | ModeRootTerm RecordModeRootTerm
  | ModeTheorem RecordModeTheorem
  -- TODO: add more mode

-- ModeRootTerm ----------------------------------------------------------------

type alias RecordModeRootTerm =
  CursorTree
    { module_path            : ModulePath
    , root_term_focus        : Focus Model RootTerm
    , micro_mode             : MicroModeRootTerm
    , editability            : EditabilityRootTerm
    , can_create_fresh_vars  : Bool
    , get_existing_variables : Model -> Dict VarName GrammarName
    , on_quit_callback       : Command -- what to do after exit root_term mode
    }

type MicroModeRootTerm
  = MicroModeRootTermSetGrammar AutoComplete
  | MicroModeRootTermTodo AutoComplete
  | MicroModeRootTermNavigate

type EditabilityRootTerm
  = EditabilityRootTermReadOnly
  | EditabilityRootTermUpToTerm
  | EditabilityRootTermUpToGrammar

-- ModeTheorem -----------------------------------------------------------------

type alias RecordModeTheorem =
  CursorTree
    { node_path        : NodePath
    , micro_mode       : MicroModeTheorem
    }

type MicroModeTheorem
  = MicroModeTheoremNavigate
  | MicroModeTheoremSelectRule AutoComplete
  | MicroModeTheoremSelectLemma AutoComplete
