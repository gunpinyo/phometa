module Models.Pointer where

-- for pointer that use integer to refer to
-- it is better to use `IntPointer` rather than pure `Maybe Int`
-- so reader will know more about field's intention
type alias IntPointer = Maybe Int

-- for pointer that use string to refer to
-- it is better to use `StrPointer` rather than pure `Maybe String`
-- so reader will know more about field's intention
type alias StrPointer = Maybe String

-- state that what is current active pane
type PanePointer
  = PanePointerPackage
  -- no view path to keymap pane, users don't need to edit it
  | PanePointerGrid1
  | PanePointerGrid2
  | PanePointerGrid3
  | PanePointerGrid4

init_pane_pointer : PanePointer
init_pane_pointer = PanePointerGrid1
