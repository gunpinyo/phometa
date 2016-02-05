module Models.Model where

import Models.Setting exposing (Setting)
import Models.Package exposing (Package)
import Models.KeyBinding exposing (Keymap)
import Models.Popup exposing (PopupList)

type alias Model
  = { setting : Setting
    , root_package : Package
    , keymap : Keymap
    , popup_list : PopupList
    }
