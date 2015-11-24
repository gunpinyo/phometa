module Tools.KeyboardExtra where

-- this is actually define in core library named `Keyboard`
--   but we can't use it directly since it makes `elm-test` clash
--   (perhaps weird bug)
type alias KeyCode = Int

-- TODO: we will use this module to define Keycode constant (e.g. ctrl, alt)
