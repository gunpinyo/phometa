module Tools.OrderedDict where

import Dict exposing (Dict)

import Tools.Utils exposing (are_list_elements_unique,
                             are_list_unorderly_equal_to,
                             list_insert)

-- has constrain, see `check_ordered_dict`
type alias OrderedDict comparable a =
  { dict  : Dict comparable a
  , order : List comparable
  }

ordered_dict_empty : OrderedDict comparable a
ordered_dict_empty =
  { dict  = Dict.empty
  , order = []
  }

check_ordered_dict : OrderedDict comparable a -> Bool
check_ordered_dict ordered_dict =
  are_list_unorderly_equal_to (Dict.keys ordered_dict.dict) ordered_dict.order
     && are_list_elements_unique ordered_dict.order

ordered_dict_insert : Int -> comparable -> a -> OrderedDict comparable a
                        -> OrderedDict comparable a
ordered_dict_insert index key value ordered_dict =
  { dict  = Dict.insert key value ordered_dict.dict
  , order = ordered_dict.order
              |> List.filter (\key' -> key /= key')
              |> list_insert index key
  }

ordered_dict_append : comparable -> a -> OrderedDict comparable a
                        -> OrderedDict comparable a
ordered_dict_append key value ordered_dict =
  ordered_dict_insert (List.length ordered_dict.order) key value ordered_dict

ordered_dict_from_list : List (comparable, a) -> OrderedDict comparable a
ordered_dict_from_list list =
  { dict  = Dict.fromList list
  , order = List.map fst list
  }

ordered_dict_to_list : OrderedDict comparable a -> List (comparable, a)
ordered_dict_to_list ordered_dict =
  let func key = Dict.get key ordered_dict.dict
                   |> Maybe.map (\value -> (key, value))
   in List.filterMap func ordered_dict.order
