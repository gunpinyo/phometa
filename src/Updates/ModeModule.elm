module Updates.ModeModule where

import Focus exposing (Focus, (=>))

import Tools.Utils exposing (list_swap)
import Tools.CssExtra exposing (css_inline_str_embed)
import Tools.OrderedDict exposing (ordered_dict_insert)
import Models.Focus exposing (mode_, micro_mode_, sub_cursor_path_,
                              nodes_, order_)
import Models.Cursor exposing (get_cursor_info_from_cursor_tree)
import Models.RepoModel exposing (ModulePath, NodeName, Node(..), NodeType(..))
import Models.RepoUtils exposing (focus_package, init_package,
                                  focus_module, init_module, get_comment_names,
                                  get_usable_grammar_names, init_grammar,
                                  get_usable_rule_names, init_rule,
                                  get_usable_theorem_names, init_theorem)
import Models.Message exposing (Message(..))
import Models.Model exposing (Model, Command, Keymap, KeyBinding(..),
                              AutoComplete, Mode(..),
                              RecordModeModule, MicroModeModule(..))
import Models.ModelUtils exposing (init_auto_complete, focus_record_mode_module)
import Updates.Cursor exposing (cmd_click_block)
import Updates.Message exposing (cmd_send_message)
import Updates.KeymapUtils exposing (empty_keymap, build_keymap, merge_keymaps,
                                     keymap_auto_complete)

keymap_mode_module : RecordModeModule -> Model -> Keymap
keymap_mode_module record model =
  case record.micro_mode of
    MicroModeModuleNavigate -> empty_keymap
    MicroModeModuleAddNode auto_complete index node_type ->
      let hit_return_msg = case node_type of NodeTypeComment -> "add comment"
                                             NodeTypeGrammar -> "add grammar"
                                             NodeTypeRule    -> "add rule"
                                             NodeTypeTheorem -> "add theorem"
          command = cmd_add_node record index node_type
       in merge_keymaps
            (build_keymap [("Escape", "quit " ++ hit_return_msg
                           , KbCmd <| cmd_enter_micro_mode_navigate record)])
            (keymap_auto_complete [] True
               (Just (command, hit_return_msg))
               focus_auto_complete model)

cmd_enter_mode_module : RecordModeModule -> Command
cmd_enter_mode_module record =
  let cursor_info = get_cursor_info_from_cursor_tree record
   in (Focus.set mode_ (ModeModule record)) >> (cmd_click_block cursor_info)

cmd_enter_micro_mode_navigate : RecordModeModule -> Command
cmd_enter_micro_mode_navigate record =
  let record' = record
        |> Focus.set micro_mode_ MicroModeModuleNavigate
        |> Focus.set sub_cursor_path_ []
   in cmd_enter_mode_module record'

cmd_enter_micro_mode_add_node : RecordModeModule -> Int -> NodeType -> Command
cmd_enter_micro_mode_add_node record index node_type =
  let record' = record
        |> Focus.set micro_mode_
             (MicroModeModuleAddNode init_auto_complete index node_type)
        |> Focus.set sub_cursor_path_ [1, index]
   in cmd_enter_mode_module record'

cmd_add_node : RecordModeModule -> Int -> NodeType -> NodeName -> Command
cmd_add_node record index node_type node_name model =
  let module_path = record.module_path
      maybe_existing_node_css =
        if List.member node_name
             (get_comment_names module_path model) then
          Just "comment-block"
        else if List.member node_name
             (get_usable_grammar_names module_path model True) then
          Just "grammar-block"
        else if List.member node_name
             (get_usable_rule_names Nothing module_path model True) then
          Just "rule-block"
        else if List.member node_name
             (get_usable_theorem_names Nothing module_path model True) then
          Just "theorem-block"
        else
          Nothing
      new_node = case node_type of
                   NodeTypeComment -> NodeComment ""
                   NodeTypeGrammar -> NodeGrammar init_grammar
                   NodeTypeRule    -> NodeRule init_rule
                   NodeTypeTheorem -> NodeTheorem init_theorem False
   in case maybe_existing_node_css of
        Nothing -> model
          |> Focus.update (focus_module module_path => nodes_)
               (ordered_dict_insert index node_name new_node)
          |> cmd_enter_micro_mode_navigate record
        Just css_class -> model
          |> cmd_send_message (MessageException <|
               (css_inline_str_embed css_class node_name)
                ++ " already exists here, hence, cannot create a new one")
          |> cmd_enter_micro_mode_navigate record

cmd_swap_node : RecordModeModule -> Int -> Command
cmd_swap_node record index =
  Focus.update (focus_module record.module_path => nodes_ => order_)
      (list_swap index)
    >> cmd_enter_micro_mode_navigate record

focus_auto_complete : Focus Model AutoComplete
focus_auto_complete =
  let err_msg = "from Updates.ModeModule.focus_auto_complete"
      getter record = case record.micro_mode of
        MicroModeModuleNavigate                          -> Debug.crash err_msg
        MicroModeModuleAddNode auto_complete _ _         -> auto_complete
      updater update_func record = case record.micro_mode of
        MicroModeModuleNavigate                              -> record
        MicroModeModuleAddNode auto_complete index node_type ->
          Focus.set micro_mode_ (MicroModeModuleAddNode
            (update_func auto_complete) index node_type) record
   in (focus_record_mode_module => Focus.create getter updater)
