module Models.Popup where

type Popup
  = PopupSuccess String
  | PopupInfo String
  | PopupWarning String
  | PopupUserError String -- error from user than can happend
  | PopupProgError String -- fatal error, if happened contract phometa developer
  | PopupDebug String

type alias PopupList = List Popup

init_popup_list : PopupList
init_popup_list = []
