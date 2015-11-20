## [XYAHKLiveFilter](https://www.github.com/SammaySarkar/XYAHKLiveFilter)
http://www.xyplorer.com/xyfc/viewtopic.php?t=12588

####**version 3**

A live-filter plugin for [XYplorer](http://www.xyplorer.com), made in [AutoHotkey](http://www.ahkscript.org)
Live-filters the file list as you type into a textbox. Uses SC `filter`, so all its syntax is available.

###INSTALL:
* Download and extract the release archive. Or clone this repo and compile the ahk.
* Place **XYAHKLiveFilter.exe** in the `<xyscripts>` folder.
* Next attach the following xyscript to a CTB and/or to a UDC item.
```
::if($p_XYAHKLiveFilter_A!=1)||($p_XYAHKLiveFilter_B!=<hwnd>){$p_XYAHKLiveFilter_A=1;$p_XYAHKLiveFilter_B=<hwnd>;run "<xyscripts>\XYAHKLiveFilter.exe <hwnd> ^`",,0;};
```
* That's it! Now just click the CTB or trigger the UDC and filter away! (Don't forget to read about usage & options below.)
* (Don't forget to modify the path in that script to match the actual path of the exe.
  Also you can modify it even further to run the source ahk itself via the AutoHotkey interpreter.)


###USAGE:
* The filterbox pops up at the *topleft* of it's parent XYplorer window.
* Press the focus hotkey (default:<kbd>CTRL</kbd>+<kbd>\`</kbd>) to focus the filterbox and <kbd>TAB</kbd>
  to refocus main XY window. (ofcourse mouse can be used instead too.)<br/>.
* In the launching xyscript, the first commandline parameter given to the exe (or ahk) is the focus hotkey.<br/>
  The default value `^\'` means <kbd>CTRL</kbd>+<kbd>\`</kbd>. It follows [Authotkey's hotkey syntax](http://ahkscript.org/docs/Hotkeys.htm).
* Press <kbd>ESCAPE</kbd> while the filterbox is focused to close it. (also quits automatically when parent XY window is closed.)
* If you use the script as a UDC with a keyboard shortcut, I suggest setting the same shortcut as Focus Hotkey.
* Full content of the filterbox is passed to SC `filter` unchanged, so should be properly escaped according to XYplorer scripting rules when necessary.
* Live-filtering is not suitable for RegExp patterns. Activate the **P** checkbox to pause livemode, enter complex/RegExp pattern, then uncheck it again to submit.


###IMPORTANT:
* To work correctly, the exe/ahk must be launched from within XY as directed in INSTALL section.
* If the filterbox doesn't open, delete/unset the permanent variables `$p_XYAHKLiveFilter_A`,`$p_XYAHKLiveFilter_B` and try again.
* May also fail to run if an invalid hotkey string is supplied in `$FocusHotkey`.
* Some AntiMalware suites apparently flag compiled ahk scripts as infected, which is a false alarm.
  In any case, you can generate the exe yourself or directly run it as an ahk script.

Well, that's about it.
*Happy filtering!*

======================

I know the script can benefit from some improvements, bugfixes. All such help is welcome!