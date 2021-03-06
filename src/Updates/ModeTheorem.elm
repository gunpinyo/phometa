module Updates.ModeTheorem where

import String

import Focus exposing (Focus, (=>))

import Tools.Utils exposing (list_get_elem, list_update_elem, list_rotate)
import Tools.CssExtra exposing (css_inline_str_embed)
import Models.Focus exposing (mode_, micro_mode_, reversed_ref_path_,
                              node_name_, goal_, proof_, is_folded_,
                              sub_cursor_path_)
import Models.Cursor exposing (IntCursorPath, CursorInfo,
                               cursor_info_is_here,
                               get_cursor_info_from_cursor_tree,
                               cursor_info_go_to_sub_elem,
                               cursor_tree_go_to_sub_elem)
import Models.RepoModel exposing (Term(..), RuleName, TheoremName, Theorem,
                                  Proof(..), SubstitutionList)
import Models.RepoUtils exposing (has_root_term_completed,
                                  get_usable_rule_names, focus_rule, apply_rule,
                                  has_root_term_completed,
                                  focus_theorem_rule_argument,
                                  init_theorem, get_usable_theorem_names,
                                  focus_theorem_rule_argument,
                                  focus_theorem, focus_theorem_has_locked,
                                  has_theorem_completed,
                                  multiple_root_substitute,
                                  pattern_matchable, pattern_match,
                                  get_theorem_variables,
                                  root_term_undefined_grammar,
                                  get_term_todo_cursor_paths)
import Models.Message exposing (Message(..))
import Models.Model exposing (Model, Command, KeyBinding(..), Keymap, Command,
                              AutoComplete, Mode(..),
                              EditabilityRootTerm(..), MicroModeRootTerm(..),
                              RecordModeTheorem, MicroModeTheorem(..))
import Models.ModelUtils exposing (focus_record_mode_theorem,
                                   init_auto_complete)
import Updates.CommonCmd exposing (cmd_nothing)
import Updates.Message exposing (cmd_send_message)
import Updates.KeymapUtils exposing (empty_keymap,
                                     merge_keymaps, merge_keymaps_list,
                                     build_keymap, build_keymap_cond,
                                     keymap_auto_complete)
import Updates.Cursor exposing (cmd_click_block)
import Updates.ModeRootTerm exposing (embed_css_root_term,
                                      cmd_enter_mode_root_term)

keymap_mode_theorem : RecordModeTheorem -> Model -> Keymap
keymap_mode_theorem record model =
  merge_keymaps
    (build_keymap_cond (not <| has_mode_theorem_locked model)
      [(model.config.spacial_key_prefix ++ "r",
        "reset whole theorem", KbCmd cmd_reset_top_theorem)
      ,(model.config.spacial_key_prefix ++ "t",
        "reset current proof", KbCmd cmd_reset_current_proof)
      ,(model.config.spacial_key_prefix ++ "l",
        "lock as lemma", KbCmd cmd_lock_as_lemma)])
    (case record.micro_mode of
      MicroModeTheoremNavigate -> empty_keymap
      MicroModeTheoremSelectRule auto_complete ->
        let cur_sub_theorem = Focus.get (focus_current_sub_theorem model) model
            choices = get_usable_rule_names (Just cur_sub_theorem.goal.grammar)
                        record.node_path.module_path model False
              |> List.map (\rule_name ->
                   (css_inline_str_embed "rule-block" rule_name,
                    cmd_set_rule rule_name))
         in keymap_auto_complete choices True Nothing focus_auto_complete model
      MicroModeTheoremSelectLemma auto_complete ->
        let cur_sub_theorem = Focus.get (focus_current_sub_theorem model) model
            choices = get_usable_theorem_names (Just cur_sub_theorem.goal)
                        record.node_path.module_path model False
              |> List.map (\theorem_name ->
                   (css_inline_str_embed "theorem-block" theorem_name,
                    cmd_set_lemma theorem_name))
         in keymap_auto_complete choices True Nothing focus_auto_complete model)

cmd_enter_mode_theorem : RecordModeTheorem -> Command
cmd_enter_mode_theorem record =
  let cursor_info = get_cursor_info_from_cursor_tree record
   in (Focus.set mode_ (ModeTheorem record)) >> (cmd_click_block cursor_info)

cmd_theorem_auto_focus_next_todo : Command
cmd_theorem_auto_focus_next_todo model =
  let record = Focus.get focus_record_mode_theorem model
   in case auto_focus_next_todo
             record.top_cursor_info
             (Focus.set sub_cursor_path_ [] record)
             record.sub_cursor_path
             (focus_theorem record.node_path)
             model of
        Nothing -> cmd_click_block record.top_cursor_info model
        Just cmd -> cmd model

auto_focus_next_todo : CursorInfo -> RecordModeTheorem -> IntCursorPath ->
                         Focus Model Theorem -> Model -> Maybe Command
auto_focus_next_todo cursor_info record remaining_path theorem_focus model =
  let (marked_index, sub_remaining_path) =
        case remaining_path of
          [] -> (0, [])
          marked_index :: sub_remaining_path ->
            (marked_index, sub_remaining_path)
      theorem = Focus.get theorem_focus model
      module_path = record.node_path.module_path
   in case theorem.proof of
        ProofTodo ->
          if not <| has_root_term_completed theorem.goal then
            let set_grammar_goal_record =
                  { module_path = module_path
                  , root_term_focus = (theorem_focus => goal_)
                  , top_cursor_info = (cursor_info_go_to_sub_elem 0 cursor_info)
                  , sub_cursor_path = []
                  , micro_mode = MicroModeRootTermSetGrammar init_auto_complete
                  , editability = EditabilityRootTermUpToGrammar
                  , is_reducible = True
                  , can_create_fresh_vars = True
                  , get_existing_variables = get_theorem_variables
                                               record.node_path
                  , on_modify_callback = cmd_nothing
                  , on_quit_callback = cmd_enter_mode_theorem record
                                         >> cmd_theorem_auto_focus_next_todo
                  }
                goal_record =
                  if theorem.goal.grammar == root_term_undefined_grammar then
                    set_grammar_goal_record
                  else
                    set_grammar_goal_record
                       |> Focus.set micro_mode_
                            (MicroModeRootTermTodo init_auto_complete)
                       |> Focus.set sub_cursor_path_
                            (theorem.goal.term
                               |> get_term_todo_cursor_paths
                               |> list_get_elem 0)
             in Just <| cmd_enter_mode_root_term goal_record
          else
            let rule_exists = not <| List.isEmpty <|
                  get_usable_rule_names (Just theorem.goal.grammar)
                    module_path model False
                lemma_exists = not <| List.isEmpty <| get_usable_theorem_names
                    (Just theorem.goal) module_path model False
             in if rule_exists then
                  Just <| cmd_select_rule 1 record
                else if lemma_exists then
                  Just <| cmd_select_lemma 2 record
                else
                  Nothing
        ProofTodoWithRule _ arguments ->
          arguments
            |> List.indexedMap (\index argument ->
                 (index, not <| has_root_term_completed argument))
            |> List.filter snd
            |> List.head
            |> Maybe.map (\ (arg_index, _) ->
                 cmd_enter_mode_root_term  <|
                   { module_path = module_path
                   , root_term_focus =
                       (theorem_focus => focus_theorem_rule_argument arg_index)
                   , top_cursor_info =
                       (cursor_info_go_to_sub_elem (arg_index + 1) cursor_info)
                   , sub_cursor_path = arguments
                       |> list_get_elem arg_index
                       |> .term
                       |> get_term_todo_cursor_paths
                       |> list_get_elem 0
                   , is_reducible = False
                   , micro_mode = MicroModeRootTermTodo init_auto_complete
                   , editability = EditabilityRootTermUpToTerm
                   , can_create_fresh_vars = False
                   , get_existing_variables = get_theorem_variables
                                                record.node_path
                   , on_modify_callback = cmd_nothing
                   , on_quit_callback = cmd_enter_mode_theorem record
                                          >> cmd_execute_current_rule
                   })
        ProofByRule _ arguments _ sub_theorems ->
          let index_offset = 1 + List.length arguments
              fold_func (index, sub_theorem) acc = case acc of
                Nothing -> auto_focus_next_todo
                 (cursor_info_go_to_sub_elem (index + index_offset) cursor_info)
                 (cursor_tree_go_to_sub_elem (index + index_offset) record)
                 sub_remaining_path
                 (theorem_focus => focus_sub_theorem [index + index_offset])
                 model
                Just cmd -> Just cmd
           in sub_theorems
                |> List.indexedMap (,)
                |> list_rotate (marked_index - index_offset)
                |> List.foldl fold_func Nothing
        ProofByLemma _ _ -> Nothing


cmd_resume_to_navigate_micro_mode : Command
cmd_resume_to_navigate_micro_mode model =
  model
    |> cmd_enter_mode_theorem (Focus.get focus_record_mode_theorem model)
    |> cmd_set_micro_mode (MicroModeTheoremNavigate)
    |> cmd_theorem_auto_focus_next_todo

cmd_select_rule : Int -> RecordModeTheorem -> Command
cmd_select_rule index record model =
  model
    |> cmd_click_block (get_cursor_info_from_cursor_tree
                          <| cursor_tree_go_to_sub_elem index record)
    |> Focus.set mode_ (ModeTheorem record)
    |> cmd_set_micro_mode (MicroModeTheoremSelectRule init_auto_complete)

cmd_select_lemma : Int -> RecordModeTheorem -> Command
cmd_select_lemma index record model =
  model
    |> cmd_click_block (get_cursor_info_from_cursor_tree
                          <| cursor_tree_go_to_sub_elem index record)
    |> Focus.set mode_ (ModeTheorem record)
    |> cmd_set_micro_mode (MicroModeTheoremSelectLemma init_auto_complete)

has_mode_theorem_locked : Model -> Bool
has_mode_theorem_locked model =
  let record = Focus.get focus_record_mode_theorem model
      has_locked_focus = focus_theorem_has_locked record.node_path
   in Focus.get has_locked_focus model

cmd_lock_as_lemma : Command
cmd_lock_as_lemma model =
  let record = Focus.get focus_record_mode_theorem model
      top_theorem = Focus.get (focus_theorem record.node_path) model
      has_locked_focus = focus_theorem_has_locked record.node_path
      theorem_inline = css_inline_str_embed "theorem-block"
                         record.node_path.node_name
      suc_msg = theorem_inline ++" has been converted to a lemma"
      err_msg = theorem_inline ++
                  " hasn't been finished, hence, cannot be converted to a lemma"
   in if has_theorem_completed top_theorem then
        model |> Focus.set has_locked_focus True
              |> cmd_send_message (MessageSuccess suc_msg)
      else
        cmd_send_message (MessageException err_msg) model

cmd_set_rule : RuleName -> Command
cmd_set_rule rule_name model =
  let err_msg = "from Updates.ModeTheorem.cmd_set_rule"
      record = Focus.get focus_record_mode_theorem model
      module_path = record.node_path.module_path
      rule = Focus.get (focus_rule { module_path = module_path
                                   , node_name = rule_name
                                   }) model
      new_proof = ProofTodoWithRule rule_name <|
                    List.map (\parameter -> { grammar = parameter.grammar
                                            , term = TermTodo
                                            }) rule.parameters
      top_theorem_focus = focus_theorem record.node_path
      top_sub_focus = focus_sub_theorem record.sub_cursor_path
   in model
       |> Focus.set (top_theorem_focus => top_sub_focus => proof_) new_proof
       |> if List.isEmpty rule.parameters then
            cmd_execute_current_rule
          else
            cmd_resume_to_navigate_micro_mode

cmd_execute_current_rule : Command
cmd_execute_current_rule model =
  let err_msg = "from Updates.ModeTheorem.cmd_execute_current_rule"
      record = Focus.get focus_record_mode_theorem model
      module_path = record.node_path.module_path
      top_theorem_focus = focus_theorem record.node_path
      top_sub_focus = focus_sub_theorem record.sub_cursor_path
      top_theorem = Focus.get top_theorem_focus model
      sub_theorem = Focus.get top_sub_focus top_theorem
      on_success rule_name arguments premises pm_info =
        let sub_sub_theorems = List.map
              (\premise -> Focus.set goal_ premise init_theorem) premises
            new_proof = ProofByRule rule_name arguments pm_info sub_sub_theorems
            new_sub_theorem = Focus.set proof_ new_proof sub_theorem
            new_top_theorem = theorem_tree_substitute pm_info.substitution_list
              (Focus.set top_sub_focus new_sub_theorem top_theorem)
         in Focus.set top_theorem_focus new_top_theorem
      on_failure rule_name arguments =
        let parameters_inline = if List.isEmpty arguments then " " else
              " with parameter" ++ (if List.length arguments == 1
                                      then " " else "s ") ++
              (String.concat <| List.map (\argument ->
                embed_css_root_term module_path model argument ++ " ")arguments)
            exception_msg = "cannot apply "
              ++ css_inline_str_embed "rule-block" rule_name ++parameters_inline
              ++ "on " ++ embed_css_root_term module_path model sub_theorem.goal
            proof_focus = (top_theorem_focus => top_sub_focus => proof_)
         in (Focus.set proof_focus ProofTodo) >>
            (cmd_send_message <| MessageException exception_msg)
      main_command =
        case sub_theorem.proof of
          ProofTodoWithRule rule_name arguments ->
            if not <| List.all has_root_term_completed arguments then
              cmd_nothing
            else
              case apply_rule rule_name sub_theorem.goal
                     arguments record.node_path.module_path model of
                Nothing -> on_failure rule_name arguments
                Just (premises, pm_info) ->
                  on_success rule_name arguments premises pm_info
          _ -> cmd_nothing
   in model
        |> main_command
        |> cmd_resume_to_navigate_micro_mode

cmd_set_lemma : TheoremName -> Command
cmd_set_lemma theorem_name model =
  let err_msg = "from Updates.ModeTheorem.cmd_set_lemma"
      record = Focus.get focus_record_mode_theorem model
      pattern_theorem_path = Focus.set node_name_ theorem_name record.node_path
      pattern_theorem = Focus.get (focus_theorem pattern_theorem_path) model
      top_theorem_focus = focus_theorem record.node_path
      target_theorem = Focus.get top_theorem_focus model
      sub_theorem_update_func current_sub_theorem =
        case pattern_match record.node_path.module_path model
               pattern_theorem.goal current_sub_theorem.goal of
          Nothing -> current_sub_theorem
          Just pattern_match_info ->
            Focus.set proof_
              (ProofByLemma theorem_name pattern_match_info)
              current_sub_theorem
      top_theorem_update_func top_theorem =
        let top_sub_focus = focus_sub_theorem record.sub_cursor_path
            top_theorem' = Focus.update top_sub_focus
                             sub_theorem_update_func top_theorem
            sub_theorem = Focus.get top_sub_focus top_theorem
            sub_theorem' = Focus.get top_sub_focus top_theorem'
            subst_list = if sub_theorem == sub_theorem' then [] else
                           case sub_theorem'.proof of
                             ProofByLemma _ pattern_match_info ->
                               pattern_match_info.substitution_list
                             _ -> Debug.crash err_msg
         in theorem_tree_substitute subst_list top_theorem'
   in model
       |> Focus.update top_theorem_focus top_theorem_update_func
       |> cmd_resume_to_navigate_micro_mode

cmd_set_micro_mode : MicroModeTheorem -> Command
cmd_set_micro_mode micro_mode model =
  Focus.set (focus_record_mode_theorem => micro_mode_) micro_mode model

is_thorem_focusable : Theorem -> Bool
is_thorem_focusable theorem =
  case theorem.proof of
    ProofByRule _ _ _ sub_theorems ->
      List.any (\sub_theorem -> case sub_theorem.proof of
        ProofByRule _ _ _ sub_sub_theorems ->
          not <| List.isEmpty sub_sub_theorems
        _                                  -> False) sub_theorems
    _                              -> False

is_thorem_focused : Theorem -> Bool
is_thorem_focused theorem =
  case theorem.proof of
    ProofByRule _ _ _ sub_theorems ->
      List.all (Focus.get is_folded_) sub_theorems
    _                              -> False

reset_all_theorem_all_is_folded : Theorem -> Theorem
reset_all_theorem_all_is_folded theorem =
  let proof' = case theorem.proof of
        ProofByRule rule_name arguments pm_info sub_theorems ->
          ProofByRule rule_name arguments pm_info
            (List.map reset_all_theorem_all_is_folded sub_theorems)
        _                                                    -> theorem.proof
  in theorem
       |> Focus.set is_folded_ False
       |> Focus.set proof_ proof'

cmd_toggle_focus_current_theorem : Command
cmd_toggle_focus_current_theorem old_model =
  let record = Focus.get focus_record_mode_theorem old_model
      top_theorem_focus = focus_theorem record.node_path
      cur_theorem_focus = top_theorem_focus =>
                            focus_sub_theorem record.sub_cursor_path
      will_sub_thorems_be_folded = not <| is_thorem_focused <|
        Focus.get cur_theorem_focus old_model
      model = Focus.update top_theorem_focus
                reset_all_theorem_all_is_folded old_model
      cur_theorem = Focus.get cur_theorem_focus model
   in if not will_sub_thorems_be_folded then model else
      case Focus.get (cur_theorem_focus => proof_) model of
        ProofByRule rule_name arguments pm_info sub_theorems ->
          let sub_theorems' = List.map (Focus.set is_folded_ True) sub_theorems
              proof' = ProofByRule rule_name arguments pm_info sub_theorems'
           in Focus.set (cur_theorem_focus => proof_) proof' model
        _                                                    -> model

cmd_reset_current_proof : Command
cmd_reset_current_proof model =
  let record = Focus.get focus_record_mode_theorem model
      top_theorem_focus = focus_theorem record.node_path
      top_sub_focus = focus_sub_theorem record.sub_cursor_path
      proof_focus = top_theorem_focus => top_sub_focus => proof_
   in model
        |> Focus.set proof_focus ProofTodo
        |> cmd_resume_to_navigate_micro_mode

cmd_reset_top_theorem : Command
cmd_reset_top_theorem model =
  let record = Focus.get focus_record_mode_theorem model
   in model
        |> Focus.set (focus_theorem record.node_path) init_theorem
        |> Focus.set (focus_record_mode_theorem => sub_cursor_path_) []
        |> cmd_resume_to_navigate_micro_mode

theorem_tree_substitute : SubstitutionList -> Theorem -> Theorem
theorem_tree_substitute subst_list theorem = theorem
  |> Focus.set goal_ (multiple_root_substitute subst_list theorem.goal)
  |> Focus.set proof_ (case theorem.proof of
       ProofTodo -> ProofTodo
       ProofTodoWithRule rule_name arguments ->
         ProofTodoWithRule rule_name <|
           List.map (multiple_root_substitute subst_list) arguments
       ProofByRule rule_name arguments pattern_match_info sub_theorems ->
         let arguments' =
               List.map (multiple_root_substitute subst_list) arguments
             sub_theorems' =
               List.map (theorem_tree_substitute subst_list) sub_theorems
          in ProofByRule rule_name arguments' pattern_match_info sub_theorems'
       ProofByLemma theorem_name pattern_match_info ->
         ProofByLemma theorem_name pattern_match_info)

focus_auto_complete : Focus Model AutoComplete
focus_auto_complete =
  let err_msg = "from Updates.ModeTheorem.focus_auto_complete"
      getter record =
        case record.micro_mode of
          MicroModeTheoremNavigate -> Debug.crash err_msg
          MicroModeTheoremSelectRule auto_complete -> auto_complete
          MicroModeTheoremSelectLemma auto_complete -> auto_complete
      updater update_func record =
        case record.micro_mode of
          MicroModeTheoremNavigate -> record
          MicroModeTheoremSelectRule auto_complete ->
            Focus.set micro_mode_
              (MicroModeTheoremSelectRule <| update_func auto_complete)
              record
          MicroModeTheoremSelectLemma auto_complete ->
            Focus.set micro_mode_
              (MicroModeTheoremSelectLemma <| update_func auto_complete)
              record
   in (focus_record_mode_theorem => Focus.create getter updater)

focus_current_sub_theorem : Model -> Focus Model Theorem
focus_current_sub_theorem model =
  let record = Focus.get focus_record_mode_theorem model
   in (focus_theorem record.node_path) =>
        (focus_sub_theorem record.sub_cursor_path)

-- please note that cursor_path is not only for sub_theorem
-- but also for goal (index = 0) and arguments (index = 1 + i)
-- also i_th sub_theorem will be at 1 + (List.length arguments) + i
focus_sub_theorem : IntCursorPath -> Focus Theorem Theorem
focus_sub_theorem top_cursor_path =
  let err_msg = "from Updates.ModeTheorem.focus_sub_theorem"
      getter theorem = getter_aux top_cursor_path theorem
      getter_aux cursor_path theorem =
        case cursor_path of
          []                    -> theorem
          index :: cursor_path' ->
            case theorem.proof of
              ProofByRule rule_name arguments pattern_match_info sub_theorems ->
                let index' = index - (1 + List.length arguments)
                 in getter_aux cursor_path' (list_get_elem index' sub_theorems)
              _ -> Debug.crash err_msg
      updater update_func theorem =
        updater_aux top_cursor_path update_func theorem
      updater_aux cursor_path update_func theorem =
        case cursor_path of
          []                    -> update_func theorem
          index :: cursor_path' -> Focus.update proof_ (\proof ->
            case proof of
              ProofByRule rule_name arguments pattern_match_info sub_theorems ->
                let index' = index - (1 + List.length arguments)
                 in ProofByRule rule_name arguments pattern_match_info <|
                      list_update_elem index' (\sub_theorem ->
                          updater_aux cursor_path' update_func sub_theorem)
                        sub_theorems
              _ -> Debug.crash err_msg) theorem
   in Focus.create getter updater
