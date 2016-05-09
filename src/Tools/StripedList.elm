module Tools.StripedList where

import Debug

-- represent a list that always has odd length
-- with odd element has type a and even element has type b
type StripedList a b
  = StripedListNil a
  | StripedListCons a b (StripedList a b)

striped_list_introduce : List a -> List b -> StripedList a b
striped_list_introduce list_a list_b =
  case (list_a, list_b) of
    (a :: list_a', b :: list_b') ->
      StripedListCons a b (striped_list_introduce list_a' list_b')
    ([a], []) -> StripedListNil a
    _ -> Debug.crash "from Tools.StripedList.striped_list_introduce"

striped_list_eliminate : (a -> c) -> (b -> c) -> StripedList a b -> List c
striped_list_eliminate func_a func_b list =
  case list of
    StripedListNil a -> [func_a a]
    StripedListCons a b list' ->
      func_a a :: func_b b :: striped_list_eliminate func_a func_b list'

striped_list_get_even_element : StripedList a b -> List a
striped_list_get_even_element list =
  case list of
    StripedListNil a -> [a]
    StripedListCons a b list' -> a :: striped_list_get_even_element list'

striped_list_get_odd_element : StripedList a b -> List b
striped_list_get_odd_element list =
  case list of
    StripedListNil a -> []
    StripedListCons a b list' -> b :: striped_list_get_odd_element list'

stripe_two_list_together : List c -> List c -> List c
stripe_two_list_together list_a list_b =
  case (list_a, list_b) of
    (a :: list_a', b :: list_b') ->
      a :: b :: (stripe_two_list_together list_a' list_b')
    ([a] , []) -> [a]
    _ -> Debug.crash "from Tools.StripedList.stripe_two_list_together"
