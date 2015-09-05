module ModelUtils.Syntax where

import Array

import Tools.Verification exposing
  (VerificationResult, valid, to_invalid, sequentially_verify)
import Models.Syntax exposing (Syntax)

initial_syntax : Syntax
initial_syntax =
  ModuleSyntax
    { grammars = Array.empty
    , dependent_syntaxes = Array.empty
    , has_locked = False
    , comment = ""
    }

verify_syntax : Syntax -> VerificationResult
verify_syntax syntax =
  valid
  -- TODO: implement this
