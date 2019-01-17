script "Global_Atopia_Display_Menu"
--> MetaData
-
license: GPLv3
name: Global_Atopia_Display_Menu
type: controller
version: 0.2


--> Global | Atopia | Display | Menu
-
on menu_DisplayTopDomains
   display_AtopiaFolders "Top Domains"
end menu_DisplayTopDomains

on menu_TopDomainTsv indexView, cseName
   put cse_NameToID (cseName) into cseID
   put atopia_GetTopDomains() into atopiaDomains
   put google_ConstructTSV (atopiaDomains, cseID)
end menu_TopDomainTsv

on _
end _

on menu_DisplayOwners indexView
   --display_AtopiaFolders "Domain Owners"
   display_AtopiaOwners
end menu_DisplayOwners

on menu_DisplayOwnershipArray indexView
   put atopia_GetOwnershipArray() into ownershipArray
   -- put dynadot_FetchIndexedDomainArray() into domainArray
   display_Array ownershipArray, "atopia_GetOwnershipArray()", "Global | Atopia | Tree | Menu"
end menu_DisplayOwnershipArray

on menu_DisplayNewFolders
   display_AtopiaFolders "New Folders"
end menu_DisplayNewFolders

on _
end _

on menu_DisplayAtopiaConfig
   atopia_DisplayConfigArray
end menu_DisplayAtopiaConfig

on menu_DisplayDropletInfoArray
   put digitalOcean_GetDropletInfoArray() into DropletInfoArray
   display_Array DropletInfoArray, "digitalOcean_GetDropletInfoArray()"
end menu_DisplayDropletInfoArray

on menu_DisplayDomainInfoArray
   put digitalocean_GetDomainInfoArray() into DomainInfoArray
   display_Array DomainInfoArray, "digitalocean_GetDomainInfoArray()"
end menu_DisplayDomainInfoArray

on menu_DisplayFederationArray arrayView
   put fedray_GetArray() into federationArray
   --
   display_Array federationArray, "Federation Array", "Global | Atopia | Top | Menu"
end menu_DisplayFederationArray

on _
end _

on menu_LocalGoodFolders
   display_AtopiaFolders "Local Good Folders"
end menu_LocalGoodFolders

on menu_LocalBadFolders indexView
   display_AtopiaFolders "Local Bad Folders"
end menu_LocalBadFolders

on menu_AllLocalWikiFolders indexView
   display_AtopiaFolders "All Local Wiki Folders"
end menu_AllLocalWikiFolders

on _
end _

on menu_RemoteWikiFolders indexView
   display_AtopiaFolders "Remote Wiki Folders"
end menu_RemoteWikiFolders

on menu_RemoteUnhostedFolders indexView
   display_AtopiaFolders "Remote Unhosted Sites"
end menu_RemoteUnhostedFolders

on menu_RemoteTrash indexView
   display_AtopiaFolders "Remote Trash"
end menu_RemoteTrash

on menu_RemoteOldSites indexView
   display_AtopiaFolders "Remote Old Sites"
end menu_RemoteOldSites

on menu_ReservedFolders indexView
   display_AtopiaFolders "Reserved Folders"
end menu_ReservedFolders

on _
end _

on menu_DisplayAtopiaArray
   display_AtopiaDomainErrorArray
end menu_DisplayAtopiaArray

on menu_DisplayMissingRemoteFolderArray
   put atopia_MissingRemoteFolderArray() into notThereArray
   display_Array notThereArray, "atopia_MissingRemoteFolderArray()"
end menu_DisplayMissingRemoteFolderArray

on _
end _

on submenu_Dev
   return "Dev | Menu"
end submenu_Dev


--> Global | Atopia | Display | Menu | Props
-
getprop cse_Names
   return cse_ListNames()
end cse_Names


--> Global | Atopia | Display | Menu | Disabled
-
getprop disabled_DisplayFederationArray
   put fedray_GetArrayFile() into modelDataFile
   put there is not a file modelDataFile into noFileThere
   return noFileThere
end disabled_DisplayFederationArray


--> Dev | Menu
-
on menu_RevealModelFolder
   put the model_DataFolder of stack "lcw_Server" into modelFolder
   finder_Reveal modelFolder
end menu_RevealModelFolder

on _
end _

on menu_DisplayAtopiaDropletInfo
   put digitalOcean_GetDropletArray ("Atopia") into dropletArray
   display_Array dropletArray
end menu_DisplayAtopiaDropletInfo

on _
end _

on menu_Refresh indexView
   display_AtopiaFolders
end menu_Refresh
