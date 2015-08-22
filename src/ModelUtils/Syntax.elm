module ModelUtils.Syntax where

import Array

import Models.Syntax exposing (Syntax)

initial_syntax : Syntax
initial_syntax =
  ModuleSyntax
    { grammars = Array.empty
    , dependent_syntaxes = Array.empty
    , has_locked = False
    , comment = ""
    }
