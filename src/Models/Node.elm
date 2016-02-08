module Node where

type Node
  = NodeOpen -- TODO: implement open module
  | NodeComment Comment -- TODO: implement open module
  | NodeGrammar -- TODO: implement open module
  | NodeDefinition -- TODO: implement open module
  | NodeAlias -- TODO: implement open module
  | NodeRule -- TODO: implement open module
  | NodeThorem -- TODO: implement open module

type alias Comment = String
