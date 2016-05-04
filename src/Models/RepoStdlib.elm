module Models.RepoStdlib where

import Dict exposing (Dict)
import Regex exposing (regex)

import Focus

import Tools.OrderedDict exposing (ordered_dict_from_list)
import Tools.StripedList exposing (striped_list_introduce)
import Tools.RegexExtra exposing (safe_regex)
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
  { is_folded = False,
    dict = Dict.fromList [
      ("Propositional Logic", PackageElemMod {
        comment = init_comment,
        is_folded = True,
        imports = [],
        nodes = ordered_dict_from_list [
          ("Grammar-1", NodeGrammar init_grammar),
          ("Grammar-2", NodeGrammar init_grammar),
          ("Prop", NodeGrammar {
            comment = init_comment,
            is_folded = False,
            has_locked = True,
            metavar_regex = safe_regex "[A-Z][a-zA-Z]*([1-9][0-9]*|'*)",
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
            comment = init_comment,
            is_folded = False,
            has_locked = True,
            metavar_regex = Nothing,
            literal_regex = safe_regex "[a-z]+([1-9][0-9]*|'*)",
            choices = []
          }),
          ("Context", NodeGrammar {
            comment = init_comment,
            is_folded = False,
            has_locked = True,
            metavar_regex = safe_regex "[ΓΔ]([1-9][0-9]*|'*)",
            literal_regex = Nothing,
            choices = [
              striped_list_introduce ["ε"] [],
              striped_list_introduce ["", ",", ""] ["Context", "Prop"]
            ]
          }),
          ("Judgement", NodeGrammar {
            comment = init_comment,
            is_folded = False,
            has_locked = True,
            metavar_regex = Nothing,
            literal_regex = Nothing,
            choices = [
              striped_list_introduce ["", "⊢", ""] ["Context", "Prop"]
            ]
          }),
          ("rule-1", NodeRule init_rule),
          ("rule-2", NodeRule init_rule),
          ("hypothesis-base", NodeRule {
            comment = init_comment,
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
            comment = init_comment,
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
                , allow_unification = True
                }
              ] ]
          }),
          ("top-intro", NodeRule {
            comment = init_comment,
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
            comment = init_comment,
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
            comment = init_comment,
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
            comment = init_comment,
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
            comment = init_comment,
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
            comment = init_comment,
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
            comment = init_comment,
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
            comment = init_comment,
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
            comment = init_comment,
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
            comment = init_comment,
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
            comment = init_comment,
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
            comment = init_comment,
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
            comment = init_comment,
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
            comment = init_comment,
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
            comment = init_comment,
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
            comment = init_comment,
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
            comment = init_comment,
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
            comment = init_comment,
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
          ("context-commutative", NodeRule {
            comment = init_comment,
            is_folded = False,
            has_locked = True,
            allow_reduction = True,
            parameters = [],
            conclusion =
              { grammar = "Context"
              , term = TermInd (striped_list_introduce ["", ",", ""] ["Context", "Prop"]) [
                         TermInd (striped_list_introduce ["", ",", ""] ["Context", "Prop"]) [
                           TermVar "Γ", TermVar "A"], TermVar "B"]
              },
            premises = [
              PremiseDirect
                { grammar = "Context"
                , term = TermInd (striped_list_introduce ["", ",", ""] ["Context", "Prop"]) [
                           TermInd (striped_list_introduce ["", ",", ""] ["Context", "Prop"]) [
                             TermVar "Γ", TermVar "B"], TermVar "A"]
                }
            ]
          }),
          ("context-idempotent-1", NodeRule {
            comment = init_comment,
            is_folded = False,
            has_locked = True,
            allow_reduction = True,
            parameters = [],
            conclusion =
              { grammar = "Context"
              , term = TermInd (striped_list_introduce ["", ",", ""] ["Context", "Prop"]) [
                        TermVar "Γ", TermVar "A"]
              },
            premises = [
              PremiseDirect
                { grammar = "Context"
                , term = TermInd (striped_list_introduce ["", ",", ""] ["Context", "Prop"]) [
                           TermInd (striped_list_introduce ["", ",", ""] ["Context", "Prop"]) [
                            TermVar "Γ", TermVar "A"], TermVar "A"]
                }
            ]
          }),
          ("context-idempotent-2", NodeRule {
            comment = init_comment,
            is_folded = False,
            has_locked = True,
            allow_reduction = True,
            parameters = [],
            conclusion =
              { grammar = "Context"
              , term = TermInd (striped_list_introduce ["", ",", ""] ["Context", "Prop"]) [
                         TermInd (striped_list_introduce ["", ",", ""] ["Context", "Prop"]) [
                          TermVar "Γ", TermVar "A"], TermVar "A"]
              },
            premises = [
              PremiseDirect
                { grammar = "Context"
                , term = TermInd (striped_list_introduce ["", ",", ""] ["Context", "Prop"]) [
                          TermVar "Γ", TermVar "A"]
                }
            ]
          }),
          -- TODO: remove this from stdlib
          ("theorem-1", NodeTheorem init_theorem False),
          -- TODO: remove this from stdlib
          ("theorem-2", NodeTheorem init_theorem False)
        ]
      }) ,

      ( "Simply typed lambda calculus", PackageElemMod {
        comment = init_comment,
        is_folded = False,
        imports = [],
        nodes = ordered_dict_from_list [
          ("Term", NodeGrammar {
            comment = init_comment,
            is_folded = False,
            has_locked = True,
            metavar_regex = safe_regex "[M-Z]([1-9][0-9]*|'*)",
            literal_regex = Nothing,
            choices = [
              striped_list_introduce ["", ""] ["Variable"],
              striped_list_introduce ["λ", ":", ".", ""] ["Variable", "Type", "Term"],
              striped_list_introduce ["", "", ""] ["Term", "Term"]
            ]
          }),
          ("Variable", NodeGrammar {
            comment = init_comment,
            is_folded = False,
            has_locked = True,
            metavar_regex = Nothing,
            literal_regex = safe_regex "[a-z]([1-9][0-9]*|'*)",
            choices = []
          }),
          ("Type", NodeGrammar {
            comment = init_comment,
            is_folded = False,
            has_locked = True,
            metavar_regex = safe_regex "[A-L]([1-9][0-9]*|'*)",
            literal_regex = Nothing,
            choices = [
              striped_list_introduce ["", "→", ""] ["Type", "Type"]
            ]
          }),
          ("Judgement", NodeGrammar {
            comment = init_comment,
            is_folded = False,
            has_locked = True,
            metavar_regex = Nothing,
            literal_regex = Nothing,
            choices = [
              striped_list_introduce ["", ":", ""] ["Term", "Type"]
            ]
          }),
          ("Context", NodeGrammar {
            comment = init_comment,
            is_folded = False,
            has_locked = True,
            metavar_regex = safe_regex "[ΓΔ]([1-9][0-9]*|'*)",
            literal_regex = Nothing,
            choices = [
              striped_list_introduce ["ε"] [],
              striped_list_introduce ["", ",", ""] ["Context", "Judgement"]
            ]
          }),
          ("Hypothetical Judgement", NodeGrammar {
            comment = init_comment,
            is_folded = False,
            has_locked = True,
            metavar_regex = Nothing,
            literal_regex = Nothing,
            choices = [
              striped_list_introduce ["", "⊢", ""] ["Context", "Term"]
            ]
          }),
          -- TODO: remove this from stdlib
          ("theorem-a", NodeTheorem init_theorem False),
          ("theorem-b", NodeTheorem init_theorem False),
          ("theorem-c", NodeTheorem init_theorem False),
          ("theorem-d", NodeTheorem init_theorem False),
          ("theorem-e", NodeTheorem init_theorem False)
        ]
      })
    ]}
