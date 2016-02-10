module Models.Focus where

import Focus exposing (create)

-- name_ = create .name (\u r -> {r|name=u r.name})

-- Model
root_package_ = create .root_package (\u r -> {r|root_package=u r.root_package})
root_keymap_ = create .root_keymap (\u r -> {r|root_keymap=u r.root_keymap})
major_mode_ = create .major_mode (\u r -> {r|major_mode=u r.major_mode})
message_list_ = create .message_list (\u r -> {r|message_list=u r.message_list})
environment_ = create .environment (\u r -> {r|environment=u r.environment})

-- Environment
maybe_task_ = create .maybe_task (\u r -> {r|maybe_task=u r.maybe_task})
time_ = create .time (\u r -> {r|time=u r.time})
