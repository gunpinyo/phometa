module Models.RepoUtils where

import Debug
import Dict exposing (Dict)

import Focus exposing (Focus, (=>))

import Tools.Utils exposing (list_get_elem, list_focus_elem)
import Tools.SanityCheck exposing (CheckResult, valid)
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

-- Models ----------------------------------------------------------------------

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

init_judgement : Judgement
init_judgement =
  { context = init_root_term
  , root_term = init_root_term
  }

-- Theorem ---------------------------------------------------------------------

init_theorem : Theorem
init_theorem =
  { comment = Nothing
  , is_folded = False
  , goal = init_judgement
  , proof = ProofTodo
  }

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
