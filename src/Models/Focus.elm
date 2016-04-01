module Models.Focus where

import Focus exposing (create)

-- name_ = create .name (\u r -> {r|name=u r.name})

-- Model
config_ = create .config (\u r -> {r|config=u r.config})
root_package_ = create .root_package (\u r -> {r|root_package=u r.root_package})
root_keymap_ = create .root_keymap (\u r -> {r|root_keymap=u r.root_keymap})
grids_ = create .grids (\u r -> {r|grids=u r.grids})
pane_cursor_ = create .pane_cursor (\u r -> {r|pane_cursor=u r.pane_cursor})
mode_ = create .mode (\u r -> {r|mode=u r.mode})
message_list_ = create .message_list (\u r -> {r|message_list=u r.message_list})
environment_ = create .environment (\u r -> {r|environment=u r.environment})

-- Environment
maybe_task_ = create .maybe_task (\u r -> {r|maybe_task=u r.maybe_task})
time_ = create .time (\u r -> {r|time=u r.time})

side_grids_panes_ratio_ = create .side_grids_panes_ratio (\u r -> {r|side_grids_panes_ratio=u r.side_grids_panes_ratio})
show_package_pane_ = create .show_package_pane (\u r -> {r|show_package_pane=u r.show_package_pane})
show_keymap_pane_ = create .show_keymap_pane (\u r -> {r|show_keymap_pane=u r.show_keymap_pane})
globally_show_terms_description_ = create .globally_show_terms_description (\u r -> {r|globally_show_terms_description=u r.globally_show_terms_description})

grammar_ = create .grammar (\u r -> {r|grammar=u r.grammar})
dict_ = create .dict (\u r -> {r|dict=u r.dict})
nodes_ = create .nodes (\u r -> {r|nodes=u r.nodes})
goal_ = create .goal (\u r -> {r|goal=u r.goal})
context_ = create .context (\u r -> {r|context=u r.context})
root_term_ = create .root_term (\u r -> {r|root_term=u r.root_term})
micro_mode_ = create .micro_mode (\u r -> {r|micro_mode=u r.micro_mode})
reversed_ref_path_ = create .reversed_ref_path (\u r -> {r|reversed_ref_path=u r.reversed_ref_path})
root_term_focus_ = create .root_term_focus (\u r -> {r|root_term_focus=u r.root_term_focus})
term_ = create .term (\u r -> {r|term=u r.term})
top_cursor_info_ = create .top_cursorr_info (\u r -> {r|top_cursorr_info=u r.top_cursorr_info})
sub_cursor_path_ = create .sub_cursor_path (\u r -> {r|sub_cursor_path=u r.sub_cursor_path})
node_name_ = create .node_name (\u r -> {r|node_name=u r.node_name})
proof_ = create .proof (\u r -> {r|proof=u r.proof})
