module Models.Model where

import Dict exposing (Dict)

import Focus exposing (Focus)

import Tools.KeyboardExtra exposing (RawKeystroke, Keystroke)
import Models.Config exposing (Config)
import Models.Cursor exposing (IntCursorPath, PaneCursor,
                               CursorInfo, CursorTree)
import Models.RepoModel exposing (VarName, Package, PackagePath,
                                  ModulePath, NodePath, NodeType,
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
  { filters : String
  , counter : Counter
  , unicode_state : Maybe { filters : String
                          , counter : Counter
                          }
  , need_to_fetch : Bool -- if True then fetch input box with value
  }

-- Mode ------------------------------------------------------------------------

type Mode
  = ModeNothing
  | ModeMenu
  | ModeRepo RecordModeRepo
  | ModeModule RecordModeModule
  | ModeComment RecordModeComment
  | ModeGrammar RecordModeGrammar
  | ModeRootTerm RecordModeRootTerm
  | ModeRule RecordModeRule
  | ModeTheorem RecordModeTheorem

-- ModeRepo --------------------------------------------------------------------

type alias RecordModeRepo =
  { micro_mode               : MicroModeRepo }

type MicroModeRepo
  = MicroModeRepoNavigate
  | MicroModeRepoAddPkgMod AutoComplete PackagePath Bool --Bool,is_adding_module

-- ModeModule ------------------------------------------------------------------

type alias RecordModeModule =
  CursorTree -- but we don't need sub_cursor_path here
    { module_path              : ModulePath
    , micro_mode               : MicroModeModule
    }

type MicroModeModule
  = MicroModeModuleNavigate
  | MicroModeModuleAddNode AutoComplete Int NodeType

-- ModeComment -----------------------------------------------------------------

type alias RecordModeComment =
  CursorTree -- but we don't need sub_cursor_path here
    { node_path              : NodePath
    , micro_mode             : MicroModeComment
    }

type MicroModeComment
  = MicroModeCommentNavigate
  | MicroModeCommentEditing

-- ModeGrammar -----------------------------------------------------------------

type alias RecordModeGrammar =
  CursorTree -- but we don't need sub_cursor_path here
    { node_path              : NodePath
    , micro_mode             : MicroModeGrammar
    }

type MicroModeGrammar
  = MicroModeGrammarNavigate
  | MicroModeGrammarSetMetaVarRegex AutoComplete
  | MicroModeGrammarSetLiteralRegex AutoComplete
  | MicroModeGrammarAddChoice AutoComplete
  | MicroModeGrammarSetChoiceFormat AutoComplete Int Int
  | MicroModeGrammarSetChoiceGrammar AutoComplete Int Int

-- ModeRootTerm ----------------------------------------------------------------

type alias RecordModeRootTerm =
  CursorTree
    { module_path            : ModulePath
    , root_term_focus        : Focus Model RootTerm
    , micro_mode             : MicroModeRootTerm
    , editability            : EditabilityRootTerm
    , is_reducible           : Bool
    , can_create_fresh_vars  : Bool
    , get_existing_variables : Model -> Dict VarName GrammarName
    , on_modify_callback     : Command -- what to do after something change
    , on_quit_callback       : Command -- what to do after exit root_term mode
    }

type MicroModeRootTerm
  = MicroModeRootTermSetGrammar AutoComplete
  | MicroModeRootTermTodo AutoComplete
  | MicroModeRootTermNavigate AutoComplete

type EditabilityRootTerm
  = EditabilityRootTermReadOnly
  | EditabilityRootTermUpToTerm
  | EditabilityRootTermUpToGrammar

-- ModeRule --------------------------------------------------------------------

type alias RecordModeRule =
  CursorTree
    { node_path              : NodePath
    , micro_mode             : MicroModeRule
    }

type MicroModeRule
  = MicroModeRuleNavigate
  | MicroModeRuleSelectCascadeRule AutoComplete Int

-- ModeTheorem -----------------------------------------------------------------

type alias RecordModeTheorem =
  CursorTree
    { node_path              : NodePath
    , micro_mode             : MicroModeTheorem
    }

type MicroModeTheorem
  = MicroModeTheoremNavigate
  | MicroModeTheoremSelectRule AutoComplete
  | MicroModeTheoremSelectLemma AutoComplete
