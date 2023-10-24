script "Global | Server | Dev | Menu"
--> MetaData
-
license: GPLv3
name: Global | Server | Dev | Menu
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
   -- return display_MenuTarget(tObject)
   return the display_View of tObject
end menu_Target


--> Global | Server | Dev | Menu
-
on menu_ListAtopiaFolders
   display_AtopiaDomainFolders
end menu_ListAtopiaFolders

on menu_DisplayDynadot
   display_DynadotParked
end menu_DisplayDynadot

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
