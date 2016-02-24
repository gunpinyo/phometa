module Models.Cursor where

-- for cursor that use integer to refer to
-- it is better to use `IntCursor` rather than pure `Maybe Int`
-- so reader will know more about field's intention
type alias IntCursor = Maybe Int

-- for cursor that use string to refer to
-- it is better to use `StrCursor` rather than pure `Maybe String`
-- so reader will know more about field's intention
type alias StrCursor = Maybe String

-- for element in side anything in tree-like structure
-- state that the cursor point to this or sub-element of this
type alias HasCursor = Bool

-- state that what is current active pane
type PaneCursor
  = PaneCursorPackage
  -- no view path to keymap pane, users don't need to edit it
  | PaneCursorGrid1
  | PaneCursorGrid2
  | PaneCursorGrid3
  | PaneCursorGrid4

init_pane_cursor : PaneCursor
init_pane_cursor = PaneCursorGrid1
