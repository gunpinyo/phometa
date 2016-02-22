module Models.Node where

import Tools.OrderedDict exposing (OrderedDict)

type alias NodeName = String

type alias Comment = String

type alias NodeBase a = { a | comment : Comment }

type Node
  = NodeOpen -- TODO: implement open module
  | NodeComment Comment -- TODO: implement open module
  | NodeGrammar -- TODO: implement open module
  | NodeDefinition -- TODO: implement open module
  | NodeAlias Alias -- TODO: implement open module
  | NodeRule -- TODO: implement open module
  | NodeTheorem -- TODO: implement open module

type alias RawRegex = String

type alias Format = String

type alias VarName = String


type alias GrammarBase a = NodeBase { a | var_regex : Maybe RawRegex }

type alias GrammarRef = String

type Grammar
  = GrammarInd IndGrammar
  -- | GrammarLit LitGrammar
  -- | GrammarSequence Sequence -- TODO: implement this
  -- | GrammarDictionary Dictionary -- TODO: implement this

type alias IndGrammar =
  GrammarBase { choices : OrderedDict IndChoiceName IndChoice }

type alias IndChoiceName = String

-- constrain: formats must have length more than sub_grammars by 1
type alias IndChoice =
  { sub_grammars : List GrammarRef
  , formats : List Format
  }

-- type alias LitGrammar =
--   GrammarBase {
--     regex : RawRegex }

type Term
  = TermHole
  | TermVar VarName
  | TermInd IndChoiceName (List Term)
  -- | TermLit String
  -- | TermLetBe VarName Term Term         --  let v = t_1 in t_2
  -- | TermMatch Term (List (Term, Term))  --  match t_1 with [pat_{i} as t_{i}]

type alias RootTerm a =
  { a |
    grammar : GrammarRef
  , term : Term
  }

type alias Alias = RootTerm (NodeBase {})

type alias RuleRef = String

type Rule
  = RuleInference InferenceRule
  -- | RuleCompound CompoundRule

type alias InferenceRule =
  { premises : List (RootTerm {})
  , conclusion : RootTerm {}
  }

type alias Theorem = RootTerm { proof : Proof }

type Proof
  = ProofHole
  | ProofByRule RuleRef (List Theorem)
  | ProofByTheorem Theorem
  -- | ProofByPrimitive
