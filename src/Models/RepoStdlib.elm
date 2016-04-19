module Models.RepoStdlib where

import Dict exposing (Dict)

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
            var_regex = Just "[A-Z]+([1-9][0-9]*|'*)",
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
            var_regex = Just "[a-z]+([1-9][0-9]*|'*)",
            choices = []
          }),
          ("Context", NodeGrammar {
            comment = Nothing,
            is_folded = False,
            var_regex = Just "[ΓΔ]([1-9][0-9]*|'*)",
            choices = [
              striped_list_introduce ["ε"] [],
              striped_list_introduce ["", ",", ""] ["Context", "Prop"]
            ]
          }),
          ("Judgement", NodeGrammar {
            comment = Nothing,
            is_folded = False,
            var_regex = Nothing,
            choices = [
              striped_list_introduce ["", "⊢", ""] ["Context", "Prop"]
            ]
          }),
          ("hypothesis-base", NodeRule {
            comment = Nothing,
            is_folded = False,
            parameters = [],
            conclusion = {
              grammar = "Judgement"
              , term = TermInd (striped_list_introduce ["", "⊢", ""] ["Context", "Prop"])
                  [ TermInd (striped_list_introduce ["", ",", ""] ["Context", "Prop"])
                     [TermVar "Γ", TermVar "A"]
                  , TermVar "A"
                  ]
              },
            allow_target_substitution = True,
            premises = []
          }),
          ("hypothesis-next", NodeRule {
            comment = Nothing,
            is_folded = False,
            parameters = [],
            conclusion = {
              grammar = "Judgement"
              , term = TermInd (striped_list_introduce ["", "⊢", ""] ["Context", "Prop"])
                  [ TermInd (striped_list_introduce ["", ",", ""] ["Context", "Prop"])
                     [TermVar "Γ", TermVar "B"]
                  , TermVar "A"
                  ]
              },
            allow_target_substitution = True,
            premises = [
              PremiseDirect
                { grammar = "Judgement"
                , term = TermInd (striped_list_introduce ["", "⊢", ""] ["Context", "Prop"])
                    [TermVar "Γ", TermVar "A"]
                }]
          }),
          ("⊤-intro", NodeRule {
            comment = Nothing,
            is_folded = False,
            parameters = [],
            conclusion = {
              grammar = "Judgement"
              , term = TermInd (striped_list_introduce ["", "⊢", ""] ["Context", "Prop"])
                    [TermVar "Γ", TermInd (striped_list_introduce ["⊤"] []) []]
              },
            allow_target_substitution = True,
            premises = []
          }),
          ("⊥-elim", NodeRule {
            comment = Nothing,
            is_folded = False,
            parameters = [],
            conclusion = {
              grammar = "Judgement"
              , term = TermInd (striped_list_introduce ["", "⊢", ""] ["Context", "Prop"])
                    [TermVar "Γ", TermVar "A"]
              },
            allow_target_substitution = True,
            premises = [
              PremiseDirect
                { grammar = "Judgement"
                , term = TermInd (striped_list_introduce ["", "⊢", ""] ["Context", "Prop"])
                    [TermVar "Γ", TermInd (striped_list_introduce ["⊥"] []) []]
                }]
          }),
          ("∧-intro", NodeRule {
            comment = Nothing,
            is_folded = False,
            parameters = [],
            conclusion = {
              grammar = "Judgement"
              , term = TermInd (striped_list_introduce ["", "⊢", ""] ["Context", "Prop"])
                  [ TermVar "Γ"
                  , TermInd (striped_list_introduce ["", "∧", ""] ["Prop", "Prop"])
                      [TermVar "A", TermVar "B"]
                  ]
              },
            allow_target_substitution = True,
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
          ("∧-elim-left", NodeRule {
            comment = Nothing,
            is_folded = False,
            parameters = [{ grammar = "Prop", var_name = "B" }],
            conclusion = {
              grammar = "Judgement"
              , term = TermInd (striped_list_introduce ["", "⊢", ""] ["Context", "Prop"])
                  [TermVar "Γ", TermVar "A"]
              },
            allow_target_substitution = True,
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
          ("∧-elim-right", NodeRule {
            comment = Nothing,
            is_folded = False,
            parameters = [{ grammar = "Prop", var_name = "A" }],
            conclusion = {
              grammar = "Judgement"
              , term = TermInd (striped_list_introduce ["", "⊢", ""] ["Context", "Prop"])
                  [TermVar "Γ", TermVar "B"]
              },
            allow_target_substitution = True,
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
          ("∨-intro-left", NodeRule {
            comment = Nothing,
            is_folded = False,
            parameters = [],
            conclusion = {
              grammar = "Judgement"
              , term = TermInd (striped_list_introduce ["", "⊢", ""] ["Context", "Prop"])
                  [ TermVar "Γ"
                  , TermInd (striped_list_introduce ["", "∨", ""] ["Prop", "Prop"])
                      [TermVar "A", TermVar "B"]
                  ]
              },
            allow_target_substitution = True,
            premises = [
              PremiseDirect
                { grammar = "Judgement"
                , term = TermInd (striped_list_introduce ["", "⊢", ""] ["Context", "Prop"])
                    [ TermVar "Γ", TermVar "A"
                    ]
                }]
          }),
          ("∨-intro-right", NodeRule {
            comment = Nothing,
            is_folded = False,
            parameters = [],
            conclusion = {
              grammar = "Judgement"
              , term = TermInd (striped_list_introduce ["", "⊢", ""] ["Context", "Prop"])
                  [ TermVar "Γ"
                  , TermInd (striped_list_introduce ["", "∨", ""] ["Prop", "Prop"])
                      [TermVar "A", TermVar "B"]
                  ]
              },
            allow_target_substitution = True,
            premises = [
              PremiseDirect
                { grammar = "Judgement"
                , term = TermInd (striped_list_introduce ["", "⊢", ""] ["Context", "Prop"])
                    [ TermVar "Γ", TermVar "B"
                    ]
                }]
          }),
          ("∨-elim", NodeRule {
            comment = Nothing,
            is_folded = False,
            parameters = [ { grammar = "Prop", var_name = "A" }
                         , { grammar = "Prop", var_name = "B" }
                         ],
            conclusion =
              { grammar = "Judgement"
              , term = TermInd (striped_list_introduce ["", "⊢", ""] ["Context", "Prop"])
                  [ TermVar "Γ", TermVar "C"]
              },
            allow_target_substitution = True,
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
          ("¬-intro", NodeRule {
            comment = Nothing,
            is_folded = False,
            parameters = [],
            conclusion =
              { grammar = "Judgement"
              , term = TermInd (striped_list_introduce ["", "⊢", ""] ["Context", "Prop"])
                  [ TermVar "Γ", TermInd (striped_list_introduce ["¬", ""] ["Prop"]) [TermVar "A"]]
              },
            allow_target_substitution = True,
            premises = [
              PremiseDirect
                { grammar = "Judgement"
                , term = TermInd (striped_list_introduce ["", "⊢", ""] ["Context", "Prop"])
                    [TermInd (striped_list_introduce ["", ",", ""] ["Context", "Prop"]) [TermVar "Γ", TermVar "A"],
                       TermInd (striped_list_introduce ["⊥"] []) []]
                }
            ]
          }),
          ("¬-elim", NodeRule {
            comment = Nothing,
            is_folded = False,
            parameters = [{ grammar = "Prop", var_name = "A" }],
            conclusion =
              { grammar = "Judgement"
              , term = TermInd (striped_list_introduce ["", "⊢", ""] ["Context", "Prop"])
                  [ TermVar "Γ", TermInd (striped_list_introduce ["⊥"] []) []]
              },
            allow_target_substitution = True,
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
          ("double negation", NodeRule {
            comment = Nothing,
            is_folded = False,
            parameters = [],
            conclusion =
              { grammar = "Judgement"
              , term = TermInd (striped_list_introduce ["", "⊢", ""] ["Context", "Prop"])
                  [ TermVar "Γ", TermInd (striped_list_introduce ["¬", ""] ["Prop"])
                      [TermInd (striped_list_introduce ["¬", ""] ["Prop"]) [TermVar "A"]]]
              },
            allow_target_substitution = True,
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
            parameters = [],
            conclusion =
              { grammar = "Judgement"
              , term = TermInd (striped_list_introduce ["", "⊢", ""] ["Context", "Prop"])
                  [ TermVar "Γ", TermVar "A"]
              },
            allow_target_substitution = True,
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
          ("→-intro", NodeRule {
            comment = Nothing,
            is_folded = False,
            parameters = [],
            conclusion =
              { grammar = "Judgement"
              , term = TermInd (striped_list_introduce ["", "⊢", ""] ["Context", "Prop"])
                  [ TermVar "Γ", TermInd (striped_list_introduce ["", "→", ""] ["Prop", "Prop"]) [TermVar "A", TermVar "B"]]
              },
            allow_target_substitution = True,
            premises = [
              PremiseDirect
                { grammar = "Judgement"
                , term = TermInd (striped_list_introduce ["", "⊢", ""] ["Context", "Prop"])
                    [TermInd (striped_list_introduce ["", ",", ""] ["Context", "Prop"]) [TermVar "Γ", TermVar "A"], TermVar "B"]
                }
            ]
          }),
          ("→-elim", NodeRule {
            comment = Nothing,
            is_folded = False,
            parameters = [{ grammar = "Prop", var_name = "A" }],
            conclusion =
              { grammar = "Judgement"
              , term = TermInd (striped_list_introduce ["", "⊢", ""] ["Context", "Prop"])
                  [ TermVar "Γ", TermVar "B"]
              },
            allow_target_substitution = True,
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
          ("↔-intro", NodeRule {
            comment = Nothing,
            is_folded = False,
            parameters = [],
            conclusion =
              { grammar = "Judgement"
              , term = TermInd (striped_list_introduce ["", "⊢", ""] ["Context", "Prop"])
                  [ TermVar "Γ", TermInd (striped_list_introduce ["", "↔", ""] ["Prop", "Prop"]) [TermVar "A", TermVar "B"]]
              },
            allow_target_substitution = True,
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
          ("↔-elim-forward", NodeRule {
            comment = Nothing,
            is_folded = False,
            parameters = [{ grammar = "Prop", var_name = "A" }],
            conclusion =
              { grammar = "Judgement"
              , term = TermInd (striped_list_introduce ["", "⊢", ""] ["Context", "Prop"])
                  [ TermVar "Γ", TermVar "B"]
              },
            allow_target_substitution = True,
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
          ("↔-elim-backward", NodeRule {
            comment = Nothing,
            is_folded = False,
            parameters = [{ grammar = "Prop", var_name = "B" }],
            conclusion =
              { grammar = "Judgement"
              , term = TermInd (striped_list_introduce ["", "⊢", ""] ["Context", "Prop"])
                  [ TermVar "Γ", TermVar "A"]
              },
            allow_target_substitution = True,
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
          -- TODO: remove this from stdlib
          ("theorem-1", NodeTheorem init_theorem),
          -- TODO: remove this from stdlib
          ("theorem-2", NodeTheorem init_theorem)
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
