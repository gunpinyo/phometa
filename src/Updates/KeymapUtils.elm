module Updates.KeymapUtils where

import Dict
import String

import Focus exposing (Focus, (=>))

import Tools.CssExtra exposing (CssInlineStr)
import Tools.KeyboardExtra exposing (RawKeystroke, Keystroke, to_keystroke)
import Models.Focus exposing (counter_)
import Models.Model exposing (Model, Command, KeyBinding(..), KeyDescription,
                              Keymap, Counter)

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

keymap_ring_choices : List (String, a) -> Counter ->
                        ((String, a) -> Command) ->
                        (Counter -> Command) -> Keymap
keymap_ring_choices choices raw_counter choice_to_command counter_to_command  =
  if List.isEmpty choices then empty_keymap else
    let number_of_pages = (List.length choices // 9)
                            + if List.length choices % 9 == 0 then 0 else 1
        counter = if 0 <= raw_counter && raw_counter < number_of_pages
                    then raw_counter else 0
        current_choices = choices
                            |> List.drop (counter * 9)
                            |> List.take 9 -- if has less than 9 elements
                                            -- `List.take` will takes everything
        items =
          List.indexedMap (\index choice ->
            (toString (index + 1),
             fst choice, KbCmd <| choice_to_command choice))
            current_choices
        next_counter = (counter + 1) % number_of_pages
        prev_counter = (counter - 1) % number_of_pages
        prev_next_items = if number_of_pages == 1 then [] else [
          ("Alt-[", "prev choices", KbCmd <| counter_to_command prev_counter),
          ("Alt-]", "next choices", KbCmd <| counter_to_command next_counter)]
     in build_keymap (items ++ prev_next_items)

-- update_auto_complete : String -> Focus Model AutoComplete -> Model -> Model
-- update_auto_complete raw_filtering_patterns auto_complete_focus model =
--   let new_auto_complete = { raw_filtering_patterns = raw_filtering_patterns
--                           , counter = 0 }
--    in Focus.set auto_complete_focus new_auto_complete model

-- keymap_auto_complete : List (CssInlineStr, Command) ->
--                            Focus Model AutoComplete -> Model -> Keymap
-- keymap_auto_complete raw_choices auto_complete_focus model =
--   let auto_complete = Focus.get auto_complete_focus model
--       filtering_patterns = String.split " " auto_complete.raw_filtering_patterns
--       choices = List.filter (\ (choice_str, _) ->
--                   List.all (\ filtering_pattern ->
--                     String.contains filtering_pattern choice_str
--                   ) filtering_patterns
--                 ) raw_choices
--    in if List.isEmpty choices then empty_keymap else let
--       number_of_pages = (List.length choices // 10)
--                           + if List.length choices % 10 == 0 then 0 else 1
--       counter = if 0 <= auto_complete.counter &&
--                     auto_complete.counter < number_of_pages
--                   then auto_complete.counter else 0
--       current_choices = choices
--                           |> List.drop (counter * 10)
--                           |> List.take 10 -- if has less than 10 elements
--                                           -- `List.take` will takes everything
--       items = List.indexedMap
--         (\index (choice_str, choice_command) ->
--           ("Alt-" ++ toString index, choice_str, KbCmd <| choice_command))
--         current_choices
--       next_counter = (counter + 1) % number_of_pages
--       next_page_cmd = Focus.set (auto_complete_focus => counter_) next_counter
--       prev_counter = (counter - 1) % number_of_pages
--       prev_page_cmd = Focus.set (auto_complete_focus => counter_) prev_counter
--       prev_next_items = if number_of_pages == 1 then [] else [
--         ("Alt-[", "prev choices", KbCmd <| next_page_cmd),
--         ("Alt-]", "next choices", KbCmd <| prev_page_cmd)]
--    in build_keymap (items ++ prev_next_items)
