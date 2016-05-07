module Models.RepoModel where

import Dict exposing (Dict)
import Regex exposing (Regex)

import Tools.OrderedDict exposing (OrderedDict)
import Tools.StripedList exposing (StripedList)

-- Common -------------------------------------------------------------------

-- generalisation of package, module, or node
type alias ContainerName = String

type alias ContainerPath = List ContainerName

type alias Format = String

type alias VarName = String

type alias Parameters =
  List { grammar  : GrammarName
       , var_name : VarName
       }

type alias Arguments = List RootTerm

-- Package ---------------------------------------------------------------------

type alias PackageName = ContainerName

type alias PackagePath = List PackageName

type alias Package =
  { is_folded : Bool
  , dict      : Dict ContainerName PackageElem
  }

type PackageElem
  = PackageElemPkg Package
  | PackageElemMod Module

-- Module ----------------------------------------------------------------------

type alias ModuleName = ContainerName

type alias ModulePath =
  { package_path : PackagePath
  , module_name  : ModuleName
  }

type alias Module =
  { is_folded : Bool
  , imports   : List ImportModule
  , nodes     : OrderedDict NodeName Node
  }

type alias ImportModule =
  { module_path     : ModulePath
  , show_by_default : Bool
  , imports         : List ImportNode
  }

type ImportNode
  = ImportNodeShow NodeName
  | ImportNodeHide NodeName
  | ImportNodeRename NodeName NodeName

-- Node ------------------------------------------------------------------------

type alias NodeName = ContainerName

type alias NodePath =
  { module_path : ModulePath
  , node_name   : NodeName
  }

type alias NodeBase a =
  { a |
    is_folded : Bool
  }

type Node
  = NodeComment String
  | NodeGrammar Grammar
  | NodeRule Rule
  | NodeTheorem Theorem Bool -- Bool = has_locked

type NodeType
  = NodeTypeComment
  | NodeTypeGrammar
  | NodeTypeRule
  | NodeTypeTheorem

-- Grammar ---------------------------------------------------------------------

type alias GrammarName = String

type alias Grammar =
  NodeBase
    { has_locked  : Bool
    , metavar_regex : Maybe Regex
    , literal_regex : Maybe Regex
    , choices     : List GrammarChoice
    }

type alias GrammarChoice = StripedList Format GrammarName

-- Term ------------------------------------------------------------------------

type Term
  = TermTodo
  | TermVar VarName
  | TermInd GrammarChoice (List Term)
  -- | TermLet (List VarName Term) Term    --  let [var_i = term_i]* in term
  -- | TermMatch Term (List (Term, Term))  --  match term with [pat_i as term_i]

type alias RootTerm =
  { grammar : GrammarName
  , term : Term
  }

type VarType
  = VarTypeMetaVar
  | VarTypeLiteral

-- Rule ------------------------------------------------------------------------

type alias RuleName = String

type alias Rule =
  NodeBase
    { has_locked  : Bool
    , allow_reduction : Bool  -- check `Models.RepoUtils.apply_reduction`
                              --   for usage of this field
    , parameters : Parameters
    , conclusion : RootTerm
    , premises : List Premise
    }

type Premise
  = PremiseDirect RootTerm
  | PremiseCascade (List PremiseCascadeRecord)

type alias PremiseCascadeRecord =
  { rule_name : RuleName
  , pattern : RootTerm
  , arguments : Arguments
  , allow_unification : Bool
  }

-- Theorem ---------------------------------------------------------------------

type alias TheoremName = String

type alias Theorem =
  NodeBase
    { goal : RootTerm
    , proof : Proof
    }

type Proof
  = ProofTodo
  | ProofTodoWithRule RuleName Arguments -- waiting user to enter arguments
  | ProofByRule RuleName Arguments PatternMatchingInfo (List Theorem)
  | ProofByLemma TheoremName PatternMatchingInfo

-- Pattern Matching / Unification ----------------------------------------------

type alias SubstitutionList =
  List { old_var : VarName
       , new_root_term : RootTerm
       }

type alias PatternMatchingInfo =
  { pattern_variables : Dict VarName RootTerm
  , substitution_list : SubstitutionList
  }
