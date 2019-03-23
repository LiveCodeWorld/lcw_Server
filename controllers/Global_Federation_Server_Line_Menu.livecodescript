script "Global_Federation_Server_Line_Menu" with behavior "behavior_RigLocalOveride"
--> MetaData
-
license: GPLv3
name: Global_Federation_Server_Line_Menu
type: controller
version: 0.1


--> Global | Federation | Server | Line | Menu
-
on menu_PublishServer arrayView
   put item 1 of the selected_Path of arrayView into serverName
   put the displayed_Data of arrayView into serverData
   --
   federation_UpdateServerPage serverName, serverData
   --
   put federation_ConstructServerURL (serverName) into serverURL
   launch url serverURL
end menu_PublishServer

on menu_LaunchDocumentation arrayView
   put item 1 of the selected_Path of arrayView into serverName
   put federation_ConstructServerURL (serverName) into serverURL
   launch url serverURL
end menu_LaunchDocumentation

on _
end _

on menu_DisplayUpdater arrayView
   -- see also "menu_UpdateSeverData"
   put item 1 of the selected_Path of arrayView into serverName
   put the top_Array of arrayView into serverArray
   put serverArray ["domains"] into fedray
   put serverName && "Model" into displayTitle
   --
   display_FedrayUpdate fedray, displayTitle
   --
   put the result into indexView
end menu_DisplayUpdater

on _
end _

on menu_RenameServer arrayView
   put the top_Array of arrayView into serverArray
   --
   put serverArray ["ipAddress"] into ipAddress
   put serverArray ["domains"] into domainArray
   put keys (domainArray) into serverDomains
   url_SortDomainIndex serverDomains
   put line 1 of serverDomains into serverDomain
   put lcw_Ask ("Choose a name for this server...", serverDomain) into serverName
   --
   put the displayed_Data of arrayView into displayedData
   delete variable displayedData [ipAddress]
   put serverArray into displayedData [serverName]
   --
   set the displayed_Data of arrayView to displayedData
   --
   federation_StoreServerData displayedData
end menu_RenameServer

on menu_StoreServerArray arrayView
   lcw_Answer "Save this servers array to the servers wiki page?", arrayView
   --
   put item 1 of the selected_Path of arrayView into serverName
   put the top_Array of arrayView into serverArray
   federation_StoreServerArray serverName, serverArray
end menu_StoreServerArray

on menu_DeleteServer arrayView
   put item 1 of the selected_Path of arrayView into serverName
   put the displayed_Data of arrayView into serverData
   delete variable serverData [serverName]
   --
   set the displayed_Data of arrayView to serverData
   federation_StoreServerData serverData
end menu_DeleteServer

on _
end _

on submenu_Dev
   return "Dev | Menu"
end submenu_Dev


--> Global | Federation | Server | Line | Menu | Props
-

--> Global | Federation | Server | Line | Menu | Disabled
-

--> Dev | Menu
-
on menu_DisplayedServerArray arrayView
   put the top_Array of arrayView into serverArray
   --
   display_Array serverArray, "top_Array"
end menu_DisplayedServerArray

on menu_RemoteServerArray arrayView
   lcw_Answer "Remove server array from wiki model. Testing and not stored for now..."
   
   put item 1 of the selected_Path of arrayView into serverName
   put federation_FetchServerData (serverName) into federationServerArray
   put federationServerArray [serverName] into serverArray
   --
   display_Array serverArray, "federation_FetchServerData"
end menu_RemoteServerArray

on _
end _

on menu_UpdateSeverModel arrayView
   lcw_Answer "Update server array using fedray and teh displayed data. Not quite sure what it does, but testing and not stored for now..."
   
   set the cursor to watch
   --
   put true into pUpdateFedray
   put fedray_FetchWards() into fedray
   --
   put item 1 of the selected_Path of arrayView into serverName
   put the displayed_Data of arrayView into serverData
   --
   serverData_UpdateServer serverData, serverName, fedray, pUpdateFedray
   --
   set the displayed_Data of arrayView to serverData
end menu_UpdateSeverModel

on menu_CreateFedrayModels displayView
   menu_Do "menu_CreateFedrayModels", "Global | Federation | Build | Menu"
end menu_CreateFedrayModels
