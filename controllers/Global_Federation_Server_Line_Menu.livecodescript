script "Global | Federation | Server | Line | Menu" with behavior "behavior_RigLocalOveride"
--> MetaData
-
license: GPLv3
name: Global | Federation | Server | Line | Menu
type: controller
version: 0.2


--> Menu | Params
-
local LocalArray

getprop menu_Target [tObject]
   _Init tObject
   return the display_View of tObject
end menu_Target

on _Init tObject
   put item 1 of the selected_Path of tObject into serverName
   put serverName into LocalArray ["serverName"]
   put federation_ListDocumentedServerNames() into serverPageNames
   put serverPageNames into LocalArray ["serverPageNames"]
   put (serverName && "Server") is among the lines of serverPageNames into isDocumented
   put isDocumented into LocalArray ["isDocumented"]
end _Init

command serverData_UpdateServer @serverModel, serverName, fedray, pUpdateFedray
   breakpoint
   local newServerData
   put serverModel [serverName]["domains"] into serverDomainArray
   repeat for each key wikiDomain in serverDomainArray
      set the cursor to busy
      fedserver_UpdateModel newServerData, fedray, wikiDomain, pUpdateFedray -- newServerData will use ipAddress not serverName
   end repeat
   put line 1 of keys (newServerData) into ipAddress
   put newServerData [ipAddress] into serverModel [serverName]
   fedserver_UpdateServerModel serverModel, serverName
   return newServerData
end serverData_UpdateServer

private function _ServerName
   return LocalArray ["serverName"]
end _ServerName

getprop disabled_LaunchDocumentation [arrayView]
   return LocalArray ["isDocumented"] is false
end disabled_LaunchDocumentation

getprop disabled_PublishServer [arrayView]
   if LocalArray ["isDocumented"] is true then
      return "delete"
   else
      return false
   end if
end disabled_PublishServer


--> Global | Federation | Server | Line | Menu
-
on menu_LaunchDocumentation arrayView
   put _ServerName() into serverName
   --
   put federation_ConstructServerURL (serverName) into serverURL
   launch url serverURL
end menu_LaunchDocumentation

on menu_UpdateServerPage arrayView
   put _ServerName() into serverName
   put the displayed_Data of arrayView into federationServerModel
   --
   put federation_ConstructServerModel() into federationServerModel
   federation_UpdateServerPage serverName, federationServerModel
   --
   put federation_ConstructServerURL (serverName) into serverURL
   launch url serverURL
end menu_UpdateServerPage

on menu_PublishServer arrayView
   put _ServerName() into serverName
   put the displayed_Data of arrayView into federationServerModel
   --
   put federation_ConstructServerModel() into federationServerModel
   federation_UpdateServerPage serverName, federationServerModel
   --
   put federation_ConstructServerURL (serverName) into serverURL
   launch url serverURL
end menu_PublishServer

on _
end _

on menu_DisplayFedrayUpdater arrayView
   -- see also "menu_UpdateSeverData"
   put _ServerName() into serverName
   --
   put the top_Array of arrayView into serverArray
   put serverArray ["domains"] into fedray
   put serverName && "Model" into displayTitle
   --
   display_FedrayUpdate fedray, displayTitle
   --
   put the result into indexView
end menu_DisplayFedrayUpdater

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
   put lcw_Ask ("Choose a name for this server...", serverDomain, arrayView) into serverName
   --
   put the displayed_Data of arrayView into displayedData
   delete variable displayedData [ipAddress]
   put serverArray into displayedData [serverName]
   --
   set the displayed_Data of arrayView to displayedData
   --
   federation_StoreModel "Server Model", displayedData
end menu_RenameServer

on menu_StoreServerArray arrayView
   put _ServerName() into serverName
   --
   lcw_Answer "Save this servers array to the servers wiki page?", arrayView
   --
   put the top_Array of arrayView into serverArray
   federation_StoreServerArray serverName, serverArray
end menu_StoreServerArray

on menu_DeleteServer arrayView
   put _ServerName() into serverName
   --
   put the displayed_Data of arrayView into serverModel
   delete variable serverModel [serverName]
   --
   set the displayed_Data of arrayView to serverModel
   federation_StoreModel "Server Model", serverModel
end menu_DeleteServer
