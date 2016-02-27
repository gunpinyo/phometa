module Models.Grid where

import Models.Cursor exposing (IntCursor)
import Models.RepoModel exposing (ModulePath, NodePath)

type Grids
  = Grids1x1 Grid
  | Grids1x2 Grid Grid
  | Grids1x3 Grid Grid Grid
  | Grids2x1 Grid Grid
  | Grids3x1 Grid Grid Grid
  | Grids2x2 Grid Grid Grid Grid

type Grid
  = GridHome
  | GridModule ModulePath IntCursor
  | GridNode NodePath

-- TODO: reset to real initial
init_grids : Grids
init_grids =
  Grids2x1
    (GridNode {
      module_path = {
        package_path = ["Standard Library"],
        module_name = "First Order Logic"
      },
      node_name = "theorem-1"
    })
    (GridNode {
      module_path = {
        package_path = ["Standard Library"],
        module_name = "First Order Logic"
      },
      node_name = "theorem-2"
    })

get_number_of_grids : Grids -> Int
get_number_of_grids grids =
  case grids of
    Grids1x1 _       -> 1
    Grids1x2 _ _     -> 2
    Grids1x3 _ _ _   -> 3
    Grids2x1 _ _     -> 2
    Grids3x1 _ _ _   -> 3
    Grids2x2 _ _ _ _ -> 4
