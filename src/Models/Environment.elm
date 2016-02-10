-- tunnel that allow model of phometa to interact with outside world
module Models.Environment where

import Task exposing (Task)
import Time exposing (Time)

type alias Environment =
  { maybe_task : Maybe (Task () ())
  , time       : Time
  }

-- this is just for the first time
-- once the first action is triggered, environment will depend on signals
init_environment : Environment
init_environment =
  { maybe_task = Nothing
  , time       = 0.0
  }
