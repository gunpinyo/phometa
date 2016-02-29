module Models.Cursor where

-- for cursor that use integer to refer to
-- it is better to use `IntCursor` rather than pure `Int`
-- so reader will know more about field's intention
type alias IntCursor = Int
type alias IntCursorPath = List IntCursor

-- for cursor that use string to refer to
-- it is better to use `StrCursor` rather than pure `String`
-- so reader will know more about field's intention
type alias StrCursor = String

-- state that what is current active pane
type PaneCursor
  = PaneCursorPackage
  -- no view path to keymap pane, users don't need to edit it
  | PaneCursorGrid1
  | PaneCursorGrid2
  | PaneCursorGrid3
  | PaneCursorGrid4

-- for element inside anything in tree-like structure
type alias CursorInfo =
  { maybe_cursor_path : Maybe IntCursorPath
  , reversed_ref_path : IntCursorPath -- use reverse for efficiency
  , pane_cursor : PaneCursor
  }

init_pane_cursor : PaneCursor
init_pane_cursor = PaneCursorGrid1

init_cursor_info : Bool -> IntCursorPath -> PaneCursor -> CursorInfo
init_cursor_info has_cursor cursor_path pane_cursor =
  { maybe_cursor_path = if has_cursor then Just cursor_path else Nothing
  , reversed_ref_path = []
  , pane_cursor = pane_cursor
  }

cursor_info_go_to_sub_elem : CursorInfo -> IntCursor -> CursorInfo
cursor_info_go_to_sub_elem cursor_info index =
  { cursor_info |
    maybe_cursor_path = Maybe.andThen cursor_info.maybe_cursor_path
                          (\ int_cursor_path ->
                             if List.head int_cursor_path == Just index
                                then List.tail int_cursor_path else Nothing)
  , reversed_ref_path = index :: cursor_info.reversed_ref_path
  }

cursor_info_is_here : CursorInfo -> Bool
cursor_info_is_here cursor_info =
  cursor_info.maybe_cursor_path == Just []

cursor_info_get_ref_path : CursorInfo -> IntCursorPath
cursor_info_get_ref_path cursor_info =
  List.reverse cursor_info.reversed_ref_path
