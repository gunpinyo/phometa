module Models.RepoModel where

import Dict exposing (Dict)

import Tools.OrderedDict exposing (OrderedDict)
import Models.Pointer exposing (IntPointer, StrPointer)

-- PkgMod ----------------------------------------------------------------------

type alias PkgModName = String

-- Package ---------------------------------------------------------------------

type alias PackageName = PkgModName

type PackagePath
  = PackagePathCur
  | PackagePathPkg PackageName PackagePath

type alias Package =
  { dict      : Dict PkgModName PackageElem
  , is_folded : Bool
  , pointer   : StrPointer
  }

type PackageElem
  = PackageElemPkg Package
  | PackageElemMod Module

-- Module ----------------------------------------------------------------------

type alias ModuleName = PkgModName

type alias ModulePath =
  { package_path : PackagePath
  , module_name  : ModuleName
  }

type alias Module =
  { dict : OrderedDict NodeName Node
  , is_folded : Bool
  , pointer   : IntPointer
  }

-- Node ------------------------------------------------------------------------

type alias NodeName = String

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
  = NodeOpen -- TODO: implement open module
  | NodeComment Comment -- TODO: implement open module
  | NodeGrammar -- TODO: implement open module
  | NodeDefinition -- TODO: implement open module
  | NodeAlias Alias -- TODO: implement open module
  | NodeRule -- TODO: implement open module
  | NodeTheorem -- TODO: implement open module

-- Node common -----------------------------------------------------------------

type alias RawRegex = String

type alias Format = String

type alias VarName = String

-- Open ------------------------------------------------------------------------
-- TODO:

-- Comment ---------------------------------------------------------------------

type alias Comment = String

-- Grammar ---------------------------------------------------------------------

type alias GrammarName = String

type alias Grammar =
  NodeBase
    { var_regex : Maybe RawRegex
    , choices : OrderedDict GrammarChoiceName GrammarChoice
    }

type alias GrammarChoiceName = String

-- constrain: formats must have length more than sub_grammars by 1
type alias GrammarChoice =
  { sub_grammars : List GrammarName
  , formats : List Format
  }

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

--------------------------------------------------------------------------------

type alias Alias =
  NodeBase { root_term : RootTerm }

type alias RuleName = String

type Rule
  = RuleInference InferenceRule
  -- | RuleCompound CompoundRule

type alias InferenceRule =
  NodeBase
    { premises : List RootTerm
    , conclusion : RootTerm
    }

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
