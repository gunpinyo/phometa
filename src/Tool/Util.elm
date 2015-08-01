--module Tool.Util where

----import Array exposing (Array)
----import Dict exposing (Dict)
--import List
--import Set


--list_element_unique : List comparable -> Bool
--list_element_unique xs =
--  (xs |> Set.fromList |> Set.toList |> List.length) == List.length xs

---- if any list is not unique, return False immediately
--list_is_subset_of_list : List comparable -> List comparable -> Bool
--list_is_subset_of_list xs ys =
--  list_element_unique xs && list_element_unique ys
--    && List.foldl (\x acc -> acc && List.member x ys) True xs

---- if any list is not unique, return False immediately
--list_unordered_identical : List comparable -> List comparable -> Bool
--list_unordered_identical xs ys =
--  list_is_subset_of_list xs ys && list_is_subset_of_list ys xs
