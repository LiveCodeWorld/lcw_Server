﻿script "Global | Pihole | Subdomains | Menu"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: Global | Pihole | Subdomains | Menu
type: controller
version: 0.1

/*Here you can describe this menu.
Full help text should be provided on the linked wiki.*/


--> Variables
-
local LocalArray

--> Menu | Props
-
getprop menu_Target [tObject]
   put the display_View of tObject into LocalArray ["dView"]
   put the displayed_Object of tObject into sObject
   return sObject
end menu_Target

private function _dView
   return LocalArray ["dView"]
end _dView

getprop menu_CheckTarget [dView]
   return exists (dView)
end menu_CheckTarget


--> Global | Pihole | Subdomains | Menu
-
on menu_PiholeSubdomains dView
   put the title_Text of dView into tldDomain
   --
   display_PiholeSubdomains tldDomain, dView
end menu_PiholeSubdomains

private on _
end _

on menu_Behavior dView
   put the behavior of dView into bObject
   edit the script of bObject
end menu_Behavior

on menu_ModuleTools dView
   put the view_Name of dView into viewName
   display_ModuleTools viewName
end menu_ModuleTools

private on __
end __

on submenu_Dev
   return menu_DevTitle ("Global | Pihole | Subdomains | Menu")
end submenu_Dev
