script "Global | Xterm | Dev | Menu"
--> MetaData
-
license: GPLv3
name: Global | Xterm | Dev | Menu
type: controller
author: David Bovill
version: 0.1

/*
Here you can describe this menu.
Full help text should be provided on the linked wiki.
*/

--> Variables
-
local LocalArray

--> Menu | Props
-
getprop menu_Target [tObject]
   return the browser_View of tObject
end menu_Target


--> Global | Xterm | Dev | Menu
-
on menu_HtmlText browserView
   get the browser_HtmlText of browserView
end menu_HtmlText

on menu_Refresh browserView
   -- put "http://localhost:8080" into xtermURL
   put the browser_URL of browserView into xtermURL
   set the browser_URL of browserView to xtermURL
end menu_Refresh

private on _
end _

on menu_EditBehavior browserView
   put the behavior of browserView into bObject
   edit the script of bObject
end menu_EditBehavior
