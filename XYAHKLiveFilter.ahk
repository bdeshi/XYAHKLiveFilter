;XYAHKLiveFilter v3
#SingleInstance, Off
OnExit, ExitRoutine
SetControlDelay, -1
XYhWnd = %1%
Shortcut = %2%
Main:
	Gui, +HwndGUIhWnd  -Resize -Border -Caption +OwnDialogs +AlwaysOnTop
	Gui, Margin, 1, 1
	Gui, Font, s8, Segoe UI
	GUI, Add, Checkbox, gUpdateFilter hWndGUIPausehWnd 0x8000 0xc00, P
	Gui, Add, Edit, y1 gUpdateFilter hWndGUIEdithWnd R1, ""
	DllCall("SetParent","UInt", GUIhWnd, "UInt", XYhWnd)
	GuiControlGet, EditPos, Pos, %GUIEdithWnd%
	GuiControl, Move, %GUIEdithWnd%, % "w" EditPosW*8
	GuiControl, Move, %GUIPausehWnd%, % "h" EditPosH
	Gui, Show, X1 Y1 AutoSize
	SendInput, {Right}{Left}
	OnMessage(0x200, "FocusGUI")
	OnMessage(0x02, "Destroyer")
	Hotkey, IfWinActive, ahk_id %GUIhWnd%
		Hotkey, Tab, lblFocusXY
	If (Shortcut) {
		Hotkey, IfWinActive, ahk_id %XYhWnd%
			Hotkey, %Shortcut%, lblFocusGUI
	}
Return

UpdateFilter:
	GuiControlGet, PauseState, , %GUIPausehWnd%
	GuiControlGet, StrFilter, , %GUIEdithWnd%
	If (PauseState = 1) {
		Return
	}
	If (StrFilterLast != StrFilter) {
		StrFilterLast := StrFilter
		StrFilter = ::filter %StrFilter%;
		MsgToXY(StrFilter)
		StrFilter := ""
	}
Return

GuiClose:
GuiEscape:
	GoSub, ExitRoutine
Return

lblFocusXY:
	FocusXY()
Return
lblFocusGUI:
	FocusGUI()
Return

FocusGUI() {
	global
	IfWinActive, ahk_id %XYhWnd%
	{
		WinActivate, ahk_id %GUIEdithWnd%
	}
	Return
}
FocusXY() {
	global
	IfWinActive, ahk_id %GUIhWnd%
	{
		WinActivate, ahk_id %XYhWnd%
	}
	Return
}

Destroyer() {
	ExitApp
	Return
}

MsgToXY(arg_Msg) {
	global XYhWnd
	Size := StrLen(arg_Msg)
	If !(A_IsUnicode) {
		VarSetCapacity(Data, Size * 2, 0)
		StrPut(arg_Msg, &Data, Size, "UTF-16")
	} Else {
		Data := arg_Msg
	}
	VarSetCapacity(COPYDATA, A_PtrSize * 3, 0)
	NumPut(4194305, COPYDATA, 0, "Ptr")
	NumPut(Size * 2, COPYDATA, A_PtrSize, "UInt")
	NumPut(&Data, COPYDATA, A_PtrSize * 2, "Ptr")
	SendMessage, 0x4A, 0, &COPYDATA, , ahk_id %XYhWnd%
	Return
}

ExitRoutine:
	GUI, Destroy
	WinActivate, ahk_id %XYhWnd%
	EndMsg := "::filter;unset $p_XYAHKLiveFilter_A,$p_XYAHKLiveFilter_B;"
	MsgToXY(EndMsg)
	ExitApp
Return
