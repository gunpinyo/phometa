module Tools.OrderedDict where

import Dict exposing (Dict)

import Tools.Utils exposing (are_list_elements_unique,
                             are_list_unorderly_equal_to)

-- has constrain, see `check_ordered_dict`
type alias OrderedDict comparable a
 = { dict : Dict comparable a
   , order : List comparable
   }

check_ordered_dict : OrderedDict comparable a -> Bool
check_ordered_dict ordered_dict =
  are_list_unorderly_equal_to (Dict.keys ordered_dict.dict) ordered_dict.order
     && are_list_elements_unique ordered_dict.order
