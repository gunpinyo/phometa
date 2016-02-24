module Models.RepoModel where

import Dict exposing (Dict)

import Tools.OrderedDict exposing (OrderedDict)

-- Common -------------------------------------------------------------------

-- generalise for package, module, or node
type alias ContainerName = String

type alias ContainerPath = List ContainerName

type alias Comment = Maybe String

-- for any string that allow to use mixfix
type alias Mixfixable = String

mixfix_hole : String
mixfix_hole = "⁑"

type alias RawRegex = String

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
    , choices   : OrderedDict GrammarChoiceName (List GrammarName)
    }

type alias GrammarChoiceName = Mixfixable

-- Term ------------------------------------------------------------------------

type Term
  = TermTodo
  | TermVar VarName
  | TermInd GrammarChoiceName (List Term)
  -- | TermLetBe VarName Term Term         --  let v = t_1 in t_2
  -- | TermMatch Term (List (Term, Term))  --  match t_1 with [pat_{i} as t_{i}]

type alias RootTerm =
  { grammar : GrammarName
  , term : Term
  }

type TermPath
  = TermPathCurrent
  | TermPathInd GrammarChoiceName TermPath
  -- TermPathLetBe Bool TermPath -- Bool, then t_2 else t_1
  -- TermPathMatch Int Bool Term -- Int, pattern order, Bool, then pat else t


-- Definition ------------------------------------------------------------------

type alias DefinitionName = Mixfixable

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

type alias Theorem =
  NodeBase
    { goal : RootTerm
    , proof : Proof
    }

type Proof
  = ProofHole
  | ProofByRule RuleName (List Theorem)
  | ProofByTheorem Theorem
  -- | ProofByPrimitive
