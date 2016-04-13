module Models.Grid where

import Focus exposing (Focus)

import Models.Cursor exposing (IntCursorPath, PaneCursor(..))
import Models.RepoModel exposing (ModulePath, NodePath)

type Grids
  = Grids1x1 Grid
  | Grids1x2 Grid Grid
  | Grids1x3 Grid Grid Grid
  | Grids2x1 Grid Grid
  | Grids3x1 Grid Grid Grid
  | Grids2x2 Grid Grid Grid Grid

type Grid
  = GridHome IntCursorPath
  | GridModule ModulePath IntCursorPath
  | GridNode NodePath IntCursorPath

-- TODO: reset to real initial
init_grids : Grids
init_grids =
  Grids2x1
    (GridNode {
      module_path = {
        package_path = ["Standard Library"],
        module_name = "Propositional Logic"
      },
      node_name = "theorem-1"
    } [])
    (GridNode {
      module_path = {
        package_path = ["Standard Library"],
        module_name = "Propositional Logic"
      },
      node_name = "theorem-2"
    } [])
    -- (GridNode {
    --   module_path = {
    --     package_path = ["Standard Library"],
    --     module_name = "Simply type lambda calculus"
    --   },
    --   node_name = "theorem-a"
    -- } [])

get_grid : PaneCursor -> Grids -> Maybe Grid
get_grid pane_cursor grids =
  case grids of
    Grids1x1 g1          -> case pane_cursor of
      PaneCursorGrid1 -> Just g1
      _               -> Nothing
    Grids1x2 g1 g2       -> case pane_cursor of
      PaneCursorGrid1 -> Just g1
      PaneCursorGrid2 -> Just g2
      _               -> Nothing
    Grids1x3 g1 g2 g3    -> case pane_cursor of
      PaneCursorGrid1 -> Just g1
      PaneCursorGrid2 -> Just g2
      PaneCursorGrid3 -> Just g3
      _               -> Nothing
    Grids2x1 g1 g2       -> case pane_cursor of
      PaneCursorGrid1 -> Just g1
      PaneCursorGrid2 -> Just g2
      _               -> Nothing
    Grids3x1 g1 g2 g3    -> case pane_cursor of
      PaneCursorGrid1 -> Just g1
      PaneCursorGrid2 -> Just g2
      PaneCursorGrid3 -> Just g3
      _               -> Nothing
    Grids2x2 g1 g2 g3 g4 -> case pane_cursor of
      PaneCursorGrid1 -> Just g1
      PaneCursorGrid2 -> Just g2
      PaneCursorGrid3 -> Just g3
      PaneCursorGrid4 -> Just g4
      _               -> Nothing

update_grid : PaneCursor -> (Grid -> Grid) -> Grids -> Grids
update_grid pane_cursor update_func grids =
  case grids of
    Grids1x1 g1          -> case pane_cursor of
      PaneCursorGrid1 -> Grids1x1 (update_func g1)
      _               -> grids
    Grids1x2 g1 g2       -> case pane_cursor of
      PaneCursorGrid1 -> Grids1x2 (update_func g1) g2
      PaneCursorGrid2 -> Grids1x2 g1 (update_func g2)
      _               -> grids
    Grids1x3 g1 g2 g3    -> case pane_cursor of
      PaneCursorGrid1 -> Grids1x3 (update_func g1) g2 g3
      PaneCursorGrid2 -> Grids1x3 g1 (update_func g2) g3
      PaneCursorGrid3 -> Grids1x3 g1 g2 (update_func g3)
      _               -> grids
    Grids2x1 g1 g2       -> case pane_cursor of
      PaneCursorGrid1 -> Grids2x1 (update_func g1) g2
      PaneCursorGrid2 -> Grids2x1 g1 (update_func g2)
      _               -> grids
    Grids3x1 g1 g2 g3    -> case pane_cursor of
      PaneCursorGrid1 -> Grids3x1 (update_func g1) g2 g3
      PaneCursorGrid2 -> Grids3x1 g1 (update_func g2) g3
      PaneCursorGrid3 -> Grids3x1 g1 g2 (update_func g3)
      _               -> grids
    Grids2x2 g1 g2 g3 g4 -> case pane_cursor of
      PaneCursorGrid1 -> Grids2x2 (update_func g1) g2 g3 g4
      PaneCursorGrid2 -> Grids2x2 g1 (update_func g2) g3 g4
      PaneCursorGrid3 -> Grids2x2 g1 g2 (update_func g3) g4
      PaneCursorGrid4 -> Grids2x2 g1 g2 g3 (update_func g4)
      _               -> grids

focus_grid : PaneCursor -> Focus Grids Grid
focus_grid pane_cursor =
  Focus.create
    (\grids -> case get_grid pane_cursor grids of
                 Just grid -> grid
                 Nothing   -> Debug.crash "from Models.Grid.focus_grid")
    (update_grid pane_cursor)

get_number_of_grids : Grids -> Int
get_number_of_grids grids =
  case grids of
    Grids1x1 _       -> 1
    Grids1x2 _ _     -> 2
    Grids1x3 _ _ _   -> 3
    Grids2x1 _ _     -> 2
    Grids3x1 _ _ _   -> 3
    Grids2x2 _ _ _ _ -> 4
