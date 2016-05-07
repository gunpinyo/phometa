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
        is_folded = True,
        imports = [],
        nodes = ordered_dict_from_list [
          ("Prop", NodeGrammar {
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
            is_folded = False,
            has_locked = True,
            metavar_regex = Nothing,
            literal_regex = safe_regex "[a-z]+([1-9][0-9]*|'*)",
            choices = []
          }),
          ("Context", NodeGrammar {
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
            is_folded = False,
            has_locked = True,
            metavar_regex = Nothing,
            literal_regex = Nothing,
            choices = [
              striped_list_introduce ["", "⊢", ""] ["Context", "Prop"]
            ]
          }),
          ("hypothesis-base", NodeRule {
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
          })
        ]
      }) ,

      ( "Typed Lambda Calculus", PackageElemMod {
        is_folded = False,
        imports = [],
        nodes = ordered_dict_from_list [
          ("Term", NodeGrammar {
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
            is_folded = False,
            has_locked = True,
            metavar_regex = Nothing,
            literal_regex = safe_regex "[a-z]([1-9][0-9]*|'*)",
            choices = []
          }),
          ("Type", NodeGrammar {
            is_folded = False,
            has_locked = True,
            metavar_regex = safe_regex "[A-L]([1-9][0-9]*|'*)",
            literal_regex = Nothing,
            choices = [
              striped_list_introduce ["", "→", ""] ["Type", "Type"]
            ]
          }),
          ("Judgement", NodeGrammar {
            is_folded = False,
            has_locked = True,
            metavar_regex = Nothing,
            literal_regex = Nothing,
            choices = [
              striped_list_introduce ["", ":", ""] ["Term", "Type"]
            ]
          }),
          ("Context", NodeGrammar {
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
            is_folded = False,
            has_locked = True,
            metavar_regex = Nothing,
            literal_regex = Nothing,
            choices = [
              striped_list_introduce ["", "⊢", ""] ["Context", "Judgement"]
            ]
          }),
          ("arrow-elim", NodeRule {
            is_folded = False,
            has_locked = True,
            allow_reduction = False,
            parameters = [{grammar = "Type", var_name = "A"}],
            conclusion = { grammar = "Hypothetical Judgement"
                         , term = TermInd (striped_list_introduce ["", "⊢", ""] ["Context", "Judgement"])
                                  [TermVar "Γ", TermInd (striped_list_introduce ["", ":", ""] ["Term", "Type"])
                                    [TermInd (striped_list_introduce ["", "", ""] ["Term", "Term"]) [TermVar "M", TermVar "N"], TermVar "B"]]
                         },
            premises = [PremiseDirect
                         { grammar = "Hypothetical Judgement"
                         , term = TermInd (striped_list_introduce ["", "⊢", ""] ["Context", "Judgement"])
                                  [TermVar "Γ", TermInd (striped_list_introduce ["", ":", ""] ["Term", "Type"])
                                    [TermVar "M", TermInd (striped_list_introduce ["", "→", ""] ["Type", "Type"]) [TermVar "A", TermVar "B"]]]
                         }
                       ,PremiseDirect
                         { grammar = "Hypothetical Judgement"
                         , term = TermInd (striped_list_introduce ["", "⊢", ""] ["Context", "Judgement"])
                                  [TermVar "Γ", TermInd (striped_list_introduce ["", ":", ""] ["Term", "Type"])
                                    [TermVar "N", TermVar "A"]]
                         }]
          })
        ]
      })
    ]}
