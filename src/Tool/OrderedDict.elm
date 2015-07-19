module Tool.OrderedDict where

import Dict exposing (Dict)
import List

import Tool.Util exposing (list_element_unique, list_unordered_identical)


-- constrain:
--   key must be unique in `order`
--   `order` and key list of `dict` must be (unorderly) identical
type alias OrderedDict comparable a
 = { dict : Dict comparable a
   , order : List comparable
   }

validate_ordered_dict : OrderedDict comparable a -> Bool
validate_ordered_dict ordered_dict
  = list_unordered_identical (Dict.keys ordered_dict.dict) ordered_dict.order
      && list_element_unique ordered_dict.order
