script "Global_Atopia_Tree_Menu"
--> MetaData
-
license: GPLv3
name: Global_Atopia_Tree_Menu
type: controller
version: 0.3


--> Display | Events
-
command mDoubleUp_AtopiaFolder indexView, wikiDomain
   if the optionKey is "down" then breakpoint
   
   display_AtopiaWikiPages wikiDomain
end mDoubleUp_AtopiaFolder


--> Display | Menu
-
on menu_NewFolders indexView
   put atopia_FetchNewFolderList() into domainNames
   put "atopia_FetchNewFolderList()" into stackLabel
   
   _SetDisplayDomainNames indexView, domainNames, "New Folders", stackLabel
end menu_NewFolders indexView

on menu_GoodFolders indexView
   set the cursor to watch
   put atopia_ListGoodFolders() into domainNames
   put "atopia_ListGoodFolders()" into stackLabel
   
   _SetDisplayDomainNames indexView, domainNames, "Good Folders", stackLabel
end menu_GoodFolders

on menu_BadFolders indexView
   put atopia_ListBadFolders() into domainNames
   put "atopia_ListBadFolders()" into stackLabel
   
   _SetDisplayDomainNames indexView, domainNames, "Bad Folders", stackLabel
end menu_BadFolders

on _
end _

on menu_FindGoodUnhosted indexView
   set the cursor to watch
   --
   put atopia_ListGoodFolders() into goodFolders
   put atopia_CheckUnhosted (goodFolders) into dnsArray
   put the keys of dnsArray ["bad ip"] into domainNames
   put "atopia_CheckUnhosted()" into stackLabel
   
   _SetDisplayDomainNames indexView, domainNames, "Find Good Unhosted", stackLabel
end menu_FindGoodUnhosted

on menu_RemoteUnhostedFolders indexView
   put atopia_FetchAllFolderList ("_unhosted_sites") into domainNames
   put "_unhosted_sites" into stackLabel
   
   _SetDisplayDomainNames indexView, domainNames, "Unhosted Sites", stackLabel
end menu_RemoteUnhostedFolders

on menu_Trash indexView
   put atopia_FetchAllFolderList ("_trash") into domainNames
   put "_trash" into stackLabel
   
   _SetDisplayDomainNames indexView, domainNames, "Trash", stackLabel
end menu_Trash

on menu_OldSites indexView
   put atopia_FetchAllFolderList ("_old_sites") into domainNames
   put "_old_sites" into stackLabel
   
   _SetDisplayDomainNames indexView, domainNames, "Old Sites", stackLabel
end menu_OldSites

on _
end _

on menu_LocalDomains indexView
   put atopia_ListDomainFolders() into domainNames
   put "atopia_ListDomainFolders()" into stackLabel
   
   _SetDisplayDomainNames indexView, domainNames, "Local Domains", stackLabel
end menu_LocalDomains

on menu_RemoteDomains indexView
   put atopia_FetchAllFolderList() into domainNames
   put "atopia_FetchAllFolderList()" into stackLabel
   
   _SetDisplayDomainNames indexView, domainNames, "Remote Domains", stackLabel
end menu_RemoteDomains

on menu_ReservedFolders indexView
   put atopia_FetchReservedFoldersList() into domainNames
   put "atopia_FetchReservedFoldersList()" into stackLabel
   
   _SetDisplayDomainNames indexView, domainNames, "Reserved Folders", stackLabel
end menu_ReservedFolders

on _
end _

on menu_AtopiaConfig
   put atopia_FetchConfigArray() into configArray
   display_Array configArray, "Atopia config.json"
end menu_AtopiaConfig

on menu_AtopiaInfo
   put digitalOcean_GetDropletArray ("Atopia") into dropletArray
   display_Array dropletArray
end menu_AtopiaInfo

on menu_DisplayErrorArray
   display_AtopiaDomainErrorArray
end menu_DisplayErrorArray


--> Global | Atopia | Tree | Menu
-
on submenu_Display
   return "Display | Menu"
end submenu_Display

on _
end _

on menu_ProcessNewFolders indexView
   lcw_AnswerSheet "Check if new folders are bad?"
   --
   atopia_UpdateDomainErrorArray
   put atopia_FetchNewFolderList() into domainNames
   --
   lock screen
   set the atopia_ColouredLines of indexView to domainNames
   set the label of the stack_Object of indexView to "atopia_FetchNewFolderList()"
   set the title_Text of indexView to "New Folders"
   unlock screen
end menu_ProcessNewFolders

on submenu_Move
   return "Move | Menu"
end submenu_Move

on submenu_Check
   return "Check | Menu"
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

on menu_UpdateDomainErrorArray indexView
   put the selected_Line of indexView into wikiDomain
   atopia_UpdateDomainErrorArray wikiDomain
   put atopia_FetchNewFolderList() into domainNames
   _SetDisplayDomainNames indexView, domainNames, "New Folders"
end menu_UpdateDomainErrorArray

on menu_BuildOwnershipArray indexView
   -- could just get the good and bad
   -- put atopia_ListDomainFolders() into wikiFolders
   -- instead we get just the good ones
   put atopia_ListGoodFolders() into wikiFolders
   put atopia_ConstructDomainOwnershipArray (wikiFolders) into domainOwnershipArray
   --
   atopia_SetDomainOwnershipArray domainOwnershipArray
   put the result into modelDataFile
   lcw_AnswerSheet "Built and saved ownership array!"
   --
   put atopia_GetDomainOwnershipArray() into domainOwnershipArray
   display_Array domainOwnershipArray, "atopia_ConstructDomainOwnershipArray()", "Global | Atopia | Tree | Menu"
end menu_BuildOwnershipArray

on menu_BuildAtopiaDomainArray
   lcw_AnswerSheet "This is very slow! Update instead?"
   --
   put atopia_FetchAndBuildArray() into pDomainErrorArray
   atopia_SetDomainErrorArray pDomainErrorArray   
   --
   display_AtopiaDomainFolders
   display_AtopiaDomainErrorArray
end menu_BuildAtopiaDomainArray

on _
end _

on menu_Refresh indexView
   display_AtopiaDomainFolders indexView
end menu_Refresh

on submenu_Dev
   return "Dev | Menu"
end submenu_Dev


--> Move | Menu
-
on menu_MoveUnhostedFolders indexView
   put atopia_ListBadFolders() into domainNames
   _SetDisplayDomainNames indexView, domainNames, "Bad Folders"   
   lcw_AnswerSheet "Move all unhosted folders to the _unhosted_sites folder?"
   --
   atopi_MoveGoodToUnhosted
   --
   put the result into domainErrorArray
   put the keys of domainErrorArray ["_unhosted_sites"] into domainNames
   
   _SetDisplayDomainNames indexView, domainNames, "Unhosted Folders"
end menu_MoveUnhostedFolders

on menu_MoveBadFolders indexVi
   put atopia_ListBadFolders() into domainNames
   _SetDisplayDomainNames indexView, domainNames, "Bad Folders"   
   lcw_AnswerWarning "Move all these bad folders to the _trash folder?"
   --
   atopia_MoveAllBadFoldersToTrash indexView
   put the result into missingFolderNames
   put missingFolderNames
   --
   put atopia_ListBadFolders() into domainNames
   _SetDisplayDomainNames indexView, domainNames, "Bad Folders"   
end menu_MoveBadFolders


--> Check | Menu
-
on menu_CheckGoodFolders indexView
   -- let's see if they have DNS settings
   
   put atopia_ListGoodFolders() into goodFolders
   --
   put atopia_GetDomainErrorArray() into domainErrorArray
   repeat for each line goodShortFolder in goodFolders
      put dig_GetIP (goodShortFolder) into testIP
      if testIP is empty then
         -- put dig_GetNS (goodShortFolder) into nsInfo
         put domainErrorArray ["good"][goodShortFolder] into goodPageIndex
         put goodPageIndex into domainErrorArray ["no ip"][goodShortFolder] 
         delete variable domainErrorArray ["good"][goodShortFolder]
      else
         -- it's good
         put testIP into domainErrorArray ["dns"][goodShortFolder]["A record"]
      end if
   end repeat 
   /*
   atopia_SetDomainErrorArray domainErrorArray
   --
   put atopia_ListGoodFolders() into domainNames
   _SetDisplayDomainNames indexView, domainNames, "Good Folders"
   */
   
   display_Array domainErrorArray
end menu_CheckGoodFolders

on menu_CheckBadFolders indexView
   put atopia_MissingRemoteFolderArray() into notThereArray
   put notThereArray ["Local Bad folder missing"] into badMissingIndex
   if badMissingIndex is empty then
      lcw_WarnAndExit "There are no bad missing folders!"
   end if
   
   breakpoint
   put atopia_GetDomainErrorArray() into domainErrorArray
   repeat for each line badMissingfolder in badMissingIndex
      put domainErrorArray ["bad"][badMissingfolder] into probablyEmptyArray
      put domainErrorArray ["_trash"][badMissingfolder] into trashEmptyArray
      --
      put probablyEmptyArray into domainErrorArray ["_trash"][badMissingfolder]
      delete variable domainErrorArray ["bad"][badMissingfolder]
   end repeat
   breakpoint
   atopia_SetDomainErrorArray domainErrorArray
   
   put atopia_ListBadFolders() into domainNames
   _SetDisplayDomainNames indexView, domainNames, "Bad Folders"
end menu_CheckBadFolders

on menu_CheckFolders
   put atopia_MissingRemoteFolderArray() into notThereArray
   display_Array notThereArray
end menu_CheckFolders

on menu_TestFetchedSameAsLocal
   set the cursor to watch
   put atopia_FetchAllFolderList() into fetchedFolders
   put atopia_ListDomainFolders() into localFolders
   --
   if localFolders = fetchedFolders then
      lcw_AnswerSheet "Good server folders are the same as local folders!"
   else
      display_Lines fetchedFolders, "Fetched,atopia_FetchAllFolderList()"
      display_Lines localFolders, "Local,atopia_ListDomainFolders()"
      lcw_AnswerSheet "Good server folders are different from local folders!"
   end if
end menu_TestFetchedSameAsLocal


--> Dev | Menu
-
on menu_DomainLsArray indexView
   put atopia_FetchFilteredFolderLsArray() into wikiFolderArray
   display_Array wikiFolderArray
end menu_DomainLsArray

on menu_DisplayMyDomains indexView
   put "david.bovill@gmail.com" into userEmail
   put atopia_GetDomainOwnershipArray() into domainOwnershipArray
   put domainOwnershipArray [userEmail]["domains"] into domainArray
   
   repeat for each key indexNum in domainArray
      put domainArray [indexNum]["domain"] into domainName
      put domainName & CR after domainNames
   end repeat
   delete char -1 of domainNames
   
   put domainNames
end menu_DisplayMyDomains

on _
end _

on menu_StoreOwnershipArray indexView
   put the displayed_Data of indexView into domainOwnershipArray
   if domainOwnershipArray is not an array then
      breakpoint
      lcw_WarnAndExit "Not an array!"
   end if
   lcw_AnswerSheet "Are you sure you want to store this ownership array?"
   
   atopia_SetDomainOwnershipArray domainOwnershipArray
   put the result into modelDataFile
   lcw_AnswerSheet "Saved ownership array!"
end menu_StoreOwnershipArray

on menu_DisplayOwnershipArray indexView
   put atopia_GetDomainOwnershipArray() into domainOwnershipArray
   -- put the displayed_Data of indexView into domainOwnershipArray
   -- put dynadot_FetchIndexedDomainArray() into domainArray
   --
   display_Array domainOwnershipArray, "atopia_ConstructDomainOwnershipArray()", "Global | Atopia | Tree | Menu"
end menu_DisplayOwnershipArray


--> Global | Atopia | Tree | Menu | Props
-

--> Global | Atopia | Tree | Menu | Disabled
-

--> Private
-
private command _SetDisplayDomainNames indexView, domainNames, whichFolders, stackLabel
   lock screen
   set the label of the stack_Object of indexView to stackLabel
   set the atopia_ColouredLines of indexView to domainNames
   set the title_Text of indexView to whichFolders
   unlock screen
end _SetDisplayDomainNames
