script "Global | Browser | Dev | Menu"
--> MetaData
-
license: GPLv3
name: Global | Browser | Dev | Menu
type: controller
author: David Bovill
version: 0.1

/*
Here you can describe this developer menu.
Full help text should be provided on the linked wiki.

Consider improving by creating with same menu_Target as no-developer menu is is based on.
*/

--> Variables
-
local LocalArray

--> Menu | Props
-
getprop menu_Target [tObject]
   -- return display_MenuTarget(tObject)
   return the display_View of tObject
end menu_Target

getprop menu_CheckTarget [cameraView]
   return exists (cameraView)
end menu_CheckTarget


--> Global | Browser | Dev | Menu
-
on menu_TtydExecute browserView
   ttyd_Execute "whoami", browserView
   --
   ttyd_Execute "ls -la", browserView
end menu_TtydExecute

on menu_TtydClear browserView
   ttyd_Execute "clear", browserView
end menu_TtydClear

on menu_DisplayBrowserTemplate
   display_ViewTemplate "View|Browser"
   put the result
end menu_DisplayBrowserTemplate

on menu_EditBrowserBehavior browserView
   put the behavior of browserView into bObject
   edit the script of bObject
end menu_EditBrowserBehavior

