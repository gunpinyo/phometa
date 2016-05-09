module Models.RepoEnDeJson where

import Dict exposing (Dict)
import Json.Encode exposing (Value)
import Json.Decode exposing (Decoder, (:=), customDecoder, succeed,
                             decodeString, decodeValue, keyValuePairs, value,
                             object1, object2, object3,
                             object4, object5, object6,
                             tuple1, tuple2, tuple4)
import Regex exposing (Regex)

import Tools.OrderedDict exposing (OrderedDict)
import Tools.StripedList exposing (striped_list_introduce
                                  ,striped_list_get_even_element
                                  ,striped_list_get_odd_element)
import Tools.RegexExtra exposing (safe_regex, regex_to_string)
import Models.RepoModel exposing (..)

-- Usage ------------------------------------------------------------------------

encode_repository : Package -> String
encode_repository = en_package >> Json.Encode.encode 2

decode_repository : String -> Result String Package
decode_repository = decodeString de_package

-- Utils -----------------------------------------------------------------------

en_str       : String -> Value
en_str       = Regex.replace Regex.All (Regex.regex "\\\\") (\_ -> "\\\\")
            >> Regex.replace Regex.All (Regex.regex "\\n") (\_ -> "\\n")
            >> Json.Encode.string

de_str       : Decoder String
de_str       = Json.Decode.string

en_int       : Int -> Value
en_int       = Json.Encode.int

de_int       : Decoder Int
de_int       = Json.Decode.int

en_bool      : Bool -> Value
en_bool      = Json.Encode.bool

de_bool      : Decoder Bool
de_bool      = Json.Decode.bool

en_list      : (a -> Value) -> List a -> Value
en_list func = List.map func >> Json.Encode.list

de_list      : Decoder a -> Decoder (List a)
de_list      = Json.Decode.list

en_obj       : List (String, Value) -> Value
en_obj       = Json.Encode.object

-- decode object by object1, object2, object3, etc

en_null      : Value
en_null      = Json.Encode.null

de_null      : a -> Decoder a
de_null      = Json.Decode.null

en_TODO : Value
en_TODO = Json.Encode.null -- for value that needed to be done in the future

de_TODO : a -> Decoder a
de_TODO = Json.Decode.succeed

en_bnf0 : String -> Value
en_bnf0 construct_name = en_obj
  [(construct_name, Json.Encode.list [])]

en_bnf1 : String -> Value -> Value
en_bnf1 construct_name a = en_obj
  [(construct_name, Json.Encode.list [a])]

en_bnf2 : String -> Value -> Value -> Value
en_bnf2 construct_name a b = en_obj
  [(construct_name, Json.Encode.list [a, b])]

en_bnf4 : String -> Value -> Value -> Value -> Value -> Value
en_bnf4 construct_name a b c d = en_obj
  [(construct_name, Json.Encode.list [a, b, c, d])]

-- credit: adapt from https://github.com/elm-lang/elm-compiler/issues/1244
de_bnf : String -> Dict String (() -> Decoder a) -> Decoder a
de_bnf name dict = customDecoder (keyValuePairs value) (\list -> case list of
  [(key, value)] -> case Dict.get key dict of
    Nothing  -> Err ("constructor " ++ key ++ " is not valid for " ++ name)
    Just dec -> decodeValue (dec ()) value
  _              -> Err ("cannot decode " ++ name ++
                         " because the corresponded object is not well-from"))

-- decode bnf by tuple1, tuple2, tuple3, etc instead

en_dict : (a -> Value) -> Dict String a -> Value
en_dict func dict = dict
  |> Dict.toList
  |> List.map (\ (key, val) -> (key, func val))
  |> en_obj

de_dict : Decoder a -> Decoder (Dict String a)
de_dict = Json.Decode.dict

en_ordered_dict : (a -> Value) -> OrderedDict String a -> Value
en_ordered_dict func ordered_dict = en_obj
  [ ("dict", en_dict func ordered_dict.dict)
  , ("order", en_list en_str ordered_dict.order)
  ]

de_ordered_dict : Decoder a -> Decoder (OrderedDict String a)
de_ordered_dict dec = object2 OrderedDict
  ("dict" := de_dict dec)
  ("order" := de_list de_str)

en_maybe_regex : Maybe Regex -> Value
en_maybe_regex maybe_regex = case maybe_regex of
  Nothing -> en_null
  Just regex -> en_str (regex_to_string regex)

de_maybe_regex : Decoder (Maybe Regex)
de_maybe_regex =
  Json.Decode.maybe (customDecoder de_str
    (\raw_regex -> case safe_regex raw_regex of
        Nothing -> Err ("regex " ++ raw_regex ++ " is not valid pattern")
        Just regex -> Ok regex))

-- Common ----------------------------------------------------------------------

en_format : Format -> Value
en_format = en_str

de_format : Decoder Format
de_format = de_str

en_var_name : VarName -> Value
en_var_name = en_str

de_var_name : Decoder VarName
de_var_name = de_str

en_parameters : Parameters -> Value
en_parameters parameters =
  en_list (\param -> en_obj
            [ ("grammar", en_grammar_name param.grammar)
            , ("var_name", en_var_name param.var_name)
            ]) parameters

de_parameters : Decoder Parameters
de_parameters = de_list <| object2
  (\grammar var_name -> { grammar = grammar
                        , var_name = var_name })
  ("grammar" := de_grammar_name)
  ("var_name" := de_var_name)

en_arguments : Arguments -> Value
en_arguments arguments = en_list en_root_term arguments

de_arguments : Decoder Arguments
de_arguments = de_list de_root_term

-- Package ---------------------------------------------------------------------

en_package_name : PackageName -> Value
en_package_name = en_str

de_package_name : Decoder PackageName
de_package_name = de_str

en_package_path : PackagePath -> Value
en_package_path = en_list en_package_name

de_package_path : Decoder PackagePath
de_package_path = de_list de_package_name

en_package : Package -> Value
en_package package = en_obj
  [ ("is_folded", en_bool package.is_folded)
  , ("dict", en_dict en_package_elem package.dict)
  ]

de_package : Decoder Package
de_package = object2 Package
  ("is_folded" := de_bool)
  ("dict" :=  de_dict de_package_elem)

en_package_elem : PackageElem -> Value
en_package_elem package_elem = case package_elem of
  PackageElemPkg package' -> en_bnf1 "PackageElemPkg" (en_package package')
  PackageElemMod module'  -> en_bnf1 "PackageElemMod" (en_module module')

de_package_elem : Decoder PackageElem
de_package_elem = de_bnf "PackageElem" <| Dict.fromList
  [ ("PackageElemPkg", \ () -> tuple1 PackageElemPkg de_package)
  , ("PackageElemMod", \ () -> tuple1 PackageElemMod de_module)
  ]

-- Module ----------------------------------------------------------------------

en_module_name : ModuleName -> Value
en_module_name = en_str

de_module_name : Decoder ModuleName
de_module_name = de_str

en_module_path : ModulePath -> Value
en_module_path module_path = en_obj
  [ ("package_path", en_package_path module_path.package_path)
  , ("module_name", en_module_name module_path.module_name)
  ]

de_module_path : Decoder ModulePath
de_module_path = object2 ModulePath
  ("package_path" := de_package_path)
  ("module_name" := de_module_name)

en_module : Module -> Value
en_module module' = en_obj
  [ ("is_folded", en_bool module'.is_folded)
  , ("imports", en_list en_import_module module'.imports)
  , ("nodes", en_ordered_dict en_node module'.nodes)
  ]

de_module : Decoder Module
de_module = object3 Module
  ("is_folded" := de_bool)
  ("imports" := de_TODO [])
  ("nodes" := de_ordered_dict de_node)

en_import_module : ImportModule -> Value
en_import_module import_module = en_TODO -- TODO:

-- de_import_module : Decoder ImportModule
-- de_import_module = import_module = en_TODO

-- Node ------------------------------------------------------------------------

en_node_name : NodeName -> Value
en_node_name = en_str

de_node_name : Decoder NodeName
de_node_name = de_str

en_node_path : NodePath -> Value
en_node_path node_path = en_obj
  [ ("module_path", en_module_path node_path.module_path)
  , ("node_name", en_node_name node_path.node_name)
  ]

de_node_path : Decoder NodePath
de_node_path = object2 NodePath
  ("module_path" := de_module_path)
  ("node_name" := de_node_name)

en_node : Node -> Value
en_node node = case node of
  NodeComment comment -> en_bnf1 "NodeComment" (en_str comment)
  NodeGrammar grammar -> en_bnf1 "NodeGrammar" (en_grammar grammar)
  NodeRule rule       -> en_bnf1 "NodeRule" (en_rule rule)
  NodeTheorem theorem has_locked -> en_bnf2 "NodeTheorem"
    (en_theorem theorem) (en_bool has_locked)

de_node : Decoder Node
de_node = de_bnf "Node" <| Dict.fromList
  [ ("NodeComment",  \ () -> tuple1 NodeComment de_str)
  , ("NodeGrammar",  \ () -> tuple1 NodeGrammar de_grammar)
  , ("NodeRule",     \ () -> tuple1 NodeRule    de_rule)
  , ("NodeTheorem",  \ () -> tuple2 NodeTheorem de_theorem de_bool)
  ]

en_node_type : NodeType -> Value
en_node_type node_type = case node_type of
  NodeTypeComment -> en_bnf0 "NodeTypeComment"
  NodeTypeGrammar -> en_bnf0 "NodeTypeGrammar"
  NodeTypeRule    -> en_bnf0 "NodeTypeRule"
  NodeTypeTheorem -> en_bnf0 "NodeTypeTheorem"

de_node_type : Decoder NodeType
de_node_type = de_bnf "NodeType" <| Dict.fromList
  [ ("NodeTypeComment", \ () -> succeed NodeTypeComment)
  , ("NodeTypeGrammar", \ () -> succeed NodeTypeGrammar)
  , ("NodeTypeRule"   , \ () -> succeed NodeTypeRule)
  , ("NodeTypeTheorem", \ () -> succeed NodeTypeTheorem)
  ]

-- Grammar ---------------------------------------------------------------------

en_grammar_name : GrammarName -> Value
en_grammar_name = en_str

de_grammar_name : Decoder GrammarName
de_grammar_name = de_str

en_grammar : Grammar -> Value
en_grammar grammar = en_obj
  [ ("is_folded", en_bool grammar.is_folded)
  , ("has_locked",  en_bool grammar.has_locked)
  , ("metavar_regex", en_maybe_regex grammar.metavar_regex)
  , ("literal_regex", en_maybe_regex grammar.literal_regex)
  , ("choices", en_list en_grammar_choice grammar.choices)
  ]

de_grammar : Decoder Grammar
de_grammar = object5 Grammar
  ("is_folded" := de_bool)
  ("has_locked" := de_bool)
  ("metavar_regex" := de_maybe_regex)
  ("literal_regex" := de_maybe_regex)
  ("choices" := de_list de_grammar_choice)

en_grammar_choice : GrammarChoice -> Value
en_grammar_choice grammar_choice = en_obj
  [ ("formats",
       en_list en_grammar_name (striped_list_get_even_element grammar_choice))
  , ("sub_grammars",
       en_list en_grammar_name (striped_list_get_odd_element grammar_choice))
  ]

de_grammar_choice : Decoder GrammarChoice
de_grammar_choice = object2 striped_list_introduce
  ("formats" := de_list de_grammar_name)
  ("sub_grammars" := de_list de_format)

-- Term ------------------------------------------------------------------------

en_term : Term -> Value
en_term term = case term of
  TermTodo         -> en_bnf0 "TermTodo"
  TermVar var_name -> en_bnf1 "TermVar" (en_var_name var_name)
  TermInd grammar_choice sub_terms -> en_bnf2 "TermInd"
    (en_grammar_choice grammar_choice) (en_list en_term sub_terms)

de_term : Decoder Term
de_term = de_bnf "Term" <| Dict.fromList
  [ ("TermTodo", \ () -> succeed TermTodo)
  , ("TermVar" , \ () -> tuple1 TermVar de_var_name)
  , ("TermInd" , \ () -> tuple2 TermInd de_grammar_choice (de_list de_term))
  ]

en_root_term : RootTerm -> Value
en_root_term root_term = en_obj
  [ ("grammar", en_grammar_name root_term.grammar)
  , ("term", en_term root_term.term)
  ]

de_root_term : Decoder RootTerm
de_root_term = object2 RootTerm
  ("grammar" := de_grammar_name)
  ("term" := de_term)

en_var_type : VarType -> Value
en_var_type var_type = case var_type of
  VarTypeMetaVar -> en_bnf0 "VarTypeMetaVar"
  VarTypeLiteral -> en_bnf0 "VarTypeLiteral"

de_var_type : Decoder VarType
de_var_type = de_bnf "VarType" <| Dict.fromList
  [ ("VarTypeMetaVar", \ () -> succeed VarTypeMetaVar)
  , ("VarTypeLiteral", \ () -> succeed VarTypeLiteral)
  ]

-- Rule ------------------------------------------------------------------------

en_rule_name : RuleName -> Value
en_rule_name = en_str

de_rule_name : Decoder RuleName
de_rule_name = de_str

en_rule : Rule -> Value
en_rule rule = en_obj
  [ ("is_folded", en_bool rule.is_folded)
  , ("has_locked",  en_bool rule.has_locked)
  , ("allow_reduction", en_bool rule.allow_reduction)
  , ("parameters", en_parameters rule.parameters)
  , ("conclusion", en_root_term rule.conclusion)
  , ("premises", en_list en_premise rule.premises)
  ]

de_rule : Decoder Rule
de_rule = object6 Rule
  ("is_folded" := de_bool)
  ("has_locked" := de_bool)
  ("allow_reduction" := de_bool)
  ("parameters" := de_parameters)
  ("conclusion" := de_root_term)
  ("premises" := de_list de_premise)

en_premise : Premise -> Value
en_premise premise = case premise of
  PremiseDirect pattern -> en_bnf1 "PremiseDirect" (en_root_term pattern)
  PremiseCascade records -> en_bnf1 "PremiseCascade"
    (en_list en_premise_cascade_record records)

de_premise : Decoder Premise
de_premise = de_bnf "Premise" <| Dict.fromList
  [ ("PremiseDirect",  \ () -> tuple1 PremiseDirect de_root_term)
  , ("PremiseCascade", \ () -> tuple1 PremiseCascade
                                (de_list de_premise_cascade_record))
  ]

en_premise_cascade_record : PremiseCascadeRecord -> Value
en_premise_cascade_record record = en_obj
  [ ("rule_name", en_rule_name record.rule_name)
  , ("pattern", en_root_term record.pattern)
  , ("arguments", en_arguments record.arguments)
  , ("allow_unification", en_bool record.allow_unification)
  ]

de_premise_cascade_record : Decoder PremiseCascadeRecord
de_premise_cascade_record = object4 PremiseCascadeRecord
  ("rule_name" := de_rule_name)
  ("pattern" := de_root_term)
  ("arguments" := de_arguments)
  ("allow_unification" := de_bool)

-- Theorem ---------------------------------------------------------------------

en_theorem_name : TheoremName -> Value
en_theorem_name = en_str

de_theorem_name : Decoder TheoremName
de_theorem_name = de_str

en_theorem : Theorem -> Value
en_theorem theorem = en_obj
  [ ("is_folded", en_bool theorem.is_folded)
  , ("goal", en_root_term theorem.goal)
  , ("proof", en_proof theorem.proof)
  ]

de_theorem : Decoder Theorem
de_theorem = object3 Theorem
  ("is_folded" := de_bool)
  ("goal" := de_root_term)
  ("proof" := de_proof)

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

de_proof : Decoder Proof
de_proof = de_bnf "Proof" <| Dict.fromList
  [ ("ProofTodo", \ () -> succeed ProofTodo)
  , ("ProofTodoWithRule", \ () -> tuple2 ProofTodoWithRule
                                    de_rule_name de_arguments)
  , ("ProofByRule", \ () -> tuple4 ProofByRule de_rule_name de_arguments
                             de_pattern_matching_info (de_list de_theorem))
  , ("ProofByLemma", \ () -> tuple2 ProofByLemma de_theorem_name
                              de_pattern_matching_info)
  ]

-- Pattern Matching / Unification ----------------------------------------------

en_substitution_list : SubstitutionList -> Value
en_substitution_list subst_list =
  en_list (\subst_elem -> en_obj
             [ ("old_var", en_var_name subst_elem.old_var)
             , ("new_root_term", en_root_term subst_elem.new_root_term)])
          subst_list

de_substitution_list : Decoder SubstitutionList
de_substitution_list = de_list <| object2
  (\old_var new_root_term -> { old_var = old_var
                             , new_root_term = new_root_term})
  ("old_var" := de_var_name)
  ("new_root_term" := de_root_term)

en_pattern_matching_info : PatternMatchingInfo -> Value
en_pattern_matching_info pm_info = en_obj
  [ ("pattern_variables", en_dict en_root_term pm_info.pattern_variables)
  , ("substitution_list", en_substitution_list pm_info.substitution_list)
  ]

de_pattern_matching_info : Decoder PatternMatchingInfo
de_pattern_matching_info = object2 PatternMatchingInfo
  ("pattern_variables" := de_dict de_root_term)
  ("substitution_list" := de_substitution_list)
