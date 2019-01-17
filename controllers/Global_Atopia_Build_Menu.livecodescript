script "Global_Atopia_Build_Menu"
--> MetaData
-
license: GPLv3
name: Global_Atopia_Build_Menu
type: controller
version: 0.1


--> Global | Atopia | Build | Menu
-
on menu_UpdateDigitalOceanArrays
   digitalOcean_FetchAndSetDropletArrays
   lcw_AnswerWarning "Updated local Droplet, and domain arrays for Digital Ocean"
end menu_UpdateDigitalOceanArrays

on menu_UpdateAtopiaConfig
   put atopia_FetchConfigArray() into configArray
   atopia_SetConfigArray configArray
   --
   atopia_DisplayConfigArray
end menu_UpdateAtopiaConfig

on _
end _

on menu_BuildOwnershipArray indexView
   lcw_AnswerSheet "Do you want to build an ownership array for all server side (good) wiki folders?"
   --
   atopia_ConstructOwnershipArray true, indexView
   put the result into ownershipArray
   breakpoint
   fedray_AddOwnershipArray ownershipArray, "atopia.array"
   --
   lcw_AnswerSheet "Built and saved ownership array!"
   --
   display_AtopiaFolders "Domain Owners"
end menu_BuildOwnershipArray

on menu_AddOwnedToFedray indexView
   put atopia_GetOwnershipArray() into ownershipArray
   fedray_AddOwnershipArray ownershipArray, "atopia.array"
end menu_AddOwnedToFedray

on menu_BuildAtopiaDnsArray indexView
   lcw_AnswerSheet "Do you want to build the dns array for all server side (good) wiki folders?"
   --
   atopia_ConstructDnsArray true
   --
   menu_DisplayAtopiaArray indexView
end menu_BuildAtopiaDnsArray

on menu_BuildAtopiaDomainArray
   lcw_AnswerSheet "This is very slow! Update instead?"
   --
   put atopia_FetchAndBuildArray() into pAtopiaData
   atopia_SetData pAtopiaData   
   --
   display_AtopiaFolders "All Local Wiki Folders"
   display_AtopiaDomainErrorArray
end menu_BuildAtopiaDomainArray



--> Global | Atopia | Build | Menu | Props
-

--> Global | Atopia | Build | Menu | Disabled
-

--> Deps
-
command digitalOcean_FetchAndSetDropletArrays
   digitalocean_UpdateDropletInfoArray
   if the result is not an array then
      lcw_AnswerSheet "Fetching DropletInfoArray failed"
   end if
   
   digitalocean_UpdateDomainInfoArray
   if the result is not an array then
      lcw_AnswerSheet "Fetching DomainInfoArray failed"
   end if
   
   put atopia_FetchConfigArray() into configArray
   if the result is not an array then
      lcw_AnswerSheet "Fetching configArray failed"
   end if
   atopia_SetConfigArray configArray
end digitalOcean_FetchAndSetDropletArrays
