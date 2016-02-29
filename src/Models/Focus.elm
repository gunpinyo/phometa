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
