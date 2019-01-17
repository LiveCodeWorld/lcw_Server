script "lib_Atopia"
--> MetaData
-
license: GPLv3
name: lib_Atopia
type: library
version: 0.3

/*
This library is for processing and interfacing with wiki folders on the Atopia server.
Carful with it as it does a lot of moving and deleting of files and folders using ssh
*/

--> Variables
-
constant ReservedFolderNames = "_old_sites,_unhosted_sites,_trash,fedwiki_owners"


--> Working on
-
function atopia_FetchFarmStatus nsType, domainName
   switch nsType
      case "digitalocean"
         put digitalocean_GetDomainArray (domainName) into domainArray
         put domainArray ["domain_records"] into recordArray
         repeat for each key indexNum in recordArray
            if recordArray [indexNum]["type"] = "A" and recordArray [indexNum]["name"] begins with "*." then
               return true
            end if
         end repeat
         return false
      case "dynadot"
         -- while the api is down
         return false
      default
         -- just a guess
         return empty
   end switch
end atopia_FetchFarmStatus

function atopia_FetchNameServerType domainName
   put dig_GetNS (domainName) into nameServers
   set the itemdelimiter to "."
   return item -2 of nameServers
end atopia_FetchNameServerType


--> Atopia | Update
-
command atopia_UpdateArrayAndMove pWikiFolders
   -- this should step through all tests and update everything
   -- moving folders to trash or unhosted as needed
   
   -- defaults to processing new folders
   if pWikiFolders is empty then
      put atopia_FetchNewFolderList() into pWikiFolders
   end if
   put atopia_GetData() into atopiaData
   
   -- let's update bad ones
   -- first check how many wiki pages each domain has
   atopia_AddToDomainErrorArray atopiaData, pWikiFolders
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
   
   -- now let's check that the good folders left are hosted
   put pWikiFolders into newGoodFoldersleft
   line_DeleteIndex newGoodFoldersleft, addedBadFolders
   if newGoodFoldersleft is empty then return resultArray
   
   -- now let's move those unhosted folders
   atopi_MoveGoodToUnhosted newGoodFoldersleft
   put the result into movedToUnhosted
   -- atopi_MoveGoodToUnhosted also does atopia_SetData
   put movedToUnhosted into resultArray ["movedToUnhosted"]
   
   -- perhaps removed a few more
   line_DeleteIndex newGoodFoldersleft, movedToUnhosted
   if newGoodFoldersleft is empty then return resultArray
   
   -- now we have the good new folders
   -- from here we add them to local good folder store
   -- the bad ones should already be moved
   -- these three sstages could be done as one write to the database
   put atopia_GetData() into atopiaData
   atopia_AddToDomainErrorArray atopiaData, newGoodFoldersleft
   atopia_SetData atopiaData
   
   -- and update the ownership and dns array entries
   --
   -- now update the ownershipArray for the hosted good folders
   put atopia_GetOwnershipArray() into ownershipArray
   atopia_AddOwnershipToDomainArray ownershipArray, newGoodFoldersleft
   atopia_SetOwnershipArray ownershipArray
   put newGoodFoldersleft into resultArray ["newGoodFoldersAdded"]
   
   -- and add DNS entries
   put atopia_GetDomainDnsArray() into dnsArray
   atopia_AddDnsToDomainArray dnsArray, newGoodFoldersleft
   atopia_SetDomainDnsArray dnsArray
   
   return resultArray
end atopia_UpdateArrayAndMove


--> Atopia | Model | Build
-
command atopia_AddToDomainErrorArray @atopiaData, wikiFolders, pMinNum
   if pMinNum is empty then put 1 into pMinNum
   
   repeat for each line wikiFolder in wikiFolders
      set the cursor to busy
      if wikiFolder is among the items of ReservedFolderNames then next repeat
      --
      put atopia_FetchWikiPageList (wikiFolder) into wikiPages
      if the number of lines of wikiPages > pMinNum then
         put wikiPages into atopiaData ["good"][wikiFolder]
         delete variable atopiaData ["bad"][wikiFolder]
      else
         put wikiPages into atopiaData ["bad"][wikiFolder]
         delete variable atopiaData ["good"][wikiFolder]
         put wikiFolder & CR after addedBadFolders
      end if
      add 1 to lineNum
   end repeat
   delete char -1 of addedBadFolders
   
   -- not needed now?
   -- put atopia_ConstructGoodBadNumArray (atopiaData, pMinNum) into domainInfoArray
   -- put domainInfoArray into atopiaData ["info"]
   return addedBadFolders
end atopia_AddToDomainErrorArray

command atopia_FilterAllFolderArray @folderArray
   -- let's filter
   repeat for each key folderName in folderArray
      switch
         case folderName begins with "."
         case folderName begins with "_"
         case folderName is among the items of ReservedFolderNames
            delete variable folderArray [folderName]
            put folderName & CR after removedFolderNames
            break
         default
            -- it's ok
      end switch
   end repeat
   delete char -1 of removedFolderNames
   return removedFolderNames
end atopia_FilterAllFolderArray

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
         put wikiPages into atopiaData ["good"][wikiFolder]
      else
         put wikiPages into atopiaData ["bad"][wikiFolder]
      end if
      add 1 to lineNum
   end repeat
   
   -- not deeded?
   put atopia_ConstructGoodBadNumArray (atopiaData, pMinNum) into domainInfoArray
   put domainInfoArray into atopiaData ["info"]
   
   return atopiaData
end atopia_FetchAndBuildArray


--> Atopia | Model | Construct
-
command atopia_ConstructDnsArray pDeleteExisting
   put atopia_FetchAllFolderList() into wikiFolders
   if pDeleteExisting is true then
      atopia_SetDomainDnsArray empty
      put empty into dnsArray
   else
      put atopia_GetDomainDnsArray() into dnsArray
   end if
   --
   atopia_AddDnsToDomainArray dnsArray, wikiFolders
   --
   atopia_SetDomainDnsArray dnsArray
   put the result into modelDataFile
   return modelDataFile
end atopia_ConstructDnsArray

command atopia_AddDnsToDomainArray @dnsArray, wikiFolders
   repeat for each line wikiFolder in wikiFolders
      set the cursor to busy
      if wikiFolder is among the items of ReservedFolderNames then next repeat
      --
      put dig_GetIP (wikiFolder) into testIP
      put dig_GetNS (wikiFolder) into nsList
      --
      put nsList into dnsArray [wikiFolder]["NS"]
      put testIP into dnsArray [wikiFolder]["A record"]
   end repeat
end atopia_AddDnsToDomainArray


--> Atopia | Check

function atopia_RemoteWikiFolderExists folderName, pRemoteFolderArray
   if pRemoteFolderArray is empty then
      put atopia_FetchFilteredFolderLsArray() into pRemoteFolderArray
   end if
   
   put folderName is among the keys of pRemoteFolderArray into remoteExists
   return remoteExists
end atopia_RemoteWikiFolderExists

function atopia_TrashFolderExists trashDomain
   -- could check it is a folder and not a file
   put atopia_FolderInTrashFolder (trashDomain) into folderInTrashFolder
   put "ls -la" && folderInTrashFolder into remoteShell
   _DoAtopiaShell remoteShell
   if the result begins with "ls: cannot access" then
      return false
   else
      return true
   end if
end atopia_TrashFolderExists

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
      put the result into atopiaData
      --
      put the result into atopiaData
   end repeat
   delete char -1 of missingFolders
   return missingFolders
end atopia_MoveAllBadFoldersToTrash

command atopia_MoveToTrash shortWikiFolder
   -- moves a top level wiki folder to trash
   -- checks atopia_DomainIsBadInDomainArray() among other things
   
   put atopia_GetData() into atopiaData
   
   -- let's do lot's of checks
   if shortWikiFolder is empty then
      breakpoint
      return empty
   end if
   -- we are assuming it is a bad folder
   if atopia_DomainIsBadInDomainArray (shortWikiFolder, atopiaData) is false then
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
   
   -- tidy atopiaData 
   -- now that we've moved it remove from local bad
   put atopiaData ["bad"][shortWikiFolder] into badFolderWikiFiles -- probably empty
   delete variable atopiaData ["bad"][shortWikiFolder]
   put badFolderWikiFiles into atopiaData ["_trash"][shortWikiFolder]
   --
   atopia_SetData atopiaData
   --
   return atopiaData
end atopia_MoveToTrash

private command atopia_MoveFoldertoTrash remoteWikiFolderPath
   -- dangerous (no checking)
   set the itemdelimiter to slash
   put item -1 of remoteWikiFolderPath into trashDomain
   atopia_DeleteFolderInTrash trashDomain
   --
   put atopia_TrashFolder() into trashFolder
   put "mv -f" && remoteWikiFolderPath && trashFolder into remoteShell
   -- put space & "&& rmdir" && remoteWikiFolderPath after remoteShell
   --
   _DoAtopiaShell remoteShell
   put the result into moveResult
   return moveResult
end atopia_MoveFoldertoTrash

command atopia_DeleteFolderInTrash trashDomain
   -- super dangerous (no checking)
   set the itemdelimiter to slash
   put item -1 of trashDomain into trashDomain
   --
   put atopia_FolderInTrashFolder (trashDomain) into folderInTrashFolder
   put atopia_TrashFolderExists (trashDomain) into alreadyThere
   if alreadyThere is false then return empty
   --
   put "rm -rf" && folderInTrashFolder into remoteShell
   _DoAtopiaShell remoteShell
   --
   put the result into deleteResult
   return deleteResult
end atopia_DeleteFolderInTrash

command atopi_MoveGoodToUnhosted pGoodFolders, pForce
   if pGoodFolders is empty then
      put atopia_ListLocalGoodFolders() into pGoodFolders
   end if
   --
   put atopia_GetData() into atopiaData
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
         _AddDnsToAtopiaArray atopiaData, goodShortFolder, testIP
      else
         -- let's move it
         atopia_MoveToUnhosted goodShortFolder
         --
         put goodShortFolder & CR after goodFoldersMoved
         put the result into atopiaData
      end if
   end repeat
   delete char -1 of goodFoldersMoved
   return goodFoldersMoved
end atopi_MoveGoodToUnhosted

command atopia_MoveToUnhosted shortWikiFolder
   put atopia_GetData() into atopiaData
   
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
   get atopia_DomainIsBadInDomainArray (shortWikiFolder, atopiaData)
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
   _DoAtopiaShell remoteShell
   put the result into moveResult
   if moveResult is not empty then
      put moveResult
      lcw_WarnAndExit "Fail to move domain to wiki_trash folder"
   end if
   --
   
   -- tidy atopiaData
   put atopiaData ["good"][shortWikiFolder] into goodPageIndex
   put goodPageIndex into atopiaData ["_unhosted_sites"][shortWikiFolder] 
   delete variable atopiaData ["good"][shortWikiFolder]
   --
   atopia_SetData atopiaData
   --
   return atopiaData
end atopia_MoveToUnhosted


--> Private
-
private function atopia_ConstructGoodBadNumArray @atopiaData, pMinNum
   /*
   Not needed now??
   
   This is a crappy way to index things
   As given that each domain must be unique, we don't need to care about the order?
   Use numbered arrays instead? Or work out dynamically
   */
   
   put atopia_ListLocalWikiFolders (atopiaData) into wikiFolders
   put 1 into lineNum
   repeat for each line wikiFolder in wikiFolders
      put atopia_DomainIsBadInDomainArray (wikiFolder, atopiaData) into isBad
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


--> Private
-
private command _DoAtopiaShell remoteShell
   -- carefull with this
   -- with the right private ssh key a dangerous sheel command can wipe the entire server
   
   put atopia_GetIP() into dropletIP
   ssh_DoRemoteShell AtopiaSshUser, dropletIP, remoteShell
   put the result into shellResult
   return shellResult
end _DoAtopiaShell

private command _AddDnsToAtopiaArray @atopiaData, goodShortFolder, testIP
   put dig_GetNS (goodShortFolder) into dnsArray
   put dnsArray into atopiaData ["dns"][goodShortFolder]["NS"]
   put testIP into atopiaData ["dns"][goodShortFolder]["A record"]
   
   -- in case we crash :)
   atopia_SetData atopiaData
   return dnsArray
end _AddDnsToAtopiaArray
