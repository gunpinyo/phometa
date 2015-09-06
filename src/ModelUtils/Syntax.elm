module ModelUtils.Syntax where

import Array

import Tools.Verification exposing
  (VerificationResult, valid, invalid, sequentially_verify)
import Models.Module exposing (ModulePath)
import Models.Syntax exposing (Syntax)
import Models.Model exposing (Model)
import Models.EtcAlias exposing(VerifyModel)

initial_syntax : ModulePath -> Syntax
initial_syntax module_path =
    { module_path = module_path
    , has_locked = False
    , comment = ""
    , grammars = Array.empty
    , dependent_syntaxes = Array.empty
    }

verify_syntax : Syntax -> VerifyModel
verify_syntax syntax model =
  valid
  -- TODO: implement this
