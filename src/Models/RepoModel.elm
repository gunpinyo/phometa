module Models.RepoModel where

import Dict exposing (Dict)

import Tools.OrderedDict exposing (OrderedDict)
import Tools.StripedList exposing (StripedList)

-- Common -------------------------------------------------------------------

-- generalisation of package, module, or node
type alias ContainerName = String

type alias ContainerPath = List ContainerName

type alias Comment = Maybe String

type alias RawRegex = String

type alias Format = String

type alias VarName = String

-- Package ---------------------------------------------------------------------

type alias PackageName = ContainerName

type alias PackagePath = List PackageName

type alias Package =
  { dict      : Dict ContainerName PackageElem
  , is_folded : Bool
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
  { -- imports  : List Import
    comment   : Comment
  , nodes     : OrderedDict NodeName Node
  , is_folded : Bool
  }

-- Node ------------------------------------------------------------------------

type alias NodeName = ContainerName

type alias NodePath =
  { module_path : ModulePath
  , node_name   : NodeName
  }

type alias NodeBase a =
  { a |
    comment   : Maybe Comment
  , is_folded : Bool
  }

type Node
  = NodeGrammar Grammar -- TODO: implement this
  | NodeDefinition Definition -- TODO: implement this
  | NodeRule Rule -- TODO: implement this
  | NodeTheorem Theorem-- TODO: implement this

-- Grammar ---------------------------------------------------------------------

type alias GrammarName = String

type alias Grammar =
  NodeBase
    { var_regex : Maybe RawRegex
    , choices   : List GrammarChoice
    }

type alias GrammarChoice = StripedList Format GrammarName

-- Term ------------------------------------------------------------------------

type Term
  = TermTodo
  | TermVar VarName
  | TermInd GrammarChoice (List Term)
  -- | TermLet (List VarName Term) Term    --  let [var_i = term_i]* in term
  -- | TermMatch Term (List (Term, Term))  --  match term with [pat_i as term_i]

type TermPath
  = TermPathCurrent
  | TermPathInd TermPath
  -- TermPathLet (Maybe Int) TermPath     -- Nothing, to term, Just i, to term_i
  -- TermPathMatch (Maybe (Int, Bool)) TermPath -- Nothing, to term
                                                -- (Just (False, i)), to pat_i
                                                -- (Just (True, i)), to term_i

type alias RootTerm =
  { grammar : GrammarName
  , term : Term
  }

-- Definition ------------------------------------------------------------------

type alias DefinitionName = StripedList Format GrammarName

type alias Definition =
  NodeBase
    { arguments : List VarName
    , root_term : RootTerm
    }

-- Rule ------------------------------------------------------------------------

type alias RuleName = String

type alias Rule =
  NodeBase
    { premises : List RootTerm
    , conclusion : RootTerm
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
  | ProofByRule RuleName (List Theorem)
  | ProofByLemma TheoremName
  -- | ProofByPrimitive
