module Updates.PreProcess where

import Models.EtcAlias exposing (ProcessCommand)
import ModelUtils.KeyBinding exposing (initial_key_binding)

pre_process_pcmd : ProcessCommand
pre_process_pcmd model =
  let model' = { model |
                 key_binding = initial_key_binding
               }
   in ([], model')
