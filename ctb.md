[`XYAHKLiveFilter.CTB.xys`](/XYAHKLiveFilter.ctb.xys) provides tighter CTB integration.
* Add a new CTB with this snippet:
```
Snip: CTB 1
  XYplorer 15.90.0013, 11/8/2015 10:56:37 AM
Action
  NewUserButton
Name
  LC: open XYAHKLiveFilter
  ------------------------
  RC: 'Reset' XYAHKLiveFilter
        (if it doesn't open)
Icon
  
ScriptL
  $FocusHotkey = "^`" ;/*Ensure this matches associated shortcut!*/ if isset($p_XYAHKLiveFilter_A){sendkeys $FocusHotkey;} else {load "<xyscripts>\XYAHKLiveFilter.CTB.xys";}
ScriptR
  "RESET|:refreshsus"
   filter;unset $p_XYAHKLiveFilter_A,$p_XYAHKLiveFilter_B;ctbstate(0);
  "edit CTB script|:udc"
   openwith "notepad",, "<xyscripts>\XYAHKLiveFilter.CTB.xys";
  "edit BASE script|:udc"
   openwith "notepad",, "<xyscripts>\XYAHKLiveFilter.xys";
FireClick
  0
```
* Make sure the _paths_ and the `$FocusHotkey` value match your setup.
* Now the associated ctb will toggle on and run XYAHKLiveFilter, and XYAHKLiveFilter will toggle it off when closing.
* For best results, associate a single CTB with XYAHKLiveFilter. Also use this ctb to run the filter from now on
  instead of other methods, so the ctbstate always stays synced.<br>
  (But of course, you can make the button sync anyway with enough XYScripting expertise.)
* The right-click menu has a basic reset routine built-in (when the filterbox doesn't come up).
