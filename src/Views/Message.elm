module Views.Message where

import String

import Html exposing (Html, div, text, table, tr, th, td)
import Html.Attributes exposing (class, classList, style, align)

import Tools.Flex exposing (flex_div)
import Tools.CssExtra exposing (css_inline_str_embed, css_inline_str_compile)
import Models.Message exposing (Message(..))
import Models.RepoModel exposing (NodeType(..))
import Models.ViewState exposing (View)
import Updates.CommonCmd exposing ( cmd_confirmed_delete_nodes
                                  , cmd_confirmed_delete_module
                                  , cmd_confirmed_delete_package)
import Updates.Message exposing (cmd_remove_message)
import Views.Utils exposing (show_text_block,
                             show_ok_button, show_close_button)
import Views.Module exposing (get_module_path_css, get_package_path_css)

show_messages_pane : View
show_messages_pane model =
  let msg_tr_func index message =
        let (css_kw, keyword, msg_css_inline) = case message of
             MessageSuccess css_inline    -> ("success-msg", "SUCCESS"
                                             , css_inline)
             MessageInfo css_inline       -> ("info-msg", "INFO"
                                             , css_inline)
             MessageWarning css_inline    -> ("warning-msg", "WARNING"
                                             , css_inline)
             MessageException css_inline  -> ("err-msg", "EXCEPTION"
                                             , css_inline)
             MessageFatalError css_inline -> ("err-msg", "FATAL ERROR"
                                             , css_inline)
             MessageDebug css_inline      -> ("err-msg", "DEBUG"
                                             , css_inline)
             MessageDeleteNodeConfirmation _ list ->
               let css_inline_nodes = List.map (\ (node_type, node_name) ->
                     let css_node_type = case node_type of
                                           NodeTypeComment -> "comment-block"
                                           NodeTypeGrammar -> "grammar-block"
                                           NodeTypeRule    -> "rule-block"
                                           NodeTypeTheorem -> "theorem-block"
                      in css_inline_str_embed css_node_type node_name) list
                   css_inline = ["Are you sure you want to delete "] ++
                                  (List.intersperse ", " css_inline_nodes)
                                  ++ [" ?"]
                                |> String.concat
                in ("confirmnation-msg", "CONFIRMATION", css_inline)
             MessageDeleteModuleConfirmation module_path ->
               ("confirmnation-msg", "CONFIRMATION",
                "Are you sure you want to delete module "
                  ++ get_module_path_css module_path ++ " ?")
             MessageDeletePackageConfirmation package_path ->
               ("confirmnation-msg", "CONFIRMATION",
                "Are you sure you want to delete package "
                  ++ get_package_path_css package_path ++ " ?")
            tick_html = case message of
              MessageDeleteNodeConfirmation module_path list ->
                let nodes = List.map snd list
                    command = cmd_confirmed_delete_nodes nodes module_path
                                >> cmd_remove_message index
                 in [show_ok_button command]
              MessageDeleteModuleConfirmation module_path ->
                [show_ok_button <| cmd_confirmed_delete_module module_path
                                     >> cmd_remove_message index]
              MessageDeletePackageConfirmation package_path ->
                [show_ok_button <| cmd_confirmed_delete_package package_path
                                     >> cmd_remove_message index]
              _ -> []
         in tr [] <| [ td [] [show_text_block css_kw keyword]
                     , td [] (css_inline_str_compile msg_css_inline)
                     , td [] ([show_close_button <| cmd_remove_message index]
                                ++ tick_html)]
      table' = table [style [("width", "100%")]]
        <| List.indexedMap msg_tr_func model.message_list
   in if List.isEmpty model.message_list then flex_div [] [] [] else
       flex_div [] [class "pane"] [table']
