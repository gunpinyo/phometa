module Tools.Utils where

----import Array exposing (Array)
----import Dict exposing (Dict)
import Set exposing (Set)

parity_pair_extract : Int -> (a, a) -> a
parity_pair_extract parity =
  if parity % 2 == 0 then fst else snd

-- need to write this function
-- since, eg Set.fromList([4, 5]) /= Set.fromList([5, 4])
are_set_equal : Set comparable -> Set comparable -> Bool
are_set_equal a b = Set.diff a b == Set.empty && Set.diff b a == Set.empty

are_list_elements_unique : List comparable -> Bool
are_list_elements_unique xs =
  List.length (xs |> Set.fromList |> Set.toList) == List.length xs

---- if any list is not unique, return False immediately
--list_is_subset_of_list : List comparable -> List comparable -> Bool
--list_is_subset_of_list xs ys =
--  list_element_unique xs && list_element_unique ys
--    && List.foldl (\x acc -> acc && List.member x ys) True xs

---- if any list is not unique, return False immediately
--list_unordered_identical : List comparable -> List comparable -> Bool
--list_unordered_identical xs ys =
--  list_is_subset_of_list xs ys && list_is_subset_of_list ys xs
