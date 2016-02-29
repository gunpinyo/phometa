module Updates.ModeRootTerm where

import Dict

import Focus

import Models.Focus exposing (mode_)
import Models.RepoModel exposing (RootTerm, Term(..))
import Models.RepoUtils exposing (root_term_undefined_grammar)
import Models.Cursor exposing (CursorInfo)
import Models.Model exposing (Model, Command, KeyBinding(..), Keymap, Mode(..),
                              RecordModeRootTerm, MicroModeRootTerm(..))
import Updates.KeymapUtils exposing (build_keymap, empty_keymap)
import Updates.Cursor exposing (cmd_click_block)

keymap_mode_root_term : RecordModeRootTerm -> Model -> Keymap
keymap_mode_root_term record model = empty_keymap
--   build_keymap [
--     ("g", "Change root term grammar", KbCmd <|
--        cmd_root_term_change_grammar record model)
--   ]

-- cmd_root_term_change_grammar : RecordModeRootTerm -> Model -> Command
-- cmd_root_term_change_grammar record model =
--   cmd_push_mode_str_choices
--     (List.map fst <| Dict.toList <| record.get_grammar model)
--     "select grammar:"
--     ""
--     (\grammar_name model' ->
--       case model'.mode of
--         ModeRootTerm record' ->
--           let new_root_term = Focus.set grammar_ grammar_name
--                                 (record'.get_root_term model')
--            in record'.set_root_term new_root_term model'
--         _ -> model')

-- get_micro_mode_root_term : RootTerm -> MicroModeRootTerm
-- get_micro_mode_root_term root_term =
--   if root_term.grammar == root_term_undefined_grammar then
--     MicroModeRootTermSetGrammar
--   else case root_term.term of
--     TermTodo    -> MicroModeRootTermTodo
--     TermVar _   -> MicroModeRootTermVar
--     TermInd _ _ -> MicroModeRootTermInd

cmd_enter_mode_root_term : RecordModeRootTerm -> CursorInfo -> Command
cmd_enter_mode_root_term record cursor_info =
  (Focus.set mode_ (ModeRootTerm record)) >> (cmd_click_block cursor_info)
