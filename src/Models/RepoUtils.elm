module Models.RepoUtils where

import Debug
import Dict exposing (Dict)
import Set exposing (Set)

import Focus exposing (Focus, (=>))

import Tools.Utils exposing (list_get_elem, list_focus_elem,
                             list_remove_duplication)
import Tools.SanityCheck exposing (CheckResult, valid)
import Tools.StripedList exposing (striped_list_get_odd_element)
import Tools.OrderedDict exposing (ordered_dict_to_list)
import Models.Focus exposing (root_package_, dict_, nodes_, term_)
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

get_grammar_names : ModulePath -> Model -> List GrammarName
get_grammar_names module_path model =
  case get_module module_path model of
    Nothing -> []
    Just module' -> ordered_dict_to_list module'.nodes
                      |> List.filterMap (\ (node_name, node) ->
                           case node of
                             NodeGrammar _ -> Just node_name
                             _             -> Nothing)

get_grammar : NodePath -> Model -> Maybe Grammar
get_grammar node_path model =
  case get_node node_path model of
    Just (NodeGrammar grammar) -> Just grammar
    _                          -> Nothing

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

get_all_todo_cursor_paths : Term -> List IntCursorPath
get_all_todo_cursor_paths term =
  case term of
    TermTodo            -> [[]] -- has one one todo which is empty path
    TermVar _           -> []   -- has no todos
    TermInd _ sub_terms ->
      sub_terms
         |> List.indexedMap
              (\index sub_term -> get_all_todo_cursor_paths sub_term
                |> List.map (\cursor_path -> index :: cursor_path))
         |> List.concat

has_root_term_completed : RootTerm -> Bool
has_root_term_completed root_term =
  List.isEmpty <| get_all_todo_cursor_paths root_term.term

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

-- Rule ------------------------------------------------------------------------

get_rule_names : ModulePath -> Model -> List RuleName
get_rule_names module_path model =
  case get_module module_path model of
    Nothing -> []
    Just module' -> ordered_dict_to_list module'.nodes
                      |> List.filterMap (\ (node_name, node) ->
                           case node of
                             NodeRule _  -> Just node_name
                             _           -> Nothing)

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

-- Theorem ---------------------------------------------------------------------

init_theorem : Theorem
init_theorem =
  { comment = Nothing
  , is_folded = False
  , goal = init_root_term
  , proof = ProofTodo
  }

get_theorem_names : ModulePath -> Model -> List TheoremName
get_theorem_names module_path model =
  case get_module module_path model of
    Nothing -> []
    Just module' -> ordered_dict_to_list module'.nodes
                      |> List.filterMap (\ (node_name, node) ->
                           case node of
                             NodeTheorem _  -> Just node_name
                             _              -> Nothing)

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

has_theorem_completed : Theorem -> Bool
has_theorem_completed theorem =
  if not <| has_root_term_completed theorem.goal then False else
    case theorem.proof of
      ProofTodo -> False
      ProofByRule _ _ sub_theorems ->
        List.all has_theorem_completed sub_theorems
      ProofByReduction theorem' ->
        has_theorem_completed theorem'
      ProofByLemma _ _ -> True

-- Pattern Matching / Unification ----------------------------------------------

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

pattern_matchable : RootTerm -> RootTerm -> Bool
pattern_matchable pattern target =
  pattern_match_aux pattern target /= Nothing

-- -- if matched, return
-- --   1. dict that map pattern variables to corresponded goal root terms
-- --   2. sequence of goal variables that needed to be substituted by
-- --        the corresponded root term in order to make matching successful
-- -- otherwise, return nothing
pattern_match : RootTerm -> RootTerm -> Maybe PatternMatchingInfo
pattern_match pattern target =
  let maybe_aux_dict = pattern_match_aux pattern target
      subst_list_func var_name root_term_list maybe_acc_subst_list =
        case root_term_list of
          [] -> Nothing -- impossible, pattern variable will match to something
          root_term :: [] -> maybe_acc_subst_list -- no need for unification
          fst_root_term :: other_root_terms ->
            let fold_func root_term maybe_acc =
                  let maybe_partial_subst_list =
                        Maybe.andThen maybe_acc (\acc ->
                          unify (multiple_root_substitute acc fst_root_term)
                                (multiple_root_substitute acc root_term))
                   in Maybe.map2 List.append maybe_acc maybe_partial_subst_list
             in List.foldl fold_func maybe_acc_subst_list other_root_terms
      maybe_subst_list = Maybe.andThen maybe_aux_dict (\aux_dict ->
        Dict.foldl subst_list_func (Just []) aux_dict)
   in Maybe.map2
        (\subst_list aux_dict ->
          { pattern_variables =
              Dict.map (\var_name root_term_list ->
                multiple_root_substitute subst_list <|
                  list_get_elem 0 root_term_list) aux_dict
          , substitution_list = subst_list
          })
        maybe_subst_list maybe_aux_dict

-- do a pattern matching between `pattern` and `target`
-- if success, return a dict from pattern variables to corresponded root terms
--      this may be more than one of the pattern variable occur multiple time
-- otherwise, return nothing
pattern_match_aux : RootTerm -> RootTerm -> Maybe (Dict VarName (List RootTerm))
pattern_match_aux pattern target =
  if pattern.grammar /= target.grammar then Nothing else
  case (pattern.term, target.term) of
    (TermTodo, _) -> Nothing -- impossible to have `TermTodo` on this stage
    (_, TermTodo) -> Nothing -- impossible to have `TermTodo` on this stage
    (TermVar var_name, _) -> Just (Dict.singleton var_name [target])
    (_, TermVar _) -> Nothing -- this is one way matching, so need to reject
    (TermInd pat_mixfix pat_sub_terms, TermInd tar_mixfix tar_sub_terms) ->
      if pat_mixfix /= tar_mixfix then Nothing else
        let results = List.map2 pattern_match_aux
              (get_sub_root_terms pat_mixfix pat_sub_terms)
              (get_sub_root_terms tar_mixfix tar_sub_terms)
            fold_func result acc =
              case (result, acc) of
                (Nothing, _) -> acc
                (_, Nothing) -> result
                (Just result_dict, Just acc_dict) -> Just <|
                  Dict.foldl
                    (\key val dict ->
                      let old_val = Maybe.withDefault [] (Dict.get key dict)
                          new_val = List.append val old_val
                       in Dict.insert key new_val dict)
                    acc_dict
                    result_dict
         in List.foldl fold_func (Just Dict.empty) results
              |> Maybe.map (\dict ->
                   Dict.map (\_ list -> list_remove_duplication list) dict)

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
                      (\subst_list ->
                         unify (multiple_root_substitute subst_list a)
                               (multiple_root_substitute subst_list b))
               in Maybe.map2 List.append maybe_acc_subst_list
                                         maybe_partial_subst_list
         in List.map2 (,) a_sub_terms b_sub_terms
              |> List.foldl fold_func (Just [])

-- return list of pattern variable and its corresponded root term
-- if can't unify, return `Nothing`
unify' : RootTerm -> RootTerm -> Maybe (Dict VarName RootTerm)
unify' pattern goal =
  case pattern.term of
    TermTodo          -> Nothing
    TermVar var_name  -> Just (Dict.singleton var_name goal)
    TermInd pattern_grammar_choice pattern_sub_terms  ->
      case goal.term of
        TermTodo         -> Nothing
        TermVar _        -> Nothing
        TermInd goal_grammar_choice goal_sub_terms ->
          if List.length pattern_sub_terms /= List.length goal_sub_terms
             then Nothing
          else
             let results = List.map2 unify'
                   (get_sub_root_terms pattern_grammar_choice pattern_sub_terms)
                   (get_sub_root_terms goal_grammar_choice goal_sub_terms)
              in List.foldl
                   (\result acc ->
                     case (result, acc) of
                       (Just result_dict, Just acc_dict) ->
                         Just (Dict.union result_dict acc_dict)
                       _ -> Nothing)
                   (Just Dict.empty)
                   results
