module Tools.Utils where

import Debug
import Set exposing (Set)

import Focus exposing (Focus)

list_skeleton : a -> List a
list_skeleton x = [x]

list_get_elem : Int -> List a -> a
list_get_elem index list =
  case list |> List.drop index |> List.head of
    Nothing   -> Debug.crash "from Tools.Utils.list_get_elem"
    Just elem -> elem

list_update_elem : Int -> (a -> a) -> List a -> List a
list_update_elem index update_func list =
  case list of
    [] -> []
    elem :: list' ->
      if index <= 0 then
        (update_func elem) :: list'
      else
        elem :: (list_update_elem (index - 1) update_func list')

list_focus_elem : Int -> Focus (List a) a
list_focus_elem index =
  Focus.create (list_get_elem index) (list_update_elem index)

-- search for the first index of the first occurrence
-- if not found, return the index of next element
-- e.g. ['a', 'c'], 'a' => 0, 'b' => 1, 'c' => 1
-- pre: the given list must be sorted
sorted_list_get_index : comparable -> List comparable -> Int
sorted_list_get_index target_elem list =
  case list of
    [] -> 0
    elem :: list' -> if target_elem <= elem then 0
                       else (1 + sorted_list_get_index target_elem list')

list_insert : Int -> a -> List a -> List a
list_insert n x xs =
  if n <= 0 then x :: xs else
    case xs of
      []      -> [x]
      y :: ys -> y :: (list_insert (n - 1) x ys)

parity_pair_extract : Int -> (a, a) -> a
parity_pair_extract parity =
  if parity % 2 == 0 then fst else snd

-- for each element, if there is at least one element on RHS, remove itself
list_remove_duplication : List a -> List a
list_remove_duplication xs =
  List.foldr (\x acc -> if List.member x acc then acc else x :: acc ) [] xs

-- need to write this function, can't use technique "convert to set and compare"
-- since, eg Set.fromList([4, 5]) /= Set.fromList([5, 4])
are_list_unorderly_equal_to : List comparable -> List comparable -> Bool
are_list_unorderly_equal_to xs ys =
  List.sort xs == List.sort ys

are_list_elements_unique : List a -> Bool
are_list_elements_unique xs =
  xs == list_remove_duplication xs
