module Tools.Utils where

import Set exposing (Set)

list_skeleton : a -> List a
list_skeleton x = [x]

parity_pair_extract : Int -> (a, a) -> a
parity_pair_extract parity =
  if parity % 2 == 0 then fst else snd

-- for each element if there is the same element on RHS, remove it self
remove_list_duplicate : List comparable -> List comparable
remove_list_duplicate xs =
  List.foldr (\x acc -> if List.member x acc then acc else x :: acc ) [] xs

-- need to write this function, can't use technique "convert to set and compare"
-- since, eg Set.fromList([4, 5]) /= Set.fromList([5, 4])
are_list_unorderly_equal_to : List comparable -> List comparable -> Bool
are_list_unorderly_equal_to xs ys =
  List.sort xs == List.sort ys

are_list_elements_unique : List comparable -> Bool
are_list_elements_unique xs =
  xs == remove_list_duplicate xs
