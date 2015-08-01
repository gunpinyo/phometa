module ModelUtil.MiniBuffer where

import Model.MiniBuffer exposing (MiniBuffer(..))

initial_mini_buffer : MiniBuffer
--initial_mini_buffer = MiniBufferNothing
-- TODO: remove debug and use line above
initial_mini_buffer = MiniBufferDebug "Hello world"
