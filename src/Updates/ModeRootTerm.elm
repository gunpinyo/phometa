module Updates.ModeRootTerm where

import Debug
import Dict
import String

import Focus exposing (Focus, (=>))

import Tools.Utils exposing (list_get_elem, sorted_list_get_index)
import Tools.CssExtra exposing (CssInlineStr, css_inline_str_embed)
import Tools.StripedList exposing (striped_list_get_even_element,
                                   striped_list_get_odd_element,
                                   striped_list_eliminate,
                                   stripe_two_list_together)
import Models.Focus exposing (mode_, micro_mode_, grammar_, reversed_ref_path_,
                              sub_cursor_path_, root_term_focus_, term_)
import Models.RepoModel exposing (VarName, ModulePath,
                                  GrammarName, Grammar, GrammarChoice,
                                  RootTerm, Term(..), VarType(..))
import Models.RepoUtils exposing (init_root_term, root_term_undefined_grammar,
                                  get_usable_grammar_names, get_grammar,
                                  get_variable_type, get_variable_css,
                                  focus_grammar, grammar_allow_variable,
                                  focus_sub_term, get_term_todo_cursor_paths,
                                  init_term_ind, get_sub_root_terms,
                                  auto_manipulate_term,
                                  get_usable_rule_names, apply_reduction)
import Models.Cursor exposing (IntCursorPath, get_cursor_info_from_cursor_tree,
                               cursor_tree_go_to_sub_elem)
import Models.Message exposing (Message(..))
import Models.Model exposing (Model, Command, KeyBinding(..), Keymap,
                              AutoComplete, Mode(..),
                              RecordModeRootTerm, MicroModeRootTerm(..),
                              EditabilityRootTerm(..))
import Models.ModelUtils exposing (focus_record_mode_root_term,
                                   init_auto_complete)
import Updates.CommonCmd exposing (cmd_nothing)
import Updates.Message exposing (cmd_send_message)
import Updates.KeymapUtils exposing (empty_keymap,
                                     merge_keymaps, merge_keymaps_list,
                                     build_keymap, build_keymap_cond,
                                     keymap_auto_complete)
import Updates.Cursor exposing (cmd_click_block)

embed_css_grammar_choice : GrammarChoice -> CssInlineStr
embed_css_grammar_choice grammar_choice =
  let fmt_func format = if format == "" then " " else
        css_inline_str_embed "ind-format-block" format
      gmr_func grammar_name =
        css_inline_str_embed "grammar-block" grammar_name
      gmr_length = List.length <| striped_list_get_odd_element grammar_choice
   in grammar_choice
        |> striped_list_eliminate fmt_func gmr_func
        |> List.indexedMap (\index css_inline ->
             if (index == 0 || index == 2 * gmr_length) && css_inline == " "
               then "" else css_inline)
        |> String.concat
        |> css_inline_str_embed "root-term-block"

embed_css_root_term : ModulePath -> Model -> RootTerm -> CssInlineStr
embed_css_root_term module_path model root_term =
  css_inline_str_embed "root-term-block" <|
    embed_css_term module_path model root_term.term root_term.grammar

embed_css_term : ModulePath -> Model -> Term -> GrammarName -> CssInlineStr
embed_css_term module_path model term grammar_name =
  case term of
    TermTodo ->
      css_inline_str_embed "term-todo-block" grammar_name
    TermVar var_name ->
      embed_css_term_var module_path model var_name grammar_name
    TermInd grammar_choice sub_terms ->
      let sub_grammars = striped_list_get_odd_element grammar_choice
          sub_term_inlines = List.map2 (embed_css_term module_path model)
                               sub_terms sub_grammars
          raw_formats = striped_list_get_even_element grammar_choice
          format_inlines = raw_formats
            |> List.indexedMap (\index format ->
                 if format == "" then
                   (if index == 0 || index == List.length raw_formats - 1
                      then "" else " ")
                 else
                   css_inline_str_embed "ind-format-block" format)
       in stripe_two_list_together format_inlines sub_term_inlines
            |> String.concat
            |> css_inline_str_embed "underlined-child-block"
            |> css_inline_str_embed "underlined-block"

embed_css_term_var : ModulePath -> Model -> VarName-> GrammarName-> CssInlineStr
embed_css_term_var module_path model var_name grammar_name =
  let css_class = get_variable_css module_path model var_name grammar_name
   in css_inline_str_embed css_class var_name

keymap_mode_root_term : RecordModeRootTerm -> Model -> Keymap
keymap_mode_root_term record model =
  case record.micro_mode of
    MicroModeRootTermSetGrammar auto_complete ->
      let choices = get_usable_grammar_names record.module_path model False |>
            List.map (\grammar_name ->
              (css_inline_str_embed "grammar-block" grammar_name,
               cmd_set_grammar grammar_name))
       in if record.editability /= EditabilityRootTermUpToGrammar
          then empty_keymap
          else merge_keymaps
                 (keymap_auto_complete choices True Nothing
                    focus_auto_complete model)
                 (build_keymap
                    [("⭡", "quit root term", KbCmd record.on_quit_callback)])
    MicroModeRootTermTodo auto_complete ->
      let (grammar_name, grammar) = get_grammar_at_sub_term model
          grammar_choice_choices = grammar.choices |>
            List.map (\grammar_choice ->
              let description = embed_css_grammar_choice grammar_choice
               in (description, cmd_set_sub_term (init_term_ind grammar_choice)
                                  >> cmd_jump_to_next_todo 0
                                  >> cmd_quit_if_has_no_todo))
          variable_choices = model
            |> record.get_existing_variables
            |> Dict.toList
            |> List.filterMap (\ (var_name, var_grammar_name) ->
                 if grammar_name == var_grammar_name then
                   Just (embed_css_term_var record.module_path model
                           var_name var_grammar_name,
                         cmd_set_var_at_sub_term True var_name)
                 else
                   Nothing)
       in if record.editability == EditabilityRootTermReadOnly
          then empty_keymap
          else
            merge_keymaps (keymap_after_set_grammar record model)
              (keymap_auto_complete (grammar_choice_choices ++ variable_choices)
                 True (Just <| (cmd_set_var_at_sub_term True,
                               "create metavar or literal"))
                 focus_auto_complete model)
    MicroModeRootTermNavigate auto_complete ->
      let sub_term_focus = (record.root_term_focus =>
                                 (focus_sub_term record.sub_cursor_path))
          cur_root_sub_term =
            { grammar = fst (get_grammar_at_sub_term model)
            , term = Focus.get sub_term_focus model}
          reduction_choices = get_usable_rule_names
                 (Just cur_root_sub_term.grammar) record.module_path model False
            |> (\rule_names -> if record.is_reducible then rule_names else [])
            |> List.map (\rule_name -> (apply_reduction rule_name
                 cur_root_sub_term record.module_path model, rule_name))
            |> List.filterMap (\ (maybe_root_term, rule_name) -> Maybe.map
                 (\root_term -> (root_term, rule_name)) maybe_root_term)
            |> List.map (\ (root_term, rule_name) ->
                 ( css_inline_str_embed "rule-block" rule_name
                 , Focus.set sub_term_focus root_term.term
                     >> record.on_modify_callback))
          children_choices = case cur_root_sub_term.term of
            TermTodo -> []   -- impossible for Todo to be navigate mode
            TermVar _ -> []  -- doesn't have any children
            TermInd grammar_choice sub_terms ->
              get_sub_root_terms grammar_choice sub_terms
                |> List.indexedMap (\index sub_root_sub_term ->
                     ( "jump to child " ++ toString (index + 1)
                     , Focus.get focus_record_mode_root_term model
                         |> Focus.update sub_cursor_path_ ((flip (++)) [index])
                         |> Focus.set micro_mode_
                             (if sub_root_sub_term.term == TermTodo
                              then MicroModeRootTermTodo init_auto_complete
                              else MicroModeRootTermNavigate init_auto_complete)
                         |> cmd_enter_mode_root_term
                     ))
       in merge_keymaps_list
           [ keymap_after_set_grammar record model
           , build_keymap [
                ("(Term)", embed_css_root_term record.module_path model
                 cur_root_sub_term, KbCmd cmd_nothing)]
           , build_keymap_cond (record.editability/=EditabilityRootTermReadOnly)
               [(model.config.spacial_key_prefix ++ "t",
                 "reset current term", KbCmd <| cmd_set_sub_term TermTodo)]
           , keymap_auto_complete (children_choices ++ reduction_choices)
               False Nothing focus_auto_complete model
           ]

keymap_after_set_grammar : RecordModeRootTerm -> Model -> Keymap
keymap_after_set_grammar record model =
  merge_keymaps_list [
    (let sub_term_focus = (record.root_term_focus =>
                             (focus_sub_term record.sub_cursor_path))
         cur_root_sub_term =
           { grammar = fst (get_grammar_at_sub_term model)
           , term = Focus.get sub_term_focus model}
      in build_keymap [
           ("(Grammar)", css_inline_str_embed "grammar-block"
              cur_root_sub_term.grammar, KbCmd cmd_nothing)]),
    build_keymap_cond (record.editability /= EditabilityRootTermReadOnly)
      [(model.config.spacial_key_prefix ++ "r",
        "reset root term", KbCmd cmd_reset_root_term)],
    build_keymap_cond
      (not <| List.isEmpty
           <| get_term_todo_cursor_paths
           <| Focus.get (record.root_term_focus => term_) model)
      [("⭠", "jump to prev todo",
          KbCmd <| cmd_jump_to_next_todo -1),
       ("⭢", "jump to next todo",
          KbCmd <| cmd_jump_to_next_todo 1)],
    if not <| List.isEmpty record.sub_cursor_path then
      build_keymap
        [("⭡", "jump to parent term", KbCmd cmd_jump_to_parent_term)]
    else
      build_keymap [("⭡", "quit root term", KbCmd record.on_quit_callback)]
  ]

cmd_enter_mode_root_term : RecordModeRootTerm -> Command
cmd_enter_mode_root_term record =
  let cursor_info = get_cursor_info_from_cursor_tree record
   in (Focus.set mode_ (ModeRootTerm record)) >> (cmd_click_block cursor_info)

cmd_set_var_at_sub_term : Bool -> String -> Command
cmd_set_var_at_sub_term verbose cur_var_name model =
  let record = Focus.get focus_record_mode_root_term model
      existing_vars = record.get_existing_variables model
      (cur_grammar_name, _) = get_grammar_at_sub_term model
      cur_var_css_inline = embed_css_term_var record.module_path model
                             cur_var_name cur_grammar_name
      cur_grammar_css_inline = css_inline_str_embed
                                 "grammar-block" cur_grammar_name
      maybe_exception_str = case Dict.get cur_var_name existing_vars of
        Nothing ->
          if not record.can_create_fresh_vars then
            Just "cannot create fresh variable here"
          else if get_variable_type record.module_path model
                    cur_var_name cur_grammar_name == Nothing then
            Just <| cur_var_css_inline
                 ++ " doesn't match any variable regex of "
                 ++ cur_grammar_css_inline
          else
            Nothing
        Just existing_grammar_name ->
          if existing_grammar_name /= cur_grammar_name then
            Just <| cur_var_css_inline
                 ++ " exists but has grammar as "
                 ++ css_inline_str_embed "grammar-block" existing_grammar_name
                 ++ " rather than "
                 ++ cur_grammar_css_inline
          else
            Nothing
   in case maybe_exception_str of
        Nothing -> model
          |> cmd_set_sub_term (TermVar cur_var_name)
          |> cmd_quit_if_has_no_todo
        Just exception_str -> model
          |> Focus.set focus_auto_complete init_auto_complete
          |> if verbose then
               cmd_send_message (MessageException exception_str)
             else
               cmd_nothing

cmd_set_grammar : GrammarName -> Command
cmd_set_grammar grammar_name model =
  let record = Focus.get focus_record_mode_root_term model
   in model
       |> Focus.set (record.root_term_focus => grammar_) grammar_name
       |> Focus.set (focus_record_mode_root_term => micro_mode_)
                    (MicroModeRootTermTodo init_auto_complete)
       |> cmd_set_sub_term TermTodo -- for auto manipulation of TermTodo

cmd_set_sub_term : Term -> Command
cmd_set_sub_term term model =
  let record = Focus.get focus_record_mode_root_term model
   in model
        |> Focus.set (record.root_term_focus =>
             (focus_sub_term record.sub_cursor_path))
             (auto_manipulate_term (snd <| get_grammar_at_sub_term model)
                term record.module_path model)
        |> record.on_modify_callback
        |> cmd_jump_to_next_todo 0

cmd_jump_to_parent_term : Command
cmd_jump_to_parent_term model =
  let record = Focus.get focus_record_mode_root_term model
                 |> Focus.update sub_cursor_path_ (\cursor_path ->
                      List.take ((List.length cursor_path) - 1) cursor_path)
                 |> Focus.set micro_mode_
                      (MicroModeRootTermNavigate init_auto_complete)
   in cmd_enter_mode_root_term record model

cmd_jump_to_next_todo : Int -> Command
cmd_jump_to_next_todo displacement model =
  let record = Focus.get focus_record_mode_root_term model
      todo_cursor_paths = get_term_todo_cursor_paths <|
        Focus.get (record.root_term_focus => term_) model
      record' =
        if List.isEmpty todo_cursor_paths then
          record -- if no todos, go to root_term
            |> Focus.set sub_cursor_path_ []
            |> Focus.set micro_mode_
                 (MicroModeRootTermNavigate init_auto_complete)
        else
          record
            |> Focus.update sub_cursor_path_ (\old_cursor_path ->
                 let old_index = sorted_list_get_index
                                   old_cursor_path todo_cursor_paths
                     pre_index = if displacement > 0 && not (List.member
                                  record.sub_cursor_path todo_cursor_paths)
                                   then old_index - 1 else old_index
                     index = (pre_index + displacement) %
                               List.length todo_cursor_paths
                  in list_get_elem index todo_cursor_paths)
            |> Focus.set micro_mode_ (MicroModeRootTermTodo init_auto_complete)
   in cmd_enter_mode_root_term record' model

cmd_set_micro_mode : MicroModeRootTerm -> Command
cmd_set_micro_mode micro_mode model =
  Focus.set (focus_record_mode_root_term => micro_mode_) micro_mode model

cmd_reset_root_term : Command
cmd_reset_root_term model =
  let record = Focus.get focus_record_mode_root_term model
   in case record.editability of
        EditabilityRootTermReadOnly -> model
        EditabilityRootTermUpToTerm ->
          let record' = record
                |> Focus.set sub_cursor_path_ []
                |> Focus.set micro_mode_
                     (MicroModeRootTermTodo init_auto_complete)
           in model
                |> cmd_enter_mode_root_term record'
                |> cmd_set_sub_term TermTodo
                |> record.on_modify_callback
        EditabilityRootTermUpToGrammar ->
          let model' = Focus.set record.root_term_focus init_root_term model
              record' = record
                |> Focus.set sub_cursor_path_ []
                |> Focus.set micro_mode_
                     (MicroModeRootTermSetGrammar init_auto_complete)
           in cmd_enter_mode_root_term record' model'
                |> record.on_modify_callback

cmd_quit_if_has_no_todo : Command
cmd_quit_if_has_no_todo model =
  let record = Focus.get focus_record_mode_root_term model
      todo_cursor_paths = get_term_todo_cursor_paths <|
        Focus.get (record.root_term_focus => term_) model
   in if List.isEmpty todo_cursor_paths
        then record.on_quit_callback model else model

get_grammar_at_sub_term : Model -> (GrammarName, Grammar)
get_grammar_at_sub_term model =
  let record = Focus.get focus_record_mode_root_term model
      root_term = Focus.get record.root_term_focus model
   in get_grammar_at_sub_term' record.module_path model
        root_term.grammar root_term.term record.sub_cursor_path

get_grammar_at_sub_term' : ModulePath -> Model -> GrammarName ->
                                 Term -> IntCursorPath -> (GrammarName, Grammar)
get_grammar_at_sub_term' module_path model grammar_name term cursor_path =
  let err_msg = "from Updates.ModeRootTerm.cmd_get_grammar_at_sub_term'"
   in case cursor_path of
        [] -> let node_path = { module_path = module_path
                              , node_name = grammar_name
                              }
               in (grammar_name, Focus.get (focus_grammar node_path) model)
        cursor_index :: cursor_path' ->
          case term of
            TermInd grammar_choice sub_terms ->
              get_grammar_at_sub_term' module_path model
                (list_get_elem cursor_index <|
                   striped_list_get_odd_element grammar_choice)
                (list_get_elem cursor_index sub_terms)
                cursor_path'
            _                                -> Debug.crash err_msg

focus_auto_complete : Focus Model AutoComplete
focus_auto_complete =
  let err_msg = "from Updates.ModeRootTerm.focus_auto_complete"
      getter record = case record.micro_mode of
        MicroModeRootTermSetGrammar auto_complete -> auto_complete
        MicroModeRootTermTodo auto_complete       -> auto_complete
        MicroModeRootTermNavigate auto_complete   -> auto_complete
      updater update_func record = case record.micro_mode of
        MicroModeRootTermSetGrammar auto_complete ->
          Focus.set micro_mode_
            (MicroModeRootTermSetGrammar <| update_func auto_complete) record
        MicroModeRootTermTodo auto_complete ->
          Focus.set micro_mode_
            (MicroModeRootTermTodo <| update_func auto_complete) record
        MicroModeRootTermNavigate auto_complete ->
          Focus.set micro_mode_
            (MicroModeRootTermNavigate <| update_func auto_complete) record
   in (focus_record_mode_root_term => Focus.create getter updater)
