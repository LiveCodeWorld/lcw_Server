script "Global | Server | Menu"
--> MetaData
-
license: GPLv3
name: Global | Server | Menu
type: controller
version: 0.2

/*For some strange reason this provokes recursion. Try adding it and track down the menu bug!

on submenu_Dynadot
   return "Global | Dynadot | Menu"
end submenu_Dynadot*/


--> Menu | Init
-
getprop disabled_DisplayServerArray
   put the server_Array of stack "lib_RemoteServer" into serverArray
   if serverArray is an array then
      return false
   else
      return true
   end if
end disabled_DisplayServerArray


--> Global | Server | Menu
-
on menu_ListAtopiaFolders
   display_AtopiaDomainFolders
end menu_ListAtopiaFolders

on _
end _

on menu_DisplayDynadot
   display_DynadotParked
end menu_DisplayDynadot

on submenu_Dev
   return "Dev | Menu"
end submenu_Dev


--> Dev | Menu
-
on menu_DisplayServerArray
   put the server_Array of stack "lib_RemoteServer" into serverArray
   display_Array serverArray, "the server_Array"
end menu_DisplayServerArray

on _
end _

on menu_LoadLiveCodeWorld
   server_LoadDetails "rest.livecode.world"
   menu_DisplayServerArray
end menu_LoadLiveCodeWorld

on menu_ShowStoredTokens
   put pref_GetValue ("GitHubAuthoringToken") into GitHubAuthoringToken
   put GitHubAuthoringToken
end menu_ShowStoredTokens
