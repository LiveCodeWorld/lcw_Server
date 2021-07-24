script "Global | Atopia | Check | Menu"
--> MetaData
-


--> Global | Atopia | Check | Menu
-
on menu_CheckSitesAreReachable indexView
   put atopia_ListFederationSitePages() into allSites
   set the displayed_Index ["Good Site Pages"] of indexView to allSites
   --
   lcw_Answer "Test each of these sites listed on 'sites.fedwiki.org' and check that they are reachable?", indexView
   --
   repeat for each line wikiDomain in allSites
      display_Spin wikiDomain, indexView
      put the result into lineNum
      --
      set the cursor to watch
      set the socketTimeoutInterval to 100
      if fedwiki_WikiExists (wikiDomain) then
         set the line_Colour [lineNum] of indexView to "green"
      else
         set the deleted_Line of indexView to lineNum
         atopia_DeleteFederationSitePage wikiDomain
      end if
   end repeat   
end menu_CheckSitesAreReachable

on menu_CheckAtopiaFedrayRoster indexView
   put atopia_FetchRosterDomains() into atopiaRosterDomains
   set the displayed_Index ["Atopia Roster"] of indexView to atopiaRosterDomains
   --
   put atopia_ListDomainsFromFedray() into atopiaFedrayDomains
   --
   if word 1 to -1 of atopiaRosterDomains = word 1 to -1 of atopiaFedrayDomains then
      lcw_Answer "The atopia domain index is the same for both the Atopia Fedray and roster", indexView
   else
      set the wholematches to true
      repeat with rLineNum = the number of lines of atopiaRosterDomains down to 1
         put line rLineNum of atopiaRosterDomains into rosterLine
         put lineOffset (rosterLine, atopiaFedrayDomains ) into fLineNum
         if fLineNum is not 0 then
            delete line rLineNum of atopiaRosterDomains 
            delete line fLineNum of atopiaFedrayDomains 
         end if
      end repeat
      --
      display_AtopiaRoster atopiaRosterDomains, "Atopia Index"
      display_AtopiaRoster atopiaFedrayDomains, "Fedray"
      --
      lcw_AnswerWarning "The atopia domain index is different for the Atopia Fedray and Roster!", indexView
   end if
end menu_CheckAtopiaFedrayRoster

on _
end _

on menu_DisplayMissingSitePages indexView
   put atopia_ListSitePagesToCreate() into sitesToCreate
   set the displayed_Index ["Missing Site Pages"] of indexView to sitesToCreate
end menu_DisplayMissingSitePages

on menu_CreateMissingSitePages indexView
   put atopia_ListSitePagesToCreate() into sitesToCreate
   set the displayed_Index ["Missing Site Pages"] of indexView to sitesToCreate
   --
   lcw_Answer "Create a new site page for each of these missing pages?"
   --
   atopia_CreateFederationSitePages sitesToCreate, indexView
   --
   put atopia_ListSitePagesToCreate() into sitesToCreate
   set the displayed_Index ["Missing Site Pages"] of indexView to sitesToCreate
end menu_CreateMissingSitePages

on _
end _

on menu_CheckThisWeeks displayView
   put federation_FetchRecentSites ("1 week", true)  into thisWeeksModifiedSites
   put fedray_FetchRecentSites() into fedraySites
   --
   if fedraySites = thisWeeksModifiedSites is false then
      display_Data thisWeeksModifiedSites, "federation_ThisWeeksModifiedSites (true)", "Federation"
      display_Data fedraySites, "fedray_FetchRecentSites (true)", "Federation"
   else
      lcw_Answer "Same", displayView
   end if
end menu_CheckThisWeeks


--> Dev | Local | Menu
-
on menu_FindLocalGoodUnhosted indexView
   lcw_Answer "This is slow as we rotate through all local good folders and check they have A records for Atopia!", indexView
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
   lcw_Answer someQuestion, indexView
   --
   put atopia_GetOwnershipArray() into ownershipArray
   --
   put atopia_FetchFolders() into remoteWikiFolders
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
      lcw_Answer someQuestion, indexView
      --
      breakpoint
      menu_BuildOwnershipArray indexView
   else
      put "Remote good folders have all been entered in ownershipArray!" into someQuestion
      lcw_Answer someQuestion, indexView
   end if
end menu_CheckWithoutOwners

on menu_CheckLocalBad indexView
   put "Check each local bad folder and fix depending on if it is remote bad or good folder?" into someQuestion
   lcw_Answer someQuestion, indexView
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
   lcw_Answer someQuestion, indexView
   --
   put atopia_ListLocalUnhostedFolders() into unhostedFolders
   put atopia_FetchFolders() into remoteWikiFolders
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
   lcw_Answer someQuestion, indexView
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
   lcw_Answer someQuestion, indexView
   --
   put atopia_MissingRemoteFolderArray() into notThereArray
   put notThereArray ["Local Bad folder missing"] into badMissingIndex
   if badMissingIndex is empty then
      lcw_AnswerWarning "There are no bad missing folders!", indexView
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

on menu_TestFetchedSameAsLocal indexView
   put "Check atopia_ListLocalWikiFolders() = atopia_FetchFolders() ?" into someQuestion
   lcw_Answer someQuestion, indexView
   --
   set the cursor to watch
   put atopia_FetchFolders() into fetchedFolders
   put atopia_ListLocalWikiFolders() into localFolders
   --
   if localFolders = fetchedFolders then
      lcw_Answer "Good server folders are the same as local folders!", indexView
   else
      display_Lines fetchedFolders, "Fetched,atopia_FetchFolders()"
      display_Lines localFolders, "Local,atopia_ListLocalWikiFolders()"
      lcw_Answer "Good server folders are different from local folders!", indexView
   end if
end menu_TestFetchedSameAsLocal


--> Global | Atopia | Check | Menu | Props
-

--> Global | Atopia | Check | Menu | Disabled
-
