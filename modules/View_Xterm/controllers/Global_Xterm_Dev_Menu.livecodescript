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
on menu_RefreshBrowser browserView
   -- put "http://localhost:8080" into xtermURL
   put the browser_URL of browserView into xtermURL
   set the browser_URL of browserView to xtermURL
end menu_RefreshBrowser

on menu_RefreshBehavior xTermView
   view_RefreshBehavior xTermView
   --
   put the template_Object of xTermView into mView
   view_RefreshBehavior mView
end menu_RefreshBehavior

private on _
end _

on menu_PreviousJavascript xTermView
   put the browser_Javascript of xTermView
end menu_PreviousJavascript

on menu_ViewProperties tWidget
   display_ObjectProperties tWidget
end menu_ViewProperties

on menu_ModuleProperties dWidget
   put the view_Name of dWidget into viewName
   display_Template viewName
   --
   put the result into moduleObject
   display_ObjectProperties moduleObject
end menu_ModuleProperties

on menu_DisplayModuleTools tWidget
   -- put the menu_Name of me into mName
   put the view_Name of tWidget into moduleName
   --
   display_ModuleTools moduleName
end menu_DisplayModuleTools

on menu_EditBehavior browserView
   put the behavior of browserView into bObject
   edit the script of bObject
end menu_EditBehavior
