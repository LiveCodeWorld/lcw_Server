script "lib_Atopia"
--> MetaData
-
license: GPLv3
name: lib_Atopia
type: library
version: 0.3

/*
This library is for processing and interfacing with wiki folders on the Atopia server.
*/


--> Working on
-
command atopia_UpdateArrayAndMove pWikiFolders
   -- this should step through all tests and update everything
   -- moving folders to trash or unhosted as needed
   
   -- defaults to prcessing new folders
   if pWikiFolders is empty then
      put atopia_FetchNewFolderList() into pWikiFolders
   end if
   put atopia_GetDomainErrorArray() into domainErrorArray
   
   -- let's update bad ones
   -- first check how many wiki pages each domain has
   -- then update local good/bad domainErrorArray
   atopia_AddToDomainErrorArray domainErrorArray, pWikiFolders
   put the result into addedBadFolders
   -- finally move bad ones we added to trash
   atopia_MoveAllBadFoldersToTrash addedBadFolders
   put the result into missingFolders
   if missingFolders is not empty then
      breakpoint
      -- it should not be
      put missingFolders into resultArray ["missingFolders"]
   end if
   put addedBadFolders into resultArray ["addedBadFolders"]
   -- now store the updated with the new bad/good value
   atopia_SetDomainErrorArray domainErrorArray
   
   -- now let's check that the good folders left are hosted
   put pWikiFolders into newGoodFoldersleft
   line_DeleteIndex newGoodFoldersleft, addedBadFolders
   if newGoodFoldersleft is empty then return resultArray
   
   -- now let's move those unhosted folders
   atopi_MoveGoodToUnhosted newGoodFoldersleft
   put the result into movedToUnhosted
   -- atopi_MoveGoodToUnhosted also does atopia_SetDomainErrorArray
   put movedToUnhosted into resultArray ["movedToUnhosted"]
   
   -- perhaps removed a few more
   line_DeleteIndex newGoodFoldersleft, movedToUnhosted
   if newGoodFoldersleft is empty then return resultArray
   
   -- now update the domainOwnershipArray for the hosted good folders
   put atopia_ConstructDomainOwnershipArray (newGoodFoldersleft) into domainOwnershipArray
   atopia_SetDomainOwnershipArray domainOwnershipArray
   put newGoodFoldersleft into resultArray ["newGoodFoldersAdded"]
   
   return resultArray
end atopia_UpdateArrayAndMove


--> Atopia | Model | Build
-
command atopia_AddToDomainErrorArray @domainErrorArray, wikiFolders, pMinNum
   if pMinNum is empty then put 1 into pMinNum
   
   repeat for each line wikiFolder in wikiFolders
      set the cursor to busy
      if wikiFolder is among the items of ReservedFolderNames then next repeat
      --
      put atopia_FetchWikiPageList (wikiFolder) into wikiPages
      if the number of lines of wikiPages > pMinNum then
         put wikiPages into domainErrorArray ["good"][wikiFolder]
      else
         put wikiPages into domainErrorArray ["bad"][wikiFolder]
         put wikiFolder & CR after addedBadFolders
      end if
      add 1 to lineNum
   end repeat
   delete char -1 of addedBadFolders
   
   -- not needed now?
   put atopia_ConstructGoodBadNumArray (domainErrorArray, pMinNum) into domainInfoArray
   put domainInfoArray into domainErrorArray ["info"]
   return addedBadFolders
end atopia_AddToDomainErrorArray

function atopia_FetchAndBuildArray pMinNum, pWikiFolders
   -- really, really slow (consider using cli "tree" thing)
   
   if pMinNum is empty then put 1 into pMinNum
   if pWikiFolders is empty then
      put atopia_FetchAllFolderList() into pWikiFolders
   end if
   
   put 1 into lineNum
   repeat for each line wikiFolder in pWikiFolders
      set the cursor to busy
      if wikiFolder is among the items of ReservedFolderNames then next repeat
      put wikiFolder
      --
      put atopia_FetchWikiPageList (wikiFolder) into wikiPages
      if the number of lines of wikiPages > pMinNum then
         put wikiPages into domainErrorArray ["good"][wikiFolder]
      else
         put wikiPages into domainErrorArray ["bad"][wikiFolder]
      end if
      add 1 to lineNum
   end repeat
   
   -- not deeded?
   put atopia_ConstructGoodBadNumArray (domainErrorArray, pMinNum) into domainInfoArray
   put domainInfoArray into domainErrorArray ["info"]
     
   return domainErrorArray
end atopia_FetchAndBuildArray


--> Atopia | Model | Construct
-
function atopia_ConstructDomainOwnershipArray wikiFolders, pDomainOwnershipArray
   local indexedArray, domainOwnershipArray
   
   if pDomainOwnershipArray is not an array then
      put atopia_GetDomainOwnershipArray() into pDomainOwnershipArray
   end if
   
   repeat for each line wikiFolder in wikiFolders
      set the cursor to busy
      --
      put atopia_FindOwnerArray (wikiFolder, pConfigArray) into ownerArray
      --
      put fedwiki_GetOwnerEmail (ownerArray) into ownerEmail
      if ownerEmail is empty then
         put "No email" into ownerEmail
      end if
      
      put pDomainOwnershipArray [ownerEmail]["domains"] into indexedArray
      --
      array_AddToNumbered indexedArray, "domain", wikiFolder
      put the result into newIndexNum
      put ownerArray into indexedArray [newIndexNum]["ownerArray"]
      --
      put indexedArray into pDomainOwnershipArray [ownerEmail]["domains"]
   end repeat
   return pDomainOwnershipArray
end atopia_ConstructDomainOwnershipArray


--> Atopia | Check
-
function atopia_DomainIsBad folderName, domainErrorArray
   put domainErrorArray ["good"] into goodArray
   put domainErrorArray ["bad"] into badArray
   
   set the caseSensitive to true
   put folderName is among the keys of badArray into isBad
   put folderName is among the keys of goodArray into isGood
   
   if isGood and isbad is true then
      breakpoint -- shoud be one or the other
      return false
   else if isGood is true then
      return false
   else if isBad is true then
      return true
   end if
end atopia_DomainIsBad

function atopia_RemoteWikiFolderExists folderName, pRemoteFolderArray
   if pRemoteFolderArray is empty then
      put atopia_FetchFilteredFolderLsArray() into pRemoteFolderArray
   end if
   
   put folderName is among the keys of pRemoteFolderArray into remoteExists
   return remoteExists
end atopia_RemoteWikiFolderExists

function atopia_CheckUnhosted goodFolders
   -- This is slow
   -- We rotate through all goodFolders and check they have A records for Atopia
   
   put atopia_GetIP() into dropletIP
   repeat for each line goodShortFolder in goodFolders
      set the cursor to busy
      put goodShortFolder
      --
      put dig_GetIP (goodShortFolder) into testIP
      put dig_GetNS (goodShortFolder) into testDNS
      --
      if testIP = dropletIP then
         -- it's good
         put testDNS into dnsArray ["good ip"][goodShortFolder]["NS"]
         put testIP into dnsArray ["good ip"][goodShortFolder]["A record"]
      else
         put testDNS into dnsArray ["bad ip"][goodShortFolder]["NS"]
         put testIP into dnsArray ["bad ip"][goodShortFolder]["A record"]
      end if
   end repeat
   return dnsArray
end atopia_CheckUnhosted


--> Display | Events
-
on mDoubleUp_AtopiaWikiFiles indexView, pageSlug
   if the optionKey is "down" then breakpoint
   --
   put the title_Text of indexView into wikiDomain
   --
   put fedwiki_PageUrl (wikiDomain, pageSlug) into pageURL
   launch url pageURL
   
   put atopia_FindOwnerArray (wikiDomain) into ownerArray
   display_AtopiaOwnerArray ownerArray, wikiDomain
end mDoubleUp_AtopiaWikiFiles

command mDoubleUp_AtopiaFolder indexView, wikiDomain
   if the optionKey is "down" then breakpoint
   
   display_AtopiaWikiPages wikiDomain
end mDoubleUp_AtopiaFolder



--> Display
-
command display_AtopiaLocalWikiFolders pIndexView
   -- put atopia_FetchAllFolderList() into wikiFolders
   put atopia_ListLocalWikiFolders() into wikiFolders
   
   if exists (pIndexView) then
      set the displayed_Index of pIndexView to wikiFolders
   else
      display_Lines wikiFolders, "Atopia Wiki Folders,atopia_FetchAllFolderList()", "mDoubleUp_AtopiaFolder"
      put the result into pIndexView
      set the title_Menu of pIndexView to "Global | Atopia | Tree | Menu"
      set the line_Menu of pIndexView to "Global | Atopia | Line | Menu"
   end if
   
   set the atopia_ColouredLines of pIndexView to wikiFolders
   return pIndexView
end display_AtopiaLocalWikiFolders

command display_AtopiaWikiPages wikiDomain
   set the cursor to watch
   put atopia_FetchWikiPageList (wikiDomain) into wikiPages
   
   put wikiDomain & comma & "atopia_FetchWikiPageList()" into displayTitle
   display_Lines wikiPages, displayTitle, "mDoubleUp_AtopiaWikiFiles"
   put the result into displayView
   --
   set the title_Menu of displayView to "Global | Atopia | Tree | Menu"
   set the line_Menu of displayView to "Global | Atopia | Line | Menu"
   --
   return displayView
end display_AtopiaWikiPages

command display_AtopiaDomainErrorArray
   put atopia_GetDomainErrorArray() into domainErrorArray
   --
   display_Array domainErrorArray, "Domain Error Array,atopia_GetDomainErrorArray()"
end display_AtopiaDomainErrorArray

command display_AtopiaOwnerArray ownerArray, wikiDomain
   display_Array ownerArray, (wikiDomain & ",atopia_FindOwnerArray()")
   put fedwiki_GetOwnerEmail (ownerArray)
end display_AtopiaOwnerArray


--> Props
-
setprop atopia_ColouredLines allFolderNames
   -- this will set a domain list fo an index_View
   -- and check and colour any domains red that are marked bad in the local domainErrorArray
   
   put atopia_GetDomainErrorArray() into domainErrorArray
   url_SortDomainIndex allFolderNames, true
   --
   repeat with lineNum = 1 to the number of lines of allFolderNames
      put line lineNum of allFolderNames into folderName
      if atopia_DomainIsBad (folderName, domainErrorArray) is true then
         put empty into colourArray ["red"][lineNum]
         put lineNum & comma after badNums
      else
         put empty into colourArray ["none"][lineNum]
         put lineNum & comma after goodNums
      end if
   end repeat
   delete char -1 of goodNums
   delete char -1 of badNums
   --
   lock screen
   set the field_Align of the target to "right"
   set the view_Index of the target to allFolderNames
   set the line_Colours of the target to colourArray
   unlock screen
end atopia_ColouredLines


--> Atopia | Model | Move
-
command atopia_MoveAllBadFoldersToTrash pBadFolders
   if pBadFolders is empty then
      put atopia_ListLocalBadFolders() into pBadFolders
   end if
   --
   put atopia_FetchFilteredFolderLsArray() into remoteFolderArray
   repeat for each line badFolderName in pBadFolders
      set the cursor to busy
      put badFolderName
      if atopia_RemoteWikiFolderExists (badFolderName, remoteFolderArray) is false then
         breakpoint
         put badFolderName & CR after missingFolders
         next repeat
      end if
      --
      atopia_MoveToTrash badFolderName
      put the result into domainErrorArray
      --
      put the result into domainErrorArray
   end repeat
   delete char -1 of missingFolders
   return missingFolders
end atopia_MoveAllBadFoldersToTrash

command atopia_MoveToTrash shortWikiFolder
   -- moves a top level wiki folder to trash
   -- checks atopia_DomainIsBad() among other things
   
   put atopia_GetDomainErrorArray() into domainErrorArray
   
   -- let's do lot's of checks
   if shortWikiFolder is empty then
      breakpoint
      return empty
   end if
   -- we are assuming it is a bad folder
   if atopia_DomainIsBad (shortWikiFolder, domainErrorArray) is false then
      put "This wiki is not bad!" into someQuestion
      lcw_AnswerSheet someQuestion, empty, true
      exit to top
   end if
   --
   -- /root/.wiki/sub.domain.wiki/ -- absolute path for safety
   put atopia_WikiDomainFolder (shortWikiFolder) into remoteWikiFolderPath
   if remoteWikiFolderPath begins with "/root/.wiki/" is false then
      breakpoint
      return empty
   end if
   
   --
   atopia_MoveFoldertoTrash remoteWikiFolderPath
   put the result into moveResult
   --
   if moveResult is not empty then
      put moveResult
      lcw_WarnAndExit "Fail to move domain to wiki_trash folder"
   end if
   
   -- tidy domainErrorArray
   put domainErrorArray ["bad"][shortWikiFolder] into badFolderWikiFiles -- probably empty
   delete variable domainErrorArray ["bad"][shortWikiFolder]
   put badFolderWikiFiles into domainErrorArray ["_trash"][shortWikiFolder]
   --
   atopia_SetDomainErrorArray domainErrorArray
   --
   return domainErrorArray
end atopia_MoveToTrash

command atopi_MoveGoodToUnhosted pGoodFolders
   if pGoodFolders is empty then
      put atopia_ListLocalGoodFolders() into pGoodFolders
   end if
   --
   put atopia_GetDomainErrorArray() into domainErrorArray
   put atopia_GetIP() into dropletIP
   --
   repeat for each line goodShortFolder in pGoodFolders
      set the cursor to busy
      put goodShortFolder
      --
      put dig_GetIP (goodShortFolder) into testIP
      --
      if testIP = dropletIP then
         -- it's good so let's add some DNS information for fun
         _AddDnsToAtopiaArray domainErrorArray, goodShortFolder, testIP
      else
         -- let's move it
         atopia_MoveToUnhosted goodShortFolder
         --
         put goodShortFolder & CR after goodFoldersMoved
         put the result into domainErrorArray
      end if
   end repeat
   delete char -1 of goodFoldersMoved
   return goodFoldersMoved
end atopi_MoveGoodToUnhosted

private command _AddDnsToAtopiaArray @domainErrorArray, goodShortFolder, testIP
   put dig_GetNS (goodShortFolder) into dnsArray
   put dnsArray into domainErrorArray ["dns"][goodShortFolder]["NS"]
   put testIP into domainErrorArray ["dns"][goodShortFolder]["A record"]
   
   -- in case we crash :)
   atopia_SetDomainErrorArray domainErrorArray
   return dnsArray
end _AddDnsToAtopiaArray

command atopia_MoveToUnhosted shortWikiFolder
   put atopia_GetDomainErrorArray() into domainErrorArray
   
   -- let's do lot's of checks
   if shortWikiFolder is empty then
      breakpoint
      put "The wiki domain is empty!" into someQuestion
      lcw_WarnAndExit someQuestion
   end if
   -- /root/.wiki/sub.domain.wiki/ -- absolute path for safety
   put atopia_WikiDomainFolder (shortWikiFolder) into domainFolder
   if domainFolder begins with "/root/.wiki/" is false then
      breakpoint
      put "The wiki domain is invalid!" into someQuestion
      lcw_WarnAndExit someQuestion
   end if
   
   -- we are assuming it is a good folder
   get atopia_DomainIsBad (shortWikiFolder, domainErrorArray)
   if it is true then
      put "This wiki is not good!" into someQuestion
      lcw_WarnAndExit someQuestion
   end if
   
   -- it must have NOT a valid A record
   put dig_GetIP (shortWikiFolder) into aRecord
   put atopia_GetIP() into dropletIP
   if aRecord = dropletIP then
      put aRecord
      put "This wiki is hosted on Atopia!" into someQuestion
      lcw_WarnAndExit someQuestion
   end if
   
   --
   put atopia_UnhostedFolder() into unhostedFolder
   put "mv" && domainFolder && unhostedFolder into remoteShell
   atopia_DoRemoteShell remoteShell
   put the result into moveResult
   if moveResult is not empty then
      put moveResult
      lcw_WarnAndExit "Fail to move domain to wiki_trash folder"
   end if
   --
   
   -- tidy domainErrorArray
   put domainErrorArray ["good"][shortWikiFolder] into goodPageIndex
   put goodPageIndex into domainErrorArray ["_unhosted_sites"][shortWikiFolder] 
   delete variable domainErrorArray ["good"][shortWikiFolder]
   --
   atopia_SetDomainErrorArray domainErrorArray
   --
   return domainErrorArray
end atopia_MoveToUnhosted

private command atopia_MoveFoldertoTrash remoteWikiFolderPath
   -- dangerous (no checking)
   put atopia_TrashFolder() into trashFolder
   put "mv" && remoteWikiFolderPath && trashFolder into remoteShell
   --
   atopia_DoRemoteShell remoteShell
   put the result into moveResult
   return moveResult
end atopia_MoveFoldertoTrash


--> Atopia | Domain | Owner
-
function atopia_FindOwnerArray wikiDomain, pConfigArray
   put atopia_FetchOwnerArray (wikiDomain) into ownerArray
   if ownerArray is an array then return ownerArray
   
   -- let's try the config.json
   put atopia_GetOwnerArrayFromConfig (wikiDomain, pConfigArray) into ownerArray
   if ownerArray is an array then return ownerArray
   
   -- let's see if it an old persona site
   put atopia_FetchPersonaEmail (wikiDomain) into personaEmail
   if personaEmail is not empty then
      put fedwiki_ConstructPersonaOwnerArray (personaEmail) into ownerArray
      return ownerArray
   end if
   
   return empty
end atopia_FindOwnerArray

function atopia_FindEmail wikiDomain, pConfigArray
   -- looks in local owner.json and if not for id file specified in config.json
   put atopia_FetchOwnerArray (wikiDomain) into ownerArray
   put fedwiki_GetOwnerEmail (ownerArray) into ownerEmail
   if ownerEmail is not empty then return ownerEmail
   
   -- let's try the config.json
   put atopia_GetOwnerArrayFromConfig (wikiDomain, pConfigArray) into ownerArray
   put fedwiki_GetOwnerEmail (ownerArray) into ownerEmail
   return ownerEmail
end atopia_FindEmail

function atopia_GetOwnerArrayFromConfig wikiDomain, pConfigArray
   if pConfigArray is not an array then
      put atopia_FetchConfigArray() into pConfigArray
   end if
   set the itemdelimiter to "."
   put the number of items of wikiDomain -1 into maxNum
   put wikiDomain into testDomain
   repeat maxNum
      put pConfigArray ["wikiDomains"][testDomain]["id"] into ownerFilePath
      if ownerFilePath is not empty then next repeat
      delete item 1 of testDomain
   end repeat
   
   if ownerFilePath is empty then return empty
   --
   put digitalOcean_FetchFile (ownerFilePath, "Atopia", "root") into ownerJSON
   put json_ToArray (ownerJSON) into ownerArray
   return ownerArray
end atopia_GetOwnerArrayFromConfig

function atopia_FetchOwnerArray wikiDomain
   put atopia_FetchOwnerJson (wikiDomain) into ownerJSON
   put json_ToArray (ownerJSON) into ownerArray
   return ownerArray
end atopia_FetchOwnerArray

function atopia_FetchPersonaEmail wikiDomain
   put atopia_WikiStatusFolder (wikiDomain) into wikiStatusFolder
   put wikiStatusFolder & "persona.identity" into ownerJsonPath
   
   put digitalOcean_FetchFile (ownerJsonPath, "Atopia", "root") into personaData
   return personaData
end atopia_FetchPersonaEmail


--> Atopia | Model | Config
-
function atopia_FetchConfigFolderList
   put atopia_FetchConfigArray() into configArray
   put configArray ["wikidomains"] into wikiDomainArray
   put keys (wikiDomainArray) into wikiDomains
   return wikiDomains
end atopia_FetchConfigFolderList

function atopia_FetchConfigArray
   put atopia_FetchConfigJSON() into configJSON
   put json_ToArray (configJSON) into configArray
   return configArray
end atopia_FetchConfigArray


--> Private
-
private function atopia_ConstructGoodBadNumArray @domainErrorArray, pMinNum
   /*
   Not needed now??
   
   This is a crappy way to index things
   As given that each domain must be unique, we don't need to care about the order?
   Use numbered arrays instead? Or work out dynamically
   */
   
   put atopia_ListLocalWikiFolders (domainErrorArray) into wikiFolders
   put 1 into lineNum
   repeat for each line wikiFolder in wikiFolders
      put atopia_DomainIsBad (wikiFolder, domainErrorArray) into isBad
      if isBad is true then
         put lineNum & comma after badNums
      else
         put lineNum & comma after goodNums
      end if
      add 1 to lineNum
   end repeat
   
   -- think this is not needed
   put pMinNum into domainInfoArray ["minNum"]
   put goodNums into domainInfoArray ["goodNums"]
   put badNums into domainInfoArray ["badNums"]
   return domainInfoArray
end atopia_ConstructGoodBadNumArray
