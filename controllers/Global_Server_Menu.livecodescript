script "Global_Server_Menu"
--> MetaData
-
license: GPLv3
name: Global_Server_Menu
type: controller
version: 0.2


--> Global | Server | Menu
-
on menu_ListAtopiaFolders
   display_AtopiaDomainFolders
end menu_ListAtopiaFolders

on _
end _

on submenu_Dynadot
   return "Global | Dynadot | Menu"
end submenu_Dynadot

on _
end _

on menu_DisplayServerArray
   put the server_Array of stack "lib_RemoteServer" into serverArray
   display_Array serverArray, "the server_Array"
end menu_DisplayServerArray

on menu_LoadLiveCodeWorld
   server_LoadDetails "rest.livecode.world"
   menu_DisplayServerArray
end menu_LoadLiveCodeWorld

on menu_ShowStoredTokens
   put pref_GetValue ("GitHubAuthoringToken") into GitHubAuthoringToken
   put GitHubAuthoringToken
end menu_ShowStoredTokens

on _
end _

on menu_UpdateDynadotInfoArray
   dynadot_UpdateCachedIndexDomainArray
   put the result into dynadotInfoArray
   display_Array dynadotInfoArray, "Dynadot Info Array,dynadot_UpdateCachedIndexDomainArray"
end menu_UpdateDynadotInfoArray

on menu_UpdateOceanInfoArray
   digitalocean_UpdateDomainInfoArray
   put the result into oceanInfoArray
   display_Array oceanInfoArray, "Ocean Info Array,digitalocean_FetchDomainInfoArray()"
end menu_UpdateOceanInfoArray


--> Global | Server | Menu | Props
-

--> Global | Server | Menu | Disabled
-
getprop disabled_DisplayServerArray
   put the server_Array of stack "lib_RemoteServer" into serverArray
   if serverArray is an array then
      return false
   else
      return true
   end if
end disabled_DisplayServerArray


on mainStackChanged
   
end mainStackChanged
