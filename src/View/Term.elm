module View.Term where

import Maybe exposing (Maybe)

import Model.Grammar exposing (Grammar)
import Model.Term exposing (Term)

--show_term : Grammar -> Term -> Maybe Html
--show_term grammar term
--  = case term of
--      Term_FromIndType type_name index subterms ->
--        let subterms_types, format = get_indtype_detail Grammar type_name index
--         in List.map 
