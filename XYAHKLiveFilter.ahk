; XYAHKLiveFilter v4
#SingleInstance, Off
#NoEnv
SetBatchLines, 10ms
SetControlDelay, -1

XYhWnd = %1%
Shortcut = %2%
ABPadding = %3%
ABPadding := (ABPadding+0)="" ? 5 : ABPadding
SyncPos = %4%
TTShow = %5%
AHKhWnd := A_ScriptHwnd + 0
Global ReceivedData

OnExit, ExitRoutine
OnMessage(0x4a, "MsgFromXY")
OnMessage(0x200, "FocusGUI")
OnMessage(0x7e, "Destroyer")

Gui, +HwndGUIhWnd -Border -Caption +OwnDialogs +AlwaysOnTop
Gui, Margin, 1, 1
If (SyncPos = 1)
	Gosub, ABattribs
Else {
	GUIX = 1
	GUIY = 1
	FontName = Segoe UI
	FontSize = 8
}
Gui, Font, s%FontSize%, %FontName%
GUI, Add, Checkbox, gUpdateFilter hWndGUIPausehWnd 0xc00, P
Gui, Add, Edit, y1 gUpdateFilter hWndGUIEdithWnd R1, ""
DllCall("SetParent", "UInt", GUIhWnd, "UInt", XYhWnd)
GuiControlGet, EditPos, Pos, %GUIEdithWnd%
GuiControl, Move, %GUIEdithWnd%, % "w" EditPosW*8
GuiControl, Move, %GUIPausehWnd%, % "h" EditPosH
Gui, Show, X%GUIX% Y%GUIY% AutoSize
SendInput, {Right}{Left}

If (SyncPos = 1) {
	WinGetPos, , , GUIW, , ahk_id %GUIhWnd%
	GUIX := ABX + ABW - xborder - GUIW
	WinMove, ahk_id %GUIhWnd%, , %GUIX%, %GUIY%
	SetTimer, UpdatePos, 100
}

Hotkey, IfWinActive, ahk_id %GUIhWnd%
	Hotkey, Tab, lblFocusXY
If (Shortcut) {
	Hotkey, IfWinActive, ahk_id %XYhWnd%
		Hotkey, %Shortcut%, lblFocusGUI
}

Return
;=== END OF AUTO-EXECUTION SECTION =============================================

ABattribs:
	MsgToXy("::copydata " AHKHwnd ",get('#660'),0;setlayout('showaddressbar=1');")
	ABState := ReceivedData
	ReceivedData =
	ControlGet, XYABhWnd, Hwnd, , Edit16, ahk_id %XYhWnd%
	ControlGetPos, ABX, ABY, ABW, ABH, , ahk_id %XYABhWnd%
	SysGet, xborder, 32
	SysGet, yborder, 33
	SysGet, CaptionH, 4
	SysGet, MenuH, 15
	GUIX := ABX + ABW - xborder
	GUIY := ABY - yborder - CaptionH - MenuH - ABPadding
	FontName:= GetFont(XYABhWnd)
	FontSize:= A_LastError
Return

UpdatePos:
	If WinActive("ahk_id" XYhWnd) {
		ControlGet, ABvis, Visible, , , ahk_id %XYABhWnd%
		If (ABvis = 0)
			MsgToXY("::setlayout('showaddressbar=1')")
		PABP = %ABX% %ABY% %ABH% %ABW%
		PABH = %ABH%
		ControlGetPos, ABX, ABY, ABW, ABH, , ahk_id %XYABhWnd%
		CABP = %ABX% %ABY% %ABH% %ABW%
		CABH = %ABH%
		If (PABP != CABP) {
			GUIX := ABX + ABW - xborder - GUIW
			GUIY := ABY - yborder - CaptionH - MenuH - ABPadding
			GUIH := ABH + ABPadding + 1
			If (PABH <> CABH) {
				FontName:= GetFont(XYABhWnd),
				FontSize:= A_LastError
				Gui, Font, s%FontSize%, %FontName%
				GuiControl, Font, %GUiPausehWnd%
				GuiControl, Font, %GUiEdithWnd%
			}
			WinMove, ahk_id %GUIhWnd%, , %GUIX%, %GUIY%, , %GUIH%
			GuiControl, move, %GUiPausehWnd%, h%GUIH%
			GuiControl, move, %GUiEdithWnd%, h%GUIH%
		}
	}
Return

UpdateFilter:
	GuiControlGet, Paused, , %GUIPausehWnd%
	If (Paused = 1)
		Return
	GuiControlGet, StrFilter, , %GUIEdithWnd%
	If (StrFilterLast != StrFilter) {
		StrFilterLast := StrFilter
		StrFilter = ::filter %StrFilter%
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
		WinActivate, ahk_id %GUIEdithWnd%
	IfWinActive, ahk_id %GUIhWnd%
	{
		If (TTShow != 1) {
			TTShow = 1
			ToolTip
			SetTimer, TTOn, 10
		}
		Return

		TTOn:
			ToolTip, P: Pause live mode
			SetTimer, TTOn, Off
			SetTimer, TTOff, 800
		Return

		TTOff:
			ToolTip
			SetTimer, TTOff, Off
		Return
	}
	Return
}

FocusXY() {
	global
	IfWinActive, ahk_id %GUIhWnd%
		WinActivate, ahk_id %XYhWnd%
	Return
}

Destroyer() {
	ExitApp
	Return
}

;function lifted from binocular222's XYplorer Messenger[AHK], (thanks!)
MsgToXY(arg_Msg) {
	global XYhWnd
	Size := StrLen(arg_Msg)
	If !(A_IsUnicode) {
		VarSetCapacity(Data, Size * 2, 0)
		StrPut(arg_Msg, &Data, Size, "UTF-16")
	} Else
		Data := arg_Msg
	VarSetCapacity(COPYDATA, A_PtrSize * 3, 0)
	NumPut(4194305, COPYDATA, 0, "Ptr")
	NumPut(Size * 2, COPYDATA, A_PtrSize, "UInt")
	NumPut(&Data, COPYDATA, A_PtrSize * 2, "Ptr")
	SendMessage, 0x4A, 0, &COPYDATA, , ahk_id %XYhWnd%
	Return
}

;also based on binocular222's code
MsgFromXY(wParam, lParam) {
	StringAddress := NumGet(lParam + 2*A_PtrSize)
	cbData := NumGet(lParam+A_PtrSize)/2
	CopyOfData := StrGet(StringAddress)
	StringLeft, ReceivedData, CopyOfData, cbData
	Return
}

;By SKAN www.autohotkey.com/forum/viewtopic.php?p=465438#465438
GetFont(arg_hwnd) {
	SendMessage 0x31, 0, 0, , ahk_id %arg_hwnd%
	IfEqual, ErrorLevel, FAIL, Return
	hFont := Errorlevel, VarSetCapacity(LF, szLF := 60*(A_IsUnicode ? 2:1))
	DllCall("GetObject", UInt, hFont, Int, szLF, UInt, &LF)
	hDC := DllCall("GetDC", UInt, hwnd), DPI := DllCall("GetDeviceCaps", UInt, hDC, Int, 90)
	DllCall("ReleaseDC", Int, 0, UInt, hDC), S := Round((-NumGet(LF, 0, "Int")*72)/DPI)
	Return DllCall("MulDiv", Int, &LF+28, Int, 1, Int, 1, Str), DllCall("SetLastError", UInt, S)
}

ExitRoutine:
	GUI, Hide
	If (SyncPos = 1)
		MsgToXY("::setlayout('showaddressbar=" ABState "');")
	MsgToXY("::filter;unset $p_XYAHKLiveFilter_A,$p_XYAHKLiveFilter_B;")
	ExitApp
Return
