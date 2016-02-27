module Updates.ModeRootTerm where

import Dict

import Focus

import Models.Focus exposing (grammar_)
import Models.Model exposing (Model, Command, KeyBinding(..), Keymap,
                              Mode(..), RecordModeRootTerm)
import Updates.KeymapUtils exposing (build_keymap, empty_keymap)
import Updates.ModeStrChoices exposing (cmd_push_mode_str_choices)

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
