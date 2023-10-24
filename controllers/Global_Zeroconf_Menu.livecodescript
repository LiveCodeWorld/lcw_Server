script "Global | Zeroconf | Menu"
--> MetaData
-
copyright: Anonymous
license: GPLv3
name: Global | Zeroconf | Menu
type: controller
version: 0.1

/*Here you can describe this menu.
Full help text should be provided on the linked wiki.*/


--> Variables
-
local LocalArray


--> Menu | Init
-
on menu_Init tObject   
   -- do something when the menu first loads
end menu_Init

getprop checked_StartSearch
   return zeroconf_IsSearching()
end checked_StartSearch

getprop checked_StartServer
   return zero_IsRunning()
end checked_StartServer


--> Global | Zeroconf | Menu
-
on menu_StartSearch
   if zeroconf_IsSearching() then
      zeroconf_StopSearch
   else
      zeroconf_StartSearch
   end if
end menu_StartSearch

on menu_StartServer
   if zero_IsRunning() then
      zero_StopServer
   else
      zero_StartServer sName
   end if
end menu_StartServer
