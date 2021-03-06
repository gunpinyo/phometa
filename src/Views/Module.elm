module Views.Module where

import String

import Html exposing (Html, div, hr, br, text)
import Html.Attributes exposing (class, style)
import Focus

import Tools.OrderedDict exposing (ordered_dict_to_list)
import Tools.StripedList exposing (stripe_two_list_together)
import Tools.CssExtra exposing (CssInlineStr, css_inline_str_embed,
                                css_inline_str_compile)
import Models.Cursor exposing (CursorInfo, cursor_info_go_to_sub_elem)
import Models.RepoModel exposing (PackagePath, ModulePath,
                                  Node(..), NodeType(..))
import Models.RepoUtils exposing (focus_module)
import Models.Model exposing (Command, Mode(..), MicroModeModule(..))
import Models.ViewState exposing (View)
import Updates.CommonCmd exposing (cmd_nothing)
import Updates.ModeModule exposing (cmd_enter_micro_mode_add_node
                                   ,cmd_swap_node
                                   ,focus_auto_complete)
import Views.Utils exposing (show_keyword_block, show_auto_complete_filter,
                             show_button, show_swap_button)
import Views.Comment exposing (show_comment)
import Views.Grammar exposing (show_grammar)
import Views.Rule exposing (show_rule)
import Views.Theorem exposing (show_theorem)

get_package_path_css : PackagePath -> CssInlineStr
get_package_path_css package_path = String.concat <|
  css_inline_str_embed "keyword-block" "/" ::
  List.concatMap (\package_name ->
    [ css_inline_str_embed "package-block" package_name
    , css_inline_str_embed "keyword-block" "/"]) package_path

get_module_path_css : ModulePath -> CssInlineStr
get_module_path_css module_path =
  get_package_path_css module_path.package_path ++
  css_inline_str_embed "module-block" module_path.module_name

show_module : CursorInfo -> ModulePath -> View
show_module cursor_info module_path model =
  let record = { top_cursor_info = cursor_info
               , sub_cursor_path = []
               , module_path = module_path
               , micro_mode = MicroModeModuleNavigate
               }
      module' = Focus.get (focus_module module_path) model
      header_html = div [] <| [show_keyword_block "module "] ++
                     (css_inline_str_compile <| get_module_path_css module_path)
      nodes_htmls = (ordered_dict_to_list module'.nodes)
        |> List.indexedMap (\index (node_name, node) ->
             let sub_cursor_info = List.foldl cursor_info_go_to_sub_elem
                                     cursor_info [0, index]
                 node_path = { module_path = module_path
                             , node_name = node_name }
              in case node of
                   NodeComment comment ->
                     show_comment sub_cursor_info node_path comment model
                   NodeGrammar grammar ->
                     show_grammar sub_cursor_info node_path grammar model
                   NodeRule rule ->
                     show_rule sub_cursor_info node_path rule model
                   NodeTheorem theorem has_locked ->
                     show_theorem sub_cursor_info node_path
                       theorem has_locked model)
      intersperse_panel_htmls = List.indexedMap (\index _ ->
        let sub_cursor_info = List.foldl cursor_info_go_to_sub_elem
                                     cursor_info [1, index]
            maybe_node_type = case model.mode of
              ModeModule record' ->
                if record'.module_path /= module_path then Nothing else
                  case record'.micro_mode of
                    MicroModeModuleNavigate -> Nothing
                    MicroModeModuleAddNode _ index' node_type ->
                      if index == index' then Just node_type else Nothing
              _                 -> Nothing
         in div [class "module-intersperse-panel"] <| [
             div [class "button-panel"] <|
               List.concatMap (\html -> [html, text " "]) <|
               List.map2 (\node_type placeholder ->
                 if maybe_node_type == Just node_type then
                   show_auto_complete_filter "button-block" sub_cursor_info
                     placeholder focus_auto_complete model
                 else
                   show_button placeholder <|
                     cmd_enter_micro_mode_add_node record index node_type)
               [NodeTypeComment, NodeTypeGrammar, NodeTypeRule, NodeTypeTheorem]
               ["Add Comment", "Add Grammar", "Add Rule", "Add Theorem"]]
             ++ (if index == 0 || index == List.length nodes_htmls then []
               else [ div [class "button-panel"] [text " "]
                    , show_swap_button <| cmd_swap_node record (index - 1)])
             ++ [show_keyword_block " "] -- for vertical gap

        ) (List.repeat (List.length nodes_htmls + 1) ())
   in div [] <| header_html ::
        (stripe_two_list_together intersperse_panel_htmls nodes_htmls)
