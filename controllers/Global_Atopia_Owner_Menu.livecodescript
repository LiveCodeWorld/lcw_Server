script "Global_Atopia_Owner_Menu"
--> MetaData
-
license: GPLv3
name: Global_Atopia_Owner_Menu
type: controller
version: 0.1


--> Global | Atopia | Owner | Menu
-
on menu_DisplayOwnerTsv indexView, cseName
   put cse_NameToID (cseName) into cseID
   --
   put the displayed_Index of indexView into atopiaDomains
   put google_ConstructTSV (atopiaDomains, cseID)
end menu_DisplayOwnerTsv

on _
end _

on insert_Menu
   return "Global | Atopia | Tree | Menu"
end insert_Menu


--> Global | Atopia | Owner | Menu | Props
-
getprop cse_Names
   return cse_ListNames()
end cse_Names


--> Global | Atopia | Owner | Menu | Disabled
-
