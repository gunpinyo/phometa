module Models.Grid where

import Models.Pointer exposing (IntPointer)
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
  | GridModule ModulePath IntPointer
  | GridNode NodePath

init_grids : Grids
init_grids = Grids1x1 GridHome
