## [XYAHKLiveFilter](https://www.github.com/SammaySarkar/XYAHKLiveFilter)
http://www.xyplorer.com/xyfc/viewtopic.php?t=12588

**version 4.1.0**

A live-filter plugin for [XYplorer](http://www.xyplorer.com), made with [AutoHotkey](http://www.ahkscript.org)
Live-filters the file list as you type into a textbox. Uses SC `filter`, so all its syntax is available.

###INSTALL:
* Download and extract the release archive. Or clone this repo and compile the ahk.
* Place **XYAHKLiveFilter.exe** in the `<xyscripts>` folder.
* Next attach the following xyscript to a CTB and/or to a UDC item (it's also available as `XYAHKLiveFilter.xys`).
```
 perm $p_XYAHKLiveFilter_A, $p_XYAHKLiveFilter_B;
 if ($p_XYAHKLiveFilter_A != 1)||($p_XYAHKLiveFilter_B != <hwnd>){
  $p_XYAHKLiveFilter_A = 1; $p_XYAHKLiveFilter_B = <hwnd>;
  $FocusHotkey = "^`" ; //ex: ^`=CTRL+`, !+'=ALT+SHIFT+', !Space=ALT+SPACE
  $SyncToAB = 1 ; //sync filterbox position with AB
  $ABPadding = 5 ; //not effective if not $SyncToAB = 1
  run trim(<<<#RuncmD
  "<xyscripts>\XYAHKLiveFilter.exe" <hwnd> "$FocusHotkey" "$ABPadding" "$SyncToAB"#RuncmD,"  ",L),, 0;
 }
```
* That's it! Now just click the CTB or trigger the UDC and filter away! (Don't forget to read about usage & options below.)
* (Don't forget to modify the path in that script to match the actual path of the exe.
  Also you can modify it even further to run the source ahk itself via the AutoHotkey interpreter.)

###USAGE:
* By default, the filterbox pops up and stays over the right edge of the AB (addressbar), enabling AB if needed.<br/>
  See `$SyncToAB` in the **OPTIONS** section below for more details.
* Press the focus hotkey (default:<kbd>CTRL</kbd>+<kbd>\`</kbd>) to focus the filterbox and <kbd>TAB</kbd>
  to refocus main XY window. (ofcourse mouse can be used instead too.)<br/>
  See `$FocusHotkey` in the **OPTIONS** section below for more details.
* Press <kbd>ESCAPE</kbd> while the filterbox is focused to close it. (also quits automatically when parent XY window is closed.)
* Live-filtering is not suitable for RegExp patterns. Check the **P** checkbox to pause livemode, enter complex/RegExp pattern, then uncheck it again to submit.
* You can press <kbd>ENTER</kbd> to force a filter update while livemode is paused.
* Full content of the filterbox is passed to SC `filter` unchanged, so should be properly escaped according to XYplorer scripting rules when necessary.
* If you use the script as a UDC with a keyboard shortcut, I suggest setting the same shortcut as `$FocusHotkey`.<br/>
  This way, you can use the same keypresses to launch the filterbox and focus it subsequently.
* The filterbox uses the same font and fontsize as the addressbar, so you can be sure it'll always match the zoom level of XY.


###OPTIONS:
Some options may be modified in the XYscript.
* `$FocusHotkey`: this value is passed as the shortcut code to instantly focus the filterbox. The default value `^\`` means <kbd>CTRL</kbd>+<kbd>\`</kbd>.<br/>
  It follows [Authotkey's hotkey definition syntax](http://ahkscript.org/docs/Hotkeys.htm).
* `$SyncToAB`: if `$SyncToAB` is 1, the filterbox is positioned over right edge the of the addressbar.
  This also forces the AB to stay visible as long as livefilter is running, and reverts back to last state when the filter is closed.<br/>
  If `$SyncToAB` is not 1, then the filterbox is positioned at the *topleft* of XY, and does not try to modify AB visibility.
* `$ABPadding`: Adjust this value only if the filterbox doesn't horizontal-align exactly with the addressbar.<br/>
  The value should be a (small) integer: 0,3,-2 etc.<br/>
  The filterbox moves up/down this many pixels. Only effective when `$SyncToAB = 1`.

Each of these variables may be set as empty, eg, `$FocusHotkey = "";`

###IMPORTANT:
* To work correctly, the exe/ahk must be launched from within XY as directed in INSTALL section.
* If the filterbox doesn't open, delete/unset the permanent variables `$p_XYAHKLiveFilter_A`,`$p_XYAHKLiveFilter_B` and try again.
* May also fail to run if an invalid hotkey string is supplied in `$FocusHotkey`.
* Some AntiMalware suites apparently flag compiled ahk scripts as infected, which is a false alarm.
  In any case, you can generate the exe yourself or directly run it as an ahk script.

Well, that's about it.
*Happy filtering!*


*I know the script can benefit from some improvements, bugfixes. All such help is welcome!*