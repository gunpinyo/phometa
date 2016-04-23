module Updates.KeymapUtils where

import Dict
import String

import Focus exposing (Focus, (=>))

import Tools.CssExtra exposing (CssInlineStr, CssInlineToken(..),
                                css_inline_str_embed,
                                css_inline_str_tokenise)
import Tools.KeyboardExtra exposing (RawKeystroke, Keystroke,
                                     to_keystroke, transfrom_to_unicode_string)
import Models.Focus exposing (counter_, is_searching_)
import Models.Model exposing (Model, Command, KeyBinding(..), KeyDescription,
                              Keymap, Counter, AutoComplete)
import Updates.CommonCmd exposing (cmd_nothing)

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

update_auto_complete : String -> Focus Model AutoComplete -> Command
update_auto_complete raw_filters auto_complete_focus model =
  let new_auto_complete = { raw_filters = raw_filters
                          , counter = 0
                          , is_searching = True
                          }
   in Focus.set auto_complete_focus new_auto_complete model

cmd_toggle_search : Focus Model AutoComplete -> Command
cmd_toggle_search auto_complete_focus =
  Focus.update (auto_complete_focus => is_searching_) not

keymap_auto_complete : List (CssInlineStr, Command) ->
                         Maybe (String -> Command) ->
                         Focus Model AutoComplete -> Model -> Keymap
keymap_auto_complete raw_choices maybe_on_hit_return auto_complete_focus model =
  let auto_complete = Focus.get auto_complete_focus model
      unicode_filters = transfrom_to_unicode_string auto_complete.raw_filters
      filtering_patterns = String.split " " unicode_filters
      choices = List.filter (\ (choice_str, _) ->
                  let choice_plain_str = choice_str
                        |> css_inline_str_tokenise
                        |> List.filterMap (\css_token -> case css_token of
                             CssInlineTokenText string -> Just string
                             _                         -> Nothing)
                        |> List.intersperse " "
                        |> String.concat
                   in List.all (\ filtering_pattern ->
                        String.contains (String.toLower filtering_pattern)
                                        (String.toLower choice_plain_str)
                      ) filtering_patterns
                ) raw_choices
      toggle_search_cmd = cmd_toggle_search auto_complete_focus
      hit_return_cmd = case maybe_on_hit_return of
                         Nothing -> cmd_nothing
                         Just on_hit_return -> on_hit_return unicode_filters
      toggle_items = if not auto_complete.is_searching then
          [("Space", "go to typing mode", KbCmd toggle_search_cmd)]
        else if unicode_filters /= "" then
          [("Return",
            css_inline_str_embed "newly-defined-block" unicode_filters,
            KbCmd <| toggle_search_cmd >> hit_return_cmd)]
        else []
   in if List.isEmpty choices then build_keymap toggle_items else let
      number_of_pages = (List.length choices // 9)
                          + if List.length choices % 9 == 0 then 0 else 1
      counter = if 0 <= auto_complete.counter &&
                    auto_complete.counter < number_of_pages
                  then auto_complete.counter else 0
      current_choices = choices
                          |> List.drop (counter * 9)
                          |> List.take 9 -- if has less than 10 elements
                                          -- `List.take` will takes everything
      key_prefix = if auto_complete.is_searching
                     then model.config.spacial_key_prefix else ""
      items = List.indexedMap (\index (choice_str, choice_command) ->
                                (key_prefix ++ toString (index + 1),
                                 choice_str, KbCmd choice_command))
                              current_choices
      auto_items = case current_choices of
        [(choice_str, choice_command)] ->
          if auto_complete.is_searching && maybe_on_hit_return == Nothing
            then [("Return", choice_str, KbCmd choice_command)] else []
        _ -> []
      next_counter = (counter + 1) % number_of_pages
      next_page_cmd = Focus.set (auto_complete_focus => counter_) next_counter
      prev_counter = (counter - 1) % number_of_pages
      prev_page_cmd = Focus.set (auto_complete_focus => counter_) prev_counter
      prev_next_items = if number_of_pages == 1 then [] else [
        (key_prefix ++ "[", "prev choices", KbCmd <| next_page_cmd),
        (key_prefix ++ "]", "next choices", KbCmd <| prev_page_cmd)]
   in -- `auto_item` must come after `toggle_items` since it might override it
      build_keymap (toggle_items ++ auto_items ++ items ++ prev_next_items)
