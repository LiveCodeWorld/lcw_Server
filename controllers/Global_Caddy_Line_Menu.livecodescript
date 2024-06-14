script "Global | Caddy | Line | Menu"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: Global | Caddy | Line | Menu
type: controller
version: 0.4

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
   put the top_Data [6] of dView into routeArray
   put caddyRouteArray_Hosts (routeArray) into caddyHosts
   return caddyHosts
end _GetCaddyHost


--> Global | Caddy | Line | Menu
-
on menu_DisplayRoute dView
   put _GetCaddyHost(dView) into wikiDomain
   --
   put caddyRouteArray_Construct (wikiDomain, toDomainPort) into routeArray
   display_Data routeArray, "caddyRouteArray_Construct()", "Caddy Route Array"
end menu_DisplayRoute

getprop disabled_DisplayRoute [dView]
   put the selected_Path of dView into sPath
   put the number of items of sPath into pNum
   --
   put (item 5 of sPath = "routes") AND (pNum > 5) into hasRoute
   return hasRoute is false
end disabled_DisplayRoute

on menu_ConstructRouteArray dView
   put the top_Data [6] of dView into routeArray
   put caddyRouteArray_Hosts (routeArray) into wikiDomain
   put "localhost:3000" into toDomainPort
   --
   put caddyRouteArray_Construct (wikiDomain, toDomainPort) into cRouteArray
   --
   if routeArray = cRouteArray then
      put the shiftKey is "Down" into makePretty
      put json_FromArray (cRouteArray, false, makePretty) into sJSON
      put sJSON
   else
      display_Data cRouteArray, "caddyRouteArray_Construct()"
      breakpoint
   end if
end menu_ConstructRouteArray

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
   return menu_DevTitle ("Global | Caddy | Line | Menu")
end submenu_Dev
