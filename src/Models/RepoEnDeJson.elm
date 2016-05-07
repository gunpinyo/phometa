module Models.RepoEnDeJson where

import Dict exposing (Dict)
import Json.Encode exposing (Value)
import Regex exposing (Regex)

import Tools.OrderedDict exposing (OrderedDict)
import Tools.StripedList exposing (striped_list_eliminate)
import Tools.RegexExtra exposing (regex_to_string)
import Models.RepoModel exposing (..)
import Models.Model exposing (Model)

-- Usage ------------------------------------------------------------------------

encode_repository : Model -> String
encode_repository model =
  Json.Encode.encode 2 (en_package model.root_package)

-- Utils -----------------------------------------------------------------------

en_str       : String -> Value
en_str       = Json.Encode.string

en_int       : Int -> Value
en_int       = Json.Encode.int

en_bool      : Bool -> Value
en_bool      = Json.Encode.bool

en_list      : (a -> Value) -> List a -> Value
en_list func = List.map func >> Json.Encode.list

en_obj       : List (String, Value) -> Value
en_obj       = Json.Encode.object

en_null      : Value
en_null      = Json.Encode.null

en_TODO : Value
en_TODO = Json.Encode.null -- for value that needed to be done in the future

en_bnf0 : String -> Value
en_bnf0 construct_name =
  Json.Encode.list [en_str construct_name]

en_bnf1 : String -> Value -> Value
en_bnf1 construct_name a =
  Json.Encode.list [en_str construct_name, a]

en_bnf2 : String -> Value -> Value -> Value
en_bnf2 construct_name a b =
  Json.Encode.list [en_str construct_name, a, b]

en_bnf4 : String -> Value -> Value -> Value -> Value -> Value
en_bnf4 construct_name a b c d =
  Json.Encode.list [en_str construct_name, a, b, c, d]

en_dict : (a -> Value) -> Dict String a -> Value
en_dict func dict = dict
  |> Dict.toList
  |> List.map (\ (key, val) -> (key, func val))
  |> en_obj

en_ordered_dict : (a -> Value) -> OrderedDict String a -> Value
en_ordered_dict func ordered_dict = en_obj
  [ ("dict", en_dict func ordered_dict.dict)
  , ("order", en_list en_str ordered_dict.order)
  ]

en_maybe_regex : Maybe Regex -> Value
en_maybe_regex maybe_regex = case maybe_regex of
  Nothing -> en_null
  Just regex -> en_str (regex_to_string regex)

-- Common ----------------------------------------------------------------------

en_format : Format -> Value
en_format = en_str

en_var_name : VarName -> Value
en_var_name = en_str

en_parameters : Parameters -> Value
en_parameters parameters =
  en_list (\param -> en_obj
            [ ("grammar", en_grammar_name param.grammar)
            , ("var_name", en_var_name param.var_name)
            ]) parameters

en_arguments : Arguments -> Value
en_arguments arguments = en_list en_root_term arguments

-- Package ---------------------------------------------------------------------

en_package_name : PackageName -> Value
en_package_name = en_str

en_package_path : PackagePath -> Value
en_package_path = en_list en_package_name

en_package : Package -> Value
en_package package = en_obj
  [ ("is_folded", en_bool package.is_folded)
  , ("dict", en_dict en_package_elem package.dict)
  ]

en_package_elem : PackageElem -> Value
en_package_elem package_elem = case package_elem of
  PackageElemPkg package' -> en_bnf1 "PackageElemPkg" (en_package package')
  PackageElemMod module'  -> en_bnf1 "PackageElemMod" (en_module module')

-- Module ----------------------------------------------------------------------

en_module_name : ModuleName -> Value
en_module_name = en_str

en_module_path : ModulePath -> Value
en_module_path module_path = en_obj
  [ ("package_path", en_package_path module_path.package_path)
  , ("module_name", en_module_name module_path.module_name)
  ]

en_module : Module -> Value
en_module module' = en_obj
  [ ("is_folded", en_bool module'.is_folded)
  , ("imports", en_list en_import_module module'.imports)
  , ("nodes", en_ordered_dict en_node module'.nodes)
  ]

en_import_module : ImportModule -> Value
en_import_module import_module = en_TODO -- TODO:

-- Node ------------------------------------------------------------------------

en_node_name : NodeName -> Value
en_node_name = en_str

en_node_path : NodePath -> Value
en_node_path node_path = en_obj
  [ ("module_path", en_module_path node_path.module_path)
  , ("node_name", en_node_name node_path.node_name)
  ]

en_node : Node -> Value
en_node node = case node of
  NodeComment comment -> en_bnf1 "NodeComment" (en_str comment)
  NodeGrammar grammar -> en_bnf1 "NodeGrammar" (en_grammar grammar)
  NodeRule rule       -> en_bnf1 "NodeRule" (en_rule rule)
  NodeTheorem theorem has_locked -> en_bnf2 "NodeTheorem"
    (en_theorem theorem) (en_bool has_locked)

en_node_type : NodeType -> Value
en_node_type node_type = case node_type of
  NodeTypeComment -> en_str "NodeTypeComment"
  NodeTypeGrammar -> en_str "NodeTypeGrammar"
  NodeTypeRule    -> en_str "NodeTypeRule"
  NodeTypeTheorem -> en_str "NodeTypeTheorem"

-- Grammar ---------------------------------------------------------------------

en_grammar_name : GrammarName -> Value
en_grammar_name = en_str

en_grammar : Grammar -> Value
en_grammar grammar = en_obj
  [ ("is_folded", en_bool grammar.is_folded)
  , ("has_locked",  en_bool grammar.has_locked)
  , ("metavar_regex", en_maybe_regex grammar.metavar_regex)
  , ("literal_regex", en_maybe_regex grammar.literal_regex)
  , ("choices", en_list en_grammar_choice grammar.choices)
  ]

en_grammar_choice : GrammarChoice -> Value
en_grammar_choice grammar_choice =
  Json.Encode.list (striped_list_eliminate
                      en_format en_grammar_name grammar_choice)

-- Term ------------------------------------------------------------------------

en_term : Term -> Value
en_term term = case term of
  TermTodo         -> en_bnf0 "TermTodo"
  TermVar var_name -> en_bnf1 "TermVar" (en_var_name var_name)
  TermInd grammar_choice sub_terms -> en_bnf2 "TermInd"
    (en_grammar_choice grammar_choice) (en_list en_term sub_terms)

en_root_term : RootTerm -> Value
en_root_term root_term = en_obj
  [ ("grammar", en_grammar_name root_term.grammar)
  , ("term", en_term root_term.term)
  ]

en_var_type : VarType -> Value
en_var_type var_type = case var_type of
  VarTypeMetaVar -> en_bnf0 "VarTypeMetaVar"
  VarTypeLiteral -> en_bnf0 "VarTypeLiteral"

-- Rule ------------------------------------------------------------------------

en_rule_name : RuleName -> Value
en_rule_name = en_str

en_rule : Rule -> Value
en_rule rule = en_obj
  [ ("is_folded", en_bool rule.is_folded)
  , ("has_locked",  en_bool rule.has_locked)
  , ("allow_reduction", en_bool rule.allow_reduction)
  , ("parameters", en_parameters rule.parameters)
  , ("conclusion", en_root_term rule.conclusion)
  , ("premises", en_list en_premise rule.premises)
  ]

en_premise : Premise -> Value
en_premise premise = case premise of
  PremiseDirect pattern -> en_bnf1 "PremiseDirect" (en_root_term pattern)
  PremiseCascade records -> en_bnf1 "PremiseCascade"
    (en_list en_premise_cascade_record records)

en_premise_cascade_record : PremiseCascadeRecord -> Value
en_premise_cascade_record record = en_obj
  [ ("rule_name", en_rule_name record.rule_name)
  , ("pattern", en_root_term record.pattern)
  , ("arguments", en_arguments record.arguments)
  , ("allow_unification", en_bool record.allow_unification)
  ]

-- Theorem ---------------------------------------------------------------------

en_theorem_name : TheoremName -> Value
en_theorem_name = en_str

en_theorem : Theorem -> Value
en_theorem theorem = en_obj
  [ ("is_folded", en_bool theorem.is_folded)
  , ("goal", en_root_term theorem.goal)
  , ("proof", en_proof theorem.proof)
  ]

en_proof : Proof -> Value
en_proof proof = case proof of
  ProofTodo -> en_bnf0 "ProofTodo"
  ProofTodoWithRule rule_name arguments -> en_bnf2 "ProofTodoWithRule"
    (en_rule_name rule_name) (en_arguments arguments)
  ProofByRule rule_name arguments pm_info sub_theorems -> en_bnf4 "ProofByRule"
    (en_rule_name rule_name) (en_arguments arguments)
    (en_pattern_matching_info pm_info) (en_list en_theorem sub_theorems)
  ProofByLemma lemma_name pm_info -> en_bnf2 "ProofByLemma"
    (en_theorem_name lemma_name) (en_pattern_matching_info pm_info)

-- Pattern Matching / Unification ----------------------------------------------

en_substitution_list : SubstitutionList -> Value
en_substitution_list subst_list =
  en_list (\subst_elem -> en_obj
             [ ("old_var", en_var_name subst_elem.old_var)
             , ("new_root_term", en_root_term subst_elem.new_root_term)])
          subst_list

en_pattern_matching_info : PatternMatchingInfo -> Value
en_pattern_matching_info pm_info = en_obj
  [ ("pattern_variables", en_dict en_root_term pm_info.pattern_variables)
  , ("substitution_list", en_substitution_list pm_info.substitution_list)
  ]
