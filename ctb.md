[`XYAHKLiveFilter.CTB.xys`](/XYAHKLiveFilter.CTB.xys) provides tighter CTB integration.
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
  if isset($p_XYAHKLiveFilter_A){sendkeys "^`";/*Ensure this matches associated shortcut!*/} else {load "<xyscripts>\XYAHKLiveFilter.CTB.xys";}
ScriptR
  "reset"
   filter;unset $p_XYAHKLiveFilter_A,$p_XYAHKLiveFilter_B;ctbstate(0);
  "edit"
   open "<xyscripts>\XYAHKLiveFilter.xys";
FireClick
  0
```
* (make sure the paths and the sendkey shortcut are correct.)
* Open the CTB editor and note the CTB index.
* Insert this index into XYAHKLiveFilter.ctb.xys as the value of $CTB.
* Now the ctb will toggle on and run XYAHKLiveFilter, and XYAHKLiveFilter will toggle it off when quitting.
* For best results, associate a single CTB with XYAHKLiveFilter. Also use the ctb script instead of the regular one in UDC.
* The right-click menu has a basic reset routine built-in (when the filterbox doesn't come up).

####TODO
* one click opens and another click should close filter.