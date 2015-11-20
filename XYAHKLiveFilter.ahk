;XYAHKLiveFilter.ahk//v4.1
;Author:SammaySarkar//Credits:autocart, binocular222, SKAN (AHK forum)
;http://xyplorer.com/xyfc/viewtopic.php?t=12588
#SingleInstance, Off ;multiple instances can run for multiple XY instances
#NoEnv ;(recommended)
SetBatchLines, 10ms ;good balance of speed/CPU (so says AHK doc)
SetControlDelay, -1 ;fastest possible control operations

XYhWnd = %1% ;parent/target XY window
Shortcut = %2% ;hotkey to focus filterbox
ABPadding = %3% ;manual adjustent of GUI Y (for same Y of AB)
ABPadding := (ABPadding+0)="" ? 5 : ABPadding ;default ABPadding = 5
SyncPos = %4% ;keep GUI position synced with AB (else at the topleft of XY)
TTShow = %5%
AHKhWnd := A_ScriptHwnd + 0 ;pass as hwnd to SC copydata
Global ReceivedData ;holds WM_COPYDATA return (temporarily)

OnExit, ExitRoutine
OnMessage(0x4a, "MsgFromXY") ;WM_COPYDATA
OnMessage(0x200, "FocusGUI") ;WM_MOUSEMOVE
OnMessage(0x7e, "Destroyer") ;WM_DESTROY

;create GUI and hotkeys
Gui, +HwndGUIhWnd -Border -Caption +OwnDialogs +AlwaysOnTop
Gui, Margin, 1, 1
If (SyncPos = 1)
	Gosub, ABattribs ;obtain AB attribs
Else { ;else gui will be at topleft of XY clientarea
	GUIX = 1
	GUIY = 1
	FontName = Segoe UI
	FontSize = 8
}
Gui, Font, s%FontSize%, %FontName%
GUI, Add, Checkbox, gCallUpdateFilter hWndGUIPausehWnd 0xc00, P ;livemode toggle
Gui, Add, Edit, y1 gCallUpdateFilter hWndGUIEdithWnd R1, "" ;the filterbox
DllCall("SetParent", "UInt", GUIhWnd, "UInt", XYhWnd) ;set child of XY
GuiControlGet, EditPos, Pos, %GUIEdithWnd%
GuiControl, Move, %GUIEdithWnd%, % "w" EditPosW*8 ;a ~standard width
GuiControl, Move, %GUIPausehWnd%, % "h" EditPosH  ;chkbox H==edit H:center-align
Gui, Show, X%GUIX% Y%GUIY% AutoSize
SendInput, {Right}{Left} ;put cursor between default quotes
If (SyncPos = 1) { ;right align filterbox
	WinGetPos, , , GUIW, , ahk_id %GUIhWnd%
	GUIX := ABX + ABW - xborder - GUIW ;account for GUIWidth
	WinMove, ahk_id %GUIhWnd%, , %GUIX%, %GUIY%
	SetTimer, UpdatePos, 100 ;turn on the synchronizer
}
Hotkey, IfWinActive, ahk_id %GUIhWnd%
	Hotkey, Tab, lblFocusXY ;tab to give focus to XY
;Hotkey, IfWinActive, ahk_id %GUIhWnd%
	Hotkey, Enter, UpdateFilter ;ENTER to force filter update
If (Shortcut) {
	Hotkey, IfWinActive, ahk_id %XYhWnd%
		Hotkey, %Shortcut%, lblFocusGUI ;hotkey to refocus filterbox
}
Return
;=== END OF AUTO-EXECUTION SECTION =============================================

;obtain AddressBar attributes, called only if SyncPos=1
ABattribs:
	;ensure AB is visible
	MsgToXy("::copydata " AHKHwnd ",get('#660'),0;setlayout('showaddressbar=1');")
	;^get(#660) AB visibility (1/0)
	ABState := ReceivedData ;remember prev AB visibility (for reverting)
	ReceivedData =
	;infer AB position relative to clientarea (thanks, autocart :) )
	ControlGet, XYABhWnd, Hwnd, , Edit16, ahk_id %XYhWnd%
	;^Edit16 isn't a static idenifier either, fingers crossed ...
	ControlGetPos, ABX, ABY, ABW, ABH, , ahk_id %XYABhWnd%
	SysGet, xborder, 32
	SysGet, yborder, 33
	SysGet, CaptionH, 4
	SysGet, MenuH, 15
	GUIX := ABX + ABW - xborder   ;^ GUIWidth is accounted for after GUI, Show
	GUIY := ABY - yborder - CaptionH - MenuH - ABPadding
	FontName:= GetFont(XYABhWnd), FontSize:= A_LastError ;font of AB
Return

;update filterbox position to match AB. Called by timer
UpdatePos:
	If WinActive("ahk_id" XYhWnd) {
		ControlGet, ABvis, Visible, , , ahk_id %XYABhWnd% ;get AB visiblity
		If (ABvis = 0) ;so you hid the AB? Not allowed while I'm syncing, sorry.
			MsgToXY("::setlayout('showaddressbar=1')")
		PABP = %ABX% %ABY% %ABH% %ABW%
		PABH = %ABH%
		ControlGetPos, ABX, ABY, ABW, ABH, , ahk_id %XYABhWnd%
		CABP = %ABX% %ABY% %ABH% %ABW%
		CABH = %ABH%
		If (PABP != CABP) {
			GUIX := ABX + ABW - xborder - GUIW
			GUIY := ABY - yborder - CaptionH - MenuH - ABPadding
			GUIH := ABH + ABPadding + 1 ;1 is to account for margin
			If (PABH <> CABH) { ;change of height means font change
				FontName:= GetFont(XYABhWnd), FontSize:= A_LastError ;new font
				Gui, Font, s%FontSize%, %FontName% ;set new font
				GuiControl, Font, %GUiPausehWnd% ;apply to filterbox
				GuiControl, Font, %GUiEdithWnd% ;and P chkbox
			}
			WinMove, ahk_id %GUIhWnd%, , %GUIX%, %GUIY%, , %GUIH% ;sync pos with AB
			GuiControl, move, %GUIPausehWnd%, h%GUIH% ;set equal height to filter...
			GuiControl, move, %GUIEdithWnd%, h%GUIH% ;...and chkbox to center align
		}
	}
Return

;triggered by filterbox content change. Passes box scontent to SC filter
CallUpdateFilter:
	GuiControlGet, Paused, , %GUIPausehWnd% ;get 'P'ause state
	If (Paused = 1)
		Return ;stop msging (ie live-flitering) while paused
	GoSub, UpdateFilter
Return

;get filterbox content and pass to XY
UpdateFilter:
	GuiControlGet, StrFilter, , %GUIEdithWnd%
	;same filter twice resets VF, guard against this
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

;focus the GUI .Here triggered on WM_Mouseover (else ctrl under GUI gets focus)
FocusGUI() {
	global
	IfWinActive, ahk_id %XYhWnd%
		WinActivate, ahk_id %GUIEdithWnd%
	;show a little tooltip
	IfWinActive, ahk_id %GUIhWnd%
	{
		If (TTShow != 1) {
			TTShow = 1
			ToolTip
			SetTimer, TTOn, 10
		}
		Return
		TTOn:
			ToolTip, % "CHECK 'P': Pause live mode`nTEXTBOX: enter filter`nFOCUS HOTKEY:"
						. (Shortcut = "" ? "None": Shortcut)
			SetTimer, TTOn, Off
			SetTimer, TTOff, 1000
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

;=== MsgToXY() =================================================================
;send arg_Msg to %XYhWnd% via WM_COPYDATA
;functin lifted from binocular222's XYplorer Messenger[AHK], (thanks!)
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
;=== End of MsgToXY() ==========================================================
;=== MsgFromXY() ===============================================================
;receive WM_COPYDATA from %XYhWnd% to %ReceivedData%
;also based on binocular222's code
MsgFromXY(wParam, lParam) {
	StringAddress := NumGet(lParam + 2*A_PtrSize)
	cbData := NumGet(lParam+A_PtrSize)/2
	CopyOfData := StrGet(StringAddress)
	StringLeft, ReceivedData, CopyOfData, cbData
	Return
}
;=== End of MsgFromXY() ========================================================

;=== GetFont() =================================================================
;returns font (and it's size) used in a ctrl with hwnd of  arg_hWnd
;fontname = function return, and fontsize = A_LastError
;By SKAN www.autohotkey.com/forum/viewtopic.php?p=465438#465438
GetFont(arg_hwnd) {
	SendMessage 0x31,0,0,,ahk_id %arg_hwnd%
	IfEqual,ErrorLevel,FAIL,Return
	hFont := Errorlevel,VarSetCapacity(LF,szLF := 60*(A_IsUnicode ? 2:1))
	DllCall("GetObject",UInt,hFont,Int,szLF,UInt,&LF)
	hDC := DllCall("GetDC",UInt,hwnd),DPI := DllCall("GetDeviceCaps",UInt,hDC,Int,90)
	DllCall("ReleaseDC",Int,0,UInt,hDC),S := Round((-NumGet(LF,0,"Int")*72)/DPI)
	Return DllCall("MulDiv",Int,&LF+28,Int,1,Int,1,Str),DllCall("SetLastError",UInt,S)
}
;=== End of GetFont() ==========================================================

;cleanup filter and perms on exit. Triggered on "normal" script/GUI exit
ExitRoutine:
	GUI, Hide ;exiting "looks" slightly faster
	If (SyncPos = 1) ;if so then revert AB visibility to pre-exec
		MsgToXY("::setlayout('showaddressbar=" ABState "');")
	MsgToXY("::filter;unset $p_XYAHKLiveFilter_A,$p_XYAHKLiveFilter_B;")
	ExitApp
Return
