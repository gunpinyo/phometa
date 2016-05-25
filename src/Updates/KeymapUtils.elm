module Updates.KeymapUtils where

import Dict
import String

import Focus exposing (Focus, (=>))

import Tools.CssExtra exposing (CssInlineStr, CssInlineToken(..),
                                css_inline_str_embed,
                                css_inline_str_tokenise)
import Tools.KeyboardExtra exposing (RawKeystroke, Keystroke, to_keystroke)
import Tools.Unicode exposing (name_to_unicode)
import Models.Focus exposing (filters_, counter_, unicode_state_)
import Models.Model exposing (Model, Command, KeyBinding(..), KeyDescription,
                              Keymap, Counter, AutoComplete)
import Models.ModelUtils exposing (focus_auto_complete_unicode)
import Updates.CommonCmd exposing (cmd_nothing)

empty_keymap : Keymap
empty_keymap = build_keymap []

merge_keymaps : Keymap -> Keymap -> Keymap
merge_keymaps fst_keymap snd_keymap =
  let result = Dict.union snd_keymap fst_keymap -- a collision, second one wins
   in case (Dict.get [] fst_keymap, Dict.get [] snd_keymap) of
        (Just ((fst_key, fst_val), _), Just ((snd_key, snd_val), _)) ->
          Dict.insert [] ((snd_key ++ "\n" ++ fst_key,
                           snd_val ++ "\n" ++ fst_val), KbCmd cmd_nothing)
                         result
        _  -> result

merge_keymaps_list : List Keymap -> Keymap
merge_keymaps_list list = List.foldl merge_keymaps empty_keymap list

get_key_binding : Keystroke -> Keymap -> Maybe KeyBinding
get_key_binding keystroke keymap =
  Maybe.map snd <| Dict.get keystroke keymap

build_keymap : List (RawKeystroke, KeyDescription, KeyBinding) -> Keymap
build_keymap list =
  let tuple_to_dict_elem_func (raw_keystroke, key_binding_name, key_binding) =
        (to_keystroke raw_keystroke,
           ((raw_keystroke, key_binding_name), key_binding))
      (info_items, actual_items) = list |> List.map tuple_to_dict_elem_func
                                        |> List.partition (fst >> List.isEmpty)
      info_item_func (_, ((key, val), _)) maybe_acc = case maybe_acc of
         Nothing -> Just ([], ((key, val), KbCmd cmd_nothing))
         Just (_, ((acc_key, acc_val), _)) ->
           Just ([], ((acc_key ++ "\n" ++ key, acc_val ++ "\n" ++ val)
                     , KbCmd cmd_nothing))
      info_item' = case List.foldl info_item_func Nothing info_items of
                     Nothing -> []
                     Just item -> [item]
   in Dict.fromList (info_item' ++ actual_items)

build_keymap_cond : Bool -> List (RawKeystroke, KeyDescription, KeyBinding)
                      -> Keymap
build_keymap_cond cond list = if cond then build_keymap list else empty_keymap

update_auto_complete : String -> Focus Model AutoComplete -> Command
update_auto_complete filters auto_complete_focus model =
  let unicode_focus = (auto_complete_focus => unicode_state_)
   in case Focus.get unicode_focus model of
        Nothing -> Focus.set auto_complete_focus { filters = filters
                                                 , counter = 0
                                                 , unicode_state = Nothing
                                                 } model
        Just record -> Focus.set unicode_focus (Just { filters = filters
                                                     , counter = 0
                                                     }) model

keymap_auto_complete : List (CssInlineStr, Command) -> Bool ->
                         Maybe ((String -> Command), String) ->
                         Focus Model AutoComplete -> Model -> Keymap
keymap_auto_complete original_choices is_visible maybe_for_hit_return
                       auto_complete_focus model =
  let auto_complete = Focus.get auto_complete_focus model
      in_unicode_state = auto_complete.unicode_state /= Nothing
      unicode_focus = (auto_complete_focus => unicode_state_)
      quit_unicode_cmd = Focus.set unicode_focus Nothing
      filter_func target_string filtering_pattern =
        String.contains (String.toLower filtering_pattern)
                        (String.toLower target_string)
      (filters, raw_counter, choices) = case auto_complete.unicode_state of
        Nothing ->
          let filtering_patterns = String.split " " auto_complete.filters
              filtered_choices = List.filter
                (\ (choice_str, _) ->
                 let choice_plain_str = choice_str
                       |> css_inline_str_tokenise
                       |> List.filterMap (\css_token -> case css_token of
                            CssInlineTokenText string -> Just string
                            _                         -> Nothing)
                       |> List.intersperse " "
                       |> String.concat
                  in List.all (filter_func choice_plain_str) filtering_patterns)
                original_choices
           in (auto_complete.filters, auto_complete.counter, filtered_choices)
        Just record ->
          let filtering_patterns = String.split " " record.filters
              filtered_unicode = List.filter (\ (key, val) ->
                List.all (filter_func key) filtering_patterns) name_to_unicode
              cmd_func val =
                Focus.update (auto_complete_focus => filters_) ((flip (++)) val)
                  >> quit_unicode_cmd
              map_func (key, val) =
                ( key ++ " " ++ (css_inline_str_embed "newly-defined-block" val)
                , cmd_func val )
           in (record.filters,record.counter,List.map map_func filtered_unicode)
      key_prefix = if is_visible then model.config.spacial_key_prefix else ""
      filters_css = css_inline_str_embed "newly-defined-block" <|
                      if filters == "" then " " else filters
      toggle_items = if not is_visible then []
        else if in_unicode_state then
          [ ("Escape", "quit searching unicode", KbCmd quit_unicode_cmd)
          , ("(Input)", filters_css, KbCmd cmd_nothing) ]
        else
          ( key_prefix ++ "u", "search unicode",
            KbCmd <| Focus.set unicode_focus
                  <| Just {filters = "", counter = 0})
          :: ("(Input)", filters_css, KbCmd cmd_nothing)
          :: (case maybe_for_hit_return of
                Nothing -> []
                Just (on_hit_return, hit_return_desc) ->
                  [("Return", hit_return_desc, KbCmd <| on_hit_return filters)])
   in if List.isEmpty choices then build_keymap toggle_items else let
      number_of_pages = (List.length choices // 9)
                          + if List.length choices % 9 == 0 then 0 else 1
      counter = if 0 <= raw_counter && raw_counter < number_of_pages
                  then raw_counter else 0
      current_choices = choices
                          |> List.drop (counter * 9)
                          |> List.take 9  -- if has less than 9 elements
                                          -- `List.take` will takes everything
      items = List.indexedMap (\index (choice_str, choice_command) ->
                                 (key_prefix ++ toString (index + 1),
                                 choice_str, KbCmd choice_command))
                              current_choices
      auto_items = case current_choices of
        [(choice_str, choice_command)] ->
          if in_unicode_state || maybe_for_hit_return == Nothing
            then [("Return", choice_str, KbCmd choice_command)] else []
        _ -> []
      jump_page_cmd displacement =
         let new_counter = (counter + displacement) % number_of_pages
             counter_focus = auto_complete_focus =>
               if in_unicode_state
                 then focus_auto_complete_unicode => counter_
                 else counter_
          in Focus.set counter_focus new_counter
      prev_next_items = if number_of_pages == 1 then [] else [
        (key_prefix ++ "[", "prev choices", KbCmd <| jump_page_cmd (-1)),
        (key_prefix ++ "]", "next choices", KbCmd <| jump_page_cmd 1)]
   in -- `auto_item` must come after `toggle_items` since it might override it
      build_keymap (toggle_items ++ auto_items ++ items ++ prev_next_items)
