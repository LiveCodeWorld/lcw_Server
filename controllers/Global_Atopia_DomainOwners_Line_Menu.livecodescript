script "Global_Atopia_DomainOwners_Line_Menu"
--> MetaData
-
license: GPLv3
name: Global_Atopia_DomainOwners_Line_Menu
type: controller
version: 0.1


--> Global | Atopia | DomainOwners | Line | Menu
-
on menu_DisplayTsv indexView, cseName
   put the selected_Line of indexView into ownerEmail
   put atopia_GetDomainsFromEmail (ownerEmail) into atopiaDomains
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


--> Global | Atopia | DomainOwners | Line | Menu | Props
-
getprop cse_Names
   return cse_ListNames()
end cse_Names


--> Global | Atopia | DomainOwners | Line | Menu | Disabled
-
