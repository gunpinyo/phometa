module Models.MiniBuffer where

type MiniBuffer
  = MiniBufferNothing
  | MiniBufferDebug String
  | MiniBufferError String
  -- TODO: write more
