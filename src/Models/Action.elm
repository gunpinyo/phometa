module Models.Action where

import Signal exposing (Mailbox, Address)

import Tools.KeyboardExtra exposing (Keystroke)
import Models.Model exposing (Command)

type Action
  = ActionNothing
  | ActionCommand Command
  | ActionKeystroke Keystroke

-- event of mouse and result of `Task` will enter phomata thought mailbox
mailbox : Mailbox Action
mailbox = Signal.mailbox ActionNothing

-- address of mailbox will be used so often, better to declare here
address : Address Action
address = mailbox.address
