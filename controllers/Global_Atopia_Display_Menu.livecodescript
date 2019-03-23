script "Global_Atopia_Display_Menu"
--> MetaData
-
license: GPLv3
name: Global_Atopia_Display_Menu
type: controller
version: 0.2


--> Global | Atopia | Display | Menu
-
on menu_DisplayAtopiaRoster indexView, pHow
   switch pHow
      case "New Folders"
      case "-"
      case "Atopia Roster"
      case "Domain Array"
      case "Atopia Folders"
         break
   end switch
   put atopia_FetchDomains (pHow) into atopiaDomains
   set the displayed_Index [pHow] of indexView to atopiaDomains
end menu_DisplayAtopiaRoster

on menu_DisplayAtopiaFedray
   local lineMenuTitle
   put atopia_FetchFedray() into fedray
   display_Array fedray, "atopia_FetchFedray()", "Global | Federation | Build | Menu", lineMenuTitle
end menu_DisplayAtopiaFedray

on menu_DisplayAtopiaOwners indexView
   --display_AtopiaDomains "Domain Owners"
   display_AtopiaOwners
end menu_DisplayAtopiaOwners

on _
end _


on menu_DisplayFederationArray
   put fedray_Fetch() into fedray
   display_Array fedray, "fedray_Fetch()", "Global | Federation | Build | Menu"
end menu_DisplayFederationArray

on _
end _

on menu_DisplayAtopiaConfig
   display_AtopiaConfigArray
end menu_DisplayAtopiaConfig

on menu_DisplayDropletInfoArray
   put digitalOcean_GetDropletInfoArray() into DropletInfoArray
   display_Array DropletInfoArray, "digitalOcean_GetDropletInfoArray()"
end menu_DisplayDropletInfoArray

on menu_DigitalOceanDomainInfoArray
   put digitalocean_GetDomainInfoArray() into DomainInfoArray
   display_Array DomainInfoArray, "digitalocean_GetDomainInfoArray()"
end menu_DigitalOceanDomainInfoArray


--> END
-
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


--> Dev | Menu
-
on menu_TopDomainTsv indexView, cseName
   put atopia_FetchTopTSV (cseName)
end menu_TopDomainTsv

on menu_DisplayOwnershipArray indexView
   put atopia_GetOwnershipArray() into ownershipArray
   -- put dynadot_FetchIndexedDomainArray() into domainArray
   display_Array ownershipArray, "atopia_GetOwnershipArray()", "Global | Atopia | Tree | Menu"
end menu_DisplayOwnershipArray

on _
end _

on menu_LocalFederationArray arrayView
   breakpoint -- old local model
   put fedray_GetArray() into federationArray
   --
   display_Array federationArray, "Federation Array", "Global | Atopia | Top | Menu"
end menu_LocalFederationArray

on _
end _

on menu_LocalGoodFolders
   display_AtopiaDomains "Local Good Folders"
end menu_LocalGoodFolders

on menu_LocalBadFolders indexView
   display_AtopiaDomains "Local Bad Folders"
end menu_LocalBadFolders

on menu_AllLocalWikiFolders indexView
   display_AtopiaDomains "All Local Wiki Folders"
end menu_AllLocalWikiFolders

on _
end _

on menu_RemoteWikiFolders indexView
   display_AtopiaDomains "Remote Wiki Folders"
end menu_RemoteWikiFolders

on menu_RemoteUnhostedFolders indexView
   display_AtopiaDomains "Remote Unhosted Sites"
end menu_RemoteUnhostedFolders

on menu_RemoteTrash indexView
   display_AtopiaDomains "Remote Trash"
end menu_RemoteTrash

on menu_RemoteOldSites indexView
   display_AtopiaDomains "Remote Old Sites"
end menu_RemoteOldSites

on menu_ReservedFolders indexView
   display_AtopiaDomains "Reserved Folders"
end menu_ReservedFolders

on _
end _

on menu_DisplayMissingRemoteFolderArray
   put atopia_MissingRemoteFolderArray() into notThereArray
   display_Array notThereArray, "atopia_MissingRemoteFolderArray()"
end menu_DisplayMissingRemoteFolderArray
