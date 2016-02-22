module Models.Focus where

import Focus exposing (create)

-- name_ = create .name (\u r -> {r|name=u r.name})

-- Model
config_ = create .config (\u r -> {r|config=u r.config})
root_package_ = create .root_package (\u r -> {r|root_package=u r.root_package})
root_keymap_ = create .root_keymap (\u r -> {r|root_keymap=u r.root_keymap})
grid_ = create .grid (\u r -> {r|grid=u r.grid})
major_mode_ = create .major_mode (\u r -> {r|major_mode=u r.major_mode})
message_list_ = create .message_list (\u r -> {r|message_list=u r.message_list})
environment_ = create .environment (\u r -> {r|environment=u r.environment})

-- Environment
maybe_task_ = create .maybe_task (\u r -> {r|maybe_task=u r.maybe_task})
time_ = create .time (\u r -> {r|time=u r.time})

side_grid_panes_ratio_ = create .side_grid_panes_ratio (\u r -> {r|side_grid_panes_ratio=u r.side_grid_panes_ratio})
show_package_pane_ = create .show_package_pane (\u r -> {r|show_package_pane=u r.show_package_pane})
show_keymap_pane_ = create .show_keymap_pane (\u r -> {r|show_keymap_pane=u r.show_keymap_pane})
globally_show_terms_description_ = create .globally_show_terms_description (\u r -> {r|globally_show_terms_description=u r.globally_show_terms_description})
