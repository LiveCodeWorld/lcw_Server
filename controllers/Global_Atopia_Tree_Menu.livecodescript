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

on _
end _

on menu_LocalGoodFolders indexView
   set the cursor to watch
   put atopia_ListLocalGoodFolders() into domainNames
   put "atopia_ListLocalGoodFolders()" into stackLabel
   
   _SetDisplayDomainNames indexView, domainNames, "Local Good Folders", stackLabel
end menu_LocalGoodFolders

on menu_LocalBadFolders indexView
   put atopia_ListLocalBadFolders() into domainNames
   put "atopia_ListLocalBadFolders()" into stackLabel
   
   _SetDisplayDomainNames indexView, domainNames, "Local Bad Folders", stackLabel
end menu_LocalBadFolders

on menu_AllLocalWikiFolders indexView
   put atopia_ListLocalWikiFolders() into localWikiFolders
   put "atopia_ListLocalWikiFolders()" into stackLabel
   
   _SetDisplayDomainNames indexView, localWikiFolders, "All Local Wiki Folders", stackLabel
end menu_AllLocalWikiFolders

on _
end _

on menu_RemoteUnhostedFolders indexView
   put atopia_FetchAllFolderList ("_unhosted_sites") into domainNames
   put "_unhosted_sites" into stackLabel
   
   _SetDisplayDomainNames indexView, domainNames, "Remote Unhosted Sites", stackLabel
end menu_RemoteUnhostedFolders

on menu_RemoteTrash indexView
   put atopia_FetchAllFolderList ("_trash") into domainNames
   put "_trash" into stackLabel
   
   _SetDisplayDomainNames indexView, domainNames, "Remote Trash", stackLabel
end menu_RemoteTrash

on menu_RemoteOldSites indexView
   put atopia_FetchAllFolderList ("_old_sites") into domainNames
   put "_old_sites" into stackLabel
   
   _SetDisplayDomainNames indexView, domainNames, "Remote Old Sites", stackLabel
end menu_RemoteOldSites

on menu_RemoteWikiFolders indexView
   put atopia_FetchAllFolderList() into remoteWikiFolders
   put "atopia_FetchAllFolderList()" into stackLabel
   
   _SetDisplayDomainNames indexView, remoteWikiFolders, "Remote Wiki Folders", stackLabel
end menu_RemoteWikiFolders

on menu_ReservedFolders indexView
   put atopia_FetchReservedFoldersList() into domainNames
   put "atopia_FetchReservedFoldersList()" into stackLabel
   
   _SetDisplayDomainNames indexView, domainNames, "Reserved Folders", stackLabel
end menu_ReservedFolders

on _
end _

on menu_DisplayAtopiaArray
   display_AtopiaDomainErrorArray
end menu_DisplayAtopiaArray

on menu_DisplayAtopiaConfig
   put atopia_FetchConfigArray() into configArray
   display_Array configArray, "Atopia config.json"
end menu_DisplayAtopiaConfig

on menu_DisplayOwnershipArray indexView
   put atopia_GetDomainOwnershipArray() into domainOwnershipArray
   -- put dynadot_FetchIndexedDomainArray() into domainArray
   display_Array domainOwnershipArray, "atopia_ConstructDomainOwnershipArray()", "Global | Atopia | Tree | Menu"
end menu_DisplayOwnershipArray

on menu_DisplayAtopiaDropletInfo
   put digitalOcean_GetDropletArray ("Atopia") into dropletArray
   display_Array dropletArray
end menu_DisplayAtopiaDropletInfo

on _
end _

on menu_FindLocalGoodUnhosted indexView
   lcw_AnswerSheet "This is slow as we rotate through all local good folders and check they have A records for Atopia!"
   set the cursor to watch
   --
   put atopia_ListLocalGoodFolders() into localGoodFolders
   put atopia_CheckUnhosted (localGoodFolders) into dnsArray
   put the keys of dnsArray ["bad ip"] into domainNames
   put "atopia_CheckUnhosted()" into stackLabel
   
   _SetDisplayDomainNames indexView, domainNames, "Found Local Good Unhosted", stackLabel
end menu_FindLocalGoodUnhosted


--> Global | Atopia | Tree | Menu
-
on menu_ProcessNewFolders indexView
   lcw_AnswerSheet "Check if new folders are bad and trash, move to unhosted and update them?"
   --
   atopia_UpdateArrayAndMove
   put the result into resultArray
   --
   display_AtopiaUpdateResult resultArray, indexView
end menu_ProcessNewFolders

on _
end _

on submenu_Display
   return "Display | Menu"
end submenu_Display

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

on menu_BuildOwnershipArray indexView
   -- could just get the good and bad
   -- put atopia_ListLocalWikiFolders() into wikiFolders
   -- instead we get just the good ones
   lcw_AnswerSheet "Do you want to build an ownership array for all server side (good) wiki folders?"
   --
   -- put atopia_ListLocalGoodFolders() into wikiFolders
   put atopia_FetchAllFolderList() into wikiFolders
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
   display_AtopiaLocalWikiFolders
   display_AtopiaDomainErrorArray
end menu_BuildAtopiaDomainArray

on _
end _

on menu_Refresh indexView
   display_AtopiaLocalWikiFolders indexView
end menu_Refresh

on submenu_Dev
   return "Dev | Menu"
end submenu_Dev


--> Move | Menu
-
on menu_MoveBadFolders indexView
   put atopia_ListLocalBadFolders() into domainNames
   _SetDisplayDomainNames indexView, domainNames, "Bad Folders"   
   lcw_AnswerWarning "Move all these bad folders to the _trash folder?"
   --
   atopia_MoveAllBadFoldersToTrash indexView
   put the result into missingFolders
   put missingFolders
   --
   put atopia_ListLocalBadFolders() into domainNames
   _SetDisplayDomainNames indexView, domainNames, "Bad Folders"   
end menu_MoveBadFolders

on menu_MoveUnhostedBadFolders indexView
   put atopia_ListLocalBadFolders() into domainNames
   _SetDisplayDomainNames indexView, domainNames, "Bad Folders"   
   lcw_AnswerSheet "Move all unhosted folders to the _unhosted_sites folder?"
   --
   atopi_MoveGoodToUnhosted
   --
   put the result into domainErrorArray
   put the keys of domainErrorArray ["_unhosted_sites"] into domainNames
   
   _SetDisplayDomainNames indexView, domainNames, "Unhosted Folders"
end menu_MoveUnhostedBadFolders


--> Check | Menu
-
on menu_CheckLocalUnhosted indexView
   -- quick check
   put atopia_ListLocalUnhostedFolders() into unhostedFolders
   put atopia_FetchAllFolderList() into remoteWikiFolders
   repeat for each line unhostedFolder in unhostedFolders
      set the cursor to busy
      if unhostedFolder is among the lines of remoteWikiFolders then
         put unhostedFolder & CR after inGoodRemoteFolders
      end if
   end repeat
   delete char -1 of inGoodRemoteFolders
   
   _SetDisplayDomainNames indexView, inGoodRemoteFolders, "Remove from unhosted"
end menu_CheckLocalUnhosted

on menu_CheckGoodFolders indexView
   -- let's see if they have DNS settings
   
   put atopia_ListLocalGoodFolders() into goodFolders
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
   put atopia_ListLocalGoodFolders() into domainNames
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
   
   put atopia_ListLocalBadFolders() into domainNames
   _SetDisplayDomainNames indexView, domainNames, "Bad Folders"
end menu_CheckBadFolders

on menu_CheckFolders
   put atopia_MissingRemoteFolderArray() into notThereArray
   display_Array notThereArray
end menu_CheckFolders

on menu_TestFetchedSameAsLocal
   set the cursor to watch
   put atopia_FetchAllFolderList() into fetchedFolders
   put atopia_ListLocalWikiFolders() into localFolders
   --
   if localFolders = fetchedFolders then
      lcw_AnswerSheet "Good server folders are the same as local folders!"
   else
      display_Lines fetchedFolders, "Fetched,atopia_FetchAllFolderList()"
      display_Lines localFolders, "Local,atopia_ListLocalWikiFolders()"
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

-- private command _ColourGoodBad indexView
lock screen
put atopia_GetDomainErrorArray() into domainErrorArray
put domainErrorArray ["info"]["badNums"] into badNums
put domainErrorArray ["info"]["goodNums"] into goodNums

set the field_Align of indexView to "right"
set the line_Colour [badNums] of indexView to red
set the line_Colour [goodNums] of indexView to empty
unlock screen
end _ColourGoodBad
