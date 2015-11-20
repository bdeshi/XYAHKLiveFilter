;XYAHKLiveFilter v1
#SingleInstance, Off
SetControlDelay, -1
XYhWnd = %1%
Shortcut = %2%

Main:
	Gui, +HwndGUIhWnd +OwnDialogs -Resize -Border -Caption +AlwaysOnTop
	Gui, Margin, 0, 0
	Gui, Font, s8, Segoe UI
	Gui, Add, Edit, R1 vXYAHKFilter gUpdateFilter hWndGUIEdithWnd, ""
	DllCall("SetParent","UInt", GUIhWnd, "UInt", XYhWnd)
	GuiControlGet, EditPos, Pos, %GUIEdithWnd%
	GuiControl, Move, %GUIEdithWnd%, % "w" EditPosW*8
	Gui, Show, X1 Y1 AutoSize
	SendInput, {Left}
	OnMessage(0x200, "FocusGUI")
	OnMessage(0x02, "Destroyer")
	Hotkey, IfWinActive, ahk_id %GUIhWnd%
	Hotkey, Tab, LabelFocusXY
	If Shortcut
	{
		Hotkey, IfWinActive, ahk_id %XYhWnd%
		Hotkey, %Shortcut%, LabelFocusGUI
	}
Return

UpdateFilter:
	GuiControlGet,  XYAHKLiveFilter, , %GUIEdithWnd%
	XYAHKLiveFilter = ::filter %XYAHKLiveFilter%
	MsgToXY(XYAHKLiveFilter, XYhWnd)
	FocusGUI()
Return

GuiEscape:
	GoSub, ExitSub
Return
GuiClose:
	GoSub, ExitSub
Return

OnExit, ExitSub
Return

LabelFocusGUI:
	FocusGUI()
Return
LabelFocusXY:
	WinActivate, ahk_id %XYhWnd%
Return

FocusGUI()
{
	Gui, +LastFound
	WinActivate
	Return
}

Destroyer()
{
	ExitApp
}

MsgToXY(arg_Msg, arg_XYhWnd)
{
	Size := StrLen(arg_Msg)
	If !(A_IsUnicode)
	{
		VarSetCapacity(Data, Size * 2, 0)
		StrPut(arg_Msg, &Data, Size, "UTF-16")
	}
	Else
	{
		Data := arg_Msg
	}
	VarSetCapacity(COPYDATA, A_PtrSize * 3, 0)
	NumPut(4194305, COPYDATA, 0, "Ptr")
	NumPut(Size * 2, COPYDATA, A_PtrSize, "UInt")
	NumPut(&Data, COPYDATA, A_PtrSize * 2, "Ptr")
	SendMessage, 0x4A, 0, &COPYDATA, , ahk_id %arg_XYhWnd%
	Return
}

ExitSub:
	EndMsg := "::filter;unset $p_XYAHKLiveFilter_A,$p_XYAHKLiveFilter_B;status 'XYAHKLF:Esc';"
	MsgToXY(EndMsg, XYhWnd)
	WinActivate, ahk_id %XYhWnd%
	ExitApp
Return
