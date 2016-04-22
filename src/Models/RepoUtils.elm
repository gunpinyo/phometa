module Models.RepoUtils where

import Debug
import Dict exposing (Dict)
import Regex exposing (Regex, contains)
import Set exposing (Set)
import String

import Focus exposing (Focus, (=>))

import Tools.Utils exposing (list_get_elem, list_focus_elem,
                             list_remove_duplication)
import Tools.SanityCheck exposing (CheckResult, valid)
import Tools.StripedList exposing (striped_list_get_even_element,
                                   striped_list_get_odd_element,
                                   stripe_two_list_together)
import Tools.OrderedDict exposing (ordered_dict_to_list)
import Models.Focus exposing (root_package_, dict_, nodes_,
                              term_, proof_, pattern_variables_)
import Models.Cursor exposing (IntCursorPath)
import Models.RepoModel exposing (..)
import Models.Model exposing (Model)

-- Package ---------------------------------------------------------------------

init_package : Package
init_package =
  { dict = Dict.empty
  , is_folded = False
  }

check_package : Package -> CheckResult
check_package package = valid -- TODO: implment this

get_package : PackagePath -> Model -> Maybe Package
get_package package_path model =
  get_package' package_path model.root_package

get_package' : PackagePath -> Package -> Maybe Package
get_package' package_path top_package =
  case package_path of
    [] -> Just top_package
    package_name :: package_path' ->
      case Dict.get package_name top_package.dict of
        Just (PackageElemPkg package) -> get_package' package_path' package
        _                             -> Nothing

update_package : PackagePath -> (Package -> Package) -> Model -> Model
update_package package_path update_func model =
  let func root_package = update_package' package_path update_func root_package
   in Focus.update root_package_ func model

update_package' : PackagePath -> (Package -> Package) -> Package -> Package
update_package' package_path update_func top_package =
  case package_path of
    [] -> update_func top_package
    package_name :: package_path' ->
      case Dict.get package_name top_package.dict of
        Just (PackageElemPkg old_sub_package) ->
          let new_sub_package = update_package'
                                  package_path' update_func old_sub_package
              dict' = Dict.insert package_name
                        (PackageElemPkg new_sub_package) top_package.dict
           in Focus.set dict_ dict' top_package
        _                             -> top_package

focus_package : PackagePath -> Focus Model Package
focus_package package_path =
  Focus.create
    (\model -> case get_package package_path model of
                 Nothing -> Debug.crash "from Models.RepoUtils.focus_package"
                 Just package -> package)
    (update_package package_path)

-- Module ----------------------------------------------------------------------

get_module : ModulePath -> Model -> Maybe Module
get_module module_path model =
  get_package module_path.package_path model
     |> (flip Maybe.andThen) (\package ->
          case Dict.get module_path.module_name package.dict of
            Just (PackageElemMod module') -> Just module'
            _                             -> Nothing)

update_module : ModulePath -> (Module -> Module) -> Model -> Model
update_module module_path update_func model =
  let package_update_func package =
        let dict' = Dict.update
                      module_path.module_name
                      (\ maybe_package_elem -> case maybe_package_elem of
                           Just (PackageElemMod module') ->
                             Just (PackageElemMod <| update_func module')
                           other                         -> other)
                      package.dict
         in Focus.set dict_ dict' package
   in update_package module_path.package_path package_update_func model

focus_module : ModulePath -> Focus Model Module
focus_module module_path =
  Focus.create
    (\model -> case get_module module_path model of
                 Nothing -> Debug.crash "from Models.RepoUtils.focus_module"
                 Just module' -> module')
    (update_module module_path)

-- Node ------------------------------------------------------------------------

get_node : NodePath -> Model -> Maybe Node
get_node node_path model =
  get_module node_path.module_path model
     |> (flip Maybe.andThen)
          (\module' -> Dict.get node_path.node_name module'.nodes.dict)

update_node : NodePath -> (Node -> Node) -> Model -> Model
update_node node_path update_func model =
  let module_update_func module' =
        let nodes' = Dict.update
                       node_path.node_name
                       (Maybe.map update_func)
                       module'.nodes.dict
         in Focus.set (nodes_ => dict_) nodes' module'
   in update_module node_path.module_path module_update_func model

focus_node : NodePath -> Focus Model Node
focus_node node_path =
  Focus.create
    (\model -> case get_node node_path model of
                 Nothing -> Debug.crash "from Models.RepoUtils.focus_node"
                 Just node -> node)
    (update_node node_path)

-- Grammar ---------------------------------------------------------------------

-- get all of name of grammar in this module (including imported grammars)
-- exclude any grammar that hasn't been locked
-- TODO: support imported grammar
get_usable_grammar_names : ModulePath -> Model -> List GrammarName
get_usable_grammar_names module_path model =
  case get_module module_path model of
    Nothing -> []
    Just module' -> ordered_dict_to_list module'.nodes
                      |> List.filterMap (\ (node_name, node) ->
                           case node of
                             NodeGrammar grammar ->
                               if grammar.has_locked then Just node_name
                                                     else Nothing
                             _             -> Nothing)

-- TODO: support imported grammars
get_grammar : NodePath -> Model -> Maybe Grammar
get_grammar node_path model =
  case get_node node_path model of
    Just (NodeGrammar grammar) -> Just grammar
    _                          -> Nothing

-- TODO: support imported grammars
focus_grammar : NodePath -> Focus Model Grammar
focus_grammar node_path =
  let err_msg = "from Models.RepoUtils.focus_grammar"
   in (focus_node node_path => (Focus.create
        (\node -> case node of
            NodeGrammar grammar -> grammar
            _ -> Debug.crash err_msg)
        (\update_func node -> case node of
            NodeGrammar grammar -> NodeGrammar (update_func grammar)
            other -> other)))

grammar_allow_variable : Grammar -> Bool
grammar_allow_variable grammar =
  grammar.const_regex /= Nothing ||
  grammar.subst_regex /= Nothing ||
  grammar.unify_regex /= Nothing

get_variable_type : Grammar -> VarName -> Maybe VarType
get_variable_type grammar var_name =
  let match_func getter = case getter grammar of
        Nothing -> False
        Just regex ->                -- can use `contains` function directly
          contains regex var_name    -- since all of regex in phometa is /^...$/
   in if match_func .unify_regex then
        Just VarTypeUnify
      else if match_func .subst_regex then
        Just VarTypeSubst
      else if match_func .const_regex then
        Just VarTypeConst
      else
        Nothing

-- Term ------------------------------------------------------------------------

-- when root_term is newly created, its grammar hasn't been defined
root_term_undefined_grammar : GrammarName
root_term_undefined_grammar = ""

init_root_term : RootTerm
init_root_term =
  { grammar = root_term_undefined_grammar
  , term = TermTodo
  }

focus_sub_term : IntCursorPath -> Focus RootTerm Term
focus_sub_term from_root_cursor_path =
  let err_msg = "from Models.RepoUtils.focus_sub_term"
      get_func cursor_path term =
        case cursor_path of
          [] -> term
          cursor_index :: cursor_path' ->
            case term of
              TermTodo -> Debug.crash err_msg
              TermVar _ -> Debug.crash err_msg
              TermInd grammar_choice sub_terms ->
                get_func cursor_path' (list_get_elem cursor_index sub_terms)
      update_func func cursor_path term =
        case cursor_path of
          [] -> func term
          cursor_index :: cursor_path' ->
            case term of
              TermTodo -> term
              TermVar _ -> term
              TermInd grammar_choice sub_terms ->
                TermInd grammar_choice <|
                  Focus.update (list_focus_elem cursor_index)
                    (\sub_term -> update_func func cursor_path' sub_term)
                    sub_terms
   in term_ => (Focus.create
        (\ term -> get_func from_root_cursor_path term)
        (\ func term -> update_func func from_root_cursor_path term))

get_term_todo_cursor_paths : Term -> List IntCursorPath
get_term_todo_cursor_paths term =
  case term of
    TermTodo            -> [[]] -- has one one todo which is empty path
    TermVar _           -> []   -- has no todos
    TermInd _ sub_terms ->
      sub_terms
         |> List.indexedMap
              (\index sub_term -> get_term_todo_cursor_paths sub_term
                |> List.map (\cursor_path -> index :: cursor_path))
         |> List.concat

get_root_term_variables : RootTerm -> Dict VarName GrammarName
get_root_term_variables root_term =
  case root_term.term of
    TermTodo -> Dict.empty
    TermVar var_name -> Dict.singleton var_name root_term.grammar
    TermInd grammar_choice sub_terms ->
      List.foldl
        (\root_sub_term -> Dict.union (get_root_term_variables root_sub_term))
        Dict.empty
        (get_sub_root_terms grammar_choice sub_terms)

has_root_term_completed : RootTerm -> Bool
has_root_term_completed root_term =
  List.isEmpty <| get_term_todo_cursor_paths root_term.term

init_term_ind : GrammarChoice -> Term
init_term_ind grammar_choice =
  let number_of_sub_terms = List.length
        <| striped_list_get_odd_element grammar_choice
      sub_terms = List.repeat number_of_sub_terms TermTodo
   in TermInd grammar_choice sub_terms

get_sub_root_terms : GrammarChoice -> List Term -> List RootTerm
get_sub_root_terms grammar_choice sub_terms =
  List.map2
    (\sub_grammar_name sub_term ->
       { grammar = sub_grammar_name
       , term = sub_term
       })
    (striped_list_get_odd_element grammar_choice)
    sub_terms

debug_show_root_term : Bool -> RootTerm -> String
debug_show_root_term show_grammar root_term =
  let grammar_str = if show_grammar then ":" ++ root_term.grammar else ""
   in case root_term.term of
        TermTodo -> "?"
        TermVar var_name -> var_name ++ grammar_str
        TermInd grammar_choice sub_terms ->
          let sub_terms_strs = get_sub_root_terms grammar_choice sub_terms
                                 |> List.map (debug_show_root_term show_grammar)
              format_strs = striped_list_get_even_element grammar_choice
              strs = stripe_two_list_together format_strs sub_terms_strs
           in "(" ++ (String.concat strs) ++ grammar_str ++ ")"

-- Rule ------------------------------------------------------------------------

-- get all of name of rules in this module (including imported rules)
-- exclude any rule that hasn't been locked
-- TODO: support imported rules
get_usable_rule_names : ModulePath -> Model -> List RuleName
get_usable_rule_names module_path model =
  case get_module module_path model of
    Nothing -> []
    Just module' -> ordered_dict_to_list module'.nodes
                      |> List.filterMap (\ (node_name, node) ->
                           case node of
                             NodeRule rule ->
                               if rule.has_locked then Just node_name
                                                  else Nothing
                             _           -> Nothing)

-- TODO: support imported rules
focus_rule : NodePath -> Focus Model Rule
focus_rule node_path =
  let err_msg = "from Models.RepoUtils.focus_rule"
   in (focus_node node_path => (Focus.create
        (\node -> case node of
            NodeRule rule -> rule
            _ -> Debug.crash err_msg)
        (\update_func node -> case node of
            NodeRule rule -> NodeRule (update_func rule)
            other -> other)))

apply_rule : RuleName -> RootTerm -> Arguments -> ModulePath -> Model ->
               Maybe (List RootTerm, PatternMatchingInfo)
apply_rule rule_name target arguments module_path model =
  if not <| List.member rule_name
         <| get_usable_rule_names module_path model then
    Nothing
  else
    let rule = Focus.get (focus_rule { module_path = module_path
                                     , node_name = rule_name
                                     }) model
        parameters = List.map (\parameter -> { grammar = parameter.grammar
                                             , term = TermVar parameter.var_name
                                             }) rule.parameters
        param_arg_list = List.map2 (,) parameters arguments
        pattern_target_list = (rule.conclusion, target) :: param_arg_list
        maybe_pattern_matching_info = pattern_match_multiple module_path model
                                        pattern_target_list
     in Maybe.andThen maybe_pattern_matching_info (\pattern_matching_info ->
          apply_rule_aux rule.premises pattern_matching_info module_path model)

apply_rule_aux : List Premise -> PatternMatchingInfo -> ModulePath -> Model ->
                        Maybe (List RootTerm, PatternMatchingInfo)
apply_rule_aux rule_premises pm_info module_path model =
  case rule_premises of
    [] -> Just ([], pm_info)
    (PremiseDirect premise_pattern) :: rule_premises' ->
      let sub_result = apply_rule_aux rule_premises' pm_info module_path model
          map_func (sub_premises, sub_pm_info) =
            let head_premise = pattern_root_substitute
                                 sub_pm_info.pattern_variables premise_pattern
             in (head_premise :: sub_premises, sub_pm_info)
       in Maybe.map map_func sub_result
    (PremiseSubRule srule_name srule_target srule_arguments) :: rule_premises'->
      let srule_subst_func = pattern_root_substitute pm_info.pattern_variables
          srule_result = apply_rule srule_name (srule_subst_func srule_target)
            (List.map srule_subst_func srule_arguments) module_path model
          sub_result = Maybe.andThen srule_result (\ (_, srule_pm_info) ->
            apply_rule_aux rule_premises' (pattern_matching_info_substitute
              pm_info srule_pm_info.substitution_list) module_path model)
          map_func (srule_premises, srule_pm_info) (sub_premises, sub_pm_info) =
            let updating_subst_list = get_updating_subst_list
                                        srule_pm_info sub_pm_info
                srule_premises' = List.map
                  (multiple_root_substitute updating_subst_list) srule_premises
             in (srule_premises' ++ sub_premises, sub_pm_info)
       in Maybe.map2 map_func srule_result sub_result
    (PremiseLetBe letbe_pattern letbe_target) :: rule_premises' ->
      let new_rule_premise = PremiseMatch letbe_target
                               [{ pattern = letbe_pattern
                                , premises = rule_premises'
                                }]
       in apply_rule_aux [new_rule_premise] pm_info module_path model
    (PremiseMatch top_pattern match_elems) :: rule_premises' ->
      let match_target = pattern_root_substitute
                           pm_info.pattern_variables top_pattern
          try_matching_func match_pattern match_rule_premises =
            pattern_match module_path model match_pattern match_target
              |> (flip Maybe.andThen) (try_matched_func match_rule_premises)
          try_matched_func match_rule_premises match_pm_info =
            let pm_info' = pattern_matching_info_substitute
                                pm_info match_pm_info.substitution_list
                inner_scope_pm_info =             -- if there is a collusion,
                  Focus.update pattern_variables_ -- outer scope is invisible
                    (Dict.union match_pm_info.pattern_variables) pm_info'
                inner_scope_result = apply_rule_aux match_rule_premises
                                       inner_scope_pm_info module_path model
                map_func (inner_scope_premises, inner_scope_pm_info') =
                  let updating_subst_list = get_updating_subst_list
                                              pm_info' inner_scope_pm_info'
                      pm_info'' = pattern_matching_info_substitute pm_info'
                                    updating_subst_list
                   in (inner_scope_premises,  pm_info'')
             in Maybe.map map_func inner_scope_result
          match_result = List.foldl (\r acc -> if acc /= Nothing then acc
            else try_matching_func r.pattern r.premises) Nothing match_elems
          sub_result = Maybe.andThen match_result (\ (_, match_pm_info) ->
            apply_rule_aux rule_premises' match_pm_info module_path model)
          map_func (match_premises, match_pm_info) (sub_premises, sub_pm_info) =
            let updating_subst_list = get_updating_subst_list
                                        match_pm_info sub_pm_info
                match_premises' = List.map
                  (multiple_root_substitute updating_subst_list) match_premises
             in (match_premises' ++ sub_premises, sub_pm_info)
       in Maybe.map2 map_func match_result sub_result

-- helper of apply_rule_aux
get_updating_subst_list : PatternMatchingInfo -> PatternMatchingInfo
                            -> SubstitutionList
get_updating_subst_list old_pm_info new_pm_info =
  List.drop (List.length old_pm_info.substitution_list)
            new_pm_info.substitution_list

-- (sub) term can be reduce by this rule if
--   1. `allow_reduction` of the rule is true
--   2. the rule require no parameters
--   3. the rule generate exactly 1 premise
--   4. that premise and the conclusion has the same grammar as target term
--   5. applying the rule doesn't produce any self substitution
apply_reduction : RuleName -> RootTerm -> ModulePath -> Model -> Maybe RootTerm
apply_reduction rule_name target module_path model =
  if not <| List.member rule_name
         <| get_usable_rule_names module_path model
    then Nothing else
  let rule = Focus.get (focus_rule { module_path = module_path
                                   , node_name = rule_name
                                   }) model in
  if not rule.allow_reduction ||                                        -- (1)
     (not <| List.isEmpty rule.parameters) ||                           -- (2)
     rule.conclusion.grammar /=  target.grammar                         -- (4.2)
    then Nothing else
  let result = apply_rule rule_name target [] module_path model in
  Maybe.andThen result (\ (premises, pm_info) -> case premises of
    premise :: [] ->                                                    -- (3)
      if premise.grammar /= target.grammar ||                           -- (4.1)
         (not <| List.isEmpty pm_info.substitution_list)                -- (5)
        then Nothing else Just premise
    _             -> Nothing)

-- Theorem ---------------------------------------------------------------------

init_theorem : Theorem
init_theorem =
  { comment = Nothing
  , is_folded = False
  , goal = init_root_term
  , proof = ProofTodo
  }

-- get all of name of rules in this module (including imported theorems)
-- TODO: support imported theorems
get_theorem_names : ModulePath -> Model -> List TheoremName
get_theorem_names module_path model =
  case get_module module_path model of
    Nothing -> []
    Just module' -> ordered_dict_to_list module'.nodes
                      |> List.filterMap (\ (node_name, node) ->
                           case node of
                             NodeTheorem _  -> Just node_name
                             _              -> Nothing)

-- TODO: support imported theorems
focus_theorem : NodePath -> Focus Model Theorem
focus_theorem node_path =
  let err_msg = "from Models.RepoUtils.focus_theorem"
   in (focus_node node_path => (Focus.create
        (\node -> case node of
            NodeTheorem theorem -> theorem
            _ -> Debug.crash err_msg)
        (\update_func node -> case node of
            NodeTheorem theorem -> NodeTheorem (update_func theorem)
            other -> other)))

focus_theorem_rule_argument : Int -> Focus Theorem RootTerm
focus_theorem_rule_argument index =
  let err_msg = "from Models.RepoUtils.focus_theorem_rule_argument"
      arguments_focus = (Focus.create
        (\theorem -> case theorem of
           ProofTodoWithRule _ arguments -> arguments
           ProofByRule _ arguments _ _ -> arguments
           _ -> Debug.crash err_msg)
        (\update_func theorem -> case theorem of
           ProofTodoWithRule rule_name arguments ->
             ProofTodoWithRule rule_name (update_func arguments)
           ProofByRule rule_name arguments pattern_matching_info sub_theorems ->
             ProofByRule rule_name (update_func arguments)
               pattern_matching_info sub_theorems
           other -> other))
   in proof_ => arguments_focus => list_focus_elem index

get_theorem_variables_from_model : NodePath -> Model -> Dict VarName GrammarName
get_theorem_variables_from_model node_path model =
  let theorem = Focus.get (focus_theorem node_path) model
   in get_theorem_variables theorem

get_theorem_variables : Theorem -> Dict VarName GrammarName
get_theorem_variables theorem =
  let goal_dict = get_root_term_variables theorem.goal
      proof_dict = case theorem.proof of
        ProofTodo -> Dict.empty
        ProofTodoWithRule _ arguments ->
          List.foldl
            (\argument -> Dict.union (get_root_term_variables argument))
            Dict.empty arguments
        ProofByRule _ arguments _ sub_theorems ->
          let arguments_dict = List.foldl
                (\argument -> Dict.union (get_root_term_variables argument))
                Dict.empty arguments
              sub_theorems_dict = List.foldl
                (\sub_theorem -> Dict.union (get_theorem_variables sub_theorem))
                Dict.empty sub_theorems
           in Dict.union arguments_dict sub_theorems_dict
        ProofByLemma _ _ -> Dict.empty
   in Dict.union goal_dict proof_dict

has_theorem_completed : Theorem -> Bool
has_theorem_completed theorem =
  if not <| has_root_term_completed theorem.goal then False else
    case theorem.proof of
      ProofTodo -> False
      ProofTodoWithRule _ _ -> False
      ProofByRule _ _ _ sub_theorems ->
        List.all has_theorem_completed sub_theorems
      ProofByLemma _ _ -> True

-- Pattern Matching ------------------------------------------------------------

substitute : VarName -> Term -> Term -> Term
substitute old_var new_term top_term =
  case top_term of
    TermTodo -> TermTodo   -- this is not possible since the term is completed
    TermVar var_name -> if var_name == old_var
                          then new_term else TermVar var_name
    TermInd grammar_choice sub_terms ->
      TermInd grammar_choice <| List.map (substitute old_var new_term) sub_terms

multiple_root_substitute : SubstitutionList -> RootTerm -> RootTerm
multiple_root_substitute list top_root_term =
  let fold_func record acc =
        substitute record.old_var record.new_root_term.term acc
      update_func top_term = List.foldl fold_func top_term list
   in Focus.update term_ update_func top_root_term

pattern_substitute : Dict VarName RootTerm -> Term -> Term
pattern_substitute dict top_term =
  case top_term of
    TermTodo -> TermTodo   -- this is not possible since the term is completed
    TermVar var_name -> case Dict.get var_name dict of
                          Nothing            -> TermVar var_name
                          Just new_root_term -> new_root_term.term
    TermInd grammar_choice sub_terms ->
      TermInd grammar_choice <| List.map (pattern_substitute dict) sub_terms

pattern_root_substitute : Dict VarName RootTerm -> RootTerm -> RootTerm
pattern_root_substitute dict top_root_term =
  Focus.update term_ (pattern_substitute dict) top_root_term

pattern_matching_info_substitute : PatternMatchingInfo -> SubstitutionList
                                     -> PatternMatchingInfo
pattern_matching_info_substitute pm_info substitution_list =
  { pattern_variables = Dict.map (\_ ->
      multiple_root_substitute substitution_list) pm_info.pattern_variables
  , substitution_list = List.append pm_info.substitution_list substitution_list
  }

pattern_matchable : ModulePath -> Model -> RootTerm -> RootTerm -> Bool
pattern_matchable module_path model pattern target =
  pattern_match module_path model pattern target /= Nothing

merge_pattern_variables_list : List (Dict VarName (List RootTerm)) ->
                                 Dict VarName (List RootTerm)
merge_pattern_variables_list main_list =
  let dict_fold_func key target_val acc =
        let old_val = Maybe.withDefault [] (Dict.get key acc)
            new_val = List.append target_val old_val
         in Dict.insert key new_val acc
      list_fold_func dict acc = Dict.foldl dict_fold_func dict acc
   in List.foldl list_fold_func Dict.empty main_list
       |> Dict.map (\_ list -> list_remove_duplication list)

-- do a pattern matching between `pattern` and `target`
-- if success, return a dict from pattern variables to corresponded root terms
--      this may be more than one of the pattern variable occur multiple time
-- otherwise, return nothing
pattern_match_get_vars_dict : RootTerm -> RootTerm ->
                                Maybe (Dict VarName (List RootTerm))
pattern_match_get_vars_dict pattern target =
  if pattern.grammar /= target.grammar then Nothing else
  case (pattern.term, target.term) of
    (TermTodo, _) -> Nothing -- impossible to have `TermTodo` on this stage
    (_, TermTodo) -> Nothing -- impossible to have `TermTodo` on this stage
    (TermVar var_name, _) -> Just (Dict.singleton var_name [target])
    (_, TermVar _) -> Nothing -- this is one way matching, need to reject this
    (TermInd pat_mixfix pat_sub_terms, TermInd tar_mixfix tar_sub_terms) ->
      if pat_mixfix /= tar_mixfix then Nothing else
        let maybe_result_list = List.map2 pattern_match_get_vars_dict
              (get_sub_root_terms pat_mixfix pat_sub_terms)
              (get_sub_root_terms tar_mixfix tar_sub_terms)
         in if List.any ((==) Nothing) maybe_result_list then
              Nothing
            else
              maybe_result_list
                |> List.filterMap identity
                |> merge_pattern_variables_list
                |> Just

-- if success, return substitution list needed to make both of term identical
-- otherwise, return nothing
unify : RootTerm -> RootTerm -> Maybe (SubstitutionList)
unify a b =
  if a.grammar /= b.grammar then Nothing else
  case (a.term, b.term) of
    (TermTodo, _) -> Nothing -- impossible to have `TermTodo` on this stage
    (_, TermTodo) -> Nothing -- impossible to have `TermTodo` on this stage
    (TermVar var_name, _) -> Just ([{old_var = var_name, new_root_term = b}])
    (_, TermVar var_name) -> Just ([{old_var = var_name, new_root_term = a}])
    (TermInd a_mixfix a_sub_terms, TermInd b_mixfix b_sub_terms) ->
      if a_mixfix /= b_mixfix then Nothing else
        let fold_func (a_root_sub_term, b_root_sub_term) maybe_acc_subst_list =
              let maybe_partial_subst_list =
                    Maybe.andThen maybe_acc_subst_list
                      (\subst_list -> unify
                         (multiple_root_substitute subst_list a_root_sub_term)
                         (multiple_root_substitute subst_list b_root_sub_term))
               in Maybe.map2 List.append maybe_acc_subst_list
                                         maybe_partial_subst_list
         in List.foldl fold_func (Just []) <|
              List.map2 (,) (get_sub_root_terms a_mixfix a_sub_terms)
                            (get_sub_root_terms b_mixfix b_sub_terms)

vars_dict_to_pattern_matching_info : ModulePath -> Model
                                       -> Dict VarName (List RootTerm)
                                       -> Maybe PatternMatchingInfo
vars_dict_to_pattern_matching_info module_path model vars_dict =
  let subst_list_func var_name root_term_list maybe_acc_subst_list =
        let grammar_name = (.grammar) (list_get_elem 0 root_term_list)
            maybe_grammar = get_grammar { module_path = module_path
                                        , node_name = grammar_name
                                        } model
            maybe_var_type = Maybe.andThen maybe_grammar
                               ((flip get_variable_type) var_name)
         in case maybe_var_type of
              Nothing -> -- impossible, var_name must belong to some grammar
                Nothing  -- and it must match with some VarType of its grammar
              Just VarTypeConst -> -- each element must match exactly to pattern
                if List.all ((==) ({ grammar = grammar_name
                                   , term = TermVar var_name
                                   })) root_term_list
                  then maybe_acc_subst_list else Nothing
              Just VarTypeSubst -> -- each element must match exactly to others
                                   -- no unification allow,
                                   -- i.e. no self substitution on target
                let first_root_term = list_get_elem 0 root_term_list
                 in if List.all ((==) first_root_term) root_term_list
                      then maybe_acc_subst_list else Nothing
              Just VarTypeUnify -> case root_term_list of
                [] ->     -- impossible,
                  Nothing -- pattern variable will match to at least something
                root_term :: [] ->  -- no need for unification
                  maybe_acc_subst_list
                fst_root_term :: other_root_terms ->
                  let fold_func root_term maybe_acc =
                        let maybe_partial_subst_list =
                              Maybe.andThen maybe_acc (\acc -> unify
                                (multiple_root_substitute acc fst_root_term)
                                (multiple_root_substitute acc root_term))
                         in Maybe.map2 (++) maybe_acc maybe_partial_subst_list
                   in List.foldl fold_func maybe_acc_subst_list other_root_terms
      maybe_subst_list = Dict.foldl subst_list_func (Just []) vars_dict
   in Maybe.map (\subst_list ->
        { pattern_variables =
            Dict.map (\var_name root_term_list ->
              multiple_root_substitute subst_list <|
                list_get_elem 0 root_term_list) vars_dict
        , substitution_list = subst_list
        }) maybe_subst_list

-- if `allow_target_substitution` is true, then accept pattern matching that
--   require target substitution i.e. substitution_list != []
-- if matched, return 1. dict that map pattern variables to
--   corresponded goal root terms 2. sequence of goal variables that needed
--   to be substituted by the corresponded root term in order to make matching
--   successful otherwise, return nothing
pattern_match : ModulePath -> Model ->
                  RootTerm -> RootTerm -> Maybe PatternMatchingInfo
pattern_match module_path model pattern target =
  pattern_match_get_vars_dict pattern target
    |> (flip Maybe.andThen)
         (vars_dict_to_pattern_matching_info module_path model)

-- the same as pattern match but have multiple (pattern, target)
-- all of this need to agree on pattern match to produce a pattern_matching_info
-- this is useful for applying rule with parameters
pattern_match_multiple : ModulePath -> Model ->
                          List (RootTerm, RootTerm) -> Maybe PatternMatchingInfo
pattern_match_multiple module_path model list =
  let vars_dict_maybe_list = List.map (uncurry pattern_match_get_vars_dict) list
   in if List.any ((==) Nothing) vars_dict_maybe_list then
        Nothing
      else
        vars_dict_maybe_list
          |> List.filterMap identity
          |> merge_pattern_variables_list
          |> vars_dict_to_pattern_matching_info module_path model
