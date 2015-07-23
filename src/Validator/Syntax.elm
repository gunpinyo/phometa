--module Validator.Syntax where

---- TODO: finish all of this

--validate_grammar_choice : Syntax -> GrammarChoice -> Bool
--validate_grammar_choice syntax grammar_choice
--  = let length_correct
--          = Array.length grammar_choice.subgrammars + 1
--              == Array.length grammar_choice.format
--        all_subgrammars_exist
--          = Array.foldl
--              (\subgrammar acc
--                -> acc && List.member subgrammar syntax.grammar_order)
--              True grammar_choice.subgrammars
--     in length_correct && all_subgrammars_exist

--validate_grammar_config : Syntax -> GrammarConfig -> Bool
--validate_grammar_config syntax grammar_config
--  -- there is no constrain for GrammarConfig at the moment
--  = True


--validate_grammar : Grammar -> Bool
--validate_grammar grammar
--  = 


--validate_syntax : Syntax -> Bool
--validate_syntax syntax
--  = let dict_ordered
--          = validate_ordered_dict
--              syntax.grammar_order syntax.grammar_dict
--        config_dict_ordered
--          = validate_ordered_dict
--              syntax.grammar_order syntax.grammar_config_dict
--        -- GrammarName in grammar_order uniqueness has been solved
--        -- by dict_ordered and config_dict_ordered
--        all_grammar_valid
--          = Dict.foldl (\_ grammar acc -> acc && validate_grammar grammar)
--              True syntax.grammar_dict
--     in dict_ordered && config_dict_ordered && all_grammar_valid
