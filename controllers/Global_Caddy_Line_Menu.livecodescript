script "Global | Caddy | Line | Menu"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: Global | Caddy | Line | Menu
type: controller
version: 0.5

/*Here you can describe this menu.
Full help text should be provided on the linked wiki.*/


--> Variables
-
local LocalArray

--> Menu | Props
-
getprop menu_Target [tObject]
   put the display_View of tObject into dView
   return dView
end menu_Target

getprop menu_CheckTarget [dView]
   return exists (dView)
end menu_CheckTarget

private function _GetCaddyHost dView
   put the caddy_ConfigData of dView into caddyConfigData
   put caddyRouteArray_Get(caddyConfigData) into indexArray
   put caddyRouteArray_FindHostArray (routeArray) into caddyHosts
   return caddyHosts
end _GetCaddyHost

function caddyRouteArray_Hosts sArray
   put sArray ["match"][1][host] into hostArray
   --
   repeat for each element sLine in hostArray
      if char 1 to 2 of sLine = "*." then next repeat
      --
      put sLine & CR after sDomains
   end repeat
   delete char -1 of sDomains
   return sDomains
end caddyRouteArray_Hosts

on mDoubleUp_Caddy dView, caddyDomain
   _DisplayHostArray dView, caddyDomain
end mDoubleUp_Caddy

command _DisplayHostArray dView, pWikiDomain
   if pWikiDomain is empty then
      put the selected_Line of dView into pWikiDomain
   end if
   
   put the caddy_ConfigData of dView into caddyConfigData
   put caddyRouteArray_Get(caddyConfigData) into routeIndexArray
   --
   put caddyRouteArray_FindItemArray(pWikiDomain, routeIndexArray) into routeItemArray
   -- put caddyRouteArray_FindHostArray (pWikiDomain, routeIndexArray) into hostArray
   --
   display_Data routeItemArray, pWikiDomain, "Caddy Route Array"
   return the result
end _DisplayHostArray


--> Global | Caddy | Line | Menu
-
on menu_DisplayRoute dView
   _DisplayHostArray dView
end menu_DisplayRoute

private on _
end _

private on __
end __

on submenu_Dev
   return menu_DevTitle ("Global | Caddy | Line | Menu")
end submenu_Dev
