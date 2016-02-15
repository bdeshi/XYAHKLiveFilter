REM compile with AHK v <default>: set ver=""
REM compile with AHK v 1.1.22.04: set ver="112204\"
REM    that version is located in AutoHotkey\112204\
setlocal
set ahkver=112204\
"%PROGS%\AutoHotkey\%ahkver%Compiler\Ahk2Exe.exe" /in ".\XYAHKLiveFilter.ahk" /out ".\XYAHKLiveFilter.exe" /icon ".\XYAHKLiveFilter.ico"
endlocal