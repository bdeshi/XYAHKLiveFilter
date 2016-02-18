REM compile with AHK v <default>: set ahkv=""
REM compile with AHK v 1.1.22.04: set ahkv="112204\"
SETLOCAL
SET ahkv=
"%PROGS%\AutoHotkey\%ahkv%Compiler\Ahk2Exe.exe" /in ".\XYAHKLiveFilter.ahk" /icon ".\XYAHKLiveFilter.ico"
ENDLOCAL