script "Global_Atopia_Check_Menu"
--> MetaData
-
license: GPLv3
name: Global_Atopia_Check_Menu
type: controller
version: 0.1


--> Global | Atopia | Check | Menu
-
on menu_FindLocalGoodUnhosted indexView
   lcw_AnswerSheet "This is slow as we rotate through all local good folders and check they have A records for Atopia!"
   set the cursor to watch
   --
   put atopia_ListLocalGoodFolders() into localGoodFolders
   put atopia_CheckUnhosted (localGoodFolders) into dnsArray
   put the keys of dnsArray ["bad ip"] into domainNames
   --
   atopia_SetDisplay indexView, domainNames, "Found Local Good Unhosted", "atopia_CheckUnhosted()"
end menu_FindLocalGoodUnhosted

on menu_CheckWithoutOwners indexView
   put "Check each local folder (good or bad) and see if they are in atopia_GetOwnershipArray()?" into someQuestion
   dispatch "lcw_AnswerSheet" to indexView with someQuestion
   --
   put atopia_GetOwnershipArray() into ownershipArray
   --
   put atopia_FetchAllFolderList() into remoteWikiFolders
   repeat for each line remoteWikiFolder in remoteWikiFolders
      set the cursor to busy
      put ownershipArray [remoteWikiFolder] into ownerArray
      if ownerArray is not an array then
         put remoteWikiFolder & CR after unownedFolders
      end if
   end repeat
   delete char -1 of unownedFolders
   
   if unownedFolders is not empty then
      atopia_SetDisplay indexView, unownedFolders, "Unowned Folders"
      put "These remote good folders have NOT been entered in ownershipArray! Do you want to rebuild the ownershipArray?" into someQuestion
      dispatch "lcw_AnswerSheet" to indexView with someQuestion
      --
      breakpoint
      menu_BuildOwnershipArray indexView
   else
      put "Remote good folders have all been entered in ownershipArray!" into someQuestion
      dispatch "lcw_AnswerSheet" to indexView with someQuestion
   end if
end menu_CheckWithoutOwners

on menu_CheckLocalBad indexView
   put "Check each local bad folder and fix depending on if it is remote bad or good folder?" into someQuestion
   dispatch "lcw_AnswerSheet" to indexView with someQuestion
   --
   put atopia_ListLocalBadFolders() into localBadFolders
   put atopia_GetData() into atopiaData
   repeat for each line localBadFolder in localBadFolders
      set the cursor to busy
      if atopia_TrashFolderExists (localBadFolder) then
         -- let's just remove it from bad
         -- atopia_RemoveLocalBad badDomainName
         delete variable atopiaData ["bad"][localBadFolder]
      else
         put atopia_RemoteWikiFolderExists (localBadFolder) into isGoodFolder
         if isGoodFolder then
            -- for some reason it exists on remote server as a good folder
            breakpoint
            atopia_AddToDomainErrorArray atopiaData, localBadFolder
         else
            -- could be somewhere else as its not in good or bad remote
            breakpoint
         end if
      end if
   end repeat
   atopia_SetData atopiaData
   delete char -1 of inGoodRemoteFolders
   
   menu_LocalBadFolders indexView
end menu_CheckLocalBad

on menu_CheckLocalUnhosted indexView
   put "Check each local unhosted folder and check there is a corresponding good remote folder?" into someQuestion
   dispatch "lcw_AnswerSheet" to indexView with someQuestion
   --
   put atopia_ListLocalUnhostedFolders() into unhostedFolders
   put atopia_FetchAllFolderList() into remoteWikiFolders
   repeat for each line unhostedFolder in unhostedFolders
      set the cursor to busy
      if unhostedFolder is among the lines of remoteWikiFolders then
         put unhostedFolder & CR after inGoodRemoteFolders
      end if
   end repeat
   delete char -1 of inGoodRemoteFolders
   
   atopia_SetDisplay indexView, inGoodRemoteFolders, "Remove from unhosted"
end menu_CheckLocalUnhosted

on menu_CheckGoodFolders indexView
   put "Check to see if local good folders have DNS settings?" into someQuestion
   dispatch "lcw_AnswerSheet" to indexView with someQuestion
   --
   put atopia_ListLocalGoodFolders() into goodFolders
   --
   put atopia_GetData() into atopiaData
   repeat for each line goodShortFolder in goodFolders
      put dig_GetIP (goodShortFolder) into testIP
      if testIP is empty then
         -- put dig_GetNS (goodShortFolder) into nsInfo
         put atopiaData ["good"][goodShortFolder] into goodPageIndex
         put goodPageIndex into atopiaData ["no ip"][goodShortFolder] 
         delete variable atopiaData ["good"][goodShortFolder]
      else
         -- it's good
         put testIP into atopiaData ["dns"][goodShortFolder]["A record"]
      end if
   end repeat 
   display_Array atopiaData
end menu_CheckGoodFolders

on menu_CheckLocalBadFolders indexView
   put "Check missing Local Bad folders to see if they are in the atopiaData?" into someQuestion
   dispatch "lcw_AnswerSheet" to indexView with someQuestion
   --
   put atopia_MissingRemoteFolderArray() into notThereArray
   put notThereArray ["Local Bad folder missing"] into badMissingIndex
   if badMissingIndex is empty then
      lcw_WarnAndExit "There are no bad missing folders!"
   end if
   
   breakpoint
   put atopia_GetData() into atopiaData
   repeat for each line badMissingfolder in badMissingIndex
      put atopiaData ["bad"][badMissingfolder] into probablyEmptyArray
      put atopiaData ["_trash"][badMissingfolder] into trashEmptyArray
      --
      put probablyEmptyArray into atopiaData ["_trash"][badMissingfolder]
      delete variable atopiaData ["bad"][badMissingfolder]
   end repeat
   breakpoint
   atopia_SetData atopiaData
   
   put atopia_ListLocalBadFolders() into domainNames
   atopia_SetDisplay indexView, domainNames, "Bad Folders"
end menu_CheckLocalBadFolders

on menu_TestFetchedSameAsLocal
   put "Check atopia_ListLocalWikiFolders() = atopia_FetchAllFolderList() ?" into someQuestion
   dispatch "lcw_AnswerSheet" to indexView with someQuestion
   --
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


--> Global | Atopia | Check | Menu | Props
-

--> Global | Atopia | Check | Menu | Disabled
-
