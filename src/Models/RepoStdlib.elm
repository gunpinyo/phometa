module Models.RepoStdlib where

import Models.RepoModel exposing (Package)
import Models.RepoEnDeJson exposing (decode_repository)
import Models.RepoUtils exposing (init_package)

init_package_with_stdlib : Package
init_package_with_stdlib =
  case decode_repository raw_stdlib_package of
    Ok repository -> repository
    Err err_msg   -> let log = Debug.log "import repo error" err_msg
                      in init_package

raw_stdlib_package : String
raw_stdlib_package = """{
  "is_folded": false,
  "dict": {
    "Standard Library": {
      "PackageElemPkg": [
        {
          "is_folded": false,
          "dict": {
            "Propositional Logic": {
              "PackageElemMod": [
                {
                  "is_folded": true,
                  "imports": [],
                  "nodes": {
                    "dict": {
                      "Atom": {
                        "NodeGrammar": [
                          {
                            "is_folded": false,
                            "has_locked": true,
                            "metavar_regex": null,
                            "literal_regex": "[a-z]+([1-9][0-9]*|'*)",
                            "choices": []
                          }
                        ]
                      },
                      "Context": {
                        "NodeGrammar": [
                          {
                            "is_folded": false,
                            "has_locked": true,
                            "metavar_regex": "[ΓΔ]([1-9][0-9]*|'*)",
                            "literal_regex": null,
                            "choices": [
                              {
                                "formats": [
                                  "ε"
                                ],
                                "sub_grammars": []
                              },
                              {
                                "formats": [
                                  "",
                                  ",",
                                  ""
                                ],
                                "sub_grammars": [
                                  "Context",
                                  "Prop"
                                ]
                              }
                            ]
                          }
                        ]
                      },
                      "Judgement": {
                        "NodeGrammar": [
                          {
                            "is_folded": false,
                            "has_locked": true,
                            "metavar_regex": null,
                            "literal_regex": null,
                            "choices": [
                              {
                                "formats": [
                                  "",
                                  "⊢",
                                  ""
                                ],
                                "sub_grammars": [
                                  "Context",
                                  "Prop"
                                ]
                              }
                            ]
                          }
                        ]
                      },
                      "Prop": {
                        "NodeGrammar": [
                          {
                            "is_folded": false,
                            "has_locked": true,
                            "metavar_regex": "[A-Z][a-zA-Z]*([1-9][0-9]*|'*)",
                            "literal_regex": null,
                            "choices": [
                              {
                                "formats": [
                                  "⊤"
                                ],
                                "sub_grammars": []
                              },
                              {
                                "formats": [
                                  "⊥"
                                ],
                                "sub_grammars": []
                              },
                              {
                                "formats": [
                                  "",
                                  ""
                                ],
                                "sub_grammars": [
                                  "Atom"
                                ]
                              },
                              {
                                "formats": [
                                  "",
                                  "∧",
                                  ""
                                ],
                                "sub_grammars": [
                                  "Prop",
                                  "Prop"
                                ]
                              },
                              {
                                "formats": [
                                  "",
                                  "∨",
                                  ""
                                ],
                                "sub_grammars": [
                                  "Prop",
                                  "Prop"
                                ]
                              },
                              {
                                "formats": [
                                  "¬",
                                  ""
                                ],
                                "sub_grammars": [
                                  "Prop"
                                ]
                              },
                              {
                                "formats": [
                                  "",
                                  "→",
                                  ""
                                ],
                                "sub_grammars": [
                                  "Prop",
                                  "Prop"
                                ]
                              },
                              {
                                "formats": [
                                  "",
                                  "↔",
                                  ""
                                ],
                                "sub_grammars": [
                                  "Prop",
                                  "Prop"
                                ]
                              }
                            ]
                          }
                        ]
                      },
                      "and-elim-left": {
                        "NodeRule": [
                          {
                            "is_folded": false,
                            "has_locked": true,
                            "allow_reduction": false,
                            "parameters": [
                              {
                                "grammar": "Prop",
                                "var_name": "B"
                              }
                            ],
                            "conclusion": {
                              "grammar": "Judgement",
                              "term": {
                                "TermInd": [
                                  {
                                    "formats": [
                                      "",
                                      "⊢",
                                      ""
                                    ],
                                    "sub_grammars": [
                                      "Context",
                                      "Prop"
                                    ]
                                  },
                                  [
                                    {
                                      "TermVar": [
                                        "Γ"
                                      ]
                                    },
                                    {
                                      "TermVar": [
                                        "A"
                                      ]
                                    }
                                  ]
                                ]
                              }
                            },
                            "premises": [
                              {
                                "PremiseDirect": [
                                  {
                                    "grammar": "Judgement",
                                    "term": {
                                      "TermInd": [
                                        {
                                          "formats": [
                                            "",
                                            "⊢",
                                            ""
                                          ],
                                          "sub_grammars": [
                                            "Context",
                                            "Prop"
                                          ]
                                        },
                                        [
                                          {
                                            "TermVar": [
                                              "Γ"
                                            ]
                                          },
                                          {
                                            "TermInd": [
                                              {
                                                "formats": [
                                                  "",
                                                  "∧",
                                                  ""
                                                ],
                                                "sub_grammars": [
                                                  "Prop",
                                                  "Prop"
                                                ]
                                              },
                                              [
                                                {
                                                  "TermVar": [
                                                    "A"
                                                  ]
                                                },
                                                {
                                                  "TermVar": [
                                                    "B"
                                                  ]
                                                }
                                              ]
                                            ]
                                          }
                                        ]
                                      ]
                                    }
                                  }
                                ]
                              }
                            ]
                          }
                        ]
                      },
                      "and-elim-right": {
                        "NodeRule": [
                          {
                            "is_folded": false,
                            "has_locked": true,
                            "allow_reduction": false,
                            "parameters": [
                              {
                                "grammar": "Prop",
                                "var_name": "A"
                              }
                            ],
                            "conclusion": {
                              "grammar": "Judgement",
                              "term": {
                                "TermInd": [
                                  {
                                    "formats": [
                                      "",
                                      "⊢",
                                      ""
                                    ],
                                    "sub_grammars": [
                                      "Context",
                                      "Prop"
                                    ]
                                  },
                                  [
                                    {
                                      "TermVar": [
                                        "Γ"
                                      ]
                                    },
                                    {
                                      "TermVar": [
                                        "B"
                                      ]
                                    }
                                  ]
                                ]
                              }
                            },
                            "premises": [
                              {
                                "PremiseDirect": [
                                  {
                                    "grammar": "Judgement",
                                    "term": {
                                      "TermInd": [
                                        {
                                          "formats": [
                                            "",
                                            "⊢",
                                            ""
                                          ],
                                          "sub_grammars": [
                                            "Context",
                                            "Prop"
                                          ]
                                        },
                                        [
                                          {
                                            "TermVar": [
                                              "Γ"
                                            ]
                                          },
                                          {
                                            "TermInd": [
                                              {
                                                "formats": [
                                                  "",
                                                  "∧",
                                                  ""
                                                ],
                                                "sub_grammars": [
                                                  "Prop",
                                                  "Prop"
                                                ]
                                              },
                                              [
                                                {
                                                  "TermVar": [
                                                    "A"
                                                  ]
                                                },
                                                {
                                                  "TermVar": [
                                                    "B"
                                                  ]
                                                }
                                              ]
                                            ]
                                          }
                                        ]
                                      ]
                                    }
                                  }
                                ]
                              }
                            ]
                          }
                        ]
                      },
                      "and-intro": {
                        "NodeRule": [
                          {
                            "is_folded": false,
                            "has_locked": true,
                            "allow_reduction": false,
                            "parameters": [],
                            "conclusion": {
                              "grammar": "Judgement",
                              "term": {
                                "TermInd": [
                                  {
                                    "formats": [
                                      "",
                                      "⊢",
                                      ""
                                    ],
                                    "sub_grammars": [
                                      "Context",
                                      "Prop"
                                    ]
                                  },
                                  [
                                    {
                                      "TermVar": [
                                        "Γ"
                                      ]
                                    },
                                    {
                                      "TermInd": [
                                        {
                                          "formats": [
                                            "",
                                            "∧",
                                            ""
                                          ],
                                          "sub_grammars": [
                                            "Prop",
                                            "Prop"
                                          ]
                                        },
                                        [
                                          {
                                            "TermVar": [
                                              "A"
                                            ]
                                          },
                                          {
                                            "TermVar": [
                                              "B"
                                            ]
                                          }
                                        ]
                                      ]
                                    }
                                  ]
                                ]
                              }
                            },
                            "premises": [
                              {
                                "PremiseDirect": [
                                  {
                                    "grammar": "Judgement",
                                    "term": {
                                      "TermInd": [
                                        {
                                          "formats": [
                                            "",
                                            "⊢",
                                            ""
                                          ],
                                          "sub_grammars": [
                                            "Context",
                                            "Prop"
                                          ]
                                        },
                                        [
                                          {
                                            "TermVar": [
                                              "Γ"
                                            ]
                                          },
                                          {
                                            "TermVar": [
                                              "A"
                                            ]
                                          }
                                        ]
                                      ]
                                    }
                                  }
                                ]
                              },
                              {
                                "PremiseDirect": [
                                  {
                                    "grammar": "Judgement",
                                    "term": {
                                      "TermInd": [
                                        {
                                          "formats": [
                                            "",
                                            "⊢",
                                            ""
                                          ],
                                          "sub_grammars": [
                                            "Context",
                                            "Prop"
                                          ]
                                        },
                                        [
                                          {
                                            "TermVar": [
                                              "Γ"
                                            ]
                                          },
                                          {
                                            "TermVar": [
                                              "B"
                                            ]
                                          }
                                        ]
                                      ]
                                    }
                                  }
                                ]
                              }
                            ]
                          }
                        ]
                      },
                      "bottom-elim": {
                        "NodeRule": [
                          {
                            "is_folded": false,
                            "has_locked": true,
                            "allow_reduction": false,
                            "parameters": [],
                            "conclusion": {
                              "grammar": "Judgement",
                              "term": {
                                "TermInd": [
                                  {
                                    "formats": [
                                      "",
                                      "⊢",
                                      ""
                                    ],
                                    "sub_grammars": [
                                      "Context",
                                      "Prop"
                                    ]
                                  },
                                  [
                                    {
                                      "TermVar": [
                                        "Γ"
                                      ]
                                    },
                                    {
                                      "TermVar": [
                                        "A"
                                      ]
                                    }
                                  ]
                                ]
                              }
                            },
                            "premises": [
                              {
                                "PremiseDirect": [
                                  {
                                    "grammar": "Judgement",
                                    "term": {
                                      "TermInd": [
                                        {
                                          "formats": [
                                            "",
                                            "⊢",
                                            ""
                                          ],
                                          "sub_grammars": [
                                            "Context",
                                            "Prop"
                                          ]
                                        },
                                        [
                                          {
                                            "TermVar": [
                                              "Γ"
                                            ]
                                          },
                                          {
                                            "TermInd": [
                                              {
                                                "formats": [
                                                  "⊥"
                                                ],
                                                "sub_grammars": []
                                              },
                                              []
                                            ]
                                          }
                                        ]
                                      ]
                                    }
                                  }
                                ]
                              }
                            ]
                          }
                        ]
                      },
                      "context-commutative": {
                        "NodeRule": [
                          {
                            "is_folded": false,
                            "has_locked": true,
                            "allow_reduction": true,
                            "parameters": [],
                            "conclusion": {
                              "grammar": "Context",
                              "term": {
                                "TermInd": [
                                  {
                                    "formats": [
                                      "",
                                      ",",
                                      ""
                                    ],
                                    "sub_grammars": [
                                      "Context",
                                      "Prop"
                                    ]
                                  },
                                  [
                                    {
                                      "TermInd": [
                                        {
                                          "formats": [
                                            "",
                                            ",",
                                            ""
                                          ],
                                          "sub_grammars": [
                                            "Context",
                                            "Prop"
                                          ]
                                        },
                                        [
                                          {
                                            "TermVar": [
                                              "Γ"
                                            ]
                                          },
                                          {
                                            "TermVar": [
                                              "A"
                                            ]
                                          }
                                        ]
                                      ]
                                    },
                                    {
                                      "TermVar": [
                                        "B"
                                      ]
                                    }
                                  ]
                                ]
                              }
                            },
                            "premises": [
                              {
                                "PremiseDirect": [
                                  {
                                    "grammar": "Context",
                                    "term": {
                                      "TermInd": [
                                        {
                                          "formats": [
                                            "",
                                            ",",
                                            ""
                                          ],
                                          "sub_grammars": [
                                            "Context",
                                            "Prop"
                                          ]
                                        },
                                        [
                                          {
                                            "TermInd": [
                                              {
                                                "formats": [
                                                  "",
                                                  ",",
                                                  ""
                                                ],
                                                "sub_grammars": [
                                                  "Context",
                                                  "Prop"
                                                ]
                                              },
                                              [
                                                {
                                                  "TermVar": [
                                                    "Γ"
                                                  ]
                                                },
                                                {
                                                  "TermVar": [
                                                    "B"
                                                  ]
                                                }
                                              ]
                                            ]
                                          },
                                          {
                                            "TermVar": [
                                              "A"
                                            ]
                                          }
                                        ]
                                      ]
                                    }
                                  }
                                ]
                              }
                            ]
                          }
                        ]
                      },
                      "context-idempotent-1": {
                        "NodeRule": [
                          {
                            "is_folded": false,
                            "has_locked": true,
                            "allow_reduction": true,
                            "parameters": [],
                            "conclusion": {
                              "grammar": "Context",
                              "term": {
                                "TermInd": [
                                  {
                                    "formats": [
                                      "",
                                      ",",
                                      ""
                                    ],
                                    "sub_grammars": [
                                      "Context",
                                      "Prop"
                                    ]
                                  },
                                  [
                                    {
                                      "TermVar": [
                                        "Γ"
                                      ]
                                    },
                                    {
                                      "TermVar": [
                                        "A"
                                      ]
                                    }
                                  ]
                                ]
                              }
                            },
                            "premises": [
                              {
                                "PremiseDirect": [
                                  {
                                    "grammar": "Context",
                                    "term": {
                                      "TermInd": [
                                        {
                                          "formats": [
                                            "",
                                            ",",
                                            ""
                                          ],
                                          "sub_grammars": [
                                            "Context",
                                            "Prop"
                                          ]
                                        },
                                        [
                                          {
                                            "TermInd": [
                                              {
                                                "formats": [
                                                  "",
                                                  ",",
                                                  ""
                                                ],
                                                "sub_grammars": [
                                                  "Context",
                                                  "Prop"
                                                ]
                                              },
                                              [
                                                {
                                                  "TermVar": [
                                                    "Γ"
                                                  ]
                                                },
                                                {
                                                  "TermVar": [
                                                    "A"
                                                  ]
                                                }
                                              ]
                                            ]
                                          },
                                          {
                                            "TermVar": [
                                              "A"
                                            ]
                                          }
                                        ]
                                      ]
                                    }
                                  }
                                ]
                              }
                            ]
                          }
                        ]
                      },
                      "context-idempotent-2": {
                        "NodeRule": [
                          {
                            "is_folded": false,
                            "has_locked": true,
                            "allow_reduction": true,
                            "parameters": [],
                            "conclusion": {
                              "grammar": "Context",
                              "term": {
                                "TermInd": [
                                  {
                                    "formats": [
                                      "",
                                      ",",
                                      ""
                                    ],
                                    "sub_grammars": [
                                      "Context",
                                      "Prop"
                                    ]
                                  },
                                  [
                                    {
                                      "TermInd": [
                                        {
                                          "formats": [
                                            "",
                                            ",",
                                            ""
                                          ],
                                          "sub_grammars": [
                                            "Context",
                                            "Prop"
                                          ]
                                        },
                                        [
                                          {
                                            "TermVar": [
                                              "Γ"
                                            ]
                                          },
                                          {
                                            "TermVar": [
                                              "A"
                                            ]
                                          }
                                        ]
                                      ]
                                    },
                                    {
                                      "TermVar": [
                                        "A"
                                      ]
                                    }
                                  ]
                                ]
                              }
                            },
                            "premises": [
                              {
                                "PremiseDirect": [
                                  {
                                    "grammar": "Context",
                                    "term": {
                                      "TermInd": [
                                        {
                                          "formats": [
                                            "",
                                            ",",
                                            ""
                                          ],
                                          "sub_grammars": [
                                            "Context",
                                            "Prop"
                                          ]
                                        },
                                        [
                                          {
                                            "TermVar": [
                                              "Γ"
                                            ]
                                          },
                                          {
                                            "TermVar": [
                                              "A"
                                            ]
                                          }
                                        ]
                                      ]
                                    }
                                  }
                                ]
                              }
                            ]
                          }
                        ]
                      },
                      "double-negation": {
                        "NodeRule": [
                          {
                            "is_folded": false,
                            "has_locked": true,
                            "allow_reduction": false,
                            "parameters": [],
                            "conclusion": {
                              "grammar": "Judgement",
                              "term": {
                                "TermInd": [
                                  {
                                    "formats": [
                                      "",
                                      "⊢",
                                      ""
                                    ],
                                    "sub_grammars": [
                                      "Context",
                                      "Prop"
                                    ]
                                  },
                                  [
                                    {
                                      "TermVar": [
                                        "Γ"
                                      ]
                                    },
                                    {
                                      "TermInd": [
                                        {
                                          "formats": [
                                            "¬",
                                            ""
                                          ],
                                          "sub_grammars": [
                                            "Prop"
                                          ]
                                        },
                                        [
                                          {
                                            "TermInd": [
                                              {
                                                "formats": [
                                                  "¬",
                                                  ""
                                                ],
                                                "sub_grammars": [
                                                  "Prop"
                                                ]
                                              },
                                              [
                                                {
                                                  "TermVar": [
                                                    "A"
                                                  ]
                                                }
                                              ]
                                            ]
                                          }
                                        ]
                                      ]
                                    }
                                  ]
                                ]
                              }
                            },
                            "premises": [
                              {
                                "PremiseDirect": [
                                  {
                                    "grammar": "Judgement",
                                    "term": {
                                      "TermInd": [
                                        {
                                          "formats": [
                                            "",
                                            "⊢",
                                            ""
                                          ],
                                          "sub_grammars": [
                                            "Context",
                                            "Prop"
                                          ]
                                        },
                                        [
                                          {
                                            "TermVar": [
                                              "Γ"
                                            ]
                                          },
                                          {
                                            "TermVar": [
                                              "A"
                                            ]
                                          }
                                        ]
                                      ]
                                    }
                                  }
                                ]
                              }
                            ]
                          }
                        ]
                      },
                      "hypothesis": {
                        "NodeRule": [
                          {
                            "is_folded": false,
                            "has_locked": true,
                            "allow_reduction": false,
                            "parameters": [],
                            "conclusion": {
                              "grammar": "Judgement",
                              "term": {
                                "TermInd": [
                                  {
                                    "formats": [
                                      "",
                                      "⊢",
                                      ""
                                    ],
                                    "sub_grammars": [
                                      "Context",
                                      "Prop"
                                    ]
                                  },
                                  [
                                    {
                                      "TermInd": [
                                        {
                                          "formats": [
                                            "",
                                            ",",
                                            ""
                                          ],
                                          "sub_grammars": [
                                            "Context",
                                            "Prop"
                                          ]
                                        },
                                        [
                                          {
                                            "TermVar": [
                                              "Γ"
                                            ]
                                          },
                                          {
                                            "TermVar": [
                                              "B"
                                            ]
                                          }
                                        ]
                                      ]
                                    },
                                    {
                                      "TermVar": [
                                        "A"
                                      ]
                                    }
                                  ]
                                ]
                              }
                            },
                            "premises": [
                              {
                                "PremiseCascade": [
                                  [
                                    {
                                      "rule_name": "hypothesis-base",
                                      "pattern": {
                                        "grammar": "Judgement",
                                        "term": {
                                          "TermInd": [
                                            {
                                              "formats": [
                                                "",
                                                "⊢",
                                                ""
                                              ],
                                              "sub_grammars": [
                                                "Context",
                                                "Prop"
                                              ]
                                            },
                                            [
                                              {
                                                "TermInd": [
                                                  {
                                                    "formats": [
                                                      "",
                                                      ",",
                                                      ""
                                                    ],
                                                    "sub_grammars": [
                                                      "Context",
                                                      "Prop"
                                                    ]
                                                  },
                                                  [
                                                    {
                                                      "TermVar": [
                                                        "Γ"
                                                      ]
                                                    },
                                                    {
                                                      "TermVar": [
                                                        "B"
                                                      ]
                                                    }
                                                  ]
                                                ]
                                              },
                                              {
                                                "TermVar": [
                                                  "A"
                                                ]
                                              }
                                            ]
                                          ]
                                        }
                                      },
                                      "arguments": [],
                                      "allow_unification": false
                                    },
                                    {
                                      "rule_name": "hypothesis",
                                      "pattern": {
                                        "grammar": "Judgement",
                                        "term": {
                                          "TermInd": [
                                            {
                                              "formats": [
                                                "",
                                                "⊢",
                                                ""
                                              ],
                                              "sub_grammars": [
                                                "Context",
                                                "Prop"
                                              ]
                                            },
                                            [
                                              {
                                                "TermVar": [
                                                  "Γ"
                                                ]
                                              },
                                              {
                                                "TermVar": [
                                                  "A"
                                                ]
                                              }
                                            ]
                                          ]
                                        }
                                      },
                                      "arguments": [],
                                      "allow_unification": true
                                    }
                                  ]
                                ]
                              }
                            ]
                          }
                        ]
                      },
                      "hypothesis-base": {
                        "NodeRule": [
                          {
                            "is_folded": false,
                            "has_locked": true,
                            "allow_reduction": false,
                            "parameters": [],
                            "conclusion": {
                              "grammar": "Judgement",
                              "term": {
                                "TermInd": [
                                  {
                                    "formats": [
                                      "",
                                      "⊢",
                                      ""
                                    ],
                                    "sub_grammars": [
                                      "Context",
                                      "Prop"
                                    ]
                                  },
                                  [
                                    {
                                      "TermInd": [
                                        {
                                          "formats": [
                                            "",
                                            ",",
                                            ""
                                          ],
                                          "sub_grammars": [
                                            "Context",
                                            "Prop"
                                          ]
                                        },
                                        [
                                          {
                                            "TermVar": [
                                              "Γ"
                                            ]
                                          },
                                          {
                                            "TermVar": [
                                              "A"
                                            ]
                                          }
                                        ]
                                      ]
                                    },
                                    {
                                      "TermVar": [
                                        "A"
                                      ]
                                    }
                                  ]
                                ]
                              }
                            },
                            "premises": []
                          }
                        ]
                      },
                      "iff-elim-backward": {
                        "NodeRule": [
                          {
                            "is_folded": false,
                            "has_locked": true,
                            "allow_reduction": false,
                            "parameters": [
                              {
                                "grammar": "Prop",
                                "var_name": "B"
                              }
                            ],
                            "conclusion": {
                              "grammar": "Judgement",
                              "term": {
                                "TermInd": [
                                  {
                                    "formats": [
                                      "",
                                      "⊢",
                                      ""
                                    ],
                                    "sub_grammars": [
                                      "Context",
                                      "Prop"
                                    ]
                                  },
                                  [
                                    {
                                      "TermVar": [
                                        "Γ"
                                      ]
                                    },
                                    {
                                      "TermVar": [
                                        "A"
                                      ]
                                    }
                                  ]
                                ]
                              }
                            },
                            "premises": [
                              {
                                "PremiseDirect": [
                                  {
                                    "grammar": "Judgement",
                                    "term": {
                                      "TermInd": [
                                        {
                                          "formats": [
                                            "",
                                            "⊢",
                                            ""
                                          ],
                                          "sub_grammars": [
                                            "Context",
                                            "Prop"
                                          ]
                                        },
                                        [
                                          {
                                            "TermVar": [
                                              "Γ"
                                            ]
                                          },
                                          {
                                            "TermInd": [
                                              {
                                                "formats": [
                                                  "",
                                                  "↔",
                                                  ""
                                                ],
                                                "sub_grammars": [
                                                  "Prop",
                                                  "Prop"
                                                ]
                                              },
                                              [
                                                {
                                                  "TermVar": [
                                                    "A"
                                                  ]
                                                },
                                                {
                                                  "TermVar": [
                                                    "B"
                                                  ]
                                                }
                                              ]
                                            ]
                                          }
                                        ]
                                      ]
                                    }
                                  }
                                ]
                              },
                              {
                                "PremiseDirect": [
                                  {
                                    "grammar": "Judgement",
                                    "term": {
                                      "TermInd": [
                                        {
                                          "formats": [
                                            "",
                                            "⊢",
                                            ""
                                          ],
                                          "sub_grammars": [
                                            "Context",
                                            "Prop"
                                          ]
                                        },
                                        [
                                          {
                                            "TermVar": [
                                              "Γ"
                                            ]
                                          },
                                          {
                                            "TermVar": [
                                              "B"
                                            ]
                                          }
                                        ]
                                      ]
                                    }
                                  }
                                ]
                              }
                            ]
                          }
                        ]
                      },
                      "iff-elim-forward": {
                        "NodeRule": [
                          {
                            "is_folded": false,
                            "has_locked": true,
                            "allow_reduction": false,
                            "parameters": [
                              {
                                "grammar": "Prop",
                                "var_name": "A"
                              }
                            ],
                            "conclusion": {
                              "grammar": "Judgement",
                              "term": {
                                "TermInd": [
                                  {
                                    "formats": [
                                      "",
                                      "⊢",
                                      ""
                                    ],
                                    "sub_grammars": [
                                      "Context",
                                      "Prop"
                                    ]
                                  },
                                  [
                                    {
                                      "TermVar": [
                                        "Γ"
                                      ]
                                    },
                                    {
                                      "TermVar": [
                                        "B"
                                      ]
                                    }
                                  ]
                                ]
                              }
                            },
                            "premises": [
                              {
                                "PremiseDirect": [
                                  {
                                    "grammar": "Judgement",
                                    "term": {
                                      "TermInd": [
                                        {
                                          "formats": [
                                            "",
                                            "⊢",
                                            ""
                                          ],
                                          "sub_grammars": [
                                            "Context",
                                            "Prop"
                                          ]
                                        },
                                        [
                                          {
                                            "TermVar": [
                                              "Γ"
                                            ]
                                          },
                                          {
                                            "TermInd": [
                                              {
                                                "formats": [
                                                  "",
                                                  "↔",
                                                  ""
                                                ],
                                                "sub_grammars": [
                                                  "Prop",
                                                  "Prop"
                                                ]
                                              },
                                              [
                                                {
                                                  "TermVar": [
                                                    "A"
                                                  ]
                                                },
                                                {
                                                  "TermVar": [
                                                    "B"
                                                  ]
                                                }
                                              ]
                                            ]
                                          }
                                        ]
                                      ]
                                    }
                                  }
                                ]
                              },
                              {
                                "PremiseDirect": [
                                  {
                                    "grammar": "Judgement",
                                    "term": {
                                      "TermInd": [
                                        {
                                          "formats": [
                                            "",
                                            "⊢",
                                            ""
                                          ],
                                          "sub_grammars": [
                                            "Context",
                                            "Prop"
                                          ]
                                        },
                                        [
                                          {
                                            "TermVar": [
                                              "Γ"
                                            ]
                                          },
                                          {
                                            "TermVar": [
                                              "A"
                                            ]
                                          }
                                        ]
                                      ]
                                    }
                                  }
                                ]
                              }
                            ]
                          }
                        ]
                      },
                      "iff-intro": {
                        "NodeRule": [
                          {
                            "is_folded": false,
                            "has_locked": true,
                            "allow_reduction": false,
                            "parameters": [],
                            "conclusion": {
                              "grammar": "Judgement",
                              "term": {
                                "TermInd": [
                                  {
                                    "formats": [
                                      "",
                                      "⊢",
                                      ""
                                    ],
                                    "sub_grammars": [
                                      "Context",
                                      "Prop"
                                    ]
                                  },
                                  [
                                    {
                                      "TermVar": [
                                        "Γ"
                                      ]
                                    },
                                    {
                                      "TermInd": [
                                        {
                                          "formats": [
                                            "",
                                            "↔",
                                            ""
                                          ],
                                          "sub_grammars": [
                                            "Prop",
                                            "Prop"
                                          ]
                                        },
                                        [
                                          {
                                            "TermVar": [
                                              "A"
                                            ]
                                          },
                                          {
                                            "TermVar": [
                                              "B"
                                            ]
                                          }
                                        ]
                                      ]
                                    }
                                  ]
                                ]
                              }
                            },
                            "premises": [
                              {
                                "PremiseDirect": [
                                  {
                                    "grammar": "Judgement",
                                    "term": {
                                      "TermInd": [
                                        {
                                          "formats": [
                                            "",
                                            "⊢",
                                            ""
                                          ],
                                          "sub_grammars": [
                                            "Context",
                                            "Prop"
                                          ]
                                        },
                                        [
                                          {
                                            "TermInd": [
                                              {
                                                "formats": [
                                                  "",
                                                  ",",
                                                  ""
                                                ],
                                                "sub_grammars": [
                                                  "Context",
                                                  "Prop"
                                                ]
                                              },
                                              [
                                                {
                                                  "TermVar": [
                                                    "Γ"
                                                  ]
                                                },
                                                {
                                                  "TermVar": [
                                                    "A"
                                                  ]
                                                }
                                              ]
                                            ]
                                          },
                                          {
                                            "TermVar": [
                                              "B"
                                            ]
                                          }
                                        ]
                                      ]
                                    }
                                  }
                                ]
                              },
                              {
                                "PremiseDirect": [
                                  {
                                    "grammar": "Judgement",
                                    "term": {
                                      "TermInd": [
                                        {
                                          "formats": [
                                            "",
                                            "⊢",
                                            ""
                                          ],
                                          "sub_grammars": [
                                            "Context",
                                            "Prop"
                                          ]
                                        },
                                        [
                                          {
                                            "TermInd": [
                                              {
                                                "formats": [
                                                  "",
                                                  ",",
                                                  ""
                                                ],
                                                "sub_grammars": [
                                                  "Context",
                                                  "Prop"
                                                ]
                                              },
                                              [
                                                {
                                                  "TermVar": [
                                                    "Γ"
                                                  ]
                                                },
                                                {
                                                  "TermVar": [
                                                    "B"
                                                  ]
                                                }
                                              ]
                                            ]
                                          },
                                          {
                                            "TermVar": [
                                              "A"
                                            ]
                                          }
                                        ]
                                      ]
                                    }
                                  }
                                ]
                              }
                            ]
                          }
                        ]
                      },
                      "imply-elim": {
                        "NodeRule": [
                          {
                            "is_folded": false,
                            "has_locked": true,
                            "allow_reduction": false,
                            "parameters": [
                              {
                                "grammar": "Prop",
                                "var_name": "A"
                              }
                            ],
                            "conclusion": {
                              "grammar": "Judgement",
                              "term": {
                                "TermInd": [
                                  {
                                    "formats": [
                                      "",
                                      "⊢",
                                      ""
                                    ],
                                    "sub_grammars": [
                                      "Context",
                                      "Prop"
                                    ]
                                  },
                                  [
                                    {
                                      "TermVar": [
                                        "Γ"
                                      ]
                                    },
                                    {
                                      "TermVar": [
                                        "B"
                                      ]
                                    }
                                  ]
                                ]
                              }
                            },
                            "premises": [
                              {
                                "PremiseDirect": [
                                  {
                                    "grammar": "Judgement",
                                    "term": {
                                      "TermInd": [
                                        {
                                          "formats": [
                                            "",
                                            "⊢",
                                            ""
                                          ],
                                          "sub_grammars": [
                                            "Context",
                                            "Prop"
                                          ]
                                        },
                                        [
                                          {
                                            "TermVar": [
                                              "Γ"
                                            ]
                                          },
                                          {
                                            "TermInd": [
                                              {
                                                "formats": [
                                                  "",
                                                  "→",
                                                  ""
                                                ],
                                                "sub_grammars": [
                                                  "Prop",
                                                  "Prop"
                                                ]
                                              },
                                              [
                                                {
                                                  "TermVar": [
                                                    "A"
                                                  ]
                                                },
                                                {
                                                  "TermVar": [
                                                    "B"
                                                  ]
                                                }
                                              ]
                                            ]
                                          }
                                        ]
                                      ]
                                    }
                                  }
                                ]
                              },
                              {
                                "PremiseDirect": [
                                  {
                                    "grammar": "Judgement",
                                    "term": {
                                      "TermInd": [
                                        {
                                          "formats": [
                                            "",
                                            "⊢",
                                            ""
                                          ],
                                          "sub_grammars": [
                                            "Context",
                                            "Prop"
                                          ]
                                        },
                                        [
                                          {
                                            "TermVar": [
                                              "Γ"
                                            ]
                                          },
                                          {
                                            "TermVar": [
                                              "A"
                                            ]
                                          }
                                        ]
                                      ]
                                    }
                                  }
                                ]
                              }
                            ]
                          }
                        ]
                      },
                      "imply-intro": {
                        "NodeRule": [
                          {
                            "is_folded": false,
                            "has_locked": true,
                            "allow_reduction": false,
                            "parameters": [],
                            "conclusion": {
                              "grammar": "Judgement",
                              "term": {
                                "TermInd": [
                                  {
                                    "formats": [
                                      "",
                                      "⊢",
                                      ""
                                    ],
                                    "sub_grammars": [
                                      "Context",
                                      "Prop"
                                    ]
                                  },
                                  [
                                    {
                                      "TermVar": [
                                        "Γ"
                                      ]
                                    },
                                    {
                                      "TermInd": [
                                        {
                                          "formats": [
                                            "",
                                            "→",
                                            ""
                                          ],
                                          "sub_grammars": [
                                            "Prop",
                                            "Prop"
                                          ]
                                        },
                                        [
                                          {
                                            "TermVar": [
                                              "A"
                                            ]
                                          },
                                          {
                                            "TermVar": [
                                              "B"
                                            ]
                                          }
                                        ]
                                      ]
                                    }
                                  ]
                                ]
                              }
                            },
                            "premises": [
                              {
                                "PremiseDirect": [
                                  {
                                    "grammar": "Judgement",
                                    "term": {
                                      "TermInd": [
                                        {
                                          "formats": [
                                            "",
                                            "⊢",
                                            ""
                                          ],
                                          "sub_grammars": [
                                            "Context",
                                            "Prop"
                                          ]
                                        },
                                        [
                                          {
                                            "TermInd": [
                                              {
                                                "formats": [
                                                  "",
                                                  ",",
                                                  ""
                                                ],
                                                "sub_grammars": [
                                                  "Context",
                                                  "Prop"
                                                ]
                                              },
                                              [
                                                {
                                                  "TermVar": [
                                                    "Γ"
                                                  ]
                                                },
                                                {
                                                  "TermVar": [
                                                    "A"
                                                  ]
                                                }
                                              ]
                                            ]
                                          },
                                          {
                                            "TermVar": [
                                              "B"
                                            ]
                                          }
                                        ]
                                      ]
                                    }
                                  }
                                ]
                              }
                            ]
                          }
                        ]
                      },
                      "not-elim": {
                        "NodeRule": [
                          {
                            "is_folded": false,
                            "has_locked": true,
                            "allow_reduction": false,
                            "parameters": [
                              {
                                "grammar": "Prop",
                                "var_name": "A"
                              }
                            ],
                            "conclusion": {
                              "grammar": "Judgement",
                              "term": {
                                "TermInd": [
                                  {
                                    "formats": [
                                      "",
                                      "⊢",
                                      ""
                                    ],
                                    "sub_grammars": [
                                      "Context",
                                      "Prop"
                                    ]
                                  },
                                  [
                                    {
                                      "TermVar": [
                                        "Γ"
                                      ]
                                    },
                                    {
                                      "TermInd": [
                                        {
                                          "formats": [
                                            "⊥"
                                          ],
                                          "sub_grammars": []
                                        },
                                        []
                                      ]
                                    }
                                  ]
                                ]
                              }
                            },
                            "premises": [
                              {
                                "PremiseDirect": [
                                  {
                                    "grammar": "Judgement",
                                    "term": {
                                      "TermInd": [
                                        {
                                          "formats": [
                                            "",
                                            "⊢",
                                            ""
                                          ],
                                          "sub_grammars": [
                                            "Context",
                                            "Prop"
                                          ]
                                        },
                                        [
                                          {
                                            "TermVar": [
                                              "Γ"
                                            ]
                                          },
                                          {
                                            "TermInd": [
                                              {
                                                "formats": [
                                                  "¬",
                                                  ""
                                                ],
                                                "sub_grammars": [
                                                  "Prop"
                                                ]
                                              },
                                              [
                                                {
                                                  "TermVar": [
                                                    "A"
                                                  ]
                                                }
                                              ]
                                            ]
                                          }
                                        ]
                                      ]
                                    }
                                  }
                                ]
                              },
                              {
                                "PremiseDirect": [
                                  {
                                    "grammar": "Judgement",
                                    "term": {
                                      "TermInd": [
                                        {
                                          "formats": [
                                            "",
                                            "⊢",
                                            ""
                                          ],
                                          "sub_grammars": [
                                            "Context",
                                            "Prop"
                                          ]
                                        },
                                        [
                                          {
                                            "TermVar": [
                                              "Γ"
                                            ]
                                          },
                                          {
                                            "TermVar": [
                                              "A"
                                            ]
                                          }
                                        ]
                                      ]
                                    }
                                  }
                                ]
                              }
                            ]
                          }
                        ]
                      },
                      "not-intro": {
                        "NodeRule": [
                          {
                            "is_folded": false,
                            "has_locked": true,
                            "allow_reduction": false,
                            "parameters": [],
                            "conclusion": {
                              "grammar": "Judgement",
                              "term": {
                                "TermInd": [
                                  {
                                    "formats": [
                                      "",
                                      "⊢",
                                      ""
                                    ],
                                    "sub_grammars": [
                                      "Context",
                                      "Prop"
                                    ]
                                  },
                                  [
                                    {
                                      "TermVar": [
                                        "Γ"
                                      ]
                                    },
                                    {
                                      "TermInd": [
                                        {
                                          "formats": [
                                            "¬",
                                            ""
                                          ],
                                          "sub_grammars": [
                                            "Prop"
                                          ]
                                        },
                                        [
                                          {
                                            "TermVar": [
                                              "A"
                                            ]
                                          }
                                        ]
                                      ]
                                    }
                                  ]
                                ]
                              }
                            },
                            "premises": [
                              {
                                "PremiseDirect": [
                                  {
                                    "grammar": "Judgement",
                                    "term": {
                                      "TermInd": [
                                        {
                                          "formats": [
                                            "",
                                            "⊢",
                                            ""
                                          ],
                                          "sub_grammars": [
                                            "Context",
                                            "Prop"
                                          ]
                                        },
                                        [
                                          {
                                            "TermInd": [
                                              {
                                                "formats": [
                                                  "",
                                                  ",",
                                                  ""
                                                ],
                                                "sub_grammars": [
                                                  "Context",
                                                  "Prop"
                                                ]
                                              },
                                              [
                                                {
                                                  "TermVar": [
                                                    "Γ"
                                                  ]
                                                },
                                                {
                                                  "TermVar": [
                                                    "A"
                                                  ]
                                                }
                                              ]
                                            ]
                                          },
                                          {
                                            "TermInd": [
                                              {
                                                "formats": [
                                                  "⊥"
                                                ],
                                                "sub_grammars": []
                                              },
                                              []
                                            ]
                                          }
                                        ]
                                      ]
                                    }
                                  }
                                ]
                              }
                            ]
                          }
                        ]
                      },
                      "or-elim": {
                        "NodeRule": [
                          {
                            "is_folded": false,
                            "has_locked": true,
                            "allow_reduction": false,
                            "parameters": [
                              {
                                "grammar": "Prop",
                                "var_name": "A"
                              },
                              {
                                "grammar": "Prop",
                                "var_name": "B"
                              }
                            ],
                            "conclusion": {
                              "grammar": "Judgement",
                              "term": {
                                "TermInd": [
                                  {
                                    "formats": [
                                      "",
                                      "⊢",
                                      ""
                                    ],
                                    "sub_grammars": [
                                      "Context",
                                      "Prop"
                                    ]
                                  },
                                  [
                                    {
                                      "TermVar": [
                                        "Γ"
                                      ]
                                    },
                                    {
                                      "TermVar": [
                                        "C"
                                      ]
                                    }
                                  ]
                                ]
                              }
                            },
                            "premises": [
                              {
                                "PremiseDirect": [
                                  {
                                    "grammar": "Judgement",
                                    "term": {
                                      "TermInd": [
                                        {
                                          "formats": [
                                            "",
                                            "⊢",
                                            ""
                                          ],
                                          "sub_grammars": [
                                            "Context",
                                            "Prop"
                                          ]
                                        },
                                        [
                                          {
                                            "TermVar": [
                                              "Γ"
                                            ]
                                          },
                                          {
                                            "TermInd": [
                                              {
                                                "formats": [
                                                  "",
                                                  "∨",
                                                  ""
                                                ],
                                                "sub_grammars": [
                                                  "Prop",
                                                  "Prop"
                                                ]
                                              },
                                              [
                                                {
                                                  "TermVar": [
                                                    "A"
                                                  ]
                                                },
                                                {
                                                  "TermVar": [
                                                    "B"
                                                  ]
                                                }
                                              ]
                                            ]
                                          }
                                        ]
                                      ]
                                    }
                                  }
                                ]
                              },
                              {
                                "PremiseDirect": [
                                  {
                                    "grammar": "Judgement",
                                    "term": {
                                      "TermInd": [
                                        {
                                          "formats": [
                                            "",
                                            "⊢",
                                            ""
                                          ],
                                          "sub_grammars": [
                                            "Context",
                                            "Prop"
                                          ]
                                        },
                                        [
                                          {
                                            "TermInd": [
                                              {
                                                "formats": [
                                                  "",
                                                  ",",
                                                  ""
                                                ],
                                                "sub_grammars": [
                                                  "Context",
                                                  "Prop"
                                                ]
                                              },
                                              [
                                                {
                                                  "TermVar": [
                                                    "Γ"
                                                  ]
                                                },
                                                {
                                                  "TermVar": [
                                                    "A"
                                                  ]
                                                }
                                              ]
                                            ]
                                          },
                                          {
                                            "TermVar": [
                                              "C"
                                            ]
                                          }
                                        ]
                                      ]
                                    }
                                  }
                                ]
                              },
                              {
                                "PremiseDirect": [
                                  {
                                    "grammar": "Judgement",
                                    "term": {
                                      "TermInd": [
                                        {
                                          "formats": [
                                            "",
                                            "⊢",
                                            ""
                                          ],
                                          "sub_grammars": [
                                            "Context",
                                            "Prop"
                                          ]
                                        },
                                        [
                                          {
                                            "TermInd": [
                                              {
                                                "formats": [
                                                  "",
                                                  ",",
                                                  ""
                                                ],
                                                "sub_grammars": [
                                                  "Context",
                                                  "Prop"
                                                ]
                                              },
                                              [
                                                {
                                                  "TermVar": [
                                                    "Γ"
                                                  ]
                                                },
                                                {
                                                  "TermVar": [
                                                    "B"
                                                  ]
                                                }
                                              ]
                                            ]
                                          },
                                          {
                                            "TermVar": [
                                              "C"
                                            ]
                                          }
                                        ]
                                      ]
                                    }
                                  }
                                ]
                              }
                            ]
                          }
                        ]
                      },
                      "or-intro-left": {
                        "NodeRule": [
                          {
                            "is_folded": false,
                            "has_locked": true,
                            "allow_reduction": false,
                            "parameters": [],
                            "conclusion": {
                              "grammar": "Judgement",
                              "term": {
                                "TermInd": [
                                  {
                                    "formats": [
                                      "",
                                      "⊢",
                                      ""
                                    ],
                                    "sub_grammars": [
                                      "Context",
                                      "Prop"
                                    ]
                                  },
                                  [
                                    {
                                      "TermVar": [
                                        "Γ"
                                      ]
                                    },
                                    {
                                      "TermInd": [
                                        {
                                          "formats": [
                                            "",
                                            "∨",
                                            ""
                                          ],
                                          "sub_grammars": [
                                            "Prop",
                                            "Prop"
                                          ]
                                        },
                                        [
                                          {
                                            "TermVar": [
                                              "A"
                                            ]
                                          },
                                          {
                                            "TermVar": [
                                              "B"
                                            ]
                                          }
                                        ]
                                      ]
                                    }
                                  ]
                                ]
                              }
                            },
                            "premises": [
                              {
                                "PremiseDirect": [
                                  {
                                    "grammar": "Judgement",
                                    "term": {
                                      "TermInd": [
                                        {
                                          "formats": [
                                            "",
                                            "⊢",
                                            ""
                                          ],
                                          "sub_grammars": [
                                            "Context",
                                            "Prop"
                                          ]
                                        },
                                        [
                                          {
                                            "TermVar": [
                                              "Γ"
                                            ]
                                          },
                                          {
                                            "TermVar": [
                                              "A"
                                            ]
                                          }
                                        ]
                                      ]
                                    }
                                  }
                                ]
                              }
                            ]
                          }
                        ]
                      },
                      "or-intro-right": {
                        "NodeRule": [
                          {
                            "is_folded": false,
                            "has_locked": true,
                            "allow_reduction": false,
                            "parameters": [],
                            "conclusion": {
                              "grammar": "Judgement",
                              "term": {
                                "TermInd": [
                                  {
                                    "formats": [
                                      "",
                                      "⊢",
                                      ""
                                    ],
                                    "sub_grammars": [
                                      "Context",
                                      "Prop"
                                    ]
                                  },
                                  [
                                    {
                                      "TermVar": [
                                        "Γ"
                                      ]
                                    },
                                    {
                                      "TermInd": [
                                        {
                                          "formats": [
                                            "",
                                            "∨",
                                            ""
                                          ],
                                          "sub_grammars": [
                                            "Prop",
                                            "Prop"
                                          ]
                                        },
                                        [
                                          {
                                            "TermVar": [
                                              "A"
                                            ]
                                          },
                                          {
                                            "TermVar": [
                                              "B"
                                            ]
                                          }
                                        ]
                                      ]
                                    }
                                  ]
                                ]
                              }
                            },
                            "premises": [
                              {
                                "PremiseDirect": [
                                  {
                                    "grammar": "Judgement",
                                    "term": {
                                      "TermInd": [
                                        {
                                          "formats": [
                                            "",
                                            "⊢",
                                            ""
                                          ],
                                          "sub_grammars": [
                                            "Context",
                                            "Prop"
                                          ]
                                        },
                                        [
                                          {
                                            "TermVar": [
                                              "Γ"
                                            ]
                                          },
                                          {
                                            "TermVar": [
                                              "B"
                                            ]
                                          }
                                        ]
                                      ]
                                    }
                                  }
                                ]
                              }
                            ]
                          }
                        ]
                      },
                      "proof-by-contradiction": {
                        "NodeRule": [
                          {
                            "is_folded": false,
                            "has_locked": true,
                            "allow_reduction": false,
                            "parameters": [],
                            "conclusion": {
                              "grammar": "Judgement",
                              "term": {
                                "TermInd": [
                                  {
                                    "formats": [
                                      "",
                                      "⊢",
                                      ""
                                    ],
                                    "sub_grammars": [
                                      "Context",
                                      "Prop"
                                    ]
                                  },
                                  [
                                    {
                                      "TermVar": [
                                        "Γ"
                                      ]
                                    },
                                    {
                                      "TermVar": [
                                        "A"
                                      ]
                                    }
                                  ]
                                ]
                              }
                            },
                            "premises": [
                              {
                                "PremiseDirect": [
                                  {
                                    "grammar": "Judgement",
                                    "term": {
                                      "TermInd": [
                                        {
                                          "formats": [
                                            "",
                                            "⊢",
                                            ""
                                          ],
                                          "sub_grammars": [
                                            "Context",
                                            "Prop"
                                          ]
                                        },
                                        [
                                          {
                                            "TermInd": [
                                              {
                                                "formats": [
                                                  "",
                                                  ",",
                                                  ""
                                                ],
                                                "sub_grammars": [
                                                  "Context",
                                                  "Prop"
                                                ]
                                              },
                                              [
                                                {
                                                  "TermVar": [
                                                    "Γ"
                                                  ]
                                                },
                                                {
                                                  "TermInd": [
                                                    {
                                                      "formats": [
                                                        "¬",
                                                        ""
                                                      ],
                                                      "sub_grammars": [
                                                        "Prop"
                                                      ]
                                                    },
                                                    [
                                                      {
                                                        "TermVar": [
                                                          "A"
                                                        ]
                                                      }
                                                    ]
                                                  ]
                                                }
                                              ]
                                            ]
                                          },
                                          {
                                            "TermInd": [
                                              {
                                                "formats": [
                                                  "⊥"
                                                ],
                                                "sub_grammars": []
                                              },
                                              []
                                            ]
                                          }
                                        ]
                                      ]
                                    }
                                  }
                                ]
                              }
                            ]
                          }
                        ]
                      },
                      "prop-intro": {
                        "NodeRule": [
                          {
                            "is_folded": false,
                            "has_locked": true,
                            "allow_reduction": false,
                            "parameters": [],
                            "conclusion": {
                              "grammar": "Prop",
                              "term": {
                                "TermVar": [
                                  "A"
                                ]
                              }
                            },
                            "premises": [
                              {
                                "PremiseDirect": [
                                  {
                                    "grammar": "Judgement",
                                    "term": {
                                      "TermInd": [
                                        {
                                          "formats": [
                                            "",
                                            "⊢",
                                            ""
                                          ],
                                          "sub_grammars": [
                                            "Context",
                                            "Prop"
                                          ]
                                        },
                                        [
                                          {
                                            "TermInd": [
                                              {
                                                "formats": [
                                                  "ε"
                                                ],
                                                "sub_grammars": []
                                              },
                                              []
                                            ]
                                          },
                                          {
                                            "TermVar": [
                                              "A"
                                            ]
                                          }
                                        ]
                                      ]
                                    }
                                  }
                                ]
                              }
                            ]
                          }
                        ]
                      },
                      "top-intro": {
                        "NodeRule": [
                          {
                            "is_folded": false,
                            "has_locked": true,
                            "allow_reduction": false,
                            "parameters": [],
                            "conclusion": {
                              "grammar": "Judgement",
                              "term": {
                                "TermInd": [
                                  {
                                    "formats": [
                                      "",
                                      "⊢",
                                      ""
                                    ],
                                    "sub_grammars": [
                                      "Context",
                                      "Prop"
                                    ]
                                  },
                                  [
                                    {
                                      "TermVar": [
                                        "Γ"
                                      ]
                                    },
                                    {
                                      "TermInd": [
                                        {
                                          "formats": [
                                            "⊤"
                                          ],
                                          "sub_grammars": []
                                        },
                                        []
                                      ]
                                    }
                                  ]
                                ]
                              }
                            },
                            "premises": []
                          }
                        ]
                      }
                    },
                    "order": [
                      "Prop",
                      "Atom",
                      "Context",
                      "Judgement",
                      "hypothesis-base",
                      "hypothesis",
                      "top-intro",
                      "bottom-elim",
                      "and-intro",
                      "and-elim-left",
                      "and-elim-right",
                      "or-intro-left",
                      "or-intro-right",
                      "or-elim",
                      "not-intro",
                      "not-elim",
                      "double-negation",
                      "proof-by-contradiction",
                      "imply-intro",
                      "imply-elim",
                      "iff-intro",
                      "iff-elim-forward",
                      "iff-elim-backward",
                      "prop-intro",
                      "context-commutative",
                      "context-idempotent-1",
                      "context-idempotent-2"
                    ]
                  }
                }
              ]
            },
            "Typed Lambda Calculus": {
              "PackageElemMod": [
                {
                  "is_folded": true,
                  "imports": [],
                  "nodes": {
                    "dict": {
                      "Context": {
                        "NodeGrammar": [
                          {
                            "is_folded": false,
                            "has_locked": true,
                            "metavar_regex": "[ΓΔ]([1-9][0-9]*|'*)",
                            "literal_regex": null,
                            "choices": [
                              {
                                "formats": [
                                  "ε"
                                ],
                                "sub_grammars": []
                              },
                              {
                                "formats": [
                                  "",
                                  ",",
                                  ""
                                ],
                                "sub_grammars": [
                                  "Context",
                                  "Judgement"
                                ]
                              }
                            ]
                          }
                        ]
                      },
                      "Hypothetical Judgement": {
                        "NodeGrammar": [
                          {
                            "is_folded": false,
                            "has_locked": true,
                            "metavar_regex": null,
                            "literal_regex": null,
                            "choices": [
                              {
                                "formats": [
                                  "",
                                  "⊢",
                                  ""
                                ],
                                "sub_grammars": [
                                  "Context",
                                  "Judgement"
                                ]
                              }
                            ]
                          }
                        ]
                      },
                      "Judgement": {
                        "NodeGrammar": [
                          {
                            "is_folded": false,
                            "has_locked": true,
                            "metavar_regex": null,
                            "literal_regex": null,
                            "choices": [
                              {
                                "formats": [
                                  "",
                                  ":",
                                  ""
                                ],
                                "sub_grammars": [
                                  "Term",
                                  "Type"
                                ]
                              }
                            ]
                          }
                        ]
                      },
                      "Term": {
                        "NodeGrammar": [
                          {
                            "is_folded": false,
                            "has_locked": true,
                            "metavar_regex": "[M-Z]([1-9][0-9]*|'*)",
                            "literal_regex": null,
                            "choices": [
                              {
                                "formats": [
                                  "",
                                  ""
                                ],
                                "sub_grammars": [
                                  "Variable"
                                ]
                              },
                              {
                                "formats": [
                                  "λ",
                                  ":",
                                  ".",
                                  ""
                                ],
                                "sub_grammars": [
                                  "Variable",
                                  "Type",
                                  "Term"
                                ]
                              },
                              {
                                "formats": [
                                  "",
                                  "",
                                  ""
                                ],
                                "sub_grammars": [
                                  "Term",
                                  "Term"
                                ]
                              }
                            ]
                          }
                        ]
                      },
                      "Type": {
                        "NodeGrammar": [
                          {
                            "is_folded": false,
                            "has_locked": true,
                            "metavar_regex": "[A-L]([1-9][0-9]*|'*)",
                            "literal_regex": null,
                            "choices": [
                              {
                                "formats": [
                                  "",
                                  "→",
                                  ""
                                ],
                                "sub_grammars": [
                                  "Type",
                                  "Type"
                                ]
                              }
                            ]
                          }
                        ]
                      },
                      "Variable": {
                        "NodeGrammar": [
                          {
                            "is_folded": false,
                            "has_locked": true,
                            "metavar_regex": null,
                            "literal_regex": "[a-z]([1-9][0-9]*|'*)",
                            "choices": []
                          }
                        ]
                      },
                      "arrow-elim": {
                        "NodeRule": [
                          {
                            "is_folded": false,
                            "has_locked": true,
                            "allow_reduction": false,
                            "parameters": [
                              {
                                "grammar": "Type",
                                "var_name": "A"
                              }
                            ],
                            "conclusion": {
                              "grammar": "Hypothetical Judgement",
                              "term": {
                                "TermInd": [
                                  {
                                    "formats": [
                                      "",
                                      "⊢",
                                      ""
                                    ],
                                    "sub_grammars": [
                                      "Context",
                                      "Judgement"
                                    ]
                                  },
                                  [
                                    {
                                      "TermVar": [
                                        "Γ"
                                      ]
                                    },
                                    {
                                      "TermInd": [
                                        {
                                          "formats": [
                                            "",
                                            ":",
                                            ""
                                          ],
                                          "sub_grammars": [
                                            "Term",
                                            "Type"
                                          ]
                                        },
                                        [
                                          {
                                            "TermInd": [
                                              {
                                                "formats": [
                                                  "",
                                                  "",
                                                  ""
                                                ],
                                                "sub_grammars": [
                                                  "Term",
                                                  "Term"
                                                ]
                                              },
                                              [
                                                {
                                                  "TermVar": [
                                                    "M"
                                                  ]
                                                },
                                                {
                                                  "TermVar": [
                                                    "N"
                                                  ]
                                                }
                                              ]
                                            ]
                                          },
                                          {
                                            "TermVar": [
                                              "B"
                                            ]
                                          }
                                        ]
                                      ]
                                    }
                                  ]
                                ]
                              }
                            },
                            "premises": [
                              {
                                "PremiseDirect": [
                                  {
                                    "grammar": "Hypothetical Judgement",
                                    "term": {
                                      "TermInd": [
                                        {
                                          "formats": [
                                            "",
                                            "⊢",
                                            ""
                                          ],
                                          "sub_grammars": [
                                            "Context",
                                            "Judgement"
                                          ]
                                        },
                                        [
                                          {
                                            "TermVar": [
                                              "Γ"
                                            ]
                                          },
                                          {
                                            "TermInd": [
                                              {
                                                "formats": [
                                                  "",
                                                  ":",
                                                  ""
                                                ],
                                                "sub_grammars": [
                                                  "Term",
                                                  "Type"
                                                ]
                                              },
                                              [
                                                {
                                                  "TermVar": [
                                                    "M"
                                                  ]
                                                },
                                                {
                                                  "TermInd": [
                                                    {
                                                      "formats": [
                                                        "",
                                                        "→",
                                                        ""
                                                      ],
                                                      "sub_grammars": [
                                                        "Type",
                                                        "Type"
                                                      ]
                                                    },
                                                    [
                                                      {
                                                        "TermVar": [
                                                          "A"
                                                        ]
                                                      },
                                                      {
                                                        "TermVar": [
                                                          "B"
                                                        ]
                                                      }
                                                    ]
                                                  ]
                                                }
                                              ]
                                            ]
                                          }
                                        ]
                                      ]
                                    }
                                  }
                                ]
                              },
                              {
                                "PremiseDirect": [
                                  {
                                    "grammar": "Hypothetical Judgement",
                                    "term": {
                                      "TermInd": [
                                        {
                                          "formats": [
                                            "",
                                            "⊢",
                                            ""
                                          ],
                                          "sub_grammars": [
                                            "Context",
                                            "Judgement"
                                          ]
                                        },
                                        [
                                          {
                                            "TermVar": [
                                              "Γ"
                                            ]
                                          },
                                          {
                                            "TermInd": [
                                              {
                                                "formats": [
                                                  "",
                                                  ":",
                                                  ""
                                                ],
                                                "sub_grammars": [
                                                  "Term",
                                                  "Type"
                                                ]
                                              },
                                              [
                                                {
                                                  "TermVar": [
                                                    "N"
                                                  ]
                                                },
                                                {
                                                  "TermVar": [
                                                    "A"
                                                  ]
                                                }
                                              ]
                                            ]
                                          }
                                        ]
                                      ]
                                    }
                                  }
                                ]
                              }
                            ]
                          }
                        ]
                      }
                    },
                    "order": [
                      "Term",
                      "Variable",
                      "Type",
                      "Judgement",
                      "Context",
                      "Hypothetical Judgement",
                      "arrow-elim"
                    ]
                  }
                }
              ]
            }
          }
        }
      ]
    }
  }
}"""
