script "Global_Atopia_Tree_Dev_Menu"
--> MetaData
-
license: GPLv3
name: Global_Atopia_Tree_Dev_Menu
type: controller
version: 0.1


--> Menu | Props
-


--> Global | Atopia | Tree | Dev | Menu
-
on menu_ProcessNewFolders indexView
   -- use "menu_CheckDisplayedFolders" instead
   lcw_AnswerSheet "Check if new folders are bad and trash, move to unhosted and update them?"
   --
   atopia_UpdateArrayAndMove
   put the result into resultArray
   --
   display_AtopiaUpdateResult resultArray, indexView
end menu_ProcessNewFolders

on submenu_Check
   return "Global | Atopia | Check | Menu"
end submenu_Check

on _
end _

on submenu_Atopia
   return "Global | Server | Menu"
end submenu_Atopia

on submenu_Dynadot
   return "Global | Dynadot | Menu"
end submenu_Dynadot

on _
end _

on menu_MoveBadFolders indexView
   put atopia_ListLocalBadFolders() into domainNames
   atopia_SetDisplay indexView, domainNames, "Bad Folders"   
   lcw_AnswerWarning "Move all these bad folders to the _trash folder?"
   --
   atopia_MoveAllBadFoldersToTrash indexView
   put the result into missingFolders
   put missingFolders
   --
   put atopia_ListLocalBadFolders() into domainNames
   atopia_SetDisplay indexView, domainNames, "Bad Folders"   
end menu_MoveBadFolders

on menu_MoveUnhostedBadFolders indexView
   put atopia_ListLocalBadFolders() into domainNames
   atopia_SetDisplay indexView, domainNames, "Bad Folders"   
   lcw_AnswerSheet "Move all unhosted folders to the _unhosted_sites folder?"
   --
   atopi_MoveGoodToUnhosted
   --
   put the result into atopiaData
   put the keys of atopiaData ["_unhosted_sites"] into domainNames
   
   atopia_SetDisplay indexView, domainNames, "Unhosted Folders"
end menu_MoveUnhostedBadFolders

on menu_DomainLsArray indexView
   put atopia_FetchFilteredFolderLsArray() into wikiFolderArray
   display_Array wikiFolderArray
end menu_DomainLsArray

on menu_DisplayMyDomains indexView
   put "david.bovill@gmail.com" into userEmail
   
   put atopia_GetDomainsFromEmail (userEmail)
end menu_DisplayMyDomains


--> Global | Atopia | Tree | Dev | Menu | Disabled
-
