module Models.Grid where

import Models.PkgMod exposing (ModulePath)
import Models.Node exposing (NodeName)

type Grid
  = Grid1x1 GridElem
  | Grid1x2 GridElem GridElem
  | Grid1x3 GridElem GridElem GridElem
  | Grid2x1 GridElem GridElem
  | Grid3x1 GridElem GridElem GridElem
  | Grid2x2 GridElem GridElem GridElem GridElem

type GridElem
  = GridElemHome
  | GridElemModule ModulePath
  | GridElemNode ModulePath NodeName

init_grid : Grid
init_grid = Grid1x1 GridElemHome
