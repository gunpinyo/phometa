module Updates.KeymapUtils where

import Dict

import Tools.KeyboardExtra exposing (RawKeystroke, Keystroke, to_keystroke)
import Models.Model exposing (Command, KeyBinding(..), KeyDescription,
                              Keymap, RingChoiceCounter)

empty_keymap : Keymap
empty_keymap = build_keymap []

-- if there a collision, second one wins
merge_keymaps : Keymap -> Keymap -> Keymap
merge_keymaps = flip Dict.union

merge_keymaps_list : List Keymap -> Keymap
merge_keymaps_list list = List.foldl merge_keymaps empty_keymap list

get_key_binding : Keystroke -> Keymap -> Maybe KeyBinding
get_key_binding keystroke keymap =
  Maybe.map snd <| Dict.get keystroke keymap

build_keymap : List (RawKeystroke, KeyDescription, KeyBinding) -> Keymap
build_keymap list =
  let tuple_to_dict_elem (raw_keystroke, key_binding_name, key_binding) =
        (to_keystroke raw_keystroke,
           ((raw_keystroke, key_binding_name), key_binding))
   in Dict.fromList <| List.map tuple_to_dict_elem list

build_keymap_cond : Bool -> List (RawKeystroke, KeyDescription, KeyBinding)
                      -> Keymap
build_keymap_cond cond list = if cond then build_keymap list else empty_keymap

keymap_ring_choices : List (String, a) -> RingChoiceCounter ->
                        ((String, a) -> Command) ->
                        (RingChoiceCounter -> Command) -> Keymap
keymap_ring_choices choices raw_counter choice_to_command counter_to_command  =
  if List.isEmpty choices then empty_keymap else
    let number_of_pages = (List.length choices // 10)
                            + if List.length choices % 10 == 0 then 0 else 1
        counter = if 0 <= raw_counter && raw_counter < number_of_pages
                    then raw_counter else 0
        current_choices = choices
                            |> List.drop (counter * 10)
                            |> List.take 10 -- if has less than 10 elements
                                            -- `List.take` will takes everything
        items =
          List.indexedMap (\index choice ->
            (toString ((index + 1) % 10),
             fst choice, KbCmd <| choice_to_command choice))
            current_choices
        next_counter = (counter + 1) % number_of_pages
        prev_counter = (counter - 1) % number_of_pages
        prev_next_items = if number_of_pages == 1 then [] else [
          ("Alt-[", "prev choices", KbCmd <| counter_to_command prev_counter),
          ("Alt-]", "next choices", KbCmd <| counter_to_command next_counter)]
     in build_keymap (items ++ prev_next_items)
