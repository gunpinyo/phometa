module Models.RepoStdlib where

import Dict exposing (Dict)
import Regex exposing (regex)

import Focus

import Tools.OrderedDict exposing (ordered_dict_from_list)
import Tools.StripedList exposing (striped_list_introduce)
import Models.Focus exposing (dict_)
import Models.RepoModel exposing (..)
import Models.RepoUtils exposing (..)


init_package_with_stdlib : Package
init_package_with_stdlib =
  Focus.update
    dict_
    (Dict.insert "Standard Library" (PackageElemPkg stdlib_package))
    init_package

stdlib_package : Package
stdlib_package =
  { dict = Dict.fromList [
      ("Propositional Logic", PackageElemMod {
        comment = Nothing,
        nodes = ordered_dict_from_list [
          ("Prop", NodeGrammar {
            comment = Nothing,
            is_folded = False,
            has_locked = True,
            metavar_regex = Just (regex "^[A-Z][a-zA-Z]*([1-9][0-9]*|'*)$"),
            literal_regex = Nothing,
            choices = [
              striped_list_introduce ["⊤"] [],
              striped_list_introduce ["⊥"] [],
              striped_list_introduce ["", ""] ["Atom"],
              striped_list_introduce ["", "∧", ""] ["Prop", "Prop"],
              striped_list_introduce ["", "∨", ""] ["Prop", "Prop"],
              striped_list_introduce ["¬", ""] ["Prop"],
              striped_list_introduce ["", "→", ""] ["Prop", "Prop"],
              striped_list_introduce ["", "↔", ""] ["Prop", "Prop"]
            ]
          }),
          ("Atom", NodeGrammar {
            comment = Nothing,
            is_folded = False,
            has_locked = True,
            metavar_regex = Nothing,
            literal_regex = Just (regex "^[a-z]+([1-9][0-9]*|'*)$"),
            choices = []
          }),
          ("Context", NodeGrammar {
            comment = Nothing,
            is_folded = False,
            has_locked = True,
            metavar_regex = Just (regex "^[ΓΔ]([1-9][0-9]*|'*)$"),
            literal_regex = Nothing,
            choices = [
              striped_list_introduce ["ε"] [],
              striped_list_introduce ["", ",", ""] ["Context", "Prop"]
            ]
          }),
          ("Judgement", NodeGrammar {
            comment = Nothing,
            is_folded = False,
            has_locked = True,
            metavar_regex = Nothing,
            literal_regex = Nothing,
            choices = [
              striped_list_introduce ["", "⊢", ""] ["Context", "Prop"]
            ]
          }),
          ("hypothesis-base", NodeRule {
            comment = Nothing,
            is_folded = False,
            has_locked = True,
            allow_reduction = False,
            parameters = [],
            conclusion =
              { grammar = "Judgement"
              , term = TermInd (striped_list_introduce ["", "⊢", ""] ["Context", "Prop"])
                  [ TermInd (striped_list_introduce ["", ",", ""] ["Context", "Prop"])
                     [TermVar "Γ", TermVar "A"]
                  , TermVar "A"
                  ]
              },
            premises = []
          }),
          ("hypothesis", NodeRule {
            comment = Nothing,
            is_folded = False,
            has_locked = True,
            allow_reduction = False,
            parameters = [],
            conclusion =
              { grammar = "Judgement"
              , term = TermInd (striped_list_introduce ["", "⊢", ""] ["Context", "Prop"])
                  [ TermInd (striped_list_introduce ["", ",", ""] ["Context", "Prop"])
                     [TermVar "Γ", TermVar "B"]
                  , TermVar "A"
                  ]
              },
            premises = [ PremiseCascade
              [ { rule_name = "hypothesis-base"
                , pattern =
                    { grammar = "Judgement"
                    , term = TermInd (striped_list_introduce ["", "⊢", ""] ["Context", "Prop"])
                        [ TermInd (striped_list_introduce ["", ",", ""] ["Context", "Prop"])
                           [TermVar "Γ", TermVar "B"]
                        , TermVar "A"
                        ]
                    }
                , arguments = []
                , allow_unification = False
                }
              , { rule_name = "hypothesis"
                , pattern =
                    { grammar = "Judgement"
                    , term = TermInd (striped_list_introduce ["", "⊢", ""] ["Context", "Prop"])
                        [ TermVar "Γ", TermVar "A" ]
                    }
                , arguments = []
                , allow_unification = False
                }
              ] ]
          }),
          ("top-intro", NodeRule {
            comment = Nothing,
            is_folded = False,
            has_locked = True,
            allow_reduction = False,
            parameters = [],
            conclusion = {
              grammar = "Judgement"
              , term = TermInd (striped_list_introduce ["", "⊢", ""] ["Context", "Prop"])
                    [TermVar "Γ", TermInd (striped_list_introduce ["⊤"] []) []]
              },
            premises = []
          }),
          ("bottom-elim", NodeRule {
            comment = Nothing,
            is_folded = False,
            has_locked = True,
            allow_reduction = False,
            parameters = [],
            conclusion = {
              grammar = "Judgement"
              , term = TermInd (striped_list_introduce ["", "⊢", ""] ["Context", "Prop"])
                    [TermVar "Γ", TermVar "A"]
              },
            premises = [
              PremiseDirect
                { grammar = "Judgement"
                , term = TermInd (striped_list_introduce ["", "⊢", ""] ["Context", "Prop"])
                    [TermVar "Γ", TermInd (striped_list_introduce ["⊥"] []) []]
                }]
          }),
          ("and-intro", NodeRule {
            comment = Nothing,
            is_folded = False,
            has_locked = True,
            allow_reduction = False,
            parameters = [],
            conclusion = {
              grammar = "Judgement"
              , term = TermInd (striped_list_introduce ["", "⊢", ""] ["Context", "Prop"])
                  [ TermVar "Γ"
                  , TermInd (striped_list_introduce ["", "∧", ""] ["Prop", "Prop"])
                      [TermVar "A", TermVar "B"]
                  ]
              },
            premises = [
              PremiseDirect
                { grammar = "Judgement"
                , term = TermInd (striped_list_introduce ["", "⊢", ""] ["Context", "Prop"])
                    [TermVar "Γ", TermVar "A"]
                },
              PremiseDirect
                { grammar = "Judgement"
                , term = TermInd (striped_list_introduce ["", "⊢", ""] ["Context", "Prop"])
                    [TermVar "Γ", TermVar "B"]
                }]
          }),
          ("and-elim-left", NodeRule {
            comment = Nothing,
            is_folded = False,
            has_locked = True,
            allow_reduction = False,
            parameters = [{ grammar = "Prop", var_name = "B" }],
            conclusion = {
              grammar = "Judgement"
              , term = TermInd (striped_list_introduce ["", "⊢", ""] ["Context", "Prop"])
                  [TermVar "Γ", TermVar "A"]
              },
            premises = [
              PremiseDirect
                { grammar = "Judgement"
                , term = TermInd (striped_list_introduce ["", "⊢", ""] ["Context", "Prop"])
                    [ TermVar "Γ"
                    , TermInd (striped_list_introduce ["", "∧", ""] ["Prop", "Prop"])
                        [TermVar "A", TermVar "B"]
                    ]
                }]
          }),
          ("and-elim-right", NodeRule {
            comment = Nothing,
            is_folded = False,
            has_locked = True,
            allow_reduction = False,
            parameters = [{ grammar = "Prop", var_name = "A" }],
            conclusion = {
              grammar = "Judgement"
              , term = TermInd (striped_list_introduce ["", "⊢", ""] ["Context", "Prop"])
                  [TermVar "Γ", TermVar "B"]
              },
            premises = [
              PremiseDirect
                { grammar = "Judgement"
                , term = TermInd (striped_list_introduce ["", "⊢", ""] ["Context", "Prop"])
                    [ TermVar "Γ"
                    , TermInd (striped_list_introduce ["", "∧", ""] ["Prop", "Prop"])
                        [TermVar "A", TermVar "B"]
                    ]
                }]
          }),
          ("or-intro-left", NodeRule {
            comment = Nothing,
            is_folded = False,
            has_locked = True,
            allow_reduction = False,
            parameters = [],
            conclusion = {
              grammar = "Judgement"
              , term = TermInd (striped_list_introduce ["", "⊢", ""] ["Context", "Prop"])
                  [ TermVar "Γ"
                  , TermInd (striped_list_introduce ["", "∨", ""] ["Prop", "Prop"])
                      [TermVar "A", TermVar "B"]
                  ]
              },
            premises = [
              PremiseDirect
                { grammar = "Judgement"
                , term = TermInd (striped_list_introduce ["", "⊢", ""] ["Context", "Prop"])
                    [ TermVar "Γ", TermVar "A"
                    ]
                }]
          }),
          ("or-intro-right", NodeRule {
            comment = Nothing,
            is_folded = False,
            has_locked = True,
            allow_reduction = False,
            parameters = [],
            conclusion = {
              grammar = "Judgement"
              , term = TermInd (striped_list_introduce ["", "⊢", ""] ["Context", "Prop"])
                  [ TermVar "Γ"
                  , TermInd (striped_list_introduce ["", "∨", ""] ["Prop", "Prop"])
                      [TermVar "A", TermVar "B"]
                  ]
              },
            premises = [
              PremiseDirect
                { grammar = "Judgement"
                , term = TermInd (striped_list_introduce ["", "⊢", ""] ["Context", "Prop"])
                    [ TermVar "Γ", TermVar "B"
                    ]
                }]
          }),
          ("or-elim", NodeRule {
            comment = Nothing,
            is_folded = False,
            has_locked = True,
            allow_reduction = False,
            parameters = [ { grammar = "Prop", var_name = "A" }
                         , { grammar = "Prop", var_name = "B" }
                         ],
            conclusion =
              { grammar = "Judgement"
              , term = TermInd (striped_list_introduce ["", "⊢", ""] ["Context", "Prop"])
                  [ TermVar "Γ", TermVar "C"]
              },
            premises = [
              PremiseDirect
                { grammar = "Judgement"
                , term = TermInd (striped_list_introduce ["", "⊢", ""] ["Context", "Prop"])
                    [TermVar "Γ", TermInd (striped_list_introduce ["", "∨", ""] ["Prop", "Prop"]) [TermVar "A", TermVar "B"]]
                },
              PremiseDirect
                { grammar = "Judgement"
                , term = TermInd (striped_list_introduce ["", "⊢", ""] ["Context", "Prop"])
                    [TermInd (striped_list_introduce ["", ",", ""] ["Context", "Prop"]) [TermVar "Γ", TermVar "A"], TermVar "C"]
                },
              PremiseDirect
                { grammar = "Judgement"
                , term = TermInd (striped_list_introduce ["", "⊢", ""] ["Context", "Prop"])
                    [TermInd (striped_list_introduce ["", ",", ""] ["Context", "Prop"]) [TermVar "Γ", TermVar "B"], TermVar "C"]
                }
            ]
          }),
          ("not-intro", NodeRule {
            comment = Nothing,
            is_folded = False,
            has_locked = True,
            allow_reduction = False,
            parameters = [],
            conclusion =
              { grammar = "Judgement"
              , term = TermInd (striped_list_introduce ["", "⊢", ""] ["Context", "Prop"])
                  [ TermVar "Γ", TermInd (striped_list_introduce ["¬", ""] ["Prop"]) [TermVar "A"]]
              },
            premises = [
              PremiseDirect
                { grammar = "Judgement"
                , term = TermInd (striped_list_introduce ["", "⊢", ""] ["Context", "Prop"])
                    [TermInd (striped_list_introduce ["", ",", ""] ["Context", "Prop"]) [TermVar "Γ", TermVar "A"],
                       TermInd (striped_list_introduce ["⊥"] []) []]
                }
            ]
          }),
          ("not-elim", NodeRule {
            comment = Nothing,
            is_folded = False,
            has_locked = True,
            allow_reduction = False,
            parameters = [{ grammar = "Prop", var_name = "A" }],
            conclusion =
              { grammar = "Judgement"
              , term = TermInd (striped_list_introduce ["", "⊢", ""] ["Context", "Prop"])
                  [ TermVar "Γ", TermInd (striped_list_introduce ["⊥"] []) []]
              },
            premises = [
              PremiseDirect
                { grammar = "Judgement"
                , term = TermInd (striped_list_introduce ["", "⊢", ""] ["Context", "Prop"])
                    [ TermVar "Γ", TermInd (striped_list_introduce ["¬", ""] ["Prop"]) [TermVar "A"]]
                },
              PremiseDirect
                { grammar = "Judgement"
                , term = TermInd (striped_list_introduce ["", "⊢", ""] ["Context", "Prop"])
                    [ TermVar "Γ", TermVar "A" ]
                }
            ]
          }),
          ("double-negation", NodeRule {
            comment = Nothing,
            is_folded = False,
            has_locked = True,
            allow_reduction = False,
            parameters = [],
            conclusion =
              { grammar = "Judgement"
              , term = TermInd (striped_list_introduce ["", "⊢", ""] ["Context", "Prop"])
                  [ TermVar "Γ", TermInd (striped_list_introduce ["¬", ""] ["Prop"])
                      [TermInd (striped_list_introduce ["¬", ""] ["Prop"]) [TermVar "A"]]]
              },
            premises = [
              PremiseDirect
                { grammar = "Judgement"
                , term = TermInd (striped_list_introduce ["", "⊢", ""] ["Context", "Prop"])
                    [TermVar "Γ", TermVar "A"]
                }
            ]
          }),
          ("proof-by-contradiction", NodeRule {
            comment = Nothing,
            is_folded = False,
            has_locked = True,
            allow_reduction = False,
            parameters = [],
            conclusion =
              { grammar = "Judgement"
              , term = TermInd (striped_list_introduce ["", "⊢", ""] ["Context", "Prop"])
                  [ TermVar "Γ", TermVar "A"]
              },
            premises = [
              PremiseDirect
                { grammar = "Judgement"
                , term = TermInd (striped_list_introduce ["", "⊢", ""] ["Context", "Prop"])
                    [TermInd (striped_list_introduce ["", ",", ""] ["Context", "Prop"])
                       [TermVar "Γ", TermInd (striped_list_introduce ["¬", ""] ["Prop"]) [TermVar "A"]],
                       TermInd (striped_list_introduce ["⊥"] []) []]
                }
            ]
          }),
          ("imply-intro", NodeRule {
            comment = Nothing,
            is_folded = False,
            has_locked = True,
            allow_reduction = False,
            parameters = [],
            conclusion =
              { grammar = "Judgement"
              , term = TermInd (striped_list_introduce ["", "⊢", ""] ["Context", "Prop"])
                  [ TermVar "Γ", TermInd (striped_list_introduce ["", "→", ""] ["Prop", "Prop"]) [TermVar "A", TermVar "B"]]
              },
            premises = [
              PremiseDirect
                { grammar = "Judgement"
                , term = TermInd (striped_list_introduce ["", "⊢", ""] ["Context", "Prop"])
                    [TermInd (striped_list_introduce ["", ",", ""] ["Context", "Prop"]) [TermVar "Γ", TermVar "A"], TermVar "B"]
                }
            ]
          }),
          ("imply-elim", NodeRule {
            comment = Nothing,
            is_folded = False,
            has_locked = True,
            allow_reduction = False,
            parameters = [{ grammar = "Prop", var_name = "A" }],
            conclusion =
              { grammar = "Judgement"
              , term = TermInd (striped_list_introduce ["", "⊢", ""] ["Context", "Prop"])
                  [ TermVar "Γ", TermVar "B"]
              },
            premises = [
              PremiseDirect
                { grammar = "Judgement"
                , term = TermInd (striped_list_introduce ["", "⊢", ""] ["Context", "Prop"])
                    [TermVar "Γ", TermInd (striped_list_introduce ["", "→", ""] ["Prop", "Prop"]) [TermVar "A", TermVar "B"]]
                },
              PremiseDirect
                { grammar = "Judgement"
                , term = TermInd (striped_list_introduce ["", "⊢", ""] ["Context", "Prop"])
                    [TermVar "Γ", TermVar "A"]
                }
            ]
          }),
          ("iff-intro", NodeRule {
            comment = Nothing,
            is_folded = False,
            has_locked = True,
            allow_reduction = False,
            parameters = [],
            conclusion =
              { grammar = "Judgement"
              , term = TermInd (striped_list_introduce ["", "⊢", ""] ["Context", "Prop"])
                  [ TermVar "Γ", TermInd (striped_list_introduce ["", "↔", ""] ["Prop", "Prop"]) [TermVar "A", TermVar "B"]]
              },
            premises = [
              PremiseDirect
                { grammar = "Judgement"
                , term = TermInd (striped_list_introduce ["", "⊢", ""] ["Context", "Prop"])
                    [TermInd (striped_list_introduce ["", ",", ""] ["Context", "Prop"]) [TermVar "Γ", TermVar "A"], TermVar "B"]
                },
              PremiseDirect
                { grammar = "Judgement"
                , term = TermInd (striped_list_introduce ["", "⊢", ""] ["Context", "Prop"])
                    [TermInd (striped_list_introduce ["", ",", ""] ["Context", "Prop"]) [TermVar "Γ", TermVar "B"], TermVar "A"]
                }
            ]
          }),
          ("iff-elim-forward", NodeRule {
            comment = Nothing,
            is_folded = False,
            has_locked = True,
            allow_reduction = False,
            parameters = [{ grammar = "Prop", var_name = "A" }],
            conclusion =
              { grammar = "Judgement"
              , term = TermInd (striped_list_introduce ["", "⊢", ""] ["Context", "Prop"])
                  [ TermVar "Γ", TermVar "B"]
              },
            premises = [
              PremiseDirect
                { grammar = "Judgement"
                , term = TermInd (striped_list_introduce ["", "⊢", ""] ["Context", "Prop"])
                    [TermVar "Γ", TermInd (striped_list_introduce ["", "↔", ""] ["Prop", "Prop"]) [TermVar "A", TermVar "B"]]
                },
              PremiseDirect
                { grammar = "Judgement"
                , term = TermInd (striped_list_introduce ["", "⊢", ""] ["Context", "Prop"])
                    [TermVar "Γ", TermVar "A"]
                }
            ]
          }),
          ("iff-elim-backward", NodeRule {
            comment = Nothing,
            is_folded = False,
            has_locked = True,
            allow_reduction = False,
            parameters = [{ grammar = "Prop", var_name = "B" }],
            conclusion =
              { grammar = "Judgement"
              , term = TermInd (striped_list_introduce ["", "⊢", ""] ["Context", "Prop"])
                  [ TermVar "Γ", TermVar "A"]
              },
            premises = [
              PremiseDirect
                { grammar = "Judgement"
                , term = TermInd (striped_list_introduce ["", "⊢", ""] ["Context", "Prop"])
                    [TermVar "Γ", TermInd (striped_list_introduce ["", "↔", ""] ["Prop", "Prop"]) [TermVar "A", TermVar "B"]]
                },
              PremiseDirect
                { grammar = "Judgement"
                , term = TermInd (striped_list_introduce ["", "⊢", ""] ["Context", "Prop"])
                    [TermVar "Γ", TermVar "B"]
                }
            ]
          }),
          ("prop-intro", NodeRule {
            comment = Nothing,
            is_folded = False,
            has_locked = True,
            allow_reduction = False,
            parameters = [],
            conclusion =
              { grammar = "Prop"
              , term = TermVar "A"
              },
            premises = [
              PremiseDirect
                { grammar = "Judgement"
                , term = TermInd (striped_list_introduce ["", "⊢", ""] ["Context", "Prop"])
                    [TermInd (striped_list_introduce ["ε"] []) [], TermVar "A"]
                }
            ]
          }),
          -- TODO: remove this from stdlib
          ("theorem-1", NodeTheorem init_theorem False),
          -- TODO: remove this from stdlib
          ("theorem-2", NodeTheorem init_theorem False)
        ],
        is_folded = False
      }) -- ,
      --( "Simply type lambda calculus", PackageElemMod {
      --   comment = Nothing,
      --   nodes = ordered_dict_from_list [
      --     ("Term", NodeGrammar {
      --       comment = Nothing,
      --       is_folded = False,
      --       var_regex = Just "[M-Z]([1-9][0-9]*|'*)",
      --       choices = [
      --         striped_list_introduce ["", ""] ["Variable"],
      --         striped_list_introduce ["λ", ":", ".", ""] ["Variable", "Type", "Term"],
      --         striped_list_introduce ["", "", ""] ["Term", "Term"]
      --       ]
      --     }),
      --     ("Variable", NodeGrammar {
      --       comment = Nothing,
      --       is_folded = False,
      --       var_regex = Just "[a-z]([1-9][0-9]*|'*)",
      --       choices = []
      --     }),
      --     ("Type", NodeGrammar {
      --       comment = Nothing,
      --       is_folded = False,
      --       var_regex = Just "[A-L]([1-9][0-9]*|'*)",
      --       choices = [
      --         striped_list_introduce ["", "→", ""] ["Type", "Type"]
      --       ]
      --     }),
      --     ("Judgement", NodeGrammar {
      --       comment = Nothing,
      --       is_folded = False,
      --       var_regex = Nothing,
      --       choices = [
      --         striped_list_introduce ["", ":", ""] ["Term", "Type"]
      --       ]
      --     }),
      --     ("Context", NodeGrammar {
      --       comment = Nothing,
      --       is_folded = False,
      --       var_regex = Just "[ΓΔ]([1-9][0-9]*|'*)",
      --       choices = [
      --         striped_list_introduce ["ε"] [],
      --         striped_list_introduce ["", ",", ""] ["Context", "Judgement"]
      --       ]
      --     }),
      --     ("Hypothetical Judgement", NodeGrammar {
      --       comment = Nothing,
      --       is_folded = False,
      --       var_regex = Nothing,
      --       choices = [
      --         striped_list_introduce ["", "⊢", ""] ["Context", "Term"]
      --       ]
      --     }),
      --     -- TODO: remove this from stdlib
      --     ("theorem-a", NodeTheorem init_theorem)
      --   ],
      --   is_folded = False
      -- })
    ]
  , is_folded = False }
