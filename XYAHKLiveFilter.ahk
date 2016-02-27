;XYAHKLiveFilter.ahk/v4.5.0b/author:SammaySarkar
;http://xyplorer.com/xyfc/viewtopic.php?t=12588
;https://github.com/smsrkr/XYAHKLiveFilter

#SingleInstance, Off				;multiple instances can run for multiple XY instances
#NoTrayIcon							;hide tray icon
#NoEnv								;(recommended)
SetBatchLines, 10ms					;good balance of speed/CPU (so says AHK doc)
SetControlDelay, -1					;fastest possible control operations

Global AHKhWnd := A_ScriptHwnd + 0	;own hwnd in base10, can pass to SC copydata
Global ReceivedData					;holds WM_COPYDATA return (temporarily)
Global GUIhWnd						;holds gui hwnd
Global GUIEdithWnd, GUIPausehWnd	;holds gui elements hwnd
Global XYhWnd						;parent/target XY window hwnd

;process XY hwnd from cmdline
XYhWnd		= %1%
XYhWnd		:= Format("0x{:x}", XYhWnd)	;convert to hex, like GUIhWnd

;retrieve other options from cmdline
Shortcut	= %2%					;hotkey to focus filterbox
ABPadding	= %3%					;manual adjustent of GUI Y (for same Y of AB)
ABPadding	:= (ABPadding+0 == "") ? 5 : ABPadding
SyncPos		= %4%					;sync GUI position with AB (else at the topleft of XY)
OwnCTB		= %5%					;ID of associated custom toolbar button in XY (>= 0)
;Quote		= %6%					;Pattern quoting; S or D: single-quotes or double

OnExit, ExitRoutine					;need to cleanup before exit
OnMessage(0x4a, "MsgFromXY")		;WM_COPYDATA
OnMessage(0x02, "Destroyer")		;WM_DESTROY
;OnMessage(0x200, "FocusGUI")		;WM_MOUSEMOVE | disabled, non-standard

;setup GUI
Gui, +HwndGUIhWnd -Border -Caption +OwnDialogs +AlwaysOnTop
	Gui, Margin, 2, 1
	GoSub, Sysdims			;get some system element dims for correct positioning
	If (SyncPos == 1)		;right-align with AB
		GoSub, ABdims		;get AB position
	Else					;else right-align with window
		GoSub, Windims		;get window position
	Gui, Font, s%FontSize%, %FontName%
	GUI, Add, Checkbox, gCallUpdateFilter hWndGUIPausehWnd 0xc00, P	;pause checkbox
	Gui, Add, Edit, y1 gCallUpdateFilter hWndGUIEdithWnd R1, %A_Space%	;filterbox, " " for sizing
	;set as child of XY
	DllCall("SetParent", "Ptr", GUIhWnd, "Ptr", XYhWnd, "Ptr")
	GuiControlGet, EditPos, Pos, %GUIEdithWnd%
	GuiControl, Move, %GUIEdithWnd%, % "w" EditPosW*12				;set a sane width
	GuiControl, Move, %GUIPausehWnd%, % "h" EditPosH				;chkbox H==edit H
	GuiControl,, %GUIEdithWnd%, % ""								;remove default " " content
	GuiControl, Focus, %GUIEdithWnd%								;focus filterbox
	Gui, Show, X%GUIX% Y%GUIY% AutoSize

;setup position
WinGetPos,,, GUIW,, ahk_id %GUIhWnd%			;get current width
If (SyncPos == 1) {								;right align filterbox with AB
	GUIX := AncX + AncW - xborder - GUIW		;get real abwidth - GUIWidth
	SetTimer, UpdatePosAB, 100					;turn on the position synchronizer
}
Else {
	GUIX := AncW - xborder*2 - GUIW				;get real winwidth - GUIWidth
	SetTimer, UpdatePosWin, 100					;turn on the position synchronizer
}
WinMove, ahk_id %GUIhWnd%,, %GUIX%, %GUIY%		;set new position

;setup hotkeys
If (Shortcut) {								;put this first to override any other
	Hotkey, IfWinActive, ahk_id %XYhWnd%	;trigger only when parent XY active
		Hotkey, %Shortcut%, lblFocusGUI		;hotkey to refocus filterbox
}
Hotkey, IfWinActive, ahk_id %GUIhWnd%
	Hotkey, Tab, lblFocusXY					;tab to give focus to XY
	Hotkey, Enter, UpdateFilter				;ENTER to force filter update
	Hotkey, !p, lblTogglePause				;alt+p to toggle pause status
	;and Escape key closes GUI via GuiEscape label
Return
;=== END OF AUTO-EXECUTION SECTION =============================================

;obtain necessary AddressBar attributes
ABdims:
	;ensure AB is visible 
	MsgToXy("::copydata " AHKhWnd ",get('#660'),0;setlayout('showaddressbar=1');")
		;^get(#660) AB visibility (returns 1||0)
		ABState		 := ReceivedData	;remember prev AB visibility to revert back
		ReceivedData := ""				;reset receiveddata
	;infer AB position relative to clientarea (thanks, autocart :) )
	ControlGet, XYABhWnd, Hwnd,, Edit16, ahk_id %XYhWnd%
	ControlGetPos, AncX, AncY, AncW, AncH,, ahk_id %XYABhWnd%
	GUIX	 := AncX + AncW - xborder	;GUIWidth is accounted for after GUI,Show
	GUIY	 := AncY - yborder - CaptionH - MenuH - ABPadding
	FontName := GetFont(XYABhWnd)		;get fontname of AB
	FontSize := A_LastError 			;get fontsize of AB
Return
;obtain necessary XY Window attributes
Windims:
	WinGetPos,,, AncW,, ahk_id %XYhWnd%
	GUIX	 := AncW - xborder*2		;GUIWidth is accounted for after GUI,Show
	GUIY	 := 1						;no need for dynamic Y pos
	FontName := GetFont(XYhWnd)			;get fontname of win
	FontSize := A_LastError 			;get fontsize of win
Return
;obtain some system dimension attributes
Sysdims:
	SysGet, CaptionH, 4
	SysGet, MenuH,   15
	SysGet, xborder, 32
	SysGet, yborder, 33
Return

;update filterbox position to match AB. Called by timer
UpdatePosAB:
	If WinActive("ahk_id" XYhWnd) {			;update position only while XY is active
		ControlGet, ABvis, Visible,,, ahk_id %XYABhWnd%	;get AB visiblity
		If (ABvis == 0)									;if AB is hidden
			MsgToXY("::setlayout('showaddressbar=1')")	;unhide AB while running
		PAncA = %AncX% %AncY% %AncH% %AncW%	;previous AB dims
		PAncB = %AncH%						;previous AB H
		ControlGetPos, AncX, AncY, AncW, AncH,, ahk_id %XYABhWnd%
		CAncA = %AncX% %AncY% %AncH% %AncW%	;current AB dims
		CAncB = %AncH%						;current AB H
		If (PAncA != CAncA) {				;AB pos change = sync new pos
			GUIX := AncX + AncW - xborder - GUIW
			GUIY := AncY - yborder - CaptionH - MenuH - ABPadding
			GUIH := AncH + ABPadding
			If (PAncB <> CAncB) {						;AB H change = font change
				FontName := GetFont(XYABhWnd)			;get new fontname
				FontSize := A_LastError					;get new fontsize
				Gui, Font, s%FontSize%, %FontName%		;set new font
				GuiControl, Font, %GUIPausehWnd%		;apply font to filterbox 
				GuiControl, Font, %GUIEdithWnd%			;and to pause chkbox
			}
			WinMove, ahk_id %GUIhWnd%,, %GUIX%, %GUIY%,, %GUIH%	;set new position
			GuiControl, move, %GUIPausehWnd%, h%GUIH%			;pause H = filter H
			GuiControl, move, %GUIEdithWnd%, h%GUIH%			;center align pause chkbox
		}
	}
Return
;update filterbox position to match Window. Called by timer
UpdatePosWin:
	If WinActive("ahk_id" XYhWnd) {			;update position only while XY is active
		PAncA = %AncW%						;previous win W
		WinGetPos,,, AncW,, ahk_id %XYhWnd%
		CAncA = %AncW%						;current win W
		If (PAncA != CAncA) {				;Win W change = sync new pos
			GUIX	 := AncW - xborder*2 - GUIW
			GUIY	 := 1
			WinMove, ahk_id %GUIhWnd%,, %GUIX%, %GUIY%	;set new position
		}
	}
Return

;triggered by filterbox or Pause chkbox change.
CallUpdateFilter:
	GuiControl, Focus, %GUIEdithWnd%		;refocus filterbox always
	GuiControlGet, Paused,, %GUIPausehWnd%	;get current Pause state
	If (Paused == 1)
		Return			;stop msging (ie live-flitering) while paused
	GoSub, UpdateFilter	;else proceed with filter update
Return

;get filterbox content and pass to XY
UpdateFilter:
	GuiControlGet, StrFilter,, %GUIEdithWnd%	;get current filterbox text
	; escape and/or enclose in SINGLE-quotes (so pattern stays non-resolved)
	IfInString, StrFilter, % "'"
		StrFilter := "'" StrReplace(StrFilter, "'", "''") "'"
	Else
		StrFilter := "'" StrFilter "'"
	;same filter twice resets VF, so skip that
	If (LastFilter != StrFilter) {			;check if last sent filter is unique
		LastFilter := StrFilter				;remember current filter as last one
		StrFilter  := "::filter " StrFilter	;make XY filtering script
		MsgToXY(StrFilter)					;send filter msg
		StrFilter  := ""					;forget current filter
	}
Return

;toggles pause status
lblTogglePause:
	GuiControlGet, Paused,, %GUIPausehWnd%					;get current 'P'ause state
	GuiControl,, %GUIPausehWnd%, % ((Paused == 0) ? 1 : 0)	;toggle status
	;updateFilter is set to run automatically on pause state change
	;but it doesn't seem to trigger on programmatic change
	GoSub, CallUpdateFilter
Return

;handle escape routes
GuiClose:
GuiEscape:
	ExitApp
Return
;focus parent XY window
lblFocusXY:
	FocusXY()
Return
;focus own window
lblFocusGUI:
	FocusGUI()
Return

;focus own window. also triggered on WM_Mouseover (else ctrl under GUI gets focus)
FocusGUI() {
	global Showtip, Shortcut
	IfWinActive, ahk_id %XYhWnd%
		WinActivate, ahk_id %GUIEdithWnd%	;focus only if parent XY is active
	;show a little tooltip
	IfWinActive, ahk_id %GUIhWnd%
	{
	If (ShowTip != 1) {		;user disabled tips or not shown yet this session
		ShowTip = 1			;remember that tooltips have been shown once (now)
		ToolTip				;hide existing tooltip
		SetTimer, TTOn, 10	;show tips after a slight delay
	}
	Return
	TTOn:	;sub to show tips
		ToolTip, % "CHECKBOX/Alt+P: Pause livemode`nTEXTBOX: enter filter pattern`n"
				 . "FOCUS HOTKEY:" . (Shortcut == "" ? "{None}": Shortcut)
		SetTimer, TTOn, Off		;delete this timer so tips are shown once per session
		SetTimer, TTOff, 2000	;hide tip after a delay
	Return
	TTOff:	;sub to hide tips
		ToolTip					;hide existing tips
		SetTimer, TTOff, Off	;delete this timer
	Return
	}
  Return
}
;focus parent XY window
FocusXY() {
	IfWinActive, ahk_id %GUIhWnd%
		WinActivate, ahk_id %XYhWnd%
  Return
}

;triggered on WM_DESTROY
Destroyer() {
	ExitApp
  Return
}

;=== MsgToXY() =================================================================
;send arg_Msg to %XYhWnd% via WM_COPYDATA
;function lifted from binocular222's XYplorer Messenger[AHK], (thanks!)
MsgToXY(arg_Msg) {
	Size := StrLen(arg_Msg)
	If !(A_IsUnicode)
		VarSetCapacity(Data, Size*2,0),StrPut(arg_Msg,&Data,Size,"UTF-16")
	Else
		Data := arg_Msg
	VarSetCapacity(COPYDATA,A_PtrSize*3,0),NumPut(4194305,COPYDATA,0,"Ptr")
	NumPut(Size*2,COPYDATA,A_PtrSize,"UInt"),NumPut(&Data,COPYDATA,A_PtrSize*2,"Ptr")
	SendMessage,0x4A,0,&COPYDATA,,ahk_id %XYhWnd%
  Return
}
;=== End of MsgToXY() ==========================================================
;=== MsgFromXY() ===============================================================
;triggers on recv WM_COPYDATA from %XYhWnd%, puts data to %ReceivedData%
;also based on binocular222's code
MsgFromXY(wParam, lParam) {
	StringAddress := NumGet(lParam+2*A_PtrSize)
	cbData := NumGet(lParam+A_PtrSize)/2,CopyOfData := StrGet(StringAddress)
	StringLeft,ReceivedData,CopyOfData,cbData
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
	DllCall("GetObject","UInt",hFont,"Int",szLF,"UInt",&LF)
	hDC := DllCall("GetDC","UInt",hwnd),DPI := DllCall("GetDeviceCaps","UInt",hDC,"Int",90)
	DllCall("ReleaseDC","Int",0,"UInt",hDC),S := Round((-NumGet(LF,0,"Int")*72)/DPI)
	Return DllCall("MulDiv","Int",&LF+28,"Int",1,"Int",1,"Str"),DllCall("SetLastError","UInt",S)
}
;=== End of GetFont() ==========================================================

;cleanup filter and perms on exit. Triggered on "normal" script/GUI exit
ExitRoutine:
	GUI, Hide				;exiting "looks" slightly faster
	If WinExist("ahk_id " . XYhWnd) {
		WinActivate, ahk_id %XYhWnd%	;reactivate parent
		If (SyncPos == 1)				;revert AB visibility to pre-exec
			MsgToXY("::setlayout('showaddressbar=" ABState "');")
		;make and send cleanup script
		endMsg := "::filter;unset $p_XYAHKLiveFilter_A,$p_XYAHKLiveFilter_B;"
				. ((OwnCTB > 0) ? "ctbstate(0, " OwnCTB ")" : "") . ";"
		MsgToXY(endMsg)
	}
	ExitApp
Return
