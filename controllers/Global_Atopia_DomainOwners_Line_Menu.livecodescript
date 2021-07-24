script "Global | Atopia | DomainOwners | Line | Menu"
--> MetaData
-
license: GPLv3
name: Global | Atopia | DomainOwners | Line | Menu
type: controller
version: 0.1


--> Menu | Init
-
getprop displayTsv_Params
   return cse_ListNames()
end displayTsv_Params


--> Global | Atopia | DomainOwners | Line | Menu
-
on menu_CheckDomainOwner indexView
   put the selected_Line of indexView into wikiDomain
   put the title_Text of indexView into ownerEmail
   --
   put atopia_FetchConfigArray() into configArray
   put atopia_FetchDomainOwnerArray (wikiDomain, configArray) into ownerArray
   
   display_View ownerArray, "Owner Array"
end menu_CheckDomainOwner

on _
end _

on submenu_AtopiaDomain
   return "Global | Atopia | Line | Menu"
end submenu_AtopiaDomain

on submenu_Dev
   return "Dev | Menu"
end submenu_Dev


--> Dev | Menu
-
on menu_DisplayTsv indexView, cseName
   put the selected_Line of indexView into ownerEmail
   put atopia_GetLocalDomainsFromEmail (ownerEmail) into atopiaDomains
   --
   put cse_NameToID (cseName) into cseID
   put google_ConstructTSV (atopiaDomains, cseID)
end menu_DisplayTsv

on _
end _

on menu_DisplayOwnedDomains indexView
   put the selected_Line of indexView into ownerEmail
   display_AtopiaOwnerDomains ownerEmail
end menu_DisplayOwnedDomains
